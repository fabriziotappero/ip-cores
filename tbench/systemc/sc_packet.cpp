//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_packet.cpp"                                   ////
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

#include <stdio.h>
#include <iostream>
#include <sys/times.h>
#include <sys/stat.h>

#include "systemc.h"

#include "crc.h"
#include "sc_packet.h"

ostream& operator<<(ostream& os, const packet_t& p) {
    os << "\n=====================\n"
       << dec
       << "   length   : " << p.length  << "\n"
       << hex
       << "   src_addr : 0x" << p.src_addr  << "\n"
       << "   dest_addr: 0x" << p.dest_addr << "\n"
       << "   crc      : 0x" << p.crc << "\n"
       << "   crc_rx   : 0x" << p.crc_rx << "\n"
       << "   err_flags: 0x" << p.err_flags << "\n" 
       << "   payload  : " << "\n";

    for (int i = 0; i < p.length; i++) {
        os << p.payload[i] << " ";
    }

    cout << "\n--\n";

    for (int i = 0; i < p.length; i++) {
        os << p.data[i] << " ";
    }

    os << dec << "\n" << endl;

    return os;
}

void pack(packet_t* p) {
    if (p->dest_addr != 0) {
        for (int i = 0; i < 6; i++) {
            p->payload[i] = p->dest_addr >> ((5-i)*8);
        }
    }
    for (int i = 0; i < p->length; i++) {
        p->data[i] = p->payload[i];
    }
}


void unpack(packet_t* p) {
    for (int i = 0; i < p->length; i++) {
        p->payload[i] = p->data[i];
    }
}

void add_crc(packet_t* p) {
    for (int i = p->length; i < p->length + 4; i++) {
        p->data[i] = p->crc >> (8 * (i - p->length));
    }
    p->length += 4;
}

void strip_crc(packet_t* p) {
    if (p->length >= 4) {
        p->crc_rx = 0;
        for (int i = p->length - 4; i < p->length; i++) {
          p->crc_rx |= p->data[i] << (8 * (i - p->length - 4));
        }
        p->length -= 4;
    }
}

void calc_crc(packet_t* p) {

    u_int32_t crc;

    p->crc = chksum_crc32(p->data, p->length);
}

void pad(packet_t* p, int len) {
    if (p->length < len) {
        for (int i = p->length; i < len; i++) {
            p->payload[i] = 0;
        }
        p->length = len;
    };
}

bool compare(packet_t* pkta, packet_t* pktb) {

    bool good = true;

    if (pkta->length != pktb->length) {

        good = false;

    }
    else {

        if (pkta->crc != pktb->crc) {
            good = false;
        }

        for (int i = 0; i < pkta->length; i++) {
            if (pkta->payload[i] != pktb->payload[i]) {
                good = false;
            }
        }
    
    }
    
    return good;
}

