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

#include <stdio.h>
#include <iostream>
#include <sys/times.h>
#include <sys/stat.h>

#include "systemc.h"

#include "sc_cpu_if.h"

void cpu_if::init() {
};

void cpu_if::connect_scoreboard(scoreboard *sbptr, scoreboard::sbSourceId sid) {
    sb = sbptr;
    sb_id = sid;
}

void cpu_if::set_param(cpu_if::paramId param, int value) {

    switch (param) {

      case TX_ENABLE:
          writebits(cpu_if::CPUREG_CONFIG0, 0, 0, value);
          break;

    }

};

void cpu_if::set_interrupt(cpu_if::intId intr) {

    writebits(cpu_if::CPUREG_INT_PENDING, intr, intr, 1);
};

void cpu_if::set_interrupt_mask(cpu_if::intId intr, bool value) {

    writebits(cpu_if::CPUREG_INT_MASK, intr, intr, value);
};

void cpu_if::enable_all_interrupts(void) {

    write(cpu_if::CPUREG_INT_MASK, 0xffffffff);
};

void cpu_if::get_rmon_stats(rmonStats_t *rmon_stats) {

    rmon_stats->tx_octets_cnt = read(cpu_if::CPUREG_STATSTXOCTETS);
    rmon_stats->tx_pkt_cnt = read(cpu_if::CPUREG_STATSTXPKTS);

    rmon_stats->rx_octets_cnt = read(cpu_if::CPUREG_STATSRXOCTETS);
    rmon_stats->rx_pkt_cnt = read(cpu_if::CPUREG_STATSRXPKTS);
};

uint cpu_if::read(uint addr) {

    uint data;

    //--
    // Wait for bus to be free, lock it, start transaction

    bus_lock.lock();
    bus_addr = addr;
    bus_write = false;
    bus_start.post();

    //--
    // Wait for transaction to complete

    bus_done.wait();

    //--
    // Get the data, free the bus

    data = bus_data;
    cout << hex << "READ ADDR 0x" << addr << ": 0x" << data << dec << endl;
    bus_lock.unlock();

    return data;
};

void cpu_if::write(uint addr, uint data) {

    //--
    // Wait for bus to be free, lock it, start transaction

    bus_lock.lock();
    bus_addr = addr;
    bus_data = data;
    bus_write = true;
    bus_start.post();

    //--
    // Wait for transaction to complete

    bus_done.wait();

    //--
    // Free the bus

    cout << hex << "WRITE ADDR 0x" << addr << ": 0x" << data << dec << endl;
    bus_lock.unlock();
};

void cpu_if::writebits(uint addr, uint hbit, uint lbit, uint value) {

    uint data;
    uint mask;

    mask = ~((0xffffffff << lbit) & (0xffffffff >> (31-lbit)));

    data = mask & read(addr);
    data = data | ((value << lbit) & ~mask);

    write(addr, data);
};

void cpu_if::transactor() {


    while (true) {

        // Wait for a transaction
        while (bus_start.trywait()) {
            wait();
        }

        if (!bus_write) {

            //---
            // Read access

            // Start of access
            wb_adr_i = bus_addr;
            wb_dat_i = 0;

            wb_cyc_i = 1;
            wb_stb_i = 1;
            wb_we_i = 0;

            // Wait for ack
            while (wb_ack_o != 1) {
                wait();
            }

            // Capture data
            bus_data = wb_dat_o;

            wb_adr_i = 0;
            wb_dat_i = 0;

            wb_cyc_i = 0;
            wb_stb_i = 0;

        }
        else {

            //---
            // Write access

            // Start of access
            wb_adr_i = bus_addr;
            wb_dat_i = bus_data;

            wb_cyc_i = 1;
            wb_stb_i = 1;
            wb_we_i = 1;

            // Wait for ack
            while (wb_ack_o != 1) {
                wait();
            }

            // End cycle
            wb_adr_i = 0;
            wb_dat_i = 0;

            wb_cyc_i = 0;
            wb_stb_i = 0;
            wb_we_i = 0;

        }

        bus_done.post();
    }
};

void cpu_if::monitor() {

    uint data;

    wait();

    while (true) {

        if (wb_int_o) {

            //---
            // Read interrupt register when interrupt signal is asserted

            data = read(cpu_if::CPUREG_INT_PENDING);

            cout << "READ INTERRUPTS: 0x" << hex << data << dec << endl;

            //---
            // Notify scoreboard

            if ((data >> cpu_if::INT_CRC_ERROR) & 0x1) {
                sb->notify_status(sb_id, scoreboard::CRC_ERROR);
            }

            if ((data >> cpu_if::INT_FRAGMENT_ERROR) & 0x1) {
               sb->notify_status(sb_id, scoreboard::FRAGMENT_ERROR);
            }

            if ((data >> cpu_if::INT_LENGHT_ERROR) & 0x1) {
               sb->notify_status(sb_id, scoreboard::LENGHT_ERROR);
            }

            if ((data >> cpu_if::INT_LOCAL_FAULT) & 0x1) {

                data = read(cpu_if::CPUREG_INT_STATUS);

                if ((data >> cpu_if::INT_LOCAL_FAULT) & 0x1) {
                    sb->notify_status(sb_id, scoreboard::LOCAL_FAULT);
                }
            }

            if ((data >> cpu_if::INT_REMOTE_FAULT) & 0x1) {

                data = read(cpu_if::CPUREG_INT_STATUS);

                if ((data >> cpu_if::INT_REMOTE_FAULT) & 0x1) {
                    sb->notify_status(sb_id, scoreboard::REMOTE_FAULT);
                }
            }

            if ((data >> cpu_if::INT_RXD_FIFO_OVFLOW) & 0x1) {
                sb->notify_status(sb_id, scoreboard::RXD_FIFO_OVFLOW);
            }

            if ((data >> cpu_if::INT_RXD_FIFO_UDFLOW) & 0x1) {
                sb->notify_status(sb_id, scoreboard::RXD_FIFO_UDFLOW);
            }

            if ((data >> cpu_if::INT_TXD_FIFO_OVFLOW) & 0x1) {
                sb->notify_status(sb_id, scoreboard::TXD_FIFO_OVFLOW);
            }

            if ((data >> cpu_if::INT_TXD_FIFO_UDFLOW) & 0x1) {
                sb->notify_status(sb_id, scoreboard::TXD_FIFO_UDFLOW);
            }

            if ((data >> cpu_if::INT_PAUSE_FRAME) & 0x1) {
                sb->notify_status(sb_id, scoreboard::RX_GOOD_PAUSE_FRAME);
            }

        }

        wait();
    }
};
