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
 02/05/2010  Initial version. <wsong83@gmail.com>
 03/06/2011  Remove the sc_unit datatype to support data width larger than 64. <wsong83@gmail.com>
 
*/

#include "rtdriver.h"

RTDriver::RTDriver(sc_module_name mname)
  : sc_module(mname),
    NI2P("NI2P"),
    P2NI("P2NI"),
    rtia("rtia"),
    rtic("rtic"),
    rtica("rtica"),
    rtoa("rtoa"),
    rtoc("rtoc"),
    rtoca("rtoca")
{
  SC_METHOD(IPdetect);
  sensitive << rtia;

  SC_METHOD(OPdetect);
  sensitive << rtod[0] << rtod[1] << rtod[2] << rtod[3] << rtovc << rtoft;

  SC_METHOD(Creditdetect);
  for(unsigned int i = 0; i<SubChN; i++) {
    sensitive << CPa[i];
    sensitive << out_cred[i];
  }
  sensitive << rtic << rtoca;

  SC_THREAD(send);
  SC_THREAD(recv);

  rtinp_sig = false;
  rtoutp_sig = false;
}
  
void RTDriver::IPdetect() {
  sc_logic ack_lv_high, ack_lv_low;		// the sc_logic ack

  ack_lv_high = rtia.read();
  ack_lv_low = rtia.read();  

  if(ack_lv_high.is_01() && ack_lv_high.to_bool())
    rtinp_sig = true;
  
  if(ack_lv_low.is_01() && (!ack_lv_low.to_bool()))
    rtinp_sig = false;
}

void RTDriver::OPdetect() {
  sc_lv<ChBW*4> data_lv;	// the ORed data
  sc_logic data_lv_high, data_lv_low;
  sc_lv<SubChN> vc_lv;		// the local copy of vc number
  sc_lv<3> ft_lv;		// the local copy of flit type

  data_lv = rtod[0].read() | rtod[1].read() | rtod[2].read() | rtod[3].read();
  vc_lv = rtovc.read();
  ft_lv = rtoft.read();
  data_lv_high = (sc_logic)(data_lv.and_reduce()) & (sc_logic)(vc_lv.or_reduce()) & (sc_logic)(ft_lv.or_reduce());
  data_lv_low = (sc_logic)(data_lv.or_reduce()) | (sc_logic)(vc_lv.or_reduce()) | (sc_logic)(ft_lv.or_reduce());

  if(data_lv_high.is_01() && data_lv_high.to_bool())
    rtoutp_sig = true;
  
  if(data_lv_high.is_01() && (!data_lv_low.to_bool()))
    rtoutp_sig = false;
}  

void RTDriver::Creditdetect() {
  sc_lv<SubChN> mic;		// the local input credit
  sc_lv<SubChN> mica;		// the local input credit ack
  sc_lv<SubChN> moc;		// the local output credit;
  sc_lv<SubChN> moca;		// the local output credit ack;
  
  mic = rtic.read();
  moca = rtoca.read();

  for(unsigned int i=0; i<SubChN; i++) {
    CP[i].write(mic[i].is_01()? mic[i].to_bool():false);
    out_cred_ack[i] = moca[i].is_01()? moca[i].to_bool():false;
    mica[i] = CPa[i].read();
    moc[i] = out_cred[i];
  }

  rtica.write(mica);
  rtoc.write(moc);
} 

void RTDriver::send() {
  FLIT mflit;			// the local flit buffer
  unsigned int i, j;		// local loop index
  sc_lv<ChBW*4> mdata[4];	// local data copy
  sc_lv<SubChN> mvc;		// local vcn
  sc_lv<3> mft;			// local flit type
  
  // initialize the output ports
  mdata[0] = 0;
  mdata[1] = 0;
  mdata[2] = 0;
  mdata[3] = 0;
  mvc = 0;
  mft = 0;


  rtid[0].write(mdata[0]);
  rtid[1].write(mdata[1]);
  rtid[2].write(mdata[2]);
  rtid[3].write(mdata[3]);
  rtivc.write(mvc);
  rtift.write(mft);

  while(true) {
    mflit = NI2P->read();	// read in the flit

    // write the flit
    if(mflit.ftype == F_HD) {
      // the target address
      mdata[mflit.addrx&0x3][0] = SC_LOGIC_1;
      mdata[(mflit.addrx&0xc)>>2][1] = SC_LOGIC_1;
      mdata[mflit.addry&0x3][2] = SC_LOGIC_1;
      mdata[(mflit.addry&0xc)>>2][3] = SC_LOGIC_1;
      
      for(i=0,j=4; i<(ChBW-1)*4; i++, j++) {
	switch((mflit[i/4] >> ((i%4)*2)) & 0x3) {
	case 0: mdata[0][j] = SC_LOGIC_1; break;
	case 1: mdata[1][j] = SC_LOGIC_1; break;
	case 2: mdata[2][j] = SC_LOGIC_1; break;
	case 3: mdata[3][j] = SC_LOGIC_1; break;
	}
      }	
    } else {
      for(i=0; i<ChBW*4; i++) {
	switch((mflit[i/4] >> ((i%4)*2)) & 0x3) {
	case 0: mdata[0][i] = SC_LOGIC_1; break;
	case 1: mdata[1][i] = SC_LOGIC_1; break;
	case 2: mdata[2][i] = SC_LOGIC_1; break;
	case 3: mdata[3][i] = SC_LOGIC_1; break;
	}
      }
    }
    
    // flit type
    switch(mflit.ftype) {
    case F_HD: mft[0] = SC_LOGIC_1; break;
    case F_DAT: mft[1] = SC_LOGIC_1; break;
    case F_TL: mft[2] = SC_LOGIC_1; break;
    default: break;
    }
    
    // VC number
    mvc[mflit.vcn] = SC_LOGIC_1;
    
    // write to the port
    rtid[0].write(mdata[0]);
    rtid[1].write(mdata[1]);
    rtid[2].write(mdata[2]);
    rtid[3].write(mdata[3]);
    rtivc.write(mvc);
    rtift.write(mft);

    // wait for the router to capture the data
    wait(rtinp_sig.posedge_event());
    wait(0.2, SC_NS);		// a delay to avoid data override
    
    // clear the data
    mdata[0] = 0;
    mdata[1] = 0;
    mdata[2] = 0;
    mdata[3] = 0;
    mvc = 0;
    mft = 0;
    
    rtid[0].write(mdata[0]);
    rtid[1].write(mdata[1]);
    rtid[2].write(mdata[2]);
    rtid[3].write(mdata[3]);
    rtivc.write(mvc);
    rtift.write(mft);
   
    // wait for the input port be ready again
    wait(rtinp_sig.negedge_event());
    wait(0.2, SC_NS);		// a delay to avoid data override
  }
}

void RTDriver::recv() {
  FLIT mflit;			// the local flit buffer
  sc_lv<ChBW*4> mdata[4];	// local data copy
  sc_lv<SubChN> mvc;		// local vc number
  sc_lv<3> mft;			// local flit type
  sc_logic mack = SC_LOGIC_0;	// local copy of ack
  sc_lv<4> dd;		      // the current 1-of-4 data under process
  unsigned int i, j;	      // local loop index
  
  // initialize the ack signal
  rtoa.write(mack);

  while(true) {
    // wait for an incoming flit
    wait(rtoutp_sig.posedge_event());
    if(out_cred_ack[mflit.vcn].read())
      wait(out_cred_ack[mflit.vcn].negedge_event());

    // clear the flit
    mflit.clear();

    // analyse the flit
    mdata[0] = rtod[0].read();
    mdata[1] = rtod[1].read();
    mdata[2] = rtod[2].read();
    mdata[3] = rtod[3].read();
    mft = rtoft.read();
    mvc = rtovc.read();

    switch(mft.to_uint()) {
    case 1: mflit.ftype = F_HD; break;
    case 2: mflit.ftype = F_DAT; break;
    case 4: mflit.ftype = F_TL; break;
    default: mflit.ftype = F_IDLE; // shoudle not happen
    }
    
    if(mflit.ftype == F_HD) {
      // fetch the address
      dd[0] = mdata[0][0]; dd[1] = mdata[1][0]; dd[2] = mdata[2][0]; dd[3] = mdata[3][0]; 
      mflit.addrx |= (c1o42b(dd.to_uint()) << 0);
      dd[0] = mdata[0][1]; dd[1] = mdata[1][1]; dd[2] = mdata[2][1]; dd[3] = mdata[3][1]; 
      mflit.addrx |= (c1o42b(dd.to_uint()) << 2);
      dd[0] = mdata[0][2]; dd[1] = mdata[1][2]; dd[2] = mdata[2][2]; dd[3] = mdata[3][2]; 
      mflit.addry |= (c1o42b(dd.to_uint()) << 0);
      dd[0] = mdata[0][3]; dd[1] = mdata[1][3]; dd[2] = mdata[2][3]; dd[3] = mdata[3][3]; 
      mflit.addry |= (c1o42b(dd.to_uint()) << 2);
      
      // fill in data
      for(i=1; i<ChBW; i++) {
	for(j=0; j<4; j++) {
	  dd[0] = mdata[0][i*4+j]; 
	  dd[1] = mdata[1][i*4+j]; 
	  dd[2] = mdata[2][i*4+j]; 
	  dd[3] = mdata[3][i*4+j];
	  mflit[i-1] |= c1o42b(dd.to_uint()) << j*2;
	}
      }
    } else{
      for(i=0; i<ChBW; i++) {
	for(j=0; j<4; j++) {
	  dd[0] = mdata[0][i*4+j]; 
	  dd[1] = mdata[1][i*4+j]; 
	  dd[2] = mdata[2][i*4+j]; 
	  dd[3] = mdata[3][i*4+j];
	  mflit[i] |= c1o42b(dd.to_uint()) << j*2;
	}
      } 
    }
    
    // get the binary vc number
    unsigned int fvcn = mvc.to_uint();
    while(fvcn != 1) {
      mflit.vcn += 1;
      fvcn >>= 1;
    }

    // send the flit to the NI
    P2NI->write(mflit);

    // send back a credit
    out_cred[mflit.vcn] = true;
    
    wait(0.2, SC_NS);		// a delay to avoid data override
    rtoa.write(~mack);		// notify that data is captured

    // wait for the data withdrawal
    wait(rtoutp_sig.negedge_event());
    if(!out_cred_ack[mflit.vcn].read())
      wait(out_cred_ack[mflit.vcn].posedge_event());

    wait(0.2, SC_NS);		// a delay to avoid data override
    rtoa.write(mack);		// notify that data is captured
    out_cred[mflit.vcn] = false;
  }
}

unsigned int RTDriver::c1o42b(unsigned int dd) {
  switch(dd) {
  case 1: return 0;
  case 2: return 1;
  case 4: return 2;
  case 8: return 3;
  default: return 0xff;
  }
}
