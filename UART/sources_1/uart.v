`timescale 1ns / 1ps

module uart_long (
    input        clk,
    input        rst,
    input        BtnR,
    input  [7:0] tx_data,
    output       tx
);

    wire w_start, w_b_tick;

    button_debounce U_BD_TX_START (
        .clk  (clk),
        .rst  (rst),
        .i_btn(BtnR),
        .o_btn(w_start)
    );

    uart_tx_long U_UART_TX (
        .clk     (clk),
        .rst     (rst),
        .tx_start(w_start),
        .tx_data (tx_data),   // 8'h30: ASKII '0'
        .b_tick  (w_b_tick),
        .tx      (tx)
    );

    baud_tick_gen U_B_TICK_GEN (
        .clk     (clk),
        .rst     (rst),
        .o_b_tick(w_b_tick)
    );

endmodule

module uart_tx_long (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,
    input        b_tick,
    output       tx
);

    parameter IDLE = 4'b0000;
    parameter WAIT = 4'b0001;
    parameter START = 4'b0010;
    parameter BIT0 = 4'b0011;
    parameter BIT1 = 4'b0100;
    parameter BIT2 = 4'b0101;
    parameter BIT3 = 4'b0110;
    parameter BIT4 = 4'b0111;
    parameter BIT5 = 4'b1000;
    parameter BIT6 = 4'b1001;
    parameter BIT7 = 4'b1010;
    parameter STOP = 4'b1011;

    reg [3:0] cstate, nstate;
    reg tx_reg, tx_next;

    reg [7:0] tx_data_reg, tx_data_next;

    assign tx = tx_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cstate <= IDLE;
            tx_reg <= 1'b1;
            tx_data_reg <= 8'b0;
        end else begin
            cstate <= nstate;
            tx_reg <= tx_next;
            tx_data_reg <= tx_data_next;
        end
    end

    always @(*) begin
        nstate = cstate;
        case (cstate)
            IDLE:    if (tx_start) nstate = WAIT;
            WAIT:    if (b_tick)   nstate =  START;
            START:   if (b_tick)   nstate =  BIT0 ;
            BIT0:    if (b_tick)   nstate =  BIT1 ;
            BIT1:    if (b_tick)   nstate =  BIT2 ;
            BIT2:    if (b_tick)   nstate =  BIT3 ;
            BIT3:    if (b_tick)   nstate =  BIT4 ;
            BIT4:    if (b_tick)   nstate =  BIT5 ;
            BIT5:    if (b_tick)   nstate =  BIT6 ;
            BIT6:    if (b_tick)   nstate =  BIT7 ;
            BIT7:    if (b_tick)   nstate =  STOP ;
            STOP:    if (b_tick)   nstate =  IDLE ;
            default: nstate = cstate;
        endcase
    end

    always @(*) begin
        case (cstate)
            IDLE:    tx_next = 1'b1;
            WAIT:    tx_next = tx_reg;
            START:   tx_next = 1'b0;
            BIT0:    tx_next = tx_data_reg[0];
            BIT1:    tx_next = tx_data_reg[1];
            BIT2:    tx_next = tx_data_reg[2];
            BIT3:    tx_next = tx_data_reg[3];
            BIT4:    tx_next = tx_data_reg[4];
            BIT5:    tx_next = tx_data_reg[5];
            BIT6:    tx_next = tx_data_reg[6];
            BIT7:    tx_next = tx_data_reg[7];
            STOP:    tx_next = 1'b1;
            default: tx_next = tx_reg;
        endcase
    end

    always @(*) begin
        case (cstate)
            IDLE:    tx_data_next = tx_data;
            WAIT:    tx_data_next = tx_data_reg;
            START:   tx_data_next = tx_data_reg;
            BIT0:    tx_data_next = tx_data_reg;
            BIT1:    tx_data_next = tx_data_reg;
            BIT2:    tx_data_next = tx_data_reg;
            BIT3:    tx_data_next = tx_data_reg;
            BIT4:    tx_data_next = tx_data_reg;
            BIT5:    tx_data_next = tx_data_reg;
            BIT6:    tx_data_next = tx_data_reg;
            BIT7:    tx_data_next = tx_data_reg;
            STOP:    tx_data_next = tx_data;
            default: tx_data_next = tx_data;
        endcase
    end

endmodule

module baud_tick_gen (
    input      clk,
    input      rst,
    output reg o_b_tick
);

    // baud tick 9600Hz tick gen => 16x speed
    parameter F_COUNT = 100_000_000 / (9_600 * 16);
    parameter WIDTH = $clog2(F_COUNT);

    reg [WIDTH - 1:0] cnt_reg;


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_reg  <= 0;
            o_b_tick <= 1'b0;
        end else begin
            cnt_reg <= cnt_reg + 1;
            if (cnt_reg == (F_COUNT - 1)) begin
                cnt_reg  <= 0;
                o_b_tick <= 1'b1;
            end else begin
                o_b_tick <= 1'b0;
            end
        end
    end

endmodule

