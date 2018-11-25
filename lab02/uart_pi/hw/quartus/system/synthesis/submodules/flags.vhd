-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flags is
    port(
        clk         : in  std_logic;
        reset       : in  std_logic;

        read        : in  std_logic;
        rddata      : out  std_logic_vector(7 downto 0);
        data_to_read : in  std_logic
    );
end flags;

architecture synth of flags is
begin

    get_flag : process(clk)
    begin
        if rising_edge(clk) then
            rddata <= (std_logic_vector(to_unsigned(0,7))  & data_to_read);
        end if;
    end process get_flag;

end synth;
