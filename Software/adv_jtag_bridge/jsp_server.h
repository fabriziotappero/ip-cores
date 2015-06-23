/* jsp_server.h -- Header for the JTAG serial port
   Copyright(C) 2010 Nathan Yawn <nyawn@opencores.org>

   This file is part the advanced debug unit / bridge.  The JSP server
   acts as a telnet server, to send and receive data for the JTAG Serial 
   Port (JSP).

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

#ifndef _JSP_SERVER_H_
#define _JSP_SERVER_H_


void jsp_init(int portNum);
int jsp_server_start(void);
void jsp_server_stop(void);


#endif
