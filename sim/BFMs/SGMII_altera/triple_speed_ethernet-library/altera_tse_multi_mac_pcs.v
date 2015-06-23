
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_multi_mac_pcs.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_multi_mac_pcs.v,v $
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
// Top Level Triple Speed Ethernet(10/100/1000) MAC with FIFOs, MII/GMII
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
module altera_tse_multi_mac_pcs
/* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"D101,D103,C105\"" */
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
parameter ENABLE_RX_FIFO_STATUS = 1,                    //  Enable Receive FIFO Almost Full status interface
parameter CHANNEL_WIDTH         = 1,                    //  The width of the channel interface
parameter ENABLE_PKT_CLASS      = 1,                    //  Enable Packet Classification Av-ST Interface
parameter SYNCHRONIZER_DEPTH 	= 3,		  	//  Number of synchronizer
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
    input wire   ref_clk,                    //  Reference Clock

	// SHARED CLK SIGNALS
    output wire  mac_rx_clk,                 //  Av-ST Receive Clock
	output wire  mac_tx_clk,                 //  Av-ST Transmit Clock 

	// SHARED RX STATUS
    input wire   rx_afull_clk,                             //  Almost full clk
    input wire   [1:0] rx_afull_data,                      //  Almost full data
    input wire   rx_afull_valid,                           //  Almost full valid
    input wire   [CHANNEL_WIDTH-1:0] rx_afull_channel,     //  Almost full channel


    // CHANNEL 0

    // PCS SIGNALS TO PHY
    input wire   tbi_rx_clk_0,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_0,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_0,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_0,         //  Transmit TBI Interface
    output wire  sd_loopback_0,            //  SERDES Loopback Enable
    output wire  powerdown_0,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_1,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_1,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_1,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_1,         //  Transmit TBI Interface
    output wire  sd_loopback_1,            //  SERDES Loopback Enable
    output wire  powerdown_1,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_2,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_2,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_2,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_2,         //  Transmit TBI Interface
    output wire  sd_loopback_2,            //  SERDES Loopback Enable
    output wire  powerdown_2,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_3,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_3,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_3,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_3,         //  Transmit TBI Interface
    output wire  sd_loopback_3,            //  SERDES Loopback Enable
    output wire  powerdown_3,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_4,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_4,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_4,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_4,         //  Transmit TBI Interface
    output wire  sd_loopback_4,            //  SERDES Loopback Enable
    output wire  powerdown_4,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_5,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_5,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_5,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_5,         //  Transmit TBI Interface
    output wire  sd_loopback_5,            //  SERDES Loopback Enable
    output wire  powerdown_5,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_6,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_6,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_6,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_6,         //  Transmit TBI Interface
    output wire  sd_loopback_6,            //  SERDES Loopback Enable
    output wire  powerdown_6,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_7,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_7,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_7,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_7,         //  Transmit TBI Interface
    output wire  sd_loopback_7,            //  SERDES Loopback Enable
    output wire  powerdown_7,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_8,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_8,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_8,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_8,         //  Transmit TBI Interface
    output wire  sd_loopback_8,            //  SERDES Loopback Enable
    output wire  powerdown_8,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_9,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_9,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_9,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_9,         //  Transmit TBI Interface
    output wire  sd_loopback_9,            //  SERDES Loopback Enable
    output wire  powerdown_9,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_10,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_10,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_10,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_10,         //  Transmit TBI Interface
    output wire  sd_loopback_10,            //  SERDES Loopback Enable
    output wire  powerdown_10,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_11,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_11,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_11,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_11,         //  Transmit TBI Interface
    output wire  sd_loopback_11,            //  SERDES Loopback Enable
    output wire  powerdown_11,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_12,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_12,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_12,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_12,         //  Transmit TBI Interface
    output wire  sd_loopback_12,            //  SERDES Loopback Enable
    output wire  powerdown_12,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_13,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_13,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_13,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_13,         //  Transmit TBI Interface
    output wire  sd_loopback_13,            //  SERDES Loopback Enable
    output wire  powerdown_13,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_14,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_14,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_14,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_14,         //  Transmit TBI Interface
    output wire  sd_loopback_14,            //  SERDES Loopback Enable
    output wire  powerdown_14,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_15,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_15,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_15,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_15,         //  Transmit TBI Interface
    output wire  sd_loopback_15,            //  SERDES Loopback Enable
    output wire  powerdown_15,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_16,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_16,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_16,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_16,         //  Transmit TBI Interface
    output wire  sd_loopback_16,            //  SERDES Loopback Enable
    output wire  powerdown_16,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_17,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_17,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_17,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_17,         //  Transmit TBI Interface
    output wire  sd_loopback_17,            //  SERDES Loopback Enable
    output wire  powerdown_17,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_18,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_18,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_18,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_18,         //  Transmit TBI Interface
    output wire  sd_loopback_18,            //  SERDES Loopback Enable
    output wire  powerdown_18,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_19,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_19,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_19,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_19,         //  Transmit TBI Interface
    output wire  sd_loopback_19,            //  SERDES Loopback Enable
    output wire  powerdown_19,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_20,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_20,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_20,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_20,         //  Transmit TBI Interface
    output wire  sd_loopback_20,            //  SERDES Loopback Enable
    output wire  powerdown_20,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_21,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_21,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_21,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_21,         //  Transmit TBI Interface
    output wire  sd_loopback_21,            //  SERDES Loopback Enable
    output wire  powerdown_21,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_22,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_22,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_22,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_22,         //  Transmit TBI Interface
    output wire  sd_loopback_22,            //  SERDES Loopback Enable
    output wire  powerdown_22,              //  Powerdown Enable
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
    input wire   tbi_rx_clk_23,             //  125MHz Recoved Clock
    input wire   tbi_tx_clk_23,             //  125MHz Transmit Clock
    input wire   [9:0] tbi_rx_d_23,         //  Non Aligned 10-Bit Characters
    output wire  [9:0] tbi_tx_d_23,         //  Transmit TBI Interface
    output wire  sd_loopback_23,            //  SERDES Loopback Enable
    output wire  powerdown_23,              //  Powerdown Enable
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


    // Component instantiation

    altera_tse_top_multi_mac_pcs U_MULTI_MAC_PCS(

        .reset(reset),                            //INPUT  : ASYNCHRONOUS RESET - clk DOMAIN
        .clk(clk),                                //INPUT  : CLOCK
        .read(read),                              //INPUT  : REGISTER READ TRANSACTION
        .write(write),                            //INPUT  : REGISTER WRITE TRANSACTION
        .ref_clk(ref_clk),                        //INPUT  : REFERENCE CLOCK
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
        .powerdown_0(powerdown_0),                //OUTPUT : Powerdown Enable
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
        .powerdown_1(powerdown_1),                //OUTPUT : Powerdown Enable
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
        .powerdown_2(powerdown_2),                //OUTPUT : Powerdown Enable
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
        .powerdown_3(powerdown_3),                //OUTPUT : Powerdown Enable
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
        .powerdown_4(powerdown_4),                //OUTPUT : Powerdown Enable
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
        .powerdown_5(powerdown_5),                //OUTPUT : Powerdown Enable
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
        .powerdown_6(powerdown_6),                //OUTPUT : Powerdown Enable
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
        .powerdown_7(powerdown_7),                //OUTPUT : Powerdown Enable
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
        .powerdown_8(powerdown_8),                //OUTPUT : Powerdown Enable
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
        .powerdown_9(powerdown_9),                //OUTPUT : Powerdown Enable
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
        .powerdown_10(powerdown_10),                //OUTPUT : Powerdown Enable
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
        .powerdown_11(powerdown_11),                //OUTPUT : Powerdown Enable
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
        .powerdown_12(powerdown_12),                //OUTPUT : Powerdown Enable
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
        .powerdown_13(powerdown_13),                //OUTPUT : Powerdown Enable
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
        .powerdown_14(powerdown_14),                //OUTPUT : Powerdown Enable
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
        .powerdown_15(powerdown_15),                //OUTPUT : Powerdown Enable
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
        .powerdown_16(powerdown_16),                //OUTPUT : Powerdown Enable
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
        .powerdown_17(powerdown_17),                //OUTPUT : Powerdown Enable
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
        .powerdown_18(powerdown_18),                //OUTPUT : Powerdown Enable
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
        .powerdown_19(powerdown_19),                //OUTPUT : Powerdown Enable
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
        .powerdown_20(powerdown_20),                //OUTPUT : Powerdown Enable
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
        .powerdown_21(powerdown_21),                //OUTPUT : Powerdown Enable
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
        .powerdown_22(powerdown_22),                //OUTPUT : Powerdown Enable
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
        .powerdown_23(powerdown_23),                //OUTPUT : Powerdown Enable
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


 endmodule // module altera_tse_multi_mac_pcs
