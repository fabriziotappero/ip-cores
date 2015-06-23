//********************************************************************************************
//
// File : lcd.c implement for 16x2 LCD module
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
// Function : lcd_send_nibble
// Description : Send data (nibble) to lcd module
//
//********************************************************************************************
void lcd_send_nibble(unsigned char datap)
{
}
//********************************************************************************************
//
// Function : lcd_send_byte
// Description : Send data (byte) to lcd module
//
//********************************************************************************************
void lcd_send_byte( char data_or_cmd, char datap )
{
}
//********************************************************************************************
//
// Function : lcd_init
// Description : Lcd module initiation.(4-bits mode)
//
//********************************************************************************************
void lcd_init(void)
{
}
//********************************************************************************************
//
// Function : lcd_gotoxy
// Description : Send SET_DDRAM command to lcd module
//
//********************************************************************************************
void lcd_gotoxy( unsigned char x, unsigned char y)
{
}
//********************************************************************************************
//
// Function : lcd_putc
// Description : Send data(byte) or command to lcd module
// '\f' is clear display command
// '\n' is new line (second line) command
// '\b' is cursor back command
//
//********************************************************************************************
void lcd_putc( unsigned char c)
{
}
//********************************************************************************************
//
// Function : lcd_print
// Description : print string from ram to lcd module
//
//********************************************************************************************
void lcd_print( BYTE *ptr )
{

	while( *ptr )
	{
		lcd_putc(*ptr++);
	}
}
//********************************************************************************************
//
// Function : lcd_print_p
// Description : print string from program memory to lcd module
//
//********************************************************************************************
void lcd_print_p( BYTE *ptr )
{
	unsigned char c;

	while(c = *ptr++ )
	{
		lcd_putc(c);
	}
}
