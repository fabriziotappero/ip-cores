
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

#define MONTE_N 10
#define MONTE_NUM_RUNS 1000

// sequences.c
AIMoves *move_utilities(const Board *b);

AIMoves *empty_cells(Board *b)
/* returns an array of the empty locations on board b */
{
        int i, j;
        AIMoves *empties = aimoves_new();
        AIMove move;

        for (i = 0; i < board_size; i++) {
                for (j = 0; j < board_size; j++) {
                        if (piece_at(b, i, j) == PIECE_NONE) {
                                move.x = i;
                                move.y = j;
                                move.weight = 0.f;
                                aimoves_add(empties, &move);
                        }
                }
        }
        return empties;
}

int mc_run(Board *b)
/* plays a random game on board b, returns 1 if the current player wins
and 0 otherwise */
{
        Board *new_board = board_new();
        board_copy(b, new_board);

        AIMove move;
        AIMoves *empties;
        empties = empty_cells(new_board);
        int tries = 0;
        int i;

        while ( TRUE ) {

                /* if the board filled up, start over */
                if (empties->len == 0) {
                        board_copy(b, new_board);
                        empties = empty_cells(new_board);
                        tries++;
                        if (tries == 10) {
                                g_debug("bailing");
                                board_free(new_board);
                                aimoves_free(empties);
                                return 0;
                        }
                }

                i = g_random_int_range(0, empties->len);
                move = empties->data[i];
                aimoves_remove_index_fast(empties, i);

                place_piece(new_board, move.x, move.y);

                if (check_win(new_board, move.x, move.y)) {
                        if (new_board->turn == board->turn) {
                                board_free(new_board);
                                aimoves_free(empties);
                                return 1;
                        }
                        else {
                                board_free(new_board);
                                aimoves_free(empties);
                                return 0;
                        }
                }

                new_board->moves_left--;
                if (new_board->moves_left == 0) {
                        new_board->turn = other_player(new_board->turn);
                        new_board->moves_left = place_p;
                }
        }
}

AIMoves *ai_monte_carlo(const Board *b)
/* chooses the best move based on which one wins the most random games */
{
        int i, k, wins, len;

        Board *new_board = board_new();

        AIMove move;
        AIMoves *moves = move_utilities(b);
        moves->utility = 0;
        aimoves_crop(moves, MONTE_N);

        len = moves->len;

        for (i = 0; i < len; i++) {

                move = moves->data[i];

                board_copy(b, new_board);
                place_piece(new_board, move.x, move.y);

                if (check_win(new_board, move.x, move.y)) {
                        move.weight = MONTE_NUM_RUNS;
                        moves->data[i] = move;
                        moves->utility += MONTE_NUM_RUNS;
                } else {
                        /* run the monte carlo trials */
                        wins = 0;
                        for (k = 0; k < MONTE_NUM_RUNS; k++) {
                                wins += mc_run(new_board);
                        }
                        move.weight = wins;
                        moves->data[i] = move;
                        moves->utility += wins;
                }
        }

        board_free(new_board);
        return moves;
}
