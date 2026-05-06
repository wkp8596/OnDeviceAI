`timescale 1ns / 1ps

module tb_ascii_sender();

	reg clk, rst;
	reg [3:0] con;
	wire [7:0] data;
	wire push;

	top_ascii_sender dut (
		.clk(clk),
		.rst(rst),
		
		.s_msec(7'd0),
		.s_sec(6'd1),
		.s_min(6'd2),
		.s_hour(5'd3),
		
		.w_msec(7'd4),
		.w_sec(6'd5),
		.w_min(6'd6),
		.w_hour(5'd7),
		
		.hum({8'd8, 8'd0}),
		.temp({8'd9, 8'd0}),

		.distance(9'd123),

		.sender_con(con),
		.ascii_send_data(data),
		.fifo_tx_push(push)
	);

 	always #5 clk = ~clk;

	initial begin
		clk = 0;
		rst = 1;

		con = 3'b000;

		repeat(3) @(negedge clk);

		rst = 0;


		@(negedge clk);
		con = 3'b001;
		@(negedge clk);
		con = 3'b000;
		@(negedge push);

		repeat(3) @(negedge clk);
		con = 3'b010;
		@(negedge clk);
		con = 3'b000;
		@(negedge push);

		repeat(3) @(negedge clk);
		con = 3'b011;
		@(negedge clk);
		con = 3'b000;
		@(negedge push);

		repeat(3) @(negedge clk);
		con = 3'b100;
		@(negedge clk);
		con = 3'b000;
		@(negedge push);
		
		repeat(3) @(negedge clk);
		con = 3'b101;
		@(negedge clk);
		con = 3'b000;
		@(negedge push);

		repeat(3) @(negedge clk);
		con = 3'b111;
		@(negedge clk);
		con = 3'b000;
		@(negedge push);

		#100;

		$stop;
	end

endmodule
