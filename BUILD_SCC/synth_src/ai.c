
/*

connectk -- a program to play the connect-k family of games
Copyright (C) 2007 Michael Levin

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
#include <string.h>
#include <math.h>
#include <glib.h>
#include "../shared.h"
#include "../connectk.h"

/*
 *      AIs
 */

static AI ais[] = {
        { "human", "Human", NULL },
        { "random", "Random", ai_random },
        { "adjacent", "Adjacent", ai_adjacent },
        { "threats", "Threats", ai_threats },
        /*{ "windows", "Windows", ai_windows },*/
        /*{ "priority", "Prioritized Threats", ai_priority },*/
        { "sequences", "Sequences", ai_sequences },
        { "mesh", "Mesh", ai_mesh },
        { "montecarlo", "Monte Carlo", ai_monte_carlo },
};

static gboolean is_adjacent(const Board *b, BCOORD x, BCOORD y, int dist)
{
        int dx, dy, count;
        PIECE p;

        if (!piece_empty(piece_at(b, x, y)))
                return FALSE;
        for (dy = -1; dy < 2; dy++)
                for (dx = -1; dx < 2; dx++) {
                        if (!dx && !dy)
                                continue;
                        count = count_pieces(b, x, y, PIECE_NONE, dx, dy, &p);
                        if (count - 1 < dist && p != PIECE_NONE)
                                return TRUE;
                }
        return FALSE;
}

AIMoves *enum_adjacent(const Board *b, int dist)
{
        AIMoves *moves;
        AIMove move;

        move.weight = AIW_NONE;
        moves = aimoves_new();
        for (move.y = 0; move.y < board_size; move.y++)
                for (move.x = 0; move.x < board_size; move.x++)
                        if (is_adjacent(b, move.x, move.y, dist))
                                aimoves_append(moves, &move);
        aimoves_shuffle(moves);
        return moves;
}

AIMoves *ai_marks(const Board *b, PIECE min)
{
        AIMoves *moves = aimoves_new();
        AIMove move;
        PIECE p;

        for (move.y = 0; move.y < board_size; move.y++)
                for (move.x = 0; move.x < board_size; move.x++)
                        if ((p = piece_at(b, move.x, move.y)) >= min) {
                                move.weight = p - PIECE_THREAT0;
                                aimoves_set(moves, &move);
                        }
        return moves;
}

AIMoves *ai_random(const Board *b)
/* Returns a list of all empty tiles */
{
        AIMove move;
        AIMoves *moves;

        moves = aimoves_new();
        for (move.y = 0; move.y < board_size; move.y++)
                for (move.x = 0; move.x < board_size; move.x++)
                        if (piece_empty(piece_at(b, move.x, move.y))) {
                                move.weight =
                                           g_random_int_range(AIW_MIN, AIW_MAX);
                                aimoves_append(moves, &move);
                        }
        return moves;
}

AIMoves *ai_adjacent(const Board *b)
{
        AIMove move;
        AIMoves *moves;

        /* Get all open tiles adjacent to any piece */
        moves = enum_adjacent(b, 1);
        if (moves->len)
                return moves;

        /* Play in the middle if there are no open adjacent tiles */
        move.x = board_size / 2;
        move.y = board_size / 2;
        move.weight = AIW_NONE;
        aimoves_append(moves, &move);
        return moves;
}

const char *player_to_string(PLAYER p)
{
        return ais[p].l_desc;
}

int number_of_ais(void)
{
        return sizeof (ais) / sizeof (*ais);
}

AI *ai(int n)
{
        if (n >= 0 && n < number_of_ais())
                return ais + n;
        return NULL;
}

