/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 CM allocator (the CM dispatcher in the thesis)
 *** SystemVerilog is used ***
 
 References
 For the detail structure, please refer to Section 6.3.1 of the thesis:
   Wei Song, Spatial parallelism in the routers of asynchronous on-chip networks, PhD thesis, the University of Manchester, 2011.
  
 History:
 08/09/2009  Initial version. <wsong83@gmail.com>
 20/09/2010  Modified for the Clos SDM router <wsong83@cs.man.ac.uk>
 25/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module cm_alloc (/*AUTOARG*/
`ifndef ENABLE_CRRD
   s,
`endif	       
   // Outputs
   sra, wra, nra, era, lra, scfg, ncfg, wcfg, ecfg, lcfg,
   // Inputs
   wr, er, sr, nr, lr
   ) ;

   //requests from all IMs
   input [1:0]   wr, er;
   input [3:0] 	 sr, nr, lr;

   // ack to IMs
   output        sra, wra, nra, era, lra;

   // the configuration to the local CM
   output [1:0]  scfg, ncfg;
   output [3:0]  wcfg, ecfg, lcfg;

   // when using the asynchronous dispatching algorithm, status is sent back to IMs
`ifndef ENABLE_CRRD
   output [4:0]  s;
`endif	       

   // arbiters
   mutex_arb #(2)
   SA ( .req  ( {lr[0], nr[0]} ),
	.gnt  ( scfg           )
	);

   mutex_arb #(4)
   WA ( .req  ( {lr[1], er[0], nr[1], sr[0]} ),
	.gnt  ( wcfg                         )
	);

   mutex_arb #(2)
   NA ( .req  ( {lr[2], sr[1]} ),
	.gnt  ( ncfg           )
	);

   mutex_arb #(4)
   EA ( .req  ( {lr[3], nr[2], wr[0], sr[2]} ),
	.gnt  ( ecfg                         )
	);

   mutex_arb #(4)
   LA ( .req  ( {er[1], nr[3], wr[1], sr[3]} ),
	.gnt  ( lcfg                         )
	);

   // generating the ack
   assign sra = |{wcfg[0], ncfg[0], ecfg[0], lcfg[0]};
   assign wra = |{ecfg[1], lcfg[1]};
   assign nra = |{scfg[0], wcfg[1], ecfg[2], lcfg[2]};
   assign era = |{wcfg[2], lcfg[3]};
   assign lra = |{scfg[1], wcfg[3], ncfg[1], ecfg[3]};

   // generating the status
`ifndef ENABLE_CRRD
   assign s = {|lcfg, |ecfg, |ncfg, |wcfg, |scfg};
`endif	       

endmodule // cm_alloc


