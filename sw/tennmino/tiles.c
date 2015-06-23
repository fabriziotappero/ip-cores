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

/* The current tile. */
static Tile tile;

/* The state of the move. Can be either 
      MOVE_CONTINUE when everything is okay to move or
      MOVE_BLOCKED  when the tile can not move down anymore. */
static uchar moveState = MOVE_CONTINUE;

/* The sequences of each tile 
   A tile is represented by a 16bit unsigned number. Every 4bit represent a
   line of the 4x4 tile starting on the top. */
static ushort seq[7][4] = {
   {0x4444, 0x00f0, 0x4444, 0x00f0},   /* I */
   {0x0e20, 0x6440, 0x8e00, 0x44c0},   /* J */
   {0x02e0, 0x6220, 0xe800, 0x88c0},   /* L */
   {0x0660, 0x0660, 0x0660, 0x0660},   /* O */
   {0x0e40, 0x4c40, 0x4e00, 0x4640},   /* T */
   {0x06c0, 0x4620, 0x06c0, 0x4620},   /* S */
   {0x0c60, 0x2640, 0x0c60, 0x2640}    /* Z */
};


/******************************************************************************
 * Reading VGA RAM                                                            *
 ******************************************************************************/
/* Read contetnts of the VGA RAM at location (x,y). */
uchar getVGAContents(uchar x, uchar y) {
   return (VGA_MEMORY[ VGA_POS(x, y) ] & 0xff);
}

/* Read a 4x4 area of the VGA RAM starting at loaction (x,y). */
uint getVGAMask(uchar x, uchar y) {
   
   uint mask = 0;

   for(uchar i=0; i < 4; i++) {
      for(uchar j=0; j < 8; j+=2) {
         if( getVGAContents(x + j, y + i) == CHR_FULL )
            mask |= 1;
            
         mask <<= 1;
      }
   }   
   return mask >> 1; // Shifting happens once too often.
}


/******************************************************************************
 * Tile Placement                                                             *
 ******************************************************************************/
/* Initialize a tile at te top of the board. */
void initTile(uchar type) {  
   tile.type = type;
   tile.tile = seq[type][0];
   tile.ridx = 0;
   tile.pos.x = VGA_H/2 - 2;     // Center tile horizontally.
   tile.pos.y = 0;
   drawTile();
}

/* Print the current tile either visible or invisible to erase it from the 
   screen. */
void printTile(uchar chr) {
   
   ushort pos;
   ushort mask = 0x8000;
   
   for(uchar i=0; i < 4; i++) {
      for(uchar j=0; j < 8; j+=2) {     
         if(tile.tile & mask) {        
            pos = VGA_POS(tile.pos.x + j, tile.pos.y + i);
            VGA_MEMORY[pos] = VGA_CHR(tile.type + 1, BLACK, chr);
            VGA_MEMORY[++pos] = VGA_CHR(tile.type + 1, BLACK, chr);
         }
         mask >>= 1;
      }
   }
}


/******************************************************************************
 * Tile Movement                                                              *
 ******************************************************************************/
/* Rotate the tile if its new rotation does not interfere with already present
   tiles or the game board. */
void rotate() { 

   ushort mask;
   uchar ridx;
   ushort rtile;
   
   eraseTile();
   
   mask = (ushort) getVGAMask(tile.pos.x, tile.pos.y);
   ridx = ++tile.ridx & 3;              // Mod 4 counter.   
   rtile = seq[tile.type][ridx];
   
   // See if the rotated tile and the area share occupied blocks. 
   if(mask & rtile) {   
      // If true we can not accept the rotation of the tile. Instead
      // draw the original tile once more.     
      moveState = MOVE_BLOCKED;
   }
   else {
      tile.ridx = ridx; 
      tile.tile = rtile;
      moveState = MOVE_CONTINUE;
   }

   drawTile();
}

/* Move in any direction and check if the tile does not interfere with already
   present tiles or the borders of the game board. */
void move(char x, char y) {
   
   ushort mask;
   
   eraseTile();

   // Grab the area for the tiles next position. The old tile is erased and 
   // won't interfere with the match.
   mask = (ushort) getVGAMask(tile.pos.x + x, tile.pos.y + y);
   
   // See if the tile and the area share occupied blocks. 
   if(mask & tile.tile) {   
      // If true we can not continue with the movement of the tile. Instead
      // draw the tile at the old position once more and change moveState.     
      moveState = MOVE_BLOCKED;
   }
   else {
      tile.pos.x += x;
      tile.pos.y += y;
      moveState = MOVE_CONTINUE;
   }
   
   drawTile();
}


/******************************************************************************
 * Game State                                                                 *
 ******************************************************************************/
/* Return the current game state. Can be either
      GAME_CONTINUE if the game can continue without further processing.
      GAME_NEW_TILE if the current tile is stuck and a new tile needs to be
                    initialized.
      GAME_OVER     if the current tile can not move down from the beginning.
 */
uchar getGameState() {

   switch(moveState) {
      case MOVE_BLOCKED:
         return (tile.pos.y == 0) ? GAME_OVER : GAME_NEW_TILE;
      
      default:
         return GAME_CONTINUE;
         break;
   }
}


/******************************************************************************
 * Deletion of Lines                                                          *
 ******************************************************************************/
/* Deletes one complete row and scrolls down the remaining board. */
uchar deleteCompletedRow(uchar x, uchar y, uchar w) {

   ushort pos = VGA_POS(x, y);

   for(uchar i=0; i<w; i++){
      if( (VGA_MEMORY[pos + i] & 0xff) != CHR_FULL )
         return 0;
   }
   
   for(uchar j = y; j>0; j--)
      for(uchar i=0; i<w; i++)
         VGA_MEMORY[VGA_POS( (x+i), j )] = VGA_MEMORY[VGA_POS( (x+i), (j-1) )];
   
   return 1;
}

/* Deletes up to four complete rows and scrolls down acordingly. Returns the
   number of deleted rows. For x deleted lines return
      0  ...     0 Points
      1  ...   128 points
      2  ...   256 points
      3  ...   512 points
      4  ...  1024 points
 */
uint deleteCompletedRows(uchar x, uchar w) {
   
   uchar cnt = 0;
   
   for(uchar i=0; i<4; i++) {
      // Empty tile lines do not change anything. 
      if( tile.tile & (0xf000 >> (i*4)) )
         cnt += deleteCompletedRow(x, tile.pos.y + i, w);
   }  
   return (cnt << 7);
}
