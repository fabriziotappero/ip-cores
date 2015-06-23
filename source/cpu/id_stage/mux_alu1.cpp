#include "mux_alu1.h"

void mux_alu1::do_mux_alu1()
{
	sc_logic isc = id_shamt_ctrl;
	sc_logic ips = id_pc_store;

	sc_lv<2> select;
	select[1] = isc;
	select[0] = ips;
	sc_lv<32> iii = if_id_inst;
	sc_lv<32> v_id_alu1;


	if (id_mfc0.read() == SC_LOGIC_1)
	   v_id_alu1 = cp0_reg_out;
	else 
	   if(select == "00")
	      v_id_alu1 = id_mux_fw1;
	   else
	      if(select == "01")  
	         v_id_alu1 = if_id_next_pc;
	      else
	         v_id_alu1 = ("00000000000000000000000000",iii.range(11,6));


	id_alu1 = v_id_alu1;
} 
