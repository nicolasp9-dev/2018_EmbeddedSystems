-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart is
end;

architecture testbench of tb_uart is
    constant CLK_PERIOD : time := 20 ns;

    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';

    signal address      : std_logic_vector(1 downto 0) := (others => '0');

    signal read_value   : std_logic_vector(31 downto 0) := (others => '0');
    signal read         : std_logic := '0';

    signal write_value  : std_logic_vector(31 downto 0) := (others => '0');
    signal write        : std_logic := '0';
    signal chip_select  : std_logic := '1';

    signal tx           : std_logic := '0';
    signal rx           : std_logic := '0';

    signal check_value  : std_logic_vector(31 downto 0) := (others => '0');
    signal finished : std_logic := '0';

begin
    uart_0 : ENTITY work.uart port map(
        clk             => clk,
        reset           => reset,

        avs_address     => address,

        avs_read        => read,
        avs_readdata    => read_value,

        avs_write       => write,
        avs_writedata   => write_value,

        -- External Tx / Rx Transmission
        tx              => tx,
        rx              => rx
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
        REPORT "************** START ***************" SEVERITY NOTE;

        --init
        rx <= '1';
        reset <= '0';
        wait for CLK_PERIOD * 3 / 2;
        reset <= '1';

        REPORT "******* Will write data for transmiting (Tx) *******" SEVERITY NOTE;

        address <= std_logic_vector(to_unsigned(2, 2));
        -- Write 100 data over from the processor
        for i in 0 to 100 loop
            write <= '1';
            write_value <= std_logic_vector(to_unsigned(i * 2, 32));
            wait for CLK_PERIOD;
            write <= '0';
            wait for CLK_PERIOD;
        end loop;

        REPORT "******* Will check transmitted data *******" SEVERITY NOTE;

        for i in 1 to 100 loop
            check_value <= std_logic_vector(to_unsigned(i * 2, 32));
            wait until falling_edge(tx);

            wait for 52 us;
            ASSERT tx = '0'
                REPORT "Step 1 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = check_value(0)
                REPORT "Step 2 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = check_value(1)
                REPORT "Step 3 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = check_value(2)
                REPORT "Step 4 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = check_value(3)
                REPORT "Step 5 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = check_value(4)
                REPORT "Step 6 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = check_value(5)
                REPORT "Step 7 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = check_value(6)
                REPORT "Step 8 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = check_value(7)
                REPORT "Step 9 failed"
                SEVERITY ERROR;

            wait for 105 us;

            ASSERT tx = '1'
                REPORT "Step 10 failed"
                SEVERITY ERROR;

        end loop;

        address <= std_logic_vector(to_unsigned(1, 2));
        read <= '1';
        wait for CLK_PERIOD * 3 / 2;
        ASSERT read_value = std_logic_vector(to_unsigned(0, 32))
            REPORT "Buffer flag is not 0"
            SEVERITY ERROR;
        read <= '0';

        REPORT "******* Will read data for reception (Rx) *******" SEVERITY NOTE;

        for i in 0 to 50 loop
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
        end loop;

        address <= std_logic_vector(to_unsigned(1, 2));
        read <= '1';
        wait for CLK_PERIOD;
        ASSERT read_value = std_logic_vector(to_unsigned(1, 32))
            REPORT "Buffer flag is not 1"
            SEVERITY ERROR;
        read <= '0';

        REPORT "******* Will check received data *******" SEVERITY NOTE;

        wait until rising_edge(clk);
        wait for CLK_PERIOD * 3 / 2;
        address <= std_logic_vector(to_unsigned(3, 2));
        for i in 0 to 50 loop
            read <= '1';
            check_value <= std_logic_vector(to_unsigned(i * 4, 32));
            wait for CLK_PERIOD;
            ASSERT read_value = check_value
                REPORT "Read data in buffer incorrect"
                SEVERITY ERROR;
            read <= '0';
            wait for CLK_PERIOD;
        end loop;

        REPORT "************** END ***************" SEVERITY NOTE;
        finished <= '1';
        wait;
    end process;

end testbench;