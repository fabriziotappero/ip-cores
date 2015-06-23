//!
/*
  No description
*/
#include "../../constants/config.h"

// #ifdef _HIGH_LEVEL_SIM_
#include "regfile_high.h"

void regfile::storeregister()
{
  sc_lv<5> d = rd;
  if(reset.read() == true)
    {
      for(int i = 0; i<32; i++)
	r[i] = WORD_ZERO;
    }
  else
    {
      if(wr == SC_LOGIC_1)
	r[(sc_uint<5>) d] = rd_in;
    }
}

//! Load register outputs
/*!
  Sets the register file output signals according the inputs
 */
void regfile::loadregister()
{
  sc_lv<5> t = rt;
  sc_lv<5> s = rs;   

  if(s == "00000")
    rs_out = WORD_ZERO;
  else
    rs_out = r[(sc_uint<5>) s];
  
  if(t == "00000")
    rt_out = WORD_ZERO;
  else
    rt_out = r[(sc_uint<5>) t];
}
// #endif
