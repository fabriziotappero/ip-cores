//********************************************************************************************
//
// File : udp.h implement for User Datagram Protocol
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
#define UDP_AVR_PORT_V		3000
#define UDP_AVR_PORT_H_V	(UDP_AVR_PORT_V>>8)
#define UDP_AVR_PORT_L_V	(UDP_AVR_PORT_V&0xff)

#define UDP_SRC_PORT_H_P	0x22
#define UDP_SRC_PORT_L_P	0x23
#define UDP_DST_PORT_H_P	0x24
#define UDP_DST_PORT_L_P	0x25
#define UDP_LENGTH_H_P		0x26
#define UDP_LENGTH_L_P		0x27
#define UDP_CHECKSUM_H_P	0x28
#define UDP_CHECKSUM_L_P	0x29
#define UDP_DATA_P			0x2A

extern void udp_generate_header ( BYTE *rxtx_buffer, WORD dest_port, WORD length );
extern WORD udp_puts_data ( BYTE *rxtx_buffer, BYTE *datap, WORD offset );
// Need to find out alternative method for 8051 access constant from Program memory - Dinesh.A
//extern WORD udp_puts_data_p ( BYTE *rxtx_buffer, PGM_P data, WORD offset );
extern BYTE udp_receive ( BYTE *rxtx_buffer, BYTE *dest_mac, BYTE *dest_ip );
