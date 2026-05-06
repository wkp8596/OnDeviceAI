`timescale 1ns / 1ps

module TOP(
	input		clk,
	input		rst,
	input [3:0]	btn,
	input [4:0]	switch,	// clear, aj, hour-sec, sw/w/ht/d
	input		rx,
	input		echo,
	output		trig,
	output		tx,
	output [7:0]	fnd_data,
	output [3:0]	fnd_com,

	output		led,

	inout		dht11
    );

    	wire [3:0] w_btn;

	wire w_rx_pop, w_tx_push, w_rx_empty, w_tx_full;
	wire [7:0] w_rx_data, w_tx_data;

	wire w_ascii_decoder_vld;
	wire [4:0] w_abc;

	wire [7:0] sw_w_con;

	wire w_dht11, w_sr04;

	wire [2:0] w_sender_con;

	wire [8:0] w_dist;
	wire [15:0] w_temp, w_hum;
	wire [6:0] w_w_msec, w_s_msec;
	wire [5:0] w_w_sec, w_s_sec;
	wire [5:0] w_w_min, w_s_min;
	wire [4:0] w_w_hour, w_s_hour;

	wire w_flash;

	wire [1:0] w_hms;

	button_debounce U_BD_R(
		.clk(clk),
		.rst(rst),
		.i_btn(btn[3]),
		.o_btn(w_btn[3])
	);
	button_debounce U_BD_L(
		.clk(clk),
		.rst(rst),
		.i_btn(btn[0]),
		.o_btn(w_btn[0])
	);
	button_debounce U_BD_U(
		.clk(clk),
		.rst(rst),
		.i_btn(btn[2]),
		.o_btn(w_btn[2])
	);
	button_debounce U_BD_D(
		.clk(clk),
		.rst(rst),
		.i_btn(btn[1]),
		.o_btn(w_btn[1])
	);

	uart_fifo U_UART_FIFO ( 
		.clk(clk),
		.rst(rst),
		.rx(rx),
		.fifo_rx_pop(w_rx_pop),
		.fifo_tx_push(w_tx_push),
		.tx_data(w_tx_data),
		.tx(tx),
		.rx_data(w_rx_data),
		.fifo_rx_empty(w_rx_empty),
		.fifo_tx_full(w_tx_full)
	);

	ascii_decoder U_ASCII_DECODER(
		.clk(clk),
		.rst(rst),
		.fifo_rx_empty(w_rx_empty),
		.rx_data(w_rx_data),
		.fifo_rx_pop(w_rx_pop),
		.alphabet(w_abc),
		.out_vld(w_ascii_decoder_vld)
	);

	top_ascii_sender U_ASCII_SENDER (
		.clk(clk),
		.rst(rst),

		.s_msec(w_s_msec),
		.s_sec(w_s_sec),
		.s_min(w_s_min),
		.s_hour(w_s_hour),
		
		.w_msec(w_w_msec),
		.w_sec(w_w_sec),
		.w_min(w_w_min),
		.w_hour(w_w_hour),
		
		.hum(w_hum),
		.temp(w_temp),

		.distance(w_dist),

		.sender_con(w_sender_con),
		.ascii_send_data(w_tx_data),
		.fifo_tx_push(w_tx_push)
	);
	
	top_control_unit U_TOP_CU (
		.clk(clk),
		.rst(rst),
		.alphabet(w_abc),
		.btn(w_btn),
		.switch(),
		.ascii_vld(w_ascii_decoder_vld),
		.sw_w_con(sw_w_con),	// 4 bit sw, 4 bit btn
		.sr04_start(w_sr04),
		.dht11_start(w_dht11),
		.sender_con(w_sender_con)
	);

	wire sw_w;

	assign sw_w = (switch[1:0] == 2'b01) ? 1'b1 : 1'b0;


	datapath U_DP(
		.clk(clk),
		.rst(rst),
		.sw_w_con({switch[4], switch[3], sw_w, switch[2], sw_w_con[3:0]}), // 4 bit sw, 4 bit btn
		
		.dht11_start(w_dht11),
		
		.sr04_start(w_sr04),
		.echo(echo),
		
		.s_msec(w_s_msec),
		.s_sec(w_s_sec),
		.s_min(w_s_min),
		.s_hour(w_s_hour),
		
		.w_msec(w_w_msec),
		.w_sec(w_w_sec),
		.w_min(w_w_min),
		.w_hour(w_w_hour),
		
		.humidity(w_hum),
		.temprature(w_temp),
		.dht11_vld(led),
		
		.trig(trig),
		.distance(w_dist),

		.hms(w_hms),

		.dht11(dht11)

	);


	fnd_controller #(
    		.MSEC_WIDTH(7),
    		.SEC_WIDTH(6),
    		.MIN_WIDTH(6),
    		.HOUR_WIDTH(5)
	) U_FND_CON (
		.clk(clk),
		.rst(rst),
		.sw(switch[1:0]),  // sw[0], 0: msec_sec, 1: min_hour
		.sel_watch_hms(w_hms),
		.w_msec(w_w_msec),
		.w_sec(w_w_sec),
		.w_min(w_w_min),
		.w_hour(w_w_hour),
		.s_msec(w_s_msec),
		.s_sec(w_s_sec),
		.s_min(w_s_min),
		.s_hour(w_s_hour),
		.distance(w_dist),
		.hum(w_hum[15:8]),
		.temp(w_temp[15:8]),
		.hs(switch[2]),
		.flash(w_flash),
		.fnd_data(fnd_data),
		.fnd_com(fnd_com)
);


endmodule

module top_control_unit (
	input		clk,
	input		rst,
	input [4:0]	alphabet,
	input [3:0]	btn,		// r u d l
	input [5:0]	switch,
	input		ascii_vld,
	output [7:0]	sw_w_con,	// 4 bit sw, 4 bit btn
	output reg	sr04_start,
	output reg	dht11_start,
	output reg[2:0]	sender_con
);

	parameter IDLE = 0, RX = 1, WAIT = 2, COMP = 3, CMD = 4;

	wire w_tick;

	wire [8:0] w_cmd;

	reg [2:0] cstate, nstate;
	reg [3:0] full_reg, full_next;

	reg [7:0] sw_w_con_reg, sw_w_con_next;

	reg [44:0] cmd_reg, cmd_next;

	reg [4:0] tick_cnt_reg, tick_cnt_next;

	assign sw_w_con = {sw_w_con_reg[7:4], btn | sw_w_con_reg[3:0]};
	
	tick_gen_9600 U_TICK_GEN_9600 (
		.clk(clk),
		.rst(rst),
		.tick(w_tick)
	);
	
	CU_rom U_CU_ROM(
		.word(cmd_reg),
		.cmd(w_cmd)
	);

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cstate	 <= IDLE;
			full_reg <= full_next;
			sw_w_con_reg <= 0;
			tick_cnt_reg <= 0;
			cmd_reg <= cmd_next;
		end else begin
			cstate 	 <= nstate;
			full_reg <= full_next;
			sw_w_con_reg <= sw_w_con_next;
			tick_cnt_reg <= tick_cnt_next;
			cmd_reg <= cmd_next;
		end
	end

	always @(*) begin
		nstate = cstate;
		full_next = full_reg;
		sw_w_con_next = {sw_w_con_reg[7:4], 4'b0000};
		tick_cnt_next = tick_cnt_reg;
		cmd_next = cmd_reg;
		sr04_start = 0;
		dht11_start = 0;
		sender_con = 0;
		case (cstate)
			IDLE	: begin
				sr04_start = 0;
				dht11_start = 0;
				sender_con = 0;
				tick_cnt_next = 0;
				cmd_next = 0;
				full_next = 0;
				if (ascii_vld) begin
					nstate = RX;
					cmd_next = {alphabet, cmd_reg[44:5]};
				end
			end
			RX	: begin
				full_next = full_reg + 1;
				tick_cnt_next = 0;
				nstate = COMP;
			end
			WAIT	: begin
				if (full_reg == 10) begin
					nstate = IDLE;
				end else begin
					if (ascii_vld) begin
						nstate = RX;
						cmd_next = {alphabet, cmd_reg[44:5]};
					end else begin
						if (w_tick) begin
							if (tick_cnt_reg > 15) begin
								nstate = IDLE;
								tick_cnt_next = 0;
							end else begin
								tick_cnt_next = tick_cnt_reg + 1;
							end
						end
					end
				end
			end
			COMP	: begin
				if (&w_cmd) begin
					nstate = WAIT;
				end else begin
					nstate = CMD;
				end
			end
			CMD	: begin
				nstate = IDLE;
				sw_w_con_next[3:0] = w_cmd[8:5];
				sr04_start = w_cmd[4];
				dht11_start = w_cmd[3];
				sender_con = w_cmd[2:0];
			end
		endcase
	end


endmodule

module tick_gen_9600 (
    input      clk,
    input      rst,
    output reg tick
);

    // baud tick 9600Hz tick gen => 16x speed
    parameter F_COUNT = 100_000_000 / (9_600);
    parameter WIDTH = $clog2(F_COUNT);

    reg [WIDTH - 1:0] cnt_reg;


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_reg  <= 0;
            tick <= 1'b0;
        end else begin
            cnt_reg <= cnt_reg + 1;
            if (cnt_reg == (F_COUNT - 1)) begin
                cnt_reg  <= 0;
                tick <= 1'b1;
            end else begin
                tick <= 1'b0;
            end
        end
    end

endmodule

module CU_rom(
    input [44:0]	word,
    output reg [8:0]	cmd // up, down, left, right, sr04, dht11, sender
    );

    always @(*) begin
        case (word)
            45'b01101_10100_10001_00000_00000_00000_00000_00000_00000:	cmd = 9'b1000_00_000;	//run
            45'b00100_10010_10100_00000_01111_00000_00000_00000_00000:	cmd = 9'b1000_00_000;	//pause
            45'b00100_00011_01110_01100_00000_00000_00000_00000_00000:	cmd = 9'b0010_00_000;	//mode
            45'b10001_00000_00100_01011_00010_00000_00000_00000_00000:	cmd = 9'b0001_00_000;	//clear
            45'b01111_10100_00000_00000_00000_00000_00000_00000_00000:	cmd = 9'b0100_00_000;	//up
            45'b01101_10110_01110_00011_00000_00000_00000_00000_00000:	cmd = 9'b0010_00_000;	//down
            45'b10011_00101_00100_01011_00000_00000_00000_00000_00000:	cmd = 9'b0001_00_000;	//left
            45'b10011_00111_00110_01000_10001_00000_00000_00000_00000:	cmd = 9'b1000_00_000;	//right

            45'b01111_01100_00100_10011_00000_00000_00000_00000_00000:	cmd = 9'b0000_01_001;	//temp
            45'b01100_10100_00111_00000_00000_00000_00000_00000_00000:	cmd = 9'b0000_01_010;	//hum
            45'b10011_10010_01000_00011_00000_00000_00000_00000_00000:	cmd = 9'b0000_10_011;	//dist
            45'b00111_00010_10011_00000_10110_00000_00000_00000_00000:	cmd = 9'b0000_00_100;	//watch
            45'b00111_00010_10011_00000_10110_01111_01110_10011_10010:	cmd = 9'b0000_00_101;	//stopwatch

            45'b01011_01011_00000_00000_00000_00000_00000_00000_00000:	cmd = 9'b0000_11_111;	//all
                                	       
            //45'b10001_10100_01110_00111_00000_00000_00000_00000_00000:	cmd = 9'b0000_00_000;	//hour
            //45'b01101_01000_01100_00000_00000_00000_00000_00000_00000:	cmd = 9'b0000_00_000;	//min
            //45'b00010_00100_10010_00000_00000_00000_00000_00000_00000:	cmd = 9'b0000_00_000;	//sec
            default: cmd = 9'b111_111_111; // &cmd = 1
        endcase
    end
endmodule



module datapath#(parameter MSEC_WIDTH = 7, SEC_WIDTH = 6, MIN_WIDTH = 6, HOUR_WIDTH = 5 ) (
	input				clk,
	input				rst,
	input [7:0]			sw_w_con, // 4 bit sw, 4 bit btn r u d l

	input				dht11_start,

	input				sr04_start,
	input				echo,

	output[MSEC_WIDTH - 1:0] 	s_msec,
	output[ SEC_WIDTH - 1:0] 	s_sec,
	output[ MIN_WIDTH - 1:0] 	s_min,
	output[HOUR_WIDTH - 1:0] 	s_hour,
	
	output[MSEC_WIDTH - 1:0] 	w_msec,
	output[ SEC_WIDTH - 1:0] 	w_sec,
	output[ MIN_WIDTH - 1:0] 	w_min,
	output[HOUR_WIDTH - 1:0] 	w_hour,

	output [15:0]		 	humidity,
	output [15:0]		 	temprature,
	output				dht11_vld,

	output				trig,
	output [8:0]			distance,

	output [1:0]			hms,

	inout dht11

);


	top_stopwatch_watch U_SW_W (
		.clk(clk),
		.rst(rst),
		.sw(sw_w_con[7:4]),
		.btnR(sw_w_con[3]),
		.btnU(sw_w_con[2]),
		.btnD(sw_w_con[1]),
		.btnL(sw_w_con[0]),

		.s_msec(s_msec),
		.s_sec(s_sec),
		.s_min(s_min),
		.s_hour(s_hour),
		
		.w_msec(w_msec),
		.w_sec(w_sec),
		.w_min(w_min),
		.w_hour(w_hour),

		.hms(hms)

	);


	TOP_dht11 U_DHT11(
		.clk(clk),
		.rst(rst),
		.dht11_start(dht11_start),
		.humidity(humidity),
		.temprature(temprature),
		.valid(dht11_vld),
		.dht11(dht11)
	);

	TOP_sr04_controller U_SR04(
		.clk(clk),
		.rst(rst),
		.sr04_start(sr04_start),
		.echo(echo),
		.trig(trig),
		.distance(distance)
	);


endmodule
