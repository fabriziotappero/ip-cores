/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The SystemC to keep a module of the simulation analysis object. 
 
 History:
 27/02/2011  Initial version. <wsong83@gmail.com>
 28/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

#ifndef ANA_PROC_H_
#define ANA_PROC_H_

#include "define.h"
#include <systemc.h>

class AnaProc : public sc_module {

 public:
  SC_CTOR(AnaProc)
  {
    ANA->analyze_delay("delay.ana");
    ANA->analyze_throughput("throughput.ana");
    SC_THREAD(run_proc);
  }

  void run_proc() {
     while(1){
	wait(SIM_TIME, SC_NS);
     }
  }

};



#endif
