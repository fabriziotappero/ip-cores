//! Selects whether to bypass data memory or not
/*!
  When reading from memory, the data signal from data memory is chosen
  sensitive << id_ex_m_memtoreg << ex_m_alu << dataread;
 */
 
 #include "multiplexer_mem.h"
 
 void multiplexer_mem::do_multiplexer_mem()
 {
  sc_lv<32> store;
  sc_lv<2>  byteselect = id_ex_m_byteselect.read();
  sc_logic  bssign     = id_ex_m_bssign.read();
  if (id_ex_m_memtoreg.read() == SC_LOGIC_0)
    {
      store = ex_m_alu.read();
    }
  else
    {
      store = dataread.read();
      if (byteselect == "01")
	{
	  store = store & "00000000000000000000000011111111";
	  if ((store.range(7,7) == "1") && (bssign == SC_LOGIC_1))
	    store = store | "11111111111111111111111100000000";
	}
      else if (byteselect == "10")
	{
	  store = store & "00000000000000001111111111111111";
	  if ((store.range(15,15) == "1") && (bssign == SC_LOGIC_1))
	    store = store | "11111111111111110000000000000000";
	}
      
    }

  id_store.write(store);
  m_id_forward.write(store);
 }
