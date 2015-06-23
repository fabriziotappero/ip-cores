/******************************************************************************
 * Tennmino Version 0.1                                                       *
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
#include "view.h"

/* Draw a vertical border line. The line width is 2 characters. */
void drawVerticalBorder(uchar x, uchar y, uchar h, uchar chr) {
   for(uchar i=y; i < h; i++) {
      gotoxy(x, i);
      putc(chr); putc(chr);
   }
} 

/* Draw a horizontal border line. */
void drawHorizontalBorder(uchar x, uchar y, uchar w, uchar chr) {
   gotoxy(x, y);  
   for(uchar i=0; i < w + 2; i++) {      
      putc(chr);
   }
}

/* Draw the board. */
void drawBoard() {

   cls();

   drawVerticalBorder(BOARD_LEFT, 0, BOARD_HEIGHT, BORDER_FULL);
   drawVerticalBorder(BOARD_RIGHT, 0, BOARD_HEIGHT, BORDER_FULL);
   drawHorizontalBorder(
      BOARD_LEFT, 
      BOARD_HEIGHT, 
      BOARD_RIGHT - BOARD_LEFT, 
      BORDER_FULL
   );
}

/* Game Over screen. */
void drawGameOver() {
   
   cls();
   
   gotoxy(45, 15);
   printf0("GAME OVER!");
}