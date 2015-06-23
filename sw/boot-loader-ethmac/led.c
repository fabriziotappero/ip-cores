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
#include "timer.h"
#include "led.h"


/* global variables */
time_t* led_flash_timer_g;


void init_led()
{
    /* Turn off all LEDs */
    led_clear();

    /* create some timers */
    led_flash_timer_g = new_timer();
    set_timer(led_flash_timer_g, 500);
}


void process_led()
{
    /* Flash a heartbeat LED */
    if (timer_expired(led_flash_timer_g)) {
        led_flip(0);
        set_timer(led_flash_timer_g, 500);
        }
}


/* turn off all leds */
void led_clear()
{
    *(unsigned int *) ADR_AMBER_TEST_LED = 0;
}


/* led is either 0,1,2 or 3 */
void led_flip(int led)
{
    int current_value;
    current_value = *(unsigned int *) ADR_AMBER_TEST_LED;
    *(unsigned int *) ADR_AMBER_TEST_LED = current_value ^ (1<<led);
}



/* led is either 0,1,2 or 3 */
void led_on(int led)
{
    int current_value;
    current_value = *(unsigned int *) ADR_AMBER_TEST_LED;
    *(unsigned int *) ADR_AMBER_TEST_LED = current_value | (1<<led);
}



/* led is either 0,1,2 or 3 */
void led_off(int led)
{
    int current_value;
    current_value = *(unsigned int *) ADR_AMBER_TEST_LED;
    *(unsigned int *) ADR_AMBER_TEST_LED = current_value & ~(1<<led);
}


/* led is either 0,1,2 or 3 */
void led_123(int value)
{
    int current_value;
    current_value = *(unsigned int *) ADR_AMBER_TEST_LED;
    *(unsigned int *) ADR_AMBER_TEST_LED = (current_value & 1) | value<<1;
}
