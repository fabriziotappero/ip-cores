#ifndef IT_CFG_DRIVER_H_
#define IT_CFG_DRIVER_H_

#include <stdint.h>
#include "systemc.h"
#include <stdlib.h>
#include <queue>

using namespace std;

SC_MODULE(it_cfg_driver)
{
  private:
  queue<uint32_t> send_queue;
  int addr;
  //uint32_t *send_queue;
  //int q_sz, q_rptr;

  public:
  sc_in<bool>   clk;
  sc_in<bool>   reset_n;

  sc_out<bool>     cfgi_irdy;
  sc_in<bool>      cfgi_trdy;
  sc_out<uint32_t> cfgi_addr;
  sc_out<bool>     cfgi_write;
  sc_out<uint32_t> cfgi_wr_data;
  sc_in<uint32_t>  cfgi_rd_data;


  void event();

  SC_CTOR(it_cfg_driver) {
    SC_METHOD(event);
    sensitive << clk.pos();
    addr = 0;
  }

  void add_queue (uint32_t d);
};

#endif /*IT_CFG_DRIVER_H_*/
