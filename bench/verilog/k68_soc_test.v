//                              -*- Mode: Verilog -*-
// Filename        : k68_soc_test.v
// Description     : k68 SOC Test Bench
// Author          : Shawn Tan
// Created On      : Sat Feb 15 18:08:50 2003
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 to Shawn Tan Ser Ngiap.                  ////
////                       shawn.tan@aeste.net                   ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

`timescale 1ns / 10ps

//
// Bench Interface to Soft ROM
//

module k68_testrom (/*AUTOARG*/
   // Outputs
   dat_o, 
   // Inputs
   add_i
   );
   
   input [31:0] add_i;
   output [31:0] dat_o;

   //reg [31:0] 	 dat_o;
   reg [31:0] 	 mem [10240:0];

   wire [9:0] 	 add;

   assign 	 add = add_i[11:2];
 	 
   
   initial
     $readmemh ("test.rom",mem);
      
   assign  dat_o = mem[add];
      
endmodule // k68_testrom

module k68_testram (/*AUTOARG*/
   // Outputs
   dat_o, 
   // Inputs
   add_i, dat_i, we_i
   );
   
   input [31:0] add_i,dat_i;
   output [31:0] dat_o;
   input 	 we_i;
   
   reg [31:0] 	 mem [10240:0];
   wire [9:0] 	 add;

   assign 	 add = add_i[11:2];
   
   assign  dat_o = mem[add];

   always @(/*AUTOSENSE*/add or dat_i or we_i)
     if (we_i) mem[add] <= dat_i;
   
      
endmodule // k68_testrom

module k68_soc_test (/*AUTOARG*/) ;
   
   wire [31:0] add_o;
   wire [31:0] p_dat_i,m_dat_i,dat_o;
   reg [31:0]  dat_i;
   
   wire [1:0]  rts,tx;
   wire        we;
      
   reg 	       clk,rst;
   
   k68_soc dut0 (
		 .add_o(add_o),
		 .dat_o(dat_o),
		 .dat_i(dat_i),
		 .we_o(we),
		 .tx_o(tx),.rts_o(rts),
		 .rx_i(tx),.cts_i(rts),
		 .clk_i(clk), .rst_i(rst)
	 	 );
    
   k68_testrom prog0 (
		      .add_i(add_o),
		      .dat_o(p_dat_i)
		      );

   k68_testram data0 (
		      .add_i(add_o),
		      .dat_o(m_dat_i),
		      .dat_i(dat_o),
		      .we_i(we)
		      );
      
   initial begin
      clk = 1;
      rst = 0;
      #40 rst = 1;
      
   end
   
   
   always begin
      #5 clk = ~clk;
   end
   
   always @(/*AUTOSENSE*/add_o or m_dat_i or p_dat_i) begin
      if (add_o[31])
	dat_i <= m_dat_i;
      else
	dat_i <= p_dat_i;
   end

  
endmodule // k68_soc_test
