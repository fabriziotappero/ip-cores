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

// icmp.h: defines for ICMP

#ifndef H__ICMP
#define H__ICMP

void tx_icmp_packet(unsigned char tx_type, unsigned char *szData, unsigned char nLength);
void rx_icmp_packet(unsigned char *rx_buffer);

#endif
