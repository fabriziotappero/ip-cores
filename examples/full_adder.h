// File: full_adder.h

#include "half_adder.h"

SC_MODULE (full_adder) {
  sc_in<bool> a, b, carry_in;

  sc_out<bool> sum, carry_out;

  sc_signal<bool> c1, s1, c2;

  void prc_or ();

  half_adder *ha1_ptr, *ha2_ptr,*ha2_ptr; // not supported by sc2v_0.4 ?

  SC_CTOR (full_adder) {
    ha1_ptr = new half_adder ("ha1");

    // Named association:
    ha1_ptr->a (a);
    ha1_ptr->b (b);
    ha1_ptr->sum (s1);
    ha1_ptr->carry (c1);

    ha2_ptr = new half_adder ("ha2");

    // Positional association:
//    (*ha2_ptr) (s1, carry_in, sum, c2); // not supported by scv_0.4 ?
    ha2_ptr->a (s1);
    ha2_ptr->b (carry_in);
    ha2_ptr->sum (sum);
    ha2_ptr->carry (c2);


    SC_METHOD (prc_or);
    sensitive << c1 << c2;
  }
//#ifndef SYNTHESIS
// Destructors not supported by sc2v _0.4 ?
//~full_adder() {
//  delete ha1_ptr;
//  delete ha2_ptr;
//}
//#endif
};
