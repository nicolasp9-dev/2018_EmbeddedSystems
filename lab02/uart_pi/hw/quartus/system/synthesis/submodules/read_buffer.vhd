-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity read_buffer is
    port(
        clk         : in  std_logic;
        reset       : in  std_logic;
        not_empty   : out  std_logic;
        read        : in  std_logic;
        write       : in  std_logic;
        wrdata      : in  std_logic_vector(7 downto 0);
        rddata      : out std_logic_vector(7 downto 0)
    );
end read_buffer;

architecture synth of read_buffer is

    -- The buffer memory content, internal to the block, buffer size is 512 octets, of 8 bits dara
    type buffer_content is array(0 to 1023) of std_logic_vector(7 downto 0);
    signal reg : buffer_content := (others => (others => '0'));

    -- The current read and write adress to create a rotating buffer : 0 at the beginning
    signal buffer_write_address : std_logic_vector(9 downto 0) := (others => '0');
    signal buffer_read_address : std_logic_vector(9 downto 0) := (others => '0');
begin

    -- return true everytime the write adress is different with the read adress, it means that data must be send over UART
    empty_status_func : process(clk)
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
    end process empty_status_func;

    -- it everytime reads the value linked with the buffer_read_address
    read_func : process(clk, reset)
    begin
        if (reset = '0') then
            buffer_read_address <= (others => '0');
        elsif rising_edge(clk) then
            if (buffer_read_address /= buffer_write_address) then
                rddata <= reg(to_integer(unsigned(buffer_read_address)));
            else
                rddata <= "00000000";
            end if;
            if read = '1' then
                buffer_read_address <= std_logic_vector(unsigned(buffer_read_address) + 1);
            end if;
        end if;
    end process read_func;

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

