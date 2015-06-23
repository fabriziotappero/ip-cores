/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The port driver between NI and router. 
 
 History:
 27/04/2010  Initial version. <wsong83@gmail.com>
 16/10/2010  Support SDM. <wsong83@gmail.com>
 30/05/2011  Remove the sc_unit datatype to support data width larger than 64. <wsong83@gmail.com>
 
*/

#ifndef RT_DRIVER_H_
#define RT_DRIVER_H_

#include "define.h"
#include <systemc.h>
#include "pdu_def.h"

SC_MODULE(RTDriver) {

 public:
  // port with network interface
  sc_port<sc_fifo_in_if<FLIT> > NI2P;
  sc_port<sc_fifo_out_if<FLIT> > P2NI;
  
  // signals from interface to router
  sc_out<sc_lv<ChBW*4> > rtid [4];
  sc_in<sc_lv<ChBW*4> > rtod [4];

#ifdef ENABLE_CHANNEL_CLISING
  sc_out<sc_lv<ChBW*4> > rtid4;
  sc_in<sc_lv<ChBW*4> > rtod4;
  sc_in<sc_lv<ChBW*4> > rtia;
  sc_out<sc_lv<ChBW*4> > rtoa;
#else
  sc_out<sc_logic > rtid4;
  sc_in<sc_logic > rtod4;
  sc_in<sc_logic> rtia;
  sc_out<sc_logic> rtoa;
#endif
  
  SC_HAS_PROCESS(RTDriver);
  RTDriver(sc_module_name name);
  
  void IPdetect();		// Method to detect the router input port
  void OPdetect();		// Method to detect the router output port
  void send();			// thread of sending a flit
  void recv();			// thread to recveive a flit

  sc_signal<bool> rtinp_sig; // fire when the router input port is ready for a new flit
  sc_signal<bool> rtoutp_sig; // fire when the router output port has a new flit
  
  unsigned int c1o42b(unsigned int); // convert 1-of-4 to binary
};


#endif
