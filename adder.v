`timescale 1ns / 1ps

module adder_fnd (
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output       led
);

    wire [3:0] w_sum;

    full_adder_4bit U_FA_4 (
        .a  (a),
        .b  (b),
        .cin(1'b0),
        .s  (w_sum),
        .c  (led)
    );  

    fnd_controller U_FND_CNTL (
        .bin(w_sum),
        .fnd_data(fnd_data),
        .fnd_com(fnd_com)
    );


endmodule

module full_adder_4bit (
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] s,
    output       c
);

    wire w_c0, w_c1, w_c2;

    full_adder U_FA0 (
        .a  (a[0]),
        .b  (b[0]),
        .cin(cin),
        .s  (s[0]),
        .c  (w_c0)
    );

    full_adder U_FA1 (
        .a  (a[1]),
        .b  (b[1]),
        .cin(w_c0),
        .s  (s[1]),
        .c  (w_c1)
    );

    full_adder U_FA2 (
        .a  (a[2]),
        .b  (b[2]),
        .cin(w_c1),
        .s  (s[2]),
        .c  (w_c2)
    );

    full_adder U_FA3 (
        .a  (a[3]),
        .b  (b[3]),
        .cin(w_c2),
        .s  (s[3]),
        .c  (c)
    );

endmodule





module full_adder (
    input  a,
    input  b,
    input  cin,
    output s,
    output c
);

    wire w_s1, w_c1, w_c2;

    adder U_HA0 (
        .a(a),  // from full_adder input a
        .b(b),  // from full_adder input b
        .s(w_s1),
        .c(w_c1)
    );

    adder U_HA1 (
        .a(w_s1),
        .b(cin),  // from full_adder cin
        .s(s),  // to full adder output s
        .c(w_c2)  // to full adder output c
    );

    assign c = w_c1 | w_c2;

endmodule

module adder (
    input  a,
    input  b,
    output s,
    output c
);

    assign s = a ^ b;
    assign c = a & b;

endmodule
