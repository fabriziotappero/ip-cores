/*  util.cpp
    June 9, 2011
    Some helper functions.

    Much of the code below is borrowed from Alastair Smith's program
    from the 2010 FPT Othello competition

    By Kevin Nam
*/


#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <sys/time.h>
#include "util.h"

#define IA 1103515245u
#define IC 12345u
#define IM 2147483648u

using namespace std;

static unsigned int current_random = 0;


char select_AI_colour (int argc, char **argv){
    char ai_colour;
    int i;
    //cout<<"Please enter referee AI's colour. L or D"<<endl;
    //cin >> ai_colour;
	for(i=0;i<argc; i++){
          if((strcmp(argv[i],"-player")==0) && (i< (argc+1)) ){
                   ai_colour= *argv[i+1];
          }
  	}

    while (ai_colour != 'L' && ai_colour != 'D'){
        cout<<"Invalid colour. Single character L or D"<<endl;
        cin >> ai_colour;
    }

    cout<<"AI is playing as "<<ai_colour<<endl;
    return ai_colour;
}


int select_com_port(int argc, char **argv)
{
  string com_port;
  int i, port;
  bool cmd_line_port_set = false;

  for(i=0;i<argc; i++){
	  if((strcmp(argv[i],"-port")==0) && (i< (argc+1)) ){
		  com_port = argv[i+1];
		  cmd_line_port_set = true;
	  }
  }
  if( !cmd_line_port_set ){
    cout << "Please enter serial port name. Ex. /dev/comx (windows) or /dev/ttyx (linux)\n";
    cin >> com_port;
  }


  port = open(com_port.c_str(), O_RDWR | O_NOCTTY | O_NONBLOCK);
  while(port < 0) // if open is unsucessful keep trying until the user specifies a good port
  {
    cout << "Unable to open port " << com_port << ", try again, should be: (windows) /dev/comx or (linux) /dev/ttyx ?\n";
    cin >> com_port;
    port = open(com_port.c_str(), O_RDWR | O_NOCTTY | O_NONBLOCK);
  }
  setup_port(port);

  cout << "COM port has been set up at a baud rate of 115200\n";
  return port;
}

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

int char_to_int (char c){
    if (c == '0') return 0;
    else if (c == '1') return 1;
    else if (c == '2') return 2;
    else if (c == '3') return 3;
    else if (c == '4') return 4;
    else if (c == '5') return 5;
    else if (c == '6') return 6;
    else if (c == '7') return 7;
    else if (c == '8') return 8;
    else if (c == '9') return 9;

    return 0;
}

void wait(double seconds){
    timeval tim;
    gettimeofday(&tim, NULL);
    double t1=tim.tv_sec+(tim.tv_usec/1000000.0);
    while (1){
        gettimeofday(&tim, NULL);
        double t2=tim.tv_sec+(tim.tv_usec/1000000.0);
        if (t2-t1 >= seconds)
            break;
    }
}

