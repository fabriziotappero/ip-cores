//
// HO MODIFICATO la funzione SLLV e SRLV
// ed ho aggiunto i segnali temp_rs e shift_rs 
//


#include "alu.h"

void alu::do_alu()
{
  sc_lv<6> 	func = id_ex_alu_ctrl.read();
  sc_lv<32> 	rs = id_ex_alu1.read();
  sc_lv<32> 	rt = id_ex_alu2.read();
  sc_lv<32> 	rd = WORD_ZERO;
  sc_int<32> 	irs = rs;
  sc_int<32> 	irt = rt;
  sc_uint<32> 	uirs = rs;
  sc_uint<32> 	uirt = rt;
  sc_logic 	equal = id_ex_equal.read();
  sc_logic 	ovf_excep_l;

  sc_logic 	sign_bit_for_sra;

  // shift amount
  sc_lv<5> sa = id_ex_alu_sa.read();
  sc_uint<5> uisa = sa;
  
  // shift from the register rs
  sc_lv<5> temp_rs = rs.range(4,0);
  sc_uint<5> shift_rs = temp_rs;
  
  sc_logic n0, n1;
  n0 = 0;
  n1 = 1;

  // Defaults...
  ovf_excep.write(n0); // ovf_excep_l = 0;
  carry.write(n0);
  
  if(func == FUNC_SLL)
    {
      rd = rt << uisa;
    }
  else if(func == FUNC_SRL)
    {
      rd = rt >> uisa;
    }
  else if(func == FUNC_SRA)
    {
      sign_bit_for_sra = rt[31];
      rd = rt >> uisa;
    }
  else if(func == FUNC_SLLV)
    {
      rd = rt << shift_rs;
    }
  else if(func == FUNC_SRLV)
    {
      rd = rt >> shift_rs;
    }
  else if(func == FUNC_SRAV)
    {
    }
  /*else if(func == FUNC_MFHI)
    {
      rd = hi;
    }
  
  else if(func == FUNC_MFLO)
    {
      rd = lo;
    }*/
  
  else if(func == FUNC_ADD)
    {
      sc_lv<33> temp;
      sc_lv<32> t = rt, s = rs;
      sc_lv<33> tt, ss;
      sc_int<33> ttt, sss;
      // Sign extend t
      if(t[31] == '1')
	ttt = tt = ("1",t);
      else
	ttt = tt = ("0",t);
      // Sign extend s
      if(s[31] == '1')
	sss = ss = ("1",s);
      else
	sss = ss = ("0",s);
      temp = ttt + sss;
      
      // Set exception bit
      if (temp[32] != temp[31])
	ovf_excep.write(SC_LOGIC_1);
      else
	ovf_excep.write(SC_LOGIC_0);
      rd = temp.range(31,0);
    }
  else if(func == FUNC_ADDU)
    {
      rd = uirs + uirt;
    }
  else if(func == FUNC_SUB)
    {
      sc_lv<33> temp;
      sc_lv<32> t = rt, s = rs;
      sc_lv<33> tt, ss;
      sc_int<33> ttt, sss;
      // Sign extend t
      if(t[31] == '1')
	ttt = tt = ("1",t);
      else
	ttt = tt = ("0",t);
      // Sign extend s
      if(s[31] == '1')
	sss = ss = ("1",s);
      else
	sss = ss = ("0",s);
      temp = ttt + sss;
      
      // Set exception bit
      if (temp[32] != temp[31])
	ovf_excep.write(SC_LOGIC_1);
      else
	ovf_excep.write(SC_LOGIC_0);
      rd = temp.range(31,0);
    }
  else if(func == FUNC_SUBU)
    {
      rd = irs - irt;
    }
  else if(func == FUNC_AND)
    {
      rd = rs & rt;
    }
  else if(func == FUNC_OR)
    {
      rd = rs | rt;
    }
  else if(func == FUNC_XOR)
    {
      rd = rs ^ rt;
    }
  else if(func == FUNC_NOR)
    {
      rd =  ~(rs|rt);
    }
  else if(func == FUNC_SLT)
    if(irs < irt)
      {
	rd = WORD_CON_ONE;
      }
    else
      {
	rd = WORD_ZERO;
      }
  else if(func == FUNC_SLTU)
    if(uirs < uirt)
      {
	rd = WORD_CON_ONE;
      }
    else
      {
	rd = WORD_ZERO;
      }
  else
    {
      rd = WORD_ZERO;
    }

  ex_alu_s.write(rd);
  ex_id_forward_s.write(rd);



} 
