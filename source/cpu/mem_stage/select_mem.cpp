/*!
  Sets the address and request signals to the data memory.
  For load instructions, data is set to ZZZ...
  sensitive << id_ex_m_datareq << id_ex_m_datarw << id_ex_m_datastore << ex_m_alu << datawrite;
 */
 
#include "select_mem.h" 
#include "../../constants/constants.h"
void select_mem::do_select_mem()
{
	sc_logic dreq = id_ex_m_datareq.read();
	sc_logic drw = id_ex_m_datarw.read();
	sc_lv<32> d;
	sc_uint<32> daddr;
	sc_lv<2> byteselect = id_ex_m_byteselect.read();
	
	
	if(enable_memstage.read() == SC_LOGIC_1)
	{
		if ((dreq == 1) && (drw == 1))
		{
			d = id_ex_m_datastore.read();
			datawrite.write(d);
		}
		else
		{
			d = WORD_ZERO;
			datawrite.write(d);
		}
		daddr = ex_m_alu.read();
		dataaddr.write(daddr);
		datareq.write(dreq);
		datarw.write(drw);
		databs.write(byteselect);
	}
	else
	{
		datawrite.write(WORD_ZERO);
		dataaddr.write(0);
		datareq.write(SC_LOGIC_0);
		datarw.write(SC_LOGIC_0);
		databs.write(byteselect);
		
	}
}
