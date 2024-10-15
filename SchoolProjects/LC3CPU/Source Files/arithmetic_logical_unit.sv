`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2024 08:52:25 PM
// Design Name: 
// Module Name: arithmetic_logical_unit
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


module arithmetic_logical_unit(
    input logic [1:0] aluk,
    input logic [15:0] A,
    input logic [15:0] B,
    output logic [15:0] S
    );
    always_comb begin
        unique case(aluk)
            2'b00: S = A + B;
            2'b01: S = A & B;   
            2'b10: S = ~A;
            2'b11: S = A;
        endcase
    end
endmodule
