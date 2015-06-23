/* $Id: semaphore.hh,v 1.1 2008-04-28 20:29:15 sybreon Exp $
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
   General semaphore library
   @file semaphore.hh  
 */

#include "aemb/thread.hh"

#ifndef _AEMB_SEMAPHORE_HH
#define _AEMB_SEMAPHORE_HH

#ifdef __cplusplus
extern "C" {
#endif

  // TODO: Extend this library to include threading mechanisms such as
  // semaphores, mutexes and such.

  /**
     Semaphore struct.     
     Presently implemented as software solution but a hardware one may be
     required as the threads are hardware.
  */
  
  typedef int semaphore;

  /**
     Software Semaphore Signal.

     Increment the semaphore and run. This is a software mechanism.
  */
  inline void aembSignal(volatile semaphore _sem) 
  { 
    _aembLockMTX();
    _sem++; 
    _aembFreeMTX();
  }
    
  /**
     Software Semaphore Wait.

     Decrement the semaphore and block if < 0. This is a software
     mechanism.
  */
  inline void aembWait(volatile semaphore _sem) 
  {
    _aembLockMTX();
    _sem--; 
    _aembFreeMTX();
    while (_sem < 0); 
  }

  semaphore __mutex_rendezvous0 = 0; ///< internal rendezvous mutex
  semaphore __mutex_rendezvous1 = 1; ///< internal rendezvous mutex

  /**
     Implements a simple rendezvous mechanism
   */
  /*
  inline void aembRendezvous()
  {
    if (isThread1())
      {
	wait(__mutex_rendezvous0);
	signal(__mutex_rendezvous1);
      }
    else
      {
	signal(__mutex_rendezvous0);
	wait(__mutex_rendezvous1);
      }
  }
  */

#ifdef __cplusplus
}
#endif

#endif

/*
$log$
*/
