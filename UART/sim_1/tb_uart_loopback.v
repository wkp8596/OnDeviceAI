`timescale 1ns / 1ps

module tb_uart_loopback ();

    parameter BAUD_PERIOD = 100_000_000 * 10 / 9600;

    reg clk, rst, rx;
    reg [7:0] compare_data;
    wire tx;


    uart_loopback dut (
        .clk(clk),
        .rst(rst),
        .rx (rx),
        .tx (tx)
    );

    always #5 clk = ~clk;

    integer i;

    // pc uart(txrx) module task

    task SENDER_UART(input [7:0] send_data);
        begin
            rx = 0;  // start signal
            #(BAUD_PERIOD);  //  1/9600 second

            // data bit
            for (i = 0; i < 8; i = i + 1) begin
                // rx, send_data[0] ~ [7]
                rx = send_data[i];
                #(BAUD_PERIOD);
            end
            // stop bit
            rx = 1;
            #(BAUD_PERIOD);
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        rx = 1;
        compare_data = 8'h30;
        repeat (3) @(negedge clk);
        rst = 0;
        SENDER_UART(compare_data);


        repeat (10) #(BAUD_PERIOD);

        #1000;

        $stop;
    end


endmodule
