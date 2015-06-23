`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    11:18:48 12/08/2009 
// Design Name: 
// Module Name:    t_memory_bank 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module t_memory_bank;
   // clock and reset signal
   reg CLK,EN,WE;
	reg [2:0]SELECT;
	reg [13:0] ADDR;
	reg [7:0]DI;
	wire [7:0]DO_BUF;
   
   initial begin CLK = 1'b0;
      repeat(200) #10 CLK=~CLK;
   end 
   
   // memory bank
   memory_bank MB(CLK,EN,WE,SELECT,ADDR,DI,DO_BUF);
   
   // clock generation
   //initial begin clock=0;forever #10 clock=~clock;end
   
   // start testing
   initial fork
		#0 ADDR=0;
      #0 EN=0; // write
		#0 WE=0;
		#0 SELECT=1;
		#0 DI=3;
		#5 EN=1;
		#5 WE=1;
		#25 ADDR=1;
		#25 DI=4;
		#45 ADDR=2;
		#45 DI=100;
		#65 ADDR=3;
		#65 DI=0;
		
		
      #85 ADDR=0;
		#85 EN=1; //burst read
		#85 WE=0;
		#85 SELECT=0;
		#105 ADDR=0;
		#105 SELECT=1;
		#125 ADDR=0;
		#125 SELECT=2;
		#145 ADDR=0;
		#145 SELECT=3;
		#165 ADDR=0;
		#165 SELECT=4;
		#185 ADDR=0;
		#185 SELECT=5;
		#205 ADDR=0;
		#205 SELECT=6;
		#225 ADDR=0;
		#225 SELECT=7;
		#245 EN=0;
		#245 WE=0;
   join


endmodule
