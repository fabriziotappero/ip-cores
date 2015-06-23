//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_pkt_generator.cpp"                            ////
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

#include "sc_pkt_generator.h"


void pkt_generator::init(void) {
    crc_interval = 0;
    fragment_interval = 0;
    lenght_err_interval = 0;
    lenght_err_size = 10000;
    coding_interval = 0;
    local_fault_interval = 0;
    remote_fault_interval = 0;
}

void pkt_generator::connect_fifo(sc_fifo<packet_t*> * fifo) {
    tx_fifo = fifo;
}


void pkt_generator::gen_packet() {

    int len = 0;
    int crc_int = 0;
    int fragment_int = 0;
    int lenght_err_int = 0;
    int coding_int = 0;
    int local_fault_int = 0;
    int remote_fault_int = 0;
    int fault_spacing = 120;
    int pause_int = 0;
    char running_cnt = 0;

    while (true) {

        wait(5, SC_NS);

        if (tx_bucket != 0 && tx_fifo->num_available() == 0) {

            //--
            // Check fifo

            if (tx_fifo == NULL || tx_fifo->num_free() == 0) {
                cout << "ERROR: FIFO not defined or full" << endl;
                sc_stop();
            }

            //---
            // Update constraints

            if (len < min_pkt_size) {
                len = min_pkt_size;
            }

            if (len > max_pkt_size) {
                len = min_pkt_size;
            }

            //--
            // Generate packet

            packet_t* pkt = new(packet_t);

            for (int i = 0; i < len+8; i++) {
                pkt->payload[i] = len+i;
            }
            pkt->payload[0] = running_cnt;
            running_cnt++;

            pkt->length = len;

            //---
            // Inject errors

            if (crc_interval != 0) {
                if (crc_int >= crc_interval) {
                    pkt->err_flags |= PKT_FLAG_ERR_CRC;
                    crc_int = 0;
                }
                else {
                    crc_int++;
                }
            }
            else {
                crc_int = 0;
            }

            if (fragment_interval != 0) {
                if (fragment_int >= fragment_interval) {
                    pkt->err_flags |= PKT_FLAG_ERR_FRG;
                    fragment_int = 0;
                }
                else {
                    fragment_int++;
                }
            }
            else {
                fragment_int = 0;
            }

            if (lenght_err_interval != 0) {
                if (lenght_err_int >= lenght_err_interval) {
                    pkt->err_flags |= PKT_FLAG_ERR_LENGHT;
                    lenght_err_int = 0;
                    pkt->length = lenght_err_size;
                }
                else {
                    lenght_err_int++;
                }
            }
            else {
                lenght_err_int = 0;
            }

            if (coding_interval != 0) {
                if (coding_int >= coding_interval) {
                    pkt->err_flags |= PKT_FLAG_ERR_CODING;
                    coding_int = 0;
                }
                else {
                    coding_int++;
                }
            }
            else {
                coding_int = 0;
            }

            //--
            // Inject local / remote faults

            if (local_fault_interval != 0) {
                if (local_fault_int >= local_fault_interval) {

                    pkt->err_flags |= PKT_FLAG_LOCAL_FAULT;
                    local_fault_int = 0;

                    fault_spacing++;
                    if (fault_spacing > (132 - 4)) {
                        fault_spacing = 120;
                    }
                    pkt->err_info = fault_spacing;
                }
                else {
                    local_fault_int++;
                }
            }
            else {
                local_fault_int = 0;
            }

            if (remote_fault_interval != 0) {
                if (remote_fault_int >= remote_fault_interval) {

                    pkt->err_flags |= PKT_FLAG_REMOTE_FAULT;
                    remote_fault_int = 0;

                    fault_spacing++;
                    if (fault_spacing > (132 - 4)) {
                        fault_spacing = 120;
                    }
                    pkt->err_info = fault_spacing;
                }
                else {
                    remote_fault_int++;
                }
            }
            else {
                remote_fault_int = 0;
            }

            //--
            // Inject PAUSE frames

            if (inject_pause_interval != 0) {
                if (pause_int >= inject_pause_interval) {

                    pkt->dest_addr = 0x0180c2;
                    pkt->dest_addr = (pkt->dest_addr << 24) | 0x000001;
                    pause_int = 0;

                }
                else {
                    pause_int++;
                }
            }

            //--
            // Send packet

            tx_fifo->write(pkt);

            tx_bucket--;
            len++;

        }
        else {
            wait(50, SC_NS);
        }

    }
}

void pkt_generator::set_tx_bucket(int cnt) {
    tx_bucket = cnt;
}

int pkt_generator::get_tx_bucket(void) {
    return tx_bucket;
}

void pkt_generator::set_pkt_size(int min, int max) {

    min_pkt_size = min;
    max_pkt_size = max;

}

void pkt_generator::set_crc_errors(int interval) {
    crc_interval = interval;
}

void pkt_generator::set_fragment_errors(int interval) {
    fragment_interval = interval;
}

void pkt_generator::set_lenght_errors(int interval, int size) {
    lenght_err_interval = interval;
    lenght_err_size = size;
}

void pkt_generator::set_coding_errors(int interval) {
    coding_interval = interval;
}

void pkt_generator::set_local_fault(int interval) {
    local_fault_interval = interval;
}

void pkt_generator::set_remote_fault(int interval) {
    remote_fault_interval = interval;
}

void pkt_generator::set_inject_pause(int interval) {
    inject_pause_interval = interval;
}
