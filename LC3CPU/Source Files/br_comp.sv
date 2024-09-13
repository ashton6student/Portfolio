`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2024 09:09:33 PM
// Design Name: 
// Module Name: br_comp
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


module br_comp(
    input logic clk,
    input logic [2:0] nzp,
    input logic [2:0] ir,
    input logic ld_ben,
    output logic ben
    );
    logic ben_nxt;
    always_comb begin
        if(((nzp[2] && ir[2]) || (nzp[1] && ir[1]) || (nzp[0] && ir[0])) && ld_ben) begin
            ben_nxt = 1'b1;
        end else if(ld_ben) begin
            ben_nxt = 1'b0;
        end else begin
            ben_nxt = ben;
        end
    end
    
    always_ff @(posedge clk) begin
        ben <= ben_nxt;
    end
endmodule
