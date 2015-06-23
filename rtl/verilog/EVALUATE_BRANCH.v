// ============================================================================
//  EVALUATE_BRANCH.v
//  Evaluate branch condition
//
//
//  (C) 2009,2010  Robert Finch
//  Stratford
//  robfinch[remove]@opencores.ca
//
//  
//  This source code is available for evaluation and validation purposes
//  only. This copyright statement and disclaimer must remain present in
//  the file.
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//  EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//  Work.
//
//  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//  IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//  IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//  REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//  LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//  AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//  LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//  Verilog 
//
// ============================================================================
//
`ifndef JMPS
`define JMPS	8'hEB
`endif

`ifndef JO
`define JO		8'h70
`define JNO		8'h71
`define JB		8'h72
`define JAE		8'h73
`define JE		8'h74
`define JNE		8'h75
`define JBE		8'h76
`define JA		8'h77
`define JS		8'h78
`define JNS		8'h79
`define JP		8'h7A
`define JNP		8'h7B
`define JL		8'h7C
`define JNL		8'h7D
`define JLE		8'h7E
`define JNLE	8'h7F

`define JNA		8'h76
`define JNAE	8'h72
`define JNB     8'h73
`define JNBE    8'h77
`define JC      8'h72
`define JNC     8'h73
`define JG		8'h7F
`define JNG		8'h7E
`define JGE		8'h7D
`define JNGE	8'h7C
`define JPE     8'h7A
`define JPO     8'h7B

`define LOOPNZ	8'hE0
`define LOOPZ	8'hE1
`define LOOP	8'hE2
`define JCXZ	8'hE3

`endif

module evaluate_branch(ir,cx,zf,cf,sf,vf,pf,take_br);
input [7:0] ir;
input [15:0] cx;
input zf,cf,sf,vf,pf;
output take_br;

reg take_br;
wire cxo = cx==16'h0001;	// CX is one
wire cxz = cx==16'h0000;	// CX is zero

always @(ir or cx or cxz or cxo or zf or cf or sf or vf or pf)
	case(ir)
	`JMPS:		take_br <= 1'b1;
	`JP:		take_br <=  pf;
	`JNP:		take_br <= !pf;
	`JO:		take_br <=  vf;
	`JNO:		take_br <= !vf;
	`JE:		take_br <=  zf;
	`JNE:		take_br <= !zf;
	`JAE:		take_br <= !cf;
	`JB:		take_br <=  cf;
	`JS:		take_br <=  sf;
	`JNS:		take_br <= !sf;
	`JBE:		take_br <=  cf | zf;
	`JA:		take_br <= !cf & !zf;
	`JL:		take_br <= sf ^ vf;
	`JNL:		take_br <= !(sf ^ vf);
	`JLE:		take_br <= (sf ^ vf) | zf;
	`JNLE:		take_br <= !((sf ^ vf) | zf);
	`JCXZ:		take_br <= cxz;
	`LOOP:		take_br <= !cxo;
	`LOOPZ:		take_br <= !cxo && zf;
	`LOOPNZ:	take_br <= !cxo && !zf;
	default:	take_br <= 1'b0;
	endcase

endmodule
