/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The SystemC processing element.
 
 History:
 26/02/2011  Initial version. <wsong83@gmail.com>
 31/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

#ifndef PROCELEM_H_
#define PROCELEM_H_

#include "define.h"
#include <systemc.h>


// a function to generate random numbers comply with an exponential distribution with expection exp
double rand_exponential(double exp) {
  unsigned int rint = rand() % (unsigned int)(1e6);
  double rdat = rint * 1.0 / 1e6;
  return (-1.0 * exp * log(rdat));
}

class ProcElem : public sc_module {

public:
  sc_in<bool>  rst_n;		// active low reset
  sc_port<sc_fifo_out_if<FRAME> > Fout;	// frame output port
  sc_port<sc_fifo_in_if<FRAME> > Fin;	// frame input port

  SC_HAS_PROCESS(ProcElem);

  unsigned int addrx, addry;	// the local address

  ProcElem(sc_module_name nm, unsigned int addrx, unsigned int addry)
  : sc_module(nm), addrx(addrx), addry(addry)
  {
    SC_THREAD(tproc);		// frame transmission thread
    SC_THREAD(rproc);		// frame receiving thread
  }
  
  // the transmission thread
  void tproc() {
    // waiting for reset
    wait(rst_n.posedge_event());

    while(1) {
      // wait for a random interval
      if(FFreq != 0) {
	double rnum = rand_exponential(1e6/FFreq);
	wait(rnum, SC_PS);
      }
	
      // generate a frame
      // specify the target address according to random uniform traffic
      unsigned int rint, tarx, tary;
      rint = rand()%(DIMX*DIMY-1);
      if(rint == addrx*DIMY + addry)
	rint = DIMX*DIMY-1;
      
      tarx = rint/DIMY;
      tary = rint%DIMY;
      
      // initialize the frame object
      FRAME tframe(FLEN);
      
      // fill in the fields
      tframe.addrx = tarx;
      tframe.addry = tary;
      for(unsigned int i=0; i<FLEN; i++)
	tframe.push(rand()&0xff);
      
      // specify the unique key of each frame
      // a key is 32 bits log
      // in this test bench, it is the first 4 bytes of the frame payload
      unsigned long key = 0;
      for(unsigned int i=0; (i<FLEN && i<4); i++) {
	key <<= 8;
	key |= tframe[i];
      }
      
      // record the new frame
      ANA->start(key, sc_time_stamp().to_double());
      
      // sen the frame to the router
      Fout->write(tframe);
    }
  }

  // the receiving thread
  void rproc() {
    while(1) {
      // initialize a space for the frame
      FRAME rframe;

      // read in the frame
      rframe = Fin->read();
      unsigned long key = 0;

      // regenerate the unique key
      for(unsigned int i=0; (i<FLEN && i<4); i++) {
	key <<= 8;
	key |= rframe[i];
      }
      
      // check the key in the simulation analysis database and update info.
      if(!ANA->stop(key, sc_time_stamp().to_double(), rframe.psize())) {
        // report error when no match is found
	cout << sc_time_stamp() << " " << name() ;
        cout << "packet did not find!" << endl;
        cout << rframe << endl;
        sc_stop();
      }
    }
  }

};

#endif

