/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Sub-channel controller
 
 References
 * Lookahead pipelines 
     Montek Singh and Steven M. Nowick, The design of high-performance dynamic asynchronous pipelines: lookahead style, IEEE Transactions on Very Large Scale Integration (VLSI) Systems, 2007(15), 1256-1269. doi:10.1109/TVLSI.2007.902205
 * Channel slicing
     Wei Song and Doug Edwards, A low latency wormhole router for asynchronous on-chip networks, Asia and South Pacific Design Automation Conference, 2010, 437-443.
 
 For the detail structure, please refer to Section 7.1.1 of the thesis:
   Wei Song, Spatial parallelism in the routers of asynchronous on-chip networks, PhD thesis, the University of Manchester, 2011.
  
 History:
 05/05/2009  Initial version. <wsong83@gmail.com>
 22/10/2010  Make it more timing robust. <wsong83@gmail.com>
 24/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module subc_ctl (/*AUTOARG*/
   // Outputs
   nack, rt_rst,
   // Inputs
   ai2cb, ack, eof, rt_ra, rt_err, rst_n
   );

   input ai2cb;			// the ack from output ports
   input ack;			// the ack from the last stage of the input buffer
   input eof;			// the eof bit from the last stage of the input buffer
   input rt_ra;			// ack from the switch allocator
   input rt_err;		// invalid router decision
   input rst_n;			// the global active low reset signal
   output nack;			// the ack to the last stage of the input buffer
   output rt_rst;		// the router reset signal
   
   wire   csc;		        // internal wires to handle the CSC of the STG
   wire   acko;			// the ack signal after the C2N gate
   wire   fend;  		// the end of frame indicator
   wire   acken;		// active low ack enable
   
`ifdef ENABLE_LOOKAHEAD
   c2n CD (.q(acko), .a(ai2cb), .b(ack)); // the C2N gate to avoid early withdrawal
`else
   assign acko = ai2cb;
`endif
   
   c2p  CEN  (.b(eof), .a(acko), .q(fend));
   c2   C    (.a0(rt_ra), .a1(fend), .q(csc));
   nand U1   ( acken, rt_ra, ~csc);
   nor  U2   ( rt_rst, fend, ~csc);
   nor  AG   ( nack, acko&(~eof), acken|(rt_err&ack), ~rst_n);
   
endmodule // subc_ctl

   