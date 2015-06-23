//! Selects whether to bypass data memory or not
/*!
  When reading from memory, the data signal from data memory is chosen
  sensitive << id_ex_m_memtoreg << ex_m_alu << dataread;
 */
 
#include "systemc.h"
#include "../../constants/constants.h"

SC_MODULE(multiplexer_mem)
{	
	sc_in<sc_lv<2> >	id_ex_m_byteselect;
	sc_in<sc_logic> 	id_ex_m_bssign; 
	sc_in<sc_logic> 	id_ex_m_memtoreg;
	sc_in<sc_lv<32> >	ex_m_alu;
	sc_in<sc_lv<32> >	dataread;
	sc_out<sc_lv<32> >	id_store;
	sc_out<sc_lv<32> >	m_id_forward;

	void do_multiplexer_mem();

	SC_CTOR(multiplexer_mem)
	{
		SC_METHOD(do_multiplexer_mem);
		sensitive << id_ex_m_memtoreg << ex_m_alu << dataread;
		sensitive << id_ex_m_byteselect << id_ex_m_bssign;
	}
}; 
