-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity read is
    port(
        clk         : in  std_logic;
        reset       : in  std_logic;

        read        : out  std_logic;

        rddata      : out  std_logic_vector(7 downto 0);
        word_lenth  : in   std_logic_vector(2 downto 0);
        parity      : in   std_logic;
        rate        : in   std_logic_vector(3 downto 0);

        rx          : in   std_logic
    );
end read;

architecture synth of read is

    signal counter : std_logic_vector(15 downto 0) := (others => '0');
    signal counter_stop_value : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(5208, 16));
    signal counter_setted_stop_value : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(5208, 16));

    signal current_step : std_logic_vector(3 downto 0) := (others => '0');
    signal change_step : std_logic := '0';

    signal raz : std_logic := '0';
    signal rx_vector : std_logic_vector(7 downto 0);
    signal read_vector : std_logic_vector(7 downto 0);
begin
    counter_func : process(clk, reset)
    begin
        if reset = '0' then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            change_step <= '0';
            if raz = '1' then
                counter <= x"0000";
                counter_setted_stop_value <= std_logic_vector(unsigned(counter_stop_value) + unsigned(shift_right(unsigned(counter_stop_value), 1)));
            elsif to_integer(unsigned(counter)) = to_integer(unsigned(counter_setted_stop_value)) then
                if to_integer(unsigned(current_step)) /= 0 then
                    change_step <= '1';
                    counter_setted_stop_value <= counter_stop_value;
                end if;
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


    read_uart : process(clk, reset)
    begin
        if reset = '0' then
            current_step <= std_logic_vector(to_unsigned(0,4));
            read_vector <= x"00";
            raz <= '0';
        elsif rising_edge(clk) then
            read <= '0';
            raz <= '0';
            if (rx = '0') and (to_integer(unsigned(current_step)) = 0) then
                current_step <= std_logic_vector(unsigned(current_step) + 1);
                read_vector <= x"00";
                raz <= '1';
            elsif (change_step = '1') then
                if rx = '1' then
                    rx_vector <= std_logic_vector(to_unsigned(1, 8));
                else
                    rx_vector <= std_logic_vector(to_unsigned(0, 8));
                end if;
                if (to_integer(unsigned(current_step)) = 9 and parity = '0') then
                    rddata <= read_vector or std_logic_vector(unsigned(shift_left(unsigned(rx_vector), to_integer(unsigned(current_step))-2)));
                    read <= '1';
                    current_step <= std_logic_vector(to_unsigned(0,4));

                elsif (to_integer(unsigned(current_step)) = 10 and parity = '1') then
                    current_step <= std_logic_vector(to_unsigned(0,4));

                else
                    current_step <= std_logic_vector(unsigned(current_step) + 1);
                    case to_integer(unsigned(current_step)) is
                        when 2 to 8 =>
                            read_vector <= read_vector or std_logic_vector(unsigned(shift_left(unsigned(rx_vector), to_integer(unsigned(current_step))-2)));
                        when 9 =>
                            rddata <= read_vector or std_logic_vector(unsigned(shift_left(unsigned(rx_vector), to_integer(unsigned(current_step))-2)));
                            read <= '1';
                        when others =>
                    end case;
                end if;
            end if;
        end if;

    end process;

end synth;
