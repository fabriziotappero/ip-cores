//********************************************************************************************
//
// File : arp.c implement for Address Resolution Protocol
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
// Address Resolution Protocol (ARP) is the method for finding a host's hardware address 
// when only its network layer address is known. 
// Due to the overwhelming prevalence of IPv4 and Ethernet, 
// ARP is primarily used to translate IP addresses to Ethernet MAC addresses. 
// It is also used for IP over other LAN technologies, 
// such as Token Ring, FDDI, or IEEE 802.11, and for IP over ATM.
//
// ARP is used in four cases of two hosts communicating:
// 
//   1. When two hosts are on the same network and one desires to send a packet to the other
//   2. When two hosts are on different networks and must use a gateway/router to reach the other host
//   3. When a router needs to forward a packet for one host through another router
//   4. When a router needs to forward a packet from one host to the destination host on the same network
//
// +------------+------------+-----------+
// + MAC header + ARP header +	Data ::: +
// +------------+------------+-----------+
// 
// ARP header
//
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +00+01+02+03+04+05+06+07+08+09+10+11+12+13+14+15+16+17+18+19+20+21+22+23+24+25+26+27+28+29+30+31+
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +             Hardware type 	                   +                    Protocol type              +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// + HardwareAddressLength + ProtocolAddressLength +	                 Opcode                    +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                   Source hardware address :::                                 +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                   Source protocol address :::                                 +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                Destination hardware address :::                               +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                Destination protocol address :::                               +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                          Data :::                                             +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
//
//********************************************************************************************

//********************************************************************************************
//
// Function : arp_generate_packet
// Description : generate arp packet
//
//********************************************************************************************
void arp_generate_packet ( BYTE *rxtx_buffer, BYTE *dest_mac, BYTE *dest_ip )
{
	unsigned char i;
	
	// setup hardware type to ethernet 0x0001
	rxtx_buffer[ ARP_HARDWARE_TYPE_H_P ] = ARP_HARDWARE_TYPE_H_V;
	rxtx_buffer[ ARP_HARDWARE_TYPE_L_P ] = ARP_HARDWARE_TYPE_L_V;
	
	// setup protocol type to ip 0x0800
	rxtx_buffer[ ARP_PROTOCOL_H_P ] = ARP_PROTOCOL_H_V;
	rxtx_buffer[ ARP_PROTOCOL_L_P ] = ARP_PROTOCOL_L_V;

	// setup hardware length to 0x06
	rxtx_buffer[ ARP_HARDWARE_SIZE_P ] = ARP_HARDWARE_SIZE_V;

	// setup protocol length to 0x04
	rxtx_buffer[ ARP_PROTOCOL_SIZE_P ] = ARP_PROTOCOL_SIZE_V;

	// setup arp destination and source mac address
	for ( i=0; i<sizeof(MAC_ADDR); i++)
	{
		rxtx_buffer[ ARP_DST_MAC_P + i ] = dest_mac[i];
		rxtx_buffer[ ARP_SRC_MAC_P + i ] = avr_mac.byte[i];
	}
	
	// setup arp destination and source ip address
	for ( i=0; i<sizeof(IP_ADDR); i++)
	{
		rxtx_buffer[ ARP_DST_IP_P + i ] = dest_ip[i];
		rxtx_buffer[ ARP_SRC_IP_P + i ] = avr_ip.byte[i];
	}
}
//********************************************************************************************
//
// Function : arp_send_request
// Description : send arp request packet (who is?) to network.
//
//********************************************************************************************
void arp_send_request ( BYTE *rxtx_buffer, BYTE *dest_ip )
{
	unsigned char i;
	MAC_ADDR dest_mac;

	// generate ethernet header
	for ( i=0; i<sizeof(MAC_ADDR); i++)
		dest_mac.byte[i] = 0xff;
	eth_generate_header ( rxtx_buffer, ETH_TYPE_ARP_V, (BYTE*)&dest_mac );

	// generate arp packet
	for ( i=0; i<sizeof(MAC_ADDR); i++)
		dest_mac.byte[i] = 0x00;
	
	// set arp opcode is request
	rxtx_buffer[ ARP_OPCODE_H_P ] = ARP_OPCODE_REQUEST_H_V;
	rxtx_buffer[ ARP_OPCODE_L_P ] = ARP_OPCODE_REQUEST_L_V;
	arp_generate_packet ( rxtx_buffer, (BYTE*)&dest_mac, dest_ip );

	cDebugReg = 0x10; // Debug 1 
	
	// send arp packet to network
	enc28j60_packet_send ( &rxtx_buffer, sizeof(ETH_HEADER) + sizeof(ARP_PACKET) );
	cDebugReg = 0x11; // Debug 1
}
//*******************************************************************************************
//
// Function : arp_packet_is_arp
// Description : check received packet, that packet is match with arp and avr ip or not?
//
//*******************************************************************************************
BYTE arp_packet_is_arp ( BYTE *rxtx_buffer, WORD opcode )
{
	BYTE i;

	// if packet type is not arp packet exit from function
	if( rxtx_buffer[ ETH_TYPE_H_P ] != ETH_TYPE_ARP_H_V || rxtx_buffer[ ETH_TYPE_L_P ] != ETH_TYPE_ARP_L_V)
		return 0;
	
	cDebugReg = 0x12; // Debug 1
	// check arp request opcode
	if ( rxtx_buffer[ ARP_OPCODE_H_P ] != ((opcode >> 8) & 0xFF) || 
       rxtx_buffer[ ARP_OPCODE_L_P ] != (opcode & 0xFF) )
		return 0;
	
	cDebugReg = 0x13; // Debug 1
	// if destination ip address in arp packet not match with avr ip address
	for ( i=0; i<sizeof(IP_ADDR); i++ )
	{
		if ( rxtx_buffer[ ARP_DST_IP_P + i] != avr_ip.byte[i] )
			return 0;
	}
	cDebugReg = 0x14; // Debug 1
	return 1;
}
//*******************************************************************************************
//
// Function : arp_send_reply
// Description : Send reply if recieved packet is ARP and IP address is match with avr_ip
//
//*******************************************************************************************
void arp_send_reply ( BYTE *rx_buffer, BYTE **tx_buffer, BYTE *dest_mac )
{
	// generate ethernet header
	eth_generate_header ( *tx_buffer, ETH_TYPE_ARP_V, dest_mac );

	cDebugReg = 0x15; // Debug 1 
	// change packet type to echo reply
	*tx_buffer[ARP_OPCODE_H_P] = ARP_OPCODE_REPLY_H_V;
	*tx_buffer[ARP_OPCODE_L_P] = ARP_OPCODE_REPLY_L_V;
	cDebugReg = 0x16; // Debug 1 
	arp_generate_packet ( *tx_buffer, dest_mac, rx_buffer[ ARP_SRC_IP_P ] );
	
	cDebugReg = 0x17; // Debug 1 
	// send arp packet
	enc28j60_packet_send ( &(*tx_buffer), sizeof(ETH_HEADER) + sizeof(ARP_PACKET) );
}
//*******************************************************************************************
//
// Function : arp_who_is
// Description : send arp request to destination ip, and save destination mac to dest_mac.
// call this function to find the destination mac address before send other packet.
//
//*******************************************************************************************
BYTE arp_who_is ( BYTE *rxtx_buffer, BYTE *dest_mac, BYTE *dest_ip )
{
	BYTE i;
	WORD dlength;

	// send arp request packet to network
	arp_send_request ( rxtx_buffer, dest_ip );
	cDebugReg = 0x18; // Debug 1 

	for ( i=0; i<10; i++ )
	{
		// Time out 10x10ms = 100ms
		_delay_ms ( 10 );
		dlength = enc28j60_packet_receive( &rxtx_buffer, MAX_RXTX_BUFFER );

		// destination ip address was found on network
		if ( dlength )
		{
			if ( arp_packet_is_arp ( rxtx_buffer, ARP_OPCODE_REPLY_V ) )
			{
				// copy destination mac address from arp reply packet to destination mac address
				memcpy ( dest_mac, &rxtx_buffer[ ETH_SRC_MAC_P ], sizeof(MAC_ADDR) );
				return 1;
			}
		}
	}
	cDebugReg = 0x19; // Debug 1 
	
	// destination ip was not found on network
	return 0;
}

