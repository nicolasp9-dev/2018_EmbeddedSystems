-- Author: Nicolas Peslerbe | Embedded system course | Camera Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity camera_control is
    port(
        clk         : in  std_logic;
        reset_n       : in std_logic;

        -- Avalon Slave bus transmission
        avs_address : in std_logic_vector(3 downto 0);
        avs_read    : in std_logic;
        avs_readdata: out std_logic_vector(31 downto 0);
        avs_write   : in std_logic;
        avs_writedata:in std_logic_vector(31 downto 0);
        avs_irq_n: out std_logic;

        -- Avalon Master bus transmission
        avm_address : out std_logic_vector(31 downto 0);
        avm_byteenable_n : out std_logic_vector(3 downto 0);
        avm_burstcount : out std_logic_vector(2 downto 0);
        avm_write : out std_logic;
        avm_writedata : out std_logic_vector(31 downto 0);
        avm_waitrequest : in std_logic;

        -- Camera interface
        cam_reset_n : out std_logic;
        cam_data : in std_logic_vector(11 downto 0);
        cam_pixelclk : in std_logic;
        cam_lvalid : in std_logic;
        cam_fvalid : in std_logic

    );
end camera_control;

architecture synth of camera_control is

begin


end synth;