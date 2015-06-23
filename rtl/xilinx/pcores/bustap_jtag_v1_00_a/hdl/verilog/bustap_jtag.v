//**************************************************************
// Module             : bustap_jtag.v
// Platform           : Ubuntu 10.04 
// Simulator          : Modelsim 6.5b
// Synthesizer        : PlanAhead 14.2
// Place and Route    : PlanAhead 14.2
// Targets device     : Zynq 7000
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.3 
// Date               : 2012/11/19
// Description        : axi interface to pipelined access
//                      interface converter.
//                      @Note: AXI-Lite is supported.
//**************************************************************

`timescale 1ns/1ns

module bustap_jtag (
  // Global Signals
  ACLK,
  ARESETN,

  // Write Address Channel
  AWADDR,
  AWPROT,
  AWVALID,
  AWREADY,

  // Write Channel
  WDATA,
  WSTRB,
  WVALID,
  WREADY,

  // Write Response Channel
  BRESP,
  BVALID,
  BREADY,

  // Read Address Channel
  ARADDR,
  ARPROT,
  ARVALID,
  ARREADY,

  // Read Channel
  RDATA,
  RRESP,
  RVALID,
  RREADY,

  CHIPSCOPE_ICON_CONTROL0,
  CHIPSCOPE_ICON_CONTROL1,
  CHIPSCOPE_ICON_CONTROL2
);

  // Set C_DATA_WIDTH to the data-bus width required
  parameter C_DATA_WIDTH = 32;        // data bus width, default = 32-bit
  // Set C_ADDR_WIDTH to the address-bus width required
  parameter C_ADDR_WIDTH = 32;        // address bus width, default = 32-bit

  localparam DATA_MAX   = C_DATA_WIDTH-1;              // data max index
  localparam ADDR_MAX   = C_ADDR_WIDTH-1;              // address max index
  localparam STRB_WIDTH = C_DATA_WIDTH/8;              // WSTRB width
  localparam STRB_MAX   = STRB_WIDTH-1;              // WSTRB max index

  // - Global Signals
  input                ACLK;        // AXI Clock
  input                ARESETN;     // AXI Reset

  // - Write Address Channel
  input   [ADDR_MAX:0] AWADDR;  // M -> S
  input          [2:0] AWPROT;  // M -> S
  input                AWVALID;  // M -> S
  input                AWREADY;  // S -> M

  // - Write Data Channel
  input                WVALID;  // M -> S
  input                WREADY;  // S -> M
  input   [DATA_MAX:0] WDATA;  // M -> S
  input   [STRB_MAX:0] WSTRB;  // M -> S

  // - Write Response Channel
  input          [1:0] BRESP;  // S -> M
  input                BVALID;  // S -> M
  input                BREADY;  // M -> S

  // - Read Address Channel
  input   [ADDR_MAX:0] ARADDR;  // M -> S
  input          [2:0] ARPROT;  // M -> S
  input                ARVALID;  // M -> S
  input                ARREADY;  // S -> M

  // - Read Data Channel
  input   [DATA_MAX:0] RDATA;  // S -> M
  input          [1:0] RRESP;  // S -> M
  input                RVALID;  // S -> M
  input                RREADY;  // M -> S

  input [35:0] CHIPSCOPE_ICON_CONTROL0, CHIPSCOPE_ICON_CONTROL1, CHIPSCOPE_ICON_CONTROL2;

// latch address and data
reg [ADDR_MAX:0] addr_latch;
always @(posedge ACLK) begin
  if      (AWVALID && AWREADY)
    addr_latch <= AWADDR;
  else if (ARVALID && ARREADY)
    addr_latch <= ARADDR;
  else
    addr_latch <= addr_latch;
end

reg [DATA_MAX:0] data_latch;
always @(posedge ACLK) begin
  if      (WVALID && WREADY)
    data_latch <= WDATA;
  else if (RVALID && RREADY)
    data_latch <= RDATA;
  else
    data_latch <= data_latch;
end

// generate wr/rd pulse
reg wr_pulse;
always @(posedge ACLK or negedge ARESETN) begin
  if (!ARESETN)
    wr_pulse <= 1'b0;
  else if (WVALID && WREADY)
    wr_pulse <= 1'b1;
  else
    wr_pulse <= 1'b0;
end

reg rd_pulse;
always @(posedge ACLK or negedge ARESETN) begin
  if (!ARESETN)
    rd_pulse <= 1'b0;
  else if (RVALID && RREADY)
    rd_pulse <= 1'b1;
  else
    rd_pulse <= 1'b0;
end

// map to pipelined access interface
wire        clk     = ACLK;
wire        wr_en   = wr_pulse;
wire        rd_en   = rd_pulse;
wire [31:0] addr_in = addr_latch[31:0];
wire [31:0] data_in = data_latch;

up_monitor inst (
	.clk(clk),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr_in(addr_in),
	.data_in(data_in),
        .icontrol0(CHIPSCOPE_ICON_CONTROL0),
        .icontrol1(CHIPSCOPE_ICON_CONTROL1),
        .icontrol2(CHIPSCOPE_ICON_CONTROL2)
);

endmodule
