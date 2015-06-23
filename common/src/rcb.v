/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Request crossbar for wormhole and SDM routers.
 *** SystemVerilog is used ***
 
 History:
 10/12/2009  Initial version. <wsong83@gmail.com>
 23/05/2011  Use SystemVerilog for wire declaration. <wsong83@gmail.com>
 27/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module rcb (/*AUTOARG*/
   // Outputs
   ira, oreq,
   // Inputs
   ireq, ora, cfg
   ) ;
   // parameters
   parameter NN = 1;	      // number of input ports
   parameter MN = 1;	      // number of output ports
   parameter DW = 1;	      // datawidth a port

   input [NN-1:0][DW-1:0]     ireq; // input requests
   output [NN-1:0] 	      ira;  // ack for input requests
   output [MN-1:0][DW-1:0]    oreq; // output requests
   input [MN-1:0] 	      ora;  // ack for output requests
   input [MN-1:0][NN-1:0]     cfg;  // the crossbar configuration
   
   wire [MN-1:0][DW-1:0][NN-1:0] m; // the internal wires for requests
   wire [NN-1:0][MN-1:0] 	 ma; // the internal wires for acks
 
   // generate variable
   genvar 		      i, j, k;

   // request matrix
   generate
      for (i=0; i<MN; i++) begin: EN
	 for (j=0; j<DW; j++) begin: SC
	    for (k=0; k<NN; k++) begin: IP
	       and AC (m[i][j][k], ireq[k][j], cfg[i][k]);
	    end
	    
	    // the OR gates
	    assign oreq[i][j] = |m[i][j];
	 end
      end
   endgenerate

   // ack matrix
   generate
      for (k=0; k<NN; k++) begin: ENA
	 for (i=0; i<MN; i++) begin: OP
	    and AC (ma[k][i], ora[i], cfg[i][k]);
	 end
	 
	 // the OR gates
	 assign ira[k] = |ma[k];
      end
   endgenerate
   
endmodule // rcb


