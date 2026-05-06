`timescale 1ns / 1ps

module watch_datapath #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input                    clk,
    input                    rst,
    input                    watch_up,       // btnU
    input                    watch_down,     // btnD
    input  [            1:0] sel_watch_hms,  // sel_time_hms
    input                    watch_clear,
    output [MSEC_WIDTH -1:0] msec,
    output [ SEC_WIDTH -1:0] sec,
    output [ MIN_WIDTH -1:0] min,
    output [HOUR_WIDTH -1:0] hour
);

    wire w_tick_100Hz, w_sec_tick, w_min_tick, w_hour_tick;
    wire w_sel_sec, w_sel_min, w_sel_hour;

    time_selector U_time_selector (
        .sel_time_hms(sel_watch_hms),
        .out_sel_time({w_sel_hour, w_sel_min, w_sel_sec})
    );

    tick_counter_wtc #(
        .TIMES(24),
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_TICK_COUNTER (
        .clk(clk),
        .rst(rst),
        .watch_up(watch_up),
        .watch_down(watch_down),
        .sel_time(w_sel_hour),
        .i_tick(w_hour_tick),
        .o_tick(),
        .time_counter(hour)
    );

    tick_counter_wtc #(
        .TIMES(60),
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_TICK_COUNTER (
        .clk(clk),
        .rst(rst),
        .watch_up(watch_up),
        .watch_down(watch_down),
        .sel_time(w_sel_min),
        .i_tick(w_min_tick),
        .o_tick(w_hour_tick),
        .time_counter(min)
    );

    tick_counter_wtc #(
        .TIMES(60),
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_TICK_COUNTER (
        .clk(clk),
        .rst(rst | watch_clear),
        .watch_up(watch_up),
        .watch_down(watch_down),
        .sel_time(w_sel_sec),
        .i_tick(w_sec_tick),
        .o_tick(w_min_tick),
        .time_counter(sec)
    );

    tick_counter_wtc #(
        .TIMES(100),
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_TICK_COUNTER (
        .clk(clk),
        .rst(rst | watch_clear),
        .watch_up(),
        .watch_down(),
        .sel_time(),
        .i_tick(w_tick_100Hz),
        .o_tick(w_sec_tick),
        .time_counter(msec)
    );

    tick_gen_100Hz_wtc U_tick_gen_100Hz (
        .clk(clk),
        .rst(rst),
        .o_tick_100Hz(w_tick_100Hz)
    );

endmodule

module time_selector (
    input      [1:0] sel_time_hms,  // sel_watch_hms
    output reg [2:0] out_sel_time
);

    always @(*) begin
        case (sel_time_hms)
            2'b00:   out_sel_time = 3'b001;  //  sec
            2'b10:   out_sel_time = 3'b010;  //  min
            2'b11:   out_sel_time = 3'b100;  //  hour
            default: out_sel_time = 3'b000;
        endcase
    end

endmodule

module tick_counter_wtc #(
    parameter TIMES = 100,
    BIT_WIDTH = 7
) (
    input                        clk,
    input                        rst,
    input                        i_tick,
    input                        watch_up,     // btnU
    input                        watch_down,   // btnD
    input                        sel_time,     // sel_time_hms
    output reg                   o_tick,
    output     [BIT_WIDTH-1 : 0] time_counter
);
    // counter register
    reg [BIT_WIDTH-1 : 0] counter_reg, counter_next;
    assign time_counter = counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    // next counter CL : blocking =

    always @(*) begin
        counter_next = counter_reg;
        o_tick = 1'b0;
        if (sel_time) begin
            if (watch_up) begin
                if (i_tick) begin
                    counter_next = counter_reg + 2;
                    if (counter_reg > (TIMES - 3)) begin
                        counter_next = counter_reg - 58;
                        o_tick       = 1'b1;
                    end
                end else begin
                    counter_next = counter_reg + 1;
                    if (counter_reg == (TIMES - 1)) begin
                        counter_next = 0;
                        o_tick       = 1'b1;
                    end
                end
            end
            if (watch_down) begin
                if (i_tick) begin
                    counter_next = counter_reg;
                end else begin
                    counter_next = counter_reg - 1;
                    if (counter_reg == 0) begin
                        counter_next = TIMES - 1;
                        o_tick       = 1'b0;
                    end
                end
            end else begin
                if (i_tick) begin
                    counter_next = counter_reg + 1;
                    if (counter_reg == (TIMES - 1)) begin
                        counter_next = 0;
                        o_tick       = 1'b1;
                    end
                end
            end
        end else begin
            if (i_tick) begin
                counter_next = counter_reg + 1;
                if (counter_reg == (TIMES - 1)) begin
                    counter_next = 0;
                    o_tick       = 1'b1;
                end
            end
        end
    end

endmodule

module tick_gen_100Hz_wtc (
    input clk,
    input rst,
    output reg o_tick_100Hz
);
    //100Hz counter number
    parameter F_COUNT = 100_000_000 / 100;
    reg [$clog2(F_COUNT)-1:0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg  <= 20'b0;
            o_tick_100Hz <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_COUNT - 1) begin
                counter_reg  <= 20'b0;
                o_tick_100Hz <= 1'b1;
            end else begin
                o_tick_100Hz <= 1'b0;
            end
        end
    end
endmodule
