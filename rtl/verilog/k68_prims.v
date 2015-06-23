//                              -*- Mode: Verilog -*-
// Filename        : k68_prims.v
// Description     : RISC ALU blocks
// Author          : Shawn Tan
// Created On      : Sun Feb  9 00:06:41 2003
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
  
//
// 1 CLK 32bit ROX Shifter
//
module k68_rox (/*AUTOARG*/
   // Outputs
   res, 
   // Inputs
   in, step
   ) ;
   parameter dw = `k68_DATA_W;
   
   output [dw-1:0] res;
   input [dw-1:0] in;
   input [5:0] 	  step;
   reg [dw-1:0] 	  res;
   reg [4:0] 		  move;
   
   always @ ( /*AUTOSENSE*/step) begin
      if (step[5]) 
	move <= 6'd32 - step[4:0];
      else
	move <= step[4:0];
   end
   	     
   always @ ( /*AUTOSENSE*/in or move) begin
      //
      // Barrel Shift
      //
      case (move)
	5'd01: res <= {in[30:0],in[31]};
	5'd02: res <= {in[29:0],in[31:30]};
	5'd03: res <= {in[28:0],in[31:29]};
	5'd04: res <= {in[27:0],in[31:28]};
	5'd05: res <= {in[26:0],in[31:27]};
	5'd06: res <= {in[25:0],in[31:26]};
	5'd07: res <= {in[24:0],in[31:25]};
	5'd08: res <= {in[23:0],in[31:24]};
	5'd09: res <= {in[22:0],in[31:23]};
	5'd10: res <= {in[21:0],in[31:22]};
	5'd11: res <= {in[20:0],in[31:21]};
	5'd12: res <= {in[19:0],in[31:20]};
	5'd13: res <= {in[18:0],in[31:19]};
	5'd14: res <= {in[17:0],in[31:18]};
	5'd15: res <= {in[16:0],in[31:17]};
	5'd16: res <= {in[15:0],in[31:16]};
	5'd17: res <= {in[14:0],in[31:15]};
	5'd18: res <= {in[13:0],in[31:14]};
	5'd19: res <= {in[12:0],in[31:13]};
	5'd20: res <= {in[11:0],in[31:12]};
	5'd21: res <= {in[10:0],in[31:11]};
	5'd22: res <= {in[9:0],in[31:10]};
	5'd23: res <= {in[8:0],in[31:9]};
	5'd24: res <= {in[7:0],in[31:8]};
	5'd25: res <= {in[6:0],in[31:7]};
	5'd26: res <= {in[5:0],in[31:6]};
	5'd27: res <= {in[4:0],in[31:5]};
	5'd28: res <= {in[3:0],in[31:4]};
	5'd29: res <= {in[2:0],in[31:3]};
	5'd30: res <= {in[1:0],in[31:2]};
	5'd31: res <= {in[0],in[31:1]};
	default: res <= {in[31:0]};
	
      endcase // case(step)
   end

endmodule // k68_barrel
  
//
// 1 CLK 32bit ROX Shifter
//
module k68_roxx (/*AUTOARG*/
   // Outputs
   res, 
   // Inputs
   in, xin, step
   ) ;
   parameter dw = `k68_DATA_W;
   
   output [dw:0] res;
   input [dw-1:0] in;
   input 	xin;
   input [6:0] 	step;
   reg [dw:0] res;
   reg [5:0] 	move;
   
   always @ ( /*AUTOSENSE*/step) begin
      if (step[6]) 
	move <= 6'd33 - step[5:0];
      else
	move <= step[5:0];
   end
   	     
   always @ ( /*AUTOSENSE*/in or move or xin) begin
      //
      // Barrel Shift
      //
      case (move)
	6'd01: res <= {in[30:0],xin,in[31]};
	6'd02: res <= {in[29:0],xin,in[31:30]};
	6'd03: res <= {in[28:0],xin,in[31:29]};
	6'd04: res <= {in[27:0],xin,in[31:28]};
	6'd05: res <= {in[26:0],xin,in[31:27]};
	6'd06: res <= {in[25:0],xin,in[31:26]};
	6'd07: res <= {in[24:0],xin,in[31:25]};
	6'd08: res <= {in[23:0],xin,in[31:24]};
	6'd09: res <= {in[22:0],xin,in[31:23]};
	6'd10: res <= {in[21:0],xin,in[31:22]};
	6'd11: res <= {in[20:0],xin,in[31:21]};
	6'd12: res <= {in[19:0],xin,in[31:20]};
	6'd13: res <= {in[18:0],xin,in[31:19]};
	6'd14: res <= {in[17:0],xin,in[31:18]};
	6'd15: res <= {in[16:0],xin,in[31:17]};
	6'd16: res <= {in[15:0],xin,in[31:16]};
	6'd17: res <= {in[14:0],xin,in[31:15]};
	6'd18: res <= {in[13:0],xin,in[31:14]};
	6'd19: res <= {in[12:0],xin,in[31:13]};
	6'd20: res <= {in[11:0],xin,in[31:12]};
	6'd21: res <= {in[10:0],xin,in[31:11]};
	6'd22: res <= {in[9:0],xin,in[31:10]};
	6'd23: res <= {in[8:0],xin,in[31:9]};
	6'd24: res <= {in[7:0],xin,in[31:8]};
	6'd25: res <= {in[6:0],xin,in[31:7]};
	6'd26: res <= {in[5:0],xin,in[31:6]};
	6'd27: res <= {in[4:0],xin,in[31:5]};
	6'd28: res <= {in[3:0],xin,in[31:4]};
	6'd29: res <= {in[2:0],xin,in[31:3]};
	6'd30: res <= {in[1:0],xin,in[31:2]};
	6'd31: res <= {in[0],xin,in[31:1]};
	6'd32: res <= {xin,in[31:0]};
	default: res <= {in[31:0],xin};
	
      endcase // case(step)
   end

endmodule // k68_barrel

//
// 1 CLK 32bit LSX Shifter
//
module k68_lsx (/*AUTOARG*/
   // Outputs
   res, 
   // Inputs
   in, step
   ) ;
   parameter dw = `k68_DATA_W;
   
   output [dw-1:0] res;
   input [dw-1:0] in;
   input [5:0] 	  step;
   reg [dw-1:0] 	  res;
  
   always @ ( /*AUTOSENSE*/in or step) begin
      if (step[5])
	res <= in >> step[4:0];
      else
	res <= in << step[4:0];
   end
   

endmodule // k68_barrel

//
// 1 CLK 32bit ASX Shifter
//
module k68_asx (/*AUTOARG*/
   // Outputs
   res, 
   // Inputs
   in, step
   ) ;
   parameter dw = `k68_DATA_W;
   
   output [dw-1:0] res;
   input [dw-1:0] in;
   input [5:0] 	  step;
   reg [dw-1:0] 	  res;
  
   always @ ( /*AUTOSENSE*/in or step) begin
      if (step[5])
	if (in[31])
	  case (step[4:0])
	    5'd01: res <= {1'b1,in[31:1]};
	    5'd02: res <= {2'b11,in[31:2]};
	    5'd03: res <= {3'b111,in[31:3]};
	    5'd04: res <= {4'b1111,in[31:4]};
	    5'd05: res <= {5'b11111,in[31:5]};
	    5'd06: res <= {6'b111111,in[31:6]};
	    5'd07: res <= {7'b1111111,in[31:7]};
	    5'd08: res <= {8'b11111111,in[31:8]};
	    5'd09: res <= {9'b111111111,in[31:9]};
	    5'd10: res <= {10'b1111111111,in[31:10]};
	    5'd11: res <= {11'b11111111111,in[31:11]};
	    5'd12: res <= {12'b111111111111,in[31:12]};
	    5'd13: res <= {13'b1111111111111,in[31:13]};
	    5'd14: res <= {14'b11111111111111,in[31:14]};
	    5'd15: res <= {15'b111111111111111,in[31:15]};
	    5'd16: res <= {16'b1111111111111111,in[31:16]};
	    5'd17: res <= {17'b11111111111111111,in[31:17]};
	    5'd18: res <= {18'b111111111111111111,in[31:18]};
	    5'd19: res <= {19'b1111111111111111111,in[31:19]};
	    5'd20: res <= {20'b11111111111111111111,in[31:20]};
	    5'd21: res <= {21'b111111111111111111111,in[31:21]};
	    5'd22: res <= {22'b1111111111111111111111,in[31:22]};
	    5'd23: res <= {23'b11111111111111111111111,in[31:23]};
	    5'd24: res <= {24'b111111111111111111111111,in[31:24]};
	    5'd25: res <= {25'b1111111111111111111111111,in[31:25]};
	    5'd26: res <= {26'b11111111111111111111111111,in[31:26]};
	    5'd27: res <= {27'b111111111111111111111111111,in[31:27]};
	    5'd28: res <= {28'b1111111111111111111111111111,in[31:28]};
	    5'd29: res <= {29'b11111111111111111111111111111,in[31:29]};
	    5'd30: res <= {30'b111111111111111111111111111111,in[31:30]};
	    5'd31: res <= {31'b1111111111111111111111111111111,in[31]};
	    default: res <= in;
	  endcase // case(step[4:0])
	else
	  res <= in >> step[4:0];
      else
	res <= in << step[4:0];
   end
   

endmodule // k68_barrel

//
// 1 CLK 34bit Parallel Multiplier
//
module k68_par_mul (/*AUTOARG*/
   // Outputs
   res, 
   // Inputs
   src, dst
   ) ;
   parameter dw = `k68_DATA_W;

   output [dw:0] res;
   input [dw/2-1:0] src,dst;

         
endmodule // k68_par_mul

//
// 1 CLK 32bit Adder
//
module k68_adder (/*AUTOARG*/
   // Outputs
   res, 
   // Inputs
   src, dst
   ) ;
   parameter dw = `k68_DATA_W;

   output [dw:0] res;
   input [dw-1:0] src, dst;
   reg [dw:0] 	  res;

   always @(/*AUTOSENSE*/dst or src) begin
      res <= src + dst;
   end
      
endmodule // k68_adder

//
// CC Condition Calc
//
module k68_ccc(/*AUTOARG*/
   // Outputs
   flag, 
   // Inputs
   cc, code
   );

   parameter XF = `k68_X_FLAG;
   parameter CF = `k68_C_FLAG;
   parameter NF = `k68_N_FLAG;
   parameter ZF = `k68_Z_FLAG;
   parameter VF = `k68_V_FLAG;
      
   input [7:0] cc;
   input [3:0] code;
   output      flag;
   reg 	       flag;

   always @(/*AUTOSENSE*/cc or code) begin
      case (code)
	4'h4: flag <= ~cc[CF];
	4'h5: flag <= cc[CF];
	4'h7: flag <= cc[ZF];
	4'hC: flag <= cc[NF] & cc[VF] | ~cc[NF] & ~cc[VF];
	4'hE: flag <= cc[NF] & cc[VF] & ~cc[ZF] | ~cc[NF] & ~cc[VF] & ~cc[ZF];
	4'h2: flag <= ~cc[CF] & ~cc[ZF];
	4'hF: flag <= cc[ZF] | cc[NF] & ~cc[VF] | ~cc[NF] & cc[VF];
	4'h3: flag <= cc[CF] | cc[ZF];
	4'hD: flag <= cc[NF] & ~cc[VF] | ~cc[NF] & cc[VF];
	4'hB: flag <= cc[NF];
	4'h6: flag <= ~cc[ZF];
	4'hA: flag <= ~cc[NF];
	4'h8: flag <= ~cc[VF];
	4'h9: flag <= cc[VF];
	4'h1: flag <= 1'b0;
	4'h0: flag <= 1'b1;
	//default: flag <= 1'b0;
      endcase // case(code)
   end
   
endmodule // k68_ccc

//
// BCD CONVERTER
//
module k68_d2b(/*AUTOARG*/
   // Outputs
   b, 
   // Inputs
   d
   );
   parameter dw = `k68_DATA_W;
   input [7:0] d;
   output [7:0] b;
   reg [7:0] 	b;

   always @ ( /*AUTOSENSE*/d) begin

      if (d[7:4] >= 4'd5)
	b[7:4] <= d[7:4] + 2'd3;
      else
	b[7:4] <= d[7:4];

      if (d[3:0] >= 4'd5)
	b[3:0] <= d[3:0] + 2'd3;
      else
	b[3:0] <= d[3:0];
            
   end
     
   
endmodule // k68_d2b

//
// BCD CONVERTER
//
module k68_b2d(/*AUTOARG*/
   // Outputs
   d, 
   // Inputs
   b
   );
   parameter dw = `k68_DATA_W;
   input [7:0] b;
   output [7:0] d;
   reg [7:0] 	d;

   always @ ( /*AUTOSENSE*/b) begin

      if (b[7:4] >= 4'd5)
	d[7:4] <= b[7:4] - 2'd3;
      else
	d[7:4] <= b[7:4];

      if (b[3:0] >= 4'd5)
	d[3:0] <= b[3:0] - 2'd3;
      else
	d[3:0] <= b[3:0];
            
   end
   
      
endmodule // k68_b2d
 