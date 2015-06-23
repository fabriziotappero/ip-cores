/* $Id: memtest.hh,v 1.8 2008-06-24 10:03:41 sybreon Exp $
** 
** VIRTUAL PERIPHERAL I/O LIBRARY
** Copyright (C) 2009 Shawn Tan <shawn.tan@aeste.net>
**
** This file is part of AEMB.
**
** AEMB is free software: you can redistribute it and/or modify it
** under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** AEMB is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
** License for more details.
**
** You should have received a copy of the GNU General Public License
** along with AEMB.  If not, see <http://www.gnu.org/licenses/>.
*/

/*!
  Character LCD Interface Library
  @file

  Interface library for standard HH44780/SED1278 character LCD
  drivers. This library assumes a 4-bit hardware interface mode to
  reduce the lines and GPIO width. 

  Routines modified from AVRLib by Pascal Stang.
 */

#include "vpioGpio.h"

#ifndef VPIO_LCD_H
#define VPIO_LCD_H

#define LCD_NIB 1 // nibble mode
#define WAIT_STATE 1

// GPIO control lines - DO NOT MODIFY
#define LCD_D7 7 // D7 - P14
#define LCD_D6 6 // D6 - P13
#define LCD_D5 5 // D5 - P12
#define LCD_D4 4 // D4 - P11
#define LCD_EN 3 // EN - P6
#define LCD_RW 2 // RW - P5
#define LCD_RS 1 // RS - P4
#define LCD_HB 0 // HB - NC

// HD44780 LCD controller command set (do not modify these)
// writing:
#define LCD_CLR             0      // DB0: clear display
#define LCD_HOME            1      // DB1: return to home position
#define LCD_ENTRY_MODE      2      // DB2: set entry mode
#define LCD_ENTRY_INC       1      //   DB1: increment
#define LCD_ENTRY_SHIFT     0      //   DB2: shift
#define LCD_ON_CTRL         3      // DB3: turn lcd/cursor on
#define LCD_ON_DISPLAY      2      //   DB2: turn display on
#define LCD_ON_CURSOR       1      //   DB1: turn cursor on
#define LCD_ON_BLINK        0      //   DB0: blinking cursor
#define LCD_MOVE            4      // DB4: move cursor/display
#define LCD_MOVE_DISP       3      //   DB3: move display (0-> move cursor)
#define LCD_MOVE_RIGHT      2      //   DB2: move right (0-> left)
#define LCD_FUNCTION        5      // DB5: function set
#define LCD_FUNCTION_8BIT   4      //   DB4: set 8BIT mode (0->4BIT mode)
#define LCD_FUNCTION_2LINES 3      //   DB3: two lines (0->one line)
#define LCD_FUNCTION_10DOTS 2      //   DB2: 5x10 font (0->5x7 font)
#define LCD_CGRAM           6      // DB6: set CG RAM address
#define LCD_DDRAM           7      // DB7: set DD RAM address
// reading:
#define LCD_BUSY            7      // DB7: LCD is busy

// Default LCD setup
// this default setup is loaded on LCD initialization
#define LCD_FDEF_1	     (0<<LCD_FUNCTION_8BIT)
#define LCD_FDEF_2	     (1<<LCD_FUNCTION_2LINES)
#define LCD_FUNCTION_DEFAULT ((1<<LCD_FUNCTION) | LCD_FDEF_1 | LCD_FDEF_2)
#define LCD_MODE_DEFAULT     ((1<<LCD_ENTRY_MODE) | (1<<LCD_ENTRY_INC))

#define LCD_OUTPUT  0xFF
#define LCD_INPUT   0x0F

typedef struct gpioRegs lcdRegs;

// Low-level I/O functions
void lcdReset(lcdRegs* lcd);
void lcdWaitBusy(lcdRegs* lcd);
void lcdPutControl(lcdRegs* lcd, char ctrl);
char lcdGetControl(lcdRegs* lcd);
void lcdPutData(lcdRegs* lcd, char data);
char lcdGetData(lcdRegs* lcd);
void lcdDelay(int ms);
//void lcdSetTris(lcdRegs* lcd, gpioTrisType dir);

// High-level application functions
void lcdInit(lcdRegs* lcd);
void lcdHome(lcdRegs* lcd);
void lcdClear(lcdRegs* lcd);


/*!
  Reset the LCD hardware.

  @param lcd LCD GPIO port.
 */

void lcdReset(lcdRegs* lcd)
{
  // set GPIO to output
  gpioSetTris(lcd, LCD_OUTPUT);  

  // clear lines
  /*
  gpioClrBit(lcd, LCD_RS);
  gpioClrBit(lcd, LCD_RW);
  gpioClrBit(lcd, LCD_EN);
  */
  gpioPutData(lcd, 0x00);

  // set lines
  /*
  gpioSetBit(lcd, LCD_RS);
  gpioSetBit(lcd, LCD_RW);
  gpioSetBit(lcd, LCD_EN);
  */
  gpioPutData(lcd, 0xFF);

  // set GPIO to input
  gpioSetTris(lcd, LCD_INPUT);    
}

/*!
  Blocking wait for LCD busy signal.

  This function blocks the LCD port while the busy signal is asserted
  by the LCD.

  @param lcd LCD GPIO port.
 */
void lcdWaitBusy(lcdRegs* lcd)
{  
  int i;
  gpioSetTris(lcd, LCD_INPUT); // set INPUT
  //gpioClrBit(lcd, LCD_RS); // select CONTROL
  //gpioSetBit(lcd, LCD_RW); // set to READ
  //gpioSetBit(lcd, LCD_EN);
  gpioPutData(lcd, (1<<LCD_RW) | (1<<LCD_EN)); // EN|RD|CT
  lcdDelay(WAIT_STATE);
  while (gpioGetBit(lcd, LCD_BUSY))
    {
      for (i = 2; i>0; --i)
	{
	  /*
	    gpioClrBit(lcd, LCD_EN);
	    lcdDelay(WAIT_STATE);
	    gpioSetBit(lcd, LCD_EN);
	    lcdDelay(WAIT_STATE);
	  */
	  gpioPutData(lcd, (1<<LCD_RW) );
	  lcdDelay(WAIT_STATE);
	  gpioPutData(lcd, (1<<LCD_RW) | (1<<LCD_EN) );
	  lcdDelay(WAIT_STATE);
	}
    }

  gpioPutData(lcd, (1<<LCD_RW) );
  //gpioClrBit(lcd, LCD_EN);
  //gpioTogBit(lcd, LCD_HB);
}

/*!
  Write a control byte to the LCD.

  This function writes a byte to the LCD control register.
  @param lcd LCD GPIO port.
  @param ctrl Control byte to write
 */
void lcdPutControl(lcdRegs* lcd, char ctrl)
{
  lcdWaitBusy(lcd); // wait until free
  //gpioClrBit(lcd, LCD_RS); // select CONTROL
  //gpioClrBit(lcd, LCD_RW); // set to WRITE
  gpioPutData(lcd, (1<<LCD_HB));
  gpioSetTris(lcd, LCD_OUTPUT); // Set OUTPUT

  gpioPutData(lcd, (gpioGetData(lcd) & 0x0F) | (ctrl & 0xF0) );
  gpioSetBit(lcd, LCD_EN); 
  lcdDelay(WAIT_STATE);
  gpioClrBit(lcd, LCD_EN);
  lcdDelay(WAIT_STATE);
  gpioPutData(lcd, (gpioGetData(lcd) & 0x0F) | (ctrl << 4) );
  gpioSetBit(lcd, LCD_EN);
  lcdDelay(WAIT_STATE);
  gpioClrBit(lcd, LCD_EN);
  gpioSetTris(lcd, LCD_INPUT); // set INPUT
}

/*!
  Read a control byte from the LCD.

  This function reads a control byte from the LCD control register.
  @param lcd LCD GPIO port.
  @return control register value.
 */

char lcdGetControl(lcdRegs* lcd)
{
  char b;
  lcdWaitBusy(lcd); // wait until free
  gpioSetTris(lcd, LCD_INPUT); // Set INPUT
  //gpioClrBit(lcd, LCD_RS); // select CONTROL
  //gpioSetBit(lcd, LCD_RW); // set to READ
  //gpioSetBit(lcd, LCD_EN); 
  gpioPutData(lcd, (1<<LCD_RW) | (1<<LCD_EN) );
  lcdDelay(WAIT_STATE);

  b = gpioGetData(lcd) & 0xF0; // read upper nib
  gpioClrBit(lcd, LCD_EN);
  lcdDelay(WAIT_STATE);
  gpioSetBit(lcd, LCD_EN);
  lcdDelay(WAIT_STATE);
  gpioClrBit(lcd, LCD_EN);
  b |= (gpioGetData(lcd) >> 4); // read lower nib
  gpioSetTris(lcd, LCD_INPUT); // set INPUT
  return b;
}

/*!
  Write a data byte to the LCD.

  This function writes a byte to the LCD data register.
  @param lcd LCD GPIO port.
  @param ctrl Control byte to write
 */
void lcdPutData(lcdRegs* lcd, char data)
{
  lcdWaitBusy(lcd); // wait until free
  //gpioSetBit(lcd, LCD_RS); // select DATA
  //gpioClrBit(lcd, LCD_RW); // set to WRITE
  gpioPutData(lcd, (1<<LCD_RS) );
  gpioSetTris(lcd, LCD_OUTPUT); // Set OUTPUT

  gpioPutData(lcd, (gpioGetData(lcd) & 0x0F) | (data & 0xF0) );
  gpioSetBit(lcd, LCD_EN); 
  lcdDelay(WAIT_STATE);
  gpioClrBit(lcd, LCD_EN);
  lcdDelay(WAIT_STATE);
  gpioPutData(lcd, (gpioGetData(lcd) & 0x0F) | (data << 4) );
  gpioSetBit(lcd, LCD_EN);
  lcdDelay(WAIT_STATE);
  gpioClrBit(lcd, LCD_EN);
  //gpioPutData(lcd, (1<<LCD_RS) );
  gpioSetTris(lcd, LCD_INPUT); // set INPUT
}

/*!
  Read a data byte from the LCD.

  This function reads a control byte from the LCD control register.
  @param lcd LCD GPIO port.
  @return data register value.
 */

char lcdGetData(lcdRegs* lcd)
{
  char b;
  lcdWaitBusy(lcd); // wait until free
  gpioSetTris(lcd, LCD_INPUT); // Set INPUT
  gpioSetBit(lcd, LCD_RS); // select DATA
  gpioSetBit(lcd, LCD_RW); // set to READ
  gpioSetBit(lcd, LCD_EN); 
  lcdDelay(WAIT_STATE);
  b = gpioGetData(lcd) & 0xF0; // read upper nib
  gpioClrBit(lcd, LCD_EN);
  lcdDelay(WAIT_STATE);
  gpioSetBit(lcd, LCD_EN);
  lcdDelay(WAIT_STATE);
  gpioClrBit(lcd, LCD_EN);
  b |= (gpioGetData(lcd) >> 4); // read lower nib
  gpioSetTris(lcd, LCD_INPUT); // set INPUT
  return b;
}

/*!
  Initialisation Routine.

  This function brings the LCD through the standard initialisation
  process. It sets the LCD mode to default entry modes, clears the
  screen and cursors to home.

  @param lcd LCD GPIO port.
 */

void lcdInit(lcdRegs* lcd)
{
  lcdReset(lcd); // reset HW
  
  lcdPutControl(lcd, LCD_FUNCTION_DEFAULT);
  
  lcdPutControl(lcd, 1 << LCD_CLR);
  lcdDelay(0x00008000); // delay 30ms+

  lcdPutControl(lcd, 1 << LCD_ENTRY_MODE | 1 << LCD_ENTRY_INC);
  lcdPutControl(lcd, 1 << LCD_ON_CTRL | 1 << LCD_ON_DISPLAY);

  lcdPutControl(lcd, 1 << LCD_HOME);
  lcdPutControl(lcd, 1 << LCD_DDRAM | 0x00);    
}

/*!
  Arbitrary delay routine.

  This function does a NOP loop for an arbitrary number of cycles. The
  cycles are not calibrated to any clock but is assumed to run on a
  nominal 100MHz clock.
  
  @param us Assume number of micro-seconds (us).
 */

inline
void lcdDelay(int us)
{
  int i;
  //for (i = 0; i < (ms << 3); ++i) { asm volatile ("nop"); } // do NOP
  for (i = us << 4; i > 0; --i) { asm volatile ("nop"); } // do NOP
}

/*!
  Returns the LCD cursor to home.

  @param lcd LCD GPIO port.
 */
void lcdHome(lcdRegs* lcd)
{
  lcdPutControl(lcd, 1<<LCD_HOME);
}

/*!
  Clear the LCD screen.

  @param lcd LCD GPIO port.
 */
void lcdClear(lcdRegs* lcd)
{
  lcdPutControl(lcd, 1<<LCD_CLR);
}

#endif
