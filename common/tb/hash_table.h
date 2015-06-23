/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 A hash table container to store the frames under transmission.
 ?? Using STL may be better?

 Sorry, I have no intention to explain the codes below as it is unlikely to modify it.
 If there are bugs here, please email me.
 
 History:
 29/06/2010  Initial version. <wsong83@gmail.com>
 27/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

#ifndef HASH_TABLE_H_
#define HASH_TABLE_H_

#include <ostream>

using namespace std;

template<typename T, unsigned int HSIZE>
class hash_table;


template<typename T, unsigned int HSIZE>
ostream& operator<< (ostream& os, const hash_table<T,HSIZE>& HB) {
  T * item;
  os << "Records in hash table:" << endl;
  for(unsigned int i=0; i<HSIZE; i++) {
    os << "vector " << i << ": ";
    item = HB.dat[i][0];
    while(item != NULL) {
      os << *item << "| ";
      item = item->next;
    }
    os << endl;
  }
  return os;
}  

template<typename T, unsigned int HSIZE>
class hash_table {

 public:
  T * dat [HSIZE][2];
  
  hash_table() {
    for(unsigned int i=0; i<HSIZE; i++) {
      dat[i][0] = NULL;
      dat[i][1] = NULL;
    }
  }

  void insert ( T& );	 /* insert an item into the hash table */
  T * find ( long );	 /* find an item */
  T * find ( const T& ); /* find an item by reading an existing item */
  void clear ( T * );	 /* delete an item in the hash table */
  
  ~hash_table() {
    for(unsigned int i=0; i<HSIZE; i++) {
      if(dat[i][0] != NULL) {
	delete dat[i][0];
	dat[i][0] = NULL;
	dat[i][1] = NULL;
      }
    }
  }

  friend ostream& operator<< <T,HSIZE> (ostream&, const hash_table<T,HSIZE>&);

 private:
  T* search (T*, long);
};

template<typename T, unsigned int HSIZE>
  void hash_table<T,HSIZE>::insert ( T& RD) {
  long key = RD.key;
  unsigned int vcn = key%HSIZE;
  T * entry = dat[vcn][1];
  
  if(entry == NULL) {	     /* the whole vector is empty right now */
    dat[vcn][0] = &RD;
    dat[vcn][1] = &RD;
  } else {			/* non-empty vector */
    entry->next = &RD;
    RD.pre = entry;
    dat[vcn][1] = &RD;
  }
}

template<typename T, unsigned int HSIZE>
  T * hash_table<T,HSIZE>::find ( long mkey) {
  unsigned int vcn = mkey%HSIZE;
  return search(dat[vcn][0], mkey);
}

template<typename T, unsigned int HSIZE>
  T * hash_table<T,HSIZE>::find ( const T& RD) {
  return find((long)(RD));
}
 
template<typename T, unsigned int HSIZE>
  void hash_table<T,HSIZE>::clear ( T * RD) {
  unsigned int vcn = ((long)(*RD)) % HSIZE;
  
  if(RD->pre == NULL) 		/* head of a vector */
    dat[vcn][0] = RD->next;
  
  if(RD->next == NULL)		/* tail of a vector */
    dat[vcn][1] = RD->pre;

  if(RD->pre != NULL)
    (RD->pre)->next = RD->next;

  if(RD->next != NULL)
    (RD->next)->pre = RD->pre;

  RD->pre = NULL;
  RD->next = NULL;

  delete RD;
}

template<typename T, unsigned int HSIZE>
  T* hash_table<T,HSIZE>::search (T* entry, long mkey) {
  while(entry != NULL) {
    if((long)(*entry) == mkey)
      return entry;
    else
      entry = entry->next;
  }
  return NULL;
}

#endif
