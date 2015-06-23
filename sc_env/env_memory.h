#include "sc_env.h"

#ifndef ENV_MEMORY_H
#define ENV_MEMORY_H
#define AM_ASZ 16
#define AM_DEPTH (1<<AM_ASZ)

SC_MODULE(env_memory) {

  sc_in<bool > clk;  
  sc_in<uint32_t> wr_data;
  sc_in<bool> mreq_n;
  sc_in<bool> rd_n;
  sc_in<bool> wr_n;
  sc_in<uint32_t> addr;
  sc_out<uint32_t> rd_data; 
  sc_in<bool> reset_n;

  unsigned char *memory;

  void event();
  
  void load_ihex (char *filename);

  SC_CTOR(env_memory) {
    memory = new unsigned char[AM_DEPTH];
    SC_METHOD(event);
    sensitive << clk.pos() << addr;
  }
};

#endif
