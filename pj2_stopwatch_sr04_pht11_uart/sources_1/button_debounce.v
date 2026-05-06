`timescale 1ns / 1ps

module button_debounce (
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);

    // clock divider
    // 100MHz => 100KHz 1/1000

    parameter F_COUNT = 100_000_000 / 100_000;
    reg [$clog2(F_COUNT) - 1:0] r_counter;
    reg clk_100kHz;
    
    reg [7:0] sync_reg, sync_next;
    reg  edge_reg;

    wire debounce;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            clk_100kHz <= 1'b0;
        end else begin
            r_counter <= r_counter + 1;
            if (r_counter == F_COUNT - 1) begin
                r_counter  <= 0;
                clk_100kHz <= 1'b1;
            end else begin
                clk_100kHz <= 1'b0;
            end
        end
    end

    // syncronizer


    always @(posedge clk_100kHz or posedge rst) begin
        if (rst) begin
            sync_reg <= 8'b0000000;
        end else begin
            sync_reg <= sync_next;
        end
    end

    always @(*) begin
        sync_next = {i_btn, sync_reg[7:1]};  // >>
    end

    // 8bit input to 1 output AND gate

    assign debounce = &sync_reg;

    // rising edge detection

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            edge_reg <= 1'b0;
        end else begin
            edge_reg <= debounce;
        end
    end

    assign o_btn = debounce & ~edge_reg;



endmodule
