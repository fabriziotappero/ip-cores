//! Selects inputs to the data memory

#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(select_mem)
{
	sc_in<sc_logic> 	id_ex_m_datareq;
	sc_in<sc_logic> 	id_ex_m_datarw;
	sc_in<sc_lv<2> >	id_ex_m_byteselect;
	sc_in<sc_lv<32> >	id_ex_m_datastore;
	sc_out<sc_lv<32> >	datawrite;
	sc_in<sc_lv<32> >	ex_m_alu;
	sc_out<sc_uint<32> >	dataaddr;
	sc_out<sc_logic>	datareq;
	sc_out<sc_logic>	datarw;
	sc_out<sc_lv<2> >	databs;
	sc_in<sc_logic> 	enable_memstage;
	
	void do_select_mem();
	
	SC_CTOR(select_mem)
	{
		SC_METHOD(do_select_mem);
		sensitive << id_ex_m_datareq << id_ex_m_datarw << id_ex_m_datastore;
		sensitive << ex_m_alu << id_ex_m_byteselect << enable_memstage;
		//sensitive << datawrite;
	}
};
