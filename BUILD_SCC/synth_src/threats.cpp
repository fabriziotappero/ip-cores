
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

//FIFO(x,int);
//#pragma fifo_length x 24
//#pragma no_inter_loop_stream_analysis pico_stream_input_x
//#pragma no_inter_loop_stream_analysis pico_stream_output_x
//#pragma no_inter_task_stream_analysis pico_stream_input_x
//#pragma no_inter_task_stream_analysis pico_stream_output_x
/*--------------------------------------------------------------------*/
#ifdef PICO_SYNTH
#define Q_ASSERT(_cond, _msg)
//#include <iostream>
//#include "pico.h"
//#include "q.hpp"
//#include "./shared.h"
using namespace std;
#else
/* not synthesizable */
#include <iostream>
#include <sstream>
#include <string>
#include <assert.h>

static void debug_assert (bool cond, char * msg) {
	if (!cond) {
		printf("assert failed: %s\n", msg);
		assert(0);
	}
}

#define Q_ASSERT(_cond, _msg) debug_assert(_cond, _msg)
#endif
#define max_size 361
#define ptr_bw 32
//FIFO(queue,AIMove);
//#pragma no_inter_loop_stream_analysis pico_stream_input_queue
//#pragma no_inter_loop_stream_analysis pico_stream_output_queue
//#pragma no_inter_task_stream_analysis pico_stream_input_queue
//#pragma no_inter_task_stream_analysis pico_stream_output_queue

//FIFO(queue,AIMove);
//FIFO_INTERFACE(queue,AIMove);
//#pragma fifo_length pico_stream_input_queue 800
//#pragma fifo_length pico_stream_output_queue 800
//#pragma read_write_port queue separate
//#pragma bandwidth pico_stream_input_queue 1
//#pragma bandwidth pico_stream_output_queue 1
//////template <class tp=AIMove, int max_size=128, int ptr_bw=32>
////
////  /* pop front of queue, returning the front data */
////  /* q is corrupted if pop when empty */
////  AIMove q::pop (){
////    /* assert that before pop, queue is not empty (underflow check) */
////    Q_ASSERT((!wrapped && (head < tail)) || (wrapped && (head >= tail)),
////    		"queue underflowed");
////    AIMove d = pico_stream_input_queue();
////	//cout <<"pop: "<<head<<":"<<tail<<":"<<wrapped<<endl;
////    if (head == max_size-1) {
////      head = 0;
////      wrapped = false;
////    } else {
////      head = head + 1;
////    }
////    return d;
////  }
////
////  /* push data into back of queue */
////  /* q is corrupted if push when full */
////   void q::push (AIMove d){
////    pico_stream_output_queue(d);
////    if (tail == max_size-1) {
////      tail = 0;
////      wrapped = true;
////    } else {
////      tail = tail + 1;
////    }
////    /* assert that after push, queue is not empty (overflow check) */
////    Q_ASSERT((!wrapped && (head < tail)) || (wrapped && (head >= tail)),
////    		"Queue overflowed") ;
////	//cout <<"push: "<<head<<":"<<tail<<":"<<wrapped<<endl;
////  }
////
////  /* return current size of the queue */
////  int q::size (){
////    if (wrapped) {
////      return (max_size - head) + (tail - 0);
////    } else {
////      return tail - head;
////    }
////  }
/////*--------------------------------------------------------------------*/
////void test(int ready){
////	int i;
////	//for (i=0;i<10;i++) if(ready>1) pico_stream_input_x(); 
////	//for (i=0;i<10;i++) {if(!moves_fifo1.empty()) moves_fifo1.pop(); }
////	AIMove m;
////	while(1) {
////		if(ready>1) m=pico_stream_input_queue(); 
////		if(m.weight==-1) break;
////	}
////}
////q moves_fifo1;

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
	#pragma unroll 
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
	#pragma unroll 
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
	//#pragma read_write_ports b.data separate 1 readonly 2 writeonly
	//#pragma no_memory_analysis b
	/* This is the line of threats currently being processed */
	Line line[board_size]={{1},{2}};
	#pragma internal_fast line
	//#pragma no_memory_analysis line
	/* Running tally of threats for both players */
	//static int threat_counts[MAX_CONNECT_K + 1][2];
	threat_count_array threat_counts={{0}};
	#pragma internal_fast threat_counts
	//#pragma read_write_ports threat_counts.data combined 2
	//#pragma no_memory_analysis threat_counts
        //if (k==1) board_copy(b, bwrite);
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

FIFO(queue,AIMove);
//FIFO_INTERFACE(queue,AIMove);
#pragma fifo_length pico_stream_input_queue 800
#pragma fifo_length pico_stream_output_queue 800
#pragma bandwidth pico_stream_input_queue 1
#pragma bandwidth pico_stream_output_queue 1
/*AIMoves*/int ai_threats(Board board[2][16],int depth,int branch,AIMoves moves[2][16]/*,index_array *index*/)
{
	//#pragma read_write_ports board.data combined 2
	//#pragma internal_blockram board
	//#pragma no_memory_analysis board

	//#pragma internal_blockram move
	//#pragma no_memory_analysis move
	index_array  index={0};
		#pragma internal_fast index
	
	/////////* All threat functions work on this board */
	/*static*/ Board b;//={0,0,0,0,0,0,0,0,0,0,0,{{0}}} ;//= NULL;
	//#pragma read_write_ports b.data combined 2
	#pragma internal_blockram b
	//#pragma multi_buffer b 2
	//#pragma read_write_ports b.data separate 1 readonly 2 writeonly
	//#pragma no_memory_analysis b
	/*static*/ Board bwrite;//={0,0,0,0,0,0,0,0,0,0,0,{{0}}} ;//= NULL;
	//#pragma read_write_ports b.data combined 2
	#pragma internal_blockram bwrite
	//#pragma multi_buffer bwrite 22
	//#pragma no_memory_analysis b
	///*static*/ AIMoves moves;//={0,0,0,{{0,0,0}}};
	//#pragma read_write_ports moves.data combined 3
	//#pragma internal_blockram moves
	//#pragma no_memory_analysis moves

	moves[depth][branch].len=0;
        //AIMoves moves;
        AIWEIGHT u_sum = 0;
        int i;

        //b = board_new();
	//Board b;
        board_copy(&board[depth][branch], &b);

        /* Clear threat tallys */
        //for (i = 0; i < connect_k; i++) {
        //        threat_counts.data[i][0] = 0;
        //        threat_counts.data[i][1] = 0;
        //}
/*---------------------------------------------------------------------------*/
       // /* Horizontal lines */
       // for (i = 0; i < board_size; i++)
       //         u_sum += threat_line(0, i, 1, 0,&b);

       // /* Vertical lines */
       // for (i = 0; i < board_size; i++)
       //         u_sum += threat_line(i, 0, 0, 1,&b);

       // /* SE diagonals */
       // for (i = 0; i < board_size - connect_k + 1; i++)
       //         u_sum += threat_line(i, 0, 1, 1,&b);
       // for (i = 1; i < board_size - connect_k + 1; i++)
       //         u_sum += threat_line(0, i, 1, 1,&b);

       // /* SW diagonals */
       // for (i = connect_k - 1; i < board_size; i++)
       //         u_sum += threat_line(i, 0, -1, 1,&b);
       // for (i = 1; i < board_size - connect_k + 1; i++)
       //         u_sum += threat_line(board_size - 1, i, -1, 1,&b);
/*---------------------------------------------------------------------------*/
//rewritten for hardware
/*---------------------------------------------------------------------------*/
	//int id= PICO_initialize_PPA(threat_line);	
	//PICO_set_task_overlap(id, 2);
	int j;
	int arg1,arg2,arg3,arg4,loop_bound,loop_begin;
	int k=0;
	for(j=0;j<6;j++){
			switch(j){
			case 0:
				{
				loop_begin=0;
				loop_bound=board_size;
				break;
				}
			case 1:
				{
				loop_begin=0;
				loop_bound=board_size;
				break;
				}
			case 2:
				{
				loop_begin=0;
				loop_bound=board_size-connect_k+1;
				break;
				}
			case 3:
				{
				loop_begin=1;
				loop_bound=board_size-connect_k+1;
				break;
				}
			case 4:
				{
				loop_begin=connect_k-1;
				loop_bound=board_size;
				break;
				}
			case 5:
				{
				loop_begin=1;
				loop_bound=board_size-connect_k+1;
				break;
				}
			default:{
				break;
				}
			}
        		for (i = loop_begin; i < loop_bound; i++){
				k++;
				switch(j){
				case 0:
					{
					arg1=0;
					arg2=i;	
					arg3=1;
					arg4=0;
					break;
					}
				case 1:
					{
					arg1=i;
					arg2=0;	
					arg3=0;
					arg4=1;
					break;
					}
				case 2:
					{
					arg1=i;
					arg2=0;	
					arg3=1;
					arg4=1;
					break;
					}
				case 3:
					{
					arg1=0;
					arg2=i;	
					arg3=1;
					arg4=1;
					break;
					}
				case 4:
					{
					arg1=i;
					arg2=0;	
					arg3=-1;
					arg4=1;
					break;
					}
				case 5:
					{
					arg1=board_size-1;
					arg2=i;	
					arg3=-1;
					arg4=1;
					break;
					}
				default:{
					break;
					}
				}


        			if (k==1) board_copy(&b, &bwrite);
                		u_sum += threat_line(arg1, arg2, arg3, arg4,&b,&bwrite,k,loop_bound);
			}
	}
	//PICO_sync_task(id, 1);
	//PICO_finalize_PPA(id);
/*---------------------------------------------------------------------------*/
	//board_copy(&b,&b_marks);
		//unsigned int index[max_size]={0};
		//#pragma bitsize index 9
		//#pragma internal_fast index
	AIMoves moves1;
	moves1.len=0;
	#pragma internal_blockram moves1
        /*moves = */ ai_marks(&bwrite, PIECE_THREAT(1),&moves1);
	//test(ready);
	streamsort(&moves[depth][branch],&index);
        moves1.utility = u_sum;
        moves[depth][branch].utility = u_sum;
	/*----------------------------
		rewritten for hardware
	----------------------------*/
	//if (!aimoves_choose(&moves1, move))
	//	return 0;
	//else return 1;		
	//int ret_val;
	//ret_val=aimoves_choose(&moves1, move,&index[0]);
	//if (!ret_val)
	//	return 0;
	//else return 1;		
	/*----------------------------
	end rewritten for hardware
	----------------------------*/
        //board_free(b);
        //return moves;
	return 1;
}

//void debug_counts(void)
//{
//        int i, sum = 0;
//
//        if (!b)
//                return;
//
//        g_debug("Threat counts (black, white):");
//        for (i = 1; i < connect_k; i++) {
//                g_debug("%d: %3d %3d", i, threat_counts[i][0],
//                        threat_counts[i][1]);
//                sum += threat_counts[i][0] * threat_bits(i, b->turn) -
//                       threat_counts[i][1] *
//                       threat_bits(i, other_player(b->turn));
//        }
//        if (sum > 0)
//                g_debug("Threat sum: %d (10^%.2f)", sum, log10((double)sum));
//        else if (sum < 0)
//                g_debug("Threat sum: %d (-10^%.2f)", sum, log10((double)-sum));
//        else
//                g_debug("Threat sum: 0");
//}

//static int threat_number(int player, int threat,threat_count_array threat_counts)
//{
//        return threat_counts.data[threat][player] / (connect_k - threat);
//}

//AIMoves *ai_priority(const Board *b)
//{
//        AIMoves *moves;
//        int i, j, stage[2] = {1, 1}, mask, bits;
//
//        moves = ai_threats(b);
//
//        /* Do not prioritize if we've won */
//        if (threat_counts[connect_k - place_p + 1][b->turn - 1]) {
//                moves->utility = AIW_WIN;
//                return moves;
//        }
//
//        /* Find the largest supported threat for each player */
//        for (i = 2; i < connect_k; i++) {
//                if (threat_number(0, i - 1) >= place_p &&
//                    threat_number(0, i) > place_p)
//                        stage[0] = i;
//                if (threat_number(1, i - 1) >= place_p &&
//                    threat_number(1, i) > place_p)
//                        stage[1] = i;
//        }
//
//        //if (opt_debug_stage)
//        //        g_debug("Stages %d/%d", stage[0], stage[1]);
//
//        /* Do not prioritize if we're losing */
//        if (stage[b->turn - 1] <= stage[other_player(b->turn) - 1]) {
//                moves->utility = -stage[other_player(b->turn) - 1];
//                return moves;
//        }
//
//        /* Threats above the player's stage are no more valuable than the
//           stage */
//        bits = 1 << (stage[b->turn - 1] * BITS_PER_THREAT);
//        mask = bits - 1;
//        for (i = 0; i < moves->len; i++) {
//                AIWEIGHT w = moves->data[i].weight, w2;
//
//                if (w < AIW_THREAT_MAX && w >= bits) {
//                        w2 = w & mask;
//                        w = w & ~mask;
//                        for (j = stage[b->turn - 1];
//                             w && j < connect_k - place_p + 1; j++) {
//                                w = w >> BITS_PER_THREAT;
//                                w2 += w & mask;
//                        }
//                        moves->data[i].weight = w2;
//                }
//        }
//
//        /* Stage determines weight */
//        moves->utility = stage[b->turn - 1];
//        return moves;
//}
/*AIMoves*/ void ai_marks(Board *b, PIECE minimum,AIMoves *moves)
{
	//#pragma read_write_ports b.data combined 2
	//#pragma internal_blockram b
	//#pragma no_memory_analysis b
        //AIMoves *moves = aimoves_new();
	//AIMoves moves;
        //AIMoves moves[361];
        AIMove move;
        PIECE p;
	//moves_fifo.resoet();
	AIMove m;
	#pragma num_iterations(19,19,19)
        for (move.y = 0; move.y < board_size; move.y++)
	#pragma num_iterations(19,19,19)
                for (move.x = 0; move.x < board_size; move.x++){
                        if ((p = piece_at(b, move.x, move.y)) >= minimum) {
                                move.weight = p - PIECE_THREAT0;
                                aimoves_set(moves, &move);
				pico_stream_output_queue(move);
				//cout<<"push"<<move.weight<<endl;
			//ready=ready+1;
			//cout<<"READY"<<*ready<<endl;
                        }else {
			m.weight =-100;
			pico_stream_output_queue(m);
				//cout<<"push"<<m.weight<<endl;
			}
			//if((move.y == board_size-1) && (move.x == board_size-1)){
			//	m.weight=-1;m.x=-1;m.y=-1;
                        //        /*if((ready))*/ {pico_stream_output_queue(m);/*cout<<"push_finish"<<m.weight<<endl;*/}
			//
			//}
		}
	//moves_fifo.active=0;
        //return moves;
	int i;
	//for (i=0;i<10;i++) {*ready=i;pico_stream_output_x(i); }
	//for (i=0;i<10;i++) {if(!moves_fifo1.full()) moves_fifo1.push(m); }
	//for (i=0;i<10;i++) {
	//	*ready=i;pico_stream_output_queue(m); 
	//	if(i==9){
	//		m.weight=-1;
	//		pico_stream_output_queue(m);
	//	}
	//		
	//	}
	
}
void streamsort(AIMoves *moves,index_array *index){
/* Insertion sort for streaming*/
		AIMove val;
		AIMove data[361]={{-1},{-1},{-1}};
		//unsigned int index[361];
		//#pragma bitsize index 9
		//#pragma internal_fast index
		int i,j,k;
		unsigned int len=0;
		moves->data[0].weight=-100;
//		while(1) {
//			if(!moves_fifo.empty()){ 
//				val=moves_fifo.pop();
//				for(i=0;i<len;i++){
//					if (list[i].weight < val.weight){
//					for(j=len-1;j>i-1;j--){
//						list[j+1]=list[j];
//					}
//					break;
//					}
//				}
//					list[i]=val;
//					len++;
//			}
//			else break;
//			//if(!moves_fifo.active && moves_fifo.empty()) break;
//		}
		//while(1) {
		//int count=0;
		#pragma num_iterations(1,150,368)
		for(k=0;k<368;k++){
			//count++;
			//cout<<count<<endl;
			if (k>6){
				
			//if(ready>5){ 
				val=pico_stream_input_queue();
				//cout<<"popped"<<","<<val.weight<<" "<<val.x<<" "<<val.y<<endl;
				if(val.weight==-1) {moves->len=len;break;}
				else if(val.weight==-100) continue;
				#pragma num_iterations(0,150,361)
				for(i=0;i<len;i++){
					if (moves->data[i].weight < val.weight){
					for(j=len-1;j>i-1;j--){
						moves->data[j+1]=moves->data[j];
						//index[j+1]=index[j];
					}
					break;
					}
				}
					index->data[i]=len;
					moves->data[i]=val;
					len++;
				//cout<<"STREAMSORT"<<":";
			//}
			/*else*/ //{moves->len=len;break;}
			}
		}
		moves->len=len;
				//cout<<"STREAMSORT"<<":"<<moves->len<<endl;
				//for(i=0;i<len;i++) cout<<moves->data[i].weight<<",";
				//cout<<endl;
				//for(i=0;i<len;i++) cout<<moves->data[index[i]].weight<<",";
				//cout<<endl;
}
static gboolean is_adjacent( Board *b, BCOORD x, BCOORD y, int dist)
{
        int dx, dy, count;
	#pragma bitsize dx 4
	#pragma bitsize dy 4
        PIECE p;

        if (!piece_empty(piece_at(b, x, y)))
                return FALSE;
        for (dy = -1; dy < 2; dy++)
                for (dx = -1; dx < 2; dx++) {
                        if (!dx && !dy)
                                continue;
                        count = count_pieces(b, x, y, PIECE_NONE, dx, dy, &p);
                        if (count - 1 < dist && p != PIECE_NONE)
                                return TRUE;
                }
        return FALSE;
}
/*AIMoves **/ void enum_adjacent(Board *b, int dist,AIMoves *moves,unsigned int current_random)
{
        //AIMoves *moves;
        AIMove move;

        move.weight = AIW_NONE;
        //moves = aimoves_new();
	#pragma num_iterations(1,9,19)
        for (move.y = 0; move.y < board_size; move.y++){
	#pragma num_iterations(1,9,19)
                for (move.x = 0; move.x < board_size; move.x++){
                        if (is_adjacent(b, move.x, move.y, dist))
                                aimoves_append(moves, &move);
		}
	}
        //aimoves_shuffle(moves,current_random);
        //return moves;
}
/*AIMoves **/void ai_adjacent( Board *b, AIMove *move,unsigned int current_random)
{
	//#pragma read_write_ports board.data combined 2
	#pragma internal_blockram b
	//#pragma no_memory_analysis b
	
	/*static*/ AIMoves moves;//={{0,0,0,{{0,0,0}}}};
	//#pragma read_write_ports moves.data combined 3
	#pragma internal_blockram moves
	//#pragma no_memory_analysis moves
	//#pragma read_write_ports moves.data combined 3
	//#pragma internal_blockram moves
	//#pragma no_memory_analysis moves
        //AIMove move;
	index_array  index={0};
        //AIMoves *moves;
	moves.len=0;
        /* Get all open tiles adjacent to any piece */
        /*moves =*/ enum_adjacent(b, 1,&moves,current_random);
        if (moves.len){
        	aimoves_choose(&moves, move/*,&index*/);
		
                return ;//moves;
	}
        /* Play in the middle if there are no open adjacent tiles */
        move->x = board_size / 2;
        move->y = board_size / 2;
        move->weight = AIW_NONE;
        //aimoves_append(&moves, move);
        //aimoves_choose(&moves, move);
        //return moves;
}
