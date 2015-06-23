//**************************************************************
// Module             : bustap_jtag_v1_0.v
// Platform           : Ubuntu 14.04 
// Simulator          : Modelsim 6.5b
// Synthesizer        : Vivado 2014.2
// Place and Route    : Vivado 2014.2
// Targets device     : Zynq 7000
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.4 
// Date               : 2014/09/22
// Description        : axi interface to pipelined access
//                      interface converter. axi pass through
//                      @Note: AXI-Lite is supported.
//**************************************************************

`timescale 1ns/1ns

module bustap_jtag_v1_0 #
(
  parameter integer C_S00_AXI_DATA_WIDTH = 32,
  parameter integer C_S00_AXI_ADDR_WIDTH = 32,
  parameter integer C_M00_AXI_DATA_WIDTH = 32,
  parameter integer C_M00_AXI_ADDR_WIDTH = 32
) 
(
  // AXI Slave Interface
  input wire  s00_axi_aclk,
  input wire  s00_axi_aresetn,
  input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
  input wire [2 : 0] s00_axi_awprot,
  input wire  s00_axi_awvalid,
  output wire  s00_axi_awready,
  input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
  input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
  input wire  s00_axi_wvalid,
  output wire  s00_axi_wready,
  output wire [1 : 0] s00_axi_bresp,
  output wire  s00_axi_bvalid,
  input wire  s00_axi_bready,
  input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
  input wire [2 : 0] s00_axi_arprot,
  input wire  s00_axi_arvalid,
  output wire  s00_axi_arready,
  output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
  output wire [1 : 0] s00_axi_rresp,
  output wire  s00_axi_rvalid,
  input wire  s00_axi_rready,

  // AXI Master Interface
  input wire  m00_axi_aclk,
  input wire  m00_axi_aresetn,
  output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
  output wire [2 : 0] m00_axi_awprot,
  output wire  m00_axi_awvalid,
  input wire  m00_axi_awready,
  output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
  output wire [(C_M00_AXI_DATA_WIDTH/8)-1 : 0] m00_axi_wstrb,
  output wire  m00_axi_wvalid,
  input wire  m00_axi_wready,
  input wire [1 : 0] m00_axi_bresp,
  input wire  m00_axi_bvalid,
  output wire  m00_axi_bready,
  output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
  output wire [2 : 0] m00_axi_arprot,
  output wire  m00_axi_arvalid,
  input wire  m00_axi_arready,
  input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
  input wire [1 : 0] m00_axi_rresp,
  input wire  m00_axi_rvalid,
  output wire  m00_axi_rready
);

// Pass Through  
assign m00_axi_awaddr = s00_axi_awaddr;
assign m00_axi_awprot = s00_axi_awprot;
assign m00_axi_awvalid = s00_axi_awvalid;
assign s00_axi_awready = m00_axi_awready;
assign m00_axi_wdata = s00_axi_wdata;
assign m00_axi_wstrb = s00_axi_wstrb;
assign m00_axi_wvalid = s00_axi_wvalid;
assign s00_axi_wready = m00_axi_wready;
assign s00_axi_bresp = m00_axi_bresp;
assign s00_axi_bvalid = m00_axi_bvalid;
assign m00_axi_bready = s00_axi_bready;
assign m00_axi_araddr = s00_axi_araddr;
assign m00_axi_arprot = s00_axi_arprot;
assign m00_axi_arvalid = s00_axi_arvalid;
assign s00_axi_arready = m00_axi_arready;
assign s00_axi_rdata = m00_axi_rdata;
assign s00_axi_rresp = m00_axi_rresp;
assign s00_axi_rvalid = m00_axi_rvalid;
assign m00_axi_rready = s00_axi_rready;

// latch address and data, does not support simultaneous read and write
reg [C_S00_AXI_ADDR_WIDTH-1:0] addr_latch;
always @(posedge s00_axi_aclk) begin
  if      (s00_axi_awvalid && s00_axi_awready)
    addr_latch <= s00_axi_awaddr;
  else if (s00_axi_arvalid && s00_axi_arready)
    addr_latch <= s00_axi_araddr;
  else
    addr_latch <= addr_latch;
end

reg [C_S00_AXI_DATA_WIDTH-1:0] data_latch;
always @(posedge s00_axi_aclk) begin
  if      (s00_axi_wvalid && s00_axi_wready)
    data_latch <= s00_axi_wdata;
  else if (s00_axi_rvalid && s00_axi_rready)
    data_latch <= s00_axi_rdata;
  else
    data_latch <= data_latch;
end

// generate wr/rd pulse
reg wr_pulse;
always @(posedge s00_axi_aclk or negedge s00_axi_aresetn) begin
  if (!s00_axi_aresetn)
    wr_pulse <= 1'b0;
  else if (s00_axi_wvalid && s00_axi_wready)
    wr_pulse <= 1'b1;
  else
    wr_pulse <= 1'b0;
end

reg rd_pulse;
always @(posedge s00_axi_aclk or negedge s00_axi_aresetn) begin
  if (!s00_axi_aresetn)
    rd_pulse <= 1'b0;
  else if (s00_axi_rvalid && s00_axi_rready)
    rd_pulse <= 1'b1;
  else
    rd_pulse <= 1'b0;
end

// map to pipelined access interface
wire        clk     = s00_axi_aclk;
wire        wr_en   = wr_pulse;
wire        rd_en   = rd_pulse;
wire [31:0] addr_in = addr_latch[31:0];
wire [31:0] data_in = data_latch;

up_monitor inst (
	.clk(clk),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr_in(addr_in),
	.data_in(data_in)
);

endmodule
