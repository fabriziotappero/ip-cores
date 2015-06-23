/* $Id: thread.hh,v 1.10 2008-04-28 20:29:15 sybreon Exp $
** 
** AEMB2 HI-PERFORMANCE CPU 
** Copyright (C) 2004-2007 Shawn Tan Ser Ngiap <shawn.tan@aeste.net>
**  
** This file is part of AEMB.
**
** AEMB is free software: you can redistribute it and/or modify it
** under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** AEMB is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
** License for more details.
**
** You should have received a copy of the GNU General Public License
** along with AEMB.  If not, see <http://www.gnu.org/licenses/>.
*/

/**
   Basic thread functions
   @file thread.hh  

   These functions deal with the various hardware threads. It also
   provides simple mechanisms for toggling semaphores.
 */

#include "aemb/msr.hh"

#ifndef _AEMB_THREAD_HH
#define _AEMB_THREAD_HH

#ifdef __cplusplus
extern "C" {
#endif

  /**
     Checks to see if currently executing Thread 1
     @return true if is Thread 1
  */
  
  inline int aembIsThread1() 
  {
    int rmsr = aembGetMSR();
    return ((rmsr & AEMB_MSR_PHA));
  }
  
  /**
     Checks to see if currently executing Thread 0
     @return true if is Thread 0
  */
  
  inline int aembIsThread0()
  {
    int rmsr = aembGetMSR();
    return (!(rmsr & AEMB_MSR_PHA));
  }
  
  /**
     Checks to see if it is multi-threaded or not.
     @return true if thread capable
  */
  inline int aembIsThreaded()
  {
    int rmsr = aembGetMSR();
    return (rmsr & AEMB_MSR_HTX);
  }

  /**
     Hardware Mutex Signal.  
     Unlock the hardware mutex, which is unlocked on reset.
   */
  inline void _aembFreeMTX()
  {
    int tmp;
    asm volatile ("msrclr %0, %1":"=r"(tmp):"K"(AEMB_MSR_MTX));
  }

  /**
     Hardware Mutex Wait.

     Waits until the hardware mutex is unlocked. This should be used
     as part of a larger software mutex mechanism.
   */
  inline void _aembLockMTX()
  {
    int rmsr;
    do 
      {
	asm volatile ("msrset %0, %1":"=r"(rmsr):"K"(AEMB_MSR_MTX));	
      }
    while (rmsr & AEMB_MSR_MTX);    
  }
    
#ifdef __cplusplus
}
#endif

#endif
