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
#include "interrupt.h"

/* Holds all interrupt callback routines. */
static callback irq_callbacks[8];


/******************************************************************************
 * Status Register Operations                                                 *
 ******************************************************************************/
/* Set interrupts of mask. */
void set_intr(ushort mask) {
   __asm__(
      "mfc0 $k0, $12       \n\t"
      "or   $k0, $k0, $a0  \n\t"
      "mtc0 $k0, $12       \n\t"
   );
}

/* Unset interrupts of mask. */
void unset_intr(ushort mask) {
   __asm__(
      "mfc0 $k0, $12          \n\t"
      "nor  $k1, $0,  $a0     \n\t" // Negate mask.
      "and  $k0, $k0, $k1     \n\t" // Turn off those, that are set in mask.
      "mtc0 $k0, $12          \n\t"
   );
}


/******************************************************************************
 * Callback Functions                                                         *
 ******************************************************************************/
/* Registers a callback routine at some interrupt line. The interrupt line
   can be one out of IRQ_0 - IRQ_7. */
void register_callback(int irq_line, callback c) {  
   irq_callbacks[irq_line] = c;
}

/* Set a interrupt callback to NULL. If a interrupt callback points to NULL,
   the interrupt will be ignored. */
void free_callback(int irq_line) {
   irq_callbacks[irq_line] = NULL;
}

/* Call the interrupt routines one by one starting with the interrupt at INTR_0
   (or IRQ_0). Interrupts with NULL interrupt routines are ignored. */
void intr_dispatch(uchar irq) {

   // Iterate through all interrupt lines. 
   for(int i=0; i<8; i++) {
      
      // Check if callback function is defined.
      // Check if there exists a pending interrupt.
      if( ((*irq_callbacks[i]) != NULL) && (irq & 0x1) ) {      
         (*irq_callbacks[i])();
      }
      irq >>= 1;
   }
}