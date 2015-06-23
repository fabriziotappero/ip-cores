//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_testcases.cpp"                                ////
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

#include "sc_testcases.h"


void testcases::connect_testbench(testbench* tbptr) {
    tb = tbptr;
}

void testcases::run_tests(void) {

    //---
    // Init

    tb->pkt_if0.init();
    tb->xgm_if0.init();
    tb->cpu_if0.init();
    tb->pif_gen0.init();
    tb->xgm_gen0.init();
    tb->sb.init();

    wait(300, SC_NS);

    tb->cpu_if0.enable_all_interrupts();




//    done = true;
//    return;
    //---
    // Testcases

    test_noise();

    test_packet_size(50, 90, 500);
    test_packet_size(9000, 9020, 20);
    test_packet_size(9599, 9601, 10);

    test_deficit_idle_count();

    test_crc_errors(50, 90, 300, 2);
    test_crc_errors(9000, 9020, 20, 1);

    test_txdfifo_ovflow();
    test_rxdfifo_ovflow();

    test_rx_fragments(55, 90, 300, 2);
    test_rx_lenght(20, 3);
    test_rx_coding_err(400, 4);

    test_rx_local_fault(55, 90, 600, 15);
    test_rx_remote_fault(55, 90, 600, 15);

    test_rx_pause(64, 70, 600, 5);

    test_interrupt_mask();

    done = true;

}


void testcases::test_deficit_idle_count(void) {

    int range;
    int size;

    cout << "-----------------------" << endl;
    cout << "Deficit IDLE count" << endl;
    cout << "-----------------------" << endl;

    for (range = 0; range < 8; range++) {
        for (size = 60; size < 68; size++) {
            packet_dic(size, size + range);
        }
    }

}


void testcases::packet_dic(int minsize, int maxsize) {

    sbStats_t* pif_stats;
    sbStats_t* xgm_stats;

    int cnt = 6;
    float delta;
    float cycletime = 6.4;
    float rate;

    //---
    // Setup parameters

    tb->sb.clear_stats();

    tb->pif_gen0.set_pkt_size(minsize, maxsize);
    tb->xgm_gen0.set_pkt_size(minsize, maxsize);

    //---
    // Enable traffic

    tb->pif_gen0.set_tx_bucket(cnt);
    tb->xgm_gen0.set_tx_bucket(cnt);

    //---
    // Wait for test to complete

    while (tb->pif_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    //---
    // Check traffic

    wait(1000, SC_NS);

    pif_stats = tb->sb.get_pif_stats();
    xgm_stats = tb->sb.get_xgm_stats();

    if (pif_stats->rx_pkt_cnt != cnt || xgm_stats->rx_pkt_cnt != cnt) {
        cout << "ERROR: Not all packets received." << endl;
        sc_stop();
    }

}


void testcases::test_packet_size(int min, int max, int cnt) {

    sbStats_t* pif_stats;
    sbStats_t* xgm_stats;
    rmonStats_t rmon_stats;

    cout << "-----------------------" << endl;
    cout << "Packet size" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.clear_stats();

    tb->pif_gen0.set_pkt_size(min, max);
    tb->xgm_gen0.set_pkt_size(min, max);

    //---
    // Enable traffic

    tb->pif_gen0.set_tx_bucket(cnt);
    tb->xgm_gen0.set_tx_bucket(cnt);

    //---
    // Wait for test to complete

    while (tb->pif_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    //---
    // Check traffic

    wait(30000, SC_NS);

    pif_stats = tb->sb.get_pif_stats();
    xgm_stats = tb->sb.get_xgm_stats();

    if (pif_stats->rx_pkt_cnt != cnt) {
        cout << "ERROR: Not all packets received by PIF." << endl;
        cout << pif_stats->rx_pkt_cnt << " " << cnt << endl;
        sc_stop();
    }

    if (xgm_stats->rx_pkt_cnt != cnt) {
        cout << "ERROR: Not all packets received by XGM." << endl;
        cout << xgm_stats->rx_pkt_cnt << " " << cnt << endl;
        sc_stop();
    }

    //---
    // Check stats

    tb->cpu_if0.get_rmon_stats(&rmon_stats);

    if (rmon_stats.tx_pkt_cnt != cnt) {
        cout << "ERROR: Not all TX packets counted by MAC." << endl;
        cout << rmon_stats.tx_pkt_cnt << " " << cnt << endl;
        sc_stop();
    }

    if (rmon_stats.rx_pkt_cnt != cnt) {
        cout << "ERROR: Not all RX packets counted by MAC." << endl;
        cout << rmon_stats.rx_pkt_cnt << " " << cnt << endl;
        sc_stop();
    }

    if (rmon_stats.tx_octets_cnt != xgm_stats->rx_octets_cnt) {
        cout << "ERROR: Not all TX octets counted by MAC." << endl;
        cout << rmon_stats.tx_octets_cnt << " " << xgm_stats->rx_octets_cnt << endl;
        sc_stop();
    }

    if (rmon_stats.rx_octets_cnt != pif_stats->rx_octets_cnt) {
        cout << "ERROR: Not all RX octets counted by MAC." << endl;
        cout << rmon_stats.rx_octets_cnt << " " << pif_stats->rx_octets_cnt << endl;
        sc_stop();
    }
}

void testcases::test_crc_errors(int min, int max, int cnt, int interval) {

    sbStats_t* pif_stats;
    sbCpuStats_t* cpu_stats;

    cout << "-----------------------" << endl;
    cout << "CRC errors" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.clear_stats();

    tb->xgm_gen0.set_pkt_size(min, max);
    tb->xgm_gen0.set_crc_errors(interval);
    tb->sb.disable_signal_check = true;

    //---
    // Enable traffic

    tb->xgm_gen0.set_tx_bucket(cnt);

    //---
    // Wait for test to complete

    while (tb->xgm_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    //---
    // Check traffic

    wait(30000, SC_NS);

    pif_stats = tb->sb.get_pif_stats();
    cpu_stats = tb->sb.get_cpu_stats();

    if (pif_stats->rx_pkt_cnt != cnt) {
        cout << "ERROR: Not all packets received by PIF." << endl;
        cout << pif_stats->rx_pkt_cnt << " " << cnt << endl;
        sc_stop();
    }

    if (cpu_stats->crc_error_cnt != pif_stats->crc_error_cnt) {
        cout << "ERROR: Not all CRC errors reported to cpu" << endl;
        sc_stop();
    }

    //---
    // Return parameters to default state

    tb->xgm_gen0.set_crc_errors(0);
    tb->sb.disable_signal_check = false;
}

void testcases::test_txdfifo_ovflow() {

    sbStats_t* xgm_stats;
    sbCpuStats_t* cpu_stats;

    cout << "-----------------------" << endl;
    cout << "TXD FIFO overflow" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.clear_stats();

    tb->pif_gen0.set_pkt_size(500, 500);

    tb->cpu_if0.set_param(cpu_if::TX_ENABLE, 0);
    tb->sb.disable_signal_check = true;

    //---
    // Enable traffic

    tb->pif_gen0.set_tx_bucket(2);

    //---
    // Wait for packets to be sent

    while (tb->pif_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    wait(30000, SC_NS);

    //---
    // Check errors reported

    cpu_stats = tb->sb.get_cpu_stats();
    cout << "Count: " << cpu_stats->txd_fifo_ovflow_cnt << endl;
    sc_assert(cpu_stats->txd_fifo_ovflow_cnt == 1);

    //---
    // Flush out bad packets

    tb->xgm_if0.allow_idle_errors = true;
    tb->sb.disable_packet_check = true;
    tb->cpu_if0.set_param(cpu_if::TX_ENABLE, 1);

    wait(30000, SC_NS);
    tb->xgm_if0.allow_idle_errors = false;
    tb->sb.disable_packet_check = false;

    //---
    // Check errors reported

    cpu_stats = tb->sb.get_cpu_stats();

    //---
    // Enable traffic

    tb->pif_gen0.set_tx_bucket(2);

    //---
    // Wait for packets to be sent

    while (tb->pif_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    wait(30000, SC_NS);

    xgm_stats = tb->sb.get_xgm_stats();
    sc_assert(xgm_stats->rx_pkt_cnt == 4);

    //---
    // Return parameters to default state

    tb->cpu_if0.set_param(cpu_if::TX_ENABLE, 1);
    tb->sb.disable_signal_check = false;
}

void testcases::test_rxdfifo_ovflow() {

    sbStats_t* pif_stats;
    sbCpuStats_t* cpu_stats;

    cout << "-----------------------" << endl;
    cout << "RXD FIFO overflow" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.clear_stats();

    tb->xgm_gen0.set_pkt_size(500, 500);

    tb->pkt_if0.disable_rx = true;
    tb->pkt_if0.allow_rx_sop_err = true;
    tb->sb.disable_flags_check = true;
    tb->sb.disable_packet_check = true;
    tb->sb.disable_signal_check = true;

    //---
    // Enable traffic

    tb->xgm_gen0.set_tx_bucket(3);

    //---
    // Wait for packets to be sent

    while (tb->xgm_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    wait(30000, SC_NS);

    //---
    // Check errors reported

    cpu_stats = tb->sb.get_cpu_stats();
    sc_assert(cpu_stats->rxd_fifo_ovflow_cnt == 2);

    //---
    // Flush out bad packets

    tb->pkt_if0.disable_rx = false;

    wait(30000, SC_NS);

    //---
    // Check errors reported

    cpu_stats = tb->sb.get_cpu_stats();
    tb->sb.clear_stats();
    tb->sb.disable_flags_check = false;
    tb->sb.disable_packet_check = false;

    //---
    // Enable traffic

    tb->xgm_gen0.set_tx_bucket(2);

    //---
    // Wait for packets to be sent

    while (tb->xgm_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    wait(30000, SC_NS);

    pif_stats = tb->sb.get_pif_stats();
    sc_assert(pif_stats->rx_pkt_cnt == 2);

    //---
    // Return parameters to default state

    tb->pkt_if0.allow_rx_sop_err = false;
    tb->sb.disable_signal_check = false;
}

void testcases::test_rx_fragments(int min, int max, int cnt, int interval) {

    sbStats_t* pif_stats;
    sbCpuStats_t* cpu_stats;

    cout << "-----------------------" << endl;
    cout << "Fragments errors" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.clear_stats();

    tb->xgm_gen0.set_pkt_size(min, max);
    tb->xgm_gen0.set_fragment_errors(interval);
    tb->sb.disable_signal_check = true;

    //---
    // Enable traffic

    tb->xgm_gen0.set_tx_bucket(cnt);

    //---
    // Wait for test to complete

    while (tb->xgm_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    //---
    // Check traffic

    wait(30000, SC_NS);

    pif_stats = tb->sb.get_pif_stats();
    cpu_stats = tb->sb.get_cpu_stats();

    if (pif_stats->rx_pkt_cnt != cnt) {
        cout << "ERROR: Not all packets received by PIF." << endl;
        cout << pif_stats->rx_pkt_cnt << " " << cnt << endl;
        sc_stop();
    }

    if ((cpu_stats->fragment_error_cnt + cpu_stats->crc_error_cnt)
                != pif_stats->fragment_error_cnt) {
        cout << "ERROR: Not all fragment errors reported to cpu" << endl;
        sc_stop();
    }

    //---
    // Return parameters to default state

    tb->xgm_gen0.set_fragment_errors(0);
    tb->sb.disable_signal_check = false;
}

void testcases::test_rx_lenght(int cnt, int interval) {

    sbStats_t* pif_stats;
    sbCpuStats_t* cpu_stats;

    cout << "-----------------------" << endl;
    cout << "Lenght errors" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.clear_stats();

    tb->xgm_gen0.set_pkt_size(16000-4, 16000-4);
    tb->xgm_gen0.set_lenght_errors(interval, 16000-3);
    tb->sb.disable_signal_check = true;

    //---
    // Enable traffic

    tb->xgm_gen0.set_tx_bucket(cnt);

    //---
    // Wait for test to complete

    while (tb->xgm_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    //---
    // Check traffic

    wait(60000, SC_NS);

    pif_stats = tb->sb.get_pif_stats();
    cpu_stats = tb->sb.get_cpu_stats();

    if (pif_stats->rx_pkt_cnt != cnt) {
        cout << "ERROR: Not all packets received by PIF." << endl;
        cout << pif_stats->rx_pkt_cnt << " " << cnt << endl;
        sc_stop();
    }

    if (cpu_stats->lenght_error_cnt + cpu_stats->crc_error_cnt
        != pif_stats->lenght_error_cnt) {
        cout << "ERROR: Not all lenght errors reported to cpu" << endl;
        cout << cpu_stats->lenght_error_cnt << endl;
        cout << pif_stats->lenght_error_cnt << endl;
        sc_stop();
    }

    //---
    // Return parameters to default state

    tb->sb.disable_signal_check = false;
    tb->xgm_gen0.set_lenght_errors(0, 16000-3);
}

void testcases::test_rx_coding_err(int cnt, int interval) {

    sbStats_t* pif_stats;
    sbStats_t* xgm_stats;
    sbCpuStats_t* cpu_stats;

    cout << "-----------------------" << endl;
    cout << "Coding errors" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.clear_stats();

    tb->xgm_gen0.set_pkt_size(64, 69);
    tb->xgm_gen0.set_coding_errors(interval);
    tb->sb.disable_signal_check = true;

    //---
    // Enable traffic

    tb->xgm_gen0.set_tx_bucket(cnt);

    //---
    // Wait for test to complete

    while (tb->xgm_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    //---
    // Check traffic

    wait(30000, SC_NS);

    pif_stats = tb->sb.get_pif_stats();
    xgm_stats = tb->sb.get_xgm_stats();
    cpu_stats = tb->sb.get_cpu_stats();

    if (pif_stats->rx_pkt_cnt != xgm_stats->tx_pkt_cnt) {
        cout << "ERROR: Not all packets received by PIF." << endl;
        cout << pif_stats->rx_pkt_cnt << " " << xgm_stats->tx_pkt_cnt << endl;
        sc_stop();
    }

    if (cpu_stats->crc_error_cnt != xgm_stats->crc_error_cnt) {
        cout << "ERROR: Not all coding errors reported to cpu" << endl;
        sc_stop();
    }

    //---
    // Return parameters to default state

    tb->xgm_gen0.set_coding_errors(0);
    tb->sb.disable_signal_check = false;
}

void testcases::test_rx_local_fault(int min, int max, int cnt, int interval) {

    sbStats_t* pif_stats;

    cout << "-----------------------" << endl;
    cout << "Local fault" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.clear_stats();

    tb->pif_gen0.set_pkt_size(min, max);
    tb->xgm_gen0.set_pkt_size(min, max);

    tb->xgm_gen0.set_local_fault(interval);
    tb->sb.disable_signal_check = true;
    tb->xgm_if0.allow_idle_errors = true;
    tb->xgm_if0.disable_receive = true;

    //---
    // Enable traffic

    tb->pif_gen0.set_tx_bucket(cnt);
    tb->xgm_gen0.set_tx_bucket(cnt);

    //---
    // Wait for test to complete

    while (tb->xgm_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    //---
    // Check traffic

    wait(30000, SC_NS);

    pif_stats = tb->sb.get_pif_stats();

    if (pif_stats->rx_pkt_cnt != cnt) {
        cout << "ERROR: Not all packets received by PIF." << endl;
        cout << pif_stats->rx_pkt_cnt << " " << cnt << endl;
        sc_stop();
    }

    //---
    // Return parameters to default state

    tb->xgm_gen0.set_local_fault(0);
    tb->sb.disable_signal_check = false;
    tb->xgm_if0.allow_idle_errors = false;
    tb->xgm_if0.disable_receive = false;
}

void testcases::test_rx_remote_fault(int min, int max, int cnt, int interval) {

    sbStats_t* pif_stats;

    cout << "-----------------------" << endl;
    cout << "Remote fault" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.clear_stats();

    tb->pif_gen0.set_pkt_size(min, max);
    tb->xgm_gen0.set_pkt_size(min, max);

    tb->xgm_gen0.set_remote_fault(interval);
    tb->sb.disable_signal_check = true;
    tb->xgm_if0.allow_idle_errors = true;
    tb->xgm_if0.disable_receive = true;

    //---
    // Enable traffic

    tb->pif_gen0.set_tx_bucket(cnt);
    tb->xgm_gen0.set_tx_bucket(cnt);

    //---
    // Wait for test to complete

    while (tb->xgm_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    //---
    // Check traffic

    wait(30000, SC_NS);

    pif_stats = tb->sb.get_pif_stats();

    if (pif_stats->rx_pkt_cnt != cnt) {
        cout << "ERROR: Not all packets received by PIF." << endl;
        cout << pif_stats->rx_pkt_cnt << " " << cnt << endl;
        sc_stop();
    }

    //---
    // Return parameters to default state

    tb->xgm_gen0.set_remote_fault(0);
    tb->sb.disable_signal_check = false;
    tb->xgm_if0.allow_idle_errors = false;
    tb->xgm_if0.disable_receive = false;
}

void testcases::test_rx_pause(int min, int max, int cnt, int interval) {

    sbCpuStats_t* cpu_stats;

    cout << "-----------------------" << endl;
    cout << "Receive Pause" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.clear_stats();

    tb->xgm_gen0.set_pkt_size(min, max);

    tb->xgm_gen0.set_inject_pause(interval);
    tb->sb.disable_signal_check = true;

    //---
    // Enable traffic

    tb->xgm_gen0.set_tx_bucket(cnt);

    //---
    // Wait for test to complete

    while (tb->xgm_gen0.get_tx_bucket() != 0) {
        wait(10, SC_NS);
    }

    //---
    // Check traffic

    wait(30000, SC_NS);

    cpu_stats = tb->sb.get_cpu_stats();

    if (cpu_stats->rx_pause_frame_cnt == 0) {
        cout << "ERROR: No pause frames received." << endl;
        sc_stop();
    }

    //---
    // Return parameters to default state

    tb->xgm_gen0.set_inject_pause(0);
    tb->sb.disable_signal_check = false;
}

void testcases::test_interrupt_mask() {

    sbCpuStats_t* cpu_stats;

    cout << "-----------------------" << endl;
    cout << "Interrupt Mask" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.clear_stats();
    tb->sb.disable_signal_check = true;


    //---
    // Test unmasked

    tb->cpu_if0.set_interrupt(cpu_if::INT_CRC_ERROR);

    wait(300, SC_NS);

    cpu_stats = tb->sb.get_cpu_stats();
    sc_assert(cpu_stats->crc_error_cnt == 1);


    //---
    // Test masked

    tb->cpu_if0.set_interrupt_mask(cpu_if::INT_CRC_ERROR, 0);
    tb->cpu_if0.set_interrupt(cpu_if::INT_CRC_ERROR);

    wait(300, SC_NS);

    cpu_stats = tb->sb.get_cpu_stats();
    sc_assert(cpu_stats->crc_error_cnt == 1);


    //---
    // Return parameters to default state

    tb->sb.disable_signal_check = false;
    tb->cpu_if0.set_interrupt_mask(cpu_if::INT_CRC_ERROR, 1);
}

void testcases::test_noise() {

    cout << "-----------------------" << endl;
    cout << "XGMII Noise" << endl;
    cout << "-----------------------" << endl;

    //---
    // Setup parameters

    tb->sb.disable_signal_check = true;
    tb->pkt_if0.flush_rx = true;

    //---
    // Inject noise

    tb->xgm_if0.inject_noise = true;

    while (tb->xgm_if0.inject_noise) {
        wait(100, SC_NS);
    }

    wait(30000, SC_NS);

    //---
    // Return parameters to default state

    tb->sb.disable_signal_check = true;
    tb->pkt_if0.flush_rx = false;

    wait(30000, SC_NS);
}
