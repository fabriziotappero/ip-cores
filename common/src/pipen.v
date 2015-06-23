/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 A single 4-phase 1-of-n pipeline stage.
 
 History:
 05/05/2009  Initial version. <wsong83@gmail.com>
 01/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module pipen(/*AUTOARG*/
   // Outputs
   d_in_a, d_out,
   // Inputs
   d_in, d_out_a
   );

   parameter DW = 4;		// the wire count, the "n" of the 1-of-n code
       
   input [DW-1:0]   d_in;
   output 	    d_in_a;
   output [DW-1:0]  d_out;
   input 	    d_out_a;

   genvar 	    i;
   
   // the data pipe stage
   generate for (i=0; i<DW; i=i+1) begin:DD
       dc2 DC  (.d(d_in[i]),       .a(d_out_a),   .q(d_out[i]));
   end endgenerate

   assign d_in_a = |d_out;

endmodule // pipen
