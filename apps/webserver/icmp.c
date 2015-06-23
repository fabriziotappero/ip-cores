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
void icmp_generate_packet ( BYTE *rx_buffer, BYTE *tx_buffer )
{
	BYTE i;
	WORD ck;
	
	// In send ICMP request case, generate new ICMP data.
	if ( rx_buffer[ ICMP_TYPE_P ] == ICMP_TYPE_ECHOREQUEST_V )
	{
	        cDebugReg = 0x20; // Debug 1 */	
		for ( i=0; i<ICMP_MAX_DATA; i++ )
		{
			tx_buffer[ ICMP_DATA_P + i ] = 'A' + i;
		}
	}
	cDebugReg = 0x21; // Debug 1 */	
	// clear icmp checksum
	tx_buffer[ ICMP_CHECKSUM_H_P ] = 0;
	tx_buffer[ ICMP_CHECKSUM_L_P ] = 0;

	// calculate new checksum.
	// ICMP checksum calculation begin at ICMP type to ICMP data.
	// Before calculate new checksum the checksum field must be zero.
	ck = software_checksum ( tx_buffer[ ICMP_TYPE_P ], sizeof(ICMP_PACKET), 0 );
	cDebugReg = 0x22; // Debug 1 */	
	tx_buffer[ ICMP_CHECKSUM_H_P ] = (ck >> 8 ) & 0xFF;
	tx_buffer[ ICMP_CHECKSUM_L_P ] = ck & 0xFF;
}
//*******************************************************************************************
//
// Function : icmp_send_request
// Description : Send ARP request packet to destination.
//
//*******************************************************************************************
void icmp_send_request ( BYTE *rx_buffer, BYTE **tx_buffer, BYTE *dest_mac, BYTE *dest_ip )
{	
	// set ethernet header
	eth_generate_header ( *tx_buffer, ETH_TYPE_IP_V, dest_mac );
	
	// generate ip header and checksum
	ip_generate_header ( *tx_buffer, sizeof(IP_HEADER) + sizeof(ICMP_PACKET), IP_PROTO_ICMP_V, dest_ip );

	// generate icmp packet and checksum
	*tx_buffer[ ICMP_TYPE_P ] = ICMP_TYPE_ECHOREQUEST_V;
	*tx_buffer[ ICMP_CODE_P ] = 0;
	*tx_buffer[ ICMP_IDENTIFIER_H_P ] = icmp_id;
	*tx_buffer[ ICMP_IDENTIFIER_L_P ] = 0;
	*tx_buffer[ ICMP_SEQUENCE_H_P ] = icmp_seq;
	*tx_buffer[ ICMP_SEQUENCE_L_P ] = 0;
	icmp_id++;
	icmp_seq++;
	icmp_generate_packet ( rx_buffer, *tx_buffer );	

	// send packet to ethernet media
	enc28j60_packet_send ( &(*tx_buffer), sizeof(ETH_HEADER) + sizeof(IP_HEADER) + sizeof(ICMP_PACKET) );
}
//*******************************************************************************************
//
// Function : icmp_send_reply
// Description : Send ARP reply packet to destination.
//
//*******************************************************************************************
BYTE icmp_send_reply ( BYTE *rx_buffer, BYTE **tx_buffer, BYTE *dest_mac, BYTE *dest_ip )
{
	
	// check protocol is icmp or not?
	if ( rx_buffer [ IP_PROTO_P ] != IP_PROTO_ICMP_V )
		return 0;
	
	cDebugReg = 0x23; // Debug 1 */	
	// check icmp packet type is echo request or not?
	if ( rx_buffer [ ICMP_TYPE_P ] != ICMP_TYPE_ECHOREQUEST_V )
		return 0;
	cDebugReg = 0x24; // Debug 1 */	

	// set ethernet header
	eth_generate_header ( *tx_buffer, ETH_TYPE_IP_V, dest_mac );

	cDebugReg = 0x25; // Debug 1 */	
	
	// generate ip header and checksum
	ip_generate_header ( *tx_buffer, (rx_buffer[IP_TOTLEN_H_P]<<8)|rx_buffer[IP_TOTLEN_L_P], IP_PROTO_ICMP_V, dest_ip );

	cDebugReg = 0x26; // Debug 1 */	
	// generate icmp packet
	*tx_buffer[ ICMP_TYPE_P ] = ICMP_TYPE_ECHOREPLY_V;
	icmp_generate_packet ( rx_buffer, *tx_buffer );

	cDebugReg = 0x27; // Debug 1 */	
	// send packet to ethernet media
	enc28j60_packet_send ( &(*tx_buffer), sizeof(ETH_HEADER) + sizeof(IP_HEADER) + sizeof(ICMP_PACKET) );
	cDebugReg = 0x28; // Debug 1 */	
	return 1;
}
//*******************************************************************************************
//
// Function : icmp_ping_server
// Description : Send ARP reply packet to destination.
//
//*******************************************************************************************
BYTE icmp_ping ( BYTE *rx_buffer, BYTE **tx_buffer, BYTE *dest_mac, BYTE *dest_ip )
{
	BYTE i;
	WORD dlength;
	
	// destination ip was not found on network.
	if ( arp_who_is ( rx_buffer, dest_mac, dest_ip ) == 0 )
		return 0;

	cDebugReg = 0x29; // Debug 1 */	
	// send icmp request packet (ping) to server
	icmp_send_request ( rx_buffer, &(*tx_buffer), (BYTE*)&server_mac, dest_ip );

	for ( i=0; i<10; i++ )
	{
		_delay_ms( 10 );
		dlength = enc28j60_packet_receive( &(*tx_buffer), MAX_RXTX_BUFFER );

		if ( dlength )
		{
			// check protocol is icmp or not?
			if ( rx_buffer [ IP_PROTO_P ] != IP_PROTO_ICMP_V )
				continue;
	                cDebugReg = 0x2A; // Debug 1 */	
	
			// check icmp packet type is echo reply or not?
			if ( rx_buffer [ ICMP_TYPE_P ] != ICMP_TYPE_ECHOREPLY_V )
				continue;
	                cDebugReg = 0x2B; // Debug 1 */	

			return 1;
		}
	}

	// time out
	return 0;
}
