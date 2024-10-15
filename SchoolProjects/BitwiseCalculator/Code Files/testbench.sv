`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2024 09:07:29 PM
// Design Name: 
// Module Name: testbench
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


module testbench();

timeunit 10ns;
timeprecision 1ns;

logic Clk;     // Internal
logic Reset;   // Push button 0
logic LoadA;   // Push button 1
logic LoadB;   // Push button 2
logic Execute; // Push button 3
logic [7:0] Din;   
logic [2:0] F;     // Function select 
logic [1:0] R;       // Routing select

logic [3:0] LED;     // DEBUG
logic [7:0] Aval;    // DEBUG
logic [7:0] Bval;    // DEBUG
logic [7:0] hex_seg; // Hex display control
logic [3:0] hex_grid;

always begin: CLOCK_GENERATION
    #1 Clk = ~Clk;
end

initial begin: CLOCK_INTIIALIZATION
    Clk = 0;
end

Processor test_processor(.*);

initial begin: TEST_BODY
    Reset = 1;
    #2 Reset = 0;
    
    #1 Din = 8'b01101010;
    LoadA = 1;
    #2 LoadA = 0;
    
    #2 Din = 8'b00011011;
    LoadB = 1;
    #2 LoadB = 0;
    
    F = 3'b010; //XOR
    R = 2'b01;  //Result to B
    #1 Execute = 1;
    
end

endmodule
