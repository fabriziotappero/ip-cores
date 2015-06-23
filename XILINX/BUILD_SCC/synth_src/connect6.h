/*
    connect6.h
    June 9, 2011
    This file contains the game AI
    By Kevin Nam

*/

#ifndef _CONNECT6_H
#define _CONNECT6_H

int calculatepoints(char board[][19], int y, int x, char colour);
int connect6ai(char board[][19], char colour, char move[4]);
char check_for_win (char board[][19]);
int check_board_full (char board[][19]);
int check_move_validity (char board[][19],int y, int x);
void print_board (char board[][19]);
void print_board_file (char board[][19]);
#endif
