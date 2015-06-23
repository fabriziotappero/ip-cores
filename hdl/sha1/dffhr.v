///////////////////////////////////////////////////////////////
// dffhr.v  version 0.1
// 
// Standard parameterizable synchronous reset D-type flipflop
//
// Paul Hartke, phartke@stanford.edu,  Copyright (c)2002
//
// The information and description contained herein is the
// property of Paul Hartke.
//
// Permission is granted for any reuse of this information
// and description as long as this copyright notice is
// preserved.  Modifications may be made as long as this
// notice is preserved.
// This code is made available "as is".  There is no warranty,
// so use it at your own risk.
// Documentation? "Use the source, Luke!"
///////////////////////////////////////////////////////////////

module dffhr (d, r, clk, q);
  parameter WIDTH = 1;
  input 			r;
  input 			clk;
  input 	[WIDTH-1:0] 	d;
  output 	[WIDTH-1:0] 	q;
  reg 		[WIDTH-1:0] 	q;

  always @ (posedge clk) 
    if ( r ) 
      q <= {WIDTH{1'b0}};
    else
      q <= d;

endmodule // dffhr


