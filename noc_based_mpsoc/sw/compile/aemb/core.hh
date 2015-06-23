/* $Id: core.hh,v 1.5 2008-05-31 17:02:04 sybreon Exp $
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
   General AEMB2 core library
   @file core.hh  
 */

#ifdef  __MICROBLAZE__

#include "aemb/msr.hh"
#include "aemb/stack.hh"
#include "aemb/heap.hh"
#include "aemb/thread.hh"
#include "aemb/hook.hh"
#include "aemb/stdio.hh"
#include "aemb/semaphore.hh"

#endif

/*
  $Log: not supported by cvs2svn $
  Revision 1.4  2008/04/28 20:29:15  sybreon
  Made files C compatible under C++.

  Revision 1.3  2008/04/27 16:33:42  sybreon
  License change to GPL3.

  Revision 1.2  2008/04/26 19:31:35  sybreon
  Made headers C compatible.

  Revision 1.1  2008/04/09 19:48:37  sybreon
  Added new C++ files

 */
