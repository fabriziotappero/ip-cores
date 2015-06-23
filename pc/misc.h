/*
 * =====================================================================================
 *
 *       Filename:  misc.h
 *
 *    Description:  some stuff
 *
 *        Version:  1.0
 *        Created:  04/16/2009 08:19:32 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  mengxipeng@gmail.com
 *
 * =====================================================================================
 */


#ifndef __MISC__
#define __MISC__

#include <stdio.h>
//#include <unistd.h>

#define DEBUG_LINE(fmt,arg...) \
        do{   printf(fmt,##arg);printf("\n");fflush(stdout);}while(0)

#endif

