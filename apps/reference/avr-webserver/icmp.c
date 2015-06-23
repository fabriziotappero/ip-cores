//********************************************************************************************
//
// File : icmp.c implement for Internet Control Message Protocol
//
//********************************************************************************************
//
// Copyright (C) 2007
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
// This program is distributed in the hope that it will be useful, but
//
// WITHOUT ANY WARRANTY;
//
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin St, Fifth Floor, Boston, MA 02110, USA
//
// http://www.gnu.de/gpl-ger.html
//
//********************************************************************************************
#include "includes.h"
//********************************************************************************************
//
// The Internet Control Message Protocol (ICMP) is one of the core protocols of the 
// Internet protocol suite. It is chiefly used by networked computers' 
// operating systems to send error messages---indicating, for instance, 
// that a requested service is not available or that a host or router could not be reached.
//
// ICMP differs in purpose from TCP and UDP in that it is usually not used directly 
// by user network applications. One exception is the ping tool, 
// which sends ICMP Echo Request messages (and receives Echo Response messages) 
// to determine whether a host is reachable and how long packets take to get to and from that host.
//
// +------------+-----------+-------------+----------+
// + MAC header + IP header + ICMP header + Data ::: +
// +------------+-----------+-------------+----------+
//
// ICMP header
//
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +00+01+02+03+04+05+06+07+08+09+10+11+12+13+14+15+16+17+18+19+20+21+22+23+24+25+26+27+28+29+30+31+
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +         Type          +          Code         +               ICMP header checksum            +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                            Data :::                                           +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
//
//********************************************************************************************
unsigned char icmp_id=1;
unsigned char icmp_seq=1;
//*******************************************************************************************
//
// Function : icmp_send_reply
// Description : Send ARP reply packet from ARP request packet
//
//*******************************************************************************************
void icmp_generate_packet ( BYTE *rxtx_buffer )
{
	BYTE i;
	WORD_BYTES ck;
	
	// In send ICMP request case, generate new ICMP data.
	if ( rxtx_buffer[ ICMP_TYPE_P ] == ICMP_TYPE_ECHOREQUEST_V )
	{
		for ( i=0; i<ICMP_MAX_DATA; i++ )
		{
			rxtx_buffer[ ICMP_DATA_P + i ] = 'A' + i;
		}
	}
	// clear icmp checksum
	rxtx_buffer[ ICMP_CHECKSUM_H_P ] = 0;
	rxtx_buffer[ ICMP_CHECKSUM_L_P ] = 0;

	// calculate new checksum.
	// ICMP checksum calculation begin at ICMP type to ICMP data.
	// Before calculate new checksum the checksum field must be zero.
	ck.word = software_checksum ( &rxtx_buffer[ ICMP_TYPE_P ], sizeof(ICMP_PACKET), 0 );
	rxtx_buffer[ ICMP_CHECKSUM_H_P ] = ck.byte.high;
	rxtx_buffer[ ICMP_CHECKSUM_L_P ] = ck.byte.low;
}
//*******************************************************************************************
//
// Function : icmp_send_request
// Description : Send ARP request packet to destination.
//
//*******************************************************************************************
void icmp_send_request ( BYTE *rxtx_buffer, BYTE *dest_mac, BYTE *dest_ip )
{	
	// set ethernet header
	eth_generate_header ( rxtx_buffer, (WORD_BYTES){ETH_TYPE_IP_V}, dest_mac );
	
	// generate ip header and checksum
	ip_generate_header (	rxtx_buffer, (WORD_BYTES){sizeof(IP_HEADER) + sizeof(ICMP_PACKET)}, IP_PROTO_ICMP_V, dest_ip );

	// generate icmp packet and checksum
	rxtx_buffer[ ICMP_TYPE_P ] = ICMP_TYPE_ECHOREQUEST_V;
	rxtx_buffer[ ICMP_CODE_P ] = 0;
	rxtx_buffer[ ICMP_IDENTIFIER_H_P ] = icmp_id;
	rxtx_buffer[ ICMP_IDENTIFIER_L_P ] = 0;
	rxtx_buffer[ ICMP_SEQUENCE_H_P ] = icmp_seq;
	rxtx_buffer[ ICMP_SEQUENCE_L_P ] = 0;
	icmp_id++;
	icmp_seq++;
	icmp_generate_packet ( rxtx_buffer );	

	// send packet to ethernet media
	enc28j60_packet_send ( rxtx_buffer, sizeof(ETH_HEADER) + sizeof(IP_HEADER) + sizeof(ICMP_PACKET) );
}
//*******************************************************************************************
//
// Function : icmp_send_reply
// Description : Send ARP reply packet to destination.
//
//*******************************************************************************************
BYTE icmp_send_reply ( BYTE *rxtx_buffer, BYTE *dest_mac, BYTE *dest_ip )
{
	
	// check protocol is icmp or not?
	if ( rxtx_buffer [ IP_PROTO_P ] != IP_PROTO_ICMP_V )
		return 0;
	
	// check icmp packet type is echo request or not?
	if ( rxtx_buffer [ ICMP_TYPE_P ] != ICMP_TYPE_ECHOREQUEST_V )
		return 0;

	// set ethernet header
	eth_generate_header ( rxtx_buffer, (WORD_BYTES){ETH_TYPE_IP_V}, dest_mac );
	
	// generate ip header and checksum
	ip_generate_header ( rxtx_buffer, (WORD_BYTES){(rxtx_buffer[IP_TOTLEN_H_P]<<8)|rxtx_buffer[IP_TOTLEN_L_P]}, IP_PROTO_ICMP_V, dest_ip );

	// generate icmp packet
	rxtx_buffer[ ICMP_TYPE_P ] = ICMP_TYPE_ECHOREPLY_V;
	icmp_generate_packet ( rxtx_buffer );

	// send packet to ethernet media
	enc28j60_packet_send ( rxtx_buffer, sizeof(ETH_HEADER) + sizeof(IP_HEADER) + sizeof(ICMP_PACKET) );
	return 1;
}
//*******************************************************************************************
//
// Function : icmp_ping_server
// Description : Send ARP reply packet to destination.
//
//*******************************************************************************************
BYTE icmp_ping ( BYTE *rxtx_buffer, BYTE *dest_mac, BYTE *dest_ip )
{
	BYTE i;
	WORD dlength;
	
	// destination ip was not found on network.
	if ( arp_who_is ( rxtx_buffer, dest_mac, dest_ip ) == 0 )
		return 0;

	// send icmp request packet (ping) to server
	icmp_send_request ( rxtx_buffer, (BYTE*)&server_mac, dest_ip );

	for ( i=0; i<10; i++ )
	{
		_delay_ms( 10 );
		dlength = enc28j60_packet_receive( rxtx_buffer, MAX_RXTX_BUFFER );

		if ( dlength )
		{
			// check protocol is icmp or not?
			if ( rxtx_buffer [ IP_PROTO_P ] != IP_PROTO_ICMP_V )
				continue;
	
			// check icmp packet type is echo reply or not?
			if ( rxtx_buffer [ ICMP_TYPE_P ] != ICMP_TYPE_ECHOREPLY_V )
				continue;

			return 1;
		}
	}

	// time out
	return 0;
}
