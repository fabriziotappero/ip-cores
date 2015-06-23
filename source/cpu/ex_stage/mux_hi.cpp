#include "mux_hi.h"

void mux_hi::do_mux_hi()
{
	if (id_ex_alu_ctrl.read() == FUNC_MTHI)
	  out.write(rs.read());
	else
	  out.write(hi.read());
}
