/*
 * biolib.h -- basic I/O library
 */


#ifndef _BIOLIB_H_
#define _BIOLIB_H_


char getc(void);
void putc(char c);
int rwscts(int dskno, int cmd, int sector, int addr, int count);


#endif /* _BIOLIB_H_ */
