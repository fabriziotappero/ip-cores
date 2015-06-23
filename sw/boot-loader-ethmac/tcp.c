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
#include "address_map.h"
#include "line-buffer.h"
#include "timer.h"
#include "utilities.h"
#include "packet.h"
#include "tcp.h"
#include "telnet.h"
#include "serial.h"


/* Global variables */
int         tcp_checksum_errors_g = 0;
socket_t*   first_socket_g = NULL;


/* input argument is a pointer to the previous socket,
   if this is the first socket object, then it is NULL */
socket_t* new_socket(socket_t* prev)
{
    socket_t* socket;
    int i;

    socket = (socket_t*) malloc(sizeof(socket_t));
    socket->rx_packet = (packet_t*) malloc(sizeof(packet_t));

    /* Create space for an array of pointers */
    socket->tcp_buf = malloc (TCP_TX_BUFFERS * sizeof (void *));

    /* Create space for a set of buffers, each pointed to by an element of the array */
    for (i=0;i<TCP_TX_BUFFERS;i=i+1) {
        socket->tcp_buf[i] = (packet_buffer_t*) malloc (sizeof (packet_buffer_t));
        socket->tcp_buf[i]->payload_valid = 0;
        socket->tcp_buf[i]->starting_seq = 0;
        socket->tcp_buf[i]->ending_seq   = 0;
        socket->tcp_buf[i]->len_bytes    = 0;
        socket->tcp_buf[i]->ack_received = 0;
        }

    socket->packets_sent = 0;
    socket->packets_received = 0;
    socket->packets_resent = 0;

    socket->tcp_current_buf = 0;
    socket->tcp_reset = 0;
    socket->tcp_connection_state = TCP_CLOSED;
    socket->tcp_disconnect = 0;
    socket->tcp_tx_seq = 0x100;  /* should be random initial seq number for tcp */
    socket->tcp_rx_ack = 0;
    socket->tcp_bytes_received = 0;
    socket->tcp_bytes_acked = 0;

    /* Chain the socket objects together */
    if (prev == NULL){
        socket->first = socket;
        socket->id = 0;
        }
    else {
        socket->first = prev->first;
        socket->id = prev->id + 1;
        prev->next = socket;
        }
    socket->next  = NULL;

    return socket;
}



/* returns the socket id */
int listen_socket (unsigned int listen_port, app_t* app)
{
    socket_t* socket;

    /* Add a new socket to the end of the list */
    if (first_socket_g == NULL) {
        trace("first_socket_g == NULL");
        first_socket_g = new_socket(NULL);
        socket = first_socket_g;
    }
    else {
        socket = first_socket_g;
        for(;;){
            if (socket->next!=NULL)
                socket=socket->next;
            else
                break;
            }
        socket = new_socket(socket);
    }

    socket->listen_port = listen_port;
    socket->tcp_connection_state = TCP_LISTENING;

    /* Assign the telnet object */
    socket->app = app;
    /* cross link, so can find the socket object when have pointer to the telnet object */
    socket->app->socket = socket;

    trace("new socket %d listening", socket->id);

    return socket->id;
}



/* All received tcp packets with dset ip == me arrive here */
void parse_tcp_packet(char * buf, packet_t* rx_packet)
{
    int i;
    int ptr;
    socket_t* socket;
    int found=0;

    /* TCP Length */
    rx_packet->tcp_len         = rx_packet->ip_len - rx_packet->ip_header_len*4;
    rx_packet->tcp_hdr_len     = (buf[12]>>4)*4;

    // Guard against incorrect tcp_hdr_len value
    if (rx_packet->tcp_hdr_len < rx_packet->tcp_len)
        rx_packet->tcp_payload_len = rx_packet->tcp_len - rx_packet->tcp_hdr_len;
    else
        rx_packet->tcp_payload_len = 0;

    /* Verify the TCP checksum is correct */
    if (tcp_checksum(buf, rx_packet, 0)) {
        tcp_checksum_errors_g++;
        return;
    }


    rx_packet->tcp_src_port    = buf[0]<<8|buf[1];
    rx_packet->tcp_dst_port    = buf[2]<<8|buf[3];
    rx_packet->tcp_seq         = buf[4]<<24|buf[5]<<16|buf[6]<<8|buf[7];
    rx_packet->tcp_ack         = buf[8]<<24|buf[9]<<16|buf[10]<<8|buf[11];
    rx_packet->tcp_flags       = buf[13];
    rx_packet->tcp_window_size = buf[14]<<8|buf[15];

    // trace("client tcp rx window %d bytes",
    //     (rx_packet->tcp_window_size)<<rx_packet->tcp_window_scale);


    if (rx_packet->tcp_hdr_len > 20) {
        /* Get the source time stamp */
        parse_tcp_options(buf, rx_packet);
        }


    /* only interested in telnet packet to dest port xx */
    //if (rx_packet->tcp_dst_port != 23) {
    //    return;
    //}


    /*  --------------------------------------------------
        Assign the received packet to a socket
        -------------------------------------------------- */
    /*  seach for an open socket that matches the tcp connection */
    socket = first_socket_g;
    if (socket == NULL) {
        trace("first socket is null");
        return;
    }


    /* Search for an already open socket */
    for(;;){
        if ((socket->tcp_connection_state == TCP_PENDING ||
             socket->tcp_connection_state == TCP_OPEN)      &&
            socket->rx_packet->tcp_src_port == rx_packet->tcp_src_port) {
            found=1;
            break;
            }
        if (socket->next!=NULL)
            socket=socket->next;
        else
            break;
        }


    /* Search for a listening socket */
    if (!found){
        socket = first_socket_g;
        trace("search for listening socket");

        for(;;){
            if (socket->tcp_connection_state == TCP_LISTENING) {
                if (socket->listen_port == rx_packet->tcp_dst_port)  {
                    found=1;
                    break;
                    }
                }
            if (socket->next!=NULL)
                socket=socket->next;
            else
                break;
            }
        }


    /* All available sockets being used. Add a new one to the end of the chain */
    if (!found) {
        trace("not found");
        return;
     }

    /* Copy the rx_packet structure into the socket */
    memcpy(socket->rx_packet, rx_packet, sizeof(packet_t));

    tcp_response(buf, socket);
}


/* Get the tcp source time stamp by walking through the options */
void parse_tcp_options(char * buf, packet_t* rx_packet)
{
    int ptr;

    ptr = 20;
    while (ptr < rx_packet->tcp_hdr_len-1) {
        switch (buf[ptr]) {
            case 0:  ptr=rx_packet->tcp_hdr_len; break; // end of options
            case 1:  ptr++; break;
            case 2:  ptr = ptr + buf[ptr+1]; break;  // max segment size
            case 3:
                // Window Scale
                trace("%s:L%d window scale bytes %d, 0x%x", buf[ptr+1], buf[ptr+2]);
                rx_packet->tcp_window_scale = buf[ptr+2];
                ptr = ptr + buf[ptr+1];
                break;

            case 4:  ptr = ptr + buf[ptr+1]; break;  // SACK Permitted
            case 5:  ptr = ptr + buf[ptr+1]; break;  // SACK
            case 8:
                // Time Stamp Option
                rx_packet->tcp_src_time_stamp = buf[ptr+2]<<24|buf[ptr+3]<<16|buf[ptr+4]<<8|buf[ptr+5];
                ptr = ptr + buf[ptr+1];
                break;

            case 28:  // User Timeout Option
                ptr = ptr + buf[ptr+1]; break;

            default:
                ptr++; break;
            }
        }
}


void tcp_response(char * buf, socket_t* socket)
{
    socket->packets_received++;
    trace("tcp_response");

    /* Mark the ack in the tcp tx packet buffer so the tx packet does not get resent */
    if (socket->rx_packet->tcp_flags & 0x10) // ack flag set ?
        tcp_ack(socket);


    // Other side requesting to reset a connection ?
    if (socket->rx_packet->tcp_flags & 0x04) { // RST
        // Reset the connection
        socket->tcp_disconnect = 1;
        }

    // open a connection
    else if (socket->tcp_connection_state == TCP_LISTENING) {

        if (socket->rx_packet->tcp_flags & 0x02) { // SYN
            trace("tcp_open");
            // Open connection
            tcp_open(socket);
            socket->tcp_connection_state = TCP_PENDING;
            }

        /* ACK any FIN received */
        else if (socket->rx_packet->tcp_flags & 0x01) // FIN
            tcp_reply(socket, NULL, 0);
        }


    // Sent the first ack packet to establish a connection.
    // Have just received the second packet from the server
    else if (socket->tcp_connection_state == TCP_PENDING) {
        /* Add 1 to the sequence number as a special case to open
           the connection */
        socket->tcp_tx_seq++;
        socket->tcp_connection_state = TCP_OPEN;
        }


    // connection is already open
    else {

        /* contains tcp payload */
        if (socket->rx_packet->tcp_payload_len != 0) {

            socket->tcp_bytes_received += socket->rx_packet->tcp_payload_len;
            trace("socket %d received total %d bytes", socket->id, socket->tcp_bytes_received);

            /* Ack the packet only if the payload length is non-zero */
            tcp_reply(socket, NULL, 0);

            /* Process the tcp contents */
            if (socket->rx_packet->tcp_dst_port == TELNET_PORT)
                /* telnet */
                parse_telnet_options(&buf[socket->rx_packet->tcp_hdr_len], socket);
            }
        }
}


void tcp_disconnect(socket_t * socket)
{
    telnet_t* telnet;

    if (socket->tcp_connection_state != TCP_CLOSED) {
        socket->tcp_connection_state = TCP_CLOSED;
        tcp_reply(socket, NULL, 0);

        /* app level disconnect function */
        switch(socket->app->type) {
            case APP_TELNET: telnet_disconnect(socket->app);
                              break;
            default:
                trace("Unknown app type");
        }
        socket->tcp_disconnect = 0;
    }
}



/* Transmit a string of length line_len
   Suspend interrupts so this process does not get interrupted */
void tcp_tx(socket_t* socket, char* buf, int len)
{
    /* Disable ethmac_int interrupt */
    *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLECLR ) = 0x100;

    tcp_reply(socket, buf, len);

    /* Enable ethmac_int interrupt */
    *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLESET ) = 0x100;
}



/* TODO merge this into tcp_reply */
void tcp_open(socket_t* socket)
{

    int i, j;
    unsigned short header_checksum;
    int ip_length;
    char * buf;

    buf = socket->tcp_buf[socket->tcp_current_buf]->buf;

    strncpy(&socket->dest_ip,  socket->rx_packet->src_ip, 4);
    strncpy(&socket->dest_mac, socket->rx_packet->src_mac, 6);

    /* Include 20 bytes of tcp options */
    ip_length = 20+20+20; /* 20 bytes ip header, 20 bytes tcp header, 20 bytes tcp options */

    /* fill in the information about the packet about to be sent */
    socket->tcp_buf[socket->tcp_current_buf]->payload_valid = 1;
    socket->tcp_buf[socket->tcp_current_buf]->ack_received = 0;
    socket->tcp_buf[socket->tcp_current_buf]->starting_seq = tcp_header(&buf[34], socket, 0, TCP_NEW);
    socket->tcp_buf[socket->tcp_current_buf]->ending_seq   = socket->tcp_buf[socket->tcp_current_buf]->starting_seq + 1;
    socket->tcp_buf[socket->tcp_current_buf]->len_bytes = 14+ip_length;
    set_timer(&socket->tcp_buf[socket->tcp_current_buf]->resend_time, 500);

    ip_header(&buf[14], &socket->dest_ip, ip_length, 6); /* 20 byes of tcp  options, bytes 14 to 33, ip_proto = 6, TCP*/
    ethernet_header(buf, &socket->dest_mac, 0x0800);  /* bytes 0 to 13*/

    /* transmit an ethernet frame */
    //trace("tx_packet buf 0x%d, len %d",
    //    (unsigned int)buf, socket->tcp_buf[socket->tcp_current_buf]->len_bytes);
    ethmac_tx_packet(buf, socket->tcp_buf[socket->tcp_current_buf]->len_bytes);
    socket->packets_sent++;


    /* Pick the next tx buffer to use */
    if (socket->tcp_current_buf == TCP_TX_BUFFERS-1)
        socket->tcp_current_buf=0;
    else
        socket->tcp_current_buf++;
}



void tcp_reply(socket_t* socket, char* telnet_payload, int telnet_payload_length)
{

    int i, j;
    int ip_length;
    char * buf;

    buf = socket->tcp_buf[socket->tcp_current_buf]->buf;

    ip_length = 20+20 + telnet_payload_length;

    /* Copy the payload into the transmit buffer */
    if (telnet_payload_length != 0) {
        for (i=14+ip_length-telnet_payload_length, j=0; i<14+ip_length;i++,j++) {
            buf[i] = telnet_payload[j];
            }
        }

    if (telnet_payload_length)
        socket->tcp_buf[socket->tcp_current_buf]->payload_valid = 1;
    else
        socket->tcp_buf[socket->tcp_current_buf]->payload_valid = 0;

    /* fill in the information about the packet about to be sent */
    socket->tcp_buf[socket->tcp_current_buf]->ack_received = 0;
    socket->tcp_buf[socket->tcp_current_buf]->starting_seq = tcp_header(&buf[34], socket, telnet_payload_length, TCP_NORMAL);
    socket->tcp_buf[socket->tcp_current_buf]->ending_seq   = socket->tcp_buf[socket->tcp_current_buf]->starting_seq + telnet_payload_length;
    socket->tcp_buf[socket->tcp_current_buf]->len_bytes = 14+ip_length;
    set_timer(&socket->tcp_buf[socket->tcp_current_buf]->resend_time, 500);

    /* Create the IP header */
    /* 20 byes of tcp  options, bytes 14 to 33, ip_proto = 6, TCP*/
    ip_header(&buf[14], &socket->dest_ip, ip_length, 6); /* 20 byes of tcp  options, bytes 14 to 33, ip_proto = 6, TCP*/
    ethernet_header(buf, &socket->dest_mac, 0x0800);  /* bytes 0 to 13*/

    /* transmit an ethernet frame */
    ethmac_tx_packet(buf, socket->tcp_buf[socket->tcp_current_buf]->len_bytes);
    socket->packets_sent++;


    /* Pick the next tx buffer to use */
    if (socket->tcp_current_buf == TCP_TX_BUFFERS-1)
        socket->tcp_current_buf=0;
    else
        socket->tcp_current_buf++;
}



/* Find the packets lower than or equal to seq and mark them as acked */
void tcp_ack(socket_t* socket)
{
    int i, ack_valid;
    unsigned int ack      = socket->rx_packet->tcp_ack;
    unsigned int last_ack = socket->tcp_rx_ack;

    for (i=0;i<TCP_TX_BUFFERS;i=i+1) {
        if (socket->tcp_buf[i]->payload_valid) {

            if (ack > last_ack) {
                ack_valid = (socket->tcp_buf[i]->ending_seq > last_ack) &&
                            (socket->tcp_buf[i]->ending_seq <= ack);
                }
            else { /* ack is a little after 0, last_ack is a little before 0 */
                if (socket->tcp_buf[i]->ending_seq < last_ack)
                    /* ending sequence is a little after 0 */
                    ack_valid = socket->tcp_buf[i]->ending_seq <= ack;
                else
                    ack_valid = 1;
                }

            if (ack_valid)  {
                socket->tcp_buf[i]->ack_received = 1;
                if (socket->tcp_buf[i]->ending_seq == ack) break;
                }
            }
        }

   socket->tcp_rx_ack = ack;
}


/* Check if any tcp packets need to be re-transmitted */
void tcp_retransmit(socket_t* socket)
{
    int i;

    /* Find the packet that matches seq */
    for (i=0;i<TCP_TX_BUFFERS;i=i+1) {
        if (socket->tcp_buf[i]->payload_valid && !socket->tcp_buf[i]->ack_received) {
            if (timer_expired(&socket->tcp_buf[i]->resend_time))  {

                /* Update the timer to trigger again in another little while */
                set_timer(&socket->tcp_buf[i]->resend_time, 500);

                socket->packets_resent++;

                /* Disable ethmac_int interrupt */
                *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLECLR ) = 0x100;

                /* transmit an ethernet frame */
                ethmac_tx_packet(socket->tcp_buf[i]->buf, socket->tcp_buf[i]->len_bytes);
                socket->packets_sent++;


                /* Enable ethmac_int interrupt */
                *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLESET ) = 0x100;
                break;
                }
            }
        }
}


/* return the starting seq number for this packet */
unsigned int tcp_header(char *buf, socket_t* socket, int payload_length, int options)
{
    unsigned short header_checksum;
    unsigned int seq_num;
    unsigned int ack_num;
    char flags = 0;
    unsigned short len_tcp;
    unsigned int starting_seq;

    /* Source Port */
    buf[0] = socket->rx_packet->tcp_dst_port >>8;
    buf[1] = socket->rx_packet->tcp_dst_port &0xff;

    /* Destination Port */
    buf[2] = socket->rx_packet->tcp_src_port >>8;
    buf[3] = socket->rx_packet->tcp_src_port &0xff;

    /* Sequence Number */
    /* Increment the sequence number for the next packet */
    starting_seq = socket->tcp_tx_seq;
    socket->tcp_tx_seq += payload_length;


    buf[4] =  starting_seq>>24;
    buf[5] = (starting_seq>>16)&0xff;
    buf[6] = (starting_seq>>8)&0xff;
    buf[7] =  starting_seq&0xff;


    /* Ack Number */
    if (options == TCP_NEW) {
        ack_num = socket->rx_packet->tcp_seq + 1;
        socket->tcp_rx_init_seq = socket->rx_packet->tcp_seq;
    }
    else if (socket->rx_packet->tcp_flags & 0x01) // FIN
        // +1 to the final ack
        ack_num = socket->rx_packet->tcp_seq + 1;
    else
        ack_num = socket->rx_packet->tcp_seq + socket->rx_packet->tcp_payload_len;

    socket->tcp_rx_seq= ack_num;
    //trace("socket %d received seq %d",
    //    socket->id, socket->tcp_rx_seq - socket->tcp_rx_init_seq);


    buf[8]  =  ack_num>>24;
    buf[9]  = (ack_num>>16)&0xff;
    buf[10] = (ack_num>>8)&0xff;
    buf[11] =  ack_num&0xff;


    /* Data offset with OPTIONS */
    if (options == TCP_NEW)
        buf[12] = 0xa0;  /* upper 4 bits, min is 5 */
    else
        buf[12] = 0x50;  /* upper 4 bits, min is 5 */


    /* Flags */
    flags = 0x10;       /* ACK */
    if (options == TCP_NEW)    /* Valid in first reply in new connection only */
        flags |= 0x02;  /* SYNchronise */
    if (socket->tcp_disconnect)
        flags |= 0x01;  /* FINish */
    if (socket->tcp_reset)
        flags |= 0x04;  /* Reset */

    buf[13] = flags;

    /* Window Size */
    buf[14] = socket->rx_packet->tcp_window_size >> 8;
    buf[15] = socket->rx_packet->tcp_window_size & 0xff;

    /* Checksum */
    buf[16] = 0;
    buf[17] = 0;

    /* Urgent Pointer */
    buf[18] = 0;
    buf[19] = 0;


    if (options == TCP_NEW) {
        /* OPTION: max seg size */
        buf[20] = 0x02;
        buf[21] = 0x04;
        buf[22] = 0x05;
        buf[23] = 0xb4;

        /* OPTION Sack OK */
        buf[24] = 0x04;
        buf[25] = 0x02;

        /* OPTION Time Stamp */
        buf[26] = 0x08;
        buf[27] = 0x0a;
        buf[28] = 0x00;
        buf[29] = 0x61;
        buf[30] = 0x1f;
        buf[31] = 0xc6;
        buf[32] =  socket->rx_packet->tcp_src_time_stamp>>24;
        buf[33] = (socket->rx_packet->tcp_src_time_stamp>>16)&0xff;
        buf[34] = (socket->rx_packet->tcp_src_time_stamp>>8)&0xff;
        buf[35] =  socket->rx_packet->tcp_src_time_stamp&0xff;

        /* OPTION: NOP */
        buf[36] = 0x01;

        /* OPTION Window Scale */
        buf[37] = 0x03;
        buf[38] = 0x03;
        buf[39] = 0x06;
        }


    /* Length */
    if (options == TCP_NEW)
        len_tcp = 40+payload_length;
    else
        len_tcp = 20+payload_length;


    /* header checksum */
    header_checksum = tcp_checksum(buf, socket->rx_packet, len_tcp);
    buf[16] = (header_checksum>>8)&0xff;
    buf[17] = header_checksum&0xff;

    return starting_seq;
}


unsigned short tcp_checksum(unsigned char *buf, packet_t* rx_packet, unsigned short len_tcp)
{
    unsigned short prot_tcp=6;
    unsigned short word16;
    unsigned long  sum;
    int i;

    //initialize sum to zero
    sum=0;
    if (!len_tcp) len_tcp = rx_packet->tcp_len;


    // add the TCP pseudo header which contains:
    // the IP source and destinationn addresses,
    for (i=0;i<4;i=i+2){
            word16 =((rx_packet->src_ip[i]<<8)&0xFF00)+(rx_packet->src_ip[i+1]&0xFF);
            sum=sum+word16;
    }
    for (i=0;i<4;i=i+2){
            word16 =((rx_packet->dst_ip[i]<<8)&0xFF00)+(rx_packet->dst_ip[i+1]&0xFF);
            sum=sum+word16;
    }
    // the protocol number and the length of the TCP packet
    sum = sum + prot_tcp + len_tcp;


    return header_checksum16(buf, len_tcp, sum);
}


/* handle tcp connections and process buffers
   Poll all sockets in turn for activity */
void process_tcp(socket_t* socket)
{
    telnet_t* telnet;

    /* Check if any tcp packets need to be re-transmitted */
    tcp_retransmit(socket);

    /* Handle exit command */
    if (socket->tcp_disconnect && socket->tcp_connection_state == TCP_OPEN) {
        trace("calling tcp disconnect %d",
            socket->tcp_rx_seq - socket->tcp_rx_init_seq);
        tcp_disconnect(socket);
        }

    /* Reset connection */
    else if (socket->tcp_reset) {
        socket->tcp_connection_state = TCP_CLOSED;

        telnet = (telnet_t*) socket->app->telnet;
        telnet->connection_state = TELNET_CLOSED;
        telnet->options_sent = 0;

        tcp_reply(socket, NULL, 0);
        socket->tcp_reset = 0;
        }

    /* handle telnet messages */
    else if (socket->tcp_connection_state == TCP_OPEN){

        /* app level process function */
        switch(socket->app->type) {
            case APP_TELNET: process_telnet(socket);
                             break;
            default:
                trace("Unknown app type");
        }
    }
}



void process_sockets()
{
    socket_t* socket;

    /* handle tcp connections and process buffers */
    /* Poll all sockets in turn for activity */
    socket = first_socket_g;
    for(;;){
        process_tcp(socket);
        if (socket->next!=NULL)
            socket=socket->next;
        else
            break;
        }
}
