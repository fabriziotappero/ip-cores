/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 A synthesizable cell library for asynchronous circuis.
 Some cell are directly initialized to one of the Nangate 45nm cell lib.
 
 History:
 05/05/2009  Initial version. <wsong83@gmail.com>
 20/05/2011  Change to general verilog description for opensource. 
             The Nangate cell library is used. <wsong83@gmail.com>
 01/06/2011  The bugs in the C2 and C2P1 gates are fixed. <wsong83@gmail.com>
*/

// General 2-input C-element
module c2 (a0, a1, q);

   input a0, a1;		// two inputs
   output q;			// output

   wire [2:0] m;		// internal wires

   nand U1 (m[0], a0, a1);
   nand U2 (m[1], a0, q);
   nand U3 (m[2], a1, q);
   assign q = ~&m;
   
endmodule

// the 2-input C-element on data paths, different name for easy synthesis scription
module dc2 (d, a, q);

   input d;			// data input
   input a;			// ack input
   output q;			// data output

   wire [2:0] m;		// internal wires

   nand U1 (m[0], a, d);
   nand U2 (m[1], d, q);
   nand U3 (m[2], a, q);
   assign q = ~&m;

endmodule

// 2-input C-element with a minus input
module c2n (a, b, q);

   input a;			// the normal input
   input b;			// the minus input
   output q;			// output

   wire m;			// internal wire
   
   and U1 (m, b, q);
   or  U2 (q, m, a);
   
endmodule

// 2-input C-element with a plus input
module c2p (a, b, q);

   input a;			// the normal input
   input b;			// the plus input
   output q;			// output

   wire m;			// internal wire

   or  U1 (m, b, q);
   and U2 (q, m, a);
   
endmodule

// 2-input MUTEX cell, Nangate
module mutex2 ( a, b, qa, qb );	// !!! dont touch !!!

   input a, b;			// request inputs
   output qa, qb;		// grant outputs

   wire   qan, qbn;		// internal wires

   NAND2_X2 U1 ( .A1(a), .A2(qbn), .ZN(qan) ); // different driving strength for fast convergence
   NOR3_X2  U2 ( .A1(qbn), .A2(qbn), .A3(qbn), .ZN(qb) ); // pulse filter
   NOR3_X2  U3 ( .A1(qan), .A2(qan), .A3(qan), .ZN(qa) ); // pulse filter
   NAND2_X1 U4 ( .A1(b), .A2(qan), .ZN(qbn) );

endmodule

// 3-input C-element with a plus input
module c2p1 (a0, a1, b, q); 
   
   input a0, a1;		// normal inputs
   input b;			// plus input
   output q;			// output
                   
   wire [2:0] m;		// internal wires

   nand U1 (m[0], a0, a1, b);
   nand U2 (m[1], a0, q);
   nand U3 (m[2], a1, q);
   assign q = ~&m;

endmodule                    

// the basic element of a tree arbiter
module tarb ( ngnt, ntgnt, req, treq );

   input [1:0] req;		// request input
   output [1:0] ngnt;		// the negative grant output
   output treq;			// combined request output
   input ntgnt;			// the negative combined grant input
  
   wire  n1, n2;		// internal wires
   wire [1:0] mgnt;		// outputs of the MUTEX

   mutex2 ME ( .a(req[0]), .b(req[1]), .qa(mgnt[0]), .qb(mgnt[1]) );
   c2n C0 ( .a(ntgnt), .b(n2), .q(ngnt[0]) );
   c2n C1 ( .a(ntgnt), .b(n1), .q(ngnt[1]) );
   nand U1 (treq, n1, n2);
   nand U2 (n1, ngnt[0], mgnt[1]);
   nand U3 (n2, ngnt[1], mgnt[0]);
endmodule

// the tile in a multi-resource arbiter
module cr_blk ( bo, hs, cbi, rbi, rg, cg );

   input rg, cg;		// input requests
   input cbi, rbi;		// input blockage
   output bo;			// output blockage
   output hs;			// match result
  
   wire   blk;			// internal wire

   c2p1 XG ( .a0(rg), .a1(cg), .b(blk), .q(bo) );
   c2p1 HG ( .a0(cbi), .a1(rbi), .b(bo), .q(hs) );
   nor U1 (blk, rbi, cbi);

endmodule

// a data latch template, Nangate
module dlatch ( q, qb, d, g);
   output q, qb;
   input  d, g;

   DLH_X1 U1 (.Q(q), .D(d), .G(g));
endmodule

// a delay line, Nangate
module delay (q, a);
   input a;
   output q;
   
   BUF_X2 U (.Z(q), .A(a));
endmodule

   