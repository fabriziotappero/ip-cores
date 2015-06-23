/*----------------------------------------------------------------
//                                                              //
//  boot-loader.h                                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Defines for the boot-loader application.                    //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
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

/* These uart input delay values are correct for a 33MHz system clock */
#define DLY_1S          1000
#define DLY_300MS       300

#define LINUX_JUMP_ADR  0x00080000 /* Boot loader jumps to this address to run vmlinux */
#define APP_JUMP_ADR    0x00008000 /* Boot loader jumps to this address to run test programs */
#define FILE_LOAD_BASE  0x01000000
#define DEBUG_BUF       0x01800000
#define FILE_MAX_SIZE   0x00800000 /* 8MB max Xmodem transfer file size        */

/* Function prototypes */
void parse ( char * buf );
void printm ( unsigned int address );
int  get_hex ( char * buf, int start_position, unsigned int *address, unsigned int *length );
int  get_address_data ( char * buf, unsigned int *address, unsigned int *data );
void load_run( int type, unsigned int address );
void print_spaces ( int num );
void print_help ( void );
