/* GECKO3COM
 *
 * Copyright (C) 2008 by
 *   ___    ____  _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (_  | |_| |   Bern University of Applied Sciences
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
/** \file     gecko3com_gpif.h
 *********************************************************************
 * \brief     project specific functions to handle the GPIF
 *
 *            
 *
 * \author    GNUradio team, Christoph Zimmermann bfh.ch
 * \date      2009-4-16
 *
*/

#ifndef INCLUDED_GECKO3COM_GPIF_H
#define INCLUDED_GECKO3COM_GPIF_H

/** signal that a read (data flows from the FPGA to the FX2) in in progress */
#define bmGPIF_READ_IN_PROGRESS 1  

/** signal that there is data waiting in the OUT fifo to be handled */
#define bmGPIF_PENDING_DATA 2


/** flag to signal, that the GPIF receives data from the FPGA */
volatile static idata uint8_t flGPIF;

/** \brief initialize GPIF system
 *
 *  initialize GPIF with waveform data.
 *  for this init_gpif initializes and hooks up all needed ISR's and configures
 *  auto OUT/IN mode.
 */
void init_gpif (void);


/** \brief aborts any gpif running gpif transaction  */
void abort_gpif(void);


/** \brief disables gpif system 
 *
 *  disables the GPIF I/O ports, unhooks gpif ISR's and configures 
 *  manual OUT/IN mode.
 */
void deactivate_gpif(void);


#ifdef GECKO3MAIN

/** makro to trigger a fifo read waveform */
#define gpif_trigger_read()  \
  do { 							 	        \
    GPIFREADYCFG |= bmINTRDY; /* set internal ready (INTRDY) signal */	\
    SYNCDELAY;								\
    setup_flowstate_read();						\
    SYNCDELAY;								\
    GPIFTCB3 = 0x00; 							\
    GPIFTCB2 = 0x00; 						        \
    GPIFTCB1 = 0x00; 					                \
    GPIFTCB0 = 0x01;							\
    GPIFTRIG = bmGPIF_EP6_START | bmGPIF_READ; /* trigger FIFO IN transfer */ \
    /*SYNCDELAY;*/							\
  } while (0)


/** makro to trigger a fifo write waveform */
#define gpif_trigger_write()  \
  do { 								        \
    GPIFREADYCFG |= bmINTRDY; /* set internal ready (INTRDY) signal */	\
    SYNCDELAY;								\
    setup_flowstate_write();						\
    SYNCDELAY;								\
    GPIFTCB3 = 0x00; 						        \
    GPIFTCB2 = 0x00;							\
    GPIFTCB1 = 0x00;							\
    GPIFTCB0 = 0x01;							\
    GPIFTRIG = bmGPIF_EP2_START | bmGPIF_WRITE; /* trigger FIFO OUT transfer*/ \
    /*SYNCDELAY;*/							\
  } while(0)

#endif /* GECKO3MAIN */

#endif /* INCLUDED_GECKO3COM_GPIF_H */
