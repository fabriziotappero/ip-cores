//                              -*- Mode: Verilog -*-
// Filename        : k68_execute.v
// Description     : RISC 68k ALU
// Author          : Shawn Tan
// Created On      : Sun Feb  9 00:05:41 2003
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

module k68_execute (/*AUTOARG*/
   // Outputs
   res_o, ccr_o, ssr_o, add_c_o, alu_o, siz_o, pc_o, 
   // Inputs
   clk_i, rst_i, alu_i, src_i, dst_i, add_src_i, add_dst_i, siz_i, 
   pc_i, int_i, skip_i
   ) ;

   parameter dw = `k68_DATA_W;
   parameter lw = `k68_ALU_W;
   parameter kw = 6;
   parameter sw = `k68_SCR_W;
   parameter zero = `ZERO;
   parameter xxxx = `XXXX;
   parameter esc = `ESC;
   parameter aw = `k68_ADDR_W;
   parameter ccr = `k68_RST_CCR;
   parameter ssr = `k68_RST_SSR;
   
   // FLAGS
   parameter ZF = `k68_Z_FLAG;
   parameter CF = `k68_C_FLAG;
   parameter VF = `k68_V_FLAG;
   parameter NF = `k68_N_FLAG;
   parameter XF = `k68_X_FLAG;
   
   // ALUOPS
   parameter ALU_ABCD = `k68_ALU_ABCD;
   parameter ALU_SBCD = `k68_ALU_SBCD;
   parameter ALU_NBCD = `k68_ALU_NBCD;
   parameter ALU_ADD = `k68_ALU_ADD;
   parameter ALU_ADDX = `k68_ALU_ADDX;
   parameter ALU_SUB = `k68_ALU_SUB;
   parameter ALU_SUBX = `k68_ALU_SUBX;
   parameter ALU_OR = `k68_ALU_OR;
   parameter ALU_AND = `k68_ALU_AND;
   parameter ALU_EOR = `k68_ALU_EOR;
   parameter ALU_BTST = `k68_ALU_BTST;
   parameter ALU_BCHG = `k68_ALU_BCHG;
   parameter ALU_BCLR = `k68_ALU_BCLR;
   parameter ALU_BSET = `k68_ALU_BSET;
   parameter ALU_MOV = `k68_ALU_MOV;
   parameter ALU_DIV = `k68_ALU_DIV;
   parameter ALU_MUL = `k68_ALU_MUL;
   parameter ALU_ASX = `k68_ALU_ASX;
   parameter ALU_LSX = `k68_ALU_LSX;
   parameter ALU_ROX = `k68_ALU_ROX;
   parameter ALU_ROXX = `k68_ALU_ROXX;
   parameter ALU_NOT = `k68_ALU_NOT;
   parameter ALU_NOP = `k68_ALU_NOP;
   parameter ALU_NEGX = `k68_ALU_NEGX;
   parameter ALU_NEG = `k68_ALU_NEG;
    
   parameter ALU_ANDSR = `k68_ALU_ANDSR;
   parameter ALU_ORSR = `k68_ALU_ORSR;
   parameter ALU_EORSR = `k68_ALU_EORSR;
   parameter ALU_MOVSR = `k68_ALU_MOVSR;

   parameter ALU_BCC = `k68_ALU_BCC;
   parameter ALU_DBCC = `k68_ALU_DBCC;
   parameter ALU_SCC = `k68_ALU_SCC;
   parameter ALU_SWAP = `k68_ALU_SWAP;
   parameter ALU_STOP = `k68_ALU_STOP;

   parameter ALU_VECTOR = `k68_ALU_VECTOR;
   parameter ALU_TAS = `k68_ALU_TAS;
   parameter ALU_TST = `k68_ALU_TST;
   parameter ALU_EA = `k68_ALU_EA;
   parameter ALU_CMP = `k68_ALU_CMP;
      
   output [dw-1:0] res_o;
   output [7:0]    ccr_o, ssr_o;
   output [kw-1:0] add_c_o;
   output [lw-1:0] alu_o;
   output [1:0]    siz_o;
   reg [1:0] 	   siz_o;
      
   input 	   clk_i, rst_i;
   input [lw-1:0]  alu_i;
   input [dw-1:0]  src_i, dst_i;
   input [kw-1:0]  add_src_i, add_dst_i;
   input [1:0] 	   siz_i;
   input [aw-1:0]  pc_i;
   input [2:0] 	   int_i;
   output [aw-1:0] pc_o;
   input [1:0] 	   skip_i;
        
   reg [dw-1:0]    res_o;
   reg [sw-1:0]    ccr_o, ssr_o;
   reg [kw-1:0]    add_c_o, add_c;
   reg [lw-1:0]    alu_o, alu;
   reg [aw-1:0]    pc_o, pc;
   reg [dw-1:0]    src,dst;
   reg [dw-1:0]	   res;

   wire [7:0] 	   d2ba,d2bb,b2d;
   wire 	   flag;
   reg [7:0] 	   bcd;
   wire [dw-1:0]   res_rox,res_lsx,res_asx,res_roxx;
   wire 	   x;
   reg 		   c;
     
            
   //
   // Sync Output
   // res_o, add_c_o, ccr_o, ssr_o;
   //
   always @ (posedge clk_i) begin
      if (rst_i) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 add_c_o <= 0;
	 alu_o <= 0;
	 ccr_o <= 0;
	 pc_o <= 0;
	 res_o <= 0;
	 siz_o <= 0;
	 ssr_o <= 0;
	 // End of automatics
	 
	 ssr_o <= ssr;
	 ccr_o <= ccr;
	 
      end else begin

	 pc_o <= pc_i+{skip_i,1'b0};
	 alu_o <= alu;
	 add_c_o <= add_c;
	 siz_o <= siz_i;
	 
	 // 
	 // Modify CCR
	 //
	 case (alu_i)
	   ALU_ABCD, ALU_SBCD, ALU_NBCD: begin
	      ccr_o[XF] <= c;
	      ccr_o[NF] <= 1'bX;
	      ccr_o[ZF] <= (res[31:0] == zero) & ccr_o[ZF];
	      ccr_o[VF] <= 1'bx;
	      ccr_o[CF] <= c;
	   end
	   ALU_ADD: begin
	      ccr_o[XF] <= src[31] & dst[31] | ~res[31] & dst[31] | src[31] & ~res[31];
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0] == zero);
	      ccr_o[VF] <= src[31] & dst[31] & ~res[31] | ~src[31] & ~dst[31] & res[31];
	      ccr_o[CF] <= src[31] & dst[31] | ~res[31] & dst[31] | src[31] & ~res[31];
	   end
	   ALU_ADDX: begin
	      ccr_o[XF] <= src[31] & dst[31] | ~res[31] & dst[31] | src[31] & ~res[31];
	      ccr_o[NF] <= ccr_o[NF];
	      ccr_o[ZF] <= (res[31:0] == zero) & ccr_o[ZF];
	      ccr_o[VF] <= src[31] & dst[31] & ~res[31] | ~src[31] & ~dst[31] & res[31];
	      ccr_o[CF] <= src[31] & dst[31] | ~res[31] & dst[31] | src[31] & ~res[31];
	   end
	   ALU_MOV,ALU_AND,ALU_EOR,ALU_OR,ALU_NOT,ALU_TAS,ALU_TST: begin
	      ccr_o[XF] <= ccr_o[XF];
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0] == zero);
	      ccr_o[VF] <= 1'b0;
	      ccr_o[CF] <= 1'b0;
	   end
	   ALU_SUB: begin
	      ccr_o[XF] <= src[31] & ~dst[31] | res[31] & ~dst[31] | src[31] & res[31];
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0] == zero);
	      ccr_o[VF] <= ~src[31] & dst[31] & ~res[31] | src[31] & ~dst[31] & res[31];
	      ccr_o[CF] <= src[31] & ~dst[31] | res[31] & ~dst[31] | src[31] & res[31];
	   end
	   ALU_SUBX: begin
	      ccr_o[XF] <= src[31] & ~dst[31] | res[31] & ~dst[31] | src[31] & res[31];
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0] == zero) & ccr_o[ZF];
	      ccr_o[VF] <= ~src[31] & dst[31] & ~res[31] | src[31] & ~dst[31] & res[31];
	      ccr_o[CF] <= src[31] & ~dst[31] | res[31] & ~dst[31] | src[31] & res[31];
	   end
	   ALU_CMP: begin
	      ccr_o[XF] <= ccr_o[XF];
	      ccr_o[NF] <= res[31];
	      ccr_o[XF] <= (res[31:0] == zero);
	      ccr_o[VF] <= ~src[31] & dst[31] & ~res[31] | src[31] & ~dst[31] & res[31];
	      ccr_o[CF] <= src[31] & ~dst[31] | res[31] & ~dst[31] | src[31] & res[31];
	   end
`ifdef k68_DIVX
	   ALU_DIV: begin
	      ccr_o[XF] <= ccr_o[XF];
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0]==zero);
	      ccr_o[VF] <= c;
	      ccr_o[CF] <= 1'b0;
	   end
`endif	   	   
`ifdef k68_MULX
	   ALU_MUL: begin
	      ccr_o[XF] <= ccr_o[XF];
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0]==zero);
	      ccr_o[VF] <= c;
	      ccr_o[CF] <= 1'b0;
	   end
`endif
	   ALU_NEG: begin
	      ccr_o[XF] <= dst[31] | res[31];
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0] == zero);
	      ccr_o[VF] <= dst[31] & res[31];
	      ccr_o[CF] <= dst[31] | res[31];
	   end
	   ALU_NEGX: begin
	      ccr_o[XF] <= dst[31] | res[31];
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0] == zero) & ccr_o[ZF];
	      ccr_o[VF] <= dst[31] & res[31];
	      ccr_o[CF] <= dst[31] | res[31];
	   end
	   ALU_BSET,ALU_BTST,ALU_BCLR,ALU_BCHG: begin
	      ccr_o[XF] <= ccr_o[XF];
	      ccr_o[NF] <= ccr_o[NF];
	      ccr_o[VF] <= ccr_o[VF];
	      ccr_o[CF] <= ccr_o[CF];
	      ccr_o[ZF] <= ~dst[src[28:24]];
	   end
	   ALU_ROX: begin
	      ccr_o[XF] <= ccr_o[XF];
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0] == zero);
	      ccr_o[VF] <= 1'b0;
	      ccr_o[CF] <= x;
	   end
`ifdef k68_LSX
	   ALU_LSX: begin
	      ccr_o[XF] <= x;
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0] == zero);
	      ccr_o[VF] <= 1'b0;
	      ccr_o[CF] <= x;
	   end
`endif
`ifdef k68_ROXX
	   ALU_ROXX: begin
	      ccr_o[XF] <= x;
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0] == zero);
	      ccr_o[VF] <= 1'b0;
	      ccr_o[CF] <= x;
	   end
`endif
`ifdef k68_ASX
	   ALU_ASX: begin
	      ccr_o[XF] <= x;
	      ccr_o[NF] <= res[31];
	      ccr_o[ZF] <= (res[31:0] == zero);
	      ccr_o[VF] <= 1'b0;
	      ccr_o[CF] <= x;
	   end
`endif
	   ALU_MOVSR: {ssr_o, ccr_o} <= res[31:16];
	   ALU_STOP: {ssr_o,ccr_o} <= src[15:0];
	   default: begin
	      ccr_o <= ccr_o;
	      ssr_o <= {ssr_o[7:3],int_i};
	   end
	   
	 endcase // case(alu_i)

	 // ****************************************************
	 
	 // 
	 // Set res
	 //
	 case (siz_i)
	   2'b00: res_o <= {dst_i[31:8],res[31:24]}; // BYTE
	   2'b01: res_o <= {dst_i[31:16],res[31:16]}; // WORD
      	   default: res_o <= res[31:0]; // LONG
	   //default: res_o <= dst_i; // PASSTHROUGH
	 endcase // case(siz_i)
      end// else: !if(run_i)
    
   end

   //
   // Async Stuff, Actual ALU
   //
   always @ (/*AUTOSENSE*/add_c_o or add_dst_i or add_src_i or alu_i
	     or dst_i or res_o or rst_i or siz_i or src_i) begin
      if (rst_i) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 dst <= 0;
	 src <= 0;
	 // End of automatics
      end else begin
	 	 	 
	 // 
	 // Fit src and dst with Operand Forwarding & Special OP Ignore
	 //
	 case(alu_i)
	   ALU_ROX:
	     case (siz_i)
	       2'b00: begin // BYTE
		  src <= {src_i[7:0],src_i[7:0],src_i[7:0],src_i[7:0]};
		  if ((add_dst_i == add_c_o) && ~(add_c_o == 6'b111100) && ~(add_c_o == esc))
		    dst <= {res_o[7:0],res_o[7:0],res_o[7:0],res_o[7:0]};
		  else
		    dst <= {dst_i[7:0],dst_i[7:0],dst_i[7:0],dst_i[7:0]};
	       end
	       2'b01: begin // WORD
		  src <= {src_i[15:0],src_i[15:0]};
		  if ((add_dst_i == add_c_o) && ~(add_c_o == 6'b111100) && ~(add_c_o == esc))
		    dst <= {res_o[15:0],res_o[15:0]};
		  else
		    dst <= {dst_i[15:0],dst_i[15:0]};
	       end
	       default: begin // LONG
		  src <= src_i;
		  if ((add_dst_i == add_c_o) && ~(add_c_o == 6'b111100) && ~(add_c_o == esc))
		    dst <= res_o;
		  else
		    dst <= dst_i;
	       end
	     endcase // case(siz_i)
	   
	   default:
	     case (siz_i)
	       2'b00: begin // BYTE
		  if ((add_src_i == add_c_o) && ~(add_c_o == 6'b111100) && ~(add_c_o == esc))
		    src <= {res_o[7:0],24'd0};
		  else
		    src <= {src_i[7:0],24'd0};
		  if ((add_dst_i == add_c_o) && ~(add_c_o == 6'b111100) && ~(add_c_o == esc))
		    dst <= {res_o[7:0],24'd0};
		  else
		    dst <= {dst_i[7:0],24'd0};
	       end
	       2'b01: begin // WORD
		  if ((add_src_i == add_c_o) && ~(add_c_o == 6'b111100) && ~(add_c_o == esc))
		    src <= {res_o[15:0],16'd0};
		  else
		    src <= {src_i[15:0],16'd0};
		  if ((add_dst_i == add_c_o) && ~(add_c_o == 6'b111100) && ~(add_c_o == esc))
		    dst <= {res_o[15:0],16'd0};
		  else
		    dst <= {dst_i[15:0],16'd0};
	       end
	       default: begin // LONG
		  if ((add_src_i == add_c_o) && ~(add_c_o == 6'b111100) && ~(add_c_o == esc))
		    src <= res_o;
		  else
		    src <= src_i;
		  if ((add_dst_i == add_c_o) && ~(add_c_o == 6'b111100) && ~(add_c_o == esc))
		    dst <= res_o;
		  else
		    dst <= dst_i;
	       end
	     endcase // case(siz_i)
	 endcase // case(alu_i)

      end // else: !if(rst_i)
   end // always @ (...


   
   always @(/*AUTOSENSE*/add_dst_i or add_src_i or alu_i or b2d
	    or ccr_o or d2ba or d2bb or dst or flag or pc_i or res_asx
	    or res_lsx or res_rox or res_roxx or rst_i or src or ssr_o) begin
      if (rst_i) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 add_c <= 0;
	 alu <= 0;
	 bcd <= 0;
	 c <= 0;
	 pc <= 0;
	 res <= 0;
	 // End of automatics
      end else begin
	 // ***************************************************

	 alu <= alu_i;
	 pc <= pc_i;
	 //add_c <= add_dst_i;
	 
	 // 
	 // Modify results... Actual Execution
	 //
	 case (alu_i)
	   
	   // ARITHMETIC
	   ALU_ADD: begin
	      res <= src + dst;//res_a;
	      add_c <= add_dst_i;
	   end
	   ALU_SUB: begin
	      res <= dst - src;
	      add_c <= add_dst_i;
	   end
`ifdef k68_MULX
	   ALU_MUL: begin
	      res <= dst;
	      add_c <= add_dst_i;
	   end
`endif
`ifdef k68_DIVX
	   ALU_DIV: begin
	      res <= dst;
	      add_c <= add_dst_i;
	   end
`endif
	   ALU_NEG: begin
	      res <= zero - dst;
	      add_c <= add_dst_i;
	   end
	   ALU_ADDX: begin
	      res <= src + dst + ccr_o[XF];
	      add_c <= add_dst_i;
	   end
	   ALU_SUBX: begin
	      res <= dst - src - ccr_o[XF];
	      add_c <= add_dst_i;
	   end

	   ALU_NEGX: begin
	      res <= zero - dst - ccr_o[XF];
	      add_c <= add_dst_i;
	   end

	   // Compare
	   ALU_CMP: begin
	      res <= dst - src;
	      add_c <= esc;
	   end
	   	   
	   // BCDS
	   ALU_ABCD: begin
	      {res[31:0]} <= {b2d, 24'd0};
	      {c,bcd} <= d2ba + d2bb + ccr_o[XF];
	      add_c <= add_dst_i;
	   end
 	   ALU_SBCD: begin
	      {res[31:0]} <= {b2d, 24'd0};
	      {c,bcd} <= d2bb - d2ba - ccr_o[XF];
	      add_c <= add_dst_i;
	   end
	   ALU_NBCD: begin
	      {res[31:0]} <= {b2d, 24'd0};
	      {c,bcd} <= 8'd0 - d2bb - ccr_o[XF];
	      add_c <= add_dst_i;
	   end

	   // SHIFTS
`ifdef k68_ASX
	   ALU_ASX: begin
	      res <= res_asx;
	      add_c <= add_dst_i;
	   end
`endif
`ifdef k68_LSX
	   ALU_LSX: begin
	      res <= res_lsx;
	      add_c <= add_dst_i;
	   end
`endif
`ifdef k68_ROXX
	   ALU_ROXX: begin
	      res <= res_roxx;
	      add_c <= add_dst_i;
	   end
`endif
	   ALU_ROX: begin
	      res <= res_rox;
	      add_c <= add_dst_i;
	   end
      
	   // LOGICS
	   ALU_AND: begin
	      res <= dst & src;
	      add_c <= add_dst_i;
	   end
	   ALU_OR: begin
	      res <= dst | src;
	      add_c <= add_dst_i;
	   end
	   ALU_EOR: begin
	      res <= dst ^ src;
	      add_c <= add_dst_i;
	   end
	   ALU_NOT: begin
	      res <= ~dst;
	      add_c <= add_dst_i;
	   end

	   // SSR CCR
	   ALU_ANDSR: begin
	      res <= {ssr_o,ccr_o,16'd0} & src;
	      add_c <= add_dst_i;
	   end
	   ALU_ORSR: begin
	      res <= {ssr_o,ccr_o,16'd0} | src;
	      add_c <= add_dst_i;
	   end
	   ALU_EORSR: begin
	      res <= {ssr_o,ccr_o,16'd0} ^ src;
	      add_c <= add_dst_i;
	   end
	   ALU_MOVSR: begin
	      if(add_dst_i==6'h3C)
		res <= { (ssr_o & dst[31:24]) | src[31:24] , src[23:16], 16'd0};
	      else
		res <= {ssr_o, ccr_o, 16'd0};
	      add_c <= add_dst_i;
	   end
	   	   
	   // MOVS	   
	   ALU_MOV: begin
	      res <= src;
	      add_c <= add_dst_i;
	   end

	   // BIT TESTS
	   ALU_BCHG: begin
	      res <= dst;
	      res[src[28:24]] <= ~dst[src[28:24]];
	      add_c <= add_dst_i;
	      
	   end
	   ALU_BCLR: begin
	      res <= dst;
	      res[src[28:24]] <= 1'b0;
	      add_c <= add_dst_i;
	      
	   end
	   ALU_BSET: begin
	      res <= dst;
	      res[src[28:24]] <= 1'b1;
	      add_c <= add_dst_i;
	   end
	   ALU_BTST: begin
	      res <= dst;
	      add_c <= 6'h3C;
	   end
	   	

	   
	   // BCC DBCC SCC
	   ALU_BCC:
	      case(flag)
		1'b1: begin
		   res <= src + dst;
		   add_c <= add_dst_i;
		end 
		default: begin
		   res <= zero;
		   add_c <= esc;
		end
	      endcase // case(flag)

	   ALU_SCC:
	     case (flag)
	       1'b1: begin
		  res <= 32'hFFFFFFFF;
		  add_c <= add_dst_i;
	       end
	       default: begin
		  res <= zero;
		  add_c <= add_dst_i;
	       end
	     endcase // case(flag)

//	   ALU_DBCC:
//	     case (flag)
//	       1'b1: begin
//		  res <= dst;
//		  add_c <= 6'h3C;
//		  alu <= ALU_NOP;
//	       end
//	       default: begin
//		  res <= dst - 1'b1;
//		  add_c <= 6'h3C;
//		  case (res[15:0])
//		    16'hFFFF: begin
//		       pc <= pc_i + src_i;
//		       alu <= ALU_DBCC;
//		    end
//		    default: begin
//		       pc <= add_dst_i;
//		       alu <= ALU_SCC;
//		    end
//		  endcase // case(res[15:0])
//	       end
//	     endcase // case(flag)


	   // MISC
	   ALU_SWAP: begin
	      res <= {dst[15:0],dst[31:16]};
	      add_c <= add_dst_i;
	   end

	   ALU_STOP: begin
	      res <= dst - 2'b10;
	      add_c <= 6'h3C;
	   end

	   ALU_VECTOR: begin
	      case (add_src_i)
		6'h3C: begin
		   add_c <= 6'h3C;
		   res <= ((src[5:0] + dst[5:0]) << 2) | 1'b1;
		end
		default: 
		  if (ccr_o[VF])  begin
		       add_c <= 6'h3C;
		       res <= ((src[5:0] + dst[5:0]) << 2) | 1'b1;
		    end else begin
		       add_c <= ALU_NOP;
		       res <= zero;
		    end
	      endcase // case(add_src_i)
	   end

	   ALU_TAS: begin
	      res <= {1'b1, dst[30:0]};
	      add_c <= add_dst_i;
	   end
	   
	   ALU_TST: begin
	      res <= dst;
	      add_c <= add_dst_i;
	   end
	   	
	   ALU_EA: begin
	      res <= dst;
	      add_c <= add_dst_i;
	   end
	   
	   default: begin
	      res <= zero;
	      add_c <= add_c;
	   end
	   
	 endcase // case(alu_i)

	 // ****************************************************

      end
      
      
   end

   // 
   // Instantiate Functions Blocks
   // Shifters, Multipliers, Converters
   //

   /********************************************************
    *******************************************************
    * *****************************************************/


   //
   // Shifters
   //
   k68_rox rox0(
		.step(src[5:0]),
		.in(dst),
		.res(res_rox)
		);

`ifdef k68_ASX
   k68_asx asx0(
		.step(src[5:0]),
		.in(dst),
		.res(res_asx)
		);
`endif
`ifdef k68_LSX
   k68_lsx lsx0(
		.step(src[5:0]),
		.in(dst),
		.res(res_lsx)
		);
`endif
`ifdef k68_ROXX
   k68_rox roxx0(
		.step(src[5:0]),
		.in(dst),
		.xin(ccr_o[XF]),
		.res(res_roxx)
		);
`endif

   // 
   // K68 Multiplier. Instantiate your own hardware
   // multiplier here. It must be single cycle operation
   // 
`ifdef k68_MULX
`endif

   //
   // K68 Divider. Instantiate your own hardware
   // divider here. It must be single cycle operation
   //
`ifdef k68_DIVX
`endif
         
   //
   //  BCD Convertors
   //
   k68_d2b d2b0(
		.d(src[31:24]),
		.b(d2ba)
		);
   
   k68_d2b d2b1(
		.d(dst[31:24]),
		.b(d2bb)
		);
   
   k68_b2d b2d0(
		.b(bcd),
		.d(b2d)
		);
   

   //
   // Conditional Code Checker for Xcc kind of instructions
   //
   k68_ccc ccc0(
		.cc(ccr_o),
		.code(add_src_i[3:0]),
		.flag(flag)
		);
   
   
endmodule // k68_execute

