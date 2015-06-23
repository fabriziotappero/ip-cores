//////////////////////////////////////////////////////////////////////
////                                                              ////
////  tb_eth_defines.v                                            ////
////                                                              ////
////  This file is part of the Ethernet IP core project           ////
////  http://www.opencores.org/project,ethmac                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Igor Mohor (igorM@opencores.org)                      ////
////                                                              ////
////  All additional information is available in the Readme.txt   ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2001, 2002 Authors                             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.10  2002/11/19 20:27:46  mohor
// Temp version.
//
// Revision 1.9  2002/10/09 13:16:51  tadejm
// Just back-up; not completed testbench and some testcases are not
// wotking properly yet.
//
// Revision 1.8  2002/09/13 18:41:45  mohor
// Rearanged testcases
//
// Revision 1.7  2002/09/13 12:29:14  mohor
// Headers changed.
//
// Revision 1.6  2002/09/13 11:57:20  mohor
// New testbench. Thanks to Tadej M - "The Spammer".
//
// Revision 1.3  2002/07/19 13:57:53  mohor
// Testing environment also includes traffic cop, memory interface and host
// interface.
//
// Revision 1.2  2002/05/03 10:22:17  mohor
// TX_BUF_BASE changed.
//
// Revision 1.1  2002/03/19 12:53:54  mohor
// Some defines that are used in testbench only were moved to tb_eth_defines.v
// file.
//
//
//
//



//`define VERBOSE                       // if log files of device modules are written

`define MULTICAST_XFR          0
`define UNICAST_XFR            1
`define BROADCAST_XFR          2
`define UNICAST_WRONG_XFR      3

`define ETH_BASE              32'hd0000000
`define ETH_WIDTH             32'h800
`define MEMORY_BASE           32'h2000
`define MEMORY_WIDTH          32'h10000
`define TX_BUF_BASE           `MEMORY_BASE
`define RX_BUF_BASE           `MEMORY_BASE + 32'h8000
`define TX_BD_BASE            `ETH_BASE + 32'h00000400
`define RX_BD_BASE            `ETH_BASE + 32'h00000600

/* Tx BD */
`define ETH_TX_BD_READY    32'h8000 /* Tx BD Ready */
`define ETH_TX_BD_IRQ      32'h4000 /* Tx BD IRQ Enable */
`define ETH_TX_BD_WRAP     32'h2000 /* Tx BD Wrap (last BD) */
`define ETH_TX_BD_PAD      32'h1000 /* Tx BD Pad Enable */
`define ETH_TX_BD_CRC      32'h0800 /* Tx BD CRC Enable */

`define ETH_TX_BD_UNDERRUN 32'h0100 /* Tx BD Underrun Status */
`define ETH_TX_BD_RETRY    32'h00F0 /* Tx BD Retry Status */
`define ETH_TX_BD_RETLIM   32'h0008 /* Tx BD Retransmission Limit Status */
`define ETH_TX_BD_LATECOL  32'h0004 /* Tx BD Late Collision Status */
`define ETH_TX_BD_DEFER    32'h0002 /* Tx BD Defer Status */
`define ETH_TX_BD_CARRIER  32'h0001 /* Tx BD Carrier Sense Lost Status */

/* Rx BD */
`define ETH_RX_BD_EMPTY    32'h8000 /* Rx BD Empty */
`define ETH_RX_BD_IRQ      32'h4000 /* Rx BD IRQ Enable */
`define ETH_RX_BD_WRAP     32'h2000 /* Rx BD Wrap (last BD) */

`define ETH_RX_BD_MISS     32'h0080 /* Rx BD Miss Status */
`define ETH_RX_BD_OVERRUN  32'h0040 /* Rx BD Overrun Status */
`define ETH_RX_BD_INVSIMB  32'h0020 /* Rx BD Invalid Symbol Status */
`define ETH_RX_BD_DRIBBLE  32'h0010 /* Rx BD Dribble Nibble Status */
`define ETH_RX_BD_TOOLONG  32'h0008 /* Rx BD Too Long Status */
`define ETH_RX_BD_SHORT    32'h0004 /* Rx BD Too Short Frame Status */
`define ETH_RX_BD_CRCERR   32'h0002 /* Rx BD CRC Error Status */
`define ETH_RX_BD_LATECOL  32'h0001 /* Rx BD Late Collision Status */



/* Register space */
`define ETH_MODER      `ETH_BASE + 32'h00	/* Mode Register */
`define ETH_INT        `ETH_BASE + 32'h04	/* Interrupt Source Register */
`define ETH_INT_MASK   `ETH_BASE + 32'h08 /* Interrupt Mask Register */
`define ETH_IPGT       `ETH_BASE + 32'h0C /* Back to Bak Inter Packet Gap Register */
`define ETH_IPGR1      `ETH_BASE + 32'h10 /* Non Back to Back Inter Packet Gap Register 1 */
`define ETH_IPGR2      `ETH_BASE + 32'h14 /* Non Back to Back Inter Packet Gap Register 2 */
`define ETH_PACKETLEN  `ETH_BASE + 32'h18 /* Packet Length Register (min. and max.) */
`define ETH_COLLCONF   `ETH_BASE + 32'h1C /* Collision and Retry Configuration Register */
`define ETH_TX_BD_NUM  `ETH_BASE + 32'h20 /* Transmit Buffer Descriptor Number Register */
`define ETH_CTRLMODER  `ETH_BASE + 32'h24 /* Control Module Mode Register */
`define ETH_MIIMODER   `ETH_BASE + 32'h28 /* MII Mode Register */
`define ETH_MIICOMMAND `ETH_BASE + 32'h2C /* MII Command Register */
`define ETH_MIIADDRESS `ETH_BASE + 32'h30 /* MII Address Register */
`define ETH_MIITX_DATA `ETH_BASE + 32'h34 /* MII Transmit Data Register */
`define ETH_MIIRX_DATA `ETH_BASE + 32'h38 /* MII Receive Data Register */
`define ETH_MIISTATUS  `ETH_BASE + 32'h3C /* MII Status Register */
`define ETH_MAC_ADDR0  `ETH_BASE + 32'h40 /* MAC Individual Address Register 0 */
`define ETH_MAC_ADDR1  `ETH_BASE + 32'h44 /* MAC Individual Address Register 1 */
`define ETH_HASH_ADDR0 `ETH_BASE + 32'h48 /* Hash Register 0 */
`define ETH_HASH_ADDR1 `ETH_BASE + 32'h4C /* Hash Register 1 */
`define ETH_TX_CTRL    `ETH_BASE + 32'h50 /* Tx Control Register */


/* MODER Register */
`define ETH_MODER_RXEN     32'h00000001 /* Receive Enable  */
`define ETH_MODER_TXEN     32'h00000002 /* Transmit Enable */
`define ETH_MODER_NOPRE    32'h00000004 /* No Preamble  */
`define ETH_MODER_BRO      32'h00000008 /* Reject Broadcast */
`define ETH_MODER_IAM      32'h00000010 /* Use Individual Hash */
`define ETH_MODER_PRO      32'h00000020 /* Promiscuous (receive all) */
`define ETH_MODER_IFG      32'h00000040 /* Min. IFG not required */
`define ETH_MODER_LOOPBCK  32'h00000080 /* Loop Back */
`define ETH_MODER_NOBCKOF  32'h00000100 /* No Backoff */
`define ETH_MODER_EXDFREN  32'h00000200 /* Excess Defer */
`define ETH_MODER_FULLD    32'h00000400 /* Full Duplex */
`define ETH_MODER_RST      32'h00000800 /* Reset MAC */
`define ETH_MODER_DLYCRCEN 32'h00001000 /* Delayed CRC Enable */
`define ETH_MODER_CRCEN    32'h00002000 /* CRC Enable */
`define ETH_MODER_HUGEN    32'h00004000 /* Huge Enable */
`define ETH_MODER_PAD      32'h00008000 /* Pad Enable */
`define ETH_MODER_RECSMALL 32'h00010000 /* Receive Small */

/* Interrupt Source Register */
`define ETH_INT_TXB        32'h00000001 /* Transmit Buffer IRQ */
`define ETH_INT_TXE        32'h00000002 /* Transmit Error IRQ */
`define ETH_INT_RXB        32'h00000004 /* Receive Buffer IRQ */
`define ETH_INT_RXE        32'h00000008 /* Receive Error IRQ */
`define ETH_INT_BUSY       32'h00000010 /* Busy IRQ */
`define ETH_INT_TXC        32'h00000020 /* Transmit Control Frame IRQ */
`define ETH_INT_RXC        32'h00000040 /* Received Control Frame IRQ */

/* Interrupt Mask Register */
`define ETH_INT_MASK_TXB   32'h00000001 /* Transmit Buffer IRQ Mask */
`define ETH_INT_MASK_TXE   32'h00000002 /* Transmit Error IRQ Mask */
`define ETH_INT_MASK_RXF   32'h00000004 /* Receive Frame IRQ Mask */
`define ETH_INT_MASK_RXE   32'h00000008 /* Receive Error IRQ Mask */
`define ETH_INT_MASK_BUSY  32'h00000010 /* Busy IRQ Mask */
`define ETH_INT_MASK_TXC   32'h00000020 /* Transmit Control Frame IRQ Mask */
`define ETH_INT_MASK_RXC   32'h00000040 /* Received Control Frame IRQ Mask */

/* Control Module Mode Register */
`define ETH_CTRLMODER_PASSALL 32'h00000001 /* Pass Control Frames */
`define ETH_CTRLMODER_RXFLOW  32'h00000002 /* Receive Control Flow Enable */
`define ETH_CTRLMODER_TXFLOW  32'h00000004 /* Transmit Control Flow Enable */

/* MII Mode Register */
`define ETH_MIIMODER_CLKDIV   32'h000000FF /* Clock Divider */
`define ETH_MIIMODER_NOPRE    32'h00000100 /* No Preamble */
`define ETH_MIIMODER_RST      32'h00000200 /* MIIM Reset */

/* MII Command Register */
`define ETH_MIICOMMAND_SCANSTAT  32'h00000001 /* Scan Status */
`define ETH_MIICOMMAND_RSTAT     32'h00000002 /* Read Status */
`define ETH_MIICOMMAND_WCTRLDATA 32'h00000004 /* Write Control Data */

/* MII Address Register */
`define ETH_MIIADDRESS_FIAD 32'h0000001F /* PHY Address */
`define ETH_MIIADDRESS_RGAD 32'h00001F00 /* RGAD Address */

/* MII Status Register */
`define ETH_MIISTATUS_LINKFAIL    0 /* Link Fail bit */
`define ETH_MIISTATUS_BUSY        1 /* MII Busy bit */
`define ETH_MIISTATUS_NVALID      2 /* Data in MII Status Register is invalid bit */

/* TX Control Register */
`define ETH_TX_CTRL_TXPAUSERQ     32'h10000 /* Send PAUSE request */


`define TIME $display("  Time: %0t", $time)
