/*
    connect6.cpp
    June 9, 2011
    This file contains the game AI
    By Kevin Nam

*/

#include <time.h>
#include <stdlib.h>

#include "util.h"
#include "connect6.h"

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
int calculatepoints(char board[][19], int y, int x, char colour){
    int pts = 0, tempx = x, tempy = y, tcount = 0,bcount = 0;
    int lcount = 0,rcount = 0,trcount = 0,tlcount = 0,brcount = 0,blcount = 0;
    char tcolour = 0,bcolour = 0,lcolour = 0,rcolour = 0,tlcolour = 0,trcolour = 0,brcolour = 0,blcolour = 0;

    if (board[y][x] != 0)
        return 0;

    // scan column above
    if (y > 0){
        tempy = y-1;
        tempx = x;
        tcolour = board[tempy][tempx];
        while (1){
            if (board[tempy][tempx] != tcolour || board[tempy][tempx] == 0) break;
            tcount++;
            if (tempy == 0) break;
            tempy--;
        }
    }
    // scan column below
    if (y < 18){
        tempy = y+1;
        tempx = x;
        bcolour = board[tempy][tempx];
        while (1){
            if (board[tempy][tempx] != bcolour || board[tempy][tempx] == 0) break;
            bcount++;
            if (tempy == 18) break;
            tempy++;
        }
    }
    // scan row to left
    if (x > 0){
        tempy = y;
        tempx = x-1;
        lcolour = board[tempy][tempx];
        while (1){
            if (board[tempy][tempx] != lcolour || board[tempy][tempx] == 0) break;
            lcount++;
            if (tempx == 0) break;
            tempx--;
        }
    }
    // scan row to right
    if (x < 18){
        tempy = y;
        tempx = x+1;
        rcolour = board[tempy][tempx];
        while (1){
            if (board[tempy][tempx] != rcolour || board[tempy][tempx] == 0) break;
            rcount++;
            if (tempx == 18) break;
            tempx++;
        }
    }
    // scan diagonal topleft
    if (x > 0 && y > 0){
        tempy = y-1;
        tempx = x-1;
        tlcolour = board[tempy][tempx];
        while (1){
            if (board[tempy][tempx] != tlcolour || board[tempy][tempx] == 0) break;
            tlcount++;
            if (tempx == 0 || tempy == 0) break;
            tempx--;
            tempy--;
        }
    }
    // scan diagonal bottomright
    if (x < 18 && y < 18){
        tempy = y+1;
        tempx = x+1;
        brcolour = board[tempy][tempx];
        while (1){
            if (board[tempy][tempx] != brcolour || board[tempy][tempx] == 0) break;
            brcount++;
            if (tempx == 18 || tempy == 18) break;
            tempx++;
            tempy++;
        }
    }
    // scan diagonal topright
    if (x < 18 && y > 0){
        tempy = y-1;
        tempx = x+1;
        trcolour = board[tempy][tempx];
        while (1){
            if (board[tempy][tempx] != trcolour || board[tempy][tempx] == 0) break;
            trcount++;
            if (tempx == 18 || tempy == 0) break;
            tempx++;
            tempy--;
        }
    }
    // scan diagonal bottomleft
    if (y < 18 && x > 0){
        tempy = y+1;
        tempx = x-1;
        blcolour = board[tempy][tempx];
        while (1){
            if (board[tempy][tempx] != blcolour || board[tempy][tempx] == 0) break;
            blcount++;
            if (tempy == 18 || tempx == 0) break;
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
int connect6ai(char board[][19], char colour, char move[4]){
    int x,y,highx = 0, highy = 0,currenthigh = 0, temp;
    srand(time(NULL));
    int highRandom = rand();
    // Sweep the entire board with the cost function
    for (x = 0; x <= 18; x++){
        for (y = 0; y <= 18; y++){

            temp = calculatepoints(board,y,x, colour);
            if (temp > currenthigh){
                highx = x;
                highy = y;
                currenthigh = temp;
                highRandom = rand();
            }
            // If a tie happens, pseudo-randomly choose one between them
            if (temp == currenthigh && temp != 0){
                int tempRandom = rand();
                if (tempRandom > highRandom){
                    highx = x;
                    highy = y;
                    highRandom = tempRandom;
                }
            }
        }
    }

    // Modify the board based on current move.
    board[highy][highx] = colour;

    // Increment by 1 because indexing starts at 1.
    highy++;
    highx++;

    /// Convert the int coordinates to corresponding ASCII chars
    if (highy >= 10){
        move[0] = '1';
        highy -= 10;
    } else {
        move[0] = '0';
    }
    if      (highy == 0) move[1] = '0';
    else if (highy == 1) move[1] = '1';
    else if (highy == 2) move[1] = '2';
    else if (highy == 3) move[1] = '3';
    else if (highy == 4) move[1] = '4';
    else if (highy == 5) move[1] = '5';
    else if (highy == 6) move[1] = '6';
    else if (highy == 7) move[1] = '7';
    else if (highy == 8) move[1] = '8';
    else if (highy == 9) move[1] = '9';

    // Do same for x.
    if (highx >= 10){
        move[2] = '1';
        highx -= 10;
    } else {
        move[2] = '0';
    }
    if      (highx == 0) move[3] = '0';
    else if (highx == 1) move[3] = '1';
    else if (highx == 2) move[3] = '2';
    else if (highx == 3) move[3] = '3';
    else if (highx == 4) move[3] = '4';
    else if (highx == 5) move[3] = '5';
    else if (highx == 6) move[3] = '6';
    else if (highx == 7) move[3] = '7';
    else if (highx == 8) move[3] = '8';
    else if (highx == 9) move[3] = '9';

    return 0;
}


// scan board, return 'L' or 'D' for the winner, 'n' if no winner.
char check_for_win (char board[][19]){
    int y,x;
    for (y = 0; y < 19; y++){
        for (x = 0; x < 19; x++){
            if (board[y][x] == 0)
                continue;

            int tempx, tempy, tcount = 0,bcount = 0;
            int lcount = 0,rcount = 0,trcount = 0,tlcount = 0,brcount = 0,blcount = 0;
            char tcolour = 0,bcolour = 0,lcolour = 0,rcolour = 0,tlcolour = 0,trcolour = 0,brcolour = 0,blcolour = 0;

            // scan column above
            if (y > 0){
                tempy = y;
                tempx = x;
                tcolour = board[tempy][tempx];
                while (1){
                    if (board[tempy][tempx] != tcolour || board[tempy][tempx] == 0) break;
                    tcount++;
                    if (tempy == 0) break;
                    tempy--;
                }
            }
            // scan column below
            if (y < 18){
                tempy = y+1;
                tempx = x;
                bcolour = board[tempy][tempx];
                while (1){
                    if (board[tempy][tempx] != bcolour || board[tempy][tempx] == 0) break;
                    bcount++;
                    if (tempy == 18) break;
                    tempy++;
                }
            }

            if (tcolour == bcolour && tcount + bcount >= 6) return tcolour;

            // scan row to left
            if (x > 0){
                tempy = y;
                tempx = x;
                lcolour = board[tempy][tempx];
                while (1){
                    if (board[tempy][tempx] != lcolour || board[tempy][tempx] == 0) break;
                    lcount++;
                    if (tempx == 0) break;
                    tempx--;
                }
            }
            // scan row to right
            if (x < 18){
                tempy = y;
                tempx = x+1;
                rcolour = board[tempy][tempx];
                while (1){
                    if (board[tempy][tempx] != rcolour || board[tempy][tempx] == 0) break;
                    rcount++;
                    if (tempx == 18) break;
                    tempx++;
                }
            }

            if (lcolour == rcolour && lcount + rcount >= 6) return lcolour;

            // scan diagonal topleft
            if (x > 0 && y > 0){
                tempy = y;
                tempx = x;
                tlcolour = board[tempy][tempx];
                while (1){
                    if (board[tempy][tempx] != tlcolour || board[tempy][tempx] == 0) break;
                    tlcount++;
                    if (tempx == 0 || tempy == 0) break;
                    tempx--;
                    tempy--;
                }
            }
            // scan diagonal bottomright
            if (x < 18 && y < 18){
                tempy = y+1;
                tempx = x+1;
                brcolour = board[tempy][tempx];
                while (1){
                    if (board[tempy][tempx] != brcolour || board[tempy][tempx] == 0) break;
                    brcount++;
                    if (tempx == 18 || tempy == 18) break;
                    tempx++;
                    tempy++;
                }
            }

            if (tlcolour == brcolour && tlcount + brcount >= 6) return tlcolour;

            // scan diagonal topright
            if (x < 18 && y > 0){
                tempy = y;
                tempx = x;
                trcolour = board[tempy][tempx];
                while (1){
                    if (board[tempy][tempx] != trcolour || board[tempy][tempx] == 0) break;
                    trcount++;
                    if (tempx == 18 || tempy == 0) break;
                    tempx++;
                    tempy--;
                }
            }
            // scan diagonal bottomleft
            if (y < 18 && x > 0){
                tempy = y+1;
                tempx = x-1;
                blcolour = board[tempy][tempx];
                while (1){
                    if (board[tempy][tempx] != blcolour || board[tempy][tempx] == 0) break;
                    blcount++;
                    if (tempy == 18 || tempx == 0) break;
                    tempy++;
                    tempx--;
                }
            }

            if (trcolour == blcolour && trcount + blcount >= 6) return trcolour;
        }
    }
    // return 'n' for no victory
    return 'n';
}

// Check if the board is full
int check_board_full (char board[][19]){
    int y,x;
    // As soon as there is an empty intersection, return 0;
    for (y = 0; y < 19; y++)
        for (x = 0; x < 19; x++)
            if (board[y][x] == 0)
                return 0;

    // By now, swept entire board and all filled.
    return -1;
}

// Check if move y,x is valid. Here, y and x are [0 ... 18]
int check_move_validity (char board[][19],int y, int x){
    if (y < 0 || y > 18 || x < 0 || x > 18 || board[y][x] != 0){
        return -1;
    }
    return 0;
}


void print_board (char board[][19]){
    printf("  1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9");
    unsigned short x,y;
    for (x = 0; x <= 18; x++){
    printf("\n");
    printf("%d",x+1);
    if (x < 9) printf(" ");
        for (y = 0; y <= 18; y++){
            if (board[x][y] == 0)
                printf(".");
	    else printf("%c",board[x][y]);
            printf(" ");
        }

    }
    printf("\n");
}

void print_board_file (char board[][19]){
char *filename="myboard.txt";
FILE *fp=fopen(filename,"w");
    fprintf(fp,"  1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9");
    unsigned short x,y;
    for (x = 0; x <= 18; x++){
    fprintf(fp,"\n");
    fprintf(fp,"%d",x+1);
    if (x < 9) fprintf(fp," ");
        for (y = 0; y <= 18; y++){
            if (board[x][y] == 0)
                fprintf(fp,".");
	    else fprintf(fp,"%c",board[x][y]);
            fprintf(fp," ");
        }

    }
    fprintf(fp,"\n");
fclose(fp);
}
