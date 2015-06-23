/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 A SystemC network adapter/interface for NoC simulation.
   
 History:
 23/12/2008  Initial version. <wsong83@gmail.com>
 30/09/2010  Use template style packet definition. <wsong83@gmail.com>
 16/10/2010  Support SDM. <wsong83@gmail.com>
 29/05/2011  CLean up for opensource. <wsong83@gmail.com>

*/

#include "ni.h"

Network_Adapter::Network_Adapter(
         sc_module_name     name            // module name
        ,unsigned int       x               // location x
        ,unsigned int       y               // location y
    ):
         sc_module(name),
	 frame_in("FrmIn"),
	 frame_out("FrmOut"),
         loc_x(x),
         loc_y(y)
{
  sc_spawn_options opt;

  for(unsigned int i=0; i<SubChN; i++) {
    sc_spawn(sc_bind(&Network_Adapter::ibuffer_thread, this, i), NULL, &opt);
    sc_spawn(sc_bind(&Network_Adapter::obuffer_thread, this, i), NULL, &opt);
  }
}

Network_Adapter::~Network_Adapter()
{
}

// read in the incoming frame
void Network_Adapter::ibuffer_thread(unsigned int ii){
  FRAME mframe; 
  FLIT mflit;

  while(1){
    mframe.clear();
    
    while(1) {
      mflit = IP[ii]->read();
      mframe << mflit;
      
      if(mflit.ftype == F_TL)	break;
    }

    frame_out->write(mframe);
  }
}

// send out a frame
void Network_Adapter::obuffer_thread(unsigned int ii){

  FRAME mframe; 
  FLIT mflit;

  while(1){
    mframe = frame_in->read();
    
    while(1) {
      mframe >> mflit;
      mflit.vcn = ii;

      OP[ii]->write(mflit);

      if(mflit.ftype == F_TL) break;
    }
  }
}

bool Network_Adapter::check_frame(const FRAME& frame)
{
    // TODO: check the integerity, dummy right noe
    return true;
}




