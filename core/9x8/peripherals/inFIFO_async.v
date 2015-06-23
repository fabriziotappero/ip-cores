//
// PERIPHERAL inFIFO_async:  @NAME@
// Copyright 2014, Sinclair R.F., Inc.
//
generate
// FIFO memory
reg [7:0] s__fifo[@DEPTH-1@:0];
// write side of the FIFO
reg [@DEPTH_NBITS-1@:0] s__ix_in = @DEPTH_NBITS@'h0;
always @ (posedge i_rst or posedge @INCLK@)
  if (i_rst)
    s__ix_in <= @DEPTH_NBITS@'h0;
  else if (@DATA_WR@) begin
    s__ix_in <= s__ix_in + @DEPTH_NBITS@'d1;
    s__fifo[s__ix_in] <= @DATA@;
  end else
    s__ix_in <= s__ix_in;
// read side of the FIFO
reg [@DEPTH_NBITS-1@:0] s__ix_out = @DEPTH_NBITS@'h0;
always @ (posedge i_clk)
  if (i_rst)
    s__ix_out <= @DEPTH_NBITS@'h0;
  else if (s_inport && (s_T == 8'd@IX_DATA@))
    s__ix_out <= s__ix_out + @DEPTH_NBITS@'d1;
  else
    s__ix_out <= s__ix_out;
always @ (posedge i_clk)
  s__data <= s__fifo[s__ix_out];
// empty indication to the micro controller
// Note:  The lag in the "empty" indication is OK because of the minimum 2 clock
//        delay between reading the data and then reading the "empty"
//        indication.
reg [@DEPTH_NBITS-1@:0] s__ix_in_gray = @DEPTH_NBITS@'h0;
always @ (posedge @INCLK@)
  s__ix_in_gray <= { 1'b0, s__ix_in[@DEPTH_NBITS-1@:1] } ^ s__ix_in;
reg [@DEPTH_NBITS-1@:0] s__ix_in_gray_s[2:0];
always @ (posedge i_clk) begin
  s__ix_in_gray_s[0] <= s__ix_in_gray;
  s__ix_in_gray_s[1] <= s__ix_in_gray_s[0];
  s__ix_in_gray_s[2] <= s__ix_in_gray_s[1];
end
genvar ix__clk;
wire [@DEPTH_NBITS-1@:0] s__ix_in_clk;
assign s__ix_in_clk[@DEPTH_NBITS-1@] = s__ix_in_gray_s[2][@DEPTH_NBITS-1@];
for (ix__clk=@DEPTH_NBITS-1@; ix__clk>0; ix__clk=ix__clk-1) begin : gen__ix_in_clk
  assign s__ix_in_clk[ix__clk-1] = s__ix_in_clk[ix__clk] ^ s__ix_in_gray_s[2][ix__clk-1];
end
always @ (posedge i_clk)
  s__empty <= (s__ix_in_clk == s__ix_out);
// full indication to the fabric
reg [@DEPTH_NBITS-1@:0] s__ix_out_gray = @DEPTH_NBITS@'h0;
always @ (posedge i_clk)
  s__ix_out_gray <= { 1'b0, s__ix_out[@DEPTH_NBITS-1@:1] } ^ s__ix_out;
reg [@DEPTH_NBITS-1@:0] s__ix_out_gray_s[2:0];
always @ (posedge @INCLK@) begin
  s__ix_out_gray_s[0] <= s__ix_out_gray;
  s__ix_out_gray_s[1] <= s__ix_out_gray_s[0];
  s__ix_out_gray_s[2] <= s__ix_out_gray_s[1];
end
genvar ix__inclk;
wire [@DEPTH_NBITS-1@:0] s__ix_out_inclk;
assign s__ix_out_inclk[@DEPTH_NBITS-1@] = s__ix_out_gray_s[2][@DEPTH_NBITS-1@];
for (ix__inclk=@DEPTH_NBITS-1@; ix__inclk>0; ix__inclk=ix__inclk-1) begin : gen__ix_out_inclk
  assign s__ix_out_inclk[ix__inclk-1] = s__ix_out_inclk[ix__inclk] ^ s__ix_out_gray_s[2][ix__inclk-1];
end
reg [@DEPTH_NBITS-1@:0] s__delta_inclk = @DEPTH_NBITS@'h0;
always @ (posedge @INCLK@)
  s__delta_inclk <= s__ix_in - s__ix_out_inclk;
always @ (posedge @INCLK@)
  @DATA_FULL@ <= &s__delta_inclk[@DEPTH_NBITS-1@:3];
endgenerate
