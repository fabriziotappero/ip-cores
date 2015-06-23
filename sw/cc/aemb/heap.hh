/* $Id: heap.hh,v 1.6 2008-04-28 20:29:15 sybreon Exp $
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
   Basic heap related functions
   @file heap.hh  
 */

#ifndef _AEMB_HEAP_HH
#define _AEMB_HEAP_HH

#ifdef __cplusplus
extern "C" {
#endif

  /**
  Extracts the heap size from the linker
  @return heap size
  */
  
  inline int aembGetHeapSize()
  {
    int tmp;
    asm ("la %0, r0, _HEAP_SIZE":"=r"(tmp));
    return tmp;
  }
  
  /**
  Extracts the heap end from the linker
  @return heap end
  */
  
  inline int aembGetHeapEnd()
  {
    int tmp;
    asm ("la %0, r0, _heap_end":"=r"(tmp));
    return tmp;
  }
  
  /**
  Extracts the heap top from the linker
  @return heap top
  */
  
  inline int aembGetHeapTop()
  {
    int tmp;
    asm ("la %0, r0, _heap":"=r"(tmp));
    return tmp;
  }

#ifdef __cplusplus
}
#endif
  
#endif

/*
  $Log: not supported by cvs2svn $
  Revision 1.5  2008/04/27 16:33:42  sybreon
  License change to GPL3.

  Revision 1.4  2008/04/26 19:31:35  sybreon
  Made headers C compatible.

  Revision 1.3  2008/04/26 18:05:22  sybreon
  Minor cosmetic changes.

  Revision 1.2  2008/04/20 16:35:53  sybreon
  Added C/C++ compatible #ifdef statements

  Revision 1.1  2008/04/09 19:48:37  sybreon
  Added new C++ files

*/
