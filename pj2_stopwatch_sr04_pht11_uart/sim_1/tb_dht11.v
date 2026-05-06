`timescale 1ns / 1ps
module tb_dht11 ();
    // 시뮬레이션 파라미터
    parameter [7:0] HUMI_INT = 8'd71;  // 습도 정수부
    parameter [7:0] TEMP_INT = 8'd92;  // 온도 정수부
    parameter [39:0] DATA_STREAM = {
        HUMI_INT, 8'h00, TEMP_INT, 8'h00, HUMI_INT + TEMP_INT
    };

    parameter REPEAT = 20;
    reg clk;
    reg reset;
    reg btn_start;

    // 
    reg dht_sensor_data;
    reg io_oe;

    reg [REPEAT-1:0] check;

    wire [5:0] led;
    wire dht_io;

    reg [7:0] hum_i, hum_f, temp_i, temp_f;

    wire [7:0] hum, temp;

    reg [39:0] send;

    integer j;
    integer i = 0;
    //  tb io mode 변환.
    assign dht_io = (io_oe) ? dht_sensor_data : 1'bz;

	TOP_dht11 dut(
		.clk(clk),
		.rst(reset),
		.btn_R(btn_start),
		.fnd_com(),
		.fnd_data(),
		.valid(led),
		.w_hum(hum),
		.w_temp(temp),
		.dht11(dht_io)
	    );

	    task CHECK_TH(input [39:0] send_data);
		    begin
        btn_start = 1;
        #100000;
        btn_start = 0;
        #100;
        wait (!dht_io);
        // 18msec 대기
        wait (dht_io);
        #30000;
        // 입력 모드로 변환
        io_oe = 1;
        dht_sensor_data = 1'b0;
        #80000;
        dht_sensor_data = 1'b1;
        #80000;
        for (i = 39; i >= 0; i = i - 1) begin
            dht_sensor_data = 0;
            #50000;
            dht_sensor_data = 1'b1;
            #(send_data[i] ? 70000 : 26000);

        end
        dht_sensor_data = 0;
        #50000;
        io_oe = 0;
        #50000;
 



		    end
	    endtask

    always #5 clk = ~clk;


    initial begin
        clk = 0;
        reset = 1;
        io_oe = 0;
        btn_start = 0;

        #100;
        reset = 0;
        #100;


	for (j=0;j<REPEAT;j=j+1) begin
	       	hum_i = $urandom%100; hum_f = 0;
		temp_i = $urandom%100;
		temp_f = 0;

		send = {hum_i, hum_f, temp_i, temp_f, hum_i+hum_f+temp_i+temp_f};

		CHECK_TH(send);

		if ((hum_i == hum) && (temp_i == temp)) begin
			$display("hum: %d, %d, temp: %d, %d, valid", hum_i, hum, temp_i, temp);
			check[j] = 1'b1;

		end else begin

			$display("hum: %d, %d, temp: %d, %d, wrong", hum_i, hum, temp_i, temp);

			check[j] = 1'b0;
		end



	end

	if (&check) begin
		$display("all pass");
	end else begin

		$display("fail");
	end

       $stop;
    end




endmodule
