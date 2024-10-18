module I2C_Transmit(    
    output [7:0] led,
    input  sys_clkn,
    input  sys_clkp,
    input  simStart,
    output ADT7420_A0,
    output ADT7420_A1,
    output I2C_SCL_1,
    inout  I2C_SDA_1,        
    output reg FSM_Clk_reg,    
    output reg ILA_Clk_reg,
    output reg ACK_bit,
    output reg SCL,
    output reg SDA,
    output reg [7:0] State,
    output wire [31:0] from_PC,
    input  wire    [4:0] okUH,
    output wire    [2:0] okHU,
    inout  wire    [31:0] okUHU,   
    inout wire okAA,
    output wire [31:0] data1,
    output wire [31:0] data2     
    );
    
    // Instantiate the ClockGenerator module, where three signals are generated:
    // High speed CLK signal, Low speed FSM_Clk signal     
    wire [23:0] ClkDivThreshold = 1;   
    wire FSM_Clk, ILA_Clk; 
    
    ClockGenerator ClockGenerator1 (  .sys_clkn(sys_clkn),
                                      .sys_clkp(sys_clkp),                                      
                                      .ClkDivThreshold(ClkDivThreshold),
                                      .FSM_Clk(FSM_Clk),                                      
                                      .ILA_Clk(ILA_Clk) );
    // Data 
    wire PC_START = from_PC[31];                        
    wire [6:0] SAD = from_PC[30:24];
    wire [7:0] SUB = from_PC[23:16];
    wire [15:0] BYTE_COUNT = from_PC[15:0];
    
//    localparam RepeatFlag = 1'b1;
//    localparam RegisterA = 7'b010_1000;
//    reg [7:0] SUB = {RepeatFlag, RegisterA};

    reg [7:0] counter = 0;
//    localparam byteCount = 12;
    reg [7:0] byteCountReg;
    reg [511:0] data = 0;
    
    assign data1 = data[63:32];
    assign data2 = data[31:0];
    
    reg [7:0] STOP_CONDITION_1 = 8'd151;
    reg [7:0] READ_START = 8'd114;

    reg [15:0] XaxisReg = 16'b0000_0000_0000_0000;
    reg [15:0] YaxisReg = 16'b0000_0000_0000_0000;
    reg [15:0] ZaxisReg = 16'b0000_0000_0000_0000;
    
    reg error_bit = 1'b1;      
       
    localparam STATE_INIT = 8'd0;    
    assign led[7] = ACK_bit;
    assign led[6] = error_bit;
    assign ADT7420_A0 = 1'b0;
    assign ADT7420_A1 = 1'b0;
    assign I2C_SCL_1 = SCL;
    assign I2C_SDA_1 = SDA; 
    
    initial begin
        SCL = 1'b1;
        SDA = 1'b1;
        ACK_bit = 1'b1;  
        State = STATE_INIT;
        byteCountReg = BYTE_COUNT;    
    end
    
    always @(*) begin          
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;
    end   
                               
    always @(posedge FSM_Clk) begin
        case (State)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT: begin
                 if (PC_START == 1'b1 || simStart == 1'b1)
                     State <= State + 1;                    
                 else
                     State <= STATE_INIT;
            end
            
            // Start condition
            8'd1: begin SCL <= 1'b1; SDA <= 1'b0; State <= State + 1; end  
            8'd2: begin SCL <= 1'b0; State <= State + 1; end  
            //**************************************************
            //Transmit Sensor Address / Write
            //**************************************************  
            8'd3: begin SCL <= 1'b0; SDA <= SAD[6]; State <= State + 1; end  
            8'd4: begin SCL <= 1'b1; State <= State + 1; end  
            8'd5: begin SCL <= 1'b1; State <= State + 1; end
            8'd6: begin SCL <= 1'b0; State <= State + 1; end
            8'd7: begin SCL <= 1'b0; SDA <= SAD[5]; State <= State + 1; end  
            8'd8: begin SCL <= 1'b1; State <= State + 1; end  
            8'd9: begin SCL <= 1'b1; State <= State + 1; end
            8'd10: begin SCL <= 1'b0; State <= State + 1; end
            8'd11: begin SCL <= 1'b0; SDA <= SAD[4]; State <= State + 1; end  
            8'd12: begin SCL <= 1'b1; State <= State + 1; end  
            8'd13: begin SCL <= 1'b1; State <= State + 1; end
            8'd14: begin SCL <= 1'b0; State <= State + 1; end
            8'd15: begin SCL <= 1'b0; SDA <= SAD[3]; State <= State + 1; end  
            8'd16: begin SCL <= 1'b1; State <= State + 1; end  
            8'd17: begin SCL <= 1'b1; State <= State + 1; end
            8'd18: begin SCL <= 1'b0; State <= State + 1; end
            8'd19: begin SCL <= 1'b0; SDA <= SAD[2]; State <= State + 1; end  
            8'd20: begin SCL <= 1'b1; State <= State + 1; end  
            8'd21: begin SCL <= 1'b1; State <= State + 1; end
            8'd22: begin SCL <= 1'b0; State <= State + 1; end
            8'd23: begin SCL <= 1'b0; SDA <= SAD[1]; State <= State + 1; end  
            8'd24: begin SCL <= 1'b1; State <= State + 1; end  
            8'd25: begin SCL <= 1'b1; State <= State + 1; end
            8'd26: begin SCL <= 1'b0; State <= State + 1; end
            8'd27: begin SCL <= 1'b0; SDA <= SAD[0]; State <= State + 1; end  
            8'd28: begin SCL <= 1'b1; State <= State + 1; end  
            8'd29: begin SCL <= 1'b1; State <= State + 1; end
            8'd30: begin SCL <= 1'b0; State <= State + 1; end
            8'd31: begin SCL <= 1'b0; SDA <= 1'b0; State <= State + 1; end  
            8'd32: begin SCL <= 1'b1; State <= State + 1; end  
            8'd33: begin SCL <= 1'b1; State <= State + 1; end
            8'd34: begin SCL <= 1'b0; State <= State + 1; end
            8'd35: begin SCL <= 1'b0; SDA <= 1'bz; State <= State + 1; end 
            8'd36: begin SCL <= 1'b1; State <= State + 1; end 
            8'd37: begin SCL <= 1'b1; ACK_bit <= SDA; State <= State + 1; end
            //**************************************************
            //Transmit Register Address
            //**************************************************  
            8'd38: begin SCL <= 1'b0; State <= State + 1; end  
            8'd39: begin SCL <= 1'b0; SDA <= SUB[7]; State <= State + 1; end  
            8'd40: begin SCL <= 1'b1; State <= State + 1; end  
            8'd41: begin SCL <= 1'b1; State <= State + 1; end
            8'd42: begin SCL <= 1'b0; State <= State + 1; end
            8'd43: begin SCL <= 1'b0; SDA <= SUB[6]; State <= State + 1; end  
            8'd44: begin SCL <= 1'b1; State <= State + 1; end  
            8'd45: begin SCL <= 1'b1; State <= State + 1; end
            8'd46: begin SCL <= 1'b0; State <= State + 1; end
            8'd47: begin SCL <= 1'b0; SDA <= SUB[5]; State <= State + 1; end  
            8'd48: begin SCL <= 1'b1; State <= State + 1; end  
            8'd49: begin SCL <= 1'b1; State <= State + 1; end
            8'd50: begin SCL <= 1'b0; State <= State + 1; end
            8'd51: begin SCL <= 1'b0; SDA <= SUB[4]; State <= State + 1; end  
            8'd52: begin SCL <= 1'b1; State <= State + 1; end  
            8'd53: begin SCL <= 1'b1; State <= State + 1; end
            8'd54: begin SCL <= 1'b0; State <= State + 1; end
            8'd55: begin SCL <= 1'b0; SDA <= SUB[3]; State <= State + 1; end  
            8'd56: begin SCL <= 1'b1; State <= State + 1; end  
            8'd57: begin SCL <= 1'b1; State <= State + 1; end
            8'd58: begin SCL <= 1'b0; State <= State + 1; end
            8'd59: begin SCL <= 1'b0; SDA <= SUB[2]; State <= State + 1; end  
            8'd60: begin SCL <= 1'b1; State <= State + 1; end  
            8'd61: begin SCL <= 1'b1; State <= State + 1; end
            8'd62: begin SCL <= 1'b0; State <= State + 1; end
            8'd63: begin SCL <= 1'b0; SDA <= SUB[1]; State <= State + 1; end  
            8'd64: begin SCL <= 1'b1; State <= State + 1; end  
            8'd65: begin SCL <= 1'b1; State <= State + 1; end
            8'd66: begin SCL <= 1'b0; State <= State + 1; end
            8'd67: begin SCL <= 1'b0; SDA <= SUB[0]; State <= State + 1; end  
            8'd68: begin SCL <= 1'b1; State <= State + 1; end  
            8'd69: begin SCL <= 1'b1; State <= State + 1; end
            8'd70: begin SCL <= 1'b0; State <= State + 1; end
            8'd71: begin SCL <= 1'b0; SDA <= 1'bz; State <= State + 1; end  
            8'd72: begin SCL <= 1'b1; State <= State + 1; end
            8'd73: begin SCL <= 1'b1; ACK_bit <= SDA; State <= State + 1; end
            //**************************************************
            //Second Start Condition
            //**************************************************
            8'd74: begin SCL <= 1'b0; State <= State + 1; end      
            8'd75: begin SCL <= 1'b0; SDA <= 1'b1; State <= State + 1; end  
            8'd76: begin SCL <= 1'b1; State <= State + 1; end  
            8'd77: begin SCL <= 1'b1; SDA <= 1'b0; State <= State + 1; end
            //**************************************************
            //Transmit Sensor Address / Read
            //**************************************************  
            8'd78: begin SCL <= 1'b0; State <= State + 1; end  
            8'd79: begin SCL <= 1'b0; SDA <= SAD[6]; State <= State + 1; end  
            8'd80: begin SCL <= 1'b1; State <= State + 1; end  
            8'd81: begin SCL <= 1'b1; State <= State + 1; end
            8'd82: begin SCL <= 1'b0; State <= State + 1; end
            8'd83: begin SCL <= 1'b0; SDA <= SAD[5]; State <= State + 1; end  
            8'd84: begin SCL <= 1'b1; State <= State + 1; end  
            8'd85: begin SCL <= 1'b1; State <= State + 1; end
            8'd86: begin SCL <= 1'b0; State <= State + 1; end
            8'd87: begin SCL <= 1'b0; SDA <= SAD[4]; State <= State + 1; end  
            8'd88: begin SCL <= 1'b1; State <= State + 1; end  
            8'd89: begin SCL <= 1'b1; State <= State + 1; end
            8'd90: begin SCL <= 1'b0; State <= State + 1; end
            8'd91: begin SCL <= 1'b0; SDA <= SAD[3]; State <= State + 1; end  
            8'd92: begin SCL <= 1'b1; State <= State + 1; end  
            8'd93: begin SCL <= 1'b1; State <= State + 1; end
            8'd94: begin SCL <= 1'b0; State <= State + 1; end
            8'd95: begin SCL <= 1'b0; SDA <= SAD[2]; State <= State + 1; end  
            8'd96: begin SCL <= 1'b1; State <= State + 1; end  
            8'd97: begin SCL <= 1'b1; State <= State + 1; end
            8'd98: begin SCL <= 1'b0; State <= State + 1; end
            8'd99: begin SCL <= 1'b0; SDA <= SAD[1]; State <= State + 1; end  
            8'd100: begin SCL <= 1'b1; State <= State + 1; end  
            8'd101: begin SCL <= 1'b1; State <= State + 1; end
            8'd102: begin SCL <= 1'b0; State <= State + 1; end
            8'd103: begin SCL <= 1'b0; SDA <= SAD[0]; State <= State + 1; end  
            8'd104: begin SCL <= 1'b1; State <= State + 1; end  
            8'd105: begin SCL <= 1'b1; State <= State + 1; end
            8'd106: begin SCL <= 1'b0; State <= State + 1; end
            8'd107: begin SCL <= 1'b0; SDA <= 1'b1; State <= State + 1; end  
            8'd108: begin SCL <= 1'b1; State <= State + 1; end  
            8'd109: begin SCL <= 1'b1; State <= State + 1; end
            8'd110: begin SCL <= 1'b0; State <= State + 1; end
            8'd111: begin SCL <= 1'b0; SDA <= 1'bz; State <= State + 1; end  
            8'd112: begin SCL <= 1'b1; State <= State + 1; end
            8'd113: begin SCL <= 1'b1; ACK_bit <= SDA; State <= State + 1; end
            //**************************************************
            //Receive Register Data
            //**************************************************  
            READ_START: begin SCL <= 1'b0; State <= State + 1; end  
            8'd115: begin SCL <= 1'b0; SDA <= 1'bz; State <= State + 1; end  
            8'd116: begin SCL <= 1'b1; State <= State + 1; end
            8'd117: begin SCL <= 1'b1; data[8 * byteCountReg - 1] <= SDA; State <= State + 1; end  
            8'd118: begin SCL <= 1'b0; State <= State + 1; end
            8'd119: begin SCL <= 1'b0; State <= State + 1; end  
            8'd120: begin SCL <= 1'b1; State <= State + 1; end
            8'd121: begin SCL <= 1'b1; data[8 * byteCountReg - 2] <= SDA; State <= State + 1; end  
            8'd122: begin SCL <= 1'b0; State <= State + 1; end  
            8'd123: begin SCL <= 1'b0; State <= State + 1; end
            8'd124: begin SCL <= 1'b1; State <= State + 1; end
            8'd125: begin SCL <= 1'b1; data[8 * byteCountReg - 3] <= SDA; State <= State + 1; end  
            8'd126: begin SCL <= 1'b0; State <= State + 1; end  
            8'd127: begin SCL <= 1'b0; State <= State + 1; end
            8'd128: begin SCL <= 1'b1; State <= State + 1; end
            8'd129: begin SCL <= 1'b1; data[8 * byteCountReg - 4] <= SDA; State <= State + 1; end  
            8'd130: begin SCL <= 1'b0; State <= State + 1; end  
            8'd131: begin SCL <= 1'b0; State <= State + 1; end
            8'd132: begin SCL <= 1'b1; State <= State + 1; end
            8'd133: begin SCL <= 1'b1; data[8 * byteCountReg - 5] <= SDA; State <= State + 1; end  
            8'd134: begin SCL <= 1'b0; State <= State + 1; end  
            8'd135: begin SCL <= 1'b0; State <= State + 1; end
            8'd136: begin SCL <= 1'b1; State <= State + 1; end
            8'd137: begin SCL <= 1'b1; data[8 * byteCountReg - 6] <= SDA; State <= State + 1; end  
            8'd138: begin SCL <= 1'b0; State <= State + 1; end  
            8'd139: begin SCL <= 1'b0; State <= State + 1; end
            8'd140: begin SCL <= 1'b1; State <= State + 1; end
            8'd141: begin SCL <= 1'b1; data[8 * byteCountReg - 7] <= SDA; State <= State + 1; end  
            8'd142: begin SCL <= 1'b0; State <= State + 1; end  
            8'd143: begin SCL <= 1'b0; State <= State + 1; end
            8'd144: begin SCL <= 1'b1; State <= State + 1; end
            8'd145: begin SCL <= 1'b1; data[8 * byteCountReg - 8] <= SDA; State <= State + 1; end
            8'd146: begin SCL <= 1'b0; State <= State + 1; end  
            8'd147: begin SCL <= 1'b0; SDA <= 1'b0; State <= State + 1; end  
            8'd148: begin SCL <= 1'b1; State <= State + 1; end  
            8'd149: begin SCL <= 1'b1; State <= State + 1; end
            8'd150: begin SCL <= 1'b0; State <= State + 1; byteCountReg <= byteCountReg - 1; if(byteCountReg == 1) State <= STOP_CONDITION_1; else State <= READ_START; end                          
            //**************************************************
            //Master NACK
            //**************************************************  
            STOP_CONDITION_1: begin SCL <= 1'b0; SDA <= 1'b1; State <= State + 1; end  
            8'd152: begin SCL <= 1'b1; State <= State + 1; end 
            8'd153: begin SCL <= 1'b1; State <= State + 1; end 
            8'd154: begin SCL <= 1'b0; State <= State + 1; end  
            //**************************************************
            //Stop Condition
            //**************************************************    
            8'd155: begin SCL <= 1'b0; SDA <= 1'b0; State <= State + 1; end  
            8'd156: begin SCL <= 1'b1; State <= State + 1; end  
            8'd157: begin SCL <= 1'b1; SDA <= 1'b1; State <= STATE_INIT; end
            //**************************************************
            //Error State
            //**************************************************    
            default: begin
                error_bit <= 0;
            end
        endcase                           
    end      
    
    // OK Interface wires for communication    
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
    
    // Wire OR to combine endpoint outputs
    localparam endPt_count = 2;
    wire [endPt_count*65-1:0] okEHx;  
    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);
       
    // PC_control is data sent from PC to FPGA, communicated via memory location 0x00
    okWireIn wire10 (.okHE(okHE), .ep_addr(8'h00), .ep_dataout(from_PC));     
                        
    // FPGA to PC wire output
    okWireOut wire20 (.okHE(okHE), .okEH(okEHx[ 0*65 +: 65 ]), .ep_addr(8'h20), .ep_datain(data1));
    okWireOut wire21 (.okHE(okHE), .okEH(okEHx[ 1*65 +: 65 ]), .ep_addr(8'h21), .ep_datain(data2));   
endmodule
