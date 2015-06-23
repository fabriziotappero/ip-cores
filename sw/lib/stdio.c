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
#include "stdio.h"
#include "stdlib.h"

/* Current character and background color. */
static color col = {WHITE, BLACK};

/* Current cursor position. */
static cursor cur = {0, 0};

/* Current received key. */
static key ckey;

/* Input buffer. Holds INBUF_SIZE keyboard input characters. This variable is
   located in the *.bss section and thus all zero. Important for the termination
   character '\0' at position INBUF_SIZE. */
static uchar inbuf[INBUF_SIZE+1];

/* Buffer for all number to string converting functions: itoa, itox, itob */
static uchar bufc[35];

/******************************************************************************
 * Private Functions                                                          *
 ******************************************************************************/
/* Save cur.y--; */
static void decy() {
   if(cur.y > 0) cur.y--;
} 
 
/* Save cur.x--; */
static void decx() {
   if(cur.x > 0) {
      cur.x--;
   }
   else {
      decy();
      cur.x = VGA_H-1;
   }

   // if(--cur.x < 0) {
      // decy();
      // cur.x = VGA_H-1;
   // }
}

/* Save cur.y++; */
static void incy() {
   if(++cur.y >= VGA_V) scroll();
}

/* Save cur.x++; */
static void incx() {
   if(++cur.x >= VGA_H) {
      incy();
      cur.x = 0;
   }  
}

/******************************************************************************
 * Output Functions                                                           *
 ******************************************************************************/
/* Set text and background colors. */
void setcolor(uchar fg, uchar bg) {
   col.fg = fg;
   col.bg = bg;
}
 
 /* Set cursor at position x,y. */ 
void gotoxy(uchar x, uchar y) {
   if(x < 100) cur.x = x;
   if(y < 37)  cur.y = y;
}

/* Clears the entire display and resets the cursor. */
void cls() {
   for(int i=0; i < VGA_H * VGA_V; VGA_MEMORY[i++] = 0); // Clear display.
   cur.x = 0;                                            // Reset cursor.
   cur.y = 0;
}

/* Scrolls down one line and clears the lowest line. The vertical cursor jumps 
   one line up, if not already on line one. If the cursor is on the first line
   the horizontal cursor is reset to zero. */
void scroll() {  

   // Shift up content one line.
   for(int i=VGA_H; i < VGA_H * VGA_V; VGA_MEMORY[i-VGA_H] = VGA_MEMORY[i++]);     
   // Clean up last line.
   for(int i=VGA_H * (VGA_V-1); i < VGA_H * VGA_V; VGA_MEMORY[i++] = 0);      
   // Reposition cursor.
   if(cur.y == 0) cur.x = 0;  // On top line carrage return.
   decy();
}

/* Outputs a single character onto the screen. */
void putc(const uchar chr) {   
   VGA_MEMORY[ VGA_POS(cur.x, cur.y) ] = VGA_CHR(col.fg, col.bg, chr);
   incx();
}

/* Print a string without it's trailing '\0' onto the screen. */
void puts(const uchar *str) {   
   for(char *s = str; *s; putc(*s++));
}

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
void printf(const uchar *format, void *arg) {
   
   char *f = format;
   
   for(char c; c = *f; f++) {
      switch(c) {
      
         // Argument format flags.
         case '%':
            switch( (c = *++f) ) {
               case '%': putc(c);                           break;
               case 's': puts( (uchar *) arg );             break;
               case 'c': putc( (uchar) arg );               break;
               case 'd': /*puts( itoa((int *) arg, bufc) );*/ break;
               case 'x': puts( itox((int *) arg, bufc) );   break;
               case 'b': puts( itob((int *) arg, bufc) );   break;
            }
            break;  
         
         // Foreground color state arguments.
         case '$':
            switch( (c = *++f) ) {
               case '$': putc(c);            break;
               case 'k': col.fg = BLACK;     break;
               case 'b': col.fg = BLUE;      break;
               case 'g': col.fg = GREEN;     break;
               case 'c': col.fg = CYAN;      break;
               case 'r': col.fg = RED;       break;
               case 'm': col.fg = MAGENTA;   break;
               case 'y': col.fg = YELLOW;    break;
               case 'w': col.fg = WHITE;     break;
            }            
            break;
            
         // Background color state arguments.
         case '#':
            switch( (c = *++f) ) {
               case '#': putc(c);            break;
               case 'k': col.bg = BLACK;     break;
               case 'b': col.bg = BLUE;      break;
               case 'g': col.bg = GREEN;     break;
               case 'c': col.bg = CYAN;      break;
               case 'r': col.bg = RED;       break;
               case 'm': col.bg = MAGENTA;   break;
               case 'y': col.bg = YELLOW;    break;
               case 'w': col.bg = WHITE;     break;
            }            
            break;
            
         // Text layout flags.
         case '\\':
            putc(c);
            break;
         case '\n':           
            incy();
            cur.x = 0;
            break;
         case '\r':
            cur.x = 0;
            break;
         case '\t':
            cur.x += 4; // ohohhhh
            cur.x &= ~3;
            break;
         case '\b':            
            decx();
            break;
            
         default:
            putc(c);
            break;
      }
   }
}

/******************************************************************************
 * Input Functions                                                            *
 ******************************************************************************/
/* Polls for a singe character. The keyboard controller only sends make codes
   and postpones the read ack until a key is pressed. */   
key* getc() {

   // Blocks until keyboard input is ready.
   uint k = KEYB_MEMORY[0];   
   
   ckey.flags = k >> 4;
   ckey.chr = k;         
   return &ckey;
}

/* Returns a string of at most INBUF_SIZE characters (without '\0'). The user 
   can confirm the input with the enter button. */
uchar* gets() {
   
   int i=0;
   uchar chr;

   while( ((chr = getc()->chr) != KEY_ENTER) && (i < INBUF_SIZE) ) {
   
      if(chr == KEY_BACKSP) {      
         // Go back no further than the start of the input.
         if(i > 0) {
            decx();     
            // Undo last character.
            VGA_MEMORY[ VGA_POS(cur.x, cur.y) ] = 0; 
            // Clear buffer.
            inbuf[i--] = '\0';
         }           
      }
      else {
         putc(chr);
         inbuf[i++] = chr;
      }
   }   
   
   // We do not need to terrminate the string if we ran out of buffer size
   // (i == INBUF_SZE), since it is by default zero and will not be altered.
   inbuf[i] = '\0';  
   return inbuf;
}
