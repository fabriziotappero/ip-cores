/**********************************************************************
axasm Copyright 2006, 2007, 2008, 2009 
by Al Williams (alw@al-williams.com).


This file is part of axasm.

axasm is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public Licenses as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

axasm is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY: without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with axasm (see LICENSE.TXT). 
If not, see http://www.gnu.org/licenses/.

If a non-GPL license is desired, contact the author.

This is the retargetable assembler core file (header)

***********************************************************************/
#ifndef _SOLOASM_H
#define _SOLOASM_H

typedef struct
  {
  unsigned int memsize;
  unsigned int *ary;
  unsigned int psize;  // 8, 16, 32 etc. 
  unsigned int begin;
  unsigned int end;
  unsigned int err;
  } __solo_info;

#ifdef _SOLO_MAIN
extern __solo_info _solo_info;
extern char * __listtext;
#else
__solo_info _solo_info;
char * __listtext;
#endif
#endif
