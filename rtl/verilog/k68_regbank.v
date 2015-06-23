//                              -*- Mode: Verilog -*-
// Filename        : k68_regbank.v
// Description     : RISC Async RegBank
// Author          : Shawn Tan
// Created On      : Sat Feb  8 16:47:06 2003
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

`include "k68_defines.v"

module k68_regbank (/*AUTOARG*/
   // Outputs
   rs_dat_o, rt_dat_o, 
   // Inputs
   rs_add_i, rt_add_i, rd_add_i, clk_i, rst_i, we_i, rd_dat_i
   ) ;

   parameter dw = `k68_DATA_W;
   parameter gw = `k68_GPR_W;
         
   input [gw-1:0] rs_add_i, rt_add_i, rd_add_i;
   input 	  clk_i, rst_i, we_i;
   
   output [dw-1:0] rs_dat_o, rt_dat_o;
   input [dw-1:0]  rd_dat_i;

   reg [dw-1:0]    w_dat;
   reg [gw-1:0]    w_add;
   reg 		   we;
   
   
   k68_dpmem #(gw,dw) bank0(
		   .clk_i(clk_i), .rst_i(rst_i), .we_i(we),
		   .add_r_i(rs_add_i), .dat_r_o(rs_dat_o),
		   .add_w_i(w_add), .dat_w_i(w_dat)
		   );

   k68_dpmem #(gw,dw) bank1(
		   .clk_i(clk_i), .rst_i(rst_i), .we_i(we),
		   .add_r_i(rt_add_i), .dat_r_o(rt_dat_o),
		   .add_w_i(w_add), .dat_w_i(w_dat)
		   );

   always @(posedge clk_i) begin
      w_add <= rd_add_i;
      w_dat <= rd_dat_i;
      we <= we_i;
   end
      
endmodule // k68_regbank


//
// Dual Port Memory Submodule
//

module k68_dpmem(/*AUTOARG*/
   // Outputs
   dat_r_o, 
   // Inputs
   add_r_i, add_w_i, dat_w_i, clk_i, rst_i, we_i
   );
   parameter gw = `k68_GPR_W;
   parameter dw = `k68_DATA_W;

   input [gw-1:0] add_r_i, add_w_i;
   input [dw-1:0] dat_w_i;
   output [dw-1:0] dat_r_o;
   input 	   clk_i, rst_i, we_i;

   wire [7:0] 	   r_add,w_add;
   
   assign 	   r_add = 8'hFF & add_r_i;
   assign 	   w_add = 8'hFF & add_w_i;
   
   reg [dw-1:0]    mem [(1<<gw)-1:0];
      
   // Synchronous Writes
   always @ (posedge clk_i)
     if (we_i) mem[add_w_i] <= dat_w_i;
   
   assign 	   dat_r_o = mem[add_r_i];

        
endmodule // dpmem
