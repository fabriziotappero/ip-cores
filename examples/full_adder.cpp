// File: full_adder.cpp

#include "full_adder.h"

void full_adder::prc_or () {
  carry_out.write(c1 | c2);
}
