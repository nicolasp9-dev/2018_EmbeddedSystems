-- Author: Nicolas Peslerbe | Embedded system course | Image Processing Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avalon_master_camera is
    port(

        clk         : in  std_logic;
        reset       : in  std_logic;

        sync_reset                  : in std_logic;
        end_writing_image           : out std_logic;
        base_address                : in std_logic_vector(31 downto 0);

        must_read_from_buffer       : out std_logic;
        pixel_in_buffer             : in std_logic;
        incoming_pixel_value        : in std_logic_vector(15 downto 0);
        number_of_pixels_in_buffer  : in std_logic_vector(7 downto 0);

        -- Avalon Master bus transmission
        avm_address : out std_logic_vector(31 downto 0);
        avm_byteenable_n : out std_logic_vector(3 downto 0);
        avm_burstcount : out std_logic_vector(2 downto 0);
        avm_write : out std_logic;
        avm_writedata : out std_logic_vector(31 downto 0);
        avm_waitrequest : in std_logic

    );
end avalon_master_camera;

architecture synth of avalon_master_camera is


begin





end synth;
