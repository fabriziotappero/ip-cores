////////////////////////////////////////////////////////////
//
// This confidential and proprietary software may be used
// only as authorized by a licensing agreement from
// Bean Digital Ltd
// In the event of publication, the following notice is
// applicable:
//
// (C)COPYRIGHT 2012 BEAN DIGITAL LTD.
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all
// authorized copies.
//
// File        : sata_phy_top_x6series_tb.v
// Author      : J.Bean
// Date        : Mar 2012
// Description : SATA PHY Layer Top Xilinx 6 Series TB
////////////////////////////////////////////////////////////

`resetall
`timescale 1ns/10ps

`include "sata_constants.v" 

module sata_phy_top_x6series_tb;

reg         gt_clk;
wire        clk_ref;
wire        clk_sata;
wire        clk_phy;
wire        clk_gt;
wire        rst_n;
reg  [5:0]  rst_cnt;

wire [1:0]  host_gt_clk_ref;       
wire        host_gt_plllkdet;
wire        host_gt_rst_done;
wire [15:0] host_gt_rx_data;
wire [1:0]  host_gt_rx_charisk;
wire [1:0]  host_gt_rx_disp_err;
wire [1:0]  host_gt_rx_8b10b_err;
wire        host_gt_rx_elec_idle;
wire [2:0]  host_gt_rx_status;
wire [15:0] host_gt_tx_data;
wire [1:0]  host_gt_tx_charisk;
wire        host_gt_tx_elec_idle;
wire        host_gt_tx_com_strt;
wire        host_gt_tx_com_type;
wire        host_gt_rx_p;
wire        host_gt_rx_n;
wire        host_gt_tx_p;
wire        host_gt_tx_n;

wire [1:0]  dev_gt_clk_ref;       
wire        dev_gt_plllkdet;
wire        dev_gt_rst_done;
wire [15:0] dev_gt_rx_data;
wire [1:0]  dev_gt_rx_charisk;
wire [1:0]  dev_gt_rx_disp_err;
wire [1:0]  dev_gt_rx_8b10b_err;
wire        dev_gt_rx_elec_idle;
wire [2:0]  dev_gt_rx_status;
wire [15:0] dev_gt_tx_data;
wire [1:0]  dev_gt_tx_charisk;
wire        dev_gt_tx_elec_idle;
wire        dev_gt_tx_com_strt;
wire        dev_gt_tx_com_type;
wire        dev_gt_rx_p;
wire        dev_gt_rx_n;
wire        dev_gt_tx_p;
wire        dev_gt_tx_n;

assign host_gt_rx_p = dev_gt_tx_p;
assign host_gt_rx_n = dev_gt_tx_n;
assign dev_gt_rx_p  = host_gt_tx_p;
assign dev_gt_rx_n  = host_gt_tx_n;

initial
begin
  gt_clk = 0;
  
  forever begin
    #(6.66/2.0) gt_clk = ~gt_clk; // 150 MHz
  end
end

////////////////////////////////////////////////////////////
// Instance    : 
// Description : 
////////////////////////////////////////////////////////////

PLL_BASE #(
  .BANDWIDTH             ("OPTIMIZED"),
  .CLKFBOUT_MULT         (5),     
  .CLKFBOUT_PHASE        (0.0),
  .CLKIN_PERIOD          (6.66),
  .CLKOUT0_DIVIDE        (20),       
  .CLKOUT1_DIVIDE        (10),      
  .CLKOUT2_DIVIDE        (5),      
  .CLKOUT3_DIVIDE        (1),  
  .CLKOUT4_DIVIDE        (1),  
  .CLKOUT5_DIVIDE        (1),    
  .CLKOUT0_PHASE         (0.0),
  .CLKOUT1_PHASE         (0.0),
  .CLKOUT2_PHASE         (0.0),  
  .CLKOUT3_PHASE         (0.0),
  .CLKOUT4_PHASE         (0.0),
  .CLKOUT5_PHASE         (0.0),
  .CLKOUT0_DUTY_CYCLE    (0.500),
  .CLKOUT1_DUTY_CYCLE    (0.500),
  .CLKOUT2_DUTY_CYCLE    (0.500),
  .CLKOUT3_DUTY_CYCLE    (0.500),
  .CLKOUT4_DUTY_CYCLE    (0.500),
  .CLKOUT5_DUTY_CYCLE    (0.500),
  .CLK_FEEDBACK          ("CLKFBOUT"),
  .COMPENSATION          ("SYSTEM_SYNCHRONOUS"),
  .DIVCLK_DIVIDE         (1),
  .REF_JITTER            (0.000200),
  .RESET_ON_LOSS_OF_LOCK ("FALSE"))
  U_pll (
  .CLKFBOUT              (pll_clkfb),   
  .CLKOUT0               (pll_clk0),   
  .CLKOUT1               (pll_clk1),   
  .CLKOUT2               (pll_clk2),   
  .CLKOUT3               (pll_clk3), 
  .CLKOUT4               (pll_clk4),  
  .CLKOUT5               (pll_clk5),  
  .LOCKED                (pll_locked),   
  .CLKFBIN               (pll_clkfb), 
  .CLKIN                 (clkin), 
  .RST                   (~host_gt_plllkdet)); 

BUFG U_pll_clk0_bufg(
  .O (clk_sata),
  .I (pll_clk0));

BUFG U_pll_clk1_bufg(
  .O (clk_phy),
  .I (pll_clk1));
  
BUFG U_pll_clk2_bufg(
  .O (clk_gt),
  .I (pll_clk2));  
  
assign pll_locked_n = ~pll_locked;

assign rst_n = (rst_cnt == 16);

always @(posedge clk_sata or posedge pll_locked_n)
begin
  if (pll_locked_n == 1) begin
    rst_cnt <= 0;
  end else begin
    if (rst_cnt != 16) begin
      rst_cnt <= rst_cnt + 1;
    end
  end
end

////////////////////////////////////////////////////////////
// Instance    : 
// Description : 
////////////////////////////////////////////////////////////

BUFIO2 #(
  .DIVIDE        (1),
  .DIVIDE_BYPASS ("TRUE"))
  U_refclk_bufg(
  .I             (host_gt_clk_ref[0]),
  .DIVCLK        (clkin),
  .IOCLK         (),
  .SERDESSTROBE  ());
  
////////////////////////////////////////////////////////////
// Instance    : SATA Host PHY
// Description : 
////////////////////////////////////////////////////////////

sata_phy_top_x6series #(
  .IS_HOST           (1),
  .SATA_REV          (1)) 
  U_sata_host(
  .clk               (clk_sata),
  .clk_phy           (clk_phy),
  .rst_n             (rst_n),
  .lnk_tx_tdata_i    (`SYNC_VAL),
  .lnk_tx_tvalid_i   (1'b1),
  .lnk_tx_tready_o   (),
  .lnk_tx_tuser_i    (4'b0001),
  .lnk_rx_tdata_o    (),
  .lnk_rx_tvalid_o   (),
  .lnk_rx_tready_i   (1'b1),
  .lnk_rx_tuser_o    (),
  .phy_status_o      (),
  .gt_rst_done_i     (host_gt_rst_done),
  .gt_rx_data_i      (host_gt_rx_data),
  .gt_rx_charisk_i   (host_gt_rx_charisk),
  .gt_rx_disp_err_i  (host_gt_rx_disp_err),
  .gt_rx_8b10b_err_i (host_gt_rx_8b10b_err),
  .gt_rx_elec_idle_i (host_gt_rx_elec_idle),
  .gt_rx_status_i    (host_gt_rx_status),
  .gt_tx_data_o      (host_gt_tx_data),
  .gt_tx_charisk_o   (host_gt_tx_charisk),
  .gt_tx_elec_idle_o (host_gt_tx_elec_idle),
  .gt_tx_com_strt_o  (host_gt_tx_com_strt),
  .gt_tx_com_type_o  (host_gt_tx_com_type));

////////////////////////////////////////////////////////////
// Instance    : SATA 1 Host GTP
// Description : 
////////////////////////////////////////////////////////////

sata_s6_sata1_gtp #(
  .WRAPPER_SIM_GTPRESET_SPEEDUP   (0),      // Set this to 1 for simulation
  .WRAPPER_SIMULATION             (0))      // Set this to 1 for simulation
  U_sata_host_gtp(
  //_____________________________________________________________________
  //_____________________________________________________________________
  //TILE0  (X1_Y0)

  //---------------------- Loopback and Powerdown Ports ----------------------
  .TILE0_LOOPBACK0_IN             (3'd0),
  .TILE0_LOOPBACK1_IN             (3'd0), 
  //------------------------------- PLL Ports --------------------------------
  .TILE0_CLK00_IN                 (gt_clk),
  .TILE0_CLK01_IN                 (1'b0),
  .TILE0_GTPRESET0_IN             (1'b0),
  .TILE0_GTPRESET1_IN             (1'b0),
  .TILE0_PLLLKDET0_OUT            (host_gt_plllkdet),
  .TILE0_RESETDONE0_OUT           (host_gt_rst_done),
  .TILE0_RESETDONE1_OUT           (),
  //--------------------- Receive Ports - 8b10b Decoder ----------------------
  .TILE0_RXCHARISCOMMA0_OUT       (),
  .TILE0_RXCHARISCOMMA1_OUT       (),
  .TILE0_RXCHARISK0_OUT           (host_gt_rx_charisk),
  .TILE0_RXCHARISK1_OUT           (),
  .TILE0_RXDISPERR0_OUT           (host_gt_rx_disp_err),
  .TILE0_RXDISPERR1_OUT           (),
  .TILE0_RXNOTINTABLE0_OUT        (host_gt_rx_8b10b_err),
  .TILE0_RXNOTINTABLE1_OUT        (),
  //-------------------- Receive Ports - Clock Correction --------------------
  .TILE0_RXCLKCORCNT0_OUT         (),
  .TILE0_RXCLKCORCNT1_OUT         (),
  //------------- Receive Ports - Comma Detection and Alignment --------------
  .TILE0_RXBYTEISALIGNED0_OUT     (),
  .TILE0_RXBYTEISALIGNED1_OUT     (),  
  .TILE0_RXENMCOMMAALIGN0_IN      (1'b1),
  .TILE0_RXENMCOMMAALIGN1_IN      (1'b1),
  .TILE0_RXENPCOMMAALIGN0_IN      (1'b1),
  .TILE0_RXENPCOMMAALIGN1_IN      (1'b1),
  //----------------- Receive Ports - RX Data Path interface -----------------
  .TILE0_RXDATA0_OUT              (host_gt_rx_data),
  .TILE0_RXDATA1_OUT              (),
  .TILE0_RXRECCLK0_OUT            (),
  .TILE0_RXRECCLK1_OUT            (),
  .TILE0_RXRESET0_IN              (1'b0),
  .TILE0_RXRESET1_IN              (1'b0),  
  .TILE0_RXUSRCLK0_IN             (clk_gt),
  .TILE0_RXUSRCLK1_IN             (clk_gt),
  .TILE0_RXUSRCLK20_IN            (clk_phy),
  .TILE0_RXUSRCLK21_IN            (clk_phy),
  //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
  .TILE0_GATERXELECIDLE0_IN       (1'b0),
  .TILE0_GATERXELECIDLE1_IN       (1'b0),
  .TILE0_IGNORESIGDET0_IN         (1'b0),
  .TILE0_IGNORESIGDET1_IN         (1'b0),
  .TILE0_RXELECIDLE0_OUT          (host_gt_rx_elec_idle),
  .TILE0_RXELECIDLE1_OUT          (),
  .TILE0_RXEQMIX0_IN              (2'd0),
  .TILE0_RXEQMIX1_IN              (2'd0),
  .TILE0_RXN0_IN                  (host_gt_rx_n),
  .TILE0_RXN1_IN                  (1'b0),
  .TILE0_RXP0_IN                  (host_gt_rx_p),
  .TILE0_RXP1_IN                  (1'b0),
  //--------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
  .TILE0_RXSTATUS0_OUT            (host_gt_rx_status),
  .TILE0_RXSTATUS1_OUT            (),
  //-------------------------- TX/RX Datapath Ports --------------------------
  .TILE0_GTPCLKOUT0_OUT           (host_gt_clk_ref),
  .TILE0_GTPCLKOUT1_OUT           (),
  //----------------- Transmit Ports - 8b10b Encoder Control -----------------
  .TILE0_TXCHARISK0_IN            (host_gt_tx_charisk),
  .TILE0_TXCHARISK1_IN            (2'd0),
  //---------------- Transmit Ports - TX Data Path interface -----------------
  .TILE0_TXDATA0_IN               (host_gt_tx_data),
  .TILE0_TXDATA1_IN               (16'd0),
  .TILE0_TXOUTCLK0_OUT            (),
  .TILE0_TXOUTCLK1_OUT            (),
  .TILE0_TXRESET0_IN              (1'b0),
  .TILE0_TXRESET1_IN              (1'b0),  
  .TILE0_TXUSRCLK0_IN             (clk_gt),
  .TILE0_TXUSRCLK1_IN             (clk_gt),
  .TILE0_TXUSRCLK20_IN            (clk_phy),
  .TILE0_TXUSRCLK21_IN            (clk_phy),
  //------------- Transmit Ports - TX Driver and OOB signalling --------------
  .TILE0_TXDIFFCTRL0_IN           (4'b0111),
  .TILE0_TXDIFFCTRL1_IN           (4'b0111),
  .TILE0_TXN0_OUT                 (host_gt_tx_n),
  .TILE0_TXN1_OUT                 (),
  .TILE0_TXP0_OUT                 (host_gt_tx_p),
  .TILE0_TXP1_OUT                 (),
  .TILE0_TXPREEMPHASIS0_IN        (3'd0),
  .TILE0_TXPREEMPHASIS1_IN        (3'd0),  
  //--------------- Transmit Ports - TX Ports for PCI Express ----------------
  .TILE0_TXELECIDLE0_IN           (host_gt_tx_elec_idle),
  .TILE0_TXELECIDLE1_IN           (1'b0),
  //------------------- Transmit Ports - TX Ports for SATA -------------------
  .TILE0_TXCOMSTART0_IN           (host_gt_tx_com_strt),
  .TILE0_TXCOMSTART1_IN           (1'b0),
  .TILE0_TXCOMTYPE0_IN            (host_gt_tx_com_type),
  .TILE0_TXCOMTYPE1_IN            (1'b0));
  
////////////////////////////////////////////////////////////
// Instance    : SATA Device PHY
// Description : 
////////////////////////////////////////////////////////////

sata_phy_top_x6series #(
  .IS_HOST           (0),
  .SATA_REV          (1)) 
  U_sata_dev(
  .clk               (clk_sata),
  .clk_phy           (clk_phy),
  .rst_n             (rst_n),
  .lnk_tx_tdata_i    (`SYNC_VAL),
  .lnk_tx_tvalid_i   (1'b1),
  .lnk_tx_tready_o   (),
  .lnk_tx_tuser_i    (4'b0001),
  .lnk_rx_tdata_o    (),
  .lnk_rx_tvalid_o   (),
  .lnk_rx_tready_i   (1'b1),
  .lnk_rx_tuser_o    (),
  .phy_status_o      (),
  .gt_rst_done_i     (dev_gt_rst_done),
  .gt_rx_data_i      (dev_gt_rx_data),
  .gt_rx_charisk_i   (dev_gt_rx_charisk),
  .gt_rx_disp_err_i  (dev_gt_rx_disp_err),
  .gt_rx_8b10b_err_i (dev_gt_rx_8b10b_err),
  .gt_rx_elec_idle_i (dev_gt_rx_elec_idle),
  .gt_rx_status_i    (dev_gt_rx_status),
  .gt_tx_data_o      (dev_gt_tx_data),
  .gt_tx_charisk_o   (dev_gt_tx_charisk),
  .gt_tx_elec_idle_o (dev_gt_tx_elec_idle),
  .gt_tx_com_strt_o  (dev_gt_tx_com_strt),
  .gt_tx_com_type_o  (dev_gt_tx_com_type));

////////////////////////////////////////////////////////////
// Instance    : SATA 1 Device GTP
// Description : 
////////////////////////////////////////////////////////////

sata_s6_sata1_gtp #(
  .WRAPPER_SIM_GTPRESET_SPEEDUP   (0),      // Set this to 1 for simulation
  .WRAPPER_SIMULATION             (0))      // Set this to 1 for simulation
  U_sata_dev_gtp(
  //_____________________________________________________________________
  //_____________________________________________________________________
  //TILE0  (X1_Y0)

  //---------------------- Loopback and Powerdown Ports ----------------------
  .TILE0_LOOPBACK0_IN             (3'd0),
  .TILE0_LOOPBACK1_IN             (3'd0), 
  //------------------------------- PLL Ports --------------------------------
  .TILE0_CLK00_IN                 (gt_clk),
  .TILE0_CLK01_IN                 (1'b0),
  .TILE0_GTPRESET0_IN             (1'b0),
  .TILE0_GTPRESET1_IN             (1'b0),
  .TILE0_PLLLKDET0_OUT            (dev_gt_plllkdet),
  .TILE0_RESETDONE0_OUT           (dev_gt_rst_done),
  .TILE0_RESETDONE1_OUT           (),
  //--------------------- Receive Ports - 8b10b Decoder ----------------------
  .TILE0_RXCHARISCOMMA0_OUT       (),
  .TILE0_RXCHARISCOMMA1_OUT       (),
  .TILE0_RXCHARISK0_OUT           (dev_gt_rx_charisk),
  .TILE0_RXCHARISK1_OUT           (),
  .TILE0_RXDISPERR0_OUT           (dev_gt_rx_disp_err),
  .TILE0_RXDISPERR1_OUT           (),
  .TILE0_RXNOTINTABLE0_OUT        (dev_gt_rx_8b10b_err),
  .TILE0_RXNOTINTABLE1_OUT        (),
  //-------------------- Receive Ports - Clock Correction --------------------
  .TILE0_RXCLKCORCNT0_OUT         (),
  .TILE0_RXCLKCORCNT1_OUT         (),
  //------------- Receive Ports - Comma Detection and Alignment --------------
  .TILE0_RXBYTEISALIGNED0_OUT     (),
  .TILE0_RXBYTEISALIGNED1_OUT     (),  
  .TILE0_RXENMCOMMAALIGN0_IN      (1'b1),
  .TILE0_RXENMCOMMAALIGN1_IN      (1'b1),
  .TILE0_RXENPCOMMAALIGN0_IN      (1'b1),
  .TILE0_RXENPCOMMAALIGN1_IN      (1'b1),
  //----------------- Receive Ports - RX Data Path interface -----------------
  .TILE0_RXDATA0_OUT              (dev_gt_rx_data),
  .TILE0_RXDATA1_OUT              (),
  .TILE0_RXRECCLK0_OUT            (),
  .TILE0_RXRECCLK1_OUT            (),
  .TILE0_RXRESET0_IN              (1'b0),
  .TILE0_RXRESET1_IN              (1'b0),  
  .TILE0_RXUSRCLK0_IN             (clk_gt),
  .TILE0_RXUSRCLK1_IN             (clk_gt),
  .TILE0_RXUSRCLK20_IN            (clk_phy),
  .TILE0_RXUSRCLK21_IN            (clk_phy),
  //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
  .TILE0_GATERXELECIDLE0_IN       (1'b0),
  .TILE0_GATERXELECIDLE1_IN       (1'b0),
  .TILE0_IGNORESIGDET0_IN         (1'b0),
  .TILE0_IGNORESIGDET1_IN         (1'b0),
  .TILE0_RXELECIDLE0_OUT          (dev_gt_rx_elec_idle),
  .TILE0_RXELECIDLE1_OUT          (),
  .TILE0_RXEQMIX0_IN              (2'd0),
  .TILE0_RXEQMIX1_IN              (2'd0),
  .TILE0_RXN0_IN                  (dev_gt_rx_n),
  .TILE0_RXN1_IN                  (1'b0),
  .TILE0_RXP0_IN                  (dev_gt_rx_p),
  .TILE0_RXP1_IN                  (1'b0),
  //--------- Receive Ports - RX Elastic Buffer and Phase Alignment ----------
  .TILE0_RXSTATUS0_OUT            (dev_gt_rx_status),
  .TILE0_RXSTATUS1_OUT            (),
  //-------------------------- TX/RX Datapath Ports --------------------------
  .TILE0_GTPCLKOUT0_OUT           (dev_gt_clk_ref),
  .TILE0_GTPCLKOUT1_OUT           (),
  //----------------- Transmit Ports - 8b10b Encoder Control -----------------
  .TILE0_TXCHARISK0_IN            (dev_gt_tx_charisk),
  .TILE0_TXCHARISK1_IN            (2'd0),
  //---------------- Transmit Ports - TX Data Path interface -----------------
  .TILE0_TXDATA0_IN               (dev_gt_tx_data),
  .TILE0_TXDATA1_IN               (16'd0),
  .TILE0_TXOUTCLK0_OUT            (),
  .TILE0_TXOUTCLK1_OUT            (),
  .TILE0_TXRESET0_IN              (1'b0),
  .TILE0_TXRESET1_IN              (1'b0),  
  .TILE0_TXUSRCLK0_IN             (clk_gt),
  .TILE0_TXUSRCLK1_IN             (clk_gt),
  .TILE0_TXUSRCLK20_IN            (clk_phy),
  .TILE0_TXUSRCLK21_IN            (clk_phy),
  //------------- Transmit Ports - TX Driver and OOB signalling --------------
  .TILE0_TXDIFFCTRL0_IN           (4'b0111),
  .TILE0_TXDIFFCTRL1_IN           (4'b0111),
  .TILE0_TXN0_OUT                 (dev_gt_tx_n),
  .TILE0_TXN1_OUT                 (),
  .TILE0_TXP0_OUT                 (dev_gt_tx_p),
  .TILE0_TXP1_OUT                 (),
  .TILE0_TXPREEMPHASIS0_IN        (3'd0),
  .TILE0_TXPREEMPHASIS1_IN        (3'd0),  
  //--------------- Transmit Ports - TX Ports for PCI Express ----------------
  .TILE0_TXELECIDLE0_IN           (dev_gt_tx_elec_idle),
  .TILE0_TXELECIDLE1_IN           (1'b0),
  //------------------- Transmit Ports - TX Ports for SATA -------------------
  .TILE0_TXCOMSTART0_IN           (dev_gt_tx_com_strt),
  .TILE0_TXCOMSTART1_IN           (1'b0),
  .TILE0_TXCOMTYPE0_IN            (dev_gt_tx_com_type),
  .TILE0_TXCOMTYPE1_IN            (1'b0));
    
endmodule 


