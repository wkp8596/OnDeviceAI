`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/21 15:58:58
// Design Name: 
// Module Name: tb_uart
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


module tb_uart ();

    parameter UART_BAUD_PERIOD = 100_000_000 * 10 / 9600;

    reg clk, rst, tx_start, rx;
    reg [7:0] tx_data;
    wire tx, rx_done, tx_busy;
    wire [7:0] rx_data;

    uart dut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .tx_busy(tx_busy),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        tx_start = 0;
        rx = 1;
        tx_data = 8'h30;
        repeat (3) @(negedge clk);

        rst = 0;

        #(UART_BAUD_PERIOD);
        tx_start = 1;
        rx = 0;  // start bit

        #(UART_BAUD_PERIOD);

        tx_start = 0;

        //#(UART_BAUD_PERIOD);

        //#(UART_BAUD_PERIOD);
        rx = 0;  // 1 bit

        #(UART_BAUD_PERIOD);
        rx = 0;  // 2 bit

        #(UART_BAUD_PERIOD);
        rx = 0;  // 3 bit

        #(UART_BAUD_PERIOD);
        rx = 0;  // 4 bit

        #(UART_BAUD_PERIOD);
        rx = 1;  // 5 bit

        #(UART_BAUD_PERIOD);
        rx = 1;  // 6 bit

        #(UART_BAUD_PERIOD);
        rx = 0;  // 7 bit

        #(UART_BAUD_PERIOD);
        rx = 0;  // 8 bit

        #(UART_BAUD_PERIOD);
        rx = 1;  // stop bit

        #(UART_BAUD_PERIOD);

        repeat (2) #(UART_BAUD_PERIOD);

        //

        #(UART_BAUD_PERIOD);
        rx = 0;  // start bit

        #(UART_BAUD_PERIOD);
        rx = 0;  // 1 bit

        #(UART_BAUD_PERIOD);
        rx = 0;  // 2 bit

        #(UART_BAUD_PERIOD);
        rx = 0;  // 3 bit

        #(UART_BAUD_PERIOD);
        rx = 0;  // 4 bit

        #(UART_BAUD_PERIOD);
        rx = 1;  // 5 bit

        #(UART_BAUD_PERIOD);
        rx = 1;  // 6 bit

        #(UART_BAUD_PERIOD);
        rx = 0;  // 7 bit

        #(UART_BAUD_PERIOD);
        rx = 0;  // 8 bit

        #(UART_BAUD_PERIOD);
        rx = 1;  // stop bit

        #(UART_BAUD_PERIOD);

        repeat (2) #(UART_BAUD_PERIOD);

        //

        $stop;

    end



endmodule
