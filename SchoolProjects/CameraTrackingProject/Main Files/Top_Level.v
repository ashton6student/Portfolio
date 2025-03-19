`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2024 05:17:33 PM
// Design Name: 
// Module Name: Top_Level
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


module Top_Level(
    //differential clock
    input wire sys_clkn,
    input wire sys_clkp,
    
    //Camera stuff
    output CVM300_CLK_IN,
    output CVM300_SPI_CLK,
    output CVM300_SPI_EN,
    output CVM300_SPI_IN,
    input  CVM300_SPI_OUT, 
    output CVM300_FRAME_REQ,
    output CVM300_SYS_RES_N,
    
    input [9:0] CVM300_D,
    input CVM300_Line_valid,
    input CVM300_Data_valid,
    input CVM300_CLK_OUT,

    //OK inputs
    input  [4:0] okUH,
    output [2:0] okHU,
    inout  [31:0] okUHU,
    inout  okAA,    
    
    //Other
    input [3:0] button,
    output [7:0] led  
);
    //Stuff
    wire [31:0] FIFO_data_out;
    
    wire [31:0] from_PC;
    wire [7:0] SPI_State;
    wire [7:0] FIFO_State;
    
    //Instantiate Clocks 
    ///////////////////////////////////////////////////////////////////////////
    wire clk;
    
    wire FSM_Clk, ILA_Clk; 
    
    wire [23:0] ClkDivThreshold1 = 2;   
    
    wire [7:0] data1; 
       
    IBUFGDS osc_clk(
        .O(clk),
        .I(sys_clkp),
        .IB(sys_clkn)
    );   
    
    ClockGenerator ClockGenerator1 (  
        .clk(clk),                                     
        .ClkDivThreshold(ClkDivThreshold1),
        .FSM_Clk(FSM_Clk),                                      
        .ILA_Clk(ILA_Clk));
    ///////////////////////////////////////////////////////////////////////////
            
    //OK Stuff 
    ///////////////////////////////////////////////////////////////////////////
    wire [112:0] okHE;  
    wire [64:0] okEH;  
    okHost hostIF (
        .okUH(okUH),
        .okHU(okHU),
        .okUHU(okUHU),
        .okClk(okClk),
        .okAA(okAA),
        .okHE(okHE),
        .okEH(okEH)
    );

    localparam endPt_count = 2;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);
        
    //PC Data
    okWireIn wire10 (.okHE(okHE), .ep_addr(8'h00), .ep_dataout(from_PC));  
    
    // FPGA to PC wire output
    okWireOut wire20 (.okHE(okHE), .okEH(okEHx[ 0*65 +: 65 ]), .ep_addr(8'h20), .ep_datain(data1));   
    
    //FPGA to PC BTPipe output
    okBTPipeOut CounterToPC (
        .okHE(okHE), 
        .okEH(okEHx[ 1*65 +: 65 ]),
        .ep_addr(8'ha0), 
        .ep_datain({FIFO_data_out[7:0],FIFO_data_out[15:8],FIFO_data_out[23:16],FIFO_data_out[31:24]}), 
        .ep_read(FIFO_read_enable),
        .ep_blockstrobe(BT_Strobe), 
        .ep_ready(FIFO_BT_BlockSize_Full)
    );                                      
    ///////////////////////////////////////////////////////////////////////////
    
    //Modules
    ///////////////////////////////////////////////////////////////////////////    
    //SPI_Transmit
    SPI_Transmit spi_transmit(
        .FSM_CLK(FSM_Clk),
        .CLK_IN(CVM300_CLK_IN),
        .SPI_CLK(CVM300_SPI_CLK),
        .SPI_EN(CVM300_SPI_EN),
        .SPI_IN(CVM300_SPI_IN),
        .SPI_OUT(CVM300_SPI_OUT), 
        .SYS_RES_N(CVM300_SYS_RES_N),
        .data1(data1),
        .State(SPI_State),
        .from_PC(from_PC)
    );         
    
    //ImageFIFO
    ImageFIFO imageFIFO (
        .button(button),
        .led(led),
        .from_PC(from_PC),
        .FSM_Clk(FSM_Clk),
    
        //Camera Stuff
        .Data(CVM300_D),
        .Wr_Clk(CVM300_CLK_OUT),
        .Rd_Clk(okClk),
        .FIFO_read_enable(FIFO_read_enable),
        .FIFO_data_out(FIFO_data_out),
        .FIFO_BT_BlockSize_Full(FIFO_BT_BlockSize_Full),
        .State(FIFO_State)
    );    
    ///////////////////////////////////////////////////////////////////////////
    
    //Frame Req
    ///////////////////////////////////////////////////////////////////////////    

    reg prev_trigger;
    reg pulse;
    reg [1:0] pulse_counter;  // 2-bit counter to count 4 cycles

    assign CVM300_FRAME_REQ = pulse;

    always @(posedge FSM_Clk) begin
        // Rising edge detection
        if (from_PC[0] & ~prev_trigger) begin
            pulse <= 1'b1;
            pulse_counter <= 2'b11;
        end else if (pulse_counter > 0) begin
            pulse_counter <= pulse_counter - 1;
        end else begin
            pulse <= 1'b0;
        end

        prev_trigger <= from_PC[0];
    end
    ///////////////////////////////////////////////////////////////////////////    
    
    //Instantiate the ILA module
    ///////////////////////////////////////////////////////////////////////////    
    ila_0 ila_sample12 ( 
        .clk(ILA_Clk),
        .probe0({SPI_State, FIFO_State, CVM300_CLK_IN, CVM300_Line_valid, CVM300_D, from_PC}),                           
        .probe1({CVM300_CLK_OUT, CVM300_Data_valid})
        );      
    ///////////////////////////////////////////////////////////////////////////        
endmodule
