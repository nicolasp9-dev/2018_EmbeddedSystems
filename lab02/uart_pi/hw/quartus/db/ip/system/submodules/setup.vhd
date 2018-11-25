-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;

entity setup is
    port(
        clk         : in    std_logic;
        reset       : in    std_logic;
        data        : in    std_logic_vector(7 downto 0);
        must_record : in    std_logic;
        word_lenth  : out   std_logic_vector(2 downto 0);
        parity     : out   std_logic;
        rate        : out   std_logic_vector(3 downto 0)
    );
end setup;

architecture synth of setup is

    signal parameters : std_logic_vector(7 downto 0) := (others => '0');

begin

    word_lenth <= parameters(2 downto 0);
    parity <= parameters(3);
    rate <= parameters(7 downto 4);

    record_parameters_func : process(clk, reset)
    begin
        if reset = '0' then
            parameters <= (others => '0');
        elsif rising_edge(clk) and must_record = '1' then
            parameters <= data;
        end if;
    end process record_parameters_func;

end synth;
