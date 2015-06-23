//////////////////////////////////////////////////////////////////////
////                                                              ////
////  File name "sc_scoreboard.h"                                 ////
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

#ifndef SCOREBOARD_H
#define SCOREBOARD_H

#include "systemc.h"

#include "sc_packet.h"


struct sbStats_t {
    int tx_pkt_cnt;
    int rx_pkt_cnt;

    int tx_octets_cnt;
    int rx_octets_cnt;

    int crc_error_cnt;
    int fragment_error_cnt;
    int lenght_error_cnt;
    int coding_error_cnt;
    int flags_error_cnt;

    int inject_local_fault_cnt;
    int inject_remote_fault_cnt;

    int inject_pause_frame_cnt;

    int detect_local_fault_cnt;
    int detect_remote_fault_cnt;

    double timestamp_first_pkt;
    double timestamp_last_pkt;

    int next_ifg_length;
    int deficit_idle_count;
};

struct sbCpuStats_t {
    int crc_error_cnt;
    int fragment_error_cnt;
    int lenght_error_cnt;

    int rxd_fifo_ovflow_cnt;
    int rxd_fifo_udflow_cnt;
    int txd_fifo_ovflow_cnt;
    int txd_fifo_udflow_cnt;

    int rx_pause_frame_cnt;

    int local_fault_cnt;
    int remote_fault_cnt;
};

SC_MODULE(scoreboard) {

  public:

    //---
    // Types

    enum sbSourceId {
        SB_PIF_ID,
        SB_XGM_ID,
        SB_CPU_ID,
    };

    enum sbStatusId {
        CRC_ERROR,
        FRAGMENT_ERROR,
        LENGHT_ERROR,
        LOCAL_FAULT,
        REMOTE_FAULT,
        RXD_FIFO_OVFLOW,
        RXD_FIFO_UDFLOW,
        TXD_FIFO_OVFLOW,
        TXD_FIFO_UDFLOW,
        RX_GOOD_PAUSE_FRAME,
    };

  private:

    //---
    // Variables

    sc_fifo<packet_t*> pif_fifo;
    sc_fifo<packet_t*> xgm_fifo;

    sbStats_t pif_stats;
    sbStats_t xgm_stats;
    sbCpuStats_t cpu_stats;

  public:

    //---
    // Variables

    bool disable_padding;
    bool disable_crc_check;
    bool disable_packet_check;
    bool disable_flags_check;
    bool disable_signal_check;

    //---
    // Functions

    void init(void);

    void notify_packet_tx(sbSourceId sid, packet_t* pkt);
    void notify_packet_rx(sbSourceId sid, packet_t* pkt);
    void notify_status(sbSourceId sid, sbStatusId statusId);

    sbStats_t* get_pif_stats(void);
    sbStats_t* get_xgm_stats(void);
    sbCpuStats_t* get_cpu_stats(void);

    void clear_stats(void);

    SC_CTOR(scoreboard):
        pif_fifo (2000),
        xgm_fifo (2000) {

    }

};


#endif
