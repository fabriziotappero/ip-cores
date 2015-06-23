/* SXP Arithmetic Logic Unit
 *
 * Bob Hoffman
 *
 */

module alu     (opcode,		// alu function select
		a,		// a operand
		b,		// b operand
		cin,		// carry input
		ya,		// data output
		yb,		// data output
		cvnz_a,		// a output flags
		cvnz_b		// b output flags
	       );


input [2:0] opcode;
input [31:0] a;
input [31:0] b;
input cin;
output [31:0] ya;
reg [31:0] ya;
output [31:0] yb;
reg [31:0] yb;
output [3:0] cvnz_a;
output [3:0] cvnz_b;


// Flags:  c: indicates that a carry has occurred
//         z: indicates that the result is zero
//         v: indicates that an overflow has occurred
//	   n: indicates a negative result

reg  c_flag_a;		// c flag for output a
reg  v_flag_a;		// v flag for output a
wire n_flag_a;		// n flag for output a
wire z_flag_a;		// z flag for output a
reg  c_flag_b;		// c flag for output b
reg  v_flag_b;		// v flag for output b
wire n_flag_b;		// n flag for output b
wire z_flag_b;		// z flag for output b

assign cvnz_a = {c_flag_a, v_flag_a, n_flag_a, z_flag_a};
assign cvnz_b = {c_flag_b, v_flag_b, n_flag_b, z_flag_b};

wire [31:0] b_se;	// b input sign extended from 16-bits


// Operations:
//
// Opcode	 Function	     ya		     yb
// ------	----------	-------------	-------------
//  000		 pass		     a               b
//  001		 add		   a + b           a + b(se)
//  010		 sub		   a - b           a - b(se)
//  011		 mult		a * b [31:0]	a * b [63:32]
//  100		 and/or		   a & b	   a | b
//  101		 xor/xnor	   a ^ b	 ~(a ^ b)
//  110		(reserved)	    ---		    ---
//  111		 flip_pass      a[15:0,31:16]   b[15:0,31:16]


assign b_se = {{16{b[15]}}, b[15:0]};


always @(opcode or a or b or b_se or cin)
  begin
    ya = 'b 0;
    yb = 'b 0;
    c_flag_a = 'b 0;
    v_flag_a = 'b 0;
    c_flag_b = 'b 0;
    v_flag_b = 'b 0;

    case (opcode)
      3'd 0: begin	// pass through (similar to a noop)
          ya = a;
          yb = b;
        end
      3'd 1: begin	// add
          {c_flag_a, ya} = a + b + cin;
          {c_flag_b, yb} = a + b_se + cin;
	  v_flag_a = (~a[31] && ~b[31] && ya[31]) || (a[31] && b[31] && ~ya[31]);
	  v_flag_b = (~a[31] && ~b_se[31] && yb[31]) || (a[31] && b_se[31] && ~yb[31]);
        end
      3'd 2: begin	// subtract
          ya = a - b - cin;
          yb = a - b_se - cin;
	  if(b + cin > a)
	    c_flag_a = 1'b 1;
	  if(b_se + cin > a)
	    c_flag_b = 1'b 1;
	  v_flag_a = (~a[31] & b[31] & ya[31]) || (a[31] & ~b[31] & ~ya[31]);
	  v_flag_b = (~a[31] & b[31] & yb[31]) || (a[31] & ~b[31] & ~yb[31]);
        end
      3'd 3: begin	//mult
	  {yb, ya} = a * b;
        end
      3'd 4: begin	// logical and / or of a, b
          ya = a & b;
          yb = a | b;
        end
      3'd 5: begin	// logical xor of a, b
          ya = a ^ b;
          yb = ~(a ^ b);
        end
      3'd 7: begin	// byte-flipped pass through
          ya = {a[15:0], a[31:16]};
          yb = {b[15:0], b[31:16]};
        end
    endcase
  end

assign n_flag_a = ya[31];
assign z_flag_a = !ya;
assign n_flag_b = yb[31];
assign z_flag_b = !yb;

endmodule


/*
 *  $Id: alu_r.v,v 1.1 2001-10-26 21:29:34 bobh Exp $ 
 *  Module : alu_r.v
 *  Scope : Arithmetic Logic Unit
 *  Author : Bob Hoffman
 *  Function : Arithmetic Logic Unit
 *
 *  Issues :  1. Multiply is unsigned.
 *  $Log: not supported by cvs2svn $
 */
