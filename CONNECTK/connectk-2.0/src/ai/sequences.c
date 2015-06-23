
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
#include <string.h>
#include "../shared.h"

int utility_upper_bound;

/* arrays for holding the utility and threat values for each window */
int white_window_sequence_array[MAX_BOARD_SIZE][MAX_BOARD_SIZE][4];
int black_window_sequence_array[MAX_BOARD_SIZE][MAX_BOARD_SIZE][4];
int white_window_threat_array[MAX_BOARD_SIZE][MAX_BOARD_SIZE][4];
int black_window_threat_array[MAX_BOARD_SIZE][MAX_BOARD_SIZE][4];

/* arrays for holding the marks used for counting threats */
int whites_marks[MAX_BOARD_SIZE][MAX_BOARD_SIZE];
int blacks_marks[MAX_BOARD_SIZE][MAX_BOARD_SIZE];

/* the sum of all the windows' values for threats and utility */
int white_window_sequence_count;
int black_window_sequence_count;
int white_threat_count;
int black_threat_count;

/* the max sequence on a board */
int max_white_sequence;
int max_black_sequence;

/* Returns an integer to identify the window */
static int window_id(BCOORD x, BCOORD y, int i)
{
	return x * board_size * 4 + y * 4 + i + 1;
}

static void clear_all()
{
	/* clears all values in the matricies that hold the window scores and threat info */
	int x, y, d;
	for (x = 0; x < board_size; x++) {
		for (y = 0; y < board_size; y++) {

			blacks_marks[x][y] = 0;
			whites_marks[x][y] = 0;

			for (d = 0; d < 4; d++) {
				white_window_sequence_array[x][y][d] = 0;
				black_window_sequence_array[x][y][d] = 0;
				white_window_threat_array[x][y][d] = 0;
				black_window_threat_array[x][y][d] = 0;
			}
		}
	}

	white_window_sequence_count = 0;
	black_window_sequence_count = 0;
	white_threat_count = 0;
	black_threat_count = 0;

	max_black_sequence = 0;
	max_white_sequence = 0;
}

/* A utility function of a particular window for a given player */
static void window_sequence(const Board *b, BCOORD x, BCOORD y, int i, PIECE player)
{
	int sequence, count_sequence, count_threat, dx, dy, ddx, ddy, j, len;
	int ddxs[] = {1, 0, 1,  1};
	int ddys[] = {0, 1, 1, -1};
	int to_mark[MAX_CONNECT_K];

	ddx = ddxs[i];
	ddy = ddys[i];

	len = 0;
	count_sequence = 0;
	count_threat = 0;
	sequence = 0;

	if (player == PIECE_WHITE) {
		// We are recalculating this window's threat level.
		// Start be taking this window's previous threat out of the sum
		// and reset it to 0.
		white_threat_count -= white_window_threat_array[x][y][i];
		white_window_threat_array[x][y][i] = 0;

		// Do the same for the sequence count.
		white_window_sequence_count -= white_window_sequence_array[x][y][i];
		white_window_sequence_array[x][y][i] = 0;

		// step through the window.
		for (dx = 0, dy = 0; dx < connect_k && dy < (int)connect_k; dx += ddx, dy += ddy) {
			if (x + dx < 0 || y + dy < 0 || x + dx >= board_size || y + dy >= board_size) {
				break;
			}
			// If this window was the one that marked this spot, unmark it so we can recheck.
			if (whites_marks[x + dx][y + dy] == window_id(x, y, i)) {
				whites_marks[x + dx][y + dy] = 0;
			}

			if (piece_at(b, x + dx, y + dy) == PIECE_NONE) {
				count_sequence++;
				if (whites_marks[x + dx][y + dy] == 0) {
					count_threat++;
					to_mark[len++] = x + dx;
					to_mark[len++] = y + dy;
				}
			} else if (piece_at(b, x + dx, y + dy) == player) {
				count_sequence++;
				count_threat++;
				sequence++;
			}
		}

		if (count_threat == connect_k) {
			/* if this is a threat, update the threat array */
			if (sequence >= (connect_k - place_p)) {
				for (j = 0; j < len; j+=2) {
					whites_marks[to_mark[j]][to_mark[j+1]] = window_id(x, y, i);
				}
				white_window_threat_array[x][y][i] = 1;
				white_threat_count += 1;
			}
		}

		if (count_sequence == connect_k) {

			/* if this is the max sequence of the board, update the max_sequence value */
			if (sequence > max_white_sequence) {
				max_white_sequence = sequence;
			}

			/* if the sequence is greater than connect_k - place_p, set it equal to connect_k - place_p.
			This prevents it from giving a sequence of 5 a higher score than a sequence of 4 in the default game.  */
			if (sequence > (connect_k - place_p)) {
				sequence = (connect_k - place_p);
			}

			/* update the utility array values */
			white_window_sequence_array[x][y][i] = sequence * sequence;
			white_window_sequence_count += white_window_sequence_array[x][y][i];
		}

		/* Do it all again if we are black.  There must be a better way to do this */
	} else if (player == PIECE_BLACK) {
		// We are recalculating this window's threat level.
		// Start be taking this window's previous threat out of the sum
		// and reset it to 0.
		black_threat_count -= black_window_threat_array[x][y][i];
		black_window_threat_array[x][y][i] = 0;

		// Do the same for the sequence count.
		black_window_sequence_count -= black_window_sequence_array[x][y][i];
		black_window_sequence_array[x][y][i] = 0;

		// step through the window.
		for (dx = 0, dy = 0; dx < connect_k && dy < (int)connect_k; dx += ddx, dy += ddy) {
			if (x + dx < 0 || y + dy < 0 || x + dx >= board_size || y + dy >= board_size) {
				break;
			}
			// If this window was the one that marked this spot, unmark it so we can recheck.
			if (blacks_marks[x + dx][y + dy] == window_id(x, y, i)) {
				blacks_marks[x + dx][y + dy] = 0;
			}

			if (piece_at(b, x + dx, y + dy) == PIECE_NONE) {
				count_sequence++;
				if (blacks_marks[x + dx][y + dy] == 0) {
					count_threat++;
					to_mark[len++] = x + dx;
					to_mark[len++] = y + dy;
				}
			} else if (piece_at(b, x + dx, y + dy) == player) {
				count_sequence++;
				count_threat++;
				sequence++;
			}
		}

		if (count_threat == connect_k) {
			/* if this is a threat, update the threat array */
			if (sequence >= (connect_k - place_p)) {
				for (j = 0; j < len; j+=2) {
					blacks_marks[to_mark[j]][to_mark[j+1]] = window_id(x, y, i);
				}
				black_window_threat_array[x][y][i] = 1;
				black_threat_count += 1;
			}
		}

		if (count_sequence == connect_k) {

			/* if this is the max sequence of the board, update the max_sequence value */
			if (sequence > max_black_sequence) {
				max_black_sequence = sequence;
			}

			/* if the sequence is greater than connect_k - place_p, set it equal to connect_k - place_p.
			This prevents it from giving a sequence of 5 a higher score than a sequence of 4 in the default game.  */
			if (sequence > (connect_k - place_p)) {
				sequence = (connect_k - place_p);
			}

			/* update the utility array values */
			black_window_sequence_array[x][y][i] = sequence * sequence;
			black_window_sequence_count += black_window_sequence_array[x][y][i];
		}
	} else {
		g_debug("error in window_sequence(), unknown board turn.");
	}
}

int board_utility(const Board *b, PIECE player)
/* This returns the utility value of the board
It looks for a few things, first if the currently player is on their way to winning
(have enough moves left in given turn to win) it returns a high utility
second if there is a threat on this board from the other player, it gives a very low utility.
Third, if the board is going to force a win for the player, it gives a high utility.
If none of these are true, it adds up the utilities of all the windows and subtracts
the sum of the utilities of the other player times the defensive constant */
{

	int utility = 0;
	utility_upper_bound = 2 * board_size * board_size * connect_k * connect_k;

	if (b->turn == PIECE_WHITE) {
		if ((connect_k - max_white_sequence) <= (b->moves_left)) {
			utility = utility_upper_bound;
		} else if (black_threat_count) {
			utility = -utility_upper_bound - black_threat_count;
		} else if (white_threat_count > place_p) {
			utility = utility_upper_bound - 1;
		} else {
			utility = white_window_sequence_count - black_window_sequence_count;
		}
	} else if (b->turn == PIECE_BLACK) {
		if ((connect_k - max_black_sequence) <= (b->moves_left)) {
			utility = utility_upper_bound;
		} else if (white_threat_count) {
			utility = -utility_upper_bound - white_threat_count;
		} else if (black_threat_count > place_p) {
			utility = utility_upper_bound - 1;
		} else {
			utility = black_window_sequence_count - white_window_sequence_count;
		}
	} else {
		g_debug("error in board_utility(), unknown board turn.");
	}

	if (b->turn != player)
		utility = -utility;

	return utility;
}

int board_update(const Board *b, PIECE player)
{
	/* scans the entire board and returns its utility */
	BCOORD x, y;
	int i;

	clear_all();

	for (y = 0; y < board_size; y++) {
		for (x = 0; x < board_size; x++) {
			for (i = 0; i < 4; i++) {
				window_sequence(b, x, y, i, PIECE_WHITE);
				window_sequence(b, x, y, i, PIECE_BLACK);
			}
		}
	}

	return board_utility(b, player);
}

int incremental_update(const Board *b, BCOORD x, BCOORD y, PIECE player)
/* only scans the windows that have been impacted by a new piece and returns the board's utility */
{
	int dx, dy, ddx, ddy, i, counter;
	int ddxs[] = {1, 0, 1,  1};
	int ddys[] = {0, 1, 1, -1};

	max_black_sequence = 0;
	max_white_sequence = 0;

	for (i = 0; i < 4; i++) {

		ddx = ddxs[i];
		ddy = ddys[i];

		for (counter = 0, dx = ddx * -connect_k, dy = ddy * -connect_k;
		     counter < connect_k + 2;
		     counter ++, dx += ddx, dy += ddy) {
			if (x + dx < 0 || y + dy < 0 || x + dx >= board_size || y + dy >= board_size) {
				continue;
			}

			window_sequence(b, x + dx, y + dy, i, PIECE_WHITE);
			window_sequence(b, x + dx, y + dy, i, PIECE_BLACK);
		}
	}

	return board_utility(b, player);
}

AIMoves *move_utilities(const Board *b)
{
	/* creates a list of possible moves based on the sequences utility function */
	AIMoves *moves = aimoves_new();
	AIMove move;

	moves->utility = board_update(b, b->turn);

	/* create a new board */
	Board *new_board;
	new_board = board_new();

	for (move.y = 0; move.y < board_size; move.y++) {

		/* bails out if ai_stop is true */
		if (ai_stop)
			return moves;

		for (move.x = 0; move.x < board_size; move.x++) {

			if (piece_at(b, move.x, move.y) != PIECE_NONE)
				continue;

			/* copy the board into the new board */
			board_copy(b, new_board);
			/* Add the piece to the board */
			place_piece(new_board, move.x, move.y);
			new_board->moves_left--;
			/* find the utility for this new board */
			move.weight = incremental_update(new_board, move.x, move.y, new_board->turn);

			aimoves_add(moves, &move);

			/* undo what we did, so things are correct next time around */
			place_piece_type(new_board, move.x, move.y, PIECE_NONE);
			new_board->moves_left++;
			incremental_update(new_board, move.x, move.y, new_board->turn);
		}
	}

	if ((b->turn == PIECE_WHITE && black_threat_count) || (b->turn == PIECE_BLACK && white_threat_count)) {
		aimoves_sort(moves);
		aimoves_crop(moves, 1);
	}

	board_free(new_board);

	return moves;
}

AIMoves *ai_sequences(const Board *b)
{
	AIMoves *moves = move_utilities(b);

	return moves;
}
