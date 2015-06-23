//                              -*- Mode: Verilog -*-
// Filename        : oks8_prims.v
// Description     : OKS8 Basic Types and Units
//					 *** Most from ae18_prims.v, See AE18 on OPENCORES ***
// Author          : Shawn Tan
// Created On      : Wed Jul 30 20:24:29 2003
// Last Modified By: Jian Li
// Last Modified On: Sat Jan 07 09:09:49 2006
// Update Count    : 2
// Status          : Unknown, Use with caution!

/*
 * Copyright (C) 2003 to Shawn Tan Ser Ngiap. Aeste Works (M) Sdn Bhd.
 * Contact: shawn.tan@aeste.net
 * Copyright (C) 2006 to Jian Li
 * Contact: kongzilee@yahoo.com.cn
 * 
 * This source file may be used and distributed without restriction
 * provided that this copyright statement is not removed from the file
 * and that any derivative works contain the original copyright notice
 * and the associated disclaimer.
 * 
 * THIS SOFTWARE IS PROVIDE "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
 * SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

`include "oks8_defines.v"

// =====================================================================
// OKS8_AND
// =====================================================================

module oks8_and (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw-1:0]  c_o;
   assign 	    c_o = a_i & b_i;
   
endmodule // oks8_and

// =====================================================================
// OKS8_IOR
// =====================================================================

module oks8_ior (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw-1:0] c_o;
   assign 	   c_o = a_i | b_i;
   
endmodule // oks8_ior

// =====================================================================
// OKS8_XOR
// =====================================================================

module oks8_tcm (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw-1:0]  c_o;
   assign 	    c_o = (~a_i) & b_i;
   
endmodule // oks8_tcm

module oks8_tcm2 (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw-1:0]  c_o;
   assign 	    c_o = a_i & (~b_i);
   
endmodule // oks8_tcm2

// =====================================================================
// OKS8_XOR
// =====================================================================

module oks8_xor (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw-1:0]  c_o;
   assign 	    c_o = a_i ^ b_i;
   
endmodule // oks8_xor

// =====================================================================
// OKS8_ADD
// adder
// =====================================================================

module oks8_add (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw:0]  c_o;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [dw:0]		c_o;
   // End of automatics
   
   always @(/*AUTOSENSE*/a_i or b_i)
     c_o <= a_i + b_i;
   
endmodule // oks8_add

module oks8_adc (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i, c_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   input 	  c_i;
   output [dw:0]  c_o;
   reg [dw:0] 	  c_o;
   always @(/*AUTOSENSE*/a_i or b_i or c_i)
     c_o <= a_i + b_i + c_i;
   
endmodule // oks8_adc

// =====================================================================
// OKS8_SUB
// Subtractor
// =====================================================================

module oks8_sub (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   output [dw:0]  c_o;
   reg [dw:0] 	  c_o;
   always @(/*AUTOSENSE*/a_i or b_i)
     c_o <= a_i - b_i;
   
endmodule // oks8_sub

module oks8_sbc (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i, b_i, c_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i,b_i;
   input 	  c_i;
   output [dw:0]  c_o;
   reg [dw:0] 	  c_o;
   always @(/*AUTOSENSE*/a_i or b_i or c_i)
     c_o <= a_i - b_i - c_i;
   
endmodule // oks8_sbc

// =====================================================================
// OKS8_RR
// 8Bit Barrel
// =====================================================================

module oks8_rr (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i;
   output [dw:0]  c_o;
   assign 	    c_o = {a_i[0],a_i[0],a_i[dw-1:1]};
   
endmodule // oks8_rr

// =====================================================================
// OKS8_RRC
// 9Bit Barrel
// =====================================================================
module oks8_rrc (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i
   ) ;
   parameter dw = `W_DATA;
   input [dw:0] a_i;
   output [dw:0]  c_o;
   assign 	  c_o = {a_i[0],a_i[dw:1]};
   
endmodule // oks8_rrc

// =====================================================================
// OKS8_RL
// 8Bit Barrel
// =====================================================================
module oks8_rl (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i;
   output [dw:0]  c_o;
   assign 	    c_o = {a_i[dw-1],a_i[dw-2:0],a_i[dw-1]};
   
endmodule // oks8_rl

// =====================================================================
// OKS8_RLC
// 9Bit Barrel
// =====================================================================

module oks8_rlc (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i
   ) ;
   parameter dw = `W_DATA;
   input [dw:0] a_i;
   output [dw:0]  c_o;
   assign 	  c_o = {a_i[dw-1:0],a_i[dw]};
   
endmodule // oks8_rlc

// =====================================================================
// OKS8_SRA
// 9Bit Barrel
// =====================================================================

module oks8_sra (/*AUTOARG*/
   // Outputs
   c_o, 
   // Inputs
   a_i
   ) ;
   parameter dw = `W_DATA;
   input [dw-1:0] a_i;
   output [dw:0]  c_o;
   assign 	  c_o = {a_i[0],a_i[dw-1],a_i[dw-1],a_i[dw-2:1]};
   
endmodule // oks8_sra
