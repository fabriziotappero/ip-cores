// Copyright (C) 2002 Mason Kidd (mrkidd@nettaxi.com)
//
// This file is part of MicroWeb.
//
// MicroWeb is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// MicroWeb is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MicroWeb; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

// http.h: defines for HTTP protocol

#ifndef H__HTTP
#define H__HTTP

#define _HTTP_PROTOCOL "HTTP/1.0"
#define _HTTP_SERVER "Microweb v0.1"

void tx_http_packet(unsigned char *szData, unsigned char nLength);
void rx_http_packet(unsigned char *szData, unsigned char nLength, unsigned char current_TCB);

#endif

