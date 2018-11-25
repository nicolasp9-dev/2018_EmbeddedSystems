-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_write_buffer is
end;

architecture testbench of tb_write_buffer is
    constant CLK_PERIOD : time := 40 ns;

    signal clk         : std_logic := '0';
    signal not_empty   : std_logic;
    signal reset       : std_logic := '0';
    signal next_item   : std_logic := '0';
    signal write       : std_logic := '0';
    signal wrdata      : std_logic_vector(7 downto 0);
    signal rddata      : std_logic_vector(7 downto 0);

    signal finished : std_logic := '0';

begin
    write_buffer_0 : ENTITY work.write_buffer port map(
        clk         => clk,
        not_empty   => not_empty,
        write       => write,
        next_item   => next_item,
        wrdata      => wrdata,
        rddata      => rddata,
        reset       => reset
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

        ASSERT not_empty = '0'
             REPORT "The buffer is supposed to be empty"
             SEVERITY ERROR;

        -- Write some data in the buffer
        write <= '1';
        for i in 0 to 31 loop
            wrdata <= std_logic_vector(to_unsigned(i * 4, 8));
            wait for CLK_PERIOD;
        end loop;
        write <= '0';

        ASSERT not_empty = '1'
             REPORT "The buffer is supposed to not be empty"
             SEVERITY ERROR;

        -- Read written data and check it
        for i in 0 to 31 loop
            ASSERT rddata = std_logic_vector(to_unsigned(i * 4, 8))
                REPORT "Did not read the correct value from the buffer"
                SEVERITY ERROR;
            next_item   <= '1';
            wait for CLK_PERIOD;
            next_item   <= '0';
            wait for CLK_PERIOD;
        end loop;

         ASSERT not_empty = '0'
             REPORT "The buffer is supposed to be empty"
             SEVERITY ERROR;

        -- Write and read with different timings
        write <= '1';
        for i in 140 to 231 loop
            wrdata <= std_logic_vector(to_unsigned(i, 8));
            if ((i mod 4 = 0) and (not_empty = '1')) then
                ASSERT rddata = std_logic_vector(to_unsigned(140+(i-140)/4 -1 , 8))
                    REPORT "Error in consecutive read"
                    SEVERITY ERROR;
                next_item   <= '1';
            end if;
            wait for CLK_PERIOD;
            next_item   <= '0';
        end loop;
        write <= '0';

        ASSERT not_empty = '1'
             REPORT "The buffer is supposed to not be empty"
             SEVERITY ERROR;

        -- Read last values in buffer
        for i in 162 to 231 loop
            ASSERT rddata = std_logic_vector(to_unsigned(i, 8))
                REPORT "End buffer reading failed"
                SEVERITY ERROR;
            next_item   <= '1';
            wait for CLK_PERIOD;
            next_item   <= '0';
            wait for CLK_PERIOD;
        end loop;

        ASSERT not_empty = '0'
             REPORT "The buffer is supposed to not be empty"
             SEVERITY ERROR;

        finished <= '1';
        wait;
    end process;

end testbench;
