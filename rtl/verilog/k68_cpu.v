//                              -*- Mode: Verilog -*-
// Filename        : k68_cpu.v
// Description     : RISC 68K
// Author          : Shawn Tan
// Created On      : Sat Feb  8 02:23:38 2003
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

module k68_cpu (/*AUTOARG*/
   // Outputs
   add_o, cs_o, dat_o, we_o, clk_o, rst_o, 
   // Inputs
   dat_i, clk_i, rst_i, int_i
   );
   parameter dw = `k68_DATA_W;
   parameter aw = `k68_ADDR_W;
   parameter ow = `k68_OP_W;
   parameter gw = `k68_GPR_W;
   parameter sw = `k68_SCR_W;
   parameter lw = `k68_ALU_W;
   parameter kw = 6;
            
   output [aw-1:0] add_o;
   output 	   cs_o;
   output [dw-1:0] dat_o;
   input [dw-1:0]  dat_i;
   output 	   we_o;
   input 	   clk_i,rst_i;
   input [2:0] 	   int_i;
   output 	   clk_o;
   output 	   rst_o;
         
   wire [aw-1:0]   p_add_o, m_add_o;
   wire 	   p_cs_o, m_cs_o, m_we_o;
   wire [dw-1:0]   m_dat_i, m_dat_o;
   wire [ow-1:0]   p_dat_i;
   
   wire 	   f_rdy_o;
   wire [aw-1:0]   f_pc_o;
   wire [ow-1:0]   f_op_o;
   wire [dw-1:0]   f_imm_o;
   
   wire [lw-1:0]   d_alu_o;
   wire [dw-1:0]   d_src_o, d_dst_o;
   wire 	   d_run_o,d_brch_o;
   wire [1:0] 	   d_skip_o;
   wire [aw-1:0]   d_pc_o;
   wire [kw-1:0]   d_add_a_o, d_add_b_o, d_add_c_o, d_add_src_o, d_add_dst_o;
   wire [dw-1:0]   d_dat_c_o;
   wire [1:0] 	   d_siz_o, d_siz_a_o;
   wire [dw-1:0]   d_imm_o;
   
   wire [dw-1:0]   a_dat_a_o, a_dat_b_o, a_dat_c_o;
   wire [1:0] 	   a_skip_o;
   wire [gw-1:0]   a_rs_add_o, a_rt_add_o, a_rd_add_o;
   wire 	   a_we_o;
   wire [dw-1:0]   a_rd_dat_o;
   wire [dw-1:0]   a_dst_o;
   
   wire [aw-1:0]   e_pc_o, d_alu_pc_o;
   
   wire [dw-1:0]   r_rs_dat_o, r_rt_dat_o;
   
   wire [dw-1:0]   e_res_o;
   wire [sw-1:0]   e_ccr_o, e_ssr_o;
   wire [kw-1:0]   e_add_c_o;
   wire [lw-1:0]   e_alu_o;
   
   wire 	   clk4_i;
   wire [1:0] 	   e_siz_o, c_siz_o;
      
   wire 	   rst,cs,we;
  
`ifdef k68_RESET_HI
   assign 	   rst = rst_i;
`else
   assign 	   rst = ~rst_i;
`endif
  
`ifdef k68_ACTIVE_HI
   assign 	   cs_o = cs;
   assign 	   we_o = we;
`else
   assign 	   cs_o = ~cs;
   assign 	   we_o = ~we;
`endif

   //
   // Fix Endianess
   //
   
   k68_clkgen clkgen0(.clk4_o(clk4_i), .rst_o(rst_o), .clk_o(clk_o),
		      .clk_i(clk_i), .rst_i(rst)
		      );

   k68_buni unify0(
		   .add_o(add_o),
		   .dat_o(dat_o),
		   .dat_i(dat_i),
		   
		   .cs_o(cs),
		   .we_o(we),

		   .p_add_i(p_add_o),
		   .p_dat_o(p_dat_i),

		   .m_add_i(m_add_o),
		   .m_we_i(m_we_o),
		   .m_dat_i(m_dat_o),
		   .m_dat_o(m_dat_i),
		   
		   .clk_i(clk_i), .rst_i(rst_o)
		   );
  
   k68_fetch fetch0 (
		     .rst_i(rst_o),
		     .cpu_clk_i(clk4_i), 
		     .mem_clk_i(clk_i),
		     .p_add_o(p_add_o),
		     .p_dat_i(p_dat_i),
		     .p_cs_o(p_cs_o),
		     .pc_o(f_pc_o),
		     .brch_i(d_brch_o),
		     .op_o(f_op_o),
		     .imm_o(f_imm_o),
		     .pc_i(d_pc_o)
		     );
  
   k68_load addmode0(
		     .dat_a_o(a_dat_a_o),
		     .dat_b_o(a_dat_b_o),
		     .dat_c_o(a_dat_c_o),
		     .skip_o(a_skip_o),
		     .m_add_o(m_add_o),
		     .m_dat_o(m_dat_o),
		     .m_cs_o(m_cs_o),
		     .m_we_o(m_we_o),
		     .rs_add_o(a_rs_add_o),
		     .rt_add_o(a_rt_add_o),
		     .rd_add_o(a_rd_add_o),
		     .r_we_o(a_we_o),
		     .rd_dat_o(a_rd_dat_o),
		     
		     .dat_c_i(d_dat_c_o),
		     .add_a_i(d_add_a_o),
		     .add_b_i(d_add_b_o),
		     .add_c_i(d_add_c_o),
		     .imm_i(d_imm_o),
		     .siz_i(d_siz_a_o),
		     .m_dat_i(m_dat_i),
		     .rs_dat_i(r_rs_dat_o),
		     .rt_dat_i(r_rt_dat_o),
		     .c_siz_i(c_siz_o),
		     .pc_i(f_pc_o),

		     .clk_i(clk4_i),
		     .m_clk_i(clk_i),.rst_i(rst_o)
		     );
      
   k68_execute execute0(
			.res_o(e_res_o),
			.ccr_o(e_ccr_o),
			.ssr_o(e_ssr_o),
			.alu_o(e_alu_o),
			.add_c_o(e_add_c_o),
			.pc_i(d_alu_pc_o),
			.pc_o(e_pc_o),
			.siz_o(e_siz_o),
			.int_i(int_i),
			
			.alu_i(d_alu_o),
			.src_i(d_src_o),
			.dst_i(d_dst_o),
			.add_src_i(d_add_src_o),
			.add_dst_i(d_add_dst_o),
			.siz_i(d_siz_o),

			.skip_i(a_skip_o),
			.clk_i(clk4_i), .rst_i(rst_o)
			);
 
   k68_regbank regbank0(
			.rs_dat_o(r_rs_dat_o),
			.rt_dat_o(r_rt_dat_o),

			.rs_add_i(a_rs_add_o),
			.rt_add_i(a_rt_add_o),
			.rd_add_i(a_rd_add_o),
			.we_i(a_we_o),
			.rd_dat_i(a_rd_dat_o),
			.clk_i(clk_i), .rst_i(rst_o)
			);
   
   k68_decode decode0 (
		       .pc_i(f_pc_o),
		       .op_i(f_op_o),
		       .imm_i(f_imm_o),
		       .alu_i(e_alu_o),
		       .res_i(e_res_o),
		       .add_c_i(e_add_c_o),
		       .dat_a_i(a_dat_a_o),
		       .dat_b_i(a_dat_b_o),
		       .skip_i(a_skip_o),
		       .alu_pc_i(e_pc_o),
		       .dat_c_i(a_dat_c_o),
		       
		       .siz_i(e_siz_o),
		       .c_siz_o(c_siz_o),
		       
		       .alu_o(d_alu_o),
		       .src_o(d_src_o),
		       .dst_o(d_dst_o),
		       .skip_o(d_skip_o),
		       .brch_o(d_brch_o),
		       .pc_o(d_pc_o),
		       .alu_pc_o(d_alu_pc_o),
		       
		       .add_a_o(d_add_a_o),
		       .add_b_o(d_add_b_o),
		       .add_c_o(d_add_c_o),
		       .add_src_o(d_add_src_o),
		       .add_dst_o(d_add_dst_o),
		       .dat_c_o(d_dat_c_o),
		       .siz_o(d_siz_o),
		       .imm_o(d_imm_o),
		       .siz_a_o(d_siz_a_o),
		       
		       .clk_i(clk4_i),
		       .rst_i(rst_o)
		       );

endmodule // k68_cpu

// 
// BUS Unifier
//
module k68_buni (/*AUTOARG*/
   // Outputs
   cs_o, we_o, add_o, dat_o, p_dat_o, m_dat_o, 
   // Inputs
   clk_i, rst_i, p_add_i, m_add_i, dat_i, m_dat_i, m_we_i
   ) ;
   parameter aw = `k68_ADDR_W;
   parameter dw = `k68_DATA_W;
   parameter ow = `k68_OP_W;
   parameter xxxx = `XXXX;
   parameter zero = `ZERO;
   
   input     clk_i, rst_i;
   output    cs_o, we_o;
   
   input [aw-1:0] p_add_i, m_add_i;
   output [aw-1:0] add_o;

   input [dw-1:0]  dat_i;
   output [dw-1:0] dat_o;
       
   input [dw-1:0]  m_dat_i;
   output [ow-1:0]  p_dat_o;
   output [dw-1:0]  m_dat_o;

   input 	    m_we_i;
   reg [1:0] 	    uni_cnt;
 

   // Chip select always ON becuase it's either Program or Data Access
   assign 	    cs_o = 1'b1;
   
   assign 	    m_dat_o = (uni_cnt == 2'b00) ? xxxx : dat_i;
   assign 	    p_dat_o = (uni_cnt == 2'b00) ? dat_i : xxxx;
   assign 	    add_o = (uni_cnt == 2'b00) ? p_add_i : m_add_i;
   assign 	    dat_o = m_dat_i;
   assign 	    we_o = (uni_cnt == 2'b00) ? 1'b0 : m_we_i;
   
   //
   // Synchronouse Count
   always @(posedge clk_i) begin
      if (rst_i)
	uni_cnt <= 2'b00;
      else
	uni_cnt <= uni_cnt + 2'b01;
   end
      
endmodule // k68_sba


//
// CLOCK DIVIDER TO GENERATE CLK and CLK/4
//

module k68_clkgen (/*AUTOARG*/
   // Outputs
   clk4_o, clk_o, rst_o, 
   // Inputs
   clk_i, rst_i
   ) ;

   input clk_i,rst_i;
   output clk4_o;
   output clk_o;
   output rst_o;
   reg 	  rst_o;
   
   reg [1:0] 	    cnt;

   assign    clk4_o = cnt[1];
   assign    clk_o = ~clk_i;
   
   always @(posedge clk_i) begin
	cnt <= cnt + 1'b1;
   end

   always @(posedge clk4_o) rst_o <= rst_i;
      
endmodule // k68_clkgen

