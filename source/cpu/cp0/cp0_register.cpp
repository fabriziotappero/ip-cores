#include  "cp0_register.h"
 
 //! Read registers
/*!
  sensitive << all registers, reg_wr and reg_no
 */
void cp0_register::cp0_register_read()
{
  EPC_FOR_RFE.write( (sc_uint<32>) cp0regs[14]);
  reg_out = cp0regs[reg_no.read()];

}

//! Write registers
/*!
  sensitive_neg << in_clk
 */
void cp0_register::cp0_register_write()
{
  if (reset.read() == true)
    {
      cp0regs[0] = WORD_ZERO;
      cp0regs[1] = WORD_ZERO;
      cp0regs[2] = WORD_ZERO;
      cp0regs[3] = WORD_ZERO;
      cp0regs[4] = WORD_ZERO;
      cp0regs[5] = WORD_ZERO;
      cp0regs[6] = WORD_ZERO;
      cp0regs[7] = WORD_ZERO;
      cp0regs[8] = WORD_ZERO;
      cp0regs[9] = WORD_ZERO;
      cp0regs[0] = WORD_ZERO;
      cp0regs[11] = WORD_ZERO;
      cp0regs[12] = WORD_ZERO;
      cp0regs[13] = WORD_ZERO;
      cp0regs[14] = WORD_ZERO;
      cp0regs[15] = WORD_ZERO;
      cp0regs[16] = WORD_ZERO;
      cp0regs[17] = WORD_ZERO;
      cp0regs[18] = WORD_ZERO;
      cp0regs[19] = WORD_ZERO;
      cp0regs[20] = WORD_ZERO;
      cp0regs[21] = WORD_ZERO;
      cp0regs[22] = WORD_ZERO;
      cp0regs[23] = WORD_ZERO;
      cp0regs[24] = WORD_ZERO;
      cp0regs[25] = WORD_ZERO;
      cp0regs[26] = WORD_ZERO;
      cp0regs[27] = WORD_ZERO;
      cp0regs[28] = WORD_ZERO;
      cp0regs[29] = WORD_ZERO;
      cp0regs[30] = WORD_ZERO;
      cp0regs[31] = WORD_ZERO;
    }
    else
       if(check_excep.read() == SC_LOGIC_1)
	{
	   cp0regs[13] = cause.read(); 
	   cp0regs[14] = (sc_lv<32>) to_EPC.read();
	   cp0regs[8]  = (sc_lv<32>) to_BadVAddr.read();
	   cp0regs[12] = Temp_Status_Register.read();
	}
	else
	  if((cp0_inst.read() == CP0_ERET) && (insthold.read()==true)) 
	     cp0regs[12] = Temp_Status_Register.read();
	  else
             if ((reg_rw.read() == SC_LOGIC_1))
	     {
	        cp0regs[reg_no.read()] = reg_rs.read();
	     }
}

void cp0_register::cp0_status_register()
{

	sc_lv<6>	temp;
	sc_lv<32>	temp_32;
	
	if((check_excep.read() == SC_LOGIC_1))
	{
	   temp_32 = (cp0regs[12]).read();
	   
	   temp.range(5,2) = temp_32.range(3,0);
	   temp.range(1,0) = "00";
	   
	   temp_32.range(5,0) = temp;
	   
	   Temp_Status_Register.write(temp_32);
	}
	else
	   {
	      temp_32 = (cp0regs[12]).read();
	      
	      temp.range(3,0) = temp_32.range(5,2);
	      temp.range(5,4) = temp_32.range(5,4);
	      
	      temp_32.range(5,0) = temp;
	      
	      Temp_Status_Register.write(temp_32);
	   }
}

void cp0_register::enable_interrupt_and_OS()
{
	enable_interrupt.write(((cp0regs[12]).read())[0]);
	enable_kernel_mode.write(((cp0regs[12]).read())[1]);


}

