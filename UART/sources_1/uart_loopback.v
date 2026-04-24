`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/22 16:08:09
// Design Name: 
// Module Name: uart_loopback
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_loopback (
    input  clk,
    input  rst,
    input  rx,
    output tx
);

    wire [7:0] w_data;
    wire w_tx_start;

    uart U_UART (
        .clk     (clk),
        .rst     (rst),
        .tx_start(w_tx_start),
        .tx_data (w_data),
        .rx      (rx),
        .rx_data (w_data),
        .rx_done (w_tx_start),
        .tx_busy (),
        .tx      (tx)
    );


endmodule
