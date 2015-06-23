// $Id: sc_main.cpp,v 1.3 2008-06-07 02:59:55 antanguay Exp $ -*- SystemC -*-
// DESCRIPTION: Verilator Example: Top level main for invoking SystemC model
//
// Copyright 2003-2008 by Wilson Snyder. This program is free software; you can
// redistribute it and/or modify it under the terms of either the GNU
// General Public License or the Perl Artistic License.
//====================================================================

//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_main.cpp"                                     ////
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

#include "systemc.h"		// SystemC global header
//#include "SpTraceVcd.h"
#include "verilated_vcd_sc.h"  // Tracing

#include "crc.h"

#include "Vxge_mac.h"		// Top level header, generated from verilog

#include "sc_defines.h"

#include "sc_testbench.h"
#include "sc_testcases.h"


int sc_main(int argc, char* argv[]) {

    chksum_crc32gentab();

    Verilated::randReset(2);
    Verilated::debug(0);	// We compiled with it on for testing, turn it back off

    // General logfile
    ios::sync_with_stdio();

    cout << ("Defining Clocks\n");

    sc_clock clk_156m25 ("clk_156m25", 10, SC_NS, 0.5);
    sc_clock clk_wb ("clk_wb", 29, SC_NS, 0.5);
    sc_clock clk_xgmii ("clk_xgmii", 10, SC_NS, 0.5);

    sc_signal<bool> pkt_rx_ren;
    sc_signal<vluint64_t > pkt_tx_data;
    sc_signal<bool> pkt_tx_eop;
    sc_signal<unsigned int> pkt_tx_mod;
    sc_signal<bool> pkt_tx_sop;
    sc_signal<bool> pkt_tx_val;
    sc_signal<bool> reset_156m25_n;
    sc_signal<bool> reset_xgmii_n;
    sc_signal<unsigned int> wb_adr_i;
    sc_signal<bool> wb_cyc_i;
    sc_signal<unsigned int > wb_dat_i;
    sc_signal<bool> wb_rst_i;
    sc_signal<bool> wb_stb_i;
    sc_signal<bool> wb_we_i;
    sc_signal<unsigned int> xgmii_rxc;
    sc_signal<vluint64_t > xgmii_rxd;

    sc_signal<bool> pkt_rx_avail;
    sc_signal<vluint64_t > pkt_rx_data;
    sc_signal<bool> pkt_rx_eop;
    sc_signal<unsigned int> pkt_rx_mod;
    sc_signal<bool> pkt_rx_sop;
    sc_signal<bool> pkt_rx_val;
    sc_signal<bool> pkt_rx_err;
    sc_signal<bool> pkt_tx_full;
    sc_signal<bool> wb_ack_o;
    sc_signal<unsigned int> wb_dat_o;
    sc_signal<bool> wb_int_o;
    sc_signal<unsigned int> xgmii_txc;
    sc_signal<vluint64_t > xgmii_txd;

    //==========
    // Part under test

    Vxge_mac* top = new Vxge_mac("top");

    top->clk_156m25 (clk_156m25);
    top->clk_xgmii_rx (clk_xgmii);
    top->clk_xgmii_tx (clk_xgmii);

    top->pkt_rx_ren (pkt_rx_ren);
    top->pkt_tx_data (pkt_tx_data);
    top->pkt_tx_eop (pkt_tx_eop);
    top->pkt_tx_mod (pkt_tx_mod);
    top->pkt_tx_sop (pkt_tx_sop);
    top->pkt_tx_val (pkt_tx_val);
    top->reset_156m25_n (reset_156m25_n);
    top->reset_xgmii_rx_n (reset_xgmii_n);
    top->reset_xgmii_tx_n (reset_xgmii_n);
    top->wb_adr_i (wb_adr_i);
    top->wb_clk_i (clk_wb);
    top->wb_cyc_i (wb_cyc_i);
    top->wb_dat_i (wb_dat_i);
    top->wb_rst_i (wb_rst_i);
    top->wb_stb_i (wb_stb_i);
    top->wb_we_i (wb_we_i);
    top->xgmii_rxc (xgmii_rxc);
    top->xgmii_rxd (xgmii_rxd);

    top->pkt_rx_avail (pkt_rx_avail);
    top->pkt_rx_data (pkt_rx_data);
    top->pkt_rx_eop (pkt_rx_eop);
    top->pkt_rx_mod (pkt_rx_mod);
    top->pkt_rx_err (pkt_rx_err);
    top->pkt_rx_sop (pkt_rx_sop);
    top->pkt_rx_val (pkt_rx_val);
    top->pkt_tx_full (pkt_tx_full);
    top->wb_ack_o (wb_ack_o);
    top->wb_dat_o (wb_dat_o);
    top->wb_int_o (wb_int_o);
    top->xgmii_txc (xgmii_txc);
    top->xgmii_txd (xgmii_txd);

    //==========
    // Testbench

    testbench* tb = new testbench("tb");

    tb->clk_156m25 (clk_156m25);
    tb->clk_xgmii (clk_xgmii);
    tb->wb_clk_i (clk_wb);

    tb->reset_156m25_n (reset_156m25_n);
    tb->reset_xgmii_n (reset_xgmii_n);
    tb->wb_rst_i (wb_rst_i);

    tb->wb_ack_o (wb_ack_o);
    tb->wb_dat_o (wb_dat_o);
    tb->wb_int_o (wb_int_o);

    tb->wb_adr_i (wb_adr_i);
    tb->wb_cyc_i (wb_cyc_i);
    tb->wb_dat_i (wb_dat_i);
    tb->wb_stb_i (wb_stb_i);
    tb->wb_we_i (wb_we_i);

    tb->xgmii_rxc (xgmii_rxc);
    tb->xgmii_rxd (xgmii_rxd);

    tb->xgmii_txc (xgmii_txc);
    tb->xgmii_txd (xgmii_txd);

    tb->pkt_tx_data (pkt_tx_data);
    tb->pkt_tx_eop (pkt_tx_eop);
    tb->pkt_tx_mod (pkt_tx_mod);
    tb->pkt_tx_sop (pkt_tx_sop);
    tb->pkt_tx_val (pkt_tx_val);

    tb->pkt_tx_full (pkt_tx_full);

    tb->pkt_rx_avail (pkt_rx_avail);
    tb->pkt_rx_data (pkt_rx_data);
    tb->pkt_rx_eop (pkt_rx_eop);
    tb->pkt_rx_mod (pkt_rx_mod);
    tb->pkt_rx_err (pkt_rx_err);
    tb->pkt_rx_sop (pkt_rx_sop);
    tb->pkt_rx_val (pkt_rx_val);

    tb->pkt_rx_ren (pkt_rx_ren);

    //==========
    // Testcases
    testcases* tc = new testcases("tc");

    tc->connect_testbench(tb);


#if WAVES
    // Before any evaluation, need to know to calculate those signals only used for tracing
    Verilated::traceEverOn(true);
#endif

    // You must do one evaluation before enabling waves, in order to allow
    // SystemC to interconnect everything for testing.
    cout <<("Test initialization...\n");

    sc_start(1, SC_NS);

    reset_156m25_n = 0;
    wb_rst_i = 1;
    reset_xgmii_n = 0;

    sc_start(1, SC_NS);

#if WAVES
    cout << "Enabling waves...\n";
    VerilatedVcdSc* tfp = new VerilatedVcdSc;
    top->trace (tfp, 99);
    tfp->open ("vl_dump.vcd");
#endif

    //==========
    // Start of Test

    cout <<("Test beginning...\n");

    reset_156m25_n = 0;
    wb_rst_i = 1;
    reset_xgmii_n = 0;

    while (!tc->done) {

#if WAVES
        tfp->flush();
#endif
        if (VL_TIME_Q() > 10) {
            reset_156m25_n = 1;
            wb_rst_i = 0;
            reset_xgmii_n = 1;
        }

        sc_start(1, SC_NS);
    }

    top->final();

#if WAVES
    tfp->close();
#endif

    cout << "*-* All Finished *-*\n";

    return(0);
}
