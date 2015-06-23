// File: half_adder.h            /* Line 1 */

#include "systemc.h"             /* Line 2 */

SC_MODULE (half_adder) {         /* Line 3 */
  sc_in<bool> a, b;              /* Line 4 */

  sc_out<bool> sum, carry;       /* Line 5 */

  void prc_half_adder ();        /* Line 6 */

  SC_CTOR (half_adder) {         /* Line 7 */
    SC_METHOD (prc_half_adder);  /* Line 8 */
    sensitive << a << b;         /* Line 9 */
  }                              /* Line 10 */
};                               /* Line 11 */
