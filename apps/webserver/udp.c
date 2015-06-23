//********************************************************************************************
//
// File : udp.c implement for User Datagram Protocol
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

extern union flag1
{
	BYTE byte;
	struct
	{
		unsigned char key_is_executed:1;
		unsigned char update_display:1;
		unsigned char lcd_busy:1;
		unsigned char key_press:1;
		unsigned char send_temp:1;
		unsigned char syn_is_sent:1;
		unsigned char syn_is_received:1;
		unsigned char send_temp_timeout:1;
	}bits;
}flag1;

//********************************************************************************************
// The User Datagram Protocol offers only a minimal transport service 
// -- non-guaranteed datagram delivery 
// -- and gives applications direct access to the datagram service of the IP layer. 
// UDP is used by applications that do not require the level of service of TCP or 
// that wish to use communications services (e.g., multicast or broadcast delivery) 
// not available from TCP.
//
// +------------+-----------+-------------+----------+
// + MAC header + IP header +  UDP header + Data ::: +
// +------------+-----------+-------------+----------+
//
// UDP header
//
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +00+01+02+03+04+05+06+07+08+09+10+11+12+13+14+15+16+17+18+19+20+21+22+23+24+25+26+27+28+29+30+31+
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                  Source port                  +               Destination port                +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                  Length                       +               Checksum                        +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
// +                                           Data :::                                            +
// +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
//
//********************************************************************************************
//
// Function : udp_generate_header
// Argument : BYTE *rxtx_buffer is a pointer point to UDP tx buffer
//			  WORD dest_port is a destiantion port
//			  WORD length is a UDP header and data length
// Return value : None
//
// Description : generate udp header
//
//********************************************************************************************
void udp_generate_header ( BYTE *rxtx_buffer, WORD dest_port, WORD length )
{
	WORD ck;

	// setup source port, default value is 3000
	rxtx_buffer[UDP_SRC_PORT_H_P] = UDP_AVR_PORT_H_V;
	rxtx_buffer[UDP_SRC_PORT_L_P] = UDP_AVR_PORT_L_V;

	// setup destination port
	rxtx_buffer[UDP_DST_PORT_H_P] = (dest_port >> 8) & 0xFF;
	rxtx_buffer[UDP_DST_PORT_L_P] = dest_port & 0xFF;

	// setup udp length
	rxtx_buffer[UDP_LENGTH_H_P] = (length >> 8) & 0xFF;
	rxtx_buffer[UDP_LENGTH_L_P] = length & 0xFF;

	// setup udp checksum
	rxtx_buffer[UDP_CHECKSUM_H_P] = 0;
	rxtx_buffer[UDP_CHECKSUM_L_P] = 0;
	// length+8 for source/destination IP address length (8-bytes)
	ck = software_checksum ( (BYTE*)&rxtx_buffer[IP_SRC_IP_P], length+8, length+IP_PROTO_UDP_V);
	rxtx_buffer[UDP_CHECKSUM_H_P] = (ck >> 8) & 0xFF;
	rxtx_buffer[UDP_CHECKSUM_L_P] = ck >> 0xFF;
}
//********************************************************************************************
//
// Function : udp_puts_data
// Description : puts data from RAM to UDP tx buffer
//
//********************************************************************************************
WORD udp_puts_data ( BYTE *rxtx_buffer, BYTE *datap, WORD offset )
{
	while( *datap )
	{
		rxtx_buffer[ UDP_DATA_P + offset ] = *datap++;
		offset++;
	}

	return offset;
}
//********************************************************************************************
//
// Function : udp_puts_data_p
// Description : puts data from program memory to tx buffer
//
//********************************************************************************************
/***********************
   Dinesh-A
   Need to find out alternative method for 8051
WORD udp_puts_data_p ( BYTE *rxtx_buffer, PGM_P data, WORD offset )
{
	BYTE ch;
	
	while( (ch = pgm_read_byte(data++)) )
	{
		rxtx_buffer[ UDP_DATA_P + offset ] = ch;
		offset++;
	}

	return offset;
}
************************/
//********************************************************************************************
//
// Function : udp_receive
// Argument : BYTE *rxtx_buffer is a pointer, point to UDP tx buffer
//			  BYTE *dest_mac is a pointer, point to destiantion MAC address
//			  BYTE *dest_ip is a pointer, point to destiantion IP address
// Return value : if received packet is UDP and destination port matching with AVR port, return true
//				  other return false
//
// Description : check received packet and process UDP command.
//
//********************************************************************************************
BYTE udp_receive ( BYTE *rxtx_buffer, BYTE *dest_mac, BYTE *dest_ip )
{
	WORD_BYTES dlength, adc0;
	BYTE generic_buf[64], temp, count_time_temp[3], tmp;

	        cDebugReg = 0x60; // Debug 1 
	// check UDP packet and check destination port
	if ( rxtx_buffer[IP_PROTO_P] != IP_PROTO_UDP_V || rxtx_buffer[UDP_DST_PORT_H_P] != UDP_AVR_PORT_H_V || rxtx_buffer[ UDP_DST_PORT_L_P ] != UDP_AVR_PORT_L_V ) {
	        cDebugReg = 0x61; // Debug 1 
		return 0;
	}	
	
	// check UDP command, UDP command are first and second byte
	// "GA" command is Get All command, AVR will be send all data to AVRnet CPannel
	// Response format is OKLLADC0TTEHHMMAAA.AAA.AAA.AAA;SSS.SSS.SSS.SSS;\r\n
	// LL is LED1 and LED2
	// ADC0 is ADC0 value
	// TT is temperature
	// E is send temp enable/disable
	// HH is hours for send temp
	// MM is minutes for send temp
	// AAA.AAA.AAA.AAA is an AVR IP address
	// SSS.SSS.SSS.SSS is a Server IP address
	// ';' is end of IP address
	// \r\n is end of command
	// for example : GA100512250010010.1.1.1;10.1.1.76\r\n = LED1 on, LED2 off, ADC0 0512, Temp 25, Disable send temp, Hour 01, Min 00
	if ( rxtx_buffer[UDP_DATA_P] == 'G' && rxtx_buffer[UDP_DATA_P+1] == 'A' && rxtx_buffer[UDP_DATA_P+2] == '\r' && rxtx_buffer[UDP_DATA_P+3] == '\n')
	{
	        cDebugReg = 0x62; 
	}
	// "ST" command is set send temperature configuration command
	// "ST" command format is STEHHMM\r\n
	// E is send temp enable/disable
	// HH is hours for send temp
	// MM is minutes for send temp
	// \r\n is end of command
	// for example : ST10115\r\n = Enable send temp, 1-Hour, 15-Minutes
	else if ( rxtx_buffer[UDP_DATA_P] == 'S' && rxtx_buffer[UDP_DATA_P+1] == 'T' && rxtx_buffer[UDP_DATA_P+7] == '\r' && rxtx_buffer[UDP_DATA_P+8] == '\n')
	{
	        cDebugReg = 0x63; 
		dlength.word = udp_puts_data ( rxtx_buffer, "STOK\r\n", 0 );
	}
	// "SI" command is set AVR IP address command
	// "SI" command format is SIAAA.AAA.AAA.AAA;SSS.SSS.SSS.SSS;\r\n
	// AAA.AAA.AAA.AAA is an AVR IP address (variable length)
	// SSS.SSS.SSS.SSS is a Server IP address (variable length)
	// ';' end of ip address
	// \r\n is end of command
	// for example : SI10.1.1.1;10.1.1.76;\r\n
	else if ( rxtx_buffer[UDP_DATA_P] == 'S' && rxtx_buffer[UDP_DATA_P+1] == 'I' )
	{
	        cDebugReg = 0x64; 
		// find \r\n
		for(tmp=UDP_DATA_P; tmp<UDP_DATA_P+128; tmp++)
		{
	                cDebugReg = 0x65; 
			if(rxtx_buffer[UDP_DATA_P+tmp]=='\r' && rxtx_buffer[UDP_DATA_P+tmp+1]=='\n')
			{
	                        cDebugReg = 0x66; 
				temp = 0;
				break;
			}
		}
		if(temp==0)
		{
	                cDebugReg = 0x67; 
		}
		else
		{
	                cDebugReg = 0x68; 
			dlength.word = udp_puts_data ( rxtx_buffer, "ERROR\r\n", 0 );
		}
	}
	// "WL" command is Write LCD command
	// "WL" command format is WL1111111111111111;2222222222222222;\r\n
	// 1111111111111111 is 1'st line character (variable length, max is 16)
	// 2222222222222222 is 2'nd line character (variable length, max is 16)
	// ';' end of character
	// \r\n is end of command
	// for example : WLHello World!;I'm AVRnet;\r\n
	else if ( rxtx_buffer[UDP_DATA_P] == 'W' && rxtx_buffer[UDP_DATA_P+1] == 'L')
	{
	        cDebugReg = 0x69; 
		// find \r\n
		for(tmp=UDP_DATA_P; tmp<UDP_DATA_P+128; tmp++)
		{
	                cDebugReg = 0x6A; 
			if(rxtx_buffer[UDP_DATA_P+tmp]=='\r' && rxtx_buffer[UDP_DATA_P+tmp+1]=='\n')
			{
	                        cDebugReg = 0x6B; 
				temp = 0;
				break;
			}
		}
		if(temp==0)
		{
	                cDebugReg = 0x6C; 
			tmp=0;
			// find end of 1'st line and replace it with '\n'
			while( rxtx_buffer[UDP_DATA_P+tmp] != ';' ) tmp++;
			rxtx_buffer[UDP_DATA_P+tmp] = '\n';
			// find end of 1'st line and replace it with '\0'
			while( rxtx_buffer[UDP_DATA_P+tmp] != ';' ) tmp++;
			rxtx_buffer[UDP_DATA_P+tmp] = '\0';
			// print string to LCD
			lcd_putc ( '\f' );
			lcd_print ( (BYTE*)&rxtx_buffer[UDP_DATA_P+2] );
			flag1.bits.lcd_busy = 1;

			// send command response to client
			dlength.word = udp_puts_data ( rxtx_buffer, "WLOK\r\n", 0 );
		}
		else
		{
	                cDebugReg = 0x6D; 
			dlength.word = udp_puts_data ( rxtx_buffer, "ERROR\r\n", 0 );
		}
	}
	// "SL" command, is set LED1, LED2 command
	// "SL" command format is SL12\r\n
	// 1 is on/off command for LED1 '1' = ON, '0' = OFF
	// 2 is on/off command for LED2 '1' = ON, '0' = OFF
	// \r\n is end of command
	else if(rxtx_buffer[UDP_DATA_P]=='S' && rxtx_buffer[UDP_DATA_P+1]=='L' && rxtx_buffer[UDP_DATA_P+4]=='\r' && rxtx_buffer[UDP_DATA_P+5]=='\n')
	{
	        cDebugReg = 0x6E; 
		// send command response
		dlength.word = udp_puts_data ( rxtx_buffer, "SLOK\r\n", 0 );
	}
	else
	{
	        cDebugReg = 0x6F; 
		// unknown command, send "ERROR" to client
		dlength.word = udp_puts_data ( rxtx_buffer, "ERROR\r\n", 0 );
	}

	cDebugReg = 0x70; 
	// set ethernet header
	eth_generate_header (rxtx_buffer, ETH_TYPE_IP_V, dest_mac );
	
	cDebugReg = 0x71; 
	// generate ip header and checksum
	ip_generate_header (rxtx_buffer, sizeof(IP_HEADER)+sizeof(UDP_HEADER)+dlength.word, IP_PROTO_UDP_V, dest_ip );

	cDebugReg = 0x72; 
	// generate UDP header
	udp_generate_header (rxtx_buffer, (rxtx_buffer[UDP_SRC_PORT_H_P]<<8)|rxtx_buffer[UDP_SRC_PORT_L_P], sizeof(UDP_HEADER)+dlength.word);

	cDebugReg = 0x73; 
	// send packet to ethernet media
	enc28j60_packet_send ( &rxtx_buffer, sizeof(ETH_HEADER)+sizeof(IP_HEADER)+sizeof(UDP_HEADER)+dlength.word );

	return 1;
}
