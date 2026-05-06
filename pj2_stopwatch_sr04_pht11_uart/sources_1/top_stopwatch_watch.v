`timescale 1ns / 1ps

module top_stopwatch_watch #(parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5 )

  (
	input       		 clk,
	input       		 rst,
	input  [3:0]		 sw,
	input       		 btnR,
	input       		 btnU,
	input       		 btnD,
	input       		 btnL,

	output[MSEC_WIDTH - 1:0] s_msec,
	output[ SEC_WIDTH - 1:0] s_sec,
	output[ MIN_WIDTH - 1:0] s_min,
	output[HOUR_WIDTH - 1:0] s_hour,
	
	output[MSEC_WIDTH - 1:0] w_msec,
	output[ SEC_WIDTH - 1:0] w_sec,
	output[ MIN_WIDTH - 1:0] w_min,
	output[HOUR_WIDTH - 1:0] w_hour,
	
	output [1:0]		 hms
);

    wire w_runstop, w_clear, w_mode;
    wire w_btnR, w_btnL, w_btnU, w_btnD;

    wire [1:0] w_watch_updn, w_aj_watch_hms;
    wire w_watch_stopwatch, w_hour_sec;

    wire w_flash;

    wire w_watch_clear;
    
    control_unit U_CONTROL_UNIT (
        .clk          (clk),
        .rst          (rst),
        .btnD         (btnD),             // mode
        .btnL         (btnL),             // clear
        .btnR         (btnR),             // run/stop
        .btnU         (btnU),             // 
        .flash        (flash),
        .sw           (sw),                 // 
        .run_stop     (w_runstop),          // 
        .clear        (w_clear),            // 
        .mode         (w_mode),             // 
        
        .watch_up_dn  (w_watch_updn),       //  UD
        .sel_watch_hms(hms),     //  SH
        .sel_w_sw     (w_watch_stopwatch),  //  sw[1]
        .sel_hour_sec (w_hour_sec),         //  sw[0] or SH[1]
        .watch_clear  (w_watch_clear)
    );

    stopwatch_datapatch U_STOPWATCH_DATAPATH (
        .clk      (clk),
        .rst      (rst),
        .i_runstop(w_runstop),
        .i_clear  (w_clear),
        .i_mode   (w_mode),
        .msec     (s_msec),
        .sec      (s_sec),
        .min      (s_min),
        .hour     (s_hour)
    );

    watch_datapath U_WATCH_DATAPATH (
        .clk          (clk),
        .rst          (rst),
        .watch_up     (w_watch_updn[1]),  // btnU
        .watch_down   (w_watch_updn[0]),  // btnD
        .sel_watch_hms(hms),   // sel_time_hms
        .watch_clear  (w_watch_clear),
        .msec         (w_msec),
        .sec          (w_sec),
        .min          (w_min),
        .hour         (w_hour)
    );

endmodule
