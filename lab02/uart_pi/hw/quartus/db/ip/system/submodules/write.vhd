-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity write is
    port(
        clk         : in  std_logic;
        reset       : in  std_logic;

        written   : out  std_logic;
        write       : in  std_logic;
        wrdata      : in  std_logic_vector(7 downto 0);

        word_lenth  : in   std_logic_vector(2 downto 0);
        parity      : in   std_logic;
        rate        : in   std_logic_vector(3 downto 0);
        tx          : out  std_logic
    );
end write;

architecture synth of write is

    signal counter : std_logic_vector(16 downto 0) := (others => '0');
    signal counter_stop_value : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(5208, 16));
    signal current_step : std_logic_vector(3 downto 0) := (others => '0');
    signal change_step : std_logic := '0';
    signal raz : std_logic := '0';

begin
    counter_func : process(clk, reset)
    begin
        if reset = '0' then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            change_step <= '0';
            if raz = '1' then
                counter <= (others => '0');
            elsif to_integer(unsigned(counter)) = to_integer(unsigned(counter_stop_value)) then
                change_step <= '1';
                counter <= (others => '0');
            else
                counter <= std_logic_vector(unsigned(counter) + 1);
            end if;
        end if;
    end process;

    counter_end : process(clk, reset)
    begin
        if reset = '0' then
            counter_stop_value <= std_logic_vector(to_unsigned(5208, counter_stop_value'length));
        elsif rising_edge(clk) then
            case rate is
                when "0001" => counter_stop_value <= std_logic_vector(to_unsigned(217, counter_stop_value'length));  -- bd rate 115200
                when "0010" => counter_stop_value <= std_logic_vector(to_unsigned(434, counter_stop_value'length));  -- bd rate 57600
                when "0011" => counter_stop_value <= std_logic_vector(to_unsigned(651, counter_stop_value'length)); -- bd rate 38400
                when "0100" => counter_stop_value <= std_logic_vector(to_unsigned(1302, counter_stop_value'length)); -- bd rate 19200
                when "0101" => counter_stop_value <= std_logic_vector(to_unsigned(5208, counter_stop_value'length));-- bd rate 4800
                when "0110" => counter_stop_value <= std_logic_vector(to_unsigned(10416, counter_stop_value'length));-- bd rate 2400
                when "0111" => counter_stop_value <= std_logic_vector(to_unsigned(20833, counter_stop_value'length));-- bd rate 1200
                when others  => counter_stop_value <= std_logic_vector(to_unsigned(5208, counter_stop_value'length));-- bd rate 9600 (default)
            end case;
        end if;
    end process;

    write_uart : process(clk, reset)
    begin
        if reset = '0' then
            current_step <= (others => '0');
        elsif rising_edge(clk)  then
            written <= '0';
            raz <= '0';
            if to_integer(unsigned(current_step)) = 12 then
                current_step <= (others => '0');
            elsif to_integer(unsigned(current_step)) = 11 and change_step = '1' then
                written <= '1';
                current_step <= std_logic_vector(unsigned(current_step) + 1);
            elsif (to_integer(unsigned(current_step)) /= 0 and change_step = '1') then
                current_step <= std_logic_vector(unsigned(current_step) + 1);
            elsif (to_integer(unsigned(current_step)) = 0 and write = '1') then
                current_step <= std_logic_vector(unsigned(current_step) + 1);
                raz <= '1';
            end if;
        end if;
    end process;

    state_machine : process(current_step)
    begin
        case to_integer(unsigned(current_step)) is
            when 1 =>
                tx <= '0';
            when 2 to 9  =>  tx <= wrdata(to_integer(unsigned(current_step)-2));
            when 10 =>
                if parity = '1' then
                    tx <= '0';
                else
                    tx <= '1';
                end if;
            when 11 =>
                tx <= '1';
            when others =>
                tx <= '1';
        end case;
    end process state_machine;

end synth;
