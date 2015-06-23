//
// PERIPHERAL:  AXI4-Lite Master
// Copyright 2014, Sinclair R.F., Inc.
//
generate
localparam L__ADDRESS_WIDTH = @ADDRESS_WIDTH@;
localparam L__ISSYNC = @ISSYNC@;
localparam L__RESP_OKAY = 2'b00;
// Shift 8-bit values into the output 32-bit word.
initial o_wdata = 32'd0;
always @ (posedge i_clk)
  if (i_rst)
    o_wdata <= 32'd0;
  else if (s_outport && (s_T == 8'd@IX_DATA@))
    o_wdata <= { o_wdata[0+:24], s_N };
  else
    o_wdata <= o_wdata;
// Shift 8-bit values into the common output address and coerce 2 lsb of output
// addresses to 0.
reg [L__ADDRESS_WIDTH-1:0] s__addr = @ADDRESS_WIDTH@'d0;
if (L__ADDRESS_WIDTH <= 8) begin : gen__short_addr
  always @ (posedge i_clk)
    if (i_rst)
      s__addr <= @ADDRESS_WIDTH@'d0;
    else if (s_outport && (s_T == 8'd@IX_ADDRESS@))
      s__addr <= s_N[0+:L__ADDRESS_WIDTH];
    else
      s__addr <= s__addr;
end else begin : gen__long_addr
  always @ (posedge i_clk)
    if (i_rst)
      s__addr <= @ADDRESS_WIDTH@'d0;
    else if (s_outport && (s_T == 8'd@IX_ADDRESS@))
      s__addr <= { s__addr[L__ADDRESS_WIDTH-9:0], s_N };
    else
      s__addr <= s__addr;
end
always @ (*) begin
  o_awaddr = { s__addr[L__ADDRESS_WIDTH-1:2], 2'b00 };
  o_araddr = { s__addr[L__ADDRESS_WIDTH-1:2], 2'b00 };
end
// Either use the raw write strobe or synchronize the write strobe.
wire s__wr_aclk;
if (L__ISSYNC) begin : gen__sync_wr
  assign s__wr_aclk = s__wr;
end else begin : gen__async_wr
  reg s__wr_toggle = 1'b0;
  always @ (posedge i_clk)
    s__wr_toggle <= s__wr ^ s__wr_toggle;
  reg [3:0] s__wr_s = 4'd0;
  always @ (i_aclk)
    s__wr_s <= { s__wr_s[0+:3], s__wr_toggle };
  reg s__wr_aclk_out = 1'b0;
  always @ (posedge i_aclk)
    s__wr_aclk_out <= ^s__wr_s[2+:2];
  assign s__wr_aclk = s__wr_aclk_out;
end
// Write side of the bus.
initial o_awvalid = 1'b0;
initial o_wvalid  = 1'b0;
initial o_bready  = 1'b0;
reg [2:0] s__pending_wr = 3'h0;
always @ (posedge i_aclk)
  if (~i_aresetn) begin
    o_awvalid <= 1'b0;
    o_wvalid  <= 1'b0;
    o_bready  <= 1'b0;
    s__pending_wr <= 3'h0;
  end else begin
    o_awvalid <= o_awvalid;
    o_wvalid  <= o_wvalid;
    o_bready  <= o_bready;
    s__pending_wr <= s__pending_wr;
    if (s__wr_aclk) begin
      o_awvalid <= 1'b1;
      o_wvalid  <= 1'b1;
      o_bready  <= 1'b0;
      s__pending_wr <= 3'b111;
    end else begin
      if (i_awready) begin
        o_awvalid <= 1'b0;
        s__pending_wr[0] <= 1'b0;
      end
      if (i_wready) begin
        o_wvalid <= 1'b0;
        s__pending_wr[1] <= 1'b0;
      end
      if (i_bvalid) begin
        if (!o_bready)
          o_bready <= 1'b1;
        else begin
          o_bready <= 1'b0;
          s__pending_wr[2] <= 1'b0;
        end
      end
    end
  end

// Either use the raw read strobe or synchronize the read strobe.
wire s__rd_aclk;
if (L__ISSYNC) begin : gen__sync_rd
  assign s__rd_aclk = s__rd;
end else begin : gen__async_rd
  reg s__rd_toggle = 1'b0;
  always @ (posedge i_clk)
    s__rd_toggle <= s__rd ^ s__rd_toggle;
  reg [3:0] s__rd_s = 4'd0;
  always @ (i_aclk)
    s__rd_s <= { s__rd_s[0+:3], s__rd_toggle };
  reg s__rd_aclk_out = 1'b0;
  always @ (posedge i_aclk)
    s__rd_aclk_out <= ^s__rd_s[2+:2];
  assign s__rd_aclk = s__rd_aclk_out;
end

// Generate the read address valid signal and record the address acknowledgement
// pending status.
reg s__pending_rd_aclk = 1'b0;
always @ (posedge i_aclk)
  if (~i_aresetn) begin
    o_arvalid <= 1'b0;
    s__pending_rd_aclk <= 1'b0;
  end else if (s__rd_aclk) begin
    o_arvalid <= 1'b1;
    s__pending_rd_aclk <= 1'b1;
  end else if (i_arready) begin
    o_arvalid <= 1'b0;
    s__pending_rd_aclk <= 1'b0;
  end else begin
    o_arvalid <= o_arvalid;
    s__pending_rd_aclk <= s__pending_rd_aclk;
  end

// Generate a strobe from the i_aclk domain to the i_clk domain to latch the
// incoming read data and then generate a strobe in the reverse direction to
// acknowledge the data.
wire s__latch_read;
if (L__ISSYNC) begin : gen__sync_read_ack
  always @ (posedge i_aclk)
    if (~i_aresetn)
      o_rready <= 1'b0;
    else
      o_rready <= i_rvalid && ~o_rready;
  assign s__latch_read = o_rready;
end else begin : gen__async_read_ack
  reg s__rvalid_toggle = 1'b0;
  always @ (i_aclk)
    if (~i_aresetn)
      s__rvalid_toggle <= 1'b0;
    else if (s__rd_aclk)
      s__rvalid_toggle <= 1'b0;
    else if (i_rvalid)
      s__rvalid_toggle <= 1'b1;
    else
      s__rvalid_toggle <= s__rvalid_toggle;
  reg [3:0] s__rvalid_toggle_s = 4'd0;
  always @ (posedge i_clk)
    s__rvalid_toggle_s <= { s__rvalid_toggle_s[0+:2], s__rvalid_toggle };
  reg s__latch_read_p = 1'b0;
  always @ (posedge i_clk)
    if (i_rst)
      s__latch_read_p <= 1'b0;
    else
      s__latch_read_p <= (s__rvalid_toggle_s[2+:2] == 2'b01);
  assign s__latch_read = s__latch_read_p;
  reg s__latch_toggle = 1'b0;
  always @ (posedge i_clk)
    if (i_rst)
      s__latch_toggle <= 1'b0;
    else if (s__rd)
      s__latch_toggle <= 1'b0;
    else if (s__latch_read_p)
      s__latch_toggle <= 1'b1;
    else
      s__latch_toggle <= s__latch_toggle;
  reg [3:0] s__latch_toggle_s = 4'd0;
  always @ (posedge i_aclk)
    s__latch_toggle_s <= { s__latch_toggle_s[0+:3], s__latch_toggle };
  always @ (posedge i_aclk)
    if (~i_aresetn)
      o_rready <= 1'b0;
    else if (s__rd_aclk)
      o_rready <= 1'b0;
    else
      o_rready <= (s__latch_toggle_s[2+:2] == 2'b01);
end

// Track the "pending" status of the data acknowledgement.
reg s__pending_rd_clk = 1'b0;
always @ (posedge i_clk)
  if (i_rst)
    s__pending_rd_clk <= 1'b0;
  else if (s__rd)
    s__pending_rd_clk <= 1'b1;
  else if (s__latch_read)
    s__pending_rd_clk <= 1'b0;
  else
    s__pending_rd_clk <= s__pending_rd_clk;

// Store the received value in a 32-bit word and right shift it when it's read.
always @ (posedge i_clk)
  if (i_rst)
    s__read <= 32'd0;
  else if (s__latch_read)
    s__read <= i_rdata;
  else if (s_inport && (s_T == 8'd@IX_READ@))
    s__read <= { 8'd0, s__read[8+:24] };

// Composite status (non-zero indicates the bus has not finished the last
// transaction).
always @ (posedge i_clk)
  s__busy <= { s__pending_rd_clk, s__pending_rd_aclk, s__pending_wr };

// Monitor the bresp and rresp 2-bit signals for non-OK indication
always @ (posedge i_aclk)
  if (~i_aresetn)
    s__error <= 2'd0;
  else begin
    if (i_bvalid && o_bready) s__error[0] <= (i_bresp != L__RESP_OKAY);
    if (i_rvalid && o_rready) s__error[1] <= (i_rresp != L__RESP_OKAY);
  end

endgenerate
