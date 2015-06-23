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


enum tcp_state {
	TCP_CLOSED    = 0,
    TCP_LISTENING = 1,
	TCP_PENDING   = 2,
	TCP_OPEN      = 3
};


enum tcp_options {
        TCP_NEW         = 0,
        TCP_NORMAL      = 1,
        TCP_RESET       = 2
};


enum app_type {
        APP_TELNET      = 0,
        APP_HTTPD       = 1,
        APP_FTPD        = 2
};


typedef struct {
    /* socket associated with this application */
    void*               socket;
    void*               telnet;
    int                 type;
} app_t;



typedef struct {

    packet_buffer_t**   tcp_buf;
    int                 tcp_current_buf;

    int                 packets_sent;
    int                 packets_received;
    int                 packets_resent;

    int                 tcp_connection_state;
    int                 tcp_reset;
    int                 tcp_disconnect;

    /* byte sequence numbers */
    unsigned int        tcp_tx_seq;             /* initial value should be random initial seq number for tcp */

    unsigned int        tcp_rx_init_seq;        /* Initial byte sequence number received from client */
    unsigned int        tcp_rx_seq;             /* is equivalent to tcp_tx_ack */
    unsigned int        tcp_rx_ack;

    unsigned int        tcp_bytes_received;
    unsigned int        tcp_bytes_acked;

    ip_t                dest_ip;                /* IP address of the far end */
    mac_t               dest_mac;               /* MAC address of the far end */
    unsigned int        listen_port;            /* Listen on this port for connection requests */
    int                 id;

    packet_t*           rx_packet;              /* Header info from last packet received */

    /* pointers to the next socket in the chain and the first socket in the chain */
    void*               next;
    void*               first;

    /* pointer to generic application object */
    app_t*              app;
} socket_t;




/* Global Variables */
extern socket_t*    first_socket_g;
extern int          tcp_checksum_errors_g;


/* Function prototypes */
socket_t*       new_socket              (socket_t* prev);
int             listen_socket           (unsigned int, app_t*);
void            process_sockets         ();

unsigned short  tcp_checksum            (unsigned char*, packet_t*, unsigned short);
unsigned int    tcp_header              (char*, socket_t*, int, int);
void            tcp_reply               (socket_t*, char*, int);
void            tcp_open                (socket_t*);
void            tcp_retransmit          (socket_t*);
void            tcp_ack                 (socket_t*);
void            tcp_response            (char*, socket_t*);
void            tcp_disconnect          (socket_t*);
void            tcp_tx                  (socket_t*, char*, int);
void            parse_tcp_options       (char*, packet_t*);
void            parse_tcp_packet        (char*, packet_t*);
void            process_tcp             (socket_t*);

