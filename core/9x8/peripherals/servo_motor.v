//
// PERIPHERAL servo_motor:  @NAME@
// Copyright 2015, Sinclair R.F.,  Inc.
//
generate
reg [@NBITS_PWM@-1:0] s__pwm_count_init = @DEFAULT_PWM@;
always @ (posedge i_clk)
  if (i_rst)
    s__pwm_count_init <= @DEFAULT_PWM@;
  else if (s_outport && (s_T == @IX_OUTPORT@))
    s__pwm_count_init <= @PWM_FORMULA@;
  else
    s__pwm_count_init <= s__pwm_count_init;
reg [@NBITS_PWM@-1:0] s__pwm_count = @DEFAULT_PWM@;
@SCALE_0_BEGIN@
@SCALE_0_ELSE@
reg s__tick = 1'b0;
reg [@NBITS_SCALE@-1:0] s__tick_cnt = @SCALE_MINUS_ONE@;
wire s__tick_last = (s__tick_cnt == @ONE_SCALE@);
always @ (posedge i_clk)
  if (i_rst) begin
    s__tick <= 1'b0;
    s__tick_cnt <= @SCALE_MINUS_ONE@;
  end else begin
    s__tick <= s__tick_last;
    if (s__tick)
      s__tick_cnt <= @SCALE_MINUS_ONE@;
    else
      s__tick_cnt <= s__tick_cnt - @ONE_SCALE@;
  end
@SCALE_0_END@
@PERIOD_BEGIN@
reg [@NBITS_PERIOD@-1:0] s__period = @PERIOD_MINUS_ONE@;
@SCALE_0_BEGIN@
always @ (posedge i_clk)
  if (i_rst) begin
    s__period <= @PERIOD_MINUS_ONE@;
    s__period_done <= 1'b0;
  end else begin
    if (s__period_done)
      s__period <= @PERIOD_MINUS_ONE@;
    else
      s__period <= s__period - @ONE_PERIOD@;
    s__period_done <= (s__period == @ONE_PERIOD@);
  end
@SCALE_0_ELSE@
always @ (posedge i_clk)
  if (i_rst) begin
    s__period <= @PERIOD_MINUS_ONE@;
    s__period_done <= 1'b0;
  end else begin
    if (s__period_done)
      s__period <= @PERIOD_MINUS_ONE@;
    else if (s__tick)
      s__period <= s__period - @ONE_PERIOD@;
    else
      s__period <= s__period;
    s__period_done <= s__tick_last && (s__period == @NBITS_PERIOD@'d0);
  end
@SCALE_0_END@
@PERIOD_END@
@SCALE_0_BEGIN@
always @ (posedge i_clk)
  if (i_rst)
    s__pwm_count <= @DEFAULT_PWM@;
  else if (@PERIOD_SIGNAL@)
    s__pwm_count <= s__pwm_count_init;
  else
    s__pwm_count <= s__pwm_count - @ONE_PWM@;
@SCALE_0_ELSE@
always @ (posedge i_clk)
  if (i_rst)
    s__pwm_count <= @DEFAULT_PWM@;
  else if (@PERIOD_SIGNAL@)
    s__pwm_count <= s__pwm_count_init;
  else if (s__tick)
    s__pwm_count <= s__pwm_count - @ONE_PWM@;
  else
    s__pwm_count <= s__pwm_count;
@SCALE_0_END@
reg s__outsignal = 1'b0;
always @ (posedge i_clk)
  if (i_rst)
    s__outsignal <= 1'b0;
  else if (@PERIOD_SIGNAL@)
    s__outsignal <= 1'b1;
@SCALE_0_BEGIN@
  else if (s__pwm_count == {(@NBITS_PWM@){1'b0}})
@SCALE_0_ELSE@
  else if (s__tick && (s__pwm_count == {(@NBITS_PWM@){1'b0}}))
@SCALE_0_END@
    s__outsignal <= 1'b0;
  else
    s__outsignal <= s__outsignal;
always @ (*)
  @OUTSIGNAL@ = @INVERT@s__outsignal;
endgenerate
