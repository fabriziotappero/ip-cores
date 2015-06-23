/* tc-scarts_16.c -- Assembler for the SCARTS_16 family.
   Copyright 2001, 2002, 2003, 2005, 2006, 2007 Free Software Foundation.
   Contributed by Martin Walter <mwalter@opencores.org>

   This file is part of GAS, the GNU Assembler.

   GAS is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3, or (at your option)
   any later version.

   GAS is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with GAS; see the file COPYING.  If not, write to
   the Free Software Foundation, 51 Franklin Street - Fifth Floor,
   Boston, MA 02110-1301, USA.  */

#include "as.h"
#include "subsegs.h"
#include "symcat.h"
#include "opcodes/scarts_16-desc.h"
#include "opcodes/scarts_16-opc.h"
#include "cgen.h"
#include "libbfd.h"

const char comment_chars[]        = ";";
const char line_comment_chars[]   = "#";
const char line_separator_chars[] = "|";
const char EXP_CHARS[]            = "eE";
const char FLT_CHARS[]            = "dD";

const char scarts_16_comment_chars[] = ";#";


/* Target specific short options. */
#define SCARTS_16_SHORTOPTS ""
const char *md_shortopts = SCARTS_16_SHORTOPTS;

/* Target specific long options. */
struct option md_longopts[] =
{
  {NULL, no_argument, NULL, 0}
};

size_t md_longopts_size = sizeof(md_longopts);

/* Set the default machine. */
#define DEFAULT_MACHINE bfd_mach_scarts_16
unsigned long scarts_16_mach = DEFAULT_MACHINE;

/* Target specific pseudo-ops. */
const pseudo_typeS md_pseudo_table[] =
{
  {NULL,  NULL, 0}
};


/* GAS will call md_parse_option whenever getopt returns an unrecognized code,
   presumably indicating a special code value which appears in md_longopts.
   This function should return non-zero if it handled the option and zero
   otherwise. There is no need to print a message about an option not being
   recognized. This will be handled by the generic code. */
int
md_parse_option(int c ATTRIBUTE_UNUSED, char *arg ATTRIBUTE_UNUSED)
{
  return 0;
}

/* GAS will call md_show_usage when a usage message is printed; it should print
   a description of the machine specific options. */
void
md_show_usage(FILE * stream ATTRIBUTE_UNUSED)
{
}

/* GAS will call this function at the start of the assembly, after the command
   line arguments have been parsed and all the machine independent
   initializations have been completed. */
void
md_begin(void)
{
  /* Set the machine number and endianness.  */
  gas_cgen_cpu_desc = scarts_16_cgen_cpu_open(CGEN_CPU_OPEN_MACHS, scarts_16_mach, CGEN_CPU_OPEN_ENDIAN, (target_big_endian ? CGEN_ENDIAN_BIG : CGEN_ENDIAN_LITTLE), CGEN_CPU_OPEN_END);
  
  scarts_16_cgen_init_asm(gas_cgen_cpu_desc);
  
  /* This is a callback from cgen to gas to parse operands.  */
  cgen_set_parse_operand_fn(gas_cgen_cpu_desc, gas_cgen_parse_operand);
  
  /* Set the machine type.  */
  bfd_default_set_arch_mach(stdoutput, bfd_arch_scarts_16, scarts_16_mach);
}

/* GAS will call this function for each input line which does not contain a
   pseudoop. The argument is a null terminated string. The function should
   assemble the string as an instruction with operands. */
void
md_assemble(char *str)
{
  const CGEN_INSN *insn;
  char *errmsg;
  CGEN_FIELDS fields;

#if CGEN_INT_INSN_P
  CGEN_INSN_INT buffer[CGEN_MAX_INSN_SIZE / sizeof(CGEN_INSN_INT)];
#else
  unsigned char buffer[CGEN_MAX_INSN_SIZE];
#endif

  gas_cgen_init_parse();

  insn = scarts_16_cgen_assemble_insn(gas_cgen_cpu_desc, str, &fields, buffer, &errmsg);
  if (!insn)
  {
    as_bad(errmsg);
    return;
  }

  /* MWA: Instead of the instruction size, CGEN_FIELDS_BITSIZE(&fields)
   * erroneously delivers the value of the instruction and is therefore
   * replaced by the the proper CGEN_INSN_BITSIZE(insn). */
  gas_cgen_finish_insn(insn, buffer, CGEN_INSN_BITSIZE(insn), 0, NULL);
}

/* GAS will call this function when a symbol table lookup fails, before it
   creates a new symbol. Typically this would be used to supply symbols whose
   name or value changes dynamically, possibly in a context sensitive way.
   Predefined symbols with fixed values, such as register names or condition
   codes, are typically entered directly into the symbol table when md_begin
   is called. */
symbolS *
md_undefined_symbol(char * name ATTRIBUTE_UNUSED)
{
  return 0;
}

/* GAS will call this function with one argument, an expressionS pointer, for
   any expression that can not be recognized. When the function is called,
   input_line_pointer will point to the start of the expression. */
void
md_operand(expressionS *exp)
{
  if (*input_line_pointer == ';' || *input_line_pointer == '#')
  {
    input_line_pointer++;
    expression(exp);
  }
}

/* This function is called to convert an ASCII string into a floating point
   value in format used by the CPU. It takes three arguments. The first is type
   which is a byte describing the type of floating point number to be created.
   Possible values are ’f’ or ’s’ for single precision, ’d’ or ’r’ for double
   precision and ’x’ or ’p’ for extended precision. Either lower or upper case
   versions of these letters can be used.

   The second parameter is litP which is a pointer to a byte array where the
   converted value should be stored. The third argument is sizeP, which is a
   pointer to a integer that should be filled in with the number of LITTLENUMs
   emitted into the byte array. (LITTLENUM is defined in gas/bignum.h). The
   function should return NULL upon success or an error string upon failure. */

/* Equal to MAX_PRECISION in atof-ieee.c. */
#define MAX_LITTLENUMS 6

char *
md_atof (int type, char *litP, int *sizeP)
{
  char *t;
  int i, prec;
  LITTLENUM_TYPE words[MAX_LITTLENUMS];

  switch (type)
  {
    case 'f':
    case 'F':
    case 's':
    case 'S':
      prec = 2;
      break;

    case 'd':
    case 'D':
    case 'r':
    case 'R':
      prec = 4;
      break;

   /* FIXME: Some targets allow other format chars for bigger sizes here. */

    default:
      * sizeP = 0;
      return _("Bad call to md_atof()");
  }

  t = atof_ieee(input_line_pointer, type, words);
  if (t)
    input_line_pointer = t;

  *sizeP = prec * sizeof(LITTLENUM_TYPE);

  for (i = 0; i < prec; i++)
  {
    md_number_to_chars (litP, (valueT) words[i], sizeof (LITTLENUM_TYPE));
    litP += sizeof (LITTLENUM_TYPE);
  }

  return 0;
}

int
md_estimate_size_before_relax(register fragS *fragP ATTRIBUTE_UNUSED, register segT segment_type ATTRIBUTE_UNUSED)
{
  printf(_("Bad call to md_estimate_size_before_relax\n"));
  abort();
}

void
md_convert_frag(bfd *abfd ATTRIBUTE_UNUSED, segT sec ATTRIBUTE_UNUSED, fragS *fragP ATTRIBUTE_UNUSED)
{
}

long
md_pcrel_from_section(fixS *fixP, segT sec)
{
  if (fixP->fx_addsy != (symbolS *) NULL && (! S_IS_DEFINED (fixP->fx_addsy) || S_GET_SEGMENT (fixP->fx_addsy) != sec))
    /* The symbol is undefined (or is defined but not in this section).
       Let the linker figure it out. */
    return 0;
  
  return (fixP->fx_frag->fr_address + fixP->fx_where);
}

valueT
md_section_align(segT segment, valueT size)
{
  int align = bfd_get_section_alignment(stdoutput, segment);
  return ((size + (1 << align) - 1) & (-1 << align));
}

/* GAS will call this for each fixup.
   It should store the correct value in the object file.  */

void
scarts_16_md_apply_fix(fixS *fixP, valueT * valP, segT seg)
{
  long value;
  value = *valP;

  /* It is assumed that the program counter gets incremented after
   * an instruction fetch. In this case, a PC-relative relocation
   * value would need to be adjusted by the incrementation value. */
  /*
  if (fixP->fx_pcrel == 1)
    value -= 2;
  */

  gas_cgen_md_apply_fix(fixP, (valueT *)&value, seg);
}

int
scarts_16_force_relocation (fixP)
  fixS *fixP;
{
  int type;
  type = fixP->fx_r_type < BFD_RELOC_UNUSED ? (int) fixP->fx_r_type : fixP->fx_cgen.opinfo;

  switch (type)
  {
    case BFD_RELOC_SCARTS_16_PCREL_10:
      return 1;
    default:
      break;
  }

  return generic_force_reloc(fixP);
}

/* Return the bfd reloc type for OPERAND of INSN at fixup fixP.
   Returns BFD_RELOC_NONE if no reloc type can be found. */

bfd_reloc_code_real_type
md_cgen_lookup_reloc(const CGEN_INSN *insn ATTRIBUTE_UNUSED, const CGEN_OPERAND *operand, fixS *fixP)
{
  bfd_reloc_code_real_type type;
  type = BFD_RELOC_NONE;

  switch (operand->type)
  {
    case SCARTS_16_OPERAND_SIMM8:
      fixP->fx_pcrel = 0;

      if (fixP->fx_cgen.opinfo != 0)
        type = fixP->fx_cgen.opinfo;

      break;

    case SCARTS_16_OPERAND_UIMM8:
      fixP->fx_pcrel = 0;

      if (fixP->fx_cgen.opinfo != 0)
        type = fixP->fx_cgen.opinfo;

      break;

    case SCARTS_16_OPERAND_SADDR10_PCREL:
      fixP->fx_pcrel = 1;
      type = BFD_RELOC_SCARTS_16_PCREL_10;
      break;

    default:
      break;
  }

  return type;
}
