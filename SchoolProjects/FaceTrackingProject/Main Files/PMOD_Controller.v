`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2024 04:42:38 PM
// Design Name: 
// Module Name: Motor_Control
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


module Motor_Control(
//    input  wire    [4:0] okUH,
//    output wire    [2:0] okHU,
//    inout  wire    [31:0] okUHU,   
//    inout  wire okAA,
    input wire FSM_Clk,
    output wire PMOD_A1,
    output wire PMOD_A2,
    input  wire PMOD_A3,
    input  wire PMOD_A4,
    output wire PMOD_A7,
    output wire PMOD_A8,
    input wire PMOD_A9,
    input wire PMOD_A10,
    input wire [31:0] from_PC2_sim,
    input wire [31:0] from_PC2,
    output reg FSM_Clk_reg,    
    output reg ILA_Clk_reg,
    output reg [7:0] State    
    );
    
//    //Generate Clock
//    wire [23:0] ClkDivThreshold = 12_500; //12_500 for 400Hz FSM Clk, which we want for a 200Hz output
//    wire FSM_Clk, ILA_Clk; 
    
//    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
//                                      .sys_clkp(sys_clkp),                                      
//                                      .ClkDivThreshold(ClkDivThreshold),
//                                      .FSM_Clk(FSM_Clk),                                      
//                                      .ILA_Clk(ILA_Clk) );
    
    //PMOD Connections                                  
    reg EN1, DIR1, S1A, S1B;
    reg EN2, DIR2, S2A, S2B;
    
    assign PMOD_A1 = EN1;
    assign PMOD_A2 = DIR1;
    assign PMOD_A3 = S1A;
    assign PMOD_A4 = S1B;

    assign PMOD_A7 = EN2;
    assign PMOD_A8 = DIR2;
    assign PMOD_A9 = S2A;
    assign PMOD_A10 = S2B;
    
    //From PC Connections
    wire PC_START;
    wire [30:0] CTR;
    reg [29:0] CTR_REG;
    
    //From PC actual
    assign PC_START = from_PC2[31];
    assign DIR = from_PC2[30];
    assign CTR = from_PC2[29:0];
    
    //From PC sim
//    assign PC_START = from_PC2_sim[31];
//    assign DIR = from_PC2_sim[30];
//    assign CTR = from_PC2_sim[29:0];    
    
    //FSM Stuff
    localparam START = 8'd0;
    localparam RUN = 8'd1;
    localparam STOP = 8'd2;
    
    initial begin
        EN1 = 1'b0;
        DIR1 = 1'b0;
        
        EN2 = 1'b0;
        DIR2 = 1'b0;
        
        CTR_REG = 30'b0;    
    end
    
    always @(*) begin          
        FSM_Clk_reg = FSM_Clk;
        //ILA_Clk_reg = ILA_Clk;
    end  
    
    always @(posedge FSM_Clk) begin
        case(State)
            START: begin
                if(PC_START) begin
                    State <= State + 1;
                    CTR_REG <= (CTR << 1);
                end else begin
                    State <= START;
                end
            end
            
            RUN: begin
                CTR_REG <= CTR_REG - 1;
                if (CTR_REG != 1'b1) begin
                    State <= RUN;
                    EN1 <= ~EN1;
                    EN2 <= ~EN2; 
                    if(DIR == 1'b0) begin
                        DIR1 <= 1'b0;
                        DIR2 <= 1'b0;
                    end else begin
                        DIR1 <= 1'b1;
                        DIR2 <= 1'b1;                    
                    end
                end else begin
                    State <= STOP;
                    EN1 <= 1'b0;
                    EN2 <= 1'b0;
                end
            end
            
            STOP: begin
                DIR1 <= 0'b0;
                DIR2 <= 0'b0;
                if (~PC_START) begin
                    State <= START; 
                end else begin
                    State <= STOP; 
                end   
            end  
            default : State <= START;
        endcase
    end   
         
endmodule
