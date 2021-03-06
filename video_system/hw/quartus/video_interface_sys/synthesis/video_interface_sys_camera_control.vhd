-- video_interface_sys_camera_control.vhd

-- Generated using ACDS version 18.1 625

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity video_interface_sys_camera_control is
	port (
		clk              : in  std_logic                     := '0';             --           clock.clk
		reset_n          : in  std_logic                     := '0';             --           reset.reset_n
		avs_address      : in  std_logic_vector(3 downto 0)  := (others => '0'); --  avalon_slave_0.address
		avs_read         : in  std_logic                     := '0';             --                .read
		avs_readdata     : out std_logic_vector(31 downto 0);                    --                .readdata
		avs_write        : in  std_logic                     := '0';             --                .write
		avs_writedata    : in  std_logic_vector(31 downto 0) := (others => '0'); --                .writedata
		avs_irq_n        : out std_logic;                                        --             irq.irq_n
		avm_address      : out std_logic_vector(31 downto 0);                    -- avalon_master_0.address
		avm_byteenable_n : out std_logic_vector(3 downto 0);                     --                .byteenable_n
		avm_burstcount   : out std_logic_vector(2 downto 0);                     --                .burstcount
		avm_write        : out std_logic;                                        --                .write
		avm_waitrequest  : in  std_logic                     := '0';             --                .waitrequest
		avm_writedata    : out std_logic_vector(31 downto 0);                    --                .writedata
		cam_data         : in  std_logic_vector(11 downto 0) := (others => '0'); --   camera_sensor.cam_data
		cam_lvalid       : in  std_logic                     := '0';             --                .cam_lvalid
		cam_pixelclk     : in  std_logic                     := '0';             --                .cam_pixelclk
		cam_reset_n      : out std_logic;                                        --                .cam_reset_n
		cam_fvalid       : in  std_logic                     := '0'              --                .cam_fvalid
	);
end entity video_interface_sys_camera_control;

architecture rtl of video_interface_sys_camera_control is
	component camera_control is
		port (
			clk              : in  std_logic                     := 'X';             -- clk
			reset_n          : in  std_logic                     := 'X';             -- reset_n
			avs_address      : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- address
			avs_read         : in  std_logic                     := 'X';             -- read
			avs_readdata     : out std_logic_vector(31 downto 0);                    -- readdata
			avs_write        : in  std_logic                     := 'X';             -- write
			avs_writedata    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			avs_irq_n        : out std_logic;                                        -- irq_n
			avm_address      : out std_logic_vector(31 downto 0);                    -- address
			avm_byteenable_n : out std_logic_vector(3 downto 0);                     -- byteenable_n
			avm_burstcount   : out std_logic_vector(2 downto 0);                     -- burstcount
			avm_write        : out std_logic;                                        -- write
			avm_waitrequest  : in  std_logic                     := 'X';             -- waitrequest
			avm_writedata    : out std_logic_vector(31 downto 0);                    -- writedata
			cam_data         : in  std_logic_vector(11 downto 0) := (others => 'X'); -- cam_data
			cam_lvalid       : in  std_logic                     := 'X';             -- cam_lvalid
			cam_pixelclk     : in  std_logic                     := 'X';             -- cam_pixelclk
			cam_reset_n      : out std_logic;                                        -- cam_reset_n
			cam_fvalid       : in  std_logic                     := 'X'              -- cam_fvalid
		);
	end component camera_control;

begin

	camera_control : component camera_control
		port map (
			clk              => clk,              --           clock.clk
			reset_n          => reset_n,          --           reset.reset_n
			avs_address      => avs_address,      --  avalon_slave_0.address
			avs_read         => avs_read,         --                .read
			avs_readdata     => avs_readdata,     --                .readdata
			avs_write        => avs_write,        --                .write
			avs_writedata    => avs_writedata,    --                .writedata
			avs_irq_n        => avs_irq_n,        --             irq.irq_n
			avm_address      => avm_address,      -- avalon_master_0.address
			avm_byteenable_n => avm_byteenable_n, --                .byteenable_n
			avm_burstcount   => avm_burstcount,   --                .burstcount
			avm_write        => avm_write,        --                .write
			avm_waitrequest  => avm_waitrequest,  --                .waitrequest
			avm_writedata    => avm_writedata,    --                .writedata
			cam_data         => cam_data,         --   camera_sensor.cam_data
			cam_lvalid       => cam_lvalid,       --                .cam_lvalid
			cam_pixelclk     => cam_pixelclk,     --                .cam_pixelclk
			cam_reset_n      => cam_reset_n,      --                .cam_reset_n
			cam_fvalid       => cam_fvalid        --                .cam_fvalid
		);

end architecture rtl; -- of video_interface_sys_camera_control
