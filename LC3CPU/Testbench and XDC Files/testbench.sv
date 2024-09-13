`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/21/2024 08:22:34 PM
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


module testbench;
     logic		clk; 
	 logic 		reset;

	 logic 		run_i; 
	 logic 		continue_i;
	 logic [15:0] sw_i;

	 logic [15:0] led_o;
	 logic [7:0]  hex_seg_left;
	 logic [3:0]  hex_grid_left;
	 logic [7:0]  hex_seg_right;
	 logic [3:0]  hex_grid_right;
	
	processor_top lc3(.*);
	
	initial begin
	clk = 1'b0;
	forever clk = #5 ~clk;
	end
////IO Test 1	
//	initial begin
//	   sw_i <= 16'h0000;
//	   reset <= 1'b0;
//	   run_i <= 1'b0;
//	   continue_i <= 1'b0;
//	   repeat (10) @(posedge clk);
//	   reset <= 1'b1; repeat (10) @(posedge clk); reset <= 1'b0; //Reset LC-3
//	   sw_i <= 16'h0003; //Set switches
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b1;
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b0;
//	   repeat (50) @(posedge clk);
//	   sw_i <= 16'h0056;
//	   repeat (5000) @(posedge clk);
//	   $finish;
//	end
////IO Test 2	
//	initial begin
//	   sw_i <= 16'h0000;
//	   reset <= 1'b0;
//	   run_i <= 1'b0;
//	   continue_i <= 1'b0;
//	   repeat (10) @(posedge clk);
//	   reset <= 1'b1; repeat (10) @(posedge clk); reset <= 1'b0; //Reset LC-3
//	   sw_i <= 16'h0006; //Set switches
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b1;
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b0;
//	   repeat (50) @(posedge clk);
//	   continue_i <= 16'b1;
//	   sw_i <= 16'h0056;
//	   repeat (10) @(posedge clk);
//	   continue_i <= 16'b0;
//	   repeat (50) @(posedge clk);
//	   continue_i <= 16'b1;
//	   sw_i <= 16'h0026;
//	   repeat (10) @(posedge clk);
//	   continue_i <= 16'b0;
//	   repeat (5000) @(posedge clk);
//	   $finish;
//	end
////Self-Modifying Code Program
//	initial begin
//	   sw_i <= 16'h0000;
//	   reset <= 1'b0;
//	   run_i <= 1'b0;
//	   continue_i <= 1'b0;
//	   repeat (10) @(posedge clk);
//	   reset <= 1'b1; repeat (10) @(posedge clk); reset <= 1'b0; //Reset LC-3
//	   sw_i <= 16'h000B; //Set switches
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b1;
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b0;
//	   repeat (50) @(posedge clk);
//	   continue_i <= 16'b1;
//	   sw_i <= 16'h0056;
//	   repeat (10) @(posedge clk);
//	   continue_i <= 16'b0;
//	   repeat (50) @(posedge clk);
//	   continue_i <= 16'b1;
//	   sw_i <= 16'h0026;
//	   repeat (10) @(posedge clk);
//	   continue_i <= 16'b0;
//	   repeat (50) @(posedge clk);
//	   continue_i <= 16'b1;
//	   sw_i <= 16'h0087;
//	   repeat (10) @(posedge clk);
//	   continue_i <= 16'b0;
//	   repeat (50) @(posedge clk);
//	   continue_i <= 16'b1;
//	   sw_i <= 16'h00AB;
//	   repeat (10) @(posedge clk);
//	   continue_i <= 16'b0;
//	   repeat (5000) @(posedge clk);
//	   $finish;
//	end
//Auto-Counter Test Program
initial begin
       sw_i <= 16'h0000;
	   reset <= 1'b0;
	   run_i <= 1'b0;
	   continue_i <= 1'b0;
	   repeat (10) @(posedge clk);
	   reset <= 1'b1; repeat (10) @(posedge clk); reset <= 1'b0; //Reset LC-3
	   sw_i <= 16'h009c; //Set switches
	   repeat (10) @(posedge clk);
	   run_i <= 1'b1;
	   repeat (10) @(posedge clk);
	   run_i <= 1'b0;
	   repeat (5000) @(posedge clk);
	   $finish;
    end
////MULT Test Program
//    initial begin
//    initial begin
//       sw_i <= 16'h0000;
//	   reset <= 1'b0;
//	   run_i <= 1'b0;
//	   continue_i <= 1'b0;
//	   repeat (10) @(posedge clk);
//	   reset <= 1'b1; repeat (10) @(posedge clk); reset <= 1'b0; //Reset LC-3
//	   sw_i <= 16'h0031; //Set switches
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b1;
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b0;
//	   repeat (50) @(posedge clk);
//	   sw_i <= 16'h0007; //First mult
//	   repeat (10) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0;
//	   repeat (50) @(posedge clk);
//	   sw_i <= 16'h0008; //Second mult
//	   repeat (10) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0;
//	   repeat (1000) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0;
//	   repeat (50) @(posedge clk);
//	   $finish;
//    end
////XOR Test Program
//    initial begin
//       sw_i <= 16'h0000;
//	   reset <= 1'b0;
//	   run_i <= 1'b0;
//	   continue_i <= 1'b0;
//	   repeat (10) @(posedge clk);
//	   reset <= 1'b1; repeat (10) @(posedge clk); reset <= 1'b0; //Reset LC-3
//	   sw_i <= 16'h0014; //Set switches
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b1;
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b0;
//	   repeat (50) @(posedge clk);
//	   sw_i <= 16'b00011; //First XOR
//	   repeat (10) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0;
//	   repeat (50) @(posedge clk);
//	   sw_i <= 16'b01010; //Second XOR
//	   repeat (10) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0;
//	   repeat (50) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0;
//	   repeat (50) @(posedge clk);
//	   $finish;
//    end
////Sort Test Program
//initial begin
//       sw_i <= 16'h0000;
//	   reset <= 1'b0;
//	   run_i <= 1'b0;
//	   continue_i <= 1'b0;
//	   repeat (10) @(posedge clk);
//	   reset <= 1'b1; repeat (10) @(posedge clk); reset <= 1'b0; //Reset LC-3
//	   sw_i <= 16'h005A; //Set switches
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b1;
//	   repeat (10) @(posedge clk);
//	   run_i <= 1'b0;
//	   repeat (100) @(posedge clk);
//	   //Display Before Sort
//	   sw_i <= 16'b0011; //Display
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Trigger Display
//	   repeat (300) @(posedge clk);
////	   sw_i <= 16'h0000; //Set Switches
//	   //Displaying Values
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //First Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Second Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Third Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Fourth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Fifth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Sixth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Seventh Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Eighth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Ninth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Tenth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Eleventh Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Twelvth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Thirtenth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Fourtenth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Fiftenth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //End
//	   repeat (100) @(posedge clk);
//	   //Sort
//	   sw_i <= 16'b0010;
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Sixtenth Value
//	   repeat (13000) @(posedge clk);
//	   //Display After Sort
//	   sw_i <= 16'b0011; //Display
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Trigger Display
//	   repeat (300) @(posedge clk);
////	   sw_i <= 16'h0000; //Set Switches
//	   //Displaying Values
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //First Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Second Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Third Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Fourth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Fifth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Sixth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Seventh Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Eighth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Ninth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Tenth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Eleventh Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Twelvth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Thirtenth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Fourtenth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //Fiftenth Value
//	   repeat (100) @(posedge clk);
//	   continue_i = 1'b1; repeat (10) @(posedge clk); continue_i = 1'b0; //End
//	   repeat (100) @(posedge clk);
//	   $finish;
//    end
endmodule
