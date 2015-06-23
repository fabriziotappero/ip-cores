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
// Copyright (C) 2011-2013 Authors and OPENCORES.ORG            //
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

#include "line-buffer.h"
#include "timer.h"
#include "utilities.h"
#include "packet.h"
#include "ethmac.h"
#include "tcp.h"
#include "udp.h"
#include "telnet.h"
#include "serial.h"


int main ( void ) {
    /* Enable the serial debug port */
    init_serial();
    print_serial("Amber debug port\n\r");


    /* initialize the memory allocation system */
    init_malloc();

    /* Enable the hardware timer to generate interrrupts 100 timer per second,
       current time will start incrementing from this point onwards */
    init_timer();

    /* Create a timer to flash a led periodically */
    init_led();

    /* initialize the PHY and MAC and listen for connections
       This is the last init because packets will be received from this point
       onwards. */
    init_ethmac();

    /* create a tcp socket for listening on port 23 */
    listen_telnet();

    /* initialize the tftp stuff */
    init_tftp();


    /* Process loop. Everything is timer, interrupt and queue driven from here on down */
    while (1) {

        /* flash an led */
        process_led();

        /* Check for received tftp files and reboot */
        process_tftp();

        /* Process all socket traffic */
        process_sockets();
    }
}





