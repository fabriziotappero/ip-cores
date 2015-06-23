//-----------------------------------------------------------------------------
// Title      : Virtex-4 Ethernet MAC Wrapper Top Level
// Project    : Virtex-4 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : v4_emac_v4_8_block.v
// Version    : 4.8
//-----------------------------------------------------------------------------
//
// (c) Copyright 2004-2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Description:  This is the EMAC block level Verilog design for the Virtex-4 
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
//               Please refer to the Datasheet, Getting Started Guide, and
//               the Virtex-4 Embedded Tri-Mode Ethernet MAC User Gude for
//               further information.
//-----------------------------------------------------------------------------


`timescale 1 ps / 1 ps


//-----------------------------------------------------------------------------
// The module declaration for the top level design.
//-----------------------------------------------------------------------------
module v4_emac_v4_8_block
(
    // Client Receiver Interface - EMAC0
    RX_CLIENT_CLK_0,
    EMAC0CLIENTRXD,
    EMAC0CLIENTRXDVLD,
    EMAC0CLIENTRXGOODFRAME,
    EMAC0CLIENTRXBADFRAME,
    EMAC0CLIENTRXFRAMEDROP,
    EMAC0CLIENTRXSTATS,
    EMAC0CLIENTRXSTATSVLD,
    EMAC0CLIENTRXSTATSBYTEVLD,

    // Client Transmitter Interface - EMAC0
    TX_CLIENT_CLK_0,
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


    // MII Interface - EMAC0
    MII_COL_0,
    MII_CRS_0,
    MII_TXD_0,
    MII_TX_EN_0,
    MII_TX_ER_0,
    MII_TX_CLK_0,
    MII_RXD_0,
    MII_RX_DV_0,
    MII_RX_ER_0,
    MII_RX_CLK_0,

    // Preserved Tie-Off Pins for EMAC0
    SPEED_VECTOR_IN_0,
    HOSTCLK,
   // Asynchronous Reset Input
    RESET
);


//-----------------------------------------------------------------------------
// Port Declarations 
//-----------------------------------------------------------------------------
    // Client Receiver Interface - EMAC0
    output          RX_CLIENT_CLK_0;
    output   [7:0]  EMAC0CLIENTRXD;
    output          EMAC0CLIENTRXDVLD;
    output          EMAC0CLIENTRXGOODFRAME;
    output          EMAC0CLIENTRXBADFRAME;
    output          EMAC0CLIENTRXFRAMEDROP;
    output   [6:0]  EMAC0CLIENTRXSTATS;
    output          EMAC0CLIENTRXSTATSVLD;
    output          EMAC0CLIENTRXSTATSBYTEVLD;

    // Client Transmitter Interface - EMAC0
    output          TX_CLIENT_CLK_0;
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


    // MII Interface - EMAC0
    input           MII_COL_0;
    input           MII_CRS_0;
    output   [3:0]  MII_TXD_0;
    output          MII_TX_EN_0;
    output          MII_TX_ER_0;
    input           MII_TX_CLK_0;
    input    [3:0]  MII_RXD_0;
    input           MII_RX_DV_0;
    input           MII_RX_ER_0;
    input           MII_RX_CLK_0;

    // Preserved Tie-Off Pins for EMAC0
    input    [1:0]  SPEED_VECTOR_IN_0;
    input           HOSTCLK;
   
    // Asynchronous Reset
    input           RESET;
    
//-----------------------------------------------------------------------------
// Wire and Reg Declarations
//-----------------------------------------------------------------------------

    wire            reset_ibuf_i;
    wire            reset_i;
    wire            emac_reset;

    wire            rx_client_clk_out_0_i;
    wire            rx_client_clk_in_0_i;
    wire            tx_client_clk_out_0_i;
    wire            tx_client_clk_in_0_i;
    wire            tx_gmii_mii_clk_out_0_i;
    wire            tx_gmii_mii_clk_in_0_i;
    wire            mii_tx_clk_0_i;
    wire            mii_tx_en_0_i;
    wire            mii_tx_er_0_i;
    wire     [3:0]  mii_txd_0_i;
    wire            mii_tx_en_fa_0_i;
    wire            mii_tx_er_fa_0_i;
    wire     [3:0]  mii_txd_fa_0_i;
    wire            mii_crs_0_i;
    wire            mii_rx_clk_ibufg_0_i;
    wire            mii_rx_clk_0_i;


    wire     [7:0]  tx_data_0_i;
    wire            tx_data_valid_0_i;
    wire     [7:0]  rx_data_0_i;
    wire            rx_data_valid_0_i;
    wire            tx_underrun_0_i;
    wire            tx_ack_0_i;
    wire            rx_good_frame_0_i;
    wire            rx_bad_frame_0_i;
    wire            tx_retransmit_0_i;

    wire            host_clk_i;
    wire     [1:0]  speed_vector_0_i;
    wire     [1:0]  speed_vector_1_i;
    reg      [3:0]  reset_r;

    wire            mii_rx_dv_0_r;
    wire            mii_rx_er_0_r;
    wire     [3:0]  mii_rxd_0_r;




    // EMAC0 FCS block signals
    wire            tx_stats_byte_valid_0_i;
    wire            tx_collision_0_i;

//-----------------------------------------------------------------------------
// Main Body of Code
//-----------------------------------------------------------------------------


    //-------------------------------------------------------------------------
    // Main Reset Circuitry
    //-------------------------------------------------------------------------
    assign reset_ibuf_i = RESET;

    // Asserting the reset of the EMAC for a few clock cycles
    // (Any clock can be used besides the HOSTCLK)
    always @(posedge host_clk_i or posedge reset_ibuf_i)
    begin
        if (reset_ibuf_i == 1)
            reset_r <= 4'b1111;
        else
            reset_r <= {reset_r[2:0], reset_ibuf_i};
    end
    //synthesis attribute ASYNC_REG of reset_r is "TRUE"

    // The reset pulse is now several clock cycles in duration
    assign reset_i = reset_r[3];



    //-------------------------------------------------------------------------
    // MII circuitry for the Physical Interface of EMAC0
    //-------------------------------------------------------------------------

    mii_if mii0 (
        .RESET(reset_i),
        .MII_TXD(MII_TXD_0),
        .MII_TX_EN(MII_TX_EN_0),
        .MII_TX_ER(MII_TX_ER_0),
        .MII_RXD(MII_RXD_0),
        .MII_RX_DV(MII_RX_DV_0),
        .MII_RX_ER(MII_RX_ER_0),
        .MII_COL(MII_COL_0),
        .MII_CRS(MII_CRS_0),
        .TXD_FROM_MAC(mii_txd_0_i),
        .TX_EN_FROM_MAC(mii_tx_en_0_i),
        .TX_ER_FROM_MAC(mii_tx_er_0_i),
        .TX_CLK(tx_gmii_mii_clk_in_0_i),
        .RXD_TO_MAC(mii_rxd_0_r),
        .RX_DV_TO_MAC(mii_rx_dv_0_r),
        .RX_ER_TO_MAC(mii_rx_er_0_r),
        .RX_CLK(mii_rx_clk_0_i),
        .MII_COL_TO_MAC(mii_col_int_0),
        .MII_CRS_TO_MAC(mii_crs_0_i));

    // Instantiate the FCS block to correct possible duplicate
    // transmission of the final FCS byte
    emac0_fcs_blk_mii emac0_fcs_blk_inst (
        .reset               (reset_i),
        .tx_phy_clk          (tx_gmii_mii_clk_in_0_i),
        .txd_from_mac        (mii_txd_fa_0_i),
        .tx_en_from_mac      (mii_tx_en_fa_0_i),
        .tx_er_from_mac      (mii_tx_er_fa_0_i),
        .tx_client_clk       (tx_client_clk_in_0_i),
        .tx_stats_byte_valid (tx_stats_byte_valid_0_i),
        .tx_collision        (tx_collision_0_i),
        .speed_is_10_100     (1'b1),
        .txd                 (mii_txd_0_i),
        .tx_en               (mii_tx_en_0_i),
        .tx_er               (mii_tx_er_0_i)
    );

    assign EMAC0CLIENTTXCOLLISION    = tx_collision_0_i;
    assign EMAC0CLIENTTXSTATSBYTEVLD = tx_stats_byte_valid_0_i;






    //------------------------------------------------------------------------
    // MII PHY side transmit clock for EMAC0
    //------------------------------------------------------------------------
    //synthesis attribute keep of tx_gmii_mii_clk_in_0_i is "true"

    BUFG tx_gmii_mii_clk_0_bufg (
        //.I(tx_gmii_mii_clk_out_0_i),
        .I(mii_tx_clk_0_i),
        .O(tx_gmii_mii_clk_in_0_i)
        );

    //------------------------------------------------------------------------
    // MII PHY side Receiver Clock Management for EMAC0
    //------------------------------------------------------------------------
    IBUFG gmii_rx_clk_0_ibufg (
        .I(MII_RX_CLK_0),
        .O(mii_rx_clk_ibufg_0_i)
        );

    //synthesis attribute keep of mii_rx_clk_0_i is "true"
    BUFG gmii_rx_clk_0_bufg (
        .I(mii_rx_clk_ibufg_0_i),
        .O(mii_rx_clk_0_i)
        );


    //------------------------------------------------------------------------
    // MII client side transmit clock for EMAC0
    //------------------------------------------------------------------------
    //synthesis attribute keep of tx_client_clk_in_0_i is "true"
    BUFG tx_client_clk_0_bufg (
        .I(tx_client_clk_out_0_i),
        .O(tx_client_clk_in_0_i)
        );


    //------------------------------------------------------------------------
    // MII client side receive clock for EMAC0
    //------------------------------------------------------------------------
    //synthesis attribute keep of rx_client_clk_in_0_i is "true"
    BUFG rx_client_clk_0_bufg (
        .I(rx_client_clk_out_0_i),
        .O(rx_client_clk_in_0_i)
        );


    //------------------------------------------------------------------------
    // MII PHY side Transmitter Clock Management for EMAC0
    //------------------------------------------------------------------------
    IBUFG mii_tx_clk_0_ibufg (
        .I(MII_TX_CLK_0),
        .O(mii_tx_clk_0_i)
        );



    //------------------------------------------------------------------------
    // Connect previously derived client clocks to example design output ports
    //------------------------------------------------------------------------
    assign RX_CLIENT_CLK_0 = rx_client_clk_in_0_i;
    assign TX_CLIENT_CLK_0 = tx_client_clk_in_0_i;


    //------------------------------------------------------------------------
    // Instantiate the EMAC Wrapper (v4_emac_v4_8.v)
    //------------------------------------------------------------------------
    v4_emac_v4_8 v4_emac_top
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
        .EMAC0CLIENTRXDVREG6            (),
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
        .EMAC0CLIENTTXCOLLISION         (tx_collision_0_i),
        .EMAC0CLIENTTXRETRANSMIT        (EMAC0CLIENTTXRETRANSMIT),
        .CLIENTEMAC0TXIFGDELAY          (CLIENTEMAC0TXIFGDELAY),
        .EMAC0CLIENTTXSTATS             (EMAC0CLIENTTXSTATS),
        .EMAC0CLIENTTXSTATSVLD          (EMAC0CLIENTTXSTATSVLD),
        .EMAC0CLIENTTXSTATSBYTEVLD      (tx_stats_byte_valid_0_i),

        // MAC Control Interface - EMAC0
        .CLIENTEMAC0PAUSEREQ            (CLIENTEMAC0PAUSEREQ),
        .CLIENTEMAC0PAUSEVAL            (CLIENTEMAC0PAUSEVAL),

        // Clock Signals - EMAC0
        .GTX_CLK_0                      (1'b0),

        .EMAC0CLIENTTXGMIIMIICLKOUT     (tx_gmii_mii_clk_out_0_i),
        .CLIENTEMAC0TXGMIIMIICLKIN      (tx_gmii_mii_clk_in_0_i),

        // MII Interface - EMAC0
        .MII_COL_0                      (mii_col_int_0),
        .MII_CRS_0                      (mii_crs_0_i),
        .MII_TXD_0                      (mii_txd_fa_0_i),
        .MII_TX_EN_0                    (mii_tx_en_fa_0_i),
        .MII_TX_ER_0                    (mii_tx_er_fa_0_i),
      //.MII_TX_CLK_0                   (mii_tx_clk_0_i),
        .MII_TX_CLK_0                   (tx_gmii_mii_clk_in_0_i),
        .MII_RXD_0                      (mii_rxd_0_r),
        .MII_RX_DV_0                    (mii_rx_dv_0_r),
        .MII_RX_ER_0                    (mii_rx_er_0_r),
        .MII_RX_CLK_0                   (mii_rx_clk_0_i),

        // Preserved Tie-Off Pins for EMAC0
        .SPEED_VECTOR_IN_0              (speed_vector_0_i),

        .HOSTCLK                        (HOSTCLK),

        .DCM_LOCKED_0                   (1'b1  ),

        // Asynchronous Reset
        .RESET                          (reset_i)
        );





  // The Host clock (HOSTCLK on EMAC primitive) must always be driven.
  // In this example design it is kept as a standalone signal.  However,
  // this can be shared with one of the other clock sources, for
  // example, one of the 125MHz PHYEMAC#GTX clock inputs.

    assign host_clk_i = HOSTCLK;


  //--------------------------------------------------------------------
  // EMAC0 Tie-Off Pins
  //--------------------------------------------------------------------
  // All other Tie-Off Pins for EMAC0 are tied to a logic level in the
  // EMAC wrapper file (v4_emac_v4_8.v).  The exception is
  // the following signals: by routing them to Input Buffers, the
  // demonstration testbench is able to perform speed changes during
  // simulation.
  assign speed_vector_0_i = SPEED_VECTOR_IN_0;






endmodule
