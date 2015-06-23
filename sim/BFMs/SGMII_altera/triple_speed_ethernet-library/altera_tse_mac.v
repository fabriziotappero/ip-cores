// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_mac.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/Top_level_modules/altera_tse_mac.v,v $
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
// Top level module for Triple Speed Ethernet MAC

// 
// ALTERA Confidential and Proprietary
// Copyright 2006 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

(*altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION OFF" } *)
module altera_tse_mac /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"R102,R105,D102,D101,D103\"" */(

    clk,                       // Avalon slave - clock
    read,                      // Avalon slave - read
    write,                     // Avalon slave - write
    address,                   // Avalon slave - address
    writedata,                 // Avalon slave - writedata
    readdata,                  // Avalon slave - readdata
    waitrequest,               // Avalon slave - waitrequest
    reset,                     // Avalon slave - reset
    reset_rx_clk,              
    reset_tx_clk,
    reset_ff_rx_clk,
    reset_ff_tx_clk,
    ff_rx_clk,                 // AtlanticII source - clk  
    ff_rx_data,                // AtlanticII source - data 
    ff_rx_mod,                 // Will not exists in SoPC Model as the 8-bit version is used
    ff_rx_sop,                 // AtlanticII source - startofpacket
    ff_rx_eop,                 // AtlanticII source - endofpacket
    rx_err,                    // AtlanticII source - error 
    rx_err_stat,               // AtlanticII source - component_specific_signal(eop)
    rx_frm_type,               // AtlanticII source - component_specific_signal(data)
    ff_rx_rdy,                 // AtlanticII source - ready
    ff_rx_dval,                // AtlanticII source - valid
    ff_rx_dsav,                // AtlanticII source - component_specific_signal(data)
    ff_tx_clk,                 // AtlanticII sink - clk
    ff_tx_data,                // AtlanticII sink - data
    ff_tx_mod,                 // Will not exists in SoPC Model as the 8-bit version is used
    ff_tx_sop,                 // AtlanticII sink - startofpacket
    ff_tx_eop,                 // AtlanticII sink - endofpacket
    ff_tx_err,                 // AtlanticII sink - error
    ff_tx_wren,                // AtlanticII sink - valid
    ff_tx_crc_fwd,             // AtlanticII sink - component_specific_signal(eop)
    ff_tx_rdy,                 // AtlanticII sink - ready
    ff_tx_septy,               // AtlanticII source - component_specific_signal(data)
    tx_ff_uflow,               // AtlanticII source - component_specific_signal(data)
    ff_rx_a_full,
    ff_rx_a_empty,
    ff_tx_a_full,
    ff_tx_a_empty,
    xoff_gen,
    xon_gen,
    magic_sleep_n,
    magic_wakeup,
    rx_clk,
    tx_clk,
    gm_rx_d,
    gm_rx_dv,
    gm_rx_err,
    gm_tx_d,
    gm_tx_en,
    gm_tx_err,
    m_rx_d,
    m_rx_en,
    m_rx_err,
    m_tx_d,
    m_tx_en,
    m_tx_err,
    m_rx_crs,
    m_rx_col,   
    eth_mode,
    ena_10,
    set_10,
    set_1000,
    mdc,
    mdio_in,
    mdio_out,
    mdio_oen,    
    tx_control,
    rx_control,
    rgmii_in,
    rgmii_out
);

parameter ENABLE_ENA            = 8;            //  Enable n-Bit Local Interface
parameter ENABLE_GMII_LOOPBACK  = 1;            //  GMII_LOOPBACK_ENA : Enable GMII Loopback Logic 
parameter ENABLE_HD_LOGIC       = 1;            //  HD_LOGIC_ENA : Enable Half Duplex Logic
parameter USE_SYNC_RESET        = 1;            //  Use Synchronized Reset Inputs
parameter ENABLE_SUP_ADDR       = 1;        //  SUP_ADDR_ENA : Enable Supplemental Addresses
parameter ENA_HASH              = 1;            //  ENA_HASH Enable Hash Table 
parameter STAT_CNT_ENA          = 1;            //  STAT_CNT_ENA Enable Statistic Counters
parameter ENABLE_EXTENDED_STAT_REG = 0;         //  Enable a few extended statistic registers
parameter EG_FIFO               = 256 ;         //  Egress FIFO Depth
parameter EG_ADDR               = 8 ;           //  Egress FIFO Depth
parameter ING_FIFO              = 256 ;         //  Ingress FIFO Depth
parameter ING_ADDR              = 8 ;           //  Egress FIFO Depth
parameter RESET_LEVEL           = 1'b 1 ;       //  Reset Active Level
parameter MDIO_CLK_DIV          = 40 ;          //  Host Clock Division - MDC Generation
parameter CORE_VERSION          = 16'h3;        //  ALTERA Core Version
parameter CUST_VERSION          = 1 ;           //  Customer Core Version
parameter REDUCED_INTERFACE_ENA = 1;            //  Enable the RGMII Interface
parameter ENABLE_MDIO           = 1;            //  Enable the MDIO Interface
parameter ENABLE_MAGIC_DETECT   = 1;            //  Enable magic packet detection
parameter ENABLE_MIN_FIFO       = 1;            //  Enable minimun FIFO (Reduced functionality)
parameter ENABLE_MACLITE        = 0;            //  Enable MAC LITE operation
parameter MACLITE_GIGE          = 0;            //  Enable/Disable Gigabit MAC operation for MAC LITE.
parameter CRC32DWIDTH           = 4'b 1000;     //  input data width (informal, not for change)
parameter CRC32GENDELAY         = 3'b 110;      //  when the data from the generator is valid
parameter CRC32CHECK16BIT       = 1'b 0;        //  1 compare two times 16 bit of the CRC (adds one pipeline step) 
parameter CRC32S1L2_EXTERN      = 1'b0;         //  false: merge enable
parameter ENABLE_SHIFT16        = 0;            //  Enable byte stuffing at packet header 
parameter RAM_TYPE              = "AUTO";       //  Specify the RAM type 
parameter INSERT_TA             = 0;            //  Option to insert timing adapter for SOPC systems
parameter ENABLE_MAC_FLOW_CTRL  = 1'b1;         //  Option to enable flow control 
parameter ENABLE_MAC_TXADDR_SET = 1'b1;         //  Option to enable MAC address insertion onto 'to-be-transmitted' Ethernet frames on MAC TX data path
parameter ENABLE_MAC_RX_VLAN    = 1'b1;         //  Option to enable VLAN tagged Ethernet frames on MAC RX data path
parameter ENABLE_MAC_TX_VLAN    = 1'b1;         //  Option to enable VLAN tagged Ethernet frames on MAC TX data path
parameter SYNCHRONIZER_DEPTH 	= 3;	  	//  Number of synchronizer


input   clk;                    //  25MHz Host Interface Clock
input   read;                   //  Register Read Strobe
input   write;                  //  Register Write Strobe
input   [7:0] address;          //  Register Address
input   [31:0] writedata;       //  Write Data for Host Bus
output  [31:0] readdata;        //  Read Data to Host Bus
output  waitrequest;            //  Interface Busy
input   reset;                  //  Asynchronous Reset
input   reset_rx_clk;           //  Asynchronous Reset - rx_clk Domain
input   reset_tx_clk;           //  Asynchronous Reset - tx_clk Domain
input   reset_ff_rx_clk;        //  Asynchronous Reset - ff_rx_clk Domain
input   reset_ff_tx_clk;        //  Asynchronous Reset - ff_tx_clk Domain
input   ff_rx_clk;              //  Transmit Local Clock
output  [ENABLE_ENA-1:0] ff_rx_data;      //  Data Out
output  [1:0] ff_rx_mod;        //  Data Modulo
output  ff_rx_sop;              //  Start of Packet
output  ff_rx_eop;              //  End of Packet
output  [5:0] rx_err;           //  Errored Packet Indication
output  [17:0] rx_err_stat;     //  Packet Length and Status Word
output  [3:0] rx_frm_type;      //  Unicast Frame Indication    
input   ff_rx_rdy;              //  PHY Application Ready
output  ff_rx_dval;             //  Data Valid Strobe
output  ff_rx_dsav;             //  Data Available
input   ff_tx_clk;              //  Transmit Local Clock    
input   [ENABLE_ENA-1:0] ff_tx_data;      //  Data Out
input   [1:0] ff_tx_mod;        //  Data Modulo
input   ff_tx_sop;              //  Start of Packet
input   ff_tx_eop;              //  End of Packet
input   ff_tx_err;              //  Errored Packet
input   ff_tx_wren;             //  Write Enable
input   ff_tx_crc_fwd;          //  Forward Current Frame with CRC from Application
output  ff_tx_rdy;              //  FIFO Ready
output  ff_tx_septy;            //  FIFO has space for at least one section
output  tx_ff_uflow;            //  TX FIFO underflow occured (Synchronous with tx_clk) 
output  ff_rx_a_full;           //  Receive FIFO Almost Full
output  ff_rx_a_empty;          //  Receive FIFO Almost Empty
output  ff_tx_a_full;           //  Transmit FIFO Almost Full
output  ff_tx_a_empty;          //  Transmit FIFO Almost Empty
input   xoff_gen;               //  Xoff Pause frame generate 
input   xon_gen;                //  Xon Pause frame generate 
input   magic_sleep_n;          //  Enable Sleep Mode
output  magic_wakeup;           //  Wake Up Request
input   rx_clk;                 //  Receive Clock
input   tx_clk;                 //  Transmit Clock                
input   [7:0] gm_rx_d;          //  GMII Receive Data
input   gm_rx_dv;               //  GMII Receive Frame Enable  
input   gm_rx_err;              //  GMII Receive Frame Error  
output  [7:0] gm_tx_d;          //  GMII Transmit Data
output  gm_tx_en;               //  GMII Transmit Frame Enable  
output  gm_tx_err;              //  GMII Transmit Frame Error
input   [3:0] m_rx_d;           //  MII Receive Data
input   m_rx_en;                //  MII Receive Frame Enable  
input   m_rx_err;               //  MII Receive Drame Error      
output  [3:0] m_tx_d;           //  MII Transmit Data
output  m_tx_en;                //  MII Transmit Frame Enable  
output  m_tx_err;               //  MII Transmit Frame Error
input   m_rx_crs;               //  Carrier Sense
input   m_rx_col;               //  Collition
output  eth_mode;               //  Ethernet Mode
output  ena_10;                 //  Enable 10Mbps Mode
input   set_1000;               //  Gigabit Mode Enable
input   set_10;                 //  10Mbps Mode Enable
output  mdc;                    //  2.5MHz Inteface
input   mdio_in;                //  MDIO Input
output  mdio_out;               //  MDIO Output
output  mdio_oen;               //  MDIO Output Enable
output  tx_control;
output  [3:0] rgmii_out;
input   [3:0] rgmii_in;
input   rx_control;


wire    [31:0] reg_data_out; 
wire    reg_busy; 
wire    [ENABLE_ENA-1:0] ff_rx_data; 
wire    [1:0] ff_rx_mod; 
wire    ff_rx_sop; 
wire    ff_rx_eop; 
wire    ff_rx_dval; 
wire    ff_rx_dsav; 
wire    ff_tx_rdy; 
wire    ff_tx_septy;
wire    tx_ff_uflow;
wire    magic_wakeup; 
wire    ff_rx_a_full;
wire    ff_rx_a_empty;
wire    ff_tx_a_full;
wire    ff_tx_a_empty;
wire    [7:0] gm_tx_d; 
wire    gm_tx_en; 
wire    gm_tx_err;
wire    [3:0] m_tx_d; 
wire    m_tx_en; 
wire    m_tx_err; 
wire    eth_mode; 
wire    ena_10;
wire    mdc; 
wire    mdio_out; 
wire    mdio_oen; 
wire    tx_control;
wire    [3:0] rgmii_out; 
wire    [5:0] rx_err;
wire    [17:0] rx_err_stat;
wire    [3:0] rx_frm_type;

//  Reset Lines
//  -----------

wire    reset_rx_clk_int;                       //  Asynchronous Reset - rx_clk Domain
wire    reset_tx_clk_int;                       //  Asynchronous Reset - tx_clk Domain
wire    reset_ff_rx_clk_int;                    //  Asynchronous Reset - ff_rx_clk Domain
wire    reset_ff_tx_clk_int;                    //  Asynchronous Reset - ff_tx_clk Domain
wire    reset_reg_clk_int;                      //  Asynchronous Reset - reg_clk Domain



// Programmable Reset Options
// --------------------------
    
generate if (USE_SYNC_RESET == 1)
    begin
        altera_tse_reset_synchronizer reset_sync_0 (
        .clk(rx_clk),
        .reset_in(reset),
        .reset_out(reset_rx_clk_int)
        );
        
        altera_tse_reset_synchronizer reset_sync_1 (
        .clk(tx_clk),
        .reset_in(reset),
        .reset_out(reset_tx_clk_int)
        );
        
        altera_tse_reset_synchronizer reset_sync_2 (
        .clk(ff_rx_clk),
        .reset_in(reset),
        .reset_out(reset_ff_rx_clk_int)
        );
        
        altera_tse_reset_synchronizer reset_sync_3 (
        .clk(ff_tx_clk),
        .reset_in(reset),
        .reset_out(reset_ff_tx_clk_int)
        );
        
        altera_tse_reset_synchronizer reset_sync_4 (
        .clk(clk),
        .reset_in(reset),
        .reset_out(reset_reg_clk_int)
        );
        
    end
else
    begin
        assign reset_rx_clk_int    = RESET_LEVEL == 1'b 1 ? reset : !reset ;
        assign reset_tx_clk_int    = RESET_LEVEL == 1'b 1 ? reset : !reset ;   
        assign reset_ff_rx_clk_int = RESET_LEVEL == 1'b 1 ? reset : !reset ;
        assign reset_ff_tx_clk_int = RESET_LEVEL == 1'b 1 ? reset : !reset ;
        assign reset_reg_clk_int   = RESET_LEVEL == 1'b 1 ? reset : !reset ; 
    end      
endgenerate
    
// --------------------------


    altera_tse_top_gen_host    top_gen_host_inst(
        .reset_ff_rx_clk(reset_ff_rx_clk_int),
        .reset_ff_tx_clk(reset_ff_tx_clk_int),
        .reset_reg_clk(reset_reg_clk_int),
        .reset_rx_clk(reset_rx_clk_int),
        .reset_tx_clk(reset_tx_clk_int),
        .rx_clk(rx_clk),
        .tx_clk(tx_clk),
		.rx_clkena(1'b1),
		.tx_clkena(1'b1), 
        .gm_rx_dv(gm_rx_dv),
        .gm_rx_d(gm_rx_d),
        .gm_rx_err(gm_rx_err),
        .m_rx_en(m_rx_en),
        .m_rx_d(m_rx_d),
        .m_rx_err(m_rx_err),
        .m_rx_col(m_rx_col),
        .m_rx_crs(m_rx_crs),
        .set_1000(set_1000),
        .set_10(set_10),
        .ff_rx_clk(ff_rx_clk),
        .ff_rx_rdy(ff_rx_rdy),
        .ff_tx_clk(ff_tx_clk),
        .ff_tx_wren(ff_tx_wren),
        .ff_tx_data(ff_tx_data),
        .ff_tx_mod(ff_tx_mod),
        .ff_tx_sop(ff_tx_sop),
        .ff_tx_eop(ff_tx_eop),
        .ff_tx_err(ff_tx_err),
        .ff_tx_crc_fwd(ff_tx_crc_fwd),
        .reg_clk(clk),
        .reg_addr(address),
        .reg_data_in(writedata),
        .reg_rd(read),
        .reg_wr(write),
        .mdio_in(mdio_in),
        .gm_tx_en(gm_tx_en),
        .gm_tx_d(gm_tx_d),
        .gm_tx_err(gm_tx_err),
        .m_tx_en(m_tx_en),
        .m_tx_d(m_tx_d),
        .m_tx_err(m_tx_err),
        .eth_mode(eth_mode),
        .ena_10(ena_10),
        .ff_rx_dval(ff_rx_dval),
        .ff_rx_data(ff_rx_data),
        .ff_rx_mod(ff_rx_mod),
        .ff_rx_sop(ff_rx_sop),
        .ff_rx_eop(ff_rx_eop),
        .ff_rx_dsav(ff_rx_dsav),
        .rx_err(rx_err),
        .rx_err_stat(rx_err_stat),
        .rx_frm_type(rx_frm_type),
        .ff_tx_rdy(ff_tx_rdy),
        .ff_tx_septy(ff_tx_septy),
        .tx_ff_uflow(tx_ff_uflow),
        .rx_a_full(ff_rx_a_full),
        .rx_a_empty(ff_rx_a_empty),
        .tx_a_full(ff_tx_a_full),
        .tx_a_empty(ff_tx_a_empty),
        .xoff_gen(xoff_gen),
        .xon_gen(xon_gen),
        .reg_data_out(readdata),
        .reg_busy(waitrequest),
        .reg_sleepN(magic_sleep_n),
        .reg_wakeup(magic_wakeup),
        .mdc(mdc),
        .mdio_out(mdio_out),
        .mdio_oen(mdio_oen),
        .tx_control(tx_control),
        .rgmii_out(rgmii_out),
        .rgmii_in(rgmii_in),
        .rx_control(rx_control));

    defparam
        top_gen_host_inst.EG_FIFO = EG_FIFO,
        top_gen_host_inst.ENABLE_SUP_ADDR = ENABLE_SUP_ADDR,
        top_gen_host_inst.CORE_VERSION = CORE_VERSION,
        top_gen_host_inst.CRC32GENDELAY = CRC32GENDELAY,
        top_gen_host_inst.MDIO_CLK_DIV = MDIO_CLK_DIV,
        top_gen_host_inst.EG_ADDR = EG_ADDR,
        top_gen_host_inst.ENA_HASH = ENA_HASH,
        top_gen_host_inst.STAT_CNT_ENA = STAT_CNT_ENA,
		top_gen_host_inst.ENABLE_EXTENDED_STAT_REG = ENABLE_EXTENDED_STAT_REG,
        top_gen_host_inst.ING_FIFO = ING_FIFO,
        top_gen_host_inst.ENABLE_ENA = ENABLE_ENA,
        top_gen_host_inst.ENABLE_HD_LOGIC = ENABLE_HD_LOGIC,
        top_gen_host_inst.REDUCED_INTERFACE_ENA = REDUCED_INTERFACE_ENA,
        top_gen_host_inst.ENABLE_MDIO = ENABLE_MDIO,
        top_gen_host_inst.ENABLE_MAGIC_DETECT = ENABLE_MAGIC_DETECT,
        top_gen_host_inst.ENABLE_MIN_FIFO = ENABLE_MIN_FIFO,        
        top_gen_host_inst.ENABLE_PADDING = !ENABLE_MACLITE, //1,
        top_gen_host_inst.ENABLE_LGTH_CHECK = !ENABLE_MACLITE, //1,
        top_gen_host_inst.GBIT_ONLY = !ENABLE_MACLITE | MACLITE_GIGE, //1,
        top_gen_host_inst.MBIT_ONLY = !ENABLE_MACLITE | !MACLITE_GIGE, //1,
        top_gen_host_inst.REDUCED_CONTROL = ENABLE_MACLITE, //0,
        top_gen_host_inst.CRC32S1L2_EXTERN = CRC32S1L2_EXTERN,
        top_gen_host_inst.ENABLE_GMII_LOOPBACK = ENABLE_GMII_LOOPBACK,
        top_gen_host_inst.ING_ADDR = ING_ADDR,
        top_gen_host_inst.CRC32DWIDTH = CRC32DWIDTH,
        top_gen_host_inst.CUST_VERSION = CUST_VERSION,
        top_gen_host_inst.CRC32CHECK16BIT = CRC32CHECK16BIT,
        top_gen_host_inst.ENABLE_SHIFT16 = ENABLE_SHIFT16,
        top_gen_host_inst.INSERT_TA = INSERT_TA,
        top_gen_host_inst.RAM_TYPE = RAM_TYPE,
        top_gen_host_inst.ENABLE_MAC_FLOW_CTRL  = ENABLE_MAC_FLOW_CTRL,
        top_gen_host_inst.ENABLE_MAC_TXADDR_SET = ENABLE_MAC_TXADDR_SET,
        top_gen_host_inst.ENABLE_MAC_RX_VLAN    = ENABLE_MAC_RX_VLAN,
		top_gen_host_inst.SYNCHRONIZER_DEPTH	= SYNCHRONIZER_DEPTH,
        top_gen_host_inst.ENABLE_MAC_TX_VLAN    = ENABLE_MAC_TX_VLAN;
		



endmodule
