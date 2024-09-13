`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2024 09:15:39 PM
// Design Name: 
// Module Name: nzp
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


module nzp(
    input logic [2:0] nzp_i,
    input logic clk,
    input logic reset,
    input logic ld_cc,
    output logic [2:0] nzp
    );
    always_ff @(posedge clk) begin
        if(ld_cc) begin
            nzp <= nzp_i;
        end else if(reset) begin
            nzp <= 3'b000;
        end else begin
            nzp <= nzp;
        end
    end
endmodule
