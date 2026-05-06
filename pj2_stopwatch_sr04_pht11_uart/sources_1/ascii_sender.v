`timescale 1ns / 1ps

module top_ascii_sender (
    input clk,
    input rst,

    input [6:0] s_msec,
    input [5:0] s_sec,
    input [5:0] s_min,
    input [4:0] s_hour,

    input [6:0] w_msec,
    input [5:0] w_sec,
    input [5:0] w_min,
    input [4:0] w_hour,

    input [15:0] hum,
    input [15:0] temp,

    input [8:0] distance,

    input [2:0] sender_con,

    output [7:0]   ascii_send_data,
    output    fifo_tx_push
);

    wire w_tick_sender;

    wire [3:0] w_msec_1, w_msec_10, w_sec_1, w_sec_10, w_min_1, w_min_10, w_hour_1, w_hour_10;
    wire [3:0] s_msec_1, s_msec_10, s_sec_1, s_sec_10, s_min_1, s_min_10, s_hour_1, s_hour_10;

    wire [3:0] w_dist_1, w_dist_10, w_dist_100, w_dist_1000;

    wire [3:0] w_hum_1, w_hum_10, w_temp_1, w_temp_10;

    tick_gen_sneder U_TICK_GEN_SENDER (
        .clk(clk),
        .rst(rst),
        .tick_sender(w_tick_sender)
    );

    digit_split_10 #(
        .BIT_WIDTH(8)
    ) U_DS_HUM (
        .digit_in(hum[15:8]),
        .digit_1 (w_hum_1),
        .digit_10(w_hum_10)
    );

    digit_split_10 #(
        .BIT_WIDTH(8)
    ) U_DS_TEMP (
        .digit_in(temp[15:8]),
        .digit_1 (w_temp_1),
        .digit_10(w_temp_10)
    );

    digit_split_1000 #(
        .BIT_WIDTH(9)
    ) U_DS_DIST (
        .digit_in(distance),
        .digit_1(w_dist_1),
        .digit_10(w_dist_10),
        .digit_100(w_dist_100),
        .digit_1000(w_dist_1000)
    );

    digit_split_10 #(
        .BIT_WIDTH(7)
    ) U_DS_WMSEC (
        .digit_in(w_msec),
        .digit_1 (w_msec_1),
        .digit_10(w_msec_10)
    );

    digit_split_10 #(
        .BIT_WIDTH(6)
    ) U_DS_WSEC (
        .digit_in(w_sec),
        .digit_1 (w_sec_1),
        .digit_10(w_sec_10)
    );

    digit_split_10 #(
        .BIT_WIDTH(6)
    ) U_DS_WMIN (
        .digit_in(w_min),
        .digit_1 (w_min_1),
        .digit_10(w_min_10)
    );

    digit_split_10 #(
        .BIT_WIDTH(5)
    ) U_DS_WHOUR (
        .digit_in(w_hour),
        .digit_1 (w_hour_1),
        .digit_10(w_hour_10)
    );

    digit_split_10 #(
        .BIT_WIDTH(7)
    ) U_DS_SMSEC (
        .digit_in(s_msec),
        .digit_1 (s_msec_1),
        .digit_10(s_msec_10)
    );

    digit_split_10 #(
        .BIT_WIDTH(6)
    ) U_DS_SSEC (
        .digit_in(s_sec),
        .digit_1 (s_sec_1),
        .digit_10(s_sec_10)
    );

    digit_split_10 #(
        .BIT_WIDTH(6)
    ) U_DS_SMIN (
        .digit_in(s_min),
        .digit_1 (s_min_1),
        .digit_10(s_min_10)
    );

    digit_split_10 #(
        .BIT_WIDTH(5)
    ) U_DS_SHOUR (
        .digit_in(s_hour),
        .digit_1 (s_hour_1),
        .digit_10(s_hour_10)
    );

    ascii_sender_contol_unit U_ASCII_SENDER_CONTROL_UNIT (
        .clk(clk),
        .rst(rst),

        .w_msec_1 (w_msec_1),
        .w_msec_10(w_msec_10),
        .w_sec_1  (w_sec_1),
        .w_sec_10 (w_sec_10),
        .w_min_1  (w_min_1),
        .w_min_10 (w_min_10),
        .w_hour_1 (w_hour_1),
        .w_hour_10(w_hour_10),

        .s_msec_1 (s_msec_1),
        .s_msec_10(s_msec_10),
        .s_sec_1  (s_sec_1),
        .s_sec_10 (s_sec_10),
        .s_min_1  (s_min_1),
        .s_min_10 (s_min_10),
        .s_hour_1 (s_hour_1),
        .s_hour_10(s_hour_10),

        .w_dist_1(w_dist_1),
        .w_dist_10(w_dist_10),
        .w_dist_100(w_dist_100),
        .w_dist_1000(w_dist_1000),

        .w_hum_1 (w_hum_1),
        .w_hum_10(w_hum_10),

        .w_temp_1 (w_temp_1),
        .w_temp_10(w_temp_10),


        .sender_con(sender_con),
        .tick_sender(w_tick_sender),
        .send_data(ascii_send_data),
        .fifo_tx_push(fifo_tx_push)
    );

endmodule

module ascii_sender_contol_unit (
    input clk,
    input rst,
    input [2:0] sender_con,
    input tick_sender,

    input [3:0] w_msec_1,
    input [3:0] w_msec_10,
    input [3:0] w_sec_1,
    input [3:0] w_sec_10,
    input [3:0] w_min_1,
    input [3:0] w_min_10,
    input [3:0] w_hour_1,
    input [3:0] w_hour_10,

    input [3:0] s_msec_1,
    input [3:0] s_msec_10,
    input [3:0] s_sec_1,
    input [3:0] s_sec_10,
    input [3:0] s_min_1,
    input [3:0] s_min_10,
    input [3:0] s_hour_1,
    input [3:0] s_hour_10,

    input [3:0] w_dist_1,
    input [3:0] w_dist_10,
    input [3:0] w_dist_100,
    input [3:0] w_dist_1000,

    input [3:0] w_hum_1,
    input [3:0] w_hum_10,

    input [3:0] w_temp_1,
    input [3:0] w_temp_10,


    output reg [7:0] send_data,
    output reg fifo_tx_push
);

    parameter IDLE = 0, WAIT = 1, SEND_001 = 2;
    parameter SEND_010 = 3, SEND_011 = 4;
    parameter SEND_100 = 5, SEND_101 = 6;
    parameter SEND_110 = 7, SEND_111 = 8;

    reg [3:0] c_state, n_state;
    reg [4:0] tick_send_cnt_reg, tick_send_cnt_next;
    reg [3:0] cmd_reg, cmd_next;
    reg [6:0] cnt_reg, cnt_next;
    reg [6:0] all_cnt_reg, all_cnt_next;

    wire [7:0] w_ascii_o_temp, w_ascii_o_hum;
    wire [7:0] w_ascii_o_dist, w_ascii_o_time;
    wire [7:0] w_ascii_o_stw;

    reg  [3:0] w_mux_digit;

    reg  [4:0] mux_sel;

    wire [7:0] w_num;

    always @(*) begin
        case (mux_sel)
            5'd0: w_mux_digit = w_msec_1;
            5'd1: w_mux_digit = w_msec_10;
            5'd2: w_mux_digit = w_sec_1;
            5'd3: w_mux_digit = w_sec_10;
            5'd4: w_mux_digit = w_min_1;
            5'd5: w_mux_digit = w_min_10;
            5'd6: w_mux_digit = w_hour_1;
            5'd7: w_mux_digit = w_hour_10;

            5'd8:  w_mux_digit = s_msec_1;
            5'd9:  w_mux_digit = s_msec_10;
            5'd10: w_mux_digit = s_sec_1;
            5'd11: w_mux_digit = s_sec_10;
            5'd12: w_mux_digit = s_min_1;
            5'd13: w_mux_digit = s_min_10;
            5'd14: w_mux_digit = s_hour_1;
            5'd15: w_mux_digit = s_hour_10;

            5'd16: w_mux_digit = w_dist_1;
            5'd17: w_mux_digit = w_dist_10;
            5'd18: w_mux_digit = w_dist_100;
            5'd19: w_mux_digit = w_dist_1000;

            5'd20: w_mux_digit = w_hum_1;
            5'd21: w_mux_digit = w_hum_10;

            5'd22:   w_mux_digit = w_temp_1;
            5'd23:   w_mux_digit = w_temp_10;
            default: w_mux_digit = 4'bxxxx;
        endcase
    end

    sender_rom_001 U_SENDER_ROM_001 (
        .ascii_i_temp(cnt_reg[4:0]),
        .ascii_o_temp(w_ascii_o_temp)
    );
    sender_rom_010 U_SENDER_ROM_010 (
        .ascii_i_hum(cnt_reg[4:0]),
        .ascii_o_hum(w_ascii_o_hum)
    );
    sender_rom_011 U_SENDER_ROM_011 (
        .ascii_i_dist(cnt_reg[3:0]),
        .ascii_o_dist(w_ascii_o_dist)
    );
    sender_rom_100 U_SENDER_ROM_100 (
        .ascii_i_time(cnt_reg[4:0]),
        .ascii_o_time(w_ascii_o_time)
    );
    sender_rom_101 U_SENDER_ROM_101 (
        .ascii_i_stw(cnt_reg[4:0]),
        .ascii_o_stw(w_ascii_o_stw)
    );

    num_rom U_NUM_ROM (
        .digit(w_mux_digit),
        .ascii_num(w_num)
    );

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
            tick_send_cnt_reg <= 0;
            cnt_reg <= 0;
            cmd_reg <= 3'b000;
            all_cnt_reg <= 0;
        end else begin
            c_state <= n_state;
            tick_send_cnt_reg <= tick_send_cnt_next;
            cnt_reg <= cnt_next;
            cmd_reg <= cmd_next;
            all_cnt_reg <= all_cnt_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        send_data = 8'h00;
        tick_send_cnt_next = tick_send_cnt_reg;
        cnt_next = cnt_reg;
        fifo_tx_push = 1'b0;
        cmd_next = cmd_reg;
        all_cnt_next = all_cnt_reg;
        mux_sel = 0;
        case (c_state)
            IDLE: begin
		all_cnt_next = 0;
                cmd_next = 0;
                fifo_tx_push = 1'b0;
                tick_send_cnt_next = 0;
                cnt_next = 0;
                if (|sender_con) begin
                    cmd_next = sender_con;
                    n_state  = WAIT;
                end
            end
            WAIT: begin
                if (tick_sender) begin
                    tick_send_cnt_next = tick_send_cnt_reg + 1;
                    if (tick_send_cnt_reg == 30) begin	// 20 => 30 => 40
                        case (cmd_reg)
                            3'b001: begin
                                n_state = SEND_001;
                            end
                            3'b010: begin
                                n_state = SEND_010;
                            end
                            3'b011: begin
                                n_state = SEND_011;
                            end
                            3'b100: begin
                                n_state = SEND_100;
                            end
                            3'b101: begin
                                n_state = SEND_101;
                            end
                            3'b111: begin
                                n_state = SEND_111;
                            end
                        endcase
                    end
                end
            end
            SEND_001: begin
                fifo_tx_push = 1'b1;
                if (w_ascii_o_temp[7]) begin
                    mux_sel   = w_ascii_o_temp[4:0];
                    send_data = w_num;
                end else begin
                    send_data = w_ascii_o_temp;
                end
                if (cnt_reg == 17) begin
                    n_state = IDLE;
                end else begin
                    cnt_next = cnt_reg + 1;
                end
            end
            SEND_010: begin
                fifo_tx_push = 1'b1;
                if (w_ascii_o_hum[7]) begin
                    mux_sel   = w_ascii_o_hum[4:0];
                    send_data = w_num;
                end else begin
                    send_data = w_ascii_o_hum;
                end
                if (cnt_reg == 13) begin
                    n_state = IDLE;
                end else begin
                    cnt_next = cnt_reg + 1;
                end
            end
            SEND_011: begin
                fifo_tx_push = 1'b1;
                if (w_ascii_o_dist[7]) begin
                    mux_sel   = w_ascii_o_dist[4:0];
                    send_data = w_num;
                end else begin
                    send_data = w_ascii_o_dist;
                end
                if (cnt_reg == 15) begin
                    n_state = IDLE;
                end else begin
                    cnt_next = cnt_reg + 1;
                end
            end
            SEND_100: begin
                fifo_tx_push = 1'b1;
                if (w_ascii_o_time[7]) begin
                    mux_sel   = w_ascii_o_time[4:0];
                    send_data = w_num;
                end else begin
                    send_data = w_ascii_o_time;
                end
                if (cnt_reg == 17) begin
                    n_state = IDLE;
                end else begin
                    cnt_next = cnt_reg + 1;
                end
            end
            SEND_101: begin
                fifo_tx_push = 1'b1;
                if (w_ascii_o_stw[7]) begin
                    mux_sel   = w_ascii_o_stw[4:0];
                    send_data = w_num;
                end else begin
                    send_data = w_ascii_o_stw;
                end
                if (cnt_reg == 22) begin
                    n_state = IDLE;
                end else begin
                    cnt_next = cnt_reg + 1;
                end
            end
            SEND_111: begin
                fifo_tx_push = 1'b1;
		all_cnt_next = all_cnt_reg + 1;
                if (all_cnt_reg < 18) begin
                    if (w_ascii_o_temp[7]) begin
                        mux_sel   = w_ascii_o_temp[4:0];
                        send_data = w_num;
                    end else begin
                        send_data = w_ascii_o_temp;
                    end                    
                end else if ((all_cnt_reg >= 18) && (all_cnt_reg < 32)) begin
                    if (w_ascii_o_hum[7]) begin
                        mux_sel   = w_ascii_o_hum[4:0];
                        send_data = w_num;
                    end else begin
                        send_data = w_ascii_o_hum;
                    end
                end else if ((all_cnt_reg >= 32) && (all_cnt_reg < 48)) begin
                    if (w_ascii_o_dist[7]) begin
                        mux_sel   = w_ascii_o_dist[4:0];
                        send_data = w_num;
                    end else begin
                        send_data = w_ascii_o_dist;
                    end
                end else if ((all_cnt_reg >= 48) && (all_cnt_reg < 66)) begin
                    if (w_ascii_o_time[7]) begin
                        mux_sel   = w_ascii_o_time[4:0];
                        send_data = w_num;
                    end else begin
                        send_data = w_ascii_o_time;
                    end                    
                end else if ((all_cnt_reg >= 66) && (all_cnt_reg < 89)) begin
                    if (w_ascii_o_stw[7]) begin
                        mux_sel   = w_ascii_o_stw[4:0];
                        send_data = w_num;
                    end else begin
                        send_data = w_ascii_o_stw;
                    end
                end else if (all_cnt_reg == 89) begin
                    n_state = IDLE;
                end 
		if (all_cnt_reg == 17 || all_cnt_reg == 31 || all_cnt_reg == 47 || all_cnt_reg == 65 || all_cnt_reg == 88) begin
			cnt_next = 0;
		end else begin
			cnt_next = cnt_reg + 1;
		end
            end
        endcase
    end
endmodule

module num_rom (
    input [3:0] digit,
    output reg [7:0] ascii_num
);

    always @(*) begin
        case (digit)
            4'd0 :    ascii_num = 8'h30;
            4'd1 :    ascii_num = 8'h31;
            4'd2 :    ascii_num = 8'h32;
            4'd3 :    ascii_num = 8'h33;
            4'd4 :    ascii_num = 8'h34;
            4'd5 :    ascii_num = 8'h35;
            4'd6 :    ascii_num = 8'h36;
            4'd7 :    ascii_num = 8'h37;
            4'd8 :    ascii_num = 8'h38;
            4'd9 :    ascii_num = 8'h39;
            default : ascii_num = 8'hxx;
        endcase
    end

endmodule


module tick_gen_sneder (
    input clk,
    input rst,
    output reg tick_sender
);

    parameter F_COUNT = 100_000_000 / 1_000;
    reg [$clog2(F_COUNT -1):0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_sender <= 1'b0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                tick_sender <= 1'b1;
            end else begin
                tick_sender <= 1'b0;
            end
        end
    end

endmodule


module sender_rom_001 (
    input [4:0] ascii_i_temp,
    output reg [7:0] ascii_o_temp
);
    always @(*) begin
        case (ascii_i_temp)
            5'd00:   ascii_o_temp = 8'h54;  // T
            5'd01:   ascii_o_temp = 8'h65;  // e
            5'd02:   ascii_o_temp = 8'h6d;  // m
            5'd03:   ascii_o_temp = 8'h70;  // p
            5'd04:   ascii_o_temp = 8'h65;  // e
            5'd05:   ascii_o_temp = 8'h72;  // r
            5'd06:   ascii_o_temp = 8'h61;  // a
            5'd07:   ascii_o_temp = 8'h74;  // t
            5'd08:   ascii_o_temp = 8'h75;  // u 
            5'd09:   ascii_o_temp = 8'h72;  // r 
            5'd10:   ascii_o_temp = 8'h65;  // e 
            5'd11:   ascii_o_temp = 8'h3a;  // : 
            5'd12:   ascii_o_temp = 8'h20;  //   
            5'd13:   ascii_o_temp = 8'b1001_0111;  // num 
            5'd14:   ascii_o_temp = 8'b1001_0110;  // num 
            5'd15:   ascii_o_temp = 8'h27;  // ' 
            5'd16:   ascii_o_temp = 8'h43;  // C 
            5'd17:   ascii_o_temp = 8'h0a;  // enter
            default: ascii_o_temp = 8'hff;
        endcase
    end

endmodule

module sender_rom_010 (
    input [4:0] ascii_i_hum,
    output reg [7:0] ascii_o_hum
);
    always @(*) begin
        case (ascii_i_hum)
            5'd00:   ascii_o_hum = 8'h48;  // H
            5'd01:   ascii_o_hum = 8'h75;  // u
            5'd02:   ascii_o_hum = 8'h6d;  // m
            5'd03:   ascii_o_hum = 8'h69;  // i
            5'd04:   ascii_o_hum = 8'h64;  // d
            5'd05:   ascii_o_hum = 8'h69;  // i
            5'd06:   ascii_o_hum = 8'h74;  // t
            5'd07:   ascii_o_hum = 8'h79;  // y
            5'd08:   ascii_o_hum = 8'h3a;  // :
            5'd09:   ascii_o_hum = 8'h20;  // 
            5'd10:   ascii_o_hum = 8'b1001_0101;  // num
            5'd11:   ascii_o_hum = 8'b1001_0100;  // num
            5'd12:   ascii_o_hum = 8'h25;  // % 
            5'd13:   ascii_o_hum = 8'h0a;  // enter
            default: ascii_o_hum = 8'hff;
        endcase
    end

endmodule

module sender_rom_011 (
    input [3:0] ascii_i_dist,
    output reg [7:0] ascii_o_dist
);
    always @(*) begin
        case (ascii_i_dist)
            4'd00:   ascii_o_dist = 8'h44;  // D 
            4'd01:   ascii_o_dist = 8'h69;  // i 
            4'd02:   ascii_o_dist = 8'h73;  // s 
            4'd03:   ascii_o_dist = 8'h74;  // t 
            4'd04:   ascii_o_dist = 8'h61;  // a 
            4'd05:   ascii_o_dist = 8'h6e;  // n 
            4'd06:   ascii_o_dist = 8'h63;  // c 
            4'd07:   ascii_o_dist = 8'h65;  // e 
            4'd08:   ascii_o_dist = 8'h3a;  // : 
            4'd09:   ascii_o_dist = 8'h20;  //  
            4'd10:   ascii_o_dist = 8'b1001_0010;  // num
            4'd11:   ascii_o_dist = 8'b1001_0001;  // num
            4'd12:   ascii_o_dist = 8'b1001_0000;  // num
            4'd13:   ascii_o_dist = 8'h63;  // c 
            4'd14:   ascii_o_dist = 8'h6d;  // m
            4'd15:   ascii_o_dist = 8'h0a;  // enter
            default: ascii_o_dist = 8'hff;
        endcase
    end

endmodule

module sender_rom_100 (
    input [4:0] ascii_i_time,
    output reg [7:0] ascii_o_time
);
    always @(*) begin
        case (ascii_i_time)
            5'd00:   ascii_o_time = 8'h54;  // T
            5'd01:   ascii_o_time = 8'h69;  // i
            5'd02:   ascii_o_time = 8'h6d;  // m
            5'd03:   ascii_o_time = 8'h65;  // e
            5'd04:   ascii_o_time = 8'h3a;  // :
            5'd05:   ascii_o_time = 8'h20;  // 
            5'd06:   ascii_o_time = 8'b1000_0111;  // num
            5'd07:   ascii_o_time = 8'b1000_0110;  // num
            5'd08:   ascii_o_time = 8'h3a;  // :
            5'd09:   ascii_o_time = 8'b1000_0101;  // num
            5'd10:   ascii_o_time = 8'b1000_0100;  // num
            5'd11:   ascii_o_time = 8'h3a;  // :
            5'd12:   ascii_o_time = 8'b1000_0011;  // num
            5'd13:   ascii_o_time = 8'b1000_0010;  // num
            5'd14:   ascii_o_time = 8'h2e;  // .
            5'd15:   ascii_o_time = 8'b1000_0001;  // num
            5'd16:   ascii_o_time = 8'b1000_0000;  // num
            5'd17:   ascii_o_time = 8'h0a;  // enter            
            default: ascii_o_time = 8'hff;
        endcase
    end

endmodule

module sender_rom_101 (
    input [4:0] ascii_i_stw,
    output reg [7:0] ascii_o_stw
);
    always @(*) begin
        case (ascii_i_stw)
            5'd00:   ascii_o_stw = 8'h53;  // S 
            5'd01:   ascii_o_stw = 8'h74;  // t 
            5'd02:   ascii_o_stw = 8'h6f;  // o 
            5'd03:   ascii_o_stw = 8'h70;  // p 
            5'd04:   ascii_o_stw = 8'h77;  // w 
            5'd05:   ascii_o_stw = 8'h61;  // a 
            5'd06:   ascii_o_stw = 8'h74;  // t 
            5'd07:   ascii_o_stw = 8'h63;  // c 
            5'd08:   ascii_o_stw = 8'h68;  // h 
            5'd09:   ascii_o_stw = 8'h3a;  // :
            5'd10:   ascii_o_stw = 8'h20;  // 
            5'd11:   ascii_o_stw = 8'b1000_1111;  // num
            5'd12:   ascii_o_stw = 8'b1000_1110;  // num
            5'd13:   ascii_o_stw = 8'h3a;  // :
            5'd14:   ascii_o_stw = 8'b1000_1101;  // num
            5'd15:   ascii_o_stw = 8'b1000_1100;  // num
            5'd16:   ascii_o_stw = 8'h3a;  // :
            5'd17:   ascii_o_stw = 8'b1000_1011;  // num
            5'd18:   ascii_o_stw = 8'b1000_1010;  // num
            5'd19:   ascii_o_stw = 8'h2e;  // .
            5'd20:   ascii_o_stw = 8'b1000_1001;  // num
            5'd21:   ascii_o_stw = 8'b1000_1000;  // num
            5'd22:   ascii_o_stw = 8'h0a;  // enter
            default: ascii_o_stw = 8'hff;
        endcase
    end

endmodule

module digit_split_10 #(
    parameter BIT_WIDTH = 9
) (
    input [BIT_WIDTH-1:0] digit_in,
    output [3:0] digit_1,
    output [3:0] digit_10
);

    assign digit_1  = digit_in % 10;
    assign digit_10 = digit_in / 10 % 10;

endmodule

module digit_split_1000 #(
    parameter BIT_WIDTH = 9
) (
    input [BIT_WIDTH-1:0] digit_in,
    output [3:0] digit_1,
    output [3:0] digit_10,
    output [3:0] digit_100,
    output [3:0] digit_1000
);

    assign digit_1 = digit_in % 10;
    assign digit_10 = digit_in / 10 % 10;
    assign digit_100 = digit_in / 100 % 10;
    assign digit_1000 = digit_in / 1000 % 10;

endmodule
