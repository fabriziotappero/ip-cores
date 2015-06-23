//********************************************************************************************
//
// File : tcp.c implement for Transmission Control Protocol
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
// +------------+-----------+------------+----------+
// + MAC header + IP header + TCP header + Data ::: +
// +------------+-----------+------------+----------+
//
// TCP Header
//
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +00+01+02+03+04+05+06+07+08+09+10+11+12+13+14+15+16+17+18+19+20+21+22+23+24+25+26+27+28+29+30+31+
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +               Source Port                     +                Destination Port               +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                        Sequence Number                                        +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                     Acknowledgment Number                                     +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +Data Offset+reserved+   ECN  +  Control Bits   +                  Window size                  +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                 Checksum                      +                Urgent Pointer                 +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                   Options and padding :::                                     +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                             Data :::                                          +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
//
//********************************************************************************************

// global variables ***********************************************************************
static BYTE seqnum=0xa; // my initial tcp sequence number
//static DWORD_BYTES tcp_sequence_number;

//*****************************************************************************************
//
// Function : tcp_get_dlength
// Description : claculate tcp received data length
//
//*****************************************************************************************
WORD tcp_get_dlength ( BYTE *rxtx_buffer )
{
	int dlength, hlength;

	cDebugReg = 0x50;
	dlength = ( rxtx_buffer[ IP_TOTLEN_H_P ] <<8 ) | ( rxtx_buffer[ IP_TOTLEN_L_P ] );
	dlength -= sizeof(IP_HEADER);
	hlength = (rxtx_buffer[ TCP_HEADER_LEN_P ]>>4) * 4; // generate len in bytes;
	dlength -= hlength;
	if ( dlength <= 0 )
		dlength=0;
	
	cDebugReg = 0x51;
	return ((WORD)dlength);
}
//*****************************************************************************************
//
// Function : tcp_get_hlength
// Description : claculate tcp received header length
//
//*****************************************************************************************
BYTE tcp_get_hlength ( BYTE *rxtx_buffer )
{
	cDebugReg = 0x52;
	return ((rxtx_buffer[ TCP_HEADER_LEN_P ]>>4) * 4); // generate len in bytes;
}
//********************************************************************************************
//
// Function : tcp_puts_data_p
// Description : puts data from program memory to tx buffer
//
//********************************************************************************************
WORD tcp_puts_data_p ( BYTE *rxtx_buffer, BYTE *datap, WORD offset )
{
	BYTE ch;
	
	cDebugReg = 0x53;
	while(ch = *datap++)
	{
		rxtx_buffer[ TCP_DATA_P + offset ] = ch;
		offset++;
	}

	return offset;
}
//********************************************************************************************
//
// Function : tcp_puts_data
// Description : puts data from RAM to tx buffer
//
//********************************************************************************************
WORD tcp_puts_data ( BYTE *rxtx_buffer, BYTE *datap, WORD offset )
{
	cDebugReg = 0x54;
	while( *datap )
	{
		rxtx_buffer[ TCP_DATA_P + offset ] = *datap++;
		offset++;
	}

	return offset;
}
//********************************************************************************************
//
// Function : tcp_send_packet
// Description : send tcp packet to network.
//
//********************************************************************************************
void tcp_send_packet (
	BYTE *rxtx_buffer,
	WORD dest_port,
	WORD src_port,
	BYTE flags,
	BYTE max_segment_size,
	BYTE clear_seqack,
	WORD next_ack_num,
	WORD dlength,
	BYTE *dest_mac,
	BYTE *dest_ip )
{
	BYTE i, tseq;
	WORD ck;
	
	cDebugReg = 0x55;
	// generate ethernet header
	eth_generate_header ( rxtx_buffer, ETH_TYPE_IP_V, dest_mac );		
	cDebugReg = 0x56;

	// sequence numbers:
	// add the rel ack num to SEQACK
	if ( next_ack_num )
	{
		for( i=4; i>0; i-- )
		{
			next_ack_num = rxtx_buffer [ TCP_SEQ_P + i - 1] + next_ack_num;
			tseq = rxtx_buffer [ TCP_SEQACK_P + i - 1];
			rxtx_buffer [ TCP_SEQACK_P + i - 1] = 0xff & next_ack_num;

			// copy the acknum sent to us into the sequence number
			rxtx_buffer[ TCP_SEQ_P + i - 1 ] = tseq;

			next_ack_num >>= 8;
		}
	}
	
	cDebugReg = 0x57;
	// initial tcp sequence number
	// setup maximum segment size
	// require to setup first packet is receive or transmit only
	if ( max_segment_size )
	{
		// initial sequence number
		rxtx_buffer[ TCP_SEQ_P + 0 ] = 0;
		rxtx_buffer[ TCP_SEQ_P + 1 ] = 0;
		rxtx_buffer[ TCP_SEQ_P + 2 ] = seqnum;
		rxtx_buffer[ TCP_SEQ_P + 3 ] = 0;
		seqnum += 2;

		// setup maximum segment size
		rxtx_buffer[ TCP_OPTIONS_P + 0 ] = 2;
		rxtx_buffer[ TCP_OPTIONS_P + 1 ] = 4;
		rxtx_buffer[ TCP_OPTIONS_P + 2 ] = HIGH(1408);
		rxtx_buffer[ TCP_OPTIONS_P + 3 ] = LOW(1408);
		// setup tcp header length 24 bytes: 6*32/8 = 24
		rxtx_buffer[ TCP_HEADER_LEN_P ] = 0x60;
		dlength += 4;
	}
	else
	{
		// no options: 20 bytes: 5*32/8 = 20
		rxtx_buffer[ TCP_HEADER_LEN_P ] = 0x50;
	}
	cDebugReg = 0x58;

	// generate ip header and checksum
	ip_generate_header ( rxtx_buffer, (sizeof(IP_HEADER) + sizeof(TCP_HEADER) + dlength), IP_PROTO_TCP_V, dest_ip );
	cDebugReg = 0x59;
	
	// clear sequence ack number before send tcp SYN packet
	if ( clear_seqack )
	{
		rxtx_buffer[ TCP_SEQACK_P + 0 ] = 0;
		rxtx_buffer[ TCP_SEQACK_P + 1 ] = 0;
		rxtx_buffer[ TCP_SEQACK_P + 2 ] = 0;
		rxtx_buffer[ TCP_SEQACK_P + 3 ] = 0;
	}
		
	cDebugReg = 0x5A;
	// setup tcp flags
	rxtx_buffer [ TCP_FLAGS_P ] = flags;
	
	// setup destination port
	rxtx_buffer [ TCP_DST_PORT_H_P ] = (dest_port >> 8 & 0xFF);
	rxtx_buffer [ TCP_DST_PORT_L_P ] = (dest_port & 0xFF);

	// setup source port
	rxtx_buffer [ TCP_SRC_PORT_H_P ] = (src_port >> 8 & 0xFF);
	rxtx_buffer [ TCP_SRC_PORT_L_P ] = src_port & 0xFF;

	// setup maximum windows size
	rxtx_buffer [ TCP_WINDOWSIZE_H_P ] = HIGH((MAX_RX_BUFFER-sizeof(IP_HEADER)-sizeof(ETH_HEADER)));
	rxtx_buffer [ TCP_WINDOWSIZE_L_P ] = LOW((MAX_RX_BUFFER-sizeof(IP_HEADER)-sizeof(ETH_HEADER)));
	
	// setup urgend pointer (not used -> 0)
	rxtx_buffer[ TCP_URGENT_PTR_H_P ] = 0;
	rxtx_buffer[ TCP_URGENT_PTR_L_P ] = 0;

	// clear old checksum and calculate new checksum
	rxtx_buffer[ TCP_CHECKSUM_H_P ] = 0;
	rxtx_buffer[ TCP_CHECKSUM_L_P ] = 0;
	cDebugReg = 0x5B;
	// This is computed as the 16-bit one's complement of the one's complement 
	// sum of a pseudo header of information from the 
	// IP header, the TCP header, and the data, padded 
	// as needed with zero bytes at the end to make a multiple of two bytes. 
	// The pseudo header contains the following fields:
	//
	// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	// +00+01+02+03+04+05+06+07+08+09+10+11+12+13+14+15+16+17+18+19+20+21+22+23+24+25+26+27+28+29+30+31+
	// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	// +                                       Source IP address                                       +
	// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	// +                                     Destination IP address                                    +
	// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	// +           0           +      IP Protocol      +                    Total length               +
	// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
	ck = software_checksum( rxtx_buffer[IP_SRC_IP_P], sizeof(TCP_HEADER)+dlength+8, IP_PROTO_TCP_V + sizeof(TCP_HEADER) + dlength );
	rxtx_buffer[ TCP_CHECKSUM_H_P ] = (ck >> 8) & 0xFF;
	rxtx_buffer[ TCP_CHECKSUM_L_P ] = ck & 0xFF;
	
	cDebugReg = 0x5C;

	// send packet to ethernet media
	enc28j60_packet_send ( &rxtx_buffer, sizeof(ETH_HEADER)+sizeof(IP_HEADER)+sizeof(TCP_HEADER)+dlength );
	cDebugReg = 0x5D;
}
