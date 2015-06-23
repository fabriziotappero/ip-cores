



typedef int PIECE;

typedef struct Board {
        AllocChain ac;
        /* Allocation chain must be the first member */

        unsigned int moves_left;
        /* How many moves the current player has left */

        struct Board *parent;
        /* The board preceeding this one in history */

        gboolean won;
        BCOORD win_x1, win_y1, win_x2, win_y2;
        /* On won boards, used to indicate where the winning line is */

        PIECE turn;
        /* Whose turn it is on this board */

        BCOORD move_x, move_y;
        /* The move to the next Board in history */

        PIECE data[];
} Board;
/* The board structure represents the state of the game board. Do NOT preserve
   board pointers across games. */
