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


#ifndef __SOCKIT_OWM_H__
#define __SOCKIT_OWM_H__

#include <stddef.h>

#include "sys/alt_warning.h"

#include "os/alt_sem.h"
#include "os/alt_flag.h"
#include "alt_types.h"

#ifdef __cplusplus
extern "C"
{
#endif // __cplusplus

//////////////////////////////////////////////////////////////////////////////
// global structure containing the current state of the sockit_owm driver
//////////////////////////////////////////////////////////////////////////////

typedef struct sockit_owm_state_s
{
  void*            base;            // The base address of the device
  // constants
  alt_u32          ovd_e;           // Overdrive mode               implementation enable
  alt_u32          cdr_e;           // Clock divider ratio register implementation enable
  alt_u32          own;             // Number of onewire ports
  char             btp_n[3];        // base time period for normal    mode
  char             btp_o[3];        // base time period for overdrive mode
  // clock divider ratio
  alt_u32          cdr_n;           // cdr for normal    mode
  alt_u32          cdr_o;           // cdr for overdrive mode
  alt_u32          f_dly;           // u16.16 1/ms (inverse of delay time)
  // status
  alt_u32          ien;             // interrupt enable status
  alt_u32          use;             // Aquire status
  alt_u32          ovd;             // Overdrive status
  alt_u32          pwr;             // Power status
  // OS multitasking features
  ALT_FLAG_GRP    (irq)             // interrupt event flag
  ALT_SEM         (cyc)             // transfer lock semaphore
} sockit_owm_state;

//////////////////////////////////////////////////////////////////////////////
// instantiation macro
// can be used oly once, since the driver is based on global variables
//////////////////////////////////////////////////////////////////////////////

#define SOCKIT_OWM_INSTANCE(name, state) \
  sockit_owm_state sockit_owm = { (void*) name##_BASE,  \
                                          name##_OVD_E, \
                                          name##_CDR_E, \
                                          name##_OWN,   \
                                          name##_BTP_N, \
                                          name##_BTP_O, \
                                          name##_CDR_N, \
                                          name##_CDR_O, \
                                          name##_F_DLY, \
                                          0, 0, 0, 0};  \
  void* state = (void*) name##_BASE

//////////////////////////////////////////////////////////////////////////////
// initialization function, registers the interrupt handler
//////////////////////////////////////////////////////////////////////////////

extern void sockit_owm_init(alt_u32 irq);

//////////////////////////////////////////////////////////////////////////////
// initialization macro
//////////////////////////////////////////////////////////////////////////////

#ifndef SOCKIT_OWM_POLLING
#define SOCKIT_OWM_INIT(name, state)                                       \
  if (name##_IRQ == ALT_IRQ_NOT_CONNECTED)                                 \
  {                                                                        \
    ALT_LINK_ERROR ("Error: Interrupt not connected for " #name ". "       \
                    "You have selected the interrupt driven version of "   \
                    "the sockit_owm (SoCkit 1-wire master) driver, but "   \
                    "the interrupt is not connected for this device. You " \
                    "can select a polled mode driver by checking the "     \
                    "'small driver' option in the HAL configuration "      \
                    "window, or by using the -DSOCKIT_OWM_POLLING "        \
                    "preprocessor flag.");                                 \
  }                                                                        \
  else                                                                     \
  {                                                                        \
    sockit_owm_init(name##_IRQ);                                           \
  }
#else
#define SOCKIT_OWM_INIT(name, state)
#endif

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // __SOCKIT_OWM_H__
