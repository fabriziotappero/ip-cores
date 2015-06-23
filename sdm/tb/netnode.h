/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The SystemC module of network node including the processing element and the network interface.
 Currently the transmission FIFO is 500 frame deep.
   
 History:
 26/02/2011  Initial version. <wsong83@gmail.com>
 30/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

#ifndef NETNODE_H_
#define NETNODE_H_

#include "define.h"
#include <systemc.h>
#include "ni.h"
#include "procelem.h"
#include "rtdriver.h"

class NetNode : public sc_module {
 public:
  RTDriver * LIOD [SubChN]; /* driving and convert I/O to/from router local port */
  Network_Adapter * NI;	    /* network interface */
  ProcElem  * PE;	    /* processor element */

#ifdef ENABLE_CHANNEL_CLISING
  sc_signal<sc_lv<ChBW*4> >    rtia [SubChN]; /* input ack to router */
  sc_signal<sc_lv<ChBW*4> >    rtod4 [SubChN]; /* output eof to router */
  sc_signal<sc_lv<ChBW*4> >    rtoa [SubChN];  /* output ack from router */
  sc_signal<sc_lv<ChBW*4> >    rtid4 [SubChN]; /* input data from router */
  sc_in<sc_lv<SubChN*ChBW*4> >     dia;	       /* input ack, undivided */
  sc_in<sc_lv<SubChN*ChBW*4> >     do4;	       /* output eof, undivided */
  sc_out<sc_lv<SubChN*ChBW*4> >    doa;	       /* output ack, undivided */
  sc_out<sc_lv<SubChN*ChBW*4> >    di4;	       /* input eof, undivided */
#else
  sc_signal<sc_logic >         rtia [SubChN]; /* input ack to router */
  sc_signal<sc_logic >         rtod4 [SubChN]; /* output data to router */
  sc_signal<sc_logic >         rtoa [SubChN];  /* output ack from router */
  sc_signal<sc_logic >         rtid4 [SubChN]; /* input eof from router */
  sc_in<sc_lv<SubChN> >     dia;	       /* input ack, undivided */
  sc_in<sc_lv<SubChN> >     do4;	       /* output eof, undivided */
  sc_out<sc_lv<SubChN> >    doa;	       /* output ack, undivided */
  sc_out<sc_lv<SubChN> >    di4;	       /* input eof, undivided */
#endif  

  sc_signal<sc_lv<ChBW*4 > >   rtod [SubChN][4]; /* output data to router */
  sc_signal<sc_lv<ChBW*4 > >   rtid [SubChN][4]; /* input data from router */
  sc_in<sc_lv<SubChN*ChBW*4 > >    do0;		 /* output d0, undivided */
  sc_in<sc_lv<SubChN*ChBW*4 > >    do1;
  sc_in<sc_lv<SubChN*ChBW*4 > >    do2;
  sc_in<sc_lv<SubChN*ChBW*4 > >    do3;
  sc_out<sc_lv<SubChN*ChBW*4 > >   di0; /* input data, undivided */
  sc_out<sc_lv<SubChN*ChBW*4 > >   di1;
  sc_out<sc_lv<SubChN*ChBW*4 > >   di2;
  sc_out<sc_lv<SubChN*ChBW*4 > >   di3;
  sc_in<sc_logic >         rst_n; /* global reste, from the verilog top level */

  // signals between IOD and NI
  sc_fifo<pdu_flit<ChBW> > *   NI2P [SubChN]; /* flit fifo, from NI to IO driver */
  sc_fifo<pdu_flit<ChBW> > *   P2NI [SubChN]; /* flit fifo, from IO driver to NI */

  // signals between NI and FG/FS
  sc_fifo<pdu_frame<ChBW> > *   FIQ; /* the frame fifo, from PE to NI */
  sc_fifo<pdu_frame<ChBW> > *   FOQ; /* the frame fifo, from NI to PE */
  sc_signal<bool>               brst_n; /* the reset in the SystemC modules */

  int x, y;			/* private local address */

  SC_CTOR(NetNode) 
    : dia("dia"), do4("do4"), doa("doa"), di4("di4"),
    do0("do0"), do1("do1"), do2("do2"), do3("do3"), 
    di0("di0"), di1("di1"), di2("di2"), di3("di3"), 
    rst_n("rst_n")
      {
	// dynamically get the parameters from Verilog test bench
	ncsc_get_param("x", x);
	ncsc_get_param("y", y);

	// initialization
	NI = new Network_Adapter("NI", x, y);
	PE = new ProcElem("PE", x, y);
	FIQ = new sc_fifo<pdu_frame<ChBW> >(500); /* currently the fifo from PE is 500 frame deep */
	FOQ = new sc_fifo<pdu_frame<ChBW> >(1);
	for(unsigned int j=0; j<SubChN; j++) {
	  LIOD[j] = new RTDriver("LIOD");
	  NI2P[j] = new sc_fifo<pdu_flit<ChBW> >(1);
	  P2NI[j] = new sc_fifo<pdu_flit<ChBW> >(1);
	}

	// connections
	for(unsigned int j=0; j<SubChN; j++) {
	  LIOD[j]->NI2P(*NI2P[j]);
	  LIOD[j]->P2NI(*P2NI[j]);
	  for(unsigned int k=0; k<4; k++) {
	    LIOD[j]->rtid[k](rtid[j][k]);
	    LIOD[j]->rtod[k](rtod[j][k]);
	  }
	  LIOD[j]->rtia(rtia[j]);
	  LIOD[j]->rtid4(rtid4[j]);
	  LIOD[j]->rtoa(rtoa[j]);
	  LIOD[j]->rtod4(rtod4[j]);
	}

	NI->frame_in(*FIQ);
	NI->frame_out(*FOQ);
	for(unsigned int j=0; j<SubChN; j++) {
	  NI->IP[j](*P2NI[j]);
	  NI->OP[j](*NI2P[j]);
	}
	
	PE->rst_n(brst_n);
	PE->Fout(*FIQ);
	PE->Fin(*FOQ);

	brst_n.write(false);

	SC_METHOD(rst_proc);
	sensitive << rst_n;
	
	sc_spawn_options opt_inp;
	opt_inp.spawn_method();
	for(unsigned int j=0; j<SubChN; j++) {
	  opt_inp.set_sensitivity(&rtid[j][0]);
	  opt_inp.set_sensitivity(&rtid[j][1]);
	  opt_inp.set_sensitivity(&rtid[j][2]);
	  opt_inp.set_sensitivity(&rtid[j][3]);
	  opt_inp.set_sensitivity(&rtid4[j]);
	}
	opt_inp.set_sensitivity(&dia);
	sc_spawn(sc_bind(&NetNode::VC_inp, this), NULL, &opt_inp);

      
	sc_spawn_options opt_outp;
	opt_outp.spawn_method();
	for(unsigned int j=0; j<SubChN; j++) {
	  opt_outp.set_sensitivity(&rtoa[j]);
	}
	opt_outp.set_sensitivity(&do0);
	opt_outp.set_sensitivity(&do1);
	opt_outp.set_sensitivity(&do2);
	opt_outp.set_sensitivity(&do3);
	opt_outp.set_sensitivity(&do4);
	sc_spawn(sc_bind(&NetNode::VC_outp, this), NULL, &opt_outp);
      }
  
	
  // thread to divide the input buses according to virtual circuits
  void VC_inp() {

    sc_lv<SubChN*ChBW*4> md[4];
#ifdef ENABLE_CHANNEL_CLISING
    sc_lv<SubChN*ChBW*4> md4;
    sc_lv<SubChN*ChBW*4> mda;
#else
    sc_lv<SubChN> md4;
    sc_lv<SubChN> mda;
#endif

    mda = dia.read();

    for(unsigned int i=0; i<SubChN; i++) {
#ifdef ENABLE_CHANNEL_CLISING
      rtia[i].write(mda(ChBW*4*(i+1)-1, ChBW*4*i));
      md4(ChBW*4*(i+1)-1, ChBW*4*i) = rtid4[i].read();
#else
      rtia[i].write(mda[i]);
      md4[i] = rtid4[i].read();
#endif
      md[0](ChBW*4*(i+1)-1, ChBW*4*i) = rtid[i][0].read();
      md[1](ChBW*4*(i+1)-1, ChBW*4*i) = rtid[i][1].read();
      md[2](ChBW*4*(i+1)-1, ChBW*4*i) = rtid[i][2].read();
      md[3](ChBW*4*(i+1)-1, ChBW*4*i) = rtid[i][3].read();
    }

    di0.write(md[0]);
    di1.write(md[1]);
    di2.write(md[2]);
    di3.write(md[3]);
    di4.write(md4);
  }

  // thread to combine the buses according to virtual circuits
  void VC_outp() {
    sc_lv<SubChN*ChBW*4> md[4];
#ifdef ENABLE_CHANNEL_CLISING
    sc_lv<SubChN*ChBW*4> md4;
    sc_lv<SubChN*ChBW*4> mda;
#else
    sc_lv<SubChN> md4;
    sc_lv<SubChN> mda;
#endif

    md[0] = do0.read();
    md[1] = do1.read();
    md[2] = do2.read();
    md[3] = do3.read();
    md4 = do4.read();


    for(unsigned int i=0; i<SubChN; i++) {
#ifdef ENABLE_CHANNEL_CLISING
      mda(ChBW*4*(i+1)-1, ChBW*4*i) = rtoa[i].read();
      rtod4[i].write(md4(ChBW*4*(i+1)-1, ChBW*4*i));
#else
      mda[i] = rtoa[i].read();
      rtod4[i].write(md4[i]);
#endif
      rtod[i][0].write(md[0](ChBW*4*(i+1)-1, ChBW*4*i));
      rtod[i][1].write(md[1](ChBW*4*(i+1)-1, ChBW*4*i));
      rtod[i][2].write(md[2](ChBW*4*(i+1)-1, ChBW*4*i));
      rtod[i][3].write(md[3](ChBW*4*(i+1)-1, ChBW*4*i));
    }

    doa.write(mda);
  }

  // generate the reset for SystemC modules
  void rst_proc() {
    bool mrst_n;
    mrst_n = rst_n.read().is_01() ? rst_n.read().to_bool() : false;
    brst_n.write(mrst_n);
  }
};


#endif
