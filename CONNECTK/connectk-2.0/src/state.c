
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
#include <gtk/gtk.h>
#include <glib/gprintf.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "shared.h"
#include "connectk.h"

/*
 *      Allocation chain
 */

static void achain_init(AllocChain *ac)
{
        static unsigned int ids;

        ac->free = FALSE;
        ac->id = ids++;
}

AllocChain *achain_new(AllocChain **root, AllocFunc afunc)
{
        AllocChain *ac;

        if (!*root) {
                *root = afunc(NULL);
                achain_init(*root);
                (*root)->next = NULL;
                return *root;
        }
        ac = *root;
        for (;;) {
                if (ac->free) {
                        afunc(ac);
                        achain_init(ac);
                        return ac;
                }
                if (!ac->next)
                        break;
                ac = ac->next;
        }
        ac->next = afunc(NULL);
        achain_init(ac->next);
        ac->next->next = NULL;
        return ac->next;
}

void achain_free(AllocChain *ac)
{
        if (!ac)
                return;
        ac->free = TRUE;
}

void achain_copy(const AllocChain *src, AllocChain *dest, gsize mem)
{
        if (!src || !dest || !mem) {
                g_warning("NULL argument(s) to achain_copy");
                return;
        }
        memcpy((char*)dest + sizeof (AllocChain),
               (char*)src + sizeof (AllocChain), mem - sizeof (AllocChain));
}

static void achain_dealloc(AllocChain **root, gsize mem)
{
        AllocChain *ac = *root, *ac_next;

        while (ac) {
                ac_next = ac->next;
                g_slice_free1(mem, ac);
                ac = ac_next;
        }
        *root = NULL;
}

/*
 *      Move Arrays
 */

AllocChain *aimoves_root = NULL;
gsize aimoves_mem = 0;

AllocChain *aimoves_alloc(AllocChain *ac)
{
        if (!ac)
                ac = (AllocChain*)g_slice_alloc(aimoves_mem);
        memset((char*)ac + sizeof (AllocChain), 0, sizeof (AIMoves) -
               sizeof (AllocChain));
        return ac;
}

void aimoves_add(AIMoves *moves, const AIMove *move)
{
        int i;

        i = aimoves_find(moves, move->x, move->y);
        if (i < 0) {
                if (moves->len >= board_size * board_size)
                        g_warning("Attempted to add a move to a full AIMoves");
                else
                        moves->data[moves->len++] = *move;
        } else
                moves->data[i].weight += move->weight;
}

void aimoves_append(AIMoves *moves, const AIMove *move)
{
        int i;

        if (move->x >= board_size || move->y >= board_size)
                return;
        for (i = 0; i < moves->len; i++) {
                AIMove *aim = moves->data + i;

                if (aim->x == move->x && aim->y == move->y) {
                        aim->weight = move->weight;
                        return;
                }
        }
        if (moves->len >= board_size * board_size) {
                g_warning("Attempted to append a move to a full AIMoves");
                return;
        }
        moves->data[moves->len++] = *move;
}

int aimoves_compare(const void *a, const void *b)
{
        return ((AIMove*)b)->weight - ((AIMove*)a)->weight;
}

int aimoves_choose(AIMoves *moves, AIMove *move)
{
        int i = 0, top = 0;

        if (!moves || !moves->len)
                return 0;
        aimoves_sort(moves);
        for (top = 0; top < moves->len &&
             moves->data[top].weight == moves->data[0].weight; top++);
        if (top)
                i = g_random_int_range(0, top);
        *move = moves->data[i];
        return 1;
}

void aimoves_crop(AIMoves *moves, unsigned int n)
{
        if (moves->len < n)
                return;
        aimoves_shuffle(moves);
        aimoves_sort(moves);
        moves->len = n;
}

void aimoves_concat(AIMoves *m1, const AIMoves *m2)
{
        gsize max_len = board_size * board_size, len;

        len = m2->len;
        if (m1->len + len > max_len)
                len = max_len - m1->len;
        memcpy(m1->data + len, m2->data, len * sizeof (AIMove));
        m1->len += len;
}

AIMoves *aimoves_dup(const AIMoves *moves)
{
        AIMoves *dup;

        if (!moves)
                return NULL;
        dup = aimoves_new();
        dup->len = moves->len;
        memcpy(dup->data, moves->data, moves->len * sizeof (AIMove));
        return dup;
}

int aimoves_find(const AIMoves *moves, BCOORD x, BCOORD y)
{
        int i;

        if (moves)
                for (i = 0; i < moves->len; i++) {
                        const AIMove *aim = moves->data + i;

                        if (aim->x == x && aim->y == y)
                                return i;
                }
        return -1;
}

void aimoves_range(AIMoves *moves, AIWEIGHT *min, AIWEIGHT *max)
{
        int i;

        *min = AIW_MAX;
        *max = AIW_MIN;
        for (i = 0; i < moves->len; i++) {
                if (moves->data[i].weight > *max)
                        *max = moves->data[i].weight;
                if (moves->data[i].weight < *min)
                        *min = moves->data[i].weight;
        }
}

void aimoves_merge(AIMoves *m1, const AIMoves *m2)
{
        int len = m1->len, i, j;

        for (i = 0; i < m2->len; i++)
                for (j = 0;; j++) {
                        if (j >= len) {
                                aimoves_append(m1, m2->data + i);
                                break;
                        }
                        if (m1->data[j].x == m2->data[i].x &&
                            m1->data[j].y == m2->data[i].y) {
                                if (m2->data[i].weight > m1->data[j].weight)
                                        m1->data[j].weight = m2->data[i].weight;
                                break;
                        }
                }
}

char *aimove_to_string(const AIMove *aim)
{
        static char buffer[32];

        g_snprintf(buffer, sizeof (buffer), "%s (%s)",
                   bcoords_to_string(aim->x, aim->y),
                   aiw_to_string(aim->weight));
        return buffer;
}

void aimoves_print(const AIMoves *moves)
{
        int i;

        if (!moves || !moves->len) {
                g_print("(empty)");
                return;
        }
        for (i = 0; i < moves->len; i++) {
                const AIMove *aim = moves->data + i;

                if (i)
                        g_print(", ");
                g_print("%s", aimove_to_string(aim));
        }
}

void aimoves_remove_index_fast(AIMoves *moves, int i)
{
        if (moves->len > i)
                moves->data[i] = moves->data[moves->len - 1];
        moves->len--;
}

void aimoves_remove(AIMoves *moves, BCOORD x, BCOORD y)
{
        int i;

        for (i = 0; i < moves->len; i++) {
                AIMove *aim = moves->data + i;

                if (aim->x == x && aim->y == y) {
                        aimoves_remove_index_fast(moves, i);
                        return;
                }
        }
}

void aimoves_shuffle(AIMoves *moves)
{
        int i;

        if (opt_det_ai)
                return;

        /* Fisher-Yates shuffle */
        for (i = 0; i < moves->len; i++) {
                int j;

                j = g_random_int_range(i, moves->len);
                if (i != j) {
                        AIMove tmp;

                        tmp = moves->data[i];
                        moves->data[i] = moves->data[j];
                        moves->data[j] = tmp;
                }
        }
}

void aimoves_sort(AIMoves *moves)
{
        qsort(moves->data, moves->len, sizeof (AIMove), aimoves_compare);
}

void aimoves_subtract(AIMoves *m1, const AIMoves *m2)
{
        int i, j;

        for (i = 0; i < m1->len; i++)
                for (j = 0; j < m2->len; j++)
                        if (m1->data[i].x == m2->data[j].x &&
                            m1->data[i].y == m2->data[j].y) {
                                aimoves_remove_index_fast(m1, i--);
                                break;
                        }
}

const char *aiw_to_string(AIWEIGHT w)
{
        static char buffer[32];

        switch (w) {
        case AIW_WIN:
                return "WIN";
        case AIW_LOSE:
                return "LOSS";
        case AIW_NONE:
                return "NONE";
        default:
                break;
        }
        if (w > 0)
                g_snprintf(buffer, sizeof (buffer), "%010d (10^%.2f)", w,
                           log10((double)w));
        else if (w < 0)
                g_snprintf(buffer, sizeof (buffer), "%010d (-10^%.2f)", w,
                           log10((double)-w));
        return buffer;
}

/*
 *      Boards
 */

Board *board;
AllocChain *board_root = NULL;
int board_size, board_stride, move_no, move_last,
    connect_k = 6, place_p = 2, start_q = 1;
gsize board_mem = 0;

Player players[PIECES] = {
        { PLAYER_HUMAN, SEARCH_NONE, 0 },
        { PLAYER_HUMAN, SEARCH_NONE, 0 },
        { PLAYER_HUMAN, SEARCH_NONE, 0 },
};

static GPtrArray *history = NULL;

static void board_init(Board *b)
{
        memset((char*)b + sizeof (AllocChain), 0, sizeof (Board) -
               sizeof (AllocChain));
}

AllocChain *board_alloc(AllocChain *ac)
{
        Board *b = (Board*)ac;
        int i;

        /* Clear the old board */
        if (b) {
                for (i = 1; i <= board_size; i++)
                        memset(b->data + board_stride * i + 1, 0,
                               board_size * sizeof (PIECE));
                board_init(b);
                return (AllocChain*)b;
        }

        /* New boards are allocated with a 1-tile wide boundary of PIECE_ERROR
           around the edges */
        b = (Board*)g_slice_alloc0(board_mem);
        memset(b->data, PIECE_ERROR, sizeof (PIECE) * board_stride);
        for (i = 1; i <= board_size; i++) {
                b->data[i * board_stride] = PIECE_ERROR;
                memset(b->data + board_stride * i + 1, 0,
                       board_size * sizeof (PIECE));
                b->data[(i + 1) * board_stride - 1] = PIECE_ERROR;
        }
        memset(b->data + board_stride * (board_stride - 1), PIECE_ERROR,
               sizeof (PIECE) * board_stride);
        board_init(b);
        return (AllocChain*)b;
}

void board_clean(Board *b)
{
        int y, x;

        for (y = 0; y < board_size; y++)
                for (x = 0; x < board_size; x++)
                        if (piece_at(b, x, y) >= PIECES)
                                place_piece_type(b, x, y, PIECE_NONE);
}

void set_board_size(unsigned int size)
{
        if (board_size == size)
                return;
        draw_marks(NULL, FALSE);
        achain_dealloc(&board_root, board_mem);
        achain_dealloc(&aimoves_root, aimoves_mem);
        board_size = size;
        board_stride = size + 2;
        board_mem = sizeof (Board) + board_stride * board_stride *
                    sizeof (PIECE);
        aimoves_mem = sizeof (AIMoves) + size * size * sizeof (AIMove);
}

Board *board_at(unsigned int move)
{
        if (move >= history->len)
                return NULL;
        return (Board*)g_ptr_array_index(history, move);
}

int count_pieces(const Board *b, BCOORD x, BCOORD y, PIECE type, int dx, int dy,
                 PIECE *out)
{
        int i;
        PIECE p = PIECE_NONE;

        if (!dx && !dy)
                return piece_at(b, x, y) == type ? 1 : 0;
        for (i = 0; x >= 0 && x < board_size && y >= 0 && y < board_size; i++) {
                p = piece_at(b, x, y);
                if (p != type)
                        break;
                x += dx;
                y += dy;
        }
        if (out)
                *out = p;
        return i;
}

gboolean check_win_full(const Board *b, BCOORD x, BCOORD y,
                        BCOORD *x1, BCOORD *y1, BCOORD *x2, BCOORD *y2)
{
        int i, c1, c2, xs[] = {1, 1, 0, -1}, ys[] = {0, 1, 1, 1};
        PIECE type;

        type = piece_at(b, x, y);
        if (type != PIECE_BLACK && type != PIECE_WHITE)
                return FALSE;
        for (i = 0; i < 4; i++) {
                c1 = count_pieces(b, x, y, type, xs[i], ys[i], NULL);
                c2 = count_pieces(b, x, y, type, -xs[i], -ys[i], NULL);
                if (c1 + c2 > connect_k) {
                        if (x1)
                                *x1 = x + xs[i] * (c1 - 1);
                        if (y1)
                                *y1 = y + ys[i] * (c1 - 1);
                        if (x2)
                                *x2 = x - xs[i] * (c2 - 1);
                        if (y2)
                                *y2 = y - ys[i] * (c2 - 1);
                        return TRUE;
                }
        }
        return FALSE;
}

/* Convert a boord coordinate to alpha representation */
const char *bcoord_to_alpha(BCOORD x)
{
        static char buf[2][32];
        static int which;
        int i, divisor = 26;

        which = !which;
        for (i = 0; i < sizeof (buf[which]) - 1; i++) {
                div_t result;

                result = div(x, divisor);
                buf[which][i] = 'a' + result.rem * 26 / divisor;
                if (i)
                        buf[which][i]--;
                x -= result.rem;
                if (!x)
                        break;
                divisor *= 26;
        }
        buf[which][i + 1] = 0;
        return g_strreverse(buf[which]);
}

// Get a string representation of board x/y coordinates (d7, h16, etc)
const char *bcoords_to_string(BCOORD x, BCOORD y)
{
        static char buf[2][32];
        static int which;

        which = !which;
        g_snprintf(buf[which], sizeof (buf[which]), "%s%d",
                   bcoord_to_alpha(x), board_size - y);
        return buf[which];
}

/* Convert a string representation to coordinates */
void string_to_bcoords(const char *str, BCOORD *x, BCOORD *y)
{
        *x = 0;
        *y = 0;
        while (*str && *str >= 'a' && *str <= 'z') {
                *x *= 26;
                *x += *str - 'a';
                str++;
        }
        while (*str && *str >= '0' && *str <= '9') {
                *y *= 10;
                *y += *str - '0';
                str++;
        }
        if (*y)
                *y = board_size - *y;
}

const char *piece_to_string(PIECE piece)
{
        switch (piece) {
        case PIECE_WHITE:
                return "White";
        case PIECE_BLACK:
                return "Black";
        case PIECE_NONE:
                return "None";
        case PIECE_ERROR:
                return "Error";
        default:
                return "Mark";
        }
}

char piece_to_char(PIECE piece)
{
        switch (piece) {
        case PIECE_WHITE:
                return 'W';
        case PIECE_BLACK:
                return 'B';
        case PIECE_NONE:
                return '_';
        case PIECE_ERROR:
                return 'E';
        default:
                return 'M';
        }
}

char *search_to_string(SEARCH s)
{
        switch (s) {
        case SEARCH_NONE:
                return "No search";
        case SEARCH_DFS:
                return "Depth first search";
        case SEARCHES:
                break;
        }
        return "Unknown";
}

void go_to_move(unsigned int move)
{
        Board *board2;

        if (!history)
                history = g_ptr_array_sized_new(32);
        if (move > history->len)
                move = history->len;
        if (move == history->len) {
                board2 = board_new();
                if (board)
                        board_copy(board, board2);
                g_ptr_array_add(history, board2);
                board2->parent = board;
        } else
                board2 = (Board*)g_ptr_array_index(history, move);
        board = board2;
        move_no = move;
        if (move_no > move_last)
                move_last = move_no;
}

void clear_history(unsigned int from)
{
        int i;

        if (!history)
                return;
        if (from >= history->len) {
                g_warning("Attempted to clear future history");
                return;
        }
        for (i = from; i < history->len; i++)
                board_free(g_ptr_array_index(history, i));
        g_ptr_array_remove_range(history, from, history->len - from);
        move_last = from;
}
