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

// main.c: main source code file

//#include <reg515.h>
#include <8051.h>
#include <string.h>
#include "csio.h"
#include "packets.h"
#include "keypad.h"
#include "arp.h"
#include "ip.h"
#include "icmp.h"
#include "udp.h"
#include "tcp.h"

unsigned char myMAC[6] = {0x00,0x08,0x07,0x06,0x05,0x04};
unsigned char myIP[4] = {192,168,1,1};
unsigned char targetIP[4] = {192,168,1,2};
unsigned char targetMAC[6] = {0x00,0xa0,0x24,0x66,0xda,0x3f};
unsigned char srcMAC[6] = {0,0,0,0,0,0};
unsigned char srcIP[4] = {0,0,0,0};
unsigned char tmp_mac[6];
unsigned char tmp_ip[4];
unsigned char myBCAST[4] = {255,255,255,255};

unsigned char rx_ip_type;
unsigned char rx_buf[BUF_LEN];
unsigned int rx_buf_len;
unsigned int rx_packet_type;

void main(void)
{	
	unsigned char cTest;
	struct eth_hdr *rx_eth_hdr = (struct eth_hdr *)rx_buf;
	unsigned char bEvent = 0;
	unsigned char bValid = 0;
	unsigned char i = 0;
	
	tcp_init();
	cTest = cs_test();
	cs_init(myMAC);

	while (1)
	{
		bEvent = rx_event_poll();
 		if (bEvent == 1)
  	{
  			rx_buf_len = rx_packet(rx_buf);
			  rx_packet_type = rx_eth_hdr->type;
			  switch (rx_packet_type)
			  {
			  	case ETHER_IP:
			  		bValid = rx_ip_packet(rx_buf);
            if(bValid !=0) break;
			  		switch (rx_ip_type)
			  			{
			  				case IP_ICMP:
			  					rx_icmp_packet(rx_buf);
   	     							break;
			  				case IP_UDP:
			  					rx_udp_packet(rx_buf);
   	     							break;
			  				case IP_TCP:
			  					rx_tcp_packet(rx_buf);
   	     							break;
			  		}
   	 	  		break;
			  	case ETHER_ARP:
			  		rx_arp_packet(rx_buf);
			  		break;
			  }
		}
	}
}
