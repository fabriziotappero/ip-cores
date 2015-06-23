`timescale 1ns/1ns

module ha1588_axi
  #(
    parameter integer C_S_AXI_REG_ADDR_WIDTH             = 32,
    parameter integer C_S_AXI_REG_DATA_WIDTH             = 32,

    parameter integer C_EXTERNAL_INTR_OUT_WIDTH          = 1
   )
  (
    // Register Slave System Signals
    input wire                                 S_AXI_REG_ACLK,
    input wire                                 S_AXI_REG_ARESETN,
 
    // Register Slave Interface Write Address Ports
    input  wire [C_S_AXI_REG_ADDR_WIDTH-1:0]   S_AXI_REG_AWADDR,
    input  wire [3-1:0]                        S_AXI_REG_AWPROT,
    input  wire                                S_AXI_REG_AWVALID,
    output wire                                S_AXI_REG_AWREADY,

    // Register Slave Interface Write Data Ports
    input  wire [C_S_AXI_REG_DATA_WIDTH-1:0]   S_AXI_REG_WDATA,
    input  wire [C_S_AXI_REG_DATA_WIDTH/8-1:0] S_AXI_REG_WSTRB,
    input  wire                                S_AXI_REG_WVALID,
    output wire                                S_AXI_REG_WREADY,

    // Register Slave Interface Write Response Ports
    output wire [2-1:0]                        S_AXI_REG_BRESP,
    output reg                                 S_AXI_REG_BVALID,
    input  wire                                S_AXI_REG_BREADY,

    // Register Slave Interface Read Address Ports
    input  wire [C_S_AXI_REG_ADDR_WIDTH-1:0]   S_AXI_REG_ARADDR,
    input  wire [3-1:0]                        S_AXI_REG_ARPROT,
    input  wire                                S_AXI_REG_ARVALID,
    output wire                                S_AXI_REG_ARREADY,

    // Register Slave Interface Read Data Ports
    output wire [C_S_AXI_REG_DATA_WIDTH-1:0]   S_AXI_REG_RDATA,
    output wire [2-1:0]                        S_AXI_REG_RRESP,
    output reg                                 S_AXI_REG_RVALID,
    input  wire                                S_AXI_REG_RREADY,

    // Interrupt Output Ports
    output wire                                INTR_OUT,

    // RTC and TSU Ports
    input  wire        rtc_clk,
    output wire [31:0] rtc_time_ptp_ns,
    output wire [47:0] rtc_time_ptp_sec,
    output wire        rtc_time_one_pps,

    input  wire        rx_gmii_clk,
    input  wire        rx_gmii_ctrl,
    input  wire [ 7:0] rx_gmii_data,
    input  wire        rx_giga_mode,
    input  wire        tx_gmii_clk,
    input  wire        tx_gmii_ctrl,
    input  wire [ 7:0] tx_gmii_data,
    input  wire        tx_giga_mode
  );

  wire        up_wr;
  wire        up_rd;
  wire [ 7:0] up_addr;
  wire [31:0] up_data_wr;
  wire [31:0] up_data_rd;

  //////////////////////////////////////////////////////////////////////////////
  // AXI interface
  //
  // TODO: to support interleaved write address channel and write data channel,
  //       with FIFO for each channel.
  // TODO: to support write data byte select
  // TODO: to support write response channel holding
  // TODO: to support read response channel holding
  //////////////////////////////////////////////////////////////////////////////
  assign S_AXI_REG_AWREADY = 1'b1;
  assign S_AXI_REG_WREADY  = 1'b1;
  assign S_AXI_REG_BRESP   = 2'b00;
  always @(negedge S_AXI_REG_ARESETN or posedge S_AXI_REG_ACLK) begin
    if (!S_AXI_REG_ARESETN) S_AXI_REG_BVALID <= 1'b0;
    else                    S_AXI_REG_BVALID <= S_AXI_REG_WVALID;
  end
  assign S_AXI_REG_ARREADY = 1'b1;
  assign S_AXI_REG_RDATA   = up_data_rd;
  assign S_AXI_REG_RRESP   = 2'b00;
  always @(negedge S_AXI_REG_ARESETN or posedge S_AXI_REG_ACLK) begin
    if (!S_AXI_REG_ARESETN) S_AXI_REG_RVALID <= 1'b0;
    else                    S_AXI_REG_RVALID <= S_AXI_REG_ARVALID;
  end
  
  /////////////////////////////////////////////////////////////////////////////
  // Interrupt interface
  //
  // TODO: to support interrupt generation
  /////////////////////////////////////////////////////////////////////////////
  assign INTR_OUT = 1'b0;

  /////////////////////////////////////////////////////////////////////////////
  // Local Bus interface
  //
  /////////////////////////////////////////////////////////////////////////////
  assign up_wr      = S_AXI_REG_WVALID;
  assign up_rd      = S_AXI_REG_ARVALID;
  assign up_addr    = S_AXI_REG_AWVALID? S_AXI_REG_AWADDR : S_AXI_REG_ARADDR;
  assign up_data_wr = S_AXI_REG_WDATA;

ha1588 ha1588_inst (
  .rst(!S_AXI_REG_ARESETN),
  .clk(S_AXI_REG_ACLK),
  .wr_in(up_wr),
  .rd_in(up_rd),
  .addr_in(up_addr),
  .data_in(up_data_wr),
  .data_out(up_data_rd),

  .rtc_clk(rtc_clk),
  .rtc_time_ptp_ns(rtc_time_ptp_ns),
  .rtc_time_ptp_sec(rtc_time_ptp_sec),
  .rtc_time_one_pps(rtc_time_one_pps),

  .rx_gmii_clk(rx_gmii_clk),
  .rx_gmii_ctrl(rx_gmii_ctrl),
  .rx_gmii_data(rx_gmii_data),
  .rx_giga_mode(giga_mode),
  .tx_gmii_clk(tx_gmii_clk),
  .tx_gmii_ctrl(tx_gmii_ctrl),
  .tx_gmii_data(tx_gmii_data),
  .tx_giga_mode(giga_mode)
);

endmodule

