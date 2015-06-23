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

#include "packets.h"
#include "ip.h"
#include "tcp.h"
//#include "http.h"

static struct tcp_TCB tcp_table[TCP_MAX_CONN];

void tcp_init(void)
{
	int i;
	
       for (i = 0; i < TCP_MAX_CONN; i++)
       {
       	tcp_table[i].local_port = 0;
       	tcp_table[i].remote_port = 0;
       	tcp_table[i].remote_addr[0] = 0;
       	tcp_table[i].remote_addr[1] = 0;
       	tcp_table[i].remote_addr[2] = 0;
       	tcp_table[i].remote_addr[3] = 0;
       	tcp_table[i].state = LISTEN;
       	tcp_table[i].local_seq = 0;
       	tcp_table[i].remote_seq = 0;
       	
       }
}

unsigned char tcp_get_TCB(unsigned char remote_addr[4], unsigned int remote_port, unsigned int local_port)
{
	int i = 0;
	unsigned char free_TCB = TCP_MAX_CONN;
    
	for (i = 0; i < TCP_MAX_CONN; i++)
	{
		if (tcp_table[i].remote_addr[0] == remote_addr[0] &&
			tcp_table[i].remote_addr[0] == remote_addr[1] &&
			tcp_table[i].remote_addr[0] == remote_addr[2] &&
			tcp_table[i].remote_addr[0] == remote_addr[3] &&
			tcp_table[i].remote_port == remote_port &&
			tcp_table[i].local_port == local_port)
			return i;
		else if (tcp_table[i].state == LISTEN)
			free_TCB = i;
	}
	
	if (free_TCB != TCP_MAX_CONN)
	{
		tcp_table[free_TCB].local_port = local_port;
		tcp_table[free_TCB].remote_port = remote_port;
		tcp_table[free_TCB].remote_addr[0] = remote_addr[0];
		tcp_table[free_TCB].remote_addr[1] = remote_addr[1];
		tcp_table[free_TCB].remote_addr[2] = remote_addr[2];
		tcp_table[free_TCB].remote_addr[3] = remote_addr[3];
		return free_TCB;
	}
	
	return 0;
}

void delete_TCB(unsigned char num_TCB)
{
       	tcp_table[num_TCB].local_port = 0;
       	tcp_table[num_TCB].remote_port = 0;
       	tcp_table[num_TCB].remote_addr[0] = 0;
       	tcp_table[num_TCB].remote_addr[1] = 0;
       	tcp_table[num_TCB].remote_addr[2] = 0;
       	tcp_table[num_TCB].remote_addr[3] = 0;
       	tcp_table[num_TCB].state = LISTEN;
       	tcp_table[num_TCB].local_seq = 0;
       	tcp_table[num_TCB].remote_seq = 0;
}

void rx_tcp_packet(unsigned char *rx_buffer)
{
	struct eth_hdr *rx_eth_hdr = (struct eth_hdr *)rx_buffer;
	struct ip_hdr *rx_ip_hdr = (struct ip_hdr *)(rx_buffer + sizeof(struct eth_hdr));
	struct tcp_hdr *rx_tcp_hdr = (struct tcp_hdr *)(rx_buffer + sizeof(struct eth_hdr) + sizeof(struct ip_hdr));
	unsigned int *tcp_data = (unsigned int *)(rx_buffer + sizeof(struct eth_hdr) + sizeof(struct ip_hdr) + sizeof(struct tcp_hdr));
	unsigned int *chksum_hdr = (unsigned int *)rx_ip_hdr->srcIP;
	unsigned int tcp_len = rx_ip_hdr->totlen - sizeof(rx_ip_hdr);
	unsigned int chksum = tcp_len + IP_TCP;
	unsigned char current_TCB = 0;
	bit process_data = 0;
	int i;
	
	for (i = 0; i < 8; i++)
		chksum += *chksum_hdr;

	chksum_hdr = (unsigned int *)rx_tcp_hdr;

	// if the packet length is odd, pad it
	if (tcp_len % 2)
		*((unsigned char *)chksum_hdr + tcp_len) = 0;

	tcp_len = (tcp_len + 1) >> 1;
	for (i = 0; i < tcp_len; i++, chksum_hdr++)
		if (i != 8)
			chksum += *chksum_hdr;
	chksum = ~chksum;

	if (chksum == rx_tcp_hdr->checksum)
	{
		current_TCB = tcp_get_TCB(rx_ip_hdr->srcIP, rx_tcp_hdr->src_port, rx_tcp_hdr->dst_port);
		if (current_TCB != 0)
 		{
			switch (tcp_table[current_TCB].state)
			{
				case LISTEN:
					if (rx_tcp_hdr->cntrl_bits & TCP_CNTRL_SYN)
					{
						// received SYN, send SYN and ACK, enter SYN_RECVD
	   					tcp_table[current_TCB].state = SYN_RECVD;
						tcp_table[current_TCB].local_seq = TCP_START_SEQ;
						tcp_table[current_TCB].remote_seq = rx_tcp_hdr->seq;
						tx_tcp_packet(current_TCB, TCP_CNTRL_ACK | TCP_CNTRL_SYN, 0, 0);
					}
					break;
				case SYN_SENT:
					if (rx_tcp_hdr->cntrl_bits & (TCP_CNTRL_ACK || TCP_CNTRL_SYN))
					{
   						// received SYN and ACK, enter ESTABLISHED, send ACK
						tcp_table[current_TCB].state = ESTABLISHED;
						tcp_table[current_TCB].remote_seq = rx_tcp_hdr->seq;
   						tx_tcp_packet(current_TCB, TCP_CNTRL_ACK, 0, 0);
					}
					else if (rx_tcp_hdr->cntrl_bits & TCP_CNTRL_SYN)
					{
	   					// received SYN, enter SYN_RECVD, send ACK
						tcp_table[current_TCB].remote_seq = rx_tcp_hdr->seq;
						tcp_table[current_TCB].state = SYN_RECVD;
   						tx_tcp_packet(current_TCB, TCP_CNTRL_ACK, 0, 0);
					}
					break;
				case SYN_RECVD:
  					if (rx_tcp_hdr->cntrl_bits & TCP_CNTRL_ACK)
   	 				{
   	   					// received ACK, enter ESTABLISHED
						tcp_table[current_TCB].remote_seq = rx_tcp_hdr->seq;
						tcp_table[current_TCB].state = ESTABLISHED;
   		   			}
					break;
				case ESTABLISHED:
					if (rx_tcp_hdr->cntrl_bits & TCP_CNTRL_FIN)
					{
   						// received FIN, send ACK, close connection
   	   					// skip the CLOSE_WAIT state
						tcp_table[current_TCB].state = LAST_ACK;
						tx_tcp_packet(current_TCB, TCP_CNTRL_ACK | TCP_CNTRL_FIN, 0, 0);
					}
					else
						process_data = 1;
   					break;
				case CLOSE_WAIT:
					break;
				case FIN_WAIT_1:
					break;
				case FIN_WAIT_2:
					break;
				case CLOSING:
					break;
				case LAST_ACK:
					if (rx_tcp_hdr->cntrl_bits & TCP_CNTRL_ACK)
					{
						tcp_table[current_TCB].state = CLOSED;
					}
				case CLOSED:
  					delete_TCB(current_TCB);
					break;
				case TIME_WAIT:
					break;
			}
			// connection is established, send data to correct socket
			if (process_data == 1)
				switch (rx_tcp_hdr->dst_port)
				{
					case TCP_PORT_HTTP:
						//rx_http_packet((unsigned char *)tcp_data, tcp_len - sizeof(struct tcp_hdr));
						break;
				}
		}
 	}
	// else discard packet
}

void tx_tcp_packet(unsigned char current_TCB, unsigned char control_bits, unsigned char *szData, unsigned int nLength)
{
	unsigned char tx_buf[BUF_LEN];
	struct ip_hdr *tx_ip_hdr = (struct ip_hdr *)(tx_buf + sizeof(struct eth_hdr));
	struct tcp_hdr *tx_tcp_hdr = (struct tcp_hdr *)(tx_buf + sizeof(struct ip_hdr) + sizeof(struct eth_hdr));
	unsigned char *tcp_data = (unsigned char *)(tx_buf + sizeof(struct eth_hdr) + sizeof(struct ip_hdr) + sizeof(struct tcp_hdr));
	unsigned int *chksum_hdr = (unsigned int *)tx_ip_hdr->srcIP;
	unsigned int tcp_len = nLength + sizeof(struct tcp_hdr);
	unsigned int chksum = tcp_len + IP_TCP;
	int i;
	
	for (i = 0; i < nLength; i++)
	{
		*tcp_data = szData[i];
 		tcp_data++;
	}
	
    tx_tcp_hdr->src_port = tcp_table[current_TCB].local_port;
    tx_tcp_hdr->dst_port = tcp_table[current_TCB].remote_port;
    tx_tcp_hdr->seq = tcp_table[current_TCB].local_seq++;
    if (control_bits & TCP_CNTRL_ACK)
	    tx_tcp_hdr->ack = tcp_table[current_TCB].remote_seq;
	tx_tcp_hdr->cntrl_bits = control_bits;
	
   	for (i = 0; i < 8; i++)
		chksum += *chksum_hdr;

	chksum_hdr = (unsigned int *)tx_tcp_hdr;

	// if the packet length is odd, pad it
	if (tcp_len % 2)
		*((unsigned char *)chksum_hdr + tcp_len) = 0;

	tcp_len = (tcp_len + 1) >> 1;
	for (i = 0; i < tcp_len; i++, chksum_hdr++)
		if (i != 8)
			chksum += *chksum_hdr;
	chksum = ~chksum;

	tx_ip_packet(tx_buf, nLength + sizeof(struct tcp_hdr));
}

