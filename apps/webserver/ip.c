//********************************************************************************************
//
// File : ip.c implement for Internet Protocol
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
// +------------+-----------+----------+
// + MAC header + IP header + Data ::: +
// +------------+-----------+----------+
//
// IP Header
//
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +00+01+02+03+04+05+06+07+08+09+10+11+12+13+14+15+16+17+18+19+20+21+22+23+24+25+26+27+28+29+30+31+
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// + Version   +   IHL     +             TOS       +                Total length                   +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                  Identification               +  Flags +          Fragment offset             +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +          TTL          +       Protocol        +                Header checksum                +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                      Source IP address                                        +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                    Destination IP address                                     +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                    Options and padding :::                                    +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
//
//********************************************************************************************
//static WORD ip_identfier=1;
WORD ip_identfier;
//********************************************************************************************
//
// Function : ip_generate_packet
// Description : generate all ip header
//
//********************************************************************************************
void ip_generate_header ( BYTE *rxtx_buffer, WORD total_length, BYTE protocol, BYTE *dest_ip )
{
	BYTE i;
	WORD_BYTES ck;
	
	// set ipv4 and header length
	rxtx_buffer[ IP_P ] = IP_V4_V | IP_HEADER_LENGTH_V;

	// set TOS to default 0x00
	rxtx_buffer[ IP_TOS_P ] = 0x00;

	// set total length
	rxtx_buffer [ IP_TOTLEN_H_P ] = (total_length >> 8) & 0xFF;
	rxtx_buffer [ IP_TOTLEN_L_P ] = total_length & 0xFF;
	
	// set packet identification
	rxtx_buffer [ IP_ID_H_P ] = (ip_identfier >> 8) & 0xFF;
	rxtx_buffer [ IP_ID_L_P ] = ip_identfier & 0xFF;
	ip_identfier++;
	
	// set fragment flags	
	rxtx_buffer [ IP_FLAGS_H_P ] = 0x00;
	rxtx_buffer [ IP_FLAGS_L_P ] = 0x00;
	
	// set Time To Live
	rxtx_buffer [ IP_TTL_P ] = 128;
	
	// set ip packettype to tcp/udp/icmp...
	rxtx_buffer [ IP_PROTO_P ] = protocol;
	
	// set source and destination ip address
	for ( i=0; i<4; i++ )
	{
		rxtx_buffer[ IP_DST_IP_P + i ] = dest_ip[i];
		rxtx_buffer[ IP_SRC_IP_P + i ] = avr_ip.byte[ i ];
	}
	
	// clear the 2 byte checksum
	rxtx_buffer[ IP_CHECKSUM_H_P ] = 0;
	rxtx_buffer[ IP_CHECKSUM_L_P ] = 0;

	// fill checksum value
	// calculate the checksum:
	ck.word = software_checksum ( &rxtx_buffer[ IP_P ], sizeof(IP_HEADER), 0 );
	rxtx_buffer[ IP_CHECKSUM_H_P ] = ck.byte.high;
	rxtx_buffer[ IP_CHECKSUM_L_P ] = ck.byte.low;
}
//********************************************************************************************
//
// Function : ip_check_ip
// Description : Check incoming packet
//
//********************************************************************************************
BYTE ip_packet_is_ip ( BYTE *rxtx_buffer )
{
	unsigned char i;
	
	cDebugReg = 0x30; // Debug 1 */	
	// if ethernet type is not ip
	if ( rxtx_buffer[ ETH_TYPE_H_P ] != ETH_TYPE_IP_H_V || rxtx_buffer[ ETH_TYPE_L_P ] != ETH_TYPE_IP_L_V)
		return 0;
	
	cDebugReg = 0x31; // Debug 1 */	
	// if ip packet not send to avr
	for ( i=0; i<sizeof(IP_ADDR); i++ )
	{
		if ( rxtx_buffer[ IP_DST_IP_P + i ] != avr_ip.byte[i] )
			return 0;
	}
	cDebugReg = 0x32; // Debug 1 */	
	
	// destination ip address match with avr ip address
	return 1;
}
