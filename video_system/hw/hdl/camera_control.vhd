-- Author: Nicolas Peslerbe | Embedded system course | Camera Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity camera_control is
    port(
        clk         : in  std_logic;
        reset_n       : in std_logic;

        -- Avalon bus transmission
        avs_address : in std_logic_vector(3 downto 0);
        avs_read    : in std_logic;
        avs_readdata: out std_logic_vector(31 downto 0);
        avs_write   : in std_logic;
        avs_writedata:in std_logic_vector(31 downto 0);


    );
end camera_control
;
