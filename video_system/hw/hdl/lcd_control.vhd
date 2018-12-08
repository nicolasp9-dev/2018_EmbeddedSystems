-- Author: Kevin Sin | Embedded system course | LCD Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity lcd_control is
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

        -- LCD interface
        lcd_reset_n : out std_logic;
        lcd_data : out std_logic_vector(15 downto 0);
        lcd_on : out std_logic;
        cs_n : out std_logic;
        rs : out std_logic;
        wr_n : out std_logic;
        rd_n : out std_logic

    );
end lcd_control;

architecture synth of lcd_control is

begin


end synth;