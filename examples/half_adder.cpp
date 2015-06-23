// File: half_adder.cpp					// Line 1
#include "half_adder.h"					// Line 2

void half_adder::prc_half_adder () {	// Line 3
//  sum = a ^ b;						// Line 4a				
  sum.write(a ^ b);						// Line 4
//  carry = a & b;						// Line 5a
  carry.write(a & b);					// Line 5
}
