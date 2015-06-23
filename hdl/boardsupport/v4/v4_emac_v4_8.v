//-----------------------------------------------------------------------------
// Title      : Virtex-4 FX Ethernet MAC Wrapper
// Project    : Virtex-4 Embedded Tri-Mode Ethernet MAC Wrapper
// File       : v4_emac_v4_8.v
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
//------------------------------------------------------------------------------
// Description:  This wrapper file instantiates the full Virtex-4 FX Ethernet
//               MAC (EMAC) primitive.  For one or both of the two Ethernet MACs
//               (EMAC0/EMAC1):
//
//               * all unused input ports on the primitive will be tied to the
//                 appropriate logic level;
//
//               * all unused output ports on the primitive will be left
//                 unconnected;
//
//               * the Tie-off Vector will be connected based on the options
//                 selected from CORE Generator;
//
//               * only used ports will be connected to the ports of this
//                 wrapper file.
//
//               This simplified wrapper should therefore be used as the
//               instantiation template for the EMAC in customer designs.
//------------------------------------------------------------------------------

`timescale 1 ps / 1 ps


//------------------------------------------------------------------------------
// The module declaration for the top level wrapper.
//------------------------------------------------------------------------------
(* X_CORE_INFO = "v4_emac_v4_8, Coregen 12.1" *)
(* CORE_GENERATION_INFO = "v4_emac_v4_8,v4_emac_v4_8,{c_emac0=true,c_emac1=false,c_has_mii_emac0=true,c_has_mii_emac1=false,c_has_gmii_emac0=false,c_has_gmii_emac1=true,c_has_rgmii_v1_3_emac0=false,c_has_rgmii_v1_3_emac1=false,c_has_rgmii_v2_0_emac0=false,c_has_rgmii_v2_0_emac1=false,c_has_sgmii_emac0=false,c_has_sgmii_emac1=false,c_has_gpcs_emac0=false,c_has_gpcs_emac1=false,c_tri_speed_emac0=false,c_tri_speed_emac1=false,c_speed_10_emac0=true,c_speed_10_emac1=false,c_speed_100_emac0=true,c_speed_100_emac1=false,c_speed_1000_emac0=false,c_speed_1000_emac1=true,c_has_host=false,c_has_dcr=false,c_has_mdio_emac0=false,c_has_mdio_emac1=false,c_client_16_emac0=false,c_client_16_emac1=false,c_add_filter_emac0=true,c_add_filter_emac1=false,}" *)
module v4_emac_v4_8
(
    // Client Receiver Interface - EMAC0
    EMAC0CLIENTRXCLIENTCLKOUT,
    CLIENTEMAC0RXCLIENTCLKIN,
    EMAC0CLIENTRXD,
    EMAC0CLIENTRXDVLD,
    EMAC0CLIENTRXDVLDMSW,
    EMAC0CLIENTRXGOODFRAME,
    EMAC0CLIENTRXBADFRAME,
    EMAC0CLIENTRXFRAMEDROP,
    EMAC0CLIENTRXDVREG6,
    EMAC0CLIENTRXSTATS,
    EMAC0CLIENTRXSTATSVLD,
    EMAC0CLIENTRXSTATSBYTEVLD,

    // Client Transmitter Interface - EMAC0
    EMAC0CLIENTTXCLIENTCLKOUT,
    CLIENTEMAC0TXCLIENTCLKIN,
    CLIENTEMAC0TXD,
    CLIENTEMAC0TXDVLD,
    CLIENTEMAC0TXDVLDMSW,
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

    // Clock Signal - EMAC0
    GTX_CLK_0,
    EMAC0CLIENTTXGMIIMIICLKOUT,
    CLIENTEMAC0TXGMIIMIICLKIN,

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

    SPEED_VECTOR_IN_0,


    HOSTCLK,

    DCM_LOCKED_0,

    // Asynchronous Reset
    RESET
);

    //--------------------------------------------------------------------------
    // Port Declarations
    //--------------------------------------------------------------------------


    // Client Receiver Interface - EMAC0
    output          EMAC0CLIENTRXCLIENTCLKOUT;
    input           CLIENTEMAC0RXCLIENTCLKIN;
    output   [7:0]  EMAC0CLIENTRXD;
    output          EMAC0CLIENTRXDVLD;
    output          EMAC0CLIENTRXDVLDMSW;
    output          EMAC0CLIENTRXGOODFRAME;
    output          EMAC0CLIENTRXBADFRAME;
    output          EMAC0CLIENTRXFRAMEDROP;
    output          EMAC0CLIENTRXDVREG6;
    output   [6:0]  EMAC0CLIENTRXSTATS;
    output          EMAC0CLIENTRXSTATSVLD;
    output          EMAC0CLIENTRXSTATSBYTEVLD;

    // Client Transmitter Interface - EMAC0
    output          EMAC0CLIENTTXCLIENTCLKOUT;
    input           CLIENTEMAC0TXCLIENTCLKIN;
    input    [7:0]  CLIENTEMAC0TXD;
    input           CLIENTEMAC0TXDVLD;
    input           CLIENTEMAC0TXDVLDMSW;
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

    // Clock Signal - EMAC0
    input           GTX_CLK_0;
    output          EMAC0CLIENTTXGMIIMIICLKOUT;
    input           CLIENTEMAC0TXGMIIMIICLKIN;

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

    input [1:0]     SPEED_VECTOR_IN_0;


    input           HOSTCLK;

    input           DCM_LOCKED_0;

    // Asynchronous Reset
    input           RESET;


    //--------------------------------------------------------------------------
    // Wire Declarations
    //--------------------------------------------------------------------------


    wire    [15:0]  client_rx_data_0_i;
    wire    [15:0]  client_tx_data_0_i;

    wire    [79:0]  tieemac0configvector_i;
    wire     [4:0]  phy_config_vector_0_i;
    wire            has_mdio_0_i;
    wire     [1:0]  speed_0_i;
    wire            has_rgmii_0_i;
    wire            has_sgmii_0_i;
    wire            has_gpcs_0_i;
    wire            has_host_0_i;
    wire            tx_client_16_0_i;
    wire            rx_client_16_0_i;
    wire            addr_filter_enable_0_i;
    wire            rx_lt_check_dis_0_i;
    wire     [1:0]  flow_control_config_vector_0_i;
    wire     [6:0]  tx_config_vector_0_i;
    wire     [5:0]  rx_config_vector_0_i;
    wire    [47:0]  pause_address_0_i;

    wire    [47:0]  unicast_address_0_i;

    wire     [7:0]  mii_txd_0_i;



    //--------------------------------------------------------------------------
    // Main Body of Code
    //--------------------------------------------------------------------------


    // 8-bit client data on EMAC0
    assign EMAC0CLIENTRXD = client_rx_data_0_i[7:0];
    assign client_tx_data_0_i = {8'b00000000, CLIENTEMAC0TXD};



    // Unicast Address
    assign unicast_address_0_i = 48'hAB8967452301;


    //--------------------------------------------------------------------------
    // Construct the tie-off vector
    // ----------------------------

    // tieemac#configvector_i[79]: Reserved - Tie to "1"

    // tieemac#configvector_i[78:74]: phy_configuration_vector[4:0] that is used
    //     to configure the PCS/PMA either when the MDIO is not present or as
    //     initial values loaded upon reset that can be modified through the
    //     MDIO.

    // tieemac#configvector_i[73:65]: tie_off_vector[8:0] that is used to
    //     configure the mode of the EMAC.

    // tieemac#configvector_i[64:0]  mac_configuration_vector[64:0] that is used
    //     to configure the EMAC either when the Host interface is not present
    //     or as initial values loaded upon reset that can be modified through
    //     the Host interface.
    //--------------------------------------------------------------------------

    //-------
    // EMAC0
    //-------

    // Connect the Tie-off Pins
    //-------------------------

    assign tieemac0configvector_i = {1'b1, phy_config_vector_0_i,
                                     has_mdio_0_i,
                                     speed_0_i,
                                     has_rgmii_0_i,
                                     has_sgmii_0_i,
                                     has_gpcs_0_i,
                                     has_host_0_i,
                                     tx_client_16_0_i,
                                     rx_client_16_0_i,
                                     addr_filter_enable_0_i,
                                     rx_lt_check_dis_0_i,
                                     flow_control_config_vector_0_i,
                                     tx_config_vector_0_i,
                                     rx_config_vector_0_i,
                                     pause_address_0_i};


    // Assign the Tie-off Pins
    //-------------------------

    assign phy_config_vector_0_i             = 5'b10000; // PCS/PMA logic is not in use, hold in reset
    assign has_mdio_0_i                      = 1'b0;  // MDIO is not enabled
    assign speed_0_i                         = SPEED_VECTOR_IN_0; // Speed is assigned from example design
    assign has_rgmii_0_i                     = 1'b0;
    assign has_sgmii_0_i                     = 1'b0;
    assign has_gpcs_0_i                      = 1'b0;
    assign has_host_0_i                      = 1'b0;  // The Host I/F is not  in use
    assign tx_client_16_0_i                  = 1'b0;  // 8-bit interface for Tx client
    assign rx_client_16_0_i                  = 1'b0;  // 8-bit interface for Rx client
    assign addr_filter_enable_0_i            = 1'b1;  // The Address Filter (enabled)
    assign rx_lt_check_dis_0_i               = 1'b0;  // Rx Length/Type checking enabled (standard IEEE operation)
    assign flow_control_config_vector_0_i[1] = 1'b0;  // Rx Flow Control (not enabled)
    assign flow_control_config_vector_0_i[0] = 1'b0;  // Tx Flow Control (not enabled)
    assign tx_config_vector_0_i[6]           = 1'b0;  // Transmitter is not held in reset not asserted (normal operating mode)
    assign tx_config_vector_0_i[5]           = 1'b0;  // Transmitter Jumbo Frames (not enabled)
    assign tx_config_vector_0_i[4]           = 1'b0;  // Transmitter In-band FCS (not enabled)
    assign tx_config_vector_0_i[3]           = 1'b1;  // Transmitter Enabled
    assign tx_config_vector_0_i[2]           = 1'b0;  // Transmitter VLAN mode (not enabled)
    assign tx_config_vector_0_i[1]           = 1'b0;  // Transmitter Half Duplex mode (not enabled)
    assign tx_config_vector_0_i[0]           = 1'b0;  // Transmitter IFG Adjust (not enabled)
    assign rx_config_vector_0_i[5]           = 1'b0;  // Receiver is not held in reset not asserted (normal operating mode)
    assign rx_config_vector_0_i[4]           = 1'b0;  // Receiver Jumbo Frames (not enabled)
    assign rx_config_vector_0_i[3]           = 1'b0;  // Receiver In-band FCS (not enabled)
    assign rx_config_vector_0_i[2]           = 1'b1;  // Receiver Enabled
    assign rx_config_vector_0_i[1]           = 1'b0;  // Receiver VLAN mode (not enabled)
    assign rx_config_vector_0_i[0]           = 1'b0;  // Receiver Half Duplex mode (not enabled)

    // Set the Pause Address Default
    assign pause_address_0_i                 = 48'hFFEEDDCCBBAA;

    assign MII_TXD_0 = mii_txd_0_i[3:0];



    //--------------------------------------------------------------------------
    // Instantiate the Virtex-4 FX Embedded Ethernet EMAC
    //--------------------------------------------------------------------------
    EMAC v4_emac
    (
        .RESET                          (RESET),

        // EMAC0
        .EMAC0CLIENTRXCLIENTCLKOUT      (EMAC0CLIENTRXCLIENTCLKOUT),
        .CLIENTEMAC0RXCLIENTCLKIN       (CLIENTEMAC0RXCLIENTCLKIN),
        .EMAC0CLIENTRXD                 (client_rx_data_0_i),
        .EMAC0CLIENTRXDVLD              (EMAC0CLIENTRXDVLD),
        .EMAC0CLIENTRXDVLDMSW           (EMAC0CLIENTRXDVLDMSW),
        .EMAC0CLIENTRXGOODFRAME         (EMAC0CLIENTRXGOODFRAME),
        .EMAC0CLIENTRXBADFRAME          (EMAC0CLIENTRXBADFRAME),
        .EMAC0CLIENTRXFRAMEDROP         (EMAC0CLIENTRXFRAMEDROP),
        .EMAC0CLIENTRXDVREG6            (EMAC0CLIENTRXDVREG6),
        .EMAC0CLIENTRXSTATS             (EMAC0CLIENTRXSTATS),
        .EMAC0CLIENTRXSTATSVLD          (EMAC0CLIENTRXSTATSVLD),
        .EMAC0CLIENTRXSTATSBYTEVLD      (EMAC0CLIENTRXSTATSBYTEVLD),

        .EMAC0CLIENTTXCLIENTCLKOUT      (EMAC0CLIENTTXCLIENTCLKOUT),
        .CLIENTEMAC0TXCLIENTCLKIN       (CLIENTEMAC0TXCLIENTCLKIN),
        .CLIENTEMAC0TXD                 (client_tx_data_0_i),
        .CLIENTEMAC0TXDVLD              (CLIENTEMAC0TXDVLD),
        .CLIENTEMAC0TXDVLDMSW           (CLIENTEMAC0TXDVLDMSW),
        .EMAC0CLIENTTXACK               (EMAC0CLIENTTXACK),
        .CLIENTEMAC0TXFIRSTBYTE         (CLIENTEMAC0TXFIRSTBYTE),
        .CLIENTEMAC0TXUNDERRUN          (CLIENTEMAC0TXUNDERRUN),
        .EMAC0CLIENTTXCOLLISION         (EMAC0CLIENTTXCOLLISION),
        .EMAC0CLIENTTXRETRANSMIT        (EMAC0CLIENTTXRETRANSMIT),
        .CLIENTEMAC0TXIFGDELAY          (CLIENTEMAC0TXIFGDELAY),
        .EMAC0CLIENTTXSTATS             (EMAC0CLIENTTXSTATS),
        .EMAC0CLIENTTXSTATSVLD          (EMAC0CLIENTTXSTATSVLD),
        .EMAC0CLIENTTXSTATSBYTEVLD      (EMAC0CLIENTTXSTATSBYTEVLD),

        .CLIENTEMAC0PAUSEREQ            (CLIENTEMAC0PAUSEREQ),
        .CLIENTEMAC0PAUSEVAL            (CLIENTEMAC0PAUSEVAL),

        .PHYEMAC0GTXCLK                 (GTX_CLK_0),
        .EMAC0CLIENTTXGMIIMIICLKOUT     (EMAC0CLIENTTXGMIIMIICLKOUT),
        .CLIENTEMAC0TXGMIIMIICLKIN      (CLIENTEMAC0TXGMIIMIICLKIN),

        .PHYEMAC0RXCLK                  (MII_RX_CLK_0),
        .PHYEMAC0RXD                    ({4'b0000, MII_RXD_0}),
        .PHYEMAC0RXDV                   (MII_RX_DV_0),
        .PHYEMAC0RXER                   (MII_RX_ER_0),
        .PHYEMAC0MIITXCLK               (MII_TX_CLK_0),
        .EMAC0PHYTXCLK                  (),
        .EMAC0PHYTXD                    (mii_txd_0_i),
        .EMAC0PHYTXEN                   (MII_TX_EN_0),
        .EMAC0PHYTXER                   (MII_TX_ER_0),
        .PHYEMAC0COL                    (MII_COL_0),
        .PHYEMAC0CRS                    (MII_CRS_0),

        .CLIENTEMAC0DCMLOCKED           (DCM_LOCKED_0),
        .EMAC0CLIENTANINTERRUPT         (),
        .PHYEMAC0SIGNALDET              (1'b0),
        .PHYEMAC0PHYAD                  (5'b00000),
        .EMAC0PHYENCOMMAALIGN           (),
        .EMAC0PHYLOOPBACKMSB            (),
        .EMAC0PHYMGTRXRESET             (),
        .EMAC0PHYMGTTXRESET             (),
        .EMAC0PHYPOWERDOWN              (),
        .EMAC0PHYSYNCACQSTATUS          (),
        .PHYEMAC0RXCLKCORCNT            (3'b000),
        .PHYEMAC0RXBUFSTATUS            (2'b00),
        .PHYEMAC0RXBUFERR               (1'b0),
        .PHYEMAC0RXCHARISCOMMA          (1'b0),
        .PHYEMAC0RXCHARISK              (1'b0),
        .PHYEMAC0RXCHECKINGCRC          (1'b0),
        .PHYEMAC0RXCOMMADET             (1'b0),
        .PHYEMAC0RXDISPERR              (1'b0),
        .PHYEMAC0RXLOSSOFSYNC           (2'b00),
        .PHYEMAC0RXNOTINTABLE           (1'b0),
        .PHYEMAC0RXRUNDISP              (1'b0),
        .PHYEMAC0TXBUFERR               (1'b0),
        .EMAC0PHYTXCHARDISPMODE         (),
        .EMAC0PHYTXCHARDISPVAL          (),
        .EMAC0PHYTXCHARISK              (),

        .EMAC0PHYMCLKOUT                (),
        .PHYEMAC0MCLKIN                 (1'b0),
        .PHYEMAC0MDIN                   (1'b1),
        .EMAC0PHYMDOUT                  (),
        .EMAC0PHYMDTRI                  (),

        .TIEEMAC0CONFIGVEC              (tieemac0configvector_i),
        .TIEEMAC0UNICASTADDR            (unicast_address_0_i),

        // EMAC1
        .EMAC1CLIENTRXCLIENTCLKOUT      (),
        .CLIENTEMAC1RXCLIENTCLKIN       (1'b0),
        .EMAC1CLIENTRXD                 (),
        .EMAC1CLIENTRXDVLD              (),
        .EMAC1CLIENTRXDVLDMSW           (),
        .EMAC1CLIENTRXGOODFRAME         (),
        .EMAC1CLIENTRXBADFRAME          (),
        .EMAC1CLIENTRXFRAMEDROP         (),
        .EMAC1CLIENTRXDVREG6            (),
        .EMAC1CLIENTRXSTATS             (),
        .EMAC1CLIENTRXSTATSVLD          (),
        .EMAC1CLIENTRXSTATSBYTEVLD      (),

        .EMAC1CLIENTTXCLIENTCLKOUT      (),
        .CLIENTEMAC1TXCLIENTCLKIN       (1'b0),
        .CLIENTEMAC1TXD                 (16'h0000),
        .CLIENTEMAC1TXDVLD              (1'b0),
        .CLIENTEMAC1TXDVLDMSW           (1'b0),
        .EMAC1CLIENTTXACK               (),
        .CLIENTEMAC1TXFIRSTBYTE         (1'b0),
        .CLIENTEMAC1TXUNDERRUN          (1'b0),
        .EMAC1CLIENTTXCOLLISION         (),
        .EMAC1CLIENTTXRETRANSMIT        (),
        .CLIENTEMAC1TXIFGDELAY          (8'h00),
        .EMAC1CLIENTTXSTATS             (),
        .EMAC1CLIENTTXSTATSVLD          (),
        .EMAC1CLIENTTXSTATSBYTEVLD      (),

        .CLIENTEMAC1PAUSEREQ            (1'b0),
        .CLIENTEMAC1PAUSEVAL            (16'h0000),

        .PHYEMAC1GTXCLK                 (1'b0),
        .EMAC1CLIENTTXGMIIMIICLKOUT     (),
        .CLIENTEMAC1TXGMIIMIICLKIN      (1'b0),

        .PHYEMAC1RXCLK                  (1'b0),
        .PHYEMAC1RXD                    (8'h00),
        .PHYEMAC1RXDV                   (1'b0),
        .PHYEMAC1RXER                   (1'b0),
        .PHYEMAC1MIITXCLK               (1'b0),
        .EMAC1PHYTXCLK                  (),
        .EMAC1PHYTXD                    (),
        .EMAC1PHYTXEN                   (),
        .EMAC1PHYTXER                   (),
        .PHYEMAC1COL                    (1'b0),
        .PHYEMAC1CRS                    (1'b0),

        .CLIENTEMAC1DCMLOCKED           (1'b1),
        .EMAC1CLIENTANINTERRUPT         (),
        .PHYEMAC1SIGNALDET              (1'b0),
        .PHYEMAC1PHYAD                  (5'b00000),
        .EMAC1PHYENCOMMAALIGN           (),
        .EMAC1PHYLOOPBACKMSB            (),
        .EMAC1PHYMGTRXRESET             (),
        .EMAC1PHYMGTTXRESET             (),
        .EMAC1PHYPOWERDOWN              (),
        .EMAC1PHYSYNCACQSTATUS          (),
        .PHYEMAC1RXCLKCORCNT            (3'b000),
        .PHYEMAC1RXBUFSTATUS            (2'b00),
        .PHYEMAC1RXBUFERR               (1'b0),
        .PHYEMAC1RXCHARISCOMMA          (1'b0),
        .PHYEMAC1RXCHARISK              (1'b0),
        .PHYEMAC1RXCHECKINGCRC          (1'b0),
        .PHYEMAC1RXCOMMADET             (1'b0),
        .PHYEMAC1RXDISPERR              (1'b0),
        .PHYEMAC1RXLOSSOFSYNC           (2'b00),
        .PHYEMAC1RXNOTINTABLE           (1'b0),
        .PHYEMAC1RXRUNDISP              (1'b0),
        .PHYEMAC1TXBUFERR               (1'b0),
        .EMAC1PHYTXCHARDISPMODE         (),
        .EMAC1PHYTXCHARDISPVAL          (),
        .EMAC1PHYTXCHARISK              (),

        .EMAC1PHYMCLKOUT                (),
        .PHYEMAC1MCLKIN                 (1'b0),
        .PHYEMAC1MDIN                   (1'b0),
        .EMAC1PHYMDOUT                  (),
        .EMAC1PHYMDTRI                  (),

        .TIEEMAC1CONFIGVEC              (80'd0),
        .TIEEMAC1UNICASTADDR            (48'd0),

        // Host Interface
        .HOSTCLK                        (HOSTCLK),
        .HOSTOPCODE                     (2'b00),
        .HOSTREQ                        (1'b0),
        .HOSTMIIMSEL                    (1'b0),
        .HOSTADDR                       (10'b0000000000),
        .HOSTWRDATA                     (32'h00000000),
        .HOSTMIIMRDY                    (),
        .HOSTRDDATA                     (),
        .HOSTEMAC1SEL                   (1'b0),

        // DCR Interface
        .DCREMACCLK                     (1'b0),
        .DCREMACABUS                    (2'b00),
        .DCREMACREAD                    (1'b0),
        .DCREMACWRITE                   (1'b0),
        .DCREMACDBUS                    (32'h00000000),
        .EMACDCRACK                     (),
        .EMACDCRDBUS                    (),
        .DCREMACENABLE                  (1'b0),
        .DCRHOSTDONEIR                  ()
    );

endmodule
