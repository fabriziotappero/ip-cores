/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 IM allocator (the IM dispatcher in the thesis)
 *** SystemVerilog is used ***
 
 References
 For the detail structure, please refer to Section 6.3.1 of the thesis:
   Wei Song, Spatial parallelism in the routers of asynchronous on-chip networks, PhD thesis, the University of Manchester, 2011.
  
 History:
 05/09/2009  Initial version. <wsong83@gmail.com>
 10/10/2009  Add the reset port. <wsong83@gmail.com>
 05/11/2009  Speed up the arbiter. <wsong83@gmail.com>
 10/06/2010  [Major] change to use PIM structure. <wsong83@gmail.com>
 23/08/2010  Fix the non-QDI request withdraw process. <wsong83@gmail.com>
 27/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module im_alloc (/*AUTOARG*/
`ifndef ENABLE_CRRD
   CMs,
`endif
   // Outputs
   IMa, cfg,
   // Inputs
   IMr, rst_n
   ) ;
   // parameters
   parameter VCN = 2;	 // the number of virtual circuits on one port
   parameter CMN = 2;	 // the number of central modules
   parameter SN = 2;	 // the possible output port choice of a port

   input  [VCN-1:0][SN-1:0]     IMr; // the requests from virtual circuits
   output [VCN-1:0] 		IMa; // switch ready, ack for the request

`ifndef ENABLE_CRRD
   input [CMN-1:0][SN-1:0] 	CMs; // the states from CMs
`endif
   
   input 			rst_n; // the negtive active reset

   output [CMN-1:0][VCN-1:0] 	cfg; // the matrix configuration signals

   // internal wires
`ifdef ENABLE_CRRD
 `ifdef ENABLE_MRMA
   wire [VCN-1:0] 		IPr; // request to the MRMA
   wire [CMN-1:0]               OPrdy, OPblk; // OP ready and blocked status
   wire [CMN:0] 		OPrst_n; // the buffered resets to avoid metastability
 `else
   wire [VCN-1:0][CMN-1:0] 	IPr; // request to the MNMA
 `endif
`else
   // using the feedback from CMs
   wire [VCN-1:0][CMN-1:0][SN-1:0] IPrm; // to generate the practical IPr
   wire [VCN-1:0][CMN-1:0] 	   IPr;        
`endif
   
   // generate variables
   genvar 		   i, j, k;

   //----------------------------------------
   // the PIM crossbar allocator
`ifndef ENABLE_MRMA
   mnma #(.N(VCN), .M(CMN))
   PIMA (
	 .cfg ( cfg   ),
	 .r   ( IPr   ),
	 .ra  ( IMa   )
	 );

   generate
      for(i=0; i<VCN; i++) begin: IPC
	 for(j=0; j<CMN; j++) begin: OPC
 `ifdef ENABLE_CRRD
	    assign IPr[i][j] = |IMr[i];
 `else
	    assign IPr[i][j] = |IPrm[i][j];
	    for(k=0; k<SN; k++) begin: DIRC
	       c2p IPRen (.q(IPrm[i][j][k]), .a(IMr[i][k]), .b(~CMs[j][k]));
	    end
 `endif
	 end
      end // block: IPC
   endgenerate
   
`else
   mrma #(.N(VCN), .M(CMN))
   PIMA (
	 .ca    ( IMa   ),
	 .ra    ( OPblk ),
	 .cfg   ( cfg   ),
	 .c     ( IPr   ),
	 .r     ( OPrdy ),
	 .rst_n ( rst_n )
	 );
   
   generate
      for(i=0; i<CMN; i++) begin: OPC
	 delay DLY ( .q(OPrst_n[i+1]), .a(OPrst_n[i])); // dont touch
	 assign OPrdy[i] = (~OPblk[i])&OPrst_n[i+1];
      end

      for(i=0; i<VCN; i++) begin: IPC
	 assign IPr[i] = |IMr[i];
      end
   endgenerate
   
   assign OPrst_n[0] = rst_n;
   
`endif // !`ifndef ENABLE_MRMA
   
endmodule // im_alloc
