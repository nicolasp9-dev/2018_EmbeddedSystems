-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_write is
end;

architecture testbench of tb_write is
    constant CLK_PERIOD : time := 40 ns;

    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal parity       : std_logic := '0';
    signal rate         : std_logic_vector(3 downto 0) := (others => '0');
    signal word_lenth   : std_logic_vector(2 downto 0) := (others => '0');
    signal tx    : std_logic;

    signal written     : std_logic := '0';
    signal write       : std_logic := '0';
    signal wrdata      : std_logic_vector(7 downto 0);

    signal finished : std_logic := '0';

begin
    write_0 : ENTITY work.write port map(
        clk  => clk,
        reset => reset,

        written => written,
        write  => write,
        wrdata  => wrdata,

        word_lenth  => word_lenth,
        parity => parity,
        rate  => rate,
        tx => tx
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
        write   <= '0';
        wrdata  <= (others => '0');
        reset <= '0';
        wait for CLK_PERIOD * 3 / 2;
        reset <= '1';

        parity <= '0';
        rate <= (others => '0');
        word_lenth <= (others => '0');

        for i in 0 to 31 loop
            -- Write some data on the bus
            wrdata <= std_logic_vector(to_unsigned(24*i, 8));
            write <= '1';

            wait until falling_edge(tx);

            wait for 52 us;
            ASSERT tx = '0'
                REPORT "Step 1 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = wrdata(0)
                REPORT "Step 2 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = wrdata(1)
                REPORT "Step 3 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = wrdata(2)
                REPORT "Step 4 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = wrdata(3)
                REPORT "Step 5 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = wrdata(4)
                REPORT "Step 6 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = wrdata(5)
                REPORT "Step 7 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = wrdata(6)
                REPORT "Step 8 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = wrdata(7)
                REPORT "Step 9 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = '1'
                REPORT "Step 10 failed"
                SEVERITY ERROR;
            ASSERT written = not parity
                REPORT "Step 10 check next mem"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT written = '0'
                REPORT "Step 11 check next mem"
                SEVERITY ERROR;
            ASSERT tx = '1'
                REPORT "Step 11 failed"
                SEVERITY ERROR;
        end loop;


        finished <= '1';
        wait;
    end process;

end testbench;