// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_pcs_pma.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_pcs_pma.v,v $
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
 
(*altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION OFF" } *)
module altera_tse_pcs_pma /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"R102,R105,D102,D101,D103\"" */(
    // inputs:
    address,
    clk,
    gmii_tx_d,
    gmii_tx_en,
    gmii_tx_err,
    gxb_cal_blk_clk,
    gxb_pwrdn_in,
    mii_tx_d,
    mii_tx_en,
    mii_tx_err,
    read,
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
    pcs_pwrdn_out,
    readdata,
    rx_clk,
	rx_clkena,
	tx_clkena,
    set_10,
    set_100,
    set_1000,
    tx_clk,
    txp,
    rx_recovclkout,
    waitrequest
);


//  Parameters to configure the core for different variations
//  ---------------------------------------------------------

parameter PHY_IDENTIFIER        = 32'h 00000000; //  PHY Identifier 
parameter DEV_VERSION           = 16'h 0001 ;    //  Customer Phy's Core Version
parameter ENABLE_SGMII          = 1;             //  Enable SGMII logic for synthesis
parameter EXPORT_PWRDN          = 1'b0;          //  Option to export the Alt2gxb powerdown signal
parameter DEVICE_FAMILY         = "ARRIAGX";     //  The device family the the core is targetted for.
parameter TRANSCEIVER_OPTION    = 1'b1;          //  Option to select transceiver block for MAC PCS PMA Instantiation. Valid Values are 0 and 1:  0 - GXB (GIGE Mode) 1 - LVDS I/O
parameter ENABLE_ALT_RECONFIG   = 0;             //  Option to have the Alt_Reconfig ports exposed
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
  output  pcs_pwrdn_out;
  output  [15:0] readdata;
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
  input   gxb_pwrdn_in;
  input   gxb_cal_blk_clk;
  input   [3:0] mii_tx_d;
  input   mii_tx_en;
  input   mii_tx_err;
  input   read;
  input   ref_clk;
  input   reset;
  input   reset_rx_clk;
  input   reset_tx_clk;
  input   rxp;
  input   write;
  input   [15:0] writedata;


  wire    PCS_rx_reset;
  wire    PCS_tx_reset;
  wire    PCS_reset;
  wire    [7:0] gmii_rx_d;
  wire    gmii_rx_dv;
  wire    gmii_rx_err;
  wire    hd_ena;
  wire    led_an;
  wire    led_char_err;
  wire    led_col;
  wire    led_crs;
  wire    led_disp_err;
  wire    led_link;
  wire    mii_col;
  wire    mii_crs;
  wire    [3:0] mii_rx_d;
  wire    mii_rx_dv;
  wire    mii_rx_err;
  
  wire    [15:0] readdata;
  wire    rx_clk;
  wire    set_10;
  wire    set_100;
  wire    set_1000;
  wire    tbi_rx_clk;
  wire    [9:0] tbi_rx_d;
  wire    [9:0] tbi_tx_d;
  wire    tx_clk;
  wire    rx_clkena;
  wire    tx_clkena;
  wire    txp;
  wire    waitrequest;
  wire    sd_loopback;
  wire    pcs_pwrdn_out_sig;
  wire    gxb_pwrdn_in_sig;
  wire    [9:0] tbi_rx_d_lvds;

  reg     [9:0] tbi_rx_d_flip;
  reg     [9:0] tbi_tx_d_flip;
  
  wire    pll_areset,rx_cda_reset,rx_channel_data_align,rx_locked;
  wire 	  reset_pma_tx_clk,reset_pma_rx_clk,rx_reset;
// Export receive recovered clock
assign rx_recovclkout = tbi_rx_clk;
  
// Reset logic used to reset the PMA blocks
// ----------------------------------------


//  Assign the digital reset of the PMA to the PCS logic
//  --------------------------------------------------------

altera_tse_reset_synchronizer reset_sync_tx (
        .clk(tx_clk),
        .reset_in(rx_reset),
        .reset_out(reset_pma_tx_clk)
        ); 		
        
altera_tse_reset_synchronizer reset_sync_rx (
        .clk(rx_clk),
        .reset_in(rx_reset),
        .reset_out(reset_pma_rx_clk)
        ); 	        
		
assign PCS_rx_reset = reset_rx_clk | reset_pma_rx_clk;
assign PCS_tx_reset = reset_tx_clk | reset_pma_tx_clk;
assign PCS_reset = reset | rx_reset;

		


// Instantiation of the PCS core that connects to a PMA
// --------------------------------------------------------
  altera_tse_top_1000_base_x altera_tse_top_1000_base_x_inst
    (
        .gmii_rx_d (gmii_rx_d),
        .gmii_rx_dv (gmii_rx_dv),
        .gmii_rx_err (gmii_rx_err),
        .gmii_tx_d (gmii_tx_d),
        .gmii_tx_en (gmii_tx_en),
        .gmii_tx_err (gmii_tx_err),
        .hd_ena (hd_ena),
        .led_an (led_an),
        .led_char_err (led_char_err),
        .led_col (led_col),
        .led_crs (led_crs),
        .led_disp_err (led_disp_err),
        .led_link (led_link),
        .mii_col (mii_col),
        .mii_crs (mii_crs),
        .mii_rx_d (mii_rx_d),
        .mii_rx_dv (mii_rx_dv),
        .mii_rx_err (mii_rx_err),
        .mii_tx_d (mii_tx_d),
        .mii_tx_en (mii_tx_en),
        .mii_tx_err (mii_tx_err),
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
		.rx_clkena(rx_clkena),
		.tx_clkena(tx_clkena),
		.ref_clk(1'b0),
        .set_10 (set_10),
        .set_100 (set_100),
        .set_1000 (set_1000),
        .sd_loopback(sd_loopback),
        .powerdown(pcs_pwrdn_out_sig),
        .tbi_rx_clk (tbi_rx_clk),
        .tbi_rx_d (tbi_rx_d),
        .tbi_tx_clk (tbi_tx_clk),
        .tbi_tx_d (tbi_tx_d),
        .tx_clk (tx_clk)
    );
    
    defparam
        altera_tse_top_1000_base_x_inst.PHY_IDENTIFIER = PHY_IDENTIFIER,
        altera_tse_top_1000_base_x_inst.DEV_VERSION = DEV_VERSION,
        altera_tse_top_1000_base_x_inst.ENABLE_SGMII = ENABLE_SGMII;



// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1)
    begin          
        assign gxb_pwrdn_in_sig = gxb_pwrdn_in;
        assign pcs_pwrdn_out = pcs_pwrdn_out_sig;
    end
else
    begin
        assign gxb_pwrdn_in_sig = pcs_pwrdn_out_sig;
		assign pcs_pwrdn_out = 1'b0;
    end      
endgenerate



// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the Alt2gxb block as the PMA for Stratix II GX devices
// ----------------------------------------------------------------------- 
// Instantiation of the Alt2gxb block as the PMA for ArriaGX device
// ---------------------------------------------------------------- 



// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1)
    begin          

    assign tbi_tx_clk = ref_clk;
    assign tbi_rx_d = tbi_rx_d_flip;
    
    // Reset Synchronizer
    altera_tse_reset_synchronizer reset_sync_0 (
        .clk(ref_clk),
        .reset_in(reset),
        .reset_out(reset_ref_clk_int)
        );
        
    altera_tse_reset_synchronizer reset_sync_1 (
        .clk(tbi_rx_clk),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_int)
        );  
        
    always @(posedge tbi_rx_clk or posedge reset_tbi_rx_clk_int)
        begin
        if (reset_tbi_rx_clk_int == 1)
            tbi_rx_d_flip <= 0;
        else 
            begin
            tbi_rx_d_flip[0] <= tbi_rx_d_lvds[9];
            tbi_rx_d_flip[1] <= tbi_rx_d_lvds[8];
            tbi_rx_d_flip[2] <= tbi_rx_d_lvds[7];
            tbi_rx_d_flip[3] <= tbi_rx_d_lvds[6];
            tbi_rx_d_flip[4] <= tbi_rx_d_lvds[5];
            tbi_rx_d_flip[5] <= tbi_rx_d_lvds[4];
            tbi_rx_d_flip[6] <= tbi_rx_d_lvds[3];
            tbi_rx_d_flip[7] <= tbi_rx_d_lvds[2];
            tbi_rx_d_flip[8] <= tbi_rx_d_lvds[1];
            tbi_rx_d_flip[9] <= tbi_rx_d_lvds[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip <= 0;
        else 
            begin
            tbi_tx_d_flip[0] <= tbi_tx_d[9];
            tbi_tx_d_flip[1] <= tbi_tx_d[8];
            tbi_tx_d_flip[2] <= tbi_tx_d[7];
            tbi_tx_d_flip[3] <= tbi_tx_d[6];
            tbi_tx_d_flip[4] <= tbi_tx_d[5];
            tbi_tx_d_flip[5] <= tbi_tx_d[4];
            tbi_tx_d_flip[6] <= tbi_tx_d[3];
            tbi_tx_d_flip[7] <= tbi_tx_d[2];
            tbi_tx_d_flip[8] <= tbi_tx_d[1];
            tbi_tx_d_flip[9] <= tbi_tx_d[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset ),
         .rx_channel_data_align ( rx_channel_data_align ),
         .rx_locked ( rx_locked ),
         .rx_divfwdclk (tbi_rx_clk),
         .rx_in (rxp),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds),
         .rx_outclock (),
         .rx_reset (rx_reset)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer (
		.clk ( clk ),
		.reset ( reset ),
		.rx_locked ( rx_locked ),
		.rx_channel_data_align ( rx_channel_data_align ),
		.pll_areset ( pll_areset ),
		.rx_reset ( rx_reset ),
		.rx_cda_reset ( rx_cda_reset )
	);   


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx
    (
        .tx_in (tbi_tx_d_flip),
		.pll_areset ( reset ),
        .tx_inclock (ref_clk),
        .tx_out (txp)
    );

    end    
endgenerate

endmodule

