`timescale 1ns / 1ps

module uart (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,
    input        rx,
    output [7:0] rx_data,
    output       rx_done,
    output       tx_busy,
    output       tx
);

    wire w_b_tick;

    uart_tx U_UART_TX (
        .clk     (clk),
        .rst     (rst),
        .tx_start(tx_start),
        .tx_data (tx_data),   // 8'h30: ASKII '0'
        .b_tick  (w_b_tick),
        .tx_busy (tx_busy),
        .tx      (tx)
    );

    uart_rx U_UART_RX (
        .clk    (clk),
        .rst    (rst),
        .rx     (rx),
        .b_tick (w_b_tick),
        .rx_done(rx_done),
        .rx_data(rx_data)
    );

    baud_tick_gen U_B_TICK_GEN (
        .clk     (clk),
        .rst     (rst),
        .o_b_tick(w_b_tick)
    );

endmodule

module uart_tx (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,
    input        b_tick,
    output       tx_busy,
    output       tx
);

    parameter IDLE = 2'b00;
    parameter START = 2'b01;
    parameter DATA = 2'b10;
    parameter STOP = 2'b11;

    reg [1:0] cstate, nstate;

    reg tx_reg, tx_next, tx_busy_reg, tx_busy_next;

    reg [7:0] tx_data_reg, tx_data_next;

    reg [2:0] bit_cnt_reg, bit_cnt_next;

    reg [3:0] b_tick_cnt_reg, b_tick_cnt_next;

    assign tx = tx_reg;
    assign tx_busy = tx_busy_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cstate         <= IDLE;
            tx_reg         <= 1'b1;
            tx_data_reg    <= 8'b00000000;
            bit_cnt_reg    <= 3'b000;
            tx_busy_reg    <= 1'b0;
            b_tick_cnt_reg <= 4'b0000;
        end else begin
            cstate         <= nstate;
            tx_reg         <= tx_next;
            tx_data_reg    <= tx_data_next;
            bit_cnt_reg    <= bit_cnt_next;
            tx_busy_reg    <= tx_busy_next;
            b_tick_cnt_reg <= b_tick_cnt_next;
        end
    end

    always @(*) begin
        nstate          = cstate;
        tx_data_next    = tx_data_reg;
        tx_busy_next    = tx_busy_reg;
        b_tick_cnt_next = b_tick_cnt_reg;
        tx_next         = tx_reg;
        bit_cnt_next    = bit_cnt_reg;
        case (cstate)
            IDLE: begin
                tx_next      = 1'b1;
                tx_busy_next = 1'b0;
                if (tx_start) begin
                    tx_busy_next = 1'b1;
                    tx_data_next = tx_data;
                    b_tick_cnt_next = 0;
                    nstate = START;
                end
            end
            START: begin
                tx_next = 1'b0;
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 0;
                        bit_cnt_next    = 0;
                        nstate          = DATA;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = tx_data_reg[0];
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 0;
                        if (bit_cnt_reg == 7) begin
                            nstate       = STOP;
                            bit_cnt_next = 0;
                        end else begin
                            tx_data_next = {1'b0, tx_data_reg[7:1]};
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1;
                if (b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        tx_busy_next = 1'b0;
                        nstate       = IDLE;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule

module uart_rx (
    input        clk,
    input        rst,
    input        rx,
    input        b_tick,
    output       rx_done,
    output [7:0] rx_data
);

    parameter IDLE = 2'b00;
    parameter START = 2'b01;
    parameter DATA = 2'b10;
    parameter STOP = 2'b11;

    reg [1:0] cstate, nstate;
    reg [4:0] b_tick_cnt_next, b_tick_cnt_reg;
    reg [2:0] data_cnt_next, data_cnt_reg;
    reg [7:0] data_reg, data_next;
    reg rx_done_reg, rx_done_next;

    assign rx_done = rx_done_reg;
    assign rx_data = data_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cstate         <= IDLE;
            b_tick_cnt_reg <= 5'b00000;
            data_cnt_reg   <= 3'b000;
            data_reg       <= 8'h00;
            rx_done_reg    <= 1'b0;
            //rx_data_reg    <= 8'h00;
        end else begin
            cstate         <= nstate;
            b_tick_cnt_reg <= b_tick_cnt_next;
            data_cnt_reg   <= data_cnt_next;
            data_reg       <= data_next;
            rx_done_reg    <= rx_done_next;
            //rx_data_reg    <= rx_data_next;
        end
    end

    always @(*) begin
        nstate          = cstate;
        b_tick_cnt_next = b_tick_cnt_reg;
        data_cnt_next   = data_cnt_reg;
        data_next       = data_reg;
        rx_done_next    = rx_done_reg;
        case (cstate)
            IDLE: begin
                rx_done_next = 1'b0;
                if (b_tick && !rx) begin
                    b_tick_cnt_next = 0;
                    nstate          = START;
                end
            end
            START: begin
                rx_done_next = 1'b0;
                if (b_tick) begin
                    if (b_tick_cnt_reg == 5'b00111) begin
                        if (!rx) begin
                            b_tick_cnt_next = 0;
                            data_cnt_next   = 0;
                            nstate          = DATA;
                        end else begin
                            nstate = IDLE;
                            b_tick_cnt_next = 0;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 5'b01111) begin
                        data_next = {rx, data_reg[7:1]};
                        b_tick_cnt_next = 0;
                        if (data_cnt_reg == 3'b111) begin
                            b_tick_cnt_next = 0;
                            nstate          = STOP;
                        end else begin
                            data_cnt_next = data_cnt_reg + 1;
                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                if (b_tick) begin
                    if (b_tick_cnt_reg == 22) begin
                        nstate          = IDLE;
                        b_tick_cnt_next = 0;
                        rx_done_next    = 1'b1;
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end




endmodule
