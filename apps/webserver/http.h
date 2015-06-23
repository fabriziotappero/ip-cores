//********************************************************************************************
//
// File : http.h implement for Hyper Text transfer Protocol
//
//********************************************************************************************
//
// Copyright (C) 2007
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 2 of the License, or (at your option) any later
// version.
// This program is distributed in the hope that it will be useful, but
//
// WITHOUT ANY WARRANTY;
//
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, write to the Free Software Foundation, Inc., 51
// Franklin St, Fifth Floor, Boston, MA 02110, USA
//
// http://www.gnu.de/gpl-ger.html
//
//********************************************************************************************

//********************************************************************************************
//
// Prototype function
//
//********************************************************************************************
extern WORD http_home( BYTE *rxtx_buffer );
extern BYTE http_get_variable ( BYTE *rxtx_buffer, WORD dlength, BYTE *val_key, BYTE *dest );
extern BYTE http_get_ip ( BYTE *buf, BYTE *dest );
extern void urldecode( BYTE *urlbuf);
extern void http_webserver_process ( BYTE *rx_buffer, BYTE **tx_buffer, BYTE *dest_mac, BYTE *dest_ip );
extern WORD http_put_request ( BYTE *rxtx_buffer );
