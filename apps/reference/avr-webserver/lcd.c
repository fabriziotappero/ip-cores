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
void lcd_send_nibble(unsigned char data)
{
	data &= 0xF0;
	LCD_DATA_PORT &= 0x0F;
	LCD_DATA_PORT |= data;
	_delay_us(1);	// 1us
	LCD_CONTROL_PORT |= _BV(LCD_EN_PIN);
	_delay_us(2);
	LCD_CONTROL_PORT &= ~_BV(LCD_EN_PIN);
}
//********************************************************************************************
//
// Function : lcd_send_byte
// Description : Send data (byte) to lcd module
//
//********************************************************************************************
void lcd_send_byte( char data_or_cmd, char data )
{
	LCD_CONTROL_PORT &= ~_BV(LCD_RS_PIN);
	if(data_or_cmd)
		LCD_CONTROL_PORT |= _BV(LCD_RS_PIN);
	else
		LCD_CONTROL_PORT &= ~_BV(LCD_RS_PIN);
	_delay_us(50);		// 1us
	LCD_CONTROL_PORT &= ~_BV(LCD_EN_PIN);
	lcd_send_nibble(data & 0xF0);
	lcd_send_nibble(data << 4);
}
//********************************************************************************************
//
// Function : lcd_init
// Description : Lcd module initiation.(4-bits mode)
//
//********************************************************************************************
void lcd_init(void)
{
	char i;
	LCD_DATA_DDR |= (_BV(LCD_D7) | _BV(LCD_D6) | _BV(LCD_D5) | _BV(LCD_D4));
	LCD_CONTROL_DDR |= (_BV(LCD_RS_PIN) | _BV(LCD_RW_PIN) | _BV(LCD_EN_PIN));

	LCD_DATA_PORT &= ~(_BV(LCD_D7) | _BV(LCD_D6) | _BV(LCD_D5) | _BV(LCD_D4));
	LCD_CONTROL_PORT &= ~(_BV(LCD_RS_PIN) | _BV(LCD_RS_PIN) | _BV(LCD_RS_PIN));
	
	_delay_ms(15);		// 15 ms
	for(i=1;i<=3;++i)
	{
       lcd_send_nibble(0x30);
       _delay_ms(5);	// 5 ms
    }
    lcd_send_nibble(0x20);
	lcd_send_byte(WRITE_COMMAND, SET_FUNCTION);
	lcd_send_byte(WRITE_COMMAND, DISPLAY_ON);
	lcd_send_byte(WRITE_COMMAND, DISPLAY_CLR);
	lcd_send_byte(WRITE_COMMAND, ENTRY_MODE);
}
//********************************************************************************************
//
// Function : lcd_gotoxy
// Description : Send SET_DDRAM command to lcd module
//
//********************************************************************************************
void lcd_gotoxy( unsigned char x, unsigned char y)
{
	char address=0;

	if(y!=1)
		address = LCD_LINE_TWO;
	address += x-1;
	lcd_send_byte(WRITE_COMMAND, SET_DDRAM|address);
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
	if(c == '\f')
	{
		lcd_send_byte(WRITE_COMMAND, DISPLAY_CLR);
		_delay_ms(2);	// 2ms
	}
	else if(c == '\n')
		lcd_gotoxy(1, 2);
	else if(c == '\b')
		lcd_send_byte(WRITE_COMMAND, CURSOR_BACK);
	else
		lcd_send_byte(WRITE_DATA, c);
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
void lcd_print_p( PGM_P ptr )
{
	unsigned char c;

	while( (c = pgm_read_byte ( ptr++ )) )
	{
		lcd_putc(c);
	}
}
