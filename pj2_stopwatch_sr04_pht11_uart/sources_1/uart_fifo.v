`timescale 1ns / 1ps

module uart_fifo(
	input		clk,
	input		rst,
	input		rx,
	input		fifo_rx_pop,
	input		fifo_tx_push,
	input  [7:0]	tx_data,
	output		tx,
	output [7:0]	rx_data,
	output		fifo_rx_empty,
	output		fifo_tx_full
    );

    	wire w_tx_empty_start, w_tx_busy_pop, w_rx_done_push;
	wire [7:0] w_tx_data, w_rx_data;

	uart U_UART (
    		.clk		(clk),
    		.rst		(rst),
    		.tx_start	(!w_tx_empty_start),
    		.tx_data	(w_tx_data),
    		.rx		(rx),
    		.rx_data	(w_rx_data),
    		.rx_done	(w_rx_done_push),
    		.tx_busy	(w_tx_busy_pop),
    		.tx		(tx)
	);

	fifo #(
	   .DEPTH(256)
	) U_FIFO_TX (
    		.clk		(clk),
    		.rst		(rst),
    		.push_data	(tx_data),
    		.push		(fifo_tx_push),
    		.pop		(!w_tx_busy_pop),
    		.pop_data	(w_tx_data),
    		.full		(fifo_tx_full),
    		.empty		(w_tx_empty_start)
	);

	fifo #(
	   .DEPTH(4)
	) U_FIFO_RX (
    		.clk		(clk),
    		.rst		(rst),
    		.push_data	(w_rx_data),
    		.push		(w_rx_done_push),
    		.pop		(fifo_rx_pop),
    		.pop_data	(rx_data),
    		.full		(),
    		.empty		(fifo_rx_empty)
	);

endmodule
