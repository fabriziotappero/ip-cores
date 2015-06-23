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
//			  WORD_BYTES dest_port is a destiantion port
//			  WORD_BYTES length is a UDP header and data length
// Return value : None
//
// Description : generate udp header
//
//********************************************************************************************
void udp_generate_header ( BYTE *rxtx_buffer, WORD_BYTES dest_port, WORD_BYTES length )
{
	WORD_BYTES ck;

	// setup source port, default value is 3000
	rxtx_buffer[UDP_SRC_PORT_H_P] = UDP_AVR_PORT_H_V;
	rxtx_buffer[UDP_SRC_PORT_L_P] = UDP_AVR_PORT_L_V;

	// setup destination port
	rxtx_buffer[UDP_DST_PORT_H_P] = dest_port.byte.high;
	rxtx_buffer[UDP_DST_PORT_L_P] = dest_port.byte.low;

	// setup udp length
	rxtx_buffer[UDP_LENGTH_H_P] = length.byte.high;
	rxtx_buffer[UDP_LENGTH_L_P] = length.byte.low;

	// setup udp checksum
	rxtx_buffer[UDP_CHECKSUM_H_P] = 0;
	rxtx_buffer[UDP_CHECKSUM_L_P] = 0;
	// length+8 for source/destination IP address length (8-bytes)
	ck.word = software_checksum ( (BYTE*)&rxtx_buffer[IP_SRC_IP_P], length.word+8, length.word+IP_PROTO_UDP_V);
	rxtx_buffer[UDP_CHECKSUM_H_P] = ck.byte.high;
	rxtx_buffer[UDP_CHECKSUM_L_P] = ck.byte.low;
}
//********************************************************************************************
//
// Function : udp_puts_data
// Description : puts data from RAM to UDP tx buffer
//
//********************************************************************************************
WORD udp_puts_data ( BYTE *rxtx_buffer, BYTE *data, WORD offset )
{
	while( *data )
	{
		rxtx_buffer[ UDP_DATA_P + offset ] = *data++;
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

	// check UDP packet and check destination port
	if ( rxtx_buffer[IP_PROTO_P] != IP_PROTO_UDP_V || rxtx_buffer[UDP_DST_PORT_H_P] != UDP_AVR_PORT_H_V || rxtx_buffer[ UDP_DST_PORT_L_P ] != UDP_AVR_PORT_L_V )
		return 0;
	
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
		// command response
		dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("GAOK"), 0 );
		// LED1
		if ((LED_PORT&_BV(LED_PIN1))==0)
			dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("1"), dlength.word );
		else
			dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("0"), dlength.word );
		// LED2
		if ((LED_PORT&_BV(LED_PIN2))==0)
			dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("1"), dlength.word );
		else
			dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("0"), dlength.word );
		// ADC0
		adc0.word = adc_read ( 0 );
		print_decimal ( generic_buf, 4, adc0.word );
		generic_buf[ 4 ] = '\0';
		dlength.word = udp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlength.word );
		// temperature
		temp = adc_read_temp();
		print_decimal ( generic_buf, 2, temp );
		generic_buf[ 2 ] = '\0';
		dlength.word = udp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlength.word );
		// send temp config
		eeprom_read_block ( count_time_temp, ee_count_time, 3 );
		if (count_time_temp[0])
			dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("1"), dlength.word );
		else
			dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("0"), dlength.word );
		print_decimal ( generic_buf, 2, count_time_temp[1] );
		generic_buf[ 2 ] = '\0';
		dlength.word = udp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlength.word );
		print_decimal ( generic_buf, 2, count_time_temp[2] );
		generic_buf[ 2 ] = '\0';
		dlength.word = udp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlength.word );
		// AVR IP address
		print_ip ( generic_buf, (BYTE*)&avr_ip, 0 );
		dlength.word = udp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlength.word );
		dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR(";"), dlength.word );
		// Server IP address
		print_ip ( generic_buf, (BYTE*)&server_ip, 0 );
		dlength.word = udp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlength.word );
		dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR(";\r\n"), dlength.word );
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
		// get enable/disable
		count_time_temp[0] = rxtx_buffer[UDP_DATA_P+2] - '0';
		// get hour
		count_time_temp[1] = (rxtx_buffer[UDP_DATA_P+3] - '0') * 10;
		count_time_temp[1] = count_time_temp[1] + (rxtx_buffer[UDP_DATA_P+4] - '0');
		// get minute
		count_time_temp[2] = (rxtx_buffer[UDP_DATA_P+5] - '0') * 10;
		count_time_temp[2] = count_time_temp[2] + (rxtx_buffer[UDP_DATA_P+6] - '0');
		// write config to eeprom
		eeprom_write_block ( count_time_temp, ee_count_time, 3 );
		eeprom_read_block ( count_time, ee_count_time, 3 );
		count_time[3] = 0;
		// command response
		dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("STOK\r\n"), 0 );
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
		// find \r\n
		for(tmp=UDP_DATA_P; tmp<UDP_DATA_P+128; tmp++)
		{
			if(rxtx_buffer[UDP_DATA_P+tmp]=='\r' && rxtx_buffer[UDP_DATA_P+tmp+1]=='\n')
			{
				temp = 0;
				break;
			}
		}
		if(temp==0)
		{
			tmp = 0;
			// find ';' end of IP address and replace it with zero
			while ( rxtx_buffer[UDP_DATA_P+tmp] != ';') tmp++;
			rxtx_buffer[UDP_DATA_P+tmp] = 0;
			// use http_get_ip to convert ascii to hex 
			if ( http_get_ip ( (BYTE*)&rxtx_buffer[UDP_DATA_P+2], (BYTE*)&avr_ip ) == 4 )
				eeprom_write_block ( &avr_ip, ee_avr_ip, 4 );
			eeprom_read_block ( &avr_ip, ee_avr_ip, 4 );
		
			// Get server IP
			temp = tmp+1;
			while ( rxtx_buffer[UDP_DATA_P+tmp] != ';') tmp++;
			rxtx_buffer[UDP_DATA_P+tmp] = '\0';
			// use http_get_ip to convert ascii to hex 
			if ( http_get_ip ( (BYTE*)&rxtx_buffer[UDP_DATA_P+temp], (BYTE*)&server_ip ) == 4 )
				eeprom_write_block ( &avr_ip, ee_server_ip, 4 );
			eeprom_read_block ( &avr_ip, ee_server_ip, 4 );

			// send command response to client
			dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("SIOK\r\n"), 0 );
		}
		else
		{
			dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("ERROR\r\n"), 0 );
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
		// find \r\n
		for(tmp=UDP_DATA_P; tmp<UDP_DATA_P+128; tmp++)
		{
			if(rxtx_buffer[UDP_DATA_P+tmp]=='\r' && rxtx_buffer[UDP_DATA_P+tmp+1]=='\n')
			{
				temp = 0;
				break;
			}
		}
		if(temp==0)
		{
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
			dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("WLOK\r\n"), 0 );
		}
		else
		{
			dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("ERROR\r\n"), 0 );
		}
	}
	// "SL" command, is set LED1, LED2 command
	// "SL" command format is SL12\r\n
	// 1 is on/off command for LED1 '1' = ON, '0' = OFF
	// 2 is on/off command for LED2 '1' = ON, '0' = OFF
	// \r\n is end of command
	else if(rxtx_buffer[UDP_DATA_P]=='S' && rxtx_buffer[UDP_DATA_P+1]=='L' && rxtx_buffer[UDP_DATA_P+4]=='\r' && rxtx_buffer[UDP_DATA_P+5]=='\n')
	{
		// on/off LED1
		if(rxtx_buffer[UDP_DATA_P+2]=='0')
			LED_PORT |= _BV ( LED_PIN1 );
		else
			LED_PORT &= ~_BV ( LED_PIN1 );
		// on/off LED2
		if(rxtx_buffer[UDP_DATA_P+3]=='0')
			LED_PORT |= _BV ( LED_PIN2 );
		else
			LED_PORT &= ~_BV ( LED_PIN2 );
		// send command response
		dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("SLOK\r\n"), 0 );
	}
	else
	{
		// unknown command, send "ERROR" to client
		dlength.word = udp_puts_data_p ( rxtx_buffer, PSTR("ERROR\r\n"), 0 );
	}

	// set ethernet header
	eth_generate_header (rxtx_buffer, (WORD_BYTES){ETH_TYPE_IP_V}, dest_mac );
	
	// generate ip header and checksum
	ip_generate_header (rxtx_buffer, (WORD_BYTES){sizeof(IP_HEADER)+sizeof(UDP_HEADER)+dlength.word}, IP_PROTO_UDP_V, dest_ip );

	// generate UDP header
	udp_generate_header (rxtx_buffer, (WORD_BYTES){(rxtx_buffer[UDP_SRC_PORT_H_P]<<8)|rxtx_buffer[UDP_SRC_PORT_L_P]}, (WORD_BYTES){sizeof(UDP_HEADER)+dlength.word});

	// send packet to ethernet media
	enc28j60_packet_send ( rxtx_buffer, sizeof(ETH_HEADER)+sizeof(IP_HEADER)+sizeof(UDP_HEADER)+dlength.word );

	return 1;
}
