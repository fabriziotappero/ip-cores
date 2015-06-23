//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_xgmii_if.cpp"                                 ////
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

#include "sc_xgmii_if.h"

sc_fifo<packet_t*> * xgmii_if::get_tx_fifo_ptr() {
    return &tx_fifo;
}

sc_fifo<packet_t*> * xgmii_if::get_rx_fifo_ptr() {
    return &rx_fifo;
}

void xgmii_if::init(void) {
    allow_idle_errors = false;
    disable_padding = false;
    inject_noise = false;
}

void xgmii_if::connect_scoreboard(scoreboard *sbptr, scoreboard::sbSourceId sid) {
    sb = sbptr;
    sb_id = sid;
}

void xgmii_if::transmit() {

    packet_t* pkt;

    sc_uint<64> txd = 0;
    sc_uint<8> txc = 0;

    int64_t noise [] = {0x1, 0xd5555555555555fb,
                        0x1, 0xd5555555555555fb,
                        0x1, 0xd5555555555555fc,
                        0x0, 0xd5555555555555fb,
                        0x1, 0xd5555555555555fb,
                        0x0, 0xd5555555555555fb,
                        0x1, 0x1111111111111111,
                        };

    int lane = 0;
    int bytecnt = 0;
    int length = 0;
    int preamblecnt = 0;
    int ifg = 0;
    int fragment_size = 8;
    int coding_offset = 0;
    int fault_cnt = 0;
    int fault_byte = 0;
    int fault_spacing;
    int fault_spacing_cnt = 0;
    int count = 0;
    int i = 0;

    while (true) {

        if (length == 0 && tx_fifo.nb_read(pkt)) {

            if (!disable_padding) {
                pad(pkt, 60);
            }
            pack(pkt);

            calc_crc(pkt);

            //---
            // Inject errors

            if (pkt->err_flags & PKT_FLAG_ERR_CRC) {
                pkt->crc++;
            }

            if (pkt->err_flags & PKT_FLAG_ERR_FRG) {
                pkt->length = fragment_size;
                fragment_size++;
                if (fragment_size > 64) {
                    fragment_size = 8;
                }
            }

            if (pkt->err_flags & PKT_FLAG_ERR_CODING) {
                if (coding_offset >= pkt->length) {
                    pkt->err_info = pkt->length-1;
                }
                else {
                    pkt->err_info = coding_offset;
                }
                coding_offset++;
                if (coding_offset >= 70) {
                    coding_offset = 0;
                }
            }

            //---
            // Inject local / remote faults

            if (pkt->err_flags & PKT_FLAG_LOCAL_FAULT ||
                pkt->err_flags & PKT_FLAG_REMOTE_FAULT) {
                fault_cnt = 4;
                fault_byte = 4;
                fault_spacing_cnt = 0;

                fault_spacing = pkt->err_info;
                cout << "INFO: Fault insert, spacing: " << fault_spacing << endl;
            }

            //---
            // Pass packet to scoreboard

            sb->notify_packet_tx(sb_id, pkt);

            add_crc(pkt);
            strip_crc(pkt);
            length = pkt->length + 4;

            //cout << "Transmit XGMII packet:\n" << * pkt << endl;

        }


        if (ifg != 0) {
            txd |= ((sc_uint<64>)0x07) << (8 * lane);
            txc |= 0x01 << lane;
            ifg--;

        }
        else if (fault_spacing_cnt != 0) {

            txd |= ((sc_uint<64>)0x07) << (8 * lane);
            txc |= 0x01 << lane;

            fault_spacing_cnt--;

        }
        else if ((lane == 0 || lane == 4) && fault_byte == 4) {

            txd |= ((sc_uint<64>)0x9c) << (8 * lane);
            txc |= 0x01 << lane;

            fault_byte--;

        }
        else if (fault_byte == 3 || fault_byte == 2) {

            fault_byte--;

        }
        else if (fault_byte == 1) {

            if (pkt->err_flags & PKT_FLAG_LOCAL_FAULT) {
                txd |= ((sc_uint<64>)0x01) << (8 * lane);
            }
            else {
                txd |= ((sc_uint<64>)0x02) << (8 * lane);
            }
            fault_byte--;

            fault_cnt--;
            if (fault_cnt > 0) {
                fault_byte = 4;
            }

            if (fault_cnt == 1) {
                fault_spacing_cnt = 4 * fault_spacing;
            }
        }
        else if ((lane == 0 || lane == 4) && bytecnt != length && preamblecnt == 0) {

            txd |= ((sc_uint<64>)0xfb) << (8 * lane);
            txc |= 0x01 << lane;

            preamblecnt++;

        }
        else if (preamblecnt > 0 && preamblecnt < 7) {

            txd |= ((sc_uint<64>)0x55) << (8 * lane);

            preamblecnt++;

        }
        else if (preamblecnt == 7) {

            txd |= ((sc_uint<64>)0xd5) << (8 * lane);

            preamblecnt++;

        }
        else if (preamblecnt > 7 && (bytecnt == (length-4)) &&
                 (pkt->err_flags & PKT_FLAG_ERR_FRG)) {

            //---
            // Fragment insertion

            bytecnt = 0;
            length = 0;
            preamblecnt = 0;
            ifg = 0;

        }
        else if (preamblecnt >7 && bytecnt == pkt->err_info &&
                 (pkt->err_flags & PKT_FLAG_ERR_CODING)) {

            //---
            // Coding error insertion

            txc |= 0x01 << lane;
            txd |= ((sc_uint<64>)pkt->data[bytecnt]) << (8 * lane);
            bytecnt++;

        }
        else if (preamblecnt > 7 && bytecnt < length) {

            txd |= ((sc_uint<64>)pkt->data[bytecnt]) << (8 * lane);
            bytecnt++;

        }
        else if (preamblecnt > 7 && bytecnt == length) {

            //---
            // End of frame TERMINATE

            txd |= ((sc_uint<64>)0xfd) << (8 * lane);
            txc |= 0x01 << lane;

            bytecnt = 0;
            length = 0;
            preamblecnt = 0;

            // Minimum IFG is 5 including TERMINATE
            ifg = 4;

        }
        else {
            txd |= ((sc_uint<64>)0x07) << (8 * lane);
            txc |= 0x01 << lane;
        }
        if (inject_noise) {
            for (count = 0; count < 10000; count += 2) {
                i = 2 * (random() % (sizeof(noise)/16));
                cout << "NOISE: " << hex << noise[i] << " " << noise[i+1] << dec << endl;
                xgmii_rxd = noise[i+1];
                xgmii_rxc = noise[i];
                txd = 0;
                txc = 0;
                wait();
            }
            inject_noise = false;
        }
        else if (lane == 7) {
            xgmii_rxd = txd;
            xgmii_rxc = txc;
            txd = 0;
            txc = 0;
            wait();
        }
        lane = (lane + 1) % 8;

    }
};


void xgmii_if::receive() {

    packet_t* pkt;

    sc_uint<64> rxd;
    sc_uint<8> rxc;

    int lane, bytecnt, ifgcnt;

    lane = 0;

    wait();

    while (true) {

        ifgcnt = 1;

        rxd = xgmii_txd;
        rxc = xgmii_txc;


        //---
        // Wait for START code in lane0 or lane4

        while (true) {

            // Check for START character
            if (((rxd >> (8*lane)) & 0xff) == 0xfb && ((rxc >> lane) & 0x1) == 1) {
                if (disable_receive) {
                    cout << "INFO: XGMII Receive Disabled" << endl;
                }
                else {
                    break;
                }
            };

            // Check IDLE character and control lines
            if (((rxd >> (8*lane)) & 0xff) != 0x07 || ((rxc >> lane) & 0x1) != 1) {
                if (allow_idle_errors) {
                    cout << "INFO: IDLE check disabled" << endl;
                }
                else {
                    cout << "ERROR: IDLE character " << hex << rxd << " " << rxc << dec << lane << endl;
                    sc_stop();
                }
            };

            ifgcnt++;

            lane = (lane + 1) % 8;
            if (lane == 0) {
                wait();
                rxd = xgmii_txd;
                rxc = xgmii_txc;
            }
        }

        //cout << "START in lane " << lane << " IFG " << ifgcnt << endl;

        // Check starting lane
        if (lane != 0 && lane != 4) {
            cout << "ERROR: Lane aligment" << endl;
            sc_stop();
        }

        // Check for minimum inter frame gap
        if (ifgcnt < 9) {
            cout << "ERROR: MINIMUM IFG " << ifgcnt << endl;
            sc_stop();
        }

        //---
        // Capture data until end of frame is detected (TERMINATE)

        pkt = new(packet_t);
        pkt->ifg = ifgcnt;
        pkt->start_lane = lane;
        pkt->length = 0;

        bytecnt = 0;
        while (true) {

            // Look for end of frame delimiter in any lane
            if (((rxd >> (8*lane)) & 0xff) == 0xfd && ((rxc >> lane) & 0x1) == 1) {
                break;
            };

            // Stop if packet is too long
            if (bytecnt >=  10000) {
                break;
            }

            // Validate preamble bytes
            if (bytecnt > 0 && bytecnt <= 6 && ((rxd >> (8*lane)) & 0xff) != 0x55) {
                cout << "ERROR: Invalid preamble byte: " << bytecnt << endl;
                sc_stop();
            }

            // Validate SFD code in preamble
            if (bytecnt == 7 && ((rxd >> (8*lane)) & 0xff) != 0xd5) {
                cout << "ERROR: Invalid preamble byte: " << bytecnt << endl;
                sc_stop();
            }

            // Store all bytes after preamble
            if (bytecnt >  7) {
                if (((rxc >> lane) & 0x1) == 0) {
                    pkt->data[pkt->length] = ((rxd >> (8*lane)) & 0xff);
                    pkt->length++;
                }
                else {
                    cout << "ERROR: RXC high during data cycle" << endl;
                    sc_stop();
                }
            }
            else if (bytecnt > 0) {
                if (((rxc >> lane) & 0x1) == 1) {
                    cout << "ERROR: RXC high during preamble" << endl;
                    sc_stop();
                }
            }

            bytecnt++;
            lane = (lane + 1) % 8;
            if (lane == 0) {
                wait();
                rxd = xgmii_txd;
                rxc = xgmii_txc;
            }
        }


        lane = (lane + 1) % 8;
        if (lane == 0) {
            wait();
            rxd = xgmii_txd;
            rxc = xgmii_txc;
        }

        //---
        // Store packet

        strip_crc(pkt);

        unpack(pkt);
        //rx_fifo.write(pkt);
        //cout << "Received XGMII packet:" << * pkt << endl;

        //---
        // Pass packet to scoreboard

        sb->notify_packet_rx(sb_id, pkt);

    }
};


void xgmii_if::monitor() {

    sc_uint<64> rxd;
    sc_uint<8> rxc;

    wait();

    while (true) {

        rxd = xgmii_txd;
        rxc = xgmii_txc;

        //---
        // Check for local/remote fault

        if (((rxd & 0xffffffff) == 0x0100009c && (rxc & 0xf) == 0x1) &&
            (((rxd >> 32) & 0xffffffff) == 0x0100009c && ((rxc > 4) & 0xf) == 0x1)) {

            //--
            // Local fault detection

            if (!rx_local_fault) {
                cout << "XGMII Local Fault Asserted" << endl;

                // Notify Scoreboard
                sb->notify_status(sb_id, scoreboard::LOCAL_FAULT);
            }
            rx_local_fault = true;

        }
        else {

            if (rx_local_fault) {
                cout << "XGMII Local Fault De-Asserted" << endl;
            }
            rx_local_fault = false;

        }

        if (((rxd & 0xffffffff) == 0x0200009c && (rxc & 0xf) == 0x1) &&
            (((rxd >> 32) & 0xffffffff) == 0x0200009c && ((rxc > 4) & 0xf) == 0x1)) {

            //--
            // Remote fault detection

            if (!rx_remote_fault) {
                cout << "XGMII Remote Fault Asserted" << endl;

                // Notify Scoreboard
                sb->notify_status(sb_id, scoreboard::REMOTE_FAULT);
            }
            rx_remote_fault = true;

        }
        else {

            if (rx_remote_fault) {
                cout << "XGMII Remote Fault De-Asserted" << endl;
            }
            rx_remote_fault = false;

        }

        wait();
    }
};
