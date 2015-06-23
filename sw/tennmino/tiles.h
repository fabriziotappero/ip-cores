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
#include "stdio.h"

#ifndef _TILES_H
#define _TILES_H

// #define TILE_I    0x00
// #define TILE_J    0x01
// #define TILE_L    0x02
// #define TILE_O    0x03
// #define TILE_T    0x04
// #define TILE_S    0x05
// #define TILE_Z    0x06

#define CHR_FULL      0xdb
#define CHR_EMPTY     0xff

#define MOVE_CONTINUE   0     // Tile can move down.
#define MOVE_BLOCKED    1     // Tile is stuck.

#define GAME_CONTINUE   2     // Continue execution of game.
#define GAME_NEW_TILE   3     // Current tile can not move down. Get a new one.
#define GAME_OVER       4     // Current tile can not move. Game over.


typedef struct _Tile {
   uchar type;
   ushort tile;
   uchar ridx;
   cursor pos;
} Tile;


/******************************************************************************
 * Tile Placement                                                             *
 ******************************************************************************/
/* Initialize a tile at te top of the board. */
extern void initTile(uchar type);

/* Draw the current tile. */
#define drawTile()   printTile(CHR_FULL);

/* Erase the curent tile from the display. */
#define eraseTile()  printTile(CHR_EMPTY);


/******************************************************************************
 * Tile Movement                                                              *
 ******************************************************************************/
/* Rotate the tile if its new rotation does not interfere with already present
   tiles or the game board. */
extern void rotate();

/* Move current tile left. */
#define moveLeft()   move(-2, 0)

/* Move current tile right. */
#define moveRight()  move(+2, 0)

/* Move current tile down. */
#define moveDown()   move(0, +1)


/******************************************************************************
 * Game State                                                                 *
 ******************************************************************************/
/* Return the current game state. Can be either
      GAME_CONTINUE if the game can continue without further processing.
      GAME_NEW_TILE if the current tile is stuck and a new tile needs to be
                    initialized.
      GAME_OVER     if the current tile can not move down from the beginning.
 */
extern uchar getGameState();


/******************************************************************************
 * Deletion of Lines                                                          *
 ******************************************************************************/
/* Deletes up to four complete rows and scrolls down acordingly. Returns the
   number of deleted rows. For x deleted lines return
      0  ...     0 Points
      1  ...   128 points
      2  ...   256 points
      3  ...   512 points
      4  ...  1024 points
 */
extern uint deleteCompletedRows(uchar x, uchar w);

#endif
