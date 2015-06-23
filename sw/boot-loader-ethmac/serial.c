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
// Copyright (C) 2010-2013 Authors and OPENCORES.ORG            //
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


#define DEBUG 1

#ifdef DEBUG
    #define trace(fmt, args...) print_serial("%s:%s:%d: "fmt"\n\r", __FILE__, __FUNCTION__, __LINE__, args)
#else
    #define trace(fmt, args...)
#endif



void init_serial()
{
    /* Enable UART 0 */
    *(unsigned int *) ADR_AMBER_UART0_LCRH = 0x10;
}



/* Add a line to the line buffer */
void print_serial(const char *fmt, ...)
{
    int len;
    register unsigned long *varg = (unsigned long *)(&fmt);
    *varg++;

    /* Need to pass a pointer to a pointer to the location to
       write the character, to that the pointer to the location
       can be incremented by the final output function
    */
    len = print(0, fmt, varg);
}

