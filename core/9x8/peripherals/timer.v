//
// PERIPHERAL timer:  @NAME@
// Copyright 2013, Sinclair R.F., Inc.
//
localparam L__COUNT = @RATEMETHOD@-1;
localparam L__COUNT_NBITS = $clog2(L__COUNT);
generate
reg [L__COUNT_NBITS-1:0] s__count = L__COUNT[0+:L__COUNT_NBITS];
always @ (posedge i_clk)
  if (i_rst) begin
    s__count <= L__COUNT[0+:L__COUNT_NBITS];
    s__expired <= 1'b0;
  end else begin
    if (s__expired)
      s__count <= L__COUNT[0+:L__COUNT_NBITS];
    else
      s__count <= s__count - { {(L__COUNT_NBITS-1){1'b0}}, 1'b1 };
    s__expired <= (s__count == { {(L__COUNT_NBITS-1){1'b0}}, 1'b1 });
  end
endgenerate
