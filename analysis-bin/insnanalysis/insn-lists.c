/*
  Instruction list-keeping functions, aiding analysis

  Julius Baxter, julius.baxter@orsoc.se

*/

#include <stdio.h> // Needed for insnanalysis.h
#include "insnanalysis.h"
#include "insn-lists.h"


void insn_lists_init(void)
{
  or1k_32_insn_lists_init();
}

void insn_lists_add(instruction insn,
		     instruction_properties *insn_props)
{
  or1k_32_insn_lists_add(insn, insn_props);
}

void insn_lists_group_add(int n,
			  instruction_properties *insn_props)
{
  or1k_32_ntuple_add(n, insn_props);
}

void insn_lists_free(void)
{
  or1k_32_insn_lists_free();
}
