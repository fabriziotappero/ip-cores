// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_pcs.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_pcs.v,v $
//
// $Revision: #1 $
// $Date: 2012/06/21 $
// Check in by : $Author: swbranch $
// Author      : Arul Paniandi
//
// Project     : Triple Speed Ethernet
//
// Description : 
//
// Top level module for Triple Speed Ethernet PCS

// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

(*altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION OFF" } *)
module altera_tse_pcs /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"R102,R105,D102,D101,D103\"" */(

    reg_clk,                     // Avalon slave - clock
    reg_rd,                      // Avalon slave - read
    reg_wr,                      // Avalon slave - write
    reg_addr,                    // Avalon slave - address
    reg_data_in,                 // Avalon slave - writedata
    reg_data_out,                // Avalon slave - readdata
    reg_busy,                    // Avalon slave - waitrequest
    reset_reg_clk,               // Avalon slave - reset  
    reset_rx_clk,
    reset_tx_clk,
    rx_clk,
    tx_clk,
	rx_clkena,
	tx_clkena,
    gmii_rx_dv,
    gmii_rx_d,
    gmii_rx_err,
    gmii_tx_en,
    gmii_tx_d,
    gmii_tx_err,
    mii_rx_dv,
    mii_rx_d,
    mii_rx_err,
    mii_tx_en,
    mii_tx_d,
    mii_tx_err,
    mii_col,
    mii_crs,
    tbi_rx_clk,
    tbi_tx_clk,
    tbi_rx_d,
    tbi_tx_d,
    sd_loopback,
    powerdown,
    set_10,
    set_100,
    set_1000,
    hd_ena,
    led_col,
    led_an,
    led_char_err,
    led_disp_err,
    led_crs,
    led_link);


parameter PHY_IDENTIFIER     = 32'h 00000000 ; 
parameter DEV_VERSION        = 16'h 0001 ; 
parameter ENABLE_SGMII       = 1;                 //  Enable SGMII logic for synthesis
parameter SYNCHRONIZER_DEPTH = 3;	  	  //  Number of synchronizer   

input   reset_rx_clk;           //  Asynchronous Reset - rx_clk Domain
input   reset_tx_clk;           //  Asynchronous Reset - tx_clk Domain
input   reset_reg_clk;          //  Asynchronous Reset - clk Domain
output  rx_clk;                 //  MAC Receive clock
output  tx_clk;                 //  MAC Transmit clock
output  rx_clkena;              //  MAC Receive Clock Enable
output  tx_clkena;              //  MAC Transmit Clock Enable
output  gmii_rx_dv;             //  GMII Receive Enable
output  [7:0] gmii_rx_d;        //  GMII Receive Data
output  gmii_rx_err;            //  GMII Receive Error
input   gmii_tx_en;             //  GMII Transmit Enable
input   [7:0] gmii_tx_d;        //  GMII Transmit Data
input   gmii_tx_err;            //  GMII Transmit Error
output  mii_rx_dv;              //  MII Receive Enable
output  [3:0] mii_rx_d;         //  MII Receive Data
output  mii_rx_err;             //  MII Receive Error
input   mii_tx_en;              //  MII Transmit Enable
input   [3:0] mii_tx_d;         //  MII Transmit Data
input   mii_tx_err;             //  MII Transmit Error
output  mii_col;                //  MII Collision
output  mii_crs;                //  MII Carrier Sense
input   tbi_rx_clk;             //  125MHz Recoved Clock
input   tbi_tx_clk;             //  125MHz Transmit Clock
input   [9:0] tbi_rx_d;         //  Non Aligned 10-Bit Characters
output  [9:0] tbi_tx_d;         //  Transmit TBI Interface
output  sd_loopback;            //  SERDES Loopback Enable
output  powerdown;              //  Powerdown Enable
input   reg_clk;                //  Register Interface Clock
input   reg_rd;                 //  Register Read Enable
input   reg_wr;                 //  Register Write Enable
input   [4:0] reg_addr;         //  Register Address
input   [15:0] reg_data_in;     //  Register Input Data 
output  [15:0] reg_data_out;    //  Register Output Data
output  reg_busy;               //  Access Busy 
output  led_crs;                //  Carrier Sense
output  led_link;               //  Valid Link 
output  hd_ena;                 //  Half-Duplex Enable
output  led_col;                //  Collision Indication
output  led_an;                 //  Auto-Negotiation Status
output  led_char_err;           //  Character Error
output  led_disp_err;           //  Disparity Error
output  set_10;                 //  10Mbps Link Indication
output  set_100;                //  100Mbps Link Indication
output  set_1000;               //  Gigabit Link Indication

wire    rx_clk;
wire    tx_clk;
wire    rx_clkena;
wire    tx_clkena;
wire    gmii_rx_dv;
wire    [7:0] gmii_rx_d;
wire    gmii_rx_err;
wire    mii_rx_dv;
wire    [3:0] mii_rx_d;
wire    mii_rx_err;
wire    mii_col;
wire    mii_crs;
wire    [9:0] tbi_tx_d;
wire    sd_loopback;
wire    powerdown;
wire    [15:0] reg_data_out;
wire    reg_busy;
wire    led_crs;
wire    led_link;
wire    hd_ena;
wire    led_col;
wire    led_an;
wire    led_char_err;
wire    led_disp_err;
wire    set_10;
wire    set_100;
wire    set_1000;



    altera_tse_top_1000_base_x    top_1000_base_x_inst(
        .reset_rx_clk(reset_rx_clk),
        .reset_tx_clk(reset_tx_clk),
        .reset_reg_clk(reset_reg_clk),
        .rx_clk(rx_clk),
        .tx_clk(tx_clk),
		.rx_clkena(rx_clkena),
		.tx_clkena(tx_clkena),
		.ref_clk(1'b0),
        .gmii_rx_dv(gmii_rx_dv),
        .gmii_rx_d(gmii_rx_d),
        .gmii_rx_err(gmii_rx_err),
        .gmii_tx_en(gmii_tx_en),
        .gmii_tx_d(gmii_tx_d),
        .gmii_tx_err(gmii_tx_err),
        .mii_rx_dv(mii_rx_dv),
        .mii_rx_d(mii_rx_d),
        .mii_rx_err(mii_rx_err),
        .mii_tx_en(mii_tx_en),
        .mii_tx_d(mii_tx_d),
        .mii_tx_err(mii_tx_err),
        .mii_col(mii_col),
        .mii_crs(mii_crs),
        .tbi_rx_clk(tbi_rx_clk),
        .tbi_tx_clk(tbi_tx_clk),
        .tbi_rx_d(tbi_rx_d),
        .tbi_tx_d(tbi_tx_d),
        .sd_loopback(sd_loopback),
        .reg_clk(reg_clk),
        .reg_rd(reg_rd),
        .reg_wr(reg_wr),
        .reg_addr(reg_addr),
        .reg_data_in(reg_data_in),
        .reg_data_out(reg_data_out),
        .reg_busy(reg_busy),
        .powerdown(powerdown),
        .set_10(set_10),
        .set_100(set_100),
        .set_1000(set_1000),
        .hd_ena(hd_ena),
        .led_col(led_col),
        .led_an(led_an),
        .led_char_err(led_char_err),
        .led_disp_err(led_disp_err),
        .led_crs(led_crs),
        .led_link(led_link));

defparam
    top_1000_base_x_inst.PHY_IDENTIFIER = PHY_IDENTIFIER,
    top_1000_base_x_inst.DEV_VERSION = DEV_VERSION,
    top_1000_base_x_inst.ENABLE_SGMII = ENABLE_SGMII;



endmodule
