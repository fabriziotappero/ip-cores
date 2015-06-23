/*
 * it_cfg_monitor.h
 *
 *  Created on: Feb 15, 2011
 *      Author: hutch
 */

#ifndef IT_CFG_MONITOR_H_
#define IT_CFG_MONITOR_H_

#include <stdint.h>
#include "systemc.h"
#include <stdlib.h>

SC_MODULE(it_cfg_monitor)
{
  private:
  int delay_cnt;

  public:
  sc_in<bool>   clk;
  sc_in<bool>   reset_n;

  sc_in<bool>      cfgo_irdy;
  sc_out<bool>     cfgo_trdy;
  sc_in<uint32_t>  cfgo_addr;
  sc_in<bool>      cfgo_write;
  sc_in<uint32_t>  cfgo_wr_data;
  sc_out<uint32_t> cfgo_rd_data;


  void event();

  SC_CTOR(it_cfg_monitor) {
    SC_METHOD(event);
    sensitive << clk.pos();
    delay_cnt = -1;
  }
};

#endif /*IT_CFG_monitor_H_*/
