//
// PERIPHERAL:  AXI4-Lite slave dual-port-RAM interface
// Copyright 2014, Sinclair R.F., Inc.
//
// Note:  While the AXI4-Lite protocol allows simultaneous read and write
// operations, only one side of the dual-port RAM is available to the AXI4-lite
// interface.  This requires internal arbitration between the two operations
// with either the first or the write operation being preferred.
//
// Note:  The dual-port-ram is implemented as write-through memory.
//
// Note:  Xilinx' distributed RAM does not support dual-port write operations,
//        so a Block RAM coding style is used instead.
//
generate
localparam L__SIZE = @SIZE@;
localparam L__NBITS_SIZE = $clog2(L__SIZE);
localparam L__RESP_OKAY = 2'b00;
localparam L__RESP_EXOKAY = 2'b01;
localparam L__RESP_SLVERR = 2'b10;
localparam L__RESP_DECERR = 2'b11;
// AXI4-Lite side of the dual-port memory;
initial o_bresp = L__RESP_OKAY;
initial o_rresp = L__RESP_OKAY;
reg                     s__axi_idle             = 1'b1;
reg                     s__axi_got_waddr        = 1'b0;
reg                     s__axi_got_wdata        = 1'b0;
reg                     s__axi_got_raddr        = 1'b0;
reg [L__NBITS_SIZE-1:2] s__axi_addr             = {(L__NBITS_SIZE-2){1'b0}};
initial                 o_awready               = 1'b0;
initial                 o_wready                = 1'b0;
initial                 o_arready               = 1'b0;
always @ (posedge i_aclk)
  if (~i_aresetn) begin
    s__axi_idle         <= 1'b1;
    s__axi_got_waddr    <= 1'b0;
    s__axi_got_wdata    <= 1'b0;
    s__axi_got_raddr    <= 1'b0;
    s__axi_addr         <= {(L__NBITS_SIZE-2){1'b0}};
    o_awready           <= 1'b0;
    o_wready            <= 1'b0;
    o_arready           <= 1'b0;
  end else begin
    s__axi_idle         <= s__axi_idle;
    s__axi_got_waddr    <= s__axi_got_waddr;
    s__axi_got_wdata    <= s__axi_got_wdata;
    s__axi_got_raddr    <= s__axi_got_raddr;
    s__axi_addr         <= s__axi_addr;
    o_awready           <= 1'b0;
    o_wready            <= 1'b0;
    o_arready           <= 1'b0;
    if (s__axi_idle) begin
      if (i_awvalid) begin
        s__axi_idle <= 1'b0;
        s__axi_got_waddr <= 1'b1;
        s__axi_addr <= i_awaddr[L__NBITS_SIZE-1:2];
        o_awready <= 1'b1;
      end else if (i_arvalid) begin
        s__axi_idle <= 1'b0;
        s__axi_got_raddr <= 1'b1;
        s__axi_addr <= i_araddr[L__NBITS_SIZE-1:2];
        o_arready <= 1'b1;
      end
    end else if (s__axi_got_waddr) begin
      if (i_wvalid) begin
        s__axi_got_waddr <= 1'b0;
        s__axi_got_wdata <= 1'b1;
        o_wready <= 1'b1;
      end
    end else if (s__axi_got_wdata) begin
      if (i_bready) begin
        s__axi_got_wdata <= 1'b0;
        s__axi_idle <= 1'b1;
      end
    end else if (s__axi_got_raddr) begin
      if (i_rready) begin
        s__axi_got_raddr <= 1'b0;
        s__axi_idle <= 1'b1;
      end
    end
  end
initial o_bvalid = 1'b0;
always @ (*)
  o_bvalid = s__axi_got_wdata;
reg s__axi_arready_s = 1'b0;
always @ (posedge i_aclk)
  if (~i_aresetn)
    s__axi_arready_s <= 1'b0;
  else
    s__axi_arready_s <= o_arready;
initial o_rvalid = 1'b0;
always @ (posedge i_aclk)
  if (~i_aresetn)
    o_rvalid <= 1'b0;
  else if (s__axi_arready_s)
    o_rvalid <= 1'b1;
  else if (i_rready)
    o_rvalid <= 1'b0;
  else
    o_rvalid <= o_rvalid;
// signals common to both memory architectures
reg [L__NBITS_SIZE-1:2] s__axi_addr_s = {(L__NBITS_SIZE-2){1'b0}};
always @ (posedge i_aclk)
  s__axi_addr_s <= s__axi_addr;
reg [3:0] s__wstrb = 4'd0;
genvar ix__wstrb;
for (ix__wstrb=0; ix__wstrb<4; ix__wstrb=ix__wstrb+1) begin : gen__wstrb
  always @ (posedge i_aclk)
    s__wstrb[ix__wstrb] <= s__axi_got_waddr && i_wvalid && i_wstrb[ix__wstrb];
end
reg [7:0] s__mc_wdata = 8'd0;
always @ (posedge i_clk)
  s__mc_wdata <= s_N;
// different memory architectures required by different synthesis tools
if (@MEM8@) begin : gen_mem8
reg [7:0] s__mem[L__SIZE-1:0];
genvar ix__mem;
for (ix__mem=0; ix__mem<4; ix__mem=ix__mem+1) begin : gen__wr
  localparam L__ix_mem = ix__mem;
  always @ (posedge i_aclk) begin
    if (s__wstrb[ix__mem])
      s__mem[{ s__axi_addr_s, L__ix_mem[0+:2] }] = i_wdata[8*ix__mem+:8];
    o_rdata[8*ix__mem+:8] <= s__mem[{ s__axi_addr_s, L__ix_mem[0+:2] }];
  end
end
// Micro controller side of the dual-port memory.
reg s__mc_wr = 1'b0;
always @ (posedge i_clk)
  s__mc_wr <= s_outport && (s_T == @IX_WRITE@);
reg [L__NBITS_SIZE-1:0] s__mc_addr_s = {(L__NBITS_SIZE){1'b0}};
always @ (posedge i_clk) begin
  s__mc_addr_s <= s__mc_addr;
  if (s__mc_wr)
    s__mem[s__mc_addr_s] = s__mc_wdata;
  s__mc_rdata <= s__mem[s__mc_addr_s];
end
end else begin : gen_mem32
reg [31:0] s__mem[L__SIZE/4-1:0];
integer ix__axi;
always @ (posedge i_aclk)
  for (ix__axi=0; ix__axi<4; ix__axi=ix__axi+1)
    if (s__wstrb[ix__axi]) s__mem[s__axi_addr_s][8*ix__axi+:8] = i_wdata[8*ix__axi+:8];
always @ (posedge i_aclk)
  o_rdata <= s__mem[s__axi_addr_s];
// Micro controller side of the dual-port memory.
reg [L__NBITS_SIZE-1:2] s__mc_addr_s = {(L__NBITS_SIZE-2){1'b0}};
always @ (posedge i_clk)
  s__mc_addr_s <= s__mc_addr[L__NBITS_SIZE-1:2];
integer ix__mc_wr;
reg [3:0] s__mc_wr = 4'd0;
always @ (posedge i_clk)
  for (ix__mc_wr=0; ix__mc_wr<4; ix__mc_wr=ix__mc_wr+1)
    s__mc_wr[ix__mc_wr] <= s_outport && (s_T == @IX_WRITE@) && (s__mc_addr[0+:2] == ix__mc_wr[0+:2]);
integer ix__mc_we;
always @ (posedge i_clk)
  for (ix__mc_we=0; ix__mc_we<4; ix__mc_we=ix__mc_we+1)
    if (s__mc_wr[ix__mc_we]) s__mem[s__mc_addr_s][8*ix__mc_we+:8] = s__mc_wdata;
reg [31:0] s__mc_rdata32 = 32'd0;
always @ (posedge i_clk)
  s__mc_rdata32 <= s__mem[s__mc_addr_s];
always @ (*)
  s__mc_rdata = (s__mc_addr[0+:2] == 2'd0) ? s__mc_rdata32[ 0+:8]
              : (s__mc_addr[0+:2] == 2'd1) ? s__mc_rdata32[ 8+:8]
              : (s__mc_addr[0+:2] == 2'd2) ? s__mc_rdata32[16+:8]
              :                              s__mc_rdata32[24+:8];
end
endgenerate
