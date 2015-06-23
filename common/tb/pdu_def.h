/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Package definition.

 History:
 19/08/2008  Initial version. <wsong83@gmail.com>
 04/08/2008  Add the check empty function. <wsong83@gmail.com>
 22/09/2008  Override the copy and = operations.  <wsong83@gmail.com>
 21/09/2010  Support VC and use templates. <wsong83@gmail.com>
 19/11/2010  Fixed to support the minimal 8bit VC. <wsong83@gmail.com>
 27/05/2011  Clean up for opensource. <wsong83@gmail.com>
 30/05/2011  Clear the addresses field when clear a flit. <wsong83@gmail.com>
 
*/

#ifndef PDU_DEF_H_
#define PDU_DEF_H_

#include <ostream>
#include <iomanip>

using namespace std;

// flit types: data, idle, head and tail
enum ftype_t {F_DAT, F_IDLE, F_HD, F_TL};

template<unsigned int BW>
class pdu_flit;

// override the method to stream out flits
template<unsigned int BW>
ostream& operator<< (ostream& os, const pdu_flit<BW>& dd) {
  switch(dd.ftype) {
  case F_DAT:
    os << hex << "<DATA:" << (unsigned int)(dd.vcn) << ":" << (unsigned int)(dd.prio) << ":";
    for(unsigned int i=0; i<BW; i++)
      os << setw(2) << setfill('0') << (unsigned int)(dd[i]);
    os << setw(0) << dec << ">";
    break;
  case F_HD:
    os << hex << "<HEAD:" << (unsigned int)(dd.vcn) << ":" << (unsigned int)(dd.prio) << ":" << (unsigned int)(dd.addrx) << "," << (unsigned int)(dd.addry) << ":";
    for(unsigned int i=0; i<BW-1; i++)
      os << setw(2) << setfill('0') << (unsigned int)(dd[i]);
    os << setw(0) << dec << ">";
    break;
  case F_TL:
    os << hex << "<TAIL:" << (unsigned int)(dd.vcn) << ":" << (unsigned int)(dd.prio) << ":";
    for(unsigned int i=0; i<BW; i++)
      os  << setw(2) << setfill('0') << (unsigned int)(dd[i]);
    os << setw(0) << dec << ">";
    break;
  case F_IDLE:
    os << "<IDLE>" ;
    break;
  default:
    os << "<ERR!>" ;
    break;
  }

  return os;
}

// flit used in NoC communication
template<unsigned int BW>
class pdu_flit {
 public:
    unsigned char vcn;
    unsigned char prio;
    ftype_t ftype;
    unsigned int addrx, addry;
 private:
    unsigned char data [BW];

     void copy(const pdu_flit<BW>& dd) {
      vcn = dd.vcn;
      prio = dd.prio;
      ftype = dd.ftype;
      addrx = dd.addrx;
      addry = dd.addry;
      for(unsigned int i=0; i<BW; i++) data[i] = dd.data[i];
    }

public:
    pdu_flit()
      : vcn(0), prio(0), ftype(F_IDLE) 
    {
      for(unsigned int i=0; i<BW; i++) data[i] = 0;
    }

    void clear(){                    // clear the flit
      vcn = 0;
      prio = 0;
      ftype = F_IDLE;
      addrx = 0;
      addry = 0;
      for(unsigned int i=0; i<BW; i++) data[i] = 0;
    }

    unsigned char& operator[] (unsigned int index){         // read as a vector
      return data[index];
    }

    const unsigned char& operator[] (unsigned int index) const {         // read as a vector
      return data[index];
    }
    
    friend ostream& operator<< <BW> (ostream& os, const pdu_flit<BW>& dd);   // output to standard output stream

    pdu_flit(const pdu_flit<BW>& dd){                           // override the default copy operation
      copy(dd);
    }

    pdu_flit& operator=(const pdu_flit<BW>& dd){                // override the default eque with operation
      copy(dd);
      return(*this);
    }
};

//===============================================================================
// method to stream out frames
template<unsigned int BW>
class pdu_frame;

template<unsigned int BW>
ostream& operator<< (ostream& os, const pdu_frame<BW>& dd) {
  os << hex << "<FRAME:p" << (unsigned int)(dd.prio) << ":a" << (unsigned int)(dd.addrx) << "," << (unsigned int)(dd.addry) << ":s" << dd.fsize << ":";
  //  os << setw(2) << setfill('0');
  for(unsigned int i=0; i<dd.fsize; i++)
    os << setw(2) << setfill('0') << (unsigned int)(dd[i]);
  os << setw(0) << dec << ">";
  return os;
}

// frame definition
template<unsigned int BW>
class pdu_frame{

 public:
  unsigned int addrx, addry;
  unsigned char prio;
  unsigned int fsize;
  int rptr, wptr;

 private:
  unsigned char * data;                       // data field

 public:
  pdu_frame()
    : addrx(0), addry(0), prio(0), fsize(0), rptr(-1), wptr(0), data(NULL)
    {}
  
  pdu_frame(unsigned int fs)
    : addrx(0), addry(0), prio(0), fsize(fs), rptr(-1), wptr(0)
    {
      data = new unsigned char [fs];
    }

  ~pdu_frame() {
    if(data != NULL) {
      delete[] data;
      data = NULL;
    }
  }

  void clear() {
    rptr = -1;
    wptr = 0;
  }

  unsigned char&  operator[] (unsigned int index) {
    if(index > fsize)   // need to enlarge the buf
      resize(index);
    
    return data[index];
  }

  const unsigned char&  operator[] (unsigned int index) const {
    return data[index];
  }

  bool empty() {
    return ((rptr == wptr) || (wptr == 0));
  }
      
  void push(unsigned char dd) {
    if(wptr==fsize)
      resize(fsize+1);
    
    data[wptr++] = dd;
  }
   
  unsigned char pop() {
    if(empty())
      return 0;
    
    return data[rptr++];
  }

  pdu_frame& operator<< (const pdu_flit<BW>& dd) {
    switch(dd.ftype) {
    case F_DAT:
      for(unsigned int i=0; i<BW; i++)
	push(dd[i]);
      break;
    case F_HD:
      addrx = dd.addrx;
      addry = dd.addry;
      prio = dd.prio;
      for(unsigned int i=0; i<BW-1; i++)
	push(dd[i]);
      break;
    case F_TL:
      for(unsigned int i=0; i<BW; i++)
	push(dd[i]);
      resize(wptr);
      break;
    default:
      break;
    }
    return *this;
  }
    
  pdu_frame& operator>> (pdu_flit<BW>& dd) {
    if(rptr==-1) {
      dd.ftype = F_HD;
      rptr++;
      for(unsigned int i=0; i<BW-1; i++) {
	dd[i] = pop();
      }
      dd.addrx = addrx;
      dd.addry = addry;
    } else {
      dd.ftype = F_DAT;
      for(unsigned int i=0; i<BW; i++) {
	dd[i] = pop();
      }
    }
    if(empty())
      dd.ftype = F_TL;
    
    return *this;
  }   

  //  friend ostream& operator<< <BW> (ostream& os, const pdu_frame<BW>& dd);

  pdu_frame(const pdu_frame<BW>& dd) {
    copy(dd);
  }

  pdu_frame<BW>& operator=(const pdu_frame<BW>& dd) {
    copy(dd);
    return (*this);
  }

  unsigned int psize() {
    unsigned int prac_size = fsize;
    while(1) {
      if(data[prac_size-1] == 0)
	    prac_size--;
      else
	    break;
    }
    return prac_size;
  }
  
  private:
  void resize(unsigned int fs) {
    // boundry check
    if(fs == fsize)
      return;
    
    // resize the buffer
    unsigned char * buf = new unsigned char [fs];
    for(unsigned int i=0; (i<fsize && i<fs); i++) {
      buf[i] = data[i];
    }
    fsize = fs;
    delete[] data;
    data = buf;
  }
  
  void copy(const pdu_frame<BW>& dd) {
    addrx = dd.addrx;
    addry = dd.addry;
    prio = dd.prio;
    resize(dd.fsize);
    rptr = dd.rptr;
    wptr = dd.wptr;
    
    for(unsigned int i=0; i<fsize; i++) {
      data[i] = dd.data[i];
    }
  }
  
};


#endif      /* PDU_DEF_H_ */
