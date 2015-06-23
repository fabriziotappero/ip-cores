
/*

connectk -- a program to play the connect-k family of games
Copyright (C) 2007 Jeff Deitch

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

#include "config.h"
#include <glib.h>
#include "../shared.h"

int cur_player_weight = 50;
int opp_player_weight = 500;
int mesh_array[19][19];

int get_mesh_value(int x, int y) {
	if (x < 0 || y < 0 || x >= board_size || y >= board_size) {
		/* out of bounds */
		return 0;
	} else {
		return mesh_array[x][y];
	}
}

int stone_weight(int x, int y) {
	if (piece_at(board, x, y) == board->turn) {
		return cur_player_weight;
	} else if (piece_at(board, x, y) == other_player(board->turn)) {
		return opp_player_weight;
	} else {
		return 0;
	}
}

int surrounding_weight(int x, int y) {

	int weight = 0;
	int n = 4;  // number of tiles in each of the 8 radials that contribute to the weight.

	int dx, dy, ddx, ddy, i;
        int ddxs[] = {1, 0, 1,  1};
        int ddys[] = {0, 1, 1, -1};

	for (i = 0; i < 4; i++) {

		ddx = ddxs[i];
		ddy = ddys[i];

		for (dx = -(ddx * n), dy = -(ddy * n); dx <= n && dy <= n; dx += ddx, dy += ddy) {
			if (dx == 0 && dy == 0) {
				continue;
			} else {
				weight += get_mesh_value(x + dx, y + dy);
			}
		}
	}

	return weight / (8 * n);
}

AIMoves *ai_mesh(const Board *b)
/* imagine the board is elastic and that each stone has a weight.  The current players stones have
a different weight than the opposite players stones.  Placing a stone on the board creates a depression,
and the more stones in an area, the deeper the depression.  This ai chooses the lowest, unplayed tile for
the next move.  The idea is to create clumps of stones.  */
{
        AIMove move;
        AIMoves *moves = aimoves_new();

	int i, x, y;
	int iterations = 10;
	int max_weight = 0;

	/* set all values to 0 */
	for (x = 0; x < board_size; x++) {
		for (y = 0; y < board_size; y++) {
			mesh_array[x][y] = 0;
		}
	}

	/* iteratively find the depth of each tile */
	for (i = 0; i < iterations; i++) {
		for (x = 0; x < board_size; x++) {
			for (y = 0; y < board_size; y++) {
				mesh_array[x][y] = stone_weight(x, y) + surrounding_weight(x, y);
			}
		}
	}

	/* find the max weight (i.e. the lowest spot on the board) */
	for (x = 0; x < board_size; x++) {
		for (y = 0; y < board_size; y++) {
			if (piece_at(b, x, y) == PIECE_NONE) {
				move.weight = mesh_array[x][y];
                                if (move.weight > max_weight)
					max_weight = move.weight;
				move.x = x;
				move.y = y;
                                aimoves_add(moves, &move);
			}
		}
	}

	/* if the board is empty, play in the middle */
	if (max_weight == 0) {
		move.x = board_size / 2;
		move.y = board_size / 2;
		move.weight = 1;
		aimoves_add(moves, &move);
	}

        moves->utility = max_weight;

	/* return the array */
	return moves;
}
