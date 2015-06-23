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

/* Max number of characters to transmit from a line buffer in a single packet */
#define MAX_TELNET_TX       1024


/* Telnet connection */
typedef struct {

    /* Telnet rx and tx line buffers */
    line_buf_t*         rxbuf;
    line_buf_t*         txbuf;

    int                 sent_opening_message;
    int                 echo_mode;
    int                 connection_state;
    int                 options_sent;

    /* socket associated with this telnet connection */
    //socket_t*           socket;

    int                 id;

    /* pointers to the next telnet object in the chain and the first telnet object in the chain */
    void*               next;
    void*               first;

    /* pointer to application (telnet) object */
    app_t*              app;
} telnet_t;



void            parse_telnet_options    (char *, socket_t*);
void            parse_telnet_payload    (char *, socket_t*);
void            telnet_options          (socket_t*);
void            telnet_tx               (socket_t*, line_buf_t*);
void            process_telnet          (socket_t*);
int             parse_command           (telnet_t*, char*);
void            telnet_disconnect       (app_t *);

