// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_mac_pcs_pma_gige.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_mac_pcs_pma_gige.v,v $
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
// Top level MAC + PCS + PMA module for Triple Speed Ethernet MAC + PCS + PMA

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
module altera_tse_mac_pcs_pma_gige /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"R102,R105,D102,D101,D103\"" */(
    // inputs:
    address,
    clk,
    ff_rx_clk,
    ff_rx_rdy,
    ff_tx_clk,
    ff_tx_crc_fwd,
    ff_tx_data,
    ff_tx_mod,
    ff_tx_eop,
    ff_tx_err,
    ff_tx_sop,
    ff_tx_wren,
    gxb_cal_blk_clk,
    gxb_pwrdn_in,
    magic_sleep_n,
    mdio_in,
    read,
    reconfig_clk,
    reconfig_togxb,
    reconfig_busy,
    ref_clk,
    reset,
    rxp,
    write,
    writedata,
    xoff_gen,
    xon_gen,

    // outputs:
    ff_rx_a_empty,
    ff_rx_a_full,
    ff_rx_data,
    ff_rx_mod,
    ff_rx_dsav,
    ff_rx_dval,
    ff_rx_eop,
    ff_rx_sop,
    ff_tx_a_empty,
    ff_tx_a_full,
    ff_tx_rdy,
    ff_tx_septy,
    led_an,
    led_char_err,
    led_col,
    led_crs,
    led_disp_err,
    led_link,
    magic_wakeup,
    mdc,
    mdio_oen,
    mdio_out,
    pcs_pwrdn_out,
    readdata,
    reconfig_fromgxb,
    rx_err,
    rx_err_stat,
    rx_frm_type,
    tx_ff_uflow,
    txp,
    rx_recovclkout,
    waitrequest
);

//  Parameters to configure the core for different variations
//  ---------------------------------------------------------

parameter ENABLE_ENA            = 8;            //  Enable n-Bit Local Interface
parameter ENABLE_GMII_LOOPBACK  = 1;            //  GMII_LOOPBACK_ENA : Enable GMII Loopback Logic 
parameter ENABLE_HD_LOGIC       = 1;            //  HD_LOGIC_ENA : Enable Half Duplex Logic
parameter USE_SYNC_RESET        = 1;            //  Use Synchronized Reset Inputs
parameter ENABLE_SUP_ADDR       = 1;            //  SUP_ADDR_ENA : Enable Supplemental Addresses
parameter ENA_HASH              = 1;            //  ENA_HASH Enable Hask Table 
parameter STAT_CNT_ENA          = 1;            //  STAT_CNT_ENA Enable Statistic Counters
parameter ENABLE_EXTENDED_STAT_REG = 0;         //  Enable a few extended statistic registers
parameter EG_FIFO               = 256 ;         //  Egress FIFO Depth
parameter EG_ADDR               = 8 ;           //  Egress FIFO Depth
parameter ING_FIFO              = 256 ;         //  Ingress FIFO Depth
parameter ING_ADDR              = 8 ;           //  Egress FIFO Depth
parameter RESET_LEVEL           = 1'b 1 ;       //  Reset Active Level
parameter MDIO_CLK_DIV          = 40 ;          //  Host Clock Division - MDC Generation
parameter CORE_VERSION          = 16'h3;        //  MorethanIP Core Version
parameter CUST_VERSION          = 1 ;           //  Customer Core Version
parameter REDUCED_INTERFACE_ENA = 1;            //  Enable the RGMII / MII Interface
parameter ENABLE_MDIO           = 1;            //  Enable the MDIO Interface
parameter ENABLE_MAGIC_DETECT   = 1;            //  Enable magic packet detection
parameter ENABLE_MACLITE        = 0;            //  Enable MAC LITE operation
parameter MACLITE_GIGE          = 0;            //  Enable/Disable Gigabit MAC operation for MAC LITE.
parameter CRC32DWIDTH           = 4'b 1000;     //  input data width (informal, not for change)
parameter CRC32GENDELAY         = 3'b 110;      //  when the data from the generator is valid
parameter CRC32CHECK16BIT       = 1'b 0;        //  1 compare two times 16 bit of the CRC (adds one pipeline step) 
parameter CRC32S1L2_EXTERN      = 1'b0;         //  false: merge enable
parameter ENABLE_SHIFT16        = 0;            //  Enable byte stuffing at packet header
parameter RAM_TYPE              = "AUTO";       //  Specify the RAM type 
parameter INSERT_TA             = 0;            //  Option to insert timing adapter for SOPC systems
parameter PHY_IDENTIFIER        = 32'h 00000000;//  PHY Identifier 
parameter DEV_VERSION           = 16'h 0001 ;   //  Customer Phy's Core Version
parameter ENABLE_SGMII          = 1;            //  Enable SGMII logic for synthesis
parameter ENABLE_MAC_FLOW_CTRL  = 1'b1;         //  Option to enable flow control 
parameter ENABLE_MAC_TXADDR_SET = 1'b1;         //  Option to enable MAC address insertion onto 'to-be-transmitted' Ethernet frames on MAC TX data path
parameter ENABLE_MAC_RX_VLAN    = 1'b1;         //  Option to enable VLAN tagged Ethernet frames on MAC RX data path
parameter ENABLE_MAC_TX_VLAN    = 1'b1;         //  Option to enable VLAN tagged Ethernet frames on MAC TX data path
parameter EXPORT_PWRDN          = 1'b0;         //  Option to export the Alt2gxb powerdown signal
parameter DEVICE_FAMILY         = "ARRIAGX";    //  The device family the the core is targetted for.
parameter TRANSCEIVER_OPTION    = 1'b0;         //  Option to select transceiver block for MAC PCS PMA Instantiation. Valid Values are 0 and 1:  0 - GXB (GIGE Mode) 1 - LVDS I/O
parameter ENABLE_ALT_RECONFIG   = 0;            //  Option to have the Alt_Reconfig ports exposed
parameter STARTING_CHANNEL_NUMBER = 0;          //  Starting Channel Number for Reconfig block
parameter SYNCHRONIZER_DEPTH     = 3;	  	//  Number of synchronizer

  output  ff_rx_a_empty;
  output  ff_rx_a_full;
  output  [ENABLE_ENA-1:0] ff_rx_data;
  output  [1:0] ff_rx_mod;
  output  ff_rx_dsav;
  output  ff_rx_dval;
  output  ff_rx_eop;
  output  ff_rx_sop;
  output  ff_tx_a_empty;
  output  ff_tx_a_full;
  output  ff_tx_rdy;
  output  ff_tx_septy;
  output  led_an;
  output  led_char_err;
  output  led_col;
  output  led_crs;
  output  led_disp_err;
  output  led_link;
  output  magic_wakeup;
  output  mdc;
  output  mdio_oen;
  output  mdio_out;
  output  pcs_pwrdn_out;
  output  [31: 0] readdata;
  output  [16:0] reconfig_fromgxb;
  output  [5: 0] rx_err;
  output  [17: 0] rx_err_stat;
  output  [3: 0] rx_frm_type;
  output  tx_ff_uflow;
  output  txp;
  output  rx_recovclkout; 
  output  waitrequest;
  
  input   [7: 0] address;
  input   clk;
  input   ff_rx_clk;
  input   ff_rx_rdy;
  input   ff_tx_clk;
  input   ff_tx_crc_fwd;
  input   [ENABLE_ENA-1:0] ff_tx_data;
  input   [1:0] ff_tx_mod;
  input   ff_tx_eop;
  input   ff_tx_err;
  input   ff_tx_sop;
  input   ff_tx_wren;
  input   gxb_cal_blk_clk;
  input   gxb_pwrdn_in;
  input   magic_sleep_n;
  input   mdio_in;
  input   read;
  input   reconfig_clk;
  input   [3:0] reconfig_togxb;
  input   reconfig_busy;
  input   ref_clk;
  input   reset;
  input   rxp;
  input   write;
  input   [31:0] writedata;
  input   xoff_gen;
  input   xon_gen;

  wire    ff_rx_a_empty;
  wire    ff_rx_a_full;
  wire    [ENABLE_ENA-1:0] ff_rx_data;
  wire    [1:0] ff_rx_mod;
  wire    ff_rx_dsav;
  wire    ff_rx_dval;
  wire    ff_rx_eop;
  wire    ff_rx_sop;
  wire    ff_tx_a_empty;
  wire    ff_tx_a_full;
  wire    ff_tx_rdy;
  wire    ff_tx_septy;
  wire    gige_pma_reset;
  wire    led_an;
  wire    led_char_err;
  wire    led_char_err_gx;
  wire    led_col;
  wire    led_crs;
  wire    led_disp_err;
  wire    led_link;
  wire    link_status;
  wire    magic_wakeup;
  wire    mdc;
  wire    mdio_oen;
  wire    mdio_out;
  wire    rx_pcs_clk;
  wire    tx_pcs_clk;
  wire    [7:0] pcs_rx_frame;
  wire    pcs_rx_kchar;
  wire    pcs_pwrdn_out_sig;
  wire    gxb_pwrdn_in_sig;
  wire    gxb_cal_blk_clk_sig;

   
  wire    [31:0] readdata;
  wire    rx_char_err_gx;
  wire    rx_disp_err;
  wire    [5:0] rx_err;
  wire    [17:0] rx_err_stat;
  wire    [3:0] rx_frm_type;
  wire    [7:0] rx_frame;
  wire    rx_syncstatus;
  wire    rx_kchar;
  wire    sd_loopback;
  wire    tx_ff_uflow;
  wire    [7:0] tx_frame;
  wire    tx_kchar;
  wire    txp;
  wire    rx_recovclkout;
  wire    waitrequest;

  wire   rx_runlengthviolation;
  wire   rx_patterndetect;
  wire   rx_runningdisp;
  wire   rx_rmfifodatadeleted;
  wire   rx_rmfifodatainserted;
  wire   pcs_rx_carrierdetected;
  wire   pcs_rx_rmfifodatadeleted;
  wire   pcs_rx_rmfifodatainserted;
  
  wire    [16:0] reconfig_fromgxb;
  
  wire reset_ref_clk;
  wire reset_rx_pcs_clk_int;
  wire pll_powerdown_sqcnr,tx_digitalreset_sqcnr,rx_analogreset_sqcnr,rx_digitalreset_sqcnr,gxb_powerdown_sqcnr,pll_locked;
  wire  locked_signal;
  wire rx_freqlocked;

  //  Assign the character error and link status to top level leds
  //  ------------------------------------------------------------
  assign led_char_err = led_char_err_gx;
  assign led_link = link_status;


  
  // Instantiation of the MAC_PCS core that connects to a PMA
  // --------------------------------------------------------
  altera_tse_mac_pcs_pma_strx_gx_ena altera_tse_mac_pcs_pma_strx_gx_ena_inst
    (
 
       .rx_carrierdetected(pcs_rx_carrierdetected),
       .rx_rmfifodatadeleted(pcs_rx_rmfifodatadeleted),
       .rx_rmfifodatainserted(pcs_rx_rmfifodatainserted),

       .address (address),
       .clk (clk),
       .ff_rx_a_empty (ff_rx_a_empty),
       .ff_rx_a_full (ff_rx_a_full),
       .ff_rx_clk (ff_rx_clk),
       .ff_rx_data (ff_rx_data),
       .ff_rx_mod (ff_rx_mod),
       .ff_rx_dsav (ff_rx_dsav),
       .ff_rx_dval (ff_rx_dval),
       .ff_rx_eop (ff_rx_eop),
       .ff_rx_rdy (ff_rx_rdy),
       .ff_rx_sop (ff_rx_sop),
       .ff_tx_a_empty (ff_tx_a_empty),
       .ff_tx_a_full (ff_tx_a_full),
       .ff_tx_clk (ff_tx_clk),
       .ff_tx_crc_fwd (ff_tx_crc_fwd),
       .ff_tx_data (ff_tx_data),
       .ff_tx_mod (ff_tx_mod),
       .ff_tx_eop (ff_tx_eop),
       .ff_tx_err (ff_tx_err),
       .ff_tx_rdy (ff_tx_rdy),
       .ff_tx_septy (ff_tx_septy),
       .ff_tx_sop (ff_tx_sop),
       .ff_tx_wren (ff_tx_wren),
       .led_an (led_an),
       .led_char_err (led_char_err_gx),
       .led_col (led_col),
       .led_crs (led_crs),
       .led_link (link_status),
       .magic_sleep_n (magic_sleep_n),
       .magic_wakeup (magic_wakeup),
       .mdc (mdc),
       .mdio_in (mdio_in),
       .mdio_oen (mdio_oen),
       .mdio_out (mdio_out),
       .powerdown (pcs_pwrdn_out_sig),
       .read (read),
       .readdata (readdata),
       .reset (reset),
       .rx_clkout (rx_pcs_clk),
       .rx_err (rx_err),
       .rx_err_stat (rx_err_stat),
       .rx_frame (pcs_rx_frame),
       .rx_frm_type (rx_frm_type),
       .rx_kchar (pcs_rx_kchar),
       .sd_loopback (sd_loopback),
       .tx_clkout (tx_pcs_clk),
       .tx_ff_uflow (tx_ff_uflow),
       .tx_frame (tx_frame),
       .tx_kchar (tx_kchar),
       .waitrequest (waitrequest),
       .write (write),
       .writedata (writedata),
       .xoff_gen (xoff_gen),
       .xon_gen (xon_gen)
    );

    defparam
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_ENA = ENABLE_ENA,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_HD_LOGIC = ENABLE_HD_LOGIC,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_GMII_LOOPBACK = ENABLE_GMII_LOOPBACK,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.USE_SYNC_RESET = USE_SYNC_RESET,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_SUP_ADDR = ENABLE_SUP_ADDR,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENA_HASH = ENA_HASH,        
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.STAT_CNT_ENA = STAT_CNT_ENA,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_EXTENDED_STAT_REG = ENABLE_EXTENDED_STAT_REG,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.EG_FIFO = EG_FIFO,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.EG_ADDR = EG_ADDR,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ING_FIFO = ING_FIFO,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ING_ADDR = ING_ADDR,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.RESET_LEVEL = RESET_LEVEL,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.MDIO_CLK_DIV = MDIO_CLK_DIV,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.CORE_VERSION = CORE_VERSION,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.CUST_VERSION = CUST_VERSION,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.REDUCED_INTERFACE_ENA = REDUCED_INTERFACE_ENA,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_MDIO = ENABLE_MDIO,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_MAGIC_DETECT = ENABLE_MAGIC_DETECT,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_MACLITE = ENABLE_MACLITE,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.MACLITE_GIGE = MACLITE_GIGE,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.CRC32S1L2_EXTERN = CRC32S1L2_EXTERN,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.CRC32DWIDTH = CRC32DWIDTH,     
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.CRC32CHECK16BIT = CRC32CHECK16BIT,               
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.CRC32GENDELAY = CRC32GENDELAY,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_SHIFT16 = ENABLE_SHIFT16,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.INSERT_TA = INSERT_TA,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.RAM_TYPE = RAM_TYPE,        
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.PHY_IDENTIFIER = PHY_IDENTIFIER,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.DEV_VERSION = DEV_VERSION,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_SGMII = ENABLE_SGMII,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_MAC_FLOW_CTRL = ENABLE_MAC_FLOW_CTRL, 
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_MAC_TXADDR_SET = ENABLE_MAC_TXADDR_SET,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_MAC_RX_VLAN = ENABLE_MAC_RX_VLAN,
    	altera_tse_mac_pcs_pma_strx_gx_ena_inst.SYNCHRONIZER_DEPTH = SYNCHRONIZER_DEPTH,
        altera_tse_mac_pcs_pma_strx_gx_ena_inst.ENABLE_MAC_TX_VLAN = ENABLE_MAC_TX_VLAN;

// Based on PHYIP , when user assert reset - it hold the reset sequencer block in reset.
//                , reset sequencing only start then reset_sequnece end.
wire reset_sync;
reg  reset_start;

 altera_tse_reset_synchronizer reset_sync_u0 (
    .clk(clk),
    .reset_in(reset),
    .reset_out(reset_sync)
    );
        
always@(posedge clk or posedge reset_sync) begin
    if (reset_sync) begin
        reset_start <= 1'b1;
    end
    else begin
        reset_start <= 1'b0;
    end
end
        
// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_d1, gxb_pwrdn_in_sig_clk;
generate if (EXPORT_PWRDN == 1)
    begin          
        always @(posedge clk or posedge gxb_pwrdn_in)
        begin
          if (gxb_pwrdn_in == 1) begin
              data_in_d1 <= 1;
              gxb_pwrdn_in_sig_clk <= 1;
          end else begin
            data_in_d1 <= 1'b0;
            gxb_pwrdn_in_sig_clk <= data_in_d1;
          end	
        end	
        assign gxb_pwrdn_in_sig = gxb_pwrdn_in;
        assign pcs_pwrdn_out = pcs_pwrdn_out_sig;
    end
else
    begin
        assign gxb_pwrdn_in_sig = pcs_pwrdn_out_sig;
        assign pcs_pwrdn_out = 1'b0;
        
        always@(*) begin
            gxb_pwrdn_in_sig_clk = gxb_pwrdn_in_sig;
        end
    end      
endgenerate
        
// Reset logic used to reset the PMA blocks
// ----------------------------------------  


//  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),    
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr),// output
            .tx_digitalreset(tx_digitalreset_sqcnr),// output
            .rx_analogreset(rx_analogreset_sqcnr),// output
            .rx_digitalreset(rx_digitalreset_sqcnr),// output
            .gxb_powerdown(gxb_powerdown_sqcnr),// output
            .pll_is_locked(locked_signal),
            .rx_is_lockedtodata(rx_freqlocked),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy)
        );

            
    assign locked_signal = (reset? 1'b0: pll_locked);

// Instantiation of the Alt2gxb block as the PMA for Stratix_II_GX and ArriaGX devices
// ----------------------------------------------------------------------------------- 
       
    altera_tse_reset_synchronizer ch_0_reset_sync_0 (
        .clk(rx_pcs_clk),
        .reset_in(rx_digitalreset_sqcnr),
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

    // Altgxb in GIGE mode
    // --------------------
    altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst
      (
        .cal_blk_clk (gxb_cal_blk_clk),
        .gxb_powerdown (gxb_pwrdn_in_sig),
        .pll_inclk (ref_clk),
        .reconfig_clk(reconfig_clk),
        .reconfig_togxb(reconfig_togxb),
        .reconfig_fromgxb(reconfig_fromgxb),    
        .rx_analogreset (rx_analogreset_sqcnr),
        .rx_cruclk (ref_clk),
        .rx_ctrldetect (rx_kchar),
        .rx_clkout (rx_pcs_clk),
        .rx_datain (rxp),
        .rx_dataout (rx_frame),
        .rx_digitalreset (rx_digitalreset_sqcnr),
        .rx_disperr (rx_disp_err),
        .rx_errdetect (rx_char_err_gx),
        .rx_patterndetect (rx_patterndetect),
        .rx_rlv (rx_runlengthviolation),
        .rx_seriallpbken (sd_loopback),
        .rx_syncstatus (rx_syncstatus),
        .tx_clkout (tx_pcs_clk),
        .tx_ctrlenable (tx_kchar),
        .tx_datain (tx_frame),
        .rx_freqlocked (rx_freqlocked),
        .tx_dataout (txp),
        .tx_digitalreset (tx_digitalreset_sqcnr),
        .rx_recovclkout(rx_recovclkout),
        .rx_rmfifodatadeleted(rx_rmfifodatadeleted),
        .rx_rmfifodatainserted(rx_rmfifodatainserted),
        .rx_runningdisp(rx_runningdisp),
        .pll_powerdown(gxb_pwrdn_in_sig),
        .pll_locked(pll_locked) 
      );
        defparam
        the_altera_tse_gxb_gige_inst.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER,
        the_altera_tse_gxb_gige_inst.DEVICE_FAMILY = DEVICE_FAMILY,
        the_altera_tse_gxb_gige_inst.ENABLE_SGMII = ENABLE_SGMII;

endmodule

