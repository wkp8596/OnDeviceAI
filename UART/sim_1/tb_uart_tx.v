`timescale 1ns / 1ps

module tb_uart_tx ();

    parameter UART_BAUD_PERIOD = 100_000_000 * 10 / 9600;

    reg clk, rst, tx_start;
    reg [7:0] tx_data;

    wire tx_l, tx_s;

    uart dut_13state (
        .clk(clk),
        .rst(rst),
        .BtnR(tx_start),
        .tx_data(tx_data),
        .tx(tx_l)
    );

    uart_long dut_5state (
        .clk(clk),
        .rst(rst),
        .BtnR(tx_start),
        .tx_data(tx_data),
        .tx(tx_s)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        tx_start = 0;

        tx_data = 8'b01110101;

        repeat (3) @(negedge clk);
        rst = 0;

        repeat (3) @(negedge clk);

        tx_start = 1;
        repeat (10_000) @(negedge clk);


        tx_start = 0;

        repeat (10) #UART_BAUD_PERIOD;  // first input tx

        tx_data = 8'b10110001;

        repeat (10000) @(negedge clk);
        tx_start = 1;
        repeat (10_000) @(negedge clk);
        tx_start = 0;
        repeat (10) #UART_BAUD_PERIOD;  // second input tx

        $stop;

    end

endmodule
