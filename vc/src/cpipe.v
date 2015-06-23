/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The full dual-rail pipeline stage for the credit fifo in VC routers.
 It has a reset pin to feed a token into every cpipe stage. 
 
 History:
 31/03/2010  Initial version. <wsong83@gmail.com>
 01/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module cpipe (/*AUTOARG*/
   // Outputs
   cia, co,
   // Inputs
   rst, ci, coa
   );
   
   input rst;			// active high reset
   input ci;			// credit input
   output cia;			// credit input ack
   output co;			// credit output
   input  coa;			// credit output ack

   wire   c0, c1;		// internal wires

   dc2 C0 ( .d(ci), .a(~c1), .q(c0));
   dc2 C1 ( .d(c0|rst), .a((~coa)|rst), .q(c1));

   assign co = (~rst)&c1;
   assign cia = c0;

endmodule // cpipe
