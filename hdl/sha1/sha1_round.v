///////////////////////////////////////////////////////////////
// sha1_round.v  version 0.1           
//
// Primitive SHA1 Round
//
// Described in Stalling, page 284
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

module sha1_round (cv_in, w, round, cv_out);

   input [159:0] cv_in;
   input [31:0]  w;
   input [6:0]   round;
   output [159:0] cv_out;

   reg [31:0]     k;
   reg [31:0]     f;
   wire [31:0]    a_shift;
   wire [31:0]    b_shift;
   wire [31:0]    add_result;
   
   wire [31:0]    a = cv_in[159:128];
   wire [31:0]    b = cv_in[127:96];
   wire [31:0]    c = cv_in[95:64];
   wire [31:0]    d = cv_in[63:32];
   wire [31:0]    e = cv_in[31:0];

   // Perhaps this should be a case statement?
   // I want it to create 4 parallel comparators...
   always @(round)
     begin
        k = 32'd0;
        if ((round >= 7'd0) && (round <= 7'd19))
          k = 32'h5A827999;
        if ((round >= 7'd20) && (round <= 7'd39))
          k = 32'h6ED9EBA1;
        if ((round >= 7'd40) && (round <= 7'd59))
          k = 32'h8F1BBCDC;
        if ((round >= 7'd60) && (round <= 7'd79))
          k = 32'hCA62C1D6;
     end // always @ (round)

   // Perhaps this should be a case statement?
   // I want it to create 4 parallel comparators...
   always @(round or b or c or d)
     begin
        f = 32'd0;
        if ((round >= 7'd0) && (round <= 7'd19))
          f = ((b & c) | (~b & d));
        if ((round >= 7'd20) && (round <= 7'd39))
          f = (b ^ c ^ d);
        if ((round >= 7'd40) && (round <= 7'd59))
          f = ((b & c) | (b & d) | (c & d));
        if ((round >= 7'd60) && (round <= 7'd79))
          f = (b ^ c ^ d);
     end // always @ (round or b or c or d)
   
   assign a_shift = {a[26:0], a[31:27]};
   assign b_shift = {b[1:0], b[31:2]};

   // Attempt to group early signals early...
   // e and w come from register outputs
   // k is 6 bit comparator & mux delay
   // f is 6 bit comparator & mux delay & computation
   // a is shift 5 from previous round
   assign add_result = (a_shift + ((f + k) + (e + w)));
   assign cv_out = {add_result, a, b_shift, c, d};

endmodule // sha1_round

