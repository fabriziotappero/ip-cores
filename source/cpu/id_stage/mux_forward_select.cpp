#include "mux_forward_select.h"

void mux_forward_select::do_mux_forward_select()
{
	sc_lv<2> ifc = id_fw_ctrl.read();

	if( ifc == "00")
	   id_mux_fw.write(id_reg.read());    
	else 
	   if( ifc == "01")
	      id_mux_fw.write(ex_id_forward.read());    
	   else 
	      if( ifc == "10")
	         id_mux_fw.write(m_id_forward.read());    
	      else
		 id_mux_fw.write(wb_id_forward.read());
} 
