	system u0 (
		.clk_clk                               (<connected-to-clk_clk>),                               //                                clk.clk
		.homemade_uart_external_connections_tx (<connected-to-homemade_uart_external_connections_tx>), // homemade_uart_external_connections.tx
		.homemade_uart_external_connections_rx (<connected-to-homemade_uart_external_connections_rx>), //                                   .rx
		.pio_0_external_connection_export      (<connected-to-pio_0_external_connection_export>),      //          pio_0_external_connection.export
		.reset_reset_n                         (<connected-to-reset_reset_n>)                          //                              reset.reset_n
	);

