#include "add_new_pc.h"

void add_new_pc::do_add_new_pc()
{	
	id_new_pc.write(((sc_int<32>) (if_id_next_pc.read())) + (((sc_int<32>) (id_sign_extend.read()) << 2)));
} 
