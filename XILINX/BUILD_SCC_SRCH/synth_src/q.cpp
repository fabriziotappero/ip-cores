
//#ifdef PICO_SYNTH
//#define Q_ASSERT(_cond, _msg)
////#include <iostream>
//#include "pico.h"
//#include "q.hpp"
//#include "./shared.h"
//using namespace std;
//#else
///* not synthesizable */
//#include <iostream>
//#include <sstream>
//#include <string>
//#include <assert.h>
//
//static void debug_assert (bool cond, char * msg) {
//	if (!cond) {
//		printf("assert failed: %s\n", msg);
//		assert(0);
//	}
//}
//
//#define Q_ASSERT(_cond, _msg) debug_assert(_cond, _msg)
//#endif
//#define max_size 361
//#define ptr_bw 32
//FIFO(queue,AIMove);
//#pragma no_inter_loop_stream_analysis pico_stream_input_queue
//#pragma no_inter_loop_stream_analysis pico_stream_output_queue
//#pragma no_inter_task_stream_analysis pico_stream_input_queue
//#pragma no_inter_task_stream_analysis pico_stream_output_queue
//
//#pragma fifo_length queue 361
////template <class tp=AIMove, int max_size=128, int ptr_bw=32>
//
//  /* pop front of queue, returning the front data */
//  /* q is corrupted if pop when empty */
//  AIMove q::pop (){
//    /* assert that before pop, queue is not empty (underflow check) */
//    Q_ASSERT((!wrapped && (head < tail)) || (wrapped && (head >= tail)),
//    		"queue underflowed");
//    AIMove d = pico_stream_input_queue();
//	//cout <<"pop: "<<head<<":"<<tail<<":"<<wrapped<<endl;
//    if (head == max_size-1) {
//      head = 0;
//      wrapped = false;
//    } else {
//      head = head + 1;
//    }
//    return d;
//  }
//
//  /* push data into back of queue */
//  /* q is corrupted if push when full */
//   void q::push (AIMove d){
//    pico_stream_output_queue(d);
//    if (tail == max_size-1) {
//      tail = 0;
//      wrapped = true;
//    } else {
//      tail = tail + 1;
//    }
//    /* assert that after push, queue is not empty (overflow check) */
//    Q_ASSERT((!wrapped && (head < tail)) || (wrapped && (head >= tail)),
//    		"Queue overflowed") ;
//	//cout <<"push: "<<head<<":"<<tail<<":"<<wrapped<<endl;
//  }
//
//  /* return current size of the queue */
//  int q::size (){
//    if (wrapped) {
//      return (max_size - head) + (tail - 0);
//    } else {
//      return tail - head;
//    }
//  }
//q  moves_fifo;
//
//#include "shared.h"
//#include"q.hpp"
//
//#ifdef PICO_SYNTH
//#define Q_ASSERT(_cond, _msg)
//#include <iostream>
//#include "pico.h"
//using namespace std;
//#else
///* not synthesizable */
//#include <iostream>
//#include <sstream>
//#include <string>
//#include <assert.h>
//
//static void debug_assert (bool cond, char * msg) {
//	if (!cond) {
//		printf("assert failed: %s\n", msg);
//		assert(0);
//	}
//}
//
//#define Q_ASSERT(_cond, _msg) debug_assert(_cond, _msg)
//#endif
//FIFO(queue,AIMove);
//
//  /* pop front of queue, returning the front data */
//  /* q is corrupted if pop when empty */
//  template<class tp, int max_size, int ptr_bw>
//  tp q<tp,max_size,ptr_bw>::pop () {
//    /* assert that before pop, queue is not empty (underflow check) */
//    Q_ASSERT((!wrapped && (head < tail)) || (wrapped && (head >= tail)),
//    		"queue underflowed");
//    tp d = pico_stream_input_queue();
//	cout <<"pop: "<<head<<":"<<tail<<":"<<wrapped<<endl;
//    if (head == max_size-1) {
//      head = 0;
//      wrapped = false;
//    } else {
//      head = head + 1;
//    }
//    return d;
//  }
//
//  /* push data into back of queue */
//  /* q is corrupted if push when full */
//  template<class tp, int max_size, int ptr_bw>
//  void q<tp,max_size,ptr_bw>::push (tp d) {
//    pico_stream_output_queue(d);
//    if (tail == max_size-1) {
//      tail = 0;
//      wrapped = true;
//    } else {
//      tail = tail + 1;
//    }
//    /* assert that after push, queue is not empty (overflow check) */
//    Q_ASSERT((!wrapped && (head < tail)) || (wrapped && (head >= tail)),
//    		"Queue overflowed") ;
//	cout <<"push: "<<head<<":"<<tail<<":"<<wrapped<<endl;
//  }
//
//  /* return current size of the queue */
//  template<class tp, int max_size, int ptr_bw>
//  int q<tp,max_size,ptr_bw>::size () {
//    if (wrapped) {
//      return (max_size - head) + (tail - 0);
//    } else {
//      return tail - head;
//    }
//  }
//
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
//#ifndef PICO_SYNTH 
///* not synthesizable */
//template <class tp, int max_size, int ptr_bw>
//std::ostream& operator << (std::ostream &os, const q<tp,max_size,ptr_bw> &f)
//{
//  os << f.to_string();
//  return os;
//}
//#endif
//q moves_fifo;
//#pragma internal_blockram moves_fifo
//#pragma no_inter_loop_memory_analysis moves_fifo.head
//#pragma no_inter_loop_memory_analysis moves_fifo.tail
//#pragma no_inter_loop_memory_analysis moves_fifo.wrapped
//#pragma no_inter_loop_memory_analysis moves_fifo.active
//#pragma no_inter_loop_memory_analysis moves_fifo
//q moves_fifo1;
//#pragma internal_blockram moves_fifo1
//#pragma no_inter_loop_memory_analysis moves_fifo1.head
//#pragma no_inter_loop_memory_analysis moves_fifo1.tail
//#pragma no_inter_loop_memory_analysis moves_fifo1.wrapped
//#pragma no_inter_loop_memory_analysis moves_fifo1.active
//#pragma no_inter_loop_memory_analysis moves_fifo1
