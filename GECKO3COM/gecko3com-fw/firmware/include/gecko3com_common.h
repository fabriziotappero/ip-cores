/* GECKO3COM
 *
 * Copyright (C) 2008 by
 *   ___    ____  _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (_  | |_| |   Berne University of Applied Sciences
 *  |  _ <'|  _) |  _  |   School of Engineering and
 *  | (_) )| |   | | | |   Information Technology
 *  (____/'(_)   (_) (_)
 *
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details. 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*********************************************************************/
/** \file     gecko3com_common.h
 *********************************************************************
 * \brief     common defines and prototypes for GECKO3COM
 *
 * \author    GNUradio, Christoph Zimmermann bfh.ch
 * \date      
 *
*/

#ifndef _GECKO3COMCOMMON_H_
#define _GECKO3COMCOMMON_H_

#include <stdint.h>
#include "syncdelay.h"
#include "gecko3com_regs.h"
#include "i2c.h"
#include "gecko3com_i2c.h"

#define	TRUE		1     /**< TRUE */
#define	FALSE		0     /**< FALSE */

/* Defines for LED output colors */
#define RED 					0x02  /**< Switch bi-color LED to RED */
#define GREEN 					0x04  /**< Switch bi-color LED to GREEN */
#define ORANGE 					0x06  /**< Switch bi-color LED to ORANGE */
#define LEDS_OFF				0x00  /**< Switch bi-color LED off */

/** flag to store the state of the LED */
extern volatile uint8_t flLED;


/* defines and global variable for context switching between EZ-USB and GPIF/FPGA */
#define GECKO3COM_LOCAL       0 /**< firmware parses commands */
#define GECKO3COM_REMOTE      1 /**< no commands parsed, data passed to fpga */

/** flag to signal who interpretes TMC messages */
extern volatile uint8_t flLOCAL; 



/** initialize all board specific stuff */
void init_gecko3com (void);

/** initialize the GPIF system of the EZ-USB FX2 */
void init_gpif (void);

/** resets the connected FPGA and the connected modules */
void gecko3com_system_reset(void);

/** switch LED0 on or off
 * \param[in] on this value is active low, write 0 to activate LED0 */
void set_led_0 (const uint8_t on);

/** switch LED1 on or off
 * \param[in] on this value is active low, write 0 to activate LED1 */
void set_led_1 (const uint8_t on);

/** toogles LED0. Connected to Port C. Debug purpose only! */
void toggle_led_0 (void);

/** toogles LED1  Connected to Port C. Debug purpose only! */
void toggle_led_1 (void);

/** initialize the external I2C I/O Expander */
void init_io_ext (void);

/** function that write to external LEDs (connected through I2C I/O Expander) */
void set_led_ext (const uint8_t color);

/** function that read the external switch (connected through I2C I/O Expander) */
uint8_t get_switch (void);

#endif /* _GECKO3COMCOMMON_H_ */
