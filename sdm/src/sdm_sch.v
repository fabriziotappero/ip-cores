/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Crossbar based SDM switch allocator
 *** SystemVerilog is used ***
 
 References
 For the detail structure, please refer to Section 6.3.1 of the thesis:
   Wei Song, Spatial parallelism in the routers of asynchronous on-chip networks, PhD thesis, the University of Manchester, 2011.
  
 History:
 28/09/2009  Initial version. <wsong83@gmail.com>
 27/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module sdm_sch (/*AUTOARG*/
   // Outputs
   sack, wack, nack, eack, lack, scfg, ncfg, wcfg, ecfg, lcfg,
   // Inputs
   sreq, nreq, lreq, wreq, ereq, rst_n
   );
   
   parameter VCN = 2;		// the number of virtual circuits per port

   // income requests
   input [VCN-1:0][3:0]            sreq, nreq, lreq;
   input [VCN-1:0][1:0] 	   wreq, ereq;

   // ack to input buffers
   output [VCN-1:0] 		   sack, wack, nack, eack, lack;

   // configuration to the crossbar
   output [VCN-1:0][1:0][VCN-1:0]  scfg, ncfg;
   output [VCN-1:0][3:0][VCN-1:0]  wcfg, ecfg, lcfg;

   input 			   rst_n; // active low global reset

   // requests to arbiters
`ifndef ENABLE_MRMA
   wire [1:0][VCN-1:0][VCN-1:0]    r2s, r2n; // shuffle the incoming request signals
   wire [3:0][VCN-1:0][VCN-1:0]    r2w, r2e, r2l;
`else
   wire [1:0][VCN-1:0] 		   r2s, r2n; // shuffle the incoming request signals
   wire [3:0][VCN-1:0] 		   r2w, r2e, r2l;
`endif   

   // ack from arbiters
   wire [VCN-1:0][3:0] 		   a2s, a2n, a2l;
   wire [VCN-1:0][1:0] 		   a2w, a2e;

   // ack of the arbiters
   wire [1:0][VCN-1:0] 		   r2sa, r2na;
   wire [3:0][VCN-1:0] 		   r2wa, r2ea, r2la;

`ifdef ENABLE_MRMA
   wire [VCN:0] 		   OPrst_n; // the buffered resets to avoid metastability
   wire [VCN-1:0] 		   SOPrdy, SOPblk; // OP ready and blocked status
   wire [VCN-1:0] 		   WOPrdy, WOPblk; // OP ready and blocked status
   wire [VCN-1:0] 		   NOPrdy, NOPblk; // OP ready and blocked status
   wire [VCN-1:0] 		   EOPrdy, EOPblk; // OP ready and blocked status
   wire [VCN-1:0] 		   LOPrdy, LOPblk; // OP ready and blocked status
`endif
  
   genvar 			   i,j;

   // wire shuffle
   generate for(i=0; i<VCN; i++) begin: SHUF
`ifndef ENABLE_MRMA
      for(j=0; j<VCN; j++) begin: CO
	 assign r2s[0][i][j] = nreq[i][0];
	 assign r2s[1][i][j] = lreq[i][0];
	 assign r2w[0][i][j] = sreq[i][0];
	 assign r2w[1][i][j] = nreq[i][1];
	 assign r2w[2][i][j] = ereq[i][0];
	 assign r2w[3][i][j] = lreq[i][1];
	 assign r2n[0][i][j] = sreq[i][1];
	 assign r2n[1][i][j] = lreq[i][2];
	 assign r2e[0][i][j] = sreq[i][2];
	 assign r2e[1][i][j] = wreq[i][0];
	 assign r2e[2][i][j] = nreq[i][2];
	 assign r2e[3][i][j] = lreq[i][3];
	 assign r2l[0][i][j] = sreq[i][3];
	 assign r2l[1][i][j] = wreq[i][1];
	 assign r2l[2][i][j] = nreq[i][3];
	 assign r2l[3][i][j] = ereq[i][1];
      end // block: CO
`else // !`ifndef ENABLE_MRMA
      assign r2s[0][i] = nreq[i][0];
      assign r2s[1][i] = lreq[i][0];
      assign r2w[0][i] = sreq[i][0];
      assign r2w[1][i] = nreq[i][1];
      assign r2w[2][i] = ereq[i][0];
      assign r2w[3][i] = lreq[i][1];
      assign r2n[0][i] = sreq[i][1];
      assign r2n[1][i] = lreq[i][2];
      assign r2e[0][i] = sreq[i][2];
      assign r2e[1][i] = wreq[i][0];
      assign r2e[2][i] = nreq[i][2];
      assign r2e[3][i] = lreq[i][3];
      assign r2l[0][i] = sreq[i][3];
      assign r2l[1][i] = wreq[i][1];
      assign r2l[2][i] = nreq[i][3];
      assign r2l[3][i] = ereq[i][1];
`endif // !`ifndef ENABLE_MRMA
      assign a2s[i][0] = r2wa[0][i];
      assign a2s[i][1] = r2na[0][i];
      assign a2s[i][2] = r2ea[0][i];
      assign a2s[i][3] = r2la[0][i];
      assign a2w[i][0] = r2ea[1][i];
      assign a2w[i][1] = r2la[1][i];
      assign a2n[i][0] = r2sa[0][i];
      assign a2n[i][1] = r2wa[1][i];
      assign a2n[i][2] = r2ea[2][i];
      assign a2n[i][3] = r2la[2][i];
      assign a2e[i][0] = r2wa[2][i];
      assign a2e[i][1] = r2la[3][i];
      assign a2l[i][0] = r2sa[1][i];
      assign a2l[i][1] = r2wa[3][i];
      assign a2l[i][2] = r2na[1][i];
      assign a2l[i][3] = r2ea[3][i];
      assign sack[i] = |a2s[i];
      assign wack[i] = |a2w[i];
      assign nack[i] = |a2n[i];
      assign eack[i] = |a2e[i];
      assign lack[i] = |a2l[i];

   end // block: SHUF
   endgenerate

   // output port arbiter/allocators
`ifndef ENABLE_MRMA
   mnma #(.N(2*VCN), .M(VCN))
   SCBA (
	 .r     ( r2s    ),
	 .ra    ( r2sa   ),
	 .cfg   ( scfg   )
	 );

   mnma #(.N(4*VCN), .M(VCN))
   WCBA (
	 .r     ( r2w    ),
	 .ra    ( r2wa   ),
	 .cfg   ( wcfg   )
	 );

   mnma #(.N(2*VCN), .M(VCN))
   NCBA (
	 .r     ( r2n    ),
	 .ra    ( r2na   ),
	 .cfg   ( ncfg   )
	 );

   mnma #(.N(4*VCN), .M(VCN))
   ECBA (
	 .r     ( r2e    ),
	 .ra    ( r2ea   ),
	 .cfg   ( ecfg   )
	 );

   mnma #(.N(4*VCN), .M(VCN))
   LCBA (
	 .r     ( r2l    ),
	 .ra    ( r2la   ),
	 .cfg   ( lcfg   )
	 );
`else // !`ifndef ENABLE_MRMA
   mrma #(.N(2*VCN), .M(VCN))
   SCBA (
	 .ca    ( r2sa   ),
	 .ra    ( SOPblk ),
	 .cfg   ( scfg   ),
	 .c     ( r2s    ),
	 .r     ( SOPrdy ),
	 .rst_n ( rst_n  )
	 );

   mrma #(.N(4*VCN), .M(VCN))
   WCBA (
	 .ca    ( r2wa   ),
	 .ra    ( WOPblk ),
	 .cfg   ( wcfg   ),
	 .c     ( r2w    ),
	 .r     ( WOPrdy ),
	 .rst_n ( rst_n  )
	 );

   mrma #(.N(2*VCN), .M(VCN))
   NCBA (
	 .ca    ( r2na   ),
	 .ra    ( NOPblk ),
	 .cfg   ( ncfg   ),
	 .c     ( r2n    ),
	 .r     ( NOPrdy ),
	 .rst_n ( rst_n  )
	 );

   mrma #(.N(4*VCN), .M(VCN))
   ECBA (
	 .ca    ( r2ea   ),
	 .ra    ( EOPblk ),
	 .cfg   ( ecfg   ),
	 .c     ( r2e    ),
	 .r     ( EOPrdy ),
	 .rst_n ( rst_n  )
	 );
   
   mrma #(.N(4*VCN), .M(VCN))
   LCBA (
	 .ca    ( r2la   ),
	 .ra    ( LOPblk ),
	 .cfg   ( lcfg   ),
	 .c     ( r2l    ),
	 .r     ( LOPrdy ),
	 .rst_n ( rst_n  )
	 );
   
   generate
      for(i=0; i<VCN; i++) begin: OPC
	 delay DLY ( .q(OPrst_n[i+1]), .a(OPrst_n[i])); // dont touch
	 assign SOPrdy[i] = (~SOPblk[i])&OPrst_n[i+1];
	 assign WOPrdy[i] = (~WOPblk[i])&OPrst_n[i+1];
	 assign NOPrdy[i] = (~NOPblk[i])&OPrst_n[i+1];
	 assign EOPrdy[i] = (~EOPblk[i])&OPrst_n[i+1];
	 assign LOPrdy[i] = (~LOPblk[i])&OPrst_n[i+1];
      end
   endgenerate

   assign OPrst_n[0] = rst_n;
   
`endif // !`ifndef ENABLE_MRMA
   
endmodule // sdm_sch
