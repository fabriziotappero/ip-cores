
/*

connectk -- UMN CSci 5512W project

*/

#include "config.h"
#include <string.h>
#include <glib.h>
#include "../shared.h"
#include "../connectk.h"

/* Variables required to check for cache hits */
static int cache_id = -1, cache_depth = -1, cache_branch = -1;
static SEARCH cache_search = -1;
static AIMoves *cache_moves = NULL;
static AIWEIGHT cache_best;
static Player *cache_player;
static AIFunc cache_func;
static BCOORD cache_size;

void dfs_cache_dump(void)
/* Called from tests.c to print out the DFS cache */
{
        g_debug("DFS cache: ");
        aimoves_print(cache_moves);
        g_print("\n");
}

static void cache_set(int index, AIMove *move)
{
        if (move->weight < cache_best || index > place_p)
                return;
        if (cache_moves->len <= index)
                cache_moves->len = index + 1;
        cache_moves->data[index] = *move;
        cache_best = move->weight;
}

static AIWEIGHT df_search(Board *b, AIMoves *moves, Player *player,
                          int depth, int cache_index,
                          PIECE searched, AIWEIGHT alpha, AIWEIGHT beta)
/* Depth is in _moves_ */
{
        int i, j;

        /* Halt and depth abort */
        if (ai_stop || depth < 1)
                return moves->utility;

        /* Alpha-beta sanity check */
        if (alpha >= beta) {
                g_warning("DFS alpha-beta failed sanity check");
                return moves->utility;
        }

        /* Search only the top moves beyond the minimum */
        aimoves_sort(moves);
        if (moves->len > player->branch) {
                for (i = player->branch; i < moves->len; i++)
                        if (moves->data[i].weight != moves->data[0].weight)
                                break;
                moves->len = i;
        }

        /* No moves left -- its a draw */
        if (moves->len < 1)
                return AIW_DRAW;

        /* Search each move available in depth first order */
        for (i = 0; i < moves->len; i++) {
                Board *b_next;
                AIMove *aim = moves->data + i;
                AIMoves *moves_next;

                /* Did we get a bad move? */
                if (!piece_empty(piece_at(b, aim->x, aim->y))) {
                        g_warning("DFS utility function suggested a bad move "
                                  "(%s)", bcoords_to_string(aim->x, aim->y));
                        continue;
                }

                /* Already searched here? */
                if (piece_at(b, aim->x, aim->y) == searched)
                        continue;
                place_piece_type(b, aim->x, aim->y, searched);

                b_next = board_new();
                board_copy(b, b_next);
                place_piece(b_next, aim->x, aim->y);

                /* Did we win? */
                if (check_win(b_next, aim->x, aim->y))
                        aim->weight = AIW_WIN;

                /* Otherwise, search deeper */
                else  {
                        int next_ci = cache_index + 1;
                        AIWEIGHT next_alpha = alpha, next_beta = beta;
                        AIFunc func;

                        b_next->moves_left--;

                        /* Player has changed */
                        if (b_next->moves_left <= 0) {
                                b_next->moves_left = place_p;
                                b_next->turn = other_player(b->turn);
                                next_ci += place_p;
                                searched++;
                                next_alpha = -beta;
                                next_beta = -alpha;
                        }

                        func = ai(player->ai)->func;
                        if (!func) {
                                g_warning("DFS player has no AI function");
                                return moves->utility;
                        }
                        moves_next = func(b_next);
                        aim->weight = df_search(b_next, moves_next, player,
                                                depth - 1, next_ci, searched,
                                                next_alpha, next_beta);
                        aimoves_free(moves_next);
                        if (b_next->turn != b->turn)
                                aim->weight = -aim->weight;
                }

                /* Debug search */
                if (opt_debug_dfsc) {
                        for(j = MAX_DEPTH - depth; j > 0; j--)
                                g_print("-");
                        g_print("> d=%d, %s, u=%d, a=%d, b=%d %s\n",
                                depth, bcoords_to_string(aim->x, aim->y),
                                aim->weight, alpha, beta,
                                piece_to_string(b->turn));
                }

                board_free(b_next);
                if (aim->weight > alpha) {
                        alpha = aim->weight;
                        cache_set(cache_index, aim);

                        /* Victory abort */
                        if (alpha >= AIW_WIN)
                                return AIW_WIN;

                        /* Alpha-beta pruning */
                        if (alpha >= beta)
                                return alpha;
                }
        }

        return alpha;
}

void search(const Board *b, AIMoves *moves, Player *player)
{
        Board *copy;
        AIFunc move_func = ai(player->ai)->func;

        /* Player is not configured to search */
        if (player->search == SEARCH_NONE)
                return;

        /* Moves list does not need to be searched */
        if (moves->len <= b->moves_left) {
                if (opt_debug_dfsc)
                        g_debug("DFS no choice abort");
                return;
        }

        /* Board size changed, cache is invalidated */
        if (board_size != cache_size)
                cache_moves = NULL;
        cache_size = board_size;

        /* Cache hit, last or same board */
        if (player->cache && cache_moves && cache_moves->len &&
            cache_search == player->search &&
            cache_depth == player->depth &&
            cache_player == player &&
            cache_func == move_func &&
            cache_branch == player->branch) {
                if (b->parent && cache_id == b->parent->ac.id) {
                        aimoves_remove(cache_moves, b->parent->move_x,
                                       b->parent->move_y);
                        cache_id = b->ac.id;
                }
                if (cache_id == b->ac.id && cache_moves->len) {
                        if (cache_moves->len) {
                                aimoves_copy(cache_moves, moves);
                                if (opt_debug_dfsc)
                                        g_debug("DFS cache HIT");
                                return;
                        }
                        aimoves_free(cache_moves);
                        cache_moves = NULL;
                }
        }

        /* Cache miss */
        if (opt_debug_dfsc)
                g_debug("DFS cache MISS");
        cache_id = b->ac.id;
        if (!cache_moves)
                cache_moves = aimoves_new();
        cache_moves->len = 0;
        cache_best = AIW_MIN;
        copy = board_new();
        board_copy(b, copy);
        if (player->search == SEARCH_DFS) {
                df_search(copy, moves, player, player->depth, 0,
                          PIECE_SEARCHED, AIW_LOSE, AIW_WIN);
                if (cache_moves->len)
                        aimoves_copy(cache_moves, moves);
        } else {
                board_free(copy);
                g_warning("Unsupported search type %d", player->search);
                return;
        }
        board_free(copy);

        /* Debug DFS search */
        if (opt_debug_dfsc)
                dfs_cache_dump();

        /* Save params so we can check if we have a hit later */
        cache_player = player;
        cache_search = player->search;
        cache_depth = player->depth;
        cache_branch = player->branch;
        cache_func = move_func;
}
