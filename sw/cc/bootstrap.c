/* $Id: bootstrap.c,v 1.5 2008-07-01 00:08:34 sybreon Exp $
** 
** BOOTSTRAP
** Copyright (C) 2008 Shawn Tan <shawn.tan@aeste.net>
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

#include <stdlib.h>
#include "memtest.hh"

/*
  BOOTSTRAP CODE

  #define SRAM_BASE - The base address of the memory block to test.
  #define SRAM_SIZE - The size of the memory block to test.
  #define BOOT_BASE - The base address of the next stage boot loader.
*/

int bootstrap ()
{
  void *fsboot = (void *) BOOT_BASE; 

  // Memory Test
  if ((memTestDataBus(SRAM_BASE) == 0) &&            // test data
      (memTestAddrBus(SRAM_BASE, SRAM_SIZE) == 0) && // test address      
#ifdef LONGTEST // 1.86kb
      (memTestFullDev(SRAM_BASE, SRAM_SIZE) == 0)    // test device
#else // 1.3kb
      true
#endif
      )    
    {      
      goto *fsboot; // on PASS: branch to boot loader
    }  
  else
    {     
      while (1); // on FAIL: lock the system
    }  
}

/*
  $Log: not supported by cvs2svn $
  Revision 1.4  2008/06/30 10:14:59  sybreon
  added some comments

  Revision 1.3  2008/06/24 10:34:40  sybreon
  updated

  Revision 1.2  2008/06/24 00:45:36  sybreon
  basic version

  Revision 1.1  2008/06/23 22:18:04  sybreon
  initial import

 */
