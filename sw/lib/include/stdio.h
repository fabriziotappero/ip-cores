/******************************************************************************
 * Standard Input/Output                                                      *
 ******************************************************************************
 * Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.com>          *
 *                                                                            *
 * This program is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by       *
 * the Free Software Foundation, either version 3 of the License, or          *
 * (at your option) any later version.                                        *
 *                                                                            *
 * This program is distributed in the hope that it will be useful,            *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 * GNU General Public License for more details.                               *
 *                                                                            *
 * You should have received a copy of the GNU General Public License          *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.      *
 ******************************************************************************/
#include "stddef.h"

#ifndef _STDIO_H
#define _STDIO_H

/******************************************************************************
 * VGA                                                                        *
 ******************************************************************************/
/* Pointer to VGA display memory. */
#define VGA_MEMORY ( (volatile ushort *) 0xffff0000 )

/* Maximum values of the display's horizontal and vertical coordinates. */
#define VGA_H 100
#define VGA_V 37

/* Calculates the position of the cursor from its x and y coordinates that is
   actually 10*y + x, substituting a multiplication with left shifts and 
   additions. */   
#define VGA_POS(x,y) ( (y << 6) + (y << 5) + (y << 2) + x )

/* Set up character information of type 0fff0bbb cccccccc where f and b are the 
   3-bit foreground and background colors respectively. c denotes the 8-bit 
   character. 
   NOTE: Does not check for 3 bit color and 8 bit character limits. */
#define VGA_CHR(f,b,c) ( (f << 12) | (b << 8) | c )

/* Available colors on an 8 color VGA display. */
#define BLACK     ((uchar) 0)
#define BLUE      ((uchar) 1)
#define GREEN     ((uchar) 2)
#define CYAN      ((uchar) 3)
#define RED       ((uchar) 4)
#define MAGENTA   ((uchar) 5)
#define YELLOW    ((uchar) 6)
#define WHITE     ((uchar) 7)


/******************************************************************************
 * Keyboard                                                                   *
 ******************************************************************************/
/* Pointer to Keyboard character memory. */
#define KEYB_MEMORY ((volatile uint *) 0xffff3000)

/* Input buffer size */
#define INBUF_SIZE  128

/* Funtional key flags. */
#define KEYB_SHIFT  ((uchar) 0x80)
#define KEYB_CTRL   ((uchar) 0x40)
#define KEYB_ALT    ((uchar) 0x20)
#define KEYB_ALTGR  ((uchar) 0x10)

/* Special keys. */
#define KEY_ENTER   ((uchar) 0x0d)
#define KEY_BACKSP  ((uchar) 0x08)
#define KEY_TAB     ((uchar) 0x09)
#define KEY_ESC     ((uchar) 0x1b)
#define KEY_DEL     ((uchar) 0x7f)
#define KEY_SCROLL  ((uchar) 0x80)
#define KEY_ARROWU  ((uchar) 0xf0)
#define KEY_ARROWL  ((uchar) 0xf1)
#define KEY_ARROWD  ((uchar) 0xf2)
#define KEY_ARROWR  ((uchar) 0xf3)


/******************************************************************************
 * Type Definitions                                                           *
 ******************************************************************************/
/* Color information structure. */
typedef struct _color {
   uchar fg;
   uchar bg;
} color;

/* Cursor position structure. */
typedef struct _cursor {
   uchar x;
   uchar y;
} cursor;

/* Key */
typedef struct _key {
   uchar flags;
   uchar chr;
} key;


/******************************************************************************
 * Output Functions                                                           *
 ******************************************************************************/
/* Set text and background colors. */
extern void setcolor(uchar fg, uchar bg);
 
/* Set cursor at position x,y. */ 
extern void gotoxy(uchar x, uchar y);
 
/* Clears the entire display and resets the cursor. */
extern void cls();

/* Scrolls down one line and clears the lowest line. The vertical cursor jumps 
   one line up, if not already on line one. If the cursor is on the first line
   the horizontal cursor is reset to zero. */
extern void scroll();

/* Outputs a single character onto the screen. */
extern void putc(const uchar chr);

/* Print a string without it's trailing '\0' onto the screen. */
extern void puts(const uchar *str);

/* Formatted string printig. The following parameters are available:
      +----+--------------------------------------------------+
      | %s | print a string                                   |
      | %c | print a single character                         |
      | %x | print a hexadecimal representation of an integer |
      | %b | print a binary representation of an intger       |
      | %% | print a '%'                                      |
      +----+--------------------------------------------------+  
      +----+----------------+
      | \n | line break     |
      | \r | carrage return |
      | \t | tab space      |
      | \b | back space     |
      | \\ | print a '\'    |
      +----+----------------+
   
   Despite the standard printf implementation, you can manipulate the background
   and text colors:     
      +----+---------+----+---------+----+---------+----+---------+
      | $k | black   | $b | blue    | $g | green   | $c | cyan    |
      | $r | red     | $m | magenta | $y | yellow  | $w | white   |
      +----+---------+----+---------+----+---------+----+---------+
        $$ - print a '$'

   The background colors can be specified the same way with a '#' as a format
   indicator. Besides the format string, the function takes only one value 
   argunment. */
extern void printf(const uchar *format, void *arg);

#define printf0(f) printf(f, NULL);

/******************************************************************************
 * Input Functions                                                            *
 ******************************************************************************/
/* Polls for a singe character. The keyboard controller only sends make codes
   and postpones the read ack until a key is pressed. */   
extern key* getc();

/* Returns a string of at most INBUF_SIZE characters (without '\0'). The user 
   can confirm the input with the enter button. */
extern uchar* gets();

#endif
