//********************************************************************************************
//
// File : http.c implement for Hyper Text transfer Protocol
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
// Global variable for http.c
//
//********************************************************************************************
prog_int8_t web_title[] = "AVRnet V0.9 by AVRportal.com";
prog_int8_t tag_br[] = "<br>";
prog_int8_t tag_hr[] = "<hr width=\"100%\" size=\"1\"><br>";
prog_int8_t tag_form[] = "<form action=\"./?\" method=\"get\">";
//********************************************************************************************
//
// Function : http_webserver_process
// Description : Initial connection to web server
//
//********************************************************************************************
void http_webserver_process ( BYTE *rxtx_buffer, BYTE *dest_mac, BYTE *dest_ip )
{
	WORD dlength, dest_port;
	BYTE count_time_temp[3];
	BYTE generic_buf[64];
	
	dest_port = (rxtx_buffer[TCP_SRC_PORT_H_P]<<8)|rxtx_buffer[TCP_SRC_PORT_L_P];
	// tcp port 80 start for web server
	if ( rxtx_buffer [ IP_PROTO_P ] == IP_PROTO_TCP_V && rxtx_buffer[ TCP_DST_PORT_H_P ] == 0 && rxtx_buffer[ TCP_DST_PORT_L_P ] == 80 )
	{
		// received packet with flags "SYN", let's send "SYNACK"
		if ( (rxtx_buffer[ TCP_FLAGS_P ] & TCP_FLAG_SYN_V) )
		{
//			tcp_send_synack ( rxtx_buffer, dest_mac, dest_ip );
			tcp_send_packet (
				rxtx_buffer,
				(WORD_BYTES){dest_port},
				(WORD_BYTES){80},					// source port
				TCP_FLAG_SYN_V|TCP_FLAG_ACK_V,			// flag
				1,						// (bool)maximum segment size
				0,						// (bool)clear sequence ack number
				1,						// (bool)calculate new seq and seqack number
				0,						// tcp data length
				dest_mac,		// server mac address
				dest_ip );		// server ip address
			flag1.bits.syn_is_received = 1;
			return;
		}

		if ( (rxtx_buffer [ TCP_FLAGS_P ] & TCP_FLAG_ACK_V) )
		{
			// get tcp data length
			dlength = tcp_get_dlength( rxtx_buffer );
			if ( dlength == 0 )
			{
				// finack, answer with ack
				if ( (rxtx_buffer[TCP_FLAGS_P] & TCP_FLAG_FIN_V) )
				{
//					tcp_send_ack ( rxtx_buffer, dest_mac, dest_ip );
					tcp_send_packet (
						rxtx_buffer,
						(WORD_BYTES){dest_port},
						(WORD_BYTES){80},						// source port
						TCP_FLAG_ACK_V,			// flag
						0,						// (bool)maximum segment size
						0,						// (bool)clear sequence ack number
						1,						// (bool)calculate new seq and seqack number
						0,						// tcp data length
						dest_mac,		// server mac address
						dest_ip );		// server ip address
				}
				return;
			}
			// get avr ip address from request and set to new avr ip address
			if ( http_get_variable ( rxtx_buffer, dlength, PSTR( "aip" ), generic_buf ) )
			{
				if ( http_get_ip ( generic_buf, (BYTE*)&avr_ip ) == 4 )
					eeprom_write_block ( &avr_ip, ee_avr_ip, 4 );
				eeprom_read_block ( &avr_ip, ee_avr_ip, 4 );
			}
			// get server ip address from request and set to new server ip address
			if ( http_get_variable ( rxtx_buffer, dlength, PSTR( "sip" ), generic_buf ) )
			{
				if ( http_get_ip ( generic_buf, (BYTE*)&server_ip ) == 4 )
					eeprom_write_block ( &server_ip, ee_server_ip, 4 );
				eeprom_read_block ( &server_ip, ee_server_ip, 4 );
			}
			// get LED1 on/of command
			if ( http_get_variable ( rxtx_buffer, dlength, PSTR( "l1" ), generic_buf ) )
			{
				if ( generic_buf[0] == '0' )
					LED_PORT |= _BV ( LED_PIN1 );
				else
					LED_PORT &= ~_BV ( LED_PIN1 );
			}
			// get LED1 on/of command
			if ( http_get_variable ( rxtx_buffer, dlength, PSTR( "l2" ), generic_buf ) )
			{
				if ( generic_buf[0] == '0' )
					LED_PORT |= _BV ( LED_PIN2 );
				else
					LED_PORT &= ~_BV ( LED_PIN2 );
			}
			// get LCD string and show on first line
			if ( http_get_variable ( rxtx_buffer, dlength, PSTR( "lcd1" ), generic_buf ) )
			{
				urldecode ( generic_buf );
				lcd_putc ( '\f' );
				lcd_print ( generic_buf );
				flag1.bits.lcd_busy = 1;
			}
			// get LCD string and show on second line
			if ( http_get_variable ( rxtx_buffer, dlength, PSTR( "lcd2" ), generic_buf ) )
			{
				urldecode ( generic_buf );
				lcd_putc ( '\n' );
				lcd_print ( generic_buf );
				flag1.bits.lcd_busy = 1;
			}
			// get send temparature to server configuration
			if ( http_get_variable ( rxtx_buffer, dlength, PSTR( "tc" ), generic_buf ) )
			{
				// enable or disable send temparature
				if ( http_get_variable ( rxtx_buffer, dlength, PSTR( "en" ), generic_buf ) )
					count_time_temp[0] = 1;
				else
					count_time_temp[0] = 0;
				// get hour
				if ( http_get_variable ( rxtx_buffer, dlength, PSTR( "h" ), generic_buf ) )
				{
					count_time_temp[1] = (generic_buf[0] - '0') * 10;
					count_time_temp[1] = count_time_temp[1] + (generic_buf[1] - '0');
				}
				// get minute
				if ( http_get_variable ( rxtx_buffer, dlength, PSTR( "m" ), generic_buf ) )
				{
					count_time_temp[2] = (generic_buf[0] - '0') * 10;
					count_time_temp[2] = count_time_temp[2] + (generic_buf[1] - '0');
				}
				// write config to eeprom
				eeprom_write_block ( count_time_temp, ee_count_time, 3 );
				eeprom_read_block ( count_time, ee_count_time, 3 );
				count_time[3] = 0;
			}

			// print webpage
			dlength = http_home( rxtx_buffer );
			// send ack before send data
//			tcp_send_ack ( rxtx_buffer, dest_mac, dest_ip );
			tcp_send_packet (
						rxtx_buffer,
						(WORD_BYTES){dest_port},
						(WORD_BYTES){80},						// source port
						TCP_FLAG_ACK_V,			// flag
						0,						// (bool)maximum segment size
						0,						// (bool)clear sequence ack number
						1,						// (bool)calculate new seq and seqack number
						0,						// tcp data length
						dest_mac,		// server mac address
						dest_ip );		// server ip address
			// send tcp data
//			tcp_send_data ( rxtx_buffer, dest_mac, dest_ip, dlength );
			tcp_send_packet (
						rxtx_buffer,
						(WORD_BYTES){dest_port},
						(WORD_BYTES){80},						// source port
						TCP_FLAG_ACK_V | TCP_FLAG_PSH_V | TCP_FLAG_FIN_V,			// flag
						0,						// (bool)maximum segment size
						0,						// (bool)clear sequence ack number
						0,						// (bool)calculate new seq and seqack number
						dlength,				// tcp data length
						dest_mac,		// server mac address
						dest_ip );		// server ip address
			flag1.bits.syn_is_received = 0;
		}		
	}
}
//********************************************************************************************
//
// Function : http_get_ip
// Description : Get IP address from buffer (stored after call http_get_variable function)
// example after call http_get_variable function ip address (ascii) has been stored in buffer
// 10.1.1.1 (ascii), http_get_ip function convert ip address in ascii to binary and stored
// in BYTE *dest
//
//********************************************************************************************
unsigned char http_get_ip ( unsigned char *buf, BYTE *dest )
{
	unsigned char i, ch, digit, temp;

	i = 0;
	digit = 1;
	temp = 0;

	while ( 1 )
	{
		ch = *buf++;

		if ( ch >= '0' && ch <= '9' )
		{
			ch = ch - '0';
			temp = (temp * digit) + ch;
			digit *= 10;
		}
		else if ( ch == '.' || ch == '\0' )
		{
			dest[ i ] = temp;
			i++;
			digit = 1;
			temp = 0;
		}
		else
		{
			return 0;
		}
		if ( i == 4 )
			return i;
	}
}
//********************************************************************************************
//
// Function : http_get_variable
// Description : Get http variable from GET method, example http://10.1.1.1/?pwd=123456
//		when you call http_get_variable with val_key="pwd", then function stored "123456"
//		to dest buffer.
//
//********************************************************************************************
BYTE http_get_variable ( BYTE *rxtx_buffer, WORD dlength, PGM_P val_key, BYTE *dest )
{
	WORD data_p;
	PGM_P key;
	BYTE match=0, temp;

	key = val_key;
	
	// get data position
	data_p = tcp_get_hlength( rxtx_buffer ) + sizeof(ETH_HEADER) + sizeof(IP_HEADER);

	// Find '?' in rx buffer, if found '?' in rx buffer then let's find variable key (val_key)
	for ( ; data_p<dlength; data_p++ )
	{
		if ( rxtx_buffer [ data_p ] == '?' )
			break;
	}
	// not found '?' in buffer
	if ( data_p == dlength )
		return 0;
	
	// find variable key in buffer 
	for ( ; data_p<dlength; data_p++ )
	{
		temp = pgm_read_byte ( key );

		// end of variable keyword
		if ( rxtx_buffer [ data_p ] == '=' && match != 0 )
		{
			if ( temp == '\0' )
			{
				data_p++;
				break;
			}
		}
		// variable keyword match with rx buffer
		if ( rxtx_buffer [ data_p ] == temp )
		{
			key++;
			match++;
		}
		else
		{
			// no match in rx buffer reset match and find again
			key = val_key;
			match = 0;
		}
	}
	
	// if found variable keyword, then store variable value in destination buffer ( dest )
	if ( match != 0 )
	{
		match = 0;

		for ( ;; )
		{
			// end of variable value break from loop
			if ( rxtx_buffer [ data_p ] == '&' || rxtx_buffer [ data_p ] == ' ' )
			{
				dest [ match ] = '\0';
				break;
			}
			dest [ match ] = rxtx_buffer [ data_p ];
			match++;
			data_p++;
		}
	}

	// return with variable value length
	return match;
}
//********************************************************************************************
//
// Function : hex2int
// Description : convert a single hex digit character to its integer value
//
//********************************************************************************************
unsigned char hex2int(char c)
{
	if (c >= '0' && c <='9')
		return((unsigned char)c - '0');

	if (c >= 'a' && c <='f')
		return((unsigned char)c - 'a' + 10);
	
	if (c >= 'A' && c <='F')
		return((unsigned char)c - 'A' + 10);

	return 0;
}
//********************************************************************************************
//
// Function : urldecode
// Description : decode a url string e.g "hello%20joe" or "hello+joe" becomes "hello joe"
//
//********************************************************************************************
void urldecode(unsigned char *urlbuf)
{
	unsigned char c;
	unsigned char *dst;

	dst=urlbuf;
	while ((c = *urlbuf))
	{
		if (c == '+') c = ' ';
		if (c == '%')
		{
			urlbuf++;
			c = *urlbuf;
			urlbuf++;
			c = (hex2int(c) << 4) | hex2int(*urlbuf);
		}
		*dst = c;
		dst++;
		urlbuf++;
	}
	*dst = '\0';
}
//*****************************************************************************************
//
// Function : http_put_request
// Description : put http request to tx buffer contain 2-variables pwd and temp.
// webserver receive pwd, temp and save to text file by PHP script on webserver.
//
//*****************************************************************************************
WORD http_put_request ( BYTE *rxtx_buffer )
{
	BYTE temp_value;
	WORD dlength;
	BYTE generic_buf[64];
	
	temp_value = adc_read_temp();
	print_decimal ( generic_buf, 2, temp_value );
	generic_buf[ 2 ] = '\0';

	dlength = tcp_puts_data_p ( rxtx_buffer, PSTR ( "GET /avrnet/save.php?pwd=secret&temp=" ), 0 );
	dlength = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlength );
	dlength = tcp_puts_data_p ( rxtx_buffer, PSTR ( " HTTP/1.0\r\n" ), dlength );
	dlength = tcp_puts_data_p ( rxtx_buffer, PSTR ( "Host: 10.1.1.76\r\n" ), dlength );
	dlength = tcp_puts_data_p ( rxtx_buffer, PSTR ( "User-Agent: AVR ethernet\r\n" ), dlength );
	dlength = tcp_puts_data_p ( rxtx_buffer, PSTR ( "Accept: text/html\r\n" ), dlength );
	dlength = tcp_puts_data_p ( rxtx_buffer, PSTR ( "Keep-Alive: 300\r\n" ), dlength );
	dlength = tcp_puts_data_p ( rxtx_buffer, PSTR ( "Connection: keep-alive\r\n\r\n" ), dlength );

	return dlength;
}
//*****************************************************************************************
//
// Function : http_home
// Description : prepare the webpage by writing the data to the tcp send buffer
//
//*****************************************************************************************
WORD http_home( BYTE *rxtx_buffer )
{
	WORD dlen, adc0_value;
	BYTE temp_value;
	BYTE count_time_temp[3];
	BYTE generic_buf[64];

	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n" ), 0 );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR  ( "<title>" ), dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, (PGM_P)web_title, dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "</title>" ), dlen );

	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<a href=\"http://www.avrportal.com/\" target=\"_blank\"><b><font color=\"#000099\" size=\"+1\">" ), dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, (PGM_P)web_title, dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "</font></b></a><br>" ), dlen );

	dlen = tcp_puts_data_p ( rxtx_buffer, (PGM_P)tag_hr, dlen );

	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "LED 1 : " ), dlen );
	if ( (LED_PORT & _BV ( LED_PIN1 )) )
		dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<font color=red>OFF" ), dlen );
	else
		dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<font color=green>ON" ), dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "</font> [ <a href=\"./?l1=" ), dlen );
	if ( (LED_PORT & _BV ( LED_PIN1 )) )
		dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "1\">ON" ), dlen );
	else
		dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "0\">OFF" ), dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "</a> ], LED 2 : " ), dlen );
	if ( (LED_PORT & _BV ( LED_PIN2 )) )
		dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<font color=red>OFF" ), dlen );
	else
		dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<font color=green>ON" ), dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "</font> [ <a href=\"./?l2=" ), dlen );
	if ( (LED_PORT & _BV ( LED_PIN2 )) )
		dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "1\">ON" ), dlen );
	else
		dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "0\">OFF" ), dlen );

	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "</a> ]<br><br>" ), dlen );
	// read adc0
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "ACD0 = " ), dlen );
	adc0_value = adc_read ( 0 );
	print_decimal ( generic_buf, 4, adc0_value );
	generic_buf[ 4 ] = '\0';
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	
	// read temp
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<br><br>Temparature = " ), dlen );
	temp_value = adc_read_temp();
	print_decimal ( generic_buf, 2, temp_value );
	generic_buf[ 2 ] = '\0';
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "&deg;C<br>" ), dlen );
	
	// send temp to server configuration
	dlen = tcp_puts_data_p ( rxtx_buffer, (PGM_P)tag_form, dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<INPUT TYPE=\"hidden\" NAME=\"tc\" VALUE=\"1\">Send Temparature in <INPUT TYPE=\"checkbox\" NAME=\"en\"" ), dlen );
	eeprom_read_block ( count_time_temp, ee_count_time, 3 );
	if ( count_time_temp[0] )
		dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "CHECKED" ), dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "> Enable " ), dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<INPUT TYPE=\"text\" NAME=\"h\" size=\"2\" maxlength=\"2\" VALUE=\"" ), dlen );
	print_decimal ( generic_buf, 2, count_time_temp[1] );
	generic_buf[ 2 ] = '\0';
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "\"> Hours <INPUT TYPE=\"text\" NAME=\"m\" size=\"2\" maxlength=\"2\" VALUE=\"" ), dlen );
	print_decimal ( generic_buf, 2, count_time_temp[2] );
	generic_buf[ 2 ] = '\0';
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "\"> Minutes<input type=\"submit\" value=\"OK\"></form>" ), dlen );
	
	// AVR IP address
	dlen = tcp_puts_data_p ( rxtx_buffer, (PGM_P) tag_form, dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<input name=\"aip\" type=\"text\" size=\"15\" maxlength=\"15\" value=\"" ), dlen );
	print_ip ( generic_buf, (BYTE*)&avr_ip, 0 );
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "\"> <input type=\"submit\" value=\"AVR IP\"></form>" ), dlen );
	
	// Server IP address
	dlen = tcp_puts_data_p ( rxtx_buffer, (PGM_P)tag_form, dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<input name=\"sip\" type=\"text\" size=\"15\" maxlength=\"15\" value=\"" ), dlen );
	print_ip ( generic_buf, (BYTE*)&server_ip, 0 );
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "\"> <input type=\"submit\" value=\"Server IP\"></form>" ), dlen );
	
	// Write LCD form
	dlen = tcp_puts_data_p ( rxtx_buffer, (PGM_P) tag_form, dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<input name=\"lcd1\" type=\"text\" size=\"16\" maxlength=\"16\"> LCD Line 1<br>" ), dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<input name=\"lcd2\" type=\"text\" size=\"16\" maxlength=\"16\"> LCD Line 2<br>" ), dlen );
	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<input type=\"submit\" value=\"Write LCD\"></form>" ), dlen );
	
	dlen = tcp_puts_data_p ( rxtx_buffer, (PGM_P)tag_hr, dlen );

	dlen = tcp_puts_data_p ( rxtx_buffer, PSTR ( "<a href=\"./\"><b><font color=\"#000099\" size=\"+1\">Refresh</font></b></a>" ), dlen );

	return(dlen);
}
