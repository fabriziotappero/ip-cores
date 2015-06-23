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
 05/06/2011  Clean up for opensource. <wsong83@gmail.com>

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
	 IP("IP"),
	 OP("OP"),
         loc_x(x),
         loc_y(y),
	 oflit(1)
{
  sc_spawn_options opt;

  for(unsigned int i=0; i<SubChN; i++) {
    token[i] = BufDepth/2;
  }

  for(unsigned int i=0; i<SubChN; i++) {
    sc_spawn(sc_bind(&Network_Adapter::ibuffer_thread, this, i), NULL, &opt);
    sc_spawn(sc_bind(&Network_Adapter::obuffer_thread, this, i), NULL, &opt);
    sc_spawn(sc_bind(&Network_Adapter::credit_update, this, i), NULL, &opt);
  }
  
  SC_THREAD(oport);
  SC_THREAD(iport);

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
      mflit = iflit[ii].read();
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

      //fetch a token
      if(token[ii] == 0)
	wait(token_arrive[ii]);
      
      token[ii]--;

      oflit.write(mflit);

      if(mflit.ftype == F_TL) break;
    }
  }
}


void Network_Adapter::oport() {
  FLIT mflit;
  
  while(1) {
    mflit = oflit.read();
    OP->write(mflit);
  }
}

void Network_Adapter::iport() {
  FLIT mflit;
  
  while(1) {
    mflit = IP->read();
    iflit[mflit.vcn].write(mflit);
  }
}

void Network_Adapter::credit_update(unsigned int ii) {

  CPa[ii].write(false);
  while(1) {
    if(!CP[ii].read())
      wait(CP[ii].posedge_event());
    
    token[ii]++;
    token_arrive[ii].notify();
    CPa[ii].write(true);

    wait(CP[ii].negedge_event());
    CPa[ii].write(false);
  }
}
  
bool Network_Adapter::check_frame(const FRAME& frame)
{
    // TODO: check the integerity, dummy right noe
    return true;
}




