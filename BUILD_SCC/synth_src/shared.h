#ifndef SHARED_H
#define SHARED_H
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
/* Some definitions in case glib is not included */
//#ifndef TRUE
#define TRUE 1
#define FALSE 0
//#define NULL ((void*)0)
//#endif
//#ifndef __G_TYPES_H__
typedef unsigned int gboolean;
#pragma bitsize gboolean 1
typedef int gsize;
//#endif
#include <limits.h>
#include "pico.h"


/*
 *      Options
 */

/* These are boolean options the user can toggle through the "Options" menu.
   Do not modify them directly as the "Options" menu will not reflect your
   changes. You can add more options in connectk.c */
extern int opt_pause_ai,        /* Pause AI to inspect the board */
//           opt_det_ai,          /* No randomness */
           opt_print_u,         /* Print utility after every move */
           opt_debug_dfsc,      /* Print out debug messages related to the DFS
                                   cache */
           opt_debug_thread,    /* Print messages related to thread and mutex function */
           opt_mark_log,        /* Take log of weights before marking */
           opt_mark_norm,       /* Normalize to the largest weight */
           opt_debug_stage,     /* Debug priority stages */
           opt_grayscale;       /* Use grayscale rendering for print outs */

/*
 *      Utility
 */

#ifdef _EFISTDARG_H_
char *nvav(int *plen, const char *fmt, va_list va);
#endif
char *nva(int *plen, const char *fmt, ...);
char *va(const char *fmt, ...);
/* The va family of functions simplify string processing by allowing
   printf-style substitution with any string-accepting function.

   For example:
     window_status(va("1 + 2 = %d", 1 + 2));

   nva provides additional functionality by outputting the length of the
   formatted string into the integer pointed to by plen. nvav accepts a variable
   argument indirectly. */

void window_status(const char *msg);
/* Sets the status bar text of the main window */

/*
 *      Allocation Chain
 */

typedef struct AllocChain {
        gboolean free;
        /* Is this object unallocated? */

        unsigned int id;
        /* Each object has a unique id */

        struct AllocChain *next;
        /* Next object in the chain */
} AllocChain;

typedef AllocChain *(*AllocFunc)(AllocChain *old_ac);

AllocChain *achain_new(AllocChain **root, AllocFunc af);
void achain_free(AllocChain *ac);
void achain_copy(const AllocChain *src, AllocChain *dest, gsize mem);

/*
 *      Game state
 */

/* We limit the maximum values of these variables; note that these are not
   arbitrary limits and should be modified with care */
#define MAX_BOARD_SIZE  59
#define MAX_CONNECT_K   12
#define MAX_PLACE_P     12
#define MAX_START_Q     6
#define MAX_DEPTH       9
#define MAX_BRANCH      32


#define board_size 19
#define board_stride 21
#define move_no 0
#define move_last 0
#define connect_k 6
#define place_p 2
#define start_q 1
#define opt_det_ai 1
//extern int board_size, board_stride, move_no, connect_k, place_p, start_q;
/* Board size (for all boards), moves in the game, connect_k to win, place_p
   moves at a time, black has start_q moves on the first move; do NOT modify
   these directly! */

enum {
        PIECE_ERROR = -1,
        /* Error pieces form a one tile deep border around the board */

        PIECE_NONE = 0,
        PIECE_BLACK,
        PIECE_WHITE,
        /* Empty and played pieces */

        PIECES,
        /* Total number of normal pieces (2) */

        PIECE_SEARCHED,
        PIECE_SEARCHED_MAX = PIECE_SEARCHED + MAX_DEPTH,
        /* Markers used by the search system */

        PIECE_THREAT0,
        PIECE_MARKER = PIECE_THREAT0,
        /* These threat markers are usable by the AIs */
};
typedef int PIECE;
#pragma bitsize PIECE 32

#define MAX_THREAT (INT_MAX - PIECE_THREAT0)
/* Highest value a threat marker can have */

#define PIECE_THREAT(n) (PIECE_THREAT0 + (n))
/* This marker represents a threat n-turns (of that player) away */

#define piece_empty(p) ((p) == PIECE_NONE || (p) >= PIECES)
/* Checks if a piece is an empty or a marker */

typedef unsigned int PLAYER;
/* Type for AIs, this is the index of the AI entry in ai.c */

typedef int BCOORD;
#pragma bitsize BCOORD 8
/* Type for board coordinates */

typedef struct Board {
        int  ac;
        /* Allocation chain must be the first member */
	#pragma bitsize ac 4
        unsigned int moves_left;
        /* How many moves the current player has left */
	#pragma bitsize  moves_left 8

        //struct Board *parent; //not synthesizable
	int parent;
        /* The board preceeding this one in history */
	#pragma bitsize  parent 4

        gboolean won;
        BCOORD win_x1, win_y1, win_x2, win_y2;
        /* On won boards, used to indicate where the winning line is */

        PIECE turn;
        /* Whose turn it is on this board */

        BCOORD move_x, move_y;
        /* The move to the next Board in history */

        PIECE data[board_stride][board_stride];
} Board;
/* The board structure represents the state of the game board. Do NOT preserve
   board pointers across games. */
typedef struct{
	unsigned int data[361];
		#pragma bitsize data 9
} index_array;

extern AllocChain *board_root;
extern gsize board_mem;
/* Variables for the allocation chain */

//extern Board board;
/* This is the current board. Do NOT modify it, that's cheating. :) */
const char *bcoords_to_string(BCOORD x, BCOORD y);
const char *bcoord_to_alpha(BCOORD c);
/* Return a static string representing a board coordinate pair */

void string_to_bcoords(const char *string, BCOORD *x, BCOORD *y);
/* Attempts to convert a string to board coordinates */

void new_game(Board *board,unsigned int size);

AllocChain *board_alloc(AllocChain *data);
#define board_new() ((Board*)achain_new(&board_root, board_alloc))
#define board_free(b) achain_free((AllocChain*)b)
/* Boards are dynamically allocated and must be free'd */

//#define board_copy(from, to) achain_copy((AllocChain*)from, (AllocChain*)to,\
                                         board_mem)
void board_copy(const Board *from,  Board *to);
/* Overwrite one board with another */

void board_clean(Board *b);
/* Remove all threat markers from a board */

int threat_count(const Board *b, PIECE player);
/* Gives the number of threats on a board for the current player */

Board *board_at(unsigned int move);
/* Returns a static pointer to a board in the history at move */

//int  count_pieces(const Board *b, BCOORD x, BCOORD y, PIECE type,
int  count_pieces(const Board *b, BCOORD x, BCOORD y, PIECE type,
                      int dx, int dy, PIECE *out);
/* Count consecutive pieces of type starting from (x, y) in the direction given
   by (dx, dy); includes (x, y) itself in the count and outputs the final
   piece to out if it is not NULL */

gboolean check_win_full(const Board *b, BCOORD x, BCOORD y,
                        BCOORD *x1, BCOORD *y1, BCOORD *x2, BCOORD *y2);
#define check_win(b, x, y) check_win_full(b, x, y, 0, 0, 0, 0)
/* Returns non-zero if placing a piece of type at (x, y) on the current board
   will result in a win for that player. The start and end coordinates of the
   winning line will be placed in (x1, y1) and (x2, y2). */

static inline PIECE piece_at(const Board *b, BCOORD x, BCOORD y)
{
        //return b->data[(y + 1) * board_stride + x + 1];
	return b->data[y+1][x+1];
}
/* Returns the piece at (x, y) on board b. If the coordinates are out of range,
   this function will return PIECE_ERROR. */

char piece_to_char(PIECE piece);
/* Returns a one character representation of a piece (e.g. 'W', 'B', etc) */

const char *piece_to_string(PIECE piece);
/* Returns a static string representation of a piece (e.g. "White" etc) */

static inline void place_piece_type(Board *b, BCOORD x, BCOORD y, PIECE type)
{
        //b->data[(y + 1) * board_stride + x + 1] = type;
	b->data[y+1][x+1]=type;
}
#define place_piece(b, x, y) place_piece_type(b, x, y, (b)->turn)
#define place_threat(b, x, y, n) place_piece_type(b, x, y, PIECE_THREAT(n))
/* Places a piece on board b, overwriting any piece that was previously in that
   place */

#define other_player(p) ((p) == PIECE_BLACK ? PIECE_WHITE : PIECE_BLACK)
/* Invert a player piece */

/*
 *      Move arrays
 */

/* Some guideline values for move weights: */
#define AIW_MAX         INT_MAX         /* largest weight value */
#define AIW_MIN         INT_MIN         /* smallest weight value */
#define AIW_WIN         AIW_MAX         /* this move wins the game */
#define AIW_DEFEND      (AIW_WIN - 2)   /* defends from an opponent win */
#define AIW_NONE        0               /* does nothing */
#define AIW_DRAW        AIW_NONE        /* draw game */
#define AIW_LOSE        (-AIW_WIN)      /* this move loses the game */
#define AIW_THREAT_MAX  262144          /* value of an immediate threat */

typedef int AIWEIGHT;
/* Type for AI move weights (utilities) */
#pragma bitsize AIWEIGHT 32

typedef struct {
        AIWEIGHT weight;
        BCOORD x, y;
} AIMove;
/* AIs return an array filled with these */

typedef struct AIMoves {
        int ac;
        /* Allocation chain must be the first member */
	#pragma bitsize ac 4

        unsigned int len;
        /* Number of members in data */
	#pragma bitsize len 8

        AIWEIGHT utility;
        /* A composite utility value set by some AIs when producing a moves
           list */

        AIMove data[361];
        /* Array of AIMove structures */
} AIMoves;
/* An array type for holding move lists */


typedef struct {
        int threat[2];
        PIECE turn[2];
} Line;
typedef struct{
	int data[MAX_CONNECT_K + 1][2];
}threat_count_array;








AllocChain *aimoves_alloc(AllocChain *data);
#define aimoves_new() ((AIMoves*)achain_new(&aimoves_root, aimoves_alloc))
//#define aimoves_free(m) achain_free((AllocChain*)(m))
static inline void aimoves_free(AIMoves *m) {
	m->len=0;
}
///////////* Move arrays are dynamically allocated and must be free'd */
//////////
//////////#define aimoves_copy(from, to) achain_copy((AllocChain*)(from),\
//////////                                           (AllocChain*)(to), aimoves_mem)
///////////* Overwrite one array with another */
//////////
//////////void aimoves_add(AIMoves *moves, const AIMove *aim);
///////////* Add an AIMove to an AIMoves array; move weights will be added to existing
//////////   weights */
//////////
void aimoves_append(AIMoves *moves, const AIMove *aim);
#define aimoves_set aimoves_append
///////////* Add an AIMove to an AIMoves array; existing moves weights will be
//////////   overwritten */
//////////
int aimoves_choose(AIMoves *moves, AIMove *move/*, index_array *index*/);
/* Will choose one of the best moves from a GArray of AIMove structures at
   random. Returns non-zero if a move was chosen or zero if a move could not
   be chosen for some reason. */
//////////
int aimoves_compare(const void *a, const void *b);
/* A comparison function for sorting move lists by weight */
//////////
//////////void aimoves_crop(AIMoves *moves, unsigned int n);
///////////* Reduce a moves list to the top-n by weight */
//////////
//////////void aimoves_concat(AIMoves *m1, const AIMoves *m2);
///////////* Concatenates m2 to m1 without checking for duplicates */
//////////
//////////AIMoves *aimoves_dup(const AIMoves *moves);
///////////* Duplicate a GArray of moves */
//////////
int aimoves_find(const AIMoves *moves, BCOORD x, BCOORD y);
///////////* Returns the index of (x, y) if it is in moves or -1 otherwise */
//////////
//////////void aimoves_range(AIMoves *moves, AIWEIGHT *min, AIWEIGHT *max);
///////////* Find the smallest and largest weight in the move array */
//////////
//////////void aimoves_merge(AIMoves *m1, const AIMoves *m2);
///////////* Merges m2 into m1, the highest weight is used for duplicates */
//////////
//////////void aimoves_print(const AIMoves *moves);
///////////* Prints out an array of moves */
//////////
//////////void aimoves_remove(AIMoves *moves, BCOORD x, BCOORD y);
///////////* Remove an AIMove from a GArray of AIMoves */
//////////
//////////void aimoves_remove_index_fast(AIMoves *moves, int i);
///////////* Remove a move from the list by overwriting it by the last move and
//////////   decrementing the length */
//////////
void aimoves_shuffle(AIMoves *moves,unsigned int current_random);
/* Shuffle a list of moves */

void aimoves_sort(AIMoves *moves);
/* Sort a list of moves by descending weight */

//////////void aimoves_subtract(AIMoves *m1, const AIMoves *m2);
///////////* Subtracts members of m2 from m1; O(n^2) */
//////////
extern AllocChain *aimoves_root;
//////////extern gsize aimoves_mem;
///////////* Allocation chain variables */
//////////
//////////const char *aiw_to_string(AIWEIGHT w);
///////////* Convert a weight to a string representation */
//////////
//////////char *aimove_to_string(const AIMove *move);
///////////* Convert a move to a string representation */
//////////
///////////*
////////// *      AI helper functions
////////// */
//////////
extern int ai_stop;
///////////* If this variable is non-zero, the system is trying to stop the AI thread
//////////   and your AI should exit. Do not set this yourself. */
//////////
//////////typedef AIMoves *(*AIFunc)(const Board *b);
///////////* AIs are defined as functions that output an unsorted, weighted list of board
//////////   coordinates for an arbitrary board. To create an AI in a file other than
//////////   ai.c, add a prototype of the function here and in ai.c. */
//////////
//////////AIMoves *enum_top_n(const Board *b, int n);
///////////* Returns an array containing the top n moves according to the utility
//////////   function */
//////////
/*AIMoves **/ void enum_adjacent(Board *b, int dist,AIMoves *moves,unsigned int current_random);
/* Enumerate empty tiles at most dist away from some other piece on the board */

void streamsort(AIMoves *moves,index_array *index);
/*AIMoves **/void ai_marks(Board *b, PIECE min,AIMoves *moves);
/* Fills a moves list with tiles marked at least PIECE_THREAT(min) */

/*
 *      AI
 */

/* This table holds the information about all of the AIs in the program. Each
   has a short and long description. The short description will be used for
   the command line interface and the long description appears in the UI menu.
   Each AI has an associated AIFunc which outputs a move for the current
   board. */
///////////typedef struct AI {
///////////        char *s_desc, *l_desc;
///////////        AIFunc func;
///////////} AI;
///////////
///////////AIMoves *ai_sequences(const Board *b);
////////////* The square of the number of pieces in a window */
///////////
///////////AIMoves *ai_mesh(const Board *b);
////////////* The board as a mesh weighed down by the pieces */
///////////
///////////AIMoves *ai_monte_carlo(const Board *b);
////////////* Chooses the best move based on which one wins the most random games */
///////////
///////////AIMoves *ai_random(const Board *b);
////////////* Plays in a random tile */
///////////
/*AIMoves */ void ai_adjacent(Board *b,AIMove *move,unsigned int current_random);
/* Plays in a random tile adjacent to any piece on the board */

///////////AIMoves *ai_windows(const Board *b);
////////////* Plays in the best defensive position */
///////////
///////////AIMoves *ai_utility(const Board *b);
///////////AIMoves *ai_dfs_utility(const Board *b);
////////////* Utility function */
///////////
/*AIMoves **/int ai_threats(Board board[2][16],int depth,int branch,AIMoves moves[2][16]/*,index_array *index*/);
AIMoves *ai_priority(const Board *b);
/* Multi-level threats */



void my_srandom(int seed,unsigned int *current_random);
int my_irand(int imax,unsigned int current_random);
//void backup_move(Board *board, AIMoves *moves,AIMove *move);
//AIWEIGHT threat_line(int x, int y, int dx, int dy,Board *b,Board *bwrite,int k,int loop_bound);
//int threat_window(int x, int y, int dx, int dy,
//                         PIECE *ptype, int *pdouble,Board *b);
int connect6ai_synth(int firstmove,char movein[8], char colour, char moveout[8]);
//extern "C" AIMove pico_stream_input_queue();
//extern "C" void pico_stream_output_queue(AIMove);
//extern "C" AIMove pico_ips_fifo_read_queue();
//extern "C" void pico_ips_fifo_write_queue(AIMove);
//extern int id;
//extern int ready; 
typedef struct {
        PLAYER ai;
        //SEARCH search;
        int depth, branch, cache, tss;
} Player;
/*AIMoves **/int search(Board *board,AIMove *move, Player *player);
AIWEIGHT df_search(Board *b, AIMoves *moves,/*index_array *index,*/ Player *player,int depth, int cache_index,PIECE searched, AIWEIGHT alpha, AIWEIGHT beta);
#endif
