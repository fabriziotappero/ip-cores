//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_scoreboard.cpp"                               ////
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

#include "sc_scoreboard.h"


void scoreboard::init(void) {
    disable_padding = false;
    disable_crc_check = false;
    disable_packet_check = false;
    disable_flags_check = false;
    disable_signal_check = false;
}

void scoreboard::notify_packet_tx(sbSourceId sid, packet_t* pkt) {

    //---
    // Save packet to a fifo

    if (sid == SB_PIF_ID) {
        cout << "SCOREBOARD PACKET INTERFACE TX ("
             << pkt->length << ")" << endl;

        //---
        // Store packet in scoreboard

        pif_fifo.write(pkt);
        pif_stats.tx_pkt_cnt++;
        pif_stats.tx_octets_cnt = pif_stats.tx_octets_cnt + pkt->length;

    }

    if (sid == SB_XGM_ID) {

        cout << "SCOREBOARD XGMII INTERFACE TX ("
             << pkt->length << ")" << endl;

        //---
        // Store packet in scoreboard

        if (sid == SB_XGM_ID && (pkt->dest_addr & 0xffff) == 0x000001 &&
            ((pkt->dest_addr >> 24) & 0xffffff) == 0x0180c2) {

            // Pause frames will be dropped
            cout << "SCOREBOARD PAUSE INJECTED" << endl;
            xgm_stats.inject_pause_frame_cnt++;

        }
        else {

            xgm_fifo.write(pkt);
            xgm_stats.tx_pkt_cnt++;
            xgm_stats.tx_octets_cnt = xgm_stats.tx_octets_cnt + pkt->length;

        }

    }

    //---
    // Update stats

    if (sid == SB_XGM_ID && pkt->err_flags & PKT_FLAG_ERR_CODING) {
        xgm_stats.crc_error_cnt++;
    }

    if (sid == SB_XGM_ID && pkt->err_flags & PKT_FLAG_LOCAL_FAULT) {
        // If less than 4 faults in 128 columns, it will not be detected
        if (pkt->err_info <= (128 - 4)) {
            xgm_stats.inject_local_fault_cnt++;
        }
    }

    if (sid == SB_XGM_ID && pkt->err_flags & PKT_FLAG_REMOTE_FAULT) {
        // If less than 4 faults in 128 columns, it will not be detected
        if (pkt->err_info <= (128 - 4)) {
            xgm_stats.inject_remote_fault_cnt++;
        }
    }

    //cout << *pkt << endl;
}

void scoreboard::notify_packet_rx(sbSourceId sid, packet_t* pkt) {

    sbStats_t* stats;

    packet_t* pkt_tx;
    bool status;

    //---
    // Read matching packet from fifo

    if (sid == SB_PIF_ID) {
        status = xgm_fifo.nb_read(pkt_tx);
        if (status) {
            cout << "SCOREBOARD PACKET INTERFACE RX (TX SIZE="
                 << pkt_tx->length << "  RX SIZE="
                 << pkt->length << ")" << endl;
        }
    }

    if (sid == SB_XGM_ID) {
        status = pif_fifo.nb_read(pkt_tx);
        if (status) {
            cout << "SCOREBOARD XGMII INTERFACE RX (TX SIZE="
                 << pkt_tx->length << "  RX SIZE="
                 << pkt->length << ")" << endl;
        }
    }

    if (!status) {
        cout << "ERROR: FIFO EMPTY" << endl;
        sc_stop();
    }

    //---
    // Update stats

    if (sid == SB_PIF_ID) {
        stats = &pif_stats;
    }

    if (sid == SB_XGM_ID) {
        stats = &xgm_stats;
    }

    stats->rx_pkt_cnt++;

    if (stats->timestamp_first_pkt == 0) {
        stats->timestamp_first_pkt = sc_simulation_time();
    }

    stats->timestamp_last_pkt = sc_simulation_time();

    //---
    // Pad packet if it expected to be padded by MAC

    if (sid == SB_XGM_ID && !disable_padding) {
        pad(pkt_tx, 60);
    }

    //---
    // Calculate CRC

    calc_crc(pkt_tx);
    calc_crc(pkt);

    //---
    // Update byte count after padding

    stats->rx_octets_cnt = stats->rx_octets_cnt + pkt_tx->length + 4;

    //cout << *pkt_tx << *pkt << endl;

    //---
    // Compare TX and RX packets

    if (disable_packet_check) {

        cout << "INFO: Packet check disabled" << endl;

    }
    else if ((pkt_tx->err_flags & PKT_FLAG_ERR_FRG) &&
             (pkt->err_flags & PKT_FLAG_ERR_SIG)) {

        cout << "INFO: Fragment detected" << endl;

    }
    else if ((pkt_tx->err_flags & PKT_FLAG_ERR_LENGHT) &&
             (pkt->err_flags & PKT_FLAG_ERR_SIG)) {

        cout << "INFO: Lenght error detected" << endl;

    }
    else if ((pkt_tx->err_flags & PKT_FLAG_ERR_CODING) &&
             (pkt->err_flags & PKT_FLAG_ERR_SIG)) {

        cout << "INFO: Coding error detected:" << pkt_tx->err_info << endl;

    }
    else if ((sid == SB_PIF_ID || pkt->crc == pkt->crc_rx || disable_crc_check) &&
             compare(pkt_tx, pkt)) {

        //cout << "GOOD: Packets are matching" << endl;

    }
    else {

        cout << "ERROR: Packets don't match or bad CRC" << endl;

        cout << "<<<" << endl;
        cout << *pkt_tx << endl;
        cout << *pkt << endl;
        cout << ">>>" << endl;

        sc_stop();

    }

    //---
    // Check IFG against predicted IFG

    if (sid == SB_XGM_ID) {

        cout << "PKTMOD " << pkt->length % 4 \
             << " LANE " << pkt->start_lane \
             << " DIC " << stats->deficit_idle_count \
             << " IFGLEN " << stats->next_ifg_length  << endl;

        if (pkt->ifg < 1000 && stats->next_ifg_length != 1000) {
            if (pkt->ifg != stats->next_ifg_length) {
                cout << "ERROR: DIC IFG " << pkt->ifg                   \
                     << " Predicted: " << stats->next_ifg_length << endl;
                sc_stop();
            }
        }

    }

    //---
    // Update deficit idle count and predict IFG

    if (sid == SB_XGM_ID) {

        stats->next_ifg_length = 12 - (pkt->length % 4);
        stats->deficit_idle_count += (pkt->length % 4);
        if (stats->deficit_idle_count > 3) {
            stats->next_ifg_length += 4;
            stats->deficit_idle_count = stats->deficit_idle_count % 4;
        }
    }

    //---
    // Check error flags

    // CRC ERRORS

    if (sid == SB_PIF_ID && (pkt_tx->err_flags & PKT_FLAG_ERR_CRC)) {

        if (pkt->err_flags & PKT_FLAG_ERR_SIG) {

            cout << "SCOREBOARD CRC ERROR CHECKED" << endl;
            pif_stats.crc_error_cnt++;

            if (cpu_stats.crc_error_cnt+1 < pif_stats.crc_error_cnt) {
                cout << "ERROR: CRC error not reported to cpu" << endl;
                sc_stop();
            }
        }
        else {
            cout << "ERROR: CRC error not detected: " << hex << pkt->err_flags << dec << endl;
            sc_stop();
        }

        pkt->err_flags &= ~PKT_FLAG_ERR_SIG;
    }


    // FRAGMENT ERRORS

    if (sid == SB_PIF_ID && (pkt_tx->err_flags & PKT_FLAG_ERR_FRG)) {

        if (pkt->err_flags & PKT_FLAG_ERR_SIG) {

            cout << "SCOREBOARD FRAGMENT ERROR CHECKED" << endl;
            pif_stats.fragment_error_cnt++;

            if ((cpu_stats.fragment_error_cnt + cpu_stats.crc_error_cnt + 1)
                < pif_stats.fragment_error_cnt) {
                cout << "ERROR: FRAGMENT error not reported to cpu" << endl;
                sc_stop();
            }
        }
        else {
            cout << "ERROR: FRAGMENT error not detected: "
                 << hex << pkt->err_flags << dec << endl;
            sc_stop();
        }

        pkt->err_flags &= ~PKT_FLAG_ERR_SIG;
    }


    // LENGHT ERRORS

    if (sid == SB_PIF_ID && (pkt_tx->err_flags & PKT_FLAG_ERR_LENGHT)) {

        if (pkt->err_flags & PKT_FLAG_ERR_SIG) {

            cout << "SCOREBOARD LENGHT ERROR CHECKED" << endl;
            pif_stats.lenght_error_cnt++;

            if (cpu_stats.lenght_error_cnt + 1 < pif_stats.lenght_error_cnt) {
                cout << "ERROR: LENGHT error not reported to cpu" << endl;
                sc_stop();
            }
        }
        else {
            cout << "ERROR: LENGHT error not detected: "
                 << hex << pkt->err_flags << dec << endl;
            sc_stop();
        }

        pkt->err_flags &= ~PKT_FLAG_ERR_SIG;
    }


    // CODING ERRORS

    if (sid == SB_PIF_ID && (pkt_tx->err_flags & PKT_FLAG_ERR_CODING)) {

        if (pkt->err_flags & PKT_FLAG_ERR_SIG) {

            cout << "SCOREBOARD CODING ERROR CHECKED" << endl;

            if (cpu_stats.crc_error_cnt+1 < xgm_stats.crc_error_cnt) {
                cout << "CPU Count: " << cpu_stats.crc_error_cnt <<
                    " XGM Count: " << xgm_stats.crc_error_cnt << endl;
                cout << "ERROR: CODING error not reported to cpu" << endl;
                sc_stop();
            }
        }
        else {
            cout << "ERROR: CODING error not detected: "
                 << hex << pkt->err_flags << dec << endl;
            sc_stop();
        }

        pkt->err_flags &= ~PKT_FLAG_ERR_SIG;
    }


    if (pkt->err_flags != 0) {
        stats->flags_error_cnt++;
        if (!disable_flags_check) {
            cout << "ERROR: Error flags set: " << hex << pkt->err_flags << dec << endl;
            sc_stop();
        }
        else {
            cout << "INFO: Error flags set: " << hex << pkt->err_flags << dec << endl;
        }
    }

    //---
    // Delete packets

    delete(pkt_tx);
    delete(pkt);
}

void scoreboard::notify_status(sbSourceId sid, sbStatusId statusId) {

    //---
    // Detect errors

    if (sid == SB_CPU_ID && statusId == CRC_ERROR) {
        cout << "SCOREBOARD CRC_ERROR SIGNAL" << endl;
        cpu_stats.crc_error_cnt++;
    }

    if (sid == SB_CPU_ID && statusId == FRAGMENT_ERROR) {
        cout << "SCOREBOARD FRAGMENT_ERROR SIGNAL" << endl;
        cpu_stats.fragment_error_cnt++;
    }

    if (sid == SB_CPU_ID && statusId == LENGHT_ERROR) {
        cout << "SCOREBOARD LENGHT_ERROR SIGNAL" << endl;
        cpu_stats.lenght_error_cnt++;
    }

    if (sid == SB_CPU_ID && statusId == LOCAL_FAULT) {
        cout << "SCOREBOARD LOCAL_FAULT SIGNAL" << endl;
        cpu_stats.local_fault_cnt++;

        if (cpu_stats.local_fault_cnt != xgm_stats.inject_local_fault_cnt) {
            cout << "ERROR: Local fault not reported to cpu "
                 << cpu_stats.local_fault_cnt << " "
                 << xgm_stats.inject_local_fault_cnt << endl;
            sc_stop();
        }

        if (cpu_stats.local_fault_cnt != xgm_stats.detect_remote_fault_cnt) {
            cout << "ERROR: Remote fault not detected "
                 << cpu_stats.local_fault_cnt << " "
                 << xgm_stats.detect_remote_fault_cnt << endl;
            sc_stop();
        }
    }

    if (sid == SB_CPU_ID && statusId == REMOTE_FAULT) {
        cout << "SCOREBOARD REMOTE_FAULT SIGNAL" << endl;
        cpu_stats.remote_fault_cnt++;

        if (cpu_stats.remote_fault_cnt != xgm_stats.inject_remote_fault_cnt) {
            cout << "ERROR: Remote fault not reported to cpu "
                 << cpu_stats.remote_fault_cnt << " "
                 << xgm_stats.inject_remote_fault_cnt << endl;
            sc_stop();
        }

    }

    if (sid == SB_CPU_ID && statusId == RXD_FIFO_OVFLOW) {
        cout << "SCOREBOARD RXD_FIFO_OVFLOW SIGNAL" << endl;
        cpu_stats.rxd_fifo_ovflow_cnt++;
    }

    if (sid == SB_CPU_ID && statusId == RXD_FIFO_UDFLOW) {
        cout << "SCOREBOARD RXD_FIFO_UDFLOW SIGNAL" << endl;
        cpu_stats.rxd_fifo_udflow_cnt++;
    }

    if (sid == SB_CPU_ID && statusId == TXD_FIFO_OVFLOW) {
        cout << "SCOREBOARD TXD_FIFO_OVFLOW SIGNAL" << endl;
        cpu_stats.txd_fifo_ovflow_cnt++;
    }

    if (sid == SB_CPU_ID && statusId == TXD_FIFO_UDFLOW) {
        cout << "SCOREBOARD TXD_FIFO_UDFLOW SIGNAL" << endl;
        cpu_stats.txd_fifo_udflow_cnt++;
    }

    //---
    // Detect XGMII local/remote faults

    if (sid == SB_XGM_ID && statusId == LOCAL_FAULT) {
        cout << "SCOREBOARD RX LOCAL FAULT" << endl;
        xgm_stats.detect_local_fault_cnt++;
        sc_stop();
    }

    if (sid == SB_XGM_ID && statusId == REMOTE_FAULT) {
        cout << "SCOREBOARD RX REMOTE FAULT" << endl;
        xgm_stats.detect_remote_fault_cnt++;
    }

    //---
    // Packet receive indication

    if (sid == SB_CPU_ID && statusId == RX_GOOD_PAUSE_FRAME) {
        cout << "SCOREBOARD RX GOOD PAUSE FRAME SIGNAL" << endl;
        cpu_stats.rx_pause_frame_cnt++;

        if (cpu_stats.rx_pause_frame_cnt != xgm_stats.inject_pause_frame_cnt) {
            cout << "ERROR: Pause frame not reported "
                 << cpu_stats.rx_pause_frame_cnt << " "
                 << xgm_stats.inject_pause_frame_cnt << endl;
            sc_stop();
        }
    }


    if (!disable_signal_check) {
        cout << "ERROR: Signal Active" << endl;
        sc_stop();
    }
}

sbStats_t* scoreboard::get_pif_stats(void) {
    return &pif_stats;
}

sbStats_t* scoreboard::get_xgm_stats(void) {
    return &xgm_stats;
}

sbCpuStats_t* scoreboard::get_cpu_stats(void) {
    return &cpu_stats;
}

void scoreboard::clear_stats(void) {

    //---
    // Clear FIFOs

    while (pif_fifo.num_available() != 0) {
        delete(pif_fifo.read());
    }

    while (xgm_fifo.num_available() != 0) {
        delete(xgm_fifo.read());
    }

    //---
    // Clear stats

    pif_stats.tx_pkt_cnt = 0;
    pif_stats.rx_pkt_cnt = 0;
    pif_stats.tx_octets_cnt = 0;
    pif_stats.rx_octets_cnt = 0;
    pif_stats.crc_error_cnt = 0;
    pif_stats.flags_error_cnt = 0;

    xgm_stats.tx_pkt_cnt = 0;
    xgm_stats.rx_pkt_cnt = 0;
    xgm_stats.tx_octets_cnt = 0;
    xgm_stats.rx_octets_cnt = 0;
    xgm_stats.crc_error_cnt = 0;
    xgm_stats.flags_error_cnt = 0;

    pif_stats.timestamp_first_pkt = 0;
    pif_stats.timestamp_last_pkt = 0;

    xgm_stats.timestamp_first_pkt = 0;
    xgm_stats.timestamp_last_pkt = 0;

    xgm_stats.next_ifg_length = 1000;
    xgm_stats.deficit_idle_count = 0;

    cpu_stats.crc_error_cnt = 0;
    cpu_stats.fragment_error_cnt = 0;
    cpu_stats.lenght_error_cnt = 0;
    cpu_stats.rxd_fifo_ovflow_cnt = 0;
    cpu_stats.rxd_fifo_udflow_cnt = 0;
    cpu_stats.txd_fifo_ovflow_cnt = 0;
    cpu_stats.txd_fifo_udflow_cnt = 0;
}
