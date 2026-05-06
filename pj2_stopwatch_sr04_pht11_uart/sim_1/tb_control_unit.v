`timescale 1ns / 1ps

module tb_control_unit();

	reg clk, rst;

	reg [4:0] alpha;
	reg [3:0] btn;
	reg [5:0] sw;
	reg vld;

	wire [7:0] sw_w_con;
	wire sr04, dht11;
	wire [2:0] sender_con;

	top_control_unit dut (
		.clk(clk),
		.rst(rst),
		.alphabet(alpha),
		.btn(btn),		// r u d l
		.switch(sw),
		.ascii_vld(vld),
		.sw_w_con(sw_w_con),	// 4 bit sw, 4 bit btn
		.sr04_start(sr04),
		.dht11_start(dht11),
		.sender_con(sender_con)
	);

	task SEND (input [4:0] a);
		begin
			@(negedge clk);
			vld = 1;
			alpha = a;
			@(negedge clk);
			vld = 0;
			alpha = 0;
			repeat (100) @(negedge clk);
		end
	endtask

	always #5 clk = ~clk;

	initial begin
		clk = 0;
		rst = 1;
		alpha = 0;
		btn = 0;
		sw = 0;
		vld = 0;

		repeat (3) @(negedge clk);
		rst = 0;
		
	    @(negedge clk);
		btn = 4'b0001;
		@(negedge clk);
		btn = 0;
		repeat (5) @(negedge clk);

		@(negedge clk);
		btn = 4'b0010;
		@(negedge clk);
		btn = 0;
		repeat (5) @(negedge clk);

		@(negedge clk);
		btn = 4'b0100;
		@(negedge clk);
		btn = 0;

		repeat (5) @(negedge clk);
		@(negedge clk);
		btn = 4'b1000;
		@(negedge clk);
		btn = 0;
		repeat (5) @(negedge clk);
		
		
		#10;
		SEND(5'b10001);
		SEND(5'b10100);
		SEND(5'b01101);	// run	
		#10;


		SEND(5'b01111);
		SEND(5'b00000);
		SEND(5'B10100);
		SEND(5'B10010);
		SEND(5'B00100); // PAUSE;
		#10;

		SEND(5'b01100);
		SEND(5'b01110);
		SEND(5'B00011);
		SEND(5'B00100); // mode
		#10;
		
		SEND(5'b00010);
		SEND(5'b01011);
		SEND(5'B00100);
		SEND(5'B00000);
		SEND(5'B10001); // clear
		#10;

		SEND(5'B10100);
		SEND(5'B01111); // up
		#10;

		SEND(5'b00011);
		SEND(5'b01110);
		SEND(5'B10110);
		SEND(5'B01101);	// down
		#10;

		SEND(5'b01011);
		SEND(5'b00100);
		SEND(5'B00101);
		SEND(5'B10011);	// left
		#10;

		SEND(5'b10001);
		SEND(5'b01000);
		SEND(5'B00110);
		SEND(5'B00111);
		SEND(5'B10011); // right
		#10;

		SEND(5'b10011);
		SEND(5'B00100);
		SEND(5'B01100);
		SEND(5'B01111); // temp
		#10;
		
		SEND(5'B00111);
		SEND(5'B10100);
		SEND(5'B01100); // hum
		#10;

		SEND(5'b00011);
		SEND(5'B01000);
		SEND(5'B10010);
		SEND(5'B10011); // dist
		#10;

		SEND(5'b10110);
		SEND(5'b00000);
		SEND(5'B10011);
		SEND(5'B00010);
		SEND(5'B00111); // watch
		#10;

		SEND(5'b10010);
		SEND(5'b10011);
		SEND(5'b01110);
		SEND(5'b01111);
		SEND(5'b10110);
		SEND(5'b00000);
		SEND(5'B10011);
		SEND(5'B00010);
		SEND(5'B00111); // stopwatch
		#10;

		SEND(5'B00000);
		SEND(5'B01011);
		SEND(5'B01011); // stopwatch
		#10;

		$stop;

		SEND(5'b10010);

		SEND(5'b10010);

		SEND(5'b10010);

		SEND(5'b10010);

		SEND(5'b10010);

		SEND(5'b10010);

		SEND(5'b10010);

		SEND(5'b10010);

		SEND(5'b10010);

		SEND(5'b10010);
		#10;

		SEND(5'b10010);
		#100000;

		#100;
		$stop;
	end


endmodule
