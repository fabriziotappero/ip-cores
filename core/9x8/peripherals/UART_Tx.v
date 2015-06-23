//
// PERIPHERAL UART_Tx:  @NAME@
// Copyright 2013-2015 Sinclair R.F., Inc.
//
localparam L__OUTFIFO_NBITS = $clog2(@OUTFIFO@);
localparam L__COUNT         = @BAUDMETHOD@-1;
localparam L__COUNT_NBITS   = $clog2(L__COUNT+1);
localparam L__NTX           = 1+8+@NSTOP@-1;
localparam L__NTX_NBITS     = $clog2((L__NTX==0)?1:L__NTX);
generate
reg  [7:0] s__Tx_data;
wire       s__Tx_enabled = @ENABLED@;
reg        s__Tx_go;
reg        s__Tx_uart_busy;
if (@OUTFIFO@ == 0) begin : gen__nooutfifo
  always @ (s__Tx_uart_busy, s__Tx_enabled)
    s__Tx_busy = s__Tx_uart_busy || !s__Tx_enabled;
  always @ (s__Tx)
    s__Tx_data = s__Tx;
  always @ (s__Tx_wr)
    s__Tx_go = s__Tx_wr;
end else begin : gen__outfifo
  reg [7:0] s__Tx_fifo_mem[@OUTFIFO@-1:0];
  reg [L__OUTFIFO_NBITS:0] s__Tx_fifo_addr_in = {(L__OUTFIFO_NBITS+1){1'b0}};
  always @ (posedge i_clk)
    if (i_rst)
      s__Tx_fifo_addr_in <= {(L__OUTFIFO_NBITS+1){1'b0}};
    else if (s__Tx_wr) begin
      s__Tx_fifo_addr_in <= s__Tx_fifo_addr_in + { {(L__OUTFIFO_NBITS){1'b0}}, 1'b1 };
      s__Tx_fifo_mem[s__Tx_fifo_addr_in[0+:L__OUTFIFO_NBITS]] <= s__Tx;
    end else
      s__Tx_fifo_addr_in <= s__Tx_fifo_addr_in;
  reg [L__OUTFIFO_NBITS:0] s__Tx_fifo_addr_out;
  reg s__Tx_fifo_has_data = 1'b0;
  reg s__Tx_fifo_full = 1'b0;
  always @ (posedge i_clk)
    if (i_rst) begin
      s__Tx_fifo_has_data <= 1'b0;
      s__Tx_fifo_full <= 1'b0;
    end else begin
      s__Tx_fifo_has_data <= (s__Tx_fifo_addr_out != s__Tx_fifo_addr_in);
      s__Tx_fifo_full <= (s__Tx_fifo_addr_out == (s__Tx_fifo_addr_in ^ { 1'b1, {(L__OUTFIFO_NBITS){1'b0}} }));
    end
  initial s__Tx_go = 1'b0;
  always @ (posedge i_clk)
    if (i_rst)
      s__Tx_go <= 1'b0;
    else if (s__Tx_enabled && s__Tx_fifo_has_data && !s__Tx_uart_busy && !s__Tx_go)
      s__Tx_go <= 1'b1;
    else
      s__Tx_go <= 1'b0;
  initial s__Tx_fifo_addr_out = {(L__OUTFIFO_NBITS+1){1'b0}};
  always @ (posedge i_clk)
    if (i_rst)
      s__Tx_fifo_addr_out <= {(L__OUTFIFO_NBITS+1){1'b0}};
    else if (s__Tx_go)
      s__Tx_fifo_addr_out <= s__Tx_fifo_addr_out + { {(L__OUTFIFO_NBITS){1'b0}}, 1'b1 };
    else
      s__Tx_fifo_addr_out <= s__Tx_fifo_addr_out;
  initial s__Tx_data = 8'd0;
  always @ (posedge i_clk)
    if (i_rst)
      s__Tx_data <= 8'd0;
    else
      s__Tx_data <= s__Tx_fifo_mem[s__Tx_fifo_addr_out[0+:L__OUTFIFO_NBITS]];
  always @ (s__Tx_fifo_full)
    s__Tx_busy = s__Tx_fifo_full;
end
// Count the clock cycles to decimate to the desired baud rate.
reg [L__COUNT_NBITS-1:0] s__Tx_count = {(L__COUNT_NBITS){1'b0}};
reg s__Tx_count_is_zero = 1'b0;
always @ (posedge i_clk)
  if (i_rst) begin
    s__Tx_count <= {(L__COUNT_NBITS){1'b0}};
    s__Tx_count_is_zero <= 1'b0;
  end else if (s__Tx_go || s__Tx_count_is_zero) begin
    s__Tx_count <= L__COUNT[0+:L__COUNT_NBITS];
    s__Tx_count_is_zero <= 1'b0;
  end else begin
    s__Tx_count <= s__Tx_count - { {(L__COUNT_NBITS-1){1'b0}}, 1'b1 };
    s__Tx_count_is_zero <= (s__Tx_count == { {(L__COUNT_NBITS-1){1'b0}}, 1'b1 });
  end
// Latch the bits to output.
reg [7:0] s__Tx_stream = 8'hFF;
always @ (posedge i_clk)
  if (i_rst)
    s__Tx_stream <= 8'hFF;
  else if (s__Tx_go)
    s__Tx_stream <= s__Tx_data;
  else if (s__Tx_count_is_zero)
    s__Tx_stream <= { 1'b1, s__Tx_stream[1+:7] };
  else
    s__Tx_stream <= s__Tx_stream;
// Generate the output bit stream.
initial @NAME@ = 1'b1;
always @ (posedge i_clk)
  if (i_rst)
    @NAME@ <= 1'b1;
  else if (s__Tx_go)
    @NAME@ <= 1'b0;
  else if (s__Tx_count_is_zero)
    @NAME@ <= s__Tx_stream[0];
  else
    @NAME@ <= @NAME@;
// Count down the number of bits.
reg [L__NTX_NBITS-1:0] s__Tx_n = {(L__NTX_NBITS){1'b0}};
always @ (posedge i_clk)
  if (i_rst)
    s__Tx_n <= {(L__NTX_NBITS){1'b0}};
  else if (s__Tx_go)
    s__Tx_n <= L__NTX[0+:L__NTX_NBITS];
  else if (s__Tx_count_is_zero)
    s__Tx_n <= s__Tx_n - { {(L__NTX_NBITS-1){1'b0}}, 1'b1 };
  else
    s__Tx_n <= s__Tx_n;
// The status bit is 1 if the core is busy and 0 otherwise.
initial s__Tx_uart_busy = 1'b1;
always @ (posedge i_clk)
  if (i_rst)
    s__Tx_uart_busy <= 1'b0;
  else if (s__Tx_go)
    s__Tx_uart_busy <= 1'b1;
  else if (s__Tx_count_is_zero && (s__Tx_n == {(L__NTX_NBITS){1'b0}}))
    s__Tx_uart_busy <= 1'b0;
  else
    s__Tx_uart_busy <= s__Tx_uart_busy;
endgenerate
