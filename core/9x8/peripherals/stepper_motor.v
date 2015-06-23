//
// PERIPHERAL stepper_motor:  @NAME@
// Copyright 2015, Sinclair R.F., Inc.
//
@MASTER_BEGIN@
localparam L__RATEMETHOD_MINUS_1 = @RATEMETHOD@ - 1;
localparam L__NBITS_RATEMETHOD = clog2(L__RATEMETHOD_MINUS_1);
// Assemble the byes of the control word from the input bytes.
reg [@CONTROL_WIDTH@-1:0] s__input_control_word = {(@CONTROL_WIDTH@){1'b0}};
always @ (posedge i_clk)
  if (i_rst)
    s__input_control_word <= {(@CONTROL_WIDTH@){1'b0}};
  else if (s_outport && (s_T == 8'd@IX_OUTCONTROL@))
    s__input_control_word <= { s__input_control_word[0+:@CONTROL_WIDTH@-@DW@], s_N };
  else
    s__input_control_word <= s__input_control_word;
wire [@CONTROL_WIDTH_PACKED@-1:0] s__input_control_word_packed = {
  s__input_control_word[@DW@*((@MODE_WIDTH@+@DWM1@)/@DW@)+@DW@*((@COUNT_WIDTH@+@DWM1@)/@DW@)+@DW@*((@ACCEL_WIDTH@+@DWM1@)/@DW@)+:@RATECMD_WIDTH@],
  s__input_control_word[@DW@*((@MODE_WIDTH@+@DWM1@)/@DW@)+@DW@*((@COUNT_WIDTH@+@DWM1@)/@DW@)+:@ACCEL_WIDTH@],
  s__input_control_word[@DW@*((@MODE_WIDTH@+@DWM1@)/@DW@)+:@COUNT_WIDTH@]
@OUTMODE_BEGIN@
  , s__input_control_word[0+:@MODE_WIDTH@]
@OUTMODE_END@
};
@MASTER_END@
// Instantiate the control word FIFO and operate its input side.
reg s__FIFO_wr = 1'b0;
always @ (posedge i_clk)
  if (i_rst)
    s__FIFO_wr <= 1'b0;
  else
    s__FIFO_wr <= (s_outport && (s_T == 8'd@IX_OUTRECORD@));
reg [@NBITS_FIFO_DEPTH@:0] s__FIFO_in_addr = {(@NBITS_FIFO_DEPTH@+1){1'b0}};
always @ (posedge i_clk)
  if (i_rst)
    s__FIFO_in_addr <= {(@NBITS_FIFO_DEPTH@+1){1'b0}};
  else
    s__FIFO_in_addr <= s__FIFO_in_addr + { @NBITS_FIFO_DEPTH@'d0, s__FIFO_wr };
reg [@CONTROL_WIDTH_PACKED@-1:0] s__FIFO[@FIFO_DEPTH@-1:0];
always @ (posedge i_clk)
  if (s__FIFO_wr)
    s__FIFO[s__FIFO_in_addr[0+:@NBITS_FIFO_DEPTH@]] <= @S__INPUT_CONTROL_WORD_PACKED@;
// Operate the output side of the FIFO and translate the packed controls into
// individual signals.
reg s__FIFO_rd = 1'b0;
reg [@NBITS_FIFO_DEPTH@:0] s__FIFO_out_addr = {(@NBITS_FIFO_DEPTH@+1){1'b0}};
always @ (posedge i_clk)
  if (i_rst)
    s__FIFO_out_addr <= {(@NBITS_FIFO_DEPTH@+1){1'b0}};
  else
    s__FIFO_out_addr <= s__FIFO_out_addr + { @NBITS_FIFO_DEPTH@'d0, s__FIFO_rd };
reg [@CONTROL_WIDTH_PACKED@-1:0] s__output_control_word = @CONTROL_WIDTH_PACKED@'d0;
always @ (posedge i_clk)
  s__output_control_word <= s__FIFO[s__FIFO_out_addr[0+:@NBITS_FIFO_DEPTH@]];
wire [@RATECMD_WIDTH@-1:0] s__next_rate  = s__output_control_word[@MODE_WIDTH@+@COUNT_WIDTH@+@ACCEL_WIDTH@+:@RATECMD_WIDTH@];
wire   [@ACCEL_WIDTH@-1:0] s__next_accel = s__output_control_word[@MODE_WIDTH@+@COUNT_WIDTH@+:@ACCEL_WIDTH@];
wire   [@COUNT_WIDTH@-1:0] s__next_count = s__output_control_word[@MODE_WIDTH@+:@COUNT_WIDTH@];
@OUTMODE_BEGIN@
wire [@MODE_WIDTH@-1:0] s__next_mode = s__output_control_word[0+:@MODE_WIDTH@];
@OUTMODE_END@
// Indicate whether or not the FIFO is empty.
reg s__FIFO_empty = 1'b1;
always @ (posedge i_clk)
  if (i_rst)
    s__FIFO_empty <=1'b1;
  else
    s__FIFO_empty <= (s__FIFO_out_addr == s__FIFO_in_addr);
@MASTER_BEGIN@
// Generate the clock enable for the effective internal clock rate.
reg s__clk_en = 1'b0;
reg [L__NBITS_RATEMETHOD-1:0] s__clk_en_count = L__RATEMETHOD_MINUS_1[0+:L__NBITS_RATEMETHOD];
always @ (posedge i_clk)
  if (i_rst) begin
    s__clk_en <= 1'b0;
    s__clk_en_count <= L__RATEMETHOD_MINUS_1[0+:L__NBITS_RATEMETHOD];
  end else begin
    s__clk_en <= (s__clk_en_count == { {(L__NBITS_RATEMETHOD-1){1'b0}}, 1'b1 });
    if (s__clk_en)
      s__clk_en_count <= L__RATEMETHOD_MINUS_1[0+:L__NBITS_RATEMETHOD];
    else
      s__clk_en_count <= s__clk_en_count - { {(L__NBITS_RATEMETHOD-1){1'b0}}, 1'b1 };
  end
@MASTER_END@
// Capture the start strobe from the micro controller.
reg s__go = 1'b0;
always @ (posedge i_clk)
  if (i_rst)
    s__go <= 1'b0;
  else if (s_outport && (s_T == 8'd@IX_OUTRUN@))
    s__go <= 1'b1;
  else if (@S__CLK_EN@)
    s__go <= 1'b0;
  else
    s__go <= s__go;
// Indicate when the controller is running.
reg s__running = 1'b0;
wire s__load_next;
always @ (posedge i_clk)
  if (i_rst)
    s__running <= 1'b0;
  else if (s__go && @S__CLK_EN@)
    s__running <= 1'b1;
  else if (s__load_next && s__FIFO_empty)
    s__running <= 1'b0;
  else
    s__running <= s__running;
always @ (posedge i_clk)
  if (i_rst)
    s__done <= 1'b1;
  else if (s_outport && (s_T == 8'd@IX_OUTRUN@))
    s__done <= 1'b0;
  else
    s__done <= !s__go && !s__running;
// Operate the step count
wire s__step_pre;
reg [@COUNT_WIDTH@-1:0] s__count = @COUNT_WIDTH@'d0;
reg s__count_zero = 1'b1;
always @ (posedge i_clk)
  if (i_rst)
    s__count <= @COUNT_WIDTH@'d0;
  else if (s__load_next && !s__FIFO_empty)
    s__count <= s__next_count;
  else if (@S__CLK_EN@ && s__step_pre)
    s__count <= s__count - { {(@COUNT_WIDTH@-1){1'b0}}, !s__count_zero };
  else
    s__count <= s__count;
always @ (posedge i_clk)
  if (i_rst)
    s__count_zero <= 1'b1;
  else
    s__count_zero <= (s__count == @COUNT_WIDTH@'d0);
assign s__load_next = @S__CLK_EN@ && (s__go || s__running && s__step_pre && s__count_zero);
always @ (posedge i_clk)
  if (i_rst)
    s__FIFO_rd <= 1'b0;
  else
    s__FIFO_rd <= s__load_next && !s__FIFO_empty;
// Operate the accumulators.
reg [@ACCUM_WIDTH@-1:0] s__angle = @ACCUM_WIDTH@'d0;
reg  [@RATE_WIDTH@-1:0] s__rate  = @RATE_WIDTH@'d0;
reg [@ACCEL_WIDTH@-1:0] s__accel = @ACCEL_WIDTH@'d0;
@OUTMODE_BEGIN@
reg  [@MODE_WIDTH@-1:0] s__mode  = @MODE_WIDTH@'d0;
@OUTMODE_END@
reg [@ACCUM_WIDTH@-1:0] s__angle_presum = @ACCUM_WIDTH@'d0;
always @ (posedge i_clk)
  if (i_rst)
    s__angle_presum <= @ACCUM_WIDTH@'d0;
  else
    s__angle_presum <= s__angle + { {(@RATE_SCALE@){s__rate[@RATE_WIDTH@-1]}}, s__rate[@RATE_WIDTH@-1:@ACCEL_RES@-@ACCUM_RES@] };
always @ (posedge i_clk)
  if (i_rst) begin
    s__angle <= @ACCUM_WIDTH@'d0;
    s__rate  <= @RATE_WIDTH@'d0;
    s__accel <= @ACCEL_WIDTH@'d0;
@OUTMODE_BEGIN@
    s__mode  <= @MODE_WIDTH@'d0;
@OUTMODE_END@
  end else if (s__load_next && !s__FIFO_empty) begin
    s__angle <= {(@ACCUM_WIDTH@){s__next_rate[@RATECMD_WIDTH@-1]}};
    s__rate  <= { s__next_rate, {(@ACCEL_RES@-@RATE_RES@){1'b0}} };
    s__accel <= s__next_accel;
@OUTMODE_BEGIN@
    s__mode  <= s__next_mode;
@OUTMODE_END@
  end else if (!s__running || (s__load_next && s__FIFO_empty)) begin
    s__angle <= @ACCUM_WIDTH@'d0;
    s__rate  <= @RATE_WIDTH@'d0;
    s__accel <= @ACCEL_WIDTH@'d0;
@OUTMODE_BEGIN@
    s__mode  <= s__mode;
@OUTMODE_END@
  end else begin
    if (@S__CLK_EN@) begin
      s__angle <= s__angle_presum;
      s__rate  <= s__rate  + { {(@ACCEL_SCALE@-@RATE_SCALE@){s__accel[@ACCEL_WIDTH@-1]}}, s__accel };
    end else begin
      s__angle <= s__angle;
      s__rate  <= s__rate;
    end
    s__accel <= s__accel;
@OUTMODE_BEGIN@
    s__mode  <= s__mode;
@OUTMODE_END@
  end
// Generate the direction and step signals.
assign s__step_pre = (s__angle[@ACCUM_WIDTH@-1] != s__angle_presum[@ACCUM_WIDTH@-1]);
always @ (posedge i_clk)
  if (i_rst) begin
    o__dir <= 1'b0;
    o__step <= 1'b0;
  end else if (@S__CLK_EN@) begin
    o__dir <= s__rate[@RATE_WIDTH@-1];
    o__step <= s__step_pre;
  end else begin
    o__dir <= o__dir;
    o__step <= o__step;
  end
@OUTMODE_BEGIN@
always @ (posedge i_clk)
  if (i_rst)
    o__mode <= @OUTMODEWIDTH@'d0;
  else if (@S__CLK_EN@)
    o__mode <= s__mode;
  else
    o__mode <= o__mode;
@OUTMODE_END@
