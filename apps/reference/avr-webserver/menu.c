//********************************************************************************************
//
// File : menu.c implement for User interface menu
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
//*******************************************************************************************
//
// Global variable
//
//*******************************************************************************************
BYTE menu_index, submenu_index;
BYTE menu_stack, submenu_stack;
BYTE setting_cursor;
BYTE standby_cursor;
BYTE sec_count;
// max index for cursor setting
prog_uint8_t setting_cursor_max[3] = { 4, 4, 4 };
// count down timer for send temp. H:M:S
prog_uint8_t count_time_max[4] = { 2, 60, 60, 24 };
// countdown timer 4-bytes, [0]=en/dis, [1]=hour, [2]=min, [3]=sec
BYTE count_time[4];
// count down time initial value stored in eeprom. Enable/Disable, Hour, Minute
BYTE ee_count_time[3] EEMEM = { 0, 0, 1 };
prog_uint8_t str_enable[] = "Enable";
prog_uint8_t str_disable[] = "Disable";

// menu and standby display string
PGM_P menu_list[5] = 
{
	"Main menu",
    "AVR IP config",
    "Server IP config",
	"Send temp config",
	"Ping server"
};

PGM_P standby_list[4] = 
{
	"AVR IP",
	"Server IP",
	"Send temp in",
	"ADC0 & Temp"
};

//*****************************************************************************************
//
// Function : my_memcpy
// Description : copy string (end '\0') from program memory to ram and return pointer
// to end of string
//
//*****************************************************************************************
BYTE *my_strcpy ( BYTE *dest, PGM_P src )
{
	BYTE ch;

	while ( (ch = pgm_read_byte( src++ )) )
	{
		*dest++ = ch;
	}
	return dest;
}

//*****************************************************************************************
//
// Function : print_decimal
// Description : Print decimal to buffer, up to 5 digits
//
//*****************************************************************************************
BYTE * print_decimal ( BYTE *ptr, BYTE digit, WORD dec )
{
	if ( digit >= 5 )
		*ptr++ = ( (dec/10000) + '0' );
	if ( digit >= 4 )
		*ptr++ = ( ((dec%10000)/1000) + '0' );
	if ( digit >= 3 )
		*ptr++ = ( ((dec%1000)/100) + '0' );
	if ( digit >= 2 )
		*ptr++ = ( ((dec%100)/10) + '0' );
	*ptr++ = ( ((dec%10)) + '0' );

	return ptr;
}
//*****************************************************************************************
//
// Function : print_temp
// Description : Print ADC0 and temparature to buffer
//
//*****************************************************************************************
void print_temp ( BYTE *dest )
{
	WORD adc0_value;
	BYTE temp_value;

	adc0_value = adc_read ( 0 );
	temp_value = adc_read_temp ( );

	dest = print_decimal ( dest, 4, adc0_value );
	*dest++ = ',';
	dest = print_decimal ( dest, 2, temp_value );
	*dest++ = ASCII_DEGREE;
	*dest++ = 'C';
	*dest = '\0';
}
//*****************************************************************************************
//
// Function : print_ip
// Description : Print ip address format to buffer e.g. 10.1.1.1
//
//*****************************************************************************************
void print_ip ( BYTE *ptr, BYTE *ip, BYTE cursor )
{
	BYTE i, digit, temp;

	for ( i=0; i<4; i++ )
	{
		temp = ip [ i ];
		if ( temp > 99 )
			digit = 3;
		else if ( temp > 9 )
			digit = 2;
		else
			digit = 1;
		
		if ( (i+1) == cursor )
		{
			*ptr = ASCII_CURSOR;
			ptr++;
		}
		else if ( i > 0 )
		{
			*ptr = '.';
			ptr++;
		}
		ptr = print_decimal ( ptr, digit, temp );

	}
	*ptr = '\0';
}
//*****************************************************************************************
//
// Function : print_time
// Description : Print time format to buffer e.g. 01:23:45
//
//*****************************************************************************************
void print_time ( BYTE *ptr, BYTE *time, BYTE cursor )
{
	BYTE i;
	
	// show setting cursor when enter to setting mode
	if ( cursor == 0 )
	{
		if ( time [ 0 ] )
		{
			time++;
			for ( i=0; i<3; i++ )
			{
				if ( (i+2) == cursor )
				{
					*ptr++ = ASCII_CURSOR;
				}
				else if ( i > 0 )
				{
					*ptr++ = ':';
				}
				ptr = print_decimal ( ptr, 2, *time++ );
			}
		}
		else
		{
			ptr = my_strcpy ( ptr, (PGM_P)str_disable );
		}
	}
	else
	{
		if ( cursor == 1 )
		{
			*ptr++ = ASCII_CURSOR;
			// show Enable/Disable send temparature to server
			if ( time [ 0 ] )
				ptr = my_strcpy ( ptr, (PGM_P)str_enable );
			else
				ptr = my_strcpy ( ptr, (PGM_P)str_disable );
		}
		else
		{
			time++;
			for ( i=0; i<3; i++ )
			{
				if ( (i+2) == cursor )
				{
					*ptr++ = ASCII_CURSOR;
				}
				else if ( i > 0 )
				{
					*ptr++ = ':';
				}
				ptr = print_decimal ( ptr, 2, *time++ );
			}
		}
	}
	
	*ptr = '\0';
}
//*****************************************************************************************
//
// Function : time_base
// Description : count-down timer for send temparature to server. you can enable/disable and 
// adjust timer by "Send temp config" menu.
// 
//*****************************************************************************************
void time_base ( void )
{
	static BYTE send_temp_timeout=0;

	if ( ++sec_count == 250 )
	{
		sec_count = 0;

		// update lcd display
		flag1.bits.update_display = 1;
		
		// timeout for send temparature to webserver
		if ( flag1.bits.syn_is_sent )
		{
			// 5 seconds
			if ( ++send_temp_timeout == 5 )
			{
				send_temp_timeout = 0;
				flag1.bits.send_temp_timeout = 1;
			}
		}
		// send temparature to server countdown
		if ( count_time[ 0 ] && menu_index!=4 )
		{
			if ( --count_time[ 3 ] > 59 )
			{
				//count_time[ 3 ] = 59;
				count_time[ 3 ] = 20;	// debug
				if ( --count_time[ 2 ] > 59 )
				{
					count_time[ 2 ] = 59;
					if ( --count_time[ 1 ] > 23 )
					{
						// read hour
						count_time[ 1 ] = eeprom_read_byte( ee_count_time + 1 );
						// read minute
						count_time[ 2 ] = eeprom_read_byte( ee_count_time + 2 );
						// clear second
						count_time[ 3 ] = 0;
						flag1.bits.send_temp = 1;
					}
				}
			}
		}
	}
}
//*******************************************************************************************
//
// Function : standby_display
// Description : display board status such as AVR ip, server ip, countdown time, temparature
//
//*******************************************************************************************
void standby_display ( void )
{
	BYTE generic_buf[64];

	// update lcd display flag not set, exit from function
	if ( flag1.bits.update_display == 0 )
		return;
	flag1.bits.update_display = 0;
	// lcd display is displaying other information, wait until busy flag clear
	if ( flag1.bits.lcd_busy )
		return;
	// now displaying menu information, wait until exit from menu
	if ( menu_index )
		return;

	// display status on lcd line 1
	lcd_putc ( '\f' );
	lcd_print ( (BYTE*)standby_list[ standby_cursor - 1 ] );

	// display status on lcd line 2
	lcd_putc ( '\n' );
	// display avr ip
	if ( standby_cursor == 1 )
	{
		print_ip ( generic_buf, (BYTE*)&avr_ip, 0 );
	}
	// display server ip
	else if ( standby_cursor == 2 )
	{
		print_ip ( generic_buf, (BYTE*)&server_ip, 0 );
	}
	// display countdown timer
	else if ( standby_cursor == 3 )
	{
		print_time ( generic_buf, count_time, 0 );
	}
	// display current temparature
	else if ( standby_cursor == 4 )
	{
		print_temp ( generic_buf );
	}
	lcd_print ( generic_buf );
}
//*******************************************************************************************
//
// Function : display_menu
// Description : display LCD user interface menu on LCD
//
//*******************************************************************************************
void display_menu(void)
{
	BYTE generic_buf[64];

	if( menu_index == 0)
		return;

	// display menu title on lcd first line
	lcd_putc( '\f' );
	lcd_print ( (BYTE *)menu_list[ menu_index - 1 ] );
	
	// display menu detail on lcd second line
	lcd_putc( '\n' );
	if( menu_index == 1 )//MENU_MAIN)
	{
		lcd_print( (BYTE *)menu_list[ submenu_index ] );
	}
	// setup avr ip address
	else if( menu_index == 2 )
	{
		print_ip ( generic_buf, (BYTE*)&avr_ip, setting_cursor+1 );
		lcd_print ( generic_buf );
	}
	// setup server ip address
	else if(menu_index == 3 )
	{
		print_ip ( generic_buf, (BYTE*)&server_ip, setting_cursor+1 );
		lcd_print ( generic_buf );
	}
	// setup countdown timer for send temparature
	else if ( menu_index == 4 )
	{
		print_time ( generic_buf, count_time, setting_cursor+1 );
		lcd_print ( generic_buf );
	}
	// ping server
	else if ( menu_index == 5 )
	{
		print_ip ( generic_buf, (BYTE*)&server_ip, 1 );
		lcd_print ( generic_buf );
	}
	// send temparature now
	//else if ( menu_index == 6 )
	//{
	//	lcd_put ( ASCII_CURSOR );
	//	lcd_print_p ( PSTR ( "OK" ) );
	//}
}
//*******************************************************************************************
//
// Function : key_up_process
// Description : 
//
//*******************************************************************************************
void key_up_process ( void )
{
	BYTE temp;
	
	// standby display, display board status
	if(menu_index == 0)
	{
		if ( ++ standby_cursor == ((sizeof(standby_list)/2)+1) )
			standby_cursor = 1;
		flag1.bits.update_display = 1;
	}
	// main menu
	else if(menu_index == 1)
	{
		if( ++submenu_index == (sizeof(menu_list)/2) )
		{
			submenu_index = 1;
		}
	}
	// setup avr ip
	else if( menu_index == 2 )
	{
		avr_ip.byte [ setting_cursor ]++;
		eeprom_write_block ( &avr_ip, ee_avr_ip, 4 );
	}
	// setup server ip
	else if( menu_index == 3 )
	{
		server_ip.byte [ setting_cursor ]++;
		eeprom_write_block ( &server_ip, ee_server_ip, 4 );
	}
	// setup countdown timer
	else if( menu_index == 4 )
	{
		temp = pgm_read_byte ( (PGM_P)(count_time_max + setting_cursor) );
		if ( ++count_time [ setting_cursor ] == temp )
			count_time [ setting_cursor ] = 0;
		eeprom_write_block ( count_time, ee_count_time, 4 );
	}
}
//*******************************************************************************************
//
// Function : key_dw_process
// Description : 
//
//*******************************************************************************************
void key_dw_process ( void )
{
	BYTE temp;
	
	// standby display, display board status
	if(menu_index == 0)
	{
		if ( -- standby_cursor == 0 )
			standby_cursor = sizeof(standby_list)/2;
		flag1.bits.update_display = 1;
	}
	// main menu
	else if(menu_index == 1)
	{
		if( --submenu_index == 0 )
		{
			submenu_index = (sizeof(menu_list)/2)-1;
		}
	}
	// setup avr ip
	else if( menu_index == 2 )
	{
		avr_ip.byte [ setting_cursor ]--;
		eeprom_write_block ( &avr_ip, ee_avr_ip, 4 );
	}
	// setup server ip
	else if( menu_index == 3 )
	{
		server_ip.byte [ setting_cursor ]--;
		eeprom_write_block ( &server_ip, ee_server_ip, 4 );
	}
	// setup countdown timer
	else if( menu_index == 4 )
	{
		temp = pgm_read_byte ( (PGM_P)(count_time_max + setting_cursor) );
		if ( --count_time [ setting_cursor ] == 0xff )
			count_time [ setting_cursor ] = temp;
		eeprom_write_block ( count_time, ee_count_time, 4 );
	}
}
//*******************************************************************************************
//
// Function : key_process
// Description : Process all key code from get_key_code function
//
//*******************************************************************************************
void menu_process ( void )
{
	static BYTE key_hold_count=0, key_hold_step_delay=0;
	BYTE rxtx_buffer[MAX_RXTX_BUFFER];
	BYTE key_code, temp;
	static BYTE backlight_sec=31, backlight_seccount=250;
	
	// get switch value from port
	key_code = SW_PIN & ( _BV( SW_DW ) | _BV( SW_UP ) | _BV( SW_EXIT ) | _BV( SW_MENU ) );
	
	// Check key press?
	if ( key_code  == ( _BV( SW_DW ) | _BV( SW_UP ) | _BV( SW_EXIT ) | _BV( SW_MENU ) ) )
	{
		flag1.bits.key_is_executed = 0;
		flag2.bits.key_hold = 0;
		key_hold_count = 0;
		key_hold_step_delay = 0;

		// lcd backlight control
		// lcd backlight off after key is unpress ( 30 seconds)
		if ( backlight_sec )
		{
			if ( --backlight_seccount > 250 )
			{
				backlight_seccount = 250;
				if ( --backlight_sec == 1 )
				{
					backlight_sec = 0;
					// lcd backlight off
					LCD_BL_PORT &= ~_BV( LCD_BL_PIN );
				}
			}
		}
		return;
	}
	
	// lcd backlight on
	// and hold-on 30 seconds
	backlight_sec = 31;
	LCD_BL_PORT |= _BV( LCD_BL_PIN );

	// check hold key
	if ( ++key_hold_count == 200 )
	{
		key_hold_count = 0;
		flag2.bits.key_hold = 1;		
	}
	
	if ( flag2.bits.key_hold )
	{
		if ( ++key_hold_step_delay == 30 )
		{
			key_hold_step_delay = 0;
			if ( key_code == ((~_BV ( SW_UP ) ) & 0xf0) )
			{
				key_up_process ();
			}
			// if down key is pressed
			else if ( key_code == ((~_BV ( SW_DW ) ) & 0xf0) )
			{
				key_dw_process ();
			}
			display_menu();
		}
	}
	// key code already executed
	if ( flag1.bits.key_is_executed )
		return;
	// check key code, what is key pressed?
	// if menu key is pressed
	if ( key_code == ((~_BV ( SW_MENU ) ) & 0xf0) )
	{
		// enter to main menu
		if( menu_index == 0 )
		{
			setting_cursor = 0;
			menu_index = 1;
			submenu_index = 1;
		}
		// enter to submenu
		else if( menu_index == 1 )
		{
			menu_stack = menu_index;
			submenu_stack = submenu_index;
			menu_index = submenu_index + menu_index;
			submenu_index = 1;
		}
		// ping server
		else if ( menu_index == 5 )
		{
			// Show on lcd first line
			lcd_putc( '\f' );
			lcd_print ( (BYTE *)menu_list[ 4 ] );
			lcd_putc( '\n' );
			if ( icmp_ping ( (BYTE*)rxtx_buffer, (BYTE*)&server_mac, (BYTE*)&server_ip ) )
			{
				lcd_print_p ( PSTR ( "Ping OK." ) );
			}
			else
			{
				lcd_print_p ( PSTR ( "Not found." ) );
			}
			flag1.bits.lcd_busy = 1;
			menu_index = 0;
			submenu_index = 0;
			flag1.bits.key_is_executed = 1;
			return;
		}
		// change cursor setting on each menu
		else
		{
			temp = pgm_read_byte ( (PGM_P)(setting_cursor_max + menu_index - 2) );

			if ( ++setting_cursor == temp )
				setting_cursor = 0;
		}
	}
	// if exit key is pressed
	else if ( key_code == ((~_BV ( SW_EXIT ) ) & 0xf0) )
	{
		setting_cursor = 0;
		if(menu_index > 1)
		{
			menu_index = menu_stack;
			submenu_index = submenu_stack;
		}
		else
		{
			menu_index = 0;
			submenu_index = 0;
			
		}
	}
	// if up key is pressed
	else if ( key_code == ((~_BV ( SW_UP ) ) & 0xf0) )
	{
		key_up_process ();
	}
	// if down key is pressed
	else if ( key_code == ((~_BV ( SW_DW ) ) & 0xf0) )
	{
		key_dw_process ();
	}
	// display menu information on LCD
	display_menu();
	flag1.bits.key_is_executed = 1;
	flag1.bits.lcd_busy = 0;
}
//*******************************************************************************************
//
// Function : menu_init
// Description : initial I/O direction for all key,
// initial timer1 for countdown timer
//
//*******************************************************************************************
void menu_init ( void )
{	
	// setup countdown initial value
	sec_count = 0;
	eeprom_read_block ( count_time, ee_count_time, 3 );
	count_time[3] = 0;

	// setup menu and standby display
	flag1.byte = 0;
	flag2.byte = 0;
	menu_index = 0;
	submenu_index = 0;
	menu_stack = 0;
	submenu_stack = 0;
	setting_cursor = 0;
	standby_cursor = 1;
}
