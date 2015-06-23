// Copyright (C) 2002 Mason Kidd (mrkidd@nettaxi.com)
//
// This file is part of MicroWeb.
//
// MicroWeb is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// MicroWeb is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MicroWeb; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

// csio.h: defines and variables for CS8900A driver code

#ifndef H__CSIO
#define H__CSIO

// PacketPage control and config registers
#define PP_RxCFG 0x0102	/*  Rx Bus config */
#define PP_RxCTL 0x0104	/*  Receive Control Register */
#define PP_TxCFG 0x0106	/*  Transmit Config Register */
#define PP_TxCMD 0x0108	/*  Transmit Command Register */
#define PP_BufCFG 0x010A	/*  Bus configuration Register */
#define PP_LineCTL 0x0112	/*  Line Config Register */
#define PP_SelfCTL 0x0114	/*  Self Command Register */
#define PP_BusCTL 0x0116	/*  ISA bus control Register */
#define PP_TestCTL 0x0118	/*  Test Register */

// PacketPage status and event registers
#define PP_RxEvent 0x0124	/*  Rx Event Register */
#define PP_TxEvent 0x0128	/*  Tx Event Register */
#define PP_BufEvent 0x012C	/*  Bus Event Register */
#define PP_RxMiss 0x0130	/*  Receive Miss Count */
#define PP_TxCol 0x0132  	/*  Transmit Collision Count */
#define PP_LineST 0x0134	/*  Line State Register */
#define PP_SelfST 0x0136	/*  Self State register */
#define PP_BusST 0x0138 	/*  Bus Status */

// PacketPage IO Port registers
#define PP_TxCommand 0x0144	/*  Tx Command */
#define PP_TxLength 0x0146	/*  Tx Length */
#define PP_LAF 0x0150		/*  Hash Table */
#define PP_IA 0x0158		/*  Physical Address Register */
#define PP_RxStatus 0x0400	/*  Receive start of frame */
#define PP_RxLength 0x0402	/*  Receive Length of frame */
#define PP_RxFrame 0x0404	/*  Beginning of received frame */

// PP_RxEvent bits
#define RX_OK 0x0100		/* Received a frame */
#define RX_HASH 0x0200		/* Hashed address */

// PP_RxCTL bits
#define RX_IA_HASH_ACCEPT 0x0040		/* Accept Hashed frames */
#define RX_OK_ACCEPT 0x0100			/* Accept frames */
#define RX_IA_ACCEPT 0x0400			/* Accept destined for individual address */
#define RX_BROADCAST_ACCEPT 0x0800	/* Accept destined for broadcast address */

// PP_LineCTL bits
#define SERIAL_RX_ON 0x0040			/* Receive frames on */
#define SERIAL_TX_ON 0x0080			/* Transmit frames on */

// PP_SelfST bits
#define INITD 0x0080			/* Init is done */

// PP_BusST bits
#define TX_BID_ERROR 0x0080		/* Error on bidding for space */
#define READY_FOR_TX_NOW 0x0100	/* Bid for space ok, ready to transmit */

// PP_TestCTL bits
#define ENDECLOOP 0x0200		/* Set to loopback mode */

// PP_SelfCTL bits
#define RESET 0x0040			/* Reset chip */

// IO Port addresses
#define IO_RxTxData 0x0000	/* Receive Transmit Data (Port 0) IO Port */
#define IO_TxCMD 0x0004   	/* Transmit Command IO Port */
#define IO_TxLength 0x0006	/* Transmit Length IO Port */
#define IO_PPPointer 0x000A	/* PacketPage Pointer IO Port */
#define IO_PPData 0x000C  	/* PacketPage Data IO Port */

void cs_init(unsigned char my_MAC_addr[]);
unsigned char cs_test(void);
//void cs_reset(void);
unsigned char rx_event_poll(void);
unsigned int rx_packet(unsigned char *rx_buffer);
void tx_packet(unsigned char *tx_buffer, unsigned int tx_buffer_len);

#endif




