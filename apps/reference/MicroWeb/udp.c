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

// tcp.c: TCP protocol processing

#include <string.h>
#include "packets.h"
#include "ip.h"
#include "udp.h"

void tx_udp_packet(unsigned char *szData, unsigned char nLength)
{
	unsigned char tx_buf[BUF_LEN];
	struct ip_hdr *tx_ip_hdr = (struct ip_hdr *)(tx_buf + sizeof(struct eth_hdr));
	struct udp_hdr *tx_udp_hdr = (struct udp_hdr *)(tx_buf + sizeof(struct ip_hdr) + sizeof(struct eth_hdr));
	unsigned char *udp_data = (unsigned char *)(tx_buf + sizeof(struct eth_hdr) + sizeof(struct ip_hdr) + sizeof(struct udp_hdr));
	unsigned int *chksum_hdr = (unsigned int *)tx_udp_hdr;
	int i;
	unsigned int chksum = 0;
	
	for (i = 0; i < nLength; i++)
	{
		*udp_data = szData[i];
 		udp_data++;
	}
	
	tx_udp_hdr->src_port = MY_UDP_PORT;
	tx_udp_hdr->dst_port = MY_UDP_PORT;
	tx_udp_hdr->length = sizeof(struct udp_hdr) + nLength;

	// Compute the checksum
	for (i = 0; i < 3; i++)
	{
			chksum += *chksum_hdr;
  			chksum_hdr++;
   	}
   	chksum_hdr = (unsigned int *)&(tx_ip_hdr->proto);
   	chksum += *chksum_hdr;
   	chksum_hdr = (unsigned int *)&targetIP;
   	for (i = 0; i < 4; i++)
   	{
			chksum += *chksum_hdr;
  			chksum_hdr++;
	}
	chksum = ~chksum;
 	tx_udp_hdr->checksum = chksum;

	tx_ip_packet(tx_buf, nLength + sizeof(struct udp_hdr));
}

void rx_udp_packet(unsigned char *rx_buffer)
{
	struct ip_hdr *rx_ip_hdr = (struct ip_hdr *)(rx_buffer + sizeof(struct eth_hdr));
	struct udp_hdr *rx_udp_hdr = (struct udp_hdr *)(rx_buffer + sizeof(struct eth_hdr) + sizeof(struct ip_hdr));
	unsigned int *tmp_chk = (unsigned int *)&rx_ip_hdr->srcIP;
	unsigned int checksum = 0;
	unsigned int i;
#define msglen 15
	unsigned char msg[msglen] = "This is a test.";
	
	// check the length
	if (rx_udp_hdr->length == rx_ip_hdr->totlen - (sizeof(struct ip_hdr) / 8))
	{
		// check the checksum
       	checksum = rx_udp_hdr->length + rx_ip_hdr->proto;
       	checksum += (*tmp_chk)++;
       	checksum += (*tmp_chk)++;
       	checksum += (*tmp_chk)++;
       	checksum += (*tmp_chk);
       	
		tmp_chk = (unsigned int *)rx_udp_hdr;
               
		for (i = 0; i < rx_udp_hdr->length; i++)
			if (i != 3)	//skip existing checksum
				checksum += *tmp_chk;
		checksum = ~checksum;

 		// packet is valid if they match
 		if (checksum == rx_udp_hdr->checksum)
			// check the port numbers
			if ((rx_udp_hdr->src_port == MY_UDP_PORT) && (rx_udp_hdr->dst_port == MY_UDP_PORT))
       		{
        			// packet is ok, respond
				tx_udp_packet(msg, strlen(msg));
			}
	  		// else discard packet
  	}
	// else discard packet
}

