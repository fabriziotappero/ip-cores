//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_packet.h"                                     ////
////                                                              ////
////  This file is part of the "10GE MAC" project                 ////
////  http://www.opencores.org/cores/xge_mac/                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - A. Tanguay (antanguay@opencores.org)                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2008 AUTHORS. All rights reserved.             ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

#ifndef PACKET_H
#define PACKET_H

#include "systemc.h"


#define PKT_FLAG_ERR_SIG      0x0001
#define PKT_FLAG_ERR_SOP      0x0002
#define PKT_FLAG_ERR_CRC      0x0004
#define PKT_FLAG_ERR_FRG      0x0008
#define PKT_FLAG_ERR_CODING   0x0010
#define PKT_FLAG_LOCAL_FAULT  0x0020
#define PKT_FLAG_REMOTE_FAULT 0x0040
#define PKT_FLAG_ERR_LENGHT   0x0080


struct packet_t {

    int length;

    // Packet fields

    sc_uint<48> dest_addr;
    sc_uint<48> src_addr;
    sc_uint<8> payload [18000];
    sc_uint<32> crc;

    sc_uint<32> crc_rx;
    sc_uint<32> err_flags;
    sc_uint<32> err_info;

    sc_uint<32> ifg;
    sc_uint<32> start_lane;

    sc_uint<8> data [20000];
};

ostream& operator<<(ostream& os, const packet_t& p);

void pack(packet_t* p);
void unpack(packet_t* p);

void add_crc(packet_t* p);
void strip_crc(packet_t* p);

void calc_crc(packet_t* p);

void pad(packet_t* p, int len);

bool compare(packet_t* pkta, packet_t* pktb);

#endif
