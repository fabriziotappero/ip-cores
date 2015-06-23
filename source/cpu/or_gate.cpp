#include "or_gate.h"

void or_gate::do_or_gate()
{
   out_gate.write((in_A.read() | in_B.read()));
} 
