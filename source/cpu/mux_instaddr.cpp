#include "mux_instaddr.h"

void mux_instaddr::do_mux_instaddr()
{
	if(m_wb_interrupt_signal.read() == true)
	{
	   sc_lv<16> temp_1;
	   sc_lv<5>  temp_2;
	   sc_lv<6>  temp_3;
	   
	   temp_1 = (ex_mem_inst.read()).range(31,16);		// upper 16 bit 
	   temp_2 = (ex_mem_inst.read()).range(10,6); 		//
	   temp_3 = (ex_mem_inst.read()).range(5,0); 		//opcode
	   
	   cout << " interrupt" << endl;
	   cout << " temp1 = " << temp_1 << endl;
	   cout << " temp2 = " << temp_2 << endl;
	   cout << " temp3 = " << temp_3 << endl;
	   cout << " inst = " << ex_mem_inst.read() << endl;
	   
	   //|| 
	   
	   
	   if(((ex_m_instaddr.read() - m_wb_instaddr.read()) == 4))
	   {
	      if(((temp_1 == HALFWORD_ZERO) && (temp_2 == "00000") && ((temp_3 == "010010") || (temp_3 == "010000") )))
	      {
	         m_wb_instaddr_s.write(m_wb_instaddr.read() - 4 );
		 cout << " Istruz MFLO o MFHI durante l'interrupt" << endl;
	      }
	      else
	      {
	         m_wb_instaddr_s.write(m_wb_instaddr.read());
		 cout << " Indirizzi consecutivi delle ultime 2 istruz durante l'interrupt" << endl;
	      }
	   }
	   else
	   {
	      m_wb_instaddr_s.write(ex_m_instaddr.read());
	      cout << " indirizzi delle ultime due istruz non consecutivi durante l'interrupt" << endl;
	   }
	 }
	else
	   m_wb_instaddr_s.write(m_wb_instaddr.read());
}
