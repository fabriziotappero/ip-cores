/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Flow control unit.
 
 History:
 31/03/2010  Initial version. <wsong83@gmail.com>
 12/05/2010  Use MPxP crossbar. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module fcctl ( /*AUTOARG*/
   // Outputs
   afc, ro,
   // Inputs
   credit, ri, rst
   );
   parameter VCN = 2;		// number of VCs per direction
   parameter PD = 3;		// depth of an input VC buffer
   
   input [VCN-1:0]  credit;	// credit input from the next router
   output [VCN-1:0] afc;	// ack for the credit input
   input [VCN-1:0]  ri;		// VC request from VCA
   output [VCN-1:0] ro;		// credit grant output
   input 	    rst;	// active high reset

   wire [PD:0][VCN-1:0] cp, cpa;

   genvar 		  i,j;

   // the credit pipeline
   generate
      for(i=0; i<PD; i++) begin: P
	 for(j=0; j<VCN; j++) begin: V
	    cpipe CP (.cia(cpa[i][j]), .co(cp[i+1][j]), .rst(rst), .ci(cp[i][j]), .coa(cpa[i+1][j]));
	 end
      end
   endgenerate

   // grant a credit to a VC request
   generate
      for(i=0; i<VCN; i++) begin:R
	 dc2 CR (.a(ri[i]), .d(cp[PD][i]), .q(cpa[PD][i]));
      end
   endgenerate	 

   assign ro = cpa[PD];
   assign cp[0] = credit;
   assign afc = cpa[0];

endmodule // fcctl

   