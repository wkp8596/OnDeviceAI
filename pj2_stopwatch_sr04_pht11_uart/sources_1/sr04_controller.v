`timescale 1ns / 1ps

module TOP_sr04_controller(
	input		clk,
	input		rst,
	input		sr04_start,
	input		echo,
	output		trig,
	output [8:0]	distance
    );

    	wire w_tick_us, w_tick_58us;

    	sr04_controller U_SR04 (
		.clk(clk),
		.rst(rst),
		.sr04_start(sr04_start),
		.tick_us(w_tick_us),
		.tick_58us(w_tick_58us),
		.echo(echo),
		.trig(trig),
		.distance(distance)
	);

	tick_gen_us U_TICK_GEN_SR (
		.clk(clk),
		.rst(rst),
		.tick_us(w_tick_us)
	);

	tick_gen_58us U_TICK_GEN_58US (
		.clk(clk),
		.rst(rst),
		.tick_58us(w_tick_58us)
	);

endmodule

module sr04_controller (
	input		clk,
	input		rst,
	input		sr04_start,
	input		tick_us,
	input		tick_58us,
	input		echo,
	output reg	trig,
	output [8:0]	distance
);

	parameter IDLE = 0, START = 1, WAIT = 2, RESPONSE = 3;	

	reg [1:0] cstate, nstate;
	reg [4:0] tick_cnt_reg, tick_cnt_next;
	reg [8:0] tick_58_cnt_reg, tick_58_cnt_next;
	reg [8:0] dist_reg, dist_next;

	assign distance = dist_reg;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cstate		<= IDLE;
			tick_cnt_reg	<= 0;
			dist_reg	<= 0;
			tick_58_cnt_reg <= 0;
		end else begin
			cstate		<= nstate;
			tick_cnt_reg	<= tick_cnt_next;
			dist_reg	<= dist_next;
			tick_58_cnt_reg <= tick_58_cnt_next;
		end
	end

	always @(*) begin
		nstate = cstate;
		tick_cnt_next = tick_cnt_reg;
		dist_next = dist_reg;
		tick_58_cnt_next = tick_58_cnt_reg;
		case (cstate)
			IDLE	:	begin
				trig = 1'b0;
				if (sr04_start) begin
					nstate = START;
					tick_cnt_next = 0;
					tick_58_cnt_next = 0;
				end
			end
			START	:	begin
				trig = 1'b1;
				if (tick_us) begin
					if (tick_cnt_reg == 11) begin
						nstate = WAIT;
						tick_cnt_next = 0;
					end else begin
						tick_cnt_next = tick_cnt_reg + 1;
					end
				end
			end
			WAIT	:	begin
				trig = 1'b0;
				if (echo && tick_us) begin
					nstate = RESPONSE;
				end
			end
			RESPONSE:	begin
				trig = 1'b0;
				if (tick_58us) begin
					tick_58_cnt_next = tick_58_cnt_reg + 1;
					if (!echo) begin
						nstate = IDLE;
						dist_next = tick_58_cnt_reg;
					end
				end
			end
		endcase
	end

endmodule

module tick_gen_58us (
	input		clk,
	input		rst,
	output reg	tick_58us
);

	parameter F_COUNT = 100_000_000 / 1_000_000 * 58;
	reg [$clog2(F_COUNT)-1:0] counter_reg;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			counter_reg <= 0;
			tick_58us	    <= 1'b0;
		end else begin
			counter_reg <= counter_reg + 1;
			if (counter_reg == F_COUNT - 1) begin
				counter_reg	<= 0;
				tick_58us		<= 1'b1;
			end else begin
				tick_58us <= 1'b0;
			end
		end
	end

endmodule
