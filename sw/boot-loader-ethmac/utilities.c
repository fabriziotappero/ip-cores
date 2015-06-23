/*----------------------------------------------------------------
//                                                              //
//  boot-loader-ethmac.c                                        //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  The main functions for the boot loader application. This    //
//  application is embedded in the FPGA's SRAM and is used      //
//  to load larger applications into the DDR3 memory on         //
//  the development board.                                      //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2011 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
----------------------------------------------------------------*/

#include "amber_registers.h"
#include "utilities.h"


int next_string(char*buf)
{
    int pos = 0;
    while (*buf != 0) {buf++; pos++;}
    return ++pos;
}


int strcmp(char* str1, char*str2)
{
    int pos = 0;
    int equal=1;

    while (*str1!=0 && *str2!=0 && pos<256 && equal) {
        equal = *str1==*str2;
        str1++;
        str2++;
        pos++;
        }
    return equal;
}


/* Return a number recovered from a string of hex digits */
int get_hex (char * buf, unsigned int *num)
{
    int cpos = 0, done = 0;
    *num = 0;

    while (!done) {
        if ( buf[cpos] >= '0' && buf[cpos] <= '9' ) {
           *num = *num<<4;
           *num = *num + buf[cpos] - '0';
           }
        else if ( buf[cpos] >= 'A' && buf[cpos] <= 'F' ) {
            *num = *num<<4;
            *num = *num + buf[cpos] - 'A' + 10;
           }
        else if ( buf[cpos] >= 'a' && buf[cpos] <= 'f' ) {
            *num = *num<<4;
            *num = *num + buf[cpos] - 'a' + 10;
           }
        else
            done = 1;

        // Don't increment cops if the first character is not part of an ascii-hex string
        // oo that a 0 is returned to indicate failure.
        if (!done)
            cpos++;

        if (cpos >= 8)
            done = 1;
        }

    /* Return length of acsii-hex string */
    return cpos;
}


void udelay20(void)
{
    volatile int i;
    for (i=0;i<500;i++) ;
}


void phy_rst(int value)
{
    *(unsigned int *) ADR_AMBER_TEST_PHY_RST = value;
}

