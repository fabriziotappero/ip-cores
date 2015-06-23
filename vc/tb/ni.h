/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Network interface for the VC router.
 
 History:
 20/08/2008  Initial version. <wsong83@gmail.com>
 30/09/2010  Use template style packet definition. <wsong83@gmail.com>
 05/06/2011  Clean up for opensource. <wsong83@gmail.com>

*/

#ifndef NETWORK_ADAPTER_H_
#define NETWORK_ADAPTER_H_

#include "define.h"
#include <systemc.h>

SC_MODULE(Network_Adapter)
{
    
public:
    SC_HAS_PROCESS(Network_Adapter);
    Network_Adapter(
             sc_module_name     name // module name
            ,unsigned int       x    // location x
            ,unsigned int       y    // location y
        );
    ~Network_Adapter();
    
    // interface with processor
    sc_port<sc_fifo_in_if<FRAME> >      frame_in; // frame for transmission
    sc_port<sc_fifo_out_if<FRAME> >     frame_out; // frame for receiving
    
    // interface with router
    sc_port<sc_fifo_in_if<FLIT> > IP;  // input port from IO driver
    sc_port<sc_fifo_out_if<FLIT> > OP; // output port to IO driver
    sc_in<bool> CP [SubChN];	       // the credit input from the router input buffer
    sc_out<bool> CPa [SubChN];	       // ack to the credit

private:
    unsigned int loc_x,loc_y; // location information
   
    sc_fifo<FLIT>                       oflit; // the current flit under transmission
    sc_fifo<FLIT>                       iflit [SubChN]; // the current flits under receiving from all input VCs
    unsigned int                        token [SubChN];	// the token ready for each output VC
    sc_event                            token_arrive [SubChN]; // the token ready event
    
    // functional thread
    void ibuffer_thread(unsigned int);                // input buffer respond thread
    void obuffer_thread(unsigned int);                // output buffer respond thread
    void oport();                                     // the thread transmitting flit
    void iport();                                     // the thread receiving flits
    void credit_update(unsigned int);                 // receive credits and update the available tokens

    // other functions
    bool check_frame(const FRAME& frame);           // check the correctness of frame received
};

#endif

