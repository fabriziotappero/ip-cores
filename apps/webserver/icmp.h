//********************************************************************************************
//
// File : icmp.h implement for Internet Control Message Protocol
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
#define ICMP_TYPE_ECHOREPLY_V 	0
#define ICMP_TYPE_ECHOREQUEST_V 8
#define ICMP_PACKET_LEN			40

// icmp buffer position
#define ICMP_TYPE_P				0x22
#define ICMP_CODE_P				0x23
#define ICMP_CHECKSUM_H_P		0x24
#define ICMP_CHECKSUM_L_P		0x25
#define ICMP_IDENTIFIER_H_P		0x26
#define ICMP_IDENTIFIER_L_P		0x27
#define ICMP_SEQUENCE_H_P		0x28
#define ICMP_SEQUENCE_L_P		0x29
#define ICMP_DATA_P				0x2A

//********************************************************************************************
//
// Prototype function
//
//********************************************************************************************
extern BYTE icmp_send_reply ( BYTE *rx_buffer, BYTE **tx_buffer, BYTE *dest_mac, BYTE *dest_ip );
extern void icmp_send_request ( BYTE *rx_buffer, BYTE **tx_buffer, BYTE *dest_mac, BYTE *dest_ip );
extern BYTE icmp_ping ( BYTE *rx_buffer, BYTE **tx_buffer, BYTE *dest_mac, BYTE *dest_ip );
extern void _delay_ms( int iDelay );
