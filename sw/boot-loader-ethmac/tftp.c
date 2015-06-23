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
#include "udp.h"
#include "tcp.h"
#include "tftp.h"
#include "elfsplitter.h"


block_t*    udp_file_g = NULL;
block_t*    udp_current_block_g = NULL;
time_t*     reboot_timer_g;
int         reboot_stage_g;


block_t* init_buffer_512()
{
    block_t* block = malloc(sizeof(block_t));
    block->buf512 = malloc(512);
    block->next   = NULL;
    block->bytes  = 0;
    block->last_block  = 0;
    block->total_bytes  = 0;
    block->total_blocks  = 0;
    block->ready  = 0;
    block->filename  = NULL;
    block->linux_boot = 0;
    return block;
}


void parse_tftp_packet(char * buf, packet_t* rx_packet, int tftp_len, unsigned int udp_src_port, unsigned int udp_dst_port)
{
    int mode_offset;
    int binary_mode;

    unsigned int opcode = buf[8]<<8|buf[9];
    unsigned int block  = buf[10]<<8|buf[11];

    mode_offset = next_string(&buf[10]);
    binary_mode = strcmp("octet", &buf[10+mode_offset]);

    switch (opcode) {

        case  UDP_READ:
            udp_reply(rx_packet, udp_dst_port, udp_src_port, 0, UDP_ERROR);
            break;

        case  UDP_WRITE:
            udp_file_g = init_buffer_512();
            udp_file_g->filename = malloc(256);
            strcpy(udp_file_g->filename, &buf[10]);

            if (strncmp(&buf[10], "vmlinux", 7) == 0)
                udp_file_g->linux_boot = 1;

            udp_current_block_g = udp_file_g;

            if (binary_mode)
                udp_reply(rx_packet, udp_dst_port, udp_src_port, 0, UDP_ACK);
            else
                udp_reply(rx_packet, udp_dst_port, udp_src_port, 0, UDP_ERROR);
            break;


        case  UDP_DATA:
            udp_reply(rx_packet, udp_dst_port, udp_src_port, block, UDP_ACK);

            if (block > udp_file_g->last_block) {
                // Have not already received this block
                udp_file_g->last_block = block;

                /* receive and save a block */
                udp_current_block_g->bytes = tftp_len;
                udp_file_g->total_bytes += tftp_len;
                udp_file_g->total_blocks++;

                memcpy(udp_current_block_g->buf512, &buf[12], tftp_len);

                /* Prepare the next block */
                if (tftp_len == 512) {
                    udp_current_block_g->next = init_buffer_512();
                    udp_current_block_g = udp_current_block_g->next;
                    }
                else { /* Last block */
                    udp_file_g->ready = 1;
                    }
                }
            break;


        default: break;
        }
}



void init_tftp()
{
    reboot_timer_g = new_timer();
    reboot_stage_g = 0;
}


void process_tftp ()
{
    socket_t* socket;

    /* Check for newly downloaded tftp file. Add to all tx buffers */
    /* Has a file been uploaded via tftp ? */
    if (udp_file_g != NULL) {
        /* Notify telnet clients that file has been received */
        if (udp_file_g->ready) {
            udp_file_g->ready = 0;

            print_serial("Received file %s, %d bytes",
                udp_file_g->filename, udp_file_g->total_bytes);
            if (udp_file_g->linux_boot)
                print_serial(", linux image detected\r\n");
            else
                print_serial("\r\n");

            if (process_file() == 0) {
                /* Disconnect in 1 second */
                set_timer(reboot_timer_g, 1000);
                }
            else
                print_serial("Not an elf file\r\n");
            }
        }

    /* reboot timer expired */
    if (timer_expired(reboot_timer_g)) {
        /* First stage of reboot sequence is to nicely disconnect */
        if (reboot_stage_g == 0) {
            set_timer(reboot_timer_g, 1000);
            reboot_stage_g = 1;
            socket = first_socket_g;
            if (socket != NULL){
                for(;;){
                    socket->tcp_disconnect = 1;
                    if (socket->next!=NULL)
                        socket=socket->next;
                    else
                        break;
                    }
                }
            }
        else {
        /* Second stage of reboot sequence is to turn off ethmac and then jump to restart vector */
            close_link();
            reboot();
            }
        }
}



/* copy tftp file into a single contiguous buffer so
   if can be processed by elf splitter */
int process_file()
{
    block_t* block;
    char*    buf512;
    char*    tftp_file;
    char*    line;
    int      line_len;
    int      ret;

    tftp_file = malloc(udp_file_g->total_bytes);

    block = udp_file_g;
    buf512= tftp_file;

    while (block->next) {
        memcpy(buf512, block->buf512, block->bytes);
        buf512=&buf512[512];
        block=block->next;
        }
    memcpy(buf512, block->buf512, block->bytes);
    buf512=&buf512[512];

    return elfsplitter(tftp_file);
}


/* Disable interrupts
   Load new values into the interrupt vector memory space
   Jump to address 0
*/
void reboot()
{
   int i;

   /* Disable all interrupts */
   /* Disable ethmac_int interrupt */
   /* Disable timer 0 interrupt in interrupt controller */
   *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLECLR ) = 0x120;

   for(i=0;i<MEM_BUF_ENTRIES;i++)
       if (elf_mem0_g->entry[i].valid)
           *(char *)(i) = elf_mem0_g->entry[i].data;

   if (udp_file_g->linux_boot) {
        print_serial("linux reboot\n\r");
        _jump_to_program(LINUX_JUMP_ADR);
        }
   else {
        print_serial("normal reboot\n\r");
        _restart();
        }
}
