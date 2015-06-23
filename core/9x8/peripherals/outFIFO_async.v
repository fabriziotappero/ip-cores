//
// PERIPHERAL outFIFO_async:  @NAME@
// Copyright 2014, Sinclair R.F., Inc.
//
generate
// FIFO memory
reg [7:0] s__fifo[@DEPTH-1@:0];
// write side of the FIFO
reg [@DEPTH_NBITS-1@:0] s__ix_in = @DEPTH_NBITS@'h0;
always @ (posedge i_clk)
  if (i_rst)
    s__ix_in <= @DEPTH_NBITS@'h0;
  else if (s_outport && (s_T == 8'd@IX_OUTPORT@)) begin
    s__ix_in <= s__ix_in + @DEPTH_NBITS@'d1;
    s__fifo[s__ix_in] <= s_N;
  end else
    s__ix_in <= s__ix_in;
// read side of the FIFO
reg [@DEPTH_NBITS-1@:0] s__ix_out = @DEPTH_NBITS@'h0;
always @ (posedge i_rst or posedge @OUTCLK@)
  if (i_rst)
    s__ix_out <= @DEPTH_NBITS@'h0;
  else if (@DATA_RD@)
    s__ix_out <= s__ix_out + @DEPTH_NBITS@'d1;
  else
    s__ix_out <= s__ix_out;
always @ (*)
  @DATA@ <= s__fifo[s__ix_out];
// empty indication from the micro controller
reg [@DEPTH_NBITS-1@:0] s__ix_in_gray = @DEPTH_NBITS@'h0;
always @ (posedge i_clk)
  s__ix_in_gray <= { 1'b0, s__ix_in[@DEPTH_NBITS-1@:1] } ^ s__ix_in;
reg [@DEPTH_NBITS-1@:0] s__ix_in_gray_s[2:0];
always @ (posedge @OUTCLK@) begin
  s__ix_in_gray_s[0] <= s__ix_in_gray;
  s__ix_in_gray_s[1] <= s__ix_in_gray_s[0];
  s__ix_in_gray_s[2] <= s__ix_in_gray_s[1];
end
genvar ix__outclk;
wire [@DEPTH_NBITS-1@:0] s__ix_in_outclk_p;
assign s__ix_in_outclk_p[@DEPTH_NBITS-1@] = s__ix_in_gray_s[2][@DEPTH_NBITS-1@];
for (ix__outclk=@DEPTH_NBITS-1@; ix__outclk>0; ix__outclk=ix__outclk-1) begin : gen_ix_in_outclk_p
  assign s__ix_in_outclk_p[ix__outclk-1] = s__ix_in_outclk_p[ix__outclk] ^ s__ix_in_gray_s[2][ix__outclk-1];
end
reg [@DEPTH_NBITS-1@:0] s__ix_in_outclk = @DEPTH_NBITS@'h0;
always @ (posedge i_rst or posedge @OUTCLK@)
  if (i_rst)
    s__ix_in_outclk <= @DEPTH_NBITS@'h0;
  else
    s__ix_in_outclk <= s__ix_in_outclk_p;
always @ (posedge @OUTCLK@)
  @DATA_EMPTY@ <= (s__ix_in_outclk == s__ix_out)
               || (@DATA_RD@ && (s__ix_in_outclk - s__ix_out == @DEPTH_NBITS@'d1));
// full indication to the micro controller
reg [@DEPTH_NBITS-1@:0] s__ix_out_gray = @DEPTH_NBITS@'h0;
always @ (posedge @OUTCLK@)
  s__ix_out_gray <= { 1'b0, s__ix_out[@DEPTH_NBITS-1@:1] } ^ s__ix_out;
reg [@DEPTH_NBITS-1@:0] s__ix_out_gray_s[2:0];
always @ (posedge i_clk) begin
  s__ix_out_gray_s[0] <= s__ix_out_gray;
  s__ix_out_gray_s[1] <= s__ix_out_gray_s[0];
  s__ix_out_gray_s[2] <= s__ix_out_gray_s[1];
end
genvar ix__clk;
wire [@DEPTH_NBITS-1@:0] s__ix_out_clk;
assign s__ix_out_clk[@DEPTH_NBITS-1@] = s__ix_out_gray_s[2][@DEPTH_NBITS-1@];
for (ix__clk=@DEPTH_NBITS-1@; ix__clk>0; ix__clk=ix__clk-1) begin : gen_ix_out_clk
  assign s__ix_out_clk[ix__clk-1] = s__ix_out_clk[ix__clk] ^ s__ix_out_gray_s[2][ix__clk-1];
end
reg [@DEPTH_NBITS-1@:0] s__delta_clk = @DEPTH_NBITS@'h0;
always @ (posedge i_clk)
  s__delta_clk <= s__ix_in - s__ix_out_clk;
always @ (posedge i_clk)
  s__full <= &s__delta_clk[@DEPTH_NBITS-1@:2];
endgenerate
