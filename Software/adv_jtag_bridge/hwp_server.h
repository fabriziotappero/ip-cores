/* hwp_server.h -- Header for hardware watchpoint handling
   Copyright(C) 2010 Nathan Yawn <nyawn@opencores.org>

   This file is part the advanced debug unit / bridge.  GDB does not
   have support for the OR1200's advanced hardware watchpoints.  This
   acts as a server for a client program that can read and set them. 

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

#ifndef _HWP_SERVER_H_
#define _HWP_SERVER_H_


int hwp_init(int portNum);
int hwp_server_start(void);
void hwp_server_stop(void);
int hwp_get_available_watchpoint(void);
void hwp_return_watchpoint(int wp);

#endif
