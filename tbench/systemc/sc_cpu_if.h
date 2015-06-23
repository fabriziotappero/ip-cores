//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_cpu_if.h"                                     ////
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

#ifndef CPU_IF_H
#define CPU_IF_H

#include "systemc.h"

#include "sc_scoreboard.h"
#include "sc_cpu_if.h"

struct rmonStats_t {
    int tx_pkt_cnt;
    int rx_pkt_cnt;

    int tx_octets_cnt;
    int rx_octets_cnt;
};


SC_MODULE(cpu_if) {

  public:

    //---
    // Ports

    sc_in<bool> wb_clk_i;

    sc_in<bool> wb_rst_i;

    sc_in<bool> wb_ack_o;
    sc_in<unsigned int> wb_dat_o;
    sc_in<bool> wb_int_o;

    sc_out<unsigned int> wb_adr_i;
    sc_out<bool> wb_cyc_i;
    sc_out<unsigned int> wb_dat_i;
    sc_out<bool> wb_stb_i;
    sc_out<bool> wb_we_i;

    //---
    // Types

    enum paramId {
        TX_ENABLE,
    };

    enum intId {
        INT_TXD_FIFO_OVFLOW = 0,
        INT_TXD_FIFO_UDFLOW = 1,
        INT_RXD_FIFO_OVFLOW = 2,
        INT_RXD_FIFO_UDFLOW = 3,
        INT_LOCAL_FAULT = 4,
        INT_REMOTE_FAULT = 5,
        INT_PAUSE_FRAME = 6,
        INT_CRC_ERROR = 7,
        INT_FRAGMENT_ERROR = 8,
        INT_LENGHT_ERROR = 9,
    };

    enum regId {
        CPUREG_CONFIG0 = 0x0,

        CPUREG_INT_PENDING = 0x8,
        CPUREG_INT_STATUS = 0xc,
        CPUREG_INT_MASK = 0x10,

        CPUREG_STATSTXOCTETS = 0x80,
        CPUREG_STATSTXPKTS = 0x84,

        CPUREG_STATSRXOCTETS = 0x90,
        CPUREG_STATSRXPKTS = 0x94,
    };

  private:

    //---
    // Variables

    scoreboard *sb;
    scoreboard::sbSourceId sb_id;

    sc_mutex bus_lock;
    sc_semaphore bus_start;
    sc_semaphore bus_done;

    uint bus_addr;
    uint bus_data;
    bool bus_write;

  public:

    //---
    // Variables

    //---
    // Functions

    void init();
    void connect_scoreboard(scoreboard *sbptr, scoreboard::sbSourceId sid);
    void set_param(cpu_if::paramId param, int value);
    void set_interrupt(cpu_if::intId intr);
    void set_interrupt_mask(cpu_if::intId intr, bool value);
    void enable_all_interrupts(void);
    void get_rmon_stats(rmonStats_t *rmon_stats);

    uint read(uint addr);
    void write(uint addr, uint data);
    void writebits(uint addr, uint hbit, uint lbit, uint value);

    //---
    // Threads

    void transactor();
    void monitor();

    SC_CTOR(cpu_if): bus_start(0), bus_done(0) {

        SC_CTHREAD (monitor, wb_clk_i.pos());
        SC_CTHREAD (transactor, wb_clk_i.pos());

    }

};

#endif
