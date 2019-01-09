-- Author: Nicolas Peslerbe | Embedded system course | Image Processing Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity image_processing is
    port(

        clk         : in  std_logic;
        reset       : in  std_logic;

        must_process_pix        : in std_logic;
        read                    : out std_logic;
        incoming_pixel_value   : in std_logic_vector(11 downto 0);

        pixel_ready         : out std_logic;
        outgoing_pixel_value: out std_logic_vector(15 downto 0);

        new_image : in std_logic

    );
end image_processing;

architecture synth of image_processing is
    type Processing_State is (Waiting, Processing);
    signal state        : Processing_State;
    signal ignore_pixel : std_logic;
    signal next_pixel   : integer;
begin

    -- This process goal is to process pixels from one FIFO and write it to the next FIFO
    process_pixel : process (clk, reset)
    begin

        if (reset = '1') then
            state <= waiting;
            read <= '0';
            pixel_ready <= '0';
        elsif rising_edge(clk) then
            read <= '0';
            pixel_ready <= '0';
            if new_image = '1' then
                state <= waiting;
            else
                case state is
                    when Waiting =>
                        if must_process_pix='1' then
                            read <= '1';
                            state <= Processing;
                        end if;
                    when Processing =>
                        if ignore_pixel = '0' then
                            outgoing_pixel_value(15 downto 11) <= std_logic_vector(unsigned('0'&incoming_pixel_value(11 downto 8)) + unsigned(incoming_pixel_value(11 downto 10)));
                            outgoing_pixel_value(10 downto 5) <= std_logic_vector(unsigned("00"&incoming_pixel_value(7 downto 4)) + unsigned(incoming_pixel_value(7 downto 5)));
                            outgoing_pixel_value(4 downto 0) <= std_logic_vector(unsigned('0'&incoming_pixel_value(3 downto 0)) + unsigned(incoming_pixel_value(3 downto 2)));
                            pixel_ready <= '1';
                        end if;
                        state <= Waiting;
                    when others =>

                end case;
            end if;
        end if;
    end process;

    -- This process goal is to identify pixels which must be ignored to reduce image size
    ignore_pixel_compute : process (clk, reset)
    begin
        if (reset = '1') then
            ignore_pixel <= '0';
            next_pixel <= 1;
        elsif rising_edge(clk) then
            if new_image = '1' then
                ignore_pixel <= '0';
                next_pixel <= 1;
            elsif state = Processing then
                if((next_pixel mod 2) = 1 or ((next_pixel mod 640) mod 2) = 1) then
                    ignore_pixel <= '1';
                else
                    ignore_pixel <= '0';
                end if;

                if(next_pixel = 307200) then
                    next_pixel <= 1;
                else
                    next_pixel <= next_pixel + 1;
                end if;

            end if;
        end if;
    end process;


end synth;
