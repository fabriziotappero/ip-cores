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
BYTE setting_cursor_max[3] = { 4, 4, 4 };
// count down timer for send temp. H:M:S
BYTE count_time_max[4] = { 2, 60, 60, 24 };
// countdown timer 4-bytes, [0]=en/dis, [1]=hour, [2]=min, [3]=sec
BYTE count_time[4];
// count down time initial value stored in eeprom. Enable/Disable, Hour, Minute
BYTE ee_count_time[3]  = { 0, 0, 1 };
BYTE str_enable[] = "Enable";
BYTE str_disable[] = "Disable";

// menu and standby display string
BYTE *menu_list[5] = 
{
	"Main menu",
    "AVR IP config",
    "Server IP config",
	"Send temp config",
	"Ping server"
};

BYTE *standby_list[4] = 
{
	"AVR IP",
	"Server IP",
	"Send temp in",
	"ADC0 & Temp"
};

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

extern union flag2
{
	BYTE byte;
	struct
	{
		unsigned char key_hold:1;
		unsigned char unuse:7;
	}bits;
}flag2;
//*****************************************************************************************
//
// Function : my_memcpy
// Description : copy string (end '\0') from program memory to ram and return pointer
// to end of string
//
//*****************************************************************************************
BYTE *my_strcpy ( BYTE *dest, BYTE *src )
{
	BYTE ch;

	while ( (ch = *src++ ) )
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
			ptr = my_strcpy ( ptr, str_disable );
		}
	}
	else
	{
		if ( cursor == 1 )
		{
			*ptr++ = ASCII_CURSOR;
			// show Enable/Disable send temparature to server
			if ( time [ 0 ] )
				ptr = my_strcpy ( ptr, str_enable );
			else
				ptr = my_strcpy ( ptr, str_disable );
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
	}
	// setup server ip
	else if( menu_index == 3 )
	{
		server_ip.byte [ setting_cursor ]++;
	}
	// setup countdown timer
	else if( menu_index == 4 )
	{
		if ( ++count_time [ setting_cursor ] == temp )
			count_time [ setting_cursor ] = 0;
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
		//eeprom_write_block ( &avr_ip, ee_avr_ip, 4 );
	}
	// setup server ip
	else if( menu_index == 3 )
	{
		server_ip.byte [ setting_cursor ]--;
		//eeprom_write_block ( &server_ip, ee_server_ip, 4 );
	}
	// setup countdown timer
	else if( menu_index == 4 )
	{
		//temp = pgm_read_byte ( (PGM_P)(count_time_max + setting_cursor) );
		if ( --count_time [ setting_cursor ] == 0xff )
			count_time [ setting_cursor ] = temp;
		//eeprom_write_block ( count_time, ee_count_time, 4 );
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
