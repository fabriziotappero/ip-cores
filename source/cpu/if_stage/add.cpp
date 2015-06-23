#include "add.h"

void add::do_add()
{
	if_pc_add.write(((sc_uint<32>) pc_out.read()) + 4);
} 
