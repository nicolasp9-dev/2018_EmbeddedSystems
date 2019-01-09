library ieee;
use ieee.std_logic_1164.all;

entity tb_lcd_control is
end tb_lcd_control;

architecture tb of tb_lcd_control is

    component LCD_controller
        port (Clk             : in std_logic;
              nReset          : in std_logic;
              AVS_CS          : in std_logic;
              AVS_Rd          : in std_logic;
              AVS_Wr          : in std_logic;
              AVS_RDData      : out std_logic_vector (31 downto 0);
              AVS_WRData      : in std_logic_vector (31 downto 0);
              AVS_Adr         : in std_logic_vector (1 downto 0);
              AVM_Adr         : out std_logic_vector (31 downto 0 );
             -- AVM_ByteEnable  : out std_logic_vector (3 downto 0 );
              --AVM_BurstCount  : out std_logic_vector (2 downto 0 );
              AVM_WaitRequest : in std_logic;
              LCD_ON          : out std_logic;
              LCD_CS_n        : out std_logic;
              LCD_Reset_n     : out std_logic;
              LCD_RS          : out std_logic;
              LCD_WR_n        : out std_logic;
              LCD_data        : inout std_logic_vector (15 downto 0));
    end component;

    signal Clk             : std_logic;
    signal nReset          : std_logic;
    signal AVS_CS          : std_logic;
    signal AVS_Rd          : std_logic;
    signal AVS_Wr          : std_logic;
    signal AVS_RDData      : std_logic_vector (31 downto 0);
    signal AVS_WRData      : std_logic_vector (31 downto 0);
    signal AVS_Adr         : std_logic_vector (1 downto 0);
    signal AVM_Adr         : std_logic_vector (31 downto 0 );
    --signal AVM_ByteEnable  : std_logic_vector (3 downto 0 );
   -- signal AVM_BurstCount  : std_logic_vector (2 downto 0 );
    signal AVM_WaitRequest : std_logic;
    signal LCD_ON          : std_logic;
    signal LCD_CS_n        : std_logic;
    signal LCD_Reset_n     : std_logic;
    signal LCD_RS          : std_logic;
    signal LCD_WR_n        : std_logic;
    signal LCD_data        : std_logic_vector (15 downto 0);

    constant TbPeriod : time := 50 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : LCD_controller
    port map (Clk             => Clk,
              nReset          => nReset,
              AVS_CS          => AVS_CS,
              AVS_Rd          => AVS_Rd,
              AVS_Wr          => AVS_Wr,
              AVS_RDData      => AVS_RDData,
              AVS_WRData      => AVS_WRData,
              AVS_Adr         => AVS_Adr,
              AVM_Adr         => AVM_Adr,
              --AVM_ByteEnable  => AVM_ByteEnable,
              --AVM_BurstCount  => AVM_BurstCount,
              AVM_WaitRequest => AVM_WaitRequest,
              LCD_ON          => LCD_ON,
              LCD_CS_n        => LCD_CS_n,
              LCD_Reset_n     => LCD_Reset_n,
              LCD_RS          => LCD_RS,
              LCD_WR_n        => LCD_WR_n,
              LCD_data        => LCD_data);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that Clk is really your main clock signal
    Clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        AVS_CS <= '0';
        AVS_Rd <= '0';
        AVS_Wr <= '0';
        AVS_WRData <= (others => '0');
        AVS_Adr <= (others => '0');
        AVM_WaitRequest <= '0';

        -- Reset generation
        -- EDIT: Check that nReset is really your reset signal
        nReset <= '0';
        wait for 100 ns;
        nReset <= '1';
        wait for 100 ns;
		
		AVS_Wr <= '1';
		AVS_CS <= '1';
		wait for TbPeriod;
		AVS_Adr <= "01";
		AVS_WRData <= x"F0F0F0F0";
		
		wait for TbPeriod;
		AVS_Adr <= "10";
		AVS_WRData <= x"0F0F0F0F";		
		
		wait for TbPeriod;
		AVS_Adr <= "11";
		AVS_WRData <= x"0F0F0F0F";		
		
		wait for TbPeriod;
		AVS_Adr <= "00";
		AVS_WRData <= x"00000007";		
		wait for TbPeriod;
		
		AVS_Wr <= '0';
		AVS_CS <= '0';

		
		wait for 21000 ns;
		
		AVS_Wr <= '1';
		AVS_CS <= '1';
		wait for TbPeriod;
		AVS_Adr <= "00";
		AVS_WRData <= x"00000007";		
		wait for TbPeriod;
		
		
		
		AVS_Wr <= '0';
		AVS_CS <= '0';
		
		
		

        -- EDIT Add stimuli here
        wait for 11000 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_lcd_control of tb_lcd_control is
    for tb
    end for;
end cfg_tb_lcd_control;