/* $Id: simboard.hh,v 1.7 2008-04-28 20:40:40 sybreon Exp $
** 
** AEMB Function Verification C++ Testbench
** Copyright (C) 2004-2008 Shawn Tan <shawn.tan@aeste.net>
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

#include "aemb/msr.hh"
#include <stdlib.h>
#include <stdio.h>

#ifndef SIMBOARD_HH
#define SIMBOARD_HH

#define CODE_FAIL 0xDEADBEEF
#define CODE_PASS 0xCAFEF00D

#ifdef __cplusplus
extern "C" {
#endif

/*
I/O FUNCTIONS
*/
void outbyte(char c) 
{
  volatile char *COUT = (char *) 0xFFFFFFC0;
  *COUT = c;
}

char inbyte() 
{
  return 0;
}

#ifdef __cplusplus
}
#endif

#endif

/*
$Log: not supported by cvs2svn $
Revision 1.6  2008/04/27 16:35:16  sybreon
Minor code cleanup.

Revision 1.5  2008/04/27 16:04:42  sybreon
Minor cosmetic changes.

Revision 1.4  2008/04/26 19:32:00  sybreon
Made headers C compatible.

Revision 1.3  2008/04/26 18:07:19  sybreon
Minor cosmetic changes.

Revision 1.2  2008/04/21 12:13:12  sybreon
Passes arithmetic tests with single thread.

Revision 1.1  2008/04/11 15:32:28  sybreon
initial checkin

*/
