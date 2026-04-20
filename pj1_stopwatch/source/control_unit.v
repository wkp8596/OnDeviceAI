`timescale 1ns / 1ps

module control_unit (
    input            clk,
    input            rst,
    input            btnD,           // mode
    input            btnL,           // clear
    input            btnR,           // run/stop
    input            btnU,
    input      [3:0] sw,
    input            flash,
    output           run_stop,
    output           clear,
    output           mode,
    output reg [1:0] watch_up_dn,    //  UD
    output reg [1:0] sel_watch_hms,  //  SH
    output reg       sel_w_sw,       //  sw[1]
    output reg       sel_hour_sec,   //  sw[0] or SH[1]
    output reg       watch_clear,
    output     [6:0] o_led
);

    parameter CLEAR = 3'b000;
    parameter STOP = 3'b001;
    parameter RUN = 3'b010;
    parameter MODE = 3'b011;
    parameter CLOCK = 3'b100;
    parameter SEC_AJ = 3'b101;
    parameter MIN_AJ = 3'b110;
    parameter HOUR_AJ = 3'b111;

    reg [2:0] cstate, nstate;
    reg mode_bar, runstop_reg;

    // state register

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cstate <= CLOCK;
        end else begin
            cstate <= nstate;
        end
    end

    // state move CL

    always @(*) begin
        case (cstate)
            CLEAR: nstate = STOP;

            RUN: nstate = (btnR) ? STOP : (!sw[1]) ? CLOCK : RUN;

            MODE: nstate = STOP;

            STOP:
            nstate = (!sw[1]) ? CLOCK : btnR ? RUN : btnL ? CLEAR : btnD ? MODE : STOP;

            CLOCK:
            nstate = (sw[2]) ? SEC_AJ : (sw[1] & !run_stop) ? STOP : (sw[1] & run_stop) ? RUN : CLOCK;

            SEC_AJ:
            nstate = (!sw[2]) ? CLOCK : btnR ? HOUR_AJ : btnL ? MIN_AJ : SEC_AJ;

            MIN_AJ:
            nstate = (!sw[2]) ? CLOCK : btnR ? SEC_AJ : btnL ? HOUR_AJ : MIN_AJ;

            HOUR_AJ:
            nstate = (!sw[2]) ? CLOCK : btnR ? MIN_AJ : btnL ? SEC_AJ : HOUR_AJ;

            default: nstate = STOP;
        endcase
    end

    // output CL

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mode_bar <= 1'b1;
        end else begin
            mode_bar <= ~mode;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            runstop_reg <= 1'b0;
        end else begin
            runstop_reg <= run_stop;
        end
    end

    assign run_stop = (cstate == RUN) ? 1'b1 : (cstate == STOP) ? 1'b0 : runstop_reg;
    assign clear = (cstate == CLEAR) ? 1'b1 : 1'b0;
    assign mode = (cstate == MODE) ? mode_bar : ~mode_bar;
    assign o_led = {
        sel_w_sw,
        (cstate > 3'b100),
        ((cstate == HOUR_AJ & flash)),
        ((cstate == MIN_AJ) & flash),
        ((cstate == SEC_AJ) & flash),
        (run_stop & flash),
        mode
    };

    always @(*) begin
        sel_watch_hms = 2'b01;
        watch_up_dn = 2'b00;
        sel_w_sw = 1'b1;
        sel_hour_sec = 1'b0;
        watch_clear = 1'b0;
        case (cstate)
            CLEAR: begin
                sel_w_sw = 1'b0;
                sel_hour_sec = sw[0];
            end
            STOP: begin
                sel_w_sw = 1'b0;
                sel_hour_sec = sw[0];
            end
            RUN: begin
                sel_w_sw = 1'b0;
                sel_hour_sec = sw[0];
            end
            MODE: begin
                sel_w_sw = 1'b0;
                sel_hour_sec = sw[0];
            end
            CLOCK: begin
                sel_w_sw = 1'b1;
                sel_hour_sec = sw[0];
            end
            SEC_AJ: begin
                sel_w_sw = 1'b1;
                sel_watch_hms = 2'b00;
                sel_hour_sec = 1'b0;
                if (btnD) begin
                    watch_up_dn = 2'b01;
                end else if (btnU) begin
                    watch_up_dn = 2'b10;
                end else if (sw[3]) begin
                    watch_clear = 1'b1;
                end else begin
                    watch_up_dn = 2'b00;
                end
            end
            MIN_AJ: begin
                sel_w_sw = 1'b1;
                sel_watch_hms = 2'b10;
                sel_hour_sec = 1'b1;
                if (btnD) begin
                    watch_up_dn = 2'b01;
                end else if (btnU) begin
                    watch_up_dn = 2'b10;
                end else begin
                    watch_up_dn = 2'b00;
                end
            end
            HOUR_AJ: begin
                sel_w_sw = 1'b1;
                sel_watch_hms = 2'b11;
                sel_hour_sec = 1'b1;
                if (btnD) begin
                    watch_up_dn = 2'b01;
                end else if (btnU) begin
                    watch_up_dn = 2'b10;
                end else begin
                    watch_up_dn = 2'b00;
                end
            end
            default: begin
                sel_watch_hms = 2'b01;
                watch_up_dn = 2'b00;
                sel_w_sw = 1'b0;
                sel_hour_sec = 1'b0;
            end
        endcase
    end

endmodule
