//********************************************************************************************
//
// File : ethernet.c implement for Ethernet Protocol
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
// Ethernet is a large, diverse family of frame-based computer networking technologies 
// that operates at many speeds for local area networks (LANs). 
// The name comes from the physical concept of the ether. 
// It defines a number of wiring and signaling standards for the physical layer, 
// through means of network access at the Media Access Control (MAC)/Data Link Layer, 
// and a common addressing format.
//
// Ethernet has been standardized as IEEE 802.3. 
// The combination of the twisted pair versions of ethernet for connecting end systems to 
// the network with the fiber optic versions for site backbones 
// become the most widespread wired LAN technology in use from the 1990s to the present, 
// largely replacing competing LAN standards such as coaxial cable Ethernet, 
// token ring, FDDI, and ARCNET. In recent years, Wi-Fi, 
// the wireless LAN standardized by IEEE 802.11, 
// has been used instead of Ethernet for many home and small office networks 
// and in addition to Ethernet in larger installations.
//
//
//********************************************************************************************

//********************************************************************************************
//
// Function : eth_generate_header
// Description : generarete ethernet header, contain destination and source MAC address,
// ethernet type.
//
//********************************************************************************************
void eth_generate_header ( BYTE *rxtx_buffer, WORD type, BYTE *dest_mac )
{
	BYTE i;
	//copy the destination mac from the source and fill my mac into src
	for ( i=0; i<sizeof(MAC_ADDR); i++)
	{
		rxtx_buffer[ ETH_DST_MAC_P + i ] = dest_mac[i];
		rxtx_buffer[ ETH_SRC_MAC_P + i ] = avr_mac.byte[i];
	}
	rxtx_buffer[ ETH_TYPE_H_P ] = (type >> 8) & 0xFF;//HIGH(type);
	rxtx_buffer[ ETH_TYPE_L_P ] = type & 0xFF;//LOW(type);
}
//********************************************************************************************
//
// Function : software_checksum
// Description : 
// The Ip checksum is calculated over the ip header only starting
// with the header length field and a total length of 20 bytes
// unitl ip.dst
// You must set the IP checksum field to zero before you start
// the calculation.
// len for ip is 20.
//
// For UDP/TCP we do not make up the required pseudo header. Instead we 
// use the ip.src and ip.dst fields of the real packet:
// The udp checksum calculation starts with the ip.src field
// Ip.src=4bytes,Ip.dst=4 bytes,Udp header=8bytes + data length=16+len
// In other words the len here is 8 + length over which you actually
// want to calculate the checksum.
// You must set the checksum field to zero before you start
// the calculation.
// len for udp is: 8 + 8 + data length
// len for tcp is: 4+4 + 20 + option len + data length
//
// For more information on how this algorithm works see:
// http://www.netfor2.com/checksum.html
// http://www.msc.uky.edu/ken/cs471/notes/chap3.htm
// The RFC has also a C code example: http://www.faqs.org/rfcs/rfc1071.html
//
//********************************************************************************************
WORD software_checksum(BYTE *rxtx_buffer, WORD len, DWORD sum)
{
	// build the sum of 16bit words
	while(len>1)
	{
		sum += 0xFFFF & (*rxtx_buffer<<8|*(rxtx_buffer+1));
		rxtx_buffer+=2;
		len-=2;
	}
	// if there is a byte left then add it (padded with zero)
	if (len)
	{
		sum += (0xFF & *rxtx_buffer)<<8;
	}
	// now calculate the sum over the bytes in the sum
	// until the result is only 16bit long
	while (sum>>16)
	{
		sum = (sum & 0xFFFF)+(sum >> 16);
	}
	// build 1's complement:
	return( (WORD) sum ^ 0xFFFF);
}
