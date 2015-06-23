/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Demux for a 1-of-n buffer stage.  
 
 History:
 31/03/2010  Initial version. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 09/06/2011  Make sure the sel pin is considered in the ack process. <wsong83@gmail.com>
 
*/

module ddmux ( /*AUTOARG*/
   // Outputs
   d_in_a, d_out,
   // Inputs
   d_in, d_sel, d_out_a
   );
   parameter VCN = 2;		// number of output VCs
   parameter DW = 32;		// data width of the input

   input [DW-1:0]   d_in;
   input [VCN-1:0]  d_sel;
   output 	    d_in_a;

   output [VCN-1:0][DW-1:0]  d_out;
   input  [VCN-1:0]	     d_out_a;
      
   genvar 		      i,j;

   /*
   generate
      for (i=0; i<VCN; i++) begin: VCD
	 for(j=0; j<DW; j++) begin: D
	    c2 C (.a0(d_in[j]), .a1(d_sel[i]), .q(d_out[i][j]));
	 end
      end
   endgenerate
    */
   
   generate
      for (i=0; i<VCN; i++) begin: VCD
	 assign d_out[i] = d_sel[i] ? d_in : 0;
      end
   endgenerate   
   
   //assign d_in_a = |d_out_a;
   c2 CACK (.a0(|d_out_a), .a1(|d_sel), .q(d_in_a));

endmodule // ddmux

