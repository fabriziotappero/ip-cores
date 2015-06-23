
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

/*
 *      User Interface
 */

#ifdef __GTK_H__
void add_tests_to_menu_shell(GtkWidget *menu);
#endif

void setup_move(void);
void tree_view_clear(unsigned int from);

/*
 *      Private game state
 */

enum {
        SEARCH_NONE,
        SEARCH_DFS,
        SEARCHES
};
typedef int SEARCH;

typedef struct {
        PLAYER ai;
        SEARCH search;
        int depth, branch, cache, tss;
} Player;

extern int move_last, tournament;
extern Player players[PIECES];
#define PLAYER_HUMAN 0

void clear_history(unsigned int from_move);
void go_to_move(unsigned int move);
void make_move(BCOORD x, BCOORD y);
void new_game(unsigned int size);
void set_board_size(unsigned int size);
char *search_to_string(SEARCH s);

/*
 *      Move list files
 */

int load_moves_list(const char *filename);
int save_moves_list(const char *filename);

/*
 *      Game board drawing
 */

#ifdef __GTK_H__
GtkWidget *draw_init(void);
#endif
void draw_board_sized(int size);
#define draw_board() draw_board_sized(0)
void draw_tile(BCOORD x, BCOORD y);
void draw_playable(int yes);
void draw_win(void);
void draw_marks(AIMoves *moves, int redraw);
void clear_last_moves(void);
void draw_last_moves(void);
void draw_screenshot(const char *filename);

/*
 *      AI players
 */

const char *player_to_string(PLAYER player);
int number_of_ais(void);
AI *ai(int n);
AIMoves *run_ai(Player *player);
void stop_ai(void);
void start_ai(void);
void halt_ai_thread(void);
void start_ai_thread(void);
void search(const Board *b, AIMoves *moves, Player *player);

/*
 *      Dialogs
 */

#ifdef __GTK_H__
typedef struct {
        GtkWidget *window, *combo, *search[SEARCHES], *depth, *branch, *cache,
                  *tss;
        Player *player;
} PlayerDialog;

extern PlayerDialog player_dialog[PIECES];

void new_game_dialog_init(void);
void open_new_game_dialog(GtkMenuItem *item, gpointer user_data);
void open_file_dialog(GtkMenuItem *item, gpointer user_data);
void save_file_dialog(GtkMenuItem *item, gpointer user_data);
void tourney_dialog_init(void);
void tourney_result(PIECE win, int moves);
void open_tourney_dialog(GtkWidget *menuitem);
void player_dialog_init(PlayerDialog *pd, PIECE player);
void open_player_dialog(GtkWidget *menuitem, PlayerDialog *pd);
void screenshot_dialog(void);
#endif
