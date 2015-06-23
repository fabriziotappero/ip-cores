/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 M-to-1 asynchronous multi-way MUTEX arbiter.
 
 History:
 24/05/2009  Initial version. <wsong83@gmail.com>
 23/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module mutex_arb (/*AUTOARG*/
   // Outputs
   gnt,
   // Inputs
   req
   );
   
   parameter wd = 4;		// the number of request inputs

   input  [wd-1:0]    req;
   output [wd-1:0]    gnt;

   genvar 	      i,j;
   
   wire [wd-1:0]      arb_w [wd-1:0];
   wire [wd-1:0]      gnt;
   
   generate 
      for(i=0; i<wd; i=i+1) begin:lv
         for(j=i+1; j<wd; j=j+1) begin:b
            mutex2 ME ( .a(arb_w[i][j-1]),     .b(arb_w[j][i]),  .qa(arb_w[i][j]),     .qb(arb_w[j][i+1]));
         end
         assign arb_w[i][0] = req[i];
         assign gnt[i] = arb_w[i][wd-1];
      end
   endgenerate
   
endmodule // mutex_arb

