//********************************************************************************************
//
// YagnaInnWebServer firmware Version 1.0
//
// Author(s) : Dinesh Annayya, dinesha@opencores.org   
// Website   : http://www.yagnainn.com/
// MCU       : Open Core 8051 @ 50Mhz
// Version   : 1.0
//
//********************************************************************************************
//
// File : main.c main program for Yagna Innovation -WebBrowser development board.
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

// Global variables
MAC_ADDR avr_mac;
IP_ADDR avr_ip;

MAC_ADDR server_mac;
IP_ADDR server_ip;

extern WORD ip_identfier;

union flag1
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

union flag2
{
	BYTE byte;
	struct
	{
		unsigned char key_hold:1;
		unsigned char unuse:7;
	}bits;
}flag2;

//BYTE generic_buf[128];

// Change your avr and server ip address here
// avr and server ip address are stored in eeprom
BYTE ee_avr_ip[4]  = { 10, 1, 1, 1 };
BYTE ee_server_ip[4]  = { 10, 1, 1, 76 };

unsigned int iRxFrmCnt = 0;
unsigned int iTxFrmCnt = 0;
unsigned int iRxDescPtr= 0;
unsigned int iTxDescPtr= 0;



void _delay_ms( int iDelay );
//--------------------------
// Data Memory MAP
//-------------------------
// 0x0000 to 0x0FFF - 4K - Processor Data Memory
// 0x1000 to 0x1FFF - 4K - Gmac Rx Data Memory
// 0x2000 to 0x2FFF - 4K - Reserved for Rx
// 0x3000 to 0x3FFF - 4K - Gmac Tx Data Memory
// 0x4000 to 0x4FFF - 4K - Reserved for Tx
// 0x7000 to 0x703F - 64 - Rx Descriptor
// 0x7040 to 0x707F - 64 - Tx Descripto
//*****************************************************************************************
//
// Function : server_process
// Description : Run web server and listen on port 80
//
//*****************************************************************************************
void server_process ( BYTE **tx_buffer )
{
	MAC_ADDR client_mac;
	IP_ADDR client_ip;
	// you can change rx,tx buffer size in includes.h
	BYTE *rx_buffer;
	WORD plen;
	
	
        cDebugReg = 0x1; // Debug 1 
	//if ( flag1.bits.syn_is_sent )
	//	return;
	// get new packet
	plen = enc28j60_packet_receive( &rx_buffer, MAX_RXTX_BUFFER);

        cDebugReg = 0x2; // Debug 1 
	
	//plen will ne unequal to zero if there is a valid packet (without crc error)
	if(plen==0)
		return;
        
	cDebugReg = 0x3; // Debug 1 

	// copy client mac address from buffer to client mac variable
	memcpy ( (BYTE*)client_mac, &rx_buffer[ ETH_SRC_MAC_P ], sizeof(MAC_ADDR) );

	cDebugReg = 0x4; // Debug 1 
	
	// check arp packet if match with avr ip let's send reply
	if ( arp_packet_is_arp( rx_buffer, ARP_OPCODE_REQUEST_V ) )
	{
	        cDebugReg = 0x5; // Debug 1 
		arp_send_reply ( rx_buffer, &(*tx_buffer), (BYTE*)&client_mac );
	        cDebugReg = 0x6; // Debug 1 
		return;
	}

	cDebugReg = 0x7; // Debug 1 
	// get client ip address
	memcpy ( (BYTE*)&client_ip, &rx_buffer[ IP_SRC_IP_P ], sizeof(IP_ADDR) );
	cDebugReg = 0x8; // Debug 1 
	// check ip packet send to avr or not?
	if ( ip_packet_is_ip ( rx_buffer ) == 0 )
	{
	        cDebugReg = 0x9; // Debug 1 
		return;
	}

	// check ICMP packet, if packet is icmp packet let's send icmp echo reply
	cDebugReg = 0xA; // Debug 1 */	
	if ( icmp_send_reply ( rx_buffer, &(*tx_buffer), (BYTE*)&client_mac, (BYTE*)&client_ip ) )
	{
	        cDebugReg = 0xB; // Debug 1 
		return;
	}

	cDebugReg = 0xC; // Debug 1 
	// check UDP packet
	if (udp_receive ( rx_buffer, (BYTE *)&client_mac, (BYTE *)&client_ip ))
	{
	        cDebugReg = 0xD; // Debug 1 
		return;
	}
	
	cDebugReg = 0xE; // Debug 1
	// tcp start here
	// start web server at port 80, see http.c
	http_webserver_process ( rx_buffer, &(*tx_buffer),(BYTE*)&client_mac, (BYTE*)&client_ip );
	cDebugReg = 0xF; // Debug 1 
}
//*****************************************************************************************
//
// Function : main
// Description : main program, 
//
//*****************************************************************************************
void lcd_backlight( void )
{
	

	
}
//*****************************************************************************************
//
// Function : main
// Description : main program, 
//
//*****************************************************************************************
int main (void)
{
	BYTE i;
	BYTE *tx_buffer;
	// change your mac address here
	avr_mac.byte[0] = 'A';
	avr_mac.byte[1] = 'V';
	avr_mac.byte[2] = 'R';
	avr_mac.byte[3] = 'P';
	avr_mac.byte[4] = 'O';
	avr_mac.byte[5] = 'R';
       
	// change your IP address here
	avr_ip.byte[0] = 10;
	avr_ip.byte[1] = 1;
	avr_ip.byte[2] = 1;
	avr_ip.byte[3] = 1;

	iRxFrmCnt = 0;
        iTxFrmCnt = 0;
        iRxDescPtr= 0;
        iTxDescPtr= 0;

        ip_identfier=1;

        // Initialise Transmit Data Pointer	
	tx_buffer = 0x3000; // GMAC Tx Data Memory, 4K Size
	//eeprom_read_block ( &avr_ip, ee_avr_ip, 4 );
	
	
	//eeprom_read_block ( &server_ip, ee_server_ip, 4 );
	
	// setup port as input and enable pull-up
	//SW_DDR &= ~ ( _BV( SW_MENU ) | _BV( SW_EXIT ) | _BV( SW_UP ) | _BV( SW_DW ) );
	//SW_PORT |= _BV( SW_MENU ) | _BV( SW_EXIT ) | _BV( SW_UP ) | _BV( SW_DW );
	//SFIOR &= ~_BV( PUD );

	// setup lcd backlight as output
	//LCD_BL_DDR |= _BV( LCD_BL_PIN );
	// lcd backlight on
	//LCD_BL_PORT |= _BV( LCD_BL_PIN );
	
	// setup clock for timer1
	//TCCR1B = 0x01;	// clk/1 no prescaling

	// initial lcd, and menu
	//lcd_init ();
	//menu_init ();

	// set LED1, LED2 as output */
	//LED_DDR |= _BV( LED_PIN1_DDR ) | _BV( LED_PIN2_DDR );
	// set LED pin to "1" ( LED1,LED2 off)
	//LED_PORT |= _BV( LED_PIN1 ) | _BV( LED_PIN2 );

	// initial enc28j60
	enc28j60_init( (BYTE*)&avr_mac );
	
	// loop forever
	for(;;)
	{
		// wait until timer1 overflow
		//while ( (TIFR & _BV ( TOV1 )) == 0 );
		//TIFR |= _BV(TOV1);
		//TCNT1 = 1536;	// Timer1 overflow every 1/16MHz * ( 65536 - 1536 ) = 4ms, 250Hz

		// general time base, generate by timer1
		// overflow every 1/250 seconds
		//time_base ();
		
		// server process response for arp, icmp, http
		server_process (&tx_buffer);

		// send temparature to web server unsing http protocol
		// disable by default.
		//client_process ();

		// lcd user interface menu
		// setup IP address, countdown timer
		menu_process ();

		// display AVR ethernet status
		// temparature, AVR ip, server ip, countdown time
		standby_display ();
	}

	return 0;
}

// Need to add the Delay
void _delay_ms (int iDelay) {


}
