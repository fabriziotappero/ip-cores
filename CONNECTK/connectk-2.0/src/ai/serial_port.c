#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <sys/time.h>
#include "../shared.h"


/* All serial functions work on this board */
static Board *myboard = NULL;
static port=0;
// The AI has as much time as it wants, but moves after 1 second. Default is to wait 2 seconds
#define AI_WAIT_TIME 0.5

// FPGA has 1 second to make its move
#define MOVE_TIME_LIMIT 0.5
	
static int char_to_int(short x){
		if(x>=48)
			return x-48;
		else 
			return 0;
}
//void wait(double seconds){
//    timeval tim;
//    gettimeofday(&tim, NULL);
//    double t1=tim.tv_sec+(tim.tv_usec/1000000.0);
//    while (1){
//        gettimeofday(&tim, NULL);
//        double t2=tim.tv_sec+(tim.tv_usec/1000000.0);
//        if (t2-t1 >= seconds)
//            break;
//    }
//}

void setup_port(int fd) {
    struct termios options;
    fcntl(fd, F_SETFL, 0);
    tcgetattr(fd, &options);
    cfsetispeed(&options, B115200);
    cfsetospeed(&options, B115200);
    options.c_cflag |= (CLOCAL | CREAD);
    tcsetattr(fd, TCSANOW, &options);

    // set up non-blocking port, so that we can time out
	int opts;
	opts = fcntl(fd,F_GETFL);
	if (opts < 0) {
		perror("fcntl(F_GETFL)");
		exit(EXIT_FAILURE);
	}
	opts = (opts | O_NONBLOCK);
	if (fcntl(fd,F_SETFL,opts) < 0) {
		perror("fcntl(F_SETFL)");
		exit(EXIT_FAILURE);
	}
	return;
}



void move_to_ascii(int x,int y, char move[4]){
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











AIMoves *ai_serial(const Board *b){
int i,j,firstmove=0;
char move[4];

AIMoves *moves = aimoves_new();
AIMove fpgamove;
        
	
	
	
	for(i=0;i<board_size;i++){
		for(j=0;j<board_size;j++){
			if (piece_at(b,i,j)!=PIECE_NONE) firstmove++;
	}
	}
	if(firstmove<=1){
		port = open("/dev/ttyS0", O_RDWR | O_NOCTTY | O_NONBLOCK);
		setup_port(port);
	
		if(b->turn==PIECE_WHITE){
			write(port, "L",1);
		}else{
			write(port, "D",1);
	
		}
		printf("firstmove %d\n",firstmove);
		if(!myboard){
			myboard=board_new();
		}else{
			board_free(myboard);
			myboard=board_new();
		}		
	
	} 
	if(b->moves_left >1 || (firstmove<=1)){
	for(i=0;i<board_size;i++){
		for(j=0;j<board_size;j++){
			if ((piece_at(myboard,i,j)==PIECE_NONE) && (piece_at(b,i,j)!=PIECE_NONE)){
				printf("%d,%d\n",i+1,j+1);	
				move_to_ascii(i+1,j+1,move);		
        			write(port,&move[0],1);
        			write(port,&move[1],1);
        			write(port,&move[2],1);
        			write(port,&move[3],1);
				printf("AI move %c%c %c%c\n", move[2],move[3],move[0],move[1] );
			}
		}	
		
	}
	
	}
        sleep(1);
        //move[0] = 0; move[1] = 0; move[2] = 0; move[3] = 0;
        ////////// Get Opponent's move
        read(port,&move[0],1);
        read(port,&move[1],1);
        read(port,&move[2],1);
        read(port,&move[3],1);
	fpgamove.y=char_to_int(move[0])*10 + char_to_int(move[1])-1;
	fpgamove.x=char_to_int(move[2])*10 + char_to_int(move[3])-1;
	printf("FPGA move %d %d\n", fpgamove.x, fpgamove.y);
        aimoves_append(moves, &fpgamove);
        //move[0] = 0; move[1] = 0; move[2] = 0; move[3] = 0;
        //read(port,&move[0],1);
        //read(port,&move[1],1);
        //read(port,&move[2],1);
        //read(port,&move[3],1);
	//			printf("FPGA move %c%c %c%c\n", move[2],move[3],move[0],move[1] );
	//fpgamove.x=char_to_int(move[2])*10 + char_to_int(move[3]) - 1;
	//fpgamove.y=char_to_int(move[0])*10 + char_to_int(move[1]) - 1;
	//printf("FPGA move %d %d\n", fpgamove.x, fpgamove.y);
        //aimoves_append(moves, &fpgamove);
        board_copy(b,myboard);
	place_piece_type(myboard,fpgamove.x,fpgamove.y,b->turn);
	return moves;
}
