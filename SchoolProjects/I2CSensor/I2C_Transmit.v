module I2C_Transmit(    
    output [7:0] led,
    input  sys_clkn,
    input  sys_clkp,
    input  simStart,
    output ADT7420_A0,
    output ADT7420_A1,
    output I2C_SCL_0,
    inout  I2C_SDA_0,        
    output reg FSM_Clk_reg,    
    output reg ILA_Clk_reg,
    output reg ACK_bit,
    output reg SCL,
    output reg SDA,
    output reg [7:0] State,
    output wire [31:0] PC_control,
    input  wire    [4:0] okUH,
    output wire    [2:0] okHU,
    inout  wire    [31:0] okUHU,   
    inout wire okAA,
    output reg [15:0] TempReg     
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
                                      
    reg [7:0] AddressW = 8'b1001_0000;
    reg [7:0] AddressR = 8'b1001_0001;

    localparam RepeatFlag = 1'b1;
    localparam RegisterA = 7'b000_0000;
    reg [7:0] SUB = {RepeatFlag, RegisterA};

    reg [7:0] counter = 0;
    localparam byteCount = 6;
    reg [7:0] byteCountReg;
    reg [(byteCount * 8) - 1:0] data = 0;

    reg [7:0] STOP_CONDITION_1 = 8'd84;

    reg [15:0] XaxisReg = 16'b0000_0000_0000_0000;
    reg [15:0] YaxisReg = 16'b0000_0000_0000_0000;
    reg [15:0] ZaxisReg = 16'b0000_0000_0000_0000;
    
    reg error_bit = 1'b1;      
       
    localparam STATE_INIT = 8'd0;    
    assign led[7] = ACK_bit;
    assign led[6] = error_bit;
    assign ADT7420_A0 = 1'b0;
    assign ADT7420_A1 = 1'b0;
    assign I2C_SCL_0 = SCL;
    assign I2C_SDA_0 = SDA; 
    
    initial begin
        SCL = 1'b1;
        SDA = 1'b1;
        ACK_bit = 1'b1;  
        State = STATE_INIT;
        byteCountReg = byteCount;    
    end
    
    always @(*) begin          
        FSM_Clk_reg = FSM_Clk;
        ILA_Clk_reg = ILA_Clk;
    end   
                               
    always @(posedge FSM_Clk) begin
        case (State)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_INIT: begin
                 if (PC_control[0] == 1'b1 || simStart == 1'b1)
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
            8'd3: begin SCL <= 1'b0; SDA <= AddressW[7]; State <= State + 1; end  
            8'd4: begin SCL <= 1'b1; State <= State + 1; end  
            8'd5: begin SCL <= 1'b0; SDA <= AddressW[6]; State <= State + 1; end  
            8'd6: begin SCL <= 1'b1; State <= State + 1; end  
            8'd7: begin SCL <= 1'b0; SDA <= AddressW[5]; State <= State + 1; end  
            8'd8: begin SCL <= 1'b1; State <= State + 1; end  
            8'd9: begin SCL <= 1'b0; SDA <= AddressW[4]; State <= State + 1; end  
            8'd10: begin SCL <= 1'b1; State <= State + 1; end  
            8'd11: begin SCL <= 1'b0; SDA <= AddressW[3]; State <= State + 1; end  
            8'd12: begin SCL <= 1'b1; State <= State + 1; end  
            8'd13: begin SCL <= 1'b0; SDA <= AddressW[2]; State <= State + 1; end  
            8'd14: begin SCL <= 1'b1; State <= State + 1; end  
            8'd15: begin SCL <= 1'b0; SDA <= AddressW[1]; State <= State + 1; end  
            8'd16: begin SCL <= 1'b1; State <= State + 1; end  
            8'd17: begin SCL <= 1'b0; SDA <= AddressW[0]; State <= State + 1; end  
            8'd18: begin SCL <= 1'b1; State <= State + 1; end  
            8'd19: begin SCL <= 1'b0; SDA <= 1'bz; State <= State + 1; end  
            8'd20: begin SCL <= 1'b1; ACK_bit <= SDA; State <= State + 1; end
            //**************************************************
            //Transmit Register Address
            //**************************************************  
            8'd21: begin SCL <= 1'b0; State <= State + 1; end  
            8'd22: begin SCL <= 1'b0; SDA <= SUB[7]; State <= State + 1; end  
            8'd23: begin SCL <= 1'b1; State <= State + 1; end  
            8'd24: begin SCL <= 1'b0; SDA <= SUB[6]; State <= State + 1; end  
            8'd25: begin SCL <= 1'b1; State <= State + 1; end  
            8'd26: begin SCL <= 1'b0; SDA <= SUB[5]; State <= State + 1; end  
            8'd27: begin SCL <= 1'b1; State <= State + 1; end  
            8'd28: begin SCL <= 1'b0; SDA <= SUB[4]; State <= State + 1; end  
            8'd29: begin SCL <= 1'b1; State <= State + 1; end  
            8'd30: begin SCL <= 1'b0; SDA <= SUB[3]; State <= State + 1; end  
            8'd31: begin SCL <= 1'b1; State <= State + 1; end  
            8'd32: begin SCL <= 1'b0; SDA <= SUB[2]; State <= State + 1; end  
            8'd33: begin SCL <= 1'b1; State <= State + 1; end  
            8'd34: begin SCL <= 1'b0; SDA <= SUB[1]; State <= State + 1; end  
            8'd35: begin SCL <= 1'b1; State <= State + 1; end  
            8'd36: begin SCL <= 1'b0; SDA <= SUB[0]; State <= State + 1; end  
            8'd37: begin SCL <= 1'b1; State <= State + 1; end  
            8'd38: begin SCL <= 1'b0; SDA <= 1'bz; State <= State + 1; end  
            8'd39: begin SCL <= 1'b1; ACK_bit <= SDA; State <= State + 1; end
            //**************************************************
            //Second Start Condition
            //**************************************************
            8'd40: begin SCL <= 1'b0; State <= State + 1; end      
            8'd41: begin SCL <= 1'b0; SDA <= 1'b1; State <= State + 1; end  
            8'd42: begin SCL <= 1'b1; State <= State + 1; end  
            8'd43: begin SCL <= 1'b1; SDA <= 1'b0; State <= State + 1; end
            //**************************************************
            //Transmit Sensor Address / Read
            //**************************************************  
            8'd44: begin SCL <= 1'b0; State <= State + 1; end  
            8'd45: begin SCL <= 1'b0; SDA <= AddressR[7]; State <= State + 1; end  
            8'd46: begin SCL <= 1'b1; State <= State + 1; end  
            8'd47: begin SCL <= 1'b0; SDA <= AddressR[6]; State <= State + 1; end  
            8'd48: begin SCL <= 1'b1; State <= State + 1; end  
            8'd49: begin SCL <= 1'b0; SDA <= AddressR[5]; State <= State + 1; end  
            8'd50: begin SCL <= 1'b1; State <= State + 1; end  
            8'd51: begin SCL <= 1'b0; SDA <= AddressR[4]; State <= State + 1; end  
            8'd52: begin SCL <= 1'b1; State <= State + 1; end  
            8'd53: begin SCL <= 1'b0; SDA <= AddressR[3]; State <= State + 1; end  
            8'd54: begin SCL <= 1'b1; State <= State + 1; end  
            8'd55: begin SCL <= 1'b0; SDA <= AddressR[2]; State <= State + 1; end  
            8'd56: begin SCL <= 1'b1; State <= State + 1; end  
            8'd57: begin SCL <= 1'b0; SDA <= AddressR[1]; State <= State + 1; end  
            8'd58: begin SCL <= 1'b1; State <= State + 1; end  
            8'd59: begin SCL <= 1'b0; SDA <= AddressR[0]; State <= State + 1; end  
            8'd60: begin SCL <= 1'b1; State <= State + 1; end  
            8'd61: begin SCL <= 1'b0; SDA <= 1'bz; State <= State + 1; end  
            8'd62: begin SCL <= 1'b1; ACK_bit <= SDA; State <= State + 1; end
            //**************************************************
            //Receive Register Data
            //**************************************************  
            8'd63: begin SCL <= 1'b0; State <= State + 1; end  
            8'd64: begin SCL <= 1'b0; SDA <= 1'bz; State <= State + 1; end  
            8'd65: begin SCL <= 1'b1; data[2^(byteCountReg) - 1] <= SDA; State <= State + 1; end  
            8'd66: begin SCL <= 1'b0; State <= State + 1; end  
            8'd67: begin SCL <= 1'b1; data[2^(byteCountReg) - 2] <= SDA; State <= State + 1; end  
            8'd68: begin SCL <= 1'b0; State <= State + 1; end  
            8'd69: begin SCL <= 1'b1; data[2^(byteCountReg) - 3] <= SDA; State <= State + 1; end  
            8'd70: begin SCL <= 1'b0; State <= State + 1; end  
            8'd71: begin SCL <= 1'b1; data[2^(byteCountReg) - 4] <= SDA; State <= State + 1; end  
            8'd72: begin SCL <= 1'b0; State <= State + 1; end  
            8'd73: begin SCL <= 1'b1; data[2^(byteCountReg) - 5] <= SDA; State <= State + 1; end  
            8'd74: begin SCL <= 1'b0; State <= State + 1; end  
            8'd75: begin SCL <= 1'b1; data[2^(byteCountReg) - 6] <= SDA; State <= State + 1; end  
            8'd76: begin SCL <= 1'b0; State <= State + 1; end  
            8'd77: begin SCL <= 1'b1; data[2^(byteCountReg) - 7] <= SDA; State <= State + 1; end  
            8'd78: begin SCL <= 1'b0; State <= State + 1; end  
            8'd79: begin SCL <= 1'b1; data[2^(byteCountReg) - 8] <= SDA; State <= State + 1; end
            8'd80: begin SCL <= 1'b0; State <= State + 1; end  
            8'd81: begin SCL <= 1'b0; SDA <= 1'b0; State <= State + 1; end  
            8'd82: begin SCL <= 1'b1; State <= State + 1; end  
            8'd83: begin SCL <= 1'b0; State <= State + 1; byteCountReg <= byteCountReg - 1; if(byteCountReg == 1) State <= STOP_CONDITION_1; else State <= 8'd63; end                          
            //**************************************************
            //Master NACK
            //**************************************************  
            STOP_CONDITION_1: begin SCL <= 1'b0; SDA <= 1'b1; State <= State + 1; end  
            8'd85: begin SCL <= 1'b1; State <= State + 1; end  
            8'd86: begin SCL <= 1'b0; State <= State + 1; end  
            //**************************************************
            //Stop Condition
            //**************************************************    
            8'd87: begin SCL <= 1'b0; SDA <= 1'b0; State <= State + 1; end  
            8'd88: begin SCL <= 1'b1; State <= State + 1; end  
            8'd89: begin SCL <= 1'b1; SDA <= 1'b1; State <= STATE_INIT; end
            //**************************************************
            //Error State
            //**************************************************    
            default: begin
                error_bit <= 0;
            end
        endcase                           
    end      
    
//    // OK Interface wires for communication    
//    wire [112:0] okHE;  
//    wire [64:0] okEH;  
//    okHost hostIF (
//        .okUH(okUH),
//        .okHU(okHU),
//        .okUHU(okUHU),
//        .okClk(okClk),
//        .okAA(okAA),
//        .okHE(okHE),
//        .okEH(okEH)
//    );
    
//    // Wire OR to combine endpoint outputs
//    localparam endPt_count = 1;
//    wire [endPt_count*65-1:0] okEHx;  
//    okWireOR # (.N(endPt_count)) wireOR (okEH, okEHx);
       
//    // PC_control is data sent from PC to FPGA, communicated via memory location 0x00
//    okWireIn wire10 (.okHE(okHE), .ep_addr(8'h00), .ep_dataout(PC_control));     
                        
//    // FPGA to PC wire output
//    okWireOut wire20 (.okHE(okHE), .okEH(okEHx[ 0*65 +: 65 ]), .ep_addr(8'h20), .ep_datain(TempReg));
       
endmodule
