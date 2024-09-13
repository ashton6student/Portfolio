//------------------------------------------------------------------------------
// Company: 		 UIUC ECE Dept.
// Engineer:		 Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Given Code - SLC-3 core
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015 
//    Revised 06-09-2020
//	  Revised 03-02-2021
//    Xilinx vivado
//    Revised 07-25-2023 
//    Revised 12-29-2023
//------------------------------------------------------------------------------

module cpu (
    input   logic        clk,
    input   logic        reset,

    input   logic        run_i,
    input   logic        continue_i,
    output  logic [15:0] hex_display_debug,
    output  logic [15:0] led_o,
   
    input   logic [15:0] mem_rdata,
    output  logic [15:0] mem_wdata,
    output  logic [15:0] mem_addr,
    output  logic        mem_mem_ena,
    output  logic        mem_wr_ena
);


// Internal connections
logic ld_mar; 
logic ld_mdr; 
logic ld_ir; 
logic ld_ben; 
logic ld_cc; 
logic ld_reg; 
logic ld_pc; 
logic ld_led;

logic gate_pc;
logic gate_mdr;
logic gate_alu; 
logic gate_marmux;

logic [1:0] pcmux;
logic       drmux;
logic       sr1mux;
logic       sr2mux;
logic       addr1mux;
logic [1:0] addr2mux;
logic [1:0] aluk;
logic       mio_en;

logic [15:0] mdr_in;
logic [15:0] mar; 
logic [15:0] mdr;
logic [15:0] ir;
logic [15:0] pc;
logic [15:0] alu;
logic ben;


assign mem_addr = mar;
assign mem_wdata = mdr;

// State machine, you need to fill in the code here as well
// .* auto-infers module input/output connections which have the same name
// This can help visually condense modules with large instantiations, 
// but can also lead to confusing code if used too commonly
control cpu_control (
    .*
);


assign led_o = ir;
assign hex_display_debug = ir;

//Week 2 Code
//Bus

logic [15:0] bus;
always_comb begin
    if(gate_marmux) begin
        bus = addr;
    end
    else if(gate_pc) begin
        bus = pc;
    end
    else if(gate_alu) begin
        bus = alu;
    end
    else if(gate_mdr) begin
        bus = mdr;
    end else begin
        bus = 16'b0;
    end
end

//Register Unit
logic [2:0] dr;
logic [2:0] sr1;
logic [2:0] sr2;
logic [15:0] sr1_out;
logic [15:0] sr2_out;
always_comb begin
    //DRMUX
    if(drmux) begin
        dr = 3'b111;
    end else begin
        dr = ir[11:9];
    end
    //SR1
    if(sr1mux) begin
        sr1 = ir[8:6];
    end else begin
        sr1 = ir[11:9];
    end
    //SR2
        sr2 = ir[2:0];
    end

//mdrmux
logic [15:0] mdrmux_out;
always_comb begin
    if(mio_en) begin
        mdrmux_out = mem_rdata;
    end else begin
        mdrmux_out = bus;
    end
end  
 
//sr2mux
logic [15:0] sr2mux_out;
logic [15:0] sext_ir4;
always_comb begin
    sext_ir4 = {{11{ir[4]}},ir[4:0]};
    if (sr2mux) begin
        sr2mux_out = sext_ir4;
    end else begin
        sr2mux_out = sr2_out;
    end
end

//adder, addr1mux, addr2mux
logic [15:0] addr1;
logic [15:0] addr2;
logic [15:0] addr;
logic [15:0] sext_ir5;
logic [15:0] sext_ir8;
logic [15:0] sext_ir10;
always_comb begin
    //addr1
    if(addr1mux) begin
        addr1 = sr1_out;
    end else begin
        addr1 = pc;
    end
    //addr2
    sext_ir5 = {{10{ir[5]}},ir[5:0]};
    sext_ir8 = {{7{ir[8]}},ir[8:0]};
    sext_ir10 ={{5{ir[10]}},ir[10:0]};
    unique case(addr2mux)
        (2'b01): addr2 = sext_ir5;
        (2'b10): addr2 = sext_ir8;
        (2'b11): addr2 = sext_ir10;
        default: addr2 = 16'h0000;
    endcase
    //addr_out
    addr = addr1 + addr2;
end

//pcmux
logic [15:0] pcmux_out;
always_comb begin
    unique case (pcmux)
        (2'b01): pcmux_out = bus;
        (2'b10): pcmux_out = addr;
        default: pcmux_out = pc +1'b1; //in lecture he said it should be two, check this
    endcase
end

//nzp
logic [2:0] nzp;
logic [2:0] nzp_i;
always_comb begin
    if(bus == 16'h0000) begin
        nzp_i = 3'b010;
    end else if (bus[15] == 1'b1) begin
        nzp_i = 3'b100;
    end else if (bus[15] == 1'b0) begin
        nzp_i = 3'b001;
    end else begin
        nzp_i = 3'b000;
    end
end
//End Week 2

load_reg #(.DATA_WIDTH(16)) ir_reg (
    .clk    (clk),
    .reset  (reset),

    .load   (ld_ir),
    .data_i (bus),

    .data_q (ir)
);

load_reg #(.DATA_WIDTH(16)) pc_reg (
    .clk(clk),
    .reset(reset),

    .load(ld_pc),
    .data_i(pcmux_out),

    .data_q(pc)
);

load_reg #(.DATA_WIDTH(16)) mar_reg (
    .clk(clk),
    .reset(reset),
    
    .load(ld_mar),
    .data_i(bus),
    
    .data_q(mar)
);

load_reg #(.DATA_WIDTH(16)) mdr_reg (
    .clk(clk),
    .reset(reset),
    
    .load(ld_mdr),
    .data_i(mdrmux_out),
    
    .data_q(mdr)
);

register_file register_file(
    .clk(clk),
    .dr(dr),
    .ld_reg(ld_reg),
    .sr1(sr1), 
    .sr2(sr2),
    .data_in(bus),
    .sr1_out(sr1_out),
    .sr2_out(sr2_out)
);

arithmetic_logical_unit alu_unit(
    .aluk(aluk),
    .A(sr1_out),
    .B(sr2mux_out),
    .S(alu)
);

br_comp br_comp_unit (
    .clk(clk),
    .nzp(nzp),
    .ir(ir[11:9]),
    .ld_ben(ld_ben),
    .ben(ben)
);

nzp nzp_unit(
    .nzp_i(nzp_i),
    .clk(clk),
    .reset(reset),
    .ld_cc(ld_cc),
    .nzp(nzp)
);
endmodule