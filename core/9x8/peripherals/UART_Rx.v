//
// PERIPHERAL UART_Rx:  @NAME@
// Copyright 2013-2015 Sinclair R.F., Inc.
//
// Technique:
// - optionally synchronize the incoming signal
// - optionally deglitch the incoming signal
// - identify edges, align with value before the edge
// - generate missing edges, align values
// - assemble received bit sequence
// - run state machine counting number of received bits and waiting for delayed start bits
// - validate bit sequence and output bit sequence at end of last stop bit
// - optional FIFO
//
localparam L__BAUDMETHOD = ((@BAUDMETHOD@)+1)/2;
localparam L__BAUDMETHOD_MINUS = L__BAUDMETHOD - 2;
localparam L__BAUDMETHOD_NBITS = $clog2(L__BAUDMETHOD_MINUS+1);
localparam L__SYNC_LENGTH = @SYNC@;
localparam L__DEGLITCH_LENGTH = @DEGLITCH@;
localparam L__NSTOP = @NSTOP@;
localparam L__NRX = 1+8+L__NSTOP;
localparam L__EVENT_COUNT = 2*L__NRX-1;
localparam L__EVENT_COUNT_NBITS = $clog2(L__EVENT_COUNT+1);
localparam L__INFIFO = @INFIFO@;
localparam L__INFIFO_NBITS = $clog2((L__INFIFO==0)?1:L__INFIFO);
generate
// Either copy the input, register it, or put it through a synchronizer.
wire s__Rx_sync;
if (L__SYNC_LENGTH == 0) begin : gen__no_sync
  assign s__Rx_sync = @INPORT@;
end else if (L__SYNC_LENGTH == 1) begin : gen__short_sync
  reg s__Rx_inport_s = 1'b1;
  always @ (posedge i_clk)
    if (i_rst)
      s__Rx_inport_s <= 1'b1;
    else
      s__Rx_inport_s <= @INPORT@;
  assign s__Rx_sync = s__Rx_inport_s;
end else begin : gen__long_sync
  reg [L__SYNC_LENGTH-1:0] s__Rx_inport_s = {(L__SYNC_LENGTH){1'b1}};
  always @ (posedge i_clk)
    if (i_rst)
      s__Rx_inport_s <= {(L__SYNC_LENGTH){1'b1}};
    else
      s__Rx_inport_s <= { s__Rx_inport_s[0+:L__SYNC_LENGTH-1], @INPORT@ };
  assign s__Rx_sync = s__Rx_inport_s[L__SYNC_LENGTH-1];
end
// Either pass the received signal with no deglitching or apply deglitch
// hysteresis that consists of not changing the reported state unless all of
// the queued bits have changed state.
reg s__Rx_deglitched;
if (L__DEGLITCH_LENGTH == 0) begin : gen__nodeglitch
  always @ (*)
    s__Rx_deglitched = s__Rx_sync;
end else begin : gen__deglitch
  initial s__Rx_deglitched = 1'b1;
  reg [L__DEGLITCH_LENGTH-1:0] s__Rx_deglitch = {(L__DEGLITCH_LENGTH){1'b1}};
  always @ (posedge i_clk) begin
    s__Rx_deglitched <= (&(s__Rx_deglitch != {(L__DEGLITCH_LENGTH){s__Rx_deglitched}})) ? ~s__Rx_deglitched : s__Rx_deglitched;
    s__Rx_deglitch <= { s__Rx_deglitch[0+:L__DEGLITCH_LENGTH-1], @INPORT@ };
  end
end
// Identify edges
reg s__Rx_last = 1'b1;
always @ (posedge i_clk)
  if (i_rst)
    s__Rx_last <= 1'b1;
  else
    s__Rx_last <= s__Rx_deglitched;
reg s__Rx_edge = 1'b0;
always @ (posedge i_clk)
  if (i_rst)
    s__Rx_edge <= 1'b0;
  else
    s__Rx_edge <= (s__Rx_deglitched != s__Rx_last);
// Run a timer at twice the desired edge frequency rate.  Synchronize it to the
// incoming edges.
reg [L__BAUDMETHOD_NBITS-1:0] s__Rx_event_time = L__BAUDMETHOD_MINUS[L__BAUDMETHOD_NBITS-1:0];
reg s__Rx_event_time_msb = L__BAUDMETHOD_MINUS[L__BAUDMETHOD_NBITS-1];
wire s__Rx_event_time_expired = ({s__Rx_event_time_msb,s__Rx_event_time[L__BAUDMETHOD_NBITS-1]} == 2'b01);
always @ (posedge i_clk)
  if (i_rst) begin
    s__Rx_event_time <= L__BAUDMETHOD_MINUS[L__BAUDMETHOD_NBITS-1:0];
    s__Rx_event_time_msb <= L__BAUDMETHOD_MINUS[L__BAUDMETHOD_NBITS-1];
  end else if (s__Rx_edge || s__Rx_event_time_expired) begin
    s__Rx_event_time <= L__BAUDMETHOD_MINUS[L__BAUDMETHOD_NBITS-1:0];
    s__Rx_event_time_msb <= L__BAUDMETHOD_MINUS[L__BAUDMETHOD_NBITS-1];
  end else begin
    s__Rx_event_time <= s__Rx_event_time - { {(L__BAUDMETHOD_NBITS-1){1'b0}}, 1'b1 };
    s__Rx_event_time_msb <= s__Rx_event_time[L__BAUDMETHOD_NBITS-1];
  end
// Fabricate composite event detection.
reg s__Rx_idle;
wire s__Rx_wait_edge;
reg s__Rx_event = 1'b0;
always @ (posedge i_clk)
  if (i_rst)
    s__Rx_event <= 1'b0;
  else
    s__Rx_event <= ~s__Rx_event && ((s__Rx_wait_edge && s__Rx_edge) || (~s__Rx_idle && s__Rx_event_time_expired));
// State machine -- idle state and event (edge/fabricated-edge and midpoint) counter.
initial s__Rx_idle = 1'b1;
reg [L__EVENT_COUNT_NBITS-1:0] s__Rx_event_count = L__EVENT_COUNT[L__EVENT_COUNT_NBITS-1:0];
reg s__Rx_event_count_zero = 1'b1;
always @ (posedge i_clk)
  if (i_rst) begin
    s__Rx_event_count <= L__EVENT_COUNT[L__EVENT_COUNT_NBITS-1:0];
    s__Rx_idle <= 1'b1;
    s__Rx_event_count_zero <= 1'b1;
  end else begin
    if (s__Rx_idle && s__Rx_event)
      s__Rx_idle <= 1'b0;
    else
      s__Rx_idle <= (s__Rx_event_count_zero) ? 1'b1: s__Rx_idle;
    if (s__Rx_idle) begin
      s__Rx_event_count <= L__EVENT_COUNT[L__EVENT_COUNT_NBITS-1:0];
      s__Rx_event_count_zero <= 1'b0;
    end else if (s__Rx_event) begin
      s__Rx_event_count <= s__Rx_event_count - { {(L__EVENT_COUNT_NBITS-1){1'b0}}, 1'b1 };
      s__Rx_event_count_zero <= (s__Rx_event_count == { {(L__EVENT_COUNT_NBITS-1){1'b0}}, 1'b1 });
    end else begin
      s__Rx_event_count <= s__Rx_event_count;
      s__Rx_event_count_zero <= 1'b0;
    end
  end
assign s__Rx_wait_edge = s__Rx_idle || (L__EVENT_COUNT[0] ^ s__Rx_event_count[0]);
wire s__Rx_wait_sample = ~s__Rx_wait_edge;
// Generate a strobe when a new bit is to be recorded.
reg s__Rx_got_bit = 1'b0;
always @ (posedge i_clk)
  if (i_rst)
    s__Rx_got_bit <= 1'b0;
  else
    s__Rx_got_bit <= (~s__Rx_idle && s__Rx_wait_sample && s__Rx_event);
// Record the received bit stream after edges occur (start bit is always discarded)
reg [L__NRX-1:2] s__Rx_s = {(L__NRX-2){1'b1}};
always @ (posedge i_clk)
  if (i_rst)
    s__Rx_s <= {(L__NRX-2){1'b1}};
  else if (s__Rx_got_bit)
    s__Rx_s <= { s__Rx_last, s__Rx_s[3+:L__NRX-3] };
  else
    s__Rx_s <= s__Rx_s;
// Generate strobe to write the received byte to the output buffer.
reg s__Rx_wr = 1'b0;
reg [3:0] s__Rx_count = L__NRX[0+:4] - 4'd1;
always @ (posedge i_clk)
  if (i_rst) begin
    s__Rx_wr <= 1'b0;
    s__Rx_count <= L__NRX[0+:4] - 4'd1;
  end else if (s__Rx_idle) begin
    s__Rx_wr <= 1'b0;
    s__Rx_count <= L__NRX[0+:4] - 4'd1;
  end else if (s__Rx_got_bit) begin
    s__Rx_wr <= (s__Rx_count == 4'd1);
    s__Rx_count <= s__Rx_count - 4'd1;
  end else begin
    s__Rx_wr <= 1'b0;
    s__Rx_count <= s__Rx_count;
  end
// Optional FIFO
@RTR_BEGIN@
reg s__rtrn = 1'b1; // Disable reception until the core is out of reset.
@RTR_END@
if (L__INFIFO == 0) begin : gen__nofifo
  always @ (posedge i_clk)
    if (i_rst) begin
      s__Rx_empty <= 1'b1;
      s__Rx <= 8'h00;
    end else begin
      if (s__Rx_wr)
        s__Rx <= s__Rx_s[2+:8];
      else
        s__Rx <= s__Rx;
      if (s__Rx_wr) begin
        if (s__Rx_rd)
          s__Rx_empty <= s__Rx_empty;
        else
          s__Rx_empty <= 1'b0;
      end else begin
        if (s__Rx_rd)
          s__Rx_empty <= 1'b1;
        else
          s__Rx_empty <= s__Rx_empty;
      end
    end
  @RTR_BEGIN@
  always @ (posedge i_clk)
    if (i_rst)
      s__rtrn <= 1'b1;
    else
      s__rtrn <= ~s__Rx_idle;
  @RTR_END@
end else begin : gen__fifo
  reg [L__INFIFO_NBITS:0] s__Rx_fifo_addr_in;
  reg [L__INFIFO_NBITS:0] s__Rx_fifo_addr_out;
  wire s__Rx_shift;
  reg s__Rx_fifo_has_data = 1'b0;
  always @ (posedge i_clk)
    if (i_rst)
      s__Rx_fifo_has_data <= 1'b0;
    else
      s__Rx_fifo_has_data <= (s__Rx_fifo_addr_out != s__Rx_fifo_addr_in) && !s__Rx_shift;
  always @ (posedge i_clk)
    if (i_rst) begin
      s__Rx_empty <= 1'b1;
    end else begin
      case ({ s__Rx_fifo_has_data, s__Rx_empty, s__Rx_rd })
        3'b000 :  s__Rx_empty <= 1'b0;
        3'b001 :  s__Rx_empty <= 1'b1; // good read
        3'b010 :  s__Rx_empty <= 1'b1;
        3'b011 :  s__Rx_empty <= 1'b1; // bad read
        3'b100 :  s__Rx_empty <= 1'b0;
        3'b101 :  s__Rx_empty <= 1'b0; // shift, good read
        3'b110 :  s__Rx_empty <= 1'b0; // shift
        3'b111 :  s__Rx_empty <= 1'b1; // shift, bad read
      endcase
    end
  assign s__Rx_shift = s__Rx_fifo_has_data && (s__Rx_empty || s__Rx_rd);
  reg s__Rx_full = 1'b0;
  always @ (posedge i_clk)
    if (i_rst)
      s__Rx_full <= 1'b0;
    else
      s__Rx_full <= (s__Rx_fifo_addr_in == (s__Rx_fifo_addr_out ^ { 1'b1, {(L__INFIFO_NBITS){1'b0}} }));
  reg [7:0] s__Rx_fifo_mem[L__INFIFO-1:0];
  initial s__Rx_fifo_addr_in = {(L__INFIFO_NBITS+1){1'b0}};
  always @ (posedge i_clk)
    if (i_rst)
      s__Rx_fifo_addr_in <= {(L__INFIFO_NBITS+1){1'b0}};
    else if (s__Rx_wr && (!s__Rx_full || s__Rx_shift)) begin
      s__Rx_fifo_addr_in <= s__Rx_fifo_addr_in + { {(L__INFIFO_NBITS){1'b0}}, 1'b1 };
      s__Rx_fifo_mem[s__Rx_fifo_addr_in[0+:L__INFIFO_NBITS]] <= s__Rx_s[2+:8];
    end else
      s__Rx_fifo_addr_in <= s__Rx_fifo_addr_in;
  initial s__Rx_fifo_addr_out = {(L__INFIFO_NBITS+1){1'b0}};
  always @ (posedge i_clk)
    if (i_rst) begin
      s__Rx_fifo_addr_out <= {(L__INFIFO_NBITS+1){1'b0}};
      s__Rx <= 8'h00;
    end else if (s__Rx_shift) begin
      s__Rx_fifo_addr_out <= s__Rx_fifo_addr_out + { {(L__INFIFO_NBITS){1'b0}}, 1'b1 };
      s__Rx <= s__Rx_fifo_mem[s__Rx_fifo_addr_out[0+:L__INFIFO_NBITS]];
    end else begin
      s__Rx_fifo_addr_out <= s__Rx_fifo_addr_out;
      s__Rx <= s__Rx;
    end
  @RTR_BEGIN@
  // Isn't ready to receive if the FIFO is full or if the FIFO is almost full.
  reg [L__INFIFO_NBITS:0] s__Rx_used = {(L__INFIFO_NBITS+1){1'b0}};
  always @ (posedge i_clk)
    if (i_rst)
      s__Rx_used <= {(L__INFIFO_NBITS+1){1'b0}};
    else
      s__Rx_used <= s__Rx_fifo_addr_in - s__Rx_fifo_addr_out;
  always @ (posedge i_clk)
    if (i_rst)
      s__rtrn <= 1'b1;
    else
      s__rtrn <= s__Rx_used[L__INFIFO_NBITS] || &(s__Rx_used[L__INFIFO_NBITS-1:@RTR_FIFO_COMPARE@]);
  @RTR_END@
end
@RTR_BEGIN@
always @ (*)
  @RTR_SIGNAL@ = @RTRN_INVERT@s__rtrn;
@RTR_END@
endgenerate
