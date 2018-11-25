-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_read is
end;

architecture testbench of tb_read is
    constant CLK_PERIOD : time := 40 ns;

    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal parity       : std_logic := '0';
    signal rate         : std_logic_vector(3 downto 0) := (others => '0');
    signal word_lenth   : std_logic_vector(2 downto 0) := (others => '0');
    signal rx           : std_logic;

    signal read         : std_logic := '0';
    signal rddata       : std_logic_vector(7 downto 0);

    signal check_value  : std_logic_vector(31 downto 0);
    signal finished : std_logic := '0';

begin
    read_0 : ENTITY work.read port map(
        clk  => clk,
        reset => reset,

        read => read,
        rddata  => rddata,

        word_lenth  => word_lenth,
        parity => parity,
        rate  => rate,
        rx => rx
    );

    process
    begin
        clk <= not clk;
        wait for CLK_PERIOD / 2;
        if (finished = '1') then
            wait;
        end if;
    end process;

    process
    begin
        --init
        rx <= '1';
        reset <= '0';
        wait for CLK_PERIOD * 3 / 2;
        reset <= '1';
        wait for 105 us;
        for i in 0 to 36 loop
            check_value <= std_logic_vector(to_unsigned(i * 4, 32));
            rx <= '0';
            wait for 105 us;
            rx <= check_value(0);
            wait for 105 us;
            rx <= check_value(1);
            wait for 105 us;
            rx <= check_value(2);
            wait for 105 us;
            rx <= check_value(3);
            wait for 105 us;
            rx <= check_value(4);
            wait for 105 us;
            rx <= check_value(5);
            wait for 105 us;
            rx <= check_value(6);
            wait for 105 us;
            rx <= check_value(7);
            wait for 105 us;
            rx <= '1';
            wait for 105 us;
            ASSERT rddata = check_value(7 downto 0)
                REPORT "Data not as expected"
                SEVERITY ERROR;
        end loop;

        finished <= '1';
        wait;
    end process;

end testbench;
