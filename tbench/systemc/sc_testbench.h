//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_testbench.h"                                  ////
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

#ifndef TESTBENCH_H
#define TESTBENCH_H

#include "systemc.h"		// SystemC global header

#include "sc_defines.h"

#include "sc_cpu_if.h"
#include "sc_pkt_if.h"
#include "sc_xgmii_if.h"
#include "sc_pkt_generator.h"
#include "sc_scoreboard.h"

SC_MODULE(testbench) {

  public:

    //---
    // Ports

    sc_in<bool> clk_156m25;
    sc_in<bool> clk_xgmii;
    sc_in<bool> wb_clk_i;

    sc_in<bool> reset_156m25_n;
    sc_in<bool> reset_xgmii_n;
    sc_in<bool> wb_rst_i;

    sc_in<bool> wb_ack_o;
    sc_in<unsigned int> wb_dat_o;
    sc_in<bool> wb_int_o;

    sc_out<unsigned int> wb_adr_i;
    sc_out<bool> wb_cyc_i;
    sc_out<unsigned int> wb_dat_i;
    sc_out<bool> wb_stb_i;
    sc_out<bool> wb_we_i;

    sc_out<unsigned int> xgmii_rxc;
    sc_out<vluint64_t > xgmii_rxd;

    sc_in<unsigned int> xgmii_txc;
    sc_in<vluint64_t > xgmii_txd;

    sc_out<vluint64_t > pkt_tx_data;
    sc_out<bool> pkt_tx_eop;
    sc_out<unsigned int> pkt_tx_mod;
    sc_out<bool> pkt_tx_sop;
    sc_out<bool> pkt_tx_val;

    sc_in<bool> pkt_tx_full;

    sc_in<bool> pkt_rx_avail;
    sc_in<vluint64_t > pkt_rx_data;
    sc_in<bool> pkt_rx_eop;
    sc_in<unsigned int> pkt_rx_mod;
    sc_in<bool> pkt_rx_err;
    sc_in<bool> pkt_rx_sop;
    sc_in<bool> pkt_rx_val;

    sc_out<bool> pkt_rx_ren;

    //---
    // Instances

    cpu_if cpu_if0;

    pkt_if pkt_if0;
    xgmii_if xgm_if0;

    pkt_generator pif_gen0;
    pkt_generator xgm_gen0;

    scoreboard sb;

    //---
    // Functions

    SC_CTOR(testbench) :
        cpu_if0("cpu_if0"),
        pkt_if0("pkt_if0"),
        xgm_if0("xgm_if0"),
        pif_gen0("pif_gen0"),
        xgm_gen0("xgm_gen0"),
        sb("sb") {

        //--
        // CPU Interface

        cpu_if0.wb_clk_i (wb_clk_i);

        cpu_if0.wb_rst_i (wb_rst_i);

        cpu_if0.wb_ack_o (wb_ack_o);
        cpu_if0.wb_dat_o (wb_dat_o);
        cpu_if0.wb_int_o (wb_int_o);

        cpu_if0.wb_adr_i (wb_adr_i);
        cpu_if0.wb_cyc_i (wb_cyc_i);
        cpu_if0.wb_dat_i (wb_dat_i);
        cpu_if0.wb_stb_i (wb_stb_i);
        cpu_if0.wb_we_i (wb_we_i);

        //---
        // Packet Interface

        pkt_if0.clk_156m25 (clk_156m25);

        pkt_if0.reset_156m25_n (reset_156m25_n);

        pkt_if0.pkt_tx_data (pkt_tx_data);
        pkt_if0.pkt_tx_eop (pkt_tx_eop);
        pkt_if0.pkt_tx_mod (pkt_tx_mod);
        pkt_if0.pkt_tx_sop (pkt_tx_sop);
        pkt_if0.pkt_tx_val (pkt_tx_val);

        pkt_if0.pkt_tx_full (pkt_tx_full);

        pkt_if0.pkt_rx_avail (pkt_rx_avail);
        pkt_if0.pkt_rx_data (pkt_rx_data);
        pkt_if0.pkt_rx_eop (pkt_rx_eop);
        pkt_if0.pkt_rx_mod (pkt_rx_mod);
        pkt_if0.pkt_rx_err (pkt_rx_err);
        pkt_if0.pkt_rx_sop (pkt_rx_sop);
        pkt_if0.pkt_rx_val (pkt_rx_val);

        pkt_if0.pkt_rx_ren (pkt_rx_ren);

        //---
        // XGMII Interface

        xgm_if0.clk_xgmii (clk_xgmii);

        xgm_if0.reset_xgmii_n (reset_xgmii_n);

        xgm_if0.xgmii_rxc (xgmii_rxc);
        xgm_if0.xgmii_rxd (xgmii_rxd);

        xgm_if0.xgmii_txc (xgmii_txc);
        xgm_if0.xgmii_txd (xgmii_txd);

        //---
        // Connect packet generators to physical interfaces

        pif_gen0.connect_fifo(pkt_if0.get_tx_fifo_ptr());
        xgm_gen0.connect_fifo(xgm_if0.get_tx_fifo_ptr());

        //---
        // Connector scoreboard to components

        pkt_if0.connect_scoreboard(&sb, scoreboard::SB_PIF_ID);
        xgm_if0.connect_scoreboard(&sb, scoreboard::SB_XGM_ID);
        cpu_if0.connect_scoreboard(&sb, scoreboard::SB_CPU_ID);

    }

};

#endif
