`timescale 1ns / 1ps

module TOP_dht11(
	input		clk,
	input		rst,
	input		dht11_start,
	output [15:0]	humidity,
	output [15:0]	temprature,
	output		valid,
	inout		dht11
    );

	wire w_btn, w_tick;

	dht11_con U_DHT11_CON (
		.clk(clk),
		.rst(rst),
		.dht11_start(dht11_start),
		.tick_us(w_tick),
		.hum(humidity),
		.temp(temprature),
		.valid(valid),
		.dht11(dht11)
	);

	tick_gen_us U_TICK_GEN_US (
		.clk(clk),
		.rst(rst),
		.tick_us(w_tick)
	);

endmodule

module dht11_con (
	input		clk,
	input		rst,
	input		dht11_start,
	input		tick_us,
	output [15:0]	hum,
	output [15:0]	temp,
	output		valid,
	inout		dht11
);



	parameter IDLE		= 0;
	parameter START		= 1;
	parameter WAIT		= 2;
	parameter SYNCL		= 3;
	parameter SYNCH		= 4;
	parameter DATA_SYNC	= 5;
	parameter DATA_READ	= 6;
	parameter DATA_SAVE	= 7;	
	parameter STOP		= 8;

	reg out_sel_reg, out_sel_next;
	reg dht11_reg, dht11_next;
	reg [3:0] cstate, nstate;
	reg [14:0] tick_cnt_reg, tick_cnt_next;
	reg [5:0] bit_cnt_reg, bit_cnt_next;
	reg [39:0] data_reg, data_next;

	reg [9:0] check_sum;

	reg [3:0] sync_reg, sync_next;

	wire sync_and;
	reg sync_before;

	assign sync_and = &sync_reg;
	
	assign dht11 = (out_sel_reg) ? dht11_reg : 1'bz;
	assign hum = data_reg[39:24];
	assign temp = data_reg[23:8];

	assign valid = (check_sum[7:0] == data_reg[7:0]) ? 1'b1 : 1'b0;

	always @(*) begin
		check_sum = (data_reg[39:32] + data_reg[31:24] + data_reg[23:16] + data_reg[15:8]);
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cstate       <= IDLE;
			tick_cnt_reg <= 0;
			bit_cnt_reg  <= 0;
			data_reg     <= 0;
			out_sel_reg  <= 1;
			dht11_reg    <= 1;
			sync_before  <= 1'b0;
		end else begin
			cstate 	     <= nstate;
			tick_cnt_reg <= tick_cnt_next;
			bit_cnt_reg  <= bit_cnt_next;
			data_reg     <= data_next;
			out_sel_reg  <= out_sel_next;
			dht11_reg    <= dht11_next;
			sync_before  <= sync_and;
		end
	end

	always @(posedge tick_us or posedge rst) begin
		if (rst) begin
			sync_reg <= 0;
		end else begin
			sync_reg <= sync_next;
		end
	end

	always @(*) begin
		sync_next = {dht11, sync_reg[3:1]};
	end

	always @(*) begin
		nstate 	      = cstate;
		tick_cnt_next = tick_cnt_reg;
		bit_cnt_next  = bit_cnt_reg;
		data_next     = data_reg;
		out_sel_next  = out_sel_reg;
		dht11_next    = dht11_reg;
		case(cstate)
			IDLE	: begin
				dht11_next = 1'b1;
				out_sel_next = 1'b1;
				if (dht11_start) begin
					nstate = START;
					tick_cnt_next = 0;
					bit_cnt_next = 0;
				end
			end
			START	: begin
				dht11_next = 1'b0;
				if (tick_us) begin
					if (tick_cnt_reg == 20000) begin
						tick_cnt_next = 0;
						nstate = WAIT;
					end else begin
						tick_cnt_next = tick_cnt_reg + 1;
					end
				end
			end
			WAIT	: begin
				dht11_next = 1'b1;
				if (tick_us) begin
					if (tick_cnt_reg == 30) begin
						nstate = SYNCL;
						tick_cnt_next = 0;
					end else begin
						tick_cnt_next = tick_cnt_reg + 1;
					end
				end
			end
			SYNCL	: begin	// posedge
				out_sel_next = 1'b0;
				if (!sync_before && sync_and) begin
					nstate = SYNCH;
				end
			end
			SYNCH	: begin	// negedge
				if (sync_before && !sync_and) begin
					nstate = DATA_SYNC;
					bit_cnt_next = 0;
				end
			end
			DATA_SYNC:begin	// posedge 5
				if (!sync_before && sync_and) begin
					nstate = DATA_READ;
				end 
			end
			DATA_READ:begin
				if (tick_us) begin // 6
					if (tick_cnt_reg > 50) begin
						nstate = DATA_SAVE;
						tick_cnt_next = 0;
					end else begin
						tick_cnt_next = tick_cnt_reg + 1;
					end
				end
			end
			DATA_SAVE:begin		// 7
				data_next = {data_reg[38:0], dht11};
				tick_cnt_next = 0;
				bit_cnt_next = bit_cnt_reg + 1;
				if (bit_cnt_reg == 39) begin
					nstate = STOP;
				end else begin
					nstate = DATA_SYNC;
				end
			end
			STOP	: begin
				if (tick_us) begin
					if (tick_cnt_reg == 50) begin
						nstate = IDLE;
						tick_cnt_next = 0;
					end else begin
						tick_cnt_next = tick_cnt_reg + 1;
					end
				end
			end
		endcase
	end

endmodule

module tick_gen_us (
	input		clk,
	input		rst,
	output reg	tick_us
);

	parameter F_COUNT = 100_000_000 / 1_000_000;
	reg [$clog2(F_COUNT)-1:0] counter_reg;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			counter_reg <= 0;
			tick_us	    <= 1'b0;
		end else begin
			counter_reg <= counter_reg + 1;
			if (counter_reg == F_COUNT - 1) begin
				counter_reg	<= 0;
				tick_us		<= 1'b1;
			end else begin
				tick_us <= 1'b0;
			end
		end
	end

endmodule
