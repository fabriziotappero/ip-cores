/*
   connect6.cpp
   June 9, 2011
   This file contains the game AI
   By Kevin Nam

 */

//#include <time.h>
//#include <stdlib.h>
//
//#include "util.h"
//#include "connect6.h"
//#include<stdio.h>
#include "./shared.h"
//#ifdef PICO_SYSC_SIM
#include "pico.h"
//#endif

// Subtract this many points for moves at the edges.
#define EDGEPENALTY 5

using namespace std;

/*  The cost function simply counts all of the consecutive stones of same colour in
    every direction from the spot for which the points is being calculated.

Ex:

.DDLL
.DLDD
DXDDD
...D.

Above, X is the spot being calculated.
The points would be 2 (above) + 2(topright) + 3(right) + 1 (left) = 8.
It treats opponent's stones and own stones with equal weighting.

Return 0 if the spot y,x is already taken, else return the calculated value

 */
void move_to_ascii(int x,int y, char *move){
    if (y >= 10){
        move[0] = '1';
        y -= 10;
    } else {
        move[0] = '0';
    }
    if      (y == 0) move[1] = '0';
    else if (y == 1) move[1] = '1';
    else if (y == 2) move[1] = '2';
    else if (y == 3) move[1] = '3';
    else if (y == 4) move[1] = '4';
    else if (y == 5) move[1] = '5';
    else if (y == 6) move[1] = '6';
    else if (y == 7) move[1] = '7';
    else if (y == 8) move[1] = '8';
    else if (y == 9) move[1] = '9';

    // Do same for x.
    if (x >= 10){
        move[2] = '1';
        x -= 10;
    } else {
        move[2] = '0';
    }
    if      (x == 0) move[3] = '0';
    else if (x == 1) move[3] = '1';
    else if (x == 2) move[3] = '2';
    else if (x == 3) move[3] = '3';
    else if (x == 4) move[3] = '4';
    else if (x == 5) move[3] = '5';
    else if (x == 6) move[3] = '6';
    else if (x == 7) move[3] = '7';
    else if (x == 8) move[3] = '8';
    else if (x == 9) move[3] = '9';

}

static int char_to_int(short x){
	if(x>=48)
		return x-48;
	else 
		return 0;
}


/*
   The AI Function that calls the cost function for every spot on the board.
   It returns the location with the highest points. In the event of a tie, randomly decide.
   Input the board and the colour being played.
   Puts the move (in ASCII chars) inside move[4]. This is from [1 ... 19]
   Puts the move (in integers) in moveY and moveX. This is from [0 ... 18]
 */
//void backup_move(Board *board, AIMoves *moves,AIMove *move){
////when the threat doesn't return any good move
////put in a single function to parition and speedup synthesis
//	//#pragma read_write_ports board.data combined 2
//	//#pragma internal_blockram myboard
//	//#pragma no_memory_analysis myboard
//	//#pragma read_write_ports moves.data combined 3
//	//#pragma internal_blockram moves
//	//#pragma no_memory_analysis moves
//			move->x=-1;
//			move->y=-1;
//                        if (!aimoves_choose(moves, move)) {
//                               // aimoves_free(moves);
//				//moves->len=0;
//                            //    /*moves = */ai_adjacent(board,moves);
//                                aimoves_choose(moves, move);
//                        }
//}
int id;
int connect6ai_synth(int firstmove,char movein[8], char colour, char moveout[8]){
	//#ifdef PICO_SYSC_SIM
	//id= PICO_initialize_PPA(ai_threats);	
	//PICO_set_task_overlap(id, 2);
	//#endif
	#pragma bitsize firstmove 17
	char moveoutm[8];
	#pragma internal_blockram moveoutm
	short x,y,highx = 0;
	//Board *myboard ;
	static Board myboard;//={0,0,0,0,0,0,0,0,0,0,0,{{0}}};
	//#pragma read_write_ports board.data combined 2
	//#pragma preserve_array myboard.data 
	#pragma internal_blockram myboard
	//#pragma multi_buffer myboard 2
	//#pragma no_memory_analysis myboard
	static unsigned int current_random = 10;
	AIMove move,move_threat,move_adj;
	//#pragma internal_blockram move
	//#pragma no_memory_analysis move
	if(firstmove==0||firstmove==1) {
			//my_srandom(1,&current_random);
			new_game(&myboard,board_size);
	}
	if(firstmove==0) myboard.moves_left=1;
	else myboard.moves_left=2;
	
	//-------------------------------------------------------------------------
	if((firstmove >= 1)){
		//update the board
		y = char_to_int(movein[0])*10 + char_to_int(movein[1]) - 1;
		x = char_to_int(movein[2])*10 + char_to_int(movein[3]) - 1;
		if(colour==68){//'D')
			//myboard[y][x] = (char)2;//76;//'L';
	place_piece_type(&myboard,x,y,PIECE_WHITE);
	myboard.turn=PIECE_BLACK;
		}else{
			//board[y][x] = (char)1;//68;//'D';
	place_piece_type(&myboard,x,y,PIECE_BLACK);
	myboard.turn=PIECE_WHITE;
		}
	}
	if((firstmove >=3)){
		//update the board
		y = char_to_int(movein[4])*10 + char_to_int(movein[5]) - 1;
		x = char_to_int(movein[6])*10 + char_to_int(movein[7]) - 1;
		if(colour==68){//'D')
			//board[y][x] = (char)2;//76;//'L';
	place_piece_type(&myboard,x,y,PIECE_WHITE);
	myboard.turn=PIECE_BLACK;
		}else{
			//board[y][x] = (char)1;//68;//'D';
	place_piece_type(&myboard,x,y,PIECE_BLACK);
	myboard.turn=PIECE_WHITE;
		}
	}
	int i;
	#pragma bitsize i 6

	//#pragma num_iterations(1,2,2)
	//#pragma unroll
	Player player;
	player.depth=2;
	player.branch=2;
	for(i=myboard.moves_left;i>0;i--){
        	  //aimoves_free(&moves);
			move.x=-1;
			move.y=-1;
			
                       	if (!search(&myboard,&move_threat,&player)){ 
                                //aimoves_free(&moves);
				//moves.len=0;
                                ai_adjacent(&myboard,&move_adj,current_random);
				move.x=move_adj.x;
				move.y=move_adj.y;
			}else{
				move.x=move_threat.x;
				move.y=move_threat.y;
			}
                        
			//backup_move(&myboard,&moves,&move);
	//printf("DEBUG1:%d ",move.x);
	// Modify the board based on current move.
	place_piece_type(&myboard,move.x,move.y,myboard.turn);
	/// Convert the int coordinates to corresponding ASCII chars
	
	//if(firstmove==0)
	//move_to_ascii(move.x+1,move.y+1,&moveout[0]);		
	//else if(myboard.moves_left==2)
	//move_to_ascii(move.x+1,move.y+1,&moveout[0]);		
	//else
	//move_to_ascii(move.x+1,move.y+1,&moveout[4]);		
	if(firstmove==0)
	move_to_ascii(move.x+1,move.y+1,&moveoutm[0]);		
	else
	move_to_ascii(move.x+1,move.y+1,&moveoutm[8-4*i]);		
	myboard.moves_left--;
	}
	if(firstmove==0){
	#pragma unroll
	for(i=0;i<4;i++)
		moveout[i]=moveoutm[i];
	}else{
	#pragma unroll
	for(i=0;i<8;i++)
		moveout[i]=moveoutm[i];
	}
	//if(firstmove==0){
	//moveout[0]=moveoutm[0];
	//moveout[1]=moveoutm[1];
	//moveout[2]=moveoutm[2];
	//moveout[3]=moveoutm[3];
	//}else{
	//moveout[0]=moveoutm[0];
	//moveout[1]=moveoutm[1];
	//moveout[2]=moveoutm[2];
	//moveout[3]=moveoutm[3];
	//moveout[4]=moveoutm[4];
	//moveout[5]=moveoutm[5];
	//moveout[6]=moveoutm[6];
	//moveout[7]=moveoutm[7];
	//}

	////-------------------------------------------------------------------------
	//if(firstmove>=1){
        ////aimoves_free(&moves);
	//moves.len=0;
	//myboard.moves_left=1;
	///*moves=*/ai_threats(&myboard,&moves);
	//		move.x=-1;
	//		move.y=-1;
        //                if (!aimoves_choose(&moves, &move)) {
        //                        //aimoves_free(&moves);
	//			moves.len=0;
        //                        /*moves = */ai_adjacent(&myboard,&moves);
        //                        aimoves_choose(&moves, &move);
        //                }
	//		//backup_move(&myboard,&moves,&move);
	////printf("DEBUG2%d\n",move.x);
	//// Modify the board based on current move.
	//place_piece_type(&myboard,move.x,move.y,myboard.turn);
	//
	//	/// Convert the int coordinates to corresponding ASCII chars
	//move_to_ascii(move.x+1,move.y+1,&moveout[4]);		
	//}
	//#ifdef PICO_SYSC_SIM
	//PICO_sync_task(id, 1);
	//PICO_finalize_PPA(id);
	//#endif
	return 0;
}



