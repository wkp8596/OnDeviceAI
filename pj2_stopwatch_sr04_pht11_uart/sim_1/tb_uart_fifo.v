`timescale 1ns / 1ps

module tb_uart_fifo();
      
	parameter BAUD_DELAY = 2000;
	parameter BAUD_PERIOD = 100_000_000 * 10 / 9600;

	reg clk, rst;
	reg rx;
	reg rxpop, txpush;
	reg [7:0] txdata;
	wire tx, rxempty, txfull;
	wire [7:0] rxdata;
	reg [7:0] pcdata, compdata;
	reg [7:0] outdata;
	reg [7:0] cmdata [0:225];

    uart_fifo dut(
	.clk(clk),
	.rst(rst),
	.rx(rx),
	.fifo_rx_pop(rxpop),
	.fifo_tx_push(txpush),
	.tx_data(txdata),
	.tx(tx),
	.rx_data(rxdata),
	.fifo_rx_empty(rxempty),
	.fifo_tx_full(txfull)
    );
    
    always #5 clk = ~clk;

    integer i, j, k;

    // pc uart(txrx) module task

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

    task READ_UART();
	    begin
		    wait (!tx);
		    #(3*BAUD_PERIOD/2);
		    for (i=0;i<8;i=i+1) begin
			    outdata[i] = tx;
			    #(BAUD_PERIOD);
		    end
	    end
    endtask

    initial begin
	clk = 0;
	rst = 1;
	rx = 1;
	rxpop = 0;
	txpush = 0;
	txdata = 0;

	repeat (3) @(negedge clk);

	rst = 0;

	// random test
	//
	
	for (j=0;j<25;j=j+1) begin
		pcdata = $urandom%256;
		SENDER_UART(pcdata);
		@(negedge rxempty);
		if (!rxempty) begin
			@(negedge clk);
			rxpop = 1;
			if (pcdata == rxdata) begin
				$display("input: %d, rx: %d, valid", pcdata, rxdata);
			end else begin
				$display("input: %d, rx: %d, wrong", pcdata, rxdata);
			end
			@(negedge clk);
			compdata = pcdata;
			rxpop = 0;
		end
	end

	for (j = 0; j < 20; j = j + 1) begin
		txpush = 1;
		txdata = $urandom%256;
		if (txpush) begin
			cmdata[j] = txdata;
		end
		@(negedge clk);

	end
	txpush = 0;

	k=0;
	
	for (j=0;j<20;j=j+1) begin
		READ_UART();

		if (outdata == cmdata[j]) begin
			$display("input: %d, tx: %d, valid", cmdata[k], outdata);
			k=k+1;
		end else begin
			$display("input: %d, tx: %d, wrong", cmdata[k], outdata);
			k =k+1;
		end
		@(negedge clk);
	end



	$stop;

    end


endmodule
