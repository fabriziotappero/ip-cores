
#ifndef __DEBUG_H
#define __DEBUG_H

#include "syscall.h"

//#define DEBUG
#define DEBUG_TEXT_LEN 8

#ifdef DEBUG
#define DEBUG_TRACE( string )												\
	{														\
		unsigned char debug_text[DEBUG_TEXT_LEN+1];								\
		syscall( SYS_SCREEN_PUT_STRING, __FILE__ );								\
		syscall( SYS_SCREEN_PUT_STRING, ":");									\
		syscall( SYS_SCREEN_PUT_STRING, debug_convert( __LINE__ , debug_text , DEBUG_TEXT_LEN , 10 ) );		\
		syscall( SYS_SCREEN_PUT_STRING, " ");									\
		syscall( SYS_SCREEN_PUT_STRING, __FUNCTION__ );								\
		syscall( SYS_SCREEN_PUT_STRING, ":");									\
		syscall( SYS_SCREEN_PUT_STRING, (string) );								\
		syscall( SYS_SCREEN_PUT_STRING, "\n")									\
	}

#define DEBUG_PRINT( string )												\
	syscall( SYS_SCREEN_PUT_STRING, (string) )

#define DEBUG_INTEGER( string , length )												\
	{														\
		unsigned char debug_text[length+1];									\
		syscall( SYS_SCREEN_PUT_STRING, debug_convert( string , debug_text , length , 16 ) );			\
	}

#else

#define DEBUG_TRACE( string )
#define DEBUG_PRINT( string )
#define DEBUG_INTEGER( string )

#endif

//extern const unsigned char debug_chars[];

unsigned char *debug_convert(unsigned long int src,unsigned char *debug_text,unsigned long int num,unsigned long int adic);

#endif

