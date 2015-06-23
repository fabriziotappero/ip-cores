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
	static int char_to_int(short x){
		if(x>=48)
			return x-48;
		else 
			return 0;
	}

static int calculatepoints_synth(unsigned char board[19][19], short y, short x, char colour8){
	#pragma bitsize x 6
	#pragma bitsize y 6
	short pts = 0, tempx = x, tempy = y, tcount = 0,bcount = 0;
	#pragma bitsize pts 8
	#pragma bitsize tempx 6
	#pragma bitsize tempy 6
	#pragma bitsize tcount 3
	#pragma bitsize bcount 3
	
	char lcount = 0,rcount = 0,trcount = 0,tlcount = 0,brcount = 0,blcount = 0;
	#pragma bitsize rcount 3
	#pragma bitsize lcount 3
	#pragma bitsize trcount 3
	#pragma bitsize tlcount 3
	#pragma bitsize brcount 3
	#pragma bitsize blcount 3
	char tcolour = 0,bcolour = 0,lcolour = 0,rcolour = 0,tlcolour = 0,trcolour = 0,brcolour = 0,blcolour = 0;
	#pragma bitsize rcolour 2
	#pragma bitsize lcolour 2
	#pragma bitsize trcolour 2
	#pragma bitsize tlcolour 2
	#pragma bitsize brcolour 2
	#pragma bitsize blcolour 2
	unsigned char colour;
	#pragma bitsize colour 2
	colour= (colour8==68) ? 1 : 2;

	if (board[y][x] != 0)
		return 0;

	// scan column above
	if (y > 0){
		tempy = y-1;
		tempx = x;
		tcolour = board[tempy][tempx];
		for(tempy=y-1;tempy > y-6;tempy--){
			if (tempy == 0) break;
			if (board[tempy][tempx] != tcolour || board[tempy][tempx] == 0) break;
			tcount++;
		}
	}

	//    // scan column above
	//    if (y > 0){
	//        tempy = y-1;
	//        tempx = x;
	//        tcolour = board[tempy][tempx];
	//        while (1){
	//            if (board[tempy][tempx] != tcolour || board[tempy][tempx] == 0) break;
	//            tcount++;
	//            if (tempy == 0) break;
	//            tempy--;
	//        }
	//    }
	// scan column below
	if (y < 18){
		tempy = y+1;
		tempx = x;
		bcolour = board[tempy][tempx];
		for(tempy=y+1;tempy < y+6;tempy++){
			if (tempy == 18) break;
			if (board[tempy][tempx] != bcolour || board[tempy][tempx] == 0) break;
			bcount++;
		}
	}
	//    // scan column below
	//    if (y < 18){
	//        tempy = y+1;
	//        tempx = x;
	//        bcolour = board[tempy][tempx];
	//        while (1){
	//            if (board[tempy][tempx] != bcolour || board[tempy][tempx] == 0) break;
	//            bcount++;
	//            if (tempy == 18) break;
	//            tempy++;
	//        }
	//    }
	// scan row to left
	if (x > 0){
		tempy = y;
		tempx = x-1;
		lcolour = board[tempy][tempx];
		for(tempx=x-1;tempx > x-6;tempx--){
			if (tempx == 0) break;
			if (board[tempy][tempx] != lcolour || board[tempy][tempx] == 0) break;
			lcount++;
		}
	}
	//    // scan row to left
	//    if (x > 0){
	//        tempy = y;
	//        tempx = x-1;
	//        lcolour = board[tempy][tempx];
	//        while (1){
	//            if (board[tempy][tempx] != lcolour || board[tempy][tempx] == 0) break;
	//            lcount++;
	//            if (tempx == 0) break;
	//            tempx--;
	//        }
	//    }
	// scan row to right
	if (x < 18){
		tempy = y;
		tempx = x+1;
		rcolour = board[tempy][tempx];
		for(tempx=x+1;tempx < x+6;tempx++){
			if (tempx == 18) break;
			if (board[tempy][tempx] != rcolour || board[tempy][tempx] == 0) break;
			rcount++;
		}
	}
	//    // scan row to right
	//    if (x < 18){
	//        tempy = y;
	//        tempx = x+1;
	//        rcolour = board[tempy][tempx];
	//        while (1){
	//            if (board[tempy][tempx] != rcolour || board[tempy][tempx] == 0) break;
	//            rcount++;
	//            if (tempx == 18) break;
	//            tempx++;
	//        }
	//    }
	// scan diagonal topleft
	if (x > 0 && y > 0){
		tempy = y-1;
		tempx = x-1;
		tlcolour = board[tempy][tempx];
		while ((tempx > x-6) && (tempy > y-6)){
			if (tempx == 0 || tempy == 0) break;
			if (board[tempy][tempx] != tlcolour || board[tempy][tempx] == 0) break;
			tlcount++;
			tempx--;
			tempy--;
		}
	}
	// scan diagonal bottomright
	if (x < 18 && y < 18){
		tempy = y+1;
		tempx = x+1;
		brcolour = board[tempy][tempx];
		while ((tempx < x+6) && (tempy < y+6)){
			if (tempx == 18 || tempy == 18) break;
			if (board[tempy][tempx] != brcolour || board[tempy][tempx] == 0) break;
			brcount++;
			tempx++;
			tempy++;
		}
	}
	// scan diagonal topright
	if (x < 18 && y > 0){
		tempy = y-1;
		tempx = x+1;
		trcolour = board[tempy][tempx];
		while ((tempx < x+6) && (tempy > y-6)){
			if (tempx == 18 || tempy == 0) break;
			if (board[tempy][tempx] != trcolour || board[tempy][tempx] == 0) break;
			trcount++;
			tempx++;
			tempy--;
		}
	}
	// scan diagonal bottomleft
	if (y < 18 && x > 0){
		tempy = y+1;
		tempx = x-1;
		blcolour = board[tempy][tempx];
		while ((tempx > x-6) && (tempy < y+6)){
			if (tempy == 18 || tempx == 0) break;
			if (board[tempy][tempx] != blcolour || board[tempy][tempx] == 0) break;
			blcount++;
			tempy++;
			tempx--;
		}
	}

	/// Now calculate the points
	// Check if this is a winning move. Priority #1.
	if ((tcount >= 5 && tcolour == colour) ||
			(bcount >= 5 && bcolour == colour) ||
			(lcount >= 5 && lcolour == colour) ||
			(rcount >= 5 && rcolour == colour) ||
			(tlcount >= 5 && tlcolour == colour) ||
			(trcount >= 5 && trcolour == colour) ||
			(brcount >= 5 && brcolour == colour) ||
			(blcount >= 5 && blcolour == colour) ||
			(tcount + bcount >= 5 && tcolour == colour && bcolour == colour) ||
			(lcount + rcount >= 5 && lcolour == colour && rcolour == colour) ||
			(tlcount + brcount >= 5 && tlcolour == colour && brcolour == colour) ||
			(trcount + blcount >= 5 && trcolour == colour && blcolour == colour))
		return 1000;

	// Check if this move can stop opponent from winning. This move is priority #2.
	if ((tcount >= 4 && tcolour != colour) ||
			(bcount >= 4 && bcolour != colour) ||
			(lcount >= 4 && lcolour != colour) ||
			(rcount >= 4 && rcolour != colour) ||
			(tlcount >= 4 && tlcolour != colour) ||
			(trcount >= 4 && trcolour != colour) ||
			(brcount >= 4 && brcolour != colour) ||
			(blcount >= 4 && blcolour != colour) ||
			(tcount + bcount >= 4 && tcolour != colour && bcolour != colour) ||
			(lcount + rcount >= 4 && lcolour != colour && rcolour != colour) ||
			(tlcount + brcount >= 4 && tlcolour != colour && brcolour != colour) ||
			(trcount + blcount >= 4 && trcolour != colour && blcolour != colour))
		return 500;

	// Else sum up the counts, use this as the points.
	pts = tcount + bcount + lcount + rcount + tlcount + trcount + blcount + brcount + 1;
	// If at an edge, lower the points
	if (x == 0 || x == 18 || y == 0 || y == 18){
		if (pts >= EDGEPENALTY)
			pts -= EDGEPENALTY;
		else
			pts = 0;
	}
	return pts;
}

/*
   The AI Function that calls the cost function for every spot on the board.
   It returns the location with the highest points. In the event of a tie, randomly decide.
   Input the board and the colour being played.
   Puts the move (in ASCII chars) inside move[4]. This is from [1 ... 19]
   Puts the move (in integers) in moveY and moveX. This is from [0 ... 18]
 */
int connect6ai_synth(int firstmove,char movein[8], char colour, char moveout[8]){
	#pragma bitsize firstmove 8
	short x,y,highx = 0, highy = 0,currenthigh = 0, temp;
	#pragma bitsize x 6
	#pragma bitsize y 6
	#pragma bitsize highx 6
	#pragma bitsize highy 6
	#pragma bitsize currenthigh 6
	#pragma bitsize temp 6 // one bit more for short
	//srand(time(NULL));
	static unsigned char myboard[19][19] ;//= {{ 0 }};
	#pragma bitsize myboard 2
	#pragma internal_blockram myboard
	#pragma preserve_array myboard
	char highRandom = 1;//rand();
	#pragma bitsize highRandom 2
	if(firstmove==0 || firstmove ==1){
		int i,j;
		for (i=0;i<19;i++) 
			for (j=0;j<19;j++) 
				myboard[i][j]=0;
	}
	//-------------------------------------------------------------------------
	if((firstmove >= 1)){
		//update the board
		y = char_to_int(movein[0])*10 + char_to_int(movein[1]) - 1;
		x = char_to_int(movein[2])*10 + char_to_int(movein[3]) - 1;
		if(colour==68)//'D')
			myboard[y][x] = (char)2;//76;//'L';
		else
			myboard[y][x] = (char)1;//68;//'D';
	}
	if((firstmove >=3)){
		//update the board
		y = char_to_int(movein[4])*10 + char_to_int(movein[5]) - 1;
		x = char_to_int(movein[6])*10 + char_to_int(movein[7]) - 1;
		if(colour==68)//'D')
			myboard[y][x] = (char)2;//76;//'L';
		else
			myboard[y][x] = (char)1;//68;//'D';
	}
	//printf("MYBOARD\n");
	//print_board(myboard);
	// Sweep the entire myboard with the cost function
	for (x = 0; x <= 18; x++){
		for (y = 0; y <= 18; y++){

			temp = calculatepoints_synth(myboard,y,x, colour);
			if (temp > currenthigh){
				highx = x;
				highy = y;
				currenthigh = temp;
				highRandom =1;// rand();
			}
			// If a tie happens, pseudo-randomly choose one between them
			if (temp == currenthigh && temp != 0){
				int tempRandom = 1;//rand();
				if (tempRandom > highRandom){
					highx = x;
					highy = y;
					highRandom = tempRandom;
				}
			}
		}
	}

	// Modify the myboard based on current move.
	
	myboard[highy][highx] = (colour==68) ? 1 : 2 ;

	// Increment by 1 because indexing starts at 1.
	highy++;
	highx++;

	/// Convert the int coordinates to corresponding ASCII chars
	if (highy >= 10){
		moveout[0] = '1';
		highy -= 10;
	} else {
		moveout[0] = '0';
	}
	if      (highy == 0) moveout[1] = '0';
	else if (highy == 1) moveout[1] = '1';
	else if (highy == 2) moveout[1] = '2';
	else if (highy == 3) moveout[1] = '3';
	else if (highy == 4) moveout[1] = '4';
	else if (highy == 5) moveout[1] = '5';
	else if (highy == 6) moveout[1] = '6';
	else if (highy == 7) moveout[1] = '7';
	else if (highy == 8) moveout[1] = '8';
	else if (highy == 9) moveout[1] = '9';

	// Do same for x.
	if (highx >= 10){
		moveout[2] = '1';
		highx -= 10;
	} else {
		moveout[2] = '0';
	}
	if      (highx == 0) moveout[3] = '0';
	else if (highx == 1) moveout[3] = '1';
	else if (highx == 2) moveout[3] = '2';
	else if (highx == 3) moveout[3] = '3';
	else if (highx == 4) moveout[3] = '4';
	else if (highx == 5) moveout[3] = '5';
	else if (highx == 6) moveout[3] = '6';
	else if (highx == 7) moveout[3] = '7';
	else if (highx == 8) moveout[3] = '8';
	else if (highx == 9) moveout[3] = '9';
	//-------------------------------------------------------------------------
	highx = 0; highy = 0;currenthigh = 0; highRandom = 1;
	//-------------------------------------------------------------------------
	if(firstmove>=1){
		// Sweep the entire myboard with the cost function
		for (x = 0; x <= 18; x++){
			for (y = 0; y <= 18; y++){
				//printf("%d %d\n",y,x);
				temp = calculatepoints_synth(myboard,y,x, colour);
				//printf("%d \n",temp);
				if (temp > currenthigh){
					highx = x;
					highy = y;
					currenthigh = temp;
					highRandom = 1;//rand();
				}
				// If a tie happens, pseudo-randomly choose one between them
				if (temp == currenthigh && temp != 0){
					int tempRandom = 1;//rand();
					if (tempRandom > highRandom){
						highx = x;
						highy = y;
						highRandom = tempRandom;
					}
				}
			}
		}

		// Modify the myboard based on current move.
		myboard[highy][highx] = (colour==68) ? 1 :2 ;

		// Increment by 1 because indexing starts at 1.
		highy++;
		highx++;

		/// Convert the int coordinates to corresponding ASCII chars
		if (highy >= 10){
			moveout[4] = '1';
			highy -= 10;
		} else {
			moveout[4] = '0';
		}
		if      (highy == 0) moveout[5] = '0';
		else if (highy == 1) moveout[5] = '1';
		else if (highy == 2) moveout[5] = '2';
		else if (highy == 3) moveout[5] = '3';
		else if (highy == 4) moveout[5] = '4';
		else if (highy == 5) moveout[5] = '5';
		else if (highy == 6) moveout[5] = '6';
		else if (highy == 7) moveout[5] = '7';
		else if (highy == 8) moveout[5] = '8';
		else if (highy == 9) moveout[5] = '9';

		// Do same for x.
		if (highx >= 10){
			moveout[6] = '1';
			highx -= 10;
		} else {
			moveout[6] = '0';
		}
		if      (highx == 0) moveout[7] = '0';
		else if (highx == 1) moveout[7] = '1';
		else if (highx == 2) moveout[7] = '2';
		else if (highx == 3) moveout[7] = '3';
		else if (highx == 4) moveout[7] = '4';
		else if (highx == 5) moveout[7] = '5';
		else if (highx == 6) moveout[7] = '6';
		else if (highx == 7) moveout[7] = '7';
		else if (highx == 8) moveout[7] = '8';
		else if (highx == 9) moveout[7] = '9';
	}
	//-------------------------------------------------------------------------
	//int i;
	//for(i=0;i<8;i++) printf("%c",moveout[i]);
	return 0;
}



