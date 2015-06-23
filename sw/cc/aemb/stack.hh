/* $Id: stack.hh,v 1.8 2008-04-28 20:29:15 sybreon Exp $
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
   Basic stack related functions
   @file stack.hh  
 */

#ifndef _AEMB_STACK_HH
#define _AEMB_STACK_HH

#ifdef __cplusplus
extern "C" {
#endif

  /**
  Reads the size of the memory space allocated for the stack in bytes.
  @return size of stack
  */
  
  inline int aembGetStackSize()
  {
    int tmp;
    asm ("la %0, r0, _STACK_SIZE":"=r"(tmp));
    return tmp;
  }
  
  /**
  Reads the end of the memory space allocated for the stack. This is
  where the stack ends.
  @return end of stack
  */
  
  inline int aembGetStackEnd()
  {
    int tmp;
    asm ("la %0, r0, _stack_end":"=r"(tmp));
    return tmp;
  }
  
  /**
  Reads the top of the memory space allocated for the stack. This is
  where the stack starts.
  @return top of stack
  */
  
  inline int aembGetStackTop()
  {
    int tmp;
    asm ("la %0, r0, _stack":"=r"(tmp));
    return tmp;
  }
  
  /**
  Reads register R1 which is the designated stack pointer.  
  @return stack pointer
  */
  
  inline int aembGetStack()
  {
    int tmp;
    asm ("addk %0, r0, r1":"=r"(tmp));
    return tmp;
  }
  
  /**
  Sets register R1 to the new stack pointer.
  @param stk new stack pointer
  @return new stack pointer
  */
  
  inline int aembSetStack(int stk)
  {
    asm ("addk r1, r0, %0"::"r"(stk));
    return stk;
  }

  /**
     Duplicates the stack
     @param newp new stack pointer
     @param oldp old stack pointer
     @param endp end of the stack
  */

  inline void aembDupStack(unsigned int *newp, unsigned int *oldp, unsigned int *endp)
  {
    while (oldp < endp)
      {
	// copy the stack content
	*newp = *oldp;
	// this increments 1 word (not 1 byte)
	newp++; 
	oldp++;
      }
  }

#ifdef __cplusplus
}
#endif

#endif

/*
  $Log: not supported by cvs2svn $
  Revision 1.7  2008/04/27 16:33:42  sybreon
  License change to GPL3.

  Revision 1.6  2008/04/27 16:04:42  sybreon
  Minor cosmetic changes.

  Revision 1.5  2008/04/26 19:31:35  sybreon
  Made headers C compatible.

  Revision 1.4  2008/04/26 18:04:31  sybreon
  Updated software to freeze T0 and run T1.

  Revision 1.3  2008/04/23 14:19:39  sybreon
  Fixed minor bugs.
  Initial use of hardware mutex.

  Revision 1.2  2008/04/20 16:35:53  sybreon
  Added C/C++ compatible #ifdef statements

  Revision 1.1  2008/04/09 19:48:37  sybreon
  Added new C++ files

*/
