#ifndef Q_H
#define Q_H

#include "shared.h"
#define max_size 361
#define ptr_bw 32
class q {
  //tp arr[max_size];
  unsigned int head, tail;
  unsigned char wrapped;
  #pragma bitsize q.head ptr_bw
  #pragma bitsize q.tail ptr_bw
  #pragma bitsize q.wrapped 1

  public:

  /* constructor */
  q () { head = tail = 0; wrapped = false; };

 // /* returns front data of queue */
 // tp front () {
 //   return arr[head];
 // }

  bool active;
  /* return true iff queue is empty */
  bool empty () {
    return ((head == tail) && !wrapped);
  }

  /* return true iff queue is full */
  bool full () {
    return ((head == tail) && wrapped);
  }
  void reset(){
  head=tail=0;wrapped=false;active=1;
  }

  /* pop front of queue, returning the front data */
  /* q is corrupted if pop when empty */
  AIMove pop ();

  /* push data into back of queue */
  /* q is corrupted if push when full */
   void push (AIMove d);

  /* return current size of the queue */
  int size ();
};
//extern q moves_fifo;
//#pragma no_inter_loop_memory_analysis moves_fifo.head
//#pragma no_inter_loop_memory_analysis moves_fifo.tail
//#pragma no_inter_loop_memory_analysis moves_fifo.wrapped
//#pragma no_inter_loop_memory_analysis moves_fifo.active
//	#pragma no_inter_loop_memory_analysis moves_fifo
extern q moves_fifo1;
#pragma no_inter_loop_memory_analysis moves_fifo1.head
#pragma no_inter_loop_memory_analysis moves_fifo1.tail
#pragma no_inter_loop_memory_analysis moves_fifo1.wrapped
#pragma no_inter_loop_memory_analysis moves_fifo1.active
	#pragma no_inter_loop_memory_analysis moves_fifo1
//#ifndef PICO_SYNTH 
//  /* not synthesizable */
//  std::string to_string () const {
//    std::string s;
//    std::stringstream out;
//
//    out << "{ ";
//
//    if (wrapped) {
//      for (int i=head; i<max_size; i++) {
//        out << arr[i];
//	out << " , ";
//      }
//      for (int i=0; i<tail; i++) {
//        out << arr[i];
//	if (i != tail - 1) out << " , ";
//      }
//    } else {
//      for (int i=head; i<tail; i++) {
//        out << arr[i];
//	if (i != tail - 1) out << " , ";
//      }
//    }
//
//    out << " }";
//    s = out.str();
//    return s; 
//  }
//
//  operator std::string () { return to_string(); }
//  
//#endif
//
//
//
//#ifndef PICO_SYNTH 
///* not synthesizable */
//template <class tp, int max_size, int ptr_bw>
//std::ostream& operator << (std::ostream &os, const q<tp,max_size,ptr_bw> &f)
//{
//  os << f.to_string();
//  return os;
//}
//#endif
//
//
//#undef Q_ASSERT
////extern q<AIMove,361,32> moves_fifo;
#endif
