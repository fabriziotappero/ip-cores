// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_multi_mac_pcs_pma.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_multi_mac_pcs_pma.v,v $
//
// $Revision: #1 $
// $Date: 2012/06/21 $
// Check in by : $Author: swbranch $
// Author      : Arul Paniandi
//
// Project     : Triple Speed Ethernet - 10/100/1000 MAC
//
// Description : 
//
// Top Level Triple Speed Ethernet(10/100/1000) MAC with MII/GMII
// interfaces, mdio module and register space (statistic, control and 
// management)

// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation  
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

(*altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION OFF" } *)
module altera_tse_multi_mac_pcs_pma
/* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"R102,R105,D102,D101,D103\"" */
#(
parameter USE_SYNC_RESET        = 0,                    //  Use Synchronized Reset Inputs
parameter RESET_LEVEL           = 1'b 1 ,               //  Reset Active Level
parameter ENABLE_GMII_LOOPBACK  = 1,                    //  GMII_LOOPBACK_ENA : Enable GMII Loopback Logic 
parameter ENABLE_HD_LOGIC       = 1,                    //  HD_LOGIC_ENA : Enable Half Duplex Logic
parameter ENABLE_SUP_ADDR       = 1,                    //  SUP_ADDR_ENA : Enable Supplemental Addresses
parameter ENA_HASH              = 1,                    //  ENA_HASH Enable Hash Table 
parameter STAT_CNT_ENA          = 1,                    //  STAT_CNT_ENA Enable Statistic Counters
parameter MDIO_CLK_DIV          = 40 ,                  //  Host Clock Division - MDC Generation
parameter CORE_VERSION          = 16'h3,                //  ALTERA Core Version
parameter CUST_VERSION          = 1 ,                   //  Customer Core Version
parameter REDUCED_INTERFACE_ENA = 0,                    //  Enable the RGMII Interface
parameter ENABLE_MDIO           = 1,                    //  Enable the MDIO Interface
parameter ENABLE_MAGIC_DETECT   = 1,                    //  Enable magic packet detection 
parameter ENABLE_PADDING        = 1,                    //  Enable padding operation.
parameter ENABLE_LGTH_CHECK     = 1,                    //  Enable frame length checking.
parameter GBIT_ONLY             = 1,                    //  Enable Gigabit only operation.
parameter MBIT_ONLY             = 1,                    //  Enable Megabit (10/100) only operation.
parameter REDUCED_CONTROL       = 0,                    //  Reduced control for MAC LITE
parameter CRC32DWIDTH           = 4'b 1000,             //  input data width (informal, not for change)
parameter CRC32GENDELAY         = 3'b 110,              //  when the data from the generator is valid
parameter CRC32CHECK16BIT       = 1'b 0,                //  1 compare two times 16 bit of the CRC (adds one pipeline step) 
parameter CRC32S1L2_EXTERN      = 1'b0,                 //  false: merge enable
parameter ENABLE_SHIFT16        = 0,                    //  Enable byte stuffing at packet header 
parameter ENABLE_MAC_FLOW_CTRL  = 1'b1,                 //  Option to enable flow control 
parameter ENABLE_MAC_TXADDR_SET = 1'b1,                 //  Option to enable MAC address insertion onto 'to-be-transmitted' Ethernet frames on MAC TX data path
parameter ENABLE_MAC_RX_VLAN    = 1'b1,                 //  Option to enable VLAN tagged Ethernet frames on MAC RX data path
parameter ENABLE_MAC_TX_VLAN    = 1'b1,                 //  Option to enable VLAN tagged Ethernet frames on MAC TX data path
parameter PHY_IDENTIFIER        = 32'h 00000000,        //  PHY Identifier
parameter DEV_VERSION           = 16'h 0001 ,           //  Customer Phy's Core Version
parameter ENABLE_SGMII          = 1,                    //  Enable SGMII logic for synthesis
parameter ENABLE_CLK_SHARING    = 0,                    //  Option to share clock for multiple channels (Clocks are rate-matched).
parameter ENABLE_REG_SHARING    = 0,                    //  Option to share register space. Uses certain hard-coded values from input.
parameter ENABLE_EXTENDED_STAT_REG = 0,                 //  Enable a few extended statistic registers
parameter MAX_CHANNELS          = 1,                    //  The number of channels in Multi-TSE component
parameter ENABLE_PKT_CLASS      = 1,                    //  Enable Packet Classification Av-ST Interface
parameter ENABLE_RX_FIFO_STATUS = 1,                    //  Enable Receive FIFO Almost Full status interface
parameter CHANNEL_WIDTH         = 1,                    //  The width of the channel interface
parameter EXPORT_PWRDN          = 1'b0,                 //  Option to export the Alt2gxb powerdown signal
parameter DEVICE_FAMILY         = "ARRIAGX",            //  The device family the the core is targetted for.
parameter TRANSCEIVER_OPTION    = 1'b1,                 //  Option to select transceiver block for MAC PCS PMA Instantiation. Valid Values are 0 and 1:  0 - GXB (GIGE Mode) 1 - LVDS I/O
parameter ENABLE_ALT_RECONFIG   = 0,                    //  Option to have the Alt_Reconfig ports exposed
parameter SYNCHRONIZER_DEPTH 	= 3,	  	        //  Number of synchronizer
// Internal parameters
parameter ADDR_WIDTH = (MAX_CHANNELS > 16)? 13 :
                       (MAX_CHANNELS > 8)? 12 : 
                       (MAX_CHANNELS > 4)? 11 : 
                       (MAX_CHANNELS > 2)? 10 :  
                       (MAX_CHANNELS > 1)? 9 : 8
)


// Port List
(

    // RESET / MAC REG IF / MDIO
    input wire   reset,                      //  Asynchronous Reset - clk Domain
    input wire   clk,                        //  25MHz Host Interface Clock
    input wire   read,                       //  Register Read Strobe
    input wire   write,                      //  Register Write Strobe
    input wire   [ADDR_WIDTH-1:0] address,   //  Register Address
    input wire   [31:0] writedata,           //  Write Data for Host Bus
    output wire  [31:0] readdata,            //  Read Data to Host Bus
    output wire  waitrequest,                //  Interface Busy
    output wire  mdc,                        //  2.5MHz Inteface
    input wire   mdio_in,                    //  MDIO Input
    output wire  mdio_out,                   //  MDIO Output
    output wire  mdio_oen,                   //  MDIO Output Enable

    // DEVICE SPECIFIC SIGNALS
    input wire   gxb_cal_blk_clk,            //  GXB Calibration Clock
    input wire   ref_clk,                    //  Rference Clock

	// SHARED CLK SIGNALS
    output wire  mac_rx_clk,                 //  Av-ST Receive Clock
	output wire  mac_tx_clk,                 //  Av-ST Transmit Clock 

	// SHARED RX STATUS
	input wire   rx_afull_clk,                             //  Almost full clock
    input wire   [1:0] rx_afull_data,                      //  Almost full data
    input wire   rx_afull_valid,                           //  Almost full valid
    input wire   [CHANNEL_WIDTH-1:0] rx_afull_channel,     //  Almost full channel


    // CHANNEL 0

    // PCS SIGNALS TO PHY
    input wire   rxp_0,                    //  Differential Receive Data 
    output wire  txp_0,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_0,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_0,          //  Powerdown Enable from PCS
    output wire  led_crs_0,                //  Carrier Sense
    output wire  led_link_0,               //  Valid Link 
    output wire  led_col_0,                //  Collision Indication
    output wire  led_an_0,                 //  Auto-Negotiation Status
    output wire  led_char_err_0,           //  Character Error
    output wire  led_disp_err_0,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_0,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_0,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_0,            //  Start of Packet
    output wire  data_rx_eop_0,            //  End of Packet
    output wire  [7:0] data_rx_data_0,     //  Data from FIFO
    output wire  [4:0] data_rx_error_0,    //  Receive packet error
    output wire  data_rx_valid_0,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_0,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_0,   //  Frame Type Indication
    output wire  pkt_class_valid_0,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_0,         //  Frame Type Indication Valid 
    input wire   data_tx_error_0,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_0,     //  Data from FIFO transmit
    input wire   data_tx_valid_0,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_0,            //  Start of Packet
    input wire   data_tx_eop_0,            //  END of Packet
    output wire  data_tx_ready_0,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_0,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_0,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_0,               //  Xoff Pause frame generate 
    input wire   xon_gen_0,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_0,          //  Enable Sleep Mode
    output wire  magic_wakeup_0,           //  Wake Up Request


    // CHANNEL 1

    // PCS SIGNALS TO PHY
    input wire   rxp_1,                    //  Differential Receive Data 
    output wire  txp_1,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_1,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_1,          //  Powerdown Enable from PCS
    output wire  led_crs_1,                //  Carrier Sense
    output wire  led_link_1,               //  Valid Link 
    output wire  led_col_1,                //  Collision Indication
    output wire  led_an_1,                 //  Auto-Negotiation Status
    output wire  led_char_err_1,           //  Character Error
    output wire  led_disp_err_1,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_1,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_1,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_1,            //  Start of Packet
    output wire  data_rx_eop_1,            //  End of Packet
    output wire  [7:0] data_rx_data_1,     //  Data from FIFO
    output wire  [4:0] data_rx_error_1,    //  Receive packet error
    output wire  data_rx_valid_1,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_1,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_1,   //  Frame Type Indication
    output wire  pkt_class_valid_1,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_1,         //  Frame Type Indication Valid 
    input wire   data_tx_error_1,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_1,     //  Data from FIFO transmit
    input wire   data_tx_valid_1,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_1,            //  Start of Packet
    input wire   data_tx_eop_1,            //  END of Packet
    output wire  data_tx_ready_1,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_1,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_1,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_1,               //  Xoff Pause frame generate 
    input wire   xon_gen_1,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_1,          //  Enable Sleep Mode
    output wire  magic_wakeup_1,           //  Wake Up Request


    // CHANNEL 2

    // PCS SIGNALS TO PHY
    input wire   rxp_2,                    //  Differential Receive Data 
    output wire  txp_2,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_2,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_2,          //  Powerdown Enable from PCS
    output wire  led_crs_2,                //  Carrier Sense
    output wire  led_link_2,               //  Valid Link 
    output wire  led_col_2,                //  Collision Indication
    output wire  led_an_2,                 //  Auto-Negotiation Status
    output wire  led_char_err_2,           //  Character Error
    output wire  led_disp_err_2,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_2,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_2,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_2,            //  Start of Packet
    output wire  data_rx_eop_2,            //  End of Packet
    output wire  [7:0] data_rx_data_2,     //  Data from FIFO
    output wire  [4:0] data_rx_error_2,    //  Receive packet error
    output wire  data_rx_valid_2,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_2,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_2,   //  Frame Type Indication
    output wire  pkt_class_valid_2,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_2,         //  Frame Type Indication Valid 
    input wire   data_tx_error_2,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_2,     //  Data from FIFO transmit
    input wire   data_tx_valid_2,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_2,            //  Start of Packet
    input wire   data_tx_eop_2,            //  END of Packet
    output wire  data_tx_ready_2,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_2,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_2,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_2,               //  Xoff Pause frame generate 
    input wire   xon_gen_2,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_2,          //  Enable Sleep Mode
    output wire  magic_wakeup_2,           //  Wake Up Request


    // CHANNEL 3

    // PCS SIGNALS TO PHY
    input wire   rxp_3,                    //  Differential Receive Data 
    output wire  txp_3,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_3,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_3,          //  Powerdown Enable from PCS
    output wire  led_crs_3,                //  Carrier Sense
    output wire  led_link_3,               //  Valid Link 
    output wire  led_col_3,                //  Collision Indication
    output wire  led_an_3,                 //  Auto-Negotiation Status
    output wire  led_char_err_3,           //  Character Error
    output wire  led_disp_err_3,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_3,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_3,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_3,            //  Start of Packet
    output wire  data_rx_eop_3,            //  End of Packet
    output wire  [7:0] data_rx_data_3,     //  Data from FIFO
    output wire  [4:0] data_rx_error_3,    //  Receive packet error
    output wire  data_rx_valid_3,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_3,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_3,   //  Frame Type Indication
    output wire  pkt_class_valid_3,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_3,         //  Frame Type Indication Valid 
    input wire   data_tx_error_3,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_3,     //  Data from FIFO transmit
    input wire   data_tx_valid_3,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_3,            //  Start of Packet
    input wire   data_tx_eop_3,            //  END of Packet
    output wire  data_tx_ready_3,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_3,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_3,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_3,               //  Xoff Pause frame generate 
    input wire   xon_gen_3,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_3,          //  Enable Sleep Mode
    output wire  magic_wakeup_3,           //  Wake Up Request


    // CHANNEL 4

    // PCS SIGNALS TO PHY
    input wire   rxp_4,                    //  Differential Receive Data 
    output wire  txp_4,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_4,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_4,          //  Powerdown Enable from PCS
    output wire  led_crs_4,                //  Carrier Sense
    output wire  led_link_4,               //  Valid Link 
    output wire  led_col_4,                //  Collision Indication
    output wire  led_an_4,                 //  Auto-Negotiation Status
    output wire  led_char_err_4,           //  Character Error
    output wire  led_disp_err_4,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_4,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_4,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_4,            //  Start of Packet
    output wire  data_rx_eop_4,            //  End of Packet
    output wire  [7:0] data_rx_data_4,     //  Data from FIFO
    output wire  [4:0] data_rx_error_4,    //  Receive packet error
    output wire  data_rx_valid_4,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_4,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_4,   //  Frame Type Indication
    output wire  pkt_class_valid_4,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_4,         //  Frame Type Indication Valid 
    input wire   data_tx_error_4,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_4,     //  Data from FIFO transmit
    input wire   data_tx_valid_4,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_4,            //  Start of Packet
    input wire   data_tx_eop_4,            //  END of Packet
    output wire  data_tx_ready_4,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_4,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_4,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_4,               //  Xoff Pause frame generate 
    input wire   xon_gen_4,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_4,          //  Enable Sleep Mode
    output wire  magic_wakeup_4,           //  Wake Up Request


    // CHANNEL 5

    // PCS SIGNALS TO PHY
    input wire   rxp_5,                    //  Differential Receive Data 
    output wire  txp_5,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_5,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_5,          //  Powerdown Enable from PCS
    output wire  led_crs_5,                //  Carrier Sense
    output wire  led_link_5,               //  Valid Link 
    output wire  led_col_5,                //  Collision Indication
    output wire  led_an_5,                 //  Auto-Negotiation Status
    output wire  led_char_err_5,           //  Character Error
    output wire  led_disp_err_5,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_5,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_5,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_5,            //  Start of Packet
    output wire  data_rx_eop_5,            //  End of Packet
    output wire  [7:0] data_rx_data_5,     //  Data from FIFO
    output wire  [4:0] data_rx_error_5,    //  Receive packet error
    output wire  data_rx_valid_5,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_5,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_5,   //  Frame Type Indication
    output wire  pkt_class_valid_5,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_5,         //  Frame Type Indication Valid 
    input wire   data_tx_error_5,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_5,     //  Data from FIFO transmit
    input wire   data_tx_valid_5,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_5,            //  Start of Packet
    input wire   data_tx_eop_5,            //  END of Packet
    output wire  data_tx_ready_5,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_5,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_5,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_5,               //  Xoff Pause frame generate 
    input wire   xon_gen_5,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_5,          //  Enable Sleep Mode
    output wire  magic_wakeup_5,           //  Wake Up Request


    // CHANNEL 6

    // PCS SIGNALS TO PHY
    input wire   rxp_6,                    //  Differential Receive Data 
    output wire  txp_6,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_6,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_6,          //  Powerdown Enable from PCS
    output wire  led_crs_6,                //  Carrier Sense
    output wire  led_link_6,               //  Valid Link 
    output wire  led_col_6,                //  Collision Indication
    output wire  led_an_6,                 //  Auto-Negotiation Status
    output wire  led_char_err_6,           //  Character Error
    output wire  led_disp_err_6,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_6,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_6,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_6,            //  Start of Packet
    output wire  data_rx_eop_6,            //  End of Packet
    output wire  [7:0] data_rx_data_6,     //  Data from FIFO
    output wire  [4:0] data_rx_error_6,    //  Receive packet error
    output wire  data_rx_valid_6,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_6,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_6,   //  Frame Type Indication
    output wire  pkt_class_valid_6,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_6,         //  Frame Type Indication Valid 
    input wire   data_tx_error_6,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_6,     //  Data from FIFO transmit
    input wire   data_tx_valid_6,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_6,            //  Start of Packet
    input wire   data_tx_eop_6,            //  END of Packet
    output wire  data_tx_ready_6,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_6,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_6,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_6,               //  Xoff Pause frame generate 
    input wire   xon_gen_6,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_6,          //  Enable Sleep Mode
    output wire  magic_wakeup_6,           //  Wake Up Request


    // CHANNEL 7

    // PCS SIGNALS TO PHY
    input wire   rxp_7,                    //  Differential Receive Data 
    output wire  txp_7,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_7,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_7,          //  Powerdown Enable from PCS
    output wire  led_crs_7,                //  Carrier Sense
    output wire  led_link_7,               //  Valid Link 
    output wire  led_col_7,                //  Collision Indication
    output wire  led_an_7,                 //  Auto-Negotiation Status
    output wire  led_char_err_7,           //  Character Error
    output wire  led_disp_err_7,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_7,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_7,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_7,            //  Start of Packet
    output wire  data_rx_eop_7,            //  End of Packet
    output wire  [7:0] data_rx_data_7,     //  Data from FIFO
    output wire  [4:0] data_rx_error_7,    //  Receive packet error
    output wire  data_rx_valid_7,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_7,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_7,   //  Frame Type Indication
    output wire  pkt_class_valid_7,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_7,         //  Frame Type Indication Valid 
    input wire   data_tx_error_7,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_7,     //  Data from FIFO transmit
    input wire   data_tx_valid_7,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_7,            //  Start of Packet
    input wire   data_tx_eop_7,            //  END of Packet
    output wire  data_tx_ready_7,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_7,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_7,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_7,               //  Xoff Pause frame generate 
    input wire   xon_gen_7,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_7,          //  Enable Sleep Mode
    output wire  magic_wakeup_7,           //  Wake Up Request


    // CHANNEL 8

    // PCS SIGNALS TO PHY
    input wire   rxp_8,                    //  Differential Receive Data 
    output wire  txp_8,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_8,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_8,          //  Powerdown Enable from PCS
    output wire  led_crs_8,                //  Carrier Sense
    output wire  led_link_8,               //  Valid Link 
    output wire  led_col_8,                //  Collision Indication
    output wire  led_an_8,                 //  Auto-Negotiation Status
    output wire  led_char_err_8,           //  Character Error
    output wire  led_disp_err_8,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_8,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_8,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_8,            //  Start of Packet
    output wire  data_rx_eop_8,            //  End of Packet
    output wire  [7:0] data_rx_data_8,     //  Data from FIFO
    output wire  [4:0] data_rx_error_8,    //  Receive packet error
    output wire  data_rx_valid_8,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_8,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_8,   //  Frame Type Indication
    output wire  pkt_class_valid_8,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_8,         //  Frame Type Indication Valid 
    input wire   data_tx_error_8,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_8,     //  Data from FIFO transmit
    input wire   data_tx_valid_8,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_8,            //  Start of Packet
    input wire   data_tx_eop_8,            //  END of Packet
    output wire  data_tx_ready_8,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_8,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_8,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_8,               //  Xoff Pause frame generate 
    input wire   xon_gen_8,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_8,          //  Enable Sleep Mode
    output wire  magic_wakeup_8,           //  Wake Up Request


    // CHANNEL 9

    // PCS SIGNALS TO PHY
    input wire   rxp_9,                    //  Differential Receive Data 
    output wire  txp_9,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_9,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_9,          //  Powerdown Enable from PCS
    output wire  led_crs_9,                //  Carrier Sense
    output wire  led_link_9,               //  Valid Link 
    output wire  led_col_9,                //  Collision Indication
    output wire  led_an_9,                 //  Auto-Negotiation Status
    output wire  led_char_err_9,           //  Character Error
    output wire  led_disp_err_9,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_9,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_9,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_9,            //  Start of Packet
    output wire  data_rx_eop_9,            //  End of Packet
    output wire  [7:0] data_rx_data_9,     //  Data from FIFO
    output wire  [4:0] data_rx_error_9,    //  Receive packet error
    output wire  data_rx_valid_9,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_9,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_9,   //  Frame Type Indication
    output wire  pkt_class_valid_9,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_9,         //  Frame Type Indication Valid 
    input wire   data_tx_error_9,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_9,     //  Data from FIFO transmit
    input wire   data_tx_valid_9,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_9,            //  Start of Packet
    input wire   data_tx_eop_9,            //  END of Packet
    output wire  data_tx_ready_9,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_9,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_9,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_9,               //  Xoff Pause frame generate 
    input wire   xon_gen_9,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_9,          //  Enable Sleep Mode
    output wire  magic_wakeup_9,           //  Wake Up Request


    // CHANNEL 10

    // PCS SIGNALS TO PHY
    input wire   rxp_10,                    //  Differential Receive Data 
    output wire  txp_10,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_10,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_10,          //  Powerdown Enable from PCS
    output wire  led_crs_10,                //  Carrier Sense
    output wire  led_link_10,               //  Valid Link 
    output wire  led_col_10,                //  Collision Indication
    output wire  led_an_10,                 //  Auto-Negotiation Status
    output wire  led_char_err_10,           //  Character Error
    output wire  led_disp_err_10,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_10,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_10,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_10,            //  Start of Packet
    output wire  data_rx_eop_10,            //  End of Packet
    output wire  [7:0] data_rx_data_10,     //  Data from FIFO
    output wire  [4:0] data_rx_error_10,    //  Receive packet error
    output wire  data_rx_valid_10,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_10,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_10,   //  Frame Type Indication
    output wire  pkt_class_valid_10,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_10,         //  Frame Type Indication Valid 
    input wire   data_tx_error_10,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_10,     //  Data from FIFO transmit
    input wire   data_tx_valid_10,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_10,            //  Start of Packet
    input wire   data_tx_eop_10,            //  END of Packet
    output wire  data_tx_ready_10,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_10,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_10,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_10,               //  Xoff Pause frame generate 
    input wire   xon_gen_10,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_10,          //  Enable Sleep Mode
    output wire  magic_wakeup_10,           //  Wake Up Request


    // CHANNEL 11

    // PCS SIGNALS TO PHY
    input wire   rxp_11,                    //  Differential Receive Data 
    output wire  txp_11,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_11,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_11,          //  Powerdown Enable from PCS
    output wire  led_crs_11,                //  Carrier Sense
    output wire  led_link_11,               //  Valid Link 
    output wire  led_col_11,                //  Collision Indication
    output wire  led_an_11,                 //  Auto-Negotiation Status
    output wire  led_char_err_11,           //  Character Error
    output wire  led_disp_err_11,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_11,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_11,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_11,            //  Start of Packet
    output wire  data_rx_eop_11,            //  End of Packet
    output wire  [7:0] data_rx_data_11,     //  Data from FIFO
    output wire  [4:0] data_rx_error_11,    //  Receive packet error
    output wire  data_rx_valid_11,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_11,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_11,   //  Frame Type Indication
    output wire  pkt_class_valid_11,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_11,         //  Frame Type Indication Valid 
    input wire   data_tx_error_11,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_11,     //  Data from FIFO transmit
    input wire   data_tx_valid_11,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_11,            //  Start of Packet
    input wire   data_tx_eop_11,            //  END of Packet
    output wire  data_tx_ready_11,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_11,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_11,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_11,               //  Xoff Pause frame generate 
    input wire   xon_gen_11,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_11,          //  Enable Sleep Mode
    output wire  magic_wakeup_11,           //  Wake Up Request


    // CHANNEL 12

    // PCS SIGNALS TO PHY
    input wire   rxp_12,                    //  Differential Receive Data 
    output wire  txp_12,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_12,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_12,          //  Powerdown Enable from PCS
    output wire  led_crs_12,                //  Carrier Sense
    output wire  led_link_12,               //  Valid Link 
    output wire  led_col_12,                //  Collision Indication
    output wire  led_an_12,                 //  Auto-Negotiation Status
    output wire  led_char_err_12,           //  Character Error
    output wire  led_disp_err_12,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_12,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_12,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_12,            //  Start of Packet
    output wire  data_rx_eop_12,            //  End of Packet
    output wire  [7:0] data_rx_data_12,     //  Data from FIFO
    output wire  [4:0] data_rx_error_12,    //  Receive packet error
    output wire  data_rx_valid_12,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_12,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_12,   //  Frame Type Indication
    output wire  pkt_class_valid_12,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_12,         //  Frame Type Indication Valid 
    input wire   data_tx_error_12,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_12,     //  Data from FIFO transmit
    input wire   data_tx_valid_12,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_12,            //  Start of Packet
    input wire   data_tx_eop_12,            //  END of Packet
    output wire  data_tx_ready_12,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_12,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_12,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_12,               //  Xoff Pause frame generate 
    input wire   xon_gen_12,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_12,          //  Enable Sleep Mode
    output wire  magic_wakeup_12,           //  Wake Up Request


    // CHANNEL 13

    // PCS SIGNALS TO PHY
    input wire   rxp_13,                    //  Differential Receive Data 
    output wire  txp_13,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_13,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_13,          //  Powerdown Enable from PCS
    output wire  led_crs_13,                //  Carrier Sense
    output wire  led_link_13,               //  Valid Link 
    output wire  led_col_13,                //  Collision Indication
    output wire  led_an_13,                 //  Auto-Negotiation Status
    output wire  led_char_err_13,           //  Character Error
    output wire  led_disp_err_13,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_13,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_13,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_13,            //  Start of Packet
    output wire  data_rx_eop_13,            //  End of Packet
    output wire  [7:0] data_rx_data_13,     //  Data from FIFO
    output wire  [4:0] data_rx_error_13,    //  Receive packet error
    output wire  data_rx_valid_13,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_13,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_13,   //  Frame Type Indication
    output wire  pkt_class_valid_13,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_13,         //  Frame Type Indication Valid 
    input wire   data_tx_error_13,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_13,     //  Data from FIFO transmit
    input wire   data_tx_valid_13,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_13,            //  Start of Packet
    input wire   data_tx_eop_13,            //  END of Packet
    output wire  data_tx_ready_13,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_13,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_13,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_13,               //  Xoff Pause frame generate 
    input wire   xon_gen_13,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_13,          //  Enable Sleep Mode
    output wire  magic_wakeup_13,           //  Wake Up Request


    // CHANNEL 14

    // PCS SIGNALS TO PHY
    input wire   rxp_14,                    //  Differential Receive Data 
    output wire  txp_14,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_14,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_14,          //  Powerdown Enable from PCS
    output wire  led_crs_14,                //  Carrier Sense
    output wire  led_link_14,               //  Valid Link 
    output wire  led_col_14,                //  Collision Indication
    output wire  led_an_14,                 //  Auto-Negotiation Status
    output wire  led_char_err_14,           //  Character Error
    output wire  led_disp_err_14,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_14,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_14,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_14,            //  Start of Packet
    output wire  data_rx_eop_14,            //  End of Packet
    output wire  [7:0] data_rx_data_14,     //  Data from FIFO
    output wire  [4:0] data_rx_error_14,    //  Receive packet error
    output wire  data_rx_valid_14,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_14,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_14,   //  Frame Type Indication
    output wire  pkt_class_valid_14,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_14,         //  Frame Type Indication Valid 
    input wire   data_tx_error_14,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_14,     //  Data from FIFO transmit
    input wire   data_tx_valid_14,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_14,            //  Start of Packet
    input wire   data_tx_eop_14,            //  END of Packet
    output wire  data_tx_ready_14,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_14,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_14,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_14,               //  Xoff Pause frame generate 
    input wire   xon_gen_14,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_14,          //  Enable Sleep Mode
    output wire  magic_wakeup_14,           //  Wake Up Request


    // CHANNEL 15

    // PCS SIGNALS TO PHY
    input wire   rxp_15,                    //  Differential Receive Data 
    output wire  txp_15,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_15,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_15,          //  Powerdown Enable from PCS
    output wire  led_crs_15,                //  Carrier Sense
    output wire  led_link_15,               //  Valid Link 
    output wire  led_col_15,                //  Collision Indication
    output wire  led_an_15,                 //  Auto-Negotiation Status
    output wire  led_char_err_15,           //  Character Error
    output wire  led_disp_err_15,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_15,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_15,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_15,            //  Start of Packet
    output wire  data_rx_eop_15,            //  End of Packet
    output wire  [7:0] data_rx_data_15,     //  Data from FIFO
    output wire  [4:0] data_rx_error_15,    //  Receive packet error
    output wire  data_rx_valid_15,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_15,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_15,   //  Frame Type Indication
    output wire  pkt_class_valid_15,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_15,         //  Frame Type Indication Valid 
    input wire   data_tx_error_15,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_15,     //  Data from FIFO transmit
    input wire   data_tx_valid_15,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_15,            //  Start of Packet
    input wire   data_tx_eop_15,            //  END of Packet
    output wire  data_tx_ready_15,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_15,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_15,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_15,               //  Xoff Pause frame generate 
    input wire   xon_gen_15,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_15,          //  Enable Sleep Mode
    output wire  magic_wakeup_15,           //  Wake Up Request


    // CHANNEL 16

    // PCS SIGNALS TO PHY
    input wire   rxp_16,                    //  Differential Receive Data 
    output wire  txp_16,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_16,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_16,          //  Powerdown Enable from PCS
    output wire  led_crs_16,                //  Carrier Sense
    output wire  led_link_16,               //  Valid Link 
    output wire  led_col_16,                //  Collision Indication
    output wire  led_an_16,                 //  Auto-Negotiation Status
    output wire  led_char_err_16,           //  Character Error
    output wire  led_disp_err_16,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_16,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_16,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_16,            //  Start of Packet
    output wire  data_rx_eop_16,            //  End of Packet
    output wire  [7:0] data_rx_data_16,     //  Data from FIFO
    output wire  [4:0] data_rx_error_16,    //  Receive packet error
    output wire  data_rx_valid_16,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_16,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_16,   //  Frame Type Indication
    output wire  pkt_class_valid_16,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_16,         //  Frame Type Indication Valid 
    input wire   data_tx_error_16,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_16,     //  Data from FIFO transmit
    input wire   data_tx_valid_16,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_16,            //  Start of Packet
    input wire   data_tx_eop_16,            //  END of Packet
    output wire  data_tx_ready_16,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_16,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_16,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_16,               //  Xoff Pause frame generate 
    input wire   xon_gen_16,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_16,          //  Enable Sleep Mode
    output wire  magic_wakeup_16,           //  Wake Up Request


    // CHANNEL 17

    // PCS SIGNALS TO PHY
    input wire   rxp_17,                    //  Differential Receive Data 
    output wire  txp_17,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_17,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_17,          //  Powerdown Enable from PCS
    output wire  led_crs_17,                //  Carrier Sense
    output wire  led_link_17,               //  Valid Link 
    output wire  led_col_17,                //  Collision Indication
    output wire  led_an_17,                 //  Auto-Negotiation Status
    output wire  led_char_err_17,           //  Character Error
    output wire  led_disp_err_17,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_17,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_17,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_17,            //  Start of Packet
    output wire  data_rx_eop_17,            //  End of Packet
    output wire  [7:0] data_rx_data_17,     //  Data from FIFO
    output wire  [4:0] data_rx_error_17,    //  Receive packet error
    output wire  data_rx_valid_17,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_17,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_17,   //  Frame Type Indication
    output wire  pkt_class_valid_17,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_17,         //  Frame Type Indication Valid 
    input wire   data_tx_error_17,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_17,     //  Data from FIFO transmit
    input wire   data_tx_valid_17,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_17,            //  Start of Packet
    input wire   data_tx_eop_17,            //  END of Packet
    output wire  data_tx_ready_17,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_17,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_17,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_17,               //  Xoff Pause frame generate 
    input wire   xon_gen_17,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_17,          //  Enable Sleep Mode
    output wire  magic_wakeup_17,           //  Wake Up Request


    // CHANNEL 18

    // PCS SIGNALS TO PHY
    input wire   rxp_18,                    //  Differential Receive Data 
    output wire  txp_18,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_18,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_18,          //  Powerdown Enable from PCS
    output wire  led_crs_18,                //  Carrier Sense
    output wire  led_link_18,               //  Valid Link 
    output wire  led_col_18,                //  Collision Indication
    output wire  led_an_18,                 //  Auto-Negotiation Status
    output wire  led_char_err_18,           //  Character Error
    output wire  led_disp_err_18,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_18,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_18,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_18,            //  Start of Packet
    output wire  data_rx_eop_18,            //  End of Packet
    output wire  [7:0] data_rx_data_18,     //  Data from FIFO
    output wire  [4:0] data_rx_error_18,    //  Receive packet error
    output wire  data_rx_valid_18,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_18,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_18,   //  Frame Type Indication
    output wire  pkt_class_valid_18,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_18,         //  Frame Type Indication Valid 
    input wire   data_tx_error_18,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_18,     //  Data from FIFO transmit
    input wire   data_tx_valid_18,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_18,            //  Start of Packet
    input wire   data_tx_eop_18,            //  END of Packet
    output wire  data_tx_ready_18,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_18,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_18,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_18,               //  Xoff Pause frame generate 
    input wire   xon_gen_18,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_18,          //  Enable Sleep Mode
    output wire  magic_wakeup_18,           //  Wake Up Request


    // CHANNEL 19

    // PCS SIGNALS TO PHY
    input wire   rxp_19,                    //  Differential Receive Data 
    output wire  txp_19,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_19,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_19,          //  Powerdown Enable from PCS
    output wire  led_crs_19,                //  Carrier Sense
    output wire  led_link_19,               //  Valid Link 
    output wire  led_col_19,                //  Collision Indication
    output wire  led_an_19,                 //  Auto-Negotiation Status
    output wire  led_char_err_19,           //  Character Error
    output wire  led_disp_err_19,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_19,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_19,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_19,            //  Start of Packet
    output wire  data_rx_eop_19,            //  End of Packet
    output wire  [7:0] data_rx_data_19,     //  Data from FIFO
    output wire  [4:0] data_rx_error_19,    //  Receive packet error
    output wire  data_rx_valid_19,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_19,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_19,   //  Frame Type Indication
    output wire  pkt_class_valid_19,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_19,         //  Frame Type Indication Valid 
    input wire   data_tx_error_19,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_19,     //  Data from FIFO transmit
    input wire   data_tx_valid_19,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_19,            //  Start of Packet
    input wire   data_tx_eop_19,            //  END of Packet
    output wire  data_tx_ready_19,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_19,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_19,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_19,               //  Xoff Pause frame generate 
    input wire   xon_gen_19,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_19,          //  Enable Sleep Mode
    output wire  magic_wakeup_19,           //  Wake Up Request


    // CHANNEL 20

    // PCS SIGNALS TO PHY
    input wire   rxp_20,                    //  Differential Receive Data 
    output wire  txp_20,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_20,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_20,          //  Powerdown Enable from PCS
    output wire  led_crs_20,                //  Carrier Sense
    output wire  led_link_20,               //  Valid Link 
    output wire  led_col_20,                //  Collision Indication
    output wire  led_an_20,                 //  Auto-Negotiation Status
    output wire  led_char_err_20,           //  Character Error
    output wire  led_disp_err_20,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_20,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_20,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_20,            //  Start of Packet
    output wire  data_rx_eop_20,            //  End of Packet
    output wire  [7:0] data_rx_data_20,     //  Data from FIFO
    output wire  [4:0] data_rx_error_20,    //  Receive packet error
    output wire  data_rx_valid_20,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_20,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_20,   //  Frame Type Indication
    output wire  pkt_class_valid_20,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_20,         //  Frame Type Indication Valid 
    input wire   data_tx_error_20,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_20,     //  Data from FIFO transmit
    input wire   data_tx_valid_20,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_20,            //  Start of Packet
    input wire   data_tx_eop_20,            //  END of Packet
    output wire  data_tx_ready_20,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_20,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_20,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_20,               //  Xoff Pause frame generate 
    input wire   xon_gen_20,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_20,          //  Enable Sleep Mode
    output wire  magic_wakeup_20,           //  Wake Up Request


    // CHANNEL 21

    // PCS SIGNALS TO PHY
    input wire   rxp_21,                    //  Differential Receive Data 
    output wire  txp_21,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_21,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_21,          //  Powerdown Enable from PCS
    output wire  led_crs_21,                //  Carrier Sense
    output wire  led_link_21,               //  Valid Link 
    output wire  led_col_21,                //  Collision Indication
    output wire  led_an_21,                 //  Auto-Negotiation Status
    output wire  led_char_err_21,           //  Character Error
    output wire  led_disp_err_21,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_21,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_21,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_21,            //  Start of Packet
    output wire  data_rx_eop_21,            //  End of Packet
    output wire  [7:0] data_rx_data_21,     //  Data from FIFO
    output wire  [4:0] data_rx_error_21,    //  Receive packet error
    output wire  data_rx_valid_21,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_21,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_21,   //  Frame Type Indication
    output wire  pkt_class_valid_21,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_21,         //  Frame Type Indication Valid 
    input wire   data_tx_error_21,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_21,     //  Data from FIFO transmit
    input wire   data_tx_valid_21,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_21,            //  Start of Packet
    input wire   data_tx_eop_21,            //  END of Packet
    output wire  data_tx_ready_21,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_21,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_21,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_21,               //  Xoff Pause frame generate 
    input wire   xon_gen_21,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_21,          //  Enable Sleep Mode
    output wire  magic_wakeup_21,           //  Wake Up Request


    // CHANNEL 22

    // PCS SIGNALS TO PHY
    input wire   rxp_22,                    //  Differential Receive Data 
    output wire  txp_22,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_22,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_22,          //  Powerdown Enable from PCS
    output wire  led_crs_22,                //  Carrier Sense
    output wire  led_link_22,               //  Valid Link 
    output wire  led_col_22,                //  Collision Indication
    output wire  led_an_22,                 //  Auto-Negotiation Status
    output wire  led_char_err_22,           //  Character Error
    output wire  led_disp_err_22,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_22,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_22,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_22,            //  Start of Packet
    output wire  data_rx_eop_22,            //  End of Packet
    output wire  [7:0] data_rx_data_22,     //  Data from FIFO
    output wire  [4:0] data_rx_error_22,    //  Receive packet error
    output wire  data_rx_valid_22,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_22,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_22,   //  Frame Type Indication
    output wire  pkt_class_valid_22,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_22,         //  Frame Type Indication Valid 
    input wire   data_tx_error_22,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_22,     //  Data from FIFO transmit
    input wire   data_tx_valid_22,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_22,            //  Start of Packet
    input wire   data_tx_eop_22,            //  END of Packet
    output wire  data_tx_ready_22,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_22,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_22,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_22,               //  Xoff Pause frame generate 
    input wire   xon_gen_22,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_22,          //  Enable Sleep Mode
    output wire  magic_wakeup_22,           //  Wake Up Request


    // CHANNEL 23

    // PCS SIGNALS TO PHY
    input wire   rxp_23,                    //  Differential Receive Data 
    output wire  txp_23,                    //  Differential Transmit Data 
    input wire   gxb_pwrdn_in_23,           //  Powerdown signal to GXB
    output wire  pcs_pwrdn_out_23,          //  Powerdown Enable from PCS
    output wire  led_crs_23,                //  Carrier Sense
    output wire  led_link_23,               //  Valid Link 
    output wire  led_col_23,                //  Collision Indication
    output wire  led_an_23,                 //  Auto-Negotiation Status
    output wire  led_char_err_23,           //  Character Error
    output wire  led_disp_err_23,           //  Disparity Error

    // AV-ST TX & RX
    output wire  mac_rx_clk_23,             //  Av-ST Receive Clock
    output wire  mac_tx_clk_23,             //  Av-ST Transmit Clock   
    output wire  data_rx_sop_23,            //  Start of Packet
    output wire  data_rx_eop_23,            //  End of Packet
    output wire  [7:0] data_rx_data_23,     //  Data from FIFO
    output wire  [4:0] data_rx_error_23,    //  Receive packet error
    output wire  data_rx_valid_23,          //  Data Receive FIFO Valid
    input wire   data_rx_ready_23,          //  Data Receive Ready
    output wire  [4:0] pkt_class_data_23,   //  Frame Type Indication
    output wire  pkt_class_valid_23,        //  Frame Type Indication Valid 
    output wire  rx_recovclkout_23,         //  Frame Type Indication Valid 
    input wire   data_tx_error_23,          //  STATUS FIFO (Tx frame Error from Apps)
    input wire   [7:0] data_tx_data_23,     //  Data from FIFO transmit
    input wire   data_tx_valid_23,          //  Data FIFO transmit Empty
    input wire   data_tx_sop_23,            //  Start of Packet
    input wire   data_tx_eop_23,            //  END of Packet
    output wire  data_tx_ready_23,          //  Data FIFO transmit Read Enable 	

    // STAND_ALONE CONDUITS 
    output wire  tx_ff_uflow_23,            //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire   tx_crc_fwd_23,             //  Forward Current Frame with CRC from Application
    input wire   xoff_gen_23,               //  Xoff Pause frame generate 
    input wire   xon_gen_23,                //  Xon Pause frame generate 
    input wire   magic_sleep_n_23,          //  Enable Sleep Mode
    output wire  magic_wakeup_23);          //  Wake Up Request


wire    [23:0] pcs_pwrdn_out_sig;
wire    [23:0] gxb_pwrdn_in_sig;

wire    [9:0] tbi_rx_d_lvds_0;
reg     [9:0] tbi_rx_d_flip_0;
reg     [9:0] tbi_tx_d_flip_0;
wire    [9:0] tbi_rx_d_0;
wire    [9:0] tbi_tx_d_0;
wire    [9:0] tbi_rx_d_lvds_1;
reg     [9:0] tbi_rx_d_flip_1;
reg     [9:0] tbi_tx_d_flip_1;
wire    [9:0] tbi_rx_d_1;
wire    [9:0] tbi_tx_d_1;
wire    [9:0] tbi_rx_d_lvds_2;
reg     [9:0] tbi_rx_d_flip_2;
reg     [9:0] tbi_tx_d_flip_2;
wire    [9:0] tbi_rx_d_2;
wire    [9:0] tbi_tx_d_2;
wire    [9:0] tbi_rx_d_lvds_3;
reg     [9:0] tbi_rx_d_flip_3;
reg     [9:0] tbi_tx_d_flip_3;
wire    [9:0] tbi_rx_d_3;
wire    [9:0] tbi_tx_d_3;
wire    [9:0] tbi_rx_d_lvds_4;
reg     [9:0] tbi_rx_d_flip_4;
reg     [9:0] tbi_tx_d_flip_4;
wire    [9:0] tbi_rx_d_4;
wire    [9:0] tbi_tx_d_4;
wire    [9:0] tbi_rx_d_lvds_5;
reg     [9:0] tbi_rx_d_flip_5;
reg     [9:0] tbi_tx_d_flip_5;
wire    [9:0] tbi_rx_d_5;
wire    [9:0] tbi_tx_d_5;
wire    [9:0] tbi_rx_d_lvds_6;
reg     [9:0] tbi_rx_d_flip_6;
reg     [9:0] tbi_tx_d_flip_6;
wire    [9:0] tbi_rx_d_6;
wire    [9:0] tbi_tx_d_6;
wire    [9:0] tbi_rx_d_lvds_7;
reg     [9:0] tbi_rx_d_flip_7;
reg     [9:0] tbi_tx_d_flip_7;
wire    [9:0] tbi_rx_d_7;
wire    [9:0] tbi_tx_d_7;
wire    [9:0] tbi_rx_d_lvds_8;
reg     [9:0] tbi_rx_d_flip_8;
reg     [9:0] tbi_tx_d_flip_8;
wire    [9:0] tbi_rx_d_8;
wire    [9:0] tbi_tx_d_8;
wire    [9:0] tbi_rx_d_lvds_9;
reg     [9:0] tbi_rx_d_flip_9;
reg     [9:0] tbi_tx_d_flip_9;
wire    [9:0] tbi_rx_d_9;
wire    [9:0] tbi_tx_d_9;
wire    [9:0] tbi_rx_d_lvds_10;
reg     [9:0] tbi_rx_d_flip_10;
reg     [9:0] tbi_tx_d_flip_10;
wire    [9:0] tbi_rx_d_10;
wire    [9:0] tbi_tx_d_10;
wire    [9:0] tbi_rx_d_lvds_11;
reg     [9:0] tbi_rx_d_flip_11;
reg     [9:0] tbi_tx_d_flip_11;
wire    [9:0] tbi_rx_d_11;
wire    [9:0] tbi_tx_d_11;
wire    [9:0] tbi_rx_d_lvds_12;
reg     [9:0] tbi_rx_d_flip_12;
reg     [9:0] tbi_tx_d_flip_12;
wire    [9:0] tbi_rx_d_12;
wire    [9:0] tbi_tx_d_12;
wire    [9:0] tbi_rx_d_lvds_13;
reg     [9:0] tbi_rx_d_flip_13;
reg     [9:0] tbi_tx_d_flip_13;
wire    [9:0] tbi_rx_d_13;
wire    [9:0] tbi_tx_d_13;
wire    [9:0] tbi_rx_d_lvds_14;
reg     [9:0] tbi_rx_d_flip_14;
reg     [9:0] tbi_tx_d_flip_14;
wire    [9:0] tbi_rx_d_14;
wire    [9:0] tbi_tx_d_14;
wire    [9:0] tbi_rx_d_lvds_15;
reg     [9:0] tbi_rx_d_flip_15;
reg     [9:0] tbi_tx_d_flip_15;
wire    [9:0] tbi_rx_d_15;
wire    [9:0] tbi_tx_d_15;
wire    [9:0] tbi_rx_d_lvds_16;
reg     [9:0] tbi_rx_d_flip_16;
reg     [9:0] tbi_tx_d_flip_16;
wire    [9:0] tbi_rx_d_16;
wire    [9:0] tbi_tx_d_16;
wire    [9:0] tbi_rx_d_lvds_17;
reg     [9:0] tbi_rx_d_flip_17;
reg     [9:0] tbi_tx_d_flip_17;
wire    [9:0] tbi_rx_d_17;
wire    [9:0] tbi_tx_d_17;
wire    [9:0] tbi_rx_d_lvds_18;
reg     [9:0] tbi_rx_d_flip_18;
reg     [9:0] tbi_tx_d_flip_18;
wire    [9:0] tbi_rx_d_18;
wire    [9:0] tbi_tx_d_18;
wire    [9:0] tbi_rx_d_lvds_19;
reg     [9:0] tbi_rx_d_flip_19;
reg     [9:0] tbi_tx_d_flip_19;
wire    [9:0] tbi_rx_d_19;
wire    [9:0] tbi_tx_d_19;
wire    [9:0] tbi_rx_d_lvds_20;
reg     [9:0] tbi_rx_d_flip_20;
reg     [9:0] tbi_tx_d_flip_20;
wire    [9:0] tbi_rx_d_20;
wire    [9:0] tbi_tx_d_20;
wire    [9:0] tbi_rx_d_lvds_21;
reg     [9:0] tbi_rx_d_flip_21;
reg     [9:0] tbi_tx_d_flip_21;
wire    [9:0] tbi_rx_d_21;
wire    [9:0] tbi_tx_d_21;
wire    [9:0] tbi_rx_d_lvds_22;
reg     [9:0] tbi_rx_d_flip_22;
reg     [9:0] tbi_tx_d_flip_22;
wire    [9:0] tbi_rx_d_22;
wire    [9:0] tbi_tx_d_22;
wire    [9:0] tbi_rx_d_lvds_23;
reg     [9:0] tbi_rx_d_flip_23;
reg     [9:0] tbi_tx_d_flip_23;
wire    [9:0] tbi_rx_d_23;
wire    [9:0] tbi_tx_d_23;

wire    sd_loopback_0;
wire    sd_loopback_1;
wire    sd_loopback_2;
wire    sd_loopback_3;
wire    sd_loopback_4;
wire    sd_loopback_5;
wire    sd_loopback_6;
wire    sd_loopback_7;
wire    sd_loopback_8;
wire    sd_loopback_9;
wire    sd_loopback_10;
wire    sd_loopback_11;
wire    sd_loopback_12;
wire    sd_loopback_13;
wire    sd_loopback_14;
wire    sd_loopback_15;
wire    sd_loopback_16;
wire    sd_loopback_17;
wire    sd_loopback_18;
wire    sd_loopback_19;
wire    sd_loopback_20;
wire    sd_loopback_21;
wire    sd_loopback_22;
wire    sd_loopback_23;

wire    tbi_rx_clk_0;
wire    tbi_rx_clk_1;
wire    tbi_rx_clk_2;
wire    tbi_rx_clk_3;
wire    tbi_rx_clk_4;
wire    tbi_rx_clk_5;
wire    tbi_rx_clk_6;
wire    tbi_rx_clk_7;
wire    tbi_rx_clk_8;
wire    tbi_rx_clk_9;
wire    tbi_rx_clk_10;
wire    tbi_rx_clk_11;
wire    tbi_rx_clk_12;
wire    tbi_rx_clk_13;
wire    tbi_rx_clk_14;
wire    tbi_rx_clk_15;
wire    tbi_rx_clk_16;
wire    tbi_rx_clk_17;
wire    tbi_rx_clk_18;
wire    tbi_rx_clk_19;
wire    tbi_rx_clk_20;
wire    tbi_rx_clk_21;
wire    tbi_rx_clk_22;
wire    tbi_rx_clk_23;

wire    tbi_tx_clk_0;
wire    tbi_tx_clk_1;
wire    tbi_tx_clk_2;
wire    tbi_tx_clk_3;
wire    tbi_tx_clk_4;
wire    tbi_tx_clk_5;
wire    tbi_tx_clk_6;
wire    tbi_tx_clk_7;
wire    tbi_tx_clk_8;
wire    tbi_tx_clk_9;
wire    tbi_tx_clk_10;
wire    tbi_tx_clk_11;
wire    tbi_tx_clk_12;
wire    tbi_tx_clk_13;
wire    tbi_tx_clk_14;
wire    tbi_tx_clk_15;
wire    tbi_tx_clk_16;
wire    tbi_tx_clk_17;
wire    tbi_tx_clk_18;
wire    tbi_tx_clk_19;
wire    tbi_tx_clk_20;
wire    tbi_tx_clk_21;
wire    tbi_tx_clk_22;
wire    tbi_tx_clk_23;

wire    reset_ref_clk_int;

wire    reset_tbi_rx_clk_0_int;
wire    reset_tbi_rx_clk_1_int;
wire    reset_tbi_rx_clk_2_int;
wire    reset_tbi_rx_clk_3_int;
wire    reset_tbi_rx_clk_4_int;
wire    reset_tbi_rx_clk_5_int;
wire    reset_tbi_rx_clk_6_int;
wire    reset_tbi_rx_clk_7_int;
wire    reset_tbi_rx_clk_8_int;
wire    reset_tbi_rx_clk_9_int;
wire    reset_tbi_rx_clk_10_int;
wire    reset_tbi_rx_clk_11_int;
wire    reset_tbi_rx_clk_12_int;
wire    reset_tbi_rx_clk_13_int;
wire    reset_tbi_rx_clk_14_int;
wire    reset_tbi_rx_clk_15_int;
wire    reset_tbi_rx_clk_16_int;
wire    reset_tbi_rx_clk_17_int;
wire    reset_tbi_rx_clk_18_int;
wire    reset_tbi_rx_clk_19_int;
wire    reset_tbi_rx_clk_20_int;
wire    reset_tbi_rx_clk_21_int;
wire    reset_tbi_rx_clk_22_int;
wire    reset_tbi_rx_clk_23_int;

wire pll_areset_0,rx_cda_reset_0,rx_channel_data_align_0,rx_locked_0,rx_reset_0;
wire pll_areset_1,rx_cda_reset_1,rx_channel_data_align_1,rx_locked_1,rx_reset_1;
wire pll_areset_2,rx_cda_reset_2,rx_channel_data_align_2,rx_locked_2,rx_reset_2;
wire pll_areset_3,rx_cda_reset_3,rx_channel_data_align_3,rx_locked_3,rx_reset_3;
wire pll_areset_4,rx_cda_reset_4,rx_channel_data_align_4,rx_locked_4,rx_reset_4;
wire pll_areset_5,rx_cda_reset_5,rx_channel_data_align_5,rx_locked_5,rx_reset_5;
wire pll_areset_6,rx_cda_reset_6,rx_channel_data_align_6,rx_locked_6,rx_reset_6;
wire pll_areset_7,rx_cda_reset_7,rx_channel_data_align_7,rx_locked_7,rx_reset_7;
wire pll_areset_8,rx_cda_reset_8,rx_channel_data_align_8,rx_locked_8,rx_reset_8;
wire pll_areset_9,rx_cda_reset_9,rx_channel_data_align_9,rx_locked_9,rx_reset_9;
wire pll_areset_10,rx_cda_reset_10,rx_channel_data_align_10,rx_locked_10,rx_reset_10;
wire pll_areset_11,rx_cda_reset_11,rx_channel_data_align_11,rx_locked_11,rx_reset_11;
wire pll_areset_12,rx_cda_reset_12,rx_channel_data_align_12,rx_locked_12,rx_reset_12;
wire pll_areset_13,rx_cda_reset_13,rx_channel_data_align_13,rx_locked_13,rx_reset_13;
wire pll_areset_14,rx_cda_reset_14,rx_channel_data_align_14,rx_locked_14,rx_reset_14;
wire pll_areset_15,rx_cda_reset_15,rx_channel_data_align_15,rx_locked_15,rx_reset_15;
wire pll_areset_16,rx_cda_reset_16,rx_channel_data_align_16,rx_locked_16,rx_reset_16;
wire pll_areset_17,rx_cda_reset_17,rx_channel_data_align_17,rx_locked_17,rx_reset_17;
wire pll_areset_18,rx_cda_reset_18,rx_channel_data_align_18,rx_locked_18,rx_reset_18;
wire pll_areset_19,rx_cda_reset_19,rx_channel_data_align_19,rx_locked_19,rx_reset_19;
wire pll_areset_20,rx_cda_reset_20,rx_channel_data_align_20,rx_locked_20,rx_reset_20;
wire pll_areset_21,rx_cda_reset_21,rx_channel_data_align_21,rx_locked_21,rx_reset_21;
wire pll_areset_22,rx_cda_reset_22,rx_channel_data_align_22,rx_locked_22,rx_reset_22;
wire pll_areset_23,rx_cda_reset_23,rx_channel_data_align_23,rx_locked_23,rx_reset_23;

assign rx_recovclkout_0 = tbi_rx_clk_0;
assign rx_recovclkout_1 = tbi_rx_clk_1;
assign rx_recovclkout_2 = tbi_rx_clk_2;
assign rx_recovclkout_3 = tbi_rx_clk_3;
assign rx_recovclkout_4 = tbi_rx_clk_4;
assign rx_recovclkout_5 = tbi_rx_clk_5;
assign rx_recovclkout_6 = tbi_rx_clk_6;
assign rx_recovclkout_7 = tbi_rx_clk_7;
assign rx_recovclkout_8 = tbi_rx_clk_8;
assign rx_recovclkout_9 = tbi_rx_clk_9;
assign rx_recovclkout_10 = tbi_rx_clk_10;
assign rx_recovclkout_11 = tbi_rx_clk_11;
assign rx_recovclkout_12 = tbi_rx_clk_12;
assign rx_recovclkout_13 = tbi_rx_clk_13;
assign rx_recovclkout_14 = tbi_rx_clk_14;
assign rx_recovclkout_15 = tbi_rx_clk_15;
assign rx_recovclkout_16 = tbi_rx_clk_16;
assign rx_recovclkout_17 = tbi_rx_clk_17;
assign rx_recovclkout_18 = tbi_rx_clk_18;
assign rx_recovclkout_19 = tbi_rx_clk_19;
assign rx_recovclkout_20 = tbi_rx_clk_20;
assign rx_recovclkout_21 = tbi_rx_clk_21;
assign rx_recovclkout_22 = tbi_rx_clk_22;
assign rx_recovclkout_23 = tbi_rx_clk_23;

    // Instantiation of the MAC_PCS core that connects to a PMA
    // --------------------------------------------------------

    altera_tse_top_multi_mac_pcs U_MULTI_MAC_PCS(

        .reset(reset),                            //INPUT  : ASYNCHRONOUS RESET - clk DOMAIN
        .clk(clk),                                //INPUT  : CLOCK
        .read(read),                              //INPUT  : REGISTER READ TRANSACTION
        .ref_clk(ref_clk),                        //INPUT  : REFERENCE CLOCK 
        .write(write),                            //INPUT  : REGISTER WRITE TRANSACTION
        .address(address),                        //INPUT  : REGISTER ADDRESS
        .writedata(writedata),                    //INPUT  : REGISTER WRITE DATA
        .readdata(readdata),                      //OUTPUT : REGISTER READ DATA
        .waitrequest(waitrequest),                //OUTPUT : TRANSACTION BUSY, ACTIVE LOW
        .mdc(mdc),                                //OUTPUT : MDIO Clock 
        .mdio_out(mdio_out),                      //OUTPUT : Outgoing MDIO DATA
        .mdio_in(mdio_in),                        //INPUT  : Incoming MDIO DATA       
        .mdio_oen(mdio_oen),                      //OUTPUT : MDIO Output Enable
        .mac_rx_clk(mac_rx_clk),                  //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk(mac_tx_clk),                  //OUTPUT : Av-ST Tx Clock
        .rx_afull_clk(rx_afull_clk),              //INPUT  : AFull Status Clock
	    .rx_afull_data(rx_afull_data),            //INPUT  : AFull Status Data
	    .rx_afull_valid(rx_afull_valid),          //INPUT  : AFull Status Valid
	    .rx_afull_channel(rx_afull_channel),      //INPUT  : AFull Status Channel

         // Channel 0 
            
        .tbi_rx_clk_0(tbi_rx_clk_0),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_0(tbi_tx_clk_0),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_0(tbi_rx_d_0),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_0(tbi_tx_d_0),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_0(sd_loopback_0),            //OUTPUT : SERDES Loopback Enable
        .powerdown_0(pcs_pwrdn_out_sig[0]),       //OUTPUT : Powerdown Enable
        .led_col_0(led_col_0),                    //OUTPUT : Collision Indication
        .led_an_0(led_an_0),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_0(led_char_err_0),          //OUTPUT : Character error
        .led_disp_err_0(led_disp_err_0),          //OUTPUT : Disparity error
        .led_crs_0(led_crs_0),                    //OUTPUT : Carrier sense
        .led_link_0(led_link_0),                  //OUTPUT : Valid link    
        .mac_rx_clk_0(mac_rx_clk_0),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_0(mac_tx_clk_0),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_0(data_rx_sop_0),            //OUTPUT : Start of Packet
        .data_rx_eop_0(data_rx_eop_0),            //OUTPUT : End of Packet
        .data_rx_data_0(data_rx_data_0),          //OUTPUT : Data from FIFO
        .data_rx_error_0(data_rx_error_0),        //OUTPUT : Receive packet error
        .data_rx_valid_0(data_rx_valid_0),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_0(data_rx_ready_0),        //OUTPUT : Data Receive Ready
        .pkt_class_data_0(pkt_class_data_0),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_0(pkt_class_valid_0),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_0(data_tx_error_0),        //INPUT  : Status
        .data_tx_data_0(data_tx_data_0),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_0(data_tx_valid_0),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_0(data_tx_sop_0),            //INPUT  : Start of Packet
        .data_tx_eop_0(data_tx_eop_0),            //INPUT  : End of Packet
        .data_tx_ready_0(data_tx_ready_0),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_0(tx_ff_uflow_0),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_0(tx_crc_fwd_0),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_0(xoff_gen_0),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_0(xon_gen_0),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_0(magic_sleep_n_0),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_0(magic_wakeup_0),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 1 
            
        .tbi_rx_clk_1(tbi_rx_clk_1),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_1(tbi_tx_clk_1),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_1(tbi_rx_d_1),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_1(tbi_tx_d_1),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_1(sd_loopback_1),            //OUTPUT : SERDES Loopback Enable
        .powerdown_1(pcs_pwrdn_out_sig[1]),       //OUTPUT : Powerdown Enable
        .led_col_1(led_col_1),                    //OUTPUT : Collision Indication
        .led_an_1(led_an_1),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_1(led_char_err_1),          //OUTPUT : Character error
        .led_disp_err_1(led_disp_err_1),          //OUTPUT : Disparity error
        .led_crs_1(led_crs_1),                    //OUTPUT : Carrier sense
        .led_link_1(led_link_1),                  //OUTPUT : Valid link    
        .mac_rx_clk_1(mac_rx_clk_1),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_1(mac_tx_clk_1),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_1(data_rx_sop_1),            //OUTPUT : Start of Packet
        .data_rx_eop_1(data_rx_eop_1),            //OUTPUT : End of Packet
        .data_rx_data_1(data_rx_data_1),          //OUTPUT : Data from FIFO
        .data_rx_error_1(data_rx_error_1),        //OUTPUT : Receive packet error
        .data_rx_valid_1(data_rx_valid_1),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_1(data_rx_ready_1),        //OUTPUT : Data Receive Ready
        .pkt_class_data_1(pkt_class_data_1),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_1(pkt_class_valid_1),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_1(data_tx_error_1),        //INPUT  : Status
        .data_tx_data_1(data_tx_data_1),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_1(data_tx_valid_1),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_1(data_tx_sop_1),            //INPUT  : Start of Packet
        .data_tx_eop_1(data_tx_eop_1),            //INPUT  : End of Packet
        .data_tx_ready_1(data_tx_ready_1),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_1(tx_ff_uflow_1),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_1(tx_crc_fwd_1),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_1(xoff_gen_1),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_1(xon_gen_1),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_1(magic_sleep_n_1),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_1(magic_wakeup_1),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 2 
            
        .tbi_rx_clk_2(tbi_rx_clk_2),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_2(tbi_tx_clk_2),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_2(tbi_rx_d_2),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_2(tbi_tx_d_2),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_2(sd_loopback_2),            //OUTPUT : SERDES Loopback Enable
        .powerdown_2(pcs_pwrdn_out_sig[2]),       //OUTPUT : Powerdown Enable
        .led_col_2(led_col_2),                    //OUTPUT : Collision Indication
        .led_an_2(led_an_2),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_2(led_char_err_2),          //OUTPUT : Character error
        .led_disp_err_2(led_disp_err_2),          //OUTPUT : Disparity error
        .led_crs_2(led_crs_2),                    //OUTPUT : Carrier sense
        .led_link_2(led_link_2),                  //OUTPUT : Valid link    
        .mac_rx_clk_2(mac_rx_clk_2),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_2(mac_tx_clk_2),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_2(data_rx_sop_2),            //OUTPUT : Start of Packet
        .data_rx_eop_2(data_rx_eop_2),            //OUTPUT : End of Packet
        .data_rx_data_2(data_rx_data_2),          //OUTPUT : Data from FIFO
        .data_rx_error_2(data_rx_error_2),        //OUTPUT : Receive packet error
        .data_rx_valid_2(data_rx_valid_2),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_2(data_rx_ready_2),        //OUTPUT : Data Receive Ready
        .pkt_class_data_2(pkt_class_data_2),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_2(pkt_class_valid_2),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_2(data_tx_error_2),        //INPUT  : Status
        .data_tx_data_2(data_tx_data_2),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_2(data_tx_valid_2),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_2(data_tx_sop_2),            //INPUT  : Start of Packet
        .data_tx_eop_2(data_tx_eop_2),            //INPUT  : End of Packet
        .data_tx_ready_2(data_tx_ready_2),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_2(tx_ff_uflow_2),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_2(tx_crc_fwd_2),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_2(xoff_gen_2),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_2(xon_gen_2),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_2(magic_sleep_n_2),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_2(magic_wakeup_2),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 3 
            
        .tbi_rx_clk_3(tbi_rx_clk_3),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_3(tbi_tx_clk_3),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_3(tbi_rx_d_3),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_3(tbi_tx_d_3),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_3(sd_loopback_3),            //OUTPUT : SERDES Loopback Enable
        .powerdown_3(pcs_pwrdn_out_sig[3]),       //OUTPUT : Powerdown Enable
        .led_col_3(led_col_3),                    //OUTPUT : Collision Indication
        .led_an_3(led_an_3),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_3(led_char_err_3),          //OUTPUT : Character error
        .led_disp_err_3(led_disp_err_3),          //OUTPUT : Disparity error
        .led_crs_3(led_crs_3),                    //OUTPUT : Carrier sense
        .led_link_3(led_link_3),                  //OUTPUT : Valid link    
        .mac_rx_clk_3(mac_rx_clk_3),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_3(mac_tx_clk_3),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_3(data_rx_sop_3),            //OUTPUT : Start of Packet
        .data_rx_eop_3(data_rx_eop_3),            //OUTPUT : End of Packet
        .data_rx_data_3(data_rx_data_3),          //OUTPUT : Data from FIFO
        .data_rx_error_3(data_rx_error_3),        //OUTPUT : Receive packet error
        .data_rx_valid_3(data_rx_valid_3),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_3(data_rx_ready_3),        //OUTPUT : Data Receive Ready
        .pkt_class_data_3(pkt_class_data_3),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_3(pkt_class_valid_3),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_3(data_tx_error_3),        //INPUT  : Status
        .data_tx_data_3(data_tx_data_3),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_3(data_tx_valid_3),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_3(data_tx_sop_3),            //INPUT  : Start of Packet
        .data_tx_eop_3(data_tx_eop_3),            //INPUT  : End of Packet
        .data_tx_ready_3(data_tx_ready_3),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_3(tx_ff_uflow_3),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_3(tx_crc_fwd_3),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_3(xoff_gen_3),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_3(xon_gen_3),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_3(magic_sleep_n_3),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_3(magic_wakeup_3),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 4 
            
        .tbi_rx_clk_4(tbi_rx_clk_4),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_4(tbi_tx_clk_4),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_4(tbi_rx_d_4),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_4(tbi_tx_d_4),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_4(sd_loopback_4),            //OUTPUT : SERDES Loopback Enable
        .powerdown_4(pcs_pwrdn_out_sig[4]),       //OUTPUT : Powerdown Enable
        .led_col_4(led_col_4),                    //OUTPUT : Collision Indication
        .led_an_4(led_an_4),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_4(led_char_err_4),          //OUTPUT : Character error
        .led_disp_err_4(led_disp_err_4),          //OUTPUT : Disparity error
        .led_crs_4(led_crs_4),                    //OUTPUT : Carrier sense
        .led_link_4(led_link_4),                  //OUTPUT : Valid link    
        .mac_rx_clk_4(mac_rx_clk_4),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_4(mac_tx_clk_4),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_4(data_rx_sop_4),            //OUTPUT : Start of Packet
        .data_rx_eop_4(data_rx_eop_4),            //OUTPUT : End of Packet
        .data_rx_data_4(data_rx_data_4),          //OUTPUT : Data from FIFO
        .data_rx_error_4(data_rx_error_4),        //OUTPUT : Receive packet error
        .data_rx_valid_4(data_rx_valid_4),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_4(data_rx_ready_4),        //OUTPUT : Data Receive Ready
        .pkt_class_data_4(pkt_class_data_4),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_4(pkt_class_valid_4),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_4(data_tx_error_4),        //INPUT  : Status
        .data_tx_data_4(data_tx_data_4),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_4(data_tx_valid_4),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_4(data_tx_sop_4),            //INPUT  : Start of Packet
        .data_tx_eop_4(data_tx_eop_4),            //INPUT  : End of Packet
        .data_tx_ready_4(data_tx_ready_4),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_4(tx_ff_uflow_4),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_4(tx_crc_fwd_4),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_4(xoff_gen_4),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_4(xon_gen_4),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_4(magic_sleep_n_4),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_4(magic_wakeup_4),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 5 
            
        .tbi_rx_clk_5(tbi_rx_clk_5),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_5(tbi_tx_clk_5),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_5(tbi_rx_d_5),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_5(tbi_tx_d_5),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_5(sd_loopback_5),            //OUTPUT : SERDES Loopback Enable
        .powerdown_5(pcs_pwrdn_out_sig[5]),       //OUTPUT : Powerdown Enable
        .led_col_5(led_col_5),                    //OUTPUT : Collision Indication
        .led_an_5(led_an_5),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_5(led_char_err_5),          //OUTPUT : Character error
        .led_disp_err_5(led_disp_err_5),          //OUTPUT : Disparity error
        .led_crs_5(led_crs_5),                    //OUTPUT : Carrier sense
        .led_link_5(led_link_5),                  //OUTPUT : Valid link    
        .mac_rx_clk_5(mac_rx_clk_5),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_5(mac_tx_clk_5),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_5(data_rx_sop_5),            //OUTPUT : Start of Packet
        .data_rx_eop_5(data_rx_eop_5),            //OUTPUT : End of Packet
        .data_rx_data_5(data_rx_data_5),          //OUTPUT : Data from FIFO
        .data_rx_error_5(data_rx_error_5),        //OUTPUT : Receive packet error
        .data_rx_valid_5(data_rx_valid_5),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_5(data_rx_ready_5),        //OUTPUT : Data Receive Ready
        .pkt_class_data_5(pkt_class_data_5),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_5(pkt_class_valid_5),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_5(data_tx_error_5),        //INPUT  : Status
        .data_tx_data_5(data_tx_data_5),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_5(data_tx_valid_5),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_5(data_tx_sop_5),            //INPUT  : Start of Packet
        .data_tx_eop_5(data_tx_eop_5),            //INPUT  : End of Packet
        .data_tx_ready_5(data_tx_ready_5),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_5(tx_ff_uflow_5),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_5(tx_crc_fwd_5),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_5(xoff_gen_5),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_5(xon_gen_5),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_5(magic_sleep_n_5),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_5(magic_wakeup_5),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 6 
            
        .tbi_rx_clk_6(tbi_rx_clk_6),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_6(tbi_tx_clk_6),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_6(tbi_rx_d_6),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_6(tbi_tx_d_6),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_6(sd_loopback_6),            //OUTPUT : SERDES Loopback Enable
        .powerdown_6(pcs_pwrdn_out_sig[6]),       //OUTPUT : Powerdown Enable
        .led_col_6(led_col_6),                    //OUTPUT : Collision Indication
        .led_an_6(led_an_6),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_6(led_char_err_6),          //OUTPUT : Character error
        .led_disp_err_6(led_disp_err_6),          //OUTPUT : Disparity error
        .led_crs_6(led_crs_6),                    //OUTPUT : Carrier sense
        .led_link_6(led_link_6),                  //OUTPUT : Valid link    
        .mac_rx_clk_6(mac_rx_clk_6),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_6(mac_tx_clk_6),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_6(data_rx_sop_6),            //OUTPUT : Start of Packet
        .data_rx_eop_6(data_rx_eop_6),            //OUTPUT : End of Packet
        .data_rx_data_6(data_rx_data_6),          //OUTPUT : Data from FIFO
        .data_rx_error_6(data_rx_error_6),        //OUTPUT : Receive packet error
        .data_rx_valid_6(data_rx_valid_6),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_6(data_rx_ready_6),        //OUTPUT : Data Receive Ready
        .pkt_class_data_6(pkt_class_data_6),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_6(pkt_class_valid_6),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_6(data_tx_error_6),        //INPUT  : Status
        .data_tx_data_6(data_tx_data_6),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_6(data_tx_valid_6),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_6(data_tx_sop_6),            //INPUT  : Start of Packet
        .data_tx_eop_6(data_tx_eop_6),            //INPUT  : End of Packet
        .data_tx_ready_6(data_tx_ready_6),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_6(tx_ff_uflow_6),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_6(tx_crc_fwd_6),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_6(xoff_gen_6),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_6(xon_gen_6),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_6(magic_sleep_n_6),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_6(magic_wakeup_6),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 7 
            
        .tbi_rx_clk_7(tbi_rx_clk_7),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_7(tbi_tx_clk_7),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_7(tbi_rx_d_7),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_7(tbi_tx_d_7),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_7(sd_loopback_7),            //OUTPUT : SERDES Loopback Enable
        .powerdown_7(pcs_pwrdn_out_sig[7]),       //OUTPUT : Powerdown Enable
        .led_col_7(led_col_7),                    //OUTPUT : Collision Indication
        .led_an_7(led_an_7),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_7(led_char_err_7),          //OUTPUT : Character error
        .led_disp_err_7(led_disp_err_7),          //OUTPUT : Disparity error
        .led_crs_7(led_crs_7),                    //OUTPUT : Carrier sense
        .led_link_7(led_link_7),                  //OUTPUT : Valid link    
        .mac_rx_clk_7(mac_rx_clk_7),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_7(mac_tx_clk_7),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_7(data_rx_sop_7),            //OUTPUT : Start of Packet
        .data_rx_eop_7(data_rx_eop_7),            //OUTPUT : End of Packet
        .data_rx_data_7(data_rx_data_7),          //OUTPUT : Data from FIFO
        .data_rx_error_7(data_rx_error_7),        //OUTPUT : Receive packet error
        .data_rx_valid_7(data_rx_valid_7),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_7(data_rx_ready_7),        //OUTPUT : Data Receive Ready
        .pkt_class_data_7(pkt_class_data_7),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_7(pkt_class_valid_7),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_7(data_tx_error_7),        //INPUT  : Status
        .data_tx_data_7(data_tx_data_7),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_7(data_tx_valid_7),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_7(data_tx_sop_7),            //INPUT  : Start of Packet
        .data_tx_eop_7(data_tx_eop_7),            //INPUT  : End of Packet
        .data_tx_ready_7(data_tx_ready_7),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_7(tx_ff_uflow_7),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_7(tx_crc_fwd_7),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_7(xoff_gen_7),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_7(xon_gen_7),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_7(magic_sleep_n_7),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_7(magic_wakeup_7),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 8 
            
        .tbi_rx_clk_8(tbi_rx_clk_8),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_8(tbi_tx_clk_8),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_8(tbi_rx_d_8),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_8(tbi_tx_d_8),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_8(sd_loopback_8),            //OUTPUT : SERDES Loopback Enable
        .powerdown_8(pcs_pwrdn_out_sig[8]),       //OUTPUT : Powerdown Enable
        .led_col_8(led_col_8),                    //OUTPUT : Collision Indication
        .led_an_8(led_an_8),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_8(led_char_err_8),          //OUTPUT : Character error
        .led_disp_err_8(led_disp_err_8),          //OUTPUT : Disparity error
        .led_crs_8(led_crs_8),                    //OUTPUT : Carrier sense
        .led_link_8(led_link_8),                  //OUTPUT : Valid link    
        .mac_rx_clk_8(mac_rx_clk_8),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_8(mac_tx_clk_8),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_8(data_rx_sop_8),            //OUTPUT : Start of Packet
        .data_rx_eop_8(data_rx_eop_8),            //OUTPUT : End of Packet
        .data_rx_data_8(data_rx_data_8),          //OUTPUT : Data from FIFO
        .data_rx_error_8(data_rx_error_8),        //OUTPUT : Receive packet error
        .data_rx_valid_8(data_rx_valid_8),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_8(data_rx_ready_8),        //OUTPUT : Data Receive Ready
        .pkt_class_data_8(pkt_class_data_8),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_8(pkt_class_valid_8),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_8(data_tx_error_8),        //INPUT  : Status
        .data_tx_data_8(data_tx_data_8),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_8(data_tx_valid_8),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_8(data_tx_sop_8),            //INPUT  : Start of Packet
        .data_tx_eop_8(data_tx_eop_8),            //INPUT  : End of Packet
        .data_tx_ready_8(data_tx_ready_8),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_8(tx_ff_uflow_8),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_8(tx_crc_fwd_8),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_8(xoff_gen_8),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_8(xon_gen_8),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_8(magic_sleep_n_8),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_8(magic_wakeup_8),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 9 
            
        .tbi_rx_clk_9(tbi_rx_clk_9),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_9(tbi_tx_clk_9),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_9(tbi_rx_d_9),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_9(tbi_tx_d_9),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_9(sd_loopback_9),            //OUTPUT : SERDES Loopback Enable
        .powerdown_9(pcs_pwrdn_out_sig[9]),       //OUTPUT : Powerdown Enable
        .led_col_9(led_col_9),                    //OUTPUT : Collision Indication
        .led_an_9(led_an_9),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_9(led_char_err_9),          //OUTPUT : Character error
        .led_disp_err_9(led_disp_err_9),          //OUTPUT : Disparity error
        .led_crs_9(led_crs_9),                    //OUTPUT : Carrier sense
        .led_link_9(led_link_9),                  //OUTPUT : Valid link    
        .mac_rx_clk_9(mac_rx_clk_9),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_9(mac_tx_clk_9),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_9(data_rx_sop_9),            //OUTPUT : Start of Packet
        .data_rx_eop_9(data_rx_eop_9),            //OUTPUT : End of Packet
        .data_rx_data_9(data_rx_data_9),          //OUTPUT : Data from FIFO
        .data_rx_error_9(data_rx_error_9),        //OUTPUT : Receive packet error
        .data_rx_valid_9(data_rx_valid_9),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_9(data_rx_ready_9),        //OUTPUT : Data Receive Ready
        .pkt_class_data_9(pkt_class_data_9),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_9(pkt_class_valid_9),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_9(data_tx_error_9),        //INPUT  : Status
        .data_tx_data_9(data_tx_data_9),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_9(data_tx_valid_9),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_9(data_tx_sop_9),            //INPUT  : Start of Packet
        .data_tx_eop_9(data_tx_eop_9),            //INPUT  : End of Packet
        .data_tx_ready_9(data_tx_ready_9),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_9(tx_ff_uflow_9),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_9(tx_crc_fwd_9),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_9(xoff_gen_9),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_9(xon_gen_9),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_9(magic_sleep_n_9),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_9(magic_wakeup_9),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 10 
            
        .tbi_rx_clk_10(tbi_rx_clk_10),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_10(tbi_tx_clk_10),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_10(tbi_rx_d_10),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_10(tbi_tx_d_10),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_10(sd_loopback_10),            //OUTPUT : SERDES Loopback Enable
        .powerdown_10(pcs_pwrdn_out_sig[10]),       //OUTPUT : Powerdown Enable
        .led_col_10(led_col_10),                    //OUTPUT : Collision Indication
        .led_an_10(led_an_10),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_10(led_char_err_10),          //OUTPUT : Character error
        .led_disp_err_10(led_disp_err_10),          //OUTPUT : Disparity error
        .led_crs_10(led_crs_10),                    //OUTPUT : Carrier sense
        .led_link_10(led_link_10),                  //OUTPUT : Valid link    
        .mac_rx_clk_10(mac_rx_clk_10),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_10(mac_tx_clk_10),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_10(data_rx_sop_10),            //OUTPUT : Start of Packet
        .data_rx_eop_10(data_rx_eop_10),            //OUTPUT : End of Packet
        .data_rx_data_10(data_rx_data_10),          //OUTPUT : Data from FIFO
        .data_rx_error_10(data_rx_error_10),        //OUTPUT : Receive packet error
        .data_rx_valid_10(data_rx_valid_10),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_10(data_rx_ready_10),        //OUTPUT : Data Receive Ready
        .pkt_class_data_10(pkt_class_data_10),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_10(pkt_class_valid_10),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_10(data_tx_error_10),        //INPUT  : Status
        .data_tx_data_10(data_tx_data_10),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_10(data_tx_valid_10),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_10(data_tx_sop_10),            //INPUT  : Start of Packet
        .data_tx_eop_10(data_tx_eop_10),            //INPUT  : End of Packet
        .data_tx_ready_10(data_tx_ready_10),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_10(tx_ff_uflow_10),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_10(tx_crc_fwd_10),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_10(xoff_gen_10),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_10(xon_gen_10),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_10(magic_sleep_n_10),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_10(magic_wakeup_10),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 11 
            
        .tbi_rx_clk_11(tbi_rx_clk_11),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_11(tbi_tx_clk_11),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_11(tbi_rx_d_11),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_11(tbi_tx_d_11),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_11(sd_loopback_11),            //OUTPUT : SERDES Loopback Enable
        .powerdown_11(pcs_pwrdn_out_sig[11]),       //OUTPUT : Powerdown Enable
        .led_col_11(led_col_11),                    //OUTPUT : Collision Indication
        .led_an_11(led_an_11),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_11(led_char_err_11),          //OUTPUT : Character error
        .led_disp_err_11(led_disp_err_11),          //OUTPUT : Disparity error
        .led_crs_11(led_crs_11),                    //OUTPUT : Carrier sense
        .led_link_11(led_link_11),                  //OUTPUT : Valid link    
        .mac_rx_clk_11(mac_rx_clk_11),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_11(mac_tx_clk_11),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_11(data_rx_sop_11),            //OUTPUT : Start of Packet
        .data_rx_eop_11(data_rx_eop_11),            //OUTPUT : End of Packet
        .data_rx_data_11(data_rx_data_11),          //OUTPUT : Data from FIFO
        .data_rx_error_11(data_rx_error_11),        //OUTPUT : Receive packet error
        .data_rx_valid_11(data_rx_valid_11),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_11(data_rx_ready_11),        //OUTPUT : Data Receive Ready
        .pkt_class_data_11(pkt_class_data_11),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_11(pkt_class_valid_11),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_11(data_tx_error_11),        //INPUT  : Status
        .data_tx_data_11(data_tx_data_11),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_11(data_tx_valid_11),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_11(data_tx_sop_11),            //INPUT  : Start of Packet
        .data_tx_eop_11(data_tx_eop_11),            //INPUT  : End of Packet
        .data_tx_ready_11(data_tx_ready_11),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_11(tx_ff_uflow_11),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_11(tx_crc_fwd_11),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_11(xoff_gen_11),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_11(xon_gen_11),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_11(magic_sleep_n_11),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_11(magic_wakeup_11),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 12 
            
        .tbi_rx_clk_12(tbi_rx_clk_12),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_12(tbi_tx_clk_12),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_12(tbi_rx_d_12),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_12(tbi_tx_d_12),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_12(sd_loopback_12),            //OUTPUT : SERDES Loopback Enable
        .powerdown_12(pcs_pwrdn_out_sig[12]),       //OUTPUT : Powerdown Enable
        .led_col_12(led_col_12),                    //OUTPUT : Collision Indication
        .led_an_12(led_an_12),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_12(led_char_err_12),          //OUTPUT : Character error
        .led_disp_err_12(led_disp_err_12),          //OUTPUT : Disparity error
        .led_crs_12(led_crs_12),                    //OUTPUT : Carrier sense
        .led_link_12(led_link_12),                  //OUTPUT : Valid link    
        .mac_rx_clk_12(mac_rx_clk_12),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_12(mac_tx_clk_12),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_12(data_rx_sop_12),            //OUTPUT : Start of Packet
        .data_rx_eop_12(data_rx_eop_12),            //OUTPUT : End of Packet
        .data_rx_data_12(data_rx_data_12),          //OUTPUT : Data from FIFO
        .data_rx_error_12(data_rx_error_12),        //OUTPUT : Receive packet error
        .data_rx_valid_12(data_rx_valid_12),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_12(data_rx_ready_12),        //OUTPUT : Data Receive Ready
        .pkt_class_data_12(pkt_class_data_12),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_12(pkt_class_valid_12),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_12(data_tx_error_12),        //INPUT  : Status
        .data_tx_data_12(data_tx_data_12),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_12(data_tx_valid_12),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_12(data_tx_sop_12),            //INPUT  : Start of Packet
        .data_tx_eop_12(data_tx_eop_12),            //INPUT  : End of Packet
        .data_tx_ready_12(data_tx_ready_12),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_12(tx_ff_uflow_12),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_12(tx_crc_fwd_12),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_12(xoff_gen_12),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_12(xon_gen_12),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_12(magic_sleep_n_12),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_12(magic_wakeup_12),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 13 
            
        .tbi_rx_clk_13(tbi_rx_clk_13),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_13(tbi_tx_clk_13),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_13(tbi_rx_d_13),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_13(tbi_tx_d_13),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_13(sd_loopback_13),            //OUTPUT : SERDES Loopback Enable
        .powerdown_13(pcs_pwrdn_out_sig[13]),       //OUTPUT : Powerdown Enable
        .led_col_13(led_col_13),                    //OUTPUT : Collision Indication
        .led_an_13(led_an_13),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_13(led_char_err_13),          //OUTPUT : Character error
        .led_disp_err_13(led_disp_err_13),          //OUTPUT : Disparity error
        .led_crs_13(led_crs_13),                    //OUTPUT : Carrier sense
        .led_link_13(led_link_13),                  //OUTPUT : Valid link    
        .mac_rx_clk_13(mac_rx_clk_13),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_13(mac_tx_clk_13),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_13(data_rx_sop_13),            //OUTPUT : Start of Packet
        .data_rx_eop_13(data_rx_eop_13),            //OUTPUT : End of Packet
        .data_rx_data_13(data_rx_data_13),          //OUTPUT : Data from FIFO
        .data_rx_error_13(data_rx_error_13),        //OUTPUT : Receive packet error
        .data_rx_valid_13(data_rx_valid_13),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_13(data_rx_ready_13),        //OUTPUT : Data Receive Ready
        .pkt_class_data_13(pkt_class_data_13),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_13(pkt_class_valid_13),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_13(data_tx_error_13),        //INPUT  : Status
        .data_tx_data_13(data_tx_data_13),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_13(data_tx_valid_13),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_13(data_tx_sop_13),            //INPUT  : Start of Packet
        .data_tx_eop_13(data_tx_eop_13),            //INPUT  : End of Packet
        .data_tx_ready_13(data_tx_ready_13),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_13(tx_ff_uflow_13),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_13(tx_crc_fwd_13),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_13(xoff_gen_13),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_13(xon_gen_13),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_13(magic_sleep_n_13),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_13(magic_wakeup_13),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 14 
            
        .tbi_rx_clk_14(tbi_rx_clk_14),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_14(tbi_tx_clk_14),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_14(tbi_rx_d_14),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_14(tbi_tx_d_14),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_14(sd_loopback_14),            //OUTPUT : SERDES Loopback Enable
        .powerdown_14(pcs_pwrdn_out_sig[14]),       //OUTPUT : Powerdown Enable
        .led_col_14(led_col_14),                    //OUTPUT : Collision Indication
        .led_an_14(led_an_14),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_14(led_char_err_14),          //OUTPUT : Character error
        .led_disp_err_14(led_disp_err_14),          //OUTPUT : Disparity error
        .led_crs_14(led_crs_14),                    //OUTPUT : Carrier sense
        .led_link_14(led_link_14),                  //OUTPUT : Valid link    
        .mac_rx_clk_14(mac_rx_clk_14),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_14(mac_tx_clk_14),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_14(data_rx_sop_14),            //OUTPUT : Start of Packet
        .data_rx_eop_14(data_rx_eop_14),            //OUTPUT : End of Packet
        .data_rx_data_14(data_rx_data_14),          //OUTPUT : Data from FIFO
        .data_rx_error_14(data_rx_error_14),        //OUTPUT : Receive packet error
        .data_rx_valid_14(data_rx_valid_14),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_14(data_rx_ready_14),        //OUTPUT : Data Receive Ready
        .pkt_class_data_14(pkt_class_data_14),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_14(pkt_class_valid_14),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_14(data_tx_error_14),        //INPUT  : Status
        .data_tx_data_14(data_tx_data_14),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_14(data_tx_valid_14),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_14(data_tx_sop_14),            //INPUT  : Start of Packet
        .data_tx_eop_14(data_tx_eop_14),            //INPUT  : End of Packet
        .data_tx_ready_14(data_tx_ready_14),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_14(tx_ff_uflow_14),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_14(tx_crc_fwd_14),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_14(xoff_gen_14),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_14(xon_gen_14),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_14(magic_sleep_n_14),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_14(magic_wakeup_14),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 15 
            
        .tbi_rx_clk_15(tbi_rx_clk_15),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_15(tbi_tx_clk_15),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_15(tbi_rx_d_15),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_15(tbi_tx_d_15),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_15(sd_loopback_15),            //OUTPUT : SERDES Loopback Enable
        .powerdown_15(pcs_pwrdn_out_sig[15]),       //OUTPUT : Powerdown Enable
        .led_col_15(led_col_15),                    //OUTPUT : Collision Indication
        .led_an_15(led_an_15),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_15(led_char_err_15),          //OUTPUT : Character error
        .led_disp_err_15(led_disp_err_15),          //OUTPUT : Disparity error
        .led_crs_15(led_crs_15),                    //OUTPUT : Carrier sense
        .led_link_15(led_link_15),                  //OUTPUT : Valid link    
        .mac_rx_clk_15(mac_rx_clk_15),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_15(mac_tx_clk_15),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_15(data_rx_sop_15),            //OUTPUT : Start of Packet
        .data_rx_eop_15(data_rx_eop_15),            //OUTPUT : End of Packet
        .data_rx_data_15(data_rx_data_15),          //OUTPUT : Data from FIFO
        .data_rx_error_15(data_rx_error_15),        //OUTPUT : Receive packet error
        .data_rx_valid_15(data_rx_valid_15),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_15(data_rx_ready_15),        //OUTPUT : Data Receive Ready
        .pkt_class_data_15(pkt_class_data_15),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_15(pkt_class_valid_15),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_15(data_tx_error_15),        //INPUT  : Status
        .data_tx_data_15(data_tx_data_15),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_15(data_tx_valid_15),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_15(data_tx_sop_15),            //INPUT  : Start of Packet
        .data_tx_eop_15(data_tx_eop_15),            //INPUT  : End of Packet
        .data_tx_ready_15(data_tx_ready_15),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_15(tx_ff_uflow_15),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_15(tx_crc_fwd_15),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_15(xoff_gen_15),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_15(xon_gen_15),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_15(magic_sleep_n_15),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_15(magic_wakeup_15),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 16 
            
        .tbi_rx_clk_16(tbi_rx_clk_16),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_16(tbi_tx_clk_16),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_16(tbi_rx_d_16),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_16(tbi_tx_d_16),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_16(sd_loopback_16),            //OUTPUT : SERDES Loopback Enable
        .powerdown_16(pcs_pwrdn_out_sig[16]),       //OUTPUT : Powerdown Enable
        .led_col_16(led_col_16),                    //OUTPUT : Collision Indication
        .led_an_16(led_an_16),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_16(led_char_err_16),          //OUTPUT : Character error
        .led_disp_err_16(led_disp_err_16),          //OUTPUT : Disparity error
        .led_crs_16(led_crs_16),                    //OUTPUT : Carrier sense
        .led_link_16(led_link_16),                  //OUTPUT : Valid link    
        .mac_rx_clk_16(mac_rx_clk_16),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_16(mac_tx_clk_16),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_16(data_rx_sop_16),            //OUTPUT : Start of Packet
        .data_rx_eop_16(data_rx_eop_16),            //OUTPUT : End of Packet
        .data_rx_data_16(data_rx_data_16),          //OUTPUT : Data from FIFO
        .data_rx_error_16(data_rx_error_16),        //OUTPUT : Receive packet error
        .data_rx_valid_16(data_rx_valid_16),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_16(data_rx_ready_16),        //OUTPUT : Data Receive Ready
        .pkt_class_data_16(pkt_class_data_16),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_16(pkt_class_valid_16),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_16(data_tx_error_16),        //INPUT  : Status
        .data_tx_data_16(data_tx_data_16),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_16(data_tx_valid_16),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_16(data_tx_sop_16),            //INPUT  : Start of Packet
        .data_tx_eop_16(data_tx_eop_16),            //INPUT  : End of Packet
        .data_tx_ready_16(data_tx_ready_16),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_16(tx_ff_uflow_16),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_16(tx_crc_fwd_16),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_16(xoff_gen_16),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_16(xon_gen_16),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_16(magic_sleep_n_16),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_16(magic_wakeup_16),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 17 
            
        .tbi_rx_clk_17(tbi_rx_clk_17),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_17(tbi_tx_clk_17),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_17(tbi_rx_d_17),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_17(tbi_tx_d_17),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_17(sd_loopback_17),            //OUTPUT : SERDES Loopback Enable
        .powerdown_17(pcs_pwrdn_out_sig[17]),       //OUTPUT : Powerdown Enable
        .led_col_17(led_col_17),                    //OUTPUT : Collision Indication
        .led_an_17(led_an_17),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_17(led_char_err_17),          //OUTPUT : Character error
        .led_disp_err_17(led_disp_err_17),          //OUTPUT : Disparity error
        .led_crs_17(led_crs_17),                    //OUTPUT : Carrier sense
        .led_link_17(led_link_17),                  //OUTPUT : Valid link    
        .mac_rx_clk_17(mac_rx_clk_17),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_17(mac_tx_clk_17),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_17(data_rx_sop_17),            //OUTPUT : Start of Packet
        .data_rx_eop_17(data_rx_eop_17),            //OUTPUT : End of Packet
        .data_rx_data_17(data_rx_data_17),          //OUTPUT : Data from FIFO
        .data_rx_error_17(data_rx_error_17),        //OUTPUT : Receive packet error
        .data_rx_valid_17(data_rx_valid_17),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_17(data_rx_ready_17),        //OUTPUT : Data Receive Ready
        .pkt_class_data_17(pkt_class_data_17),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_17(pkt_class_valid_17),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_17(data_tx_error_17),        //INPUT  : Status
        .data_tx_data_17(data_tx_data_17),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_17(data_tx_valid_17),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_17(data_tx_sop_17),            //INPUT  : Start of Packet
        .data_tx_eop_17(data_tx_eop_17),            //INPUT  : End of Packet
        .data_tx_ready_17(data_tx_ready_17),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_17(tx_ff_uflow_17),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_17(tx_crc_fwd_17),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_17(xoff_gen_17),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_17(xon_gen_17),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_17(magic_sleep_n_17),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_17(magic_wakeup_17),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 18 
            
        .tbi_rx_clk_18(tbi_rx_clk_18),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_18(tbi_tx_clk_18),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_18(tbi_rx_d_18),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_18(tbi_tx_d_18),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_18(sd_loopback_18),            //OUTPUT : SERDES Loopback Enable
        .powerdown_18(pcs_pwrdn_out_sig[18]),       //OUTPUT : Powerdown Enable
        .led_col_18(led_col_18),                    //OUTPUT : Collision Indication
        .led_an_18(led_an_18),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_18(led_char_err_18),          //OUTPUT : Character error
        .led_disp_err_18(led_disp_err_18),          //OUTPUT : Disparity error
        .led_crs_18(led_crs_18),                    //OUTPUT : Carrier sense
        .led_link_18(led_link_18),                  //OUTPUT : Valid link    
        .mac_rx_clk_18(mac_rx_clk_18),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_18(mac_tx_clk_18),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_18(data_rx_sop_18),            //OUTPUT : Start of Packet
        .data_rx_eop_18(data_rx_eop_18),            //OUTPUT : End of Packet
        .data_rx_data_18(data_rx_data_18),          //OUTPUT : Data from FIFO
        .data_rx_error_18(data_rx_error_18),        //OUTPUT : Receive packet error
        .data_rx_valid_18(data_rx_valid_18),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_18(data_rx_ready_18),        //OUTPUT : Data Receive Ready
        .pkt_class_data_18(pkt_class_data_18),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_18(pkt_class_valid_18),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_18(data_tx_error_18),        //INPUT  : Status
        .data_tx_data_18(data_tx_data_18),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_18(data_tx_valid_18),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_18(data_tx_sop_18),            //INPUT  : Start of Packet
        .data_tx_eop_18(data_tx_eop_18),            //INPUT  : End of Packet
        .data_tx_ready_18(data_tx_ready_18),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_18(tx_ff_uflow_18),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_18(tx_crc_fwd_18),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_18(xoff_gen_18),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_18(xon_gen_18),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_18(magic_sleep_n_18),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_18(magic_wakeup_18),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 19 
            
        .tbi_rx_clk_19(tbi_rx_clk_19),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_19(tbi_tx_clk_19),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_19(tbi_rx_d_19),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_19(tbi_tx_d_19),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_19(sd_loopback_19),            //OUTPUT : SERDES Loopback Enable
        .powerdown_19(pcs_pwrdn_out_sig[19]),       //OUTPUT : Powerdown Enable
        .led_col_19(led_col_19),                    //OUTPUT : Collision Indication
        .led_an_19(led_an_19),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_19(led_char_err_19),          //OUTPUT : Character error
        .led_disp_err_19(led_disp_err_19),          //OUTPUT : Disparity error
        .led_crs_19(led_crs_19),                    //OUTPUT : Carrier sense
        .led_link_19(led_link_19),                  //OUTPUT : Valid link    
        .mac_rx_clk_19(mac_rx_clk_19),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_19(mac_tx_clk_19),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_19(data_rx_sop_19),            //OUTPUT : Start of Packet
        .data_rx_eop_19(data_rx_eop_19),            //OUTPUT : End of Packet
        .data_rx_data_19(data_rx_data_19),          //OUTPUT : Data from FIFO
        .data_rx_error_19(data_rx_error_19),        //OUTPUT : Receive packet error
        .data_rx_valid_19(data_rx_valid_19),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_19(data_rx_ready_19),        //OUTPUT : Data Receive Ready
        .pkt_class_data_19(pkt_class_data_19),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_19(pkt_class_valid_19),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_19(data_tx_error_19),        //INPUT  : Status
        .data_tx_data_19(data_tx_data_19),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_19(data_tx_valid_19),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_19(data_tx_sop_19),            //INPUT  : Start of Packet
        .data_tx_eop_19(data_tx_eop_19),            //INPUT  : End of Packet
        .data_tx_ready_19(data_tx_ready_19),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_19(tx_ff_uflow_19),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_19(tx_crc_fwd_19),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_19(xoff_gen_19),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_19(xon_gen_19),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_19(magic_sleep_n_19),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_19(magic_wakeup_19),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 20 
            
        .tbi_rx_clk_20(tbi_rx_clk_20),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_20(tbi_tx_clk_20),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_20(tbi_rx_d_20),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_20(tbi_tx_d_20),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_20(sd_loopback_20),            //OUTPUT : SERDES Loopback Enable
        .powerdown_20(pcs_pwrdn_out_sig[20]),       //OUTPUT : Powerdown Enable
        .led_col_20(led_col_20),                    //OUTPUT : Collision Indication
        .led_an_20(led_an_20),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_20(led_char_err_20),          //OUTPUT : Character error
        .led_disp_err_20(led_disp_err_20),          //OUTPUT : Disparity error
        .led_crs_20(led_crs_20),                    //OUTPUT : Carrier sense
        .led_link_20(led_link_20),                  //OUTPUT : Valid link    
        .mac_rx_clk_20(mac_rx_clk_20),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_20(mac_tx_clk_20),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_20(data_rx_sop_20),            //OUTPUT : Start of Packet
        .data_rx_eop_20(data_rx_eop_20),            //OUTPUT : End of Packet
        .data_rx_data_20(data_rx_data_20),          //OUTPUT : Data from FIFO
        .data_rx_error_20(data_rx_error_20),        //OUTPUT : Receive packet error
        .data_rx_valid_20(data_rx_valid_20),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_20(data_rx_ready_20),        //OUTPUT : Data Receive Ready
        .pkt_class_data_20(pkt_class_data_20),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_20(pkt_class_valid_20),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_20(data_tx_error_20),        //INPUT  : Status
        .data_tx_data_20(data_tx_data_20),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_20(data_tx_valid_20),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_20(data_tx_sop_20),            //INPUT  : Start of Packet
        .data_tx_eop_20(data_tx_eop_20),            //INPUT  : End of Packet
        .data_tx_ready_20(data_tx_ready_20),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_20(tx_ff_uflow_20),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_20(tx_crc_fwd_20),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_20(xoff_gen_20),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_20(xon_gen_20),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_20(magic_sleep_n_20),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_20(magic_wakeup_20),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 21 
            
        .tbi_rx_clk_21(tbi_rx_clk_21),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_21(tbi_tx_clk_21),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_21(tbi_rx_d_21),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_21(tbi_tx_d_21),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_21(sd_loopback_21),            //OUTPUT : SERDES Loopback Enable
        .powerdown_21(pcs_pwrdn_out_sig[21]),       //OUTPUT : Powerdown Enable
        .led_col_21(led_col_21),                    //OUTPUT : Collision Indication
        .led_an_21(led_an_21),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_21(led_char_err_21),          //OUTPUT : Character error
        .led_disp_err_21(led_disp_err_21),          //OUTPUT : Disparity error
        .led_crs_21(led_crs_21),                    //OUTPUT : Carrier sense
        .led_link_21(led_link_21),                  //OUTPUT : Valid link    
        .mac_rx_clk_21(mac_rx_clk_21),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_21(mac_tx_clk_21),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_21(data_rx_sop_21),            //OUTPUT : Start of Packet
        .data_rx_eop_21(data_rx_eop_21),            //OUTPUT : End of Packet
        .data_rx_data_21(data_rx_data_21),          //OUTPUT : Data from FIFO
        .data_rx_error_21(data_rx_error_21),        //OUTPUT : Receive packet error
        .data_rx_valid_21(data_rx_valid_21),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_21(data_rx_ready_21),        //OUTPUT : Data Receive Ready
        .pkt_class_data_21(pkt_class_data_21),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_21(pkt_class_valid_21),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_21(data_tx_error_21),        //INPUT  : Status
        .data_tx_data_21(data_tx_data_21),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_21(data_tx_valid_21),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_21(data_tx_sop_21),            //INPUT  : Start of Packet
        .data_tx_eop_21(data_tx_eop_21),            //INPUT  : End of Packet
        .data_tx_ready_21(data_tx_ready_21),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_21(tx_ff_uflow_21),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_21(tx_crc_fwd_21),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_21(xoff_gen_21),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_21(xon_gen_21),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_21(magic_sleep_n_21),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_21(magic_wakeup_21),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 22 
            
        .tbi_rx_clk_22(tbi_rx_clk_22),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_22(tbi_tx_clk_22),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_22(tbi_rx_d_22),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_22(tbi_tx_d_22),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_22(sd_loopback_22),            //OUTPUT : SERDES Loopback Enable
        .powerdown_22(pcs_pwrdn_out_sig[22]),       //OUTPUT : Powerdown Enable
        .led_col_22(led_col_22),                    //OUTPUT : Collision Indication
        .led_an_22(led_an_22),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_22(led_char_err_22),          //OUTPUT : Character error
        .led_disp_err_22(led_disp_err_22),          //OUTPUT : Disparity error
        .led_crs_22(led_crs_22),                    //OUTPUT : Carrier sense
        .led_link_22(led_link_22),                  //OUTPUT : Valid link    
        .mac_rx_clk_22(mac_rx_clk_22),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_22(mac_tx_clk_22),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_22(data_rx_sop_22),            //OUTPUT : Start of Packet
        .data_rx_eop_22(data_rx_eop_22),            //OUTPUT : End of Packet
        .data_rx_data_22(data_rx_data_22),          //OUTPUT : Data from FIFO
        .data_rx_error_22(data_rx_error_22),        //OUTPUT : Receive packet error
        .data_rx_valid_22(data_rx_valid_22),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_22(data_rx_ready_22),        //OUTPUT : Data Receive Ready
        .pkt_class_data_22(pkt_class_data_22),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_22(pkt_class_valid_22),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_22(data_tx_error_22),        //INPUT  : Status
        .data_tx_data_22(data_tx_data_22),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_22(data_tx_valid_22),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_22(data_tx_sop_22),            //INPUT  : Start of Packet
        .data_tx_eop_22(data_tx_eop_22),            //INPUT  : End of Packet
        .data_tx_ready_22(data_tx_ready_22),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_22(tx_ff_uflow_22),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_22(tx_crc_fwd_22),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_22(xoff_gen_22),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_22(xon_gen_22),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_22(magic_sleep_n_22),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_22(magic_wakeup_22),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 23 
            
        .tbi_rx_clk_23(tbi_rx_clk_23),              //INPUT  : Receive TBI Clock
        .tbi_tx_clk_23(tbi_tx_clk_23),              //INPUT  : Transmit TBI Clock
        .tbi_rx_d_23(tbi_rx_d_23),                  //INPUT  : Receive TBI Interface
        .tbi_tx_d_23(tbi_tx_d_23),                  //OUTPUT : Transmit TBI Interface
        .sd_loopback_23(sd_loopback_23),            //OUTPUT : SERDES Loopback Enable
        .powerdown_23(pcs_pwrdn_out_sig[23]),       //OUTPUT : Powerdown Enable
        .led_col_23(led_col_23),                    //OUTPUT : Collision Indication
        .led_an_23(led_an_23),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_23(led_char_err_23),          //OUTPUT : Character error
        .led_disp_err_23(led_disp_err_23),          //OUTPUT : Disparity error
        .led_crs_23(led_crs_23),                    //OUTPUT : Carrier sense
        .led_link_23(led_link_23),                  //OUTPUT : Valid link    
        .mac_rx_clk_23(mac_rx_clk_23),              //OUTPUT : Av-ST Rx Clock
        .mac_tx_clk_23(mac_tx_clk_23),              //OUTPUT : Av-ST Tx Clock
        .data_rx_sop_23(data_rx_sop_23),            //OUTPUT : Start of Packet
        .data_rx_eop_23(data_rx_eop_23),            //OUTPUT : End of Packet
        .data_rx_data_23(data_rx_data_23),          //OUTPUT : Data from FIFO
        .data_rx_error_23(data_rx_error_23),        //OUTPUT : Receive packet error
        .data_rx_valid_23(data_rx_valid_23),        //OUTPUT : Data Receive FIFO Valid
        .data_rx_ready_23(data_rx_ready_23),        //OUTPUT : Data Receive Ready
        .pkt_class_data_23(pkt_class_data_23),      //OUTPUT : Frame Type Indication
        .pkt_class_valid_23(pkt_class_valid_23),    //OUTPUT : Frame Type Indication Valid
        .data_tx_error_23(data_tx_error_23),        //INPUT  : Status
        .data_tx_data_23(data_tx_data_23),          //INPUT  : Data from FIFO transmit
        .data_tx_valid_23(data_tx_valid_23),        //INPUT  : Data FIFO transmit Empty
        .data_tx_sop_23(data_tx_sop_23),            //INPUT  : Start of Packet
        .data_tx_eop_23(data_tx_eop_23),            //INPUT  : End of Packet
        .data_tx_ready_23(data_tx_ready_23),        //OUTPUT : Data FIFO transmit Read Enable  
        .tx_ff_uflow_23(tx_ff_uflow_23),            //OUTPUT : TX FIFO underflow occured (Synchronous with tx_clk)
        .tx_crc_fwd_23(tx_crc_fwd_23),              //INPUT  : Forward Current Frame with CRC from Application
        .xoff_gen_23(xoff_gen_23),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_23(xon_gen_23),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_23(magic_sleep_n_23),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_23(magic_wakeup_23));         //OUTPUT : MAC WAKE-UP INDICATION

    defparam
        U_MULTI_MAC_PCS.USE_SYNC_RESET = USE_SYNC_RESET, 
        U_MULTI_MAC_PCS.RESET_LEVEL = RESET_LEVEL,
        U_MULTI_MAC_PCS.ENABLE_GMII_LOOPBACK = ENABLE_GMII_LOOPBACK, 
        U_MULTI_MAC_PCS.ENABLE_HD_LOGIC = ENABLE_HD_LOGIC,
        U_MULTI_MAC_PCS.ENABLE_SUP_ADDR = ENABLE_SUP_ADDR,
        U_MULTI_MAC_PCS.ENA_HASH = ENA_HASH,
        U_MULTI_MAC_PCS.STAT_CNT_ENA = STAT_CNT_ENA,
        U_MULTI_MAC_PCS.CORE_VERSION = CORE_VERSION, 
        U_MULTI_MAC_PCS.CUST_VERSION = CUST_VERSION,
        U_MULTI_MAC_PCS.REDUCED_INTERFACE_ENA = REDUCED_INTERFACE_ENA,
        U_MULTI_MAC_PCS.ENABLE_MDIO = ENABLE_MDIO,
        U_MULTI_MAC_PCS.MDIO_CLK_DIV = MDIO_CLK_DIV,
        U_MULTI_MAC_PCS.ENABLE_MAGIC_DETECT = ENABLE_MAGIC_DETECT,
        U_MULTI_MAC_PCS.ENABLE_PADDING = ENABLE_PADDING,
        U_MULTI_MAC_PCS.ENABLE_LGTH_CHECK = ENABLE_LGTH_CHECK,
        U_MULTI_MAC_PCS.GBIT_ONLY = GBIT_ONLY,
        U_MULTI_MAC_PCS.MBIT_ONLY = MBIT_ONLY,
        U_MULTI_MAC_PCS.REDUCED_CONTROL = REDUCED_CONTROL,
        U_MULTI_MAC_PCS.CRC32DWIDTH = CRC32DWIDTH,
        U_MULTI_MAC_PCS.CRC32GENDELAY = CRC32GENDELAY, 
        U_MULTI_MAC_PCS.CRC32CHECK16BIT = CRC32CHECK16BIT, 
        U_MULTI_MAC_PCS.CRC32S1L2_EXTERN = CRC32S1L2_EXTERN,
        U_MULTI_MAC_PCS.ENABLE_SHIFT16 = ENABLE_SHIFT16,   
        U_MULTI_MAC_PCS.ENABLE_MAC_FLOW_CTRL = ENABLE_MAC_FLOW_CTRL,
        U_MULTI_MAC_PCS.ENABLE_MAC_TXADDR_SET = ENABLE_MAC_TXADDR_SET,
        U_MULTI_MAC_PCS.ENABLE_MAC_RX_VLAN = ENABLE_MAC_RX_VLAN,
        U_MULTI_MAC_PCS.ENABLE_MAC_TX_VLAN = ENABLE_MAC_TX_VLAN,
        U_MULTI_MAC_PCS.PHY_IDENTIFIER = PHY_IDENTIFIER,
        U_MULTI_MAC_PCS.DEV_VERSION = DEV_VERSION,
        U_MULTI_MAC_PCS.ENABLE_SGMII = ENABLE_SGMII,
        U_MULTI_MAC_PCS.MAX_CHANNELS = MAX_CHANNELS,
        U_MULTI_MAC_PCS.CHANNEL_WIDTH = CHANNEL_WIDTH,
	    U_MULTI_MAC_PCS.ENABLE_RX_FIFO_STATUS = ENABLE_RX_FIFO_STATUS,
	    U_MULTI_MAC_PCS.ENABLE_EXTENDED_STAT_REG = ENABLE_EXTENDED_STAT_REG,
        U_MULTI_MAC_PCS.ENABLE_CLK_SHARING = ENABLE_CLK_SHARING,    
        U_MULTI_MAC_PCS.ENABLE_REG_SHARING = ENABLE_REG_SHARING;    



// #######################################################################
// ###############       CHANNEL 0 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 0)
    begin          
        assign gxb_pwrdn_in_sig[0] = gxb_pwrdn_in_0;
        assign pcs_pwrdn_out_0 = pcs_pwrdn_out_sig[0];
    end
else
    begin
        assign gxb_pwrdn_in_sig[0] = pcs_pwrdn_out_sig[0];
		assign pcs_pwrdn_out_0 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the Alt2gxb block as the PMA for Stratix_II_GX devices
// ---------------------------------------------------------------------------- 
// Instantiation of the Alt2gxb block as the PMA for ArriaGX device
// ---------------------------------------------------------------- 

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

altera_tse_reset_synchronizer reset_sync_0 (
        .clk(ref_clk),
        .reset_in(reset),
        .reset_out(reset_ref_clk_int)
        );

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 0)
    begin          

    assign tbi_tx_clk_0 = ref_clk;
    assign tbi_rx_d_0 = tbi_rx_d_flip_0;
        
    altera_tse_reset_synchronizer ch_0_reset_sync_0 (
        .clk(tbi_rx_clk_0),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_0_int)
        ); 
    
    always @(posedge tbi_rx_clk_0 or posedge reset_tbi_rx_clk_0_int)
        begin
        if (reset_tbi_rx_clk_0_int == 1)
            tbi_rx_d_flip_0 <= 0;
        else 
            begin
            tbi_rx_d_flip_0[0] <= tbi_rx_d_lvds_0[9];
            tbi_rx_d_flip_0[1] <= tbi_rx_d_lvds_0[8];
            tbi_rx_d_flip_0[2] <= tbi_rx_d_lvds_0[7];
            tbi_rx_d_flip_0[3] <= tbi_rx_d_lvds_0[6];
            tbi_rx_d_flip_0[4] <= tbi_rx_d_lvds_0[5];
            tbi_rx_d_flip_0[5] <= tbi_rx_d_lvds_0[4];
            tbi_rx_d_flip_0[6] <= tbi_rx_d_lvds_0[3];
            tbi_rx_d_flip_0[7] <= tbi_rx_d_lvds_0[2];
            tbi_rx_d_flip_0[8] <= tbi_rx_d_lvds_0[1];
            tbi_rx_d_flip_0[9] <= tbi_rx_d_lvds_0[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_0 <= 0;
        else 
            begin
            tbi_tx_d_flip_0[0] <= tbi_tx_d_0[9];
            tbi_tx_d_flip_0[1] <= tbi_tx_d_0[8];
            tbi_tx_d_flip_0[2] <= tbi_tx_d_0[7];
            tbi_tx_d_flip_0[3] <= tbi_tx_d_0[6];
            tbi_tx_d_flip_0[4] <= tbi_tx_d_0[5];
            tbi_tx_d_flip_0[5] <= tbi_tx_d_0[4];
            tbi_tx_d_flip_0[6] <= tbi_tx_d_0[3];
            tbi_tx_d_flip_0[7] <= tbi_tx_d_0[2];
            tbi_tx_d_flip_0[8] <= tbi_tx_d_0[1];
            tbi_tx_d_flip_0[9] <= tbi_tx_d_0[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_0
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_0 ),
         .rx_channel_data_align ( rx_channel_data_align_0 ),
         .rx_locked ( rx_locked_0 ),
         .rx_divfwdclk (tbi_rx_clk_0),
         .rx_in (rxp_0),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_0),
         .rx_outclock (),
         .rx_reset (rx_reset_0)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_0 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_0 ),
		.rx_channel_data_align ( rx_channel_data_align_0 ),
		.pll_areset ( pll_areset_0 ),
		.rx_reset ( rx_reset_0 ),
		.rx_cda_reset ( rx_cda_reset_0 )
	);       

    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_0
    (
        .tx_in (tbi_tx_d_flip_0),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_0)
    );

    end   
else
    begin
    assign txp_0 = 1'b0;
    assign tbi_rx_clk_0 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 1 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 1)
    begin          
        assign gxb_pwrdn_in_sig[1] = gxb_pwrdn_in_1;
        assign pcs_pwrdn_out_1 = pcs_pwrdn_out_sig[1];
    end
else
    begin
        assign gxb_pwrdn_in_sig[1] = pcs_pwrdn_out_sig[1];
		assign pcs_pwrdn_out_1 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 1)
    begin          

    assign tbi_tx_clk_1 = ref_clk;
    assign tbi_rx_d_1 = tbi_rx_d_flip_1;
    
    altera_tse_reset_synchronizer ch_1_reset_sync_0 (
        .clk(tbi_rx_clk_1),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_1_int)
        ); 

    always @(posedge tbi_rx_clk_1 or posedge reset_tbi_rx_clk_1_int)
        begin
        if (reset_tbi_rx_clk_1_int == 1)
            tbi_rx_d_flip_1 <= 0;
        else 
            begin
            tbi_rx_d_flip_1[0] <= tbi_rx_d_lvds_1[9];
            tbi_rx_d_flip_1[1] <= tbi_rx_d_lvds_1[8];
            tbi_rx_d_flip_1[2] <= tbi_rx_d_lvds_1[7];
            tbi_rx_d_flip_1[3] <= tbi_rx_d_lvds_1[6];
            tbi_rx_d_flip_1[4] <= tbi_rx_d_lvds_1[5];
            tbi_rx_d_flip_1[5] <= tbi_rx_d_lvds_1[4];
            tbi_rx_d_flip_1[6] <= tbi_rx_d_lvds_1[3];
            tbi_rx_d_flip_1[7] <= tbi_rx_d_lvds_1[2];
            tbi_rx_d_flip_1[8] <= tbi_rx_d_lvds_1[1];
            tbi_rx_d_flip_1[9] <= tbi_rx_d_lvds_1[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_1 <= 0;
        else 
            begin
            tbi_tx_d_flip_1[0] <= tbi_tx_d_1[9];
            tbi_tx_d_flip_1[1] <= tbi_tx_d_1[8];
            tbi_tx_d_flip_1[2] <= tbi_tx_d_1[7];
            tbi_tx_d_flip_1[3] <= tbi_tx_d_1[6];
            tbi_tx_d_flip_1[4] <= tbi_tx_d_1[5];
            tbi_tx_d_flip_1[5] <= tbi_tx_d_1[4];
            tbi_tx_d_flip_1[6] <= tbi_tx_d_1[3];
            tbi_tx_d_flip_1[7] <= tbi_tx_d_1[2];
            tbi_tx_d_flip_1[8] <= tbi_tx_d_1[1];
            tbi_tx_d_flip_1[9] <= tbi_tx_d_1[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_1
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_1 ),
         .rx_channel_data_align ( rx_channel_data_align_1 ),
         .rx_locked ( rx_locked_1 ),
         .rx_divfwdclk (tbi_rx_clk_1),
         .rx_in (rxp_1),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_1),
         .rx_outclock (),
         .rx_reset (rx_reset_1)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_1 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_1 ),
		.rx_channel_data_align ( rx_channel_data_align_1 ),
		.pll_areset ( pll_areset_1 ),
		.rx_reset ( rx_reset_1 ),
		.rx_cda_reset ( rx_cda_reset_1 )
	); 


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_1
    (
        .tx_in (tbi_tx_d_flip_1),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_1)
    );

    end   
else
    begin
    assign txp_1 = 1'b0;
    assign tbi_rx_clk_1 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 2 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 2)
    begin          
        assign gxb_pwrdn_in_sig[2] = gxb_pwrdn_in_2;
        assign pcs_pwrdn_out_2 = pcs_pwrdn_out_sig[2];
    end
else
    begin
        assign gxb_pwrdn_in_sig[2] = pcs_pwrdn_out_sig[2];
		assign pcs_pwrdn_out_2 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 2)
    begin          

    assign tbi_tx_clk_2 = ref_clk;
    assign tbi_rx_d_2 = tbi_rx_d_flip_2;
    
    altera_tse_reset_synchronizer ch_2_reset_sync_0 (
        .clk(tbi_rx_clk_2),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_2_int)
        ); 

    always @(posedge tbi_rx_clk_2 or posedge reset_tbi_rx_clk_2_int)
        begin
        if (reset_tbi_rx_clk_2_int == 1)
            tbi_rx_d_flip_2 <= 0;
        else 
            begin
            tbi_rx_d_flip_2[0] <= tbi_rx_d_lvds_2[9];
            tbi_rx_d_flip_2[1] <= tbi_rx_d_lvds_2[8];
            tbi_rx_d_flip_2[2] <= tbi_rx_d_lvds_2[7];
            tbi_rx_d_flip_2[3] <= tbi_rx_d_lvds_2[6];
            tbi_rx_d_flip_2[4] <= tbi_rx_d_lvds_2[5];
            tbi_rx_d_flip_2[5] <= tbi_rx_d_lvds_2[4];
            tbi_rx_d_flip_2[6] <= tbi_rx_d_lvds_2[3];
            tbi_rx_d_flip_2[7] <= tbi_rx_d_lvds_2[2];
            tbi_rx_d_flip_2[8] <= tbi_rx_d_lvds_2[1];
            tbi_rx_d_flip_2[9] <= tbi_rx_d_lvds_2[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_2 <= 0;
        else 
            begin
            tbi_tx_d_flip_2[0] <= tbi_tx_d_2[9];
            tbi_tx_d_flip_2[1] <= tbi_tx_d_2[8];
            tbi_tx_d_flip_2[2] <= tbi_tx_d_2[7];
            tbi_tx_d_flip_2[3] <= tbi_tx_d_2[6];
            tbi_tx_d_flip_2[4] <= tbi_tx_d_2[5];
            tbi_tx_d_flip_2[5] <= tbi_tx_d_2[4];
            tbi_tx_d_flip_2[6] <= tbi_tx_d_2[3];
            tbi_tx_d_flip_2[7] <= tbi_tx_d_2[2];
            tbi_tx_d_flip_2[8] <= tbi_tx_d_2[1];
            tbi_tx_d_flip_2[9] <= tbi_tx_d_2[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_2
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_2 ),
         .rx_channel_data_align ( rx_channel_data_align_2 ),
         .rx_locked ( rx_locked_2 ),
         .rx_divfwdclk (tbi_rx_clk_2),
         .rx_in (rxp_2),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_2),
         .rx_outclock (),
         .rx_reset (rx_reset_2)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_2 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_2 ),
		.rx_channel_data_align ( rx_channel_data_align_2 ),
		.pll_areset ( pll_areset_2 ),
		.rx_reset ( rx_reset_2 ),
		.rx_cda_reset ( rx_cda_reset_2 )
	); 


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_2
    (
        .tx_in (tbi_tx_d_flip_2),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_2)
    );

    end   
else
    begin
    assign txp_2 = 1'b0;
    assign tbi_rx_clk_2 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 3 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 3)
    begin          
        assign gxb_pwrdn_in_sig[3] = gxb_pwrdn_in_3;
        assign pcs_pwrdn_out_3 = pcs_pwrdn_out_sig[3];
    end
else
    begin
        assign gxb_pwrdn_in_sig[3] = pcs_pwrdn_out_sig[3];
		assign pcs_pwrdn_out_3 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 3)
    begin          

    assign tbi_tx_clk_3 = ref_clk;
    assign tbi_rx_d_3 = tbi_rx_d_flip_3;
    
    altera_tse_reset_synchronizer ch_3_reset_sync_0 (
        .clk(tbi_rx_clk_3),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_3_int)
        ); 

    always @(posedge tbi_rx_clk_3 or posedge reset_tbi_rx_clk_3_int)
        begin
        if (reset_tbi_rx_clk_3_int == 1)
            tbi_rx_d_flip_3 <= 0;
        else 
            begin
            tbi_rx_d_flip_3[0] <= tbi_rx_d_lvds_3[9];
            tbi_rx_d_flip_3[1] <= tbi_rx_d_lvds_3[8];
            tbi_rx_d_flip_3[2] <= tbi_rx_d_lvds_3[7];
            tbi_rx_d_flip_3[3] <= tbi_rx_d_lvds_3[6];
            tbi_rx_d_flip_3[4] <= tbi_rx_d_lvds_3[5];
            tbi_rx_d_flip_3[5] <= tbi_rx_d_lvds_3[4];
            tbi_rx_d_flip_3[6] <= tbi_rx_d_lvds_3[3];
            tbi_rx_d_flip_3[7] <= tbi_rx_d_lvds_3[2];
            tbi_rx_d_flip_3[8] <= tbi_rx_d_lvds_3[1];
            tbi_rx_d_flip_3[9] <= tbi_rx_d_lvds_3[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_3 <= 0;
        else 
            begin
            tbi_tx_d_flip_3[0] <= tbi_tx_d_3[9];
            tbi_tx_d_flip_3[1] <= tbi_tx_d_3[8];
            tbi_tx_d_flip_3[2] <= tbi_tx_d_3[7];
            tbi_tx_d_flip_3[3] <= tbi_tx_d_3[6];
            tbi_tx_d_flip_3[4] <= tbi_tx_d_3[5];
            tbi_tx_d_flip_3[5] <= tbi_tx_d_3[4];
            tbi_tx_d_flip_3[6] <= tbi_tx_d_3[3];
            tbi_tx_d_flip_3[7] <= tbi_tx_d_3[2];
            tbi_tx_d_flip_3[8] <= tbi_tx_d_3[1];
            tbi_tx_d_flip_3[9] <= tbi_tx_d_3[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_3
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_3 ),
         .rx_channel_data_align ( rx_channel_data_align_3 ),
         .rx_locked ( rx_locked_3 ),
         .rx_divfwdclk (tbi_rx_clk_3),
         .rx_in (rxp_3),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_3),
         .rx_outclock (),
         .rx_reset (rx_reset_3)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_3 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_3 ),
		.rx_channel_data_align ( rx_channel_data_align_3 ),
		.pll_areset ( pll_areset_3 ),
		.rx_reset ( rx_reset_3 ),
		.rx_cda_reset ( rx_cda_reset_3 )
	); 
    
    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_3
    (
        .tx_in (tbi_tx_d_flip_3),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_3)
    );

    end   
else
    begin
    assign txp_3 = 1'b0;
    assign tbi_rx_clk_3 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 4 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 4)
    begin          
        assign gxb_pwrdn_in_sig[4] = gxb_pwrdn_in_4;
        assign pcs_pwrdn_out_4 = pcs_pwrdn_out_sig[4];
    end
else
    begin
        assign gxb_pwrdn_in_sig[4] = pcs_pwrdn_out_sig[4];
		assign pcs_pwrdn_out_4 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 4)
    begin          

    assign tbi_tx_clk_4 = ref_clk;
    assign tbi_rx_d_4 = tbi_rx_d_flip_4;
    
    altera_tse_reset_synchronizer ch_4_reset_sync_0 (
        .clk(tbi_rx_clk_4),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_4_int)
        );

    always @(posedge tbi_rx_clk_4 or posedge reset_tbi_rx_clk_4_int)
        begin
        if (reset_tbi_rx_clk_4_int == 1)
            tbi_rx_d_flip_4 <= 0;
        else 
            begin
            tbi_rx_d_flip_4[0] <= tbi_rx_d_lvds_4[9];
            tbi_rx_d_flip_4[1] <= tbi_rx_d_lvds_4[8];
            tbi_rx_d_flip_4[2] <= tbi_rx_d_lvds_4[7];
            tbi_rx_d_flip_4[3] <= tbi_rx_d_lvds_4[6];
            tbi_rx_d_flip_4[4] <= tbi_rx_d_lvds_4[5];
            tbi_rx_d_flip_4[5] <= tbi_rx_d_lvds_4[4];
            tbi_rx_d_flip_4[6] <= tbi_rx_d_lvds_4[3];
            tbi_rx_d_flip_4[7] <= tbi_rx_d_lvds_4[2];
            tbi_rx_d_flip_4[8] <= tbi_rx_d_lvds_4[1];
            tbi_rx_d_flip_4[9] <= tbi_rx_d_lvds_4[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_4 <= 0;
        else 
            begin
            tbi_tx_d_flip_4[0] <= tbi_tx_d_4[9];
            tbi_tx_d_flip_4[1] <= tbi_tx_d_4[8];
            tbi_tx_d_flip_4[2] <= tbi_tx_d_4[7];
            tbi_tx_d_flip_4[3] <= tbi_tx_d_4[6];
            tbi_tx_d_flip_4[4] <= tbi_tx_d_4[5];
            tbi_tx_d_flip_4[5] <= tbi_tx_d_4[4];
            tbi_tx_d_flip_4[6] <= tbi_tx_d_4[3];
            tbi_tx_d_flip_4[7] <= tbi_tx_d_4[2];
            tbi_tx_d_flip_4[8] <= tbi_tx_d_4[1];
            tbi_tx_d_flip_4[9] <= tbi_tx_d_4[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_4
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_4 ),
         .rx_channel_data_align ( rx_channel_data_align_4 ),
         .rx_locked ( rx_locked_4 ),
         .rx_divfwdclk (tbi_rx_clk_4),
         .rx_in (rxp_4),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_4),
         .rx_outclock (),
         .rx_reset (rx_reset_4)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_4 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_4 ),
		.rx_channel_data_align ( rx_channel_data_align_4 ),
		.pll_areset ( pll_areset_4 ),
		.rx_reset ( rx_reset_4 ),
		.rx_cda_reset ( rx_cda_reset_4 )
	); 


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_4
    (
        .tx_in (tbi_tx_d_flip_4),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_4)
    );

    end   
else
    begin
    assign txp_4 = 1'b0;
    assign tbi_rx_clk_4 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 5 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 5)
    begin          
        assign gxb_pwrdn_in_sig[5] = gxb_pwrdn_in_5;
        assign pcs_pwrdn_out_5 = pcs_pwrdn_out_sig[5];
    end
else
    begin
        assign gxb_pwrdn_in_sig[5] = pcs_pwrdn_out_sig[5];
		assign pcs_pwrdn_out_5 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 5)
    begin          

    assign tbi_tx_clk_5 = ref_clk;
    assign tbi_rx_d_5 = tbi_rx_d_flip_5;

    altera_tse_reset_synchronizer ch_5_reset_sync_0 (
        .clk(tbi_rx_clk_5),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_5_int)
        ); 
        
    always @(posedge tbi_rx_clk_5 or posedge reset_tbi_rx_clk_5_int)
        begin
        if (reset_tbi_rx_clk_5_int == 1)
            tbi_rx_d_flip_5 <= 0;
        else 
            begin
            tbi_rx_d_flip_5[0] <= tbi_rx_d_lvds_5[9];
            tbi_rx_d_flip_5[1] <= tbi_rx_d_lvds_5[8];
            tbi_rx_d_flip_5[2] <= tbi_rx_d_lvds_5[7];
            tbi_rx_d_flip_5[3] <= tbi_rx_d_lvds_5[6];
            tbi_rx_d_flip_5[4] <= tbi_rx_d_lvds_5[5];
            tbi_rx_d_flip_5[5] <= tbi_rx_d_lvds_5[4];
            tbi_rx_d_flip_5[6] <= tbi_rx_d_lvds_5[3];
            tbi_rx_d_flip_5[7] <= tbi_rx_d_lvds_5[2];
            tbi_rx_d_flip_5[8] <= tbi_rx_d_lvds_5[1];
            tbi_rx_d_flip_5[9] <= tbi_rx_d_lvds_5[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_5 <= 0;
        else 
            begin
            tbi_tx_d_flip_5[0] <= tbi_tx_d_5[9];
            tbi_tx_d_flip_5[1] <= tbi_tx_d_5[8];
            tbi_tx_d_flip_5[2] <= tbi_tx_d_5[7];
            tbi_tx_d_flip_5[3] <= tbi_tx_d_5[6];
            tbi_tx_d_flip_5[4] <= tbi_tx_d_5[5];
            tbi_tx_d_flip_5[5] <= tbi_tx_d_5[4];
            tbi_tx_d_flip_5[6] <= tbi_tx_d_5[3];
            tbi_tx_d_flip_5[7] <= tbi_tx_d_5[2];
            tbi_tx_d_flip_5[8] <= tbi_tx_d_5[1];
            tbi_tx_d_flip_5[9] <= tbi_tx_d_5[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_5
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_5 ),
         .rx_channel_data_align ( rx_channel_data_align_5 ),
         .rx_locked ( rx_locked_5 ),
         .rx_divfwdclk (tbi_rx_clk_5),
         .rx_in (rxp_5),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_5),
         .rx_outclock (),
         .rx_reset (rx_reset_5)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_5 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_5 ),
		.rx_channel_data_align ( rx_channel_data_align_5 ),
		.pll_areset ( pll_areset_5 ),
		.rx_reset ( rx_reset_5 ),
        .rx_cda_reset ( rx_cda_reset_5 )
	); 
		


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_5
    (
        .tx_in (tbi_tx_d_flip_5),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_5)
    );

    end   
else
    begin
    assign txp_5 = 1'b0;
    assign tbi_rx_clk_5 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 6 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 6)
    begin          
        assign gxb_pwrdn_in_sig[6] = gxb_pwrdn_in_6;
        assign pcs_pwrdn_out_6 = pcs_pwrdn_out_sig[6];
    end
else
    begin
        assign gxb_pwrdn_in_sig[6] = pcs_pwrdn_out_sig[6];
		assign pcs_pwrdn_out_6 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 6)
    begin          

    assign tbi_tx_clk_6 = ref_clk;
    assign tbi_rx_d_6 = tbi_rx_d_flip_6;
    
    altera_tse_reset_synchronizer ch_6_reset_sync_0 (
        .clk(tbi_rx_clk_6),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_6_int)
        ); 

    always @(posedge tbi_rx_clk_6 or posedge reset_tbi_rx_clk_6_int)
        begin
        if (reset_tbi_rx_clk_6_int == 1)
            tbi_rx_d_flip_6 <= 0;
        else 
            begin
            tbi_rx_d_flip_6[0] <= tbi_rx_d_lvds_6[9];
            tbi_rx_d_flip_6[1] <= tbi_rx_d_lvds_6[8];
            tbi_rx_d_flip_6[2] <= tbi_rx_d_lvds_6[7];
            tbi_rx_d_flip_6[3] <= tbi_rx_d_lvds_6[6];
            tbi_rx_d_flip_6[4] <= tbi_rx_d_lvds_6[5];
            tbi_rx_d_flip_6[5] <= tbi_rx_d_lvds_6[4];
            tbi_rx_d_flip_6[6] <= tbi_rx_d_lvds_6[3];
            tbi_rx_d_flip_6[7] <= tbi_rx_d_lvds_6[2];
            tbi_rx_d_flip_6[8] <= tbi_rx_d_lvds_6[1];
            tbi_rx_d_flip_6[9] <= tbi_rx_d_lvds_6[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_6 <= 0;
        else 
            begin
            tbi_tx_d_flip_6[0] <= tbi_tx_d_6[9];
            tbi_tx_d_flip_6[1] <= tbi_tx_d_6[8];
            tbi_tx_d_flip_6[2] <= tbi_tx_d_6[7];
            tbi_tx_d_flip_6[3] <= tbi_tx_d_6[6];
            tbi_tx_d_flip_6[4] <= tbi_tx_d_6[5];
            tbi_tx_d_flip_6[5] <= tbi_tx_d_6[4];
            tbi_tx_d_flip_6[6] <= tbi_tx_d_6[3];
            tbi_tx_d_flip_6[7] <= tbi_tx_d_6[2];
            tbi_tx_d_flip_6[8] <= tbi_tx_d_6[1];
            tbi_tx_d_flip_6[9] <= tbi_tx_d_6[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_6
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_6 ),
         .rx_channel_data_align ( rx_channel_data_align_6 ),
         .rx_locked ( rx_locked_6 ),
         .rx_divfwdclk (tbi_rx_clk_6),
         .rx_in (rxp_6),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_6),
         .rx_outclock (),
         .rx_reset (rx_reset_6)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_6 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_6 ),
		.rx_channel_data_align ( rx_channel_data_align_6 ),
		.pll_areset ( pll_areset_6 ),
		.rx_reset ( rx_reset_6 ),
        .rx_cda_reset ( rx_cda_reset_6 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_6
    (
        .tx_in (tbi_tx_d_flip_6),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_6)
    );

    end   
else
    begin
    assign txp_6 = 1'b0;
    assign tbi_rx_clk_6 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 7 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 7)
    begin          
        assign gxb_pwrdn_in_sig[7] = gxb_pwrdn_in_7;
        assign pcs_pwrdn_out_7 = pcs_pwrdn_out_sig[7];
    end
else
    begin
        assign gxb_pwrdn_in_sig[7] = pcs_pwrdn_out_sig[7];
		assign pcs_pwrdn_out_7 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 7)
    begin          

    assign tbi_tx_clk_7 = ref_clk;
    assign tbi_rx_d_7 = tbi_rx_d_flip_7;
    
    altera_tse_reset_synchronizer ch_7_reset_sync_0 (
        .clk(tbi_rx_clk_7),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_7_int)
        ); 

    always @(posedge tbi_rx_clk_7 or posedge reset_tbi_rx_clk_7_int)
        begin
        if (reset_tbi_rx_clk_7_int == 1)
            tbi_rx_d_flip_7 <= 0;
        else 
            begin
            tbi_rx_d_flip_7[0] <= tbi_rx_d_lvds_7[9];
            tbi_rx_d_flip_7[1] <= tbi_rx_d_lvds_7[8];
            tbi_rx_d_flip_7[2] <= tbi_rx_d_lvds_7[7];
            tbi_rx_d_flip_7[3] <= tbi_rx_d_lvds_7[6];
            tbi_rx_d_flip_7[4] <= tbi_rx_d_lvds_7[5];
            tbi_rx_d_flip_7[5] <= tbi_rx_d_lvds_7[4];
            tbi_rx_d_flip_7[6] <= tbi_rx_d_lvds_7[3];
            tbi_rx_d_flip_7[7] <= tbi_rx_d_lvds_7[2];
            tbi_rx_d_flip_7[8] <= tbi_rx_d_lvds_7[1];
            tbi_rx_d_flip_7[9] <= tbi_rx_d_lvds_7[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_7 <= 0;
        else 
            begin
            tbi_tx_d_flip_7[0] <= tbi_tx_d_7[9];
            tbi_tx_d_flip_7[1] <= tbi_tx_d_7[8];
            tbi_tx_d_flip_7[2] <= tbi_tx_d_7[7];
            tbi_tx_d_flip_7[3] <= tbi_tx_d_7[6];
            tbi_tx_d_flip_7[4] <= tbi_tx_d_7[5];
            tbi_tx_d_flip_7[5] <= tbi_tx_d_7[4];
            tbi_tx_d_flip_7[6] <= tbi_tx_d_7[3];
            tbi_tx_d_flip_7[7] <= tbi_tx_d_7[2];
            tbi_tx_d_flip_7[8] <= tbi_tx_d_7[1];
            tbi_tx_d_flip_7[9] <= tbi_tx_d_7[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_7
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_7 ),
         .rx_channel_data_align ( rx_channel_data_align_7 ),
         .rx_locked ( rx_locked_7 ),
         .rx_divfwdclk (tbi_rx_clk_7),
         .rx_in (rxp_7),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_7),
         .rx_outclock (),
         .rx_reset (rx_reset_7)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_7 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_7 ),
		.rx_channel_data_align ( rx_channel_data_align_7 ),
		.pll_areset ( pll_areset_7 ),
		.rx_reset ( rx_reset_7 ),
        .rx_cda_reset ( rx_cda_reset_7 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_7
    (
        .tx_in (tbi_tx_d_flip_7),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_7)
    );

    end   
else
    begin
    assign txp_7 = 1'b0;
    assign tbi_rx_clk_7 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 8 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 8)
    begin          
        assign gxb_pwrdn_in_sig[8] = gxb_pwrdn_in_8;
        assign pcs_pwrdn_out_8 = pcs_pwrdn_out_sig[8];
    end
else
    begin
        assign gxb_pwrdn_in_sig[8] = pcs_pwrdn_out_sig[8];
		assign pcs_pwrdn_out_8 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 8)
    begin          

    assign tbi_tx_clk_8 = ref_clk;
    assign tbi_rx_d_8 = tbi_rx_d_flip_8;
    
    altera_tse_reset_synchronizer ch_8_reset_sync_0 (
        .clk(tbi_rx_clk_8),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_8_int)
        ); 

    always @(posedge tbi_rx_clk_8 or posedge reset_tbi_rx_clk_8_int)
        begin
        if (reset_tbi_rx_clk_8_int == 1)
            tbi_rx_d_flip_8 <= 0;
        else 
            begin
            tbi_rx_d_flip_8[0] <= tbi_rx_d_lvds_8[9];
            tbi_rx_d_flip_8[1] <= tbi_rx_d_lvds_8[8];
            tbi_rx_d_flip_8[2] <= tbi_rx_d_lvds_8[7];
            tbi_rx_d_flip_8[3] <= tbi_rx_d_lvds_8[6];
            tbi_rx_d_flip_8[4] <= tbi_rx_d_lvds_8[5];
            tbi_rx_d_flip_8[5] <= tbi_rx_d_lvds_8[4];
            tbi_rx_d_flip_8[6] <= tbi_rx_d_lvds_8[3];
            tbi_rx_d_flip_8[7] <= tbi_rx_d_lvds_8[2];
            tbi_rx_d_flip_8[8] <= tbi_rx_d_lvds_8[1];
            tbi_rx_d_flip_8[9] <= tbi_rx_d_lvds_8[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_8 <= 0;
        else 
            begin
            tbi_tx_d_flip_8[0] <= tbi_tx_d_8[9];
            tbi_tx_d_flip_8[1] <= tbi_tx_d_8[8];
            tbi_tx_d_flip_8[2] <= tbi_tx_d_8[7];
            tbi_tx_d_flip_8[3] <= tbi_tx_d_8[6];
            tbi_tx_d_flip_8[4] <= tbi_tx_d_8[5];
            tbi_tx_d_flip_8[5] <= tbi_tx_d_8[4];
            tbi_tx_d_flip_8[6] <= tbi_tx_d_8[3];
            tbi_tx_d_flip_8[7] <= tbi_tx_d_8[2];
            tbi_tx_d_flip_8[8] <= tbi_tx_d_8[1];
            tbi_tx_d_flip_8[9] <= tbi_tx_d_8[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_8
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_8 ),
         .rx_channel_data_align ( rx_channel_data_align_8 ),
         .rx_locked ( rx_locked_8 ),
         .rx_divfwdclk (tbi_rx_clk_8),
         .rx_in (rxp_8),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_8),
         .rx_outclock (),
         .rx_reset (rx_reset_8)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_8 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_8 ),
		.rx_channel_data_align ( rx_channel_data_align_8 ),
		.pll_areset ( pll_areset_8 ),
		.rx_reset ( rx_reset_8 ),
        .rx_cda_reset ( rx_cda_reset_8 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_8
    (
        .tx_in (tbi_tx_d_flip_8),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_8)
    );

    end   
else
    begin
    assign txp_8 = 1'b0;
    assign tbi_rx_clk_8 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 9 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 9)
    begin          
        assign gxb_pwrdn_in_sig[9] = gxb_pwrdn_in_9;
        assign pcs_pwrdn_out_9 = pcs_pwrdn_out_sig[9];
    end
else
    begin
        assign gxb_pwrdn_in_sig[9] = pcs_pwrdn_out_sig[9];
		assign pcs_pwrdn_out_9 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 9)
    begin          

    assign tbi_tx_clk_9 = ref_clk;
    assign tbi_rx_d_9 = tbi_rx_d_flip_9;
    
    altera_tse_reset_synchronizer ch_9_reset_sync_0 (
        .clk(tbi_rx_clk_9),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_9_int)
        );

    always @(posedge tbi_rx_clk_9 or posedge reset_tbi_rx_clk_9_int)
        begin
        if (reset_tbi_rx_clk_9_int == 1)
            tbi_rx_d_flip_9 <= 0;
        else 
            begin
            tbi_rx_d_flip_9[0] <= tbi_rx_d_lvds_9[9];
            tbi_rx_d_flip_9[1] <= tbi_rx_d_lvds_9[8];
            tbi_rx_d_flip_9[2] <= tbi_rx_d_lvds_9[7];
            tbi_rx_d_flip_9[3] <= tbi_rx_d_lvds_9[6];
            tbi_rx_d_flip_9[4] <= tbi_rx_d_lvds_9[5];
            tbi_rx_d_flip_9[5] <= tbi_rx_d_lvds_9[4];
            tbi_rx_d_flip_9[6] <= tbi_rx_d_lvds_9[3];
            tbi_rx_d_flip_9[7] <= tbi_rx_d_lvds_9[2];
            tbi_rx_d_flip_9[8] <= tbi_rx_d_lvds_9[1];
            tbi_rx_d_flip_9[9] <= tbi_rx_d_lvds_9[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_9 <= 0;
        else 
            begin
            tbi_tx_d_flip_9[0] <= tbi_tx_d_9[9];
            tbi_tx_d_flip_9[1] <= tbi_tx_d_9[8];
            tbi_tx_d_flip_9[2] <= tbi_tx_d_9[7];
            tbi_tx_d_flip_9[3] <= tbi_tx_d_9[6];
            tbi_tx_d_flip_9[4] <= tbi_tx_d_9[5];
            tbi_tx_d_flip_9[5] <= tbi_tx_d_9[4];
            tbi_tx_d_flip_9[6] <= tbi_tx_d_9[3];
            tbi_tx_d_flip_9[7] <= tbi_tx_d_9[2];
            tbi_tx_d_flip_9[8] <= tbi_tx_d_9[1];
            tbi_tx_d_flip_9[9] <= tbi_tx_d_9[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_9
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_9 ),
         .rx_channel_data_align ( rx_channel_data_align_9 ),
         .rx_locked ( rx_locked_9 ),
         .rx_divfwdclk (tbi_rx_clk_9),
         .rx_in (rxp_9),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_9),
         .rx_outclock (),
         .rx_reset (rx_reset_9)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_9 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_9 ),
		.rx_channel_data_align ( rx_channel_data_align_9 ),
		.pll_areset ( pll_areset_9 ),
		.rx_reset ( rx_reset_9 ),
        .rx_cda_reset ( rx_cda_reset_9 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_9
    (
        .tx_in (tbi_tx_d_flip_9),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_9)
    );

    end   
else
    begin
    assign txp_9 = 1'b0;
    assign tbi_rx_clk_9 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 10 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 10)
    begin          
        assign gxb_pwrdn_in_sig[10] = gxb_pwrdn_in_10;
        assign pcs_pwrdn_out_10 = pcs_pwrdn_out_sig[10];
    end
else
    begin
        assign gxb_pwrdn_in_sig[10] = pcs_pwrdn_out_sig[10];
		assign pcs_pwrdn_out_10 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 10)
    begin          

    assign tbi_tx_clk_10 = ref_clk;
    assign tbi_rx_d_10 = tbi_rx_d_flip_10;
    
    altera_tse_reset_synchronizer ch_10_reset_sync_0 (
        .clk(tbi_rx_clk_10),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_10_int)
        );

    always @(posedge tbi_rx_clk_10 or posedge reset_tbi_rx_clk_10_int)
        begin
        if (reset_tbi_rx_clk_10_int == 1)
            tbi_rx_d_flip_10 <= 0;
        else 
            begin
            tbi_rx_d_flip_10[0] <= tbi_rx_d_lvds_10[9];
            tbi_rx_d_flip_10[1] <= tbi_rx_d_lvds_10[8];
            tbi_rx_d_flip_10[2] <= tbi_rx_d_lvds_10[7];
            tbi_rx_d_flip_10[3] <= tbi_rx_d_lvds_10[6];
            tbi_rx_d_flip_10[4] <= tbi_rx_d_lvds_10[5];
            tbi_rx_d_flip_10[5] <= tbi_rx_d_lvds_10[4];
            tbi_rx_d_flip_10[6] <= tbi_rx_d_lvds_10[3];
            tbi_rx_d_flip_10[7] <= tbi_rx_d_lvds_10[2];
            tbi_rx_d_flip_10[8] <= tbi_rx_d_lvds_10[1];
            tbi_rx_d_flip_10[9] <= tbi_rx_d_lvds_10[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_10 <= 0;
        else 
            begin
            tbi_tx_d_flip_10[0] <= tbi_tx_d_10[9];
            tbi_tx_d_flip_10[1] <= tbi_tx_d_10[8];
            tbi_tx_d_flip_10[2] <= tbi_tx_d_10[7];
            tbi_tx_d_flip_10[3] <= tbi_tx_d_10[6];
            tbi_tx_d_flip_10[4] <= tbi_tx_d_10[5];
            tbi_tx_d_flip_10[5] <= tbi_tx_d_10[4];
            tbi_tx_d_flip_10[6] <= tbi_tx_d_10[3];
            tbi_tx_d_flip_10[7] <= tbi_tx_d_10[2];
            tbi_tx_d_flip_10[8] <= tbi_tx_d_10[1];
            tbi_tx_d_flip_10[9] <= tbi_tx_d_10[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_10
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_10 ),
         .rx_channel_data_align ( rx_channel_data_align_10 ),
         .rx_locked ( rx_locked_10 ),
         .rx_divfwdclk (tbi_rx_clk_10),
         .rx_in (rxp_10),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_10),
         .rx_outclock (),
         .rx_reset (rx_reset_10)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_10 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_10 ),
		.rx_channel_data_align ( rx_channel_data_align_10 ),
		.pll_areset ( pll_areset_10 ),
		.rx_reset ( rx_reset_10 ),
        .rx_cda_reset ( rx_cda_reset_10 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_10
    (
        .tx_in (tbi_tx_d_flip_10),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_10)
    );

    end   
else
    begin
    assign txp_10 = 1'b0;
    assign tbi_rx_clk_10 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 11 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 11)
    begin          
        assign gxb_pwrdn_in_sig[11] = gxb_pwrdn_in_11;
        assign pcs_pwrdn_out_11 = pcs_pwrdn_out_sig[11];
    end
else
    begin
        assign gxb_pwrdn_in_sig[11] = pcs_pwrdn_out_sig[11];
		assign pcs_pwrdn_out_11 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 11)
    begin          

    assign tbi_tx_clk_11 = ref_clk;
    assign tbi_rx_d_11 = tbi_rx_d_flip_11;
    
    altera_tse_reset_synchronizer ch_11_reset_sync_0 (
        .clk(tbi_rx_clk_11),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_11_int)
        );

    always @(posedge tbi_rx_clk_11 or posedge reset_tbi_rx_clk_11_int)
        begin
        if (reset_tbi_rx_clk_11_int == 1)
            tbi_rx_d_flip_11 <= 0;
        else 
            begin
            tbi_rx_d_flip_11[0] <= tbi_rx_d_lvds_11[9];
            tbi_rx_d_flip_11[1] <= tbi_rx_d_lvds_11[8];
            tbi_rx_d_flip_11[2] <= tbi_rx_d_lvds_11[7];
            tbi_rx_d_flip_11[3] <= tbi_rx_d_lvds_11[6];
            tbi_rx_d_flip_11[4] <= tbi_rx_d_lvds_11[5];
            tbi_rx_d_flip_11[5] <= tbi_rx_d_lvds_11[4];
            tbi_rx_d_flip_11[6] <= tbi_rx_d_lvds_11[3];
            tbi_rx_d_flip_11[7] <= tbi_rx_d_lvds_11[2];
            tbi_rx_d_flip_11[8] <= tbi_rx_d_lvds_11[1];
            tbi_rx_d_flip_11[9] <= tbi_rx_d_lvds_11[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_11 <= 0;
        else 
            begin
            tbi_tx_d_flip_11[0] <= tbi_tx_d_11[9];
            tbi_tx_d_flip_11[1] <= tbi_tx_d_11[8];
            tbi_tx_d_flip_11[2] <= tbi_tx_d_11[7];
            tbi_tx_d_flip_11[3] <= tbi_tx_d_11[6];
            tbi_tx_d_flip_11[4] <= tbi_tx_d_11[5];
            tbi_tx_d_flip_11[5] <= tbi_tx_d_11[4];
            tbi_tx_d_flip_11[6] <= tbi_tx_d_11[3];
            tbi_tx_d_flip_11[7] <= tbi_tx_d_11[2];
            tbi_tx_d_flip_11[8] <= tbi_tx_d_11[1];
            tbi_tx_d_flip_11[9] <= tbi_tx_d_11[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_11
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_11 ),
         .rx_channel_data_align ( rx_channel_data_align_11 ),
         .rx_locked ( rx_locked_11 ),
         .rx_divfwdclk (tbi_rx_clk_11),
         .rx_in (rxp_11),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_11),
         .rx_outclock (),
         .rx_reset (rx_reset_11)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_11 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_11 ),
		.rx_channel_data_align ( rx_channel_data_align_11 ),
		.pll_areset ( pll_areset_11 ),
		.rx_reset ( rx_reset_11 ),
        .rx_cda_reset ( rx_cda_reset_11 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_11
    (
        .tx_in (tbi_tx_d_flip_11),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_11)
    );

    end   
else
    begin
    assign txp_11 = 1'b0;
    assign tbi_rx_clk_11 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 12 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 12)
    begin          
        assign gxb_pwrdn_in_sig[12] = gxb_pwrdn_in_12;
        assign pcs_pwrdn_out_12 = pcs_pwrdn_out_sig[12];
    end
else
    begin
        assign gxb_pwrdn_in_sig[12] = pcs_pwrdn_out_sig[12];
		assign pcs_pwrdn_out_12 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 12)
    begin          

    assign tbi_tx_clk_12 = ref_clk;
    assign tbi_rx_d_12 = tbi_rx_d_flip_12;
    
    altera_tse_reset_synchronizer ch_12_reset_sync_0 (
        .clk(tbi_rx_clk_12),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_12_int)
        );

    always @(posedge tbi_rx_clk_12 or posedge reset_tbi_rx_clk_12_int)
        begin
        if (reset_tbi_rx_clk_12_int == 1)
            tbi_rx_d_flip_12 <= 0;
        else 
            begin
            tbi_rx_d_flip_12[0] <= tbi_rx_d_lvds_12[9];
            tbi_rx_d_flip_12[1] <= tbi_rx_d_lvds_12[8];
            tbi_rx_d_flip_12[2] <= tbi_rx_d_lvds_12[7];
            tbi_rx_d_flip_12[3] <= tbi_rx_d_lvds_12[6];
            tbi_rx_d_flip_12[4] <= tbi_rx_d_lvds_12[5];
            tbi_rx_d_flip_12[5] <= tbi_rx_d_lvds_12[4];
            tbi_rx_d_flip_12[6] <= tbi_rx_d_lvds_12[3];
            tbi_rx_d_flip_12[7] <= tbi_rx_d_lvds_12[2];
            tbi_rx_d_flip_12[8] <= tbi_rx_d_lvds_12[1];
            tbi_rx_d_flip_12[9] <= tbi_rx_d_lvds_12[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_12 <= 0;
        else 
            begin
            tbi_tx_d_flip_12[0] <= tbi_tx_d_12[9];
            tbi_tx_d_flip_12[1] <= tbi_tx_d_12[8];
            tbi_tx_d_flip_12[2] <= tbi_tx_d_12[7];
            tbi_tx_d_flip_12[3] <= tbi_tx_d_12[6];
            tbi_tx_d_flip_12[4] <= tbi_tx_d_12[5];
            tbi_tx_d_flip_12[5] <= tbi_tx_d_12[4];
            tbi_tx_d_flip_12[6] <= tbi_tx_d_12[3];
            tbi_tx_d_flip_12[7] <= tbi_tx_d_12[2];
            tbi_tx_d_flip_12[8] <= tbi_tx_d_12[1];
            tbi_tx_d_flip_12[9] <= tbi_tx_d_12[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_12
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_12 ),
         .rx_channel_data_align ( rx_channel_data_align_12 ),
         .rx_locked ( rx_locked_12 ),
         .rx_divfwdclk (tbi_rx_clk_12),
         .rx_in (rxp_12),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_12),
         .rx_outclock (),
         .rx_reset (rx_reset_12)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_12 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_12 ),
		.rx_channel_data_align ( rx_channel_data_align_12 ),
		.pll_areset ( pll_areset_12 ),
		.rx_reset ( rx_reset_12 ),
        .rx_cda_reset ( rx_cda_reset_12 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_12
    (
        .tx_in (tbi_tx_d_flip_12),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_12)
    );

    end   
else
    begin
    assign txp_12 = 1'b0;
    assign tbi_rx_clk_12 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 13 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 13)
    begin          
        assign gxb_pwrdn_in_sig[13] = gxb_pwrdn_in_13;
        assign pcs_pwrdn_out_13 = pcs_pwrdn_out_sig[13];
    end
else
    begin
        assign gxb_pwrdn_in_sig[13] = pcs_pwrdn_out_sig[13];
		assign pcs_pwrdn_out_13 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 13)
    begin          

    assign tbi_tx_clk_13 = ref_clk;
    assign tbi_rx_d_13 = tbi_rx_d_flip_13;
    
    altera_tse_reset_synchronizer ch_13_reset_sync_0 (
        .clk(tbi_rx_clk_13),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_13_int)
        );

    always @(posedge tbi_rx_clk_13 or posedge reset_tbi_rx_clk_13_int)
        begin
        if (reset_tbi_rx_clk_13_int == 1)
            tbi_rx_d_flip_13 <= 0;
        else 
            begin
            tbi_rx_d_flip_13[0] <= tbi_rx_d_lvds_13[9];
            tbi_rx_d_flip_13[1] <= tbi_rx_d_lvds_13[8];
            tbi_rx_d_flip_13[2] <= tbi_rx_d_lvds_13[7];
            tbi_rx_d_flip_13[3] <= tbi_rx_d_lvds_13[6];
            tbi_rx_d_flip_13[4] <= tbi_rx_d_lvds_13[5];
            tbi_rx_d_flip_13[5] <= tbi_rx_d_lvds_13[4];
            tbi_rx_d_flip_13[6] <= tbi_rx_d_lvds_13[3];
            tbi_rx_d_flip_13[7] <= tbi_rx_d_lvds_13[2];
            tbi_rx_d_flip_13[8] <= tbi_rx_d_lvds_13[1];
            tbi_rx_d_flip_13[9] <= tbi_rx_d_lvds_13[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_13 <= 0;
        else 
            begin
            tbi_tx_d_flip_13[0] <= tbi_tx_d_13[9];
            tbi_tx_d_flip_13[1] <= tbi_tx_d_13[8];
            tbi_tx_d_flip_13[2] <= tbi_tx_d_13[7];
            tbi_tx_d_flip_13[3] <= tbi_tx_d_13[6];
            tbi_tx_d_flip_13[4] <= tbi_tx_d_13[5];
            tbi_tx_d_flip_13[5] <= tbi_tx_d_13[4];
            tbi_tx_d_flip_13[6] <= tbi_tx_d_13[3];
            tbi_tx_d_flip_13[7] <= tbi_tx_d_13[2];
            tbi_tx_d_flip_13[8] <= tbi_tx_d_13[1];
            tbi_tx_d_flip_13[9] <= tbi_tx_d_13[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_13
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_13 ),
         .rx_channel_data_align ( rx_channel_data_align_13 ),
         .rx_locked ( rx_locked_13 ),
         .rx_divfwdclk (tbi_rx_clk_13),
         .rx_in (rxp_13),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_13),
         .rx_outclock (),
         .rx_reset (rx_reset_13)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_13 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_13 ),
		.rx_channel_data_align ( rx_channel_data_align_13 ),
		.pll_areset ( pll_areset_13 ),
		.rx_reset ( rx_reset_13 ),
        .rx_cda_reset ( rx_cda_reset_13 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_13
    (
        .tx_in (tbi_tx_d_flip_13),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_13)
    );

    end   
else
    begin
    assign txp_13 = 1'b0;
    assign tbi_rx_clk_13 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 14 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 14)
    begin          
        assign gxb_pwrdn_in_sig[14] = gxb_pwrdn_in_14;
        assign pcs_pwrdn_out_14 = pcs_pwrdn_out_sig[14];
    end
else
    begin
        assign gxb_pwrdn_in_sig[14] = pcs_pwrdn_out_sig[14];
		assign pcs_pwrdn_out_14 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 14)
    begin          

    assign tbi_tx_clk_14 = ref_clk;
    assign tbi_rx_d_14 = tbi_rx_d_flip_14;
    
    altera_tse_reset_synchronizer ch_14_reset_sync_0 (
        .clk(tbi_rx_clk_14),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_14_int)
        );

    always @(posedge tbi_rx_clk_14 or posedge reset_tbi_rx_clk_14_int)
        begin
        if (reset_tbi_rx_clk_14_int == 1)
            tbi_rx_d_flip_14 <= 0;
        else 
            begin
            tbi_rx_d_flip_14[0] <= tbi_rx_d_lvds_14[9];
            tbi_rx_d_flip_14[1] <= tbi_rx_d_lvds_14[8];
            tbi_rx_d_flip_14[2] <= tbi_rx_d_lvds_14[7];
            tbi_rx_d_flip_14[3] <= tbi_rx_d_lvds_14[6];
            tbi_rx_d_flip_14[4] <= tbi_rx_d_lvds_14[5];
            tbi_rx_d_flip_14[5] <= tbi_rx_d_lvds_14[4];
            tbi_rx_d_flip_14[6] <= tbi_rx_d_lvds_14[3];
            tbi_rx_d_flip_14[7] <= tbi_rx_d_lvds_14[2];
            tbi_rx_d_flip_14[8] <= tbi_rx_d_lvds_14[1];
            tbi_rx_d_flip_14[9] <= tbi_rx_d_lvds_14[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_14 <= 0;
        else 
            begin
            tbi_tx_d_flip_14[0] <= tbi_tx_d_14[9];
            tbi_tx_d_flip_14[1] <= tbi_tx_d_14[8];
            tbi_tx_d_flip_14[2] <= tbi_tx_d_14[7];
            tbi_tx_d_flip_14[3] <= tbi_tx_d_14[6];
            tbi_tx_d_flip_14[4] <= tbi_tx_d_14[5];
            tbi_tx_d_flip_14[5] <= tbi_tx_d_14[4];
            tbi_tx_d_flip_14[6] <= tbi_tx_d_14[3];
            tbi_tx_d_flip_14[7] <= tbi_tx_d_14[2];
            tbi_tx_d_flip_14[8] <= tbi_tx_d_14[1];
            tbi_tx_d_flip_14[9] <= tbi_tx_d_14[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_14
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_14 ),
         .rx_channel_data_align ( rx_channel_data_align_14 ),
         .rx_locked ( rx_locked_14 ),
         .rx_divfwdclk (tbi_rx_clk_14),
         .rx_in (rxp_14),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_14),
         .rx_outclock (),
         .rx_reset (rx_reset_14)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_14 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_14 ),
		.rx_channel_data_align ( rx_channel_data_align_14 ),
		.pll_areset ( pll_areset_14 ),
		.rx_reset ( rx_reset_14 ),
        .rx_cda_reset ( rx_cda_reset_14 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_14
    (
        .tx_in (tbi_tx_d_flip_14),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_14)
    );

    end   
else
    begin
    assign txp_14 = 1'b0;
    assign tbi_rx_clk_14 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 15 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 15)
    begin          
        assign gxb_pwrdn_in_sig[15] = gxb_pwrdn_in_15;
        assign pcs_pwrdn_out_15 = pcs_pwrdn_out_sig[15];
    end
else
    begin
        assign gxb_pwrdn_in_sig[15] = pcs_pwrdn_out_sig[15];
		assign pcs_pwrdn_out_15 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 15)
    begin          

    assign tbi_tx_clk_15 = ref_clk;
    assign tbi_rx_d_15 = tbi_rx_d_flip_15;

    altera_tse_reset_synchronizer ch_15_reset_sync_0 (
        .clk(tbi_rx_clk_15),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_15_int)
        );
    
    always @(posedge tbi_rx_clk_15 or posedge reset_tbi_rx_clk_15_int)
        begin
        if (reset_tbi_rx_clk_15_int == 1)
            tbi_rx_d_flip_15 <= 0;
        else 
            begin
            tbi_rx_d_flip_15[0] <= tbi_rx_d_lvds_15[9];
            tbi_rx_d_flip_15[1] <= tbi_rx_d_lvds_15[8];
            tbi_rx_d_flip_15[2] <= tbi_rx_d_lvds_15[7];
            tbi_rx_d_flip_15[3] <= tbi_rx_d_lvds_15[6];
            tbi_rx_d_flip_15[4] <= tbi_rx_d_lvds_15[5];
            tbi_rx_d_flip_15[5] <= tbi_rx_d_lvds_15[4];
            tbi_rx_d_flip_15[6] <= tbi_rx_d_lvds_15[3];
            tbi_rx_d_flip_15[7] <= tbi_rx_d_lvds_15[2];
            tbi_rx_d_flip_15[8] <= tbi_rx_d_lvds_15[1];
            tbi_rx_d_flip_15[9] <= tbi_rx_d_lvds_15[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_15 <= 0;
        else 
            begin
            tbi_tx_d_flip_15[0] <= tbi_tx_d_15[9];
            tbi_tx_d_flip_15[1] <= tbi_tx_d_15[8];
            tbi_tx_d_flip_15[2] <= tbi_tx_d_15[7];
            tbi_tx_d_flip_15[3] <= tbi_tx_d_15[6];
            tbi_tx_d_flip_15[4] <= tbi_tx_d_15[5];
            tbi_tx_d_flip_15[5] <= tbi_tx_d_15[4];
            tbi_tx_d_flip_15[6] <= tbi_tx_d_15[3];
            tbi_tx_d_flip_15[7] <= tbi_tx_d_15[2];
            tbi_tx_d_flip_15[8] <= tbi_tx_d_15[1];
            tbi_tx_d_flip_15[9] <= tbi_tx_d_15[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_15
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_15 ),
         .rx_channel_data_align ( rx_channel_data_align_15 ),
         .rx_locked ( rx_locked_15 ),
         .rx_divfwdclk (tbi_rx_clk_15),
         .rx_in (rxp_15),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_15),
         .rx_outclock (),
         .rx_reset (rx_reset_15)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_15 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_15 ),
		.rx_channel_data_align ( rx_channel_data_align_15 ),
		.pll_areset ( pll_areset_15 ),
		.rx_reset ( rx_reset_15 ),
        .rx_cda_reset ( rx_cda_reset_15 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_15
    (
        .tx_in (tbi_tx_d_flip_15),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_15)
    );

    end   
else
    begin
    assign txp_15 = 1'b0;
    assign tbi_rx_clk_15 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 16 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 16)
    begin          
        assign gxb_pwrdn_in_sig[16] = gxb_pwrdn_in_16;
        assign pcs_pwrdn_out_16 = pcs_pwrdn_out_sig[16];
    end
else
    begin
        assign gxb_pwrdn_in_sig[16] = pcs_pwrdn_out_sig[16];
		assign pcs_pwrdn_out_16 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 16)
    begin          

    assign tbi_tx_clk_16 = ref_clk;
    assign tbi_rx_d_16 = tbi_rx_d_flip_16;
    
    altera_tse_reset_synchronizer ch_16_reset_sync_0 (
        .clk(tbi_rx_clk_16),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_16_int)
        );

    always @(posedge tbi_rx_clk_16 or posedge reset_tbi_rx_clk_16_int)
        begin
        if (reset_tbi_rx_clk_16_int == 1)
            tbi_rx_d_flip_16 <= 0;
        else 
            begin
            tbi_rx_d_flip_16[0] <= tbi_rx_d_lvds_16[9];
            tbi_rx_d_flip_16[1] <= tbi_rx_d_lvds_16[8];
            tbi_rx_d_flip_16[2] <= tbi_rx_d_lvds_16[7];
            tbi_rx_d_flip_16[3] <= tbi_rx_d_lvds_16[6];
            tbi_rx_d_flip_16[4] <= tbi_rx_d_lvds_16[5];
            tbi_rx_d_flip_16[5] <= tbi_rx_d_lvds_16[4];
            tbi_rx_d_flip_16[6] <= tbi_rx_d_lvds_16[3];
            tbi_rx_d_flip_16[7] <= tbi_rx_d_lvds_16[2];
            tbi_rx_d_flip_16[8] <= tbi_rx_d_lvds_16[1];
            tbi_rx_d_flip_16[9] <= tbi_rx_d_lvds_16[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_16 <= 0;
        else 
            begin
            tbi_tx_d_flip_16[0] <= tbi_tx_d_16[9];
            tbi_tx_d_flip_16[1] <= tbi_tx_d_16[8];
            tbi_tx_d_flip_16[2] <= tbi_tx_d_16[7];
            tbi_tx_d_flip_16[3] <= tbi_tx_d_16[6];
            tbi_tx_d_flip_16[4] <= tbi_tx_d_16[5];
            tbi_tx_d_flip_16[5] <= tbi_tx_d_16[4];
            tbi_tx_d_flip_16[6] <= tbi_tx_d_16[3];
            tbi_tx_d_flip_16[7] <= tbi_tx_d_16[2];
            tbi_tx_d_flip_16[8] <= tbi_tx_d_16[1];
            tbi_tx_d_flip_16[9] <= tbi_tx_d_16[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_16
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_16 ),
         .rx_channel_data_align ( rx_channel_data_align_16 ),
         .rx_locked ( rx_locked_16 ),
         .rx_divfwdclk (tbi_rx_clk_16),
         .rx_in (rxp_16),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_16),
         .rx_outclock (),
         .rx_reset (rx_reset_16)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_16 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_16 ),
		.rx_channel_data_align ( rx_channel_data_align_16 ),
		.pll_areset ( pll_areset_16 ),
		.rx_reset ( rx_reset_16 ),
        .rx_cda_reset ( rx_cda_reset_16 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_16
    (
        .tx_in (tbi_tx_d_flip_16),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_16)
    );

    end   
else
    begin
    assign txp_16 = 1'b0;
    assign tbi_rx_clk_16 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 17 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 17)
    begin          
        assign gxb_pwrdn_in_sig[17] = gxb_pwrdn_in_17;
        assign pcs_pwrdn_out_17 = pcs_pwrdn_out_sig[17];
    end
else
    begin
        assign gxb_pwrdn_in_sig[17] = pcs_pwrdn_out_sig[17];
		assign pcs_pwrdn_out_17 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 17)
    begin          

    assign tbi_tx_clk_17 = ref_clk;
    assign tbi_rx_d_17 = tbi_rx_d_flip_17;
    
    altera_tse_reset_synchronizer ch_17_reset_sync_0 (
        .clk(tbi_rx_clk_17),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_17_int)
        );

    always @(posedge tbi_rx_clk_17 or posedge reset_tbi_rx_clk_17_int)
        begin
        if (reset_tbi_rx_clk_17_int == 1)
            tbi_rx_d_flip_17 <= 0;
        else 
            begin
            tbi_rx_d_flip_17[0] <= tbi_rx_d_lvds_17[9];
            tbi_rx_d_flip_17[1] <= tbi_rx_d_lvds_17[8];
            tbi_rx_d_flip_17[2] <= tbi_rx_d_lvds_17[7];
            tbi_rx_d_flip_17[3] <= tbi_rx_d_lvds_17[6];
            tbi_rx_d_flip_17[4] <= tbi_rx_d_lvds_17[5];
            tbi_rx_d_flip_17[5] <= tbi_rx_d_lvds_17[4];
            tbi_rx_d_flip_17[6] <= tbi_rx_d_lvds_17[3];
            tbi_rx_d_flip_17[7] <= tbi_rx_d_lvds_17[2];
            tbi_rx_d_flip_17[8] <= tbi_rx_d_lvds_17[1];
            tbi_rx_d_flip_17[9] <= tbi_rx_d_lvds_17[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_17 <= 0;
        else 
            begin
            tbi_tx_d_flip_17[0] <= tbi_tx_d_17[9];
            tbi_tx_d_flip_17[1] <= tbi_tx_d_17[8];
            tbi_tx_d_flip_17[2] <= tbi_tx_d_17[7];
            tbi_tx_d_flip_17[3] <= tbi_tx_d_17[6];
            tbi_tx_d_flip_17[4] <= tbi_tx_d_17[5];
            tbi_tx_d_flip_17[5] <= tbi_tx_d_17[4];
            tbi_tx_d_flip_17[6] <= tbi_tx_d_17[3];
            tbi_tx_d_flip_17[7] <= tbi_tx_d_17[2];
            tbi_tx_d_flip_17[8] <= tbi_tx_d_17[1];
            tbi_tx_d_flip_17[9] <= tbi_tx_d_17[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_17
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_17 ),
         .rx_channel_data_align ( rx_channel_data_align_17 ),
         .rx_locked ( rx_locked_17 ),
         .rx_divfwdclk (tbi_rx_clk_17),
         .rx_in (rxp_17),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_17),
         .rx_outclock (),
         .rx_reset (rx_reset_17)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_17 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_17 ),
		.rx_channel_data_align ( rx_channel_data_align_17 ),
		.pll_areset ( pll_areset_17 ),
		.rx_reset ( rx_reset_17 ),
        .rx_cda_reset ( rx_cda_reset_17 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_17
    (
        .tx_in (tbi_tx_d_flip_17),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_17)
    );

    end   
else
    begin
    assign txp_17 = 1'b0;
    assign tbi_rx_clk_17 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 18 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 18)
    begin          
        assign gxb_pwrdn_in_sig[18] = gxb_pwrdn_in_18;
        assign pcs_pwrdn_out_18 = pcs_pwrdn_out_sig[18];
    end
else
    begin
        assign gxb_pwrdn_in_sig[18] = pcs_pwrdn_out_sig[18];
		assign pcs_pwrdn_out_18 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 18)
    begin          

    assign tbi_tx_clk_18 = ref_clk;
    assign tbi_rx_d_18 = tbi_rx_d_flip_18;
    
    altera_tse_reset_synchronizer ch_18_reset_sync_0 (
        .clk(tbi_rx_clk_18),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_18_int)
        );

    always @(posedge tbi_rx_clk_18 or posedge reset_tbi_rx_clk_18_int)
        begin
        if (reset_tbi_rx_clk_18_int == 1)
            tbi_rx_d_flip_18 <= 0;
        else 
            begin
            tbi_rx_d_flip_18[0] <= tbi_rx_d_lvds_18[9];
            tbi_rx_d_flip_18[1] <= tbi_rx_d_lvds_18[8];
            tbi_rx_d_flip_18[2] <= tbi_rx_d_lvds_18[7];
            tbi_rx_d_flip_18[3] <= tbi_rx_d_lvds_18[6];
            tbi_rx_d_flip_18[4] <= tbi_rx_d_lvds_18[5];
            tbi_rx_d_flip_18[5] <= tbi_rx_d_lvds_18[4];
            tbi_rx_d_flip_18[6] <= tbi_rx_d_lvds_18[3];
            tbi_rx_d_flip_18[7] <= tbi_rx_d_lvds_18[2];
            tbi_rx_d_flip_18[8] <= tbi_rx_d_lvds_18[1];
            tbi_rx_d_flip_18[9] <= tbi_rx_d_lvds_18[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_18 <= 0;
        else 
            begin
            tbi_tx_d_flip_18[0] <= tbi_tx_d_18[9];
            tbi_tx_d_flip_18[1] <= tbi_tx_d_18[8];
            tbi_tx_d_flip_18[2] <= tbi_tx_d_18[7];
            tbi_tx_d_flip_18[3] <= tbi_tx_d_18[6];
            tbi_tx_d_flip_18[4] <= tbi_tx_d_18[5];
            tbi_tx_d_flip_18[5] <= tbi_tx_d_18[4];
            tbi_tx_d_flip_18[6] <= tbi_tx_d_18[3];
            tbi_tx_d_flip_18[7] <= tbi_tx_d_18[2];
            tbi_tx_d_flip_18[8] <= tbi_tx_d_18[1];
            tbi_tx_d_flip_18[9] <= tbi_tx_d_18[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_18
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_18 ),
         .rx_channel_data_align ( rx_channel_data_align_18 ),
         .rx_locked ( rx_locked_18 ),
         .rx_divfwdclk (tbi_rx_clk_18),
         .rx_in (rxp_18),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_18),
         .rx_outclock (),
         .rx_reset (rx_reset_18)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_18 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_18 ),
		.rx_channel_data_align ( rx_channel_data_align_18 ),
		.pll_areset ( pll_areset_18 ),
		.rx_reset ( rx_reset_18 ),
        .rx_cda_reset ( rx_cda_reset_18 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_18
    (
        .tx_in (tbi_tx_d_flip_18),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_18)
    );

    end   
else
    begin
    assign txp_18 = 1'b0;
    assign tbi_rx_clk_18 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 19 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 19)
    begin          
        assign gxb_pwrdn_in_sig[19] = gxb_pwrdn_in_19;
        assign pcs_pwrdn_out_19 = pcs_pwrdn_out_sig[19];
    end
else
    begin
        assign gxb_pwrdn_in_sig[19] = pcs_pwrdn_out_sig[19];
		assign pcs_pwrdn_out_19 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 19)
    begin          

    assign tbi_tx_clk_19 = ref_clk;
    assign tbi_rx_d_19 = tbi_rx_d_flip_19;
    
    altera_tse_reset_synchronizer ch_19_reset_sync_0 (
        .clk(tbi_rx_clk_19),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_19_int)
        );

    always @(posedge tbi_rx_clk_19 or posedge reset_tbi_rx_clk_19_int)
        begin
        if (reset_tbi_rx_clk_19_int == 1)
            tbi_rx_d_flip_19 <= 0;
        else 
            begin
            tbi_rx_d_flip_19[0] <= tbi_rx_d_lvds_19[9];
            tbi_rx_d_flip_19[1] <= tbi_rx_d_lvds_19[8];
            tbi_rx_d_flip_19[2] <= tbi_rx_d_lvds_19[7];
            tbi_rx_d_flip_19[3] <= tbi_rx_d_lvds_19[6];
            tbi_rx_d_flip_19[4] <= tbi_rx_d_lvds_19[5];
            tbi_rx_d_flip_19[5] <= tbi_rx_d_lvds_19[4];
            tbi_rx_d_flip_19[6] <= tbi_rx_d_lvds_19[3];
            tbi_rx_d_flip_19[7] <= tbi_rx_d_lvds_19[2];
            tbi_rx_d_flip_19[8] <= tbi_rx_d_lvds_19[1];
            tbi_rx_d_flip_19[9] <= tbi_rx_d_lvds_19[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_19 <= 0;
        else 
            begin
            tbi_tx_d_flip_19[0] <= tbi_tx_d_19[9];
            tbi_tx_d_flip_19[1] <= tbi_tx_d_19[8];
            tbi_tx_d_flip_19[2] <= tbi_tx_d_19[7];
            tbi_tx_d_flip_19[3] <= tbi_tx_d_19[6];
            tbi_tx_d_flip_19[4] <= tbi_tx_d_19[5];
            tbi_tx_d_flip_19[5] <= tbi_tx_d_19[4];
            tbi_tx_d_flip_19[6] <= tbi_tx_d_19[3];
            tbi_tx_d_flip_19[7] <= tbi_tx_d_19[2];
            tbi_tx_d_flip_19[8] <= tbi_tx_d_19[1];
            tbi_tx_d_flip_19[9] <= tbi_tx_d_19[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_19
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_19 ),
         .rx_channel_data_align ( rx_channel_data_align_19 ),
         .rx_locked ( rx_locked_19 ),
         .rx_divfwdclk (tbi_rx_clk_19),
         .rx_in (rxp_19),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_19),
         .rx_outclock (),
         .rx_reset (rx_reset_19)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_19 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_19 ),
		.rx_channel_data_align ( rx_channel_data_align_19 ),
		.pll_areset ( pll_areset_19 ),
		.rx_reset ( rx_reset_19 ),
        .rx_cda_reset ( rx_cda_reset_19 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_19
    (
        .tx_in (tbi_tx_d_flip_19),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_19)
    );

    end   
else
    begin
    assign txp_19 = 1'b0;
    assign tbi_rx_clk_19 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 20 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 20)
    begin          
        assign gxb_pwrdn_in_sig[20] = gxb_pwrdn_in_20;
        assign pcs_pwrdn_out_20 = pcs_pwrdn_out_sig[20];
    end
else
    begin
        assign gxb_pwrdn_in_sig[20] = pcs_pwrdn_out_sig[20];
		assign pcs_pwrdn_out_20 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 20)
    begin          

    assign tbi_tx_clk_20 = ref_clk;
    assign tbi_rx_d_20 = tbi_rx_d_flip_20;
    
    altera_tse_reset_synchronizer ch_20_reset_sync_0 (
        .clk(tbi_rx_clk_20),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_20_int)
        );

    always @(posedge tbi_rx_clk_20 or posedge reset_tbi_rx_clk_20_int)
        begin
        if (reset_tbi_rx_clk_20_int == 1)
            tbi_rx_d_flip_20 <= 0;
        else 
            begin
            tbi_rx_d_flip_20[0] <= tbi_rx_d_lvds_20[9];
            tbi_rx_d_flip_20[1] <= tbi_rx_d_lvds_20[8];
            tbi_rx_d_flip_20[2] <= tbi_rx_d_lvds_20[7];
            tbi_rx_d_flip_20[3] <= tbi_rx_d_lvds_20[6];
            tbi_rx_d_flip_20[4] <= tbi_rx_d_lvds_20[5];
            tbi_rx_d_flip_20[5] <= tbi_rx_d_lvds_20[4];
            tbi_rx_d_flip_20[6] <= tbi_rx_d_lvds_20[3];
            tbi_rx_d_flip_20[7] <= tbi_rx_d_lvds_20[2];
            tbi_rx_d_flip_20[8] <= tbi_rx_d_lvds_20[1];
            tbi_rx_d_flip_20[9] <= tbi_rx_d_lvds_20[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_20 <= 0;
        else 
            begin
            tbi_tx_d_flip_20[0] <= tbi_tx_d_20[9];
            tbi_tx_d_flip_20[1] <= tbi_tx_d_20[8];
            tbi_tx_d_flip_20[2] <= tbi_tx_d_20[7];
            tbi_tx_d_flip_20[3] <= tbi_tx_d_20[6];
            tbi_tx_d_flip_20[4] <= tbi_tx_d_20[5];
            tbi_tx_d_flip_20[5] <= tbi_tx_d_20[4];
            tbi_tx_d_flip_20[6] <= tbi_tx_d_20[3];
            tbi_tx_d_flip_20[7] <= tbi_tx_d_20[2];
            tbi_tx_d_flip_20[8] <= tbi_tx_d_20[1];
            tbi_tx_d_flip_20[9] <= tbi_tx_d_20[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_20
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_20 ),
         .rx_channel_data_align ( rx_channel_data_align_20 ),
         .rx_locked ( rx_locked_20 ),
         .rx_divfwdclk (tbi_rx_clk_20),
         .rx_in (rxp_20),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_20),
         .rx_outclock (),
         .rx_reset (rx_reset_20)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_20 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_20 ),
		.rx_channel_data_align ( rx_channel_data_align_20 ),
		.pll_areset ( pll_areset_20 ),
		.rx_reset ( rx_reset_20 ),
        .rx_cda_reset ( rx_cda_reset_20 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_20
    (
        .tx_in (tbi_tx_d_flip_20),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_20)
    );

    end   
else
    begin
    assign txp_20 = 1'b0;
    assign tbi_rx_clk_20 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 21 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 21)
    begin          
        assign gxb_pwrdn_in_sig[21] = gxb_pwrdn_in_21;
        assign pcs_pwrdn_out_21 = pcs_pwrdn_out_sig[21];
    end
else
    begin
        assign gxb_pwrdn_in_sig[21] = pcs_pwrdn_out_sig[21];
		assign pcs_pwrdn_out_21 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 21)
    begin          

    assign tbi_tx_clk_21 = ref_clk;
    assign tbi_rx_d_21 = tbi_rx_d_flip_21;
    
    altera_tse_reset_synchronizer ch_21_reset_sync_0 (
        .clk(tbi_rx_clk_21),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_21_int)
        );

    always @(posedge tbi_rx_clk_21 or posedge reset_tbi_rx_clk_21_int)
        begin
        if (reset_tbi_rx_clk_21_int == 1)
            tbi_rx_d_flip_21 <= 0;
        else 
            begin
            tbi_rx_d_flip_21[0] <= tbi_rx_d_lvds_21[9];
            tbi_rx_d_flip_21[1] <= tbi_rx_d_lvds_21[8];
            tbi_rx_d_flip_21[2] <= tbi_rx_d_lvds_21[7];
            tbi_rx_d_flip_21[3] <= tbi_rx_d_lvds_21[6];
            tbi_rx_d_flip_21[4] <= tbi_rx_d_lvds_21[5];
            tbi_rx_d_flip_21[5] <= tbi_rx_d_lvds_21[4];
            tbi_rx_d_flip_21[6] <= tbi_rx_d_lvds_21[3];
            tbi_rx_d_flip_21[7] <= tbi_rx_d_lvds_21[2];
            tbi_rx_d_flip_21[8] <= tbi_rx_d_lvds_21[1];
            tbi_rx_d_flip_21[9] <= tbi_rx_d_lvds_21[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_21 <= 0;
        else 
            begin
            tbi_tx_d_flip_21[0] <= tbi_tx_d_21[9];
            tbi_tx_d_flip_21[1] <= tbi_tx_d_21[8];
            tbi_tx_d_flip_21[2] <= tbi_tx_d_21[7];
            tbi_tx_d_flip_21[3] <= tbi_tx_d_21[6];
            tbi_tx_d_flip_21[4] <= tbi_tx_d_21[5];
            tbi_tx_d_flip_21[5] <= tbi_tx_d_21[4];
            tbi_tx_d_flip_21[6] <= tbi_tx_d_21[3];
            tbi_tx_d_flip_21[7] <= tbi_tx_d_21[2];
            tbi_tx_d_flip_21[8] <= tbi_tx_d_21[1];
            tbi_tx_d_flip_21[9] <= tbi_tx_d_21[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_21
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_21 ),
         .rx_channel_data_align ( rx_channel_data_align_21 ),
         .rx_locked ( rx_locked_21 ),
         .rx_divfwdclk (tbi_rx_clk_21),
         .rx_in (rxp_21),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_21),
         .rx_outclock (),
         .rx_reset (rx_reset_21)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_21 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_21 ),
		.rx_channel_data_align ( rx_channel_data_align_21 ),
		.pll_areset ( pll_areset_21 ),
		.rx_reset ( rx_reset_21 ),
        .rx_cda_reset ( rx_cda_reset_21 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_21
    (
        .tx_in (tbi_tx_d_flip_21),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_21)
    );

    end   
else
    begin
    assign txp_21 = 1'b0;
    assign tbi_rx_clk_21 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 22 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 22)
    begin          
        assign gxb_pwrdn_in_sig[22] = gxb_pwrdn_in_22;
        assign pcs_pwrdn_out_22 = pcs_pwrdn_out_sig[22];
    end
else
    begin
        assign gxb_pwrdn_in_sig[22] = pcs_pwrdn_out_sig[22];
		assign pcs_pwrdn_out_22 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 22)
    begin          

    assign tbi_tx_clk_22 = ref_clk;
    assign tbi_rx_d_22 = tbi_rx_d_flip_22;
    
    altera_tse_reset_synchronizer ch_22_reset_sync_0 (
        .clk(tbi_rx_clk_22),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_22_int)
        );

    always @(posedge tbi_rx_clk_22 or posedge reset_tbi_rx_clk_22_int)
        begin
        if (reset_tbi_rx_clk_22_int == 1)
            tbi_rx_d_flip_22 <= 0;
        else 
            begin
            tbi_rx_d_flip_22[0] <= tbi_rx_d_lvds_22[9];
            tbi_rx_d_flip_22[1] <= tbi_rx_d_lvds_22[8];
            tbi_rx_d_flip_22[2] <= tbi_rx_d_lvds_22[7];
            tbi_rx_d_flip_22[3] <= tbi_rx_d_lvds_22[6];
            tbi_rx_d_flip_22[4] <= tbi_rx_d_lvds_22[5];
            tbi_rx_d_flip_22[5] <= tbi_rx_d_lvds_22[4];
            tbi_rx_d_flip_22[6] <= tbi_rx_d_lvds_22[3];
            tbi_rx_d_flip_22[7] <= tbi_rx_d_lvds_22[2];
            tbi_rx_d_flip_22[8] <= tbi_rx_d_lvds_22[1];
            tbi_rx_d_flip_22[9] <= tbi_rx_d_lvds_22[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_22 <= 0;
        else 
            begin
            tbi_tx_d_flip_22[0] <= tbi_tx_d_22[9];
            tbi_tx_d_flip_22[1] <= tbi_tx_d_22[8];
            tbi_tx_d_flip_22[2] <= tbi_tx_d_22[7];
            tbi_tx_d_flip_22[3] <= tbi_tx_d_22[6];
            tbi_tx_d_flip_22[4] <= tbi_tx_d_22[5];
            tbi_tx_d_flip_22[5] <= tbi_tx_d_22[4];
            tbi_tx_d_flip_22[6] <= tbi_tx_d_22[3];
            tbi_tx_d_flip_22[7] <= tbi_tx_d_22[2];
            tbi_tx_d_flip_22[8] <= tbi_tx_d_22[1];
            tbi_tx_d_flip_22[9] <= tbi_tx_d_22[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_22
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_22 ),
         .rx_channel_data_align ( rx_channel_data_align_22 ),
         .rx_locked ( rx_locked_22 ),
         .rx_divfwdclk (tbi_rx_clk_22),
         .rx_in (rxp_22),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_22),
         .rx_outclock (),
         .rx_reset (rx_reset_22)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_22 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_22 ),
		.rx_channel_data_align ( rx_channel_data_align_22 ),
		.pll_areset ( pll_areset_22 ),
		.rx_reset ( rx_reset_22 ),
        .rx_cda_reset ( rx_cda_reset_22 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_22
    (
        .tx_in (tbi_tx_d_flip_22),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_22)
    );

    end   
else
    begin
    assign txp_22 = 1'b0;
    assign tbi_rx_clk_22 = 1'b0;	
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 23 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 23)
    begin          
        assign gxb_pwrdn_in_sig[23] = gxb_pwrdn_in_23;
        assign pcs_pwrdn_out_23 = pcs_pwrdn_out_sig[23];
    end
else
    begin
        assign gxb_pwrdn_in_sig[23] = pcs_pwrdn_out_sig[23];
		assign pcs_pwrdn_out_23 = 1'b0;
    end      
endgenerate


// Either one of these blocks below will be instantiated depending on the parameterization 
// that is chosen.
// ---------------------------------------------------------------------------------------

// Instantiation of the LVDS SERDES block as the PMA for Stratix III devices
//
// IEEE 802.3 Clause 36 PCS requires that bit 0 of TBI_DATA to be transmitted 
// first.  However, ALTLVDS had bit 9 transmit first.  hence, we need a bit
// reversal algorithm.  
// -------------------------------------------------------------------------

generate if (DEVICE_FAMILY != "ARRIAGX" && TRANSCEIVER_OPTION == 1 && MAX_CHANNELS > 23)
    begin          

    assign tbi_tx_clk_23 = ref_clk;
    assign tbi_rx_d_23 = tbi_rx_d_flip_23;
    
    altera_tse_reset_synchronizer ch_23_reset_sync_0 (
        .clk(tbi_rx_clk_23),
        .reset_in(reset),
        .reset_out(reset_tbi_rx_clk_23_int)
        );

    always @(posedge tbi_rx_clk_23 or posedge reset_tbi_rx_clk_23_int)
        begin
        if (reset_tbi_rx_clk_23_int == 1)
            tbi_rx_d_flip_23 <= 0;
        else 
            begin
            tbi_rx_d_flip_23[0] <= tbi_rx_d_lvds_23[9];
            tbi_rx_d_flip_23[1] <= tbi_rx_d_lvds_23[8];
            tbi_rx_d_flip_23[2] <= tbi_rx_d_lvds_23[7];
            tbi_rx_d_flip_23[3] <= tbi_rx_d_lvds_23[6];
            tbi_rx_d_flip_23[4] <= tbi_rx_d_lvds_23[5];
            tbi_rx_d_flip_23[5] <= tbi_rx_d_lvds_23[4];
            tbi_rx_d_flip_23[6] <= tbi_rx_d_lvds_23[3];
            tbi_rx_d_flip_23[7] <= tbi_rx_d_lvds_23[2];
            tbi_rx_d_flip_23[8] <= tbi_rx_d_lvds_23[1];
            tbi_rx_d_flip_23[9] <= tbi_rx_d_lvds_23[0];
            end
        end

    always @(posedge ref_clk or posedge reset_ref_clk_int)
        begin
        if (reset_ref_clk_int == 1)
            tbi_tx_d_flip_23 <= 0;
        else 
            begin
            tbi_tx_d_flip_23[0] <= tbi_tx_d_23[9];
            tbi_tx_d_flip_23[1] <= tbi_tx_d_23[8];
            tbi_tx_d_flip_23[2] <= tbi_tx_d_23[7];
            tbi_tx_d_flip_23[3] <= tbi_tx_d_23[6];
            tbi_tx_d_flip_23[4] <= tbi_tx_d_23[5];
            tbi_tx_d_flip_23[5] <= tbi_tx_d_23[4];
            tbi_tx_d_flip_23[6] <= tbi_tx_d_23[3];
            tbi_tx_d_flip_23[7] <= tbi_tx_d_23[2];
            tbi_tx_d_flip_23[8] <= tbi_tx_d_23[1];
            tbi_tx_d_flip_23[9] <= tbi_tx_d_23[0];
            end
        end

    altera_tse_pma_lvds_rx the_altera_tse_pma_lvds_rx_23
     (
         .pll_areset ( reset ),
         .rx_cda_reset ( rx_cda_reset_23 ),
         .rx_channel_data_align ( rx_channel_data_align_23 ),
         .rx_locked ( rx_locked_23 ),
         .rx_divfwdclk (tbi_rx_clk_23),
         .rx_in (rxp_23),
         .rx_inclock (ref_clk),
         .rx_out (tbi_rx_d_lvds_23),
         .rx_outclock (),
         .rx_reset (rx_reset_23)
     );

    altera_tse_lvds_reset_sequencer the_altera_tse_lvds_reset_sequencer_23 (
		.clk ( ref_clk ),
		.reset ( reset_ref_clk_int ),
		.rx_locked ( rx_locked_23 ),
		.rx_channel_data_align ( rx_channel_data_align_23 ),
		.pll_areset ( pll_areset_23 ),
		.rx_reset ( rx_reset_23 ),
        .rx_cda_reset ( rx_cda_reset_23 )
	);


    altera_tse_pma_lvds_tx the_altera_tse_pma_lvds_tx_23
    (
        .tx_in (tbi_tx_d_flip_23),
        .tx_inclock (ref_clk),
		.pll_areset ( reset ),
        .tx_out (txp_23)
    );

    end   
else
    begin
    assign txp_23 = 1'b0;
    assign tbi_rx_clk_23 = 1'b0;	
    end      
endgenerate



endmodule // module altera_tse_multi_mac_pcs_pma
