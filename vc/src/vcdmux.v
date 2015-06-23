/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Demux for a VC buffer stage.  
 
 History:
 31/03/2010  Initial version. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 09/06/2011  Make sure the sel pin is considered in the ack process. <wsong83@gmail.com>

*/

module vcdmux ( /*AUTOARG*/
   // Outputs
   dia, do0, do1, do2, do3, dot,
   // Inputs
   di0, di1, di2, di3, dit, divc, doa
   );
   parameter VCN = 2;		// number of output VCs
   parameter DW = 32;		// data width of the input
   parameter SCN = DW/2;

   input [SCN-1:0]  di0, di1, di2, di3;
   input [2:0] 	    dit;
   input [VCN-1:0]  divc;
   output 	    dia;

   output [VCN-1:0][SCN-1:0] do0, do1, do2, do3;
   output [VCN-1:0][2:0]     dot;
   input  [VCN-1:0]	     doa;
      
   genvar 		      i,j;

   /*
   generate
      for (i=0; i<VCN; i++) begin: VCD
	 for(j=0; j<SCN; j++) begin: D
	    c2 C0 (.a0(di0[j]), .a1(divc[i]), .q(do0[i][j]));
	    c2 C1 (.a0(di1[j]), .a1(divc[i]), .q(do1[i][j]));
	    c2 C2 (.a0(di2[j]), .a1(divc[i]), .q(do2[i][j]));
	    c2 C3 (.a0(di3[j]), .a1(divc[i]), .q(do3[i][j]));
	 end
	 
	 for(j=0; j<3; j++) begin: T
	    c2 C0 (.a0(dit[j]), .a1(divc[i]), .q(dot[i][j]));
	 end
      end
   endgenerate
    */
   
   generate
      for (i=0; i<VCN; i++) begin: VCD
	 assign do0[i] = divc[i] ? di0 : 0;
	 assign do1[i] = divc[i] ? di1 : 0;
	 assign do2[i] = divc[i] ? di2 : 0;
	 assign do3[i] = divc[i] ? di3 : 0;
	 assign dot[i] = divc[i] ? dit : 0;
      end
   endgenerate   

   //assign dia = |doa;
   c2 CACK (.a0(|doa), .a1(|divc), .q(dia));

endmodule // vcdmux

