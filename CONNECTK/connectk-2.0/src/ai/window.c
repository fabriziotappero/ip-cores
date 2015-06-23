
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
#include <glib.h>
#include "../shared.h"

static int window_dir(const Board *b, BCOORD x, BCOORD y, PIECE type,
                      int dx, int dy, int *length, int *count)
{
        int i, j, min_i, max_i, min_block = 0, max_block = 0, max = 0;
        PIECE p;

        if (!dx && !dy)
                return 0;

        /* Find the lowest index i along our diagonal that is valid and is
           still a window containing (x, y) and count the number of pieces
           inside */
        for (i = 0; i > -connect_k; i--) {
                p = piece_at(b, x + dx * i, y + dy * i);
                if (p != type && p != PIECE_NONE) {
                        min_block = 1;
                        break;
                }
        }
        min_i = max_i = ++i;
        for (j = i; j < i + connect_k; j++) {
                p = piece_at(b, x + dx * j, y + dy *j);
                if (p == type)
                        max++;
                else if (p != PIECE_NONE)
                        return 0;
        }

        /* Slide out window along and find the smallest and largest maximum
           count positions */
        j = max;
        for (; i < 0; i++) {
                p = piece_at(b, x + dx * i, y + dy * i);
                if (p == type)
                        j--;
                p = piece_at(b, x + dx * (i + connect_k),
                             y + dy * (i + connect_k));
                if (p == type)
                        j++;
                else if (p != PIECE_NONE) {
                        max_block = 1;
                        break;
                }
                if (j == max)
                        max_i = i + 1;
                else if (j > max) {
                        max = j;
                        min_i = max_i = i + 1;
                }
        }

        /* Check if we have blocked multiple threats with this move */
        *count = 1;
        if (min_block || min_i > -connect_k + 1 ||
            ((p = piece_at(b, x - dx * connect_k, y - dy * connect_k)) !=
              type && p != PIECE_NONE))
                for (i = min_i; i < max_i; i++) {
                        p = piece_at(b, x + dx * i, y + dy * i);
                        if (p == PIECE_NONE)
                                (*count)++;
                        else if (p == PIECE_ERROR)
                                break;
                }
        if (max_block || max_i < 0 ||
            ((p = piece_at(b, x + dx * connect_k, y + dy * connect_k)) !=
             type && p != PIECE_NONE))
                for (i = min_i + connect_k; i < max_i + connect_k; i++) {
                        p = piece_at(b, x + dx * i, y + dy * i);
                        if (p == PIECE_NONE)
                                (*count)++;
                        else if (p == PIECE_ERROR)
                                break;
                }

        *length = max;
        return 1;
}

static AIWEIGHT window(const Board *b, BCOORD x, BCOORD y, PIECE turn)
{
        int lines[MAX_CONNECT_K], xs[] = {1, 1, 0, -1}, ys[] = {0, 1, 1, 1}, i;
        AIWEIGHT weight;
        PIECE type;

        memset(lines, 0, sizeof (lines));
        type = piece_at(b, x, y);
        if (type != PIECE_NONE)
                return AIW_NONE;
        for (i = 0; i < 4; i++) {
                int length, count;

                if (!window_dir(b, x, y, turn, xs[i], ys[i], &length, &count))
                        continue;
                lines[length] += count;
        }

        /* Bit pack the weight */
        weight = AIW_NONE;
        for (i = 1; i < connect_k; i++)
                weight += lines[i] << ((i - 1) * 6);
        return weight;
}

AIMoves *ai_windows(const Board *b)
{
        AIMoves *moves;
        AIMove move;
        PIECE opp = other_player(b->turn);

        moves = aimoves_new();
        moves->utility = AIW_NONE;
        for (move.y = 0; move.y < board_size; move.y++)
                for (move.x = 0; move.x < board_size; move.x++) {
                        move.weight = window(b, move.x, move.y, opp);
                        if (move.weight > AIW_NONE)
                                aimoves_append(moves, &move);
                }
        return moves;
}
