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
#include "tiles.h"
#include "view.h"
#include "interrupt.h"
#include "stdlib.h"

static uint interval;         // Timing interval.
static uint score;            // Game score.

/* Print the score. */
void printScore() {
   gotoxy(80, 6);
   printf("%x", score);
}

/* Randomly select the next tile. */
uchar nextTile() {
   
   uchar t;

   while( (t = rand() & 0x7) == 7 );
   return t;
}

/* With each move down, check if the tile is stuck. If so, either add a new tile
   or if the tile could not be moved any from initial position quit the game. */
void checkAndMoveDown() {
   
   moveDown();
   
   switch( getGameState() ) {
      case GAME_NEW_TILE:
         score += deleteCompletedRows(BOARD_LEFT + 2, BOARD_RIGHT - BOARD_LEFT);
         printScore();
         initTile( nextTile() );
         break;
         
      case GAME_OVER:
         unset_intr(INTR_KEYB | INTR_PIT0 | INTR_EN);
         drawGameOver();
         break;
         
      default:
         break;
   }   
}

/* Callback function for the timer. On every tick reset the clock and move
   the tile one position downwards. */
void clock() {
   pit_reset();
   checkAndMoveDown();
   pit_run(interval - score);
}

/* Callback function for the keyboard. The user can move a tile left, right, 
   down or rotate it counter-clockwise */
void keyboard() {
   switch(getc()->chr) {
      case KEY_ARROWU:
         rotate();
         break;
         
      case KEY_ARROWL:
         moveLeft();
         break; 
         
      case KEY_ARROWR:
         moveRight();
         break; 
         
      case KEY_ARROWD:
         checkAndMoveDown();
         break;
      
      case KEY_ESC:
         unset_intr(INTR_KEYB | INTR_PIT0 | INTR_EN);
         boot();
      
      default:
         break;
   }
}

int main() {
    
   drawBoard();
   
   interval = 50000 * 800;    // Movement period.
   score = 0;                 // Game score reset.
   gotoxy(80, 5);
   printf0("My Score:")
   printScore();
   
   // Enable timer and global interrupt.
   set_intr(INTR_KEYB | INTR_PIT0 | INTR_EN);
   
   // Set clock() as a callback for the PIT (IRQ_PIT0).
   register_callback(IRQ_PIT0, &clock);
   
   // Set keyboard() as a callback for the Keyboard (IRQ_KEYB).
   register_callback(IRQ_KEYB, &keyboard);
   
   // Just to be sure the PIT is ready.
   pit_reset();
   pit_run(interval);
   
   // Display the first tile.
   initTile( nextTile() );
   
   while(TRUE);
}