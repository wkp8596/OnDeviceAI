`timescale 1ns / 1ps

module tb_cu ();
    parameter US = 1_000;
    parameter CM = US * 58;
    parameter BAUD_DELAY = 2_000;
    parameter BAUD_PERIOD = 100_000_000 * 10 / 9600 - BAUD_DELAY;
    parameter SECOND = 1_000_000_000; 
 
    parameter [7:0] HUMI_INT = 8'd71;  // ?äµ?èÑ ?†ï?àòÎ∂?
    parameter [7:0] TEMP_INT = 8'd92;  // ?ò®?èÑ ?†ï?àòÎ∂?
    parameter [39:0] DATA_STREAM = {
        HUMI_INT, 8'h00, TEMP_INT, 8'h00, HUMI_INT + TEMP_INT
    };

    parameter REPEAT = 20;

    // 
    reg dht_sensor_data;
    reg io_oe;

    wire dht_io;

    wire [7:0] hum, temp;

    integer j;
    integer i = 0;
    //  tb io mode Î≥??ôò.
    assign dht_io = (io_oe) ? dht_sensor_data : 1'bz;

    reg clk, rst, rx;
    reg [7:0] compare_data;

    reg [3:0] btn;
    reg [4:0] sw;

    reg echo;

    wire trig, led, dht11;

    wire tx;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    TOP dut(
        .clk(clk),
        .rst(rst),
        .btn(btn),
        .switch(sw),
        .rx(rx),
	.echo(echo),
	.trig(trig),
        .tx(tx),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com),
	.led(led),
	.dht11(dht_io)
    );
    task SENDER_UART(input [7:0] send_data);
        begin
            rx = 0;  // start signal
            #(BAUD_PERIOD);  //  1/9600 second

            // data bit
            for (i = 0; i < 8; i = i + 1) begin
                // rx, send_data[0] ~ [7]
                rx = send_data[i];
                #(BAUD_PERIOD);
            end
            // stop bit
            rx = 1;
            #(BAUD_PERIOD);
        end
    endtask


    task CHECK_TH(input [39:0] send_data);
		    begin
        #100;
        wait (!dht_io);
        // 18msec ??Í∏?
        wait (dht_io);
        #30000;
        // ?ûÖ?†• Î™®ÎìúÎ°? Î≥??ôò
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
	task CHECK_DISTANCE(input [8:0] dist);
		begin

			@(negedge trig);

			#10;

			echo = 1;

			#((dist) * CM);
			
			echo = 0;

			#(CM);

		end
	endtask



    always #5 clk = !clk;

    initial begin
        clk = 0;
        rst = 1;
        rx  = 1;
	btn = 0;
	sw = 0;
	echo = 0;
	io_oe = 0;
        repeat (3) @(negedge clk);
        rst = 0;

	//temp

	compare_data = 8'h44;
        SENDER_UART(compare_data);
 	
	compare_data = 8'h49; 
	SENDER_UART(compare_data);
        
	compare_data = 8'h53;
	SENDER_UART(compare_data);

	compare_data = 8'h54;
	SENDER_UART(compare_data);

	CHECK_DISTANCE(139);


        repeat (10) #(BAUD_PERIOD);

        #1000;

	

	$stop;
    end
endmodule
