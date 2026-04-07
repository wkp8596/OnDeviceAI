`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: OnDeviceAI_2
// Engineer: Park Wonjun
// 
// Create Date: 2026/04/06 10:56:50
// Design Name: 
// Module Name: gates
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// ` << grave accent
//timescale 1ns(using time scale) / 1ps(simulator's time scale)

module gates( // TOP module
    input   a, // usually wire, 1'bx
    input   b,
    output  y0, //AND output
    output  y1, //NAND output
    output  y2, //OR output
    output  y3, //NOR output
    output  y4, //XOR output
    output  y5, //XNOR output
    output  y6  //NOT output
    ); // Sentence ended

    assign y0 = a & b; // &: and operator
    assign y1 = !(a & b); // !, ~: not operator
    assign y2 = a | b; // |: or operator
    assign y3 = ~(a | b); // nor
    assign y4 = a ^ b; // ^: xor operator
    assign y5 = ! (a ^ b); // nxor
    assign y6 = !a; // not 

endmodule