//
// PERIPHERAL PWM_8bit:  @NAME@
// Copyright 2013, Sinclair R.F., Inc.
//
localparam L__COUNT = @COUNT@-1;
localparam L__COUNT_NBITS = $clog2(L__COUNT+1);
generate
// generate the ticks for the PWM
reg [L__COUNT_NBITS-1:0] s__tick_counter = L__COUNT[0+:L__COUNT_NBITS];
reg s__tick_counter_is_zero = 1'b0;
always @ (posedge i_clk)
  if (i_rst) begin
    s__tick_counter <= L__COUNT[0+:L__COUNT_NBITS];
    s__tick_counter_is_zero <= 1'b0;
  end else if (s__tick_counter_is_zero) begin
    s__tick_counter <= L__COUNT[0+:L__COUNT_NBITS];
    s__tick_counter_is_zero <= 1'b0;
  end else begin
    s__tick_counter <= s__tick_counter - { {(L__COUNT_NBITS-1){1'b0}}, 1'b1 };
    s__tick_counter_is_zero <= (s__tick_counter == { {(L__COUNT_NBITS-1){1'b0}}, 1'b1 });
  end
// run the 1 to 255 PWM counter
reg [7:0] s__pwm_counter = 8'd1;
always @ (posedge i_clk)
  if (i_rst)
    s__pwm_counter <= 8'd1;
  else if (s__tick_counter_is_zero)
    if (s__pwm_counter == 8'hFF)
      s__pwm_counter <= 8'd1;
    else
      s__pwm_counter <= s__pwm_counter + 8'd1;
  else
    s__pwm_counter <= s__pwm_counter;
// Use a loop to instantiate each channel
reg [@INSTANCES@-1:0] s__raw = {(@INSTANCES@){@OFF@}};
genvar ix;
for (ix=0; ix<@INSTANCES@; ix=ix+1) begin : gen__channel
  reg [7:0] s__threshold = 8'd0;
  /* verilator lint_off WIDTH */
  wire [7:0] s__ix = ix; // Xilinx ISE can't bit-slice a genvar
  /* verilator lint_on WIDTH */
  always @ (posedge i_clk)
    if (i_rst)
      s__threshold <= 8'd0;
    else if (s_outport && (s_T == (8'd@IX_OUTPORT_0@ + s__ix)))
      s__threshold <= s_N;
    else
      s__threshold <= s__threshold;
  wire [7:0] s__threshold_use;
  if (@NORUNT@) begin : gen__norunt
    reg [7:0] s__threshold_use_tmp = 8'd0;
    always @ (posedge i_clk)
      if (i_rst)
        s__threshold_use_tmp <= 8'd0;
      else if (s__tick_counter_is_zero && (s__pwm_counter == 8'd255))
        s__threshold_use_tmp <= s__threshold;
      else
        s__threshold_use_tmp <= s__threshold_use_tmp;
    assign s__threshold_use = s__threshold_use_tmp;
  end else begin : gen__not_norunt
    assign s__threshold_use = s__threshold;
  end
  always @ (posedge i_clk)
    if (i_rst)
      s__raw[ix] <= @OFF@;
    else
      s__raw[ix] <= (s__pwm_counter <= s__threshold_use) ? @ON@ : @OFF@;
end
// needed since 1-bit wide signals don't have indices.
always @ (s__raw)
  @NAME@ = s__raw;
endgenerate
