`timescale 1ns / 1ps

module tb_b_tick_gen ();

    reg clk, rst;
    wire o_b_tick;

    baud_tick_gen dut (
        .clk(clk),
        .rst(rst),
        .o_b_tick(o_b_tick)
    );

    always #5 clk = ~clk;

    initial begin
        clk  = 0;
        rst = 1;
        repeat (3) @(negedge clk);
        rst = 0;



        repeat (50000) @(negedge clk);

        $stop;

    end


endmodule
