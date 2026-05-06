`timescale 1ns / 1ps

module ascii_decoder(
	input		clk,
	input		rst,
	input		fifo_rx_empty,
	input  [7:0]	rx_data,
	output		fifo_rx_pop,
	output [4:0]	alphabet,
	output 		out_vld
    );

	parameter IDLE = 0, RX = 1;

	reg cstate, nstate;
	reg rx_pop_reg, rx_pop_next;
	reg out_vld_reg, out_vld_next;
	
	ascii_rom U_ASCII_ROM (
		.ascii(rx_data),
		.alphabet(alphabet)
	);

	assign fifo_rx_pop = rx_pop_reg;
	assign out_vld = out_vld_reg;

	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cstate		<= IDLE;
			rx_pop_reg	<= 0;
			out_vld_reg	<= 0;
		end else begin
			cstate		<= nstate;
			rx_pop_reg	<= rx_pop_next;
			out_vld_reg	<= out_vld_next;
		end
	end

	always @(*) begin
		nstate = cstate;
		rx_pop_next = rx_pop_reg;
		out_vld_next = out_vld_reg;
		case (cstate)
			IDLE	: begin
				rx_pop_next = 1'b0;
				out_vld_next = 1'b0;
				if (!fifo_rx_empty & !out_vld_reg) begin
					nstate = RX;
				end
			end
			RX	: begin
				rx_pop_next = 1'b1;
				out_vld_next = 1'b1;
				nstate = IDLE;
			end
		endcase
	end

endmodule

module ascii_rom (
	input [7:0] ascii,
	output reg [4:0] alphabet
);

	always @(*) begin
		case (ascii) 
			8'h41: alphabet   = 5'b00000;	// A
			8'h42: alphabet   = 5'b00001;	// B
			8'h43: alphabet   = 5'b00010;	// C 
			8'h44: alphabet   = 5'b00011;	// D
			8'h45: alphabet   = 5'b00100;	// E
			8'h46: alphabet   = 5'b00101;	// F
			8'h47: alphabet   = 5'b00110;	// G
			8'h48: alphabet   = 5'b00111;	// H
			8'h49: alphabet   = 5'b01000;	// I
			8'h4a: alphabet   = 5'b01001;	// J
			8'h4b: alphabet   = 5'b01010;	// K
			8'h4c: alphabet   = 5'b01011;	// L
			8'h4d: alphabet   = 5'b01100;	// M
			8'h4e: alphabet   = 5'b01101;	// N
			8'h4f: alphabet   = 5'b01110;	// O
			8'h50: alphabet   = 5'b01111;	// P
			8'h51: alphabet   = 5'b10000;	// Q
			8'h52: alphabet   = 5'b10001;	// R
			8'h53: alphabet   = 5'b10010;	// S
			8'h54: alphabet   = 5'b10011;	// T
			8'h55: alphabet   = 5'b10100;	// U
			8'h56: alphabet   = 5'b10101;	// V
			8'h57: alphabet   = 5'b10110;	// W
			8'h58: alphabet   = 5'b10111;	// X
			8'h59: alphabet   = 5'b11000;	// Y
			8'h5a: alphabet   = 5'b11001;	// Z
			8'h61: alphabet   = 5'b00000;	// a
			8'h62: alphabet   = 5'b00001;
			8'h63: alphabet   = 5'b00010;
			8'h64: alphabet   = 5'b00011;
			8'h65: alphabet   = 5'b00100;
			8'h66: alphabet   = 5'b00101;
			8'h67: alphabet   = 5'b00110;
			8'h68: alphabet   = 5'b00111;
			8'h69: alphabet   = 5'b01000;
			8'h6a: alphabet   = 5'b01001;
			8'h6b: alphabet   = 5'b01010;
			8'h6c: alphabet   = 5'b01011;
			8'h6d: alphabet   = 5'b01100;
			8'h6e: alphabet   = 5'b01101;
			8'h6f: alphabet   = 5'b01110;
			8'h70: alphabet   = 5'b01111;
			8'h71: alphabet   = 5'b10000;
			8'h72: alphabet   = 5'b10001;
			8'h73: alphabet   = 5'b10010;
			8'h74: alphabet   = 5'b10011;
			8'h75: alphabet   = 5'b10100;
			8'h76: alphabet   = 5'b10101;
			8'h77: alphabet   = 5'b10110;
			8'h78: alphabet   = 5'b10111;
			8'h79: alphabet   = 5'b11000;
			8'h7a: alphabet   = 5'b11001;	// z
			default: alphabet = 5'b11111;
		endcase
	end

endmodule
