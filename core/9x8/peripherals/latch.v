//
// latch peripheral for @INSIGNAL@
// Copyright 2013, Sinclair R.F., Inc.
//
generate
// Register the input signal when  commanded.
reg [@LATCH_WIDTH@-1:0] s__latch = {(@LATCH_WIDTH@){1'b0}};
always @ (posedge i_clk)
  if (i_rst)
    s__latch <= {(@LATCH_WIDTH@){1'b0}};
  else if (s_outport && (s_T == 8'd@IX_O_LATCH@))
    s__latch[0+:@WIDTH@] <= @INSIGNAL@;
  else
    s__latch <= s__latch;
// Latch the mux address when commanded.
reg [@ADDR_WIDTH@-1:0] s__addr = {(@ADDR_WIDTH@){1'b0}};
always @ (posedge i_clk)
  if (i_rst)
    s__addr <= {(@ADDR_WIDTH@){1'b0}};
  else if (s_outport && (s_T == 8'd@IX_O_ADDR@))
    s__addr <= s_N[0+:@ADDR_WIDTH@];
  else
    s__addr <= s__addr;
// Run the mux.
integer ix;
always @ (posedge i_clk)
  if (i_rst)
    s__select <= 8'h00;
  else begin
    s__select <= 8'h00;
    for (ix=0; ix<@LATCH_WIDTH@/8; ix=ix+1)
      if (ix[0+:@ADDR_WIDTH@] == s__addr)
        s__select <= s__latch[8*ix+:8];
  end
endgenerate
