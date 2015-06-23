/*
  Or1K instruction set-specific decoding and analysis functions.

  Julius Baxter, julius.baxter@orsoc.se

*/


#include "stdio.h"
#include "stdint.h"
#include "stdlib.h"
#include "string.h"
#include "assert.h"
#include "or1k-32-insn.h"

// Define the appropriate instruction type, and instruction_properties type
// These should also be defined in insnanalysis.h
typedef uint32_t instruction;
typedef struct or1k_32_instruction_properties instruction_properties ;

#include "insn-lists.h"

// Variable to keep track of unique instructions we have
int num_setup_insns;
int num_seen_insns;

struct or1k_insn_info * or1k_32_insns[OR1K_32_MAX_INSNS];

// Keep enough instructions required to do the maximum n-tuple set
// analysis.
int or1k_32_recent_insns[OR1K_MAX_GROUPINGS_ANALYSIS];

// Function to take the raw binary instruction, and configure the insn_props
// struct with the appropriate settings for that instruction (string, attributes
// etc.)
// TODO: vector instructions aren't picked up - but compiler never generates
// them, so not a big issue.
int or1k_32_analyse_insn(uint32_t insn,
			 struct or1k_32_instruction_properties  * insn_props)
{
  
  switch(insn_or1k_opcode(insn))
    {
    case 0x00:
      insn_props->insn_string="l.j";
      insn_props->insn_index=0;
      insn_props->has_jumptarg = 1;
      break;
    
    case 0x01:
      insn_props->insn_string="l.jal";
      insn_props->insn_index=1;
      insn_props->has_jumptarg = 1;
      break;

     case 0x03:
      insn_props->insn_string="l.bnf";
      insn_props->insn_index=2;
      insn_props->has_branchtarg = 1;
      break;

    case 0x04:
      insn_props->insn_string="l.bf";
      insn_props->insn_index=3;
      insn_props->has_branchtarg = 1;
      break;

    case 0x05:
      insn_props->insn_string="l.nop";
      insn_props->insn_index=4;
      break;

    case 0x06:
      if((insn_or1k_opcode_0x06_get_id(insn)))
	{
	  insn_props->insn_string="l.macrc";
	  insn_props->insn_index=5;
	}
      else
	{
	  insn_props->insn_string="l.movhi";
	  insn_props->insn_index=6;
	  insn_props->has_rD = 1;
	  insn_props->has_imm = 1;
	}
      
      break;
      
    case 0x08:
      
      switch(insn_or1k_opcode_0x08_get_id(insn))
	{
	case 0x0:
	  insn_props->insn_string="l.sys";
	  insn_props->insn_index=7;
	  insn_props->has_imm = 1;
	  break;
	case 0x2:
	  insn_props->insn_string="l.trap";
	  insn_props->insn_index=8;
	  break;
	case 0x4:
	  insn_props->insn_string="l.msync";
	  insn_props->insn_index=9;
	  break;
	case 0x5:
	  insn_props->insn_string="l.psync";
	  insn_props->insn_index=10;
	  break;
	case 0x6:
	  insn_props->insn_string="l.csync";
	  insn_props->insn_index=11;
	  break;
	default:
	  printf("Unknown id (0x%x) in opcode 0x8",
		 insn_or1k_opcode_0x08_get_id(insn) );
	  return 1;
	  break;
	}
      break;

    case 0x09:
      insn_props->insn_string="l.rfe";
      insn_props->insn_index=12;
      break;
      
    case 0x0a:
      switch(insn_or1k_opcode_0x0a_get_op_hi(insn))
	{
	case 0x1:
	  switch(insn_or1k_opcode_0x0a_get_op_lo(insn))
	    {
	    case 0x0:
	      break;
	    case 0x1:
	      break;
	    case 0x2:
	      break;
	    case 0x3:
	      break;
	    case 0x4:
	      break;
	    case 0x5:
	      break;
	    case 0x6:
	      break;
	    case 0x7:
	      break;
	    case 0x8:
	      break;
	    case 0x9:
	      break;
	    case 0xa:
	      break;
	    case 0xb:
	      break;
	    default:
	      printf("Unknown lv.all_xx insn");
	      return 1;
	    }
	case 0x2:
	  switch(insn_or1k_opcode_0x0a_get_op_lo(insn))
	    {
	    case 0x0:
	      break;
	    case 0x1:
	      break;
	    case 0x2:
	      break;
	    case 0x3:
	      break;
	    case 0x4:
	      break;
	    case 0x5:
	      break;
	    case 0x6:
	      break;
	    case 0x7:
	      break;
	    case 0x8:
	      break;
	    case 0x9:
	      break;
	    case 0xa:
	      break;
	    case 0xb:
	      break;
	    default:
	      printf("Unknown lv.any_xx insn");
	      return 1;
	    }
	  break;
	case 0x3:
	  switch(insn_or1k_opcode_0x0a_get_op_lo(insn))
	    {
	    case 0x0:
	      break;
	    case 0x1:
	      break;
	    case 0x2:
	      break;
	    case 0x3:
	      break;
	    case 0x4:
	      break;
	    case 0x5:
	      break;
	    case 0x6:
	      break;
	    case 0x7:
	      break;
	    case 0x8:
	      break;
	    case 0x9:
	      break;
	    case 0xa:
	      break;
	    default:
	      printf("Unknown lv.add/and/avg_xx insn");
	      return 1;
	    }  
	  break;
	case 0x4:    
	  switch(insn_or1k_opcode_0x0a_get_op_lo(insn))
	    {
	    case 0x0:
	      break;
	    case 0x1:
	      break;
	    case 0x2:
	      break;
	    case 0x3:
	      break;
	    case 0x4:
	      break;
	    case 0x5:
	      break;
	    case 0x6:
	      break;
	    case 0x7:
	      break;
	    case 0x8:
	      break;
	    case 0x9:
	      break;
	    case 0xa:
	      break;
	    case 0xb:
	      break;
	    default:
	      printf("Unknown lv.cmp_xx insn");
	      return 1;
	    }  
	  break;
	case 0x5:      
	  switch(insn_or1k_opcode_0x0a_get_op_lo(insn))
	    {	 
	    case 0x4:
	      break;
	    case 0x5:
	      break;
	    case 0x6:
	      break;
	    case 0x7:
	      break;
	    case 0x8:
	      break;
	    case 0x9:
	      break;
	    case 0xa:
	      break;
	    case 0xb:
	      break;
	    case 0xc:
	      break;
	    case 0xd:
	      break;
	    case 0xe:
	      break;
	    case 0xf:
	      break;
	    default:
	      printf("Unknown lv.alu_xx insn");
	      return 1;
	    }
	  break;
	case 0x6:      
	  switch(insn_or1k_opcode_0x0a_get_op_lo(insn))
	    {
	    case 0x0:
	      break;
	    case 0x1:
	      break;
	    case 0x2:
	      break;
	    case 0x3:
	      break;
	    case 0x4:
	      break;
	    case 0x5:
	      break;
	    case 0x6:
	      break;
	    case 0x7:
	      break;
	    case 0x8:
	      break;
	    case 0x9:
	      break;
	    case 0xa:
	      break;
	    case 0xb:
	      break;
	    case 0xc:
	      break;
	    case 0xd:
	      break;
	    case 0xe:
	      break;
	    case 0xf:
	      break;
	    default:
	      printf("Unknown lv.pack_xx insn");
	      return 1;
	    }
	  break;
	case 0x7:
	  switch(insn_or1k_opcode_0x0a_get_op_lo(insn))
	    {
	    case 0x0:
	      break;
	    case 0x1:
	      break;
	    case 0x2:
	      break;
	    case 0x3:
	      break;
	    case 0x4:
	      break;
	    case 0x5:
	      break;
	    case 0x6:
	      break;
	    case 0x7:
	      break;
	    case 0x8:
	      break;
	    case 0x9:
	      break;
	    case 0xa:
	      break;
	    case 0xb:
	      break;
	    default:
	      printf("Unknown lv.sub/unpack/xor_xx insn");
	      return 1;
	    }  
	  break;
	case 0xc:
	  break;
	case 0xd:
	  break;
	case 0xe:
	  break;
	case 0xf:
	  break;
	default:
	  printf("Unknown lv.xxx insn hi op");
	  return 1;
	  break;
	}
      break;
      
    case 0x11:
      insn_props->insn_string="l.jr";
      insn_props->insn_index=13;
      insn_props->has_rB = 1;
      break;

    case 0x12:
      insn_props->insn_string="l.jalr";
      insn_props->insn_index=14;
      insn_props->has_rB = 1;
      break;
      
    case 0x13:
      insn_props->insn_string="l.maci";
      insn_props->insn_index=15;
      break;

    case 0x1c:
      insn_props->insn_string="l.cust1";
      insn_props->insn_index=16;
      break;

    case 0x1d:
      insn_props->insn_string="l.cust2";
      insn_props->insn_index=17;
      break;

    case 0x1e:
      insn_props->insn_string="l.cust3";
      insn_props->insn_index=18;
      break;

    case 0x1f:
      insn_props->insn_string="l.cust4";
      insn_props->insn_index=19;
      break;

    case 0x20:
      insn_props->insn_string="l.ld";
      insn_props->insn_index=20;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x21:
      insn_props->insn_string="l.lwz";
      insn_props->insn_index=21;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x22:
      insn_props->insn_string="l.lws";
      insn_props->insn_index=22;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x23:
      insn_props->insn_string="l.lbz";
      insn_props->insn_index=23;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x24:
      insn_props->insn_string="l.lbs";
      insn_props->insn_index=24;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x25:
      insn_props->insn_string="l.lhz";
      insn_props->insn_index=25;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;      
      break;

    case 0x26:
      insn_props->insn_string="l.lhs";
      insn_props->insn_index=26;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;      
      break;


    case 0x27:
      insn_props->insn_string="l.addi";
      insn_props->insn_index=27;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x28:
      insn_props->insn_string="l.addic";
      insn_props->insn_index=28;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x29:
      insn_props->insn_string="l.andi";
      insn_props->insn_index=29;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x2a:
      insn_props->insn_string="l.ori";
      insn_props->insn_index=30;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x2b:
      insn_props->insn_string="l.xori";
      insn_props->insn_index=31;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x2c:
      insn_props->insn_string="l.muli";
      insn_props->insn_index=32;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x2d:
      insn_props->insn_string="l.mfspr";
      insn_props->insn_index=33;
      insn_props->has_rD = 1;
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

    case 0x2e:
      switch(insn_or1k_opcode_0x2e_get_op(insn))
	{
	case 0x0:
	  insn_props->insn_string="l.slli";
	  insn_props->insn_index=34;
	  break;
	case 0x1:
	  insn_props->insn_string="l.srli";
	  insn_props->insn_index=35;
	  break;
	case 0x2:
	  insn_props->insn_string="l.srai";
	  insn_props->insn_index=36;
	  break;
	case 0x3:
	  insn_props->insn_string="l.rori";
	  insn_props->insn_index=37;
	  break;
	default:
	  printf("Unknown shift op (0x%x)",
		 insn_or1k_opcode_0x2e_get_op(insn));
	  return 1;
	  break;
	}
      break;
    
    case 0x2f:
      switch(insn_or1k_opcode_0x2f_get_op(insn))
	{
	case 0x0:
	  insn_props->insn_string="l.sfeqi";
	  insn_props->insn_index=38;
	  break;
	case 0x1:
	  insn_props->insn_string="l.sfnei";
	  insn_props->insn_index=39;
	  break;
	case 0x2:
	  insn_props->insn_string="l.sfgtui";
	  insn_props->insn_index=40;
	  break;
	case 0x3:
	  insn_props->insn_string="l.sfgeui";
	  insn_props->insn_index=41;
	  break;
	case 0x4:
	  insn_props->insn_string="l.sfltui";
	  insn_props->insn_index=42;
	  break;
	case 0x5:
	  insn_props->insn_string="l.sfleui";
	  insn_props->insn_index=43;
	  break;
	case 0xa:
	  insn_props->insn_string="l.sfgtsi";
	  insn_props->insn_index=44;
	  break;
	case 0xb:
	  insn_props->insn_string="l.sfgesi";
	  insn_props->insn_index=45;
	  break;
	case 0xc:
	  insn_props->insn_string="l.sfltsi";
	  insn_props->insn_index=46;
	  break;
	case 0xd:
	  insn_props->insn_string="l.sflesi";
	  insn_props->insn_index=47;
	  break;
	  
	default:
	  printf("Unknown set flag op (0x%x)",
		 insn_or1k_opcode_0x2f_get_op(insn));
	  return 1;
	  break;
	}
      insn_props->has_rA = 1;
      insn_props->has_imm = 1;
      break;

      
    case 0x30:
      insn_props->insn_string="l.mtspr";
      insn_props->insn_index=48;
      break;

    case 0x31:
      switch (insn_or1k_opcode_0x31_get_op(insn))
	{
	case 0x1:
	  insn_props->insn_string="l.mac";
	  insn_props->insn_index=49;
	  break;
	case 0x2:
	  insn_props->insn_string="l.msb";
	  insn_props->insn_index=50;
	  break;
	default:
	  printf("Unknown mac op (0x%x)",
		 insn_or1k_opcode_0x31_get_op(insn));
	  return 1;
	}
      break;

    case 0x32:
      switch(insn_or1k_opcode_0x32_get_op_hi(insn))
	{
	case 0x0:
	  switch(insn_or1k_opcode_0x32_get_op_lo(insn))
	    {
	    case 0x0:
	      insn_props->insn_string="lf.add.s";
	      insn_props->insn_index=51;
	      break;
	    case 0x1:
	      insn_props->insn_string="lf.sub.s";
	      insn_props->insn_index=52;
	      break;
	    case 0x2:
	      insn_props->insn_string="lf.mul.s";
	      insn_props->insn_index=53;
	      break;
	    case 0x3:
	      insn_props->insn_string="lf.div.s";
	      insn_props->insn_index=54;
	      break;
	    case 0x4:
	      insn_props->insn_string="lf.itof.s";
	      insn_props->insn_index=55;
	      break;
	    case 0x5:
	      insn_props->insn_string="lf.ftoi.s";
	      insn_props->insn_index=56;
	      break;
	    case 0x6:
	      insn_props->insn_string="lf.rem.s";
	      insn_props->insn_index=57;
	      break;
	    case 0x7:
	      insn_props->insn_string="lf.madd.s";
	      insn_props->insn_index=58;
	      break;
	    case 0x8:
	      insn_props->insn_string="lf.sfeq.s";
	      insn_props->insn_index=59;
	      break;
	    case 0x9:
	      insn_props->insn_string="lf.sfne.s";
	      insn_props->insn_index=60;
	      break;
	    case 0xa:
	      insn_props->insn_string="lf.sfgt.s";
	      insn_props->insn_index=61;
	      break;
	    case 0xb:
	      insn_props->insn_string="lf.sfge.s";
	      insn_props->insn_index=62;
	      break;
	    case 0xc:
	      insn_props->insn_string="lf.sflt.s";
	      insn_props->insn_index=63;
	      break;
	    case 0xd:
	      insn_props->insn_string="lf.sfle.s";
	      insn_props->insn_index=64;
	      break;
	    default:
	      printf("Unknown lf.xxx.s op (0x%x)",
		     insn_or1k_opcode_0x32_get_op_lo(insn));
	      break;
	    }
	  break;
	
	case 0x1:
	  switch(insn_or1k_opcode_0x32_get_op_lo(insn))
	    {
	    case 0x0:
	      insn_props->insn_string="lf.add.d";
	      insn_props->insn_index=65;
	      break;
	    case 0x1:
	      insn_props->insn_string="lf.sub.d";
	      insn_props->insn_index=66;
	      break;
	    case 0x2:
	      insn_props->insn_string="lf.mul.d";
	      insn_props->insn_index=67;
	      break;
	    case 0x3:
	      insn_props->insn_string="lf.div.d";
	      insn_props->insn_index=68;
	      break;
	    case 0x4:
	      insn_props->insn_string="lf.itof.d";
	      insn_props->insn_index=69;
	      break;
	    case 0x5:
	      insn_props->insn_string="lf.ftoi.d";
	      insn_props->insn_index=70;
	      break;
	    case 0x6:
	      insn_props->insn_string="lf.rem.d";
	      insn_props->insn_index=71;
	      break;
	    case 0x7:
	      insn_props->insn_string="lf.madd.d";
	      insn_props->insn_index=72;
	      break;
	    case 0x8:
	      insn_props->insn_string="lf.sfeq.d";
	      insn_props->insn_index=73;
	      break;
	    case 0x9:
	      insn_props->insn_string="lf.sfne.d";
	      insn_props->insn_index=74;
	      break;
	    case 0xa:
	      insn_props->insn_string="lf.sfgt.d";
	      insn_props->insn_index=75;
	      break;
	    case 0xb:
	      insn_props->insn_string="lf.sfge.d";
	      insn_props->insn_index=76;
	      break;
	    case 0xc:
	      insn_props->insn_string="lf.sflt.d";
	      insn_props->insn_index=77;
	      break;
	    case 0xd:
	      insn_props->insn_string="lf.sfle.d";
	      insn_props->insn_index=78;
	      break;
	    default:
	      printf("Unknown lf.xxx.d op (0x%x)",
		     insn_or1k_opcode_0x32_get_op_lo(insn));
	      break;
	    }
	  break;	  
	  
	case 0xd:
	  insn_props->insn_string="lf.cust1.s";
	  insn_props->insn_index=79;
	  break;

	case 0xe:	  
	  insn_props->insn_string="lf.cust1.d";
	  insn_props->insn_index=80;
	  break;
	  
	default:
	  printf("Unknown lf.xxx opcode hi (0x%x)",
		 insn_or1k_opcode_0x32_get_op_hi(insn));
	  return 1;
	  break;
	}
      break;
      // The l.sx instructions'd rD is actually in the location rA is for 
      // every other instruction - so we specify has_rA, but really that's 
      // the rD, so it's l.sx imm(rA), rB
    case 0x34:
      insn_props->insn_string="l.sd";
      insn_props->insn_index=81;
      insn_props->has_rA = 1;
      insn_props->has_rB = 1;
      break;
    
    case 0x35:
      insn_props->insn_string="l.sw";
      insn_props->has_rA = 1;
      insn_props->has_rB = 1;
      insn_props->has_split_imm = 1;
      insn_props->insn_index=82;
      break;
    
    case 0x36:
      insn_props->insn_string="l.sb";
      insn_props->has_rA = 1;
      insn_props->has_rB = 1;      
      insn_props->has_split_imm = 1;
      insn_props->insn_index=83;
      break;
    
    case 0x37:
      insn_props->insn_string="l.sh";
      insn_props->has_rA = 1;
      insn_props->has_rB = 1;      
      insn_props->has_split_imm = 1;
      insn_props->insn_index=84;
      break;

    case 0x38:
       insn_props->has_rD = 1;
       insn_props->has_rA = 1;
       insn_props->has_rB = 1;
       switch(insn_or1k_opcode_0x38_get_op_lo(insn))
	 {	 
	 case 0x0:
	  insn_props->insn_string="l.add";	 
	  insn_props->insn_index=85;
	  break;
	case 0x1:
	  insn_props->insn_string="l.addc";
	  insn_props->insn_index=86;
	  break;
	case 0x2:
	  insn_props->insn_string="l.sub";
	  insn_props->insn_index=87;
	  break;
	case 0x3:
	  insn_props->insn_string="l.and";
	  insn_props->insn_index=88;
	  break;
	case 0x4:
	  insn_props->insn_string="l.or";
	  insn_props->insn_index=89;
	  break;
	case 0x5:
	  insn_props->insn_string="l.xor";
	  insn_props->insn_index=90;
	  break;
	case 0x6:
	  insn_props->insn_string="l.mul";
	  insn_props->insn_index=91;
	  break;
	case 0x8:
	  switch (insn_or1k_opcode_0x38_get_op_hi_4bit(insn))
	    {
	    case 0x0:
	      insn_props->insn_string="l.sll";
	      insn_props->insn_index=92;
	      break;
	    case 0x1:
	      insn_props->insn_string="l.srl";
	      insn_props->insn_index=93;
	      break;
	    case 0x2:
	      insn_props->insn_string="l.sra";
	      insn_props->insn_index=94;
	      break;
	    case 0x3:
	      insn_props->insn_string="l.ror";
	      insn_props->insn_index=95;
	      break;
	    default:
	      printf("Unknown ALU op 0x8 hi op (0x%x)",
		     insn_or1k_opcode_0x38_get_op_hi_4bit(insn));
	      return 1;
	      break;
	    }
	  break;
	case 0x9:
	  insn_props->insn_string="l.div";
	  insn_props->insn_index=96;
	  break;
	case 0xa:
	  insn_props->insn_string="l.divu";
	  insn_props->insn_index=97;
	  break;
	case 0xb:
	  insn_props->insn_string="l.mulu";
	  insn_props->insn_index=98;
	  break;
	case 0xc:
	  switch(insn_or1k_opcode_0x38_get_op_hi_4bit(insn))
	    {
	    case 0x0:
	      insn_props->insn_string="l.exths";
	      insn_props->insn_index=99;
	      break;
	    case 0x1:
	      insn_props->insn_string="l.extbs";
	      insn_props->insn_index=100;
	      break;
	    case 0x2:
	      insn_props->insn_string="l.exthz";
	      insn_props->insn_index=101;
	      break;
	    case 0x3:
	      insn_props->insn_string="l.extbz";
	      insn_props->insn_index=102;
	      break;
	    }
	  insn_props->has_rB = 0;
	  break;
	  
	case 0xd:
	  switch(insn_or1k_opcode_0x38_get_op_hi_4bit(insn))
	    {
	    case 0x0:
	      insn_props->insn_string="l.extws";
	      insn_props->insn_index=103;
	      break;
	    case 0x1:
	      insn_props->insn_string="l.extwz";
	      insn_props->insn_index=104;
	      break;
	    }
	  insn_props->has_rB = 0;
	  break;
	
	case 0xe:
	  insn_props->insn_string="l.cmov";
	  insn_props->insn_index=105;
	  break;

	case 0xf:
	  if (insn_or1k_opcode_0x38_get_op_hi_2bit(insn) & 0x1)
	    {
	      insn_props->insn_string="l.fl1";
	      insn_props->insn_index=106;
	    }
	  else
	    {
	      insn_props->insn_string="l.ff1";
	      insn_props->insn_index=107;
	    }
	  insn_props->has_rB = 0;
	  break;

	default:
	  printf("Unknown ALU lo op (0x%x)",
		 insn_or1k_opcode_0x38_get_op_lo(insn));
	  return 1;
	  break;
	}
      break;

    case 0x39:
      insn_props->has_rA = 1;
      insn_props->has_rB = 1;
      switch (insn_or1k_opcode_0x39_get_op(insn))
	{
	case 0x0:
	  insn_props->insn_string="l.sfeq";
	  insn_props->insn_index=108;
	  break;
	case 0x1:
	  insn_props->insn_string="l.sfne";
	  insn_props->insn_index=109;
	  break;
	case 0x2:
	  insn_props->insn_string="l.sfgtu";
	  insn_props->insn_index=110;
	  break;
	case 0x3:
	  insn_props->insn_string="l.sfgeu";
	  insn_props->insn_index=111;
	  break;
	case 0x4:
	  insn_props->insn_string="l.sfltu";
	  insn_props->insn_index=112;
	  break;
	case 0x5:
	  insn_props->insn_string="l.sfleu";
	  insn_props->insn_index=113;
	  break;
	case 0xa:
	  insn_props->insn_string="l.sfgts";
	  insn_props->insn_index=114;
	  break;
	case 0xb:
	  insn_props->insn_string="l.sfges";
	  insn_props->insn_index=115;
	  break;
	case 0xc:
	  insn_props->insn_string="l.sflts";
	  insn_props->insn_index=116;
	  break;
	case 0xd:
	  insn_props->insn_string="l.sfles";
	  insn_props->insn_index=117;
	  break;
	default:
	  printf("Unknown opcode for l.sfxxx opcode (0x%x)",
		 insn_or1k_opcode_0x39_get_op(insn));
	  return 1;
	  break;
	}
      break;
      
    default:
      printf("Unknown opcode 0x%x",insn_or1k_opcode(insn));
      return 1;
      break;
    }   

  return 0;
}

// Function to track entire instructions, regardless of architecture
// Storage list:
// Format: [0] - binary copy of instruction
//         [1] - occurrence count
uint32_t (*bin_insn_list)[2] = NULL;
int bin_insn_list_count = -1;
#define NUM_EXPECTED_UNIQUE_INSNS 50000
void record_bin_insn(uint32_t insn)
{
  // Check if the array has been initialised yet
  if (bin_insn_list_count == -1)
    {
      bin_insn_list = calloc((NUM_EXPECTED_UNIQUE_INSNS*2)*sizeof(uint32_t),1);
      bin_insn_list_count = 0;
    }

  int list_check_itr;
  // Go through the list, check if we've seen this one before
  for(list_check_itr=0;list_check_itr<bin_insn_list_count;list_check_itr++)
    if (bin_insn_list[list_check_itr][0] == insn)
      {
	// Seen it before, just increment count
	bin_insn_list[list_check_itr][1]++;
	return;
      }

  
  // If we're here, we've not seen this one before, it's new

  // No room left in list to add new ones
  if ( bin_insn_list_count == NUM_EXPECTED_UNIQUE_INSNS )
    return;
  
  // Add it to the list
  bin_insn_list[bin_insn_list_count][0] = insn;
  bin_insn_list[bin_insn_list_count][1] = 1;

  bin_insn_list_count++;
  
  // No room left in list to add new ones
  if ( bin_insn_list_count == NUM_EXPECTED_UNIQUE_INSNS )
    fprintf(stderr, "Warning: bin_insn_list[][] full (%d entries)\n",
	    NUM_EXPECTED_UNIQUE_INSNS);
  
  
}

// Entry point for statistics collection.
// Passed binary copy of instruction, and pointer to properties struct
// Each function that can collect staistics is called.
void or1k_32_collect_stats(uint32_t insn,
			   struct or1k_32_instruction_properties  * insn_props,
			   int record_bin_insns)
{
  // Add this instruction's occurrence to our data
  insn_lists_add(insn, insn_props);

  // n-tuple groupings stats recording here!  
  // only if we've seen enough to do all the sequence analysis
  if (num_seen_insns > OR1K_MAX_GROUPINGS_ANALYSIS+1)
    {
      int n;
      for(n=2;n<OR1K_MAX_GROUPINGS_ANALYSIS+1;n++)
	insn_lists_group_add(n, insn_props);
    }

  if (record_bin_insns)
    record_bin_insn(insn);

  // Finished adding to stats for this instruction

}

// Function to add entry to, or increment incidences of, value in the value list
void or1k_add_in_list(struct or1k_value_list * list, int32_t value)
{
  int i;
  // See if it's already in the list
  i=list->count;

  while(i)
    {
      i--;
      if(list->values[i][0] == value)
	{
	  (list->values[i][1])++;
	  return;
	}
    }

  if (list->count < OR1K_VALUE_MAX_ENTRIES)
    {
      // Not found, add it to the list
      list->values[(list->count)][0] = value;
      list->values[(list->count)][1] = 1;
      list->count++;
    }    
}

// List management/analysis functions - accessed through insn_lists() set of
// functions

// Clear the list structs
void or1k_32_insn_lists_init(void)
{
  num_setup_insns = 0;
  num_seen_insns = 0;
  // Clear the pointer array so we can tell if things are used or not
  memset(or1k_32_insns, '\0', 
	 sizeof(struct or1k_insn_info *)*OR1K_32_MAX_INSNS);
}

// Alloc struct and put it into the list
void or1k_32_insn_lists_init_insn(uint32_t insn, 
			struct or1k_32_instruction_properties *insn_props)
{
  // Add an instruction in or1k_32_insns[num_unique_instructions];
  // use calloc() so it clears it all first (hopefully!).. assumption!
  struct or1k_insn_info * new_insn 
    = (struct or1k_insn_info *) calloc (sizeof(struct or1k_insn_info), 1);

  // Copy the string pointer
  new_insn->insn_string = insn_props->insn_string, 

  // Install the pointer for this newly allocated struct in its corresponding
  // index, as set when we decode the instruction
  or1k_32_insns[insn_props->insn_index] = new_insn;

  // Clear the set statistics counters
  int set_itr;
  for(set_itr=0;set_itr<OR1K_MAX_GROUPINGS_ANALYSIS;set_itr++)
    or1k_32_insns[insn_props->insn_index]->groupings[set_itr][0][0] = 0;

  // Increment number of instructions we have set up
  num_setup_insns++;
  
  // Debugging:
  //printf("Adding %dth instruction - %s\n",
  //num_setup_insns, new_insn->insn_string);

}



// Add stats for this instruction
void or1k_32_insn_lists_add(uint32_t insn, 
			    struct or1k_32_instruction_properties *insn_props)
{
  // Check if the entry for this instruction has been setup yet
  if (or1k_32_insns[insn_props->insn_index] == NULL)
    {
      // Here we allocate space for the instruction's stats
      or1k_32_insn_lists_init_insn(insn, insn_props);
    }
  
  // Increment occurrence count
  ((or1k_32_insns[insn_props->insn_index])->count)++;

  // Add branch target value information, if instruction has it
  if (insn_props->has_branchtarg)
    {
      (or1k_32_insns[insn_props->insn_index])->has_branchtarg = 1;
      or1k_add_in_list(&((or1k_32_insns[insn_props->insn_index])->branch_info), 
		       (int32_t)insn_or1k_opcode_0x03_get_branchoff(insn));     
    }
  
  // Add immediate value if it's got one
  if (insn_props->has_imm)
    {
      (or1k_32_insns[insn_props->insn_index])->has_imm = 1;
      or1k_add_in_list(&((or1k_32_insns[insn_props->insn_index])->imm_info), 
		       (int32_t)insn_or1k_32_imm(insn));
    }
  
  // Add split immediate value if it's got one
  if (insn_props->has_split_imm)
    {
      (or1k_32_insns[insn_props->insn_index])->has_imm = 1;
      or1k_add_in_list(&((or1k_32_insns[insn_props->insn_index])->imm_info), 
		       (int32_t)insn_or1k_32_split_imm(insn));
    }


  // Increment count of use for particular rD
  if (insn_props->has_rD)
    {
      (or1k_32_insns[insn_props->insn_index])->has_rD = 1;
      ((or1k_32_insns[insn_props->insn_index])->rD_use_freq[insn_or1k_32_rD(insn)])++;
    }

  // Increment count of use for particular rA
  if (insn_props->has_rA)
    {
      (or1k_32_insns[insn_props->insn_index])->has_rA = 1;
      ((or1k_32_insns[insn_props->insn_index])->rA_use_freq[insn_or1k_32_rA(insn)])++;
    }
  
  // Increment count of use for particular rB
  if (insn_props->has_rB)
    {
      (or1k_32_insns[insn_props->insn_index])->has_rB = 1;
      ((or1k_32_insns[insn_props->insn_index])->rB_use_freq[insn_or1k_32_rB(insn)])++;
    }
  
  // Increment overall instructions "seen" counter
  num_seen_insns++;

  // Shift along the recently seen instructions
  int i;
  for(i=OR1K_MAX_GROUPINGS_ANALYSIS-1;i>0;i--)
    or1k_32_recent_insns[i] = or1k_32_recent_insns[i-1];
  or1k_32_recent_insns[0] = insn_props->insn_index;

}




// Do the n-tuple set checking for the current instruction
void or1k_32_ntuple_add(int n, 
			struct or1k_32_instruction_properties *insn_props)
{

  if (n<2)
    {
      fprintf(stderr,"or1k_32_ntuple_add: tuple number < 2 (%d)",n);
      return;
    }

  struct or1k_insn_info * insn_info = or1k_32_insns[insn_props->insn_index];

  // Get the number of sets for these n-tuple groups we've seen so far.
  int sets_for_ntuple = insn_info->groupings[n-1][0][0];
#if DEBUG_PRINT
  printf("%s\t:\t%d-tuple add - sets so far : %d\n",
	 insn_info->insn_string, n, sets_for_ntuple);
#endif

  int set_match_index; 
  int tuple_set_itr, tuple_set_match;

  tuple_set_match = 0;
  
  // now find if the current n instructions in or1k_32_recent_insns[] matches
  // any set of n instructions we're keeping track of in groupings[][][].
#if DEBUG_PRINT
  printf("%s\tChecking\t%d\tsets for ntuple:\t",
	 insn_info->insn_string,sets_for_ntuple);
  for(tuple_set_itr=0;tuple_set_itr<n;tuple_set_itr++)
    printf("%s ",
	   or1k_32_insns[(or1k_32_recent_insns[n - 1 - tuple_set_itr])]->insn_string);
  printf("\n");
#endif  
  for (set_match_index=0; set_match_index<sets_for_ntuple; set_match_index++)
    {
      // Check this set for a match with our existing trace
      // Example:
      // In case of a triple (n=3), 1st set, [3][1][0] corresponds to the third
      // instruction in the trace (or1k_32_recent_insns[2]), [3][1][1] should 
      // be the second in the trace, and [3][1][2] should be the first in the 
      // trace (same index as insn_props->insn_index)

#if DEBUG_PRINT
      printf("Chk:\t");
      for(tuple_set_itr=0;tuple_set_itr<n;tuple_set_itr++)
	printf("%s ",
	       or1k_32_insns[(insn_info->groupings[n-1][set_match_index+1][tuple_set_itr])]->insn_string);
      printf("\t(%d)\n", insn_info->groupings[n-1][set_match_index+1][n]);
#endif      
      tuple_set_match = 1;
      // Presuppose a match, de-assert and break out of the loop as soon as we
      // detect a mismatch.
      for(tuple_set_itr=0;tuple_set_itr<n;tuple_set_itr++)
	{
	  
	  if (insn_info->groupings[n-1][set_match_index+1][tuple_set_itr] 
	      != or1k_32_recent_insns[n - 1 - tuple_set_itr])
	    {
	      tuple_set_match = 0;
	      break; // No match, so break out of this for() loop
	    }
	}
      
      if (!tuple_set_match)
	continue; // go again...
      else
	break; // Bail out, we've found our match
    }

  if (tuple_set_match)
    {
      // Found a match - just increment the counter (set_match_index should
      // be pointing at the right set)            
#if DEBUG_PRINT
      printf("Match!\n");
#endif

      (insn_info->groupings[n-1][set_match_index+1][n])++;
    }
  else
    {
      // If we can record a new set
      if (sets_for_ntuple < OR1K_MAX_ENTRIES_PER_GROUP)
	{
#if DEBUG_PRINT
	  printf("New entry\n");
#endif

	  // Increment the number of sets we have for this n-tuple starting
	  // on the current instruction  
	  sets_for_ntuple++;
	  // Add new set to the end (all n instructions, copy in)
	  for(tuple_set_itr=0;tuple_set_itr<n;tuple_set_itr++)
	    insn_info->groupings[n-1][sets_for_ntuple][tuple_set_itr] 
	      = or1k_32_recent_insns[n - 1 - tuple_set_itr];
	  // Set the count for this set to 1
	  (insn_info->groupings[n-1][sets_for_ntuple][n]) = 1;
	  // Increment the counter of these n-tuple sets
	  insn_info->groupings[n-1][0][0] = sets_for_ntuple;	       
	}
    }
  
#if DEBUG_PRINT
  // Verbose announcement of found instruction
   if (tuple_set_match)
  {
     printf("%s\t:\tMatch for %d-tuple - set %d - cnt: %d - ",
      insn_info->insn_string, n, set_match_index, 
  	     insn_info->groupings[n-1][set_match_index+1][n]);
    for(tuple_set_itr=0;tuple_set_itr<n;tuple_set_itr++)
  	printf("%s ",
  	       or1k_32_insns[(insn_info->groupings[n-1][sets_for_ntuple][tuple_set_itr])]->insn_string);
    printf("\n");
  }
  else
    {
     printf("%s\t:\tNew %d-tuple - set %d - cnt: %d - ",
  	     insn_info->insn_string, n, sets_for_ntuple, 
  	     insn_info->groupings[n-1][sets_for_ntuple][n]);
    for(tuple_set_itr=0;tuple_set_itr<n;tuple_set_itr++)
  	printf("%s ",
  	       or1k_32_insns[(insn_info->groupings[n-1][sets_for_ntuple][tuple_set_itr])]->insn_string);
    printf("\n");
  }
#endif

}

// Generate a list for the most-frequently seen instructions
void or1k_32_most_freq_insn(FILE * stream)
{
  // Print out most frequent instruction
  int i, largest, largest_index;
  int instructions_to_print = num_setup_insns;

#ifdef DISPLAY_CSV
  fprintf(stream,"\"Most frequent instructions, descending\",\n");
  fprintf(stream,"\"Instruction\",\"Occurrences\",\"Frequency\",\n");
#endif

  while (instructions_to_print)
    {
      --instructions_to_print;
      largest=0;
      // Go through the list, find the largest, print it, eliminate it
      for(i=0;i<OR1K_32_MAX_INSNS;i++)
	if (or1k_32_insns[i]!=NULL){
	  if(((or1k_32_insns[i])->count) > largest)
	    {
	      largest = ((or1k_32_insns[i])->count);
	      largest_index = i;
	    }
	}
      fprintf(stream,
#ifdef DISPLAY_STRING      
	     "Insn:\t%s\t\tCount:\t\t%d\t(%f%%)\n",
#endif
#ifdef DISPLAY_CSV
	     // CSV format - "opcode string",frequency,percentage
	     "\"%s\",%d,%f\n",
#endif
	     ((or1k_32_insns[largest_index])->insn_string),
	     ((or1k_32_insns[largest_index])->count),
	     (float)(((float)((or1k_32_insns[largest_index])->count))/
		     ((float)num_seen_insns)));
      
      
      ((or1k_32_insns[largest_index])->count) = -1; // Eliminate this one
 
    }
}


// Generate a list for the most-frequently seen n-tuple set
void or1k_32_most_freq_ntuple(int n, FILE * stream, int max_stats)
{

  fprintf(stream,
#ifdef DISPLAY_STRING
	  "Top %d %d-tuple groupings of instructions\n",
#endif
#ifdef DISPLAY_CSV
	  "\"Top %d %d-tuple groupings of instructions\",\n",
#endif
	  max_stats, n);

  // First get a copy of all the n-tuple values for each applicable
  // instruction.
  int set_counts[OR1K_32_MAX_INSNS][OR1K_MAX_ENTRIES_PER_GROUP];
  int insn_index;
  int set_index;
  int num_sets;
  struct or1k_insn_info *insn_info;

  // Copy each instruction's set totals into our local array
  for(insn_index=0;insn_index<OR1K_32_MAX_INSNS;insn_index++)
    {
      if (or1k_32_insns[insn_index] != NULL)
	{
	  insn_info = or1k_32_insns[insn_index];
	  num_sets = insn_info->groupings[n-1][0][0];
	  for(set_index=0;set_index<num_sets;set_index++)
	    set_counts[insn_index][set_index] = 
	      insn_info->groupings[n-1][set_index+1][n];
	}
    }
  
  // Go through the set numbers, look at the most frequent one, print it out
  // clear its count and continue
  

  int largest_insn_index, largest_set_index, largest_count;
  int tuple_set_itr;


#ifdef DISPLAY_CSV
  for(tuple_set_itr=0;tuple_set_itr<n;tuple_set_itr++)
    fprintf(stream, "\"insn%d\",",n-1-tuple_set_itr);
  fprintf(stream, "\"count\",\n");
#endif

  while(max_stats--)
    {
      largest_count = 0;
      // Go through each instruction we have
      for(insn_index=0;insn_index<OR1K_32_MAX_INSNS;insn_index++)
	{
	  if (or1k_32_insns[insn_index] != NULL)
	    {
	      insn_info = or1k_32_insns[insn_index];
	      // Get the total number of sets for the n-tup. of this instruction
	      num_sets = insn_info->groupings[n-1][0][0];
	      for(set_index=0;set_index<num_sets;set_index++)
		{
		  // Go through each set, check if it's largest
		  if (set_counts[insn_index][set_index] >
		      largest_count)
		    {
		      largest_insn_index = insn_index;
		      largest_set_index = set_index;
		      largest_count = set_counts[insn_index][set_index];
		    }
		}
	    }
	}

      // We now have indexes of the next largest n-tuple, print it out.

      insn_info = or1k_32_insns[largest_insn_index];

#ifdef DISPLAY_STRING
      fprintf(stream,"set :");
#endif
      
      for(tuple_set_itr=0;tuple_set_itr<n;tuple_set_itr++)
  	fprintf(stream,
#ifdef DISPLAY_STRING
		" %s",
#endif
#ifdef DISPLAY_CSV
		"\"%s\",",
#endif
		or1k_32_insns[(insn_info->groupings[n-1][largest_set_index+1][tuple_set_itr])]->insn_string);
      
      fprintf(stream,
#ifdef DISPLAY_STRING
	      "\tcount: %d\n",
#endif
#ifdef DISPLAY_CSV
	      "%d,\n",
#endif
	      set_counts[largest_insn_index][largest_set_index]);
	
	// Remove this value from getting selected from largest again
	set_counts[largest_insn_index][largest_set_index] = -1;
    } 

}




// Print out top n of each kept statistic for the requested instruction
void or1k_32_insn_top_n(struct or1k_insn_info *insn_info, FILE * stream, 
			int max_stats)
{
  int i, j, largest_i;
  
  fprintf(stream,
#ifdef DISPLAY_STRING
	  "Insn: \"%s\" statistics (%d times (%f%%))\n", 
#endif
#ifdef DISPLAY_CSV
	  "\"Instruction:\",\"%s\",\"occurrences:\",%d,%f%%\n", 
#endif
	  insn_info->insn_string,
	  insn_info->count,
	  (float)(((float)((insn_info)->count))/
		  ((float)num_seen_insns))
	  );
  

  
  // Start dumping applicable stats
  
  // Print out top max_stats branch targets
  if (insn_info->has_branchtarg)
    {
      fprintf(stream,
#ifdef DISPLAY_STRING
	      "Branch immediates:\n"
#endif
#ifdef DISPLAY_CSV
	      "\"branch imm\",\"occurrences\",\"frequency\"\n"
#endif
	      );
      i = 0;
      while(i<insn_info->branch_info.count && i < max_stats)
	{
	  largest_i=0;
	  for(j=0;j<insn_info->branch_info.count;j++)
	    largest_i = (insn_info->branch_info.values[j][1] > 
			 insn_info->branch_info.values[largest_i][1]) ?
	      j : largest_i;
	  
	  // largest_i has index of most frequent value
	  fprintf(stream, 
#ifdef DISPLAY_STRING
		  "value:\t0x%x\tcount:\t%d,\tfreq:\t%f%%\n",
#endif
#ifdef DISPLAY_CSV
		  "0x%x,%d,%f\n",
#endif
		  insn_info->branch_info.values[largest_i][0],
		  insn_info->branch_info.values[largest_i][1],
                  (float)(((float)insn_info->branch_info.values[largest_i][1])
			  /((float)((insn_info)->count))));
	  insn_info->branch_info.values[largest_i][1] = -1; // clear this one
	  i++;
	}
    }
  if (insn_info->has_imm)
    {
      fprintf(stream,
#ifdef DISPLAY_STRING
	      "Immediate values:\n"
#endif
#ifdef DISPLAY_CSV
	      "\"immediate value\",\"count\",\"frequency\"\n"
#endif
	      );
      i = 0;
      while(i<insn_info->imm_info.count && i < max_stats)
	{
	  largest_i=0;
	  for(j=0;j<insn_info->imm_info.count;j++)
	    largest_i = (insn_info->imm_info.values[j][1] > 
			 insn_info->imm_info.values[largest_i][1]) ?
	      j : largest_i;
	  
	  // largest_i has index of most frequent value
	  fprintf(stream, 
#ifdef DISPLAY_STRING
		  "value:\t0x%x\tcount:\t%d\tfreq:\t%f%%\n",
#endif
#ifdef DISPLAY_CSV
		  "0x%x,%d,%f\n",
#endif
		  insn_info->imm_info.values[largest_i][0],
		  insn_info->imm_info.values[largest_i][1],
		  (float)(((float)insn_info->imm_info.values[largest_i][1])
			  /((float)((insn_info)->count))));
	  insn_info->imm_info.values[largest_i][1] = -1; // clear this one
	  i++;
	}
    }

  if (insn_info->has_rD)
    {
      fprintf(stream,
#ifdef DISPLAY_STRING
	      "rD usage:\n"
#endif
#ifdef DISPLAY_CSV
	      "\"rD\",\"count\",\"frequency\"\n"
#endif
	      );
      i = 0;
      while(i<32 && i < max_stats)
	{
	  largest_i=0;
	  for(j=0;j<32;j++)
	    largest_i = (insn_info->rD_use_freq[j] > 
			 insn_info->rD_use_freq[largest_i]) ?
	      j : largest_i;

	  // No more interesting numbers
	  if (insn_info->rD_use_freq[largest_i] == 0)
	    break;
	  
	  // largest_i has index of most frequent value
	  fprintf(stream, 
#ifdef DISPLAY_STRING
		  "r%d\tcount:\t%d\tfreq:\t%f%%\n",
#endif
#ifdef DISPLAY_CSV
		  "\"r%d\",%d,%f\n",		  
#endif
		  largest_i,
		  insn_info->rD_use_freq[largest_i],
		  (float)(((float)insn_info->rD_use_freq[largest_i])
			  /((float)((insn_info)->count))));
	  insn_info->rD_use_freq[largest_i] = -1; // clear this one
	  i++;
	}
    }

  if (insn_info->has_rA)
    {
      fprintf(stream,
#ifdef DISPLAY_STRING
	      "rA usage:\n"
#endif
#ifdef DISPLAY_CSV
	      "\"rA\",\"count\",\"frequency\"\n"
#endif
	      );
      i = 0;
      while(i<32 && i < max_stats)
	{
	  largest_i=0;
	  for(j=0;j<32;j++)
	    largest_i = (insn_info->rA_use_freq[j] > 
			 insn_info->rA_use_freq[largest_i]) ?
	      j : largest_i;
	  
	  // No more interesting numbers
	  if (insn_info->rA_use_freq[largest_i] == 0)
	    break;
	  

	  // largest_i has index of most frequent value
	  fprintf(stream, 
#ifdef DISPLAY_STRING
		  "r%d\tcount:\t%d\tfreq:\t%f%%\n",
#endif
#ifdef DISPLAY_CSV
		  "\"r%d\",%d,%f\n",		  
#endif
		  largest_i,
		  insn_info->rA_use_freq[largest_i],
		  (float)(((float)insn_info->rA_use_freq[largest_i])
			  /((float)((insn_info)->count))));
	  insn_info->rA_use_freq[largest_i] = -1; // clear this one
	  i++;
	}
    }
  
  if (insn_info->has_rB)
    {
      fprintf(stream,
#ifdef DISPLAY_STRING
	      "rB usage:\n"
#endif
#ifdef DISPLAY_CSV
	      "\"rB\",\"count\",\"frequency\"\n"
#endif
	      );
      i = 0;
      while(i<32 && i < max_stats)
	{
	  largest_i=0;
	  for(j=0;j<32;j++)
	    largest_i = (insn_info->rB_use_freq[j] > 
			 insn_info->rB_use_freq[largest_i]) ?
	      j : largest_i;

	  // No more interesting numbers
	  if (insn_info->rB_use_freq[largest_i] == 0)
	    break;
	  
	  
	  // largest_i has index of most frequent value
	  fprintf(stream, 
#ifdef DISPLAY_STRING
		  "r%d\tcount:\t%d\tfreq:\t%f%%\n",
#endif
#ifdef DISPLAY_CSV
		  "\"r%d\",%d,%f\n",		  
#endif
		  largest_i,
		  insn_info->rB_use_freq[largest_i],
		  (float)(((float)insn_info->rB_use_freq[largest_i])
			  /((float)((insn_info)->count))));
	  insn_info->rB_use_freq[largest_i] = -1; // clear this one
	  i++;
	}
    }
}



// Print out the most common n-tuple groupings for an instruction
void or1k_32_generate_ntuple_stats(int n, struct or1k_insn_info *insn_info, 
				   FILE * stream)
{
  // Maximum number we'll print out
#define MAX_NTUPLE_LISTING 5

  int (*ntuplelist)[OR1K_MAX_GROUPINGS_ANALYSIS+1];
  int *set;
  int set_count, set_count2;

  // Get total number of sets for this n-tuple, eg:
  // if n=2 (pairs) then groupings[1] is where our list is, and we store the 
  // number of sets in [0][0] of that n-tuple data.
  int total_sets_for_ntuple =  insn_info->groupings[n-1][0][0];

  if (total_sets_for_ntuple == 0)
    return;

  fprintf(stream, 
#ifdef DISPLAY_STRING	  
	  "%d-tuple groupings finishing with %s (%d)\n",
#endif
#ifdef DISPLAY_CSV
	  "\"%d-tuple groupings\",\n",
#endif	   
	  n, insn_info->insn_string, total_sets_for_ntuple);


  // Debug - dump out all of the info for the sets
#if DEBUG_PRINT
  for (set_count = 0;set_count <total_sets_for_ntuple;set_count++)
    {

      printf("set: %d - count %d - set: ", set_count, 
	     insn_info->groupings[n-1][set_count+1][n]);
      
      for(set_count2=0;set_count2<n;set_count2++)
	fprintf(stream, "%s\t", 
		or1k_32_insns[(insn_info->groupings[n-1][set_count+1][set_count2])]->insn_string);
      printf("\n");
    }
#endif

  // A pointer to the n-tuple sets
  // This is actually a pointer to a 2-dimensional integer array, looking like:
  // [OR1K_MAX_ENTRIES_PER_GROUP+1][OR1K_MAX_GROUPINGS_ANALYSIS+1], so in 
  // 2-dimensional array pointer fashion, we should provide the "column" sizing.
      ntuplelist = insn_info->groupings[n-1];
  
  // Let's make a copy of the counts for each... so we don't trash them
  int set_count_copy[OR1K_MAX_ENTRIES_PER_GROUP+1];

  assert(total_sets_for_ntuple <= OR1K_MAX_ENTRIES_PER_GROUP);

  // Go through the list, copy the counts for each
  for (set_count = 0;set_count <total_sets_for_ntuple;set_count++)
    {
      // Pointer to a set's data
      set = ntuplelist[set_count+1];
      // Fish out the copy (0 to n-1 will be the instruction index, n will be 
      // the count)
      set_count_copy[set_count+1] = set[n];
    }


#ifdef DISPLAY_CSV
      for(set_count2=0;set_count2<n;set_count2++)
	fprintf(stream, "\"insn%d\",",n-1-set_count2);
      fprintf(stream, "\"count\",\n");
#endif

  
  // Now go through, finding the most frequent n-tuple of instructions and
  // print it out
  int largest_indx = 0;
  set_count=0;
  while(set_count < total_sets_for_ntuple && set_count < MAX_NTUPLE_LISTING)
    {
      largest_indx = 0;
      for(set_count2=0;set_count2<total_sets_for_ntuple;set_count2++)
	largest_indx = (set_count_copy[set_count2 + 1] > 
			set_count_copy[largest_indx + 1]) ?
	  set_count2 : largest_indx;
      // largest_indx is the index of the set with the highest occurrence, so
      // let's print it out, but first get a pointer to the set's data
      set = (int*)ntuplelist[largest_indx+1];

      // Print out the sequence of prior isntructions
#ifdef DISPLAY_STRING
      fprintf(stream,"Seq:\t");
#endif
      // Go through the indexes of the previous instructions, get their
      // strings, and print them out
      for(set_count2=0;set_count2<n;set_count2++)
	fprintf(stream, 
#ifdef DISPLAY_STRING
		"%s\t", 
#endif
#ifdef DISPLAY_CSV
		"\"%s\",",
#endif
		or1k_32_insns[(set[set_count2])]->insn_string);
      
      // now print out the occurrences
      fprintf(stream, 
#ifdef DISPLAY_STRING
	      "\t%d\ttimes (%f%%)\n", 
#endif
#ifdef DISPLAY_CSV
	      "%d,\n",
#endif
	      set[n],
	      (float)((float)set[n]/(float)insn_info->count));
      
      // done printing this one out.. let's clear its count
      set_count_copy[largest_indx + 1] = -1;
      
      set_count++;
    }
  
  return;

}


// Print out the top n seen entire instructions
void print_top_bin_insn(FILE * stream, int n)
{
  int largest_indx = 0;
  int bin_insn_list_itr;

  // Copy the counts, so we can trash them as needed
  int bin_insn_counts[NUM_EXPECTED_UNIQUE_INSNS];

  // An instruction properties object
  struct or1k_32_instruction_properties insn_props;
  
  for(bin_insn_list_itr=0;bin_insn_list_itr<bin_insn_list_count;
      bin_insn_list_itr++)
    bin_insn_counts[bin_insn_list_itr] = bin_insn_list[bin_insn_list_itr][1];

#ifdef DISPLAY_STRING
  fprintf(stream, "Top %d seen instructions\n", n);
  fprintf(stream, "Saw %d unique instructions\n", bin_insn_list_count);
#endif
#ifdef DISPLAY_CSV
  fprintf(stream, ",\n");
  fprintf(stream,"\"Top %d instructions\",\n\"Total unique instructions\",%d\n",
	  n, bin_insn_list_count);
  fprintf(stream, 
	  "\"Instruction (bin)\",\"Dissassembly\",\"Occurrences\",\"Freq\"\n");
#endif
  
  while (n--)
    {
      // Search for the largest count
      for(bin_insn_list_itr=0;bin_insn_list_itr<bin_insn_list_count;
	  bin_insn_list_itr++)
	largest_indx = (bin_insn_counts[bin_insn_list_itr] >
			bin_insn_counts[largest_indx]) ?
	  bin_insn_list_itr : largest_indx;

      // Gone through list, largest_indx is the biggest index

      // Clear the instruction properties struct
      memset(&insn_props, 0, sizeof(struct or1k_32_instruction_properties));

      // Get the string for this instruction
      or1k_32_analyse_insn(bin_insn_list[largest_indx][0], &insn_props);

      // Print out the instruction
#ifdef DISPLAY_STRING
      fprintf(stream, "Insn:\t0x%.8x\t%s",bin_insn_list[largest_indx][0],
	      insn_props.insn_string);
#endif
#ifdef DISPLAY_CSV
      fprintf(stream, "\"0x%.8x\",\"%s",bin_insn_list[largest_indx][0],
	      insn_props.insn_string);
#endif
  
      if (insn_props.has_jumptarg || insn_props.has_branchtarg)
#ifdef DISPLAY_STRING
	fprintf(stream, " 0x%x", (bin_insn_list[largest_indx][0] & JUMPTARG_MASK) << 2 );
#endif
#ifdef DISPLAY_CSV
        fprintf(stream, " 0x%x",  (bin_insn_list[largest_indx][0] & JUMPTARG_MASK) << 2 );
#endif
  

      if (insn_props.has_rD)
#ifdef DISPLAY_STRING
	fprintf(stream, " r%d",
		insn_or1k_32_rD(bin_insn_list[largest_indx][0]));
#endif
#ifdef DISPLAY_CSV
        fprintf(stream, " r%d",
		insn_or1k_32_rD(bin_insn_list[largest_indx][0]));
#endif

      if (insn_props.has_rA)
#ifdef DISPLAY_STRING
	fprintf(stream, " r%d",
		insn_or1k_32_rA(bin_insn_list[largest_indx][0]));
#endif
#ifdef DISPLAY_CSV
        fprintf(stream, " r%d",
		insn_or1k_32_rA(bin_insn_list[largest_indx][0]));
#endif

      if (insn_props.has_rB)
#ifdef DISPLAY_STRING
	fprintf(stream, " r%d",
		insn_or1k_32_rB(bin_insn_list[largest_indx][0]));
#endif
#ifdef DISPLAY_CSV
        fprintf(stream, " r%d",
		insn_or1k_32_rB(bin_insn_list[largest_indx][0]));
#endif


      if (insn_props.has_imm)
#ifdef DISPLAY_STRING
	fprintf(stream, " 0x%x",
		insn_or1k_32_imm(bin_insn_list[largest_indx][0]));
#endif
#ifdef DISPLAY_CSV
        fprintf(stream, " 0x%x",
		insn_or1k_32_imm(bin_insn_list[largest_indx][0]));
#endif

      if (insn_props.has_split_imm)
#ifdef DISPLAY_STRING
	fprintf(stream, " 0x%x",
		insn_or1k_32_split_imm(bin_insn_list[largest_indx][0]));
#endif
#ifdef DISPLAY_CSV
        fprintf(stream, " 0x%x",
		insn_or1k_32_split_imm(bin_insn_list[largest_indx][0]));
#endif
	
#ifdef DISPLAY_STRING
	fprintf(stream, "\tcount:\t%d (%f%%)\n",bin_insn_list[largest_indx][1],
		(float)((float)bin_insn_list[largest_indx][1])/
		((float)num_seen_insns));
#endif
#ifdef DISPLAY_CSV
	fprintf(stream, "\",%d,%f\n",bin_insn_list[largest_indx][1],
		(float)((float)bin_insn_list[largest_indx][1])/
		((float)num_seen_insns));
#endif

	// Finished printing out its instruction
	bin_insn_counts[largest_indx] = -1;
      
    }
}


// Print out the stats relating to the sequences of instructions most
// common before seeing this instruction
void or1k_32_generate_groupings_stats(struct or1k_insn_info *insn_info, 
				      FILE * stream)
{
  int n;
  for(n=2;n<OR1K_MAX_GROUPINGS_ANALYSIS+1;n++)
    or1k_32_generate_ntuple_stats(n, insn_info, stream);

}

// Entry point for statistics generation.    
void or1k_32_generate_stats(FILE * stream)
{
#ifdef DISPLAY_STRING
  // Generate some useful things
  fprintf(stream, "Analysis output:\n");
#endif  
  // 

  // Print out all stats for every instruction we saw!
  int insn_index;
  for(insn_index=0;insn_index<OR1K_32_MAX_INSNS;insn_index++)
    {
      if (or1k_32_insns[insn_index] != NULL)
	{
#ifdef DISPLAY_STRING
	  fprintf(stream, "\t---\t---\t---\t---\n");
#endif
#ifdef DISPLAY_CSV
	  fprintf(stream, ",\n");
#endif
	  or1k_32_insn_top_n(or1k_32_insns[insn_index],stream,10);
	  or1k_32_generate_groupings_stats(or1k_32_insns[insn_index],stream);

	}
    }

#ifdef DISPLAY_STRING
	  fprintf(stream, "\t---\t---\t---\t---\n");
#endif
#ifdef DISPLAY_CSV
	  fprintf(stream, ",\n");
#endif


  // print out most frequent n-tuple
  int ntuple;
  for(ntuple=2;ntuple<5;ntuple++)
    or1k_32_most_freq_ntuple(ntuple, stream, 10);


#ifdef DISPLAY_STRING
	  fprintf(stream, "\t---\t---\t---\t---\n");
#endif
#ifdef DISPLAY_CSV
	  fprintf(stream, ",\n");
#endif

      
  // Do most frequent instruction analysis -- note this trashes instruction
  // frequency count - should be fixed
#ifdef DISPLAY_STRING
  fprintf(stream, "Individual instruction frequency:\n");
#endif
  or1k_32_most_freq_insn(stream);

  // If we did the binary instruction frequency counting, print it out
  if (bin_insn_list_count != -1)
    print_top_bin_insn(stream, 20);
  
}



// Free up all added instruction statistic tracking structs
void or1k_32_insn_lists_free(void)
{
  // Free all entries we m/calloc()'d
  int insn_index;
  for(insn_index=0;insn_index<OR1K_32_MAX_INSNS;insn_index++)
    {
      if (or1k_32_insns[insn_index] != NULL)
	free(or1k_32_insns[insn_index]);
    }

  if (bin_insn_list_count != -1)
    free(bin_insn_list);
}
