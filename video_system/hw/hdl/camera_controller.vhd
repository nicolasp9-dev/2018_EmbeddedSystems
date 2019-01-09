-- Author: Nicolas Peslerbe | Embedded system course | Camera Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity camera_controller is
    port(
        clk         : in  std_logic;
        reset_n     : in std_logic;

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
        cam_lvalid : in std_logic

    );
end camera_controller;

architecture synth of camera_controller is

    component image_processing is
        port(

            clk         : in  std_logic;
            reset       : in  std_logic;

            must_process_pix        : in std_logic;
            read                    : out std_logic;
            incoming_pixel_value    : in std_logic_vector(11 downto 0);

            pixel_ready             : out std_logic;
            outgoing_pixel_value    : out std_logic_vector(15 downto 0);

            new_image : in std_logic
        );
    end component;

    component fifo_12bits is
        PORT
        (
            aclr		: IN STD_LOGIC  := '0';
            data		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            rdclk		: IN STD_LOGIC ;
            rdreq		: IN STD_LOGIC ;
            wrclk		: IN STD_LOGIC ;
            wrreq		: IN STD_LOGIC ;
            q		    : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
            rdempty		: OUT STD_LOGIC ;
            wrfull		: OUT STD_LOGIC
    );
    end component;

    component fifo_16bits is
    	PORT
    	(
    		clock		: IN STD_LOGIC ;
    		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
    		rdreq		: IN STD_LOGIC ;
    		sclr		: IN STD_LOGIC ;
    		wrreq		: IN STD_LOGIC ;
    		empty		: OUT STD_LOGIC ;
    		full		: OUT STD_LOGIC ;
    		q		    : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
    		usedw		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    	);
    end component;

    component avalon_master_camera is
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
            avm_address         : out std_logic_vector(31 downto 0);
            avm_byteenable_n    : out std_logic_vector(3 downto 0);
            avm_burstcount      : out std_logic_vector(2 downto 0);
            avm_write           : out std_logic;
            avm_writedata       : out std_logic_vector(31 downto 0);
            avm_waitrequest     : in std_logic

        );
    end component;

    component avalon_slave_camera is
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
    end component;

    signal reset : std_logic;
    signal sync_reset : std_logic;

    signal wrfull_sig : std_logic; -- not used
    signal full_sig : std_logic; -- not used

    signal camera_buffer_empty : std_logic;
    signal pixel_available_in_input_buffer : std_logic;
    signal read_pixel_from_buf1 : std_logic;
    signal camera_buffer_output : std_logic_vector(11 downto 0);

    signal processed_buffer_input : std_logic_vector(15 downto 0);
    signal pixel_processed : std_logic;

    signal processed_buffer_empty : std_logic;
    signal pixel_available_in_processed_buffer : std_logic;
    signal must_read_from_processed_buffer : std_logic;
    signal number_of_pixels_in_buffer : std_logic_vector(7 downto 0);
    signal processed_buffer_output : std_logic_vector(15 downto 0);

    signal end_writing_image : std_logic;
    signal base_address_for_new_image : std_logic_vector(31 downto 0);

begin

    fifo_12bits_inst : fifo_12bits PORT MAP (
        wrclk	 => cam_pixelclk,
        wrreq	 => cam_lvalid,
        data	 => cam_data,
        wrfull	 => wrfull_sig,

        aclr	 => sync_reset,

        rdclk	 => clk,
        rdreq	 => read_pixel_from_buf1,
        rdempty	 => camera_buffer_empty,
        q	     => camera_buffer_output
    );

    image_processing_unit : image_processing PORT MAP (
        clk         => clk,
        reset       => reset,

        must_process_pix        => pixel_available_in_input_buffer,
        read                    => read_pixel_from_buf1,
        incoming_pixel_value    => camera_buffer_output,

        pixel_ready => pixel_processed,
        outgoing_pixel_value => processed_buffer_input,

        new_image   => sync_reset
    );

    fifo_16bits_inst : fifo_16bits PORT MAP (

        wrreq	 => pixel_processed,
        data	 => processed_buffer_input,

        clock	 => clk,
        sclr	 => sync_reset,

        rdreq	 => must_read_from_processed_buffer,
        q	     => processed_buffer_output,

        full	 => full_sig,
        empty	 => processed_buffer_empty,
        usedw	 => number_of_pixels_in_buffer
    );

    avalon_master_camera0 : avalon_master_camera PORT MAP (

        clk => clk,
        reset => reset,

        sync_reset                  => sync_reset,
        number_of_pixels_in_buffer  => number_of_pixels_in_buffer,

        end_writing_image           => end_writing_image,
        base_address                => base_address_for_new_image,

        avm_address         => avm_address,
        avm_byteenable_n    => avm_byteenable_n,
        avm_burstcount      => avm_burstcount,
        avm_write           => avm_write,
        avm_writedata       => avm_writedata,
        avm_waitrequest     => avm_waitrequest,

        must_read_from_buffer   => must_read_from_processed_buffer,
        pixel_in_buffer         => pixel_available_in_processed_buffer,
        incoming_pixel_value    => processed_buffer_output
    );

    avalon_slave_camera0 : avalon_slave_camera PORT MAP (
        clk     => clk,
        reset   => reset,

        sync_reset      => sync_reset,
        base_address    => base_address_for_new_image,

        image_ready     => end_writing_image,

        avs_address     => avs_address,
        avs_read        => avs_read,
        avs_readdata    => avs_readdata,
        avs_write       => avs_write,
        avs_writedata   => avs_writedata,
        avs_irq_n       => avs_irq_n

    );

    reset <= not reset_n;
    pixel_available_in_input_buffer <= not camera_buffer_empty;
    pixel_available_in_processed_buffer <= not processed_buffer_empty;

end synth;