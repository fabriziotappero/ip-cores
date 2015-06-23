//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_testcases.h"                                  ////
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

#include "systemc.h"

#include "sc_testbench.h"



SC_MODULE(testcases) {

  public:

    //---
    // Variables

    bool done;

  private:

    testbench* tb;

  public:

    //---
    // Functions

    void connect_testbench(testbench* tbptr);

    void test_deficit_idle_count(void);
    void packet_dic(int minsize, int maxsize);

    void test_packet_size(int min, int max, int cnt);

    void test_crc_errors(int min, int max, int cnt, int interval);

    void test_txdfifo_ovflow();
    void test_rxdfifo_ovflow();

    void test_rx_fragments(int min, int max, int cnt, int interval);
    void test_rx_lenght(int cnt, int interva);
    void test_rx_coding_err(int cnt, int interval);
    void test_rx_local_fault(int min, int max, int cnt, int interval);
    void test_rx_remote_fault(int min, int max, int cnt, int interval);

    void test_rx_pause(int min, int max, int cnt, int interval);

    void test_interrupt_mask();

    void test_noise();

    //---
    // Threads

    void run_tests(void);

    SC_CTOR(testcases) {

        done = false;

        SC_THREAD (run_tests);

    }

};
