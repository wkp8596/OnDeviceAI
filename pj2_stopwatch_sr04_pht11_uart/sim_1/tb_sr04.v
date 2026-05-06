`timescale 1ns / 1ps

module tb_sr04();

	parameter US = 1_000;
	parameter CM = US * 58;

	reg clk, rst, btn_R;
	reg echo;
	wire trig;
	wire [3:0] fnd_com;
	wire [7:0] fnd_data;

	reg [255:0] check;

	wire [8:0] dist;

	reg [8:0] dist_random, compdata;

	TOP_sr04_controller dut(
		.clk(clk),
		.rst(rst),
		.btn_R(btn_R),
		.echo(echo),
		.trig(trig),
		.w_dist(dist),
		.fnd_com(fnd_com),
		.fnd_data(fnd_data)
	    );

	integer i;
	always #5 clk = ~clk;

	task CHECK_DISTANCE(input [8:0] dist);
		begin
			repeat (3) @(negedge clk);
			btn_R = 1;
			
			repeat(8000)@(negedge clk);
			btn_R = 0;

			@(negedge trig);

			#10;

			echo = 1;

			#((dist) * CM);
			
			echo = 0;

			#(CM);

		end
	endtask

	initial begin
		clk = 0;
		rst = 1;
		btn_R = 0;
		echo = 0;
		check = 0;
		
		repeat (3) @(negedge clk);
		rst = 0;

		for (i=0;i<256;i=i+1) begin
			dist_random = 2 + $urandom%398;
			compdata = dist_random;
			CHECK_DISTANCE(dist_random);
			if (compdata == dist) begin
				$display("input: %d, estimate: %d, valid", compdata, dist);
				check[i] = 1'b1;
			end else begin
				$display("input: %d, estimate: %d, wrong", compdata, dist);
				check[i] = 1'b0;
			end
		end
		if (&check) begin
			$display("all test pass");
		end else begin
			$display("fail");
		end

		$stop;

	end

endmodule
