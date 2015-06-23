// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_pcs_pma_gige.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_pcs_pma_gige_phyip.v,v $
//
// $Revision: #13 $
// $Date: 2010/10/19 $
// Check in by : $Author: aishak $
// Author      : Arul Paniandi
//
// Project     : Triple Speed Ethernet
//
// Description : 
//
// Top level PCS + PMA module for Triple Speed Ethernet PCS + PMA

// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

//Legal Notice: (C)2007 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.
 
(*altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION OFF;SUPPRESS_DA_RULE_INTERNAL=\"R102,R105,D102,D101,D103\"" } *)
module altera_tse_pcs_pma_gige_phyip (
    // inputs:
    address,
    clk,
    gmii_tx_d,
    gmii_tx_en,
    gmii_tx_err,
    mii_tx_d,
    mii_tx_en,
    mii_tx_err,
    read,
    reconfig_togxb,
    ref_clk,
    reset,
    reset_rx_clk,
    reset_tx_clk,
    rxp,
    write,
    writedata,

    // outputs:
    gmii_rx_d,
    gmii_rx_dv,
    gmii_rx_err,
    hd_ena,
    led_an,
    led_char_err,
    led_col,
    led_crs,
    led_disp_err,
    led_link,
    mii_col,
    mii_crs,
    mii_rx_d,
    mii_rx_dv,
    mii_rx_err,
    readdata,
    reconfig_fromgxb,
    rx_clk,
    set_10,
    set_100,
    set_1000,
    tx_clk,
	rx_clkena,
	tx_clkena,
    txp,
    rx_recovclkout,
    waitrequest,

    // phy_mgmt_interface
    phy_mgmt_address,
    phy_mgmt_read,
    phy_mgmt_readdata,
    phy_mgmt_waitrequest,
    phy_mgmt_write,
    phy_mgmt_writedata

);


//  Parameters to configure the core for different variations
//  ---------------------------------------------------------

parameter PHY_IDENTIFIER        = 32'h 00000000; //  PHY Identifier 
parameter DEV_VERSION           = 16'h 0001 ;    //  Customer Phy's Core Version
parameter ENABLE_SGMII          = 1;             //  Enable SGMII logic for synthesis
parameter EXPORT_PWRDN          = 1'b0;          //  Option to export the Alt2gxb powerdown signal
parameter DEVICE_FAMILY         = "ARRIAGX";     //  The device family the the core is targetted for.
parameter TRANSCEIVER_OPTION    = 1'b0;          //  Option to select transceiver block for MAC PCS PMA Instantiation. 
                                                 //  Valid Values are 0 and 1:  0 - GXB (GIGE Mode) 1 - LVDS I/O.
//parameter STARTING_CHANNEL_NUMBER = 0;           //  Starting Channel Number for Reconfig block
parameter ENABLE_ALT_RECONFIG   = 0;             //  Option to expose the alt_reconfig ports
parameter SYNCHRONIZER_DEPTH 	= 3;	  	 //  Number of synchronizer

  output  [7:0] gmii_rx_d;
  output  gmii_rx_dv;
  output  gmii_rx_err;
  output  hd_ena;
  output  led_an;
  output  led_char_err;
  output  led_col;
  output  led_crs;
  output  led_disp_err;
  output  led_link;
  output  mii_col;
  output  mii_crs;
  output  [3:0] mii_rx_d;
  output  mii_rx_dv;
  output  mii_rx_err;
  output  [15:0] readdata;
  output  [91:0] reconfig_fromgxb;
  output  rx_clk;
  output  set_10;
  output  set_100;
  output  set_1000;
  output  tx_clk;
  output  rx_clkena;
  output  tx_clkena;
  output  txp;
  output  rx_recovclkout;
  output  waitrequest;
  
  input   [4:0] address;
  input   clk;
  input   [7:0] gmii_tx_d;
  input   gmii_tx_en;
  input   gmii_tx_err;
  input   [3:0] mii_tx_d;
  input   mii_tx_en;
  input   mii_tx_err;
  input   read;
  input   [139:0] reconfig_togxb;
  input   ref_clk;
  input   reset;
  input   reset_rx_clk;
  input   reset_tx_clk;
  input   rxp;
  input   write;
  input   [15:0] writedata;

  input [8:0] phy_mgmt_address;
  input phy_mgmt_read;
  output [31:0] phy_mgmt_readdata;
  output phy_mgmt_waitrequest;
  input phy_mgmt_write;
  input [31:0]phy_mgmt_writedata;

  wire    PCS_rx_reset;
  wire    PCS_tx_reset;
  wire    PCS_reset;
  wire    gige_pma_reset;
  wire    [7:0] gmii_rx_d;
  wire    gmii_rx_dv;
  wire    gmii_rx_err;
  wire    hd_ena;
  wire    led_an;
  wire    led_char_err;
  wire    led_char_err_gx;
  wire    led_col;
  wire    led_crs;
  wire    led_disp_err;
  wire    led_link;
  wire    link_status;
  wire    mii_col;
  wire    mii_crs;
  wire    [3:0] mii_rx_d;
  wire    mii_rx_dv;
  wire    mii_rx_err;
  wire    rx_pcs_clk;
  wire    tx_pcs_clk;
  wire    [7:0] pcs_rx_frame;
  wire    pcs_rx_kchar;

  wire    [15:0] readdata;
  wire    rx_char_err_gx;
  wire    rx_clk;
  wire    rx_disp_err;
  wire    [7:0] rx_frame;
  wire    rx_syncstatus;
  wire    rx_kchar;
  wire    set_10;
  wire    set_100;
  wire    set_1000;
  wire    tx_clk;
  wire    rx_clkena;
  wire    tx_clkena;
  wire    [7:0] tx_frame;
  wire    tx_kchar;
  wire    txp;
  wire    waitrequest;
  wire    sd_loopback;

  wire   rx_runlengthviolation;
  wire   rx_patterndetect;
  wire   rx_runningdisp;
  wire   rx_rmfifodatadeleted;
  wire   rx_rmfifodatainserted;
  wire   pcs_rx_rmfifodatadeleted;
  wire   pcs_rx_rmfifodatainserted;
  wire   pcs_rx_carrierdetected;
    
  wire   [91:0] reconfig_fromgxb;
  wire   reset_rx_pcs_clk_int;
  wire   reset_reset_rx_clk;
  wire   reset_reset_tx_clk;
 
altera_tse_reset_synchronizer reset_sync_2 (
        .clk(rx_clk),
        .reset_in(reset),
        .reset_out(reset_reset_rx_clk)
        );
        
altera_tse_reset_synchronizer reset_sync_3 (
        .clk(tx_clk),
        .reset_in(reset),
        .reset_out(reset_reset_tx_clk)
        ); 
		
assign PCS_rx_reset = reset_rx_clk | reset_reset_rx_clk;
assign PCS_tx_reset = reset_tx_clk | reset_reset_tx_clk;
assign PCS_reset = reset;

//  Assign the character error and link status to top level leds
//  ------------------------------------------------------------
assign led_char_err = led_char_err_gx;
assign led_link = link_status;



// Instantiation of the PCS core that connects to a PMA
// --------------------------------------------------------
  altera_tse_top_1000_base_x_strx_gx altera_tse_top_1000_base_x_strx_gx_inst
    (
        .rx_carrierdetected(pcs_rx_carrierdetected),
        .rx_rmfifodatadeleted(pcs_rx_rmfifodatadeleted),
        .rx_rmfifodatainserted(pcs_rx_rmfifodatainserted),
        .gmii_rx_d (gmii_rx_d),
        .gmii_rx_dv (gmii_rx_dv),
        .gmii_rx_err (gmii_rx_err),
        .gmii_tx_d (gmii_tx_d),
        .gmii_tx_en (gmii_tx_en),
        .gmii_tx_err (gmii_tx_err),
        .hd_ena (hd_ena),
        .led_an (led_an),
        .led_char_err (led_char_err_gx),
        .led_col (led_col),
        .led_crs (led_crs),
        .led_link (link_status),
        .mii_col (mii_col),
        .mii_crs (mii_crs),
        .mii_rx_d (mii_rx_d),
        .mii_rx_dv (mii_rx_dv),
        .mii_rx_err (mii_rx_err),
        .mii_tx_d (mii_tx_d),
        .mii_tx_en (mii_tx_en),
        .mii_tx_err (mii_tx_err),
        .powerdown (),
        .reg_addr (address),
        .reg_busy (waitrequest),
        .reg_clk (clk),
        .reg_data_in (writedata),
        .reg_data_out (readdata),
        .reg_rd (read),
        .reg_wr (write),
        .reset_reg_clk (PCS_reset),
        .reset_rx_clk (PCS_rx_reset),
        .reset_tx_clk (PCS_tx_reset),
        .rx_clk (rx_clk),
        .rx_clkout (rx_pcs_clk),
        .rx_frame (pcs_rx_frame),
        .rx_kchar (pcs_rx_kchar),
        .sd_loopback (sd_loopback),
        .set_10 (set_10),
        .set_100 (set_100),
        .set_1000 (set_1000),
        .tx_clk (tx_clk),
		.rx_clkena(rx_clkena),
	    .tx_clkena(tx_clkena),
		.ref_clk(1'b0),
        .tx_clkout (tx_pcs_clk),
        .tx_frame (tx_frame),
        .tx_kchar (tx_kchar)

    );    
    defparam
        altera_tse_top_1000_base_x_strx_gx_inst.PHY_IDENTIFIER = PHY_IDENTIFIER,
        altera_tse_top_1000_base_x_strx_gx_inst.DEV_VERSION = DEV_VERSION,
        altera_tse_top_1000_base_x_strx_gx_inst.ENABLE_SGMII = ENABLE_SGMII;


// Instantiation of the Alt2gxb block as the PMA for Stratix_II_GX and ArriaGX devices
// ----------------------------------------------------------------------------------- 

    altera_tse_reset_synchronizer ch_0_reset_sync_0 (
        .clk(rx_pcs_clk),
        //.reset_in(rx_digitalreset_sqcnr),
        .reset_in(reset),
        .reset_out(reset_rx_pcs_clk_int)
        );
        
    // Aligned Rx_sync from gxb
    // -------------------------------
    altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync
      (
        .clk(rx_pcs_clk),
        .reset(reset_rx_pcs_clk_int),
        //input (from alt2gxb)
        .alt_dataout(rx_frame),
        .alt_sync(rx_syncstatus),
        .alt_disperr(rx_disp_err),
        .alt_ctrldetect(rx_kchar),
        .alt_errdetect(rx_char_err_gx),
        .alt_rmfifodatadeleted(rx_rmfifodatadeleted),
        .alt_rmfifodatainserted(rx_rmfifodatainserted),
        .alt_runlengthviolation(rx_runlengthviolation),
        .alt_patterndetect(rx_patterndetect),
        .alt_runningdisp(rx_runningdisp),

        //output (to PCS)
        .altpcs_dataout(pcs_rx_frame),
        .altpcs_sync(link_status),
        .altpcs_disperr(led_disp_err),
        .altpcs_ctrldetect(pcs_rx_kchar),
        .altpcs_errdetect(led_char_err_gx),
        .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted),
        .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted),
        .altpcs_carrierdetect(pcs_rx_carrierdetected)

       ) ;
       defparam
           the_altera_tse_gxb_aligned_rxsync.DEVICE_FAMILY = DEVICE_FAMILY;		


// Custom PhyIP
// ------------------------------------------
altera_tse_gxb_gige_phyip_inst the_altera_tse_gxb_gige_phyip_inst(
        .phy_mgmt_clk(clk),                          //       phy_mgmt_clk.clk
        .phy_mgmt_clk_reset(reset),                  // phy_mgmt_clk_reset.reset
        .phy_mgmt_address(phy_mgmt_address),         //           phy_mgmt.address
        .phy_mgmt_read(phy_mgmt_read),               //                   .read
        .phy_mgmt_readdata(phy_mgmt_readdata),       //                   .readdata
        .phy_mgmt_waitrequest(phy_mgmt_waitrequest), //                   .waitrequest
        .phy_mgmt_write(phy_mgmt_write),             //                   .write
        .phy_mgmt_writedata(phy_mgmt_writedata),     //                   .writedata
        .tx_ready(),                                 //           tx_ready.export
        .rx_ready(),                                 //           rx_ready.export
        .pll_ref_clk(ref_clk),                       //        pll_ref_clk.clk
        .pll_locked(),                               //         pll_locked.export
        .tx_serial_data(txp),                        //     tx_serial_data.export
        .rx_serial_data(rxp),                        //     rx_serial_data.export
        .rx_runningdisp(rx_runningdisp),             //     rx_runningdisp.export
        .rx_disperr(rx_disp_err),                    //         rx_disperr.export
        .rx_errdetect(rx_char_err_gx),               //       rx_errdetect.export
        .rx_patterndetect(rx_patterndetect),         //   rx_patterndetect.export
        .rx_syncstatus(rx_syncstatus),               //      rx_syncstatus.export
        .tx_clkout(tx_pcs_clk),                      //         tx_clkout0.clk
        .rx_clkout(rx_pcs_clk),                      //         rx_clkout0.clk
        .tx_parallel_data(tx_frame),                 //  tx_parallel_data0.data
        .tx_datak(tx_kchar),                         //          tx_datak0.data
        .rx_parallel_data(rx_frame),                 //  rx_parallel_data0.data
        .rx_datak(rx_kchar),                         //          rx_datak0.data
        .rx_rlv(rx_runlengthviolation), 
        .rx_recovclkout(rx_recovclkout),
        .rx_rmfifodatadeleted(rx_rmfifodatadeleted),
        .rx_rmfifodatainserted(rx_rmfifodatainserted),
        .reconfig_togxb(reconfig_togxb),
        .reconfig_fromgxb(reconfig_fromgxb)  
	);
        defparam
        the_altera_tse_gxb_gige_phyip_inst.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_phyip_inst.DEVICE_FAMILY = DEVICE_FAMILY,
        the_altera_tse_gxb_gige_phyip_inst.ENABLE_SGMII = ENABLE_SGMII;

endmodule

