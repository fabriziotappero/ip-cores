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

#ifndef _VIEW_H
#define _VIEW_H

#define BOARD_LEFT     30
#define BOARD_RIGHT    64
#define BOARD_HEIGHT   36

#define BORDER_FULL     0xdb
#define BORDER_DOTTED   0xb1

/* Draw the board. */
extern void drawBoard();

/* Game Over screen. */
extern void drawGameOver();

#endif
