library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is tb_camera_controller

end tb_camera_controller;

architecture testbench of tb_camera_controller is
    constant CLK_PERIOD : time := 40 ns;

    signal clk         : std_logic := '0';
    signal reset       : std_logic;

    signal finished : std_logic := '0';

begin
    camera_controller : ENTITY work.setup port map(
            clk         => clk,
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






        finished <= '1';
        wait;
    end process;

end testbench;
