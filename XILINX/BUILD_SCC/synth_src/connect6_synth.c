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
#include "./shared.h"

// Subtract this many points for moves at the edges.
#define EDGEPENALTY 5


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
int connect6ai_synth(int firstmove,char movein[8], char colour, char moveout[8]){
	#pragma bitsize firstmove 17
	short x,y,highx = 0;
	Board *myboard ;
	AIMoves *moves;
	//-------------------------------------------------------------------------
	if((firstmove >= 1)){
		//update the board
		y = char_to_int(movein[0])*10 + char_to_int(movein[1]) - 1;
		x = char_to_int(movein[2])*10 + char_to_int(movein[3]) - 1;
		if(colour==68){//'D')
			//myboard[y][x] = (char)2;//76;//'L';
	place_piece_type(myboard,x,y,PIECE_WHITE);
	myboard->turn=PIECE_BLACK;
		}else{
			//myboard[y][x] = (char)1;//68;//'D';
	place_piece_type(myboard,x,y,PIECE_BLACK);
	myboard->turn=PIECE_WHITE;
		}
	}
	if((firstmove >=3)){
		//update the board
		y = char_to_int(movein[4])*10 + char_to_int(movein[5]) - 1;
		x = char_to_int(movein[6])*10 + char_to_int(movein[7]) - 1;
		if(colour==68){//'D')
			//myboard[y][x] = (char)2;//76;//'L';
	place_piece_type(myboard,x,y,PIECE_WHITE);
	myboard->turn=PIECE_BLACK;
		}else{
			//myboard[y][x] = (char)1;//68;//'D';
	place_piece_type(myboard,x,y,PIECE_BLACK);
	myboard->turn=PIECE_WHITE;
		}
	}
	moves=ai_threats(myboard);
	// Modify the myboard based on current move.
	place_piece_type(myboard,moves->data[1].x,moves->data[1].y,myboard->turn);
	/// Convert the int coordinates to corresponding ASCII chars
	
	move_to_ascii(moves->data[1].x+1,moves->data[1].y+1,moveout);		


	//-------------------------------------------------------------------------
	if(firstmove>=1){
	moves=ai_threats(myboard);
	// Modify the myboard based on current move.
	place_piece_type(myboard,moves->data[1].x,moves->data[1].y,myboard->turn);
	
		/// Convert the int coordinates to corresponding ASCII chars
	move_to_ascii(moves->data[1].x+1,moves->data[1].y+1,&moveout[4]);		
	}
	return 0;
}



