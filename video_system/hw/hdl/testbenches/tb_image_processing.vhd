library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_image_processing is
end tb_image_processing;

architecture testbench of tb_image_processing is
    constant CLK_PERIOD : time := 40 ns;

    -- Signal for simulated module
    signal clk          : std_logic := '0';
    signal reset        : std_logic;

    signal pixel_available  : std_logic;
    signal read_next        : std_logic;
    signal camera_px_value  : std_logic_vector(11 downto 0);

    signal pixel_ready      : std_logic;
    signal new_pixel_value  : std_logic_vector(15 downto 0);

    signal sync_reset   : std_logic;
    signal finished     : std_logic := '0';

begin

    image_processing_0 : ENTITY work.image_processing port map(
            clk         => clk,
            reset       => reset,

            must_process_pix        => pixel_available,
            read                    => read_next,
            incoming_pixel_value    => camera_px_value,

            pixel_ready => pixel_ready,
            outgoing_pixel_value => new_pixel_value,

            new_image => sync_reset
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
        pixel_available <= '0';
        sync_reset <= '0';
        reset <= '1';
        wait for CLK_PERIOD * 3 / 2;
        reset <= '0';
        wait for CLK_PERIOD;
        sync_reset <= '1';
        wait for CLK_PERIOD;
        sync_reset <= '0';
        wait for CLK_PERIOD;

        for i in 0 to 307202 loop
            pixel_available <= '1';
            wait for CLK_PERIOD;
            ASSERT read_next = '1' REPORT "The IP don't read pixel value when expected" SEVERITY ERROR;
            camera_px_value <= "011010101110"; -- R:0110, G:1010, B:1110
            pixel_available <= '0';
            wait for CLK_PERIOD;
            ASSERT read_next = '0' REPORT "The IP not stopped reading" SEVERITY ERROR;
            if (i mod 2) = 0 then
                ASSERT pixel_ready = '1' REPORT "The image is not ready as expected" SEVERITY ERROR;
                ASSERT new_pixel_value = "0011100111110001" REPORT "The pixel value is does not correspond" SEVERITY ERROR;
            else
                ASSERT pixel_ready = '0' REPORT "The image is not ready as expected" SEVERITY ERROR;
            end if;
            wait for CLK_PERIOD;
            ASSERT pixel_ready = '0' REPORT "The image is not ready as expected" SEVERITY ERROR;
        end loop;

        finished <= '1';
        wait;
    end process;

end testbench;