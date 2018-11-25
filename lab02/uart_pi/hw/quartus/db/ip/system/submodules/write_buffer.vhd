-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity write_buffer is
    port(
        clk         : in  std_logic;
        not_empty   : out  std_logic;
        reset       : in  std_logic;
        next_item   : in  std_logic;
        write       : in  std_logic;
        wrdata      : in  std_logic_vector(7 downto 0);
        rddata      : out std_logic_vector(7 downto 0)
    );
end write_buffer;

architecture synth of write_buffer is

     -- The buffer memoriescontent, internal to the block, buffer size is 1024 octets, of 8 bits data
     type buffer_content is array(0 to 1023) of std_logic_vector(7 downto 0);
     signal reg : buffer_content := (others => (others => '0'));

     -- The current read and write adress to create a rotating buffer : 0 at the beginning
     signal buffer_write_address : std_logic_vector(9 downto 0) := (others => '0');
     signal buffer_read_address : std_logic_vector(9 downto 0) := (others => '0');
     signal ready : std_logic := '0';

begin

    -- return true everytime the write adress is different with the read adress, it means that data must be send over UART
    data_presence_check_func : process(clk, reset)
    begin
        if (reset = '0') then
            not_empty <= '0';
        elsif rising_edge(clk) then
            if buffer_read_address = buffer_write_address then
                not_empty <= '0';
            else
                not_empty <= '1';
            end if;
        end if;
    end process data_presence_check_func;

    -- Switch the reading process to the next address
    read_next_func : process(reset, clk)
    begin
        if (reset = '0') then
            buffer_read_address <= (others => '0');
            ready <= '1';
        elsif rising_edge(clk) then
            if  next_item = '1' then
                ready <= '0';
                if buffer_read_address /= buffer_write_address then
                    buffer_read_address <= std_logic_vector(unsigned(buffer_read_address) + 1);
                    rddata <= reg(to_integer(unsigned(buffer_read_address)));
                else
                    ready <= '1';
                end if;
            elsif ready = '1' and buffer_read_address /= buffer_write_address then
                ready <= '0';
                buffer_read_address <= std_logic_vector(unsigned(buffer_read_address) + 1);
                rddata <= reg(to_integer(unsigned(buffer_read_address)));
            end if;
        end if;
    end process read_next_func;


    -- If there is a need of write, it write the entering in memory and move to the next adress
    write_func : process(clk, reset)
    begin
        if (reset = '0') then
            buffer_write_address <= (others => '0');
        elsif rising_edge(clk) and write = '1' then
            reg(to_integer(unsigned(buffer_write_address))) <= wrdata;
            buffer_write_address <= std_logic_vector(unsigned(buffer_write_address) + 1);
        end if;
    end process write_func;

end synth;
