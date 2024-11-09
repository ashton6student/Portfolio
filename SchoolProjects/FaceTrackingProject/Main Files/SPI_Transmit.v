//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2024 05:16:11 PM
// Design Name: 
// Module Name: SPI_Transmit
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


module SPI_Transmit(
    input wire FSM_CLK,
    output CLK_IN,
    output SPI_CLK,
    output reg SPI_EN,
    output reg SPI_IN,
    input  SPI_OUT, 
    output reg SYS_RES_N,
    input wire [31:0] from_PC_sim,
    input wire [31:0] from_PC,
    output wire [7:0] data1,
//    output reg FSM_Clk_reg,    
//    output reg ILA_Clk_reg,
//    output reg SPI_EN_reg,
//    output reg SPI_CLK_reg,
//    output reg SPI_IN_reg,
//    output reg SPI_OUT_reg,
    output reg [7:0] State
    );
    
    //Generate Clock. Here we generate a clock based on FSM_Clk which is assumed to be 80MHz.
    reg ClkINPUT;
    reg ClkDiv40M;
    
    //From_PC Set
    wire power_on = from_PC[31];
    wire spi_start = from_PC[30];
    wire C = from_PC[29];
    wire [6:0] ADDRESS = from_PC[28:22];
    wire [7:0] DATA_W = from_PC[21:14];

    //From_PC Set SIM
//    wire power_on = from_PC_sim[31];
//    wire spi_start = from_PC_sim[30];
//    wire C = from_PC_sim[29];
//    wire [6:0] ADDRESS = from_PC_sim[28:22];
//    wire [7:0] DATA_W = from_PC_sim[21:14];
    
    reg [7:0] DATA_R; 
    
    assign data1 = DATA_R;
      
    always @(posedge FSM_CLK) begin        
        ClkINPUT <= ~ClkINPUT;
    end      
    
    reg start_up_flag, transmit_flag, invert_flag;
    
    reg[6:0] micro_sec_ctr;
    reg[4:0] byte_ctr;
    
    assign CLK_IN = ClkINPUT & start_up_flag;
    assign SPI_CLK = (ClkINPUT ^ invert_flag) & transmit_flag;
//    reg [7:0] State;
    
    localparam MIRCO_SEC_CTR_VAL = 7'd50;
    
    localparam INIT = 8'd0;
    localparam START_CLK = 8'd1;
    localparam START_RESET = 8'd2;
    localparam IDLE_1 = 8'd3;
    localparam SPI_ADDER = 8'd4;
    localparam SPI_WRITE = 8'd5;
    localparam SPI_READ = 8'd6;
    localparam STOP_1 = 8'd7;
    localparam STOP_2 = 8'd8;
    localparam IDLE_2 = 8'd9;
    
    initial begin
        start_up_flag <= 1'b0;
        transmit_flag <= 1'b0;
        invert_flag <= 1'b0;
        
        micro_sec_ctr <= MIRCO_SEC_CTR_VAL;
        byte_ctr <= 5'd14;
        SYS_RES_N <= 0;
        State <= 8'b0;
        
        ClkINPUT <= 0;
        
        SPI_EN <= 0;
        SPI_IN <= 0;
        
        DATA_R <= 0;
    end
    
    always @(posedge FSM_CLK) begin
        case (State)
            INIT: begin 
                if (power_on) begin
                    State <= START_CLK;
                    start_up_flag <= 1;
                end
                else State <= INIT;
            end
            
            START_CLK: begin
                if (micro_sec_ctr == 0) begin
                    micro_sec_ctr <= MIRCO_SEC_CTR_VAL;
                    SYS_RES_N <= 1;
                    State <= START_RESET;
                end 
                else begin 
                    micro_sec_ctr <= micro_sec_ctr - 1;
                    State <= START_CLK; 
                end
            end
            
            START_RESET: begin
                if (micro_sec_ctr == 0) begin
                    micro_sec_ctr <= MIRCO_SEC_CTR_VAL;
                    if(spi_start) begin
                        SPI_EN <= 1;
                        SPI_IN <= C;
                        if(CLK_IN) invert_flag <= 0; else invert_flag <= 1;
                        State <= SPI_ADDER; 
                    end else begin
                        State <= IDLE_1;
                    end
                    
                end 
                else begin 
                    micro_sec_ctr <= micro_sec_ctr - 1;
                    State <= START_RESET; 
                end
            end
            
            IDLE_1: begin
                if(power_on == 0) begin
                    start_up_flag <= 0;
                    SYS_RES_N <= 0;
                    State <= INIT; 
                end else if (spi_start) begin
                    SPI_EN <= 1;
                    SPI_IN <= C;
                    if(CLK_IN) invert_flag <= 0; else invert_flag <= 1;
                    State <= SPI_ADDER; 
                end else begin
                    State <= IDLE_1;
                end
            end
            
            SPI_ADDER: begin
                transmit_flag <= 1;
                if (byte_ctr == 0) begin
                    if(C) State <= SPI_WRITE; else State <= SPI_READ;
                    byte_ctr <= 5'd16;       
                end else begin
                    if (byte_ctr[0] == 1) begin
                        SPI_IN <= ADDRESS[byte_ctr >> 1];
                    end else begin
                        SPI_IN <= SPI_IN;
                    end
                    State <= SPI_ADDER;
                    byte_ctr <= byte_ctr - 1;               
                end
            end
            
            SPI_WRITE: begin
                if (byte_ctr == 0) begin
                    State <= STOP_1;
                    byte_ctr <= 5'd14;       
                end else begin
                    if (byte_ctr[0] == 0) begin
                        SPI_IN <= DATA_W[(byte_ctr >> 1) - 1];
                    end else begin
                        SPI_IN <= SPI_IN;
                    end
                    State <= SPI_WRITE;
                    byte_ctr <= byte_ctr - 1;               
                end
            end
            
            SPI_READ: begin
                SPI_IN <= 0;
                if (byte_ctr == 0) begin
                    State <= STOP_1;
                    byte_ctr <= 5'd14;        
                end else begin
                    if (byte_ctr[0] == 1) begin
                        DATA_R[(byte_ctr >> 1)] <= SPI_OUT;
                    end
                    State <= SPI_READ;
                    byte_ctr <= byte_ctr - 1;   
                end             
            end
            
            STOP_1: begin
                transmit_flag <= 0;
                invert_flag <= 0;
                SPI_IN <= 0;
                State <= STOP_2;
            end
            
            STOP_2: begin
                SPI_EN <= 0;
                State <= IDLE_2;
            end
            
            IDLE_2: begin
                if (power_on == 0) begin
                    start_up_flag <= 0;
                    SYS_RES_N <= 0;
                    State <= INIT;
                end else if (spi_start == 0) begin
                    State <= IDLE_1;
                end else begin
                    State <= IDLE_2;
                end
            end
            default: State <= INIT;
        endcase   
    end
endmodule
