
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
#include "shared.h"
#include "connectk.h"

/*
 *      Tests
 */

void dfs_cache_dump(void);
void sum_of_marks(void);
void debug_counts(void);

static char *achain_stat_string(AllocChain *ac, gsize mem)
{
        int used = 0, total = 0;

        while (ac) {
                total++;
                if (!ac->free)
                        used++;
                ac = ac->next;
        }
        return va("%d of %d in use, %d bytes allocated",
                  used, total, total * mem);
}

static void dump_stats(void)
{
        g_debug("Boards: %s",
                achain_stat_string(board_root, board_mem));
        g_debug("AIMoves: %s",
                achain_stat_string(aimoves_root, aimoves_mem));
}

void dump_board(const Board *b)
/* Print out a board to the console */
{
        int x, y;

        for (y = 0; y < board_size; y++) {
                for (x = 0; x < board_size; x++)
                        g_printf("%c", piece_to_char(piece_at(b, x, y)));
                g_print("\n");
        }
}

static void board_id(void)
{
        g_debug("Board id %d", board->ac.id);
}

typedef struct {
	char *desc;
	void (*func)(void);
} Test;

/* This array contains no argument functions which will appear in the tests
   menu */
static Test tests[] = {
        { "Memory Statistics", dump_stats },
        { "Board ID", board_id },
        { "Dump DFS cache", dfs_cache_dump },
        { "Sum of marks", sum_of_marks },
        { "Threat counts", debug_counts },
};

#define TESTS (sizeof (tests) / sizeof (tests[0]))

/*
 *      Test Interface
 */

static void test_menu_item_activate(GtkMenuItem *item, gpointer user_data)
{
	Test *test = (Test*)user_data;

	test->func();
}

void add_tests_to_menu_shell(GtkWidget *menu)
{
	GtkWidget *item;
	int i;

	for(i = 0; i < TESTS; i++) {
		item = gtk_menu_item_new_with_mnemonic(tests[i].desc);
		g_signal_connect(item, "activate",
				 G_CALLBACK(test_menu_item_activate),
				 tests + i);
		gtk_menu_attach(GTK_MENU(menu), item, 0, 1, i, i + 1);
	}
}
