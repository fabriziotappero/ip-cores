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

// ip.c: IP protocol processing
/************************************************************
IP4 header:
   
   1. Version. 4 bits.
       Specifies the format of the IP packet header.
           4  --- IP, Internet Protocol. 
   2. IHL, Internet Header Length. 4 bits.
       Specifies the length of the IP packet header in 32 bit words. 
       The minimum value for a valid header is 5.
   
   3. Differentiated Services. 8 bits.
   
   4. Codepoint. 6 bits.
   
   5. unused. 2 bits.
   
   6. TOS, Type of Service. 8 bits.
   
   7. Total length. 16 bits.
           Contains the length of the datagram.
   
   8. Identification. 16 bits.
      Used to identify the fragments of one datagram from those of another. 
      The originating protocol module of an internet datagram sets the identification field to a value that must be unique for that source-destination pair and protocol for the time the datagram will be active in the internet system. The originating protocol module of a complete datagram clears the MF bit to zero and the Fragment Offset field to zero.
   
   9. Flags. 3 bits.
     9.A  R, reserved. 1 bit.
          Should be cleared to 0.
     9.B  DF, Don't fragment. 1 bit.
          Controls the fragmentation of the datagram.
     9.C  MF, More fragments. 1 bit.
          Indicates if the datagram contains additional fragments.
   
   10. Fragment Offset. 13 bits.
   
   11. TTL, Time to Live. 8 bits.
       A timer field used to track the lifetime of the datagram. 
       When the TTL field is decremented down to zero, the datagram is discarded.
   
   12. Protocol. 8 bits.
       This field specifies the next encapsulated protocol.
   
       1 -- ICMP, Internet Control Message Protocol. 
       2 -- IGAP, IGMP for user Authentication Protocol.
            IGMP, Internet Group Management Protocol.
            RGMP, Router-port Group Management Protocol. 
       4 -- IP in IP encapsulation. 
       6 -- TCP, Transmission Control Protocol. 
       17-- UDP, User Datagram Protocol. 
       41-- IPv6 over IPv4. 
       58-- ICMPv6, Internet Control Message Protocol for IPv6.
            MLD, Multicast Listener Discovery. 
       59-- IPv6 No Next Header. 
       97-- EtherIP. 
**********************************************************************/


#include <string.h>
#include "packets.h"
#include "csio.h"

unsigned char rx_ip_packet(unsigned char *rx_buffer)
{
	struct eth_hdr *rx_eth_hdr = (struct eth_hdr *)rx_buffer;
	struct ip_hdr *rx_ip_hdr = (struct ip_hdr *)(rx_buffer + sizeof(struct eth_hdr));
	unsigned int *chksum_hdr = (unsigned int *)rx_ip_hdr;
	int i;
	unsigned int chksum = 0;
	
	// Make sure that the packet is destined for me or for broadcast
	if ((!memcmp(myIP, &rx_ip_hdr->destIP, sizeof(unsigned char) * 4)) || (!memcmp(myBCAST, &rx_ip_hdr->destIP, sizeof(unsigned char) * 4)))
	{
       	// Save the source MAC and IP for when I reply
       	memcpy(srcMAC, &rx_eth_hdr->shost, sizeof(unsigned char) * 6);
       	memcpy(srcIP, &rx_ip_hdr->srcIP, sizeof(unsigned char) * 4);
		
		// Compute the checksum
		for (i = 0; i < 10; i++)
			if (i != 5)
				chksum += *chksum_hdr;
		chksum = ~chksum;
 		
 		// packet is valid if they match
 		if (chksum == rx_ip_hdr->hdrchksum)
  		{
			return rx_ip_hdr->proto;
    	}
     	else
      		return 0;
	}
	return 0;
}

void tx_ip_packet(unsigned char *tx_buffer, unsigned char tx_length)
{
	struct eth_hdr *tx_eth_hdr = (struct eth_hdr *)tx_buffer;
	struct ip_hdr *tx_ip_hdr = (struct ip_hdr *)(tx_buffer + sizeof(struct eth_hdr));
	unsigned int *chksum_hdr = (unsigned int *)tx_ip_hdr;
	int i;
	unsigned int chksum = 0;

    tx_ip_hdr->verIHL = 0x45;
    tx_ip_hdr->totlen = tx_length + sizeof(struct ip_hdr);
    tx_ip_hdr->TTL = 0x32;
    tx_ip_hdr->proto = IP_UDP;
    
	memcpy(tx_ip_hdr->srcIP, myIP, sizeof(unsigned char) * 4);
	memcpy(tx_ip_hdr->destIP, targetIP, sizeof(unsigned char) * 4);
	
	chksum_hdr = (unsigned int *)tx_ip_hdr;
	// Compute the checksum
	for (i = 0; i < 10; i++)
		if (i != 5)
			chksum += *chksum_hdr;
	chksum = ~chksum;
	tx_ip_hdr->hdrchksum = chksum;

	tx_eth_hdr->type = ETHER_IP;
	memcpy(tx_eth_hdr->shost, myMAC, sizeof(unsigned char) * 6);
	memcpy(tx_eth_hdr->dhost, targetMAC, sizeof(unsigned char) * 6);
	
   	tx_packet(tx_buffer, tx_length);
}

