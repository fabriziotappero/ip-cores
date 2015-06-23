/* $Id: hook.hh,v 1.11 2008-04-28 20:31:40 sybreon Exp $
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
   Basic begin/end hooks
   @file hook.hh  

   These routines hook themselves onto parts of the main programme to
   enable the hardware threads to work properly. 
 */

#include "aemb/stack.hh"
#include "aemb/heap.hh"
#include "aemb/thread.hh"

#ifndef _AEMB_HOOK_HH
#define _AEMB_HOOK_HH

#ifdef __cplusplus
extern "C" {
#endif

    void _program_init();
    void _program_clean();
    
    // newlib locks
    void __malloc_lock(struct _reent *reent);
    void __malloc_unlock(struct _reent *reent);
    //void __env_lock(struct _reent *reent);
    //void __env_unlock(struct _reent *reent);
    
  /**
     Finalisation hook
     
     This function executes during the shutdown phase after the
     finalisation routine is called. It will merge the changes made
     during initialisation.
  */  

  void _program_clean()
  {     
    _aembLockMTX(); // enter critical section

    // unify the stack backwards
    if (aembIsThread0())       
      {	
	aembSetStack(aembGetStack() + (aembGetStackSize() >> 1));        
      }   
    
    _aembFreeMTX(); // exit critical section
  }
  
  /**
     Initialisation hook
  
     This function executes during the startup phase before the
     initialisation routine is called. It splits the stack between the
     threads. For now, it will lock up T0 for compatibility purposes.
  */  

  void _program_init()
  {
    _aembLockMTX(); // enter critical section

    // split and shift the stack for thread 1
    if (aembIsThread0()) // main thread
      {
	// NOTE: Dupe the stack otherwise it will FAIL!	
	int oldstk = aembGetStack();
	int newstk = aembSetStack(aembGetStack() - (aembGetStackSize() >> 1));
	aembDupStack((unsigned int *)newstk,
		     (unsigned int *)oldstk,
		     (unsigned int *)aembGetStackTop());	
	_aembFreeMTX(); // exit critical section
	while (1) asm volatile ("nop"); // lock thread
      }

    _aembFreeMTX(); // exit critical section
  }

  /**
     Heap Lock

     This function is called during malloc() to lock out the shared
     heap to avoid data corruption.
   */

  void __malloc_lock(struct _reent *reent)
  {
    _aembLockMTX();   
  }

  /**
     Heap Unlock

     This function is called during malloc() to indicate that the
     shared heap is now available for another thread.
  */

  void __malloc_unlock(struct _reent *reent)
  {
    _aembFreeMTX();
  }

#ifdef __cplusplus
}
#endif

#endif

#ifndef __OPTIMIZE__
// The main programme needs to be compiled with optimisations turned
// on (at least -O1). If not, the MUTEX value will be written to the
// same RAM location, giving both threads the same value.
OPTIMISATION_REQUIRED OPTIMISATION_REQUIRED
#endif

/*
  $Log: not supported by cvs2svn $
  Revision 1.10  2008/04/28 20:29:15  sybreon
  Made files C compatible under C++.

  Revision 1.9  2008/04/27 16:33:42  sybreon
  License change to GPL3.

  Revision 1.8  2008/04/27 16:04:42  sybreon
  Minor cosmetic changes.

  Revision 1.7  2008/04/26 19:31:35  sybreon
  Made headers C compatible.

  Revision 1.6  2008/04/26 18:04:31  sybreon
  Updated software to freeze T0 and run T1.

  Revision 1.5  2008/04/23 14:19:39  sybreon
  Fixed minor bugs.
  Initial use of hardware mutex.

  Revision 1.4  2008/04/20 16:35:53  sybreon
  Added C/C++ compatible #ifdef statements

  Revision 1.3  2008/04/12 13:46:02  sybreon
  Added malloc() lock and unlock routines

  Revision 1.2  2008/04/11 15:20:31  sybreon
  added static assert hack

  Revision 1.1  2008/04/09 19:48:37  sybreon
  Added new C++ files

*/
