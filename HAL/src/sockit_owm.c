/******************************************************************************
*                                                                             *
* Minimalistic 1-wire (onewire) master with Avalon MM bus interface           *
* Copyright (C) 2010  Iztok Jeras                                             *
* Since the code is based on an Altera app note, I kept their license.        *
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2008 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/

// this header would be used if a proper file handler could be assidned,
// but due to global variables in the public domain kit, this is not possible
//#include <fcntl.h>

#include "sys/alt_dev.h"
#include "sys/alt_irq.h"
#include "sys/ioctl.h"
#include "sys/alt_errno.h"

#include "sockit_owm_regs.h"
#include "sockit_owm.h"

extern sockit_owm_state sockit_owm;

#ifndef SOCKIT_OWM_POLLING

//////////////////////////////////////////////////////////////////////////////
// interrupt implementation
//////////////////////////////////////////////////////////////////////////////

#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void sockit_owm_irq ();
#else
static void sockit_owm_irq (alt_u32 id);
#endif

void sockit_owm_init (alt_u32 irq)
{
  int error;
  // initialize semaphore for 1-wire cycle locking
  error = ALT_FLAG_CREATE (sockit_owm.irq, 0) ||
          ALT_SEM_CREATE  (sockit_owm.cyc, 1);

  if (!error) {
    // enable interrupt
    sockit_owm.ien = 0x1;
    // register the interrupt handler
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
    alt_ic_isr_register (0, irq, sockit_owm_irq, NULL, 0x0);
#else
    alt_irq_register (irq, NULL, sockit_owm_irq);
#endif
  }
}

#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void sockit_owm_irq(void * state)
#else
static void sockit_owm_irq(void * state, alt_u32 id)
#endif
{
  // clear onewire interrupts
  IORD_SOCKIT_OWM_CTL (sockit_owm.base);
  // set the flag indicating a completed 1-wire cycle
  ALT_FLAG_POST (sockit_owm.irq, 0x1, OS_FLAG_SET);
}
#else

//////////////////////////////////////////////////////////////////////////////
// polling implementation
//////////////////////////////////////////////////////////////////////////////

#endif
