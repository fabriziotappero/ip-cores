#include "comparator.h"

void comparator::do_comparator()
{
  sc_logic result;

  sc_lv<32> ss = id_mux_fw1.read();
  sc_lv<32> tt = id_mux_fw2.read();


  sc_int<32> sss = ss;
  sc_int<32> ttt = tt;
  sc_lv<3> ibs = id_branch_select.read();
  result = SC_LOGIC_0;

  if(ibs == "000")
    result = SC_LOGIC_0;
  else if(ibs == "001")
    {
      result = SC_LOGIC_0; 
      PRINT("***** ERROR COMPARATOR ****** ");
    }
  else if(ibs == "010") // beq
    if( sss == ttt )
      result = SC_LOGIC_1;
    else
      result = SC_LOGIC_0;
  else if(ibs == "011") // bne
    if( sss != ttt)
      result = SC_LOGIC_1;
    else
      result = SC_LOGIC_0;
  else if(ibs == "100") // bltz
    if( sss < 0)
      result = SC_LOGIC_1;
    else
      result = SC_LOGIC_0;
  else if(ibs == "101") // blez
    if( sss <= 0)
      result = SC_LOGIC_1;
    else
      result = SC_LOGIC_0;
  else if(ibs == "110") // bgtz
    // Vil ikke godtage sss > 0 til verilog
    // if( !(sss <= 0) )
    if ( sss > 0 )
      result = SC_LOGIC_1;
    else
      result = SC_LOGIC_0;
  else if(ibs == "111")
    if( sss >= 0)
      result = SC_LOGIC_1;
    else
      result = SC_LOGIC_0;
  else
    result = SC_LOGIC_0;
  
  id_equal.write(result);
  id_branch.write(result);
}

