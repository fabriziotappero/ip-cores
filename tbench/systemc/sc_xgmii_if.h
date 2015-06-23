//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_xgmii_if.h"                                   ////
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

#ifndef XGMII_IF_H
#define XGMII_IF_H

#include "systemc.h"

#include "sc_defines.h"

#include "sc_packet.h"
#include "sc_scoreboard.h"

SC_MODULE(xgmii_if) {

  public:

    //---
    // Ports

    sc_in<bool> clk_xgmii;

    sc_in<bool> reset_xgmii_n;

    sc_out<unsigned int> xgmii_rxc;
    sc_out<vluint64_t > xgmii_rxd;

    sc_in<unsigned int> xgmii_txc;
    sc_in<vluint64_t > xgmii_txd;

  private:

    //---
    // Variables

    sc_fifo<packet_t*> tx_fifo;
    sc_fifo<packet_t*> rx_fifo;

    scoreboard *sb;
    scoreboard::sbSourceId sb_id;

  public:

    //---
    // Variables

    bool allow_idle_errors;
    bool disable_receive;
    bool disable_padding;
    bool inject_noise;

    bool rx_local_fault;
    bool rx_remote_fault;

    //---
    // Functions

    sc_fifo<packet_t*> * get_tx_fifo_ptr();
    sc_fifo<packet_t*> * get_rx_fifo_ptr();

    void init(void);
    void connect_scoreboard(scoreboard *sbptr, scoreboard::sbSourceId sid);

    //---
    // Threads

    void transmit();
    void receive();
    void monitor();

    SC_CTOR(xgmii_if) :
        tx_fifo (2),
        rx_fifo (2) {

        SC_CTHREAD (transmit, clk_xgmii.pos());

        SC_CTHREAD (receive, clk_xgmii.pos());

        SC_CTHREAD (monitor, clk_xgmii.pos());
    }

};

#endif
