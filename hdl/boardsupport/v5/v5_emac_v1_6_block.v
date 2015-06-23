//-----------------------------------------------------------------------------
// Title      : Virtex-5 Ethernet MAC Wrapper Top Level
// Project    : Virtex-5 Ethernet MAC Wrappers
//-----------------------------------------------------------------------------
// File       : v5_emac_v1_6_block.v
//-----------------------------------------------------------------------------
// Copyright (c) 2004-2008 by Xilinx, Inc. All rights reserved.
// This text/file contains proprietary, confidential
// information of Xilinx, Inc., is distributed under license
// from Xilinx, Inc., and may be used, copied and/or
// disclosed only pursuant to the terms of a valid license
// agreement with Xilinx, Inc. Xilinx hereby grants you
// a license to use this text/file solely for design, simulation,
// implementation and creation of design files limited
// to Xilinx devices or technologies. Use with non-Xilinx
// devices or technologies is expressly prohibited and
// immediately terminates your license unless covered by
// a separate agreement.
//
// Xilinx is providing this design, code, or information
// "as is" solely for use in developing programs and
// solutions for Xilinx devices. By providing this design,
// code, or information as one possible implementation of
// this feature, application or standard, Xilinx is making no
// representation that this implementation is free from any
// claims of infringement. You are responsible for
// obtaining any rights you may require for your implementation.
// Xilinx expressly disclaims any warranty whatsoever with
// respect to the adequacy of the implementation, including
// but not limited to any warranties or representations that this
// implementation is free from claims of infringement, implied
// warranties of merchantability or fitness for a particular
// purpose.
//
// Xilinx products are not intended for use in life support
// appliances, devices, or systems. Use in such applications are
// expressly prohibited.
//
// This copyright and support notice must be retained as part
// of this text at all times. (c) Copyright 2004-2008 Xilinx, Inc.
// All rights reserved.
//
//-----------------------------------------------------------------------------
// Description:  This is the EMAC block level Verilog design for the Virtex-5 
//               Embedded Ethernet MAC Example Design.  It is intended that
//               this example design can be quickly adapted and downloaded onto
//               an FPGA to provide a real hardware test environment.
//
//               The block level:
//
//               * instantiates all clock management logic required (BUFGs, 
//                 DCMs) to operate the EMAC and its example design;
//
//               * instantiates appropriate PHY interface modules (GMII, MII,
//                 RGMII, SGMII or 1000BASE-X) as required based on the user
//                 configuration.
//
//
//               Please refer to the Datasheet, Getting Started Guide, and
//               the Virtex-5 Embedded Tri-Mode Ethernet MAC User Gude for
//               further information.
//-----------------------------------------------------------------------------


`timescale 1 ps / 1 ps


//-----------------------------------------------------------------------------
// The module declaration for the top level design.
//-----------------------------------------------------------------------------
module v5_emac_v1_6_block
(
    // EMAC0 Clocking
    // 125MHz clock output from transceiver
    CLK125_OUT,
    // 125MHz clock input from BUFG
    CLK125,
    // Tri-speed clock output from EMAC0
    CLIENT_CLK_OUT_0,
    // EMAC0 Tri-speed clock input from BUFG
    CLIENT_CLK_0,

    // Client Receiver Interface - EMAC0
    EMAC0CLIENTRXD,
    EMAC0CLIENTRXDVLD,
    EMAC0CLIENTRXGOODFRAME,
    EMAC0CLIENTRXBADFRAME,
    EMAC0CLIENTRXFRAMEDROP,
    EMAC0CLIENTRXSTATS,
    EMAC0CLIENTRXSTATSVLD,
    EMAC0CLIENTRXSTATSBYTEVLD,

    // Client Transmitter Interface - EMAC0
    CLIENTEMAC0TXD,
    CLIENTEMAC0TXDVLD,
    EMAC0CLIENTTXACK,
    CLIENTEMAC0TXFIRSTBYTE,
    CLIENTEMAC0TXUNDERRUN,
    EMAC0CLIENTTXCOLLISION,
    EMAC0CLIENTTXRETRANSMIT,
    CLIENTEMAC0TXIFGDELAY,
    EMAC0CLIENTTXSTATS,
    EMAC0CLIENTTXSTATSVLD,
    EMAC0CLIENTTXSTATSBYTEVLD,

    // MAC Control Interface - EMAC0
    CLIENTEMAC0PAUSEREQ,
    CLIENTEMAC0PAUSEVAL,

    //EMAC-MGT link status
    EMAC0CLIENTSYNCACQSTATUS,
    //EMAC0 Interrupt
    EMAC0ANINTERRUPT,


    // SGMII Interface - EMAC0
    TXP_0,
    TXN_0,
    RXP_0,
    RXN_0,
    PHYAD_0,
    RESETDONE_0,

    // unused transceiver
    TXN_1_UNUSED,
    TXP_1_UNUSED,
    RXN_1_UNUSED,
    RXP_1_UNUSED,

    // SGMII MGT Clock buffer inputs 
    CLK_DS, 
    GTRESET,

    // Asynchronous Reset Input
    RESET
);


//-----------------------------------------------------------------------------
// Port Declarations 
//-----------------------------------------------------------------------------
    // EMAC0 Clocking
    // 125MHz clock output from transceiver
    output          CLK125_OUT;
    // 125MHz clock input from BUFG
    input           CLK125;
    // Tri-speed clock output from EMAC0
    output          CLIENT_CLK_OUT_0;
    // EMAC0 Tri-speed clock input from BUFG
    input           CLIENT_CLK_0;

    // Client Receiver Interface - EMAC0
    output   [7:0]  EMAC0CLIENTRXD;
    output          EMAC0CLIENTRXDVLD;
    output          EMAC0CLIENTRXGOODFRAME;
    output          EMAC0CLIENTRXBADFRAME;
    output          EMAC0CLIENTRXFRAMEDROP;
    output   [6:0]  EMAC0CLIENTRXSTATS;
    output          EMAC0CLIENTRXSTATSVLD;
    output          EMAC0CLIENTRXSTATSBYTEVLD;

    // Client Transmitter Interface - EMAC0
    input    [7:0]  CLIENTEMAC0TXD;
    input           CLIENTEMAC0TXDVLD;
    output          EMAC0CLIENTTXACK;
    input           CLIENTEMAC0TXFIRSTBYTE;
    input           CLIENTEMAC0TXUNDERRUN;
    output          EMAC0CLIENTTXCOLLISION;
    output          EMAC0CLIENTTXRETRANSMIT;
    input    [7:0]  CLIENTEMAC0TXIFGDELAY;
    output          EMAC0CLIENTTXSTATS;
    output          EMAC0CLIENTTXSTATSVLD;
    output          EMAC0CLIENTTXSTATSBYTEVLD;

    // MAC Control Interface - EMAC0
    input           CLIENTEMAC0PAUSEREQ;
    input   [15:0]  CLIENTEMAC0PAUSEVAL;

    //EMAC-MGT link status
    output          EMAC0CLIENTSYNCACQSTATUS;
    //EMAC0 Interrupt
    output          EMAC0ANINTERRUPT;


    // SGMII Interface - EMAC0
    output          TXP_0;
    output          TXN_0;
    input           RXP_0;
    input           RXN_0;
    input           [4:0] PHYAD_0;
    output          RESETDONE_0;

    // unused transceiver
    output          TXN_1_UNUSED;
    output          TXP_1_UNUSED;
    input           RXN_1_UNUSED;
    input           RXP_1_UNUSED;

    // SGMII MGT Clock buffer inputs 
    input           CLK_DS; 
    input           GTRESET; 

    // Asynchronous Reset
    input           RESET;

//-----------------------------------------------------------------------------
// Wire and Reg Declarations 
//-----------------------------------------------------------------------------

    // Asynchronous reset signals
    wire            reset_ibuf_i;
    wire            reset_i;
    reg      [3:0]  reset_r;

    // EMAC0 client clocking signals
    wire            rx_client_clk_out_0_i;
    wire            rx_client_clk_in_0_i;
    wire            tx_client_clk_out_0_i;
    wire            tx_client_clk_in_0_i;

    // EMAC0 Physical interface signals
    wire            emac_locked_0_i;
    wire     [7:0]  mgt_rx_data_0_i;
    wire     [7:0]  mgt_tx_data_0_i;
    wire            signal_detect_0_i;
    wire            rxelecidle_0_i;
    wire            encommaalign_0_i;
    wire            loopback_0_i;
    wire            mgt_rx_reset_0_i;
    wire            mgt_tx_reset_0_i;
    wire            powerdown_0_i;
    wire     [2:0]  rxclkcorcnt_0_i;
    wire            rxbuferr_0_i;
    wire            rxchariscomma_0_i;
    wire            rxcharisk_0_i;
    wire            rxdisperr_0_i;
    wire     [1:0]  rxlossofsync_0_i;
    wire            rxnotintable_0_i;
    wire            rxrundisp_0_i;
    wire            txbuferr_0_i;
    wire            txchardispmode_0_i;
    wire            txchardispval_0_i;
    wire            txcharisk_0_i;
    wire     [1:0]  rxbufstatus_0_i;
    reg      [3:0]  tx_reset_sm_0_r;
    reg             tx_pcs_reset_0_r;
    reg      [3:0]  rx_reset_sm_0_r;
    reg             rx_pcs_reset_0_r;


    // Transceiver clocking signals
    wire            usrclk2;
   
    wire            refclkout;
    wire            dcm_locked_gtp;  
    wire            plllock_0_i;

    // Speed output from EMAC0 for physical interface clocking
    wire [1:0]      speed_vector_0_i;
    wire            speed_vector_0_int;


//-----------------------------------------------------------------------------
// Main Body of Code 
//-----------------------------------------------------------------------------


    //-------------------------------------------------------------------------
    // Main Reset Circuitry
    //-------------------------------------------------------------------------

    assign reset_ibuf_i = RESET;

    // Asserting the reset of the EMAC for a few clock cycles
    always @(posedge usrclk2 or posedge reset_ibuf_i)
    begin
        if (reset_ibuf_i == 1)
        begin
            reset_r <= 4'b1111;
        end
        else
        begin
          if (plllock_0_i == 1)
            reset_r <= {reset_r[2:0], reset_ibuf_i};
        end
    end
    // synthesis attribute async_reg of reset_r is "TRUE";

    // The reset pulse is now several clock cycles in duration
    assign reset_i = reset_r[3];

 
   
    //-------------------------------------------------------------------------
    // Instantiate RocketIO tile for SGMII or 1000BASE-X PCS/PMA Physical I/F
    //-------------------------------------------------------------------------

    //EMAC0-only instance
    GTP_dual_1000X GTP_DUAL_1000X_inst
 
         (
         .RESETDONE_0           (RESETDONE_0),
         .ENMCOMMAALIGN_0       (encommaalign_0_i),
         .ENPCOMMAALIGN_0       (encommaalign_0_i),
         .LOOPBACK_0            (loopback_0_i),
         .POWERDOWN_0           (powerdown_0_i),
         .RXUSRCLK_0            (usrclk2),
         .RXUSRCLK2_0           (usrclk2),
         .RXRESET_0             (mgt_rx_reset_0_i),
         .TXCHARDISPMODE_0      (txchardispmode_0_i),
         .TXCHARDISPVAL_0       (txchardispval_0_i),
         .TXCHARISK_0           (txcharisk_0_i),
         .TXDATA_0              (mgt_tx_data_0_i),
 
         .TXUSRCLK_0            (usrclk2),
         .TXUSRCLK2_0           (usrclk2),
         .TXRESET_0             (mgt_tx_reset_0_i),                                   
         .RXCHARISCOMMA_0       (rxchariscomma_0_i),
         .RXCHARISK_0           (rxcharisk_0_i),
         .RXCLKCORCNT_0         (rxclkcorcnt_0_i),
         .RXDATA_0              (mgt_rx_data_0_i),
         .RXDISPERR_0           (rxdisperr_0_i),
         .RXNOTINTABLE_0        (rxnotintable_0_i),
         .RXRUNDISP_0           (rxrundisp_0_i),
         .RXBUFERR_0            (rxbuferr_0_i),
         .TXBUFERR_0            (txbuferr_0_i),
         .PLLLKDET_0            (plllock_0_i),
         .TXOUTCLK_0            (),
         .RXELECIDLE_0          (rxelecidle_0_i),
         .RX1P_0                (RXP_0),
         .RX1N_0                (RXN_0),
         .TX1N_0                (TXN_0),
         .TX1P_0                (TXP_0),
         .TX1N_1_UNUSED         (TXN_1_UNUSED),
         .TX1P_1_UNUSED         (TXP_1_UNUSED),
         .RX1N_1_UNUSED         (RXN_1_UNUSED),
         .RX1P_1_UNUSED         (RXP_1_UNUSED),
         .CLK_DS                (CLK_DS),         
         .GTRESET               (GTRESET),
         .REFCLKOUT             (refclkout),
         .PMARESET              (reset_ibuf_i),
         .DCM_LOCKED            (dcm_locked_gtp));



    //-------------------------------------------------------------------------
    // Generate the buffer status input to the EMAC0 from the buffer error 
    // output of the transceiver
    //-------------------------------------------------------------------------
    assign rxbufstatus_0_i[1] = rxbuferr_0_i;

    //-------------------------------------------------------------------------
    // Detect when there has been a disconnect
    //-------------------------------------------------------------------------
    assign signal_detect_0_i = ~(rxelecidle_0_i);






    //--------------------------------------------------------------------
    // Virtex5 Rocket I/O Clock Management
    //--------------------------------------------------------------------

    // The RocketIO transceivers are available in pairs with shared
    // clock resources
    // 125MHz clock is used for GTP user clocks and used
    // to clock all Ethernet core logic.
    assign usrclk2                   = CLK125;

    assign dcm_locked_gtp            = 1'b1;

    //------------------------------------------------------------------------
    // GTX_CLK Clock Management for EMAC0 - 125 MHz clock frequency
    // (Connected to PHYEMAC0GTXCLK of the EMAC primitive)
    //------------------------------------------------------------------------
    assign gtx_clk_ibufg_0_i         = usrclk2;


    // EMAC0: PLL locks
    assign emac_locked_0_i           = plllock_0_i;


    //------------------------------------------------------------------------
    // SGMII client side transmit clock for EMAC0
    //------------------------------------------------------------------------
    assign tx_client_clk_in_0_i      = CLIENT_CLK_0;

    //------------------------------------------------------------------------
    // SGMII client side receive clock for EMAC0
    //------------------------------------------------------------------------
    assign rx_client_clk_in_0_i      = CLIENT_CLK_0;


    //------------------------------------------------------------------------
    // Connect previously derived client clocks to example design output ports
    //------------------------------------------------------------------------
    // EMAC0 Clocking
    // 125MHz clock output from transceiver
    assign CLK125_OUT                = refclkout;
    // Tri-speed clock output from EMAC0
    assign CLIENT_CLK_OUT_0          = tx_client_clk_out_0_i;




    //------------------------------------------------------------------------
    // Instantiate the EMAC Wrapper (v5_emac_v1_6.v) 
    //------------------------------------------------------------------------
    v5_emac_v1_6 v5_emac_wrapper_inst
    (
        // Client Receiver Interface - EMAC0
        .EMAC0CLIENTRXCLIENTCLKOUT      (rx_client_clk_out_0_i),
        .CLIENTEMAC0RXCLIENTCLKIN       (rx_client_clk_in_0_i),
        .EMAC0CLIENTRXD                 (EMAC0CLIENTRXD),
        .EMAC0CLIENTRXDVLD              (EMAC0CLIENTRXDVLD),
        .EMAC0CLIENTRXDVLDMSW           (),
        .EMAC0CLIENTRXGOODFRAME         (EMAC0CLIENTRXGOODFRAME),
        .EMAC0CLIENTRXBADFRAME          (EMAC0CLIENTRXBADFRAME),
        .EMAC0CLIENTRXFRAMEDROP         (EMAC0CLIENTRXFRAMEDROP),
        .EMAC0CLIENTRXSTATS             (EMAC0CLIENTRXSTATS),
        .EMAC0CLIENTRXSTATSVLD          (EMAC0CLIENTRXSTATSVLD),
        .EMAC0CLIENTRXSTATSBYTEVLD      (EMAC0CLIENTRXSTATSBYTEVLD),

        // Client Transmitter Interface - EMAC0
        .EMAC0CLIENTTXCLIENTCLKOUT      (tx_client_clk_out_0_i),
        .CLIENTEMAC0TXCLIENTCLKIN       (tx_client_clk_in_0_i),
        .CLIENTEMAC0TXD                 (CLIENTEMAC0TXD),
        .CLIENTEMAC0TXDVLD              (CLIENTEMAC0TXDVLD),
        .CLIENTEMAC0TXDVLDMSW           (1'b0),
        .EMAC0CLIENTTXACK               (EMAC0CLIENTTXACK),
        .CLIENTEMAC0TXFIRSTBYTE         (CLIENTEMAC0TXFIRSTBYTE),
        .CLIENTEMAC0TXUNDERRUN          (CLIENTEMAC0TXUNDERRUN),
        .EMAC0CLIENTTXCOLLISION         (EMAC0CLIENTTXCOLLISION),
        .EMAC0CLIENTTXRETRANSMIT        (EMAC0CLIENTTXRETRANSMIT),
        .CLIENTEMAC0TXIFGDELAY          (CLIENTEMAC0TXIFGDELAY),
        .EMAC0CLIENTTXSTATS             (EMAC0CLIENTTXSTATS),
        .EMAC0CLIENTTXSTATSVLD          (EMAC0CLIENTTXSTATSVLD),
        .EMAC0CLIENTTXSTATSBYTEVLD      (EMAC0CLIENTTXSTATSBYTEVLD),

        // MAC Control Interface - EMAC0
        .CLIENTEMAC0PAUSEREQ            (CLIENTEMAC0PAUSEREQ),
        .CLIENTEMAC0PAUSEVAL            (CLIENTEMAC0PAUSEVAL),

        // Clock Signals - EMAC0
        .GTX_CLK_0                      (usrclk2),
        .EMAC0PHYTXGMIIMIICLKOUT        (),
        .PHYEMAC0TXGMIIMIICLKIN         (1'b0),

        // SGMII Interface - EMAC0
        .RXDATA_0                       (mgt_rx_data_0_i),
        .TXDATA_0                       (mgt_tx_data_0_i),
        .DCM_LOCKED_0                   (emac_locked_0_i  ),
        .AN_INTERRUPT_0                 (EMAC0ANINTERRUPT),
        .SIGNAL_DETECT_0                (signal_detect_0_i), 
        .PHYAD_0                        (PHYAD_0), 
        .ENCOMMAALIGN_0                 (encommaalign_0_i),
        .LOOPBACKMSB_0                  (loopback_0_i),
        .MGTRXRESET_0                   (mgt_rx_reset_0_i),
        .MGTTXRESET_0                   (mgt_tx_reset_0_i),
        .POWERDOWN_0                    (powerdown_0_i),
        .SYNCACQSTATUS_0                (EMAC0CLIENTSYNCACQSTATUS),
        .RXCLKCORCNT_0                  (rxclkcorcnt_0_i),
        .RXBUFSTATUS_0                  (rxbufstatus_0_i),
        .RXCHARISCOMMA_0                (rxchariscomma_0_i),
        .RXCHARISK_0                    (rxcharisk_0_i),
        .RXDISPERR_0                    (rxdisperr_0_i),
        .RXNOTINTABLE_0                 (rxnotintable_0_i),
        .RXREALIGN_0                    (1'b0),
        .RXRUNDISP_0                    (rxrundisp_0_i),
        .TXBUFERR_0                     (txbuferr_0_i),
        .TXRUNDISP_0                    (1'b0),
        .TXCHARDISPMODE_0               (txchardispmode_0_i),
        .TXCHARDISPVAL_0                (txchardispval_0_i),
        .TXCHARISK_0                    (txcharisk_0_i),

        .EMAC0SPEEDIS10100              (speed_vector_0_int),


        // Asynchronous Reset
        .RESET                          (reset_i)
        );


  
 



endmodule
