/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 C-element tree, usually for common ack generation.
 *** SystemVerilog is used ***
 
 History:
 17/04/2011  Initial version. <wsong83@gmail.com>
 23/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module ctree (/*AUTOARG*/
   // Outputs
   co,
   // Inputs
   ci
   );

   parameter DW = 2;		// the total number of leaves of the C-element tree

   input [DW-1:0] ci;		// all input leaves
   output         co;		// the combined output

   wire [2*DW-2:0] dat;
   genvar 	   i;
   
   assign dat[DW-1:0] = ci;
   
   generate for (i=0; i<DW-1; i=i+1) begin:AT
       c2 CT (.a0(dat[i*2]), .a1(dat[i*2+1]), .q(dat[i+DW]));
   end endgenerate

   assign co = dat[2*DW-2];

endmodule // ctree

