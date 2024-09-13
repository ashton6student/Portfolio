`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2024 01:06:06 AM
// Design Name: 
// Module Name: register_file
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


module register_file(

    input logic clk,
    input logic [2:0] dr,
    input logic ld_reg,
    input logic [2:0] sr1, sr2,
    input logic [15:0] data_in,
    
    output logic [15:0] sr1_out, sr2_out

);
    
logic [15:0] registers [8];

always_ff @(posedge clk) begin
    if (ld_reg) begin
        registers[dr] <= data_in;
    end else begin
        registers <= registers;
    end
    
    sr1_out = registers[sr1];
    sr2_out = registers[sr2];
end

endmodule
