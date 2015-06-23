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

// icmp.c: ICMP protocol processing

#include <string.h>
#include "packets.h"
#include "ip.h"
#include "icmp.h"

void tx_icmp_packet(unsigned char tx_type, unsigned char *szData, unsigned char nLength)
{
	unsigned char tx_buf[BUF_LEN];
	struct ip_hdr *tx_ip_hdr = (struct ip_hdr *)(tx_buf + sizeof(struct eth_hdr));
	struct icmp_hdr *tx_icmp_hdr = (struct icmp_hdr *)(tx_buf + sizeof(struct ip_hdr) + sizeof(struct eth_hdr));
	unsigned char *icmp_data = (unsigned char *)(tx_buf + sizeof(struct eth_hdr) + sizeof(struct ip_hdr) + sizeof(struct icmp_hdr));
	unsigned int *chksum_hdr = (unsigned int *)tx_icmp_hdr;
	int i;
	unsigned int chksum = 0;
	
    tx_icmp_hdr->type = tx_type;
    tx_icmp_hdr->sequence = 0x01;
    for (i = 0; i < nLength; i++)
    {
    	*icmp_data = *szData;
    	icmp_data++;
		szData++;
    }

	// Compute the checksum
	for (i = 0; i < 5; i++)
		if (i != 1)
 		{
			chksum += *chksum_hdr;
  			chksum_hdr++;
   		}
	chksum = ~chksum;
 	tx_icmp_hdr->checksum = 0x0b12;

	tx_ip_packet(tx_buf, nLength + sizeof(struct icmp_hdr));
}

void rx_icmp_packet(unsigned char *rx_buffer)
{
	struct ip_hdr *rx_ip_hdr = (struct ip_hdr *)(rx_buffer + sizeof(struct eth_hdr));
	struct icmp_hdr *rx_icmp_hdr = (struct icmp_hdr *)(rx_buffer + sizeof(struct eth_hdr) + sizeof(struct ip_hdr));
	unsigned char *pszData = (unsigned char *)(rx_buffer + sizeof(struct eth_hdr) + sizeof(struct ip_hdr) + sizeof(struct icmp_hdr));
	unsigned int nDataLen = rx_ip_hdr->totlen - sizeof(struct icmp_hdr) - sizeof(struct ip_hdr);

	// if it's an echo request, send a reply
	if (rx_icmp_hdr->type == ICMP_ECHO)
	{
		// switch source and destination IP's
		memcpy(targetMAC, srcMAC, sizeof(unsigned char) * 6);
		memcpy(targetIP, srcIP, sizeof(unsigned char) * 4);

		tx_icmp_packet(ICMP_ECHOREPLY, pszData, nDataLen);
	}
	// else discard packet
}

