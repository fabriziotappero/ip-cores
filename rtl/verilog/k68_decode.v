//                              -*- Mode: Verilog -*-
// Filename        : k68_decode.v
// Description     : RISC 68K decoder
// Author          : Shawn Tan
// Created On      : Sat Feb  8 08:38:45 2003
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

module k68_decode (/*AUTOARG*/
   // Outputs
   alu_o, src_o, dst_o, skip_o, brch_o, pc_o, alu_pc_o, c_siz_o, 
   imm_o, add_a_o, add_b_o, add_c_o, add_src_o, add_dst_o, dat_c_o, 
   siz_o, siz_a_o, 
   // Inputs
   clk_i, rst_i, pc_i, op_i, imm_i, alu_i, res_i, alu_pc_i, siz_i, 
   add_c_i, dat_a_i, dat_b_i, dat_c_i, skip_i
   ) ;
   
   parameter dw=`k68_DATA_W;
   parameter aw=`k68_ADDR_W;
   parameter nop = `k68_OP_NOP;
   parameter zero= `ZERO;
   parameter xxxx= `XXXX;
   parameter ow = `k68_OP_W;
   parameter lw = `k68_ALU_W;
   parameter sw = `k68_SCR_W;
   parameter gw = `k68_GPR_W;
   parameter kw = 6;
   parameter esc = `ESC;
   parameter reset = `k68_RST_VECTOR;
            
   // FLAGS
   parameter zf = `k68_Z_FLAG;
   parameter cf = `k68_C_FLAG;
   parameter vf = `k68_V_FLAG;
   parameter nf = `k68_N_FLAG;
   parameter xf = `k68_X_FLAG;
   
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
   
   parameter ALU_MOVSR = `k68_ALU_MOVSR;
   parameter ALU_ANDSR = `k68_ALU_ANDSR;
   parameter ALU_ORSR = `k68_ALU_ORSR;
   parameter ALU_EORSR = `k68_ALU_EORSR;

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
   
   // I/O
   input     clk_i,rst_i;
   input [aw-1:0] pc_i;     // PC for OP from FETCH
   input [ow-1:0] op_i;     // OP from FETCH
   input [dw-1:0] imm_i;    // IMM from FETCH
   input [lw-1:0] alu_i;    // ALUOP from EXEC
   output [lw-1:0] alu_o;   // ALUOP to EXEC
   output [dw-1:0] src_o, dst_o; // Source Operands to EXEC
   input [dw-1:0]  res_i;   // Result Operand from EXEC
   output [1:0]    skip_o;  // skip output to FETCH
   output          brch_o;  // Branch to FETCH
   output [aw-1:0] pc_o;    // PC to FETCH
   input [aw-1:0]  alu_pc_i;
   output [aw-1:0] alu_pc_o;
   input [1:0] 	   siz_i;
   output [1:0]    c_siz_o;
   reg [1:0] 	   c_siz_o;
   output [dw-1:0] imm_o;
      
   output [kw-1:0]    add_a_o, add_b_o, add_c_o, add_src_o, add_dst_o; // @modes
   input [kw-1:0]     add_c_i;
   input [dw-1:0]  dat_a_i, dat_b_i, dat_c_i;
   output [dw-1:0] dat_c_o;
   output [1:0]    siz_o,siz_a_o;
   input [1:0] 	   skip_i;
 
   reg [ow-1:0]    op;
   reg [lw-1:0]    alu_o;
   reg [dw-1:0]    src_o;
   reg [aw-1:0]    pc_o, alu_pc_o;
   reg 		   brch_o;
   reg [1:0] 	   skip_o, skip;
   reg [kw-1:0]    add_src_o, add_dst_o, add_a_o, add_b_o, add_c_o;
   reg [1:0] 	   siz_o, siz_a_o;
   reg [dw-1:0]	   dat_c_o;
   reg [dw-1:0]    imm_o;

   reg [dw-1:0]    src,dst_o;
   reg [lw-1:0]    alu;
   reg [1:0] 	   siz;
   reg [kw-1:0]    add_src, add_dst;
   reg 		   brch;

   //assign 	   dst_o = dat_b_i;
      
   //
   // Synchronous to EXECS
   // DECODE STAGE
   // src_o, dst_o, alu_o, add_src_o, add_dst_o, siz_o
   //
   always @ (posedge clk_i) begin
      
      if (rst_i || skip[0] || skip[1] || brch_o) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 add_dst_o <= 0;
	 add_src_o <= 0;
	 alu_o <= 0;
	 alu_pc_o <= 0;
	 brch <= 0;
	 dst_o <= 0;
	 siz_o <= 0;
	 skip <= 0;
	 skip_o <= 0;
	 src_o <= 0;
	 // End of automatics
	 
	 add_src_o <= esc;
	 add_dst_o <= esc;
	 skip <= skip_i;
	 brch <= brch_o;
	 
      end else begin // if (rst_i || skip[0] || skip[1] || brch_o)
	 
	 brch <= brch_o;
	 skip <= skip_i;
	 src_o <= src;
	 dst_o <= dat_b_i;
	 alu_o <= alu;
	 siz_o <= siz;
	 skip_o <= skip_i;
	 add_src_o <= add_src;
	 add_dst_o <= add_dst;
	 alu_pc_o <= pc_i;
	 
      end // else: !if(rst_i || skip[0] || skip[1] || brch_o)
      
   end // always @ (posedge clk_i)
   
   
   
   // ***************************************************************
   // ***************************************************************
   // ***************************************************************
   // ***************************************************************
   // ***************************************************************
   
   
   //
   // Async to @MODE
   // DECODE STAGE
   // add_a_o, add_b_o, siz_a_o, imm_o
   //
   always @(/*AUTOSENSE*/dat_a_i or dat_c_i or imm_i or op or op_i
	    or rst_i or skip) begin
      if (rst_i || skip[1] || skip[0]) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 add_a_o <= 0;
	 add_b_o <= 0;
	 add_dst <= 0;
	 add_src <= 0;
	 alu <= 0;
	 imm_o <= 0;
	 siz <= 0;
	 siz_a_o <= 0;
	 src <= 0;
	 // End of automatics
	 add_a_o <= esc;
	 add_b_o <= esc;

      end else begin // if (rst_i || skip[1] || skip[0])
	 
	 add_a_o <= esc;
	 add_b_o <= esc;
	 imm_o <= imm_i;
	 siz_a_o <= 2'd0;
	 alu <= 6'd0;
	 src <= zero;
	 //dst <= dat_b_i;
	 add_src <= esc;
	 add_dst <= esc;
	 siz <= 2'b11;
	 	 	 
      case (op_i[15:12])

	// *********************************************************
	
	4'h0: begin // GRP:0000 Bit Manipulation 
	  case (op_i[11:8])
	    4'h0: begin // SET:ORI
	       case (op_i[7:0])
		 8'h3C: begin // ORI to CCR
		    alu <= ALU_ORSR;
		    siz_a_o <= 2'b01;
		    add_a_o <= 6'h3C;
		    add_b_o <= esc;

		    src <= {24'd0,dat_a_i[7:0]};
		    //dst <= zero;
		    add_src <= 6'h3C;
		    add_dst <= 6'h3C;
		    siz <= 2'b01;
		    
		 end // case: 8'h3C
		 8'h7C: begin // ORI to SR
		    alu <= ALU_ORSR;
		    siz_a_o <= 2'b01;
		    add_a_o <= 6'h3C;
		    add_b_o <= esc;

		    src <= {16'd0,dat_a_i[15:0]};
		    //dst <= zero;
		    add_src <= 6'h3C;
		    add_dst <= 6'h3C;
		    siz <= 2'b01;
		 end // case: 8'h7C
		 default: begin // ORI
		    alu <= ALU_OR;
		    siz_a_o <= op_i[7:6];
		    add_a_o <= 6'h3C;
		    add_b_o <= op_i[5:0];

		    src <= dat_a_i;
		    //dst <= dat_b_i;
		    add_src <= 6'h3C;
		    add_dst <= op_i[5:0];
		    siz <= op_i[7:6];
		 end // case: default
	       endcase // case(op_i[7:0])
	    end // case: 4'h0
	    4'h2: begin // SET:ANDI
	       case (op_i[7:0])
		 8'h3C: begin // ANDI to CCR
		    alu <= ALU_ANDSR;
		    siz_a_o <= 2'b01;
		    add_a_o <= 6'h3C;
		    add_b_o <= esc;

		    src <= {24'hFFFFFF,dat_a_i[7:0]};
		    //dst <= zero;
		    add_src <= 6'h3C;
		    add_dst <= 6'h3C;
		    siz <= 2'b01;
		 end // case: 8'h3C
		 8'h7C: begin // ANDI to SR
		    alu <= ALU_ANDSR;
		    siz_a_o <= 2'b01;
		    add_a_o <= 6'h3C;
		    add_b_o <= esc;

		    src <= {16'hFFFF,dat_a_i[15:0]};
		    //dst <= zero;
		    add_src <= 6'h3C;
		    add_dst <= 6'h3C;
		    siz <= 2'b01;
		 end // case: 8'h7C
		 default: begin // ANDI
		    alu <= ALU_AND;
		    siz_a_o <= op_i[7:6];
		    add_a_o <= 6'h3C;
		    add_b_o <= op_i[5:0];

		    src <= dat_a_i;
		    //dst <= dat_b_i;
		    add_src <= 6'h3C;
		    add_dst <= op_i[5:0];
		    siz <= op_i[7:6];
		 end // case: default
	       endcase // case(op_i[7:0])
	    end // case: 4'h2
	    4'h4: begin // SET:SUBI
	       alu <= ALU_SUB;
	       siz_a_o <= op_i[7:6];
	       add_a_o <= 6'h3C;
	       add_b_o <= op_i[5:0];
	       
	       src <= dat_a_i;
	       //dst <= dat_b_i;
	       add_src <= 6'h3C;
	       add_dst <= op_i[5:0];
	       siz <= op_i[7:6];
	       
	    end // case: 4'h4
	    4'h6: begin // SET:ADDI
	       alu <= ALU_ADD;
	       siz_a_o <= op_i[7:6];
	       add_a_o <= 6'h3C;
	       add_b_o <= op_i[5:0];
	       
	       src <= dat_a_i;
	       //dst <= dat_b_i;
	       add_src <= 6'h3C;
	       add_dst <= op_i[5:0];
	       siz <= op_i[7:6];
	       
	    end // case: 4'h6
	    4'hA: begin // SET:EORI
	       case (op_i[7:0])
		 8'h3C: begin // EORI to CCR
		    alu <= ALU_EORSR;
		    siz_a_o <= 2'b01;
		    add_a_o <= 6'h3C;
		    add_b_o <= esc;

		    src <= {24'd0,dat_a_i[7:0]};
		    //dst <= zero;
		    add_src <= 6'h3C;
		    add_dst <= 6'h3C;
		    siz <= 2'b01;
		 end // case: 8'h3C
		 8'h7C: begin // EORI to SR
		    alu <= ALU_EORSR;
		    siz_a_o <= 2'b01;
		    add_a_o <= 6'h3C;
		    add_b_o <= esc;

		    src <= {16'd0,dat_a_i[15:0]};
		    //dst <= zero;
		    add_src <= 6'h3C;
		    add_dst <= 6'h3C;
		    siz <= 2'b01;
		 end // case: 8'h7C
		 default: begin // EORI
		    alu <= ALU_EOR;
		    siz_a_o <= op_i[7:6];
		    add_a_o <= 6'h3C;
		    add_b_o <= op_i[5:0];

		    src <= dat_a_i;
		    //dst <= dat_b_i;
		    add_src <= 6'h3C;
		    add_dst <= op_i[5:0];
		    siz <= op_i[7:6];

		 end // case: default
	       endcase // case(op_i[7:0])
	    end // case: 4'hA
	    4'hC: begin // SET:CMPI
	       alu <= ALU_SUB;
	       siz_a_o <= op_i[7:6];
	       add_a_o <= 6'h3C;
	       add_b_o <= op_i[5:0];
	       
	       src <= dat_a_i;
	       //dst <= dat_b_i;
	       add_src <= 6'h3C;
	       add_dst <= 6'h3C;
	       siz <= op_i[7:6];

	    end // case: 4'hC
	    4'h8: begin // SET:BIT IMMEDIATE
	       case (op_i[7:6])
		 2'b00: begin // BTST
		    alu <= ALU_BTST;
		    if (op_i[5:3]==3'b000) 
		      siz_a_o <= 2'b10;
		    else
		      siz_a_o <= 2'b00;

		    add_a_o <= 6'h3C;
		    add_b_o <= op_i[5:0];

		    src <= dat_a_i;
		    //dst <= dat_b_i;
		    add_src <= 6'h3C;
		    add_dst <= op_i[5:0];
		    
		    siz <= 2'b10;	        
		 end // case: 2'b00
		 2'b01: begin // BCHG
		    alu <= ALU_BCHG;
		    if (op_i[5:3]==3'b000) 
		      siz_a_o <= 2'b10;
		    else
		      siz_a_o <= 2'b00;

		    add_a_o <= 6'h3C;
		    add_b_o <= op_i[5:0];

		    src <= dat_a_i;
		    //dst <= dat_b_i;
		    add_src <= 6'h3C;
		    add_dst <= op_i[5:0];
		    
		    siz <= 2'b10;	        
		 end // case: 2'b01
		 2'b10: begin // BCLR
		    alu <= ALU_BCLR;
		    if (op_i[5:3]==3'b000) 
		      siz_a_o <= 2'b10;
		    else
		      siz_a_o <= 2'b00;

		    add_a_o <= 6'h3C;
		    add_b_o <= op_i[5:0];

		    src <= dat_a_i;
		    //dst <= dat_b_i;
		    add_src <= 6'h3C;
		    add_dst <= op_i[5:0];
		    
		    siz <= 2'b10;	        
		 end // case: 2'b10
		 2'b11: begin // BSET
		    alu <= ALU_BSET;
		    if (op_i[5:3]==3'b000) 
		      siz_a_o <= 2'b10;
		    else
		      siz_a_o <= 2'b00;

		    add_a_o <= 6'h3C;
		    add_b_o <= op_i[5:0];

		    src <= dat_a_i;
		    //dst <= dat_b_i;
		    add_src <= 6'h3C;
		    add_dst <= op_i[5:0];
		    
		    siz <= 2'b10;	        
		 end // case: 2'b11
	       endcase // case(op_i[7:6])
	    end // case: 4'h8
	    default: begin // SET:BIT2
	       case (op_i[5:3])
		 3'b001: begin //MOVEP
		 end
		 default: begin
		    case (op_i[7:6])
		      2'b00: begin // BTST
			 alu <= ALU_BTST;
			 if (op_i[5:3]==3'b000) 
			   siz_a_o <= 2'b10;
			 else
			   siz_a_o <= 2'b00;
			 
			 add_a_o <= {3'd0,op_i[11:9]};
			 add_b_o <= op_i[5:0];
			 
			 src <= dat_a_i;
			 //dst <= dat_b_i;
			 add_src <= 6'h3C;
			 add_dst <= op_i[5:0];
			 
			 siz <= 2'b10;	        
			 
		      end // case: 2'b00
		      2'b01: begin // BCHG
			 alu <= ALU_BCHG;
			 if (op_i[5:3]==3'b000) 
			   siz_a_o <= 2'b10;
			 else
			   siz_a_o <= 2'b00;
			 
			 add_a_o <= {3'd0,op_i[11:9]};
			 add_b_o <= op_i[5:0];
			 
			 src <= dat_a_i;
			 //dst <= dat_b_i;
			 add_src <= 6'h3C;
			 add_dst <= op_i[5:0];
			 
			 siz <= 2'b10;	        
		      end // case: 2'b01
		      2'b10: begin // BCLR
			 alu <= ALU_BCLR;
			 if (op_i[5:3]==3'b000) 
			   siz_a_o <= 2'b10;
			 else
			   siz_a_o <= 2'b00;
			 
			 add_a_o <= {3'd0,op_i[11:9]};
			 add_b_o <= op_i[5:0];
			 
			 src <= dat_a_i;
			 //dst <= dat_b_i;
			 add_src <= 6'h3C;
			 add_dst <= op_i[5:0];
			 
			 siz <= 2'b10;	        
		      end // case: 2'b10
		      2'b11: begin // BSET
			 alu <= ALU_BSET;
			 if (op_i[5:3]==3'b000) 
			   siz_a_o <= 2'b10;
			 else
			   siz_a_o <= 2'b00;
			 
			 add_a_o <= {3'd0,op_i[11:9]};
			 add_b_o <= op_i[5:0];
			 
			 src <= dat_a_i;
			 //dst <= dat_b_i;
			 add_src <= 6'h3C;
			 add_dst <= op_i[5:0];
			 
			 siz <= 2'b10;	        
		      end // case: 2'b11
		    endcase // case(op_i[7:6])
		 end // case: default
	       endcase // case(op_i[5:3])
	    end // case: default
	  endcase // case(op_i[11:8])
	end // case: 4'h0

	// *********************************************************
	
	4'h1,4'h2,4'h3: begin // GRP:MOVEA

	   alu <= ALU_MOV;
	   
	   add_a_o <= op_i[5:0];
	   add_b_o <= {op_i[8:6], op_i[11:9]};

	   add_src <= op_i[5:0];
	   add_dst <= {op_i[8:6], op_i[11:9]};
	   src <= dat_a_i;
	   //dst <= dat_b_i;

	   case (op_i[13:12])
	     2'b11: siz <= 2'b01;
	     2'b01: siz <= 2'b00;
	     default: siz <= 2'b10;
	   endcase // case(op_i[13:12])
	   	 
	   case (op_i[13:12])
	     2'b11: siz_a_o <= 2'b01;
	     2'b01: siz_a_o <= 2'b00;
	     default: siz_a_o <= 2'b10;
	   endcase // case(op_i[13:12])
	   	   
	end // case: 4'h1,4'h2,4'h3

	// *********************************************************

	4'h4: begin // GRP:MISC
	   case (op_i[11:6])
	     6'h03: begin // MOVE from SR
		alu <= ALU_MOVSR;
		siz_a_o <= 2'b01;
		add_a_o <= esc;
		add_b_o <= op_i[5:0];

		src <= zero;
		//dst <= dat_b_i;
		add_src <= esc;
		add_dst <= op_i[5:0];
		siz <= 2'b01;
		
	     end // case: 6'h03
	     6'h0B: begin // MOVE from CCR
		//
		//  NOT IMPLEMENTED
		//
		alu <= ALU_NOP;
		//dst <= xxxx;
		src <= xxxx;
		add_dst <= 6'bxxxxxx;
		add_src <= 6'bxxxxxx;
		siz <= 2'bxx;
		add_a_o <= 6'bxxxxxx;
		add_b_o <= 6'bxxxxxx;
		siz_a_o <= 2'bxx;
	     end
	     6'h00,6'h01,6'h02: begin // NEGX
		alu <= ALU_NEGX;
		siz_a_o <= op_i[7:6];
		add_a_o <= esc;
		add_b_o <= op_i[5:0];

		src <= zero;
		//dst <= dat_b_i;
		add_dst <= op_i[5:0];
		add_src <= esc;
		siz <= op_i[7:6];
		
	     end // case: 6'h00,6'h01,6'h02
	     6'h08,6'h09,6'h0A: begin // CLR
		alu <= ALU_MOV ;
		siz_a_o <= op_i[7:6];
		add_a_o <= esc;
		add_b_o <= op_i[5:0];

		src <= zero;
		//dst <= dat_b_i;
		add_dst <= op_i[5:0];
		add_src <= esc;
		siz <= op_i[7:6];
		
	     end // case: 6'h08,6'h09,6'h0A
	     6'h13: begin // MOVE to CCR
		alu <= ALU_MOVSR;
		siz_a_o <= 2'b01;
		add_a_o <= 6'h3C;
		add_b_o <= esc;
		
		src <= {24'd0,dat_a_i[7:0]};
		//dst <= {16'd0,16'hFFFF};
		add_src <= 6'h3C;
		add_dst <= 6'h3C;
		siz <= 2'b01;

	     end // case: 6'h13
	     6'h10,6'h11,6'h12: begin // NEG
		alu <= ALU_NEG;
		siz_a_o <= op_i[7:6];
		add_a_o <= esc;
		add_b_o <= op_i[5:0];

		src <= zero;
		//dst <= dat_b_i;
		add_dst <= op_i[5:0];
		add_src <= esc;
		siz <= op_i[7:6];
		
	     end // case: 6'h10,6'h11,6'h12
	     6'h18,6'h19,6'h1A: begin // NOT
		alu <= ALU_NOT;
		siz_a_o <= op_i[7:6];
		add_a_o <= esc;
		add_b_o <= op_i[5:0];

		src <= zero;
		//dst <= dat_b_i;
		add_dst <= op_i[5:0];
		add_src <= esc;
		siz <= op_i[7:6];
		
	     end // case: 6'h18,6'h19,6'h1A
	     6'h1B: begin // MOVE to SR
		alu <= ALU_MOVSR;
		siz_a_o <= 2'b01;
		add_a_o <= 6'h3C;
		add_b_o <= esc;
		
		src <= {24'd0,dat_a_i[7:0]};
		//dst <= {16'd0,16'd0};
		add_src <= 6'h3C;
		add_dst <= 6'h3C;
		siz <= 2'b01;
	     end // case: 6'h1B
	     6'h22,6'h23: begin
		case (op_i[5:3])
		  3'b000: begin // EXT
		     //
		     //  NOT IMPLEMENTED
		     //
		     alu <= ALU_NOP;
		     //dst <= xxxx;
		     src <= xxxx;
		     add_dst <= 6'bxxxxxx;
		     add_src <= 6'bxxxxxx;
		     siz <= 2'bxx;
		     add_a_o <= 6'bxxxxxx;
		     add_b_o <= 6'bxxxxxx;
		     siz_a_o <= 2'bxx;
		  end
		  default: begin // MOVEM
		     //
		     //  NOT IMPLEMENTED
		     //
		     alu <= ALU_NOP;
		     //dst <= xxxx;
		     src <= xxxx;
		     add_dst <= 6'bxxxxxx;
		     add_src <= 6'bxxxxxx;
		     siz <= 2'bxx;
		     add_a_o <= 6'bxxxxxx;
		     add_b_o <= 6'bxxxxxx;
		     siz_a_o <= 2'bxx;
		  end
		endcase // case(op_i[5:3])
	     end
	     6'h21: begin
		case (op_i[5:3])
		  3'b000: begin // SWAP
		     alu <= ALU_SWAP;
		     siz_a_o <= 2'b10;
		     add_a_o <= esc;
		     add_b_o <= {3'd0, op_i[2:0]};

		     src <= zero;
		     //dst <= dat_b_i;
		     add_src <= 6'h3C;
		     add_dst <= {3'd0, op_i[2:0]};
		     siz <= 2'b10;
		  end // case: 3'b000
		  3'b001: begin // BKPT
		     
		     add_a_o <= esc;
		     add_b_o <= esc;
		     siz_a_o <= 2'b00;
		     
		     alu <= ALU_VECTOR;
		     src <= 6'd4;
		     //dst <= zero;
		     add_dst <= 6'h3C;
		     add_src <= esc;
		     siz <= 2'b10;
		  end // case: 3'b001
		  default: begin // PEA
		     alu <= ALU_EA;
		     siz_a_o <= 2'b10;
		     add_a_o <= op_i[5:0];
		     add_b_o <= esc;
		     //dst <= zero;
		     src <= dat_c_i;
		     add_src <= esc;
		     add_dst <= 6'b100111; //-%a7@
		     siz <= 2'b10;
		     
		  end // case: default
		endcase // case(op_i[5:3])
	     end // case: 6'h21
	     6'h2B: begin
		case (op_i[5:0])
		  6'h3C: begin // ILLEGAL
		     
		     add_a_o <= esc;
		     add_b_o <= esc;
		     siz_a_o <= 2'b00;
		     
		     alu <= ALU_VECTOR;
		     src <= 6'd4;
		     //dst <= zero;
		     add_dst <= 6'h3C;
		     add_src <= esc;
		     siz <= 2'b10;

		  end // case: 6'h3C
		  default: begin // TAS
		     alu <= ALU_TAS;
		     siz_a_o <= op_i[7:6];
		     add_a_o <= esc;
		     add_b_o <= op_i[5:0];
		     src <= zero;
		     //dst <= dat_b_i;
		     add_src <= esc;
		     add_dst <= op_i[5:0];
		     siz <= op_i[7:0];
		  end // case: default
		endcase // case(op_i[5:0])
	     end // case: 6'h2B
	     6'h28,6'h29,6'h2A: begin // TST
		alu <= ALU_TST;
		siz_a_o <= op_i[7:6];
		add_a_o <= esc;
		add_b_o <= op_i[5:0];
		src <= zero;
		//dst <= dat_b_i;
		add_src <= esc;
		add_dst <= op_i[5:0];
		siz <= op_i[7:0];
		
	     end // case: 6'h28,6'h29,6'h2A
	     6'h39: begin
		case (op_i[5:3])
		  3'b000,3'b001: begin // TRAP
		     
		     add_a_o <= esc;
		     add_b_o <= esc;
		     siz_a_o <= 2'b00;
		     
		     alu <= ALU_VECTOR;
		     //dst <= 6'd32;
		     src <= {28'd2, op_i[3:0]};
		     add_dst <= 6'h3C;
		     add_src <= 6'h3C;
		     siz <= 2'b10;

		  end // case: 3'b000,3'b001
		  3'b010: begin // LINK
		     //
		     //  NOT IMPLEMENTED
		     //
		     alu <= ALU_NOP;
		     //dst <= xxxx;
		     src <= xxxx;
		     add_dst <= 6'bxxxxxx;
		     add_src <= 6'bxxxxxx;
		     siz <= 2'bxx;
		     add_a_o <= 6'bxxxxxx;
		     add_b_o <= 6'bxxxxxx;
		     siz_a_o <= 2'bxx;
		  end
		  3'b011: begin // ULNK
		     //
		     //  NOT IMPLEMENTED
		     //
		     alu <= ALU_NOP;
		     //dst <= xxxx;
		     src <= xxxx;
		     add_dst <= 6'bxxxxxx;
		     add_src <= 6'bxxxxxx;
		     siz <= 2'bxx;
		     add_a_o <= 6'bxxxxxx;
		     add_b_o <= 6'bxxxxxx;
		     siz_a_o <= 2'bxx;
		  end
		  
		  3'b100,3'b101: begin // MOVE USP
		     //
		     //  NOT IMPLEMENTED
		     //
		     alu <= ALU_NOP;
		     //dst <= xxxx;
		     src <= xxxx;
		     add_dst <= 6'bxxxxxx;
		     add_src <= 6'bxxxxxx;
		     siz <= 2'bxx;
		     add_a_o <= 6'bxxxxxx;
		     add_b_o <= 6'bxxxxxx;
		     siz_a_o <= 2'bxx;
		  end
		  
		  3'b110: begin
		     case (op_i[2:0])
		       3'h0: begin // RESET
			  // JMP #0
			  add_a_o <= esc;
			  add_b_o <= esc;
			  siz_a_o <= 2'b10;
			  
			  alu <= ALU_MOV;
			  //dst <= zero;
			  src <= reset;
			  add_dst <= 6'h3C;
			  add_src <= esc;
			  siz <= 2'b10;
		       end // case: 3'h0
		       3'h1: begin // NOP
			  add_a_o <= esc;
			  add_b_o <= esc;
			  siz_a_o <= 2'b11;
			  alu <= ALU_NOP;
			  //dst <= zero;
			  src <= zero;
			  add_dst <= esc;
			  add_src <= esc;
			  siz <= 2'b11;
		       end // case: 3'h1
		       3'h2: begin // STOP
			  alu <= ALU_STOP;
			  siz_a_o <= 2'b10;
			  add_a_o <= 6'h3C;
			  add_b_o <= 6'h3D;
			  //dst <= pc_i;
			  src <= dat_a_i;
			  siz <= 2'b10;
			  add_src <= 6'h3C;
			  add_dst <= 6'h3C;
			  			  
		       end // case: 3'h2
		       3'h3: begin // RTE
			  add_a_o <= 6'h1F;
			  add_b_o <= esc;
			  siz_a_o <= 2'b10;
			  
			  alu <= ALU_MOV;
			  //dst <= zero;
			  src <= {dat_a_i[31:1],1'b0};
			  add_dst <= 6'h3C;
			  add_src <= esc;
			  siz <= 2'b10;
		       end // case: 3'h3
		       3'h5: begin // RTS
			  add_a_o <= 6'h1F;
			  add_b_o <= esc;
			  siz_a_o <= 2'b10;
			  
			  alu <= ALU_MOV;
			  //dst <= zero;
			  src <= {dat_a_i[31:1],1'b0};
			  add_dst <= 6'h3C;
			  add_src <= esc;
			  siz <= 2'b10;
		       end // case: 3'h5
		       3'h6: begin // TRAPV
			  add_a_o <= esc;
			  add_b_o <= esc;
			  siz_a_o <= 2'b00;
			  
			  alu <= ALU_VECTOR;
			  //dst <= 6'd32;
			  src <= 3'd7;
			  add_dst <= 6'h3C;
			  add_src <= esc;
			  siz <= 2'b10;
			  
		       end // case: 3'h6
		       3'h7: begin // RTR
			  add_a_o <= 6'h1F;
			  add_b_o <= esc;
			  siz_a_o <= 2'b10;
			  
			  alu <= ALU_MOV;
			  //dst <= zero;
			  src <= {dat_a_i[31:1],1'b0};
			  add_dst <= 6'h3C;
			  add_src <= esc;
			  siz <= 2'b10;
		       end // case: 3'h7
		       /*************************************************/
		       default: begin
			  alu <= ALU_NOP;
			  //dst <= xxxx;
			  src <= xxxx;
			  add_dst <= 6'bxxxxxx;
			  add_src <= 6'bxxxxxx;
			  siz <= 2'bxx;
			  add_a_o <= 6'bxxxxxx;
			  add_b_o <= 6'bxxxxxx;
			  siz_a_o <= 2'bxx;
		       end
		       
		     endcase // case(op_i[2:0])
		  end // case: 3'b110
		  /*************************************************/
		  default: begin
		     alu <= ALU_NOP;
		     //dst <= xxxx;
		     src <= xxxx;
		     add_dst <= 6'bxxxxxx;
		     add_src <= 6'bxxxxxx;
		     siz <= 2'bxx;
		     add_a_o <= 6'bxxxxxx;
		     add_b_o <= 6'bxxxxxx;
		     siz_a_o <= 2'bxx;
		  end
		  
		endcase // case(op_i[5:3])
	     end // case: 6'h39
	     6'h3A: begin // JSR
		add_a_o <= op_i[5:0];
		add_b_o <= 6'h3D;
		siz_a_o <= 2'b10;
		
		alu <= ALU_MOV;
		//dst <= zero;
		src <= {dat_a_i[31:1],1'b1};
		add_dst <= 6'h3C;
		add_src <= esc;
		siz <= 2'b10;
		
	     end // case: 6'h3A
	     6'h3B: begin // JMP
		add_b_o <= 6'h3D;
		siz_a_o <= 2'b10;
		add_a_o <= op_i[5:0];
		src <= {dat_a_i[31:1],1'b0};

		siz <= 2'b10;
		alu <= ALU_MOV;
		//dst <= {pc_i[31:1],1'b0};
		add_dst <= 6'h3C;
		add_src <= esc;
		
	     end // case: 6'h3B
	     6'h07,6'h0F: begin // LEA
		alu <= ALU_EA;
		siz_a_o <= 2'b10;
		add_a_o <= op_i[5:0];
		add_b_o <= {2'd1,op_i[11:9]};
		//dst <= dat_b_i;
		src <= dat_c_i;
		add_src <= esc;
		add_dst <= {2'd1, op_i[11:9]}; //-%a7@
		siz <= 2'b10;
	     end // case: 6'h07,6'h0F
	     6'h06,6'h0E: begin // CHK
		//
		//  NOT IMPLEMENTED
		//
		alu <= ALU_NOP;
		//dst <= xxxx;
		src <= xxxx;
		add_dst <= 6'bxxxxxx;
		add_src <= 6'bxxxxxx;
		siz <= 2'bxx;
		add_a_o <= 6'bxxxxxx;
		add_b_o <= 6'bxxxxxx;
		siz_a_o <= 2'bxx;
	     end
	     default: begin
		alu <= ALU_NOP;
		//dst <= xxxx;
		src <= xxxx;
		add_dst <= 6'bxxxxxx;
		add_src <= 6'bxxxxxx;
		siz <= 2'bxx;
		add_a_o <= 6'bxxxxxx;
		add_b_o <= 6'bxxxxxx;
		siz_a_o <= 2'bxx;
	     end
	   endcase // case(op_i[11:6])
	   
	end // case: 4'h4

	// *********************************************************

	4'h5: begin // GRP:QUICK
	   case (op_i[7:6])
	     2'b11: begin // SET:cc
		case (op_i[5:3])
		  3'b001: begin // DBcc
		     //
		     //  NOT IMPLEMENTED
		     //
		     alu <= ALU_NOP;
		     //dst <= xxxx;
		     src <= xxxx;
		     add_dst <= 6'bxxxxxx;
		     add_src <= 6'bxxxxxx;
		     siz <= 2'bxx;
		     add_a_o <= 6'bxxxxxx;
		     add_b_o <= 6'bxxxxxx;
		     siz_a_o <= 2'bxx;
		  end
		  default: begin // Scc
		     alu <= ALU_SCC;
		     siz_a_o <= 2'b00;
		     add_a_o <= esc;
		     add_b_o <= op_i[5:0];

		     add_src <= {2'b11, op_i[11:8]};
		     add_dst <= op_i[5:0];
		     //dst <= dat_b_i;
		     src <= zero;
		     siz <= 2'b00;
		     
		  end // case: default
		endcase // case(op_i[5:3])
	     end // case: 2'b11
	     default: begin
		case (op_i[8])
		  1'b0: begin // ADDQ
		     alu <= ALU_ADD;
		     siz_a_o <= op_i[7:6];
		     add_a_o <= esc;
		     add_b_o <= op_i[5:0];
		     
		     if (op_i[11:9]== 3'b000)
		       src <= 32'd8;
		     else
		       src <= op_i[11:9];
		     
		     //dst <= dat_b_i;
		     add_src <= 6'h3C;
		     add_dst <= op_i[5:0];
		     siz <= op_i[7:6];
		     
		  end // case: 1'b0
		  1'b1: begin // SUBQ
		     alu <= ALU_SUB;
		     siz_a_o <= op_i[7:6];
		     add_a_o <= esc;
		     add_b_o <= op_i[5:0];
		
		     if (op_i[11:9]== 3'b000) 
		       src <= 32'd8;
		     else
		       src <= op_i[11:9];
		  	  	     
		     //dst <= dat_b_i;
		     add_src <= 6'h3C;
		     add_dst <= op_i[5:0];
		     siz <= op_i[7:6];
		  end // case: 1'b1
		endcase // case(op_i[8])
	     end // case: default
	   endcase // case(op_i[7:6])
	end // case: 4'h5
	
	// *********************************************************

	4'h6: begin // GRP:BRANCH
	   case (op_i[11:8])
	     4'h0: begin // BRA
		add_b_o <= 6'h3D;

		if (op_i[7:0]== 8'd0) begin
		   siz_a_o <= 2'b01;
		   add_a_o <= 6'h3C;
		   src <= {16'd0,dat_a_i[15:1],1'b0};
		   siz <= 2'b01;
		end else begin
		   siz_a_o <= 2'b11;
		   add_a_o <= esc;
		   src <= {24'd0,op_i[7:1],1'b0};
		   siz <= 2'b00;
		end // else: !if(op_i[7:0] == 8'd0)
				
		alu <= ALU_ADD;
		//dst <= {pc_i[31:1],1'b0};
		add_dst <= 6'h3C;
		add_src <= esc;
	     end // case: 4'h0
	     4'h1: begin // BSR
		add_b_o <= 6'h3D;

		if (op_i[7:0]==8'd0) begin
		   siz_a_o <= 2'b01;
		   add_a_o <= 6'h3C;
		   src <= {16'd0,dat_a_i[15:1],1'b1};
		   siz <= 2'b01;
		end else begin
		   siz_a_o <= 2'b11;
		   add_a_o <= esc;
		   src <= {24'd0,op_i[7:1],1'b1};
		   siz <= 2'b00;
		end // else: !if(op_i[7:0] == 8'd0)
				
		alu <= ALU_ADD;
		//dst <= {pc_i[31:1],1'b1};
		add_dst <= 6'h3C;
		add_src <= esc;
	     end // case: 4'h1
	     default: begin // Bcc
		add_b_o <= 6'h3D;
		
		if (op_i[7:0]==8'd0) begin
		   siz_a_o <= 2'b01;
		   add_a_o <= 6'h3C;
		   src <= {16'd0,dat_a_i[15:1],1'b0};
		   siz <= 2'b01;
		end else begin
		   siz_a_o <= 2'b11;
		   add_a_o <= esc;
		   src <= {24'd0,op_i[7:1],1'b0};
		   siz <= 2'b00;
		end // else: !if(op_i[7:0] == 8'd0)
			
		alu <= ALU_BCC;
		//dst <= {pc_i[31:1],1'b0};
		add_dst <= 6'h3C;
		add_src <= {2'b11, op_i[11:8]};
   
	     end // case: default
	   endcase // case(op_i[11:8])
	end // case: 4'h6
			
	// *********************************************************

	4'h7: begin // MOVEQ
	   add_b_o <= {3'd0,op_i[11:9]};
	   add_a_o <= esc;
	   siz_a_o <= 2'b11;

	   alu <= ALU_MOV;
	   src <= op_i[7:0];
	   //dst <= dat_b_i;
	   add_dst <= {3'd0, op_i[11:9]};
	   add_src <= esc;
	   siz <= 2'b00;
	   	   
	end // case: 4'h7
		
	// *********************************************************

	4'h8: begin // GRP:DIV
	   case (op_i[8:6])
	     3'b011: begin // DIVU
`ifdef k68_DIVX
		alu <= ALU_DIV;
		siz_a_o <= 2'b01;
		add_a_o <= op_i[5:0];
		add_b_o <= {3'd0, op_i[11:9]};
		src <= dat_a_i;
		//dst <= dat_b_i;
		add_src <= op_i[5:0];
		add_dst <= {3'd0, op_i[11:9]};
		siz <= 2'b01;
`else // !`ifdef k68_DIVX
		alu <= ALU_NOP;
		//dst <= xxxx;
		src <= xxxx;
		add_dst <= 6'bxxxxxx;
		add_src <= 6'bxxxxxx;
		siz <= 2'bxx;
		add_a_o <= 6'bxxxxxx;
		add_b_o <= 6'bxxxxxx;
		siz_a_o <= 2'bxx;
`endif // !`ifdef k68_DIVX
	     end // case: 3'b011
	     3'b111: begin // DIVS
`ifdef k68_DIVX		
		alu <= ALU_DIV;
		siz_a_o <= 2'b01;
		add_a_o <= op_i[5:0];
		add_b_o <= {3'd0, op_i[11:9]};
		src <= dat_a_i;
		//dst <= dat_b_i;
		add_src <= op_i[5:0];
		add_dst <= {3'd0, op_i[11:9]};
		siz <= 2'b01;
`else // !`ifdef k68_DIVX
		alu <= ALU_NOP;
		//dst <= xxxx;
		src <= xxxx;
		add_dst <= 6'bxxxxxx;
		add_src <= 6'bxxxxxx;
		siz <= 2'bxx;
		add_a_o <= 6'bxxxxxx;
		add_b_o <= 6'bxxxxxx;
		siz_a_o <= 2'bxx;
`endif // !`ifdef k68_DIVX
	     end // case: 3'b111
	     default: begin
		case (op_i[5:4])
		  2'b00: begin // SBCD
		     alu <= ALU_SBCD;
		     siz_a_o <= 2'b00;
		     
		     add_a_o <= {op_i[3],2'b00,op_i[11:9]};
		     add_b_o <= {op_i[3],2'b00,op_i[2:0]};
       
		     src <= dat_a_i;
		     //dst <= dat_b_i;
		     add_src <= {op_i[3],2'b00,op_i[11:9]};
		     add_dst <= {op_i[3],2'b00,op_i[2:0]};
		     siz <= 2'b00;
		     
		  end // case: 2'b00
		  default: begin // OR
		     alu <= ALU_OR;
		     siz_a_o <= op_i[7:6];
		     if (op_i[8]) begin
			add_a_o <= {3'd0, op_i[11:9]};
			add_b_o <= op_i[5:0];
			add_src <= {3'd0, op_i[11:9]};
			add_dst <= op_i[5:0];
			
		     end else begin
			add_b_o <= {3'd0, op_i[11:9]};
			add_a_o <= op_i[5:0];
			add_dst <= {3'd0, op_i[11:9]};
			add_src <= op_i[5:0];
		     end // else: !if(op_i[8])

		     siz <= op_i[7:6];
		     src <= dat_a_i;
		     //dst <= dat_b_i;
		     
		  end // case: default
		endcase // case(op_i[5:4])
	     end // case: default
	   endcase // case(op_i[8:6])
	end // case: 4'h8
		
	// *********************************************************

	4'h9: begin // GRP:SUB
	   case (op_i[8])
	     1'b1: begin
		case (op_i[7:6])
		  2'b11: begin // SUBA
		     alu <= ALU_SUB;
		     siz_a_o <= op_i[8:7];
		     add_b_o <= {3'd1, op_i[11:9]};
		     add_a_o <= op_i[5:0];
		     add_dst <= {3'd1, op_i[11:9]};
		     add_src <= op_i[5:0];
		     siz <= op_i[8:7];
		     src <= dat_a_i;
		     //dst <= dat_b_i;
		     
		  end // case: 2'b11
		  default: begin // SUBX
		     case (op_i[5:4])
		       2'b00: begin
			  alu <= ALU_SUBX;
			  siz_a_o <= op[7:6];
			  add_a_o <= {op_i[3], 2'b00, op_i[11:9]};
			  add_b_o <= {op_i[3], 2'b00, op_i[2:0]};
			  add_src <= {op_i[3], 2'b00, op_i[11:9]};
			  add_dst <= {op_i[3], 2'b00, op_i[2:0]};
			  src <= dat_a_i;
			  //dst <= dat_b_i;
			  siz <= op[7:6];
		       end // case: 2'b00
		       default: begin
			  alu <= ALU_SUB;
			  siz_a_o <= op_i[7:6];
			  add_a_o <= {3'd0, op_i[11:9]};
			  add_b_o <= op_i[5:0];
			  add_src <= {3'd0, op_i[11:9]};
			  add_dst <= op_i[5:0];
			  
			  siz <= op_i[7:6];
			  src <= dat_a_i;
			  //dst <= dat_b_i;
			  
		       end // case: default
		     endcase // case(op_i[5:4])
		  end // case: default
		endcase // case(op_i[7:6])
	     end // case: 1'b1
	     default: begin // SUB
		alu <= ALU_SUB;
		siz_a_o <= op_i[7:6];
		add_b_o <= {3'd0, op_i[11:9]};
		add_a_o <= op_i[5:0];
		add_dst <= {3'd0, op_i[11:9]};
		add_src <= op_i[5:0];
		
		siz <= op_i[7:6];
		src <= dat_a_i;
		//dst <= dat_b_i;
	     end // case: default
	   endcase // case(op_i[8])
	end // case: 4'h9
		
	// *********************************************************

	4'hB: begin // GRP: CMP
	   case (op_i[8:6])
	     3'h0,3'h1,3'h2: begin // CMP
		alu <= ALU_SUB;
		siz_a_o <= op_i[7:6];
		add_a_o <= op_i[5:0];
		add_b_o <= {3'd0, op_i[11:9]};
	       	src <= dat_a_i;
		//dst <= dat_b_i;
		add_src <= op_i[5:0];
		add_dst <= 6'h3C;
		siz <= op_i[7:6];

	     end // case: 3'h0,3'h1,3'h2
	     3'h3,3'h7: begin // CMPA
		alu <= ALU_SUB;
		siz_a_o <= op_i[8:7];
		add_a_o <= op_i[5:0];
		add_b_o <= {3'd1, op_i[11:9]};
	       	src <= dat_a_i;
		//dst <= dat_b_i;
		add_src <= op_i[5:0];
		add_dst <= 6'h3C;
		siz <= op_i[8:7];
		
	     end // case: 3'h3,3'h7
	     3'h4,3'h5,3'h6: begin
		case (op_i[5:3])
		  3'h1: begin // CMPM
		     alu <= ALU_SUB;
		     siz_a_o <= op_i[7:6];
		     add_a_o <= {3'b011,op_i[2:0]};
		     add_b_o <= {3'b011,op_i[11:9]};
		     add_src <= {3'b011,op_i[2:0]};
		     add_dst <= 6'h3C;
		     src <= dat_a_i;
		     //dst <= dat_b_i;
		  end
		  default: begin // EOR
		     alu <= ALU_EOR;
		     siz_a_o <= op_i[7:6];
		     add_a_o <= {3'd0, op_i[11:9]};
		     add_b_o <= op_i[5:0];
		     add_src <= {3'd0, op_i[11:9]};
		     add_dst <= op_i[5:0];
		     siz <= op_i[7:6];
		     src <= dat_a_i;
		     //dst <= dat_b_i;
		     
		  end // case: default
		endcase // case(op_i[5:3])
	     end // case: 3'h4,3'h5,3'h6
	   endcase // case(op_i[8:6])
	end // case: 4'hB
		
	// *********************************************************

	4'hC: begin // GRP:MUL
	   case (op_i[8:6])
	     3'b011: begin // MULU
`ifdef k68_MULX
		alu <= ALU_MUL;
		siz_a_o <= 2'b01;
		add_a_o <= op_i[5:0];
		add_b_o <= {3'd0, op_i[11:9]};
		src <= dat_a_i;
		//dst <= dat_b_i;
		add_src <= op_i[5:0];
		add_dst <= {3'd0, op_i[11:9]};
		siz <= 2'b01;
`else // !`ifdef k68_MULX
		alu <= ALU_NOP;
		//dst <= xxxx;
		src <= xxxx;
		add_dst <= 6'bxxxxxx;
		add_src <= 6'bxxxxxx;
		siz <= 2'bxx;
		add_a_o <= 6'bxxxxxx;
		add_b_o <= 6'bxxxxxx;
		siz_a_o <= 2'bxx;
`endif // !`ifdef k68_MULX
	     end // case: 3'b011
	     3'b111: begin // MULS
`ifdef k68_MULX
		alu <= ALU_MUL;
		siz_a_o <= 2'b01;
		add_a_o <= op_i[5:0];
		add_b_o <= {3'd0, op_i[11:9]};
		src <= dat_a_i;
		//dst <= dat_b_i;
		add_src <= op_i[5:0];
		add_dst <= {3'd0, op_i[11:9]};
		siz <= 2'b01;
`else // !`ifdef k68_MULX
		alu <= ALU_NOP;
		//dst <= xxxx;
		src <= xxxx;
		add_dst <= 6'bxxxxxx;
		add_src <= 6'bxxxxxx;
		siz <= 2'bxx;
		add_a_o <= 6'bxxxxxx;
		add_b_o <= 6'bxxxxxx;
		siz_a_o <= 2'bxx;
`endif // !`ifdef k68_MULX
	     end // case: 3'b111
	     default: begin
		case (op_i[5:4])
		  2'b00: begin // ABCD
		     alu <= ALU_ABCD;
		     siz_a_o <= 2'b00;
		     
		     add_a_o <= {op_i[3],2'b00,op_i[11:9]};
		     add_b_o <= {op_i[3],2'b00,op_i[2:0]};
       
		     src <= dat_a_i;
		     //dst <= dat_b_i;
		     add_src <= {op_i[3],2'b00,op_i[11:9]};
		     add_dst <= {op_i[3],2'b00,op_i[2:0]};
		     siz <= 2'b00;
		  end // case: 2'b00
		  default: begin // AND
		     alu <= ALU_AND;
		     siz_a_o <= op_i[7:6];

		     if (op_i[8]) begin
			add_a_o <= {3'd0, op_i[11:9]};
			add_b_o <= op_i[5:0];
			add_src <= {3'd0, op_i[11:9]};
			add_dst <= op_i[5:0];
		     end else begin
			add_b_o <= {3'd0, op_i[11:9]};
			add_a_o <= op_i[5:0];
			add_dst <= {3'd0, op_i[11:9]};
			add_src <= op_i[5:0];
		     end // else: !if(op_i[8])
		     
		     siz <= op_i[7:6];
		     src <= dat_a_i;
		     //dst <= dat_b_i;
		     
		  end // case: default
		endcase // case(op_i[5:4])
	     end // case: default
	   endcase // case(op_i[8:6])
	end // case: 4'hC
		
	// *********************************************************

	4'hD: begin // GRP:ADD
	   case (op_i[8])
	     1'b1: begin
		case (op_i[7:6])
		  2'b11: begin // ADDA
		     alu <= ALU_ADD;
		     siz_a_o <= op_i[8:7];
		     add_b_o <= {3'd1, op_i[11:9]};
		     add_a_o <= op_i[5:0];
		     add_dst <= {3'd1, op_i[11:9]};
		     add_src <= op_i[5:0];
		     siz <= op_i[8:7];
		     src <= dat_a_i;
		     //dst <= dat_b_i;
		  end // case: 2'b11
		  default: begin // ADDX
		     case (op_i[5:4])
		       2'b00: begin
			  alu <= ALU_ADDX;
			  siz_a_o <= op[7:6];
			  add_a_o <= {op_i[3], 2'b00, op_i[11:9]};
			  add_b_o <= {op_i[3], 2'b00, op_i[2:0]};
			  add_src <= {op_i[3], 2'b00, op_i[11:9]};
			  add_dst <= {op_i[3], 2'b00, op_i[2:0]};
			  src <= dat_a_i;
			  //dst <= dat_b_i;
			  siz <= op[7:6];
		       end // case: 2'b00
		       default: begin
			  alu <= ALU_ADD;
			  siz_a_o <= op_i[7:6];
			  add_a_o <= {3'd0, op_i[11:9]};
			  add_b_o <= op_i[5:0];
			  add_src <= {3'd0, op_i[11:9]};
			  add_dst <= op_i[5:0];
			  
			  siz <= op_i[7:6];
			  src <= dat_a_i;
			  //dst <= dat_b_i;
		       end // case: default
		     endcase // case(op_i[5:4])
		  end // case: default
		endcase // case(op_i[7:6])
	     end // case: 1'b1
	     default: begin // ADD
		alu <= ALU_ADD;
		siz_a_o <= op_i[7:6];
		add_b_o <= {3'd0, op_i[11:9]};
		add_a_o <= op_i[5:0];
		add_dst <= {3'd0, op_i[11:9]};
		add_src <= op_i[5:0];
		
		siz <= op_i[7:6];
		src <= dat_a_i;
		//dst <= dat_b_i;
	     end // case: default
	   endcase // case(op_i[8])
	end // case: 4'hD
	
	// *********************************************************
	
	4'hE: begin // GRP: SHIFTS
	   case (op_i[7:6])
	     2'b11: begin
		case (op_i[10:9])
`ifdef k68_ASX
		  2'h0: begin // ASX
		     alu <= ALU_ASX;
		     siz_a_o <= 2'b10;
		     add_b_o <= op_i[5:0];
		     add_a_o <= esc;
		     add_dst <= op_i[5:0];
		     add_src <= {op_i[8],4'd1};

		     siz <= 2'b10;
		     src <= zero;
		     //dst <= dat_b_i;
		  end // case: 2'h0
`endif //  `ifdef k68_ASX
`ifdef k68_LSX
		  2'h1: begin // LSX
		     alu <= ALU_LSX;
		     siz_a_o <= 2'b10;
		     add_b_o <= op_i[5:0];
		     add_a_o <= esc;
		     add_dst <= op_i[5:0];
		     add_src <= {op_i[8],4'd1};

		     siz <= 2'b10;
		     src <= zero;
		     //dst <= dat_b_i;
		  end // case: 2'h1
`endif //  `ifdef k68_LSX
`ifdef k68_ROXX
		  2'h2: begin // ROXX
		     alu <= ALU_ROXX;
		     siz_a_o <= 2'b10;
		     add_b_o <= op_i[5:0];
		     add_a_o <= esc;
		     add_dst <= op_i[5:0];
		     add_src <= {op_i[8],4'd1};

		     siz <= 2'b10;
		     src <= zero;
		     //dst <= dat_b_i;
		  end // case: 2'h2
`endif //  `ifdef k68_ROXX
		  default: begin // ROX
		     alu <= ALU_ROX;
		     siz_a_o <= 2'b10;
		     add_b_o <= op_i[5:0];
		     add_a_o <= esc;
		     add_dst <= op_i[5:0];
		     add_src <= {op_i[8],4'd1};

		     siz <= 2'b10;
		     src <= zero;
		     //dst <= dat_b_i;
		  end // case: 2'h3
		endcase // case(op_i[10:9])
	     end // case: 2'b11
	     default: begin
		case (op_i[4:3])
`ifdef k68_ASX		  
		  2'h0: begin // ASX
		     alu <= ALU_ASX;
		     siz_a_o <= op_i[7:6];
		     add_b_o <= {3'd0,op_i[2:0]};
		     add_a_o <= {3'd0,op_i[11:9]};

		     add_dst <= {3'd0,op_i[2:0]};

		     if (op_i[5])
		       add_src <= {op_i[8],dat_a_i[4:0]};
		     else
		       add_src <= {op_i[8],~(op_i[11]|op_i[10]|op_i[9]),op_i[11:9]};
		     		     		     
		     siz <= op_i[7:6];
		     //dst <= dat_b_i;
		     src <= zero;
		  end // case: 2'h0
`endif //  `ifdef k68_ASX
`ifdef k68_LSX
		  2'h1: begin // LSX
		     alu <= ALU_LSX;
		     siz_a_o <= op_i[7:6];
		     add_b_o <= {3'd0,op_i[2:0]};
		     add_a_o <= {3'd0,op_i[11:9]};

		     add_dst <= {3'd0,op_i[2:0]};

		     if (op_i[5])
		       add_src <= {op_i[8],dat_a_i[4:0]};
		     else
		       add_src <= {op_i[8],~(op_i[11]|op_i[10]|op_i[9]),op_i[11:9]};
		     		     		     
		     siz <= op_i[7:6];
		     //dst <= dat_b_i;
		     src <= zero;
		  end // case: 2'h1
`endif //  `ifdef k68_LSX
`ifdef k68_ROXX
		  2'h2: begin // ROXX
		     alu <= ALU_ROXX;
		     siz_a_o <= op_i[7:6];
		     add_b_o <= {3'd0,op_i[2:0]};
		     add_a_o <= {3'd0,op_i[11:9]};

		     add_dst <= {3'd0,op_i[2:0]};

		     if (op_i[5])
		       add_src <= {op_i[8],dat_a_i[4:0]};
		     else
		       add_src <= {op_i[8],~(op_i[11]|op_i[10]|op_i[9]),op_i[11:9]};
		     
		     siz <= op_i[7:6];
		     //dst <= dat_b_i;
		     src <= zero;
		  end // case: 2'h2
`endif //  `ifdef k68_ROXX
		  default: begin // ROX
		     alu <= ALU_ROX;
		     siz_a_o <= op_i[7:6];
		     add_b_o <= {3'd0,op_i[2:0]};
		     add_a_o <= {3'd0,op_i[11:9]};

		     add_dst <= {3'd0,op_i[2:0]};

		     if (op_i[5])
		       add_src <= {op_i[8],dat_a_i[4:0]};
		     else
		       add_src <= {op_i[8],~(op_i[11]|op_i[10]|op_i[9]),op_i[11:9]};
		     		     		     
		     siz <= op_i[7:6];
		     //dst <= dat_b_i;
		     src <= zero;
		  end // case: 2'h3
		endcase // case(op_i[4:3])
	     end // case: default
	   endcase // case(op_i[7:6])
	   
	end // case: 4'hE
		
	// *********************************************************

	default: begin // EXTRA FUNCTIONS
	   alu <= ALU_NOP;
	   //dst <= xxxx;
	   src <= xxxx;
	   add_dst <= 6'bxxxxxx;
	   add_src <= 6'bxxxxxx;
	   siz <= 2'bxx;
	   add_a_o <= 6'bxxxxxx;
	   add_b_o <= 6'bxxxxxx;
	   siz_a_o <= 2'bxx;
	end
      endcase // case(op_i[15:12])
      end // else: !if(rst_i || skip[1] || skip[0])
            
   end // always @ (...

   // ***************************************************************
   // ***************************************************************
   // ***************************************************************
   // ***************************************************************
   // ***************************************************************

       
   //
   // Synchronous from EXECS but Async to @MODE
   // STORE
   // add_c_o, dat_c_o
   //
   always @(/*AUTOSENSE*/add_c_i or alu_i or alu_pc_i or brch or res_i
	    or rst_i or siz_i) begin
      if (rst_i) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 add_c_o <= 0;
	 brch_o <= 0;
	 c_siz_o <= 0;
	 dat_c_o <= 0;
	 pc_o <= 0;
	 // End of automatics
	 
      end else begin // if (rst_i)
	 c_siz_o <= siz_i;
	 
	 case (add_c_i)
	   6'h3c:
	    case (alu_i)
	      ALU_STOP: begin
		 brch_o <= 1'b1;
		 pc_o <= res_i;
		 add_c_o <= esc;
		 dat_c_o <= xxxx;
		 
	      end
	      
	      ALU_ADD,ALU_MOV,ALU_BCC,ALU_VECTOR: begin // BRA,JMP,BSR,JSR
		 brch_o <= 1'b1;
		 pc_o <= {res_i[aw-1:1],1'b0};
		 case (res_i[0]) // SubRoutine
		   1'b1: begin
		      add_c_o <= 6'h27;
		      dat_c_o <= {alu_pc_i[aw-1:1],1'b0};
		   end
		   default: begin
		      add_c_o <= esc;
		      dat_c_o <= xxxx;
		   end
		 endcase // case(res_i[0])
	      end // case: ALU_ADD,ALU_MOV,ALU_BCC,ALU_VECTOR
	      
	      default: begin
		 brch_o <= 1'b0;
		 pc_o <= xxxx;
		 add_c_o <= esc;
		 dat_c_o <= xxxx;
		 
	      end
	      
	    endcase // case(alu_i)
	   
	   6'h3F: begin
	      add_c_o <= esc;
	      dat_c_o <= xxxx;
	      brch_o <= 1'b0;
	      pc_o <= xxxx;
	   end
	   
	   default: 
	     if (~brch) begin
		brch_o <= 1'b0;
		pc_o <= xxxx;
		
		case (alu_i)
		  ALU_NOP: begin
		     add_c_o <= esc;
		     dat_c_o <= xxxx;
		  end
		  default: begin
		     // Store the Result
		     add_c_o <= add_c_i;
		     dat_c_o <= res_i;
		  end
		endcase // case(alu_i)
	     end else begin
		add_c_o <= esc;
		dat_c_o <= xxxx;
		brch_o <= 1'b0;
		pc_o <= zero;
	     end // else: !if(~brch)
	   
	 endcase // case(add_c_i)
	 
      end // else: !if(rst_i)
      
   end // always @ (...

   // ***************************************************************
   // ***************************************************************
   // ***************************************************************
      
endmodule // k68_decode
