/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Multi-resource match arbiter
 *** SystemVerilog is used ***
 
 References
   Stanislavs Golubcovs, Delong Shang, Fei Xia, Andrey Mokhov and Alex Yakovlev, Multi-resource arbiter decomposition, Tech report NCL-EECE-MSD-TR-2009-143, Microelectronic System Design Group, School of EECE, Newcastle University, 2009.
   Stanislavs Golubcovs, Delong Shang, Fei Xia, Andrey Mokhov and Alex Yakovlev, Modular approach to multi-resource arbiter design, IEEE Symposium on Asynchronous Circuits and Systems, 2009.

 History:
 05/09/2009  Initial version. <wsong83@gmail.com>
 05/11/2009  Speed up the arbiter. <wsong83@gmail.com>
 27/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module mrma (/*AUTOARG*/
   // Outputs
   ca, ra, cfg,
   // Inputs
   c, r, rst_n
   );
   
   // parameters
   parameter N = 2;	 // the number of requests/clients
   parameter M = 2;	 // the number of resources

   input [N-1:0]   c;		// requests/clients
   output [N-1:0]  ca;		// requests ack
   
   input [M-1:0]   r;		// resources
   output [M-1:0]  ra;		// resource ack
   
   output [M-1:0][N-1:0] cfg;	// the generated configuration
   wire [N-1:0][M-1:0] 	 scfg;

   wire [M-1:0][N-1:0] 	 hs;	// match results
   wire [M-1:0][N-1:0]   blk;	// blockage
   wire [N-1:0][M-1:0]   sblk;	// shuffled blockage
   wire [M-1:0] 	 rbi;	// resource blockage
   wire [N-1:0] 	 cbi;	// client blockage
   wire [N-1:0] 	 cg, cm; // client requests
   wire [M-1:0] 	 rg, rm; // resource requests
   
   input 		 rst_n;	// active low reset

   // generate variables
   genvar 		   i, j;


   // input arbiters
   tree_arb #(N) CIArb (
			  .req    ( cm  ),
			  .gnt    ( cg  )
			  );
   
   tree_arb #(M) RIArb (
			  .req    ( rm ),
			  .gnt    ( rg )
			  );

   generate
      // tile matrix
      for (i=0; i<M; i++) begin: Row
	 for(j=0; j<N; j++) begin: Clm
	    cr_blk E (
		      .bo   ( blk[i][j]   ),
		      .hs   ( hs[i][j]    ),
		      .cbi  ( cbi[j]      ),
		      .rbi  ( rbi[i]      ),
		      .rg   ( rg[i]       ),
		      .cg   ( cg[j]       )
		      );
	    
	    // shuffle the blockage
	    assign sblk[j][i] = blk[i][j];

	    // shuffle the configuration
	    assign scfg[j][i] = cfg[i][j];
	    
	    // store the match results
	    c2p  C (.q(cfg[i][j]), .a(c[j]), .b(hs[i][j]));
	 
	 end // block: Clm
      end // block: Row

      // combine the row blockage and generate input requests
      for(i=0; i<M; i++) begin: RB
	 assign rbi[i] = (|blk[i]) & rst_n;
	 and AND_RG (rm[i], r[i], ~ra[i], rst_n);
	 assign ra[i] = |cfg[i];
      end

      // combine the column blockage and generate input requests
      for(j=0; j<N; j++) begin: CB
	 assign cbi[j] = (|sblk[j]) & rst_n;
	 and AND_CG (cm[j], c[j], ~ca[j], rst_n);
	 assign ca[j] = |scfg[j];
      end
   endgenerate
   
endmodule // mrma

