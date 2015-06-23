
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
#include <time.h>
#include <gtk/gtk.h>
#include <glib/gprintf.h>
#include "shared.h"
#include "connectk.h"

/*
 *      Options menu
 */

int opt_det_ai = 0,
    opt_print_u = 0,
    opt_debug_dfsc = 0,
    opt_debug_thread = 0,
    opt_debug_stage = 0,
    opt_pause_ai = 0,
    opt_mark_log = 1,
    opt_mark_norm = 1,
    opt_grayscale = 0;

typedef struct {
	char *desc;
	int *pint;
	int redraw;
} Option;

/* This array contains boolean integer options which will appear as check
   menu items in the Options menu, the format is:
        { "Option name", &integer, redraw_on_toggle }, */
static Option options[] = {
        { "Pause AI",                   &opt_pause_ai,          FALSE },
        { "Deterministic AI",           &opt_det_ai,            FALSE },
        { "Print board utility",        &opt_print_u,           FALSE },
        { "Debug search path",          &opt_debug_dfsc,        FALSE },
        { "Debug threat stage",         &opt_debug_stage,       FALSE },
        { "Debug threads",              &opt_debug_thread,      FALSE },
        { "Logarithmic marking",        &opt_mark_log,          TRUE  },
        { "Normalized marking",         &opt_mark_norm,         TRUE  },
        { "Grayscale rendering",        &opt_grayscale,         TRUE  },
};

#define OPTIONS (sizeof (options) / sizeof (options[0]))

static void option_menu_item_toggled(GtkCheckMenuItem *item,
                                     gpointer user_data)
{
	Option *option = (Option*)user_data;

	*option->pint = !(*option->pint);
	gtk_check_menu_item_set_active(item, *option->pint);
	if (option->redraw)
	        draw_board();
}

static void add_options_to_menu_shell(GtkWidget *menu)
{
	GtkWidget *item;
	int i;

	for(i = 0; i < OPTIONS; i++) {
		item = gtk_check_menu_item_new_with_mnemonic(options[i].desc);
		gtk_check_menu_item_set_active(GTK_CHECK_MENU_ITEM(item),
		                               *(options[i].pint));
		g_signal_connect(item, "toggled",
				 G_CALLBACK(option_menu_item_toggled),
				 options + i);
		gtk_menu_shell_append(GTK_MENU_SHELL(menu), item);
	}
}

/*
 *      Window widgets
 */

typedef struct {
        PIECE type;
        PLAYER player;
} PlayerMenuItem;

static GtkWidget *statusbar = NULL, *tree_view = NULL, *window = NULL;
static GtkListStore *list_store;

// Change window statusbar text
void window_status(const char *msg)
{
        static int context;

        if (!statusbar)
                return;
        if (context)
                gtk_statusbar_pop(GTK_STATUSBAR(statusbar), context);
        context = gtk_statusbar_get_context_id(GTK_STATUSBAR(statusbar),
                                               "default");
        gtk_statusbar_push(GTK_STATUSBAR(statusbar), context, msg);
}

// Set the correct settings for a move state
void setup_move(void)
{
        if (!tournament) {
                draw_marks(NULL, TRUE);

                /* Stop a draw game */
                if (move_no >= board_size * board_size) {
                        window_status(va("Draw in %d moves", move_no));
                        draw_playable(FALSE);
                        return;
                }

                /* Stop a won game */
                if (board->won) {
                        draw_playable(FALSE);
                        draw_win();
                        window_status(va("%s wins in %d moves (%s -> %s)",
                                         piece_to_string(board->turn), move_no,
                                         bcoords_to_string(board->win_x1,
                                                           board->win_y1),
                                         bcoords_to_string(board->win_x2,
                                                           board->win_y2)));
                        return;
                }

                /* Status bar message */
                if (!move_no)
                        window_status(va("Game start: %s to play "
                                         "(%d move%s left)",
                                         piece_to_string(board->turn),
                                         board->moves_left,
                                         board->moves_left == 1 ? "" : "s"));
                else
                        window_status(va("Move %d: %s to play (%d move%s left)",
                                         move_no, piece_to_string(board->turn),
                                         board->moves_left,
                                         board->moves_left == 1 ? "" : "s"));

                draw_playable(players[board->turn].ai == PLAYER_HUMAN);
        }

        /* Let the AI thread run one move */
        start_ai();
}

// Tree view cursor changed
static void cursor_changed(GtkTreeView *tree_view, gpointer user_data)
{
        GtkTreeSelection *selection;
        GtkTreeIter iter;
        GtkTreePath *path;
        gint *indices;

        selection = gtk_tree_view_get_selection(tree_view);
        gtk_tree_selection_get_selected(selection, NULL, &iter);
        path = gtk_tree_model_get_path(GTK_TREE_MODEL(list_store), &iter);
        indices = gtk_tree_path_get_indices(path);
        indices += gtk_tree_path_get_depth(path) - 1;
        if (*indices == move_no)
                return;
        go_to_move(*indices);
        gtk_tree_path_free(path);
        draw_board();
        stop_ai();
        setup_move();
}

// Clear moves in the history list
void tree_view_clear(unsigned int from)
{
        GtkTreeIter iter;
        GtkTreeSelection *selection;
        gboolean valid;

        if (!tree_view)
                return;

        g_signal_handlers_block_by_func(G_OBJECT(tree_view), cursor_changed,
                                        NULL);

        // Remove entries from list store
        valid = gtk_tree_model_iter_nth_child(GTK_TREE_MODEL(list_store),
                                              &iter, NULL, from);
        while (valid)
                valid = gtk_list_store_remove(list_store, &iter);

        // Select start entry
        selection = gtk_tree_view_get_selection(GTK_TREE_VIEW(tree_view));
        gtk_tree_model_get_iter_first(GTK_TREE_MODEL(list_store), &iter);
        gtk_tree_selection_select_iter(selection, &iter);

        g_signal_handlers_unblock_by_func(G_OBJECT(tree_view), cursor_changed,
                                          NULL);
}

// Make a move for the current player
void make_move(BCOORD x, BCOORD y)
{
        GtkTreeIter iter;
        GtkTreePath *path;
        GtkTreeSelection *selection;
        PIECE last_turn;

        if (piece_at(board, x, y) != PIECE_NONE) {
                g_warning("%s attempted invalid move to %s",
                          piece_to_string(board->turn),
                          bcoords_to_string(x, y));
                return;
        }

        if (!tournament) {
                clear_last_moves();

                // Remove the later moves from the list
                if (move_no < move_last) {
                        clear_history(move_no + 1);
                        tree_view_clear(move_no + 1);
                }

                /* Add move to list */
                gtk_list_store_append(list_store, &iter);
                gtk_list_store_set(list_store, &iter, 0, va("%c%s",
                                   piece_to_char(board->turn),
                                   bcoords_to_string(x, y)), -1);

                // Scroll moves list down
                path = gtk_tree_model_get_path(GTK_TREE_MODEL(list_store),
                                               &iter);
                gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(tree_view), path,
                                             NULL, FALSE, 0., 0.);
                gtk_tree_path_free(path);

                // Select last move
                selection =
                          gtk_tree_view_get_selection(GTK_TREE_VIEW(tree_view));
                g_signal_handlers_block_by_func(G_OBJECT(tree_view),
                                                cursor_changed, NULL);
                gtk_tree_selection_select_iter(selection, &iter);
                g_signal_handlers_unblock_by_func(G_OBJECT(tree_view),
                                                  cursor_changed, NULL);
        }

        // Place piece
        board->move_x = x;
        board->move_y = y;
        last_turn = board->turn;
        go_to_move(++move_no);
        place_piece(board, x, y);
        if (!tournament)
                draw_tile(x, y);
        board->won = check_win_full(board, x, y,
                                    &board->win_x1, &board->win_y1,
                                    &board->win_x2, &board->win_y2);
        if (!board->won) {
                board->moves_left--;
                if (board->moves_left <= 0) {
                        board->turn = other_player(last_turn);
                        board->moves_left = place_p;
                }
        }

        /* Tournament win conditions */
        if (tournament) {
                if (move_no >= board_size * board_size) {
                        tourney_result(PIECE_NONE, move_last);
                        return;
                }
                if (board->won) {
                        tourney_result(board->turn, move_last);
                        return;
                }
        } else
                draw_last_moves();

        setup_move();
}

// Main window closed
static void window_destroy(GtkWidget *widget, gpointer data)
{
        gtk_main_quit();
}

// Create a menu bar the old-fashioned way
static GtkWidget *window_menu_bar_init(GtkAccelGroup *accel)
{
        GtkWidget *bar, *item, *submenu;

        bar = gtk_menu_bar_new();

        /* Init player dialogs */
        player_dialog_init(player_dialog, PIECE_BLACK);
        player_dialog_init(player_dialog + 1, PIECE_WHITE);
        player_dialog_init(player_dialog + 2, PIECE_NONE);

        // Game menu
        item = gtk_menu_item_new_with_mnemonic("_Game");
        gtk_menu_shell_append(GTK_MENU_SHELL(bar), item);
        submenu = gtk_menu_new();
        gtk_menu_item_set_submenu(GTK_MENU_ITEM(item), submenu);
        item = gtk_image_menu_item_new_from_stock(GTK_STOCK_NEW, accel);
        g_signal_connect(G_OBJECT(item), "activate",
                         G_CALLBACK(open_new_game_dialog), NULL);
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
        item = gtk_image_menu_item_new_from_stock(GTK_STOCK_OPEN, accel);
        g_signal_connect(G_OBJECT(item), "activate",
                         G_CALLBACK(open_file_dialog), NULL);
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
        item = gtk_separator_menu_item_new();
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
        item = gtk_image_menu_item_new_from_stock(GTK_STOCK_SAVE_AS, accel);
        g_signal_connect(G_OBJECT(item), "activate",
                         G_CALLBACK(save_file_dialog), NULL);
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
#ifndef NO_CAIRO_SVG
        item = gtk_separator_menu_item_new();
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
        item = gtk_menu_item_new_with_mnemonic("Screenshot");
        g_signal_connect(G_OBJECT(item), "activate",
                         G_CALLBACK(screenshot_dialog), NULL);
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
#endif
        item = gtk_separator_menu_item_new();
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);

        // Game -> Quit
        item = gtk_image_menu_item_new_from_stock(GTK_STOCK_QUIT, accel);
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
        g_signal_connect(G_OBJECT(item), "activate", G_CALLBACK(window_destroy),
                         NULL);

        /* Setup menu */
        item = gtk_menu_item_new_with_mnemonic("_Setup");
        gtk_menu_shell_append(GTK_MENU_SHELL(bar), item);
        submenu = gtk_menu_new();
        gtk_menu_item_set_submenu(GTK_MENU_ITEM(item), submenu);
        item = gtk_menu_item_new_with_mnemonic("_Black Player");
        g_signal_connect(G_OBJECT(item), "activate",
                         G_CALLBACK(open_player_dialog), player_dialog);
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
        item = gtk_menu_item_new_with_mnemonic("_White Player");
        g_signal_connect(G_OBJECT(item), "activate",
                         G_CALLBACK(open_player_dialog), player_dialog + 1);
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
        item = gtk_menu_item_new_with_mnemonic("_Mark Player");
        g_signal_connect(G_OBJECT(item), "activate",
                         G_CALLBACK(open_player_dialog), player_dialog + 2);
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
        item = gtk_separator_menu_item_new();
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
        item = gtk_menu_item_new_with_mnemonic("_Tournament");
        g_signal_connect(G_OBJECT(item), "activate",
                         G_CALLBACK(open_tourney_dialog), NULL);
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
        item = gtk_separator_menu_item_new();
        gtk_menu_shell_append(GTK_MENU_SHELL(submenu), item);
        add_options_to_menu_shell(submenu);

        /* Tests menu */
        item = gtk_menu_item_new_with_mnemonic("_Tests");
        gtk_menu_shell_append(GTK_MENU_SHELL(bar), item);
        submenu = gtk_menu_new();
        add_tests_to_menu_shell(submenu);
        gtk_menu_item_set_submenu(GTK_MENU_ITEM(item), submenu);

        return bar;
}

// Create a tree view to store the move history
static GtkWidget *tree_view_init(void)
{
        GtkWidget *scrolled;
        GtkTreeViewColumn *column;
        GtkTreeSelection *selection;
        GtkTreeIter iter;

        if (tree_view)
                return tree_view;

        // Tree view to list move history
        list_store = gtk_list_store_new(1, G_TYPE_STRING);
        tree_view = gtk_tree_view_new_with_model(GTK_TREE_MODEL(list_store));
        selection = gtk_tree_view_get_selection(GTK_TREE_VIEW(tree_view));
        gtk_tree_selection_set_mode(selection, GTK_SELECTION_BROWSE);
        gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(tree_view), TRUE);
        column = gtk_tree_view_column_new_with_attributes("History",
                                                   gtk_cell_renderer_text_new(),
                                                          "text", 0, NULL);
        gtk_tree_view_append_column(GTK_TREE_VIEW(tree_view), column);
        g_signal_connect(G_OBJECT(tree_view), "cursor-changed",
                         G_CALLBACK(cursor_changed), NULL);

        // Add empty board entry to history list
        gtk_list_store_append(list_store, &iter);
        gtk_list_store_set(list_store, &iter, 0, "(start)", -1);

        // Scrolled container for tree view
        scrolled = gtk_scrolled_window_new(NULL, NULL);
        gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolled),
                                       GTK_POLICY_NEVER,
                                       GTK_POLICY_AUTOMATIC);
        gtk_scrolled_window_set_shadow_type(GTK_SCROLLED_WINDOW(scrolled),
                                            GTK_SHADOW_IN);
        gtk_container_add(GTK_CONTAINER(scrolled), tree_view);
        return scrolled;
}

// Create and show main window
static void window_init(void)
{
        GtkWidget *hbox, *vbox;
        GtkAccelGroup *accel;

        if (window)
                return;

        // Keyboard accelerator group
        accel = gtk_accel_group_new();

        // Menu, hbox, and status bar are packed vertically
        vbox = gtk_vbox_new(FALSE, 0);
        gtk_box_pack_start(GTK_BOX(vbox), window_menu_bar_init(accel), FALSE,
                           FALSE, 0);
        statusbar = gtk_statusbar_new();
        gtk_box_pack_end(GTK_BOX(vbox), statusbar, FALSE, FALSE, 0);

        // Board and history are packed horizontally
        hbox = gtk_hbox_new(FALSE, 0);
        gtk_box_pack_start(GTK_BOX(vbox), hbox, TRUE, TRUE, 0);
        gtk_box_pack_start(GTK_BOX(hbox), draw_init(), TRUE, TRUE, 0);
        gtk_box_pack_start(GTK_BOX(hbox), tree_view_init(), FALSE, FALSE, 0);

        // Create and show the window
        window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
        g_signal_connect(G_OBJECT(window), "destroy",
                         G_CALLBACK(window_destroy), NULL);
        gtk_window_set_title(GTK_WINDOW(window), "connectk");
        gtk_window_resize(GTK_WINDOW(window), 686, 656);
        gtk_window_add_accel_group(GTK_WINDOW(window), accel);
        gtk_container_add(GTK_CONTAINER(window), vbox);
        gtk_widget_show_all(window);

        // Create new game dialog
        new_game_dialog_init();

        /* Initialize tournament dialog */
        tourney_dialog_init();
}

/*
 *      Utility and main
 */

char *nvav(int *plen, const char *fmt, va_list va)
{
        static char buffer[2][16000];
        static int which;
        int len;

        which = !which;
        len = g_vsnprintf(buffer[which], sizeof(buffer[which]), fmt, va);
        if (plen)
                *plen = len;
        return buffer[which];
}

char *nva(int *plen, const char *fmt, ...)
{
        va_list va;
        char *string;

        va_start(va, fmt);
        string = nvav(plen, fmt, va);
        va_end(va);
        return string;
}

char *va(const char *fmt, ...)
{
        va_list va;
        char *string;

        va_start(va, fmt);
        string = nvav(NULL, fmt, va);
        va_end(va);
        return string;
}

int main(int argc, char *argv[])
{
        start_ai_thread();
        new_game(19);

        /* Set the Glib random seed */
        g_random_set_seed(time(NULL));

        /* Initialize and run the GTK interface */
        gtk_init(&argc, &argv);
        window_init();
        gtk_main();

        return 0;
}
