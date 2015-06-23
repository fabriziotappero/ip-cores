
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

//#include "config.h"
//#include <math.h>
//#include <glib->h>
//#include <iostream>
#include "./shared.h"
//#include "./q.hpp"
#include "pico.h"
//#include <stdio.h>

/* Bits per threat level */
#define BITS_PER_THREAT 6


//FIFO_INTERFACE(queue,AIMove);
static AIWEIGHT threat_bits(int threat, PIECE type, Board *b)
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

static void threat_mark(int i, int threat, PIECE type,Board *b,Line *line)
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

int threat_window(int x, int y, int dx, int dy,
                         PIECE *ptype, int *pdouble,Board *b)
{
        int minimum, maximum, count = 0;
        PIECE p, type = PIECE_NONE;

        /* Check if this tile is empty */
        p = piece_at(b, x, y);
        if (!piece_empty(p))
                return 0;

        /* Push forward the maximum and find the window type */
	//#pragma unroll
	#pragma num_iterations(1,3,6)
        for (maximum = 1; maximum < connect_k; maximum++) {
                p = piece_at(b, x + dx * maximum, y + dy * maximum);
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
        maximum--;

        /* Try to push the entire window back */
	//#pragma unroll
	#pragma num_iterations(1,3,6)
        for (minimum = -1; minimum > -connect_k; minimum--) {
                p = piece_at(b, x + dx * minimum, y + dy * minimum);
                if (p == PIECE_ERROR || piece_empty(p))
                        break;
                if (type == PIECE_NONE)
                        type = p;
                else if (type != p)
                        break;
                if (maximum - minimum > connect_k - 1) {
                        p = piece_at(b, x + dx * maximum, y + dy * maximum);
                        if (p == type)
                                count--;
                        maximum--;
                }
                count++;
        }
        minimum++;

        /* Push back minimum if we haven't formed a complete window, this window
           can't be a double */
        if (maximum - minimum < connect_k - 1) {
	//#pragma unroll
	#pragma num_iterations(1,3,6)
                for (minimum--; minimum > maximum - connect_k; minimum--) {
                        p = piece_at(b, x + dx * minimum, y + dy * minimum);
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
                minimum++;
        }

        *ptype = type;
        if (maximum - minimum >= connect_k - 1)
                return count;
        return 0;
}

/*static*/ AIWEIGHT threat_line(int x, int y, int dx, int dy,Board *b,Board *bwrite,int k,int loop_bound)
{
	
	//#pragma read_write_ports threat_counts.data combined 2
	//#pragma internal_blockram threat_counts
	//#pragma no_memory_analysis threat_counts
	
	//#pragma read_write_ports b.data combined 2
	//#pragma internal_blockram b
	//#pragma internal_blockram bwrite
	//#pragma read_write_ports b.data separate 1 readonly 2 writeonly
	//#pragma no_memory_analysis b
	/* This is the line of threats currently being processed */
	Line line[board_size]={{1},{2}};
	#pragma internal_fast line
	//#pragma multi_buffer line 2
	//#pragma no_memory_analysis line
	/* Running tally of threats for both players */
	//static int threat_counts[MAX_CONNECT_K + 1][2];
	threat_count_array threat_counts={{0}};
	#pragma internal_fast threat_counts
	//#pragma multi_buffer threat_counts 2
	//#pragma read_write_ports threat_counts.data combined 2
	//#pragma no_memory_analysis threat_counts
	static Board btmp;
	#pragma internal_blockram btmp
	//#pragma multi_buffer btmp 2
        if (k==1) board_copy(b, bwrite);
        //if (k==loop_bound) board_copy(&btmp, bwrite);
        int i;
        AIWEIGHT weight = 0;
        ///* Clear threat tallys */
        //for (i = 0; i < connect_k; i++) {
        //        threat_counts.data[i][0] = 1;
        //        threat_counts.data[i][1] = 1;
        //}

        /* Mark the maximum threat for each */
        for (i = 0; x >= 0 && x < board_size && y >= 0 && y < board_size; i++) {
                int count[2], tmp, double_threat = 1;
                PIECE type[2];

                count[0] = threat_window(x, y, dx, dy, type, &double_threat,bwrite);
                count[1] = threat_window(x, y, -dx, -dy, type + 1,
                                         &double_threat,bwrite);
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
                threat_mark(i, count[0], type[0],bwrite,&line[0]);
                if (double_threat)
                        threat_mark(i, count[1], type[1],bwrite,&line[0]);
                x += dx;
                y += dy;
        }

        /* Commit stored line values to the board */
        x -= dx;
        y -= dy;
        for (i--; x >= 0 && x < board_size && y >= 0 && y < board_size; i--) {
                AIWEIGHT bits[2];
                PIECE p;

                bits[0] = threat_bits(line[i].threat[0], line[i].turn[0],bwrite);
                bits[1] = threat_bits(line[i].threat[1], line[i].turn[1],bwrite);
                p = piece_at(bwrite, x, y);
                if (piece_empty(p) && line[i].threat[0]) {
                        threat_counts.data[line[i].threat[0]][line[i].turn[0] - 1]++;
                        if (line[i].threat[1])
                                threat_counts.data[line[i].threat[1]]
                                             [line[i].turn[1] - 1]++;
                        if (p >= PIECE_THREAT0)
                                place_threat(bwrite, x, y, p - PIECE_THREAT0 +
                                             bits[0] + bits[1]);
                        else
                                place_threat(bwrite, x, y, bits[0] + bits[1]);
                }
                if (bwrite->turn != line[i].turn[0])
                        bits[0] = -bits[0];
                if (bwrite->turn != line[i].turn[1])
                        bits[1] = -bits[1];
                weight += bits[0] + bits[1];
                x -= dx;
                y -= dy;
        }
        return weight;
}

