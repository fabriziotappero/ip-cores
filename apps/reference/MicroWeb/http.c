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

// http.c: HTTP protocol processing

#include <string.h>
#include "packets.h"
#include "tcp.h"
#include "http.h"

void http_response();
void http_error(int nStatus, char *szTitle, char *szText);
void http_header(int nStatus, char *szTitle, int nLength);

unsigned char szBuf[500];
unsigned char *pszBuf = szBuf;
unsigned char cTCB = 0;

void tx_http_packet(unsigned char *szData, unsigned char nLength)
{
    tx_tcp_packet(cTCB, 0, szData, nLength);
}

void rx_http_packet(unsigned char *szData, unsigned char nLength, unsigned char current_TCB)
{
	unsigned char method[5], path[100], protocol[10];
	char *file;
	int nFileLength;
	
	pszBuf = szBuf;
	cTCB = current_TCB;
	
	if (sscanf(szData, "%[^ ] %[^ ] %[^\r]", method, path, protocol) != 3)
		http_error(400, "Bad Request", "Unable to prarse request.");
	if (strcasecmp(method, "get") != 0)
		http_error(501, "Not Implemented", "That method is not implemented.");
	if (path[0] != '/')
		http_error(400, "Bad Request", "Bad filename.");
	file = &(path[1]);
	nFileLength = strlen(file);
	if (nFileLength == 0)
		http_response();
	else if ((strcasecmp(file, "index.html") == 0) || (strcasecmp(file, "index.htm") == 0))
		http_response();
	else
		http_error(404, "Not Found", "File not found.");
}

void http_response()
{
	http_header(200, "Ok", -1);
	pszBuf += sprintf(szBuf, "<html><head><title>%s</title></head>", _HTTP_SERVER);
	pszBuf += sprintf(szBuf, "<body>The current temperature is %d degrees Fahrenheit</body></html>", 20);
	
	tx_http_packet(szBuf, strlen(szBuf));
}

void http_error(int nStatus, char *szTitle, char *szText)
{
	http_header(nStatus, szTitle, -1);
	pszBuf += sprintf(szBuf, "<html><head><title>%s</title></head>", szTitle);
	pszBuf += sprintf(szBuf, "<body>%s</body></html>", szText);
}

void http_header(int nStatus, char *szTitle, int nLength)
{
	pszBuf += sprintf(szBuf, "%s %d %s\r\n", _HTTP_PROTOCOL, nStatus, szTitle);
	pszBuf += sprintf(szBuf, "Server: %s\r\n", _HTTP_SERVER);
	pszBuf += sprintf(szBuf, "Connection: close\r\n");
	pszBuf += sprintf(szBuf, "Content-Type: text/html\r\n");
	if (nLength > 0)
		pszBuf += sprintf(szBuf, "Content-Length: %d\r\n", nLength);
	pszBuf += sprintf(szBuf, "\r\n");
}
