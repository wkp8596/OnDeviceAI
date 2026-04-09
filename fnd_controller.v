`timescale 1ns / 1ps

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

module counter_4 (
    input clk,
    input rst,
    output [1:0] digit_sel
);

    reg [1:0] counter_reg;

    assign digit_sel = counter_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_reg <= 2'b00;
        end else begin
            counter_reg <= counter_reg + 2'b01;
        end
    end

endmodule

module digit_splitter (
    input  [7:0] digit_in,
    output [3:0] digit_1,    //  a % 10
    output [3:0] digit_10,   //  a / 10 % 10
    output [3:0] digit_100,  //  a / 100 % 10
    output [3:0] digit_1000  //  a / 1000 % 10
);

    assign digit_1 = digit_in % 10;
    assign digit_10 = digit_in / 10 % 10;
    assign digit_100 = digit_in / 100 % 10;
    assign digit_1000 = 4'b0000;
    //assign digit_1000 = digit_in / 1000 % 10;

endmodule

module MUX_4x1 (
    input  [3:0] in0,     //  digit 1
    input  [3:0] in1,     //  digit 10
    input  [3:0] in2,     //  digit 100
    input  [3:0] in3,     //  digit 1000
    input  [1:0] sel,     //  to select input
    output [3:0] out_mux
);

    reg [3:0] out_reg;

    assign out_mux = out_reg;

    always @(*) begin  //  senstivity list
        case (sel)
            2'b00:   out_reg = in0;
            2'b01:   out_reg = in1;
            2'b10:   out_reg = in2;
            2'b11:   out_reg = in3;
            default: out_reg = 4'bxxxx;
        endcase
    end

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

module fnd_controller (
    input  [7:0] fnd_in,
    input        clk,
    input        rst,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    wire [3:0] w_out_mux, w_digit_1, w_digit_10, w_digit_100, w_digit_1000;
    wire [1:0] w_digit_sel;
    wire w_1khz;

    clk_div_1khz  U_CLK_1KHZ(   //100MHz ->> 1kHz   100000 times -> one posedge => 50000 clk one reverse
        .clk(clk),
        .rst(rst),
        .o_1khz(w_1khz)
    );

    counter_4 U_COUNTER_4 (
        .clk(w_1khz),
        .rst(rst),
        .digit_sel(w_digit_sel)
    );

    digit_splitter U_DIGIT_SPLIT (
        .digit_in(fnd_in),
        .digit_1(w_digit_1),  //  a % 10
        .digit_10(w_digit_10),  //  a / 10 % 10
        .digit_100(w_digit_100),  //  a / 100 % 10
        .digit_1000(w_digit_1000)  //  a / 1000 % 10
    );

    MUX_4x1 U_MUX_4x1 (
        .in0(w_digit_1),     //  digit 1
        .in1(w_digit_10),     //  digit 10
        .in2(w_digit_100),     //  digit 100
        .in3(w_digit_1000),     //  digit 1000
        .sel(w_digit_sel),     //  to select input
        .out_mux(w_out_mux)
    );

    bcd U_bcd (
        .bin(w_out_mux),
        .bcd_data(fnd_data)
    );

    decoder_2x4 U_DECODER_2x4 (
        .decoder_in(w_digit_sel),
        .fnd_com(fnd_com)
    );

    //assign fnd_com = 4'b1110;

endmodule

//4 bit fnd_controller
module fnd_controller_4 (
    input  [3:0] bin,
    output [7:0] fnd_data,
    output [3:0] fnd_com
);

    bcd U_bcd (
        .bin(bin),
        .bcd_data(fnd_data)
    );

    assign fnd_com = 4'b1110;

endmodule

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
            4'b1110: bcd_data = 8'h86;
            4'b1111: bcd_data = 8'h8e;

            default: bcd_data = 8'hff;
        endcase
    end

endmodule
