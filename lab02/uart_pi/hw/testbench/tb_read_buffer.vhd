-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_read_buffer is
end;

architecture testbench of tb_read_buffer is
    constant CLK_PERIOD : time := 40 ns;

    signal clk         : std_logic := '0';
    signal not_empty   : std_logic;
    signal reset       : std_logic := '0';
    signal read        : std_logic := '0';
    signal write       : std_logic := '0';
    signal wrdata      : std_logic_vector(7 downto 0);
    signal rddata      : std_logic_vector(7 downto 0);

    signal finished : std_logic := '0';

begin
    read_buffer_0 : ENTITY work.read_buffer port map(
        clk         => clk,
        not_empty   => not_empty,
        write       => write,
        read        => read,
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
        for i in 0 to 31 loop
            write <= '1';
            wrdata <= std_logic_vector(to_unsigned(i * 4, 8));
            wait for CLK_PERIOD;
            write <= '0';
            wait for CLK_PERIOD;
        end loop;

        ASSERT not_empty = '1'
             REPORT "The buffer is supposed to not be empty"
             SEVERITY ERROR;

        -- Read written data and check it
        read  <= '1';
        for i in 0 to 31 loop
            wait for CLK_PERIOD;
            ASSERT rddata = std_logic_vector(to_unsigned(i * 4, 8))
                REPORT "Did not read the correct value from the buffer"
                SEVERITY ERROR;
        end loop;
        wait for CLK_PERIOD;
        ASSERT rddata = std_logic_vector(to_unsigned(0, 8))
            REPORT "Did not read the correct value from the buffer Must be 0 if end"
            SEVERITY ERROR;
        read  <= '0';
        wait for CLK_PERIOD;
        ASSERT rddata = std_logic_vector(to_unsigned(0, 8))
            REPORT "Did not read the correct value from the buffer Must be 0 if end"
            SEVERITY ERROR;

        ASSERT not_empty = '0'
             REPORT "The buffer is supposed to be empty"
             SEVERITY ERROR;



        finished <= '1';
        wait;
    end process;

end testbench;
