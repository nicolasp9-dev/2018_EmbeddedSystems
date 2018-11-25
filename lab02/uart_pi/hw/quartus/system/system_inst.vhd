	component system is
		port (
			clk_clk                               : in  std_logic                    := 'X'; -- clk
			homemade_uart_external_connections_tx : out std_logic;                           -- tx
			homemade_uart_external_connections_rx : in  std_logic                    := 'X'; -- rx
			pio_0_external_connection_export      : out std_logic_vector(7 downto 0);        -- export
			reset_reset_n                         : in  std_logic                    := 'X'  -- reset_n
		);
	end component system;

	u0 : component system
		port map (
			clk_clk                               => CONNECTED_TO_clk_clk,                               --                                clk.clk
			homemade_uart_external_connections_tx => CONNECTED_TO_homemade_uart_external_connections_tx, -- homemade_uart_external_connections.tx
			homemade_uart_external_connections_rx => CONNECTED_TO_homemade_uart_external_connections_rx, --                                   .rx
			pio_0_external_connection_export      => CONNECTED_TO_pio_0_external_connection_export,      --          pio_0_external_connection.export
			reset_reset_n                         => CONNECTED_TO_reset_reset_n                          --                              reset.reset_n
		);

