
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
#include <glib.h>
#include "../shared.h"
#include "../connectk.h"

/* FIXME: The AI thread function busy waits on Windows. For some reason, it fails to
   deadlock itself on mutex1! */

int ai_stop = 0;

static GMutex *ai_mutex1, *ai_mutex2;
static guint ai_done_source = 0;
static AIMove ai_move;
static GThread *ai_thread;
static int ai_halt = 0;

static gboolean ai_done(gpointer user_data)
{
        if (opt_debug_thread)
                g_debug("ai_done(): making AI move");
        make_move(ai_move.x, ai_move.y);
        return FALSE;
}

AIMoves *run_ai(Player *player)
{
        AIMoves *moves;
        AIFunc func;

        if (opt_debug_thread)
                g_debug("run_ai(): running AI function");
        ai_stop = FALSE;
        func = ai(player->ai)->func;
        if (!func)
                return NULL;
        moves = func(board);
        if (player->search)
                search(board, moves, player);

        ai_stop = FALSE;
        return moves;
}

static gpointer ai_thread_func(gpointer user_data)
{
        for (;;) {
                AIMoves *moves;

                if (opt_debug_thread)
                        g_debug("ai_thread_func(): locking mutex1");
                g_mutex_lock(ai_mutex1);
                if (opt_debug_thread)
                        g_debug("ai_thread_func(): mutex1 locked");
                if (ai_halt) {
                        ai_halt = FALSE;
                        g_mutex_unlock(ai_mutex1);
                        return NULL;
                }
                if (opt_debug_thread)
                        g_debug("ai_thread_func(): locking mutex2");
                g_mutex_lock(ai_mutex2);
                if (opt_debug_thread)
                        g_debug("ai_thread_func(): mutex2 locked");
                if (ai(players[board->turn].ai)->func && !opt_pause_ai &&
                    !board->won) {
                        ai_move.x = -1;
                        ai_move.y = -1;
                        moves = run_ai(players + board->turn);

                        /* Choose an adjacent move if the AI returns nothing */
                        if (!aimoves_choose(moves, &ai_move)) {
                                aimoves_free(moves);
                                moves = ai_adjacent(board);
                                aimoves_choose(moves, &ai_move);
                        }

                        /* Print the move list utility */
                        if (opt_print_u)
                                g_debug("AI %s utility %d (0x%x)",
                                        ai(players[board->turn].ai)->s_desc,
                                        moves->utility, moves->utility);

                        ai_done_source = g_timeout_add(0, ai_done, NULL);
                        aimoves_free(moves);
                }
                g_mutex_unlock(ai_mutex2);
                if (opt_debug_thread)
                        g_debug("ai_thread_func(): mutex2 unlocked");
                g_thread_yield();
        }
        return NULL;
}

void stop_ai(void)
{
        ai_stop = TRUE;
#ifndef NO_TRYLOCK
        if (opt_debug_thread)
                g_debug("stop_ai(): trylocking mutex1");
        g_mutex_trylock(ai_mutex1);
#endif
        if (opt_debug_thread)
                g_debug("stop_ai(): locking mutex2");
        g_mutex_lock(ai_mutex2);
        if (opt_debug_thread)
                g_debug("stop_ai(): mutex2 locked");
        if (ai_done_source) {
                g_source_remove(ai_done_source);
                ai_done_source = 0;
        }
        g_mutex_unlock(ai_mutex2);
        if (opt_debug_thread)
                g_debug("stop_ai(): mutex2 unlocked");
}

void start_ai(void)
{
        if (players[board->turn].ai == PLAYER_HUMAN)
                return;

#ifndef NO_TRYLOCK
        if (opt_debug_thread)
                g_debug("start_ai(): trylocking mutex1");
        g_mutex_trylock(ai_mutex1);
#endif
        g_mutex_unlock(ai_mutex1);
        if (opt_debug_thread)
                g_debug("stop_ai(): mutex1 unlocked");
}

void halt_ai_thread(void)
{
        if (opt_debug_thread)
                g_debug("halt_ai_thread(): unlocking mutex1, joining thread");
        ai_stop = TRUE;
        ai_halt = TRUE;
        g_mutex_unlock(ai_mutex1);
        g_thread_join(ai_thread);
        if (opt_debug_thread)
                g_debug("halt_ai_thread(): mutex1 unlocked");
}

void start_ai_thread(void)
{
        GError *error = NULL;

        g_thread_init(NULL);
        ai_mutex1 = g_mutex_new();
        ai_mutex2 = g_mutex_new();
        g_mutex_lock(ai_mutex1);
        if (opt_debug_thread)
                g_debug("start_ai_thread(): mutex1, mutex2 locked");

        ai_thread = g_thread_create_full(ai_thread_func, NULL, 0, TRUE, TRUE,
                                         G_THREAD_PRIORITY_NORMAL, &error);
        if (error)
                g_error("Failed to spawn AI thread");
}

