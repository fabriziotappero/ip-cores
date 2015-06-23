/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 M-N Match allocator
 *** SystemVerilog is used ***
 
 References
   Thomas E. Anderson, Susan S. Owicki, James B. Saxe and Charles P. Thacker, High-speed switch scheduling for local-area networks, ACM Transactions on Computer Systems, 1993(11), 319-352.

 For the detail structure, please refer to Section 6.3.1 of the thesis:
   Wei Song, Spatial parallelism in the routers of asynchronous on-chip networks, PhD thesis, the University of Manchester, 2011.
  
 History:
 09/06/2010  Initial version. <wsong83@gmail.com>
 08/03/2011  Tree arbiter cannot be used as the requests are not allowed to drop before ack. <wsong83@gmail.com>
 24/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module mnma(/*AUTOARG*/
   // Outputs
   ra, cfg,
   // Inputs
   r
   );
   parameter N = 2;		// number of input requests
   parameter M = 2;		// number of resources

   input [N-1:0][M-1:0]       r;	// input requests
   output [N-1:0] 	      ra;	// ack to input requests
   output [M-1:0][N-1:0]      cfg;	// configuration to the crssbar

   wire [M-1:0][N-1:0] 	      OPr;
   wire [M-1:0][N-1:0] 	      OPg;
   wire [M-1:0][N-1:0][M-1:0] OPren;
   wire [N-1:0][M-1:0] 	      IPr;
   wire [N-1:0][M-1:0] 	      IPg;

   genvar 		      i,j,k;

   //-------------------------------------
   // OP arbiters
   generate
      for(i=0; i<M; i++) begin:OPA
	 mutex_arb #(N)
	 A (
	    .req    ( OPr[i]  ),
	    .gnt    ( OPg[i]  )
	    );
      end
   endgenerate

   //--------------------------------------
   // IP arbiters
   generate
      for(i=0; i<N; i++) begin:IPA
	 mutex_arb #(M)
	 A (
	    .req    ( IPr[i]  ),
	    .gnt    ( IPg[i]  )
	    );

	 // the input ack
	 assign ra[i] = |IPg[i];
      end
   endgenerate

   //--------------------------------------
   // connections
   generate
      for(i=0; i<M; i++) begin:CO
	 for(j=0; j<N; j++) begin:CI
	    for(k=0; k<M; k++) begin:EN
	       if(i==k)
		 assign OPren[i][j][k] = 1'b0;
	       else
		 assign OPren[i][j][k] = IPg[j][k]; // connection j->k is settle
	    end
	    and AND_OPRen (OPr[i][j], r[j][i] ,(~|OPren[i][j]));
	    assign cfg[i][j] = IPg[j][i];
	    assign IPr[j][i] = OPg[i][j];
	 end // block: CI
      end // block: CO
   endgenerate
   
endmodule // mnma


