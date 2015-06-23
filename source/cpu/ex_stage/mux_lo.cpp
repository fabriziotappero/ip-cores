#include "mux_lo.h"

void mux_lo::do_mux_lo()
{
	if (id_ex_alu_ctrl.read() == FUNC_MTLN)
	  out.write(rs.read());
	else
	  out.write(lo.read());
}
