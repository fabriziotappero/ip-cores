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
#include "shared.h"
#include "connectk.h"

/*
 *      New game dialog
 */

static GtkWidget *window = NULL, *new_game_dialog, *ngd_board_size,
                 *ngd_connect_k, *ngd_place_p, *ngd_start_q, *ngd_combo;

/* Clear the board and history for a new game */
void new_game(unsigned int size)
{
        tree_view_clear(1);
        clear_history(0);
        set_board_size(size);
        board = NULL;
        go_to_move(0);
        board->moves_left = start_q;
        board->turn = PIECE_BLACK;
        draw_board();
        stop_ai();
        setup_move();
}

// Close the new game dialog
static void new_game_dialog_cancel(GtkButton *button, gpointer user_data)
{
        gtk_widget_hide(new_game_dialog);
}

// Accept the new game dialog
static void new_game_dialog_ok(GtkButton *button, gpointer user_data)
{
        new_game_dialog_cancel(button, user_data);
        connect_k = gtk_spin_button_get_value_as_int(
                                                GTK_SPIN_BUTTON(ngd_connect_k));
        place_p = gtk_spin_button_get_value_as_int(
                                                  GTK_SPIN_BUTTON(ngd_place_p));
        start_q = gtk_spin_button_get_value_as_int(
                                                  GTK_SPIN_BUTTON(ngd_start_q));
        new_game(gtk_spin_button_get_value_as_int(
                                              GTK_SPIN_BUTTON(ngd_board_size)));
}

// Create a spin button and label
static GtkWidget *labeled_spin_new(const gchar *text, double spin_from,
                                   double spin_to, double spin_set,
                                   GtkWidget **spin, GCallback func)
{
        GtkWidget *hbox, *label;

        hbox = gtk_hbox_new(FALSE, 4);
        label = gtk_label_new(text);
        gtk_misc_set_alignment(GTK_MISC(label), 1., 0.5);
        *spin = gtk_spin_button_new_with_range(spin_from, spin_to, 1.);
        gtk_spin_button_set_value(GTK_SPIN_BUTTON(*spin), spin_set);
        if (func)
                g_signal_connect(*spin, "value-changed", G_CALLBACK(func),
                                 NULL);
        gtk_box_pack_start(GTK_BOX(hbox), label, TRUE, TRUE, 0);
        gtk_box_pack_start(GTK_BOX(hbox), *spin, FALSE, FALSE, 0);
        return hbox;
}

static void new_game_set_custom(void)
/* Called when the user changes some parameter */
{
        gtk_combo_box_set_active(GTK_COMBO_BOX(ngd_combo), 3);
}

static void new_game_set_combo(GtkComboBox *combo)
/* Called when the combo box value changes */
{
        int new_size = 19, new_k = 6, new_p = 2, new_q = 1;

        switch(gtk_combo_box_get_active(combo)) {
        case 0:
                new_size = 3;
                new_k = 3;
                new_p = 1;
                break;
        case 1:
                new_k = 5;
                new_p = 1;
        case 2:
                break;
        default:
                return;
        }

        /* Keep the values from resetting the combo box to custom */
        g_signal_handlers_block_by_func(G_OBJECT(ngd_board_size),
                                        new_game_set_custom, NULL);
        g_signal_handlers_block_by_func(G_OBJECT(ngd_place_p),
                                        new_game_set_custom, NULL);
        g_signal_handlers_block_by_func(G_OBJECT(ngd_start_q),
                                        new_game_set_custom, NULL);
        g_signal_handlers_block_by_func(G_OBJECT(ngd_connect_k),
                                        new_game_set_custom, NULL);

        /* Set the preset values */
        gtk_spin_button_set_value(GTK_SPIN_BUTTON(ngd_board_size), new_size);
        gtk_spin_button_set_value(GTK_SPIN_BUTTON(ngd_place_p), new_p);
        gtk_spin_button_set_value(GTK_SPIN_BUTTON(ngd_start_q), new_q);
        gtk_spin_button_set_value(GTK_SPIN_BUTTON(ngd_connect_k), new_k);

        /* Re-enable the signal handlers */
        g_signal_handlers_unblock_by_func(G_OBJECT(ngd_board_size),
                                          new_game_set_custom, NULL);
        g_signal_handlers_unblock_by_func(G_OBJECT(ngd_place_p),
                                          new_game_set_custom, NULL);
        g_signal_handlers_unblock_by_func(G_OBJECT(ngd_start_q),
                                          new_game_set_custom, NULL);
        g_signal_handlers_unblock_by_func(G_OBJECT(ngd_connect_k),
                                          new_game_set_custom, NULL);
}

// Create new game dialog
void new_game_dialog_init(void)
{
        GtkWidget *vbox, *hbox, *w;

        vbox = gtk_vbox_new(FALSE, 4);

        /* Stock games */
        ngd_combo = gtk_combo_box_new_text();
        gtk_combo_box_append_text(GTK_COMBO_BOX(ngd_combo), "Tic Tac Toe");
        gtk_combo_box_append_text(GTK_COMBO_BOX(ngd_combo), "Go Moku");
        gtk_combo_box_append_text(GTK_COMBO_BOX(ngd_combo), "Connect 6");
        gtk_combo_box_append_text(GTK_COMBO_BOX(ngd_combo), "Custom");
        gtk_combo_box_set_active(GTK_COMBO_BOX(ngd_combo), 2);
        gtk_box_pack_start(GTK_BOX(vbox), ngd_combo, FALSE, FALSE, 0);
        g_signal_connect(ngd_combo, "changed", G_CALLBACK(new_game_set_combo),
                         NULL);

        // Parameters
        hbox = labeled_spin_new("Board size:", 2., MAX_BOARD_SIZE, 19.,
                                &ngd_board_size, new_game_set_custom);
        gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);
        hbox = labeled_spin_new("Connect to win:", 2., MAX_CONNECT_K, 6.,
                                &ngd_connect_k, new_game_set_custom);
        gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);
        hbox = labeled_spin_new("Moves per turn:", 1., MAX_PLACE_P, 2.,
                                &ngd_place_p, new_game_set_custom);
        gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);
        hbox = labeled_spin_new("Starting moves:", 1., MAX_START_Q, 1.,
                                &ngd_start_q, new_game_set_custom);
        gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);

        /* Separator */
        w = gtk_vbox_new(FALSE, 0);
        gtk_box_pack_start(GTK_BOX(vbox), w, FALSE, FALSE, 4);

        /* Cancel/Ok buttons */
        hbox = gtk_hbox_new(TRUE, 4);
        w = gtk_button_new_from_stock(GTK_STOCK_CANCEL);
        g_signal_connect(G_OBJECT(w), "clicked",
                         G_CALLBACK(new_game_dialog_cancel), NULL);
        gtk_box_pack_start(GTK_BOX(hbox), w, TRUE, TRUE, 0);
        w = gtk_button_new_from_stock(GTK_STOCK_OK);
        g_signal_connect(G_OBJECT(w), "clicked",
                         G_CALLBACK(new_game_dialog_ok), NULL);
        gtk_box_pack_end(GTK_BOX(hbox), w, TRUE, TRUE, 0);
        gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);

        // Create dialog window
        new_game_dialog = gtk_window_new(GTK_WINDOW_TOPLEVEL);
        g_signal_connect(G_OBJECT(new_game_dialog), "delete-event",
                         G_CALLBACK(gtk_widget_hide_on_delete), NULL);
        gtk_window_set_title(GTK_WINDOW(new_game_dialog), "New game...");
        gtk_window_set_transient_for(GTK_WINDOW(new_game_dialog),
                                     GTK_WINDOW(window));
        gtk_window_set_modal(GTK_WINDOW(new_game_dialog), TRUE);
        gtk_window_set_resizable(GTK_WINDOW(new_game_dialog), FALSE);
        gtk_container_add(GTK_CONTAINER(new_game_dialog), vbox);
        gtk_container_border_width(GTK_CONTAINER(new_game_dialog), 12);
}

// Game -> New activated
void open_new_game_dialog(GtkMenuItem *item, gpointer user_data)
{
        gtk_widget_show_all(new_game_dialog);
}

/*
 *      Open/save as dialogs
 */

/* Game -> Open activated */
void open_file_dialog(GtkMenuItem *item, gpointer user_data)
{
        GtkWidget *dialog;

        halt_ai_thread();
        dialog = gtk_file_chooser_dialog_new("Open File",
        				     GTK_WINDOW(window),
        				     GTK_FILE_CHOOSER_ACTION_OPEN,
        				     GTK_STOCK_CANCEL,
        				     GTK_RESPONSE_CANCEL,
        				     GTK_STOCK_OPEN,
        				     GTK_RESPONSE_ACCEPT,
        				     NULL);
        if (gtk_dialog_run(GTK_DIALOG (dialog)) == GTK_RESPONSE_ACCEPT) {
            char *filename;

            filename = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dialog));
            load_moves_list(filename);
            g_free(filename);
        }
        gtk_widget_destroy(dialog);
        start_ai_thread();
}

/* Game -> Save as activated */
void save_file_dialog(GtkMenuItem *item, gpointer user_data)
{
        GtkWidget *dialog;

        halt_ai_thread();
        dialog = gtk_file_chooser_dialog_new("Save File",
        				     GTK_WINDOW(window),
        				     GTK_FILE_CHOOSER_ACTION_SAVE,
        				     GTK_STOCK_CANCEL,
        				     GTK_RESPONSE_CANCEL,
        				     GTK_STOCK_SAVE,
        				     GTK_RESPONSE_ACCEPT,
        				     NULL);
        gtk_file_chooser_set_do_overwrite_confirmation(GTK_FILE_CHOOSER(dialog),
                                                       TRUE);
        if (gtk_dialog_run(GTK_DIALOG(dialog)) == GTK_RESPONSE_ACCEPT) {
            char *filename;

            filename = gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dialog));
            save_moves_list(filename);
            g_free(filename);
        }
        gtk_widget_destroy(dialog);
        start_ai_thread();
}

/*
 *      Tournament dialog
 */

static GtkWidget *tourney_dialog = NULL, *tourney_games, *tourney_save,
                 *tourney_prefix, *tourney_view, *tourney_exec, *tourney_halt;
static GtkListStore *tourney_store;
static const char *tourney_prefix_str = NULL;
static int tourney_total, tourney_wins[PIECES];
int tournament = 0;

static void tourney_dialog_close(GtkWidget *button)
{
        gtk_widget_hide(tourney_dialog);
}

static void tourney_dialog_stop(GtkWidget *button)
{
        int total = tourney_wins[PIECE_BLACK] + tourney_wins[PIECE_WHITE] +
                    tourney_wins[PIECE_NONE];

        gtk_widget_hide(tourney_halt);
        gtk_widget_show(tourney_exec);
        tournament = 0;
        if (tourney_wins[PIECE_BLACK] > tourney_wins[PIECE_WHITE])
                window_status(va("Black won tournament (%d%% of games won)",
                                 tourney_wins[PIECE_BLACK] * 100 / total));
        else if (tourney_wins[PIECE_WHITE] > tourney_wins[PIECE_BLACK])
                window_status(va("White won tournament (%d%% of games won)",
                                 tourney_wins[PIECE_WHITE] * 100 / total));
        else
                window_status("Tournament was a draw");
        draw_board();
}

static void tourney_dialog_execute(GtkWidget *button)
{
        gtk_list_store_clear(tourney_store);
        gtk_widget_hide(tourney_exec);
        gtk_widget_show(tourney_halt);
        tourney_total = tournament =
               gtk_spin_button_get_value_as_int(GTK_SPIN_BUTTON(tourney_games));
        if (gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(tourney_save)))
                tourney_prefix_str =
                                  gtk_entry_get_text(GTK_ENTRY(tourney_prefix));
        else
                tourney_prefix_str = NULL;
        new_game(board_size);
        tourney_wins[PIECE_NONE] = 0;
        tourney_wins[PIECE_BLACK] = 0;
        tourney_wins[PIECE_WHITE] = 0;
        window_status("Running tournament...");
}

void tourney_result(PIECE win, int moves)
{
        GtkTreeIter iter;
        GtkTreePath *path;
        int game = tourney_total - tournament + 1;
        char *filename;

        tourney_wins[win]++;

        /* Add game to list */
        gtk_list_store_append(tourney_store, &iter);
        gtk_list_store_set(tourney_store, &iter, 0, piece_to_string(win),
                           1, moves, 2, game, -1);

        /* Scroll games list down */
        path = gtk_tree_model_get_path(GTK_TREE_MODEL(tourney_store), &iter);
        gtk_tree_view_scroll_to_cell(GTK_TREE_VIEW(tourney_view), path,
                                     NULL, FALSE, 0., 0.);
        gtk_tree_path_free(path);

        /* Save the tournament game */
        if (tourney_prefix_str) {
                filename = g_strdup(va("%s%d", tourney_prefix_str, game));
                save_moves_list(filename);
                g_free(filename);
        }

        if (--tournament > 0) {
                new_game(board_size);
                return;
        }
        tourney_dialog_stop(NULL);
}

void tourney_dialog_init(void)
{
        GtkWidget *vbox, *hbox, *w, *scrolled;
        GtkTreeViewColumn *column;

        if (tourney_dialog)
                return;

        vbox = gtk_vbox_new(FALSE, 4);

        /* Games spin button */
        hbox = gtk_hbox_new(FALSE, 0);
        w = gtk_label_new("Number of games:");
        gtk_box_pack_start(GTK_BOX(hbox), w, FALSE, FALSE, 0);
        tourney_games = gtk_spin_button_new_with_range(1., 1000., 1.);
        gtk_box_pack_start(GTK_BOX(hbox), tourney_games, FALSE, FALSE, 0);
        gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);

        /* Games list */
        tourney_store = gtk_list_store_new(3, G_TYPE_STRING, G_TYPE_INT,
                                           G_TYPE_INT);
        tourney_view = gtk_tree_view_new_with_model(GTK_TREE_MODEL(
                                                                tourney_store));
        gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(tourney_view), TRUE);
        column = gtk_tree_view_column_new_with_attributes("Game",
                                                   gtk_cell_renderer_text_new(),
                                                          "text", 2, NULL);
        gtk_tree_view_append_column(GTK_TREE_VIEW(tourney_view), column);
        column = gtk_tree_view_column_new_with_attributes("Moves",
                                                   gtk_cell_renderer_text_new(),
                                                          "text", 1, NULL);
        gtk_tree_view_append_column(GTK_TREE_VIEW(tourney_view), column);
        column = gtk_tree_view_column_new_with_attributes("Winner",
                                                   gtk_cell_renderer_text_new(),
                                                          "text", 0, NULL);
        gtk_tree_view_append_column(GTK_TREE_VIEW(tourney_view), column);

        /* Scrolled container for tree view */
        scrolled = gtk_scrolled_window_new(NULL, NULL);
        gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scrolled),
                                       GTK_POLICY_NEVER,
                                       GTK_POLICY_AUTOMATIC);
        gtk_scrolled_window_set_shadow_type(GTK_SCROLLED_WINDOW(scrolled),
                                            GTK_SHADOW_IN);
        gtk_container_add(GTK_CONTAINER(scrolled), tourney_view);
        gtk_box_pack_start(GTK_BOX(vbox), scrolled, TRUE, TRUE, 0);

        /* Save games checkbox */
        hbox = gtk_hbox_new(FALSE, 0);
        tourney_save = gtk_check_button_new_with_label("Save games with "
                                                       "prefix:");
        gtk_box_pack_start(GTK_BOX(hbox), tourney_save, FALSE, FALSE, 0);
        tourney_prefix = gtk_entry_new();
        gtk_box_pack_start(GTK_BOX(hbox), tourney_prefix, TRUE, TRUE, 0);
        gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);

        /* Execute button */
        hbox = gtk_hbox_new(TRUE, 0);
        tourney_exec = gtk_button_new_from_stock(GTK_STOCK_EXECUTE);
        g_signal_connect(G_OBJECT(tourney_exec), "clicked",
                         G_CALLBACK(tourney_dialog_execute), NULL);
        gtk_widget_set_no_show_all(tourney_exec, TRUE);
        gtk_widget_show(tourney_exec);
        gtk_box_pack_start(GTK_BOX(hbox), tourney_exec, TRUE, TRUE, 0);

        /* Halt button */
        tourney_halt = gtk_button_new_from_stock(GTK_STOCK_STOP);
        g_signal_connect(G_OBJECT(tourney_halt), "clicked",
                         G_CALLBACK(tourney_dialog_stop), NULL);
        gtk_widget_set_no_show_all(tourney_halt, TRUE);
        gtk_widget_hide(tourney_halt);
        gtk_box_pack_start(GTK_BOX(hbox), tourney_halt, TRUE, TRUE, 0);

        /* Close button */
        w = gtk_button_new_from_stock(GTK_STOCK_CLOSE);
        g_signal_connect(G_OBJECT(w), "clicked",
                         G_CALLBACK(tourney_dialog_close), NULL);
        gtk_box_pack_start(GTK_BOX(hbox), w, TRUE, TRUE, 0);
        gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);

        /* Create dialog window */
        tourney_dialog = gtk_window_new(GTK_WINDOW_TOPLEVEL);
        g_signal_connect(G_OBJECT(tourney_dialog), "delete-event",
                         G_CALLBACK(gtk_widget_hide_on_delete), NULL);
        gtk_window_set_title(GTK_WINDOW(tourney_dialog), "Tournament");
        gtk_window_set_transient_for(GTK_WINDOW(tourney_dialog),
                                     GTK_WINDOW(window));
        gtk_window_set_modal(GTK_WINDOW(tourney_dialog), TRUE);
        gtk_container_add(GTK_CONTAINER(tourney_dialog), vbox);
        gtk_container_border_width(GTK_CONTAINER(tourney_dialog), 12);
        gtk_window_resize(GTK_WINDOW(tourney_dialog), 256, 384);
}

void open_tourney_dialog(GtkWidget *menuitem)
{
        if (!players[PIECE_BLACK].ai || !players[PIECE_WHITE].ai) {
                GtkWidget * dialog;

                dialog = gtk_message_dialog_new(GTK_WINDOW(window),
                                                GTK_DIALOG_DESTROY_WITH_PARENT,
                                                GTK_MESSAGE_ERROR,
                                                GTK_BUTTONS_OK,
                                                "Cannot run a tournament with "
                                                "human players.");
                gtk_dialog_run(GTK_DIALOG(dialog));
                gtk_widget_destroy(dialog);
                return;
        }
        gtk_widget_show_all(tourney_dialog);
}

/*
 *      Player dialog
 */

PlayerDialog player_dialog[PIECES];

static void player_dialog_ok(GtkWidget *button, PlayerDialog *pd)
{
        int i, index;

        gtk_widget_hide(pd->window);
        index = gtk_combo_box_get_active(GTK_COMBO_BOX(pd->combo));

        /* Search options */
        pd->player->depth =
                   gtk_spin_button_get_value_as_int(GTK_SPIN_BUTTON(pd->depth));
        pd->player->branch =
                  gtk_spin_button_get_value_as_int(GTK_SPIN_BUTTON(pd->branch));
        pd->player->cache =
                     gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(pd->cache));
        pd->player->tss =
                       gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(pd->tss));
        for (i = 0; i < SEARCHES; i++)
                if (gtk_toggle_button_get_active(
                                            GTK_TOGGLE_BUTTON(pd->search[i]))) {
                        pd->player->search = i;
                        break;
                }

        /* Marker player */
        if (pd->player == players) {
                AIMoves *moves;

                if (index == PLAYER_HUMAN) {
                        draw_marks(NULL, FALSE);
                        return;
                }
                pd->player->ai = index;
                stop_ai();
                moves = run_ai(players);
                if (opt_print_u)
                        g_debug("AI %s utility %d (0x%x)", ai(index)->s_desc,
                                moves->utility, moves->utility);
                setup_move();
                draw_marks(moves, TRUE);
                return;
        }

        /* White or black player changed */
        if (pd->player->ai != index) {
                pd->player->ai = index;
                stop_ai();
                setup_move();
        }
}

void player_dialog_init(PlayerDialog *pd, PIECE player)
{
        GtkWidget *vbox, *hbox, *fbox, *w;
        GSList *group = NULL;
        int i, i_max;
        const char *label;

        pd->player = players + player;
        vbox = gtk_vbox_new(FALSE, 4);

        /* Controller combo box */
        hbox = gtk_hbox_new(FALSE, 0);
        w = gtk_label_new("Controller:");
        gtk_box_pack_start(GTK_BOX(hbox), w, FALSE, FALSE, 8);
        w = gtk_combo_box_new_text();
        i_max = number_of_ais();
        for (i = 0; i < i_max; i++) {
                AI *a = ai(i);

                label = "Human";
                if (a->func)
                        label = player_to_string(i);
                gtk_combo_box_append_text(GTK_COMBO_BOX(w), label);
        }
        gtk_combo_box_set_active(GTK_COMBO_BOX(w), 0);
        pd->combo = w;
        gtk_box_pack_start(GTK_BOX(hbox), w, FALSE, FALSE, 0);
        gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);

        /* Search box frame */
        w = gtk_frame_new("Search");
        gtk_box_pack_start(GTK_BOX(vbox), w, FALSE, FALSE, 4);
        fbox = gtk_vbox_new(FALSE, 4);
        gtk_container_add(GTK_CONTAINER(w), fbox);
        gtk_container_border_width(GTK_CONTAINER(fbox), 8);

        /* Search radio buttons */
        for (i = 0; i < SEARCHES; i++) {
                w = gtk_radio_button_new_with_label(group, search_to_string(i));
                group = gtk_radio_button_get_group(GTK_RADIO_BUTTON(w));
                gtk_box_pack_start(GTK_BOX(fbox), w, FALSE, FALSE, 0);
                pd->search[i] = w;
        }

        /* Cache toggle button */
        pd->cache = gtk_check_button_new_with_label("Use search cache");
        gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(pd->cache), TRUE);
        gtk_box_pack_start(GTK_BOX(fbox), pd->cache, FALSE, FALSE, 0);

        /* Threat-space search toggle button */
        pd->tss = gtk_check_button_new_with_label("Threat-space search");
        gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(pd->tss), FALSE);
        /*gtk_box_pack_start(GTK_BOX(fbox), pd->tss, FALSE, FALSE, 0);*/

        /* Search depth spin button */
        w = labeled_spin_new("Depth in moves:", 1., MAX_DEPTH, 1., &pd->depth,
                             NULL);
        gtk_box_pack_start(GTK_BOX(fbox), w, FALSE, FALSE, 0);

        /* Minimum branching factor spin button */
        w = labeled_spin_new("Minimum branches:", 0., MAX_BRANCH, 2.,
                             &pd->branch, NULL);
        gtk_box_pack_start(GTK_BOX(fbox), w, FALSE, FALSE, 0);

        /* Ok button */
        hbox = gtk_hbox_new(TRUE, 0);
        w = gtk_hbox_new(FALSE, 0);
        gtk_box_pack_start(GTK_BOX(hbox), w, FALSE, FALSE, 0);
        w = gtk_button_new_from_stock(GTK_STOCK_OK);
        g_signal_connect(G_OBJECT(w), "clicked",
                         G_CALLBACK(player_dialog_ok), pd);
        gtk_box_pack_start(GTK_BOX(hbox), w, TRUE, TRUE, 0);
        gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);

        /* Create dialog window */
        pd->window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
        g_signal_connect(G_OBJECT(pd->window), "delete-event",
                         G_CALLBACK(gtk_widget_hide_on_delete), NULL);
        label = "Mark Player";
        if (player)
                label = va("%s Player", piece_to_string(player));
        gtk_window_set_title(GTK_WINDOW(pd->window), label);
        gtk_window_set_transient_for(GTK_WINDOW(pd->window),
                                     GTK_WINDOW(window));
        gtk_window_set_modal(GTK_WINDOW(pd->window), TRUE);
        gtk_window_set_resizable(GTK_WINDOW(pd->window), FALSE);
        gtk_container_add(GTK_CONTAINER(pd->window), vbox);
        gtk_container_border_width(GTK_CONTAINER(pd->window), 12);
}

void open_player_dialog(GtkWidget *menuitem, PlayerDialog *pd)
{
        gtk_widget_show_all(pd->window);
}

/*
 *      Screenshot
 */

#ifndef NO_CAIRO_SVG
void screenshot_dialog(void)
/* Game -> Screenshot activated */
{
        GtkWidget *dialog;

        halt_ai_thread();
        dialog = gtk_file_chooser_dialog_new("Save Screenshot",
        				     GTK_WINDOW(window),
        				     GTK_FILE_CHOOSER_ACTION_SAVE,
        				     GTK_STOCK_CANCEL,
        				     GTK_RESPONSE_CANCEL,
        				     GTK_STOCK_SAVE,
        				     GTK_RESPONSE_ACCEPT,
        				     NULL);
        gtk_file_chooser_set_do_overwrite_confirmation(GTK_FILE_CHOOSER(dialog),
                                                       TRUE);
        if (gtk_dialog_run(GTK_DIALOG(dialog)) == GTK_RESPONSE_ACCEPT) {
                char *filename;

                filename =
                        gtk_file_chooser_get_filename(GTK_FILE_CHOOSER(dialog));
                draw_screenshot(filename);
                g_free(filename);
        }
        gtk_widget_destroy(dialog);
        start_ai_thread();
}
#endif
