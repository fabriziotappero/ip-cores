/*  main.cpp
    June 9,2011

    Software connect6 AI program.
    Have your board polling for its colour before starting this program.

   commandline option:
   -port <serialport>
   Ex: "./connect6 -port /dev/ttyUSB0"

   By: Kevin Nam
*/

#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <sys/time.h>
#include "util.h"
#include "connect6.h"
#include "connect6_synth.h"
#ifndef EMUL
#include "pico.h"
#endif
#include "shared.h"

// The AI has as much time as it wants, but moves after 1 second. Default is to wait 2 seconds
#define AI_WAIT_TIME 0.1

// FPGA has 1 second to make its move
#define MOVE_TIME_LIMIT 0.1

using namespace std;
extern "C" int main(int argc, char **argv);
// commandline option: -port <serialport>
int main(int argc, char **argv){
    //for verification two runs and a reference board
    int i,j,k;
    char ref_board[19][19] = {{ 0 }};

    char board[19][19] = {{ 0 }};
    char move[4];
    char moveport[8]={0};
    char moveportout[8]={0};
    int movecount=0;
    int y,x;
    char winning_colour;

#ifdef EMUL
    // Get the serial port
    	int port = select_com_port(argc,argv);
#endif
    // Get software AI's colour
    char AI_colour = select_AI_colour(argc,argv);
    char FPGA_colour;
#ifndef EMUL
	int id = PICO_initialize_PPA(connect6ai_synth);
#endif
    // Take care of the first few moves (including sending the colour)
    if (AI_colour == 'D'){
        FPGA_colour = 'L';
#ifdef EMUL
        write(port, "L",1);
#endif

        wait(AI_WAIT_TIME);

        // AI makes a move
        connect6ai(board,AI_colour,move);
	movecount++;
        cout<<"AI MOVE: "<<move[0]<<move[1]<<move[2]<<move[3]<<endl;
#ifdef EMUL
        write(port,&move[0],1);
        write(port,&move[1],1);
        write(port,&move[2],1);
        write(port,&move[3],1);
#endif
        print_board(board);
        print_board_file(board);

	moveport[0]=move[0];
	moveport[1]=move[1];
	moveport[2]=move[2];
	moveport[3]=move[3];
	
	moveport[4]=0;
	moveport[5]=0;
	moveport[6]=0;
	moveport[7]=0;

    } else {
        FPGA_colour = 'D';
#ifdef EMUL
        write(port, "D",1);
#endif 
        wait(MOVE_TIME_LIMIT);

        move[0] = 0; move[1] = 0; move[2] = 0; move[3] = 0;
        ////////// Get Opponent's move
#ifdef EMUL
        read(port,&move[0],1);
        read(port,&move[1],1);
        read(port,&move[2],1);
        read(port,&move[3],1);
#endif
        // FPGA makes a move
        connect6ai_synth(movecount,moveport,FPGA_colour,moveportout);
	movecount++;
#ifndef EMUL
	move[0]=moveportout[0];move[1]=moveportout[1];move[2]=moveportout[2];move[3]=moveportout[3];
        //connect6ai_golden(board,FPGA_colour,move);
#endif
        if (move[0] == 0 || move[1] == 0 || move[2] == 0 || move[3] == 0){
            cout<<"FPGA has not completed a move in 1 second. Exiting."<<endl;
            return 0;
        }
        cout<<"FPGA MOVE: "<<move[0]<<move[1]<<move[2]<<move[3]<<endl;
        y = char_to_int(move[0])*10 + char_to_int(move[1]) - 1;
        x = char_to_int(move[2])*10 + char_to_int(move[3]) - 1;
        if (check_move_validity(board,y,x) < 0) return 0;
        board[y][x] = FPGA_colour;
        print_board(board);
        print_board_file(board);
        wait(AI_WAIT_TIME);


        // AI makes a move
        connect6ai(board,AI_colour,move);
	movecount++;
        cout<<"AI MOVE: "<<move[0]<<move[1]<<move[2]<<move[3]<<endl;
#ifdef EMUL
        write(port,&move[0],1);
        write(port,&move[1],1);
        write(port,&move[2],1);
        write(port,&move[3],1);
#endif
	moveport[0]=move[0];
	moveport[1]=move[1];
	moveport[2]=move[2];
	moveport[3]=move[3];
        // AI makes a move
        connect6ai(board,AI_colour,move);
	movecount++;
        cout<<"AI MOVE: "<<move[0]<<move[1]<<move[2]<<move[3]<<endl;
#ifdef EMUL
        write(port,&move[0],1);
        write(port,&move[1],1);
        write(port,&move[2],1);
        write(port,&move[3],1);
#endif	
	moveport[4]=move[0];
	moveport[5]=move[1];
	moveport[6]=move[2];
	moveport[7]=move[3];
        print_board_file(board);
    }

    // Alternate between receiving and sending moves
    while(1){
        wait(MOVE_TIME_LIMIT);

        // Get Opponent's move
        move[0] = 0; move[1] = 0; move[2] = 0; move[3] = 0;
#ifdef EMUL
        read(port,&move[0],1);
        read(port,&move[1],1);
        read(port,&move[2],1);
        read(port,&move[3],1);
#endif
        connect6ai_synth(movecount,moveport,FPGA_colour,moveportout);
	movecount++;
#ifndef EMUL
	move[0]=moveportout[0];move[1]=moveportout[1];move[2]=moveportout[2];move[3]=moveportout[3];
#endif
        //connect6ai_golden(board,FPGA_colour,move);

        cout<<"FPGA MOVE: "<<move[0]<<move[1]<<move[2]<<move[3]<<endl;
        if (move[0] == 0 || move[1] == 0 || move[2] == 0 || move[3] == 0){
            cout<<"FPGA has not completed a move in 1 second. Exiting."<<endl;
            break;
        }
        y = char_to_int(move[0])*10 + char_to_int(move[1]) - 1;
        x = char_to_int(move[2])*10 + char_to_int(move[3]) - 1;
        if (check_move_validity(board,y,x) < 0) break;
        board[y][x] = FPGA_colour;
        winning_colour = check_for_win(board);
        if (winning_colour == AI_colour){
            cout<<"AI has won!" << movecount << " moves " << "Exiting."<<endl;
            break;
        } else if (winning_colour == FPGA_colour){
            cout<<"FPGA has won! " << movecount << " moves " << "Exiting."<<endl;
            break;
        }
        if (check_board_full(board) < 0){
	    cout << "TIE "  << movecount << " moves " << "Exiting."<<endl;
		break;
	}
        // Get Opponent's move
        move[0] = 0; move[1] = 0; move[2] = 0; move[3] = 0;
#ifdef EMUL
        read(port,&move[0],1);
        read(port,&move[1],1);
        read(port,&move[2],1);
        read(port,&move[3],1);
#endif
        ////connect6ai_synth(board,FPGA_colour,move);
	movecount++;
#ifndef EMUL
	move[0]=moveportout[4];move[1]=moveportout[5];move[2]=moveportout[6];move[3]=moveportout[7];
#endif
        //connect6ai_golden(board,FPGA_colour,move);
        cout<<"FPGA MOVE: "<<move[0]<<move[1]<<move[2]<<move[3]<<endl;
        if (move[0] == 0 || move[1] == 0 || move[2] == 0 || move[3] == 0){
            cout<<"FPGA has not completed a move in 1 second. Exiting."<<endl;
            break;
        }
        y = char_to_int(move[0])*10 + char_to_int(move[1]) - 1;
        x = char_to_int(move[2])*10 + char_to_int(move[3]) - 1;
        if (check_move_validity(board,y,x) < 0) break;
        board[y][x] = FPGA_colour;
        winning_colour = check_for_win(board);
        if (winning_colour == AI_colour){
            cout<<"AI has won! " << movecount << " moves " << "Exiting."<<endl;
            break;
        } else if (winning_colour == FPGA_colour){
            cout<<"FPGA has won! " << movecount << " moves " << "Exiting."<<endl;
            break;
        }
        if (check_board_full(board) < 0) {
	    	cout << "TIE "  << movecount << " moves " << "Exiting."<<endl;
		break;
	}
        print_board(board);
        print_board_file(board);

        wait(AI_WAIT_TIME);

        // AI makes a move
        connect6ai(board,AI_colour,move);
	movecount++;
        cout<<"AI MOVE: "<<move[0]<<move[1]<<move[2]<<move[3]<<endl;
	//if(movecount >=20) return 0 ; //reducing length of simulation
        winning_colour = check_for_win(board);
        if (winning_colour == AI_colour){
            cout<<"AI has won! " << movecount << " moves " << "Exiting."<<endl;
            break;
        } else if (winning_colour == FPGA_colour){
            cout<<"FPGA has won! " << movecount << " moves " << "Exiting."<<endl;
            break;
        }
        if (check_board_full(board) < 0){
	    	cout << "TIE "  << movecount << " moves " << "Exiting."<<endl;
		 break;
	}
#ifdef EMUL
        write(port,&move[0],1);
        write(port,&move[1],1);
        write(port,&move[2],1);
        write(port,&move[3],1);
#endif
	moveport[0]=move[0];
	moveport[1]=move[1];
	moveport[2]=move[2];
	moveport[3]=move[3];
        // AI makes a move
        connect6ai(board,AI_colour,move);
	movecount++;
        cout<<"AI MOVE: "<<move[0]<<move[1]<<move[2]<<move[3]<<endl;
        winning_colour = check_for_win(board);
        if (winning_colour == AI_colour){
            cout<<"AI has won! " << movecount << " moves " << "Exiting."<<endl;
            break;
        } else if (winning_colour == FPGA_colour){
            cout<<"FPGA has won! " << movecount << " moves " << "Exiting."<<endl;
            break;
        }
        if (check_board_full(board) < 0) {
	    cout << "TIE "  << movecount << " moves " << "Exiting."<<endl;
		break;
	}
#ifdef EMUL
        write(port,&move[0],1);
        write(port,&move[1],1);
        write(port,&move[2],1);
        write(port,&move[3],1);
#endif
	moveport[4]=move[0];
	moveport[5]=move[1];
	moveport[6]=move[2];
	moveport[7]=move[3];
        print_board(board);
        print_board_file(board);
    }

#ifndef EMUL
PICO_finalize_PPA(id);
#endif

    return 0;

}
