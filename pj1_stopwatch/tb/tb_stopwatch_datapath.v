`timescale 1ns / 1ps

module tb_stopwatch_datapath ();

    parameter SEC_DELAY = 100_000;
    parameter MIN_DELAY = 6_000_000;

    reg clk, rst;
    reg i_runstop, i_clear, i_mode;
    wire [6:0] msec;
    wire [5:0] sec;
    wire [5:0] min;
    wire [4:0] hour;

    stopwatch_datapatch dut (
        .clk(clk),
        .rst(rst),
        .i_runstop(i_runstop),
        .i_clear(i_clear),
        .i_mode(i_mode),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        i_runstop = 0;
        i_clear = 0;
        i_mode = 0;
        repeat (3) @(negedge clk);
        rst = 0;
        i_runstop = 1;

        repeat (10) #(SEC_DELAY);
        i_clear = 1;
        repeat (10)@(negedge clk);
        i_clear = 0;
        #(SEC_DELAY);

        i_mode = 1;
        #(MIN_DELAY);
        
        $stop;
    end


endmodule
