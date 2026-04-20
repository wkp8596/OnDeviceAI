`timescale 1ns / 1ps

module top_stopwatch_watch (
    input        clk,
    input        rst,
    input  [3:0] sw,
    input        btnR,
    input        btnU,
    input        btnD,
    input        btnL,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output [6:0] led
);

    parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5;

    wire [MSEC_WIDTH - 1:0] w_s_msec;
    wire [ SEC_WIDTH - 1:0] w_s_sec;
    wire [ MIN_WIDTH - 1:0] w_s_min;
    wire [HOUR_WIDTH - 1:0] w_s_hour;

    wire [MSEC_WIDTH - 1:0] w_w_msec;
    wire [ SEC_WIDTH - 1:0] w_w_sec;
    wire [ MIN_WIDTH - 1:0] w_w_min;
    wire [HOUR_WIDTH - 1:0] w_w_hour;

    wire [MSEC_WIDTH - 1:0] w_mux_msec;
    wire [ SEC_WIDTH - 1:0] w_mux_sec;
    wire [ MIN_WIDTH - 1:0] w_mux_min;
    wire [HOUR_WIDTH - 1:0] w_mux_hour;

    wire w_runstop, w_clear, w_mode;
    wire w_btnR, w_btnL, w_btnU, w_btnD;

    wire [1:0] w_watch_updn, w_aj_watch_hms;
    wire w_watch_stopwatch, w_hour_sec;

    wire w_flash;

    button_debounce U_BTNR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_btnR)
    );

    button_debounce U_BTNU (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnU),
        .o_btn(w_btnU)
    );

    button_debounce U_BTNL (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL),
        .o_btn(w_btnL)
    );

    button_debounce U_BTND (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD),
        .o_btn(w_btnD)
    );
    wire w_watch_clear;

    control_unit U_CONTROL_UNIT (
        .clk          (clk),
        .rst          (rst),
        .btnD         (w_btnD),             // mode
        .btnL         (w_btnL),             // clear
        .btnR         (w_btnR),             // run/stop
        .btnU         (w_btnU),             // 
        .flash        (w_flash),
        .sw           (sw),                 // 
        .run_stop     (w_runstop),          // 
        .clear        (w_clear),            // 
        .mode         (w_mode),             // 
        
        .watch_up_dn  (w_watch_updn),       //  UD
        .sel_watch_hms(w_aj_watch_hms),     //  SH
        .sel_w_sw     (w_watch_stopwatch),  //  sw[1]
        .sel_hour_sec (w_hour_sec),         //  sw[0] or SH[1]
        .watch_clear  (w_watch_clear),
        .o_led        (led)
    );

    stopwatch_datapatch U_STOPWATCH_DATAPATH (
        .clk      (clk),
        .rst      (rst),
        .i_runstop(w_runstop),
        .i_clear  (w_clear),
        .i_mode   (w_mode),
        .msec     (w_s_msec),
        .sec      (w_s_sec),
        .min      (w_s_min),
        .hour     (w_s_hour)
    );

    watch_datapath U_WATCH_DATAPATH (
        .clk          (clk),
        .rst          (rst),
        .watch_up     (w_watch_updn[1]),  // btnU
        .watch_down   (w_watch_updn[0]),  // btnD
        .sel_watch_hms(w_aj_watch_hms),   // sel_time_hms
        .watch_clear  (w_watch_clear),
        .msec         (w_w_msec),
        .sec          (w_w_sec),
        .min          (w_w_min),
        .hour         (w_w_hour)
    );

    assign w_mux_hour = (w_watch_stopwatch) ? w_w_hour : w_s_hour;
    assign w_mux_min  = (w_watch_stopwatch) ? w_w_min : w_s_min;
    assign w_mux_sec  = (w_watch_stopwatch) ? w_w_sec : w_s_sec;
    assign w_mux_msec = (w_watch_stopwatch) ? w_w_msec : w_s_msec;

    fnd_controller U_FND_CON (
        .clk          (clk),
        .rst          (rst),
        .sw           (w_hour_sec),      // sw[0], 0: msec_sec, 1: min_hour
        .sel_watch_hms(w_aj_watch_hms),
        .msec         (w_mux_msec),
        .sec          (w_mux_sec),
        .min          (w_mux_min),
        .hour         (w_mux_hour),
        .flash        (w_flash),
        .fnd_data     (fnd_data),
        .fnd_com      (fnd_com)
    );

endmodule
