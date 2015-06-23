
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
#include <math.h>
#include <glib.h>
#include "../shared.h"

/* Bits per threat level */
#define BITS_PER_THREAT 6

/* All threat functions work on this board */
static Board *b = NULL;

/* This is the line of threats currently being processed */
static struct {
        int threat[2];
        PIECE turn[2];
} line[MAX_BOARD_SIZE];

/* Running tally of threats for both players */
static int threat_counts[MAX_CONNECT_K + 1][2];

static AIWEIGHT threat_bits(int threat, PIECE type)
/* Bit pack the threat value */
{
        if (threat < 1)
                return 0;

        /* No extra value for building sequences over k - p unless it is
           enough to win */
        if (b->turn == type && connect_k - threat <= b->moves_left)
                threat = connect_k - place_p + 1;
        else if (threat >= connect_k - place_p)
                threat = connect_k - place_p - (type == b->turn);

        return 1 << ((threat - 1) * BITS_PER_THREAT);
}

static void threat_mark(int i, int threat, PIECE type)
{
        int j, index = 0;

        if (threat <= 0)
                return;

        /* No extra value for building sequences over k - p unless it is
           enough to win */
        if (b->turn == type && connect_k - threat <= b->moves_left)
                threat = connect_k - place_p + 1;
        else if (threat >= connect_k - place_p)
                threat = connect_k - place_p - (type == b->turn);

        /* Do not mark if this threat is dominated by a preceeding threat;
           Likewise supress any smaller threats */
        for (j = i; j >= 0 && j > i - connect_k; j--)
                if (line[j].threat[0] > threat)
                        return;
                else if (line[j].threat[0] < threat) {
                        line[j].threat[0] = 0;
                        line[j].threat[1] = 0;
                }

        /* Store up to two threats per tile in the line */
        if (line[i].threat[index])
                index++;
        line[i].threat[index] = threat;
        line[i].turn[index] = type;
}

static int threat_window(int x, int y, int dx, int dy,
                         PIECE *ptype, int *pdouble)
{
        int min, max, count = 0;
        PIECE p, type = PIECE_NONE;

        /* Check if this tile is empty */
        p = piece_at(b, x, y);
        if (!piece_empty(p))
                return 0;

        /* Push forward the max and find the window type */
        for (max = 1; max < connect_k; max++) {
                p = piece_at(b, x + dx * max, y + dy * max);
                if (p == PIECE_ERROR)
                        break;
                if (!piece_empty(p)) {
                        if (type == PIECE_NONE)
                                type = p;
                        else if (type != p)
                                break;
                        count++;
                }
        }
        max--;

        /* Try to push the entire window back */
        for (min = -1; min > -connect_k; min--) {
                p = piece_at(b, x + dx * min, y + dy * min);
                if (p == PIECE_ERROR || piece_empty(p))
                        break;
                if (type == PIECE_NONE)
                        type = p;
                else if (type != p)
                        break;
                if (max - min > connect_k - 1) {
                        p = piece_at(b, x + dx * max, y + dy * max);
                        if (p == type)
                                count--;
                        max--;
                }
                count++;
        }
        min++;

        /* Push back min if we haven't formed a complete window, this window
           can't be a double */
        if (max - min < connect_k - 1) {
                for (min--; min > max - connect_k; min--) {
                        p = piece_at(b, x + dx * min, y + dy * min);
                        if (p == PIECE_ERROR)
                                break;
                        if (!piece_empty(p)) {
                                if (type != p)
                                        break;
                                if (type == PIECE_NONE)
                                        type = p;
                                count++;
                        }
                }
                *pdouble = 0;
                min++;
        }

        *ptype = type;
        if (max - min >= connect_k - 1)
                return count;
        return 0;
}

static AIWEIGHT threat_line(int x, int y, int dx, int dy)
{
        int i;
        AIWEIGHT weight = 0;

        /* Mark the maximum threat for each */
        for (i = 0; x >= 0 && x < board_size && y >= 0 && y < board_size; i++) {
                int count[2], tmp, double_threat = 1;
                PIECE type[2];

                count[0] = threat_window(x, y, dx, dy, type, &double_threat);
                count[1] = threat_window(x, y, -dx, -dy, type + 1,
                                         &double_threat);
                if (count[1] > count[0]) {
                        tmp = count[1];
                        count[1] = count[0];
                        count[0] = tmp;
                        tmp = type[1];
                        type[1] = type[0];
                        type[0] = tmp;
                }
                line[i].threat[0] = 0;
                line[i].threat[1] = 0;
                threat_mark(i, count[0], type[0]);
                if (double_threat)
                        threat_mark(i, count[1], type[1]);
                x += dx;
                y += dy;
        }

        /* Commit stored line values to the board */
        x -= dx;
        y -= dy;
        for (i--; x >= 0 && x < board_size && y >= 0 && y < board_size; i--) {
                AIWEIGHT bits[2];
                PIECE p;

                bits[0] = threat_bits(line[i].threat[0], line[i].turn[0]);
                bits[1] = threat_bits(line[i].threat[1], line[i].turn[1]);
                p = piece_at(b, x, y);
                if (piece_empty(p) && line[i].threat[0]) {
                        threat_counts[line[i].threat[0]][line[i].turn[0] - 1]++;
                        if (line[i].threat[1])
                                threat_counts[line[i].threat[1]]
                                             [line[i].turn[1] - 1]++;
                        if (p >= PIECE_THREAT0)
                                place_threat(b, x, y, p - PIECE_THREAT0 +
                                             bits[0] + bits[1]);
                        else
                                place_threat(b, x, y, bits[0] + bits[1]);
                }
                if (b->turn != line[i].turn[0])
                        bits[0] = -bits[0];
                if (b->turn != line[i].turn[1])
                        bits[1] = -bits[1];
                weight += bits[0] + bits[1];
                x -= dx;
                y -= dy;
        }

        return weight;
}

AIMoves *ai_threats(const Board *original)
{
        AIMoves *moves;
        AIWEIGHT u_sum = 0;
        int i;

        b = board_new();
        board_copy(original, b);

        /* Clear threat tallys */
        for (i = 0; i < connect_k; i++) {
                threat_counts[i][0] = 0;
                threat_counts[i][1] = 0;
        }

        /* Horizontal lines */
        for (i = 0; i < board_size; i++)
                u_sum += threat_line(0, i, 1, 0);

        /* Vertical lines */
        for (i = 0; i < board_size; i++)
                u_sum += threat_line(i, 0, 0, 1);

        /* SE diagonals */
        for (i = 0; i < board_size - connect_k + 1; i++)
                u_sum += threat_line(i, 0, 1, 1);
        for (i = 1; i < board_size - connect_k + 1; i++)
                u_sum += threat_line(0, i, 1, 1);

        /* SW diagonals */
        for (i = connect_k - 1; i < board_size; i++)
                u_sum += threat_line(i, 0, -1, 1);
        for (i = 1; i < board_size - connect_k + 1; i++)
                u_sum += threat_line(board_size - 1, i, -1, 1);

        moves = ai_marks(b, PIECE_THREAT(1));
        moves->utility = u_sum;
        board_free(b);
        return moves;
}

void debug_counts(void)
{
        int i, sum = 0;

        if (!b)
                return;

        g_debug("Threat counts (black, white):");
        for (i = 1; i < connect_k; i++) {
                g_debug("%d: %3d %3d", i, threat_counts[i][0],
                        threat_counts[i][1]);
                sum += threat_counts[i][0] * threat_bits(i, b->turn) -
                       threat_counts[i][1] *
                       threat_bits(i, other_player(b->turn));
        }
        if (sum > 0)
                g_debug("Threat sum: %d (10^%.2f)", sum, log10((double)sum));
        else if (sum < 0)
                g_debug("Threat sum: %d (-10^%.2f)", sum, log10((double)-sum));
        else
                g_debug("Threat sum: 0");
}

static int threat_number(int player, int threat)
{
        return threat_counts[threat][player] / (connect_k - threat);
}

AIMoves *ai_priority(const Board *b)
{
        AIMoves *moves;
        int i, j, stage[2] = {1, 1}, mask, bits;

        moves = ai_threats(b);

        /* Do not prioritize if we've won */
        if (threat_counts[connect_k - place_p + 1][b->turn - 1]) {
                moves->utility = AIW_WIN;
                return moves;
        }

        /* Find the largest supported threat for each player */
        for (i = 2; i < connect_k; i++) {
                if (threat_number(0, i - 1) >= place_p &&
                    threat_number(0, i) > place_p)
                        stage[0] = i;
                if (threat_number(1, i - 1) >= place_p &&
                    threat_number(1, i) > place_p)
                        stage[1] = i;
        }

        if (opt_debug_stage)
                g_debug("Stages %d/%d", stage[0], stage[1]);

        /* Do not prioritize if we're losing */
        if (stage[b->turn - 1] <= stage[other_player(b->turn) - 1]) {
                moves->utility = -stage[other_player(b->turn) - 1];
                return moves;
        }

        /* Threats above the player's stage are no more valuable than the
           stage */
        bits = 1 << (stage[b->turn - 1] * BITS_PER_THREAT);
        mask = bits - 1;
        for (i = 0; i < moves->len; i++) {
                AIWEIGHT w = moves->data[i].weight, w2;

                if (w < AIW_THREAT_MAX && w >= bits) {
                        w2 = w & mask;
                        w = w & ~mask;
                        for (j = stage[b->turn - 1];
                             w && j < connect_k - place_p + 1; j++) {
                                w = w >> BITS_PER_THREAT;
                                w2 += w & mask;
                        }
                        moves->data[i].weight = w2;
                }
        }

        /* Stage determines weight */
        moves->utility = stage[b->turn - 1];
        return moves;
}
