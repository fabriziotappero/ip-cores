/******************************************************************************
 * Interrupts                                                                 *
 ******************************************************************************
 * Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.com>          *
 *                                                                            *
 * This program is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by       *
 * the Free Software Foundation, either version 3 of the License, or          *
 * (at your option) any later version.                                        *
 *                                                                            *
 * This program is distributed in the hope that it will be useful,            *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 * GNU General Public License for more details.                               *
 *                                                                            *
 * You should have received a copy of the GNU General Public License          *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.      *
 ******************************************************************************/
#include "stddef.h"

#ifndef _INTERRUPT_H
#define _INTERRUPT_H

/* Register a callback at line IRQ_X. */ 
#define IRQ_PIT0  0
#define IRQ_1     1
#define IRQ_2     2
#define IRQ_3     3
#define IRQ_4     4
#define IRQ_5     5
#define IRQ_6     6
#define IRQ_KEYB  7


/* Enable or disable interrupt handling. */  

#define INTR_EN      0x0001            /* Global interrupt enable. */
#define INTR_PIT0    0x0100            /* Possible interrupt line masks. */    
#define INTR_1       0x0200
#define INTR_2       0x0400
#define INTR_3       0x0800
#define INTR_4       0x1000
#define INTR_5       0x2000
#define INTR_6       0x4000
#define INTR_KEYB    0x8000


/* Type definition for the interrupt callback routines. A callback routine is
   a function with no arguments and no return value. */
typedef void (*callback)();


/******************************************************************************
 * Status Register Operations                                                 *
 ******************************************************************************/
/* Set interrupts of mask. */
extern void set_intr(ushort mask);

/* Unset interrupts of mask. */
extern void unset_intr(ushort mask);


/******************************************************************************
 * Callback Functions                                                         *
 ******************************************************************************/
/* Set a interrupt callback to NULL. If a interrupt callback points to NULL,
   the interrupt will be ignored. */
extern void register_callback(int irq_line, callback c);

/* Call the interrupt routines one by one starting with the interrupt at INTR_0
   (or IRQ_0). Interrupts with NULL interrupt routines are ignored. */
extern void free_callback(int irq_line);

#endif