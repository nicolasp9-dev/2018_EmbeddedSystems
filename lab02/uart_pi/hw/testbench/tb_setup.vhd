-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_setup is
end tb_setup;

architecture testbench of tb_setup is
    constant CLK_PERIOD : time := 40 ns;

    signal clk         : std_logic := '0';
    signal data        : std_logic_vector(7 downto 0);
    signal must_record : std_logic := '0';
    signal word_lenth  : std_logic_vector(2 downto 0);
    signal parity     : std_logic;
    signal rate        : std_logic_vector(3 downto 0);
    signal reset       : std_logic;

    signal finished : std_logic := '0';

begin
    setup_0 : ENTITY work.setup port map(
            clk         => clk,
            reset       => reset,
            data        => data,
            must_record => must_record,
            word_lenth  => word_lenth,
            parity     => parity,
            rate        => rate
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
        must_record   <= '0';
        data <= (others => '0');
        reset <= '0';
        wait for CLK_PERIOD * 3 / 2;
        reset <= '1';

        -- Try to write and test if the output bits are as expected
        must_record <= '1';
        for i in 0 to 256 loop
            data <= std_logic_vector(to_unsigned(i, 8));
            wait for CLK_PERIOD;
            ASSERT word_lenth = data(2 downto 0)
                REPORT "Error with word_lenth"
                SEVERITY ERROR;
            ASSERT parity = data(3)
                REPORT "Error with parity"
                SEVERITY ERROR;
            ASSERT rate = data(7 downto 4)
                REPORT "Error with rate"
                SEVERITY ERROR;

        end loop;

        finished <= '1';
        wait;
    end process;

end testbench;
