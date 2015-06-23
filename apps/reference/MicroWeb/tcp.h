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

// tcp.h: structures for tcp connections

#ifndef H__TCP
#define H__TCP

#define TCP_MAX_CONN 1

enum tcp_state
{
	LISTEN = 1,
	SYN_SENT,
	SYN_RECVD,
	ESTABLISHED,
	FIN_WAIT_1,
	FIN_WAIT_2,
	CLOSE_WAIT,
	CLOSING,
	LAST_ACK,
	TIME_WAIT,
	CLOSED
};

enum tcp_cntrl_flags
{
	TCP_CNTRL_FIN = 0x01,
	TCP_CNTRL_SYN = 0x02,
	TCP_CNTRL_RST = 0x04,
	TCP_CNTRL_PSH = 0x08,
	TCP_CNTRL_ACK = 0x10,
	TCP_CNTRL_URG = 0x20
};

struct tcp_TCB
{
	unsigned int local_port;		// Local port number
	unsigned int remote_port;	// Remote port number
	unsigned char remote_addr[4];	// Remote IP address
	unsigned char state;		// Our current state
	unsigned char local_seq;		// Local sequence number
	unsigned char remote_seq;	// Remote sequence number
};

#define TCP_PORT_HTTP 80

#define TCP_START_SEQ 50

void tcp_init(void);
void rx_tcp_packet(unsigned char *rx_buffer);
void tx_tcp_packet(unsigned char current_TCB, unsigned char control_bits, unsigned char *szData, unsigned int nLength);

#endif

