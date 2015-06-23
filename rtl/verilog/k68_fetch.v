//                              -*- Mode: Verilog -*-
// Filename        : k68_fetch.v
// Description     : RISC Like Fetch Unit
// Author          : Shawn Tan
// Created On      : Fri Feb  7 16:17:17 2003
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
  
module k68_fetch (/*AUTOARG*/
   // Outputs
   p_cs_o, p_add_o, pc_o, op_o, imm_o, 
   // Inputs
   p_dat_i, cpu_clk_i, mem_clk_i, rst_i, brch_i, pc_i
   ) ;
   parameter dw = `k68_DATA_W;
   parameter aw = `k68_ADDR_W;
   parameter nop = `k68_OP_NOP;
   parameter ow = `k68_OP_W;
   parameter zero = `ZERO;
   parameter reset = `k68_RST_VECTOR;
               
   input [ow-1:0] p_dat_i;
   input 	    cpu_clk_i,mem_clk_i,rst_i, brch_i;
   output 	    p_cs_o;//, rdy_o;
   output [aw-1:0]  p_add_o, pc_o;
   input [aw-1:0]   pc_i;
   output [ow-1:0] op_o;
   output [dw-1:0]   imm_o;

   reg 		     rdy;
   reg [ow-1:0]      op_o,immh_o,imml_o, tmpa,tmpb,tmpc,tmpd;

   // Internal State Counters Assume it takes 4 counts to read data
   reg [1:0] 	     mem_cnt, cpu_cnt;
    
   reg [aw-1:0]      p_add_o,pc;

   assign 	     pc_o = pc;
   
   assign 	     imm_o = {immh_o, imml_o};
   assign 	     p_cs_o = 1'b1;
       
   //
   // CPU SIDE
   //
      
   always @ (posedge cpu_clk_i) begin
      if (rst_i) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 cpu_cnt <= 0;
	 immh_o <= 0;
	 imml_o <= 0;
	 op_o <= 0;
	 p_add_o <= 0;
	 pc <= 0;
	 // End of automatics
	 p_add_o <= reset;
	 pc <= reset;
	 op_o <= nop;
	 	 
      end else begin
	 if (rdy) begin
	    case (cpu_cnt)
	   
	      2'b00: begin
		 op_o <= tmpa;
		 immh_o <= tmpb;
		 imml_o <= tmpc;
		 
	      end
	      
	      2'b01: begin
		 op_o <= tmpb;
		 immh_o <= tmpc;
		 imml_o <= tmpd;
		 
	      end
	      
	      2'b10: begin
		 op_o <= tmpc;
		 immh_o <= tmpd;
		 imml_o <= tmpa;
		 
	      end
	      
	      2'b11: begin
		 op_o <= tmpd;
		 immh_o <= tmpa;
		 imml_o <= tmpb;
		 
	      end
	   
	    endcase // case(cnt[3:2])
	 end else begin // if (rdy)
	    op_o <= nop;
	    {immh_o, imml_o} <= zero;
	    
	 end // else: !if(rdy)
	 
	 	 
	 if (brch_i) begin
	    pc <= pc_i;
	    cpu_cnt <= 2'd0;
	    p_add_o <= pc_i;
	    
	 end else begin
	    
	    if (rdy) begin
	       pc <= pc + 2'd2;
	    end
   	    
	    p_add_o <= p_add_o + 2'd2;
	    cpu_cnt <= cpu_cnt + 1'd1;
	    
	 end // else: !if(brch_i)

      end
      
   end

   
   //
   //  RDY FLAG
   //
   always @ (/*AUTOSENSE*/brch_i or p_add_o or pc or rst_i) begin
      if (rst_i || brch_i) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 rdy <= 0;
	 // End of automatics
      end else if (p_add_o[3:1] - pc[3:1] == 3'd3) begin
	 rdy <= 1'b1;
      end else begin
	 rdy <= 1'b0;
	 	 
      end
    
   end // always @ (...


   wire [ow-1:0]     s_dat_i;
     
`ifdef k68_SWAP
   assign 	     s_dat_i = {p_dat_i[7:0],p_dat_i[15:8]};
`else
   assign 	     s_dat_i = p_dat_i;
`endif
      
   //
   // PMEM SIDE
   //
   always @(posedge mem_clk_i) begin
      if (rst_i) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 mem_cnt <= 0;
	 tmpa <= 0;
	 tmpb <= 0;
	 tmpc <= 0;
	 tmpd <= 0;
	 // End of automatics

	 tmpa <= nop;
	 tmpb <= nop;
	 tmpc <= nop;
	 tmpd <= nop;
	 	 
      end else begin
	  	 
	 if (mem_cnt == 2'b00) begin
	    case (cpu_cnt)
	      2'b00: tmpd <= s_dat_i;
	      2'b01: tmpa <= s_dat_i;
	      2'b10: tmpb <= s_dat_i;
	      2'b11: tmpc <= s_dat_i;
	      
	    endcase // case(cpu_cnt)
	    
	 end
	 
	 if (brch_i) begin
	    tmpd <= nop;
	    tmpa <= nop;
	    tmpc <= nop;
	    tmpb <= nop;
	    
	 end
	 
	 mem_cnt <= mem_cnt + 1'd1;
	 
      end
      
      
   end
     
   
endmodule // k68_fetch

