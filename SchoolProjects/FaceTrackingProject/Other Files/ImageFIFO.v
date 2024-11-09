`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2024 05:16:43 PM
// Design Name: 
// Module Name: ImageFIFO
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


module ImageFIFO(
    input [3:0] button,
    output [7:0] led,
    input wire [31:0] from_PC,
    input FSM_Clk,
    
    //Camera Stuff
    input [9:0] Data,
    input DVAL,
    input LVAL,
    input Wr_Clk,
    input Rd_Clk,
    input FIFO_read_enable,
    output [31:0] FIFO_data_out,
    output FIFO_BT_BlockSize_Full,
    output reg [7:0] State
    );

    wire FSM_start = from_PC[30];
    
    localparam STATE_INIT                = 8'd0;
    localparam STATE_RESET               = 8'd1;   
    localparam STATE_DELAY               = 8'd2;
    localparam STATE_RESET_FINISHED      = 8'd3;
    localparam STATE_ENABLE_WRITING      = 8'd4;
    localparam STATE_COUNT               = 8'd5;
    localparam STATE_FINISH              = 8'd6;
   
    reg [31:0] counter = 8'd0;
    reg [15:0] counter_delay = 16'd0;
    //reg [7:0] State = STATE_INIT;
    reg [7:0] led_register = 0;
    reg [3:0] button_reg, write_enable_counter;  
    reg write_reset, read_reset, write_enable;
    wire [31:0] Reset_Counter;
    wire [31:0] DATA_Counter;    
    wire FIFO_read_enable, FIFO_BT_BlockSize_Full, FIFO_full, FIFO_empty, BT_Strobe;
    wire [31:0] FIFO_data_out;
    
    wire FIFO_Clk;
    reg write_flag;
    assign FIFO_CLk = Wr_Clk & DVAL & LVAL & write_flag;
    initial begin
        State = STATE_INIT;
    end                                      
    always @(posedge FSM_Clk) begin     
        button_reg <= ~button;   // Grab the values from the button, complement and store them in register                
        if (FSM_start == 1'b1) State <= STATE_RESET;
        
        case (State)
            STATE_INIT:   begin                              
                write_enable <= 1'b0;
                if (FSM_start == 1'b1) State <= STATE_RESET;                
            end
            
            STATE_RESET:   begin
                counter <= 0;
                counter_delay <= 0;
                write_reset <= 1'b1;
                read_reset <= 1'b1;                
                if (FSM_start == 1'b0) State <= STATE_RESET_FINISHED;             
            end                                     
 
           STATE_RESET_FINISHED:   begin
                write_reset <= 1'b0;
                read_reset <= 1'b0;                 
                State <= STATE_DELAY;                                   
            end   
                          
            STATE_DELAY:   begin
                if (counter_delay == 16'b0000_1111_1111_1111)  State <= STATE_ENABLE_WRITING;
                else counter_delay <= counter_delay + 1;
            end
            
             STATE_ENABLE_WRITING:   begin
                write_enable <= 1'b1;
                //CVM_FRAM_REQ <= 1
                State <= STATE_COUNT;
             end
                                  
             STATE_COUNT:   begin
                write_flag <= 1;
             end
            
//             STATE_FINISH:   begin                         
//                 write_enable <= 1'b0;                                                           
//            end

        endcase
    end    
       
    fifo_generator_0 FIFO_for_Counter_BTPipe_Interface (
        .wr_clk(Wr_Clk),
        .wr_rst(write_reset),
        .rd_clk(Rd_Clk),
        .rd_rst(read_reset),
        .din(Data[9:2]),
        .wr_en(write_enable),
        .rd_en(FIFO_read_enable),
        .dout(FIFO_data_out),
        .full(FIFO_full),
        .empty(FIFO_empty),       
        .prog_full(FIFO_BT_BlockSize_Full)        
    );
endmodule
