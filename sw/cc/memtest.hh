/* $Id: memtest.hh,v 1.8 2008-06-24 10:03:41 sybreon Exp $
** 
** MEMORY TEST FUNCTIONS
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

#ifndef MEMTEST_HH
#define MEMTEST_HH

#ifdef __cplusplus
extern "C" {
#endif

  /**
     WALKING ONES TEST
     Checks individual bit lines in O(1). Based on code at
     http://www.embedded.com/2000/0007/0007feat1list1.htm
  */
  
  static inline int memTestDataBus(int base)
  {
    volatile int *ram = (int *) base;
    for (int i=1; i!=0; i<<=1)
      {
	*ram = i; // write test value
	if (*ram != i) // read back test
	  return i;      
      }
    return 0; // 0 if success  
  }
  
  /**
     POWERS OF TWO TEST
     Checks the address lines. Based on code at
     http://www.embedded.com/2000/0007/0007feat1list2.htm
  */
  
  static inline int memTestAddrBus(int base, int len)
  {  
    volatile int *ram = (int *) base;
    const int p = 0xAAAAAAAA;
    const int q = 0x55555555;
    int nlen = (len / sizeof(int)) - 1;
    //int nlen = (SRAM_SIZE / 4) - 1;
    
    // prefill memory
    for (int i=1; (i & nlen)!=0 ; i<<=1)
      {
	ram[i] = p;
      }
    
    // check 1 - stuck high
    ram[0] = q;
    for (int i=1; (i & nlen)!=0 ; i<<=1)
      {
	if (ram[i] != p)
	  return i;
      }
    
    // check 2 - stuck low
    ram[0] = p;
    for (int j=1; (j & nlen)!=0 ; j<<=1)
      {
	ram[j] = q;
	for (int i=1; (i & nlen)!=0 ; i<<=1)
	  {
	    if ((ram[i] != p) && (i != j))
	      return i;
	  }
	ram[j] = p;
      }
    
    return 0;
  }
  
  /**
     INCREMENT TEST
     Checks the entire memory device. Based on code at
     http://www.embedded.com/2000/0007/0007feat1list3.htm
  */
  
  static inline int memTestFullDev(int base, int len)
  {
    volatile int *ram = (int *) base;
    int nlen = len / sizeof(int);
    //int nlen = (SRAM_SIZE / 4);

    // prefill the memory
    for (int p=1, i=0; i<nlen; ++p, ++i)
      {
	ram[i] = p;      
      }  
    
    // pass 1 - check and invert
    for (int p=1, i=0; i<nlen; ++p, ++i)
      {
	if (ram[i] != p)
	  return p;      
	ram[i] = ~p;      
      }
    
    // pass 2 - check and zero
    for (int p=1, i=0; i<nlen; ++p, ++i)
      {
	if (ram[i] != ~p)
	  return p;      
	ram[i] = 0;      
      }  
    
    return 0;  
  }
  
#ifdef __cplusplus
}
#endif

#endif

/*
  $Log: not supported by cvs2svn $
  Revision 1.7  2008/06/24 00:20:13  sybreon
  changed parameters passed

  Revision 1.6  2008/06/23 23:40:28  sybreon
  *** empty log message ***

  Revision 1.5  2008/06/23 22:28:00  sybreon
  resized fulldev test

  Revision 1.4  2008/06/23 22:08:39  sybreon
  Renamed functions

  Revision 1.3  2008/06/23 22:05:14  sybreon
  *** empty log message ***

  Revision 1.2  2008/06/21 10:01:35  sybreon
  *** empty log message ***

  Revision 1.1  2008/06/20 17:51:23  sybreon
  initial import

 */
