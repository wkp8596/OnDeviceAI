`timescale 1ns / 1ps

module fnd_controller #(
    parameter MSEC_WIDTH = 7,
    SEC_WIDTH = 6,
    MIN_WIDTH = 6,
    HOUR_WIDTH = 5
) (
    input clk,
    input rst,
    input sw,  // sw[0], 0: msec_sec, 1: min_hour
    input [1:0] sel_watch_hms,
    input [MSEC_WIDTH -1:0] msec,
    input [SEC_WIDTH -1:0] sec,
    input [MIN_WIDTH -1:0] min,
    input [HOUR_WIDTH -1:0] hour,
    output flash,
    output [7:0] fnd_data,
    output reg [3:0] fnd_com
);

    wire [3:0] w_out_mux_msec_sec, w_out_mux_min_hour, w_out_mux;
    wire [2:0] w_digit_sel;
    wire w_1khz;

    wire [3:0] w_msec_digit_1, w_msec_digit_10;
    wire [3:0] w_sec_digit_1, w_sec_digit_10;
    wire [3:0] w_min_digit_1, w_min_digit_10;
    wire [3:0] w_hour_digit_1, w_hour_digit_10;

    wire w_comp;  // 0.5 sec -> dp on/off

    assign flash = w_comp;

    // digit splitter x 4

    digit_splitter #(
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_DS (
        .digit_in(msec),
        .digit_1 (w_msec_digit_1),  //  a % 10
        .digit_10(w_msec_digit_10)  //  a / 10 % 10
    );

    digit_splitter #(
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_DS (
        .digit_in(sec),
        .digit_1 (w_sec_digit_1),  //  a % 10
        .digit_10(w_sec_digit_10)  //  a / 10 % 10
    );

    digit_splitter #(
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_DS (
        .digit_in(min),
        .digit_1 (w_min_digit_1),  //  a % 10
        .digit_10(w_min_digit_10)  //  a / 10 % 10
    );

    digit_splitter #(
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_DS (
        .digit_in(hour),
        .digit_1 (w_hour_digit_1),  //  a % 10
        .digit_10(w_hour_digit_10)  //  a / 10 % 10
    );

    comparator #(
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_COMP (
        .msec  (msec),
        .dp_con(w_comp)
    );


    MUX_8x1 U_MUX_MSEC_SEC (
        .in0    (w_msec_digit_1),     //  digit 1
        .in1    (w_msec_digit_10),    //  digit 10
        .in2    (w_sec_digit_1),      //  digit 100
        .in3    (w_sec_digit_10),     //  digit 1000
        .in4    (4'hf),               //  dp on off mode
        .in5    (4'hf),               //  dp on off mode
        .in6    ({3'b111, w_comp}),   //  dp on off mode     
        .in7    (4'hf),               //  dp on off mode
        .sel    (w_digit_sel),        //  to select input
        .out_mux(w_out_mux_msec_sec)
    );

    MUX_8x1 U_MUX_MIN_HOUR (
        .in0    (w_min_digit_1),      //  digit 1
        .in1    (w_min_digit_10),     //  digit 10
        .in2    (w_hour_digit_1),     //  digit 100
        .in3    (w_hour_digit_10),    //  digit 1000
        .in4    (4'hf),               //  dp on off mode
        .in5    (4'hf),               //  dp on off mode
        .in6    ({3'b111, w_comp}),   //  dp on off mode     
        .in7    (4'hf),               //  dp on off mode
        .sel    (w_digit_sel),        //  to select input
        .out_mux(w_out_mux_min_hour)
    );




    //2x1

    MUX_2x1 U_MUX_SEC_HOUR (
        .in0(w_out_mux_msec_sec),
        .in1(w_out_mux_min_hour),
        .sel(sw),
        .out_mux(w_out_mux)
    );

    bcd U_bcd (
        .bin     (w_out_mux),
        .bcd_data(fnd_data)
    );

    clk_div_1khz  U_CLK_1KHZ(   //100MHz ->> 1kHz   100000 times -> one posedge => 50000 clk one reverse
        .clk   (clk),
        .rst   (rst),
        .o_1khz(w_1khz)
    );

    counter_8 U_COUNTER_8 (
        .clk      (w_1khz),
        .rst      (rst),
        .digit_sel(w_digit_sel)
    );

    wire [3:0] o_decoder;  //fnd_com

    decoder_2x4 U_DECODER_2x4 (
        .decoder_in(w_digit_sel[1:0]),
        .fnd_com   (o_decoder)
    );

    always @(*) begin
        case (sel_watch_hms)
            2'b00:
            if (o_decoder == 4'b0111 || o_decoder == 4'b1011) begin
                fnd_com = {
                    !(w_comp & !o_decoder[3]),
                    !(w_comp & !o_decoder[2]),
                    1'b1,
                    1'b1
                };
            end else begin
                fnd_com = o_decoder;
            end
            2'b01: begin
                fnd_com = o_decoder;
            end
            2'b10:
            if (o_decoder == 4'b1110 || o_decoder == 4'b1101) begin
                fnd_com = {
                    1'b1,
                    1'b1,
                    !(w_comp & !o_decoder[1]),
                    !(w_comp & !o_decoder[0])
                };
            end else begin
                fnd_com = o_decoder;
            end
            2'b11:
            if (o_decoder == 4'b0111 || o_decoder == 4'b1011) begin
                fnd_com = {
                    !(w_comp & !o_decoder[3]),
                    !(w_comp & !o_decoder[2]),
                    1'b1,
                    1'b1
                };
            end else begin
                fnd_com = o_decoder;
            end
            default: fnd_com = o_decoder;
        endcase


    end

    //assign fnd_com = 4'b1110;

endmodule

module comparator #(
    parameter BIT_WIDTH = 7
) (
    input  [BIT_WIDTH-1:0] msec,
    output                 dp_con
);
    //0-49: 0, 50-99: 1
    assign dp_con = (msec > 49) ? 0 : 1;

endmodule

module counter_8 (
    input        clk,
    input        rst,
    output [2:0] digit_sel
);

    reg [2:0] counter_reg;

    assign digit_sel = counter_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= 3'b00;
        end else begin
            counter_reg <= counter_reg + 3'b01;
        end
    end

endmodule

module digit_splitter #(
    parameter BIT_WIDTH = 7
) (
    input  [BIT_WIDTH - 1:0] digit_in,
    output [            3:0] digit_1,   //  a % 10
    output [            3:0] digit_10   //  a / 10 % 10
    // output [ 3:0] digit_100,  //  a / 100 % 10
    // output [ 3:0] digit_1000  //  a / 1000 % 10
);

    assign digit_1  = digit_in % 10;
    assign digit_10 = digit_in / 10 % 10;
    //assign digit_100 = digit_in / 100 % 10;
    //assign digit_1000 = digit_in / 1000 % 10;

endmodule

module clk_div_1khz (   //100MHz ->> 1kHz   100000 times -> one posedge => 50000 clk one reverse
    input  clk,
    input  rst,
    output o_1khz
);

    reg [15:0] counter_reg;
    reg o_1khz_reg;

    assign o_1khz = o_1khz_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= 16'b0;
            o_1khz_reg  <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == (50_000 - 1)) begin
                counter_reg <= 16'b0;
                o_1khz_reg  <= !o_1khz_reg;
            end
        end

    end

endmodule

module MUX_8x1 (
    input  [3:0] in0,     //  digit 1
    input  [3:0] in1,     //  digit 10
    input  [3:0] in2,     //  digit 100
    input  [3:0] in3,     //  digit 1000
    input  [3:0] in4,     //  off
    input  [3:0] in5,     //  off
    input  [3:0] in6,     //  dp on / off
    input  [3:0] in7,     //  off
    input  [2:0] sel,     //  to select input
    output [3:0] out_mux
);

    reg [3:0] out_reg;

    assign out_mux = out_reg;

    always @(*) begin  //  senstivity list
        case (sel)
            3'b000:  out_reg = in0;
            3'b001:  out_reg = in1;
            3'b010:  out_reg = in2;
            3'b011:  out_reg = in3;
            3'b100:  out_reg = in4;
            3'b101:  out_reg = in5;
            3'b110:  out_reg = in6;
            3'b111:  out_reg = in7;
            default: out_reg = 4'bxxxx;
        endcase
    end

endmodule

module MUX_2x1 (
    input  [3:0] in0,
    input  [3:0] in1,
    input        sel,
    output [3:0] out_mux
);
    assign out_mux = sel ? in1 : in0;

endmodule

module decoder_2x4 (
    input  [1:0] decoder_in,
    output [3:0] fnd_com
);

    reg [3:0] fnd_com_reg;

    assign fnd_com = fnd_com_reg;

    always @(*) begin
        case (decoder_in)
            2'b00:   fnd_com_reg = 4'b1110;
            2'b01:   fnd_com_reg = 4'b1101;
            2'b10:   fnd_com_reg = 4'b1011;
            2'b11:   fnd_com_reg = 4'b0111;
            default: fnd_com_reg = 4'b1111;
        endcase
    end

endmodule


//  //4 bit fnd_controller
//  module fnd_controller_4 (
//      input  [3:0] bin,
//      output [7:0] fnd_data,
//      output [3:0] fnd_com
//  );
//  
//      bcd U_bcd (
//          .bin        (bin),
//          .bcd_data   (fnd_data)
//      );
//  
//      assign fnd_com = 4'b1110;
//  
//  endmodule

module bcd (
    input      [3:0] bin,
    output reg [7:0] bcd_data
);

    always @(bin) begin
        case (bin)
            4'b0000: bcd_data = 8'hc0;
            4'b0001: bcd_data = 8'hf9;
            4'b0010: bcd_data = 8'ha4;
            4'b0011: bcd_data = 8'hb0;
            4'b0100: bcd_data = 8'h99;
            4'b0101: bcd_data = 8'h92;
            4'b0110: bcd_data = 8'h82;
            4'b0111: bcd_data = 8'hf8;
            4'b1000: bcd_data = 8'h80;
            4'b1001: bcd_data = 8'h90;
            4'b1010: bcd_data = 8'h88;
            4'b1011: bcd_data = 8'h83;
            4'b1100: bcd_data = 8'hc6;
            4'b1101: bcd_data = 8'ha1;
            4'b1110: bcd_data = 8'h7f;  //14    -> dp off
            4'b1111: bcd_data = 8'hff;  //15    -> dp on

            default: bcd_data = 8'hff;
        endcase
    end

endmodule
