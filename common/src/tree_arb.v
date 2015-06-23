/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 M-to-1 asynchronous tree arbiter.
 
 History:
 03/09/2009  Initial version. <wsong83@gmail.com>
 23/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module tree_arb (/*AUTOARG*/
   // Outputs
   gnt,
   // Inputs
   req
   ) ;

   // parameters
   parameter MR = 2;                  // the number of request inputs
   localparam TrLev = mlog2(MR)-1;    // the number of levels of the tree
   input [MR-1:0]  req;               // the request input
   output [MR-1:0] gnt;               // the grant output

   // generate variables
   genvar 	   i, j, k;

   // internal wires
   wire [MR*2:0]   mreq;              // the internal request lines
   wire [MR*2:0]   mgnt;              // the internal gnt lines
   wire [1:0] 	   rgnt;              // the positive gnt of the root mutex

   // the hardware block
   generate
      if (MR == 1)		// special case: only one input
	begin: MA_1
	   assign gnt = req;
	end
      else if(MR == 2)		// special case: only two input
	begin: MA_2
	   mutex2 ME0 (
		      .a    ( req[0]    ),
		      .b    ( req[1]    ),
		      .qa   ( gnt[0]    ),
		      .qb   ( gnt[1]    )
		      );
	end
      else
	begin: MA_N

	   mutex2 ME0 (
		      .a    ( mreq[0]   ),
		      .b    ( mreq[1]   ),
		      .qa   ( rgnt[0]   ),
		      .qb   ( rgnt[1]   )
		      );

	   assign mgnt[1:0] = ~rgnt;

	   for (i=1; 2**(i+1)<MR; i=i+1) begin: L
	      for (j=0; j<2**i; j=j+1) begin: T
		 tarb TA (
			  .ngnt    ( mgnt[(2**i-1)*2+j*2+1:(2**i-1)*2+j*2]  ),
			  .ntgnt   ( mgnt[(2**(i-1)-1)*2+j]                 ),
			  .req     ( mreq[(2**i-1)*2+j*2+1:(2**i-1)*2+j*2]  ),
			  .treq    ( mreq[(2**(i-1)-1)*2+j]                 )
			  );
	      end
	   end

	   for (j=0; j<MR-(2**TrLev); j=j+1) begin: LF
	      tarb TA (
		       .ngnt    ( mgnt[(2**TrLev-1)*2+j*2+1:(2**TrLev-1)*2+j*2]  ),
		       .ntgnt   ( mgnt[(2**(TrLev-1)-1)*2+j]                     ),
		       .req     ( mreq[(2**TrLev-1)*2+j*2+1:(2**TrLev-1)*2+j*2]  ),
		       .treq    ( mreq[(2**(TrLev-1)-1)*2+j]                     )
		       );
	   end

	   assign gnt = ~(mgnt[2*MR-3:MR-2]);
	   assign mreq[2*MR-3:MR-2] = req;

	end
   endgenerate

   // log_2 function
   function integer mlog2;
      input integer MR;
      begin
	 for( mlog2 = 0; 2**mlog2<MR; mlog2=mlog2+1)
	   begin
	   end
      end
   endfunction // mlog2

endmodule // tree_arb


