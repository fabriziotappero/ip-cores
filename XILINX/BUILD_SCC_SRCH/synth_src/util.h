/*  util.cpp
    June 9, 2011
    Some helper functions.

    Much of the code below is borrowed from Alastair Smith's program
    from the 2010 FPT Othello competition

    By Kevin Nam
*/

#ifndef _UTILS_H
#define _UTILS_H

using namespace std;

#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <math.h>
#include <string>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
//#include "commondefs.h"

/*********************** Portable random number generators *******************/

void setup_port(int fd);
int select_com_port(int argc, char **argv);
char select_AI_colour (int argc, char **argv);
int char_to_int (char c);
void wait(double seconds);
#endif
