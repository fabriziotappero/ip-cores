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

#include "utilities.h"
#include "line-buffer.h"
#include "timer.h"
#include "packet.h"

line_buf_t* init_line_buffer (int size)
{
    line_buf_t* lbuf;
    int i;
    
    lbuf = malloc(sizeof(line_buf_t));
    lbuf->read_ptr  = 0;
    lbuf->write_ptr = 0;
    lbuf->len_bytes = size;
    lbuf->buf = malloc(size);
    return lbuf;
}


/* Add a single byte to the line buffer */
void put_byte (line_buf_t* telnet_buf, char byte, int last)
{    

    /* Need to pass a pointer to a pointer to the location to
       write the character, to that the pointer to the location
       can be incremented by the final output function
    */   
    telnet_buf->buf[telnet_buf->write_ptr]   = byte;
    if (last)
        telnet_buf->buf[telnet_buf->write_ptr+1] = 0;
    else
        telnet_buf->buf[telnet_buf->write_ptr+1] = 1;
    telnet_buf->write_ptr++;

    /* Wrap the write pointer */
    if ((telnet_buf->write_ptr + MAX_LINE) >= telnet_buf->len_bytes)
        telnet_buf->write_ptr = 0;
}


/* Add a line to the line buffer */
void put_line (line_buf_t* telnet_buf, const char *fmt, ...)
{
    int len;
    char *buf;
    int i;
    
    register unsigned long *varg = (unsigned long *)(&fmt);
    *varg++;
    
    /* Need to pass a pointer to a pointer to the location to
       write the character, to that the pointer to the location
       can be incremented by the final output function
    */   
    buf = &telnet_buf->buf[telnet_buf->write_ptr];    
    len = print(&buf, fmt, varg);
    buf[len] = 0;
    telnet_buf->write_ptr += len;
            
    /* Wrap the write pointer */
    if ((telnet_buf->write_ptr + MAX_LINE) >= telnet_buf->len_bytes)
        telnet_buf->write_ptr = 0;
    telnet_buf->buf[telnet_buf->write_ptr] = 0;
}



/* Retrieve the next line from a line buffer.
   return 0 if buffer doesn't have a complete line */
int get_line (line_buf_t* telnet_buf, char** line)
{
    int len = 0;
    
    // Grab these once at the start in case they are changed by an interrupt
    register int write_ptr   = telnet_buf->write_ptr;
    
    /* Wrap the read pointer */
    if ((telnet_buf->read_ptr + MAX_LINE) >= telnet_buf->len_bytes)
        telnet_buf->read_ptr = 0;

    *line = telnet_buf->buf + telnet_buf->read_ptr;
    
    /* Find the length of the next line in the buffer */
    if (telnet_buf->read_ptr != write_ptr) {
        /* Find next 0 */        
        while (telnet_buf->read_ptr+len != write_ptr        &&
               telnet_buf->buf[telnet_buf->read_ptr+len]!=0 && 
               telnet_buf->buf[telnet_buf->read_ptr+len]!=1 && 
               len < MAX_LINE) 
            len++;
        
        /* Check if there are some chars from put_char but not a complete line */
        if (telnet_buf->buf[telnet_buf->read_ptr+len]==1)
            return 0;
        else {
            telnet_buf->read_ptr += len;
            return len;
            }
        }
    else
        return 0;
}

