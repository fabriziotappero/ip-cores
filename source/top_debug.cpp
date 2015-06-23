#include "top_debug.h" 

void decode(sc_lv<32> if_id_inst, unsigned int i, ostream& out)
{

  sc_lv<32> inst = if_id_inst;
  sc_lv<6> func = inst.range(5,0);
  sc_lv<6> op = inst.range(31,26);

  char *charinst=0;

  sc_lv<5> rs, rt ,rd ,lrs, lrt, lrd, lsa;        // lv version of reg #
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
  rs = inst.range(25,21);
  rt = inst.range(20,16);
  rd = inst.range(15,11);
  uirs = lrs = inst.range(25,21);
  uirt = lrt = inst.range(20,16);
  uird = lrd = inst.range(15,11);
  uisa = lsa = inst.range(10,6);
  

  // Immediate values
  imm = inst.range(15,0);
  uiimm_zero = iimm_zero = imm_zero = (HALFWORD_ZERO,imm);
  if( imm[15] == '1')
    uiimm_sign = iimm_sign = imm_sign = (HALFWORD_ONE,imm);
  else
    uiimm_sign = iimm_sign = imm_sign = (HALFWORD_ZERO,imm);

    uiinstr_index = instr_index = (inst.range(25,0), "00");
  
    
    
  //switch stage
  if(op == OP_RFORMAT)
    {
      if(func == FUNC_JR)
	{
	  out << " MIPS (ID): jr $"<< dec << (unsigned int)uirs << endl;
	}
      else if(func == FUNC_JALR)
	{
	  if (uird == 0)
	    out << " MIPS (ID): jalr $" << dec << (unsigned int)uirs << endl;
	  else
	    out << " MIPS (ID): jalr $" << dec << (unsigned int)uird << ", $" << dec << (unsigned int)uirs << endl;
	}
	
	/*
	
	*/
      else 
        if(func == FUNC_MTHI || 
	func == FUNC_MFLO ||
	func == FUNC_MULT || 
	func == FUNC_MULTU ||
	func == FUNC_DIV ||
	func == FUNC_DIVU)
	
     if (func == FUNC_MTHI) {charinst = "mthi"; out << " MIPS (ID): " << charinst << " $" << dec << (unsigned int) uirs << " [Hi]" << endl;}
     
     if (func == FUNC_MFLO) {charinst = "mflo"; out << " MIPS (ID): " << charinst << " $" << dec << (unsigned int) uird << " [Lo]" << endl;}
     
     if (func == FUNC_MULT) {charinst = "mult"; out << " MIPS (ID): " << charinst << " [Hi,Lo]," <<" $" << dec << (unsigned int)uirs << ", $" << dec << (unsigned int)uirt << endl;}
     
     if (func == FUNC_MULTU) {charinst = "multu"; out << " MIPS (ID): " << charinst <<"  [Hi,Lo], $" << dec << (unsigned int)uirs << ", $" << dec << (unsigned int)uirt << endl;}
     
     if (func == FUNC_DIV)  {charinst = "div"; out << " MIPS (ID): " << charinst << "  [Quoz = Hi, Resto = Lo], $" << dec << (unsigned int)uirs << ", $" << dec << (unsigned int)uirt << endl;}
     
     if (func == FUNC_DIVU) {charinst = "divu"; out << " MIPS (ID): " << charinst << "  [Quoz = Hi, Rest = Lo], $" << dec << (unsigned int)uirs << ", $" << dec << (unsigned int)uirt << endl;}
	
	
      else if(func == FUNC_SLL ||
	 func == FUNC_SRL ||
	 func == FUNC_SRA)
	{
	  if (func == FUNC_SLL) charinst = "sll";
	  if (func == FUNC_SRL) charinst = "srl";
	  if (func == FUNC_SRA) charinst = "sra";
	  if (func == FUNC_SLL && (unsigned int)uird == 0)
	    out << " MIPS (ID): nop" << endl;
	  else
	    out << " MIPS (ID): " << charinst << " $" << dec << (unsigned int)uird <<", $" << dec << (unsigned int)uirt <<", " << dec << (unsigned int)uisa << endl;
	}
      else if(func == FUNC_SLLV ||
	 func == FUNC_SRLV ||
	 func == FUNC_SRAV ||
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

	  // printf("MIPS (ID): R-Format - read next line!\n");
	  if (func == FUNC_SLLV) charinst = "sllv";
	  if (func == FUNC_SRLV) charinst = "srlv";
	  if (func == FUNC_SRAV) charinst = "srav";
	  if (func == FUNC_ADD)  charinst = "add";
	  if (func == FUNC_ADDU) charinst = "addu";
	  if (func == FUNC_SUB)  charinst = "sub";
	  if (func == FUNC_SUBU) charinst = "subu";
	  if (func == FUNC_AND)  charinst = "and";
	  if (func == FUNC_OR)   charinst = "or";
	  if (func == FUNC_XOR)  charinst = "xor";
	  if (func == FUNC_NOR)  charinst = "nor";
	  if (func == FUNC_SLT)  charinst = "slt";
	  if (func == FUNC_SLTU) charinst = "sltu";
	  out << " MIPS (ID): " << charinst << " $" << dec << (unsigned int)uird << ", $" << dec << (unsigned int)uirs << ", $" << dec << (unsigned int)uirt << endl;
	}
      else if (func == FUNC_BREAK)
	{
	  out << " MIPS (ID): BREAK" << endl;
	}
      
      else if (func == FUNC_SYSCALL)
	{
	  out << " MIPS (ID): SYSCALL" << endl;
	}
      
      else if (func == FUNC_BREAK || func == FUNC_SYSCALL)
	{
	  out << " Exception!!" << endl;
	}
      
      else
	{
	  out << " * UNKNOWN FUNCTION CODE FOR R-format" << endl;
	}
    }
  else if(op == OP_BRANCH)
    {
      // PRINTLN("Branch format");
      if(lrt.range(1,0) == BRANCH_BLTZ)
	{
	  out << " MIPS (ID): bltz $" << dec << (unsigned int)uirs << ", " << dec << (unsigned int)iimm_sign << endl;
	}
	
      else if(lrt.range(1,0) == BRANCH_BGEZ)
	{
	  out << " MIPS (ID): bgez $" << dec << (unsigned int)uirs << ", " << dec << (unsigned int)iimm_sign << endl;
	}
	
      else if(lrt.range(1,0) == BRANCH_BLTZAL)
	{
	  out << " MIPS (ID): bltzal $"<< dec << (unsigned int)uirs << ", " << dec << (unsigned int)iimm_sign << endl;
	}
      else if(lrt.range(1,0) == BRANCH_BGEZAL)
	{

	  out << " MIPS (ID): bgezal $" << dec << (unsigned int)uirs << ", " << dec << (unsigned int)iimm_sign << endl;
	}
    }
  
  
  else if(op == OP_J)
    {

      out << " MIPS (ID): j "<< dec << (unsigned int) uiinstr_index << endl;
    }
    
  
  else if(op == OP_JAL)
    {
      out << " MIPS (ID): jal " << dec << (unsigned int) uiinstr_index << endl;
    }
  
  
  else if(op == OP_BEQ)
    {
      out << " MIPS (ID): beq $" << dec << (unsigned int)uirt << ", $" << dec << (unsigned int)uirs << ", " << dec << (unsigned int)iimm_sign << endl;
    }
  
  
  else if(op == OP_BNE)
    {
      out << " MIPS (ID): bne $"<< dec << (unsigned int)uirt << ", $" << dec << (unsigned int)uirs << ", " << dec << (unsigned int)iimm_sign << endl;
    }
  
  
  else if(op == OP_BLEZ)
    {
      out << " MIPS (ID): blez $" << dec << (unsigned int) uirs << ", " << dec << (unsigned int) iimm_sign << endl;
    }
  
  
  else if(op == OP_BGTZ)
    {
      out << " MIPS (ID): bgtz $" << dec << (unsigned int)uirs << ", " << (unsigned int)iimm_sign << endl;
    }
  
  
  else if(op == OP_ADDI)
    {
      out << " MIPS (ID): addi $" << dec << (unsigned int)uirt << ", $" << dec << (unsigned int)uirs << ", " << dec << (unsigned int)iimm_sign << endl;
    }
  
  
  else if(op == OP_ADDIU)
    {
      out << " MIPS (ID): addiu $" << dec << (unsigned int)uirt << ", $" << dec << (unsigned int)uirs << ", " << dec << (int)uiimm_sign << endl;
    }
  
  
  else if(op == OP_SLTI)
    {
      out << " MIPS (ID): slti $" << dec << (unsigned int)uirt << ", $" << dec << (unsigned int)uirs << ", " << dec << (unsigned int)iimm_sign << endl;
    }
  
  
  else if(op == OP_SLTIU)
    {
      out << " MIPS (ID): sltiu $" << dec << (unsigned int)uirt << ", $" << dec << (unsigned int)uirs << ", " << dec << (unsigned int)iimm_sign << endl;
    }
  
  
  else if(op == OP_ANDI)
    {
      out << " MIPS (ID): andi $" <<  dec << (unsigned int)uirt << ", $" << dec << (unsigned int)uirs << ", 0x" << hex << (unsigned int)iimm_sign << endl;
    }
  
  
  else if(op == OP_ORI)
    {
      out << " MIPS (ID): ori $" << dec << (unsigned int)uirt << ", $" << dec << (unsigned int)uirs << ", 0x" << hex << (unsigned int)iimm_sign << endl;
    }
  
  
  else if(op == OP_XORI)
    {
      out << " MIPS (ID): xori $" << dec << (unsigned int)uirt << ", $" << dec << (unsigned int)uirs << ", 0x" << hex << (unsigned int)iimm_sign << endl;
    }
  
  
  else if(op == OP_LUI)
    {
      out << " MIPS (ID): lui $" << dec << (unsigned int)uirt << ", " << dec << (unsigned int)iimm_sign << endl;
    }
  
  
  else if(op == OP_LB ||
	  op == OP_LH ||
	  op == OP_LWL ||
	  op == OP_LW ||
	  op == OP_LBU ||
	  op == OP_LHU ||
	  op == OP_LWR)
    {
      if (op == OP_LB)  charinst = "lb";
      if (op == OP_LH)  charinst = "lh";
      if (op == OP_LWL) charinst = "lwl";
      if (op == OP_LW)  charinst = "lw";
      if (op == OP_LBU) charinst = "lbu";
      if (op == OP_LHU) charinst = "lhu";   
      if (op == OP_LWR) charinst = "lwr";
      out << " MIPS (ID): " << charinst << " $" << dec << (unsigned int)uirt << ", " << dec << (unsigned int)iimm_sign << "($" << dec << (unsigned int)uirs << ") (" << dec << (unsigned int)(is + iimm_sign) << ")" << endl;
    }
  
  
  else if(op == OP_SB  ||
	  op == OP_SH  ||
	  op == OP_SWL ||
	  op == OP_SW  ||
	  op == OP_SWR)
    {
      if (op == OP_SB)  charinst = "sb";
      if (op == OP_SH)  charinst = "sh";
      if (op == OP_SWL) charinst = "swl";
      if (op == OP_SW)  charinst = "sw";
      if (op == OP_SWR) charinst = "swr";
      out << " MIPS (ID): " << charinst <<" $" << dec << (unsigned int)uirt << ", " << dec << (unsigned int)iimm_sign << "($" << dec << (unsigned int)uirs << ") (" << dec << (unsigned int)(is + iimm_sign) << ")" << endl;
    }

  
  else if(op == OP_CACHE)
    {
      out << " MIPS (ID): CACHE $" << dec << (unsigned int)uirt << ", $" << dec << (unsigned int)iimm_sign.range(15,0) << "(" << dec << (unsigned int) uirs << ")" << endl;
    }
  
  
  else if(op == OP_COPROC0)
    {
      out << " MIPS (ID): CP0 instruction" << endl;
    }
    else
    {
	  if(lrs == RS_MFC0)
	    {
	      out << " MIPS (ID): mfc0 $" << dec << (unsigned int)uirt << ", $" << dec << (unsigned int)uird << endl;
	    }
	  else if(lrs == RS_MTC0)
	    {
	      out << " MIPS (ID): mtc0 $" << dec << (unsigned int)uirt << ", $" << dec << (unsigned int)uird << endl;
	    }
    }
  }




  
  
  
  

void top_debug::debug_signals()
{
	ofstream out("GIGINO.txt");

        out << endl;
	out << "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" << endl;
	out << " Simulationon after " << sc_simulation_time() << "ns 	Clock n°" <<  sc_simulation_time()/20 << "	Reset =" << top_level->reset << endl;
	out << "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  REGISTERS   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" << endl; 
	out << endl;
	for (int n=0; n < 8; n++)
	{
	    out << "$"<< dec << n <<" =	0x" << hex << setw(8) << setfill('0') <<(unsigned int) ((sc_uint<32>)(top_level->risc->cpu->id->localreg->r[n]));
	
	    out << "	$"<< dec << n+8 <<" =	0x" << hex << setw(8) << setfill('0') <<(unsigned int) ((sc_uint<32>)(top_level->risc->cpu->id->localreg->r[n+8]));
	    
	    out << "	$"<< dec << n+16 <<" =	0x" << hex << setw(8) << setfill('0') <<(unsigned int) ((sc_uint<32>)(top_level->risc->cpu->id->localreg->r[n+16]));
	    
	    out << "	$"<< dec << n+24 <<" =	0x" << hex << setw(8) << setfill('0') <<(unsigned int) ((sc_uint<32>)(top_level->risc->cpu->id->localreg->r[n+24]))<< endl;
	    
	}
	
	out << " [HI] =   " << hex << setw(8) << setfill('0') << (unsigned int) ((sc_uint<32>) top_level->risc->cpu->ex->out_hi) <<  endl;
	
	out << " [LO] =   " << hex << setw(8) << setfill('0') << (unsigned int) ((sc_uint<32>) top_level->risc->cpu->ex->out_lo) <<  endl;
	
	
	out << endl;    
	out << "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    DATA     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" << endl;
	
	out << " dataaddr  = 0x" << hex << setw(8) << setfill('0') << (unsigned int) ((sc_uint<32>)(top_level->dataaddr)) << endl;
	out << " dataread  = 0x" << hex << setw(8) << setfill('0') << (unsigned int) ((sc_uint<32>) (top_level->dataread_dec_cpu)) << "   ("<< top_level->dataread_dec_cpu <<")"<< endl;
	out << " datawrite = 0x" << hex << setw(8) << setfill('0') << (unsigned int) ((sc_uint<32>) (top_level->datawrite)) << "   ("<< top_level->datawrite <<")"<< endl;
	out << " datarw   = " << top_level->datarw  << endl;
	out << " datareq    = " << top_level->datareq << endl;
	out << " databs    = " << top_level->databs  << endl;
	
	out << endl;
	out << "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  INST_MEM   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" << endl;
	
	decode(top_level->instdataread,((unsigned int) ((sc_uint<32>)(top_level->instaddr))), out);
	
	out << " PC  = 0x" << hex << setw(8) << setfill('0') << ((unsigned int)((sc_uint<32>)(top_level->instaddr))) << endl;
	out << " InstDataRead  = 0x" << hex << setw(8) << setfill('0') << (unsigned int) ((sc_uint<32>) (top_level->instdataread)) << "	" << top_level->instdataread << endl;
	
	out << " instreq   = " << top_level->instreq  << endl;  
	    
	out << endl;
	out << endl;
	
	 
	out << "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  MEMORY   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" << endl; 
	
	int temp, temp2, Start, Stop; 
	Start = Start_pos;
	Stop  = Finish_pos;
	temp  = (Start + (Stop - Start)/4);
	temp2 = ((Stop - Start)/4);
	
	for(int n= Start; n < temp; n=n+4)
	{
          out << "[0x"<< hex << n << "] = 0x"<<  hex << setw(8) << setfill('0') << top_level->datamem->x[(n >> 2)] << "	  ";
	  
	  out << "[0x"<< hex << (n + temp2) << "] = 0x"<<  hex << setw(8) << setfill('0') << top_level->datamem->x[((n+temp2) >> 2)] << "	  ";
	  
	  out << "[0x"<< hex << (n + 2*temp2) << "] = 0x"<<  hex << setw(8) << setfill('0') << top_level->datamem->x[((n+2*temp2) >> 2)] << "	  ";
	  
	  out << "[0x"<< hex << (n + 3*temp2) << "] = 0x"<<  hex << setw(8) << setfill('0') << top_level->datamem->x[((n+3*temp2) >> 2)] << "	  " << endl;
	  
	  /*out << "cella [0x"<< hex << (n+8) << "] =   "<<  hex << setw(8) << setfill('0') << top_level->datamem->x[((n+8) >> 2)] << "   ";
	  
	  out << "cella [0x"<< hex << (n+12) << "] =   "<<  hex << setw(8) << setfill('0') << top_level->datamem->x[((n+12) >> 2)] << endl;*/
	 
	}
	 
	 
	 
	 char buffer[256];
         ifstream examplefile ("GIGINO.txt");
         if (! examplefile.is_open())
         { cout << "Error opening file"; exit (1); }

         while (! examplefile.eof() )
         {
         examplefile.getline (buffer,100);
         fprintf (fp ,"%s\n", buffer);
	 }
}
