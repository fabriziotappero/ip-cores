/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Clos scheduler
 *** SystemVerilog is used ***
 
 References
 For the detail structure, please refer to Section 6.3.1 of the thesis:
   Wei Song, Spatial parallelism in the routers of asynchronous on-chip networks, PhD thesis, the University of Manchester, 2011.
  
 History:
 11/12/2009  Initial version. <wsong83@gmail.com>
 10/06/2010  Change to use PIM structure <wsong83@gmail.com>
 23/08/2010  Fix the non-QDI request withdraw process <wsong83@gmail.com>
 23/09/2010  Modified for Clos SDM router <wsong83@gmail.com>
 27/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module clos_sch (/*AUTOARG*/
   // Outputs
   sack, wack, nack, eack, lack, imc, scfg, ncfg, wcfg, ecfg, lcfg,
   // Inputs
   sreq, nreq, lreq, wreq, ereq, rst_n
   );

   parameter M = 2;		// the number of CMs
   parameter N = 2;		// the number of ports in IMs/OMs

   // reuests from all input buffers
   input [N-1:0][3:0]             sreq, nreq, lreq;
   input [N-1:0][1:0] 		  wreq, ereq;

   // ack to input buffers
   output [N-1:0] 		  sack, wack, nack, eack, lack;

   // IM acks
   wire [4:0][N-1:0] 		  imra;
   wire [4:0][N-1:0] 		  cmra;

   // IM cfgs and CM cfgs
   output [4:0][M-1:0][N-1:0] 	  imc;
   output [M-1:0][1:0] 		  scfg, ncfg;
   output [M-1:0][3:0] 		  wcfg, ecfg, lcfg;

   input 			  rst_n;	// reset, active low

   // the requests from IMs to CMs
   wire [M-1:0][1:0] 		  wr, er;
   wire [M-1:0][3:0] 		  sr, nr, lr;
   wire [M-1:0] 		  sra, wra, nra, era, lra; 		  
   
`ifndef ENABLE_CRRD
   wire [M-1:0][4:0] 		  cms;          // the states from CMs

   wire [M-1:0][3:0] 		  scms, ncms, lcms;
   wire [M-1:0][1:0] 		  wcms, ecms;
`endif	       
   
   genvar 			  i;

   // IM schedulers
   im_alloc #(.VCN(N), .CMN(M), .SN(4))
   SIM (
	.IMr   ( sreq      ),
	.IMa   ( imra[0]   ),
`ifndef ENABLE_CRRD
	.CMs   ( scms      ),
`endif	       
	.cfg   ( imc[0]    ),
	.rst_n ( rst_n     )
	);
   
   rcb #(.NN(N), .MN(M), .DW(4))
   SRIM (
	 .ireq ( sreq      ),
	 .ira  ( cmra[0]   ),
	 .oreq ( sr        ),
	 .ora  ( sra       ),
	 .cfg  ( imc[0]    )
	 );

   // the C-element to force the request withdrawal sequence
   generate for(i=0; i<N; i++) begin: SA
      c2 UA (.q(sack[i]), .a0(imra[0][i]), .a1(cmra[0][i]));
   end endgenerate

   im_alloc #(.VCN(N), .CMN(M), .SN(2))
   WIM (
	.IMr   ( wreq      ),
	.IMa   ( imra[1]   ),
`ifndef ENABLE_CRRD
	.CMs   ( wcms      ),
`endif	       
	.cfg   ( imc[1]    ),
	.rst_n ( rst_n     )
	);

   rcb #(.NN(N), .MN(M), .DW(2))
   WRIM (
	 .ireq ( wreq      ),
	 .ira  ( cmra[1]   ),
	 .oreq ( wr        ),
	 .ora  ( wra       ),
	 .cfg  ( imc[1]    )
	 );

   generate for(i=0; i<N; i++) begin: WA
      c2 UA (.q(wack[i]), .a0(imra[1][i]), .a1(cmra[1][i]));
   end endgenerate

   im_alloc #(.VCN(N), .CMN(M), .SN(4))
   NIM (
	.IMr   ( nreq      ),
	.IMa   ( imra[2]   ),
`ifndef ENABLE_CRRD
	.CMs   ( ncms      ),
`endif	       
	.cfg   ( imc[2]    ),
	.rst_n ( rst_n     )
	);

   rcb #(.NN(N), .MN(M), .DW(4))
   NRIM (
	 .ireq ( nreq      ),
	 .ira  ( cmra[2]   ),
	 .oreq ( nr        ),
	 .ora  ( nra       ),
	 .cfg  ( imc[2]    )
	 );

   generate for(i=0; i<N; i++) begin: NA
      c2 UA (.q(nack[i]), .a0(imra[2][i]), .a1(cmra[2][i]));
   end endgenerate

   im_alloc #(.VCN(N), .CMN(M), .SN(2))
   EIM (
	.IMr   ( ereq      ),
	.IMa   ( imra[3]   ),
`ifndef ENABLE_CRRD
	.CMs   ( ecms      ),
`endif	       
	.cfg   ( imc[3]    ),
	.rst_n ( rst_n     )
	);

   rcb #(.NN(N), .MN(M), .DW(2))
   ERIM (
	 .ireq ( ereq      ),
	 .ira  ( cmra[3]   ),
	 .oreq ( er        ),
	 .ora  ( era       ),
	 .cfg  ( imc[3]    )
	 );

   generate for(i=0; i<N; i++) begin: EA
      c2 UA (.q(eack[i]), .a0(imra[3][i]), .a1(cmra[3][i]));
   end endgenerate

   im_alloc #(.VCN(N), .CMN(M), .SN(4))
   LIM (
	.IMr   ( lreq      ),
	.IMa   ( imra[4]   ),
`ifndef ENABLE_CRRD
	.CMs   ( lcms      ),
`endif	       
	.cfg   ( imc[4]    ),
	.rst_n ( rst_n     )
	);

   rcb #(.NN(N), .MN(M), .DW(4))
   LRIM (
	 .ireq ( lreq      ),
	 .ira  ( cmra[4]   ),
	 .oreq ( lr        ),
	 .ora  ( lra       ),
	 .cfg  ( imc[4]    )
	 );

   generate for(i=0; i<N; i++) begin: LA
      c2 UA (.q(lack[i]), .a0(imra[4][i]), .a1(cmra[4][i]));
   end endgenerate

   // CM schedulers
   generate
      for(i=0; i<M; i=i+1) begin: CMSch
	 cm_alloc S (
		   .sra   ( sra[i]  ), 
		   .wra   ( wra[i]  ), 
		   .nra   ( nra[i]  ), 
		   .era   ( era[i]  ), 
		   .lra   ( lra[i]  ), 
		   .scfg  ( scfg[i] ),
		   .ncfg  ( ncfg[i] ), 
		   .wcfg  ( wcfg[i] ), 
		   .ecfg  ( ecfg[i] ), 
		   .lcfg  ( lcfg[i] ), 
`ifndef ENABLE_CRRD
		   .s     ( cms[i]  ),
`endif	       
		   .wr    ( wr[i]   ), 
		   .er    ( er[i]   ), 
		   .sr    ( sr[i]   ), 
		   .nr    ( nr[i]   ), 
		   .lr    ( lr[i]   )
		   );
	 
`ifndef ENABLE_CRRD
	 assign scms[i] = {cms[i][4], cms[i][3], cms[i][2], cms[i][1]};
	 assign wcms[i] = {cms[i][4], cms[i][3]};
	 assign ncms[i] = {cms[i][4], cms[i][3], cms[i][1], cms[i][0]};
	 assign ecms[i] = {cms[i][4], cms[i][1]};
	 assign lcms[i] = {cms[i][3], cms[i][2], cms[i][1], cms[i][0]};
`endif	       
	 	 
      end
   endgenerate

endmodule // clos_sch

   
