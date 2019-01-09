-- Author: Nicolas Peslerbe | Embedded system course | Image Processing Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avalon_slave_camera is
    port(

        clk         : in  std_logic;
        reset       : in  std_logic;

        sync_reset  : out std_logic;

        image_ready       : in std_logic;
        base_address      : out std_logic_vector(31 downto 0);

         -- Avalon Slave bus transmission
        avs_address : in std_logic_vector(3 downto 0);
        avs_read    : in std_logic;
        avs_readdata: out std_logic_vector(31 downto 0);
        avs_write   : in std_logic;
        avs_writedata:in std_logic_vector(31 downto 0);
        avs_irq_n: out std_logic

    );
end avalon_slave_camera;

architecture synth of avalon_slave_camera is

    signal must_save_base : std_logic;

begin

    decode_avalon : process(clk, reset)
    begin
        if reset = '1' then

        elsif rising_edge(clk) then
            if avs_write = '1' then
                case avs_address is
                    when x"0" =>
                        base_address <= avs_writedata;
                    when others =>
                        null;
                end case;
            elsif avs_read = '1' then
                case avs_address is

                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    throw_interruption : process(clk, reset)
    begin
        if reset = '1' then

        elsif rising_edge(clk) then
            avs_irq_n <= 'Z';
            if image_ready = '1' then
                avs_irq_n <= '0';
            end if;
        end if;
    end process;

end synth;
