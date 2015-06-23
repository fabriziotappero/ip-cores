#include "mux_rd.h"

void mux_rd::do_mux_rd()
{
	if (id_ex_alu_ctrl.read() == FUNC_MFLO)
	{
	   out_ex_alu_s.write(out_lo.read());
	   out_ex_id_forward_s.write(out_lo.read());
	}
	else
	   if (id_ex_alu_ctrl.read() == FUNC_MFHI)
	   {
	      out_ex_alu_s.write(out_hi.read());
	      out_ex_id_forward_s.write(out_hi.read());
	   }
	   else
	   {
	      out_ex_alu_s.write(in_ex_alu_s.read());
	      out_ex_id_forward_s.write(in_ex_id_forward_s.read());
	   }  
}
