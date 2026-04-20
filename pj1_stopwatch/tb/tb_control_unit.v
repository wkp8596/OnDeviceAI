`timescale 1ns / 1ps

module tb_control_unit ();

    reg clk, rst;
    reg [3:0] btn;
    reg [2:0] sw;
    reg flash;

    wire run_stop, clear, mode;
    wire [1:0] watch_up_dn;
    wire [1:0] sel_watch_hms;
    wire sel_w_sw, sel_hour_sec;
    wire [6:0] o_led;

    control_unit dut (
        .clk          (clk),
        .rst          (rst),
        .btnD         (btn[0]),         // mode
        .btnL         (btn[1]),         // clear
        .btnR         (btn[2]),         // run/stop
        .btnU         (btn[3]),
        .sw           (sw),
        .flash        (flash),
        .run_stop     (run_stop),
        .clear        (clear),
        .mode         (mode),
        .watch_up_dn  (watch_up_dn),    //  UD
        .sel_watch_hms(sel_watch_hms),  //  SH
        .sel_w_sw     (sel_w_sw),       //  sw[1]
        .sel_hour_sec (sel_hour_sec),   //  sw[0] or SH[1]
        .o_led        (o_led)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        btn = 4'b0000;
        sw = 3'b000;
        flash = 1;
        repeat (3) @(negedge clk);
        rst = 0;
        repeat (3) @(negedge clk);

        // CLOCK state btn input check

        btn = 4'b0001;
        repeat (2) @(negedge clk);
        btn = 4'b0010;
        repeat (2) @(negedge clk);
        btn = 4'b0100;
        repeat (2) @(negedge clk);
        btn = 4'b1000;
        repeat (2) @(negedge clk);

        // CLOCK state sw input check

        sw = 3'b001;
        repeat (2) @(negedge clk);
        sw = 3'b000;

        repeat (2) @(negedge clk);  // STOP state
        sw = 3'b010;
        repeat (2) @(negedge clk);
        sw = 3'b000;


        repeat (2) @(negedge clk);  // MIN_AJ state
        sw = 3'b100;
        repeat (2) @(negedge clk);
        sw = 3'b000;

        repeat (3) @(negedge clk);  // STOP state
        sw[1] = 1;

        repeat (3) @(negedge clk);

        // STOP state btn input check

        btn = 4'b0001;  // MODE state
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        btn = 4'b0010;  // CLEAR state
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        btn = 4'b0100;  //  RUN state
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        btn = 4'b0100;  //  RUN state
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        btn = 4'b1000;  //  NONE
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);
        btn = 4'b0000;
        repeat (4) @(negedge clk);

        btn = 4'b0001;  // MODE state
        @(negedge clk);
        btn = 4'b0000;
        repeat (4) @(negedge clk);

        btn = 4'b0100;  //  RUN state
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        // RUN state input check

        // RUN state btn input check

        btn = 4'b0001;
        repeat (2) @(negedge clk);
        btn = 4'b0010;
        repeat (2) @(negedge clk);
        //btn = 4'b0100;
        repeat (2) @(negedge clk);
        btn = 4'b1000;
        repeat (2) @(negedge clk);
        btn = 4'b000;

        // RUN state sw input check

        sw  = 3'b011;
        repeat (2) @(negedge clk);
        sw = 3'b010;

        repeat (2) @(negedge clk);
        sw = 3'b010;
        repeat (2) @(negedge clk);
        //sw = 3'b000;


        repeat (2) @(negedge clk);
        sw = 3'b110;
        repeat (2) @(negedge clk);
        sw = 3'b010;

        repeat (2) @(negedge clk);  // CLOCK state
        sw = 3'b000;
        repeat (2) @(negedge clk);
        sw = 3'b010;

        // CLOCK state

        repeat (2) @(negedge clk);
        sw = 3'b100;
        repeat (2) @(negedge clk);


        // SEC_AJ state

        // state move check

        btn = 4'b0010;  // LEFT MIN
        @(negedge clk);
        btn = 4'b0000;
        repeat (2) @(negedge clk);

        sw = 3'b000;  // CLOCK
        repeat (2) @(negedge clk);

        sw = 3'b100;  // AJ
        repeat (2) @(negedge clk);

        btn = 4'b0010;  // LEFT HOUR
        @(negedge clk);
        btn = 4'b0000;
        repeat (2) @(negedge clk);

        btn = 4'b0010;  // LEFT SEC
        @(negedge clk);
        btn = 4'b0000;
        repeat (2) @(negedge clk);

        sw = 3'b000;  // CLOCK
        repeat (2) @(negedge clk);

        sw = 3'b100;  // AJ
        repeat (2) @(negedge clk);

        // move right

        btn = 4'b0100;  // RIGHT MIN
        @(negedge clk);
        btn = 4'b0000;
        repeat (2) @(negedge clk);

        btn = 4'b0100;  // RIGHT MIN
        @(negedge clk);
        btn = 4'b0000;
        repeat (2) @(negedge clk);

        btn = 4'b0100;  // RIGHT MIN
        @(negedge clk);
        btn = 4'b0000;
        repeat (2) @(negedge clk);

        btn = 4'b0100;  // RIGHT MIN
        @(negedge clk);
        btn = 4'b0000;
        repeat (2) @(negedge clk);

        // all move check complete

        // output check

        //  HOUR check

        btn = 4'b0001;  // DOWN
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        btn = 4'b1000;  //  UP
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        btn = 4'b0100;  //  STATE move
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        //  MIN check

        btn = 4'b0001;  // DOWN
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        btn = 4'b1000;  //  UP
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        btn = 4'b100;  //  STATE move
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        //  SEC check

        btn = 4'b0001;  // DOWN
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        btn = 4'b1000;  //  UP
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);

        btn = 4'b100;  //  STATE move
        @(negedge clk);
        btn = 4'b0000;
        @(negedge clk);



        $stop;
    end




endmodule
