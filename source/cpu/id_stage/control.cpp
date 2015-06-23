#include "control.h"



void control::do_control()
{

  sc_logic n0 = SC_LOGIC_0;
  sc_logic n1 = SC_LOGIC_1;

  sc_lv<32> inst = if_id_inst;
  sc_lv<6> func = inst.range(5,0);
  sc_lv<6> op = inst.range(31,26);

  id_opcode.write(op);
  id_function.write(func);
   
  sc_lv<5> lrs, lrt, lrd, lsa;        // lv version of reg #
  sc_uint<5> uirs, uirt, uird, uisa;  // unsigned integer version of reg #
  sc_int<32> is, it, id;              // integer version of register contents...

  //! The immediate value in an instruction
  sc_lv<16> imm;
  sc_lv<32> imm_sign, imm_zero;
  sc_int<32> iimm_sign, iimm_zero;
  sc_uint<32> uiimm_sign, uiimm_zero;
  sc_lv<28> instr_index;
  sc_uint<28> uiinstr_index;

  // register destinations and recipients
  rs.write(inst.range(25,21));
  rt.write(inst.range(20,16));
  rd.write(inst.range(15,11));
  
  uirs = lrs = inst.range(25,21);
  uirt = lrt = inst.range(20,16);
  uird = lrd = inst.range(15,11);
  uisa = lsa = inst.range(10,6);
  
  // signals for selection bytes and sign of lw/sw instructions
  sc_lv<2> byteselect = "00";
  sc_logic id_bssign = SC_LOGIC_0;

#ifdef _HIGH_LEVEL_SIM_
  is = 0; // localreg->r[uirs];
  it = 0; // localreg->r[uirt];
  id = 0; // localreg->r[uird];
#endif


  // Immediate values
  imm = inst.range(15,0);
  uiimm_zero = iimm_zero = imm_zero = (HALFWORD_ZERO,imm);
  if( imm[15] == '1')
    uiimm_sign = iimm_sign = imm_sign = (HALFWORD_ONE,imm);
  else
    uiimm_sign = iimm_sign = imm_sign = (HALFWORD_ZERO,imm);

    uiinstr_index = instr_index = (inst.range(25,0), "00");

  id_alu_ctrl.write(func);
  id_alu_sa.write(inst.range(10,6));
  id_ctrl.write(n0);
  id_extend_ctrl.write("00");
  id_sign_ctrl.write("00");
  regdest.write("00");
  id_select_jump.write(n0);
  id_pc_store.write(n0);
  id_branch_select.write("000");
  id_regwrite.write(n0);
  id_shamt_ctrl.write(n0);
  id_datarw.write(n0);
  id_datareq.write(n0);
  id_memtoreg.write(n0);

  // Signals to cp0
  cp0_inst.write(CP0_NOTHING); // 4 bit...
  // cp0_reg_rs will be set directly from forward-MUX
  cp0_reg_no.write(uird);
  cp0_reg_rw.write(SC_LOGIC_0); // default value...don't write!
  id_mfc0.write(SC_LOGIC_0);
  sc_logic cpo_co = inst[25];
  
  illegal_instruction.write(SC_LOGIC_0);
  syscall_exception.write(SC_LOGIC_0);

#ifdef ONEHOT_DEBUG
  inst_addiu.write(SC_LOGIC_0);
  inst_jalr.write(SC_LOGIC_0);
  inst_lw.write(SC_LOGIC_0);
  inst_mfc0.write(SC_LOGIC_0);
  inst_mtc0.write(SC_LOGIC_0);
  inst_nop.write(SC_LOGIC_0);
  inst_sw.write(SC_LOGIC_0);
  inst_wait.write(SC_LOGIC_0);
#endif
  
  //switch stage
  if(op == OP_RFORMAT)
    {
      if(func == FUNC_JR)
	{
	  id_ctrl.write(n1);
	  id_select_jump.write(n1);
	  id_alu_ctrl.write("000000");
	}
      else if(func == FUNC_JALR)
	{
#ifdef ONEHOT_DEBUG
	  inst_jalr.write(SC_LOGIC_1);
#endif
	  id_ctrl.write(n1);
	  id_select_jump.write(n1);
	  id_pc_store.write(n1);
	  id_regwrite.write(n1);
	  id_alu_ctrl.write(FUNC_ADDU);
	  id_sign_ctrl.write("10");
	}
	
      else 
        if(func == FUNC_MULT)
	{ 
		id_alu_ctrl.write(FUNC_MULT);
		id_regwrite.write(n0);
	}
	else if(func == FUNC_MFLO)
	{
		id_alu_ctrl.write(FUNC_MFLO);
		id_regwrite.write(n1);
	}
	
	else if(func == FUNC_MTHI)
	{
		id_alu_ctrl.write(FUNC_MTHI);
		id_regwrite.write(n1);
	}
	
	else if(func == FUNC_MULTU)
	{
		id_alu_ctrl.write(FUNC_MULTU);
		id_regwrite.write(n0);
	}
	
	
	else if(func == FUNC_DIV)
	{
		id_alu_ctrl.write(FUNC_DIV);
	}
	
	else if(func == FUNC_DIVU)
	{
		id_alu_ctrl.write(FUNC_DIVU);
	}
	
      else if(func == FUNC_SLL ||
	 func == FUNC_SRL ||
	 func == FUNC_SRA)
	{
	  id_shamt_ctrl.write(n1);
	  id_regwrite.write(n1);
#ifdef ONEHOT_DEBUG
	  inst_nop.write(SC_LOGIC_1);
#endif
	}
      else if(func == FUNC_SLLV ||
	 func == FUNC_SRLV ||
	 func == FUNC_SRAV ||
	 func == FUNC_MFHI ||
	 func == FUNC_MFLO ||
	 func == FUNC_ADD ||
	 func == FUNC_ADDU ||
	 func == FUNC_SUB ||
	 func == FUNC_SUBU ||
	 func == FUNC_AND ||
	 func == FUNC_OR ||
	 func == FUNC_XOR ||
	 func == FUNC_NOR ||
	 func == FUNC_SLT ||
	 func == FUNC_SLTU)
	{
	  id_regwrite.write(n1);
	}
#ifdef _INCLUDE_CP0_
      else if (func == FUNC_BREAK)
	{
	  cp0_inst.write(CP0_BREAK);
	}
      else if (func == FUNC_SYSCALL)
	{
	  cp0_inst.write(CP0_SYSCALL);
	  syscall_exception.write(SC_LOGIC_1);
	}
#else
      else if (func == FUNC_BREAK || func == FUNC_SYSCALL)
	{
	  
	  //sc_stop();
	}
#endif
      else
	{
	  illegal_instruction.write(SC_LOGIC_1);
	  cout << " illegal instruction " << endl;
	  //sc_stop();
	}
    }
  else if(op == OP_BRANCH)
    {
      // PRINTLN("Branch format");
      if(lrt.range(1,0) == BRANCH_BLTZ)
	{
	  id_branch_select.write("100");
	}
      else if(lrt.range(1,0) == BRANCH_BGEZ)
	{
	  id_branch_select.write("111");
	}
      else if(lrt.range(1,0) == BRANCH_BLTZAL)
	{
	  id_branch_select.write("100");
	  id_pc_store.write(n1);
	  id_sign_ctrl.write("10");
	  regdest.write("10");
	  id_regwrite.write(n1);
	  id_alu_ctrl.write(FUNC_ADDU);
	}
      else if(lrt.range(1,0) == BRANCH_BGEZAL)
	   {
	      id_branch_select.write("111");
	      id_pc_store.write(n1);
	      id_sign_ctrl.write("10");
	      regdest.write("10");
	      id_regwrite.write(n1);
	      id_alu_ctrl.write(FUNC_ADDU);
	   }
	   else illegal_instruction.write(SC_LOGIC_1);
    }
  else if(op == OP_J)
    {
      id_ctrl.write(n1);
    }
  else if(op == OP_JAL)
    {
      id_ctrl.write(n1);
      id_pc_store.write(n1);
      // add 8 in total
      id_alu_ctrl.write(FUNC_ADDU);
      id_sign_ctrl.write("10"); 
      regdest.write("10");
      id_regwrite.write(n1);
    }
  else if(op == OP_BEQ)
    {
      id_branch_select.write("010");
    }
  else if(op == OP_BNE)
    {
      id_branch_select.write("011");
    }
  else if(op == OP_BLEZ)
    {
      id_branch_select.write("101");
    }
  else if(op == OP_BGTZ)
    {
      id_branch_select.write("110");
    }
  else if(op == OP_ADDI)
    {
      id_alu_ctrl.write(FUNC_ADD);
      regdest.write("01");
      id_sign_ctrl.write("01");
      id_regwrite.write(n1);
    }
  else if(op == OP_ADDIU)
    {
      id_alu_ctrl.write(FUNC_ADDU);
      regdest.write("01");
      id_sign_ctrl.write("01");
      id_regwrite.write(n1);
#ifdef ONEHOT_DEBUG
      inst_addiu.write(SC_LOGIC_1);
#endif
    }
  else if(op == OP_SLTI)
    {
      id_alu_ctrl.write(FUNC_SLT);
      regdest.write("01");
      id_sign_ctrl.write("01");
      id_regwrite.write(n1);
    }
  else if(op == OP_SLTIU)
    {
      id_alu_ctrl.write(FUNC_SLTU);
      regdest.write("01");
      id_sign_ctrl.write("01");
      id_regwrite.write(n1);
    }
  else if(op == OP_ANDI)
    {
      id_alu_ctrl.write(FUNC_AND);
      regdest.write("01");
      id_sign_ctrl.write("01");
      id_extend_ctrl.write("01");
      id_regwrite.write(n1);
    }
  else if(op == OP_ORI)
    {
      id_alu_ctrl.write(FUNC_OR);
      regdest.write("01");
      id_sign_ctrl.write("01");
      id_extend_ctrl.write("01");
      id_regwrite.write(n1);
    }
  else if(op == OP_XORI)
    {
      id_alu_ctrl.write(FUNC_XOR);
      regdest.write("01");
      id_sign_ctrl.write("01");
      id_extend_ctrl.write("01");
      id_regwrite.write(n1);
    }
  else if(op == OP_LUI)
    {
      id_alu_ctrl.write(FUNC_ADDU);
      regdest.write("01");
      id_sign_ctrl.write("01");
      id_extend_ctrl.write("10");
      id_regwrite.write(n1);
    }
  else if(op == OP_LB ||
	  op == OP_LH ||
	  op == OP_LWL ||
	  op == OP_LW ||
	  op == OP_LBU ||
	  op == OP_LHU ||
	  op == OP_LWR)
    {
      id_alu_ctrl.write(FUNC_ADDU);
      id_regwrite.write(n1);
      regdest.write("01");
      id_datareq.write(n1);
      id_memtoreg.write(n1);
      id_sign_ctrl.write("01");
      // Select bytes to be read!
      if (op == OP_LB || op == OP_LBU)
	byteselect = "01";
      else if (op == OP_LH || op == OP_LHU)
	byteselect = "10";
      else
	byteselect = "00";
      // select to sign_extend or not
      if ((op == OP_LBU) || (op == OP_LHU))
	id_bssign = SC_LOGIC_1;
#ifdef ONEHOT_DEBUG
      inst_lw = SC_LOGIC_1;
#endif
    }
  else if(op == OP_SB  ||
	  op == OP_SH  ||
	  op == OP_SWL ||
	  op == OP_SW  ||
	  op == OP_SWR)
    {
      id_alu_ctrl.write(FUNC_ADDU);
      id_datarw.write(n1);
      id_datareq.write(n1);
      id_memtoreg.write(n1);
      id_sign_ctrl.write("01");
      // Select bytes to be written
      if (op == OP_SB) 
	byteselect = "01";
      else if (op == OP_SH) 
	byteselect = "10";
      else
	byteselect = "00";
#ifdef ONEHOT_DEBUG
      inst_sw = SC_LOGIC_1;
#endif
    }
#ifdef _INCLUDE_CP0_
  else if(op == OP_CACHE)
    {
      cp0_inst.write(CP0_CACHE);
    }
#endif
  /*!
    In order to include co-processor you need to enable it in the config file.
  */
  else 
    if(op == OP_COPROC0)
    {
      if(cpo_co == SC_LOGIC_1)
	{
	  if(func == FUNC_TLBR)
	    {
	      cp0_inst.write(CP0_TLBR);
	    }
	  else 
	     if(func == FUNC_TLBWI)
	     {
	       cp0_inst.write(CP0_TLBWI);
	     }
	     else 
	        if(func == FUNC_TLBWR)
	        {
	           cp0_inst.write(CP0_TLBWR);
	        }
	        else 
		   if(func == FUNC_TLBP)
		   {
		      cp0_inst.write(CP0_TLBP);
		   }
		   else
		      if(func == FUNC_ERET)
		      {
		            cp0_inst.write(CP0_ERET);

		      }
		      else 
		         if(func == FUNC_DERET)
			 {
			    cp0_inst.write(CP0_DERET);
			 }
			 else 
			    if(func == FUNC_WAIT)
			    {
			        cp0_inst.write(CP0_WAIT);
			        // Do same actions as jalr...except jump!
				id_ctrl.write(n0);
				id_select_jump.write(n0);
				id_pc_store.write(n1);
				id_regwrite.write(n1);
				id_alu_ctrl.write(FUNC_ADDU);
				id_sign_ctrl.write("10");
			#ifdef ONEHOT_DEBUG
				inst_wait.write(SC_LOGIC_1);
			#endif
			    }
	}
        else
	{
	  if(lrs == RS_MFC0)
	  {
	      cp0_inst.write(CP0_MFC0);
	      cp0_reg_rw.write(SC_LOGIC_0);
	      id_mfc0.write(SC_LOGIC_1);

	      id_alu_ctrl.write(FUNC_ADDU);
	      regdest.write("01");
	      id_sign_ctrl.write("00");
	      id_regwrite.write(n1);
#ifdef ONEHOT_DEBUG
	      inst_mfc0.write(SC_LOGIC_1);
#endif
	  }
	  else 
	     if(lrs == RS_MTC0)
	     {
	       cp0_inst.write(CP0_MTC0);
	       cp0_reg_rw.write(SC_LOGIC_1);
	       id_alu_ctrl.write(FUNC_ADDU);
	       cp0_reg_no.write(uird);
	       id_mfc0.write(SC_LOGIC_0);
#ifdef ONEHOT_DEBUG
	       inst_mtc0.write(SC_LOGIC_1);
#endif
	    }
	}
	//cout << "illegal instruction " << endl;
	//illegal_instruction.write(SC_LOGIC_1);
    }
    
  else
    {
      illegal_instruction.write(SC_LOGIC_1);
      cout << " illegal instruction " << endl;
      //sc_stop();
    }
    id_byteselect = byteselect;
}
