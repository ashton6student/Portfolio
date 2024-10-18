`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2024 02:48:49 PM
// Design Name: 
// Module Name: Lab5Sim
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


module Lab5Sim();
    reg sys_clkn = 1;
    wire sys_clkp;
    reg simStart;

       

    I2C_Transmit DUT(.sys_clkn(sys_clkn), .sys_clkp(sys_clkp), .simStart(simStart));

    assign sys_clkp = ~sys_clkn;    
    always begin
        #5 sys_clkn = ~sys_clkn;
    end        
      
    initial begin          
         #0 simStart <= 1'b1;
         #1000 simStart <= 1'b0; 
    end

endmodule
