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
#include "timer.h"


/* Global variable for the current time */
time_t* current_time_g;


/* Create a timer object */
time_t* new_timer()
{
    time_t* timer;
    timer= malloc(sizeof(time_t));
    timer->milliseconds = 0;
    timer->seconds      = 0;
    return timer;
}



/*Initialize a global variable that keeps
  track of the current up time. Timers are
  compared against this running value.
*/
void init_timer()
{
    /* Initialize the current time object */
    current_time_g = new_timer();

    /* Configure timer 0 */
    /* Counts down from this value and generates an interrupt every 1/100 seconds */
    *(unsigned int *) ( ADR_AMBER_TM_TIMER0_LOAD ) = 1562; // 16-bit, x 256
    *(unsigned int *) ( ADR_AMBER_TM_TIMER0_CTRL ) = 0xc8;  // enable[7], periodic[6],

    /* Enable timer 0 interrupt */
    *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLESET ) = 0x020;
}


/* Set the timer to current time plus a number of milliseconds */
void set_timer (time_t* timer, int milliseconds)
{
    int seconds = _div(milliseconds, 1000);
    int mseconds = milliseconds - seconds*1000;  /* milliseconds % 1000  */

    if (current_time_g->milliseconds >= (1000 - mseconds)) {
        timer->seconds      = current_time_g->seconds + 1;
        timer->milliseconds = current_time_g->milliseconds + mseconds - 1000;
        }
    else {
        timer->seconds      = current_time_g->seconds;
        timer->milliseconds = current_time_g->milliseconds + mseconds;
        }

   timer->seconds += seconds;
}


void timer_interrupt()
{
    /* Clear timer 0 interrupt in timer */
    *(unsigned int *) ( ADR_AMBER_TM_TIMER0_CLR ) = 1;

    /* Disable timer 0 interrupt in interrupt controller */
    *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLECLR ) = 0x020;

    /* Update the global current_time variable */
    if (current_time_g->milliseconds == 990) {
        current_time_g->milliseconds = 0;
        current_time_g->seconds++;
        }
    else {
        current_time_g->milliseconds+=10;
        }

    /* Enable timer 0 interrupt in interrupt controller */
    *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLESET ) = 0x020;
}


/* Return true if timer has expired */
int timer_expired(time_t * expiry_time)
{
    if (!expiry_time->seconds && !expiry_time->milliseconds)
        /* timer is not set */
        return 0;
    else if (expiry_time->seconds < current_time_g->seconds)
        return 1;
    else if ((expiry_time->seconds      == current_time_g->seconds) &&
             (expiry_time->milliseconds < current_time_g->milliseconds))
        return 1;
    else
        return 0;
}



