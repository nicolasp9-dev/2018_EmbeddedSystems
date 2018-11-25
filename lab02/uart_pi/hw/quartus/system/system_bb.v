
module system (
	clk_clk,
	homemade_uart_external_connections_tx,
	homemade_uart_external_connections_rx,
	pio_0_external_connection_export,
	reset_reset_n);	

	input		clk_clk;
	output		homemade_uart_external_connections_tx;
	input		homemade_uart_external_connections_rx;
	output	[7:0]	pio_0_external_connection_export;
	input		reset_reset_n;
endmodule
