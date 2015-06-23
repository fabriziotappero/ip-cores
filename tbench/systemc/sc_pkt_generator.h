//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_pkt_generator.h"                              ////
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

#ifndef GENERATOR_H
#define GENERATOR_H

#include "systemc.h"

#include "sc_packet.h"

SC_MODULE(pkt_generator) {

  private:

    //---
    // Variables

    sc_fifo<packet_t*> * tx_fifo;

    int tx_bucket;

    int min_pkt_size;
    int max_pkt_size;

    int crc_interval;
    int fragment_interval;
    int lenght_err_interval;
    int lenght_err_size;
    int coding_interval;
    int local_fault_interval;
    int remote_fault_interval;
    int inject_pause_interval;

  public:

    //---
    // Functions

    void init(void);

    void connect_fifo(sc_fifo<packet_t*> * fifo);

    void set_tx_bucket(int cnt);
    int get_tx_bucket(void);

    void set_pkt_size(int min, int max);

    void set_crc_errors(int interval);
    void set_fragment_errors(int interval);
    void set_lenght_errors(int interval, int size);
    void set_coding_errors(int interval);
    void set_local_fault(int interval);
    void set_remote_fault(int interval);
    void set_inject_pause(int interval);

    //---
    // Threads

    void gen_packet();

    SC_CTOR(pkt_generator) {

        tx_bucket = 0;

        min_pkt_size = 64;
        max_pkt_size = 72;

        SC_THREAD (gen_packet);

    }

};

#endif
