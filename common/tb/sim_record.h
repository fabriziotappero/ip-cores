/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Simulation record element.
 
 History:
 28/06/2010  Initial version. <wsong83@gmail.com>
 27/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

#ifndef SIM_RECORD_H_
#define SIM_RECORD_H_

#include <ostream>

using namespace std;

template<unsigned int TSIZE>
class sim_record;

template<unsigned int TSIZE>
ostream& operator<< (ostream& os, const sim_record<TSIZE>& mrd) {
  os << hex << mrd.key << " " << dec;
  for(unsigned int i=0; i<TSIZE; i++)
    os << mrd.stamp[i] << " ";
  return os;
}  

template<unsigned int TSIZE>
class sim_record {

 public:
  double stamp [TSIZE];		/* vector to record time information */
  long key;			/* the hash key for searching */
  unsigned int index;		/* the current stamp index */
  sim_record<TSIZE> * next;	/* pointer to the next record */
  sim_record<TSIZE> * pre;	/* pointer to the previous record */

  sim_record()
    : key(0), index(0), next(NULL), pre(NULL) 
    {}
  
 sim_record(double mt, long mkey, sim_record<TSIZE> * mnp = NULL, sim_record<TSIZE> * mpp = NULL)
   : key(mkey), index(1), next(mnp), pre(mpp) {
    for(unsigned int i=0; i<TSIZE; i++)
      stamp[i] = mt;
  }

  sim_record( const sim_record<TSIZE>& mrd )
    : key(mrd.key), index(mrd.index), next(NULL), pre(NULL) {
    for(unsigned int i=0; i<TSIZE; i++)
      stamp[i] = mrd.stamp[i];
  }

  sim_record<TSIZE>& operator= ( const sim_record<TSIZE>& mrd ) {
    key = mrd.key;
    index = mrd.index;
    next = NULL;
    pre = NULL;
    for(unsigned int i=0; i<TSIZE; i++)
      stamp[i] = mrd.stamp[i];
  }

  ~sim_record() {
    if(next != NULL) {
      delete next;
      next = NULL;
    }
    pre = NULL;
  }

  operator long() const {
    return key;
  }

  friend ostream& operator<< <TSIZE> (ostream&, const sim_record<TSIZE>&);

};


#endif
