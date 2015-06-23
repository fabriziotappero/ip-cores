#include "mux_alu2.h"

void mux_alu2::do_mux_alu2()
{
	sc_lv<2> isc = id_sign_ctrl;
	sc_lv<32> v_id_alu2;
	if(isc == "00")
	   v_id_alu2 = id_mux_fw2;
	else 
	   if(isc == "01")
	      v_id_alu2 = id_sign_extend;
	   else 
	      v_id_alu2 = (sc_int<32>) 4;

	id_alu2 = v_id_alu2;
	cp0_reg_rs = v_id_alu2;

} 
