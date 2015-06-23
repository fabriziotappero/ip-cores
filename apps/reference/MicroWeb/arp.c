//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 WebServer Project                                 ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  The basic code is taken from MicroWeb project and necessary ////
//       upgrade is done to match the Turbo 8051 Webserver        ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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

/////////////////////////////////////////////////////////////////////
// Basic Code is from :
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

// arp.c: processing for ARP packets
/*******************************************************
  Arp Packet Format
    [15:0] - HRD   = 1
    [15:0] - PRO   = 0x0800
    [7:0]  - HLN   = 6
    [7:0]  - PLN   = 4
    [15:0] - OP       
    [47:0] - SHA [0-5]
    [31:0] - SPA [0-3]
    [47:0] - THA [0-5]
    [31:0] - TPA [0-3]

HRD (Hardware Type): This field specfies the type of hardware used for the local network
transmitting the ARP message.
     1    - Ethernet (10MB)
     6    - IEEE 802 Networks
     7    - ARCNET
     15   - Frame Relay
     16   - Asynhronous Transfer Mode (ATM)
     17   - HDLC
     18   - Fibre Channel
     19   - Asynchronous


PRO (Protocol Type): This field is the complement of the Hardware Type field, 
               specifying the type of layer three addresses used in the message. 
               For IPv4 addresses, this value is 2048 (0800 hex), 
               which corresponds to the EtherType code for the Internet Protocol.

HLN (Hardware Address Length): 
     Specifies how long hardware addresses are in this message. 
     For Ethernet or other networks using IEEE 802 MAC addresses, the value is 6.

PLN (Protocol Address Length):
     The complement of the preceding field; specifies how long protocol (layer three) 
     addresses are in this message. For IP(v4) addresses this value is of course 4.

OP (Opcode): This field specifes the nature of the Arp Message being sent
     1  -- ARP Request
     2  -- ARP Reply
     3  -- RARP Request
     4  -- RARP Reply
     5  -- DRARP Request
     6  -- DRARP Reply
     7  -- DRARP Error
     8  -- InARP Request
     9  -- InARP Reply

SHA (Sender Hardware Address): 
    The hardware (layer two) address of the device sending this message

SPA (Sender Protocol Address): 
    The IP address of the device sending this message.

THA (Target Hardware Address): 
    The hardware (layer two) address of the device this message is being sent to.

TPA (Target Protocol Address): 
    The IP address of the device this message is being sent to.


********************************************************/

#include <string.h>
#include "packets.h"
#include "csio.h"
#include "arp.h"

void tx_arp_packet(unsigned int arp_oper)
{
	unsigned char tx_buf[BUF_LEN];
	struct eth_hdr *tx_eth_hdr = (struct eth_hdr *)(tx_buf);
	struct eth_arp *tx_eth_arp = (struct eth_arp *)(tx_buf + sizeof(struct eth_hdr));
	unsigned int nLength = 0;

	tx_eth_arp->eth_arp_hdr.ar_hrd = ARP_HRD_ETHER;
	tx_eth_arp->eth_arp_hdr.ar_pro = ETHER_IP;
	tx_eth_arp->eth_arp_hdr.ar_hln = MAC_ADDR_LEN;
	tx_eth_arp->eth_arp_hdr.ar_pln = IP_ADDR_LEN;
	tx_eth_arp->eth_arp_hdr.ar_op = arp_oper;

	memcpy(tx_eth_arp->ar_sha, myMAC, sizeof(char) * MAC_ADDR_LEN);
	memcpy(tx_eth_arp->ar_spa, myIP, sizeof(char) * IP_ADDR_LEN);
	memcpy(tx_eth_arp->ar_tha, targetMAC, sizeof(char) * MAC_ADDR_LEN);
	memcpy(tx_eth_arp->ar_tpa, targetIP, sizeof(char) * IP_ADDR_LEN);

	memcpy(tx_eth_hdr->dhost, targetMAC, sizeof(char) * MAC_ADDR_LEN);
	memcpy(tx_eth_hdr->shost, myMAC, sizeof(char) * MAC_ADDR_LEN);
	tx_eth_hdr->type = ETHER_ARP;

	nLength += sizeof(struct eth_hdr) + sizeof(struct eth_arp);

	tx_packet(tx_buf, nLength);
}

void rx_arp_packet(unsigned char *rx_buffer)
{
	struct eth_hdr *rx_eth_hdr = (struct eth_hdr *)rx_buffer;
	struct eth_arp *rx_eth_arp = (struct eth_arp *)(rx_buffer + sizeof(struct eth_hdr));
	
	// make sure the ARP packet is Ethernet and IP
	if ((rx_eth_arp->eth_arp_hdr.ar_hrd == ARP_HRD_ETHER) && (rx_eth_arp->eth_arp_hdr.ar_pro == ETHER_IP))
	{
		// make sure the ARP packet is a request destined for us
		if ((rx_eth_arp->eth_arp_hdr.ar_op == ARP_REQUEST) && (!memcmp(myIP, rx_eth_arp->ar_tpa, sizeof(unsigned char) * 4)))
		{
			// send a reply
			memcpy(targetMAC, rx_eth_arp->ar_sha, sizeof(char) * MAC_ADDR_LEN);
			memcpy(targetIP, rx_eth_arp->ar_spa, sizeof(char) * IP_ADDR_LEN);
			tx_arp_packet(ARP_REPLY);
		}
       		// else discard packet
	}
	// else discard packet
}

