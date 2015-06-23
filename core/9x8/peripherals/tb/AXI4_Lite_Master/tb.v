/*******************************************************************************
 *
 * Copyright 2013, Sinclair R.F., Inc.
 *
 * Test bench for the AXI4-Lite master peripheral.
 *
 ******************************************************************************/

`timescale 1ns/1ps

module tb;

localparam L_RESP_OKAY = 2'b00;

// 100 MHz clock
reg s_clk = 1'b1;
always @ (s_clk)
  s_clk <= #5 ~s_clk;

reg s_rst = 1'b1;
initial begin
  repeat (5) @ (posedge s_clk);
  s_rst = 1'b0;
end

// AXI4-Lite signals
wire            s_alm_aresetn   = ~s_rst;
wire            s_alm_aclk      = s_clk;
wire            s_alm_awvalid;
reg             s_alm_awready;
wire      [6:0] s_alm_awaddr;
wire            s_alm_wvalid;
reg             s_alm_wready;
wire     [31:0] s_alm_wdata;
wire      [3:0] s_alm_wstrb;
reg       [1:0] s_alm_bresp     = L_RESP_OKAY;
reg             s_alm_bvalid;
wire            s_alm_bready;
wire            s_alm_arvalid;
reg             s_alm_arready;
wire      [6:0] s_alm_araddr;
reg             s_alm_rvalid;
wire            s_alm_rready;
reg      [31:0] s_alm_rdata;
reg       [1:0] s_alm_rresp     = L_RESP_OKAY;

// diagnostic signals
wire      [7:0] s_diag_data;
wire            s_diag_wr;
wire            s_done;

tb_AXI4_Lite_Master uut(
  // synchronous reset and processor clock
  .i_rst                (s_rst),
  .i_clk                (s_clk),
  // AXI4-Lite Master
  .alm_aresetn          (s_alm_aresetn),
  .alm_aclk             (s_alm_aclk),
  .alm_awvalid          (s_alm_awvalid),
  .alm_awready          (s_alm_awready),
  .alm_awaddr           (s_alm_awaddr),
  .alm_wvalid           (s_alm_wvalid),
  .alm_wready           (s_alm_wready),
  .alm_wdata            (s_alm_wdata),
  .alm_wstrb            (s_alm_wstrb),
  .alm_bresp            (s_alm_bresp),
  .alm_bvalid           (s_alm_bvalid),
  .alm_bready           (s_alm_bready),
  .alm_arvalid          (s_alm_arvalid),
  .alm_arready          (s_alm_arready),
  .alm_araddr           (s_alm_araddr),
  .alm_rvalid           (s_alm_rvalid),
  .alm_rready           (s_alm_rready),
  .alm_rdata            (s_alm_rdata),
  .alm_rresp            (s_alm_rresp),
  // diagnostic output
  .o_diag_data          (s_diag_data),
  .o_diag_wr            (s_diag_wr),
  // program termination
  .o_done               (s_done)
);

// declare the memory

reg [7:0] s_mem[127:0];

//
// Acknowledge write signals.
//

initial s_alm_awready = 1'b0;
always @ (posedge s_alm_aclk)
  if (~s_alm_aresetn)
    s_alm_awready <= 1'b0;
  else
    s_alm_awready <= s_alm_awvalid && ~s_alm_awready;

initial s_alm_wready = 1'b0;
always @ (posedge s_alm_aclk)
  if (~s_alm_aresetn)
    s_alm_wready <= 1'b0;
  else
    s_alm_wready <= s_alm_wvalid && ~s_alm_wready;

initial s_alm_bvalid = 1'b0;
integer ix_write;
always @ (posedge s_alm_aclk)
  if (~s_alm_aresetn)
    s_alm_bvalid <= 1'b0;
  else if (s_alm_awvalid && s_alm_awready) begin
    s_alm_bvalid <= 1'b1;
    for (ix_write=0; ix_write<4; ix_write=ix_write+1)
      if (s_alm_wstrb[ix_write])
        s_mem[{ s_alm_awaddr[6:2], ix_write[1:0] }] <= s_alm_wdata[8*ix_write+:8];
  end else if (s_alm_bready)
    s_alm_bvalid <= 1'b0;
  else
    s_alm_bvalid <= s_alm_bvalid;

always @ (posedge s_alm_aclk) begin
  if (s_alm_awvalid && s_alm_awready) $display("%14d -- awready issued : 0x%h", $time, s_alm_awaddr);
  if (s_alm_wvalid && s_alm_wready) $display("%14d -- wready issued : 0x%h 0x%h", $time, s_alm_wdata, s_alm_wstrb);
  if (s_alm_bready && s_alm_bvalid) $display("%14d -- bvalid issued", $time);
end

//
// Acknowledge read.
//

initial s_alm_arready = 1'b0;
always @ (posedge s_alm_aclk)
  if (~s_alm_aresetn)
    s_alm_arready <= 1'b0;
  else
    s_alm_arready <= s_alm_arvalid && ~s_alm_arready;

localparam L_XOR_CONSTANT = 32'h5A5A_5A5A;
initial s_alm_rdata = 32'd0;
integer ix_read;
always @ (posedge s_alm_aclk)
  if (~s_alm_aresetn)
    s_alm_rdata <= 32'd0;
  else if (s_alm_arvalid && s_alm_arready)
    for (ix_read=0; ix_read<4; ix_read=ix_read+1)
      s_alm_rdata[8*ix_read+:8] <= s_mem[{ s_alm_araddr[6:2], ix_read[1:0] }];
  else
    s_alm_rdata <= s_alm_rdata;

initial s_alm_rvalid = 1'b0;
always @ (posedge s_alm_aclk)
  if (~s_alm_aresetn)
    s_alm_rvalid <= 1'b0;
  else if (s_alm_arready && s_alm_arvalid)
    s_alm_rvalid <= 1'b1;
  else
    s_alm_rvalid <= s_alm_rvalid && ~s_alm_rready;

always @ (posedge s_alm_aclk) begin
  if (s_alm_arvalid && s_alm_arready) $display("%14d -- arready issued : 0x%h", $time, s_alm_araddr);
  if (s_alm_rready && s_alm_rvalid) $display("%14d -- rready recieved : 0x%8h", $time, s_alm_rdata);
end

//
// Diagnostic printout.
//

always @ (posedge s_clk)
  if (s_diag_wr)
    $display("%14d : 0x%02h", $time, s_diag_data);

//
// Termination criterion.
//

always @ (posedge s_clk)
  if (s_done)
    $finish;

endmodule
