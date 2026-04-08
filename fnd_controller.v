`timescale 1ns / 1ps

module fnd_controller (
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
