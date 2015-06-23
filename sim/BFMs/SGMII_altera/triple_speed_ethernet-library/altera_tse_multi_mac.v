// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_multi_mac.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_multi_mac.v,v $
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
module altera_tse_multi_mac 
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
parameter CRC32DWIDTH           = 4'b 1000,             //  input data width (informal, not for change)
parameter CRC32GENDELAY         = 3'b 110,              //  when the data from the generator is valid
parameter CRC32CHECK16BIT       = 1'b 0,                //  1 compare two times 16 bit of the CRC (adds one pipeline step) 
parameter CRC32S1L2_EXTERN      = 1'b0,                 //  false: merge enable
parameter ENABLE_SHIFT16        = 0,                    //  Enable byte stuffing at packet header 
parameter ENABLE_MAC_FLOW_CTRL  = 1'b1,                 //  Option to enable flow control 
parameter ENABLE_MAC_TXADDR_SET = 1'b1,                 //  Option to enable MAC address insertion onto 'to-be-transmitted' Ethernet frames on MAC TX data path
parameter ENABLE_MAC_RX_VLAN    = 1'b1,                 //  Option to enable VLAN tagged Ethernet frames on MAC RX data path
parameter ENABLE_MAC_TX_VLAN    = 1'b1,                 //  Option to enable VLAN tagged Ethernet frames on MAC TX data path

parameter ENABLE_CLK_SHARING    = 0,                    //  Option to share clock for multiple channels (Clocks are rate-matched).
parameter ENABLE_REG_SHARING    = 1,                    //  Option to share register space. Uses certain hard-coded values from input.
parameter ENABLE_EXTENDED_STAT_REG = 0,                 //  Enable a few extended statistic registers
parameter MAX_CHANNELS          = 1,                    //  The number of channels in Multi-TSE component 
parameter ENABLE_PKT_CLASS      = 1,                    //  Enable Packet Classification Av-ST Interface
parameter ENABLE_RX_FIFO_STATUS = 1,                    //  Enable Receive FIFO Almost Full status interface
parameter CHANNEL_WIDTH         = 1,                    //  The width of the channel interface
parameter SYNCHRONIZER_DEPTH 	= 3,		  	//  Number of synchronizer


// Internal parameters
parameter ADDR_WIDTH = (MAX_CHANNELS > 16)? 13 :
                       (MAX_CHANNELS > 8)? 12 :
                       (MAX_CHANNELS > 4)? 11 :
                       (MAX_CHANNELS > 2)? 10 :                       
                       (MAX_CHANNELS > 1)? 9 : 8

)



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

	// SHARED CLK SIGNALS
	input wire   rx_clk,                     //  Receive Clock
	input wire   tx_clk,                     //  Transmit Clock 
    output wire  mac_rx_clk,                 //  Av-ST Receive Clock
	output wire  mac_tx_clk,                 //  Av-ST Transmit Clock 

    // SHARED RX STATUS 
    input wire   rx_afull_clk,                             //  Almost full clock
	input wire   [1:0] rx_afull_data,                      //  Almost full data
	input wire   rx_afull_valid,                           //  Almost full valid
	input wire   [CHANNEL_WIDTH-1:0] rx_afull_channel,     //  Almost full channel
	

    // CHANNEL 0
	
	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_0,               //  Carrier Sense
	input wire   m_rx_col_0,               //  Collition
	input wire   rx_clk_0,                 //  Receive Clock
	input wire   tx_clk_0,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_0,          //  GMII Receive Data
	input wire   gm_rx_dv_0,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_0,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_0,          //  GMII Transmit Data
	output wire  gm_tx_en_0,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_0,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_0,           //  MII Receive Data
	input wire   m_rx_en_0,                //  MII Receive Frame Enable  
	input wire   m_rx_err_0,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_0,           //  MII Transmit Data
	output wire  m_tx_en_0,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_0,               //  MII Transmit Frame Error
	output wire  tx_control_0,
	output wire  [3:0] rgmii_out_0,
	input wire   [3:0] rgmii_in_0,
	input wire   rx_control_0,
	output wire  eth_mode_0,               //  Ethernet Mode
	output wire  ena_10_0,                 //  Enable 10Mbps Mode
	input wire   set_1000_0,               //  Gigabit Mode Enable
	input wire   set_10_0,                 //  10Mbps Mode Enable
	
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
	
	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_1,               //  Carrier Sense
	input wire   m_rx_col_1,               //  Collition
	input wire   rx_clk_1,                 //  Receive Clock
	input wire   tx_clk_1,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_1,          //  GMII Receive Data
	input wire   gm_rx_dv_1,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_1,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_1,          //  GMII Transmit Data
	output wire  gm_tx_en_1,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_1,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_1,           //  MII Receive Data
	input wire   m_rx_en_1,                //  MII Receive Frame Enable  
	input wire   m_rx_err_1,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_1,           //  MII Transmit Data
	output wire  m_tx_en_1,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_1,               //  MII Transmit Frame Error
	output wire  tx_control_1,
	output wire  [3:0] rgmii_out_1,
	input wire   [3:0] rgmii_in_1,
	input wire   rx_control_1,
	output wire  eth_mode_1,               //  Ethernet Mode
	output wire  ena_10_1,                 //  Enable 10Mbps Mode
	input wire   set_1000_1,               //  Gigabit Mode Enable
	input wire   set_10_1,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_2,               //  Carrier Sense
	input wire   m_rx_col_2,               //  Collition
	input wire   rx_clk_2,                 //  Receive Clock
	input wire   tx_clk_2,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_2,          //  GMII Receive Data
	input wire   gm_rx_dv_2,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_2,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_2,          //  GMII Transmit Data
	output wire  gm_tx_en_2,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_2,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_2,           //  MII Receive Data
	input wire   m_rx_en_2,                //  MII Receive Frame Enable  
	input wire   m_rx_err_2,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_2,           //  MII Transmit Data
	output wire  m_tx_en_2,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_2,               //  MII Transmit Frame Error
	output wire  tx_control_2,
	output wire  [3:0] rgmii_out_2,
	input wire   [3:0] rgmii_in_2,
	input wire   rx_control_2,
	output wire  eth_mode_2,               //  Ethernet Mode
	output wire  ena_10_2,                 //  Enable 10Mbps Mode
	input wire   set_1000_2,               //  Gigabit Mode Enable
	input wire   set_10_2,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_3,               //  Carrier Sense
	input wire   m_rx_col_3,               //  Collition
	input wire   rx_clk_3,                 //  Receive Clock
	input wire   tx_clk_3,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_3,          //  GMII Receive Data
	input wire   gm_rx_dv_3,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_3,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_3,          //  GMII Transmit Data
	output wire  gm_tx_en_3,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_3,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_3,           //  MII Receive Data
	input wire   m_rx_en_3,                //  MII Receive Frame Enable  
	input wire   m_rx_err_3,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_3,           //  MII Transmit Data
	output wire  m_tx_en_3,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_3,               //  MII Transmit Frame Error
	output wire  tx_control_3,
	output wire  [3:0] rgmii_out_3,
	input wire   [3:0] rgmii_in_3,
	input wire   rx_control_3,
	output wire  eth_mode_3,               //  Ethernet Mode
	output wire  ena_10_3,                 //  Enable 10Mbps Mode
	input wire   set_1000_3,               //  Gigabit Mode Enable
	input wire   set_10_3,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_4,               //  Carrier Sense
	input wire   m_rx_col_4,               //  Collition
	input wire   rx_clk_4,                 //  Receive Clock
	input wire   tx_clk_4,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_4,          //  GMII Receive Data
	input wire   gm_rx_dv_4,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_4,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_4,          //  GMII Transmit Data
	output wire  gm_tx_en_4,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_4,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_4,           //  MII Receive Data
	input wire   m_rx_en_4,                //  MII Receive Frame Enable  
	input wire   m_rx_err_4,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_4,           //  MII Transmit Data
	output wire  m_tx_en_4,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_4,               //  MII Transmit Frame Error
	output wire  tx_control_4,
	output wire  [3:0] rgmii_out_4,
	input wire   [3:0] rgmii_in_4,
	input wire   rx_control_4,
	output wire  eth_mode_4,               //  Ethernet Mode
	output wire  ena_10_4,                 //  Enable 10Mbps Mode
	input wire   set_1000_4,               //  Gigabit Mode Enable
	input wire   set_10_4,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_5,               //  Carrier Sense
	input wire   m_rx_col_5,               //  Collition
	input wire   rx_clk_5,                 //  Receive Clock
	input wire   tx_clk_5,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_5,          //  GMII Receive Data
	input wire   gm_rx_dv_5,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_5,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_5,          //  GMII Transmit Data
	output wire  gm_tx_en_5,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_5,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_5,           //  MII Receive Data
	input wire   m_rx_en_5,                //  MII Receive Frame Enable  
	input wire   m_rx_err_5,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_5,           //  MII Transmit Data
	output wire  m_tx_en_5,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_5,               //  MII Transmit Frame Error
	output wire  tx_control_5,
	output wire  [3:0] rgmii_out_5,
	input wire   [3:0] rgmii_in_5,
	input wire   rx_control_5,
	output wire  eth_mode_5,               //  Ethernet Mode
	output wire  ena_10_5,                 //  Enable 10Mbps Mode
	input wire   set_1000_5,               //  Gigabit Mode Enable
	input wire   set_10_5,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_6,               //  Carrier Sense
	input wire   m_rx_col_6,               //  Collition
	input wire   rx_clk_6,                 //  Receive Clock
	input wire   tx_clk_6,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_6,          //  GMII Receive Data
	input wire   gm_rx_dv_6,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_6,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_6,          //  GMII Transmit Data
	output wire  gm_tx_en_6,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_6,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_6,           //  MII Receive Data
	input wire   m_rx_en_6,                //  MII Receive Frame Enable  
	input wire   m_rx_err_6,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_6,           //  MII Transmit Data
	output wire  m_tx_en_6,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_6,               //  MII Transmit Frame Error
	output wire  tx_control_6,
	output wire  [3:0] rgmii_out_6,
	input wire   [3:0] rgmii_in_6,
	input wire   rx_control_6,
	output wire  eth_mode_6,               //  Ethernet Mode
	output wire  ena_10_6,                 //  Enable 10Mbps Mode
	input wire   set_1000_6,               //  Gigabit Mode Enable
	input wire   set_10_6,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_7,               //  Carrier Sense
	input wire   m_rx_col_7,               //  Collition
	input wire   rx_clk_7,                 //  Receive Clock
	input wire   tx_clk_7,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_7,          //  GMII Receive Data
	input wire   gm_rx_dv_7,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_7,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_7,          //  GMII Transmit Data
	output wire  gm_tx_en_7,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_7,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_7,           //  MII Receive Data
	input wire   m_rx_en_7,                //  MII Receive Frame Enable  
	input wire   m_rx_err_7,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_7,           //  MII Transmit Data
	output wire  m_tx_en_7,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_7,               //  MII Transmit Frame Error
	output wire  tx_control_7,
	output wire  [3:0] rgmii_out_7,
	input wire   [3:0] rgmii_in_7,
	input wire   rx_control_7,
	output wire  eth_mode_7,               //  Ethernet Mode
	output wire  ena_10_7,                 //  Enable 10Mbps Mode
	input wire   set_1000_7,               //  Gigabit Mode Enable
	input wire   set_10_7,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_8,               //  Carrier Sense
	input wire   m_rx_col_8,               //  Collition
	input wire   rx_clk_8,                 //  Receive Clock
	input wire   tx_clk_8,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_8,          //  GMII Receive Data
	input wire   gm_rx_dv_8,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_8,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_8,          //  GMII Transmit Data
	output wire  gm_tx_en_8,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_8,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_8,           //  MII Receive Data
	input wire   m_rx_en_8,                //  MII Receive Frame Enable  
	input wire   m_rx_err_8,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_8,           //  MII Transmit Data
	output wire  m_tx_en_8,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_8,               //  MII Transmit Frame Error
	output wire  tx_control_8,
	output wire  [3:0] rgmii_out_8,
	input wire   [3:0] rgmii_in_8,
	input wire   rx_control_8,
	output wire  eth_mode_8,               //  Ethernet Mode
	output wire  ena_10_8,                 //  Enable 10Mbps Mode
	input wire   set_1000_8,               //  Gigabit Mode Enable
	input wire   set_10_8,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_9,               //  Carrier Sense
	input wire   m_rx_col_9,               //  Collition
	input wire   rx_clk_9,                 //  Receive Clock
	input wire   tx_clk_9,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_9,          //  GMII Receive Data
	input wire   gm_rx_dv_9,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_9,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_9,          //  GMII Transmit Data
	output wire  gm_tx_en_9,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_9,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_9,           //  MII Receive Data
	input wire   m_rx_en_9,                //  MII Receive Frame Enable  
	input wire   m_rx_err_9,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_9,           //  MII Transmit Data
	output wire  m_tx_en_9,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_9,               //  MII Transmit Frame Error
	output wire  tx_control_9,
	output wire  [3:0] rgmii_out_9,
	input wire   [3:0] rgmii_in_9,
	input wire   rx_control_9,
	output wire  eth_mode_9,               //  Ethernet Mode
	output wire  ena_10_9,                 //  Enable 10Mbps Mode
	input wire   set_1000_9,               //  Gigabit Mode Enable
	input wire   set_10_9,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_10,               //  Carrier Sense
	input wire   m_rx_col_10,               //  Collition
	input wire   rx_clk_10,                 //  Receive Clock
	input wire   tx_clk_10,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_10,          //  GMII Receive Data
	input wire   gm_rx_dv_10,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_10,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_10,          //  GMII Transmit Data
	output wire  gm_tx_en_10,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_10,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_10,           //  MII Receive Data
	input wire   m_rx_en_10,                //  MII Receive Frame Enable  
	input wire   m_rx_err_10,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_10,           //  MII Transmit Data
	output wire  m_tx_en_10,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_10,               //  MII Transmit Frame Error
	output wire  tx_control_10,
	output wire  [3:0] rgmii_out_10,
	input wire   [3:0] rgmii_in_10,
	input wire   rx_control_10,
	output wire  eth_mode_10,               //  Ethernet Mode
	output wire  ena_10_10,                 //  Enable 10Mbps Mode
	input wire   set_1000_10,               //  Gigabit Mode Enable
	input wire   set_10_10,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_11,               //  Carrier Sense
	input wire   m_rx_col_11,               //  Collition
	input wire   rx_clk_11,                 //  Receive Clock
	input wire   tx_clk_11,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_11,          //  GMII Receive Data
	input wire   gm_rx_dv_11,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_11,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_11,          //  GMII Transmit Data
	output wire  gm_tx_en_11,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_11,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_11,           //  MII Receive Data
	input wire   m_rx_en_11,                //  MII Receive Frame Enable  
	input wire   m_rx_err_11,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_11,           //  MII Transmit Data
	output wire  m_tx_en_11,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_11,               //  MII Transmit Frame Error
	output wire  tx_control_11,
	output wire  [3:0] rgmii_out_11,
	input wire   [3:0] rgmii_in_11,
	input wire   rx_control_11,
	output wire  eth_mode_11,               //  Ethernet Mode
	output wire  ena_10_11,                 //  Enable 10Mbps Mode
	input wire   set_1000_11,               //  Gigabit Mode Enable
	input wire   set_10_11,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_12,               //  Carrier Sense
	input wire   m_rx_col_12,               //  Collition
	input wire   rx_clk_12,                 //  Receive Clock
	input wire   tx_clk_12,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_12,          //  GMII Receive Data
	input wire   gm_rx_dv_12,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_12,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_12,          //  GMII Transmit Data
	output wire  gm_tx_en_12,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_12,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_12,           //  MII Receive Data
	input wire   m_rx_en_12,                //  MII Receive Frame Enable  
	input wire   m_rx_err_12,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_12,           //  MII Transmit Data
	output wire  m_tx_en_12,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_12,               //  MII Transmit Frame Error
	output wire  tx_control_12,
	output wire  [3:0] rgmii_out_12,
	input wire   [3:0] rgmii_in_12,
	input wire   rx_control_12,
	output wire  eth_mode_12,               //  Ethernet Mode
	output wire  ena_10_12,                 //  Enable 10Mbps Mode
	input wire   set_1000_12,               //  Gigabit Mode Enable
	input wire   set_10_12,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_13,               //  Carrier Sense
	input wire   m_rx_col_13,               //  Collition
	input wire   rx_clk_13,                 //  Receive Clock
	input wire   tx_clk_13,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_13,          //  GMII Receive Data
	input wire   gm_rx_dv_13,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_13,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_13,          //  GMII Transmit Data
	output wire  gm_tx_en_13,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_13,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_13,           //  MII Receive Data
	input wire   m_rx_en_13,                //  MII Receive Frame Enable  
	input wire   m_rx_err_13,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_13,           //  MII Transmit Data
	output wire  m_tx_en_13,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_13,               //  MII Transmit Frame Error
	output wire  tx_control_13,
	output wire  [3:0] rgmii_out_13,
	input wire   [3:0] rgmii_in_13,
	input wire   rx_control_13,
	output wire  eth_mode_13,               //  Ethernet Mode
	output wire  ena_10_13,                 //  Enable 10Mbps Mode
	input wire   set_1000_13,               //  Gigabit Mode Enable
	input wire   set_10_13,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_14,               //  Carrier Sense
	input wire   m_rx_col_14,               //  Collition
	input wire   rx_clk_14,                 //  Receive Clock
	input wire   tx_clk_14,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_14,          //  GMII Receive Data
	input wire   gm_rx_dv_14,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_14,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_14,          //  GMII Transmit Data
	output wire  gm_tx_en_14,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_14,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_14,           //  MII Receive Data
	input wire   m_rx_en_14,                //  MII Receive Frame Enable  
	input wire   m_rx_err_14,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_14,           //  MII Transmit Data
	output wire  m_tx_en_14,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_14,               //  MII Transmit Frame Error
	output wire  tx_control_14,
	output wire  [3:0] rgmii_out_14,
	input wire   [3:0] rgmii_in_14,
	input wire   rx_control_14,
	output wire  eth_mode_14,               //  Ethernet Mode
	output wire  ena_10_14,                 //  Enable 10Mbps Mode
	input wire   set_1000_14,               //  Gigabit Mode Enable
	input wire   set_10_14,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_15,               //  Carrier Sense
	input wire   m_rx_col_15,               //  Collition
	input wire   rx_clk_15,                 //  Receive Clock
	input wire   tx_clk_15,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_15,          //  GMII Receive Data
	input wire   gm_rx_dv_15,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_15,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_15,          //  GMII Transmit Data
	output wire  gm_tx_en_15,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_15,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_15,           //  MII Receive Data
	input wire   m_rx_en_15,                //  MII Receive Frame Enable  
	input wire   m_rx_err_15,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_15,           //  MII Transmit Data
	output wire  m_tx_en_15,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_15,               //  MII Transmit Frame Error
	output wire  tx_control_15,
	output wire  [3:0] rgmii_out_15,
	input wire   [3:0] rgmii_in_15,
	input wire   rx_control_15,
	output wire  eth_mode_15,               //  Ethernet Mode
	output wire  ena_10_15,                 //  Enable 10Mbps Mode
	input wire   set_1000_15,               //  Gigabit Mode Enable
	input wire   set_10_15,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_16,               //  Carrier Sense
	input wire   m_rx_col_16,               //  Collition
	input wire   rx_clk_16,                 //  Receive Clock
	input wire   tx_clk_16,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_16,          //  GMII Receive Data
	input wire   gm_rx_dv_16,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_16,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_16,          //  GMII Transmit Data
	output wire  gm_tx_en_16,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_16,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_16,           //  MII Receive Data
	input wire   m_rx_en_16,                //  MII Receive Frame Enable  
	input wire   m_rx_err_16,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_16,           //  MII Transmit Data
	output wire  m_tx_en_16,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_16,               //  MII Transmit Frame Error
	output wire  tx_control_16,
	output wire  [3:0] rgmii_out_16,
	input wire   [3:0] rgmii_in_16,
	input wire   rx_control_16,
	output wire  eth_mode_16,               //  Ethernet Mode
	output wire  ena_10_16,                 //  Enable 10Mbps Mode
	input wire   set_1000_16,               //  Gigabit Mode Enable
	input wire   set_10_16,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_17,               //  Carrier Sense
	input wire   m_rx_col_17,               //  Collition
	input wire   rx_clk_17,                 //  Receive Clock
	input wire   tx_clk_17,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_17,          //  GMII Receive Data
	input wire   gm_rx_dv_17,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_17,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_17,          //  GMII Transmit Data
	output wire  gm_tx_en_17,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_17,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_17,           //  MII Receive Data
	input wire   m_rx_en_17,                //  MII Receive Frame Enable  
	input wire   m_rx_err_17,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_17,           //  MII Transmit Data
	output wire  m_tx_en_17,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_17,               //  MII Transmit Frame Error
	output wire  tx_control_17,
	output wire  [3:0] rgmii_out_17,
	input wire   [3:0] rgmii_in_17,
	input wire   rx_control_17,
	output wire  eth_mode_17,               //  Ethernet Mode
	output wire  ena_10_17,                 //  Enable 10Mbps Mode
	input wire   set_1000_17,               //  Gigabit Mode Enable
	input wire   set_10_17,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_18,               //  Carrier Sense
	input wire   m_rx_col_18,               //  Collition
	input wire   rx_clk_18,                 //  Receive Clock
	input wire   tx_clk_18,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_18,          //  GMII Receive Data
	input wire   gm_rx_dv_18,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_18,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_18,          //  GMII Transmit Data
	output wire  gm_tx_en_18,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_18,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_18,           //  MII Receive Data
	input wire   m_rx_en_18,                //  MII Receive Frame Enable  
	input wire   m_rx_err_18,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_18,           //  MII Transmit Data
	output wire  m_tx_en_18,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_18,               //  MII Transmit Frame Error
	output wire  tx_control_18,
	output wire  [3:0] rgmii_out_18,
	input wire   [3:0] rgmii_in_18,
	input wire   rx_control_18,
	output wire  eth_mode_18,               //  Ethernet Mode
	output wire  ena_10_18,                 //  Enable 10Mbps Mode
	input wire   set_1000_18,               //  Gigabit Mode Enable
	input wire   set_10_18,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_19,               //  Carrier Sense
	input wire   m_rx_col_19,               //  Collition
	input wire   rx_clk_19,                 //  Receive Clock
	input wire   tx_clk_19,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_19,          //  GMII Receive Data
	input wire   gm_rx_dv_19,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_19,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_19,          //  GMII Transmit Data
	output wire  gm_tx_en_19,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_19,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_19,           //  MII Receive Data
	input wire   m_rx_en_19,                //  MII Receive Frame Enable  
	input wire   m_rx_err_19,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_19,           //  MII Transmit Data
	output wire  m_tx_en_19,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_19,               //  MII Transmit Frame Error
	output wire  tx_control_19,
	output wire  [3:0] rgmii_out_19,
	input wire   [3:0] rgmii_in_19,
	input wire   rx_control_19,
	output wire  eth_mode_19,               //  Ethernet Mode
	output wire  ena_10_19,                 //  Enable 10Mbps Mode
	input wire   set_1000_19,               //  Gigabit Mode Enable
	input wire   set_10_19,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_20,               //  Carrier Sense
	input wire   m_rx_col_20,               //  Collition
	input wire   rx_clk_20,                 //  Receive Clock
	input wire   tx_clk_20,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_20,          //  GMII Receive Data
	input wire   gm_rx_dv_20,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_20,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_20,          //  GMII Transmit Data
	output wire  gm_tx_en_20,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_20,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_20,           //  MII Receive Data
	input wire   m_rx_en_20,                //  MII Receive Frame Enable  
	input wire   m_rx_err_20,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_20,           //  MII Transmit Data
	output wire  m_tx_en_20,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_20,               //  MII Transmit Frame Error
	output wire  tx_control_20,
	output wire  [3:0] rgmii_out_20,
	input wire   [3:0] rgmii_in_20,
	input wire   rx_control_20,
	output wire  eth_mode_20,               //  Ethernet Mode
	output wire  ena_10_20,                 //  Enable 10Mbps Mode
	input wire   set_1000_20,               //  Gigabit Mode Enable
	input wire   set_10_20,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_21,               //  Carrier Sense
	input wire   m_rx_col_21,               //  Collition
	input wire   rx_clk_21,                 //  Receive Clock
	input wire   tx_clk_21,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_21,          //  GMII Receive Data
	input wire   gm_rx_dv_21,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_21,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_21,          //  GMII Transmit Data
	output wire  gm_tx_en_21,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_21,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_21,           //  MII Receive Data
	input wire   m_rx_en_21,                //  MII Receive Frame Enable  
	input wire   m_rx_err_21,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_21,           //  MII Transmit Data
	output wire  m_tx_en_21,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_21,               //  MII Transmit Frame Error
	output wire  tx_control_21,
	output wire  [3:0] rgmii_out_21,
	input wire   [3:0] rgmii_in_21,
	input wire   rx_control_21,
	output wire  eth_mode_21,               //  Ethernet Mode
	output wire  ena_10_21,                 //  Enable 10Mbps Mode
	input wire   set_1000_21,               //  Gigabit Mode Enable
	input wire   set_10_21,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_22,               //  Carrier Sense
	input wire   m_rx_col_22,               //  Collition
	input wire   rx_clk_22,                 //  Receive Clock
	input wire   tx_clk_22,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_22,          //  GMII Receive Data
	input wire   gm_rx_dv_22,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_22,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_22,          //  GMII Transmit Data
	output wire  gm_tx_en_22,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_22,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_22,           //  MII Receive Data
	input wire   m_rx_en_22,                //  MII Receive Frame Enable  
	input wire   m_rx_err_22,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_22,           //  MII Transmit Data
	output wire  m_tx_en_22,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_22,               //  MII Transmit Frame Error
	output wire  tx_control_22,
	output wire  [3:0] rgmii_out_22,
	input wire   [3:0] rgmii_in_22,
	input wire   rx_control_22,
	output wire  eth_mode_22,               //  Ethernet Mode
	output wire  ena_10_22,                 //  Enable 10Mbps Mode
	input wire   set_1000_22,               //  Gigabit Mode Enable
	input wire   set_10_22,                 //  10Mbps Mode Enable
	
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

	// GMII / MII / RGMII SIGNALS 
	input wire   m_rx_crs_23,               //  Carrier Sense
	input wire   m_rx_col_23,               //  Collition
	input wire   rx_clk_23,                 //  Receive Clock
	input wire   tx_clk_23,                 //  Transmit Clock                
	input wire   [7:0] gm_rx_d_23,          //  GMII Receive Data
	input wire   gm_rx_dv_23,               //  GMII Receive Frame Enable  
	input wire   gm_rx_err_23,              //  GMII Receive Frame Error  
	output wire  [7:0] gm_tx_d_23,          //  GMII Transmit Data
	output wire  gm_tx_en_23,               //  GMII Transmit Frame Enable  
	output wire  gm_tx_err_23,              //  GMII Transmit Frame Error
	input wire   [3:0] m_rx_d_23,           //  MII Receive Data
	input wire   m_rx_en_23,                //  MII Receive Frame Enable  
	input wire   m_rx_err_23,               //  MII Receive Drame Error      
	output wire  [3:0] m_tx_d_23,           //  MII Transmit Data
	output wire  m_tx_en_23,                //  MII Transmit Frame Enable  
	output wire  m_tx_err_23,               //  MII Transmit Frame Error
	output wire  tx_control_23,
	output wire  [3:0] rgmii_out_23,
	input wire   [3:0] rgmii_in_23,
	input wire   rx_control_23,
	output wire  eth_mode_23,               //  Ethernet Mode
	output wire  ena_10_23,                 //  Enable 10Mbps Mode
	input wire   set_1000_23,               //  Gigabit Mode Enable
	input wire   set_10_23,                 //  10Mbps Mode Enable
	
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




	altera_tse_top_multi_mac U_TOP_MULTI_MAC(
	
	        .reset(reset),                            //INPUT  : ASYNCHRONOUS RESET - clk DOMAIN
	        .clk(clk),                                //INPUT  : CLOCK
	        .read(read),                              //INPUT  : REGISTER READ TRANSACTION
	        .write(write),                            //INPUT  : REGISTER WRITE TRANSACTION
	        .address(address),                        //INPUT  : REGISTER ADDRESS
	        .writedata(writedata),                    //INPUT  : REGISTER WRITE DATA
	        .readdata(readdata),                      //OUTPUT : REGISTER READ DATA
	        .waitrequest(waitrequest),                //OUTPUT : TRANSACTION BUSY, ACTIVE LOW
	        .mdc(mdc),                                //OUTPUT : MDIO Clock 
	        .mdio_out(mdio_out),                      //OUTPUT : Outgoing MDIO DATA
	        .mdio_in(mdio_in),                        //INPUT  : Incoming MDIO DATA       
	        .mdio_oen(mdio_oen),                      //OUTPUT : MDIO Output Enable
	        .rx_clk(rx_clk),                          //INPUT  : MAC RX CLK
	        .tx_clk(tx_clk),                          //INPUT  : MAC TX CLK
	        .mac_rx_clk(mac_rx_clk),                  //OUTPUT : Av-ST Rx Clock
            .mac_tx_clk(mac_tx_clk),                  //OUTPUT : Av-ST Tx Clock
            .rx_afull_clk(rx_afull_clk),              //INPUT  : AFull Status Clock
	        .rx_afull_data(rx_afull_data),            //INPUT  : AFull Status Data
	        .rx_afull_valid(rx_afull_valid),          //INPUT  : AFull Status Valid
	        .rx_afull_channel(rx_afull_channel),      //INPUT  : AFull Status Channel
            
             // Channel 0 
	        
	        .rx_clk_0(rx_clk_0),                      //INPUT  : MAC RX CLK
	        .tx_clk_0(tx_clk_0),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_0(gm_rx_d_0),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_0(gm_rx_dv_0),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_0(gm_rx_err_0),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_0(gm_tx_d_0),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_0(gm_tx_en_0),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_0(gm_tx_err_0),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_0(m_rx_crs_0),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_0(m_rx_col_0),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_0(m_rx_d_0),                      //INPUT  : MII RX DATA
	        .m_rx_en_0(m_rx_en_0),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_0(m_rx_err_0),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_0(m_tx_d_0),                      //OUTPUT : MII TX DATA
	        .m_tx_en_0(m_tx_en_0),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_0(m_tx_err_0),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_0(rx_control_0),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_0(rgmii_in_0),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_0(tx_control_0),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_0(rgmii_out_0),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_0(eth_mode_0),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_0(ena_10_0),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_0(set_10_0),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_0(set_1000_0),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_1(rx_clk_1),                      //INPUT  : MAC RX CLK
	        .tx_clk_1(tx_clk_1),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_1(gm_rx_d_1),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_1(gm_rx_dv_1),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_1(gm_rx_err_1),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_1(gm_tx_d_1),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_1(gm_tx_en_1),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_1(gm_tx_err_1),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_1(m_rx_crs_1),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_1(m_rx_col_1),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_1(m_rx_d_1),                      //INPUT  : MII RX DATA
	        .m_rx_en_1(m_rx_en_1),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_1(m_rx_err_1),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_1(m_tx_d_1),                      //OUTPUT : MII TX DATA
	        .m_tx_en_1(m_tx_en_1),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_1(m_tx_err_1),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_1(rx_control_1),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_1(rgmii_in_1),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_1(tx_control_1),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_1(rgmii_out_1),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_1(eth_mode_1),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_1(ena_10_1),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_1(set_10_1),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_1(set_1000_1),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_2(rx_clk_2),                      //INPUT  : MAC RX CLK
	        .tx_clk_2(tx_clk_2),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_2(gm_rx_d_2),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_2(gm_rx_dv_2),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_2(gm_rx_err_2),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_2(gm_tx_d_2),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_2(gm_tx_en_2),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_2(gm_tx_err_2),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_2(m_rx_crs_2),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_2(m_rx_col_2),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_2(m_rx_d_2),                      //INPUT  : MII RX DATA
	        .m_rx_en_2(m_rx_en_2),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_2(m_rx_err_2),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_2(m_tx_d_2),                      //OUTPUT : MII TX DATA
	        .m_tx_en_2(m_tx_en_2),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_2(m_tx_err_2),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_2(rx_control_2),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_2(rgmii_in_2),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_2(tx_control_2),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_2(rgmii_out_2),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_2(eth_mode_2),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_2(ena_10_2),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_2(set_10_2),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_2(set_1000_2),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_3(rx_clk_3),                      //INPUT  : MAC RX CLK
	        .tx_clk_3(tx_clk_3),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_3(gm_rx_d_3),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_3(gm_rx_dv_3),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_3(gm_rx_err_3),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_3(gm_tx_d_3),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_3(gm_tx_en_3),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_3(gm_tx_err_3),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_3(m_rx_crs_3),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_3(m_rx_col_3),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_3(m_rx_d_3),                      //INPUT  : MII RX DATA
	        .m_rx_en_3(m_rx_en_3),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_3(m_rx_err_3),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_3(m_tx_d_3),                      //OUTPUT : MII TX DATA
	        .m_tx_en_3(m_tx_en_3),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_3(m_tx_err_3),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_3(rx_control_3),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_3(rgmii_in_3),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_3(tx_control_3),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_3(rgmii_out_3),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_3(eth_mode_3),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_3(ena_10_3),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_3(set_10_3),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_3(set_1000_3),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_4(rx_clk_4),                      //INPUT  : MAC RX CLK
	        .tx_clk_4(tx_clk_4),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_4(gm_rx_d_4),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_4(gm_rx_dv_4),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_4(gm_rx_err_4),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_4(gm_tx_d_4),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_4(gm_tx_en_4),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_4(gm_tx_err_4),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_4(m_rx_crs_4),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_4(m_rx_col_4),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_4(m_rx_d_4),                      //INPUT  : MII RX DATA
	        .m_rx_en_4(m_rx_en_4),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_4(m_rx_err_4),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_4(m_tx_d_4),                      //OUTPUT : MII TX DATA
	        .m_tx_en_4(m_tx_en_4),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_4(m_tx_err_4),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_4(rx_control_4),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_4(rgmii_in_4),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_4(tx_control_4),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_4(rgmii_out_4),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_4(eth_mode_4),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_4(ena_10_4),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_4(set_10_4),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_4(set_1000_4),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_5(rx_clk_5),                      //INPUT  : MAC RX CLK
	        .tx_clk_5(tx_clk_5),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_5(gm_rx_d_5),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_5(gm_rx_dv_5),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_5(gm_rx_err_5),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_5(gm_tx_d_5),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_5(gm_tx_en_5),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_5(gm_tx_err_5),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_5(m_rx_crs_5),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_5(m_rx_col_5),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_5(m_rx_d_5),                      //INPUT  : MII RX DATA
	        .m_rx_en_5(m_rx_en_5),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_5(m_rx_err_5),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_5(m_tx_d_5),                      //OUTPUT : MII TX DATA
	        .m_tx_en_5(m_tx_en_5),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_5(m_tx_err_5),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_5(rx_control_5),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_5(rgmii_in_5),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_5(tx_control_5),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_5(rgmii_out_5),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_5(eth_mode_5),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_5(ena_10_5),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_5(set_10_5),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_5(set_1000_5),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_6(rx_clk_6),                      //INPUT  : MAC RX CLK
	        .tx_clk_6(tx_clk_6),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_6(gm_rx_d_6),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_6(gm_rx_dv_6),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_6(gm_rx_err_6),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_6(gm_tx_d_6),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_6(gm_tx_en_6),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_6(gm_tx_err_6),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_6(m_rx_crs_6),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_6(m_rx_col_6),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_6(m_rx_d_6),                      //INPUT  : MII RX DATA
	        .m_rx_en_6(m_rx_en_6),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_6(m_rx_err_6),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_6(m_tx_d_6),                      //OUTPUT : MII TX DATA
	        .m_tx_en_6(m_tx_en_6),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_6(m_tx_err_6),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_6(rx_control_6),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_6(rgmii_in_6),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_6(tx_control_6),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_6(rgmii_out_6),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_6(eth_mode_6),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_6(ena_10_6),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_6(set_10_6),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_6(set_1000_6),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_7(rx_clk_7),                      //INPUT  : MAC RX CLK
	        .tx_clk_7(tx_clk_7),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_7(gm_rx_d_7),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_7(gm_rx_dv_7),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_7(gm_rx_err_7),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_7(gm_tx_d_7),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_7(gm_tx_en_7),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_7(gm_tx_err_7),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_7(m_rx_crs_7),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_7(m_rx_col_7),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_7(m_rx_d_7),                      //INPUT  : MII RX DATA
	        .m_rx_en_7(m_rx_en_7),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_7(m_rx_err_7),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_7(m_tx_d_7),                      //OUTPUT : MII TX DATA
	        .m_tx_en_7(m_tx_en_7),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_7(m_tx_err_7),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_7(rx_control_7),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_7(rgmii_in_7),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_7(tx_control_7),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_7(rgmii_out_7),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_7(eth_mode_7),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_7(ena_10_7),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_7(set_10_7),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_7(set_1000_7),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_8(rx_clk_8),                      //INPUT  : MAC RX CLK
	        .tx_clk_8(tx_clk_8),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_8(gm_rx_d_8),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_8(gm_rx_dv_8),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_8(gm_rx_err_8),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_8(gm_tx_d_8),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_8(gm_tx_en_8),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_8(gm_tx_err_8),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_8(m_rx_crs_8),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_8(m_rx_col_8),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_8(m_rx_d_8),                      //INPUT  : MII RX DATA
	        .m_rx_en_8(m_rx_en_8),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_8(m_rx_err_8),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_8(m_tx_d_8),                      //OUTPUT : MII TX DATA
	        .m_tx_en_8(m_tx_en_8),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_8(m_tx_err_8),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_8(rx_control_8),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_8(rgmii_in_8),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_8(tx_control_8),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_8(rgmii_out_8),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_8(eth_mode_8),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_8(ena_10_8),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_8(set_10_8),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_8(set_1000_8),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_9(rx_clk_9),                      //INPUT  : MAC RX CLK
	        .tx_clk_9(tx_clk_9),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_9(gm_rx_d_9),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_9(gm_rx_dv_9),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_9(gm_rx_err_9),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_9(gm_tx_d_9),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_9(gm_tx_en_9),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_9(gm_tx_err_9),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_9(m_rx_crs_9),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_9(m_rx_col_9),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_9(m_rx_d_9),                      //INPUT  : MII RX DATA
	        .m_rx_en_9(m_rx_en_9),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_9(m_rx_err_9),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_9(m_tx_d_9),                      //OUTPUT : MII TX DATA
	        .m_tx_en_9(m_tx_en_9),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_9(m_tx_err_9),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_9(rx_control_9),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_9(rgmii_in_9),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_9(tx_control_9),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_9(rgmii_out_9),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_9(eth_mode_9),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_9(ena_10_9),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_9(set_10_9),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_9(set_1000_9),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_10(rx_clk_10),                      //INPUT  : MAC RX CLK
	        .tx_clk_10(tx_clk_10),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_10(gm_rx_d_10),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_10(gm_rx_dv_10),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_10(gm_rx_err_10),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_10(gm_tx_d_10),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_10(gm_tx_en_10),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_10(gm_tx_err_10),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_10(m_rx_crs_10),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_10(m_rx_col_10),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_10(m_rx_d_10),                      //INPUT  : MII RX DATA
	        .m_rx_en_10(m_rx_en_10),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_10(m_rx_err_10),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_10(m_tx_d_10),                      //OUTPUT : MII TX DATA
	        .m_tx_en_10(m_tx_en_10),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_10(m_tx_err_10),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_10(rx_control_10),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_10(rgmii_in_10),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_10(tx_control_10),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_10(rgmii_out_10),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_10(eth_mode_10),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_10(ena_10_10),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_10(set_10_10),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_10(set_1000_10),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_11(rx_clk_11),                      //INPUT  : MAC RX CLK
	        .tx_clk_11(tx_clk_11),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_11(gm_rx_d_11),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_11(gm_rx_dv_11),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_11(gm_rx_err_11),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_11(gm_tx_d_11),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_11(gm_tx_en_11),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_11(gm_tx_err_11),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_11(m_rx_crs_11),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_11(m_rx_col_11),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_11(m_rx_d_11),                      //INPUT  : MII RX DATA
	        .m_rx_en_11(m_rx_en_11),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_11(m_rx_err_11),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_11(m_tx_d_11),                      //OUTPUT : MII TX DATA
	        .m_tx_en_11(m_tx_en_11),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_11(m_tx_err_11),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_11(rx_control_11),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_11(rgmii_in_11),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_11(tx_control_11),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_11(rgmii_out_11),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_11(eth_mode_11),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_11(ena_10_11),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_11(set_10_11),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_11(set_1000_11),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_12(rx_clk_12),                      //INPUT  : MAC RX CLK
	        .tx_clk_12(tx_clk_12),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_12(gm_rx_d_12),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_12(gm_rx_dv_12),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_12(gm_rx_err_12),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_12(gm_tx_d_12),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_12(gm_tx_en_12),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_12(gm_tx_err_12),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_12(m_rx_crs_12),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_12(m_rx_col_12),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_12(m_rx_d_12),                      //INPUT  : MII RX DATA
	        .m_rx_en_12(m_rx_en_12),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_12(m_rx_err_12),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_12(m_tx_d_12),                      //OUTPUT : MII TX DATA
	        .m_tx_en_12(m_tx_en_12),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_12(m_tx_err_12),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_12(rx_control_12),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_12(rgmii_in_12),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_12(tx_control_12),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_12(rgmii_out_12),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_12(eth_mode_12),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_12(ena_10_12),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_12(set_10_12),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_12(set_1000_12),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_13(rx_clk_13),                      //INPUT  : MAC RX CLK
	        .tx_clk_13(tx_clk_13),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_13(gm_rx_d_13),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_13(gm_rx_dv_13),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_13(gm_rx_err_13),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_13(gm_tx_d_13),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_13(gm_tx_en_13),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_13(gm_tx_err_13),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_13(m_rx_crs_13),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_13(m_rx_col_13),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_13(m_rx_d_13),                      //INPUT  : MII RX DATA
	        .m_rx_en_13(m_rx_en_13),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_13(m_rx_err_13),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_13(m_tx_d_13),                      //OUTPUT : MII TX DATA
	        .m_tx_en_13(m_tx_en_13),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_13(m_tx_err_13),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_13(rx_control_13),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_13(rgmii_in_13),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_13(tx_control_13),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_13(rgmii_out_13),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_13(eth_mode_13),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_13(ena_10_13),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_13(set_10_13),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_13(set_1000_13),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_14(rx_clk_14),                      //INPUT  : MAC RX CLK
	        .tx_clk_14(tx_clk_14),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_14(gm_rx_d_14),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_14(gm_rx_dv_14),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_14(gm_rx_err_14),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_14(gm_tx_d_14),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_14(gm_tx_en_14),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_14(gm_tx_err_14),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_14(m_rx_crs_14),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_14(m_rx_col_14),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_14(m_rx_d_14),                      //INPUT  : MII RX DATA
	        .m_rx_en_14(m_rx_en_14),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_14(m_rx_err_14),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_14(m_tx_d_14),                      //OUTPUT : MII TX DATA
	        .m_tx_en_14(m_tx_en_14),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_14(m_tx_err_14),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_14(rx_control_14),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_14(rgmii_in_14),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_14(tx_control_14),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_14(rgmii_out_14),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_14(eth_mode_14),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_14(ena_10_14),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_14(set_10_14),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_14(set_1000_14),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_15(rx_clk_15),                      //INPUT  : MAC RX CLK
	        .tx_clk_15(tx_clk_15),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_15(gm_rx_d_15),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_15(gm_rx_dv_15),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_15(gm_rx_err_15),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_15(gm_tx_d_15),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_15(gm_tx_en_15),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_15(gm_tx_err_15),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_15(m_rx_crs_15),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_15(m_rx_col_15),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_15(m_rx_d_15),                      //INPUT  : MII RX DATA
	        .m_rx_en_15(m_rx_en_15),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_15(m_rx_err_15),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_15(m_tx_d_15),                      //OUTPUT : MII TX DATA
	        .m_tx_en_15(m_tx_en_15),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_15(m_tx_err_15),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_15(rx_control_15),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_15(rgmii_in_15),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_15(tx_control_15),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_15(rgmii_out_15),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_15(eth_mode_15),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_15(ena_10_15),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_15(set_10_15),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_15(set_1000_15),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_16(rx_clk_16),                      //INPUT  : MAC RX CLK
	        .tx_clk_16(tx_clk_16),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_16(gm_rx_d_16),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_16(gm_rx_dv_16),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_16(gm_rx_err_16),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_16(gm_tx_d_16),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_16(gm_tx_en_16),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_16(gm_tx_err_16),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_16(m_rx_crs_16),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_16(m_rx_col_16),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_16(m_rx_d_16),                      //INPUT  : MII RX DATA
	        .m_rx_en_16(m_rx_en_16),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_16(m_rx_err_16),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_16(m_tx_d_16),                      //OUTPUT : MII TX DATA
	        .m_tx_en_16(m_tx_en_16),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_16(m_tx_err_16),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_16(rx_control_16),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_16(rgmii_in_16),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_16(tx_control_16),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_16(rgmii_out_16),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_16(eth_mode_16),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_16(ena_10_16),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_16(set_10_16),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_16(set_1000_16),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_17(rx_clk_17),                      //INPUT  : MAC RX CLK
	        .tx_clk_17(tx_clk_17),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_17(gm_rx_d_17),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_17(gm_rx_dv_17),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_17(gm_rx_err_17),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_17(gm_tx_d_17),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_17(gm_tx_en_17),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_17(gm_tx_err_17),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_17(m_rx_crs_17),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_17(m_rx_col_17),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_17(m_rx_d_17),                      //INPUT  : MII RX DATA
	        .m_rx_en_17(m_rx_en_17),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_17(m_rx_err_17),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_17(m_tx_d_17),                      //OUTPUT : MII TX DATA
	        .m_tx_en_17(m_tx_en_17),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_17(m_tx_err_17),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_17(rx_control_17),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_17(rgmii_in_17),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_17(tx_control_17),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_17(rgmii_out_17),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_17(eth_mode_17),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_17(ena_10_17),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_17(set_10_17),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_17(set_1000_17),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_18(rx_clk_18),                      //INPUT  : MAC RX CLK
	        .tx_clk_18(tx_clk_18),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_18(gm_rx_d_18),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_18(gm_rx_dv_18),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_18(gm_rx_err_18),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_18(gm_tx_d_18),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_18(gm_tx_en_18),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_18(gm_tx_err_18),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_18(m_rx_crs_18),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_18(m_rx_col_18),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_18(m_rx_d_18),                      //INPUT  : MII RX DATA
	        .m_rx_en_18(m_rx_en_18),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_18(m_rx_err_18),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_18(m_tx_d_18),                      //OUTPUT : MII TX DATA
	        .m_tx_en_18(m_tx_en_18),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_18(m_tx_err_18),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_18(rx_control_18),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_18(rgmii_in_18),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_18(tx_control_18),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_18(rgmii_out_18),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_18(eth_mode_18),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_18(ena_10_18),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_18(set_10_18),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_18(set_1000_18),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_19(rx_clk_19),                      //INPUT  : MAC RX CLK
	        .tx_clk_19(tx_clk_19),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_19(gm_rx_d_19),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_19(gm_rx_dv_19),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_19(gm_rx_err_19),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_19(gm_tx_d_19),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_19(gm_tx_en_19),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_19(gm_tx_err_19),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_19(m_rx_crs_19),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_19(m_rx_col_19),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_19(m_rx_d_19),                      //INPUT  : MII RX DATA
	        .m_rx_en_19(m_rx_en_19),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_19(m_rx_err_19),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_19(m_tx_d_19),                      //OUTPUT : MII TX DATA
	        .m_tx_en_19(m_tx_en_19),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_19(m_tx_err_19),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_19(rx_control_19),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_19(rgmii_in_19),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_19(tx_control_19),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_19(rgmii_out_19),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_19(eth_mode_19),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_19(ena_10_19),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_19(set_10_19),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_19(set_1000_19),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_20(rx_clk_20),                      //INPUT  : MAC RX CLK
	        .tx_clk_20(tx_clk_20),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_20(gm_rx_d_20),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_20(gm_rx_dv_20),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_20(gm_rx_err_20),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_20(gm_tx_d_20),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_20(gm_tx_en_20),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_20(gm_tx_err_20),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_20(m_rx_crs_20),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_20(m_rx_col_20),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_20(m_rx_d_20),                      //INPUT  : MII RX DATA
	        .m_rx_en_20(m_rx_en_20),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_20(m_rx_err_20),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_20(m_tx_d_20),                      //OUTPUT : MII TX DATA
	        .m_tx_en_20(m_tx_en_20),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_20(m_tx_err_20),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_20(rx_control_20),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_20(rgmii_in_20),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_20(tx_control_20),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_20(rgmii_out_20),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_20(eth_mode_20),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_20(ena_10_20),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_20(set_10_20),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_20(set_1000_20),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_21(rx_clk_21),                      //INPUT  : MAC RX CLK
	        .tx_clk_21(tx_clk_21),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_21(gm_rx_d_21),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_21(gm_rx_dv_21),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_21(gm_rx_err_21),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_21(gm_tx_d_21),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_21(gm_tx_en_21),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_21(gm_tx_err_21),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_21(m_rx_crs_21),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_21(m_rx_col_21),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_21(m_rx_d_21),                      //INPUT  : MII RX DATA
	        .m_rx_en_21(m_rx_en_21),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_21(m_rx_err_21),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_21(m_tx_d_21),                      //OUTPUT : MII TX DATA
	        .m_tx_en_21(m_tx_en_21),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_21(m_tx_err_21),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_21(rx_control_21),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_21(rgmii_in_21),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_21(tx_control_21),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_21(rgmii_out_21),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_21(eth_mode_21),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_21(ena_10_21),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_21(set_10_21),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_21(set_1000_21),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_22(rx_clk_22),                      //INPUT  : MAC RX CLK
	        .tx_clk_22(tx_clk_22),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_22(gm_rx_d_22),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_22(gm_rx_dv_22),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_22(gm_rx_err_22),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_22(gm_tx_d_22),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_22(gm_tx_en_22),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_22(gm_tx_err_22),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_22(m_rx_crs_22),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_22(m_rx_col_22),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_22(m_rx_d_22),                      //INPUT  : MII RX DATA
	        .m_rx_en_22(m_rx_en_22),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_22(m_rx_err_22),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_22(m_tx_d_22),                      //OUTPUT : MII TX DATA
	        .m_tx_en_22(m_tx_en_22),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_22(m_tx_err_22),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_22(rx_control_22),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_22(rgmii_in_22),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_22(tx_control_22),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_22(rgmii_out_22),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_22(eth_mode_22),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_22(ena_10_22),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_22(set_10_22),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_22(set_1000_22),                  //INPUT  : SPEED 1000 MBPS
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
	        
	        .rx_clk_23(rx_clk_23),                      //INPUT  : MAC RX CLK
	        .tx_clk_23(tx_clk_23),                      //INPUT  : MAC TX CLK
	        .gm_rx_d_23(gm_rx_d_23),                    //INPUT  : GMII RX DATA
	        .gm_rx_dv_23(gm_rx_dv_23),                  //INPUT  : GMII RX VALID INDICATION
	        .gm_rx_err_23(gm_rx_err_23),                //INPUT  : GMII RX ERROR INDICATION
	        .gm_tx_d_23(gm_tx_d_23),                    //OUTPUT : GMII TX DATA
	        .gm_tx_en_23(gm_tx_en_23),                  //OUTPUT : GMII TX VALID INDICATION
	        .gm_tx_err_23(gm_tx_err_23),                //OUTPUT : GMII TX ERROR INDICATION
	        .m_rx_crs_23(m_rx_crs_23),                  //INPUT  : MII RX CARRIER SENSE
	        .m_rx_col_23(m_rx_col_23),                  //INPUT  : MII RX COLLISION
	        .m_rx_d_23(m_rx_d_23),                      //INPUT  : MII RX DATA
	        .m_rx_en_23(m_rx_en_23),                    //INPUT  : MII RX VALID INDICATION
	        .m_rx_err_23(m_rx_err_23),                  //INPUT  : MII RX ERROR INDICATION
	        .m_tx_d_23(m_tx_d_23),                      //OUTPUT : MII TX DATA
	        .m_tx_en_23(m_tx_en_23),                    //OUTPUT : MII TX VALID INDICATION
	        .m_tx_err_23(m_tx_err_23),                  //OUTPUT : MII TX ERROR INDICATION
	        .rx_control_23(rx_control_23),              //INPUT  : RGMII RX CONTROL INDICATION
	        .rgmii_in_23(rgmii_in_23),                  //INPUT  : RGMII RX DATA INDICATION
	        .tx_control_23(tx_control_23),              //OUTPUT : RGMII TX CONTROL INDICATION
	        .rgmii_out_23(rgmii_out_23),                //OUTPUT : RGMII TX DATA INDICATION
	        .eth_mode_23(eth_mode_23),                  //OUTPUT : ETHERNET SPEED 1000MBPS INDICATION
	        .ena_10_23(ena_10_23),                      //OUTPUT : SPEED 10 MBPS INDICATION
	        .set_10_23(set_10_23),                      //INPUT  : SPEED 10 MBPS
	        .set_1000_23(set_1000_23),                  //INPUT  : SPEED 1000 MBPS
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
	        U_TOP_MULTI_MAC.USE_SYNC_RESET = USE_SYNC_RESET, 
	        U_TOP_MULTI_MAC.RESET_LEVEL = RESET_LEVEL,
	        U_TOP_MULTI_MAC.ENABLE_GMII_LOOPBACK = ENABLE_GMII_LOOPBACK, 
	        U_TOP_MULTI_MAC.ENABLE_HD_LOGIC = ENABLE_HD_LOGIC,
	        U_TOP_MULTI_MAC.ENABLE_SUP_ADDR = ENABLE_SUP_ADDR,
	        U_TOP_MULTI_MAC.ENA_HASH = ENA_HASH,
	        U_TOP_MULTI_MAC.STAT_CNT_ENA = STAT_CNT_ENA,
	        U_TOP_MULTI_MAC.CORE_VERSION = CORE_VERSION, 
	        U_TOP_MULTI_MAC.CUST_VERSION = CUST_VERSION,
	        U_TOP_MULTI_MAC.REDUCED_INTERFACE_ENA = REDUCED_INTERFACE_ENA,
	        U_TOP_MULTI_MAC.ENABLE_MDIO = ENABLE_MDIO,
	        U_TOP_MULTI_MAC.MDIO_CLK_DIV = MDIO_CLK_DIV,
	        U_TOP_MULTI_MAC.ENABLE_MAGIC_DETECT = ENABLE_MAGIC_DETECT,
	        U_TOP_MULTI_MAC.CRC32DWIDTH = CRC32DWIDTH,
	        U_TOP_MULTI_MAC.CRC32GENDELAY = CRC32GENDELAY, 
	        U_TOP_MULTI_MAC.CRC32CHECK16BIT = CRC32CHECK16BIT, 
	        U_TOP_MULTI_MAC.CRC32S1L2_EXTERN = CRC32S1L2_EXTERN,
	        U_TOP_MULTI_MAC.ENABLE_SHIFT16 = ENABLE_SHIFT16,   
	        U_TOP_MULTI_MAC.ENABLE_MAC_FLOW_CTRL = ENABLE_MAC_FLOW_CTRL,
	        U_TOP_MULTI_MAC.ENABLE_MAC_TXADDR_SET = ENABLE_MAC_TXADDR_SET,
	        U_TOP_MULTI_MAC.ENABLE_MAC_RX_VLAN = ENABLE_MAC_RX_VLAN,
	        U_TOP_MULTI_MAC.ENABLE_MAC_TX_VLAN = ENABLE_MAC_TX_VLAN,
	        U_TOP_MULTI_MAC.ADDR_WIDTH = ADDR_WIDTH,
	        U_TOP_MULTI_MAC.MAX_CHANNELS = MAX_CHANNELS,
	        U_TOP_MULTI_MAC.CHANNEL_WIDTH = CHANNEL_WIDTH,
	        U_TOP_MULTI_MAC.ENABLE_RX_FIFO_STATUS = ENABLE_RX_FIFO_STATUS,
	        U_TOP_MULTI_MAC.ENABLE_EXTENDED_STAT_REG = ENABLE_EXTENDED_STAT_REG,
	        U_TOP_MULTI_MAC.ENABLE_REG_SHARING = ENABLE_REG_SHARING,
			U_TOP_MULTI_MAC.SYNCHRONIZER_DEPTH = SYNCHRONIZER_DEPTH,
	        U_TOP_MULTI_MAC.ENABLE_CLK_SHARING = ENABLE_CLK_SHARING;    




endmodule // module altera_tse_multi_mac
