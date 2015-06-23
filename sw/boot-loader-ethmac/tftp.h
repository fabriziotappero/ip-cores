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
#define LINUX_JUMP_ADR  0x00080000


typedef struct {
    char *          buf512;
    void *          next;
    unsigned int    bytes;
    unsigned int    last_block;
    unsigned int    total_bytes;
    unsigned int    total_blocks;
    unsigned int    ready;
    unsigned int    linux_boot;
    char*           filename;
} block_t;


/* Global variables */
extern time_t*  reboot_timer_g;
extern int      reboot_stage_g;

/* Function prototypes */
void        process_tftp ();
void        init_tftp ();
block_t*    init_buffer_512 ();
int         process_file ();
void        reboot ();
void        parse_tftp_packet(char*, packet_t*, int, unsigned int, unsigned int);



