`timescale 1ns / 1ps

module tb_decoder();

	reg clk, rst;
	reg empty;
	reg [7:0] rxdata, send_data;

	wire pop, vld;
	wire [4:0] alpha;

	integer i;

	ascii_decoder dut(
		.clk(clk),
		.rst(rst),
		.fifo_rx_empty(empty),
		.rx_data(rxdata),
		.fifo_rx_pop(pop),
		.alphabet(alpha),
		.out_vld(vld)
	);

	always #5 clk = ~clk;

	task SEND_DATA(input [7:0] send);
	       begin
		       rxdata = send;
		       empty = 0;

		       @(negedge clk);
		       empty = 1;

		       repeat(100) @(negedge clk);



		end
	endtask

	initial begin
		clk = 0;
		rst = 1;
		empty = 1;
		rxdata = 0;

		repeat(3) @(negedge clk);
		rst = 0;

		for (i=0;i<26;i=i+1) begin
			send_data = 65+i;
			SEND_DATA(send_data);
		end
		for (i=0;i<26;i=i+1) begin
			send_data = 97+i;
			SEND_DATA(send_data);
		end
		send_data = 127;
		SEND_DATA(send_data);
		#100;
		$stop;
	end

		


endmodule
