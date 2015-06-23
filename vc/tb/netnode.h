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
 04/03/2011  Support VC router. <wsong83@gmail.com>
 05/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
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
  RTDriver * LIOD; /* driving and convert I/O to/from router local port */
  Network_Adapter * NI;		/* network interface */
  ProcElem  * PE;		/* processor element */

  // signals for router
  sc_out<   sc_logic >         doa ;
  sc_out<   sc_lv<SubChN > >   doc ;
  sc_in<    sc_lv<ChBW*4 > >   do0 ;
  sc_in<    sc_lv<ChBW*4 > >   do1 ;
  sc_in<    sc_lv<ChBW*4 > >   do2 ;
  sc_in<    sc_lv<ChBW*4 > >   do3 ;
  sc_in<    sc_lv<3> >         doft;
  sc_in<    sc_lv<SubChN > >   dovc;
  sc_in<    sc_lv<SubChN > >   doca;
  sc_in<    sc_logic >         dia;
  sc_in<    sc_lv<SubChN > >   dic;
  sc_out<   sc_lv<ChBW*4 > >   di0;
  sc_out<   sc_lv<ChBW*4 > >   di1;
  sc_out<   sc_lv<ChBW*4 > >   di2;
  sc_out<   sc_lv<ChBW*4 > >   di3;
  sc_out<   sc_lv<3> >         dift;
  sc_out<   sc_lv<SubChN > >   divc;
  sc_out<   sc_lv<SubChN > >   dica;

  sc_in<sc_logic >         rst_n; /* global active-low reset */

  // signals between IOD and NI
  sc_fifo<pdu_flit<ChBW> > *   NI2P ; /* flit fifo, from NI to IO driver */
  sc_fifo<pdu_flit<ChBW> > *   P2NI ; /* flit fifo, from IO driver to NI */
  sc_signal<bool>              CP [SubChN]; /* credit input */
  sc_signal<bool>              CPa [SubChN]; /* credit ack */

  // signals between NI and FG/FS
  sc_fifo<pdu_frame<ChBW> > *   FIQ; /* the frame fifo, from PE to NI */
  sc_fifo<pdu_frame<ChBW> > *   FOQ; /* the frame fifo, from NI to PE */
  sc_signal<bool>               brst_n;	/* the reset in the SystemC modules */

  int x, y;			/* private local address */

  SC_CTOR(NetNode) 
    : doa("doa"), doc("doc"), 
    do0("do0"), do1("do1"), do2("do2"), do3("do3"), 
    doft("doft"), dovc("dovc"), doca("doca"),
    dia("dia"), dic("dic"), 
    di0("di0"), di1("di1"), di2("di2"), di3("di3"), 
    dift("dift"), divc("divc"), dica("dica"),
    rst_n("rst_n")
      {
	// dynamically get the parameters from Verilog test bench
	ncsc_get_param("x", x);
	ncsc_get_param("y", y);

	// initialization
	LIOD = new RTDriver("LIOD");
	NI = new Network_Adapter("NI", x, y);
	PE = new ProcElem("PE", x, y);
	NI2P = new sc_fifo<pdu_flit<ChBW> >(1);
	P2NI = new sc_fifo<pdu_flit<ChBW> >(1);
	FIQ = new sc_fifo<pdu_frame<ChBW> >(500);/* currently the fifo from PE is 500 frame deep */
	FOQ = new sc_fifo<pdu_frame<ChBW> >(1);

	// connections
	LIOD->NI2P(*NI2P);
	LIOD->P2NI(*P2NI);
	LIOD->rtid[0](di0);
	LIOD->rtod[0](do0);
	LIOD->rtid[1](di1);
	LIOD->rtod[1](do1);
	LIOD->rtid[2](di2);
	LIOD->rtod[2](do2);
	LIOD->rtid[3](di3);
	LIOD->rtod[3](do3);
	LIOD->rtift(dift);
	LIOD->rtivc(divc);
	LIOD->rtia(dia);
	LIOD->rtic(dic);
	LIOD->rtica(dica);
	LIOD->rtoft(doft);
	LIOD->rtovc(dovc);
	LIOD->rtoa(doa);
	LIOD->rtoc(doc);
	LIOD->rtoca(doca);
        for(unsigned int j=0; j<SubChN; j++) {
          LIOD->CP[j](CP[j]);
          LIOD->CPa[j](CPa[j]);
        }

	NI->frame_in(*FIQ);
	NI->frame_out(*FOQ);
	NI->IP(*P2NI);
	NI->OP(*NI2P);
	for(unsigned int j=0; j<SubChN; j++) {
	  NI->CP[j](CP[j]);
	  NI->CPa[j](CPa[j]);
	}
	
	PE->rst_n(brst_n);
	PE->Fout(*FIQ);
	PE->Fin(*FOQ);

	brst_n.write(false);

	SC_METHOD(rst_proc);
	sensitive << rst_n;
      }
  

  void rst_proc() {
    bool mrst_n;
    mrst_n = rst_n.read().is_01() ? rst_n.read().to_bool() : false;
    brst_n.write(mrst_n);
  }
};


#endif
