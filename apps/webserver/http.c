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
//
// Global variable for http.c
//
//********************************************************************************************
BYTE web_title[] = "AVRnet V0.9 by AVRportal.com";
BYTE tag_br[] = "<br>";
BYTE tag_hr[] = "<hr width=\"100%\" size=\"1\"><br>";
BYTE tag_form[] = "<form action=\"./?\" method=\"get\">";
//********************************************************************************************
//
// Function : http_webserver_process
// Description : Initial connection to web server
//
//********************************************************************************************
void http_webserver_process ( BYTE *rx_buffer, BYTE **tx_buffer, BYTE *dest_mac, BYTE *dest_ip )
{
	WORD dlength, dest_port;
	BYTE count_time_temp[3];
	BYTE generic_buf[64];
	
	dest_port = (rx_buffer[TCP_SRC_PORT_H_P]<<8)|rx_buffer[TCP_SRC_PORT_L_P];

	cDebugReg = 0x40;
	// tcp port 80 start for web server
	if ( rx_buffer [ IP_PROTO_P ] == IP_PROTO_TCP_V && rx_buffer[ TCP_DST_PORT_H_P ] == 0 && rx_buffer[ TCP_DST_PORT_L_P ] == 80 )
	{
	        cDebugReg = 0x41;
		// received packet with flags "SYN", let's send "SYNACK"
		if ( (rx_buffer[ TCP_FLAGS_P ] & TCP_FLAG_SYN_V) )
		{
	                cDebugReg = 0x42;
//			tcp_send_synack ( tx_buffer, dest_mac, dest_ip );
			tcp_send_packet (
				*tx_buffer,
				dest_port,
				80,					// source port
				TCP_FLAG_SYN_V|TCP_FLAG_ACK_V,			// flag
				1,						// (bool)maximum segment size
				0,						// (bool)clear sequence ack number
				1,						// (bool)calculate new seq and seqack number
				0,						// tcp data length
				dest_mac,		// server mac address
				dest_ip );		// server ip address
	                cDebugReg = 0x43;
			flag1.bits.syn_is_received = 1;
			return;
		}

		if ( (rx_buffer [ TCP_FLAGS_P ] & TCP_FLAG_ACK_V) )
		{
	                cDebugReg = 0x44;
			// get tcp data length
			dlength = tcp_get_dlength( rx_buffer );
	                cDebugReg = 0x45;
			if ( dlength == 0 )
			{
	                        cDebugReg = 0x46;
				// finack, answer with ack
				if ( (rx_buffer[TCP_FLAGS_P] & TCP_FLAG_FIN_V) )
				{
	                                cDebugReg = 0x47;
//					tcp_send_ack ( tx_buffer, dest_mac, dest_ip );
					tcp_send_packet (
						*tx_buffer,
						dest_port,
						80,						// source port
						TCP_FLAG_ACK_V,			// flag
						0,						// (bool)maximum segment size
						0,						// (bool)clear sequence ack number
						1,						// (bool)calculate new seq and seqack number
						0,						// tcp data length
						dest_mac,		// server mac address
						dest_ip );		// server ip address
	                                cDebugReg = 0x48;
				}
				return;
			}
			// get avr ip address from request and set to new avr ip address
			// get send temparature to server configuration
			if ( http_get_variable ( rx_buffer, dlength, "tc", generic_buf ) )
			{
	                        cDebugReg = 0x49;
				// enable or disable send temparature
				if ( http_get_variable ( rx_buffer, dlength, "en", generic_buf ) )
					count_time_temp[0] = 1;
				else
					count_time_temp[0] = 0;
				// get hour
				if ( http_get_variable ( rx_buffer, dlength, "h", generic_buf ) )
				{
					count_time_temp[1] = (generic_buf[0] - '0') * 10;
					count_time_temp[1] = count_time_temp[1] + (generic_buf[1] - '0');
				}
				// get minute
				if ( http_get_variable ( rx_buffer, dlength, "m", generic_buf ) )
				{
					count_time_temp[2] = (generic_buf[0] - '0') * 10;
					count_time_temp[2] = count_time_temp[2] + (generic_buf[1] - '0');
				}
				// write config to eeprom
				//eeprom_write_block ( count_time_temp, ee_count_time, 3 );
				//eeprom_read_block ( count_time, ee_count_time, 3 );
				count_time[3] = 0;
			}

	                cDebugReg = 0x4A;
			// print webpage
			dlength = http_home( rx_buffer );
			// send ack before send data
//			tcp_send_ack ( tx_buffer, dest_mac, dest_ip );
			tcp_send_packet (
						*tx_buffer,
						dest_port,
						80,						// source port
						TCP_FLAG_ACK_V,			// flag
						0,						// (bool)maximum segment size
						0,						// (bool)clear sequence ack number
						1,						// (bool)calculate new seq and seqack number
						0,						// tcp data length
						dest_mac,		// server mac address
						dest_ip );		// server ip address
	                cDebugReg = 0x4B;
			// send tcp data
//			tcp_send_data ( tx_buffer, dest_mac, dest_ip, dlength );
			tcp_send_packet (
						*tx_buffer,
						dest_port,
						80,						// source port
						TCP_FLAG_ACK_V | TCP_FLAG_PSH_V | TCP_FLAG_FIN_V,			// flag
						0,						// (bool)maximum segment size
						0,						// (bool)clear sequence ack number
						0,						// (bool)calculate new seq and seqack number
						dlength,				// tcp data length
						dest_mac,		// server mac address
						dest_ip );		// server ip address
	                cDebugReg = 0x4C;
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
BYTE http_get_variable ( BYTE *rxtx_buffer, WORD dlength, BYTE *val_key, BYTE *dest )
{
	WORD data_p;
	BYTE *key;
	BYTE match=0, temp;

	key = val_key;
	
	// get data position
	data_p = tcp_get_hlength( rxtx_buffer ) + sizeof(ETH_HEADER) + sizeof(IP_HEADER);

	cDebugReg = 0x4D;
	// Find '?' in rx buffer, if found '?' in rx buffer then let's find variable key (val_key)
	for ( ; data_p<dlength; data_p++ )
	{
		if ( rxtx_buffer [ data_p ] == '?' )
			break;
	}
	// not found '?' in buffer
	if ( data_p == dlength )
		return 0;
	
	cDebugReg = 0x4E;
	
	// find variable key in buffer 
	for ( ; data_p<dlength; data_p++ )
	{
		temp = *key;

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
			*key++;
			match++;
		}
		else
		{
			// no match in rx buffer reset match and find again
			key = val_key;
			match = 0;
		}
	}
	
	cDebugReg = 0x4F;
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
	
	temp_value = 1; // adc_read_temp(); Masked By Dinesh
	print_decimal ( generic_buf, 2, temp_value );
	generic_buf[ 2 ] = '\0';

	dlength = tcp_puts_data ( rxtx_buffer, "GET /avrnet/save.php?pwd=secret&temp=", 0 );
	dlength = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlength );
	dlength = tcp_puts_data ( rxtx_buffer, " HTTP/1.0\r\n", dlength );
	dlength = tcp_puts_data ( rxtx_buffer, "Host: 10.1.1.76\r\n", dlength );
	dlength = tcp_puts_data ( rxtx_buffer, "User-Agent: AVR ethernet\r\n", dlength );
	dlength = tcp_puts_data ( rxtx_buffer, "Accept: text/html\r\n", dlength );
	dlength = tcp_puts_data ( rxtx_buffer, "Keep-Alive: 300\r\n", dlength );
	dlength = tcp_puts_data ( rxtx_buffer, "Connection: keep-alive\r\n\r\n", dlength );

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

	dlen = tcp_puts_data ( rxtx_buffer, "HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n", 0 );
	dlen = tcp_puts_data ( rxtx_buffer, "<title>", dlen );
	dlen = tcp_puts_data ( rxtx_buffer, web_title, dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "</title>", dlen );

	dlen = tcp_puts_data ( rxtx_buffer, "<a href=\"http://www.avrportal.com/\" target=\"_blank\"><b><font color=\"#000099\" size=\"+1\">", dlen );
	dlen = tcp_puts_data ( rxtx_buffer, web_title, dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "</font></b></a><br>", dlen );

	dlen = tcp_puts_data ( rxtx_buffer, tag_hr, dlen );

	dlen = tcp_puts_data ( rxtx_buffer, "LED 1 : ", dlen );
		dlen = tcp_puts_data ( rxtx_buffer, "<font color=red>OFF", dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "</font> [ <a href=\"./?l1=", dlen );
		dlen = tcp_puts_data ( rxtx_buffer, "1\">ON", dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "</a> ], LED 2 : ", dlen );
		dlen = tcp_puts_data ( rxtx_buffer, "<font color=red>OFF", dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "</font> [ <a href=\"./?l2=", dlen );
		dlen = tcp_puts_data ( rxtx_buffer, "1\">ON", dlen );

	dlen = tcp_puts_data ( rxtx_buffer, "</a> ]<br><br>", dlen );
	// read adc0
	dlen = tcp_puts_data ( rxtx_buffer, "ACD0 = ", dlen );
	adc0_value = 1; // adc_read ( 0 ); Masked By Dinesh A
	print_decimal ( generic_buf, 4, adc0_value );
	generic_buf[ 4 ] = '\0';
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	
	// read temp
	dlen = tcp_puts_data ( rxtx_buffer, "<br><br>Temparature = ", dlen );
	temp_value = 2; // adc_read_temp(); Masked By Dinesh A
	print_decimal ( generic_buf, 2, temp_value );
	generic_buf[ 2 ] = '\0';
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "&deg;C<br>", dlen );
	
	// send temp to server configuration
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)tag_form, dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "<INPUT TYPE=\"hidden\" NAME=\"tc\" VALUE=\"1\">Send Temparature in <INPUT TYPE=\"checkbox\" NAME=\"en\"", dlen );
	if ( count_time_temp[0] )
		dlen = tcp_puts_data ( rxtx_buffer, "CHECKED", dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "> Enable ", dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "<INPUT TYPE=\"text\" NAME=\"h\" size=\"2\" maxlength=\"2\" VALUE=\"", dlen );
	print_decimal ( generic_buf, 2, count_time_temp[1] );
	generic_buf[ 2 ] = '\0';
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "\"> Hours <INPUT TYPE=\"text\" NAME=\"m\" size=\"2\" maxlength=\"2\" VALUE=\"", dlen );
	print_decimal ( generic_buf, 2, count_time_temp[2] );
	generic_buf[ 2 ] = '\0';
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "\"> Minutes<input type=\"submit\" value=\"OK\"></form>", dlen );
	
	// AVR IP address
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)tag_form, dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "<input name=\"aip\" type=\"text\" size=\"15\" maxlength=\"15\" value=\"", dlen );
	print_ip ( generic_buf, (BYTE*)&avr_ip, 0 );
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "\"> <input type=\"submit\" value=\"AVR IP\"></form>", dlen );
	
	// Server IP address
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)tag_form, dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "<input name=\"sip\" type=\"text\" size=\"15\" maxlength=\"15\" value=\"", dlen );
	print_ip ( generic_buf, (BYTE*)&server_ip, 0 );
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)generic_buf, dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "\"> <input type=\"submit\" value=\"Server IP\"></form>", dlen );
	
	// Write LCD form
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *) tag_form, dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "<input name=\"lcd1\" type=\"text\" size=\"16\" maxlength=\"16\"> LCD Line 1<br>", dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "<input name=\"lcd2\" type=\"text\" size=\"16\" maxlength=\"16\"> LCD Line 2<br>", dlen );
	dlen = tcp_puts_data ( rxtx_buffer, "<input type=\"submit\" value=\"Write LCD\"></form>", dlen );
	
	dlen = tcp_puts_data ( rxtx_buffer, (BYTE *)tag_hr, dlen );

	dlen = tcp_puts_data ( rxtx_buffer, "<a href=\"./\"><b><font color=\"#000099\" size=\"+1\">Refresh</font></b></a>", dlen );

	return(dlen);
}
