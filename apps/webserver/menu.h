//********************************************************************************************
//
// File : menu.h implement for User interface menu
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
#define SW_DW			7
#define SW_UP			6
#define SW_EXIT			5
#define SW_MENU			4
#define SW_DDR			DDRA
#define SW_PORT			P0
#define SW_PIN			PINA
#define LCD_BL_PIN		PB3
#define LCD_BL_PORT		P1
#define LCD_BL_DDR		DDRB

//#define MENU_MAIN					1
//#define MENU_SET_AVR_IP				2
//#define MENU_SET_SERVER_IP			3
//#define MENU_SET_COUNT_TIME			4
//#define MENU_PING_SERVER			5
//#define MENU_SEND_TEMP				6

#define SUBMENU_SET_AVR_IP			1
#define SUBMENU_SET_SERVER_IP		2
#define SUBMENU_SET_COUNT_TIME		3
#define SUBMENU_PING_SERVER			4
#define SUBMENU_SEND_TEMP			6

#define CURSOR_SET_AVR_IP1			0
#define CURSOR_SET_AVR_IP2			1
#define CURSOR_SET_AVR_IP3			2
#define CURSOR_SET_AVR_IP4			3

#define CURSOR_SET_SERVER_IP1		0
#define CURSOR_SET_SERVER_IP2		1
#define CURSOR_SET_SERVER_IP3		2
#define CURSOR_SET_SERVER_IP4		3

#define CURSOR_SET_COUNT_TIME1		0
#define CURSOR_SET_COUNT_TIME2		1
#define CURSOR_SET_COUNT_TIME3		2
#define CURSOR_SET_COUNT_TIME4		3

//#define STANDBY_CURSOR_AVR_IP		1
//#define STANDBY_CURSOR_SERVER_IP	2
//#define STANDBY_CURSOR_COUNT_DOWN	3
//#define STANDBY_CURSOR_TEMP			4

#define ASCII_CURSOR	0x7E

//#include <avr/eeprom.h>

extern BYTE standby_cursor;
extern BYTE ee_count_time[] ;
extern BYTE count_time[];

//********************************************************************************************
//
// Prototype function
//
//********************************************************************************************
extern void menu_process ( void );
extern void menu_init ( void );
extern void standby_display ( void );
extern void time_base ( void );
extern void print_ip ( BYTE *ptr, BYTE *ip, BYTE cursor );
extern void print_time ( BYTE *ptr, BYTE *time, BYTE cursor );
extern BYTE *print_decimal ( BYTE *ptr, BYTE digit, WORD dec );
extern void key_up_process ( void );
extern void key_dw_process ( void );
