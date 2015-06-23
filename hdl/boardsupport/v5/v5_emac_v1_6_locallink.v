//-----------------------------------------------------------------------------
// Title      : Virtex-5 Ethernet MAC Local Link Wrapper
// Project    : Virtex-5 Ethernet MAC Wrappers
//-----------------------------------------------------------------------------
// File       : v5_emac_v1_6_locallink.v
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
// Description:  This level:
//
//               * instantiates the TEMAC top level file (the TEMAC
//                 wrapper with the clocking and physical interface
//				   logic;
//               
//               * instantiates TX and RX reference design FIFO's with 
//                 a local link interface.
//               
//               Please refer to the Datasheet, Getting Started Guide, and
//               the Virtex-5 Embedded Tri-Mode Ethernet MAC User Gude for
//               further information.
//-----------------------------------------------------------------------------


`timescale 1 ps / 1 ps


//-----------------------------------------------------------------------------
// The module declaration for the MAC with FIFO design.
//-----------------------------------------------------------------------------
module v5_emac_v1_6_locallink
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

    // Local link Receiver Interface - EMAC0
    RX_LL_CLOCK_0,
    RX_LL_RESET_0,
    RX_LL_DATA_0,
    RX_LL_SOF_N_0,
    RX_LL_EOF_N_0,
    RX_LL_SRC_RDY_N_0,
    RX_LL_DST_RDY_N_0,
    RX_LL_FIFO_STATUS_0,

    // Local link Transmitter Interface - EMAC0
    TX_LL_CLOCK_0,
    TX_LL_RESET_0,
    TX_LL_DATA_0,
    TX_LL_SOF_N_0,
    TX_LL_EOF_N_0,
    TX_LL_SRC_RDY_N_0,
    TX_LL_DST_RDY_N_0,
 
    
    // Client Receiver Interface - EMAC0
    EMAC0CLIENTRXDVLD,
    EMAC0CLIENTRXFRAMEDROP,
    EMAC0CLIENTRXSTATS,
    EMAC0CLIENTRXSTATSVLD,
    EMAC0CLIENTRXSTATSBYTEVLD,

    // Client Transmitter Interface - EMAC0
    CLIENTEMAC0TXIFGDELAY,
    EMAC0CLIENTTXSTATS,
    EMAC0CLIENTTXSTATSVLD,
    EMAC0CLIENTTXSTATSBYTEVLD,

    // MAC Control Interface - EMAC0
    CLIENTEMAC0PAUSEREQ,
    CLIENTEMAC0PAUSEVAL,

    //EMAC-MGT link status
    EMAC0CLIENTSYNCACQSTATUS,
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

    // Asynchronous Reset
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

    // Local link Receiver Interface - EMAC0
    input           RX_LL_CLOCK_0;
    input           RX_LL_RESET_0;
    output   [7:0]  RX_LL_DATA_0;
    output          RX_LL_SOF_N_0;
    output          RX_LL_EOF_N_0;
    output          RX_LL_SRC_RDY_N_0;
    input           RX_LL_DST_RDY_N_0;
    output   [3:0]  RX_LL_FIFO_STATUS_0;

    // Local link Transmitter Interface - EMAC0
    input           TX_LL_CLOCK_0;
    input           TX_LL_RESET_0;
    input    [7:0]  TX_LL_DATA_0;
    input           TX_LL_SOF_N_0;
    input           TX_LL_EOF_N_0;
    input           TX_LL_SRC_RDY_N_0;
    output          TX_LL_DST_RDY_N_0;

    // Client Receiver Interface - EMAC0
    output          EMAC0CLIENTRXDVLD;
    output          EMAC0CLIENTRXFRAMEDROP;
    output   [6:0]  EMAC0CLIENTRXSTATS;
    output          EMAC0CLIENTRXSTATSVLD;
    output          EMAC0CLIENTRXSTATSBYTEVLD;

    // Client Transmitter Interface - EMAC0
    input    [7:0]  CLIENTEMAC0TXIFGDELAY;
    output          EMAC0CLIENTTXSTATS;
    output          EMAC0CLIENTTXSTATSVLD;
    output          EMAC0CLIENTTXSTATSBYTEVLD;

    // MAC Control Interface - EMAC0
    input           CLIENTEMAC0PAUSEREQ;
    input   [15:0]  CLIENTEMAC0PAUSEVAL;

    //EMAC-MGT link status
    output          EMAC0CLIENTSYNCACQSTATUS;
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

    // Global asynchronous reset
    wire            reset_i;
    // Client interface clocking signals - EMAC0
    wire            tx_clk_0_i;
    wire            rx_clk_0_i;

    // Internal client interface connections - EMAC0
    // Transmitter interface
    wire     [7:0]  tx_data_0_i;
    wire            tx_data_valid_0_i;
    wire            tx_underrun_0_i;
    wire            tx_ack_0_i;
    wire            tx_collision_0_i;
    wire            tx_retransmit_0_i;
    // Receiver interface
    wire     [7:0]  rx_data_0_i;
    wire            rx_data_valid_0_i;
    wire            rx_good_frame_0_i;
    wire            rx_bad_frame_0_i;
    // Registers for the EMAC receiver output
    reg      [7:0]  rx_data_0_r;
    reg             rx_data_valid_0_r;
    reg             rx_good_frame_0_r;
    reg             rx_bad_frame_0_r;   

    // Reset signals from the transceiver
    wire            resetdone_0_i;

    // create a synchronous reset in the transmitter clock domain
    reg       [5:0] tx_pre_reset_0_i;
    reg             tx_reset_0_i;

    // create a synchronous reset in the receiver clock domain
    reg       [5:0] rx_pre_reset_0_i;
    reg             rx_reset_0_i;    

    // synthesis attribute ASYNC_REG of rx_pre_reset_0_i is "TRUE";
    // synthesis attribute ASYNC_REG of tx_pre_reset_0_i is "TRUE";

    
//-----------------------------------------------------------------------------
// Main Body of Code 
//-----------------------------------------------------------------------------

    // Asynchronous reset input
    assign reset_i = RESET; 

    //------------------------------------------------------------------------
    // Instantiate the EMAC Wrapper (v5_emac_v1_6_block.v) 
    //------------------------------------------------------------------------
    v5_emac_v1_6_block v5_emac_block_inst
    (
    // EMAC0 Clocking
    // 125MHz clock output from transceiver
    .CLK125_OUT                          (CLK125_OUT),
    // 125MHz clock input from BUFG
    .CLK125                              (CLK125),
    // Tri-speed clock output from EMAC0
    .CLIENT_CLK_OUT_0                    (CLIENT_CLK_OUT_0),
    // EMAC0 Tri-speed clock input from BUFG
    .CLIENT_CLK_0                        (CLIENT_CLK_0),

    // Client Receiver Interface - EMAC0
    .EMAC0CLIENTRXD                      (rx_data_0_i),
    .EMAC0CLIENTRXDVLD                   (rx_data_valid_0_i),
    .EMAC0CLIENTRXGOODFRAME              (rx_good_frame_0_i),
    .EMAC0CLIENTRXBADFRAME               (rx_bad_frame_0_i),
    .EMAC0CLIENTRXFRAMEDROP              (EMAC0CLIENTRXFRAMEDROP),
    .EMAC0CLIENTRXSTATS                  (EMAC0CLIENTRXSTATS),
    .EMAC0CLIENTRXSTATSVLD               (EMAC0CLIENTRXSTATSVLD),
    .EMAC0CLIENTRXSTATSBYTEVLD           (EMAC0CLIENTRXSTATSBYTEVLD),

    // Client Transmitter Interface - EMAC0
    .CLIENTEMAC0TXD                      (tx_data_0_i),
    .CLIENTEMAC0TXDVLD                   (tx_data_valid_0_i),
    .EMAC0CLIENTTXACK                    (tx_ack_0_i),
    .CLIENTEMAC0TXFIRSTBYTE              (1'b0),
    .CLIENTEMAC0TXUNDERRUN               (tx_underrun_0_i),
    .EMAC0CLIENTTXCOLLISION              (tx_collision_0_i),
    .EMAC0CLIENTTXRETRANSMIT             (tx_retransmit_0_i),
    .CLIENTEMAC0TXIFGDELAY               (CLIENTEMAC0TXIFGDELAY),
    .EMAC0CLIENTTXSTATS                  (EMAC0CLIENTTXSTATS),
    .EMAC0CLIENTTXSTATSVLD               (EMAC0CLIENTTXSTATSVLD),
    .EMAC0CLIENTTXSTATSBYTEVLD           (EMAC0CLIENTTXSTATSBYTEVLD),

    // MAC Control Interface - EMAC0
    .CLIENTEMAC0PAUSEREQ                 (CLIENTEMAC0PAUSEREQ),
    .CLIENTEMAC0PAUSEVAL                 (CLIENTEMAC0PAUSEVAL),

    //EMAC-MGT link status
    .EMAC0CLIENTSYNCACQSTATUS            (EMAC0CLIENTSYNCACQSTATUS),
    .EMAC0ANINTERRUPT                    (EMAC0ANINTERRUPT),


    // SGMII Interface - EMAC0
    .TXP_0                               (TXP_0),
    .TXN_0                               (TXN_0),
    .RXP_0                               (RXP_0),
    .RXN_0                               (RXN_0),
    .PHYAD_0                             (PHYAD_0),
    .RESETDONE_0                         (resetdone_0_i),

    // unused transceiver
    .TXN_1_UNUSED                        (TXN_1_UNUSED),
    .TXP_1_UNUSED                        (TXP_1_UNUSED),
    .RXN_1_UNUSED                        (RXN_1_UNUSED),
    .RXP_1_UNUSED                        (RXP_1_UNUSED),

    // SGMII MGT Clock buffer inputs 
    .CLK_DS                              (CLK_DS), 
    .GTRESET                             (GTRESET), 

    // Asynchronous Reset Input
    .RESET                               (reset_i));

  //-------------------------------------------------------------------
  // Instantiate the client side FIFO
  //-------------------------------------------------------------------
  eth_fifo_8 client_side_FIFO_emac0 (
     // EMAC transmitter client interface
     .tx_clk(tx_clk_0_i),
     .tx_reset(tx_reset_0_i),
     .tx_enable(1'b1),
     .tx_data(tx_data_0_i),
     .tx_data_valid(tx_data_valid_0_i),
     .tx_ack(tx_ack_0_i),
     .tx_underrun(tx_underrun_0_i),
     .tx_collision(tx_collision_0_i),
     .tx_retransmit(tx_retransmit_0_i),

     // Transmitter local link interface     
     .tx_ll_clock(TX_LL_CLOCK_0),
     .tx_ll_reset(TX_LL_RESET_0),
     .tx_ll_data_in(TX_LL_DATA_0),
     .tx_ll_sof_in_n(TX_LL_SOF_N_0),
     .tx_ll_eof_in_n(TX_LL_EOF_N_0),
     .tx_ll_src_rdy_in_n(TX_LL_SRC_RDY_N_0),
     .tx_ll_dst_rdy_out_n(TX_LL_DST_RDY_N_0),
     .tx_fifo_status(),
     .tx_overflow(),

     // EMAC receiver client interface     
     .rx_clk(rx_clk_0_i),
     .rx_reset(rx_reset_0_i),
     .rx_enable(1'b1),
     .rx_data(rx_data_0_r),
     .rx_data_valid(rx_data_valid_0_r),
     .rx_good_frame(rx_good_frame_0_r),
     .rx_bad_frame(rx_bad_frame_0_r),
     .rx_overflow(),

     // Receiver local link interface
     .rx_ll_clock(RX_LL_CLOCK_0),
     .rx_ll_reset(RX_LL_RESET_0),
     .rx_ll_data_out(RX_LL_DATA_0),
     .rx_ll_sof_out_n(RX_LL_SOF_N_0),
     .rx_ll_eof_out_n(RX_LL_EOF_N_0),
     .rx_ll_src_rdy_out_n(RX_LL_SRC_RDY_N_0),
     .rx_ll_dst_rdy_in_n(RX_LL_DST_RDY_N_0),
     .rx_fifo_status(RX_LL_FIFO_STATUS_0));


  //-------------------------------------------------------------------
  // Create synchronous reset signals for use in the FIFO.
  // A synchronous reset signal is created in each
  // clock domain.
  //-------------------------------------------------------------------

  // Create synchronous reset in the transmitter clock domain.
  always @(posedge tx_clk_0_i, posedge reset_i)
  begin
    if (reset_i === 1'b1)
    begin
      tx_pre_reset_0_i <= 6'h3F;
      tx_reset_0_i     <= 1'b1;
    end
    else
    begin
      if (resetdone_0_i == 1'b1)
      begin
        tx_pre_reset_0_i[0]   <= 1'b0;
        tx_pre_reset_0_i[5:1] <= tx_pre_reset_0_i[4:0];
        tx_reset_0_i          <= tx_pre_reset_0_i[5];
      end
    end
  end

always @(posedge rx_clk_0_i, posedge reset_i)
  begin
    if (reset_i === 1'b1)
    begin
      rx_pre_reset_0_i <= 6'h3F;
      rx_reset_0_i     <= 1'b1;
    end
    else
    begin
      if (resetdone_0_i == 1'b1)
      begin
        rx_pre_reset_0_i[0]   <= 1'b0;
        rx_pre_reset_0_i[5:1] <= rx_pre_reset_0_i[4:0];
        rx_reset_0_i          <= rx_pre_reset_0_i[5];
      end
    end
  end


  //--------------------------------------------------------------------
  // Register the receiver outputs from EMAC0 before routing 
  // to the FIFO
  //--------------------------------------------------------------------
  always @(posedge rx_clk_0_i, posedge reset_i)
  begin
    if (reset_i == 1'b1)
    begin
      rx_data_valid_0_r <= 1'b0;
      rx_data_0_r       <= 8'h00;
      rx_good_frame_0_r <= 1'b0;
      rx_bad_frame_0_r  <= 1'b0;
    end
    else
    begin
      if (resetdone_0_i == 1'b1)
      begin
        rx_data_0_r       <= rx_data_0_i;
        rx_data_valid_0_r <= rx_data_valid_0_i;
        rx_good_frame_0_r <= rx_good_frame_0_i;
        rx_bad_frame_0_r  <= rx_bad_frame_0_i;
      end
    end
  end
     
    assign EMAC0CLIENTRXDVLD = rx_data_valid_0_i;

    // EMAC0 Clocking
    assign tx_clk_0_i = CLIENT_CLK_0;
    assign rx_clk_0_i = CLIENT_CLK_0;

    assign RESETDONE_0 = resetdone_0_i;

endmodule
