
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_multi_mac_pcs_pma_gige.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_multi_mac_pcs_pma_gige.v,v $
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

(*altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION OFF;SUPPRESS_DA_RULE_INTERNAL=\"R102,R105,D102,D101,D103\"" } *)
module altera_tse_multi_mac_pcs_pma_gige
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
parameter ENABLE_CLK_SHARING    = 1,                    //  Option to share clock for multiple channels (Clocks are rate-matched).
parameter ENABLE_REG_SHARING    = 0,                    //  Option to share register space. Uses certain hard-coded values from input.
parameter ENABLE_EXTENDED_STAT_REG = 0,                 //  Enable a few extended statistic registers
parameter MAX_CHANNELS          = 1,                    //  The number of channels in Multi-TSE component
parameter ENABLE_PKT_CLASS      = 1,                    //  Enable Packet Classification Av-ST Interface
parameter ENABLE_RX_FIFO_STATUS = 1,                    //  Enable Receive FIFO Almost Full status interface
parameter CHANNEL_WIDTH         = 1,                    //  The width of the channel interface
parameter EXPORT_PWRDN          = 1'b0,                 //  Option to export the Alt2gxb powerdown signal
parameter DEVICE_FAMILY         = "ARRIAGX",            //  The device family the the core is targetted for.
parameter TRANSCEIVER_OPTION    = 1'b0,                 //  Option to select transceiver block for MAC PCS PMA Instantiation. Valid Values are 0 and 1:  0 - GXB (GIGE Mode) 1 - LVDS IO
parameter ENABLE_ALT_RECONFIG   = 0,                    //  Option to expose the altreconfig ports
parameter SYNCHRONIZER_DEPTH    = 3,                    //  Number of synchronizer
// Internal parameters
parameter STARTING_CHANNEL_NUMBER = 0,
parameter ADDR_WIDTH = (MAX_CHANNELS > 16)? 13 :
                       (MAX_CHANNELS > 8)? 12 : 
                       (MAX_CHANNELS > 4)? 11 : 
                       (MAX_CHANNELS > 2)? 10 :  
                       (MAX_CHANNELS > 1)? 9 : 8,
//IEEE1588 code
parameter ENABLE_TIMESTAMPING               = 0,                //      To enable time stamping logic
parameter ENABLE_PTP_1STEP                      = 0,            //      To enable time 1 step clock PTP
parameter TSTAMP_FP_WIDTH                   = 4         //      Finger print width associated to the timestamp request

)


// Port List
(

    // RESET / MAC REG IF / MDIO
    input wire                               reset, //  Asynchronous Reset - clk Domain
    input wire                               clk, //  25MHz Host Interface Clock
    input wire                               read, //  Register Read Strobe
    input wire                               write, //  Register Write Strobe
    input wire [ADDR_WIDTH-1:0]              address, //  Register Address
    input wire [31:0]                        writedata, //  Write Data for Host Bus
    output wire [31:0]                       readdata, //  Read Data to Host Bus
    output wire                              waitrequest, //  Interface Busy
    output wire                              mdc, //  2.5MHz Inteface
    input wire                               mdio_in, //  MDIO Input
    output wire                              mdio_out, //  MDIO Output
    output wire                              mdio_oen, //  MDIO Output Enable

    // DEVICE SPECIFIC SIGNALS
    input wire                               gxb_cal_blk_clk, //  GXB Calibration Clock
    input wire                               ref_clk, //  Rference Clock

        // SHARED CLK SIGNALS
    output wire                              mac_rx_clk, //  Av-ST Receive Clock
    output wire                              mac_tx_clk, //  Av-ST Transmit Clock 
    input wire                               pcs_phase_measure_clk,

        // SHARED RX STATUS
    input wire                               rx_afull_clk, //  Almost full clk
    input wire [1:0]                         rx_afull_data, //  Almost full data
    input wire                               rx_afull_valid, //  Almost full valid
    input wire [CHANNEL_WIDTH-1:0]           rx_afull_channel, //  Almost full channel


    // CHANNEL 0

    // PCS SIGNALS TO PHY
    input wire                               rxp_0, //  Differential Receive Data 
    output wire                              txp_0, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_0, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_0, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_0, //  Receiver Recovered Clock 
    output wire                              led_crs_0, //  Carrier Sense
    output wire                              led_link_0, //  Valid Link 
    output wire                              led_col_0, //  Collision Indication
    output wire                              led_an_0, //  Auto-Negotiation Status
    output wire                              led_char_err_0, //  Character Error
    output wire                              led_disp_err_0, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_0, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_0, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_0, //  Start of Packet
    output wire                              data_rx_eop_0, //  End of Packet
    output wire [7:0]                        data_rx_data_0, //  Data from FIFO
    output wire [4:0]                        data_rx_error_0, //  Receive packet error
    output wire                              data_rx_valid_0, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_0, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_0, //  Frame Type Indication
    output wire                              pkt_class_valid_0, //  Frame Type Indication Valid 
    input wire                               data_tx_error_0, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_0, //  Data from FIFO transmit
    input wire                               data_tx_valid_0, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_0, //  Start of Packet
    input wire                               data_tx_eop_0, //  END of Packet
    output wire                              data_tx_ready_0, //  Data FIFO transmit Read Enable        

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_0, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_0, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_0, //  Xoff Pause frame generate 
    input wire                               xon_gen_0, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_0, //  Enable Sleep Mode
    output wire                              magic_wakeup_0, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_0, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_0, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_0, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_0, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_0, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_0, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_0, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_0, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_0, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_0, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_0, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_0, //  Clock for reconfiguration block
    input wire                               reconfig_busy_0, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_0, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_0, //  Signals from the gxb block to the reconfig block


    // CHANNEL 1

    // PCS SIGNALS TO PHY
    input wire                               rxp_1, //  Differential Receive Data 
    output wire                              txp_1, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_1, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_1, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_1, //  Receiver Recovered Clock 
    output wire                              led_crs_1, //  Carrier Sense
    output wire                              led_link_1, //  Valid Link 
    output wire                              led_col_1, //  Collision Indication
    output wire                              led_an_1, //  Auto-Negotiation Status
    output wire                              led_char_err_1, //  Character Error
    output wire                              led_disp_err_1, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_1, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_1, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_1, //  Start of Packet
    output wire                              data_rx_eop_1, //  End of Packet
    output wire [7:0]                        data_rx_data_1, //  Data from FIFO
    output wire [4:0]                        data_rx_error_1, //  Receive packet error
    output wire                              data_rx_valid_1, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_1, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_1, //  Frame Type Indication
    output wire                              pkt_class_valid_1, //  Frame Type Indication Valid 
    input wire                               data_tx_error_1, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_1, //  Data from FIFO transmit
    input wire                               data_tx_valid_1, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_1, //  Start of Packet
    input wire                               data_tx_eop_1, //  END of Packet
    output wire                              data_tx_ready_1, //  Data FIFO transmit Read Enable        

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_1, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_1, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_1, //  Xoff Pause frame generate 
    input wire                               xon_gen_1, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_1, //  Enable Sleep Mode
    output wire                              magic_wakeup_1, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_1, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_1, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_1, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_1, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_1, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_1, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_1, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_1, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_1, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_1, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_1, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_1, //  Clock for reconfiguration block
    input wire                               reconfig_busy_1, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_1, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_1, //  Signals from the gxb block to the reconfig block


    // CHANNEL 2

    // PCS SIGNALS TO PHY
    input wire                               rxp_2, //  Differential Receive Data 
    output wire                              txp_2, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_2, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_2, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_2, //  Receiver Recovered Clock 
    output wire                              led_crs_2, //  Carrier Sense
    output wire                              led_link_2, //  Valid Link 
    output wire                              led_col_2, //  Collision Indication
    output wire                              led_an_2, //  Auto-Negotiation Status
    output wire                              led_char_err_2, //  Character Error
    output wire                              led_disp_err_2, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_2, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_2, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_2, //  Start of Packet
    output wire                              data_rx_eop_2, //  End of Packet
    output wire [7:0]                        data_rx_data_2, //  Data from FIFO
    output wire [4:0]                        data_rx_error_2, //  Receive packet error
    output wire                              data_rx_valid_2, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_2, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_2, //  Frame Type Indication
    output wire                              pkt_class_valid_2, //  Frame Type Indication Valid 
    input wire                               data_tx_error_2, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_2, //  Data from FIFO transmit
    input wire                               data_tx_valid_2, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_2, //  Start of Packet
    input wire                               data_tx_eop_2, //  END of Packet
    output wire                              data_tx_ready_2, //  Data FIFO transmit Read Enable        

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_2, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_2, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_2, //  Xoff Pause frame generate 
    input wire                               xon_gen_2, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_2, //  Enable Sleep Mode
    output wire                              magic_wakeup_2, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_2, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_2, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_2, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_2, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_2, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_2, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_2, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_2, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_2, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_2, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_2, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_2, //  Clock for reconfiguration block
    input wire                               reconfig_busy_2, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_2, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_2, //  Signals from the gxb block to the reconfig block


    // CHANNEL 3

    // PCS SIGNALS TO PHY
    input wire                               rxp_3, //  Differential Receive Data 
    output wire                              txp_3, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_3, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_3, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_3, //  Receiver Recovered Clock 
    output wire                              led_crs_3, //  Carrier Sense
    output wire                              led_link_3, //  Valid Link 
    output wire                              led_col_3, //  Collision Indication
    output wire                              led_an_3, //  Auto-Negotiation Status
    output wire                              led_char_err_3, //  Character Error
    output wire                              led_disp_err_3, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_3, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_3, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_3, //  Start of Packet
    output wire                              data_rx_eop_3, //  End of Packet
    output wire [7:0]                        data_rx_data_3, //  Data from FIFO
    output wire [4:0]                        data_rx_error_3, //  Receive packet error
    output wire                              data_rx_valid_3, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_3, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_3, //  Frame Type Indication
    output wire                              pkt_class_valid_3, //  Frame Type Indication Valid 
    input wire                               data_tx_error_3, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_3, //  Data from FIFO transmit
    input wire                               data_tx_valid_3, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_3, //  Start of Packet
    input wire                               data_tx_eop_3, //  END of Packet
    output wire                              data_tx_ready_3, //  Data FIFO transmit Read Enable        

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_3, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_3, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_3, //  Xoff Pause frame generate 
    input wire                               xon_gen_3, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_3, //  Enable Sleep Mode
    output wire                              magic_wakeup_3, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_3, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_3, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_3, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_3, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_3, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_3, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_3, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_3, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_3, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_3, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_3, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_3, //  Clock for reconfiguration block
    input wire                               reconfig_busy_3, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_3, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_3, //  Signals from the gxb block to the reconfig block


    // CHANNEL 4

    // PCS SIGNALS TO PHY
    input wire                               rxp_4, //  Differential Receive Data 
    output wire                              txp_4, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_4, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_4, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_4, //  Receiver Recovered Clock 
    output wire                              led_crs_4, //  Carrier Sense
    output wire                              led_link_4, //  Valid Link 
    output wire                              led_col_4, //  Collision Indication
    output wire                              led_an_4, //  Auto-Negotiation Status
    output wire                              led_char_err_4, //  Character Error
    output wire                              led_disp_err_4, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_4, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_4, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_4, //  Start of Packet
    output wire                              data_rx_eop_4, //  End of Packet
    output wire [7:0]                        data_rx_data_4, //  Data from FIFO
    output wire [4:0]                        data_rx_error_4, //  Receive packet error
    output wire                              data_rx_valid_4, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_4, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_4, //  Frame Type Indication
    output wire                              pkt_class_valid_4, //  Frame Type Indication Valid 
    input wire                               data_tx_error_4, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_4, //  Data from FIFO transmit
    input wire                               data_tx_valid_4, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_4, //  Start of Packet
    input wire                               data_tx_eop_4, //  END of Packet
    output wire                              data_tx_ready_4, //  Data FIFO transmit Read Enable        

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_4, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_4, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_4, //  Xoff Pause frame generate 
    input wire                               xon_gen_4, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_4, //  Enable Sleep Mode
    output wire                              magic_wakeup_4, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_4, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_4, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_4, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_4, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_4, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_4, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_4, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_4, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_4, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_4, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_4, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_4, //  Clock for reconfiguration block
    input wire                               reconfig_busy_4, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_4, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_4, //  Signals from the gxb block to the reconfig block


    // CHANNEL 5

    // PCS SIGNALS TO PHY
    input wire                               rxp_5, //  Differential Receive Data 
    output wire                              txp_5, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_5, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_5, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_5, //  Receiver Recovered Clock 
    output wire                              led_crs_5, //  Carrier Sense
    output wire                              led_link_5, //  Valid Link 
    output wire                              led_col_5, //  Collision Indication
    output wire                              led_an_5, //  Auto-Negotiation Status
    output wire                              led_char_err_5, //  Character Error
    output wire                              led_disp_err_5, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_5, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_5, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_5, //  Start of Packet
    output wire                              data_rx_eop_5, //  End of Packet
    output wire [7:0]                        data_rx_data_5, //  Data from FIFO
    output wire [4:0]                        data_rx_error_5, //  Receive packet error
    output wire                              data_rx_valid_5, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_5, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_5, //  Frame Type Indication
    output wire                              pkt_class_valid_5, //  Frame Type Indication Valid 
    input wire                               data_tx_error_5, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_5, //  Data from FIFO transmit
    input wire                               data_tx_valid_5, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_5, //  Start of Packet
    input wire                               data_tx_eop_5, //  END of Packet
    output wire                              data_tx_ready_5, //  Data FIFO transmit Read Enable        

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_5, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_5, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_5, //  Xoff Pause frame generate 
    input wire                               xon_gen_5, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_5, //  Enable Sleep Mode
    output wire                              magic_wakeup_5, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_5, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_5, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_5, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_5, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_5, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_5, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_5, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_5, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_5, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_5, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_5, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_5, //  Clock for reconfiguration block
    input wire                               reconfig_busy_5, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_5, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_5, //  Signals from the gxb block to the reconfig block


    // CHANNEL 6

    // PCS SIGNALS TO PHY
    input wire                               rxp_6, //  Differential Receive Data 
    output wire                              txp_6, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_6, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_6, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_6, //  Receiver Recovered Clock 
    output wire                              led_crs_6, //  Carrier Sense
    output wire                              led_link_6, //  Valid Link 
    output wire                              led_col_6, //  Collision Indication
    output wire                              led_an_6, //  Auto-Negotiation Status
    output wire                              led_char_err_6, //  Character Error
    output wire                              led_disp_err_6, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_6, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_6, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_6, //  Start of Packet
    output wire                              data_rx_eop_6, //  End of Packet
    output wire [7:0]                        data_rx_data_6, //  Data from FIFO
    output wire [4:0]                        data_rx_error_6, //  Receive packet error
    output wire                              data_rx_valid_6, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_6, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_6, //  Frame Type Indication
    output wire                              pkt_class_valid_6, //  Frame Type Indication Valid 
    input wire                               data_tx_error_6, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_6, //  Data from FIFO transmit
    input wire                               data_tx_valid_6, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_6, //  Start of Packet
    input wire                               data_tx_eop_6, //  END of Packet
    output wire                              data_tx_ready_6, //  Data FIFO transmit Read Enable        

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_6, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_6, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_6, //  Xoff Pause frame generate 
    input wire                               xon_gen_6, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_6, //  Enable Sleep Mode
    output wire                              magic_wakeup_6, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_6, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_6, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_6, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_6, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_6, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_6, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_6, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_6, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_6, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_6, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_6, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_6, //  Clock for reconfiguration block
    input wire                               reconfig_busy_6, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_6, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_6, //  Signals from the gxb block to the reconfig block


    // CHANNEL 7

    // PCS SIGNALS TO PHY
    input wire                               rxp_7, //  Differential Receive Data 
    output wire                              txp_7, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_7, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_7, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_7, //  Receiver Recovered Clock 
    output wire                              led_crs_7, //  Carrier Sense
    output wire                              led_link_7, //  Valid Link 
    output wire                              led_col_7, //  Collision Indication
    output wire                              led_an_7, //  Auto-Negotiation Status
    output wire                              led_char_err_7, //  Character Error
    output wire                              led_disp_err_7, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_7, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_7, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_7, //  Start of Packet
    output wire                              data_rx_eop_7, //  End of Packet
    output wire [7:0]                        data_rx_data_7, //  Data from FIFO
    output wire [4:0]                        data_rx_error_7, //  Receive packet error
    output wire                              data_rx_valid_7, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_7, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_7, //  Frame Type Indication
    output wire                              pkt_class_valid_7, //  Frame Type Indication Valid 
    input wire                               data_tx_error_7, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_7, //  Data from FIFO transmit
    input wire                               data_tx_valid_7, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_7, //  Start of Packet
    input wire                               data_tx_eop_7, //  END of Packet
    output wire                              data_tx_ready_7, //  Data FIFO transmit Read Enable        

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_7, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_7, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_7, //  Xoff Pause frame generate 
    input wire                               xon_gen_7, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_7, //  Enable Sleep Mode
    output wire                              magic_wakeup_7, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_7, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_7, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_7, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_7, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_7, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_7, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_7, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_7, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_7, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_7, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_7, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_7, //  Clock for reconfiguration block
    input wire                               reconfig_busy_7, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_7, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_7, //  Signals from the gxb block to the reconfig block


    // CHANNEL 8

    // PCS SIGNALS TO PHY
    input wire                               rxp_8, //  Differential Receive Data 
    output wire                              txp_8, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_8, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_8, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_8, //  Receiver Recovered Clock 
    output wire                              led_crs_8, //  Carrier Sense
    output wire                              led_link_8, //  Valid Link 
    output wire                              led_col_8, //  Collision Indication
    output wire                              led_an_8, //  Auto-Negotiation Status
    output wire                              led_char_err_8, //  Character Error
    output wire                              led_disp_err_8, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_8, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_8, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_8, //  Start of Packet
    output wire                              data_rx_eop_8, //  End of Packet
    output wire [7:0]                        data_rx_data_8, //  Data from FIFO
    output wire [4:0]                        data_rx_error_8, //  Receive packet error
    output wire                              data_rx_valid_8, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_8, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_8, //  Frame Type Indication
    output wire                              pkt_class_valid_8, //  Frame Type Indication Valid 
    input wire                               data_tx_error_8, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_8, //  Data from FIFO transmit
    input wire                               data_tx_valid_8, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_8, //  Start of Packet
    input wire                               data_tx_eop_8, //  END of Packet
    output wire                              data_tx_ready_8, //  Data FIFO transmit Read Enable        

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_8, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_8, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_8, //  Xoff Pause frame generate 
    input wire                               xon_gen_8, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_8, //  Enable Sleep Mode
    output wire                              magic_wakeup_8, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_8, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_8, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_8, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_8, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_8, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_8, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_8, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_8, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_8, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_8, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_8, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_8, //  Clock for reconfiguration block
    input wire                               reconfig_busy_8, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_8, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_8, //  Signals from the gxb block to the reconfig block


    // CHANNEL 9

    // PCS SIGNALS TO PHY
    input wire                               rxp_9, //  Differential Receive Data 
    output wire                              txp_9, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_9, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_9, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_9, //  Receiver Recovered Clock 
    output wire                              led_crs_9, //  Carrier Sense
    output wire                              led_link_9, //  Valid Link 
    output wire                              led_col_9, //  Collision Indication
    output wire                              led_an_9, //  Auto-Negotiation Status
    output wire                              led_char_err_9, //  Character Error
    output wire                              led_disp_err_9, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_9, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_9, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_9, //  Start of Packet
    output wire                              data_rx_eop_9, //  End of Packet
    output wire [7:0]                        data_rx_data_9, //  Data from FIFO
    output wire [4:0]                        data_rx_error_9, //  Receive packet error
    output wire                              data_rx_valid_9, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_9, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_9, //  Frame Type Indication
    output wire                              pkt_class_valid_9, //  Frame Type Indication Valid 
    input wire                               data_tx_error_9, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_9, //  Data from FIFO transmit
    input wire                               data_tx_valid_9, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_9, //  Start of Packet
    input wire                               data_tx_eop_9, //  END of Packet
    output wire                              data_tx_ready_9, //  Data FIFO transmit Read Enable        

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_9, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_9, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_9, //  Xoff Pause frame generate 
    input wire                               xon_gen_9, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_9, //  Enable Sleep Mode
    output wire                              magic_wakeup_9, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_9, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_9, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_9, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_9, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_9, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_9, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_9, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_9, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_9, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_9, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_9, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_9, //  Clock for reconfiguration block
    input wire                               reconfig_busy_9, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_9, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_9, //  Signals from the gxb block to the reconfig block


    // CHANNEL 10

    // PCS SIGNALS TO PHY
    input wire                               rxp_10, //  Differential Receive Data 
    output wire                              txp_10, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_10, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_10, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_10, //  Receiver Recovered Clock 
    output wire                              led_crs_10, //  Carrier Sense
    output wire                              led_link_10, //  Valid Link 
    output wire                              led_col_10, //  Collision Indication
    output wire                              led_an_10, //  Auto-Negotiation Status
    output wire                              led_char_err_10, //  Character Error
    output wire                              led_disp_err_10, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_10, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_10, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_10, //  Start of Packet
    output wire                              data_rx_eop_10, //  End of Packet
    output wire [7:0]                        data_rx_data_10, //  Data from FIFO
    output wire [4:0]                        data_rx_error_10, //  Receive packet error
    output wire                              data_rx_valid_10, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_10, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_10, //  Frame Type Indication
    output wire                              pkt_class_valid_10, //  Frame Type Indication Valid 
    input wire                               data_tx_error_10, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_10, //  Data from FIFO transmit
    input wire                               data_tx_valid_10, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_10, //  Start of Packet
    input wire                               data_tx_eop_10, //  END of Packet
    output wire                              data_tx_ready_10, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_10, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_10, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_10, //  Xoff Pause frame generate 
    input wire                               xon_gen_10, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_10, //  Enable Sleep Mode
    output wire                              magic_wakeup_10, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_10, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_10, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_10, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_10, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_10, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_10, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_10, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_10, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_10, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_10, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_10, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_10, //  Clock for reconfiguration block
    input wire                               reconfig_busy_10, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_10, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_10, //  Signals from the gxb block to the reconfig block


    // CHANNEL 11

    // PCS SIGNALS TO PHY
    input wire                               rxp_11, //  Differential Receive Data 
    output wire                              txp_11, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_11, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_11, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_11, //  Receiver Recovered Clock 
    output wire                              led_crs_11, //  Carrier Sense
    output wire                              led_link_11, //  Valid Link 
    output wire                              led_col_11, //  Collision Indication
    output wire                              led_an_11, //  Auto-Negotiation Status
    output wire                              led_char_err_11, //  Character Error
    output wire                              led_disp_err_11, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_11, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_11, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_11, //  Start of Packet
    output wire                              data_rx_eop_11, //  End of Packet
    output wire [7:0]                        data_rx_data_11, //  Data from FIFO
    output wire [4:0]                        data_rx_error_11, //  Receive packet error
    output wire                              data_rx_valid_11, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_11, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_11, //  Frame Type Indication
    output wire                              pkt_class_valid_11, //  Frame Type Indication Valid 
    input wire                               data_tx_error_11, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_11, //  Data from FIFO transmit
    input wire                               data_tx_valid_11, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_11, //  Start of Packet
    input wire                               data_tx_eop_11, //  END of Packet
    output wire                              data_tx_ready_11, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_11, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_11, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_11, //  Xoff Pause frame generate 
    input wire                               xon_gen_11, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_11, //  Enable Sleep Mode
    output wire                              magic_wakeup_11, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_11, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_11, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_11, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_11, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_11, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_11, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_11, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_11, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_11, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_11, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_11, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_11, //  Clock for reconfiguration block
    input wire                               reconfig_busy_11, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_11, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_11, //  Signals from the gxb block to the reconfig block


    // CHANNEL 12

    // PCS SIGNALS TO PHY
    input wire                               rxp_12, //  Differential Receive Data 
    output wire                              txp_12, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_12, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_12, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_12, //  Receiver Recovered Clock 
    output wire                              led_crs_12, //  Carrier Sense
    output wire                              led_link_12, //  Valid Link 
    output wire                              led_col_12, //  Collision Indication
    output wire                              led_an_12, //  Auto-Negotiation Status
    output wire                              led_char_err_12, //  Character Error
    output wire                              led_disp_err_12, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_12, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_12, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_12, //  Start of Packet
    output wire                              data_rx_eop_12, //  End of Packet
    output wire [7:0]                        data_rx_data_12, //  Data from FIFO
    output wire [4:0]                        data_rx_error_12, //  Receive packet error
    output wire                              data_rx_valid_12, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_12, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_12, //  Frame Type Indication
    output wire                              pkt_class_valid_12, //  Frame Type Indication Valid 
    input wire                               data_tx_error_12, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_12, //  Data from FIFO transmit
    input wire                               data_tx_valid_12, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_12, //  Start of Packet
    input wire                               data_tx_eop_12, //  END of Packet
    output wire                              data_tx_ready_12, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_12, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_12, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_12, //  Xoff Pause frame generate 
    input wire                               xon_gen_12, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_12, //  Enable Sleep Mode
    output wire                              magic_wakeup_12, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_12, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_12, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_12, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_12, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_12, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_12, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_12, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_12, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_12, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_12, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_12, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_12, //  Clock for reconfiguration block
    input wire                               reconfig_busy_12, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_12, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_12, //  Signals from the gxb block to the reconfig block


    // CHANNEL 13

    // PCS SIGNALS TO PHY
    input wire                               rxp_13, //  Differential Receive Data 
    output wire                              txp_13, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_13, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_13, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_13, //  Receiver Recovered Clock 
    output wire                              led_crs_13, //  Carrier Sense
    output wire                              led_link_13, //  Valid Link 
    output wire                              led_col_13, //  Collision Indication
    output wire                              led_an_13, //  Auto-Negotiation Status
    output wire                              led_char_err_13, //  Character Error
    output wire                              led_disp_err_13, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_13, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_13, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_13, //  Start of Packet
    output wire                              data_rx_eop_13, //  End of Packet
    output wire [7:0]                        data_rx_data_13, //  Data from FIFO
    output wire [4:0]                        data_rx_error_13, //  Receive packet error
    output wire                              data_rx_valid_13, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_13, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_13, //  Frame Type Indication
    output wire                              pkt_class_valid_13, //  Frame Type Indication Valid 
    input wire                               data_tx_error_13, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_13, //  Data from FIFO transmit
    input wire                               data_tx_valid_13, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_13, //  Start of Packet
    input wire                               data_tx_eop_13, //  END of Packet
    output wire                              data_tx_ready_13, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_13, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_13, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_13, //  Xoff Pause frame generate 
    input wire                               xon_gen_13, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_13, //  Enable Sleep Mode
    output wire                              magic_wakeup_13, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_13, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_13, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_13, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_13, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_13, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_13, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_13, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_13, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_13, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_13, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_13, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_13, //  Clock for reconfiguration block
    input wire                               reconfig_busy_13, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_13, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_13, //  Signals from the gxb block to the reconfig block


    // CHANNEL 14

    // PCS SIGNALS TO PHY
    input wire                               rxp_14, //  Differential Receive Data 
    output wire                              txp_14, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_14, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_14, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_14, //  Receiver Recovered Clock 
    output wire                              led_crs_14, //  Carrier Sense
    output wire                              led_link_14, //  Valid Link 
    output wire                              led_col_14, //  Collision Indication
    output wire                              led_an_14, //  Auto-Negotiation Status
    output wire                              led_char_err_14, //  Character Error
    output wire                              led_disp_err_14, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_14, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_14, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_14, //  Start of Packet
    output wire                              data_rx_eop_14, //  End of Packet
    output wire [7:0]                        data_rx_data_14, //  Data from FIFO
    output wire [4:0]                        data_rx_error_14, //  Receive packet error
    output wire                              data_rx_valid_14, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_14, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_14, //  Frame Type Indication
    output wire                              pkt_class_valid_14, //  Frame Type Indication Valid 
    input wire                               data_tx_error_14, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_14, //  Data from FIFO transmit
    input wire                               data_tx_valid_14, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_14, //  Start of Packet
    input wire                               data_tx_eop_14, //  END of Packet
    output wire                              data_tx_ready_14, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_14, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_14, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_14, //  Xoff Pause frame generate 
    input wire                               xon_gen_14, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_14, //  Enable Sleep Mode
    output wire                              magic_wakeup_14, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_14, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_14, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_14, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_14, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_14, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_14, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_14, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_14, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_14, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_14, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_14, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_14, //  Clock for reconfiguration block
    input wire                               reconfig_busy_14, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_14, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_14, //  Signals from the gxb block to the reconfig block


    // CHANNEL 15

    // PCS SIGNALS TO PHY
    input wire                               rxp_15, //  Differential Receive Data 
    output wire                              txp_15, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_15, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_15, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_15, //  Receiver Recovered Clock 
    output wire                              led_crs_15, //  Carrier Sense
    output wire                              led_link_15, //  Valid Link 
    output wire                              led_col_15, //  Collision Indication
    output wire                              led_an_15, //  Auto-Negotiation Status
    output wire                              led_char_err_15, //  Character Error
    output wire                              led_disp_err_15, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_15, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_15, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_15, //  Start of Packet
    output wire                              data_rx_eop_15, //  End of Packet
    output wire [7:0]                        data_rx_data_15, //  Data from FIFO
    output wire [4:0]                        data_rx_error_15, //  Receive packet error
    output wire                              data_rx_valid_15, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_15, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_15, //  Frame Type Indication
    output wire                              pkt_class_valid_15, //  Frame Type Indication Valid 
    input wire                               data_tx_error_15, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_15, //  Data from FIFO transmit
    input wire                               data_tx_valid_15, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_15, //  Start of Packet
    input wire                               data_tx_eop_15, //  END of Packet
    output wire                              data_tx_ready_15, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_15, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_15, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_15, //  Xoff Pause frame generate 
    input wire                               xon_gen_15, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_15, //  Enable Sleep Mode
    output wire                              magic_wakeup_15, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_15, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_15, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_15, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_15, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_15, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_15, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_15, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_15, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_15, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_15, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_15, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_15, //  Clock for reconfiguration block
    input wire                               reconfig_busy_15, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_15, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_15, //  Signals from the gxb block to the reconfig block


    // CHANNEL 16

    // PCS SIGNALS TO PHY
    input wire                               rxp_16, //  Differential Receive Data 
    output wire                              txp_16, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_16, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_16, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_16, //  Receiver Recovered Clock 
    output wire                              led_crs_16, //  Carrier Sense
    output wire                              led_link_16, //  Valid Link 
    output wire                              led_col_16, //  Collision Indication
    output wire                              led_an_16, //  Auto-Negotiation Status
    output wire                              led_char_err_16, //  Character Error
    output wire                              led_disp_err_16, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_16, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_16, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_16, //  Start of Packet
    output wire                              data_rx_eop_16, //  End of Packet
    output wire [7:0]                        data_rx_data_16, //  Data from FIFO
    output wire [4:0]                        data_rx_error_16, //  Receive packet error
    output wire                              data_rx_valid_16, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_16, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_16, //  Frame Type Indication
    output wire                              pkt_class_valid_16, //  Frame Type Indication Valid 
    input wire                               data_tx_error_16, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_16, //  Data from FIFO transmit
    input wire                               data_tx_valid_16, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_16, //  Start of Packet
    input wire                               data_tx_eop_16, //  END of Packet
    output wire                              data_tx_ready_16, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_16, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_16, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_16, //  Xoff Pause frame generate 
    input wire                               xon_gen_16, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_16, //  Enable Sleep Mode
    output wire                              magic_wakeup_16, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_16, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_16, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_16, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_16, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_16, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_16, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_16, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_16, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_16, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_16, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_16, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_16, //  Clock for reconfiguration block
    input wire                               reconfig_busy_16, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_16, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_16, //  Signals from the gxb block to the reconfig block


    // CHANNEL 17

    // PCS SIGNALS TO PHY
    input wire                               rxp_17, //  Differential Receive Data 
    output wire                              txp_17, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_17, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_17, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_17, //  Receiver Recovered Clock 
    output wire                              led_crs_17, //  Carrier Sense
    output wire                              led_link_17, //  Valid Link 
    output wire                              led_col_17, //  Collision Indication
    output wire                              led_an_17, //  Auto-Negotiation Status
    output wire                              led_char_err_17, //  Character Error
    output wire                              led_disp_err_17, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_17, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_17, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_17, //  Start of Packet
    output wire                              data_rx_eop_17, //  End of Packet
    output wire [7:0]                        data_rx_data_17, //  Data from FIFO
    output wire [4:0]                        data_rx_error_17, //  Receive packet error
    output wire                              data_rx_valid_17, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_17, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_17, //  Frame Type Indication
    output wire                              pkt_class_valid_17, //  Frame Type Indication Valid 
    input wire                               data_tx_error_17, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_17, //  Data from FIFO transmit
    input wire                               data_tx_valid_17, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_17, //  Start of Packet
    input wire                               data_tx_eop_17, //  END of Packet
    output wire                              data_tx_ready_17, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_17, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_17, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_17, //  Xoff Pause frame generate 
    input wire                               xon_gen_17, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_17, //  Enable Sleep Mode
    output wire                              magic_wakeup_17, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_17, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_17, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_17, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_17, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_17, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_17, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_17, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_17, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_17, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_17, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_17, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_17, //  Clock for reconfiguration block
    input wire                               reconfig_busy_17, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_17, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_17, //  Signals from the gxb block to the reconfig block


    // CHANNEL 18

    // PCS SIGNALS TO PHY
    input wire                               rxp_18, //  Differential Receive Data 
    output wire                              txp_18, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_18, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_18, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_18, //  Receiver Recovered Clock 
    output wire                              led_crs_18, //  Carrier Sense
    output wire                              led_link_18, //  Valid Link 
    output wire                              led_col_18, //  Collision Indication
    output wire                              led_an_18, //  Auto-Negotiation Status
    output wire                              led_char_err_18, //  Character Error
    output wire                              led_disp_err_18, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_18, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_18, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_18, //  Start of Packet
    output wire                              data_rx_eop_18, //  End of Packet
    output wire [7:0]                        data_rx_data_18, //  Data from FIFO
    output wire [4:0]                        data_rx_error_18, //  Receive packet error
    output wire                              data_rx_valid_18, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_18, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_18, //  Frame Type Indication
    output wire                              pkt_class_valid_18, //  Frame Type Indication Valid 
    input wire                               data_tx_error_18, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_18, //  Data from FIFO transmit
    input wire                               data_tx_valid_18, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_18, //  Start of Packet
    input wire                               data_tx_eop_18, //  END of Packet
    output wire                              data_tx_ready_18, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_18, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_18, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_18, //  Xoff Pause frame generate 
    input wire                               xon_gen_18, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_18, //  Enable Sleep Mode
    output wire                              magic_wakeup_18, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_18, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_18, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_18, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_18, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_18, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_18, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_18, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_18, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_18, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_18, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_18, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_18, //  Clock for reconfiguration block
    input wire                               reconfig_busy_18, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_18, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_18, //  Signals from the gxb block to the reconfig block


    // CHANNEL 19

    // PCS SIGNALS TO PHY
    input wire                               rxp_19, //  Differential Receive Data 
    output wire                              txp_19, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_19, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_19, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_19, //  Receiver Recovered Clock 
    output wire                              led_crs_19, //  Carrier Sense
    output wire                              led_link_19, //  Valid Link 
    output wire                              led_col_19, //  Collision Indication
    output wire                              led_an_19, //  Auto-Negotiation Status
    output wire                              led_char_err_19, //  Character Error
    output wire                              led_disp_err_19, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_19, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_19, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_19, //  Start of Packet
    output wire                              data_rx_eop_19, //  End of Packet
    output wire [7:0]                        data_rx_data_19, //  Data from FIFO
    output wire [4:0]                        data_rx_error_19, //  Receive packet error
    output wire                              data_rx_valid_19, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_19, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_19, //  Frame Type Indication
    output wire                              pkt_class_valid_19, //  Frame Type Indication Valid 
    input wire                               data_tx_error_19, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_19, //  Data from FIFO transmit
    input wire                               data_tx_valid_19, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_19, //  Start of Packet
    input wire                               data_tx_eop_19, //  END of Packet
    output wire                              data_tx_ready_19, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_19, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_19, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_19, //  Xoff Pause frame generate 
    input wire                               xon_gen_19, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_19, //  Enable Sleep Mode
    output wire                              magic_wakeup_19, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_19, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_19, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_19, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_19, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_19, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_19, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_19, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_19, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_19, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_19, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_19, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_19, //  Clock for reconfiguration block
    input wire                               reconfig_busy_19, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_19, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_19, //  Signals from the gxb block to the reconfig block


    // CHANNEL 20

    // PCS SIGNALS TO PHY
    input wire                               rxp_20, //  Differential Receive Data 
    output wire                              txp_20, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_20, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_20, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_20, //  Receiver Recovered Clock 
    output wire                              led_crs_20, //  Carrier Sense
    output wire                              led_link_20, //  Valid Link 
    output wire                              led_col_20, //  Collision Indication
    output wire                              led_an_20, //  Auto-Negotiation Status
    output wire                              led_char_err_20, //  Character Error
    output wire                              led_disp_err_20, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_20, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_20, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_20, //  Start of Packet
    output wire                              data_rx_eop_20, //  End of Packet
    output wire [7:0]                        data_rx_data_20, //  Data from FIFO
    output wire [4:0]                        data_rx_error_20, //  Receive packet error
    output wire                              data_rx_valid_20, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_20, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_20, //  Frame Type Indication
    output wire                              pkt_class_valid_20, //  Frame Type Indication Valid 
    input wire                               data_tx_error_20, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_20, //  Data from FIFO transmit
    input wire                               data_tx_valid_20, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_20, //  Start of Packet
    input wire                               data_tx_eop_20, //  END of Packet
    output wire                              data_tx_ready_20, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_20, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_20, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_20, //  Xoff Pause frame generate 
    input wire                               xon_gen_20, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_20, //  Enable Sleep Mode
    output wire                              magic_wakeup_20, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_20, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_20, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_20, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_20, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_20, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_20, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_20, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_20, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_20, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_20, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_20, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_20, //  Clock for reconfiguration block
    input wire                               reconfig_busy_20, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_20, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_20, //  Signals from the gxb block to the reconfig block


    // CHANNEL 21

    // PCS SIGNALS TO PHY
    input wire                               rxp_21, //  Differential Receive Data 
    output wire                              txp_21, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_21, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_21, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_21, //  Receiver Recovered Clock 
    output wire                              led_crs_21, //  Carrier Sense
    output wire                              led_link_21, //  Valid Link 
    output wire                              led_col_21, //  Collision Indication
    output wire                              led_an_21, //  Auto-Negotiation Status
    output wire                              led_char_err_21, //  Character Error
    output wire                              led_disp_err_21, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_21, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_21, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_21, //  Start of Packet
    output wire                              data_rx_eop_21, //  End of Packet
    output wire [7:0]                        data_rx_data_21, //  Data from FIFO
    output wire [4:0]                        data_rx_error_21, //  Receive packet error
    output wire                              data_rx_valid_21, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_21, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_21, //  Frame Type Indication
    output wire                              pkt_class_valid_21, //  Frame Type Indication Valid 
    input wire                               data_tx_error_21, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_21, //  Data from FIFO transmit
    input wire                               data_tx_valid_21, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_21, //  Start of Packet
    input wire                               data_tx_eop_21, //  END of Packet
    output wire                              data_tx_ready_21, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_21, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_21, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_21, //  Xoff Pause frame generate 
    input wire                               xon_gen_21, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_21, //  Enable Sleep Mode
    output wire                              magic_wakeup_21, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_21, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_21, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_21, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_21, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_21, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_21, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_21, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_21, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_21, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_21, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_21, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_21, //  Clock for reconfiguration block
    input wire                               reconfig_busy_21, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_21, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_21, //  Signals from the gxb block to the reconfig block


    // CHANNEL 22

    // PCS SIGNALS TO PHY
    input wire                               rxp_22, //  Differential Receive Data 
    output wire                              txp_22, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_22, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_22, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_22, //  Receiver Recovered Clock 
    output wire                              led_crs_22, //  Carrier Sense
    output wire                              led_link_22, //  Valid Link 
    output wire                              led_col_22, //  Collision Indication
    output wire                              led_an_22, //  Auto-Negotiation Status
    output wire                              led_char_err_22, //  Character Error
    output wire                              led_disp_err_22, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_22, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_22, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_22, //  Start of Packet
    output wire                              data_rx_eop_22, //  End of Packet
    output wire [7:0]                        data_rx_data_22, //  Data from FIFO
    output wire [4:0]                        data_rx_error_22, //  Receive packet error
    output wire                              data_rx_valid_22, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_22, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_22, //  Frame Type Indication
    output wire                              pkt_class_valid_22, //  Frame Type Indication Valid 
    input wire                               data_tx_error_22, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_22, //  Data from FIFO transmit
    input wire                               data_tx_valid_22, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_22, //  Start of Packet
    input wire                               data_tx_eop_22, //  END of Packet
    output wire                              data_tx_ready_22, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_22, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_22, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_22, //  Xoff Pause frame generate 
    input wire                               xon_gen_22, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_22, //  Enable Sleep Mode
    output wire                              magic_wakeup_22, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_22, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_22, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_22, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_22, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_22, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_22, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_22, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_22, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_22, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_22, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_22, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_22, //  Clock for reconfiguration block
    input wire                               reconfig_busy_22, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_22, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_22, //  Signals from the gxb block to the reconfig block


    // CHANNEL 23

    // PCS SIGNALS TO PHY
    input wire                               rxp_23, //  Differential Receive Data 
    output wire                              txp_23, //  Differential Transmit Data 
    input wire                               gxb_pwrdn_in_23, //  Powerdown signal to GXB
    output wire                              pcs_pwrdn_out_23, //  Powerdown Enable from PCS
    output wire                              rx_recovclkout_23, //  Receiver Recovered Clock 
    output wire                              led_crs_23, //  Carrier Sense
    output wire                              led_link_23, //  Valid Link 
    output wire                              led_col_23, //  Collision Indication
    output wire                              led_an_23, //  Auto-Negotiation Status
    output wire                              led_char_err_23, //  Character Error
    output wire                              led_disp_err_23, //  Disparity Error

    // AV-ST TX & RX
    output wire                              mac_rx_clk_23, //  Av-ST Receive Clock
    output wire                              mac_tx_clk_23, //  Av-ST Transmit Clock   
    output wire                              data_rx_sop_23, //  Start of Packet
    output wire                              data_rx_eop_23, //  End of Packet
    output wire [7:0]                        data_rx_data_23, //  Data from FIFO
    output wire [4:0]                        data_rx_error_23, //  Receive packet error
    output wire                              data_rx_valid_23, //  Data Receive FIFO Valid
    input wire                               data_rx_ready_23, //  Data Receive Ready
    output wire [4:0]                        pkt_class_data_23, //  Frame Type Indication
    output wire                              pkt_class_valid_23, //  Frame Type Indication Valid 
    input wire                               data_tx_error_23, //  STATUS FIFO (Tx frame Error from Apps)
    input wire [7:0]                         data_tx_data_23, //  Data from FIFO transmit
    input wire                               data_tx_valid_23, //  Data FIFO transmit Empty
    input wire                               data_tx_sop_23, //  Start of Packet
    input wire                               data_tx_eop_23, //  END of Packet
    output wire                              data_tx_ready_23, //  Data FIFO transmit Read Enable       

    // STAND_ALONE CONDUITS 
    output wire                              tx_ff_uflow_23, //  TX FIFO underflow occured (Synchronous with tx_clk)
    input wire                               tx_crc_fwd_23, //  Forward Current Frame with CRC from Application
    input wire                               xoff_gen_23, //  Xoff Pause frame generate 
    input wire                               xon_gen_23, //  Xon Pause frame generate 
    input wire                               magic_sleep_n_23, //  Enable Sleep Mode
    output wire                              magic_wakeup_23, //  Wake Up Request
    
// IEEE1588's code
    input wire                               tx_egress_timestamp_request_valid_23, //    Timestamp request valid from user
    input wire [(TSTAMP_FP_WIDTH)-1:0]       tx_egress_timestamp_request_data_23, //    Fingerprint associated to the timestamp request
    input wire                               tx_egress_timestamp_insert_valid_23, //    Timestamp insert in 1 step clock
    output wire                              tx_egress_timestamp_valid_23, //    Timestamp + fingerprint from TSU
    output wire [(96 + TSTAMP_FP_WIDTH)-1:0] tx_egress_timestamp_data_23, //    Timestamp + fingerprint from TSU
    input wire [96-1:0]                      tx_time_of_day_data_23, //    Time of Day
    input wire                               tx_ingress_timestamp_valid_23, //    Timestamp to TSU
    input wire [(96)-1:0]                    tx_ingress_timestamp_data_23, //    Timestamp to TSU
    output wire                              rx_ingress_timestamp_valid_23, //    RX timestamp valid
    output wire [(96)-1:0]                   rx_ingress_timestamp_data_23, //    RX timestamp data
    input wire [96-1:0]                      rx_time_of_day_data_23, //    Time of Day

    // RECONFIG BLOCK SIGNALS
    input wire                               reconfig_clk_23, //  Clock for reconfiguration block
    input wire                               reconfig_busy_23, //  Busy from reconfiguration block
    input wire [3:0]                         reconfig_togxb_23, //  Signals from the reconfig block to the GXB block
    output wire [16:0]                       reconfig_fromgxb_23); //  Signals from the gxb block to the reconfig block



wire    [23:0] pcs_pwrdn_out_sig;
wire    [23:0] gxb_pwrdn_in_sig;
wire    gige_pma_reset;
wire    [23:0] led_char_err_gx;
wire    [23:0] link_status;
//wire    [23:0] pcs_clk;
wire    tx_pcs_clk_c0;
wire    tx_pcs_clk_c1;
wire    tx_pcs_clk_c2;
wire    tx_pcs_clk_c3;
wire    tx_pcs_clk_c4;
wire    tx_pcs_clk_c5;
wire    tx_pcs_clk_c6;
wire    tx_pcs_clk_c7;
wire    tx_pcs_clk_c8;
wire    tx_pcs_clk_c9;
wire    tx_pcs_clk_c10;
wire    tx_pcs_clk_c11;
wire    tx_pcs_clk_c12;
wire    tx_pcs_clk_c13;
wire    tx_pcs_clk_c14;
wire    tx_pcs_clk_c15;
wire    tx_pcs_clk_c16;
wire    tx_pcs_clk_c17;
wire    tx_pcs_clk_c18;
wire    tx_pcs_clk_c19;
wire    tx_pcs_clk_c20;
wire    tx_pcs_clk_c21;
wire    tx_pcs_clk_c22;
wire    tx_pcs_clk_c23;
wire    rx_pcs_clk_c0;
wire    rx_pcs_clk_c1;
wire    rx_pcs_clk_c2;
wire    rx_pcs_clk_c3;
wire    rx_pcs_clk_c4;
wire    rx_pcs_clk_c5;
wire    rx_pcs_clk_c6;
wire    rx_pcs_clk_c7;
wire    rx_pcs_clk_c8;
wire    rx_pcs_clk_c9;
wire    rx_pcs_clk_c10;
wire    rx_pcs_clk_c11;
wire    rx_pcs_clk_c12;
wire    rx_pcs_clk_c13;
wire    rx_pcs_clk_c14;
wire    rx_pcs_clk_c15;
wire    rx_pcs_clk_c16;
wire    rx_pcs_clk_c17;
wire    rx_pcs_clk_c18;
wire    rx_pcs_clk_c19;
wire    rx_pcs_clk_c20;
wire    rx_pcs_clk_c21;
wire    rx_pcs_clk_c22;
wire    rx_pcs_clk_c23;
wire    [23:0] rx_char_err_gx;
wire    [23:0] rx_disp_err;
wire    [23:0] rx_syncstatus;
wire    [23:0] rx_runlengthviolation;
wire    [23:0] rx_patterndetect;
wire    [23:0] rx_runningdisp;
wire    [23:0] rx_rmfifodatadeleted;
wire    [23:0] rx_rmfifodatainserted;
wire    [23:0] pcs_rx_rmfifodatadeleted;
wire    [23:0] pcs_rx_rmfifodatainserted;
wire    [23:0] pcs_rx_carrierdetected;

wire    rx_kchar_0;
wire    [7:0] rx_frame_0;
wire    pcs_rx_kchar_0;
wire    [7:0] pcs_rx_frame_0;
wire    tx_kchar_0;
wire    [7:0] tx_frame_0;
wire    rx_kchar_1;
wire    [7:0] rx_frame_1;
wire    pcs_rx_kchar_1;
wire    [7:0] pcs_rx_frame_1;
wire    tx_kchar_1;
wire    [7:0] tx_frame_1;
wire    rx_kchar_2;
wire    [7:0] rx_frame_2;
wire    pcs_rx_kchar_2;
wire    [7:0] pcs_rx_frame_2;
wire    tx_kchar_2;
wire    [7:0] tx_frame_2;
wire    rx_kchar_3;
wire    [7:0] rx_frame_3;
wire    pcs_rx_kchar_3;
wire    [7:0] pcs_rx_frame_3;
wire    tx_kchar_3;
wire    [7:0] tx_frame_3;
wire    rx_kchar_4;
wire    [7:0] rx_frame_4;
wire    pcs_rx_kchar_4;
wire    [7:0] pcs_rx_frame_4;
wire    tx_kchar_4;
wire    [7:0] tx_frame_4;
wire    rx_kchar_5;
wire    [7:0] rx_frame_5;
wire    pcs_rx_kchar_5;
wire    [7:0] pcs_rx_frame_5;
wire    tx_kchar_5;
wire    [7:0] tx_frame_5;
wire    rx_kchar_6;
wire    [7:0] rx_frame_6;
wire    pcs_rx_kchar_6;
wire    [7:0] pcs_rx_frame_6;
wire    tx_kchar_6;
wire    [7:0] tx_frame_6;
wire    rx_kchar_7;
wire    [7:0] rx_frame_7;
wire    pcs_rx_kchar_7;
wire    [7:0] pcs_rx_frame_7;
wire    tx_kchar_7;
wire    [7:0] tx_frame_7;
wire    rx_kchar_8;
wire    [7:0] rx_frame_8;
wire    pcs_rx_kchar_8;
wire    [7:0] pcs_rx_frame_8;
wire    tx_kchar_8;
wire    [7:0] tx_frame_8;
wire    rx_kchar_9;
wire    [7:0] rx_frame_9;
wire    pcs_rx_kchar_9;
wire    [7:0] pcs_rx_frame_9;
wire    tx_kchar_9;
wire    [7:0] tx_frame_9;
wire    rx_kchar_10;
wire    [7:0] rx_frame_10;
wire    pcs_rx_kchar_10;
wire    [7:0] pcs_rx_frame_10;
wire    tx_kchar_10;
wire    [7:0] tx_frame_10;
wire    rx_kchar_11;
wire    [7:0] rx_frame_11;
wire    pcs_rx_kchar_11;
wire    [7:0] pcs_rx_frame_11;
wire    tx_kchar_11;
wire    [7:0] tx_frame_11;
wire    rx_kchar_12;
wire    [7:0] rx_frame_12;
wire    pcs_rx_kchar_12;
wire    [7:0] pcs_rx_frame_12;
wire    tx_kchar_12;
wire    [7:0] tx_frame_12;
wire    rx_kchar_13;
wire    [7:0] rx_frame_13;
wire    pcs_rx_kchar_13;
wire    [7:0] pcs_rx_frame_13;
wire    tx_kchar_13;
wire    [7:0] tx_frame_13;
wire    rx_kchar_14;
wire    [7:0] rx_frame_14;
wire    pcs_rx_kchar_14;
wire    [7:0] pcs_rx_frame_14;
wire    tx_kchar_14;
wire    [7:0] tx_frame_14;
wire    rx_kchar_15;
wire    [7:0] rx_frame_15;
wire    pcs_rx_kchar_15;
wire    [7:0] pcs_rx_frame_15;
wire    tx_kchar_15;
wire    [7:0] tx_frame_15;
wire    rx_kchar_16;
wire    [7:0] rx_frame_16;
wire    pcs_rx_kchar_16;
wire    [7:0] pcs_rx_frame_16;
wire    tx_kchar_16;
wire    [7:0] tx_frame_16;
wire    rx_kchar_17;
wire    [7:0] rx_frame_17;
wire    pcs_rx_kchar_17;
wire    [7:0] pcs_rx_frame_17;
wire    tx_kchar_17;
wire    [7:0] tx_frame_17;
wire    rx_kchar_18;
wire    [7:0] rx_frame_18;
wire    pcs_rx_kchar_18;
wire    [7:0] pcs_rx_frame_18;
wire    tx_kchar_18;
wire    [7:0] tx_frame_18;
wire    rx_kchar_19;
wire    [7:0] rx_frame_19;
wire    pcs_rx_kchar_19;
wire    [7:0] pcs_rx_frame_19;
wire    tx_kchar_19;
wire    [7:0] tx_frame_19;
wire    rx_kchar_20;
wire    [7:0] rx_frame_20;
wire    pcs_rx_kchar_20;
wire    [7:0] pcs_rx_frame_20;
wire    tx_kchar_20;
wire    [7:0] tx_frame_20;
wire    rx_kchar_21;
wire    [7:0] rx_frame_21;
wire    pcs_rx_kchar_21;
wire    [7:0] pcs_rx_frame_21;
wire    tx_kchar_21;
wire    [7:0] tx_frame_21;
wire    rx_kchar_22;
wire    [7:0] rx_frame_22;
wire    pcs_rx_kchar_22;
wire    [7:0] pcs_rx_frame_22;
wire    tx_kchar_22;
wire    [7:0] tx_frame_22;
wire    rx_kchar_23;
wire    [7:0] rx_frame_23;
wire    pcs_rx_kchar_23;
wire    [7:0] pcs_rx_frame_23;
wire    tx_kchar_23;
wire    [7:0] tx_frame_23;

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


wire reset_rx_pcs_clk_c0_int;
wire reset_rx_pcs_clk_c1_int;
wire reset_rx_pcs_clk_c2_int;
wire reset_rx_pcs_clk_c3_int;
wire reset_rx_pcs_clk_c4_int;
wire reset_rx_pcs_clk_c5_int;
wire reset_rx_pcs_clk_c6_int;
wire reset_rx_pcs_clk_c7_int;
wire reset_rx_pcs_clk_c8_int;
wire reset_rx_pcs_clk_c9_int;
wire reset_rx_pcs_clk_c10_int;
wire reset_rx_pcs_clk_c11_int;
wire reset_rx_pcs_clk_c12_int;
wire reset_rx_pcs_clk_c13_int;
wire reset_rx_pcs_clk_c14_int;
wire reset_rx_pcs_clk_c15_int;
wire reset_rx_pcs_clk_c16_int;
wire reset_rx_pcs_clk_c17_int;
wire reset_rx_pcs_clk_c18_int;
wire reset_rx_pcs_clk_c19_int;
wire reset_rx_pcs_clk_c20_int;
wire reset_rx_pcs_clk_c21_int;
wire reset_rx_pcs_clk_c22_int;
wire reset_rx_pcs_clk_c23_int;

wire pll_powerdown_sqcnr_0,tx_digitalreset_sqcnr_0,rx_analogreset_sqcnr_0,rx_digitalreset_sqcnr_0,gxb_powerdown_sqcnr_0,pll_locked_0,rx_freqlocked_0;
wire pll_powerdown_sqcnr_1,tx_digitalreset_sqcnr_1,rx_analogreset_sqcnr_1,rx_digitalreset_sqcnr_1,gxb_powerdown_sqcnr_1,pll_locked_1,rx_freqlocked_1;
wire pll_powerdown_sqcnr_2,tx_digitalreset_sqcnr_2,rx_analogreset_sqcnr_2,rx_digitalreset_sqcnr_2,gxb_powerdown_sqcnr_2,pll_locked_2,rx_freqlocked_2;
wire pll_powerdown_sqcnr_3,tx_digitalreset_sqcnr_3,rx_analogreset_sqcnr_3,rx_digitalreset_sqcnr_3,gxb_powerdown_sqcnr_3,pll_locked_3,rx_freqlocked_3;
wire pll_powerdown_sqcnr_4,tx_digitalreset_sqcnr_4,rx_analogreset_sqcnr_4,rx_digitalreset_sqcnr_4,gxb_powerdown_sqcnr_4,pll_locked_4,rx_freqlocked_4;
wire pll_powerdown_sqcnr_5,tx_digitalreset_sqcnr_5,rx_analogreset_sqcnr_5,rx_digitalreset_sqcnr_5,gxb_powerdown_sqcnr_5,pll_locked_5,rx_freqlocked_5;
wire pll_powerdown_sqcnr_6,tx_digitalreset_sqcnr_6,rx_analogreset_sqcnr_6,rx_digitalreset_sqcnr_6,gxb_powerdown_sqcnr_6,pll_locked_6,rx_freqlocked_6;
wire pll_powerdown_sqcnr_7,tx_digitalreset_sqcnr_7,rx_analogreset_sqcnr_7,rx_digitalreset_sqcnr_7,gxb_powerdown_sqcnr_7,pll_locked_7,rx_freqlocked_7;
wire pll_powerdown_sqcnr_8,tx_digitalreset_sqcnr_8,rx_analogreset_sqcnr_8,rx_digitalreset_sqcnr_8,gxb_powerdown_sqcnr_8,pll_locked_8,rx_freqlocked_8;
wire pll_powerdown_sqcnr_9,tx_digitalreset_sqcnr_9,rx_analogreset_sqcnr_9,rx_digitalreset_sqcnr_9,gxb_powerdown_sqcnr_9,pll_locked_9,rx_freqlocked_9;
wire pll_powerdown_sqcnr_10,tx_digitalreset_sqcnr_10,rx_analogreset_sqcnr_10,rx_digitalreset_sqcnr_10,gxb_powerdown_sqcnr_10,pll_locked_10,rx_freqlocked_10;
wire pll_powerdown_sqcnr_11,tx_digitalreset_sqcnr_11,rx_analogreset_sqcnr_11,rx_digitalreset_sqcnr_11,gxb_powerdown_sqcnr_11,pll_locked_11,rx_freqlocked_11;
wire pll_powerdown_sqcnr_12,tx_digitalreset_sqcnr_12,rx_analogreset_sqcnr_12,rx_digitalreset_sqcnr_12,gxb_powerdown_sqcnr_12,pll_locked_12,rx_freqlocked_12;
wire pll_powerdown_sqcnr_13,tx_digitalreset_sqcnr_13,rx_analogreset_sqcnr_13,rx_digitalreset_sqcnr_13,gxb_powerdown_sqcnr_13,pll_locked_13,rx_freqlocked_13;
wire pll_powerdown_sqcnr_14,tx_digitalreset_sqcnr_14,rx_analogreset_sqcnr_14,rx_digitalreset_sqcnr_14,gxb_powerdown_sqcnr_14,pll_locked_14,rx_freqlocked_14;
wire pll_powerdown_sqcnr_15,tx_digitalreset_sqcnr_15,rx_analogreset_sqcnr_15,rx_digitalreset_sqcnr_15,gxb_powerdown_sqcnr_15,pll_locked_15,rx_freqlocked_15;
wire pll_powerdown_sqcnr_16,tx_digitalreset_sqcnr_16,rx_analogreset_sqcnr_16,rx_digitalreset_sqcnr_16,gxb_powerdown_sqcnr_16,pll_locked_16,rx_freqlocked_16;
wire pll_powerdown_sqcnr_17,tx_digitalreset_sqcnr_17,rx_analogreset_sqcnr_17,rx_digitalreset_sqcnr_17,gxb_powerdown_sqcnr_17,pll_locked_17,rx_freqlocked_17;
wire pll_powerdown_sqcnr_18,tx_digitalreset_sqcnr_18,rx_analogreset_sqcnr_18,rx_digitalreset_sqcnr_18,gxb_powerdown_sqcnr_18,pll_locked_18,rx_freqlocked_18;
wire pll_powerdown_sqcnr_19,tx_digitalreset_sqcnr_19,rx_analogreset_sqcnr_19,rx_digitalreset_sqcnr_19,gxb_powerdown_sqcnr_19,pll_locked_19,rx_freqlocked_19;
wire pll_powerdown_sqcnr_20,tx_digitalreset_sqcnr_20,rx_analogreset_sqcnr_20,rx_digitalreset_sqcnr_20,gxb_powerdown_sqcnr_20,pll_locked_20,rx_freqlocked_20;
wire pll_powerdown_sqcnr_21,tx_digitalreset_sqcnr_21,rx_analogreset_sqcnr_21,rx_digitalreset_sqcnr_21,gxb_powerdown_sqcnr_21,pll_locked_21,rx_freqlocked_21;
wire pll_powerdown_sqcnr_22,tx_digitalreset_sqcnr_22,rx_analogreset_sqcnr_22,rx_digitalreset_sqcnr_22,gxb_powerdown_sqcnr_22,pll_locked_22,rx_freqlocked_22;
wire pll_powerdown_sqcnr_23,tx_digitalreset_sqcnr_23,rx_analogreset_sqcnr_23,rx_digitalreset_sqcnr_23,gxb_powerdown_sqcnr_23,pll_locked_23,rx_freqlocked_23;

      // Assign pcs clock for all channels
        //assign pcs_clk = {pcs_clk_c23,pcs_clk_c22,pcs_clk_c21,pcs_clk_c20,pcs_clk_c19,pcs_clk_c18,pcs_clk_c17,pcs_clk_c16,pcs_clk_c15,pcs_clk_c14,pcs_clk_c13,pcs_clk_c12,pcs_clk_c11,pcs_clk_c10,pcs_clk_c9,pcs_clk_c8,pcs_clk_c7,pcs_clk_c6,pcs_clk_c5,pcs_clk_c4,pcs_clk_c3,pcs_clk_c2,pcs_clk_c1,pcs_clk_c0};

    //  Assign the character error and link status to top level leds
    //  ------------------------------------------------------------
    assign led_char_err_0 = led_char_err_gx[0];
    assign led_link_0 = link_status[0];
    assign led_char_err_1 = led_char_err_gx[1];
    assign led_link_1 = link_status[1];
    assign led_char_err_2 = led_char_err_gx[2];
    assign led_link_2 = link_status[2];
    assign led_char_err_3 = led_char_err_gx[3];
    assign led_link_3 = link_status[3];
    assign led_char_err_4 = led_char_err_gx[4];
    assign led_link_4 = link_status[4];
    assign led_char_err_5 = led_char_err_gx[5];
    assign led_link_5 = link_status[5];
    assign led_char_err_6 = led_char_err_gx[6];
    assign led_link_6 = link_status[6];
    assign led_char_err_7 = led_char_err_gx[7];
    assign led_link_7 = link_status[7];
    assign led_char_err_8 = led_char_err_gx[8];
    assign led_link_8 = link_status[8];
    assign led_char_err_9 = led_char_err_gx[9];
    assign led_link_9 = link_status[9];
    assign led_char_err_10 = led_char_err_gx[10];
    assign led_link_10 = link_status[10];
    assign led_char_err_11 = led_char_err_gx[11];
    assign led_link_11 = link_status[11];
    assign led_char_err_12 = led_char_err_gx[12];
    assign led_link_12 = link_status[12];
    assign led_char_err_13 = led_char_err_gx[13];
    assign led_link_13 = link_status[13];
    assign led_char_err_14 = led_char_err_gx[14];
    assign led_link_14 = link_status[14];
    assign led_char_err_15 = led_char_err_gx[15];
    assign led_link_15 = link_status[15];
    assign led_char_err_16 = led_char_err_gx[16];
    assign led_link_16 = link_status[16];
    assign led_char_err_17 = led_char_err_gx[17];
    assign led_link_17 = link_status[17];
    assign led_char_err_18 = led_char_err_gx[18];
    assign led_link_18 = link_status[18];
    assign led_char_err_19 = led_char_err_gx[19];
    assign led_link_19 = link_status[19];
    assign led_char_err_20 = led_char_err_gx[20];
    assign led_link_20 = link_status[20];
    assign led_char_err_21 = led_char_err_gx[21];
    assign led_link_21 = link_status[21];
    assign led_char_err_22 = led_char_err_gx[22];
    assign led_link_22 = link_status[22];
    assign led_char_err_23 = led_char_err_gx[23];
    assign led_link_23 = link_status[23];

    // Based on PHYIP , when user assert reset - it hold the reset sequencer block in reset.
    //                , reset sequencing only start then reset_sequnece end.
    wire reset_sync;
    reg reset_start;

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

   wire pcs_phase_measure_clk_w;
   
   generate 
      if (ENABLE_TIMESTAMPING == 0)
        begin
           assign pcs_phase_measure_clk_w = 1'b0;
        end
      else 
        begin
           assign pcs_phase_measure_clk_w = pcs_phase_measure_clk;
        end
   endgenerate
   

    // Instantiation of the MAC_PCS core that connects to a PMA
    // --------------------------------------------------------

    altera_tse_top_multi_mac_pcs_gige U_MULTI_MAC_PCS(

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
         .pcs_phase_measure_clk(pcs_phase_measure_clk_w),
                                                      
         // Channel 0 
            

        .rx_carrierdetected_0(pcs_rx_carrierdetected[0]),
        .rx_rmfifodatadeleted_0(pcs_rx_rmfifodatadeleted[0]),
        .rx_rmfifodatainserted_0(pcs_rx_rmfifodatainserted[0]),

        .rx_clkout_0(rx_pcs_clk_c0),                 //INPUT  : Receive Clock
        .tx_clkout_0(tx_pcs_clk_c0),                 //INPUT  : Transmit Clock
        .rx_kchar_0(pcs_rx_kchar_0),              //INPUT  : Special Character Indication
        .tx_kchar_0(tx_kchar_0),                  //OUTPUT : Special Character Indication
        .rx_frame_0(pcs_rx_frame_0),              //INPUT  : Frame
        .tx_frame_0(tx_frame_0),                  //OUTPUT : Frame
        .sd_loopback_0(sd_loopback_0),            //OUTPUT : SERDES Loopback Enable
        .powerdown_0(pcs_pwrdn_out_sig[0]),       //OUTPUT : Powerdown Enable
        .led_col_0(led_col_0),                    //OUTPUT : Collision Indication
        .led_an_0(led_an_0),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_0(led_char_err_gx[0]),      //INPUT  : Character error
        .led_crs_0(led_crs_0),                    //OUTPUT : Carrier sense
        .led_link_0(link_status[0]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_0(tx_egress_timestamp_request_valid_0),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_0(tx_egress_timestamp_request_data_0),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_0(tx_egress_timestamp_valid_0),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_0(tx_egress_timestamp_data_0),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_0(tx_time_of_day_data_0),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_0(tx_ingress_timestamp_valid_0),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_0(tx_ingress_timestamp_data_0),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_0(rx_ingress_timestamp_valid_0),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_0(rx_ingress_timestamp_data_0),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_0(rx_time_of_day_data_0),                                //INPUT  : Time of Day
        .xoff_gen_0(xoff_gen_0),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_0(xon_gen_0),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_0(magic_sleep_n_0),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_0(magic_wakeup_0),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 1 
            

        .rx_carrierdetected_1(pcs_rx_carrierdetected[1]),
        .rx_rmfifodatadeleted_1(pcs_rx_rmfifodatadeleted[1]),
        .rx_rmfifodatainserted_1(pcs_rx_rmfifodatainserted[1]),

        .rx_clkout_1(rx_pcs_clk_c1),                 //INPUT  : Receive Clock
        .tx_clkout_1(tx_pcs_clk_c1),                 //INPUT  : Transmit Clock
        .rx_kchar_1(pcs_rx_kchar_1),              //INPUT  : Special Character Indication
        .tx_kchar_1(tx_kchar_1),                  //OUTPUT : Special Character Indication
        .rx_frame_1(pcs_rx_frame_1),              //INPUT  : Frame
        .tx_frame_1(tx_frame_1),                  //OUTPUT : Frame
        .sd_loopback_1(sd_loopback_1),            //OUTPUT : SERDES Loopback Enable
        .powerdown_1(pcs_pwrdn_out_sig[1]),       //OUTPUT : Powerdown Enable
        .led_col_1(led_col_1),                    //OUTPUT : Collision Indication
        .led_an_1(led_an_1),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_1(led_char_err_gx[1]),      //INPUT  : Character error
        .led_crs_1(led_crs_1),                    //OUTPUT : Carrier sense
        .led_link_1(link_status[1]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_1(tx_egress_timestamp_request_valid_1),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_1(tx_egress_timestamp_request_data_1),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_1(tx_egress_timestamp_valid_1),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_1(tx_egress_timestamp_data_1),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_1(tx_time_of_day_data_1),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_1(tx_ingress_timestamp_valid_1),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_1(tx_ingress_timestamp_data_1),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_1(rx_ingress_timestamp_valid_1),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_1(rx_ingress_timestamp_data_1),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_1(rx_time_of_day_data_1),                                //INPUT  : Time of Day
        .xoff_gen_1(xoff_gen_1),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_1(xon_gen_1),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_1(magic_sleep_n_1),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_1(magic_wakeup_1),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 2 
            

        .rx_carrierdetected_2(pcs_rx_carrierdetected[2]),
        .rx_rmfifodatadeleted_2(pcs_rx_rmfifodatadeleted[2]),
        .rx_rmfifodatainserted_2(pcs_rx_rmfifodatainserted[2]),

        .rx_clkout_2(rx_pcs_clk_c2),                 //INPUT  : Receive Clock
        .tx_clkout_2(tx_pcs_clk_c2),                 //INPUT  : Transmit Clock
        .rx_kchar_2(pcs_rx_kchar_2),              //INPUT  : Special Character Indication
        .tx_kchar_2(tx_kchar_2),                  //OUTPUT : Special Character Indication
        .rx_frame_2(pcs_rx_frame_2),              //INPUT  : Frame
        .tx_frame_2(tx_frame_2),                  //OUTPUT : Frame
        .sd_loopback_2(sd_loopback_2),            //OUTPUT : SERDES Loopback Enable
        .powerdown_2(pcs_pwrdn_out_sig[2]),       //OUTPUT : Powerdown Enable
        .led_col_2(led_col_2),                    //OUTPUT : Collision Indication
        .led_an_2(led_an_2),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_2(led_char_err_gx[2]),      //INPUT  : Character error
        .led_crs_2(led_crs_2),                    //OUTPUT : Carrier sense
        .led_link_2(link_status[2]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_2(tx_egress_timestamp_request_valid_2),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_2(tx_egress_timestamp_request_data_2),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_2(tx_egress_timestamp_valid_2),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_2(tx_egress_timestamp_data_2),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_2(tx_time_of_day_data_2),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_2(tx_ingress_timestamp_valid_2),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_2(tx_ingress_timestamp_data_2),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_2(rx_ingress_timestamp_valid_2),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_2(rx_ingress_timestamp_data_2),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_2(rx_time_of_day_data_2),                                //INPUT  : Time of Day
        .xoff_gen_2(xoff_gen_2),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_2(xon_gen_2),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_2(magic_sleep_n_2),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_2(magic_wakeup_2),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 3 
            

        .rx_carrierdetected_3(pcs_rx_carrierdetected[3]),
        .rx_rmfifodatadeleted_3(pcs_rx_rmfifodatadeleted[3]),
        .rx_rmfifodatainserted_3(pcs_rx_rmfifodatainserted[3]),

        .rx_clkout_3(rx_pcs_clk_c3),                 //INPUT  : Receive Clock
        .tx_clkout_3(tx_pcs_clk_c3),                 //INPUT  : Transmit Clock
        .rx_kchar_3(pcs_rx_kchar_3),              //INPUT  : Special Character Indication
        .tx_kchar_3(tx_kchar_3),                  //OUTPUT : Special Character Indication
        .rx_frame_3(pcs_rx_frame_3),              //INPUT  : Frame
        .tx_frame_3(tx_frame_3),                  //OUTPUT : Frame
        .sd_loopback_3(sd_loopback_3),            //OUTPUT : SERDES Loopback Enable
        .powerdown_3(pcs_pwrdn_out_sig[3]),       //OUTPUT : Powerdown Enable
        .led_col_3(led_col_3),                    //OUTPUT : Collision Indication
        .led_an_3(led_an_3),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_3(led_char_err_gx[3]),      //INPUT  : Character error
        .led_crs_3(led_crs_3),                    //OUTPUT : Carrier sense
        .led_link_3(link_status[3]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_3(tx_egress_timestamp_request_valid_3),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_3(tx_egress_timestamp_request_data_3),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_3(tx_egress_timestamp_valid_3),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_3(tx_egress_timestamp_data_3),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_3(tx_time_of_day_data_3),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_3(tx_ingress_timestamp_valid_3),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_3(tx_ingress_timestamp_data_3),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_3(rx_ingress_timestamp_valid_3),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_3(rx_ingress_timestamp_data_3),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_3(rx_time_of_day_data_3),                                //INPUT  : Time of Day
        .xoff_gen_3(xoff_gen_3),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_3(xon_gen_3),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_3(magic_sleep_n_3),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_3(magic_wakeup_3),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 4 
            

        .rx_carrierdetected_4(pcs_rx_carrierdetected[4]),
        .rx_rmfifodatadeleted_4(pcs_rx_rmfifodatadeleted[4]),
        .rx_rmfifodatainserted_4(pcs_rx_rmfifodatainserted[4]),

        .rx_clkout_4(rx_pcs_clk_c4),                 //INPUT  : Receive Clock
        .tx_clkout_4(tx_pcs_clk_c4),                 //INPUT  : Transmit Clock
        .rx_kchar_4(pcs_rx_kchar_4),              //INPUT  : Special Character Indication
        .tx_kchar_4(tx_kchar_4),                  //OUTPUT : Special Character Indication
        .rx_frame_4(pcs_rx_frame_4),              //INPUT  : Frame
        .tx_frame_4(tx_frame_4),                  //OUTPUT : Frame
        .sd_loopback_4(sd_loopback_4),            //OUTPUT : SERDES Loopback Enable
        .powerdown_4(pcs_pwrdn_out_sig[4]),       //OUTPUT : Powerdown Enable
        .led_col_4(led_col_4),                    //OUTPUT : Collision Indication
        .led_an_4(led_an_4),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_4(led_char_err_gx[4]),      //INPUT  : Character error
        .led_crs_4(led_crs_4),                    //OUTPUT : Carrier sense
        .led_link_4(link_status[4]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_4(tx_egress_timestamp_request_valid_4),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_4(tx_egress_timestamp_request_data_4),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_4(tx_egress_timestamp_valid_4),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_4(tx_egress_timestamp_data_4),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_4(tx_time_of_day_data_4),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_4(tx_ingress_timestamp_valid_4),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_4(tx_ingress_timestamp_data_4),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_4(rx_ingress_timestamp_valid_4),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_4(rx_ingress_timestamp_data_4),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_4(rx_time_of_day_data_4),                                //INPUT  : Time of Day
        .xoff_gen_4(xoff_gen_4),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_4(xon_gen_4),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_4(magic_sleep_n_4),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_4(magic_wakeup_4),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 5 
            

        .rx_carrierdetected_5(pcs_rx_carrierdetected[5]),
        .rx_rmfifodatadeleted_5(pcs_rx_rmfifodatadeleted[5]),
        .rx_rmfifodatainserted_5(pcs_rx_rmfifodatainserted[5]),

        .rx_clkout_5(rx_pcs_clk_c5),                 //INPUT  : Receive Clock
        .tx_clkout_5(tx_pcs_clk_c5),                 //INPUT  : Transmit Clock
        .rx_kchar_5(pcs_rx_kchar_5),              //INPUT  : Special Character Indication
        .tx_kchar_5(tx_kchar_5),                  //OUTPUT : Special Character Indication
        .rx_frame_5(pcs_rx_frame_5),              //INPUT  : Frame
        .tx_frame_5(tx_frame_5),                  //OUTPUT : Frame
        .sd_loopback_5(sd_loopback_5),            //OUTPUT : SERDES Loopback Enable
        .powerdown_5(pcs_pwrdn_out_sig[5]),       //OUTPUT : Powerdown Enable
        .led_col_5(led_col_5),                    //OUTPUT : Collision Indication
        .led_an_5(led_an_5),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_5(led_char_err_gx[5]),      //INPUT  : Character error
        .led_crs_5(led_crs_5),                    //OUTPUT : Carrier sense
        .led_link_5(link_status[5]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_5(tx_egress_timestamp_request_valid_5),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_5(tx_egress_timestamp_request_data_5),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_5(tx_egress_timestamp_valid_5),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_5(tx_egress_timestamp_data_5),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_5(tx_time_of_day_data_5),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_5(tx_ingress_timestamp_valid_5),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_5(tx_ingress_timestamp_data_5),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_5(rx_ingress_timestamp_valid_5),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_5(rx_ingress_timestamp_data_5),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_5(rx_time_of_day_data_5),                                //INPUT  : Time of Day
        .xoff_gen_5(xoff_gen_5),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_5(xon_gen_5),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_5(magic_sleep_n_5),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_5(magic_wakeup_5),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 6 
            

        .rx_carrierdetected_6(pcs_rx_carrierdetected[6]),
        .rx_rmfifodatadeleted_6(pcs_rx_rmfifodatadeleted[6]),
        .rx_rmfifodatainserted_6(pcs_rx_rmfifodatainserted[6]),

        .rx_clkout_6(rx_pcs_clk_c6),                 //INPUT  : Receive Clock
        .tx_clkout_6(tx_pcs_clk_c6),                 //INPUT  : Transmit Clock
        .rx_kchar_6(pcs_rx_kchar_6),              //INPUT  : Special Character Indication
        .tx_kchar_6(tx_kchar_6),                  //OUTPUT : Special Character Indication
        .rx_frame_6(pcs_rx_frame_6),              //INPUT  : Frame
        .tx_frame_6(tx_frame_6),                  //OUTPUT : Frame
        .sd_loopback_6(sd_loopback_6),            //OUTPUT : SERDES Loopback Enable
        .powerdown_6(pcs_pwrdn_out_sig[6]),       //OUTPUT : Powerdown Enable
        .led_col_6(led_col_6),                    //OUTPUT : Collision Indication
        .led_an_6(led_an_6),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_6(led_char_err_gx[6]),      //INPUT  : Character error
        .led_crs_6(led_crs_6),                    //OUTPUT : Carrier sense
        .led_link_6(link_status[6]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_6(tx_egress_timestamp_request_valid_6),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_6(tx_egress_timestamp_request_data_6),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_6(tx_egress_timestamp_valid_6),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_6(tx_egress_timestamp_data_6),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_6(tx_time_of_day_data_6),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_6(tx_ingress_timestamp_valid_6),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_6(tx_ingress_timestamp_data_6),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_6(rx_ingress_timestamp_valid_6),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_6(rx_ingress_timestamp_data_6),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_6(rx_time_of_day_data_6),                                //INPUT  : Time of Day
        .xoff_gen_6(xoff_gen_6),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_6(xon_gen_6),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_6(magic_sleep_n_6),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_6(magic_wakeup_6),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 7 
            

        .rx_carrierdetected_7(pcs_rx_carrierdetected[7]),
        .rx_rmfifodatadeleted_7(pcs_rx_rmfifodatadeleted[7]),
        .rx_rmfifodatainserted_7(pcs_rx_rmfifodatainserted[7]),

        .rx_clkout_7(rx_pcs_clk_c7),                 //INPUT  : Receive Clock
        .tx_clkout_7(tx_pcs_clk_c7),                 //INPUT  : Transmit Clock
        .rx_kchar_7(pcs_rx_kchar_7),              //INPUT  : Special Character Indication
        .tx_kchar_7(tx_kchar_7),                  //OUTPUT : Special Character Indication
        .rx_frame_7(pcs_rx_frame_7),              //INPUT  : Frame
        .tx_frame_7(tx_frame_7),                  //OUTPUT : Frame
        .sd_loopback_7(sd_loopback_7),            //OUTPUT : SERDES Loopback Enable
        .powerdown_7(pcs_pwrdn_out_sig[7]),       //OUTPUT : Powerdown Enable
        .led_col_7(led_col_7),                    //OUTPUT : Collision Indication
        .led_an_7(led_an_7),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_7(led_char_err_gx[7]),      //INPUT  : Character error
        .led_crs_7(led_crs_7),                    //OUTPUT : Carrier sense
        .led_link_7(link_status[7]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_7(tx_egress_timestamp_request_valid_7),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_7(tx_egress_timestamp_request_data_7),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_7(tx_egress_timestamp_valid_7),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_7(tx_egress_timestamp_data_7),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_7(tx_time_of_day_data_7),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_7(tx_ingress_timestamp_valid_7),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_7(tx_ingress_timestamp_data_7),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_7(rx_ingress_timestamp_valid_7),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_7(rx_ingress_timestamp_data_7),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_7(rx_time_of_day_data_7),                                //INPUT  : Time of Day
        .xoff_gen_7(xoff_gen_7),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_7(xon_gen_7),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_7(magic_sleep_n_7),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_7(magic_wakeup_7),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 8 
            

        .rx_carrierdetected_8(pcs_rx_carrierdetected[8]),
        .rx_rmfifodatadeleted_8(pcs_rx_rmfifodatadeleted[8]),
        .rx_rmfifodatainserted_8(pcs_rx_rmfifodatainserted[8]),

        .rx_clkout_8(rx_pcs_clk_c8),                 //INPUT  : Receive Clock
        .tx_clkout_8(tx_pcs_clk_c8),                 //INPUT  : Transmit Clock
        .rx_kchar_8(pcs_rx_kchar_8),              //INPUT  : Special Character Indication
        .tx_kchar_8(tx_kchar_8),                  //OUTPUT : Special Character Indication
        .rx_frame_8(pcs_rx_frame_8),              //INPUT  : Frame
        .tx_frame_8(tx_frame_8),                  //OUTPUT : Frame
        .sd_loopback_8(sd_loopback_8),            //OUTPUT : SERDES Loopback Enable
        .powerdown_8(pcs_pwrdn_out_sig[8]),       //OUTPUT : Powerdown Enable
        .led_col_8(led_col_8),                    //OUTPUT : Collision Indication
        .led_an_8(led_an_8),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_8(led_char_err_gx[8]),      //INPUT  : Character error
        .led_crs_8(led_crs_8),                    //OUTPUT : Carrier sense
        .led_link_8(link_status[8]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_8(tx_egress_timestamp_request_valid_8),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_8(tx_egress_timestamp_request_data_8),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_8(tx_egress_timestamp_valid_8),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_8(tx_egress_timestamp_data_8),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_8(tx_time_of_day_data_8),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_8(tx_ingress_timestamp_valid_8),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_8(tx_ingress_timestamp_data_8),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_8(rx_ingress_timestamp_valid_8),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_8(rx_ingress_timestamp_data_8),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_8(rx_time_of_day_data_8),                                //INPUT  : Time of Day
        .xoff_gen_8(xoff_gen_8),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_8(xon_gen_8),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_8(magic_sleep_n_8),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_8(magic_wakeup_8),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 9 
            

        .rx_carrierdetected_9(pcs_rx_carrierdetected[9]),
        .rx_rmfifodatadeleted_9(pcs_rx_rmfifodatadeleted[9]),
        .rx_rmfifodatainserted_9(pcs_rx_rmfifodatainserted[9]),

        .rx_clkout_9(rx_pcs_clk_c9),                 //INPUT  : Receive Clock
        .tx_clkout_9(tx_pcs_clk_c9),                 //INPUT  : Transmit Clock
        .rx_kchar_9(pcs_rx_kchar_9),              //INPUT  : Special Character Indication
        .tx_kchar_9(tx_kchar_9),                  //OUTPUT : Special Character Indication
        .rx_frame_9(pcs_rx_frame_9),              //INPUT  : Frame
        .tx_frame_9(tx_frame_9),                  //OUTPUT : Frame
        .sd_loopback_9(sd_loopback_9),            //OUTPUT : SERDES Loopback Enable
        .powerdown_9(pcs_pwrdn_out_sig[9]),       //OUTPUT : Powerdown Enable
        .led_col_9(led_col_9),                    //OUTPUT : Collision Indication
        .led_an_9(led_an_9),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_9(led_char_err_gx[9]),      //INPUT  : Character error
        .led_crs_9(led_crs_9),                    //OUTPUT : Carrier sense
        .led_link_9(link_status[9]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_9(tx_egress_timestamp_request_valid_9),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_9(tx_egress_timestamp_request_data_9),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_9(tx_egress_timestamp_valid_9),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_9(tx_egress_timestamp_data_9),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_9(tx_time_of_day_data_9),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_9(tx_ingress_timestamp_valid_9),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_9(tx_ingress_timestamp_data_9),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_9(rx_ingress_timestamp_valid_9),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_9(rx_ingress_timestamp_data_9),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_9(rx_time_of_day_data_9),                                //INPUT  : Time of Day
        .xoff_gen_9(xoff_gen_9),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_9(xon_gen_9),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_9(magic_sleep_n_9),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_9(magic_wakeup_9),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 10 
            

        .rx_carrierdetected_10(pcs_rx_carrierdetected[10]),
        .rx_rmfifodatadeleted_10(pcs_rx_rmfifodatadeleted[10]),
        .rx_rmfifodatainserted_10(pcs_rx_rmfifodatainserted[10]),

        .rx_clkout_10(rx_pcs_clk_c10),                 //INPUT  : Receive Clock
        .tx_clkout_10(tx_pcs_clk_c10),                 //INPUT  : Transmit Clock
        .rx_kchar_10(pcs_rx_kchar_10),              //INPUT  : Special Character Indication
        .tx_kchar_10(tx_kchar_10),                  //OUTPUT : Special Character Indication
        .rx_frame_10(pcs_rx_frame_10),              //INPUT  : Frame
        .tx_frame_10(tx_frame_10),                  //OUTPUT : Frame
        .sd_loopback_10(sd_loopback_10),            //OUTPUT : SERDES Loopback Enable
        .powerdown_10(pcs_pwrdn_out_sig[10]),       //OUTPUT : Powerdown Enable
        .led_col_10(led_col_10),                    //OUTPUT : Collision Indication
        .led_an_10(led_an_10),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_10(led_char_err_gx[10]),      //INPUT  : Character error
        .led_crs_10(led_crs_10),                    //OUTPUT : Carrier sense
        .led_link_10(link_status[10]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_10(tx_egress_timestamp_request_valid_10),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_10(tx_egress_timestamp_request_data_10),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_10(tx_egress_timestamp_valid_10),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_10(tx_egress_timestamp_data_10),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_10(tx_time_of_day_data_10),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_10(tx_ingress_timestamp_valid_10),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_10(tx_ingress_timestamp_data_10),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_10(rx_ingress_timestamp_valid_10),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_10(rx_ingress_timestamp_data_10),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_10(rx_time_of_day_data_10),                                //INPUT  : Time of Day
        .xoff_gen_10(xoff_gen_10),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_10(xon_gen_10),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_10(magic_sleep_n_10),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_10(magic_wakeup_10),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 11 
            

        .rx_carrierdetected_11(pcs_rx_carrierdetected[11]),
        .rx_rmfifodatadeleted_11(pcs_rx_rmfifodatadeleted[11]),
        .rx_rmfifodatainserted_11(pcs_rx_rmfifodatainserted[11]),

        .rx_clkout_11(rx_pcs_clk_c11),                 //INPUT  : Receive Clock
        .tx_clkout_11(tx_pcs_clk_c11),                 //INPUT  : Transmit Clock
        .rx_kchar_11(pcs_rx_kchar_11),              //INPUT  : Special Character Indication
        .tx_kchar_11(tx_kchar_11),                  //OUTPUT : Special Character Indication
        .rx_frame_11(pcs_rx_frame_11),              //INPUT  : Frame
        .tx_frame_11(tx_frame_11),                  //OUTPUT : Frame
        .sd_loopback_11(sd_loopback_11),            //OUTPUT : SERDES Loopback Enable
        .powerdown_11(pcs_pwrdn_out_sig[11]),       //OUTPUT : Powerdown Enable
        .led_col_11(led_col_11),                    //OUTPUT : Collision Indication
        .led_an_11(led_an_11),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_11(led_char_err_gx[11]),      //INPUT  : Character error
        .led_crs_11(led_crs_11),                    //OUTPUT : Carrier sense
        .led_link_11(link_status[11]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_11(tx_egress_timestamp_request_valid_11),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_11(tx_egress_timestamp_request_data_11),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_11(tx_egress_timestamp_valid_11),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_11(tx_egress_timestamp_data_11),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_11(tx_time_of_day_data_11),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_11(tx_ingress_timestamp_valid_11),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_11(tx_ingress_timestamp_data_11),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_11(rx_ingress_timestamp_valid_11),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_11(rx_ingress_timestamp_data_11),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_11(rx_time_of_day_data_11),                                //INPUT  : Time of Day
        .xoff_gen_11(xoff_gen_11),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_11(xon_gen_11),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_11(magic_sleep_n_11),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_11(magic_wakeup_11),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 12 
            

        .rx_carrierdetected_12(pcs_rx_carrierdetected[12]),
        .rx_rmfifodatadeleted_12(pcs_rx_rmfifodatadeleted[12]),
        .rx_rmfifodatainserted_12(pcs_rx_rmfifodatainserted[12]),

        .rx_clkout_12(rx_pcs_clk_c12),                 //INPUT  : Receive Clock
        .tx_clkout_12(tx_pcs_clk_c12),                 //INPUT  : Transmit Clock
        .rx_kchar_12(pcs_rx_kchar_12),              //INPUT  : Special Character Indication
        .tx_kchar_12(tx_kchar_12),                  //OUTPUT : Special Character Indication
        .rx_frame_12(pcs_rx_frame_12),              //INPUT  : Frame
        .tx_frame_12(tx_frame_12),                  //OUTPUT : Frame
        .sd_loopback_12(sd_loopback_12),            //OUTPUT : SERDES Loopback Enable
        .powerdown_12(pcs_pwrdn_out_sig[12]),       //OUTPUT : Powerdown Enable
        .led_col_12(led_col_12),                    //OUTPUT : Collision Indication
        .led_an_12(led_an_12),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_12(led_char_err_gx[12]),      //INPUT  : Character error
        .led_crs_12(led_crs_12),                    //OUTPUT : Carrier sense
        .led_link_12(link_status[12]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_12(tx_egress_timestamp_request_valid_12),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_12(tx_egress_timestamp_request_data_12),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_12(tx_egress_timestamp_valid_12),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_12(tx_egress_timestamp_data_12),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_12(tx_time_of_day_data_12),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_12(tx_ingress_timestamp_valid_12),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_12(tx_ingress_timestamp_data_12),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_12(rx_ingress_timestamp_valid_12),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_12(rx_ingress_timestamp_data_12),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_12(rx_time_of_day_data_12),                                //INPUT  : Time of Day
        .xoff_gen_12(xoff_gen_12),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_12(xon_gen_12),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_12(magic_sleep_n_12),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_12(magic_wakeup_12),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 13 
            

        .rx_carrierdetected_13(pcs_rx_carrierdetected[13]),
        .rx_rmfifodatadeleted_13(pcs_rx_rmfifodatadeleted[13]),
        .rx_rmfifodatainserted_13(pcs_rx_rmfifodatainserted[13]),

        .rx_clkout_13(rx_pcs_clk_c13),                 //INPUT  : Receive Clock
        .tx_clkout_13(tx_pcs_clk_c13),                 //INPUT  : Transmit Clock
        .rx_kchar_13(pcs_rx_kchar_13),              //INPUT  : Special Character Indication
        .tx_kchar_13(tx_kchar_13),                  //OUTPUT : Special Character Indication
        .rx_frame_13(pcs_rx_frame_13),              //INPUT  : Frame
        .tx_frame_13(tx_frame_13),                  //OUTPUT : Frame
        .sd_loopback_13(sd_loopback_13),            //OUTPUT : SERDES Loopback Enable
        .powerdown_13(pcs_pwrdn_out_sig[13]),       //OUTPUT : Powerdown Enable
        .led_col_13(led_col_13),                    //OUTPUT : Collision Indication
        .led_an_13(led_an_13),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_13(led_char_err_gx[13]),      //INPUT  : Character error
        .led_crs_13(led_crs_13),                    //OUTPUT : Carrier sense
        .led_link_13(link_status[13]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_13(tx_egress_timestamp_request_valid_13),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_13(tx_egress_timestamp_request_data_13),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_13(tx_egress_timestamp_valid_13),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_13(tx_egress_timestamp_data_13),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_13(tx_time_of_day_data_13),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_13(tx_ingress_timestamp_valid_13),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_13(tx_ingress_timestamp_data_13),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_13(rx_ingress_timestamp_valid_13),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_13(rx_ingress_timestamp_data_13),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_13(rx_time_of_day_data_13),                                //INPUT  : Time of Day
        .xoff_gen_13(xoff_gen_13),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_13(xon_gen_13),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_13(magic_sleep_n_13),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_13(magic_wakeup_13),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 14 
            

        .rx_carrierdetected_14(pcs_rx_carrierdetected[14]),
        .rx_rmfifodatadeleted_14(pcs_rx_rmfifodatadeleted[14]),
        .rx_rmfifodatainserted_14(pcs_rx_rmfifodatainserted[14]),

        .rx_clkout_14(rx_pcs_clk_c14),                 //INPUT  : Receive Clock
        .tx_clkout_14(tx_pcs_clk_c14),                 //INPUT  : Transmit Clock
        .rx_kchar_14(pcs_rx_kchar_14),              //INPUT  : Special Character Indication
        .tx_kchar_14(tx_kchar_14),                  //OUTPUT : Special Character Indication
        .rx_frame_14(pcs_rx_frame_14),              //INPUT  : Frame
        .tx_frame_14(tx_frame_14),                  //OUTPUT : Frame
        .sd_loopback_14(sd_loopback_14),            //OUTPUT : SERDES Loopback Enable
        .powerdown_14(pcs_pwrdn_out_sig[14]),       //OUTPUT : Powerdown Enable
        .led_col_14(led_col_14),                    //OUTPUT : Collision Indication
        .led_an_14(led_an_14),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_14(led_char_err_gx[14]),      //INPUT  : Character error
        .led_crs_14(led_crs_14),                    //OUTPUT : Carrier sense
        .led_link_14(link_status[14]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_14(tx_egress_timestamp_request_valid_14),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_14(tx_egress_timestamp_request_data_14),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_14(tx_egress_timestamp_valid_14),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_14(tx_egress_timestamp_data_14),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_14(tx_time_of_day_data_14),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_14(tx_ingress_timestamp_valid_14),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_14(tx_ingress_timestamp_data_14),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_14(rx_ingress_timestamp_valid_14),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_14(rx_ingress_timestamp_data_14),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_14(rx_time_of_day_data_14),                                //INPUT  : Time of Day
        .xoff_gen_14(xoff_gen_14),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_14(xon_gen_14),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_14(magic_sleep_n_14),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_14(magic_wakeup_14),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 15 
            

        .rx_carrierdetected_15(pcs_rx_carrierdetected[15]),
        .rx_rmfifodatadeleted_15(pcs_rx_rmfifodatadeleted[15]),
        .rx_rmfifodatainserted_15(pcs_rx_rmfifodatainserted[15]),

        .rx_clkout_15(rx_pcs_clk_c15),                 //INPUT  : Receive Clock
        .tx_clkout_15(tx_pcs_clk_c15),                 //INPUT  : Transmit Clock
        .rx_kchar_15(pcs_rx_kchar_15),              //INPUT  : Special Character Indication
        .tx_kchar_15(tx_kchar_15),                  //OUTPUT : Special Character Indication
        .rx_frame_15(pcs_rx_frame_15),              //INPUT  : Frame
        .tx_frame_15(tx_frame_15),                  //OUTPUT : Frame
        .sd_loopback_15(sd_loopback_15),            //OUTPUT : SERDES Loopback Enable
        .powerdown_15(pcs_pwrdn_out_sig[15]),       //OUTPUT : Powerdown Enable
        .led_col_15(led_col_15),                    //OUTPUT : Collision Indication
        .led_an_15(led_an_15),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_15(led_char_err_gx[15]),      //INPUT  : Character error
        .led_crs_15(led_crs_15),                    //OUTPUT : Carrier sense
        .led_link_15(link_status[15]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_15(tx_egress_timestamp_request_valid_15),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_15(tx_egress_timestamp_request_data_15),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_15(tx_egress_timestamp_valid_15),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_15(tx_egress_timestamp_data_15),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_15(tx_time_of_day_data_15),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_15(tx_ingress_timestamp_valid_15),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_15(tx_ingress_timestamp_data_15),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_15(rx_ingress_timestamp_valid_15),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_15(rx_ingress_timestamp_data_15),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_15(rx_time_of_day_data_15),                                //INPUT  : Time of Day
        .xoff_gen_15(xoff_gen_15),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_15(xon_gen_15),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_15(magic_sleep_n_15),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_15(magic_wakeup_15),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 16 
            

        .rx_carrierdetected_16(pcs_rx_carrierdetected[16]),
        .rx_rmfifodatadeleted_16(pcs_rx_rmfifodatadeleted[16]),
        .rx_rmfifodatainserted_16(pcs_rx_rmfifodatainserted[16]),

        .rx_clkout_16(rx_pcs_clk_c16),                 //INPUT  : Receive Clock
        .tx_clkout_16(tx_pcs_clk_c16),                 //INPUT  : Transmit Clock
        .rx_kchar_16(pcs_rx_kchar_16),              //INPUT  : Special Character Indication
        .tx_kchar_16(tx_kchar_16),                  //OUTPUT : Special Character Indication
        .rx_frame_16(pcs_rx_frame_16),              //INPUT  : Frame
        .tx_frame_16(tx_frame_16),                  //OUTPUT : Frame
        .sd_loopback_16(sd_loopback_16),            //OUTPUT : SERDES Loopback Enable
        .powerdown_16(pcs_pwrdn_out_sig[16]),       //OUTPUT : Powerdown Enable
        .led_col_16(led_col_16),                    //OUTPUT : Collision Indication
        .led_an_16(led_an_16),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_16(led_char_err_gx[16]),      //INPUT  : Character error
        .led_crs_16(led_crs_16),                    //OUTPUT : Carrier sense
        .led_link_16(link_status[16]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_16(tx_egress_timestamp_request_valid_16),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_16(tx_egress_timestamp_request_data_16),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_16(tx_egress_timestamp_valid_16),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_16(tx_egress_timestamp_data_16),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_16(tx_time_of_day_data_16),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_16(tx_ingress_timestamp_valid_16),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_16(tx_ingress_timestamp_data_16),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_16(rx_ingress_timestamp_valid_16),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_16(rx_ingress_timestamp_data_16),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_16(rx_time_of_day_data_16),                                //INPUT  : Time of Day
        .xoff_gen_16(xoff_gen_16),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_16(xon_gen_16),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_16(magic_sleep_n_16),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_16(magic_wakeup_16),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 17 
            

        .rx_carrierdetected_17(pcs_rx_carrierdetected[17]),
        .rx_rmfifodatadeleted_17(pcs_rx_rmfifodatadeleted[17]),
        .rx_rmfifodatainserted_17(pcs_rx_rmfifodatainserted[17]),

        .rx_clkout_17(rx_pcs_clk_c17),                 //INPUT  : Receive Clock
        .tx_clkout_17(tx_pcs_clk_c17),                 //INPUT  : Transmit Clock
        .rx_kchar_17(pcs_rx_kchar_17),              //INPUT  : Special Character Indication
        .tx_kchar_17(tx_kchar_17),                  //OUTPUT : Special Character Indication
        .rx_frame_17(pcs_rx_frame_17),              //INPUT  : Frame
        .tx_frame_17(tx_frame_17),                  //OUTPUT : Frame
        .sd_loopback_17(sd_loopback_17),            //OUTPUT : SERDES Loopback Enable
        .powerdown_17(pcs_pwrdn_out_sig[17]),       //OUTPUT : Powerdown Enable
        .led_col_17(led_col_17),                    //OUTPUT : Collision Indication
        .led_an_17(led_an_17),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_17(led_char_err_gx[17]),      //INPUT  : Character error
        .led_crs_17(led_crs_17),                    //OUTPUT : Carrier sense
        .led_link_17(link_status[17]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_17(tx_egress_timestamp_request_valid_17),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_17(tx_egress_timestamp_request_data_17),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_17(tx_egress_timestamp_valid_17),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_17(tx_egress_timestamp_data_17),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_17(tx_time_of_day_data_17),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_17(tx_ingress_timestamp_valid_17),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_17(tx_ingress_timestamp_data_17),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_17(rx_ingress_timestamp_valid_17),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_17(rx_ingress_timestamp_data_17),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_17(rx_time_of_day_data_17),                                //INPUT  : Time of Day
        .xoff_gen_17(xoff_gen_17),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_17(xon_gen_17),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_17(magic_sleep_n_17),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_17(magic_wakeup_17),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 18 
            

        .rx_carrierdetected_18(pcs_rx_carrierdetected[18]),
        .rx_rmfifodatadeleted_18(pcs_rx_rmfifodatadeleted[18]),
        .rx_rmfifodatainserted_18(pcs_rx_rmfifodatainserted[18]),

        .rx_clkout_18(rx_pcs_clk_c18),                 //INPUT  : Receive Clock
        .tx_clkout_18(tx_pcs_clk_c18),                 //INPUT  : Transmit Clock
        .rx_kchar_18(pcs_rx_kchar_18),              //INPUT  : Special Character Indication
        .tx_kchar_18(tx_kchar_18),                  //OUTPUT : Special Character Indication
        .rx_frame_18(pcs_rx_frame_18),              //INPUT  : Frame
        .tx_frame_18(tx_frame_18),                  //OUTPUT : Frame
        .sd_loopback_18(sd_loopback_18),            //OUTPUT : SERDES Loopback Enable
        .powerdown_18(pcs_pwrdn_out_sig[18]),       //OUTPUT : Powerdown Enable
        .led_col_18(led_col_18),                    //OUTPUT : Collision Indication
        .led_an_18(led_an_18),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_18(led_char_err_gx[18]),      //INPUT  : Character error
        .led_crs_18(led_crs_18),                    //OUTPUT : Carrier sense
        .led_link_18(link_status[18]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_18(tx_egress_timestamp_request_valid_18),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_18(tx_egress_timestamp_request_data_18),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_18(tx_egress_timestamp_valid_18),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_18(tx_egress_timestamp_data_18),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_18(tx_time_of_day_data_18),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_18(tx_ingress_timestamp_valid_18),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_18(tx_ingress_timestamp_data_18),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_18(rx_ingress_timestamp_valid_18),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_18(rx_ingress_timestamp_data_18),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_18(rx_time_of_day_data_18),                                //INPUT  : Time of Day
        .xoff_gen_18(xoff_gen_18),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_18(xon_gen_18),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_18(magic_sleep_n_18),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_18(magic_wakeup_18),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 19 
            

        .rx_carrierdetected_19(pcs_rx_carrierdetected[19]),
        .rx_rmfifodatadeleted_19(pcs_rx_rmfifodatadeleted[19]),
        .rx_rmfifodatainserted_19(pcs_rx_rmfifodatainserted[19]),

        .rx_clkout_19(rx_pcs_clk_c19),                 //INPUT  : Receive Clock
        .tx_clkout_19(tx_pcs_clk_c19),                 //INPUT  : Transmit Clock
        .rx_kchar_19(pcs_rx_kchar_19),              //INPUT  : Special Character Indication
        .tx_kchar_19(tx_kchar_19),                  //OUTPUT : Special Character Indication
        .rx_frame_19(pcs_rx_frame_19),              //INPUT  : Frame
        .tx_frame_19(tx_frame_19),                  //OUTPUT : Frame
        .sd_loopback_19(sd_loopback_19),            //OUTPUT : SERDES Loopback Enable
        .powerdown_19(pcs_pwrdn_out_sig[19]),       //OUTPUT : Powerdown Enable
        .led_col_19(led_col_19),                    //OUTPUT : Collision Indication
        .led_an_19(led_an_19),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_19(led_char_err_gx[19]),      //INPUT  : Character error
        .led_crs_19(led_crs_19),                    //OUTPUT : Carrier sense
        .led_link_19(link_status[19]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_19(tx_egress_timestamp_request_valid_19),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_19(tx_egress_timestamp_request_data_19),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_19(tx_egress_timestamp_valid_19),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_19(tx_egress_timestamp_data_19),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_19(tx_time_of_day_data_19),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_19(tx_ingress_timestamp_valid_19),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_19(tx_ingress_timestamp_data_19),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_19(rx_ingress_timestamp_valid_19),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_19(rx_ingress_timestamp_data_19),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_19(rx_time_of_day_data_19),                                //INPUT  : Time of Day
        .xoff_gen_19(xoff_gen_19),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_19(xon_gen_19),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_19(magic_sleep_n_19),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_19(magic_wakeup_19),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 20 
            

        .rx_carrierdetected_20(pcs_rx_carrierdetected[20]),
        .rx_rmfifodatadeleted_20(pcs_rx_rmfifodatadeleted[20]),
        .rx_rmfifodatainserted_20(pcs_rx_rmfifodatainserted[20]),

        .rx_clkout_20(rx_pcs_clk_c20),                 //INPUT  : Receive Clock
        .tx_clkout_20(tx_pcs_clk_c20),                 //INPUT  : Transmit Clock
        .rx_kchar_20(pcs_rx_kchar_20),              //INPUT  : Special Character Indication
        .tx_kchar_20(tx_kchar_20),                  //OUTPUT : Special Character Indication
        .rx_frame_20(pcs_rx_frame_20),              //INPUT  : Frame
        .tx_frame_20(tx_frame_20),                  //OUTPUT : Frame
        .sd_loopback_20(sd_loopback_20),            //OUTPUT : SERDES Loopback Enable
        .powerdown_20(pcs_pwrdn_out_sig[20]),       //OUTPUT : Powerdown Enable
        .led_col_20(led_col_20),                    //OUTPUT : Collision Indication
        .led_an_20(led_an_20),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_20(led_char_err_gx[20]),      //INPUT  : Character error
        .led_crs_20(led_crs_20),                    //OUTPUT : Carrier sense
        .led_link_20(link_status[20]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_20(tx_egress_timestamp_request_valid_20),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_20(tx_egress_timestamp_request_data_20),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_20(tx_egress_timestamp_valid_20),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_20(tx_egress_timestamp_data_20),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_20(tx_time_of_day_data_20),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_20(tx_ingress_timestamp_valid_20),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_20(tx_ingress_timestamp_data_20),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_20(rx_ingress_timestamp_valid_20),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_20(rx_ingress_timestamp_data_20),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_20(rx_time_of_day_data_20),                                //INPUT  : Time of Day
        .xoff_gen_20(xoff_gen_20),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_20(xon_gen_20),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_20(magic_sleep_n_20),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_20(magic_wakeup_20),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 21 
            

        .rx_carrierdetected_21(pcs_rx_carrierdetected[21]),
        .rx_rmfifodatadeleted_21(pcs_rx_rmfifodatadeleted[21]),
        .rx_rmfifodatainserted_21(pcs_rx_rmfifodatainserted[21]),

        .rx_clkout_21(rx_pcs_clk_c21),                 //INPUT  : Receive Clock
        .tx_clkout_21(tx_pcs_clk_c21),                 //INPUT  : Transmit Clock
        .rx_kchar_21(pcs_rx_kchar_21),              //INPUT  : Special Character Indication
        .tx_kchar_21(tx_kchar_21),                  //OUTPUT : Special Character Indication
        .rx_frame_21(pcs_rx_frame_21),              //INPUT  : Frame
        .tx_frame_21(tx_frame_21),                  //OUTPUT : Frame
        .sd_loopback_21(sd_loopback_21),            //OUTPUT : SERDES Loopback Enable
        .powerdown_21(pcs_pwrdn_out_sig[21]),       //OUTPUT : Powerdown Enable
        .led_col_21(led_col_21),                    //OUTPUT : Collision Indication
        .led_an_21(led_an_21),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_21(led_char_err_gx[21]),      //INPUT  : Character error
        .led_crs_21(led_crs_21),                    //OUTPUT : Carrier sense
        .led_link_21(link_status[21]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_21(tx_egress_timestamp_request_valid_21),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_21(tx_egress_timestamp_request_data_21),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_21(tx_egress_timestamp_valid_21),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_21(tx_egress_timestamp_data_21),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_21(tx_time_of_day_data_21),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_21(tx_ingress_timestamp_valid_21),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_21(tx_ingress_timestamp_data_21),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_21(rx_ingress_timestamp_valid_21),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_21(rx_ingress_timestamp_data_21),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_21(rx_time_of_day_data_21),                                //INPUT  : Time of Day
        .xoff_gen_21(xoff_gen_21),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_21(xon_gen_21),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_21(magic_sleep_n_21),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_21(magic_wakeup_21),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 22 
            

        .rx_carrierdetected_22(pcs_rx_carrierdetected[22]),
        .rx_rmfifodatadeleted_22(pcs_rx_rmfifodatadeleted[22]),
        .rx_rmfifodatainserted_22(pcs_rx_rmfifodatainserted[22]),

        .rx_clkout_22(rx_pcs_clk_c22),                 //INPUT  : Receive Clock
        .tx_clkout_22(tx_pcs_clk_c22),                 //INPUT  : Transmit Clock
        .rx_kchar_22(pcs_rx_kchar_22),              //INPUT  : Special Character Indication
        .tx_kchar_22(tx_kchar_22),                  //OUTPUT : Special Character Indication
        .rx_frame_22(pcs_rx_frame_22),              //INPUT  : Frame
        .tx_frame_22(tx_frame_22),                  //OUTPUT : Frame
        .sd_loopback_22(sd_loopback_22),            //OUTPUT : SERDES Loopback Enable
        .powerdown_22(pcs_pwrdn_out_sig[22]),       //OUTPUT : Powerdown Enable
        .led_col_22(led_col_22),                    //OUTPUT : Collision Indication
        .led_an_22(led_an_22),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_22(led_char_err_gx[22]),      //INPUT  : Character error
        .led_crs_22(led_crs_22),                    //OUTPUT : Carrier sense
        .led_link_22(link_status[22]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_22(tx_egress_timestamp_request_valid_22),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_22(tx_egress_timestamp_request_data_22),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_22(tx_egress_timestamp_valid_22),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_22(tx_egress_timestamp_data_22),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_22(tx_time_of_day_data_22),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_22(tx_ingress_timestamp_valid_22),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_22(tx_ingress_timestamp_data_22),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_22(rx_ingress_timestamp_valid_22),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_22(rx_ingress_timestamp_data_22),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_22(rx_time_of_day_data_22),                                //INPUT  : Time of Day
        .xoff_gen_22(xoff_gen_22),                  //INPUT  : XOFF PAUSE FRAME GENERATE
        .xon_gen_22(xon_gen_22),                    //INPUT  : XON PAUSE FRAME GENERATE
        .magic_sleep_n_22(magic_sleep_n_22),        //INPUT  : MAC SLEEP MODE CONTROL
        .magic_wakeup_22(magic_wakeup_22),          //OUTPUT : MAC WAKE-UP INDICATION

         // Channel 23 
            

        .rx_carrierdetected_23(pcs_rx_carrierdetected[23]),
        .rx_rmfifodatadeleted_23(pcs_rx_rmfifodatadeleted[23]),
        .rx_rmfifodatainserted_23(pcs_rx_rmfifodatainserted[23]),

        .rx_clkout_23(rx_pcs_clk_c23),                 //INPUT  : Receive Clock
        .tx_clkout_23(tx_pcs_clk_c23),                 //INPUT  : Transmit Clock
        .rx_kchar_23(pcs_rx_kchar_23),              //INPUT  : Special Character Indication
        .tx_kchar_23(tx_kchar_23),                  //OUTPUT : Special Character Indication
        .rx_frame_23(pcs_rx_frame_23),              //INPUT  : Frame
        .tx_frame_23(tx_frame_23),                  //OUTPUT : Frame
        .sd_loopback_23(sd_loopback_23),            //OUTPUT : SERDES Loopback Enable
        .powerdown_23(pcs_pwrdn_out_sig[23]),       //OUTPUT : Powerdown Enable
        .led_col_23(led_col_23),                    //OUTPUT : Collision Indication
        .led_an_23(led_an_23),                      //OUTPUT : Auto Negotiation Status
        .led_char_err_23(led_char_err_gx[23]),      //INPUT  : Character error
        .led_crs_23(led_crs_23),                    //OUTPUT : Carrier sense
        .led_link_23(link_status[23]),              //INPUT  : Valid link    
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
        //IEEE1588's code
        .tx_egress_timestamp_request_valid_23(tx_egress_timestamp_request_valid_23),    //INPUT  : Timestamp request valid from user
        .tx_egress_timestamp_request_data_23(tx_egress_timestamp_request_data_23),      //INPUT  : Fingerprint associated to the timestamp request
        .tx_egress_timestamp_valid_23(tx_egress_timestamp_valid_23),                    //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_egress_timestamp_data_23(tx_egress_timestamp_data_23),                      //OUTPUT : Timestamp + Fingerprint from TSU
        .tx_time_of_day_data_23(tx_time_of_day_data_23),                                //INPUT  : Time of Day
        .tx_ingress_timestamp_valid_23(tx_ingress_timestamp_valid_23),                  //INPUT  : Timestamp to TSU
        .tx_ingress_timestamp_data_23(tx_ingress_timestamp_data_23),                    //INPUT  : Timestamp to TSU
        .rx_ingress_timestamp_valid_23(rx_ingress_timestamp_valid_23),                  //OUTPUT : RX timestamp valid
        .rx_ingress_timestamp_data_23(rx_ingress_timestamp_data_23),                    //OUTPUT : RX timestamp data
        .rx_time_of_day_data_23(rx_time_of_day_data_23),                                //INPUT  : Time of Day
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
        U_MULTI_MAC_PCS.ENABLE_REG_SHARING = ENABLE_REG_SHARING,
        U_MULTI_MAC_PCS.TSTAMP_FP_WIDTH = TSTAMP_FP_WIDTH,
        U_MULTI_MAC_PCS.ENABLE_TIMESTAMPING = ENABLE_TIMESTAMPING,
        U_MULTI_MAC_PCS.ENABLE_PTP_1STEP = ENABLE_PTP_1STEP;



// #######################################################################
// ###############       CHANNEL 0 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_0,gxb_pwrdn_in_sig_clk_0;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 0)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_0)
        begin
          if (gxb_pwrdn_in_0 == 1) begin
              data_in_0 <= 1;
              gxb_pwrdn_in_sig_clk_0 <= 1;
          end else begin
            data_in_0 <= 1'b0;
            gxb_pwrdn_in_sig_clk_0 <= data_in_0;
          end   
        end
        assign gxb_pwrdn_in_sig[0] = gxb_pwrdn_in_0;
        assign pcs_pwrdn_out_0 = pcs_pwrdn_out_sig[0];
    end
else
    begin
        assign gxb_pwrdn_in_sig[0] = pcs_pwrdn_out_sig[0];
        assign pcs_pwrdn_out_0 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_0 = gxb_pwrdn_in_sig[0];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 0)
    begin  
        wire    locked_signal_0;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_0(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_0),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_0),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_0),// output
            .rx_analogreset(rx_analogreset_sqcnr_0),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_0),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_0),// output
            .pll_is_locked(locked_signal_0),
            .rx_is_lockedtodata(rx_freqlocked_0),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_0)
        );
        assign locked_signal_0 = (reset? 1'b0: pll_locked_0);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_0_reset_sync_0 (
            .clk(rx_pcs_clk_c0),
            .reset_in(rx_digitalreset_sqcnr_0),
            .reset_out(reset_rx_pcs_clk_c0_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_0
          (
            .clk(rx_pcs_clk_c0),
            .reset(reset_rx_pcs_clk_c0_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_0),
            .alt_sync(rx_syncstatus[0]),
            .alt_disperr(rx_disp_err[0]),
            .alt_ctrldetect(rx_kchar_0),
            .alt_errdetect(rx_char_err_gx[0]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[0]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[0]),
            .alt_runlengthviolation(rx_runlengthviolation[0]),
            .alt_patterndetect(rx_patterndetect[0]),
            .alt_runningdisp(rx_runningdisp[0]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_0),
            .altpcs_sync(link_status[0]),
            .altpcs_disperr(led_disp_err_0),
            .altpcs_ctrldetect(pcs_rx_kchar_0),
            .altpcs_errdetect(led_char_err_gx[0]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[0]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[0]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[0])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_0.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_0
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[0]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_0),
            .reconfig_clk(reconfig_clk_0),
            .reconfig_togxb(reconfig_togxb_0),
            .reconfig_fromgxb(reconfig_fromgxb_0),              
            .rx_analogreset (rx_analogreset_sqcnr_0),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_0),
            .rx_clkout (rx_pcs_clk_c0),
            .rx_datain (rxp_0),
            .rx_dataout (rx_frame_0),
            .rx_digitalreset (rx_digitalreset_sqcnr_0),
            .rx_disperr (rx_disp_err[0]),
            .rx_errdetect (rx_char_err_gx[0]),
            .rx_patterndetect (rx_patterndetect[0]),
            .rx_rlv (rx_runlengthviolation[0]),
            .rx_seriallpbken (sd_loopback_0),
            .rx_syncstatus (rx_syncstatus[0]),
            .tx_clkout (tx_pcs_clk_c0),
            .tx_ctrlenable (tx_kchar_0),
            .tx_datain (tx_frame_0),
            .rx_freqlocked (rx_freqlocked_0),
            .tx_dataout (txp_0),
            .tx_digitalreset (tx_digitalreset_sqcnr_0),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[0]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[0]),
            .rx_runningdisp(rx_runningdisp[0]),
            .pll_powerdown(gxb_pwrdn_in_sig[0]),
            .pll_locked(pll_locked_0) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_0.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_0.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_0.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER,
        the_altera_tse_gxb_gige_inst_0.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_0 = {17{1'b0}};
    assign led_char_err_gx[0] = 1'b0;
    assign link_status[0] = 1'b0;
    assign led_disp_err_0 = 1'b0;
    assign txp_0 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 1 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_1,gxb_pwrdn_in_sig_clk_1;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 1)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_1)
        begin
          if (gxb_pwrdn_in_1 == 1) begin
              data_in_1 <= 1;
              gxb_pwrdn_in_sig_clk_1 <= 1;
          end else begin
            data_in_1 <= 1'b0;
            gxb_pwrdn_in_sig_clk_1 <= data_in_1;
          end   
        end
        assign gxb_pwrdn_in_sig[1] = gxb_pwrdn_in_1;
        assign pcs_pwrdn_out_1 = pcs_pwrdn_out_sig[1];
    end
else
    begin
        assign gxb_pwrdn_in_sig[1] = pcs_pwrdn_out_sig[1];
        assign pcs_pwrdn_out_1 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_1 = gxb_pwrdn_in_sig[1];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 1)
    begin  
        wire    locked_signal_1;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_1(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_1),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_1),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_1),// output
            .rx_analogreset(rx_analogreset_sqcnr_1),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_1),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_1),// output
            .pll_is_locked(locked_signal_1),
            .rx_is_lockedtodata(rx_freqlocked_1),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_1)
        );
        assign locked_signal_1 = (reset? 1'b0: pll_locked_1);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_1_reset_sync_0 (
            .clk(rx_pcs_clk_c1),
            .reset_in(rx_digitalreset_sqcnr_1),
            .reset_out(reset_rx_pcs_clk_c1_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_1
          (
            .clk(rx_pcs_clk_c1),
            .reset(reset_rx_pcs_clk_c1_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_1),
            .alt_sync(rx_syncstatus[1]),
            .alt_disperr(rx_disp_err[1]),
            .alt_ctrldetect(rx_kchar_1),
            .alt_errdetect(rx_char_err_gx[1]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[1]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[1]),
            .alt_runlengthviolation(rx_runlengthviolation[1]),
            .alt_patterndetect(rx_patterndetect[1]),
            .alt_runningdisp(rx_runningdisp[1]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_1),
            .altpcs_sync(link_status[1]),
            .altpcs_disperr(led_disp_err_1),
            .altpcs_ctrldetect(pcs_rx_kchar_1),
            .altpcs_errdetect(led_char_err_gx[1]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[1]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[1]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[1])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_1.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_1
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[1]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_1),
            .reconfig_clk(reconfig_clk_1),
            .reconfig_togxb(reconfig_togxb_1),
            .reconfig_fromgxb(reconfig_fromgxb_1),              
            .rx_analogreset (rx_analogreset_sqcnr_1),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_1),
            .rx_clkout (rx_pcs_clk_c1),
            .rx_datain (rxp_1),
            .rx_dataout (rx_frame_1),
            .rx_digitalreset (rx_digitalreset_sqcnr_1),
            .rx_disperr (rx_disp_err[1]),
            .rx_errdetect (rx_char_err_gx[1]),
            .rx_patterndetect (rx_patterndetect[1]),
            .rx_rlv (rx_runlengthviolation[1]),
            .rx_seriallpbken (sd_loopback_1),
            .rx_syncstatus (rx_syncstatus[1]),
            .tx_clkout (tx_pcs_clk_c1),
            .tx_ctrlenable (tx_kchar_1),
            .tx_datain (tx_frame_1),
            .rx_freqlocked (rx_freqlocked_1),
            .tx_dataout (txp_1),
            .tx_digitalreset (tx_digitalreset_sqcnr_1),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[1]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[1]),
            .rx_runningdisp(rx_runningdisp[1]),
            .pll_powerdown(gxb_pwrdn_in_sig[1]),
            .pll_locked(pll_locked_1) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_1.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_1.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_1.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 4,
        the_altera_tse_gxb_gige_inst_1.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_1 = {17{1'b0}};
    assign led_char_err_gx[1] = 1'b0;
    assign link_status[1] = 1'b0;
    assign led_disp_err_1 = 1'b0;
    assign txp_1 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 2 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_2,gxb_pwrdn_in_sig_clk_2;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 2)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_2)
        begin
          if (gxb_pwrdn_in_2 == 1) begin
              data_in_2 <= 1;
              gxb_pwrdn_in_sig_clk_2 <= 1;
          end else begin
            data_in_2 <= 1'b0;
            gxb_pwrdn_in_sig_clk_2 <= data_in_2;
          end   
        end
        assign gxb_pwrdn_in_sig[2] = gxb_pwrdn_in_2;
        assign pcs_pwrdn_out_2 = pcs_pwrdn_out_sig[2];
    end
else
    begin
        assign gxb_pwrdn_in_sig[2] = pcs_pwrdn_out_sig[2];
        assign pcs_pwrdn_out_2 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_2 = gxb_pwrdn_in_sig[2];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 2)
    begin  
        wire    locked_signal_2;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_2(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_2),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_2),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_2),// output
            .rx_analogreset(rx_analogreset_sqcnr_2),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_2),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_2),// output
            .pll_is_locked(locked_signal_2),
            .rx_is_lockedtodata(rx_freqlocked_2),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_2)
        );
        assign locked_signal_2 = (reset? 1'b0: pll_locked_2);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_2_reset_sync_0 (
            .clk(rx_pcs_clk_c2),
            .reset_in(rx_digitalreset_sqcnr_2),
            .reset_out(reset_rx_pcs_clk_c2_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_2
          (
            .clk(rx_pcs_clk_c2),
            .reset(reset_rx_pcs_clk_c2_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_2),
            .alt_sync(rx_syncstatus[2]),
            .alt_disperr(rx_disp_err[2]),
            .alt_ctrldetect(rx_kchar_2),
            .alt_errdetect(rx_char_err_gx[2]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[2]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[2]),
            .alt_runlengthviolation(rx_runlengthviolation[2]),
            .alt_patterndetect(rx_patterndetect[2]),
            .alt_runningdisp(rx_runningdisp[2]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_2),
            .altpcs_sync(link_status[2]),
            .altpcs_disperr(led_disp_err_2),
            .altpcs_ctrldetect(pcs_rx_kchar_2),
            .altpcs_errdetect(led_char_err_gx[2]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[2]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[2]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[2])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_2.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_2
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[2]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_2),
            .reconfig_clk(reconfig_clk_2),
            .reconfig_togxb(reconfig_togxb_2),
            .reconfig_fromgxb(reconfig_fromgxb_2),              
            .rx_analogreset (rx_analogreset_sqcnr_2),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_2),
            .rx_clkout (rx_pcs_clk_c2),
            .rx_datain (rxp_2),
            .rx_dataout (rx_frame_2),
            .rx_digitalreset (rx_digitalreset_sqcnr_2),
            .rx_disperr (rx_disp_err[2]),
            .rx_errdetect (rx_char_err_gx[2]),
            .rx_patterndetect (rx_patterndetect[2]),
            .rx_rlv (rx_runlengthviolation[2]),
            .rx_seriallpbken (sd_loopback_2),
            .rx_syncstatus (rx_syncstatus[2]),
            .tx_clkout (tx_pcs_clk_c2),
            .tx_ctrlenable (tx_kchar_2),
            .tx_datain (tx_frame_2),
            .rx_freqlocked (rx_freqlocked_2),
            .tx_dataout (txp_2),
            .tx_digitalreset (tx_digitalreset_sqcnr_2),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[2]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[2]),
            .rx_runningdisp(rx_runningdisp[2]),
            .pll_powerdown(gxb_pwrdn_in_sig[2]),
            .pll_locked(pll_locked_2) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_2.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_2.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_2.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 8,
        the_altera_tse_gxb_gige_inst_2.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_2 = {17{1'b0}};
    assign led_char_err_gx[2] = 1'b0;
    assign link_status[2] = 1'b0;
    assign led_disp_err_2 = 1'b0;
    assign txp_2 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 3 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_3,gxb_pwrdn_in_sig_clk_3;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 3)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_3)
        begin
          if (gxb_pwrdn_in_3 == 1) begin
              data_in_3 <= 1;
              gxb_pwrdn_in_sig_clk_3 <= 1;
          end else begin
            data_in_3 <= 1'b0;
            gxb_pwrdn_in_sig_clk_3 <= data_in_3;
          end   
        end
        assign gxb_pwrdn_in_sig[3] = gxb_pwrdn_in_3;
        assign pcs_pwrdn_out_3 = pcs_pwrdn_out_sig[3];
    end
else
    begin
        assign gxb_pwrdn_in_sig[3] = pcs_pwrdn_out_sig[3];
        assign pcs_pwrdn_out_3 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_3 = gxb_pwrdn_in_sig[3];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 3)
    begin  
        wire    locked_signal_3;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_3(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_3),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_3),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_3),// output
            .rx_analogreset(rx_analogreset_sqcnr_3),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_3),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_3),// output
            .pll_is_locked(locked_signal_3),
            .rx_is_lockedtodata(rx_freqlocked_3),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_3)
        );
        assign locked_signal_3 = (reset? 1'b0: pll_locked_3);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_3_reset_sync_0 (
            .clk(rx_pcs_clk_c3),
            .reset_in(rx_digitalreset_sqcnr_3),
            .reset_out(reset_rx_pcs_clk_c3_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_3
          (
            .clk(rx_pcs_clk_c3),
            .reset(reset_rx_pcs_clk_c3_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_3),
            .alt_sync(rx_syncstatus[3]),
            .alt_disperr(rx_disp_err[3]),
            .alt_ctrldetect(rx_kchar_3),
            .alt_errdetect(rx_char_err_gx[3]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[3]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[3]),
            .alt_runlengthviolation(rx_runlengthviolation[3]),
            .alt_patterndetect(rx_patterndetect[3]),
            .alt_runningdisp(rx_runningdisp[3]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_3),
            .altpcs_sync(link_status[3]),
            .altpcs_disperr(led_disp_err_3),
            .altpcs_ctrldetect(pcs_rx_kchar_3),
            .altpcs_errdetect(led_char_err_gx[3]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[3]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[3]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[3])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_3.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_3
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[3]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_3),
            .reconfig_clk(reconfig_clk_3),
            .reconfig_togxb(reconfig_togxb_3),
            .reconfig_fromgxb(reconfig_fromgxb_3),              
            .rx_analogreset (rx_analogreset_sqcnr_3),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_3),
            .rx_clkout (rx_pcs_clk_c3),
            .rx_datain (rxp_3),
            .rx_dataout (rx_frame_3),
            .rx_digitalreset (rx_digitalreset_sqcnr_3),
            .rx_disperr (rx_disp_err[3]),
            .rx_errdetect (rx_char_err_gx[3]),
            .rx_patterndetect (rx_patterndetect[3]),
            .rx_rlv (rx_runlengthviolation[3]),
            .rx_seriallpbken (sd_loopback_3),
            .rx_syncstatus (rx_syncstatus[3]),
            .tx_clkout (tx_pcs_clk_c3),
            .tx_ctrlenable (tx_kchar_3),
            .tx_datain (tx_frame_3),
            .rx_freqlocked (rx_freqlocked_3),
            .tx_dataout (txp_3),
            .tx_digitalreset (tx_digitalreset_sqcnr_3),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[3]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[3]),
            .rx_runningdisp(rx_runningdisp[3]),
            .pll_powerdown(gxb_pwrdn_in_sig[3]),
            .pll_locked(pll_locked_3) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_3.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_3.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_3.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 12,
        the_altera_tse_gxb_gige_inst_3.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_3 = {17{1'b0}};
    assign led_char_err_gx[3] = 1'b0;
    assign link_status[3] = 1'b0;
    assign led_disp_err_3 = 1'b0;
    assign txp_3 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 4 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_4,gxb_pwrdn_in_sig_clk_4;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 4)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_4)
        begin
          if (gxb_pwrdn_in_4 == 1) begin
              data_in_4 <= 1;
              gxb_pwrdn_in_sig_clk_4 <= 1;
          end else begin
            data_in_4 <= 1'b0;
            gxb_pwrdn_in_sig_clk_4 <= data_in_4;
          end   
        end
        assign gxb_pwrdn_in_sig[4] = gxb_pwrdn_in_4;
        assign pcs_pwrdn_out_4 = pcs_pwrdn_out_sig[4];
    end
else
    begin
        assign gxb_pwrdn_in_sig[4] = pcs_pwrdn_out_sig[4];
        assign pcs_pwrdn_out_4 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_4 = gxb_pwrdn_in_sig[4];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 4)
    begin  
        wire    locked_signal_4;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_4(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_4),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_4),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_4),// output
            .rx_analogreset(rx_analogreset_sqcnr_4),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_4),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_4),// output
            .pll_is_locked(locked_signal_4),
            .rx_is_lockedtodata(rx_freqlocked_4),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_4)
        );
        assign locked_signal_4 = (reset? 1'b0: pll_locked_4);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_4_reset_sync_0 (
            .clk(rx_pcs_clk_c4),
            .reset_in(rx_digitalreset_sqcnr_4),
            .reset_out(reset_rx_pcs_clk_c4_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_4
          (
            .clk(rx_pcs_clk_c4),
            .reset(reset_rx_pcs_clk_c4_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_4),
            .alt_sync(rx_syncstatus[4]),
            .alt_disperr(rx_disp_err[4]),
            .alt_ctrldetect(rx_kchar_4),
            .alt_errdetect(rx_char_err_gx[4]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[4]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[4]),
            .alt_runlengthviolation(rx_runlengthviolation[4]),
            .alt_patterndetect(rx_patterndetect[4]),
            .alt_runningdisp(rx_runningdisp[4]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_4),
            .altpcs_sync(link_status[4]),
            .altpcs_disperr(led_disp_err_4),
            .altpcs_ctrldetect(pcs_rx_kchar_4),
            .altpcs_errdetect(led_char_err_gx[4]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[4]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[4]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[4])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_4.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_4
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[4]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_4),
            .reconfig_clk(reconfig_clk_4),
            .reconfig_togxb(reconfig_togxb_4),
            .reconfig_fromgxb(reconfig_fromgxb_4),              
            .rx_analogreset (rx_analogreset_sqcnr_4),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_4),
            .rx_clkout (rx_pcs_clk_c4),
            .rx_datain (rxp_4),
            .rx_dataout (rx_frame_4),
            .rx_digitalreset (rx_digitalreset_sqcnr_4),
            .rx_disperr (rx_disp_err[4]),
            .rx_errdetect (rx_char_err_gx[4]),
            .rx_patterndetect (rx_patterndetect[4]),
            .rx_rlv (rx_runlengthviolation[4]),
            .rx_seriallpbken (sd_loopback_4),
            .rx_syncstatus (rx_syncstatus[4]),
            .tx_clkout (tx_pcs_clk_c4),
            .tx_ctrlenable (tx_kchar_4),
            .tx_datain (tx_frame_4),
            .rx_freqlocked (rx_freqlocked_4),
            .tx_dataout (txp_4),
            .tx_digitalreset (tx_digitalreset_sqcnr_4),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[4]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[4]),
            .rx_runningdisp(rx_runningdisp[4]),
            .pll_powerdown(gxb_pwrdn_in_sig[4]),
            .pll_locked(pll_locked_4) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_4.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_4.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_4.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 16,
        the_altera_tse_gxb_gige_inst_4.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_4 = {17{1'b0}};
    assign led_char_err_gx[4] = 1'b0;
    assign link_status[4] = 1'b0;
    assign led_disp_err_4 = 1'b0;
    assign txp_4 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 5 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_5,gxb_pwrdn_in_sig_clk_5;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 5)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_5)
        begin
          if (gxb_pwrdn_in_5 == 1) begin
              data_in_5 <= 1;
              gxb_pwrdn_in_sig_clk_5 <= 1;
          end else begin
            data_in_5 <= 1'b0;
            gxb_pwrdn_in_sig_clk_5 <= data_in_5;
          end   
        end
        assign gxb_pwrdn_in_sig[5] = gxb_pwrdn_in_5;
        assign pcs_pwrdn_out_5 = pcs_pwrdn_out_sig[5];
    end
else
    begin
        assign gxb_pwrdn_in_sig[5] = pcs_pwrdn_out_sig[5];
        assign pcs_pwrdn_out_5 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_5 = gxb_pwrdn_in_sig[5];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 5)
    begin  
        wire    locked_signal_5;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_5(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_5),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_5),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_5),// output
            .rx_analogreset(rx_analogreset_sqcnr_5),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_5),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_5),// output
            .pll_is_locked(locked_signal_5),
            .rx_is_lockedtodata(rx_freqlocked_5),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_5)
        );
        assign locked_signal_5 = (reset? 1'b0: pll_locked_5);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_5_reset_sync_0 (
            .clk(rx_pcs_clk_c5),
            .reset_in(rx_digitalreset_sqcnr_5),
            .reset_out(reset_rx_pcs_clk_c5_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_5
          (
            .clk(rx_pcs_clk_c5),
            .reset(reset_rx_pcs_clk_c5_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_5),
            .alt_sync(rx_syncstatus[5]),
            .alt_disperr(rx_disp_err[5]),
            .alt_ctrldetect(rx_kchar_5),
            .alt_errdetect(rx_char_err_gx[5]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[5]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[5]),
            .alt_runlengthviolation(rx_runlengthviolation[5]),
            .alt_patterndetect(rx_patterndetect[5]),
            .alt_runningdisp(rx_runningdisp[5]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_5),
            .altpcs_sync(link_status[5]),
            .altpcs_disperr(led_disp_err_5),
            .altpcs_ctrldetect(pcs_rx_kchar_5),
            .altpcs_errdetect(led_char_err_gx[5]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[5]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[5]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[5])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_5.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_5
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[5]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_5),
            .reconfig_clk(reconfig_clk_5),
            .reconfig_togxb(reconfig_togxb_5),
            .reconfig_fromgxb(reconfig_fromgxb_5),              
            .rx_analogreset (rx_analogreset_sqcnr_5),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_5),
            .rx_clkout (rx_pcs_clk_c5),
            .rx_datain (rxp_5),
            .rx_dataout (rx_frame_5),
            .rx_digitalreset (rx_digitalreset_sqcnr_5),
            .rx_disperr (rx_disp_err[5]),
            .rx_errdetect (rx_char_err_gx[5]),
            .rx_patterndetect (rx_patterndetect[5]),
            .rx_rlv (rx_runlengthviolation[5]),
            .rx_seriallpbken (sd_loopback_5),
            .rx_syncstatus (rx_syncstatus[5]),
            .tx_clkout (tx_pcs_clk_c5),
            .tx_ctrlenable (tx_kchar_5),
            .tx_datain (tx_frame_5),
            .rx_freqlocked (rx_freqlocked_5),
            .tx_dataout (txp_5),
            .tx_digitalreset (tx_digitalreset_sqcnr_5),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[5]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[5]),
            .rx_runningdisp(rx_runningdisp[5]),
            .pll_powerdown(gxb_pwrdn_in_sig[5]),
            .pll_locked(pll_locked_5) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_5.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_5.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_5.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 20,
        the_altera_tse_gxb_gige_inst_5.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_5 = {17{1'b0}};
    assign led_char_err_gx[5] = 1'b0;
    assign link_status[5] = 1'b0;
    assign led_disp_err_5 = 1'b0;
    assign txp_5 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 6 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_6,gxb_pwrdn_in_sig_clk_6;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 6)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_6)
        begin
          if (gxb_pwrdn_in_6 == 1) begin
              data_in_6 <= 1;
              gxb_pwrdn_in_sig_clk_6 <= 1;
          end else begin
            data_in_6 <= 1'b0;
            gxb_pwrdn_in_sig_clk_6 <= data_in_6;
          end   
        end
        assign gxb_pwrdn_in_sig[6] = gxb_pwrdn_in_6;
        assign pcs_pwrdn_out_6 = pcs_pwrdn_out_sig[6];
    end
else
    begin
        assign gxb_pwrdn_in_sig[6] = pcs_pwrdn_out_sig[6];
        assign pcs_pwrdn_out_6 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_6 = gxb_pwrdn_in_sig[6];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 6)
    begin  
        wire    locked_signal_6;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_6(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_6),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_6),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_6),// output
            .rx_analogreset(rx_analogreset_sqcnr_6),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_6),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_6),// output
            .pll_is_locked(locked_signal_6),
            .rx_is_lockedtodata(rx_freqlocked_6),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_6)
        );
        assign locked_signal_6 = (reset? 1'b0: pll_locked_6);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_6_reset_sync_0 (
            .clk(rx_pcs_clk_c6),
            .reset_in(rx_digitalreset_sqcnr_6),
            .reset_out(reset_rx_pcs_clk_c6_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_6
          (
            .clk(rx_pcs_clk_c6),
            .reset(reset_rx_pcs_clk_c6_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_6),
            .alt_sync(rx_syncstatus[6]),
            .alt_disperr(rx_disp_err[6]),
            .alt_ctrldetect(rx_kchar_6),
            .alt_errdetect(rx_char_err_gx[6]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[6]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[6]),
            .alt_runlengthviolation(rx_runlengthviolation[6]),
            .alt_patterndetect(rx_patterndetect[6]),
            .alt_runningdisp(rx_runningdisp[6]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_6),
            .altpcs_sync(link_status[6]),
            .altpcs_disperr(led_disp_err_6),
            .altpcs_ctrldetect(pcs_rx_kchar_6),
            .altpcs_errdetect(led_char_err_gx[6]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[6]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[6]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[6])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_6.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_6
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[6]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_6),
            .reconfig_clk(reconfig_clk_6),
            .reconfig_togxb(reconfig_togxb_6),
            .reconfig_fromgxb(reconfig_fromgxb_6),              
            .rx_analogreset (rx_analogreset_sqcnr_6),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_6),
            .rx_clkout (rx_pcs_clk_c6),
            .rx_datain (rxp_6),
            .rx_dataout (rx_frame_6),
            .rx_digitalreset (rx_digitalreset_sqcnr_6),
            .rx_disperr (rx_disp_err[6]),
            .rx_errdetect (rx_char_err_gx[6]),
            .rx_patterndetect (rx_patterndetect[6]),
            .rx_rlv (rx_runlengthviolation[6]),
            .rx_seriallpbken (sd_loopback_6),
            .rx_syncstatus (rx_syncstatus[6]),
            .tx_clkout (tx_pcs_clk_c6),
            .tx_ctrlenable (tx_kchar_6),
            .tx_datain (tx_frame_6),
            .rx_freqlocked (rx_freqlocked_6),
            .tx_dataout (txp_6),
            .tx_digitalreset (tx_digitalreset_sqcnr_6),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[6]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[6]),
            .rx_runningdisp(rx_runningdisp[6]),
            .pll_powerdown(gxb_pwrdn_in_sig[6]),
            .pll_locked(pll_locked_6) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_6.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_6.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_6.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 24,
        the_altera_tse_gxb_gige_inst_6.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_6 = {17{1'b0}};
    assign led_char_err_gx[6] = 1'b0;
    assign link_status[6] = 1'b0;
    assign led_disp_err_6 = 1'b0;
    assign txp_6 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 7 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_7,gxb_pwrdn_in_sig_clk_7;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 7)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_7)
        begin
          if (gxb_pwrdn_in_7 == 1) begin
              data_in_7 <= 1;
              gxb_pwrdn_in_sig_clk_7 <= 1;
          end else begin
            data_in_7 <= 1'b0;
            gxb_pwrdn_in_sig_clk_7 <= data_in_7;
          end   
        end
        assign gxb_pwrdn_in_sig[7] = gxb_pwrdn_in_7;
        assign pcs_pwrdn_out_7 = pcs_pwrdn_out_sig[7];
    end
else
    begin
        assign gxb_pwrdn_in_sig[7] = pcs_pwrdn_out_sig[7];
        assign pcs_pwrdn_out_7 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_7 = gxb_pwrdn_in_sig[7];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 7)
    begin  
        wire    locked_signal_7;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_7(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_7),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_7),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_7),// output
            .rx_analogreset(rx_analogreset_sqcnr_7),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_7),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_7),// output
            .pll_is_locked(locked_signal_7),
            .rx_is_lockedtodata(rx_freqlocked_7),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_7)
        );
        assign locked_signal_7 = (reset? 1'b0: pll_locked_7);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_7_reset_sync_0 (
            .clk(rx_pcs_clk_c7),
            .reset_in(rx_digitalreset_sqcnr_7),
            .reset_out(reset_rx_pcs_clk_c7_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_7
          (
            .clk(rx_pcs_clk_c7),
            .reset(reset_rx_pcs_clk_c7_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_7),
            .alt_sync(rx_syncstatus[7]),
            .alt_disperr(rx_disp_err[7]),
            .alt_ctrldetect(rx_kchar_7),
            .alt_errdetect(rx_char_err_gx[7]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[7]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[7]),
            .alt_runlengthviolation(rx_runlengthviolation[7]),
            .alt_patterndetect(rx_patterndetect[7]),
            .alt_runningdisp(rx_runningdisp[7]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_7),
            .altpcs_sync(link_status[7]),
            .altpcs_disperr(led_disp_err_7),
            .altpcs_ctrldetect(pcs_rx_kchar_7),
            .altpcs_errdetect(led_char_err_gx[7]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[7]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[7]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[7])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_7.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_7
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[7]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_7),
            .reconfig_clk(reconfig_clk_7),
            .reconfig_togxb(reconfig_togxb_7),
            .reconfig_fromgxb(reconfig_fromgxb_7),              
            .rx_analogreset (rx_analogreset_sqcnr_7),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_7),
            .rx_clkout (rx_pcs_clk_c7),
            .rx_datain (rxp_7),
            .rx_dataout (rx_frame_7),
            .rx_digitalreset (rx_digitalreset_sqcnr_7),
            .rx_disperr (rx_disp_err[7]),
            .rx_errdetect (rx_char_err_gx[7]),
            .rx_patterndetect (rx_patterndetect[7]),
            .rx_rlv (rx_runlengthviolation[7]),
            .rx_seriallpbken (sd_loopback_7),
            .rx_syncstatus (rx_syncstatus[7]),
            .tx_clkout (tx_pcs_clk_c7),
            .tx_ctrlenable (tx_kchar_7),
            .tx_datain (tx_frame_7),
            .rx_freqlocked (rx_freqlocked_7),
            .tx_dataout (txp_7),
            .tx_digitalreset (tx_digitalreset_sqcnr_7),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[7]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[7]),
            .rx_runningdisp(rx_runningdisp[7]),
            .pll_powerdown(gxb_pwrdn_in_sig[7]),
            .pll_locked(pll_locked_7) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_7.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_7.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_7.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 28,
        the_altera_tse_gxb_gige_inst_7.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_7 = {17{1'b0}};
    assign led_char_err_gx[7] = 1'b0;
    assign link_status[7] = 1'b0;
    assign led_disp_err_7 = 1'b0;
    assign txp_7 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 8 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_8,gxb_pwrdn_in_sig_clk_8;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 8)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_8)
        begin
          if (gxb_pwrdn_in_8 == 1) begin
              data_in_8 <= 1;
              gxb_pwrdn_in_sig_clk_8 <= 1;
          end else begin
            data_in_8 <= 1'b0;
            gxb_pwrdn_in_sig_clk_8 <= data_in_8;
          end   
        end
        assign gxb_pwrdn_in_sig[8] = gxb_pwrdn_in_8;
        assign pcs_pwrdn_out_8 = pcs_pwrdn_out_sig[8];
    end
else
    begin
        assign gxb_pwrdn_in_sig[8] = pcs_pwrdn_out_sig[8];
        assign pcs_pwrdn_out_8 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_8 = gxb_pwrdn_in_sig[8];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 8)
    begin  
        wire    locked_signal_8;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_8(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_8),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_8),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_8),// output
            .rx_analogreset(rx_analogreset_sqcnr_8),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_8),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_8),// output
            .pll_is_locked(locked_signal_8),
            .rx_is_lockedtodata(rx_freqlocked_8),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_8)
        );
        assign locked_signal_8 = (reset? 1'b0: pll_locked_8);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_8_reset_sync_0 (
            .clk(rx_pcs_clk_c8),
            .reset_in(rx_digitalreset_sqcnr_8),
            .reset_out(reset_rx_pcs_clk_c8_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_8
          (
            .clk(rx_pcs_clk_c8),
            .reset(reset_rx_pcs_clk_c8_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_8),
            .alt_sync(rx_syncstatus[8]),
            .alt_disperr(rx_disp_err[8]),
            .alt_ctrldetect(rx_kchar_8),
            .alt_errdetect(rx_char_err_gx[8]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[8]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[8]),
            .alt_runlengthviolation(rx_runlengthviolation[8]),
            .alt_patterndetect(rx_patterndetect[8]),
            .alt_runningdisp(rx_runningdisp[8]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_8),
            .altpcs_sync(link_status[8]),
            .altpcs_disperr(led_disp_err_8),
            .altpcs_ctrldetect(pcs_rx_kchar_8),
            .altpcs_errdetect(led_char_err_gx[8]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[8]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[8]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[8])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_8.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_8
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[8]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_8),
            .reconfig_clk(reconfig_clk_8),
            .reconfig_togxb(reconfig_togxb_8),
            .reconfig_fromgxb(reconfig_fromgxb_8),              
            .rx_analogreset (rx_analogreset_sqcnr_8),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_8),
            .rx_clkout (rx_pcs_clk_c8),
            .rx_datain (rxp_8),
            .rx_dataout (rx_frame_8),
            .rx_digitalreset (rx_digitalreset_sqcnr_8),
            .rx_disperr (rx_disp_err[8]),
            .rx_errdetect (rx_char_err_gx[8]),
            .rx_patterndetect (rx_patterndetect[8]),
            .rx_rlv (rx_runlengthviolation[8]),
            .rx_seriallpbken (sd_loopback_8),
            .rx_syncstatus (rx_syncstatus[8]),
            .tx_clkout (tx_pcs_clk_c8),
            .tx_ctrlenable (tx_kchar_8),
            .tx_datain (tx_frame_8),
            .rx_freqlocked (rx_freqlocked_8),
            .tx_dataout (txp_8),
            .tx_digitalreset (tx_digitalreset_sqcnr_8),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[8]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[8]),
            .rx_runningdisp(rx_runningdisp[8]),
            .pll_powerdown(gxb_pwrdn_in_sig[8]),
            .pll_locked(pll_locked_8) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_8.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_8.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_8.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 32,
        the_altera_tse_gxb_gige_inst_8.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_8 = {17{1'b0}};
    assign led_char_err_gx[8] = 1'b0;
    assign link_status[8] = 1'b0;
    assign led_disp_err_8 = 1'b0;
    assign txp_8 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 9 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_9,gxb_pwrdn_in_sig_clk_9;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 9)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_9)
        begin
          if (gxb_pwrdn_in_9 == 1) begin
              data_in_9 <= 1;
              gxb_pwrdn_in_sig_clk_9 <= 1;
          end else begin
            data_in_9 <= 1'b0;
            gxb_pwrdn_in_sig_clk_9 <= data_in_9;
          end   
        end
        assign gxb_pwrdn_in_sig[9] = gxb_pwrdn_in_9;
        assign pcs_pwrdn_out_9 = pcs_pwrdn_out_sig[9];
    end
else
    begin
        assign gxb_pwrdn_in_sig[9] = pcs_pwrdn_out_sig[9];
        assign pcs_pwrdn_out_9 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_9 = gxb_pwrdn_in_sig[9];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 9)
    begin  
        wire    locked_signal_9;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_9(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_9),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_9),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_9),// output
            .rx_analogreset(rx_analogreset_sqcnr_9),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_9),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_9),// output
            .pll_is_locked(locked_signal_9),
            .rx_is_lockedtodata(rx_freqlocked_9),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_9)
        );
        assign locked_signal_9 = (reset? 1'b0: pll_locked_9);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_9_reset_sync_0 (
            .clk(rx_pcs_clk_c9),
            .reset_in(rx_digitalreset_sqcnr_9),
            .reset_out(reset_rx_pcs_clk_c9_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_9
          (
            .clk(rx_pcs_clk_c9),
            .reset(reset_rx_pcs_clk_c9_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_9),
            .alt_sync(rx_syncstatus[9]),
            .alt_disperr(rx_disp_err[9]),
            .alt_ctrldetect(rx_kchar_9),
            .alt_errdetect(rx_char_err_gx[9]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[9]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[9]),
            .alt_runlengthviolation(rx_runlengthviolation[9]),
            .alt_patterndetect(rx_patterndetect[9]),
            .alt_runningdisp(rx_runningdisp[9]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_9),
            .altpcs_sync(link_status[9]),
            .altpcs_disperr(led_disp_err_9),
            .altpcs_ctrldetect(pcs_rx_kchar_9),
            .altpcs_errdetect(led_char_err_gx[9]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[9]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[9]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[9])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_9.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_9
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[9]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_9),
            .reconfig_clk(reconfig_clk_9),
            .reconfig_togxb(reconfig_togxb_9),
            .reconfig_fromgxb(reconfig_fromgxb_9),              
            .rx_analogreset (rx_analogreset_sqcnr_9),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_9),
            .rx_clkout (rx_pcs_clk_c9),
            .rx_datain (rxp_9),
            .rx_dataout (rx_frame_9),
            .rx_digitalreset (rx_digitalreset_sqcnr_9),
            .rx_disperr (rx_disp_err[9]),
            .rx_errdetect (rx_char_err_gx[9]),
            .rx_patterndetect (rx_patterndetect[9]),
            .rx_rlv (rx_runlengthviolation[9]),
            .rx_seriallpbken (sd_loopback_9),
            .rx_syncstatus (rx_syncstatus[9]),
            .tx_clkout (tx_pcs_clk_c9),
            .tx_ctrlenable (tx_kchar_9),
            .tx_datain (tx_frame_9),
            .rx_freqlocked (rx_freqlocked_9),
            .tx_dataout (txp_9),
            .tx_digitalreset (tx_digitalreset_sqcnr_9),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[9]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[9]),
            .rx_runningdisp(rx_runningdisp[9]),
            .pll_powerdown(gxb_pwrdn_in_sig[9]),
            .pll_locked(pll_locked_9) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_9.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_9.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_9.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 36,
        the_altera_tse_gxb_gige_inst_9.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_9 = {17{1'b0}};
    assign led_char_err_gx[9] = 1'b0;
    assign link_status[9] = 1'b0;
    assign led_disp_err_9 = 1'b0;
    assign txp_9 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 10 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_10,gxb_pwrdn_in_sig_clk_10;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 10)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_10)
        begin
          if (gxb_pwrdn_in_10 == 1) begin
              data_in_10 <= 1;
              gxb_pwrdn_in_sig_clk_10 <= 1;
          end else begin
            data_in_10 <= 1'b0;
            gxb_pwrdn_in_sig_clk_10 <= data_in_10;
          end   
        end
        assign gxb_pwrdn_in_sig[10] = gxb_pwrdn_in_10;
        assign pcs_pwrdn_out_10 = pcs_pwrdn_out_sig[10];
    end
else
    begin
        assign gxb_pwrdn_in_sig[10] = pcs_pwrdn_out_sig[10];
        assign pcs_pwrdn_out_10 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_10 = gxb_pwrdn_in_sig[10];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 10)
    begin  
        wire    locked_signal_10;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_10(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_10),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_10),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_10),// output
            .rx_analogreset(rx_analogreset_sqcnr_10),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_10),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_10),// output
            .pll_is_locked(locked_signal_10),
            .rx_is_lockedtodata(rx_freqlocked_10),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_10)
        );
        assign locked_signal_10 = (reset? 1'b0: pll_locked_10);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_10_reset_sync_0 (
            .clk(rx_pcs_clk_c10),
            .reset_in(rx_digitalreset_sqcnr_10),
            .reset_out(reset_rx_pcs_clk_c10_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_10
          (
            .clk(rx_pcs_clk_c10),
            .reset(reset_rx_pcs_clk_c10_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_10),
            .alt_sync(rx_syncstatus[10]),
            .alt_disperr(rx_disp_err[10]),
            .alt_ctrldetect(rx_kchar_10),
            .alt_errdetect(rx_char_err_gx[10]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[10]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[10]),
            .alt_runlengthviolation(rx_runlengthviolation[10]),
            .alt_patterndetect(rx_patterndetect[10]),
            .alt_runningdisp(rx_runningdisp[10]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_10),
            .altpcs_sync(link_status[10]),
            .altpcs_disperr(led_disp_err_10),
            .altpcs_ctrldetect(pcs_rx_kchar_10),
            .altpcs_errdetect(led_char_err_gx[10]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[10]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[10]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[10])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_10.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_10
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[10]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_10),
            .reconfig_clk(reconfig_clk_10),
            .reconfig_togxb(reconfig_togxb_10),
            .reconfig_fromgxb(reconfig_fromgxb_10),              
            .rx_analogreset (rx_analogreset_sqcnr_10),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_10),
            .rx_clkout (rx_pcs_clk_c10),
            .rx_datain (rxp_10),
            .rx_dataout (rx_frame_10),
            .rx_digitalreset (rx_digitalreset_sqcnr_10),
            .rx_disperr (rx_disp_err[10]),
            .rx_errdetect (rx_char_err_gx[10]),
            .rx_patterndetect (rx_patterndetect[10]),
            .rx_rlv (rx_runlengthviolation[10]),
            .rx_seriallpbken (sd_loopback_10),
            .rx_syncstatus (rx_syncstatus[10]),
            .tx_clkout (tx_pcs_clk_c10),
            .tx_ctrlenable (tx_kchar_10),
            .tx_datain (tx_frame_10),
            .rx_freqlocked (rx_freqlocked_10),
            .tx_dataout (txp_10),
            .tx_digitalreset (tx_digitalreset_sqcnr_10),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[10]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[10]),
            .rx_runningdisp(rx_runningdisp[10]),
            .pll_powerdown(gxb_pwrdn_in_sig[10]),
            .pll_locked(pll_locked_10) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_10.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_10.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_10.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 40,
        the_altera_tse_gxb_gige_inst_10.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_10 = {17{1'b0}};
    assign led_char_err_gx[10] = 1'b0;
    assign link_status[10] = 1'b0;
    assign led_disp_err_10 = 1'b0;
    assign txp_10 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 11 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_11,gxb_pwrdn_in_sig_clk_11;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 11)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_11)
        begin
          if (gxb_pwrdn_in_11 == 1) begin
              data_in_11 <= 1;
              gxb_pwrdn_in_sig_clk_11 <= 1;
          end else begin
            data_in_11 <= 1'b0;
            gxb_pwrdn_in_sig_clk_11 <= data_in_11;
          end   
        end
        assign gxb_pwrdn_in_sig[11] = gxb_pwrdn_in_11;
        assign pcs_pwrdn_out_11 = pcs_pwrdn_out_sig[11];
    end
else
    begin
        assign gxb_pwrdn_in_sig[11] = pcs_pwrdn_out_sig[11];
        assign pcs_pwrdn_out_11 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_11 = gxb_pwrdn_in_sig[11];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 11)
    begin  
        wire    locked_signal_11;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_11(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_11),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_11),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_11),// output
            .rx_analogreset(rx_analogreset_sqcnr_11),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_11),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_11),// output
            .pll_is_locked(locked_signal_11),
            .rx_is_lockedtodata(rx_freqlocked_11),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_11)
        );
        assign locked_signal_11 = (reset? 1'b0: pll_locked_11);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_11_reset_sync_0 (
            .clk(rx_pcs_clk_c11),
            .reset_in(rx_digitalreset_sqcnr_11),
            .reset_out(reset_rx_pcs_clk_c11_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_11
          (
            .clk(rx_pcs_clk_c11),
            .reset(reset_rx_pcs_clk_c11_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_11),
            .alt_sync(rx_syncstatus[11]),
            .alt_disperr(rx_disp_err[11]),
            .alt_ctrldetect(rx_kchar_11),
            .alt_errdetect(rx_char_err_gx[11]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[11]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[11]),
            .alt_runlengthviolation(rx_runlengthviolation[11]),
            .alt_patterndetect(rx_patterndetect[11]),
            .alt_runningdisp(rx_runningdisp[11]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_11),
            .altpcs_sync(link_status[11]),
            .altpcs_disperr(led_disp_err_11),
            .altpcs_ctrldetect(pcs_rx_kchar_11),
            .altpcs_errdetect(led_char_err_gx[11]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[11]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[11]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[11])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_11.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_11
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[11]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_11),
            .reconfig_clk(reconfig_clk_11),
            .reconfig_togxb(reconfig_togxb_11),
            .reconfig_fromgxb(reconfig_fromgxb_11),              
            .rx_analogreset (rx_analogreset_sqcnr_11),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_11),
            .rx_clkout (rx_pcs_clk_c11),
            .rx_datain (rxp_11),
            .rx_dataout (rx_frame_11),
            .rx_digitalreset (rx_digitalreset_sqcnr_11),
            .rx_disperr (rx_disp_err[11]),
            .rx_errdetect (rx_char_err_gx[11]),
            .rx_patterndetect (rx_patterndetect[11]),
            .rx_rlv (rx_runlengthviolation[11]),
            .rx_seriallpbken (sd_loopback_11),
            .rx_syncstatus (rx_syncstatus[11]),
            .tx_clkout (tx_pcs_clk_c11),
            .tx_ctrlenable (tx_kchar_11),
            .tx_datain (tx_frame_11),
            .rx_freqlocked (rx_freqlocked_11),
            .tx_dataout (txp_11),
            .tx_digitalreset (tx_digitalreset_sqcnr_11),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[11]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[11]),
            .rx_runningdisp(rx_runningdisp[11]),
            .pll_powerdown(gxb_pwrdn_in_sig[11]),
            .pll_locked(pll_locked_11) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_11.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_11.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_11.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 44,
        the_altera_tse_gxb_gige_inst_11.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_11 = {17{1'b0}};
    assign led_char_err_gx[11] = 1'b0;
    assign link_status[11] = 1'b0;
    assign led_disp_err_11 = 1'b0;
    assign txp_11 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 12 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_12,gxb_pwrdn_in_sig_clk_12;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 12)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_12)
        begin
          if (gxb_pwrdn_in_12 == 1) begin
              data_in_12 <= 1;
              gxb_pwrdn_in_sig_clk_12 <= 1;
          end else begin
            data_in_12 <= 1'b0;
            gxb_pwrdn_in_sig_clk_12 <= data_in_12;
          end   
        end
        assign gxb_pwrdn_in_sig[12] = gxb_pwrdn_in_12;
        assign pcs_pwrdn_out_12 = pcs_pwrdn_out_sig[12];
    end
else
    begin
        assign gxb_pwrdn_in_sig[12] = pcs_pwrdn_out_sig[12];
        assign pcs_pwrdn_out_12 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_12 = gxb_pwrdn_in_sig[12];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 12)
    begin  
        wire    locked_signal_12;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_12(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_12),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_12),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_12),// output
            .rx_analogreset(rx_analogreset_sqcnr_12),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_12),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_12),// output
            .pll_is_locked(locked_signal_12),
            .rx_is_lockedtodata(rx_freqlocked_12),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_12)
        );
        assign locked_signal_12 = (reset? 1'b0: pll_locked_12);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_12_reset_sync_0 (
            .clk(rx_pcs_clk_c12),
            .reset_in(rx_digitalreset_sqcnr_12),
            .reset_out(reset_rx_pcs_clk_c12_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_12
          (
            .clk(rx_pcs_clk_c12),
            .reset(reset_rx_pcs_clk_c12_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_12),
            .alt_sync(rx_syncstatus[12]),
            .alt_disperr(rx_disp_err[12]),
            .alt_ctrldetect(rx_kchar_12),
            .alt_errdetect(rx_char_err_gx[12]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[12]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[12]),
            .alt_runlengthviolation(rx_runlengthviolation[12]),
            .alt_patterndetect(rx_patterndetect[12]),
            .alt_runningdisp(rx_runningdisp[12]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_12),
            .altpcs_sync(link_status[12]),
            .altpcs_disperr(led_disp_err_12),
            .altpcs_ctrldetect(pcs_rx_kchar_12),
            .altpcs_errdetect(led_char_err_gx[12]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[12]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[12]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[12])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_12.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_12
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[12]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_12),
            .reconfig_clk(reconfig_clk_12),
            .reconfig_togxb(reconfig_togxb_12),
            .reconfig_fromgxb(reconfig_fromgxb_12),              
            .rx_analogreset (rx_analogreset_sqcnr_12),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_12),
            .rx_clkout (rx_pcs_clk_c12),
            .rx_datain (rxp_12),
            .rx_dataout (rx_frame_12),
            .rx_digitalreset (rx_digitalreset_sqcnr_12),
            .rx_disperr (rx_disp_err[12]),
            .rx_errdetect (rx_char_err_gx[12]),
            .rx_patterndetect (rx_patterndetect[12]),
            .rx_rlv (rx_runlengthviolation[12]),
            .rx_seriallpbken (sd_loopback_12),
            .rx_syncstatus (rx_syncstatus[12]),
            .tx_clkout (tx_pcs_clk_c12),
            .tx_ctrlenable (tx_kchar_12),
            .tx_datain (tx_frame_12),
            .rx_freqlocked (rx_freqlocked_12),
            .tx_dataout (txp_12),
            .tx_digitalreset (tx_digitalreset_sqcnr_12),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[12]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[12]),
            .rx_runningdisp(rx_runningdisp[12]),
            .pll_powerdown(gxb_pwrdn_in_sig[12]),
            .pll_locked(pll_locked_12) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_12.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_12.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_12.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 48,
        the_altera_tse_gxb_gige_inst_12.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_12 = {17{1'b0}};
    assign led_char_err_gx[12] = 1'b0;
    assign link_status[12] = 1'b0;
    assign led_disp_err_12 = 1'b0;
    assign txp_12 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 13 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_13,gxb_pwrdn_in_sig_clk_13;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 13)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_13)
        begin
          if (gxb_pwrdn_in_13 == 1) begin
              data_in_13 <= 1;
              gxb_pwrdn_in_sig_clk_13 <= 1;
          end else begin
            data_in_13 <= 1'b0;
            gxb_pwrdn_in_sig_clk_13 <= data_in_13;
          end   
        end
        assign gxb_pwrdn_in_sig[13] = gxb_pwrdn_in_13;
        assign pcs_pwrdn_out_13 = pcs_pwrdn_out_sig[13];
    end
else
    begin
        assign gxb_pwrdn_in_sig[13] = pcs_pwrdn_out_sig[13];
        assign pcs_pwrdn_out_13 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_13 = gxb_pwrdn_in_sig[13];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 13)
    begin  
        wire    locked_signal_13;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_13(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_13),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_13),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_13),// output
            .rx_analogreset(rx_analogreset_sqcnr_13),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_13),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_13),// output
            .pll_is_locked(locked_signal_13),
            .rx_is_lockedtodata(rx_freqlocked_13),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_13)
        );
        assign locked_signal_13 = (reset? 1'b0: pll_locked_13);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_13_reset_sync_0 (
            .clk(rx_pcs_clk_c13),
            .reset_in(rx_digitalreset_sqcnr_13),
            .reset_out(reset_rx_pcs_clk_c13_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_13
          (
            .clk(rx_pcs_clk_c13),
            .reset(reset_rx_pcs_clk_c13_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_13),
            .alt_sync(rx_syncstatus[13]),
            .alt_disperr(rx_disp_err[13]),
            .alt_ctrldetect(rx_kchar_13),
            .alt_errdetect(rx_char_err_gx[13]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[13]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[13]),
            .alt_runlengthviolation(rx_runlengthviolation[13]),
            .alt_patterndetect(rx_patterndetect[13]),
            .alt_runningdisp(rx_runningdisp[13]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_13),
            .altpcs_sync(link_status[13]),
            .altpcs_disperr(led_disp_err_13),
            .altpcs_ctrldetect(pcs_rx_kchar_13),
            .altpcs_errdetect(led_char_err_gx[13]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[13]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[13]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[13])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_13.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_13
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[13]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_13),
            .reconfig_clk(reconfig_clk_13),
            .reconfig_togxb(reconfig_togxb_13),
            .reconfig_fromgxb(reconfig_fromgxb_13),              
            .rx_analogreset (rx_analogreset_sqcnr_13),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_13),
            .rx_clkout (rx_pcs_clk_c13),
            .rx_datain (rxp_13),
            .rx_dataout (rx_frame_13),
            .rx_digitalreset (rx_digitalreset_sqcnr_13),
            .rx_disperr (rx_disp_err[13]),
            .rx_errdetect (rx_char_err_gx[13]),
            .rx_patterndetect (rx_patterndetect[13]),
            .rx_rlv (rx_runlengthviolation[13]),
            .rx_seriallpbken (sd_loopback_13),
            .rx_syncstatus (rx_syncstatus[13]),
            .tx_clkout (tx_pcs_clk_c13),
            .tx_ctrlenable (tx_kchar_13),
            .tx_datain (tx_frame_13),
            .rx_freqlocked (rx_freqlocked_13),
            .tx_dataout (txp_13),
            .tx_digitalreset (tx_digitalreset_sqcnr_13),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[13]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[13]),
            .rx_runningdisp(rx_runningdisp[13]),
            .pll_powerdown(gxb_pwrdn_in_sig[13]),
            .pll_locked(pll_locked_13) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_13.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_13.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_13.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 52,
        the_altera_tse_gxb_gige_inst_13.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_13 = {17{1'b0}};
    assign led_char_err_gx[13] = 1'b0;
    assign link_status[13] = 1'b0;
    assign led_disp_err_13 = 1'b0;
    assign txp_13 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 14 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_14,gxb_pwrdn_in_sig_clk_14;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 14)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_14)
        begin
          if (gxb_pwrdn_in_14 == 1) begin
              data_in_14 <= 1;
              gxb_pwrdn_in_sig_clk_14 <= 1;
          end else begin
            data_in_14 <= 1'b0;
            gxb_pwrdn_in_sig_clk_14 <= data_in_14;
          end   
        end
        assign gxb_pwrdn_in_sig[14] = gxb_pwrdn_in_14;
        assign pcs_pwrdn_out_14 = pcs_pwrdn_out_sig[14];
    end
else
    begin
        assign gxb_pwrdn_in_sig[14] = pcs_pwrdn_out_sig[14];
        assign pcs_pwrdn_out_14 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_14 = gxb_pwrdn_in_sig[14];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 14)
    begin  
        wire    locked_signal_14;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_14(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_14),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_14),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_14),// output
            .rx_analogreset(rx_analogreset_sqcnr_14),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_14),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_14),// output
            .pll_is_locked(locked_signal_14),
            .rx_is_lockedtodata(rx_freqlocked_14),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_14)
        );
        assign locked_signal_14 = (reset? 1'b0: pll_locked_14);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_14_reset_sync_0 (
            .clk(rx_pcs_clk_c14),
            .reset_in(rx_digitalreset_sqcnr_14),
            .reset_out(reset_rx_pcs_clk_c14_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_14
          (
            .clk(rx_pcs_clk_c14),
            .reset(reset_rx_pcs_clk_c14_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_14),
            .alt_sync(rx_syncstatus[14]),
            .alt_disperr(rx_disp_err[14]),
            .alt_ctrldetect(rx_kchar_14),
            .alt_errdetect(rx_char_err_gx[14]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[14]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[14]),
            .alt_runlengthviolation(rx_runlengthviolation[14]),
            .alt_patterndetect(rx_patterndetect[14]),
            .alt_runningdisp(rx_runningdisp[14]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_14),
            .altpcs_sync(link_status[14]),
            .altpcs_disperr(led_disp_err_14),
            .altpcs_ctrldetect(pcs_rx_kchar_14),
            .altpcs_errdetect(led_char_err_gx[14]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[14]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[14]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[14])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_14.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_14
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[14]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_14),
            .reconfig_clk(reconfig_clk_14),
            .reconfig_togxb(reconfig_togxb_14),
            .reconfig_fromgxb(reconfig_fromgxb_14),              
            .rx_analogreset (rx_analogreset_sqcnr_14),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_14),
            .rx_clkout (rx_pcs_clk_c14),
            .rx_datain (rxp_14),
            .rx_dataout (rx_frame_14),
            .rx_digitalreset (rx_digitalreset_sqcnr_14),
            .rx_disperr (rx_disp_err[14]),
            .rx_errdetect (rx_char_err_gx[14]),
            .rx_patterndetect (rx_patterndetect[14]),
            .rx_rlv (rx_runlengthviolation[14]),
            .rx_seriallpbken (sd_loopback_14),
            .rx_syncstatus (rx_syncstatus[14]),
            .tx_clkout (tx_pcs_clk_c14),
            .tx_ctrlenable (tx_kchar_14),
            .tx_datain (tx_frame_14),
            .rx_freqlocked (rx_freqlocked_14),
            .tx_dataout (txp_14),
            .tx_digitalreset (tx_digitalreset_sqcnr_14),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[14]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[14]),
            .rx_runningdisp(rx_runningdisp[14]),
            .pll_powerdown(gxb_pwrdn_in_sig[14]),
            .pll_locked(pll_locked_14) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_14.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_14.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_14.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 56,
        the_altera_tse_gxb_gige_inst_14.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_14 = {17{1'b0}};
    assign led_char_err_gx[14] = 1'b0;
    assign link_status[14] = 1'b0;
    assign led_disp_err_14 = 1'b0;
    assign txp_14 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 15 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_15,gxb_pwrdn_in_sig_clk_15;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 15)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_15)
        begin
          if (gxb_pwrdn_in_15 == 1) begin
              data_in_15 <= 1;
              gxb_pwrdn_in_sig_clk_15 <= 1;
          end else begin
            data_in_15 <= 1'b0;
            gxb_pwrdn_in_sig_clk_15 <= data_in_15;
          end   
        end
        assign gxb_pwrdn_in_sig[15] = gxb_pwrdn_in_15;
        assign pcs_pwrdn_out_15 = pcs_pwrdn_out_sig[15];
    end
else
    begin
        assign gxb_pwrdn_in_sig[15] = pcs_pwrdn_out_sig[15];
        assign pcs_pwrdn_out_15 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_15 = gxb_pwrdn_in_sig[15];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 15)
    begin  
        wire    locked_signal_15;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_15(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_15),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_15),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_15),// output
            .rx_analogreset(rx_analogreset_sqcnr_15),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_15),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_15),// output
            .pll_is_locked(locked_signal_15),
            .rx_is_lockedtodata(rx_freqlocked_15),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_15)
        );
        assign locked_signal_15 = (reset? 1'b0: pll_locked_15);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_15_reset_sync_0 (
            .clk(rx_pcs_clk_c15),
            .reset_in(rx_digitalreset_sqcnr_15),
            .reset_out(reset_rx_pcs_clk_c15_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_15
          (
            .clk(rx_pcs_clk_c15),
            .reset(reset_rx_pcs_clk_c15_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_15),
            .alt_sync(rx_syncstatus[15]),
            .alt_disperr(rx_disp_err[15]),
            .alt_ctrldetect(rx_kchar_15),
            .alt_errdetect(rx_char_err_gx[15]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[15]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[15]),
            .alt_runlengthviolation(rx_runlengthviolation[15]),
            .alt_patterndetect(rx_patterndetect[15]),
            .alt_runningdisp(rx_runningdisp[15]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_15),
            .altpcs_sync(link_status[15]),
            .altpcs_disperr(led_disp_err_15),
            .altpcs_ctrldetect(pcs_rx_kchar_15),
            .altpcs_errdetect(led_char_err_gx[15]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[15]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[15]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[15])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_15.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_15
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[15]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_15),
            .reconfig_clk(reconfig_clk_15),
            .reconfig_togxb(reconfig_togxb_15),
            .reconfig_fromgxb(reconfig_fromgxb_15),              
            .rx_analogreset (rx_analogreset_sqcnr_15),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_15),
            .rx_clkout (rx_pcs_clk_c15),
            .rx_datain (rxp_15),
            .rx_dataout (rx_frame_15),
            .rx_digitalreset (rx_digitalreset_sqcnr_15),
            .rx_disperr (rx_disp_err[15]),
            .rx_errdetect (rx_char_err_gx[15]),
            .rx_patterndetect (rx_patterndetect[15]),
            .rx_rlv (rx_runlengthviolation[15]),
            .rx_seriallpbken (sd_loopback_15),
            .rx_syncstatus (rx_syncstatus[15]),
            .tx_clkout (tx_pcs_clk_c15),
            .tx_ctrlenable (tx_kchar_15),
            .tx_datain (tx_frame_15),
            .rx_freqlocked (rx_freqlocked_15),
            .tx_dataout (txp_15),
            .tx_digitalreset (tx_digitalreset_sqcnr_15),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[15]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[15]),
            .rx_runningdisp(rx_runningdisp[15]),
            .pll_powerdown(gxb_pwrdn_in_sig[15]),
            .pll_locked(pll_locked_15) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_15.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_15.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_15.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 60,
        the_altera_tse_gxb_gige_inst_15.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_15 = {17{1'b0}};
    assign led_char_err_gx[15] = 1'b0;
    assign link_status[15] = 1'b0;
    assign led_disp_err_15 = 1'b0;
    assign txp_15 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 16 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_16,gxb_pwrdn_in_sig_clk_16;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 16)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_16)
        begin
          if (gxb_pwrdn_in_16 == 1) begin
              data_in_16 <= 1;
              gxb_pwrdn_in_sig_clk_16 <= 1;
          end else begin
            data_in_16 <= 1'b0;
            gxb_pwrdn_in_sig_clk_16 <= data_in_16;
          end   
        end
        assign gxb_pwrdn_in_sig[16] = gxb_pwrdn_in_16;
        assign pcs_pwrdn_out_16 = pcs_pwrdn_out_sig[16];
    end
else
    begin
        assign gxb_pwrdn_in_sig[16] = pcs_pwrdn_out_sig[16];
        assign pcs_pwrdn_out_16 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_16 = gxb_pwrdn_in_sig[16];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 16)
    begin  
        wire    locked_signal_16;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_16(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_16),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_16),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_16),// output
            .rx_analogreset(rx_analogreset_sqcnr_16),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_16),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_16),// output
            .pll_is_locked(locked_signal_16),
            .rx_is_lockedtodata(rx_freqlocked_16),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_16)
        );
        assign locked_signal_16 = (reset? 1'b0: pll_locked_16);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_16_reset_sync_0 (
            .clk(rx_pcs_clk_c16),
            .reset_in(rx_digitalreset_sqcnr_16),
            .reset_out(reset_rx_pcs_clk_c16_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_16
          (
            .clk(rx_pcs_clk_c16),
            .reset(reset_rx_pcs_clk_c16_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_16),
            .alt_sync(rx_syncstatus[16]),
            .alt_disperr(rx_disp_err[16]),
            .alt_ctrldetect(rx_kchar_16),
            .alt_errdetect(rx_char_err_gx[16]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[16]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[16]),
            .alt_runlengthviolation(rx_runlengthviolation[16]),
            .alt_patterndetect(rx_patterndetect[16]),
            .alt_runningdisp(rx_runningdisp[16]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_16),
            .altpcs_sync(link_status[16]),
            .altpcs_disperr(led_disp_err_16),
            .altpcs_ctrldetect(pcs_rx_kchar_16),
            .altpcs_errdetect(led_char_err_gx[16]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[16]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[16]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[16])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_16.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_16
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[16]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_16),
            .reconfig_clk(reconfig_clk_16),
            .reconfig_togxb(reconfig_togxb_16),
            .reconfig_fromgxb(reconfig_fromgxb_16),              
            .rx_analogreset (rx_analogreset_sqcnr_16),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_16),
            .rx_clkout (rx_pcs_clk_c16),
            .rx_datain (rxp_16),
            .rx_dataout (rx_frame_16),
            .rx_digitalreset (rx_digitalreset_sqcnr_16),
            .rx_disperr (rx_disp_err[16]),
            .rx_errdetect (rx_char_err_gx[16]),
            .rx_patterndetect (rx_patterndetect[16]),
            .rx_rlv (rx_runlengthviolation[16]),
            .rx_seriallpbken (sd_loopback_16),
            .rx_syncstatus (rx_syncstatus[16]),
            .tx_clkout (tx_pcs_clk_c16),
            .tx_ctrlenable (tx_kchar_16),
            .tx_datain (tx_frame_16),
            .rx_freqlocked (rx_freqlocked_16),
            .tx_dataout (txp_16),
            .tx_digitalreset (tx_digitalreset_sqcnr_16),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[16]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[16]),
            .rx_runningdisp(rx_runningdisp[16]),
            .pll_powerdown(gxb_pwrdn_in_sig[16]),
            .pll_locked(pll_locked_16) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_16.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_16.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_16.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 64,
        the_altera_tse_gxb_gige_inst_16.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_16 = {17{1'b0}};
    assign led_char_err_gx[16] = 1'b0;
    assign link_status[16] = 1'b0;
    assign led_disp_err_16 = 1'b0;
    assign txp_16 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 17 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_17,gxb_pwrdn_in_sig_clk_17;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 17)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_17)
        begin
          if (gxb_pwrdn_in_17 == 1) begin
              data_in_17 <= 1;
              gxb_pwrdn_in_sig_clk_17 <= 1;
          end else begin
            data_in_17 <= 1'b0;
            gxb_pwrdn_in_sig_clk_17 <= data_in_17;
          end   
        end
        assign gxb_pwrdn_in_sig[17] = gxb_pwrdn_in_17;
        assign pcs_pwrdn_out_17 = pcs_pwrdn_out_sig[17];
    end
else
    begin
        assign gxb_pwrdn_in_sig[17] = pcs_pwrdn_out_sig[17];
        assign pcs_pwrdn_out_17 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_17 = gxb_pwrdn_in_sig[17];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 17)
    begin  
        wire    locked_signal_17;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_17(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_17),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_17),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_17),// output
            .rx_analogreset(rx_analogreset_sqcnr_17),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_17),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_17),// output
            .pll_is_locked(locked_signal_17),
            .rx_is_lockedtodata(rx_freqlocked_17),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_17)
        );
        assign locked_signal_17 = (reset? 1'b0: pll_locked_17);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_17_reset_sync_0 (
            .clk(rx_pcs_clk_c17),
            .reset_in(rx_digitalreset_sqcnr_17),
            .reset_out(reset_rx_pcs_clk_c17_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_17
          (
            .clk(rx_pcs_clk_c17),
            .reset(reset_rx_pcs_clk_c17_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_17),
            .alt_sync(rx_syncstatus[17]),
            .alt_disperr(rx_disp_err[17]),
            .alt_ctrldetect(rx_kchar_17),
            .alt_errdetect(rx_char_err_gx[17]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[17]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[17]),
            .alt_runlengthviolation(rx_runlengthviolation[17]),
            .alt_patterndetect(rx_patterndetect[17]),
            .alt_runningdisp(rx_runningdisp[17]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_17),
            .altpcs_sync(link_status[17]),
            .altpcs_disperr(led_disp_err_17),
            .altpcs_ctrldetect(pcs_rx_kchar_17),
            .altpcs_errdetect(led_char_err_gx[17]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[17]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[17]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[17])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_17.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_17
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[17]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_17),
            .reconfig_clk(reconfig_clk_17),
            .reconfig_togxb(reconfig_togxb_17),
            .reconfig_fromgxb(reconfig_fromgxb_17),              
            .rx_analogreset (rx_analogreset_sqcnr_17),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_17),
            .rx_clkout (rx_pcs_clk_c17),
            .rx_datain (rxp_17),
            .rx_dataout (rx_frame_17),
            .rx_digitalreset (rx_digitalreset_sqcnr_17),
            .rx_disperr (rx_disp_err[17]),
            .rx_errdetect (rx_char_err_gx[17]),
            .rx_patterndetect (rx_patterndetect[17]),
            .rx_rlv (rx_runlengthviolation[17]),
            .rx_seriallpbken (sd_loopback_17),
            .rx_syncstatus (rx_syncstatus[17]),
            .tx_clkout (tx_pcs_clk_c17),
            .tx_ctrlenable (tx_kchar_17),
            .tx_datain (tx_frame_17),
            .rx_freqlocked (rx_freqlocked_17),
            .tx_dataout (txp_17),
            .tx_digitalreset (tx_digitalreset_sqcnr_17),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[17]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[17]),
            .rx_runningdisp(rx_runningdisp[17]),
            .pll_powerdown(gxb_pwrdn_in_sig[17]),
            .pll_locked(pll_locked_17) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_17.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_17.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_17.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 68,
        the_altera_tse_gxb_gige_inst_17.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_17 = {17{1'b0}};
    assign led_char_err_gx[17] = 1'b0;
    assign link_status[17] = 1'b0;
    assign led_disp_err_17 = 1'b0;
    assign txp_17 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 18 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_18,gxb_pwrdn_in_sig_clk_18;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 18)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_18)
        begin
          if (gxb_pwrdn_in_18 == 1) begin
              data_in_18 <= 1;
              gxb_pwrdn_in_sig_clk_18 <= 1;
          end else begin
            data_in_18 <= 1'b0;
            gxb_pwrdn_in_sig_clk_18 <= data_in_18;
          end   
        end
        assign gxb_pwrdn_in_sig[18] = gxb_pwrdn_in_18;
        assign pcs_pwrdn_out_18 = pcs_pwrdn_out_sig[18];
    end
else
    begin
        assign gxb_pwrdn_in_sig[18] = pcs_pwrdn_out_sig[18];
        assign pcs_pwrdn_out_18 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_18 = gxb_pwrdn_in_sig[18];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 18)
    begin  
        wire    locked_signal_18;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_18(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_18),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_18),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_18),// output
            .rx_analogreset(rx_analogreset_sqcnr_18),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_18),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_18),// output
            .pll_is_locked(locked_signal_18),
            .rx_is_lockedtodata(rx_freqlocked_18),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_18)
        );
        assign locked_signal_18 = (reset? 1'b0: pll_locked_18);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_18_reset_sync_0 (
            .clk(rx_pcs_clk_c18),
            .reset_in(rx_digitalreset_sqcnr_18),
            .reset_out(reset_rx_pcs_clk_c18_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_18
          (
            .clk(rx_pcs_clk_c18),
            .reset(reset_rx_pcs_clk_c18_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_18),
            .alt_sync(rx_syncstatus[18]),
            .alt_disperr(rx_disp_err[18]),
            .alt_ctrldetect(rx_kchar_18),
            .alt_errdetect(rx_char_err_gx[18]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[18]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[18]),
            .alt_runlengthviolation(rx_runlengthviolation[18]),
            .alt_patterndetect(rx_patterndetect[18]),
            .alt_runningdisp(rx_runningdisp[18]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_18),
            .altpcs_sync(link_status[18]),
            .altpcs_disperr(led_disp_err_18),
            .altpcs_ctrldetect(pcs_rx_kchar_18),
            .altpcs_errdetect(led_char_err_gx[18]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[18]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[18]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[18])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_18.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_18
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[18]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_18),
            .reconfig_clk(reconfig_clk_18),
            .reconfig_togxb(reconfig_togxb_18),
            .reconfig_fromgxb(reconfig_fromgxb_18),              
            .rx_analogreset (rx_analogreset_sqcnr_18),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_18),
            .rx_clkout (rx_pcs_clk_c18),
            .rx_datain (rxp_18),
            .rx_dataout (rx_frame_18),
            .rx_digitalreset (rx_digitalreset_sqcnr_18),
            .rx_disperr (rx_disp_err[18]),
            .rx_errdetect (rx_char_err_gx[18]),
            .rx_patterndetect (rx_patterndetect[18]),
            .rx_rlv (rx_runlengthviolation[18]),
            .rx_seriallpbken (sd_loopback_18),
            .rx_syncstatus (rx_syncstatus[18]),
            .tx_clkout (tx_pcs_clk_c18),
            .tx_ctrlenable (tx_kchar_18),
            .tx_datain (tx_frame_18),
            .rx_freqlocked (rx_freqlocked_18),
            .tx_dataout (txp_18),
            .tx_digitalreset (tx_digitalreset_sqcnr_18),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[18]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[18]),
            .rx_runningdisp(rx_runningdisp[18]),
            .pll_powerdown(gxb_pwrdn_in_sig[18]),
            .pll_locked(pll_locked_18) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_18.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_18.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_18.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 72,
        the_altera_tse_gxb_gige_inst_18.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_18 = {17{1'b0}};
    assign led_char_err_gx[18] = 1'b0;
    assign link_status[18] = 1'b0;
    assign led_disp_err_18 = 1'b0;
    assign txp_18 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 19 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_19,gxb_pwrdn_in_sig_clk_19;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 19)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_19)
        begin
          if (gxb_pwrdn_in_19 == 1) begin
              data_in_19 <= 1;
              gxb_pwrdn_in_sig_clk_19 <= 1;
          end else begin
            data_in_19 <= 1'b0;
            gxb_pwrdn_in_sig_clk_19 <= data_in_19;
          end   
        end
        assign gxb_pwrdn_in_sig[19] = gxb_pwrdn_in_19;
        assign pcs_pwrdn_out_19 = pcs_pwrdn_out_sig[19];
    end
else
    begin
        assign gxb_pwrdn_in_sig[19] = pcs_pwrdn_out_sig[19];
        assign pcs_pwrdn_out_19 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_19 = gxb_pwrdn_in_sig[19];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 19)
    begin  
        wire    locked_signal_19;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_19(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_19),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_19),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_19),// output
            .rx_analogreset(rx_analogreset_sqcnr_19),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_19),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_19),// output
            .pll_is_locked(locked_signal_19),
            .rx_is_lockedtodata(rx_freqlocked_19),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_19)
        );
        assign locked_signal_19 = (reset? 1'b0: pll_locked_19);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_19_reset_sync_0 (
            .clk(rx_pcs_clk_c19),
            .reset_in(rx_digitalreset_sqcnr_19),
            .reset_out(reset_rx_pcs_clk_c19_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_19
          (
            .clk(rx_pcs_clk_c19),
            .reset(reset_rx_pcs_clk_c19_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_19),
            .alt_sync(rx_syncstatus[19]),
            .alt_disperr(rx_disp_err[19]),
            .alt_ctrldetect(rx_kchar_19),
            .alt_errdetect(rx_char_err_gx[19]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[19]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[19]),
            .alt_runlengthviolation(rx_runlengthviolation[19]),
            .alt_patterndetect(rx_patterndetect[19]),
            .alt_runningdisp(rx_runningdisp[19]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_19),
            .altpcs_sync(link_status[19]),
            .altpcs_disperr(led_disp_err_19),
            .altpcs_ctrldetect(pcs_rx_kchar_19),
            .altpcs_errdetect(led_char_err_gx[19]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[19]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[19]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[19])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_19.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_19
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[19]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_19),
            .reconfig_clk(reconfig_clk_19),
            .reconfig_togxb(reconfig_togxb_19),
            .reconfig_fromgxb(reconfig_fromgxb_19),              
            .rx_analogreset (rx_analogreset_sqcnr_19),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_19),
            .rx_clkout (rx_pcs_clk_c19),
            .rx_datain (rxp_19),
            .rx_dataout (rx_frame_19),
            .rx_digitalreset (rx_digitalreset_sqcnr_19),
            .rx_disperr (rx_disp_err[19]),
            .rx_errdetect (rx_char_err_gx[19]),
            .rx_patterndetect (rx_patterndetect[19]),
            .rx_rlv (rx_runlengthviolation[19]),
            .rx_seriallpbken (sd_loopback_19),
            .rx_syncstatus (rx_syncstatus[19]),
            .tx_clkout (tx_pcs_clk_c19),
            .tx_ctrlenable (tx_kchar_19),
            .tx_datain (tx_frame_19),
            .rx_freqlocked (rx_freqlocked_19),
            .tx_dataout (txp_19),
            .tx_digitalreset (tx_digitalreset_sqcnr_19),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[19]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[19]),
            .rx_runningdisp(rx_runningdisp[19]),
            .pll_powerdown(gxb_pwrdn_in_sig[19]),
            .pll_locked(pll_locked_19) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_19.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_19.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_19.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 76,
        the_altera_tse_gxb_gige_inst_19.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_19 = {17{1'b0}};
    assign led_char_err_gx[19] = 1'b0;
    assign link_status[19] = 1'b0;
    assign led_disp_err_19 = 1'b0;
    assign txp_19 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 20 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_20,gxb_pwrdn_in_sig_clk_20;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 20)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_20)
        begin
          if (gxb_pwrdn_in_20 == 1) begin
              data_in_20 <= 1;
              gxb_pwrdn_in_sig_clk_20 <= 1;
          end else begin
            data_in_20 <= 1'b0;
            gxb_pwrdn_in_sig_clk_20 <= data_in_20;
          end   
        end
        assign gxb_pwrdn_in_sig[20] = gxb_pwrdn_in_20;
        assign pcs_pwrdn_out_20 = pcs_pwrdn_out_sig[20];
    end
else
    begin
        assign gxb_pwrdn_in_sig[20] = pcs_pwrdn_out_sig[20];
        assign pcs_pwrdn_out_20 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_20 = gxb_pwrdn_in_sig[20];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 20)
    begin  
        wire    locked_signal_20;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_20(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_20),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_20),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_20),// output
            .rx_analogreset(rx_analogreset_sqcnr_20),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_20),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_20),// output
            .pll_is_locked(locked_signal_20),
            .rx_is_lockedtodata(rx_freqlocked_20),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_20)
        );
        assign locked_signal_20 = (reset? 1'b0: pll_locked_20);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_20_reset_sync_0 (
            .clk(rx_pcs_clk_c20),
            .reset_in(rx_digitalreset_sqcnr_20),
            .reset_out(reset_rx_pcs_clk_c20_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_20
          (
            .clk(rx_pcs_clk_c20),
            .reset(reset_rx_pcs_clk_c20_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_20),
            .alt_sync(rx_syncstatus[20]),
            .alt_disperr(rx_disp_err[20]),
            .alt_ctrldetect(rx_kchar_20),
            .alt_errdetect(rx_char_err_gx[20]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[20]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[20]),
            .alt_runlengthviolation(rx_runlengthviolation[20]),
            .alt_patterndetect(rx_patterndetect[20]),
            .alt_runningdisp(rx_runningdisp[20]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_20),
            .altpcs_sync(link_status[20]),
            .altpcs_disperr(led_disp_err_20),
            .altpcs_ctrldetect(pcs_rx_kchar_20),
            .altpcs_errdetect(led_char_err_gx[20]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[20]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[20]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[20])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_20.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_20
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[20]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_20),
            .reconfig_clk(reconfig_clk_20),
            .reconfig_togxb(reconfig_togxb_20),
            .reconfig_fromgxb(reconfig_fromgxb_20),              
            .rx_analogreset (rx_analogreset_sqcnr_20),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_20),
            .rx_clkout (rx_pcs_clk_c20),
            .rx_datain (rxp_20),
            .rx_dataout (rx_frame_20),
            .rx_digitalreset (rx_digitalreset_sqcnr_20),
            .rx_disperr (rx_disp_err[20]),
            .rx_errdetect (rx_char_err_gx[20]),
            .rx_patterndetect (rx_patterndetect[20]),
            .rx_rlv (rx_runlengthviolation[20]),
            .rx_seriallpbken (sd_loopback_20),
            .rx_syncstatus (rx_syncstatus[20]),
            .tx_clkout (tx_pcs_clk_c20),
            .tx_ctrlenable (tx_kchar_20),
            .tx_datain (tx_frame_20),
            .rx_freqlocked (rx_freqlocked_20),
            .tx_dataout (txp_20),
            .tx_digitalreset (tx_digitalreset_sqcnr_20),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[20]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[20]),
            .rx_runningdisp(rx_runningdisp[20]),
            .pll_powerdown(gxb_pwrdn_in_sig[20]),
            .pll_locked(pll_locked_20) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_20.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_20.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_20.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 80,
        the_altera_tse_gxb_gige_inst_20.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_20 = {17{1'b0}};
    assign led_char_err_gx[20] = 1'b0;
    assign link_status[20] = 1'b0;
    assign led_disp_err_20 = 1'b0;
    assign txp_20 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 21 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_21,gxb_pwrdn_in_sig_clk_21;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 21)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_21)
        begin
          if (gxb_pwrdn_in_21 == 1) begin
              data_in_21 <= 1;
              gxb_pwrdn_in_sig_clk_21 <= 1;
          end else begin
            data_in_21 <= 1'b0;
            gxb_pwrdn_in_sig_clk_21 <= data_in_21;
          end   
        end
        assign gxb_pwrdn_in_sig[21] = gxb_pwrdn_in_21;
        assign pcs_pwrdn_out_21 = pcs_pwrdn_out_sig[21];
    end
else
    begin
        assign gxb_pwrdn_in_sig[21] = pcs_pwrdn_out_sig[21];
        assign pcs_pwrdn_out_21 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_21 = gxb_pwrdn_in_sig[21];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 21)
    begin  
        wire    locked_signal_21;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_21(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_21),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_21),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_21),// output
            .rx_analogreset(rx_analogreset_sqcnr_21),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_21),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_21),// output
            .pll_is_locked(locked_signal_21),
            .rx_is_lockedtodata(rx_freqlocked_21),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_21)
        );
        assign locked_signal_21 = (reset? 1'b0: pll_locked_21);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_21_reset_sync_0 (
            .clk(rx_pcs_clk_c21),
            .reset_in(rx_digitalreset_sqcnr_21),
            .reset_out(reset_rx_pcs_clk_c21_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_21
          (
            .clk(rx_pcs_clk_c21),
            .reset(reset_rx_pcs_clk_c21_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_21),
            .alt_sync(rx_syncstatus[21]),
            .alt_disperr(rx_disp_err[21]),
            .alt_ctrldetect(rx_kchar_21),
            .alt_errdetect(rx_char_err_gx[21]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[21]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[21]),
            .alt_runlengthviolation(rx_runlengthviolation[21]),
            .alt_patterndetect(rx_patterndetect[21]),
            .alt_runningdisp(rx_runningdisp[21]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_21),
            .altpcs_sync(link_status[21]),
            .altpcs_disperr(led_disp_err_21),
            .altpcs_ctrldetect(pcs_rx_kchar_21),
            .altpcs_errdetect(led_char_err_gx[21]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[21]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[21]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[21])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_21.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_21
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[21]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_21),
            .reconfig_clk(reconfig_clk_21),
            .reconfig_togxb(reconfig_togxb_21),
            .reconfig_fromgxb(reconfig_fromgxb_21),              
            .rx_analogreset (rx_analogreset_sqcnr_21),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_21),
            .rx_clkout (rx_pcs_clk_c21),
            .rx_datain (rxp_21),
            .rx_dataout (rx_frame_21),
            .rx_digitalreset (rx_digitalreset_sqcnr_21),
            .rx_disperr (rx_disp_err[21]),
            .rx_errdetect (rx_char_err_gx[21]),
            .rx_patterndetect (rx_patterndetect[21]),
            .rx_rlv (rx_runlengthviolation[21]),
            .rx_seriallpbken (sd_loopback_21),
            .rx_syncstatus (rx_syncstatus[21]),
            .tx_clkout (tx_pcs_clk_c21),
            .tx_ctrlenable (tx_kchar_21),
            .tx_datain (tx_frame_21),
            .rx_freqlocked (rx_freqlocked_21),
            .tx_dataout (txp_21),
            .tx_digitalreset (tx_digitalreset_sqcnr_21),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[21]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[21]),
            .rx_runningdisp(rx_runningdisp[21]),
            .pll_powerdown(gxb_pwrdn_in_sig[21]),
            .pll_locked(pll_locked_21) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_21.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_21.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_21.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 84,
        the_altera_tse_gxb_gige_inst_21.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_21 = {17{1'b0}};
    assign led_char_err_gx[21] = 1'b0;
    assign link_status[21] = 1'b0;
    assign led_disp_err_21 = 1'b0;
    assign txp_21 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 22 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_22,gxb_pwrdn_in_sig_clk_22;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 22)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_22)
        begin
          if (gxb_pwrdn_in_22 == 1) begin
              data_in_22 <= 1;
              gxb_pwrdn_in_sig_clk_22 <= 1;
          end else begin
            data_in_22 <= 1'b0;
            gxb_pwrdn_in_sig_clk_22 <= data_in_22;
          end   
        end
        assign gxb_pwrdn_in_sig[22] = gxb_pwrdn_in_22;
        assign pcs_pwrdn_out_22 = pcs_pwrdn_out_sig[22];
    end
else
    begin
        assign gxb_pwrdn_in_sig[22] = pcs_pwrdn_out_sig[22];
        assign pcs_pwrdn_out_22 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_22 = gxb_pwrdn_in_sig[22];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 22)
    begin  
        wire    locked_signal_22;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_22(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_22),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_22),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_22),// output
            .rx_analogreset(rx_analogreset_sqcnr_22),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_22),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_22),// output
            .pll_is_locked(locked_signal_22),
            .rx_is_lockedtodata(rx_freqlocked_22),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_22)
        );
        assign locked_signal_22 = (reset? 1'b0: pll_locked_22);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_22_reset_sync_0 (
            .clk(rx_pcs_clk_c22),
            .reset_in(rx_digitalreset_sqcnr_22),
            .reset_out(reset_rx_pcs_clk_c22_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_22
          (
            .clk(rx_pcs_clk_c22),
            .reset(reset_rx_pcs_clk_c22_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_22),
            .alt_sync(rx_syncstatus[22]),
            .alt_disperr(rx_disp_err[22]),
            .alt_ctrldetect(rx_kchar_22),
            .alt_errdetect(rx_char_err_gx[22]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[22]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[22]),
            .alt_runlengthviolation(rx_runlengthviolation[22]),
            .alt_patterndetect(rx_patterndetect[22]),
            .alt_runningdisp(rx_runningdisp[22]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_22),
            .altpcs_sync(link_status[22]),
            .altpcs_disperr(led_disp_err_22),
            .altpcs_ctrldetect(pcs_rx_kchar_22),
            .altpcs_errdetect(led_char_err_gx[22]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[22]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[22]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[22])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_22.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_22
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[22]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_22),
            .reconfig_clk(reconfig_clk_22),
            .reconfig_togxb(reconfig_togxb_22),
            .reconfig_fromgxb(reconfig_fromgxb_22),              
            .rx_analogreset (rx_analogreset_sqcnr_22),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_22),
            .rx_clkout (rx_pcs_clk_c22),
            .rx_datain (rxp_22),
            .rx_dataout (rx_frame_22),
            .rx_digitalreset (rx_digitalreset_sqcnr_22),
            .rx_disperr (rx_disp_err[22]),
            .rx_errdetect (rx_char_err_gx[22]),
            .rx_patterndetect (rx_patterndetect[22]),
            .rx_rlv (rx_runlengthviolation[22]),
            .rx_seriallpbken (sd_loopback_22),
            .rx_syncstatus (rx_syncstatus[22]),
            .tx_clkout (tx_pcs_clk_c22),
            .tx_ctrlenable (tx_kchar_22),
            .tx_datain (tx_frame_22),
            .rx_freqlocked (rx_freqlocked_22),
            .tx_dataout (txp_22),
            .tx_digitalreset (tx_digitalreset_sqcnr_22),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[22]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[22]),
            .rx_runningdisp(rx_runningdisp[22]),
            .pll_powerdown(gxb_pwrdn_in_sig[22]),
            .pll_locked(pll_locked_22) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_22.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_22.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_22.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 88,
        the_altera_tse_gxb_gige_inst_22.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_22 = {17{1'b0}};
    assign led_char_err_gx[22] = 1'b0;
    assign link_status[22] = 1'b0;
    assign led_disp_err_22 = 1'b0;
    assign txp_22 = 1'b0;
    end      
endgenerate



// #######################################################################
// ###############       CHANNEL 23 LOGIC/COMPONENTS       ###############
// #######################################################################

// Export powerdown signal or wire it internally
// ---------------------------------------------
reg data_in_23,gxb_pwrdn_in_sig_clk_23;
generate if (EXPORT_PWRDN == 1 && MAX_CHANNELS > 23)
    begin        
        always @(posedge clk or posedge gxb_pwrdn_in_23)
        begin
          if (gxb_pwrdn_in_23 == 1) begin
              data_in_23 <= 1;
              gxb_pwrdn_in_sig_clk_23 <= 1;
          end else begin
            data_in_23 <= 1'b0;
            gxb_pwrdn_in_sig_clk_23 <= data_in_23;
          end   
        end
        assign gxb_pwrdn_in_sig[23] = gxb_pwrdn_in_23;
        assign pcs_pwrdn_out_23 = pcs_pwrdn_out_sig[23];
    end
else
    begin
        assign gxb_pwrdn_in_sig[23] = pcs_pwrdn_out_sig[23];
        assign pcs_pwrdn_out_23 = 1'b0;
        always@(*) begin
            gxb_pwrdn_in_sig_clk_23 = gxb_pwrdn_in_sig[23];
        end      
    end
endgenerate


generate if (MAX_CHANNELS > 23)
    begin  
        wire    locked_signal_23;
    //  ALTGX Reset Sequencer
        altera_tse_reset_sequencer altera_tse_reset_sequencer_inst_23(
            // User inputs and outputs
            .clock(clk),
            .reset_all(reset_start | gxb_pwrdn_in_sig_clk_23),
            //.reset_tx_digital(reset_ref_clk),
            //.reset_rx_digital(reset_ref_clk),
            .powerdown_all(reset_sync),
            .tx_ready(), // output
            .rx_ready(), // output
            // I/O transceiver and status
            .pll_powerdown(pll_powerdown_sqcnr_23),// output
            .tx_digitalreset(tx_digitalreset_sqcnr_23),// output
            .rx_analogreset(rx_analogreset_sqcnr_23),// output
            .rx_digitalreset(rx_digitalreset_sqcnr_23),// output
            .gxb_powerdown(gxb_powerdown_sqcnr_23),// output
            .pll_is_locked(locked_signal_23),
            .rx_is_lockedtodata(rx_freqlocked_23),
            .manual_mode(1'b0),
            .rx_oc_busy(reconfig_busy_23)
        );
        assign locked_signal_23 = (reset? 1'b0: pll_locked_23);
    // Instantiation of the Alt2gxb and Alt4gxb block as the PMA for Stratix_II_GX ,ArriaGX and Stratix IV devices
    // ----------------------------------------------------------------------------------- 
    

        // Aligned Rx_sync from gxb
        // -------------------------------
        altera_tse_reset_synchronizer ch_23_reset_sync_0 (
            .clk(rx_pcs_clk_c23),
            .reset_in(rx_digitalreset_sqcnr_23),
            .reset_out(reset_rx_pcs_clk_c23_int)
        );

        altera_tse_gxb_aligned_rxsync the_altera_tse_gxb_aligned_rxsync_23
          (
            .clk(rx_pcs_clk_c23),
            .reset(reset_rx_pcs_clk_c23_int),
            //input (from alt2gxb)
            .alt_dataout(rx_frame_23),
            .alt_sync(rx_syncstatus[23]),
            .alt_disperr(rx_disp_err[23]),
            .alt_ctrldetect(rx_kchar_23),
            .alt_errdetect(rx_char_err_gx[23]),
            .alt_rmfifodatadeleted(rx_rmfifodatadeleted[23]),
            .alt_rmfifodatainserted(rx_rmfifodatainserted[23]),
            .alt_runlengthviolation(rx_runlengthviolation[23]),
            .alt_patterndetect(rx_patterndetect[23]),
            .alt_runningdisp(rx_runningdisp[23]),
    
            //output (to PCS)
            .altpcs_dataout(pcs_rx_frame_23),
            .altpcs_sync(link_status[23]),
            .altpcs_disperr(led_disp_err_23),
            .altpcs_ctrldetect(pcs_rx_kchar_23),
            .altpcs_errdetect(led_char_err_gx[23]),
            .altpcs_rmfifodatadeleted(pcs_rx_rmfifodatadeleted[23]),
            .altpcs_rmfifodatainserted(pcs_rx_rmfifodatainserted[23]),
            .altpcs_carrierdetect(pcs_rx_carrierdetected[23])
           ) ;
                defparam
                the_altera_tse_gxb_aligned_rxsync_23.DEVICE_FAMILY = DEVICE_FAMILY;    

        // Altgxb in GIGE mode
        // --------------------
        altera_tse_gxb_gige_inst the_altera_tse_gxb_gige_inst_23
          (
            .cal_blk_clk (gxb_cal_blk_clk),
            .gxb_powerdown (gxb_pwrdn_in_sig[23]),
            .pll_inclk (ref_clk),
            .rx_recovclkout(rx_recovclkout_23),
            .reconfig_clk(reconfig_clk_23),
            .reconfig_togxb(reconfig_togxb_23),
            .reconfig_fromgxb(reconfig_fromgxb_23),              
            .rx_analogreset (rx_analogreset_sqcnr_23),
            .rx_cruclk (ref_clk),
            .rx_ctrldetect (rx_kchar_23),
            .rx_clkout (rx_pcs_clk_c23),
            .rx_datain (rxp_23),
            .rx_dataout (rx_frame_23),
            .rx_digitalreset (rx_digitalreset_sqcnr_23),
            .rx_disperr (rx_disp_err[23]),
            .rx_errdetect (rx_char_err_gx[23]),
            .rx_patterndetect (rx_patterndetect[23]),
            .rx_rlv (rx_runlengthviolation[23]),
            .rx_seriallpbken (sd_loopback_23),
            .rx_syncstatus (rx_syncstatus[23]),
            .tx_clkout (tx_pcs_clk_c23),
            .tx_ctrlenable (tx_kchar_23),
            .tx_datain (tx_frame_23),
            .rx_freqlocked (rx_freqlocked_23),
            .tx_dataout (txp_23),
            .tx_digitalreset (tx_digitalreset_sqcnr_23),
            .rx_rmfifodatadeleted(rx_rmfifodatadeleted[23]),
            .rx_rmfifodatainserted(rx_rmfifodatainserted[23]),
            .rx_runningdisp(rx_runningdisp[23]),
            .pll_powerdown(gxb_pwrdn_in_sig[23]),
            .pll_locked(pll_locked_23) 
          );
   defparam
        the_altera_tse_gxb_gige_inst_23.ENABLE_ALT_RECONFIG = ENABLE_ALT_RECONFIG,
        the_altera_tse_gxb_gige_inst_23.ENABLE_SGMII = ENABLE_SGMII,
        the_altera_tse_gxb_gige_inst_23.STARTING_CHANNEL_NUMBER = STARTING_CHANNEL_NUMBER + 92,
        the_altera_tse_gxb_gige_inst_23.DEVICE_FAMILY = DEVICE_FAMILY; 
    end
else
    begin
    assign reconfig_fromgxb_23 = {17{1'b0}};
    assign led_char_err_gx[23] = 1'b0;
    assign link_status[23] = 1'b0;
    assign led_disp_err_23 = 1'b0;
    assign txp_23 = 1'b0;
    end      
endgenerate



    endmodule // module altera_tse_multi_mac_pcs_pma_gige
