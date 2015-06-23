/* Subroutines for insn-output.c for the SCARTS32 micro controller
   Copyright (C) 1998, 1999, 2000, 2001, 2002, 2004, 2005 Free Software Foundation, Inc.
   Contributed by Wolfgang Puffitsch <hausen@gmx.at>
                  Martin Walter <mwalter@opencores.org>

   This file is part of the SCARTS32 port of GCC

   GNU CC is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.
   
   GNU CC is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with GNU CC; see the file COPYING.  If not, write to
   the Free Software Foundation, 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

#include "config.h"
#include "system.h"
#include "coretypes.h"
#include "tm.h"
#include "rtl.h"
#include "regs.h"
#include "hard-reg-set.h"
#include "real.h"
#include "insn-config.h"
#include "conditions.h"
#include "insn-attr.h"
#include "flags.h"
#include "reload.h"
#include "tree.h"
#include "output.h"
#include "expr.h"
#include "toplev.h"
#include "obstack.h"
#include "function.h"
#include "recog.h"
#include "tm_p.h"
#include "target.h"
#include "target-def.h"
#include "debug.h"
#include "integrate.h"

static int    scarts32_naked_function_p (tree);
static int    interrupt_function_p (tree);
static int    signal_function_p (tree);
static int    scarts32_regs_to_save (HARD_REG_SET *);
static int    scarts32_num_arg_regs (enum machine_mode, tree);
static int    out_adj_stack_ptr (FILE *, int);
static tree   scarts32_handle_progmem_attribute (tree *, tree, tree, int, bool *);
static tree   scarts32_handle_fndecl_attribute (tree *, tree, tree, int, bool *);
const struct attribute_spec scarts32_attribute_table[];
static void   scarts32_asm_file_start (void);
static void   scarts32_asm_file_end (void);
static void   scarts32_output_function_prologue (FILE *, HOST_WIDE_INT);
static void   scarts32_output_function_epilogue (FILE *, HOST_WIDE_INT);
static void   scarts32_unique_section (tree, int);
static unsigned int scarts32_section_type_flags (tree, const char *, int);

static bool   scarts32_rtx_costs (rtx, int, int, int *);
static void   scarts32_asm_named_section(const char *name, unsigned int flags, tree decl);

static int    ptrreg_to_addr(int);
static rtx    next_cc_user(rtx);

/* Allocate registers from r1 to r4 for parameters for function calls */
#define FIRST_CUM_REG ARG0_REGNO

/* SCARTS32 register names {"r0", "r1", ..., "r15"} */
static const char *const scarts32_regnames[] = REGISTER_NAMES;

/* This holds the last insn address.  */
static int last_insn_address = 0;

/* Commands count in the compiled file */
static int commands_in_file;

/* Commands in the functions prologues in the compiled file */
static int commands_in_prologues;

/* Commands in the functions epilogues in the compiled file */
static int commands_in_epilogues;

/* Prologue/Epilogue size in words */
static int prologue_size;
static int epilogue_size;

/* Preprocessor macros to define depending on MCU type.  */
const char *scarts32_base_arch_macro;
const char *scarts32_extra_arch_macro;

/* Assembler only.  */
int scarts32_asm_only_p = 0;

struct base_arch_s {
  const char *const macro;
};

static const struct base_arch_s scarts32_arch_types[] = {
  { NULL },  /* unknown device specified */
  { "__SCARTS32_ARCH__=1" }
};

struct mcu_type_s {
  const char *const name;
  int arch;  /* index in scarts32_arch_types[] */
  /* Must lie outside user's namespace.  NULL == no macro.  */
  const char *const macro;
};

/* List of all known SCARTS32 MCU types.
   These are all equivalent and are here for completeness only */
static const struct mcu_type_s scarts32_mcu_types[] = {
  { "scarts32",     1, "__SCARTS32_scarts32__" },
  { NULL,        0, NULL }
};

int scarts32_case_values_threshold = (1 << 16);

/* Initialize the GCC target structure.  */
#undef TARGET_ASM_BYTE_OP
#define TARGET_ASM_BYTE_OP "\t.byte\t"
#undef TARGET_ASM_ALIGNED_HI_OP
#define TARGET_ASM_ALIGNED_HI_OP "\t.short\t"
#undef TARGET_ASM_ALIGNED_SI_OP
#define TARGET_ASM_ALIGNED_SI_OP "\t.int\t"
#undef TARGET_ASM_UNALIGNED_HI_OP
#define TARGET_ASM_UNALIGNED_HI_OP TARGET_ASM_ALIGNED_HI_OP
#undef TARGET_ASM_UNALIGNED_SI_OP
#define TARGET_ASM_UNALIGNED_SI_OP TARGET_ASM_ALIGNED_SI_OP

#undef TARGET_ASM_FILE_START
#define TARGET_ASM_FILE_START scarts32_asm_file_start
#undef TARGET_ASM_FILE_START_FILE_DIRECTIVE
#define TARGET_ASM_FILE_START_FILE_DIRECTIVE true
#undef TARGET_ASM_FILE_END
#define TARGET_ASM_FILE_END scarts32_asm_file_end

#undef TARGET_ASM_FUNCTION_PROLOGUE
#define TARGET_ASM_FUNCTION_PROLOGUE scarts32_output_function_prologue
#undef TARGET_ASM_FUNCTION_EPILOGUE
#define TARGET_ASM_FUNCTION_EPILOGUE scarts32_output_function_epilogue
#undef TARGET_ATTRIBUTE_TABLE
#define TARGET_ATTRIBUTE_TABLE scarts32_attribute_table
#undef TARGET_ASM_UNIQUE_SECTION
#define TARGET_ASM_UNIQUE_SECTION scarts32_unique_section
#undef TARGET_SECTION_TYPE_FLAGS
#define TARGET_SECTION_TYPE_FLAGS scarts32_section_type_flags

#undef TARGET_RTX_COSTS
#define TARGET_RTX_COSTS scarts32_rtx_costs

#undef TARGET_ASM_NAMED_SECTION
#define TARGET_ASM_NAMED_SECTION scarts32_asm_named_section

struct gcc_target targetm = TARGET_INITIALIZER;

void
scarts32_override_options (void)
{
  const struct mcu_type_s *t;
  const struct base_arch_s *base;

  for (t = scarts32_mcu_types; t->name; t++)
    if (strcmp (t->name, scarts32_mcu_name) == 0)
      break;

  if (!t->name)
    {
      fprintf (stderr, "unknown MCU `%s' specified\nKnown MCU names:\n",
	       scarts32_mcu_name);
      for (t = scarts32_mcu_types; t->name; t++)
	fprintf (stderr,"   %s\n", t->name);
    }

  base = &scarts32_arch_types[t->arch];
  scarts32_base_arch_macro = base->macro;
  scarts32_extra_arch_macro = t->macro;
}

void
scarts32_optimization_options (int level ATTRIBUTE_UNUSED, int size ATTRIBUTE_UNUSED)
{
}

/*  return register class from register number */

static const int reg_class_tab[]={
  GENERAL_REGS, GENERAL_REGS, GENERAL_REGS, GENERAL_REGS,
  GENERAL_REGS, GENERAL_REGS, GENERAL_REGS, GENERAL_REGS,
  GENERAL_REGS, GENERAL_REGS, GENERAL_REGS, GENERAL_REGS,
  GENERAL_REGS, GENERAL_REGS, GENERAL_REGS, GENERAL_REGS,
  POINTER_REGS, POINTER_REGS, POINTER_REGS, POINTER_REGS, 
  NO_REGS
};

/* Return register class for register R */

enum reg_class
scarts32_regno_reg_class (int r)
{
  if (r >= 0 && r < FIRST_PSEUDO_REGISTER )
    return reg_class_tab[r];
  return ALL_REGS;
}


/* A C expression which defines the machine-dependent operand
   constraint letters for register classes.  If C is such a
   letter, the value should be the register class corresponding to
   it.  Otherwise, the value should be `NO_REGS'.  The register
   letter `r', corresponding to class `GENERAL_REGS', will not be
   passed to this macro; you do not need to handle it.  */

enum reg_class
scarts32_reg_class_from_letter  (int c)
{
  switch (c)
    {
    case 'q' : return POINTER_REGS;
    default: break;
    }
  return NO_REGS;
}

/* Define machine-dependent operand constraint letters (`I', `J', `K',
   ... `P') that specify particular ranges of integer values. */
int
scarts32_const_ok_for_letter(HOST_WIDE_INT value, char c)
{
  switch (c)
    {
    case 'I': /* one bit cleared */
      if (exact_log2 (~value) != -1)
	{
	  return 1;
	}
      break;
    case 'J': /* one bit set */
      if (exact_log2 (value) != -1)
	{
	  return 1;
	}
      break;
    case 'K': /* value for compare immediate */
      if ((value >= -0x40) && (value <= 0x3f))
	{
	  return 1;
	}
      break;
    case 'L': /* loadable */
      if ((value >= -0x80) && (value <= 0x7f))
	{
	  return 1;
	}
      break;
    case 'M': /* 16-bit value */
      if ((value >= -0x8000) && (value <= 0x7fff))
	{
	  return 1;
	}
      break;
    case 'N': /* value for bittests */
      if ((value >= 0) && (value <= 31))
	{
	  return 1;
	}
      break;
    case 'O': /* value for add immediate */
      if ((value >= -0x20) && (value <= 0x1f))
	{
	  return 1;
	}
      break;
    case 'P': /* value for shifts */
      if ((value >= 0) && (value <= 15))
	{
	  return 1;
	}
      break;
    }
  return 0;
}

/* Return nonzero if FUNC is a naked function.  */

static int
scarts32_naked_function_p (tree func)
{
  tree a;

  if (TREE_CODE (func) != FUNCTION_DECL)
    abort ();
  
  a = lookup_attribute ("naked", DECL_ATTRIBUTES (func));
  return a != NULL_TREE;
}

/* Return nonzero if FUNC is an interrupt function as specified
   by the "interrupt" attribute.  */

static int
interrupt_function_p (tree func)
{
  tree a;

  if (TREE_CODE (func) != FUNCTION_DECL)
    return 0;

  a = lookup_attribute ("interrupt", DECL_ATTRIBUTES (func));
  return a != NULL_TREE;
}

/* Return nonzero if FUNC is a signal function as specified
   by the "signal" attribute.  */

static int
signal_function_p (tree func)
{
  tree a;

  if (TREE_CODE (func) != FUNCTION_DECL)
    return 0;

  a = lookup_attribute ("signal", DECL_ATTRIBUTES (func));
  return a != NULL_TREE;
}

/* Return the number of hard registers to push/pop in the prologue/epilogue
   of the current function, and optionally store these registers in SET.  */

static int
scarts32_regs_to_save (HARD_REG_SET *set)
{
  int reg, count;
  int int_or_sig_p = (interrupt_function_p (current_function_decl)
                      || signal_function_p (current_function_decl));
  int leaf_func_p = leaf_function_p ();

  if (set)
    CLEAR_HARD_REG_SET (*set);
  count = 0;

  /* No need to save any registers if the function never returns.  */
  if (TREE_THIS_VOLATILE (current_function_decl))
    return 0;

  for (reg = 0; reg < FIRST_PSEUDO_REGISTER; reg++)
    {
      /* Push frame pointer if necessary. */
      if (frame_pointer_needed && (reg == FRAME_POINTER_REGNUM))
        {
          if (set)
            SET_HARD_REG_BIT (*set, reg);
          count++;
        }

      /* Do not push/pop __tmp_reg__ as well as
         any global register variables.  */
      if (fixed_regs[reg])
        continue;

      /* Push "normal" registers. */
      if ((int_or_sig_p && !leaf_func_p && call_used_regs[reg])
          || (regs_ever_live[reg] && (int_or_sig_p || !call_used_regs[reg])))
        {
          if (set)
            SET_HARD_REG_BIT (*set, reg);
          count++;
        }
    }
  return count;
}

/* Compute offset between arg_pointer, frame_pointer and
   stack_pointer.  */
int
initial_elimination_offset (int from, int to)
{
  int retval = 0;

  if (from == FRAME_POINTER_REGNUM && to == STACK_POINTER_REGNUM)
    {
      retval = get_frame_size();
    }
  else if (from == ARG_POINTER_REGNUM)
    {
      retval = (UNITS_PER_WORD * scarts32_regs_to_save(NULL));
      if (to == STACK_POINTER_REGNUM)
	{
	  retval += get_frame_size();
	}
    }
  else
    abort();

  return retval;
}

/* Return 1 if the function epilogue is just a single "ret".  */
int
scarts32_simple_epilogue (void)
{
  return (! frame_pointer_needed
	  && get_frame_size () == 0
	  && scarts32_regs_to_save (NULL) == 0
	  && ! interrupt_function_p (current_function_decl)
	  && ! signal_function_p (current_function_decl)
	  && ! scarts32_naked_function_p (current_function_decl)
	  && ! MAIN_NAME_P (DECL_NAME (current_function_decl))
	  && ! TREE_THIS_VOLATILE (current_function_decl));
}


/* Return 1 if frame pointer for current function required.  */
int
frame_pointer_required_p (void)
{
  return (current_function_calls_alloca
	  || current_function_args_size > 0
	  || scarts32_regs_to_save(NULL) > 0
  	  || get_frame_size () > 0);
}


/* Output to FILE the asm instructions to adjust the frame pointer by
   ADJ (r26 -= ADJ;) which can be positive (prologue) or negative
   (epilogue).  Returns the number of instructions generated.  */
static int
out_adj_stack_ptr (FILE *file, int adj)
{
  int size = 0;

  adj = -adj;

  if (adj != 0)
    {
      if (adj <= 15 && adj >= -16)
	{
	  fprintf (file, "\tldli r7, %d\n", ptrreg_to_addr(STACK_POINTER_REGNUM));
	  fprintf (file, "\tldw r13, r7\n");
	  fprintf (file, "\taddi r13, %d\n", adj);
	  fprintf (file, "\tstw r13, r7\n");
	  size += 4;
	}
      else if (adj <= 127 && adj >= -128)
	{
	  fprintf (file, "\tldli r7, %d\n", ptrreg_to_addr(STACK_POINTER_REGNUM));
	  fprintf (file, "\tldw r13, r7\n");
	  fprintf (file, "\tldli r6, %d\n", adj);
	  fprintf (file, "\tadd r13, r6\n");
	  fprintf (file, "\tstw r13, r7\n");
	  size += 5;
	}
      else if (adj <= 0x7fff && adj >= -0x8000)
	{
	  fprintf (file, "\tldli r7, %d\n", ptrreg_to_addr(STACK_POINTER_REGNUM));
	  fprintf (file, "\tldw r13, r7\n");
	  fprintf (file, "\tldli r6, %d\n", (int8_t)(adj & 0xFF));
	  fprintf (file, "\tldhi r6, %d\n", (int8_t)((adj >> 8) & 0xFF));
	  fprintf (file, "\tadd r13, r6\n");
	  fprintf (file, "\tstw r13, r7\n");
	  size += 6;
	}
      else
	{
	  fprintf (file, "\tldli r7, %d\n", ptrreg_to_addr(STACK_POINTER_REGNUM));
	  fprintf (file, "\tldw r13, r7\n");
	  fprintf (file, "\tldhi r6, %d\n ", (int8_t)((adj >> 24) & 0xFF));
	  fprintf (file, "\tldliu r6, %u\n", (adj >> 16) & 0xFF);
	  fprintf (file, "\tsli r6, 8\n");
	  fprintf (file, "\tldliu r6, %u\n", (adj >> 8) & 0xFF);
	  fprintf (file, "\tsli r6, 8\n");
	  fprintf (file, "\tldliu r6, %u\n", (adj >> 0) & 0xFF);
	  fprintf (file, "\tadd r13, r6\n");
	  fprintf (file, "\tstw r13, r7\n");
	  size += 10;
	}
    }
  return size;
}

/* Output function prologue */

static void
scarts32_output_function_prologue (FILE *file, HOST_WIDE_INT size)
{
  char *l;
  int   reg;
  int   interrupt_func_p, signal_func_p, main_p;
  HARD_REG_SET  set;
  HOST_WIDE_INT cfa_offset;

  cfa_offset = INCOMING_FRAME_SP_OFFSET;
  last_insn_address = prologue_size = 0;

  fprintf (file, "\t; prologue: stack frame size=%ld\n", size);

  if (scarts32_naked_function_p (current_function_decl))
  {
    fprintf(file, "\t; prologue: naked\n");
    goto out;
  }

  interrupt_func_p = interrupt_function_p (current_function_decl);
  signal_func_p = signal_function_p (current_function_decl);
  main_p = MAIN_NAME_P (DECL_NAME (current_function_decl));

  if (interrupt_func_p || signal_func_p)
  {
    /* Push r7 on the stack. */
    fprintf (file, "\tstfpz_dec r7, -1\n");
    prologue_size += 1;

    if (dwarf2out_do_frame ())
    {
      cfa_offset += (1 * UNITS_PER_WORD);

      l = (char *) dwarf2out_cfi_label ();
      dwarf2out_def_cfa (l, STACK_POINTER_REGNUM, cfa_offset);
      dwarf2out_reg_save (l, 7, -cfa_offset);
    }

    /* Push r13 on the stack. */
    fprintf (file, "\tstfpz_dec r13, -1\n");
    prologue_size += 1;

    if (dwarf2out_do_frame ())
    {
      cfa_offset += (1 * UNITS_PER_WORD);

      l = (char *) dwarf2out_cfi_label ();
      dwarf2out_def_cfa (l, STACK_POINTER_REGNUM, cfa_offset);
      dwarf2out_reg_save (l, 13, -cfa_offset);
    }
  }

  if (interrupt_func_p)
  {
    /* Push r15 on the stack. */
    fprintf(file, "\tstfpz_dec r15, -1\n");
    prologue_size += 1;

    if (dwarf2out_do_frame ())
    {
      cfa_offset += (1 * UNITS_PER_WORD);

      l = (char *) dwarf2out_cfi_label ();
      dwarf2out_def_cfa (l, STACK_POINTER_REGNUM, cfa_offset);
      dwarf2out_reg_save (l, 15, -cfa_offset);
    }

    /* Push the saved custom status byte on the stack. */
    fprintf (file, "\tldli r7, -8\n");
    fprintf (file, "\tldbu r13, r7\n");
    fprintf (file, "\tstfpz_dec r13, -1\n");
    prologue_size += 3;

    if (dwarf2out_do_frame ())
    {
      cfa_offset += (1 * UNITS_PER_WORD);

      l = (char *) dwarf2out_cfi_label ();
      dwarf2out_def_cfa (l, STACK_POINTER_REGNUM, cfa_offset);
      dwarf2out_reg_save (l, 13, -cfa_offset);
    }

    /* Set the GIE flag in the custom config byte. */
    fprintf (file, "\tldli r7, -29\n");
    fprintf (file, "\tldbu r13, r7\n");
    fprintf (file, "\tbset r13, 7\n");
    fprintf (file, "\tstb r13, r7\n");
    prologue_size += 4;
  }

  scarts32_regs_to_save (&set);
  for (reg = 0; reg < FIRST_PSEUDO_REGISTER; ++reg)
  {
    if (TEST_HARD_REG_BIT (set, reg))
    {
      if (scarts32_regno_reg_class (reg) == POINTER_REGS)
      {
        /* Push FP-register on the stack. */
        fprintf (file, "\tldli r7, %d\n", ptrreg_to_addr (reg));
        fprintf (file, "\tldw r13, r7\n");
        fprintf (file, "\tstfpz_dec r13, -1\n");
        prologue_size += 3;

        if (dwarf2out_do_frame ())
        {
          cfa_offset += (1 * UNITS_PER_WORD);

          l = (char *) dwarf2out_cfi_label ();
          dwarf2out_def_cfa (l, STACK_POINTER_REGNUM, cfa_offset);
          dwarf2out_reg_save (l, reg, -cfa_offset);
        }
      }
      else
      {
        /* Push 'normal' register on the stack. */
        fprintf(file, "\tstfpz_dec %s, -1\n", scarts32_regnames[reg]);
        prologue_size += 1;

        if (dwarf2out_do_frame ())
        {
          cfa_offset += (1 * UNITS_PER_WORD);

          l = (char *) dwarf2out_cfi_label ();
          dwarf2out_def_cfa (l, STACK_POINTER_REGNUM, cfa_offset);

          if (reg == RA_REGNO)
            dwarf2out_return_save (l, -cfa_offset);
          else
            dwarf2out_reg_save (l, reg, -cfa_offset);
        }
      }
    }
  }

  if (frame_pointer_needed)
  {
    /* Replace FP with current SP. */
    fprintf (file, "\tldli r7, %d\n", ptrreg_to_addr (STACK_POINTER_REGNUM));
    fprintf (file, "\tldw r13, r7\n");
    fprintf (file, "\tldli r7, %d\n", ptrreg_to_addr (FRAME_POINTER_REGNUM));
    fprintf (file, "\tstw r13, r7\n");
    prologue_size += 4;

    if (size != 0)
    {
      /* Move SP down to make room for local variables and callee saved registers. */
      prologue_size += out_adj_stack_ptr (file, size);

      if (dwarf2out_do_frame ())
      {
        cfa_offset += size;

        l = (char *) dwarf2out_cfi_label ();
        dwarf2out_def_cfa (l, STACK_POINTER_REGNUM, cfa_offset);
      }
    }
  }

  out:
    fprintf (file, "\t; prologue end (size=%d)\n", prologue_size);
}

/* Output function epilogue */

static void
scarts32_output_function_epilogue (FILE *file, HOST_WIDE_INT size)
{
  int function_size, reg;
  int interrupt_func_p, signal_func_p, main_p;
  rtx first, last;
  HARD_REG_SET set;

  function_size = 0;
  interrupt_func_p = interrupt_function_p (current_function_decl);
  signal_func_p = signal_function_p (current_function_decl);
  main_p = MAIN_NAME_P (DECL_NAME (current_function_decl));
  last = get_last_nonnote_insn ();

  epilogue_size = 0;

  if (last)
  {
    first = get_first_nonnote_insn ();
    function_size += (INSN_ADDRESSES (INSN_UID (last)) - INSN_ADDRESSES (INSN_UID (first)));
    function_size += get_attr_length (last);
  }

  fprintf (file, "\t; epilogue: stack frame size=%ld\n", size);

  if (scarts32_naked_function_p (current_function_decl))
  {
    fprintf (file, "\t; epilogue: naked\n");
    goto out;
  }

  if (last && GET_CODE (last) == BARRIER)
  {
    fprintf (file, "\t; epilogue: noreturn\n");
    goto out;
  }

  scarts32_regs_to_save (&set);
  if (frame_pointer_needed)
  {
    if (size != 0)
    {
      epilogue_size += out_adj_stack_ptr (file, -size);
    }
  }

  for (reg = FIRST_PSEUDO_REGISTER-1; reg >= 0; --reg)
  {
    if (TEST_HARD_REG_BIT (set, reg))
    {
      if (scarts32_regno_reg_class(reg) == POINTER_REGS)
      {
        fprintf (file, "\tldli r7, %d\n", ptrreg_to_addr(reg));
        fprintf (file, "\tldfpz_inc r13, 0\n");
        fprintf (file, "\tstw r13, r7\n");
        epilogue_size += 3;
      }
      else
      {
        fprintf (file, "\tldfpz_inc %s, 0\n", scarts32_regnames[reg]);
        epilogue_size += 1;
      }
    }
  }

  if (interrupt_func_p)
  {
    /* Restore the saved custom status byte from the stack. */
    fprintf (file, "\tldli r7, -8\n");
    fprintf (file, "\tldfpz_inc r13, 0\n");
    fprintf (file, "\tstb r13, r7\n");

    fprintf (file, "\tldfpz_inc r15, 0\n");
    epilogue_size += 4;
    
  }

  if (interrupt_func_p || signal_func_p)
  {
    fprintf (file, "\tldfpz_inc r13, 0\n");
    fprintf (file, "\tldfpz_inc r7, 0\n");
    fprintf (file, "\trte\n");
    epilogue_size += 3;
  }
  else
  {
    fprintf (file, "\trts\n");
    epilogue_size += 1;
  }

  out:
    fprintf (file, "\t;epilogue end (size=%d)\n", epilogue_size);
    fprintf (file, "\t;function %s size %d (%d)\n",
      (* targetm.strip_name_encoding) (IDENTIFIER_POINTER (DECL_ASSEMBLER_NAME (current_function_decl))),
      prologue_size + function_size + epilogue_size, function_size);

    commands_in_file += prologue_size + function_size + epilogue_size;
    commands_in_prologues += prologue_size;
    commands_in_epilogues += epilogue_size;
}


/* Return nonzero if X (an RTX) is a legitimate memory address on the target
   machine for a memory operand of mode MODE.  */

int
legitimate_address_p (enum machine_mode mode, rtx x, int strict)
{
  enum reg_class r = NO_REGS;
  
  if (TARGET_ALL_DEBUG)
    {
      fprintf (stderr, "mode: (%s) %s %s %s %s:",
	       GET_MODE_NAME(mode),
	       strict ? "(strict)": "",
	       reload_completed ? "(reload_completed)": "",
	       reload_in_progress ? "(reload_in_progress)": "",
	       reg_renumber ? "(reg_renumber)" : "");
      if (GET_CODE (x) == PLUS
	  && REG_P (XEXP (x, 0))
	  && GET_CODE (XEXP (x, 1)) == CONST_INT
	  && INTVAL (XEXP (x, 1)) >= (-16*UNITS_PER_WORD)
	  && INTVAL (XEXP (x, 1)) <= (15*UNITS_PER_WORD)
	  && reg_renumber
	  )
	fprintf (stderr, "(r%d ---> r%d)", REGNO (XEXP (x, 0)),
		 true_regnum (XEXP (x, 0)));
      debug_rtx (x);
    }

  if (REG_P (x))
    {
      r = ALL_REGS;
      if (strict && (REGNO (x) >= FIRST_PSEUDO_REGISTER))
	{
	  r = NO_REGS;
	}
    }
  else if (mode == SImode
	   && GET_CODE (x) == PLUS
           && REG_P (XEXP (x, 0))
	   && GET_CODE (XEXP (x, 1)) == CONST_INT)
    {
      if ((INTVAL (XEXP (x, 1)) >= (-16*UNITS_PER_WORD))
	  && (INTVAL (XEXP (x, 1)) <= (15*UNITS_PER_WORD))
	  && ((INTVAL (XEXP (x, 1)) % UNITS_PER_WORD) == 0)
	  && ((REGNO (XEXP (x, 0)) == PTR_W)
	      || (REGNO (XEXP (x, 0)) == PTR_X)
	      || (REGNO (XEXP (x, 0)) == PTR_Y)
	      || (REGNO (XEXP (x, 0)) == PTR_Z)))
	{
	  r = POINTER_REGS;
	}
    }
 
  if (TARGET_ALL_DEBUG)
    {
      fprintf (stderr, "   ret = %d\n", r);
    }
  return r == NO_REGS ? 0 : (int)r;
}

/* Output X as assembler operand to file FILE */
void
print_operand (FILE *file, rtx x, int code)
{
  int abcd = 0;
  int signbit = 0;

  if (code >= 'A' && code <= 'B')
    abcd = code - 'A';

  if (code == 's')
    signbit = 1;

  if (REG_P (x))
    {
      fprintf (file, "%s", reg_names[true_regnum (x) + abcd]);
    }
  else if ((GET_CODE (x) == CONST_INT)
	   || ((GET_CODE (x) == CONST_DOUBLE)
	       && (GET_MODE (x) == VOIDmode)))
    {
      if (code == 't')
	{
	  fprintf (file, "%d", (int8_t)((INTVAL (x) >> 0) & 0xFF));
	}
      else if (code == 'u')
	{
	  fprintf (file, "%d", (int8_t)((INTVAL (x) >> 8) & 0xFF));
	}
      else if (code == 'v')
	{
	  fprintf (file, "%d", (int8_t)((INTVAL (x) >> 16) & 0xFF));
	}
      else if (code == 'w')
	{
	  fprintf (file, "%d", (int8_t)((INTVAL (x) >> 24) & 0xFF));
	}
      else if ((code == 'T') || (code == 'U') || (code == 'V') || (code == 'W'))
	{
	  if (GET_CODE(x) == CONST_INT)
	    {
              /* MWA: the code below creates the 64-bit target datatypes
                 on a 64-bit host machine.
                 FIXME: the higher 4 bytes of double data types also get
                 created by this code, which probably is not correct. */
	      if (code == 'T')
	        {
	          fprintf (file, "%d", (int8_t)((INTVAL (x) >> 32) & 0xFF));
	        }
	      else if (code == 'U')
	        {
	          fprintf (file, "%d", (int8_t)((INTVAL (x) >> 40) & 0xFF));
	        }
	      else if (code == 'V')
	        {
	          fprintf (file, "%d", (int8_t)((INTVAL (x) >> 48) & 0xFF));
	        }
	      else if (code == 'W')
	        {
	          fprintf (file, "%d", (int8_t)((INTVAL (x) >> 56) & 0xFF));
	        }
	      else
	        {
	          fprintf (file, "%d", INTVAL(x) >= 0 ? 0 : -1);
	        }
	    }
	  else
	    {
	      if (code == 'T')
	        {
	          fprintf (file, "%d", (int8_t)((CONST_DOUBLE_HIGH (x) >> 0) & 0xFF));
	        }
	      else if (code == 'U')
	        {
	          fprintf (file, "%d", (int8_t)((CONST_DOUBLE_HIGH (x) >> 8) & 0xFF));
	        }
	      else if (code == 'V')
	        {
	          fprintf (file, "%d", (int8_t)((CONST_DOUBLE_HIGH (x) >> 16) & 0xFF));
	        }
	      else if (code == 'W')
	        {
	          fprintf (file, "%d", (int8_t)((CONST_DOUBLE_HIGH (x) >> 24) & 0xFF));
	        }
	    }
	}
      else
	{
	  if (signbit)
	    {
	      fprintf (file, "%d", INTVAL(x) >= 0 ? 0 : -1);
	    }
	  else
	    {
	      fprintf (file, "%d", (int)(INTVAL (x) + abcd));
	    }
	}
    }
  else if (GET_CODE (x) == MEM)
    {
      rtx addr = XEXP (x,0);
      output_address (addr);
    }
  else if (GET_CODE (x) == CONST_DOUBLE)
    {
      long val [2];
      REAL_VALUE_TYPE rv;

      REAL_VALUE_FROM_CONST_DOUBLE (rv, x);
      if (GET_MODE (x) == SFmode)
        {
          REAL_VALUE_TO_TARGET_SINGLE (rv, val[0]);
        }
      else
        {
          REAL_VALUE_TO_TARGET_DOUBLE (rv, val);
        }

      if (code == 't')
        {
          fprintf (file, "%d", (int8_t)((val[0] >> 0) & 0xFF));
        }
      else if (code == 'u')
        {
          fprintf (file, "%d", (int8_t)((val[0] >> 8) & 0xFF));
        }
      else if (code == 'v')
        {
          fprintf (file, "%d", (int8_t)((val[0] >> 16) & 0xFF));
        }
      else if (code == 'w')
        {
          fprintf (file, "%d", (int8_t)((val[0] >> 24) & 0xFF));
        }
      else if (code == 'T')
        {
          fprintf (file, "%d", (int8_t)((val[1] >> 0) & 0xFF));
        }
      else if (code == 'U')
        {
          fprintf (file, "%d", (int8_t)((val[1] >> 8) & 0xFF));
        }
      else if (code == 'V')
        {
          fprintf (file, "%d", (int8_t)((val[1] >> 16) & 0xFF));
        }
      else if (code == 'W')
        {
          fprintf (file, "%d", (int8_t)((val[1] >> 24) & 0xFF));
        }
      else
        {
          fatal_insn ("internal compiler error. Invalid constant for output:", x);
        }
    }
  else
    {
      if (code == 'S')
	{
	  if (GET_CODE (x) == SYMBOL_REF
	      || GET_CODE (x) == LABEL_REF)
	    {
	      output_addr_const (file, x);
	    }
	  else if ((GET_CODE (x) == CONST)
		   && (GET_CODE (XEXP (x, 0)) == PLUS)
		   && (GET_CODE (XEXP (XEXP (x, 0), 0)) == SYMBOL_REF))
	    {
	      output_addr_const (file, XEXP (XEXP (x, 0), 0));
	    }
	}
      else
	{
	  output_addr_const (file, x);
	}
    }
}

/* Recognize operand OP of mode MODE used in call instructions */
int
call_insn_operand (rtx op, enum machine_mode mode ATTRIBUTE_UNUSED)
{
  if (GET_CODE (op) == MEM)
    {
      rtx inside = XEXP (op, 0);

      if (register_operand (inside, Pmode))
        return 1;
      if (CONSTANT_ADDRESS_P (inside))
        return 1;
    }
  return 0;
}

/* Choose mode for jump insn:
   SCARTS32_NEAR_JUMP - relative jump in range -256 <= x <= 511
   SCARTS32_FAR_JUMP - relative jump outside of near range */
int
scarts32_jump_mode (rtx x, rtx insn)
{
  int dest_addr = INSN_ADDRESSES (INSN_UID (GET_MODE (x) == LABEL_REF
					    ? XEXP (x, 0) : x));
  int cur_addr = INSN_ADDRESSES (INSN_UID (insn));
  int jump_distance = dest_addr - cur_addr;

  if ((jump_distance >= -256) && (jump_distance <= 511))
    return SCARTS32_NEAR_JUMP;
  
  return SCARTS32_FAR_JUMP;
}

/* Output all insn addresses and their sizes into the assembly language
   output file.  This is helpful for debugging whether the length attributes
   in the md file are correct.
   Output insn cost for next insn.  */

void
final_prescan_insn (rtx insn, rtx *operand ATTRIBUTE_UNUSED, int num_operands ATTRIBUTE_UNUSED)
{
  int uid = INSN_UID (insn);

  if (TARGET_INSN_SIZE_DUMP || TARGET_ALL_DEBUG)
    {
      fprintf (asm_out_file, "\t; DEBUG: 0x%x\t\t%d\t%d\n",
	       INSN_ADDRESSES (uid),
               INSN_ADDRESSES (uid) - last_insn_address,
	       rtx_cost (PATTERN (insn), INSN));
    }
  last_insn_address = INSN_ADDRESSES (uid);

  if (TARGET_RTL_DUMP)
    {
      fprintf (asm_out_file, "#################\n");
      print_rtl_single (asm_out_file, insn);
      fprintf (asm_out_file, "#################\n");
    }
}

/* Returns nonzero if REGNO is the number of a hard
   register in which function arguments are sometimes passed.  */
int
function_arg_regno_p(int r)
{
 /* argument passing is done in the registers r1 to r4 */
  return (r >= FIRST_CUM_REG && r < (FIRST_CUM_REG+4));
}

/* Initializing the variable cum for the state at the beginning
   of the argument list.  */

void
init_cumulative_args (CUMULATIVE_ARGS *cum, tree fntype, rtx libname, tree fndecl ATTRIBUTE_UNUSED)
{
  cum->nregs = 4; /* four registers are available for argument passing */
  cum->regno = FIRST_CUM_REG;
  if (!libname && fntype)
    {
      int stdarg = (TYPE_ARG_TYPES (fntype) != 0
                    && (TREE_VALUE (tree_last (TYPE_ARG_TYPES (fntype)))
                        != void_type_node));
      if (stdarg)
        cum->nregs = 0;
    }
}

/* Returns the number of registers to allocate for a function argument.  */

static int
scarts32_num_arg_regs (enum machine_mode mode, tree type)
{
  int size;

  if (mode == BLKmode)
    size = ((int_size_in_bytes (type) + UNITS_PER_WORD - 1) / UNITS_PER_WORD);
  else
    size = ((GET_MODE_SIZE (mode) + UNITS_PER_WORD - 1) / UNITS_PER_WORD);

  return size;
}

/* Controls whether a function argument is passed
   in a register, and which register. */

rtx
function_arg (CUMULATIVE_ARGS *cum, enum machine_mode mode, tree type, int named ATTRIBUTE_UNUSED)
{
  int regs = scarts32_num_arg_regs (mode, type);

  if ((cum->nregs > 0)
      && (regs <= cum->nregs)
      && (mode != BLKmode))
    {
      return gen_rtx_REG (mode, cum->regno);
    }

  return NULL_RTX;
}

/* Update the summarizer variable CUM to advance past an argument
   in the argument list.  */
   
void
function_arg_advance (CUMULATIVE_ARGS *cum, enum machine_mode mode, tree type, int named ATTRIBUTE_UNUSED)
{
  int regs = scarts32_num_arg_regs (mode, type);

  cum->nregs -= regs;
  cum->regno += regs;

  if (cum->nregs <= 0)
    {
      cum->nregs = 0;
      cum->regno = FIRST_CUM_REG;
    }
}

/* Modifies the length assigned to instruction INSN
   LEN is the initially computed length of the insn.  */

int
adjust_insn_length (rtx insn ATTRIBUTE_UNUSED, int len)
{
  return len;
}

/* Sets section name for declaration DECL */
  
static void
scarts32_unique_section (tree decl, int reloc ATTRIBUTE_UNUSED)
{
  int len;
  const char *name, *prefix;
  char *string;

  name = IDENTIFIER_POINTER (DECL_ASSEMBLER_NAME (decl));
  name = (* targetm.strip_name_encoding) (name);

  if (TREE_CODE (decl) == FUNCTION_DECL)
    {
      prefix = "__text.";
    }
  else if (TREE_PUBLIC (decl))
    {
      prefix = "";
    }
  else
    {
      prefix = "__data.";
    }

  len = strlen (name) + strlen (prefix);
  string = alloca (len + 1);
  sprintf (string, "%s%s", prefix, name);
  DECL_SECTION_NAME (decl) = build_string (len, string);
}

/* Valid attributes:
   progmem - put data to program memory;
   signal - make a function to be hardware interrupt. After function
   prologue interrupts are disabled;
   interrupt - make a function to be hardware interrupt. After function
   prologue interrupts are enabled;
   naked     - don't generate function prologue/epilogue and `ret' command.

   Only `progmem' attribute valid for type.  */

const struct attribute_spec scarts32_attribute_table[] =
  {
    /* { name, min_len, max_len, decl_req, type_req, fn_type_req, handler } */
    { "progmem",   0, 0, false, false, false,  scarts32_handle_progmem_attribute },
    { "signal",    0, 0, true,  false, false,  scarts32_handle_fndecl_attribute },
    { "interrupt", 0, 0, true,  false, false,  scarts32_handle_fndecl_attribute },
    { "naked",     0, 0, true,  false, false,  scarts32_handle_fndecl_attribute },
    { NULL,        0, 0, false, false, false, NULL }
  };

/* Handle a "progmem" attribute; arguments as in
   struct attribute_spec.handler.  */
static tree
scarts32_handle_progmem_attribute (tree *node, tree name, tree args ATTRIBUTE_UNUSED, int flags ATTRIBUTE_UNUSED, bool *no_add_attrs)
{
  if (DECL_P (*node))
    {
      if (TREE_CODE (*node) == TYPE_DECL)
	{
	  /* This is really a decl attribute, not a type attribute,
	     but try to handle it for GCC 3.0 backwards compatibility.  */

	  tree type = TREE_TYPE (*node);
	  tree attr = tree_cons (name, args, TYPE_ATTRIBUTES (type));
	  tree newtype = build_type_attribute_variant (type, attr);

	  TYPE_MAIN_VARIANT (newtype) = TYPE_MAIN_VARIANT (type);
	  TREE_TYPE (*node) = newtype;
	  *no_add_attrs = true;
	}
      else if (TREE_STATIC (*node) || DECL_EXTERNAL (*node))
	{
	  if (DECL_INITIAL (*node) == NULL_TREE && !DECL_EXTERNAL (*node))
	    {
	      warning (0, "only initialized variables can be placed into program memory area");
	      *no_add_attrs = true;
	    }
	}
      else
	{
	  warning (0, "`%s' attribute ignored", IDENTIFIER_POINTER (name));
	  *no_add_attrs = true;
	}
    }

  return NULL_TREE;
}

/* Handle an attribute requiring a FUNCTION_DECL; arguments as in
   struct attribute_spec.handler.  */
static tree
scarts32_handle_fndecl_attribute (tree *node, tree name, tree args ATTRIBUTE_UNUSED, int flags ATTRIBUTE_UNUSED, bool *no_add_attrs)
{
  if (TREE_CODE (*node) != FUNCTION_DECL)
    {
      warning (0, "`%s' attribute only applies to functions",
	       IDENTIFIER_POINTER (name));
      *no_add_attrs = true;
    }

  return NULL_TREE;
}

/* Look for attribute `progmem' in DECL
   if found return 1, otherwise 0.  */

int
scarts32_progmem_p (tree decl)
{
  tree a;

  if (TREE_CODE (decl) != VAR_DECL)
    return 0;

  if (NULL_TREE
      != lookup_attribute ("progmem", DECL_ATTRIBUTES (decl)))
    return 1;

  a=decl;
  do
    a = TREE_TYPE(a);
  while (TREE_CODE (a) == ARRAY_TYPE);

  if (a == error_mark_node)
    return 0;

  if (NULL_TREE != lookup_attribute ("progmem", TYPE_ATTRIBUTES (a)))
    return 1;
  
  return 0;
}

static unsigned int
scarts32_section_type_flags (tree decl, const char *name, int reloc)
{
  unsigned int flags = default_section_type_flags (decl, name, reloc);

  if (strncmp (name, ".noinit", 7) == 0)
    {
      if (decl && TREE_CODE (decl) == VAR_DECL
	  && DECL_INITIAL (decl) == NULL_TREE)
	flags |= SECTION_BSS;  /* @nobits */
      else
	warning (0, "only uninitialized variables can be placed in the .noinit section");
    }

  return flags;
}

/* Outputs to the stdio stream FILE some
   appropriate text to go at the start of an assembler file.  */

void
scarts32_asm_file_start (void)
{
  fprintf (asm_out_file, "\t.file\t");
  output_quoted_string (asm_out_file, main_input_filename);
  fprintf (asm_out_file, "\n");

  commands_in_file = 0;
  commands_in_prologues = 0;
  commands_in_epilogues = 0;
}

/* Outputs to the stdio stream FILE some
   appropriate text to go at the end of an assembler file.  */

void
scarts32_asm_file_end (void)
{
  if (flag_verbose_asm)
    {
      fprintf (asm_out_file, "\t; file ");
      output_quoted_string (asm_out_file, main_input_filename);
      fprintf (asm_out_file,
	       ": code %4d = 0x%04x (%4d), prologues %3d, epilogues %3d\n",
	       commands_in_file,
	       commands_in_file,
	       commands_in_file - commands_in_prologues - commands_in_epilogues,
	       commands_in_prologues, commands_in_epilogues);
    }
}

static bool
scarts32_rtx_costs (rtx x, int code, int outer_code, int *total)
{
  bool retval = false;

  switch (code)
    {
    case MEM:
      *total = 2 + GET_MODE_SIZE (GET_MODE (x));
      break;

    case CONST_DOUBLE:
      if (GET_MODE (x) != VOIDmode)
	{
	  *total = 6 * (1 + GET_MODE_SIZE (GET_MODE (x)));
	  retval = true;
	  break;
	}
      else
	{
	  /* fall through */
	}
    case CONST_INT:
      if (outer_code == AND
	  && scarts32_const_ok_for_letter(INTVAL (x), 'I'))
	*total = 0;
      else if (outer_code == IOR
	       && scarts32_const_ok_for_letter(INTVAL (x), 'J'))
	*total = 0;
      else if (INTVAL (x) <= 15 && INTVAL (x) >= -16)
	*total = 0;
      else
	*total = 6 * (1 + GET_MODE_SIZE (GET_MODE (x)));
      retval = true;
      break;

    case CONST:
    case LABEL_REF:
    case SYMBOL_REF:
      *total = 6 * (1 + GET_MODE_SIZE (GET_MODE (x)));
      retval = true;
      break;

    case SUBREG:
    case REG:
      *total = 0;
      retval = true;
      break;

    case MINUS:
    case PLUS:
      if (outer_code == MEM)
	*total = 1;
      else
	*total = 1 + GET_MODE_SIZE (GET_MODE (x));
      break;

    case MULT:
      *total = 10 * (1 + GET_MODE_SIZE (GET_MODE (x)));
      break;

    case DIV:
    case UDIV:
      *total = 30 * (1 + GET_MODE_SIZE (GET_MODE (x)));
      break;

    case MOD:
    case UMOD:
      *total = 35 * (1 + GET_MODE_SIZE (GET_MODE (x)));
      break;

    default:
      *total = 1 + GET_MODE_SIZE (GET_MODE (x));
      break;
    }

  *total *= COSTS_N_INSNS(1);

  return retval;
}

/*  EXTRA_CONSTRAINT helper */
int
extra_constraint (rtx x ATTRIBUTE_UNUSED, int c ATTRIBUTE_UNUSED)
{
  return 0;
}

/* Ceate an RTX representing the place where a
   library function returns a value of mode MODE.  */

rtx
scarts32_libcall_value (enum machine_mode mode)
{
  int offs = GET_MODE_SIZE (mode);
  if (offs <= UNITS_PER_WORD)
    return gen_rtx_REG (mode, RET_REGISTER);
  else
    return gen_rtx_REG (mode, -1);
}

/* Create an RTX representing the place where a
   function returns a value of data type VALTYPE.  */

rtx
scarts32_function_value (tree type, tree func ATTRIBUTE_UNUSED)
{
  if (TYPE_MODE (type) != BLKmode)
    return scarts32_libcall_value (TYPE_MODE (type));
  
  return gen_rtx_REG (BLKmode, -1);
}

int
test_hard_reg_class (enum reg_class class, rtx x)
{
  int regno = true_regnum (x);

  if (regno < 0)
    return 0;

  if (TEST_HARD_REG_CLASS (class, regno))
    return 1;

  return 0;
}

const char *
scarts32_out_movqi (rtx insn ATTRIBUTE_UNUSED, rtx operands [], int alternative)
{
  switch (alternative)
    {
    case 0:
      output_asm_insn ("mov %0,%1", operands);
      break;
    case 1:
      output_asm_insn ("ldli %0,%1", operands);
      break;
    case 2:
      {
	/* operands: src, dest [, offset] */
	rtx x = XEXP (operands[0], 0);
        if (REG_P (x))
	  {
	    if (scarts32_regno_reg_class(true_regnum(x)) == POINTER_REGS)
	      {
		operands[0] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(x)));
		output_asm_insn ("ldli r13, %0", operands);
		output_asm_insn ("ldw r13, r13", operands);
		output_asm_insn ("stb %1,r13", operands);
	      }
	    else
	      {
		output_asm_insn ("stb %1,%0", operands);
	      }
	  }
	else
	  {
	    fatal_insn ("internal compiler error. Invalid memory insn:",
			operands[0]);
	  }
      }
      break;
    case 3:
      {
	/* operands: dest, src [, offset] */
	rtx x = XEXP (operands[1], 0);
	if (REG_P (x))
	  {
	    if (scarts32_regno_reg_class(true_regnum(x)) == POINTER_REGS)
	      {
		operands[1] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(x)));
		output_asm_insn ("ldli r13, %1", operands);
		output_asm_insn ("ldw r13, r13", operands);
		output_asm_insn ("ldbu %0,r13", operands);
	      }
	    else
	      {
		output_asm_insn ("ldbu %0,%1", operands);
	      }
	  }
	else
	  {
	    fatal_insn ("internal compiler error. Invalid memory insn:",
			operands[1]);
	  }
      }
      break;
    default:
      gcc_unreachable();
    }
  return "";
}

const char *
scarts32_out_movhi (rtx insn ATTRIBUTE_UNUSED, rtx operands [], int alternative)
{
  switch (alternative)
    {
    case 0:
      output_asm_insn ("mov %0,%1", operands);
      break;
    case 1:
      output_asm_insn ("ldli %0,%1", operands);
      break;
    case 2:
      output_asm_insn ("ldli %0,%t1", operands);
      output_asm_insn ("ldhi %0,%u1", operands);
      break;
    case 3:
      {
	/* operands: src, dest [, offset] */
	rtx x = XEXP (operands[0], 0);
        if (REG_P (x))
	  {
	    if (scarts32_regno_reg_class(true_regnum(x)) == POINTER_REGS)
	      {
		operands[0] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(x)));
		output_asm_insn ("ldli r13, %0", operands);
		output_asm_insn ("ldw r13, r13", operands);
		output_asm_insn ("sth %1,r13", operands);
	      }
	    else
	      {
		output_asm_insn ("sth %1,%0", operands);
	      }
	  }
	else
	  {
	    fatal_insn ("internal compiler error. Invalid memory insn:",
			operands[0]);
	  }
      }
      break;
    case 4:
      {
	/* operands: dest, src [, offset] */
	rtx x = XEXP (operands[1], 0);
	if (REG_P (x))
	  {
	    if (scarts32_regno_reg_class(true_regnum(x)) == POINTER_REGS)
	      {
		operands[1] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(x)));
		output_asm_insn ("ldli r13, %1", operands);
		output_asm_insn ("ldw r13, r13", operands);
		output_asm_insn ("ldhu %0,r13", operands);
	      }
	    else
	      {
		output_asm_insn ("ldhu %0,%1", operands);
	      }
	  }
	else
	  {
	    fatal_insn ("internal compiler error. Invalid memory insn:",
			operands[1]);
	  }
      }
      break;
    default:
      gcc_unreachable();
    }
  return "";
}

const char *
scarts32_out_movsi (rtx insn ATTRIBUTE_UNUSED, rtx operands [], int alternative)
{
  switch (alternative)
    {
    case 0:
      output_asm_insn ("mov %0,%1", operands);
      break;
    case 1:
      output_asm_insn ("ldli %0,%1", operands);
      break;
    case 2:
      output_asm_insn ("ldli %0,%t1", operands);
      output_asm_insn ("ldhi %0,%u1", operands);
      break;
    case 3:
      output_asm_insn ("ldhi  %0,%w1", operands);
      output_asm_insn ("ldliu %0,%v1", operands);
      output_asm_insn ("sli   %0,8", operands);
      output_asm_insn ("ldliu %0,%u1", operands);
      output_asm_insn ("sli   %0,8", operands);
      output_asm_insn ("ldliu %0,%t1", operands);
      break;
    case 4:
      output_asm_insn ("ldhi  %0,4th(%1)", operands);
      output_asm_insn ("ldliu %0,3rd(%1)", operands);
      output_asm_insn ("sli   %0,8", operands);
      output_asm_insn ("ldliu %0,hi(%1)", operands);
      output_asm_insn ("sli   %0,8", operands);
      output_asm_insn ("ldliu %0,lo(%1)", operands);
      break;
    case 5:
      {
	/* operands: src, dest [, offset] */
	rtx x = XEXP (operands[0], 0);
	if (GET_CODE (x) == PLUS)
	  {
	    operands[0] = (XEXP (x, 0));
	    operands[2] = (XEXP (x, 1));

	    if (REG_P (XEXP (x, 0)) && (GET_CODE (XEXP (x, 1)) == CONST_INT))
	      {
		int disp = INTVAL (XEXP (x, 1));

		if ((disp >= (-16*UNITS_PER_WORD)) && (disp <= (15*UNITS_PER_WORD))
		    && ((disp % UNITS_PER_WORD) == 0))
		  {
		    operands[2] = gen_rtx_CONST_INT(SImode, disp/UNITS_PER_WORD);

		    if (scarts32_regno_reg_class(true_regnum(operands[1])) == POINTER_REGS)
		      {
			int clobbered = 0;

			if (true_regnum(operands[1]) == STACK_POINTER_REGNUM)
			  {
			    clobbered = 1;
			  }

			operands[1] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(operands[1])));
			
			output_asm_insn ("stfpz_dec r7,-1", operands);
			output_asm_insn ("ldli r13,%1", operands);
			output_asm_insn ("ldw r7,r13", operands);
			if (clobbered)
			  {
			    output_asm_insn ("addi r7, 4", operands);
			  }		    
			output_asm_insn ("st%0 r7,%2", operands);
			output_asm_insn ("ldfpz_inc r7,0", operands);
		      }
		    else
		      {
			output_asm_insn ("st%0 %1,%2", operands);
		      }
		  }
		else
		  {
		    fatal_insn ("internal compiler error. Invalid memory insn:",
				operands[0]);
		  }
	      }
	    else 
	      {
		fatal_insn ("internal compiler error. Invalid memory insn:",
			    operands[0]);
	      }
	  }
	else if (REG_P (x))
	  {
	    if (scarts32_regno_reg_class(true_regnum(x)) == POINTER_REGS)
	      {
		if (scarts32_regno_reg_class(true_regnum(operands[1])) == POINTER_REGS)
		  {
		    int clobbered = 0;

		    if (true_regnum(operands[1]) == STACK_POINTER_REGNUM)
		      {
			clobbered = 1;
		      }

		    operands[1] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(operands[1])));

		    output_asm_insn ("stfpz_dec r7,-1", operands);
		    output_asm_insn ("ldli r13,%1", operands);
		    output_asm_insn ("ldw r7,r13", operands);
		    if (clobbered)
		      {
			output_asm_insn ("addi r7, 4", operands);
		      }		    
		    output_asm_insn ("st%0 r7,0", operands);
		    output_asm_insn ("ldfpz_inc r7,0", operands);
		  }
		else
		  {
		    output_asm_insn ("st%0 %1,0", operands);
		  }
	      }
	    else
	      {
		if (scarts32_regno_reg_class(true_regnum(operands[1])) == POINTER_REGS)
		  {
		    int clobbered = 0;
		    
		    if (true_regnum(operands[1]) == STACK_POINTER_REGNUM)
		      {
			clobbered = 1;
		      }

		    operands[1] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(operands[1])));

		    output_asm_insn ("stfpz_dec r7,-1", operands);
		    output_asm_insn ("ldli r13,%1", operands);
		    output_asm_insn ("ldw r7,r13", operands);
		    if (clobbered)
		      {
			output_asm_insn ("addi r7, 4", operands);
		      }		    
		    output_asm_insn ("stw r7,%0", operands);
		    output_asm_insn ("ldfpz_inc r7,0", operands);
		  }
		else
		  {
		    output_asm_insn ("stw %1,%0", operands);
		  }
	      }
	  }
	else
	  {
	    fatal_insn ("internal compiler error. Invalid memory insn:",
			operands[0]);
	  }
      }
      break;

    case 6:
      {
	/* operands: dest, src [, offset] */
	rtx x = XEXP (operands[1], 0);
	if (GET_CODE (x) == PLUS)
	  {
	    operands[1] = (XEXP (x, 0));
	    operands[2] = (XEXP (x, 1));

	    if (REG_P (operands[1]) && (GET_CODE (operands[2]) == CONST_INT))
	      {
		int disp = INTVAL (XEXP (x, 1));

		if ((disp >= (-16*UNITS_PER_WORD)) && (disp <= (15*UNITS_PER_WORD))
		    && ((disp % UNITS_PER_WORD) == 0))
		  {
		    operands[2] = gen_rtx_CONST_INT(SImode, disp/UNITS_PER_WORD);
		    
		    if (scarts32_regno_reg_class(true_regnum(operands[0])) == POINTER_REGS)
		      {
			if (true_regnum(operands[0]) == STACK_POINTER_REGNUM)
			  {
			    fatal_insn ("internal compiler error. Clobbered stack-pointer:", operands[1]);
			  }

			operands[0] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(operands[0])));
			
			output_asm_insn ("stfpz_dec r7,-1", operands);
			output_asm_insn ("ld%1 r7,%2", operands);
			output_asm_insn ("ldli r13,%0", operands);
			output_asm_insn ("stw r7,r13", operands);
			output_asm_insn ("ldfpz_inc r7,0", operands);
		      }
		    else
		      {
			output_asm_insn ("ld%1 %0,%2", operands);
		      }
		  }
		else
		  {
		    fatal_insn ("internal compiler error. Invalid memory insn:",
				operands[1]);
		  }
	      }
	    else
	      {
		fatal_insn ("internal compiler error. Invalid memory insn:",
			    operands[1]);
	      }
	  }
	else if (REG_P (x))
	  {
	    if (scarts32_regno_reg_class(true_regnum(x)) == POINTER_REGS)
	      {
		if (scarts32_regno_reg_class(true_regnum(operands[0])) == POINTER_REGS)
		  {
		    if (true_regnum(operands[0]) == STACK_POINTER_REGNUM)
		      {
			fatal_insn ("internal compiler error. Clobbered stack-pointer:", operands[1]);
		      }

		    operands[0] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(operands[0])));

		    output_asm_insn ("stfpz_dec r7,-1", operands);
		    output_asm_insn ("ld%1 r7,0", operands);
		    output_asm_insn ("ldli r13,%0", operands);
		    output_asm_insn ("stw r7,r13", operands);
		    output_asm_insn ("ldfpz_inc r7,0", operands);
		  }
		else
		  {
		    output_asm_insn ("ld%1 %0,0", operands);
		  }
	      }
	    else
	      {
		if (scarts32_regno_reg_class(true_regnum(operands[0])) == POINTER_REGS)
		  {
		    if (true_regnum(operands[0]) == STACK_POINTER_REGNUM)
		      {
			fatal_insn ("internal compiler error. Clobbered stack-pointer:", operands[1]);
		      }

		    operands[0] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(operands[0])));

		    output_asm_insn ("stfpz_dec r7,-1", operands);
		    output_asm_insn ("ldw r7,%1", operands);
		    output_asm_insn ("ldli r13,%0", operands);
		    output_asm_insn ("stw r7,r13", operands);
		    output_asm_insn ("ldfpz_inc r7,0", operands);
		  }
		else
		  {
		    output_asm_insn ("ldw %0,%1", operands);
		  }
	      }
	  }
	else
	  {
	    fatal_insn ("internal compiler error. Invalid memory insn:",
			operands[1]);
	  }
      }
      break;

    case 7:
      {
	if (scarts32_regno_reg_class(true_regnum(operands[1])) == POINTER_REGS)
	  {
	    if (scarts32_regno_reg_class(true_regnum(operands[0])) == POINTER_REGS)
	      {
		int clobbered = 0;

		if (true_regnum(operands[0]) == STACK_POINTER_REGNUM)
		  {
		    fatal_insn ("internal compiler error. Clobbered stack-pointer:", operands[1]);
		  }
		else if (true_regnum(operands[1]) == STACK_POINTER_REGNUM)
		  {
		    clobbered = 1;
		  }

		operands[0] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(operands[0])));
		operands[1] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(operands[1])));
		
		output_asm_insn ("stfpz_dec r7,-1", operands);
		output_asm_insn ("ldli r13,%1", operands);
		output_asm_insn ("ldw r7,r13", operands);
		if (clobbered)
		  {
		    output_asm_insn ("addi r7, 4", operands);
		  }
		output_asm_insn ("ldli r13,%0", operands);
		output_asm_insn ("stw r7,r13", operands);
		output_asm_insn ("ldfpz_inc r7,0", operands);
	      }
	    else
	      {
		operands[1] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(operands[1])));
		output_asm_insn ("ldli r13,%1", operands);
		output_asm_insn ("ldw %0,r13", operands);
	      }
	  }
	else
	  {
	    if (scarts32_regno_reg_class(true_regnum(operands[0])) == POINTER_REGS)
	      {
		operands[0] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(operands[0])));
		output_asm_insn ("ldli r13,%0", operands);
		output_asm_insn ("stw %1,r13", operands);
	      }
	    else
	      {
		output_asm_insn ("mov %0,%1", operands);
	      }
	  }
      }
      break;

    default:
      gcc_unreachable();
    }
  return "";
}

const char *
scarts32_out_movdi (rtx insn ATTRIBUTE_UNUSED, rtx operands [], int alternative)
{
  switch (alternative)
    {
    case 0:
      if (true_regnum(operands[0]) < true_regnum(operands[1]))
	{  
	  output_asm_insn ("mov %A0,%A1", operands);
	  output_asm_insn ("mov %B0,%B1", operands);
	}
      else
	{
	  output_asm_insn ("mov %B0,%B1", operands);
	  output_asm_insn ("mov %A0,%A1", operands);
	}
      break;
    case 1:
      output_asm_insn ("ldli %A0,%1", operands);
      output_asm_insn ("ldli %B0,%s1", operands);
      break;
    case 2:
      output_asm_insn ("ldhi  %A0,%w1", operands);
      output_asm_insn ("ldliu %A0,%v1", operands);
      output_asm_insn ("sli   %A0,8", operands);
      output_asm_insn ("ldliu %A0,%u1", operands);
      output_asm_insn ("sli   %A0,8", operands);
      output_asm_insn ("ldliu %A0,%t1", operands);
      output_asm_insn ("ldhi  %B0,%W1", operands);
      output_asm_insn ("ldliu %B0,%V1", operands);
      output_asm_insn ("sli   %B0,8", operands);
      output_asm_insn ("ldliu %B0,%U1", operands);
      output_asm_insn ("sli   %B0,8", operands);
      output_asm_insn ("ldliu %B0,%T1", operands);
      break;
    case 3:
      {
	/* operands: src, dest [, offset] */
	rtx x = XEXP (operands[0], 0);
	if (GET_CODE (x) == PLUS)
	  {
	    operands[0] = (XEXP (x, 0));
	    operands[2] = (XEXP (x, 1));

	    if (REG_P (XEXP (x, 0)) && (GET_CODE (XEXP (x, 1)) == CONST_INT))
	      {
		int disp = INTVAL (XEXP (x, 1));

		if ((disp >= (-16*UNITS_PER_WORD)) && (disp <= (14*UNITS_PER_WORD))
		    && ((disp % UNITS_PER_WORD) == 0))
		  {
		    operands[2] = gen_rtx_CONST_INT(SImode, disp/UNITS_PER_WORD);

		    output_asm_insn ("st%0 %A1,%A2", operands);
		    output_asm_insn ("st%0 %B1,%B2", operands);
		  }
		else
		  {
		    fatal_insn ("internal compiler error. Invalid memory insn:",
				operands[0]);
		  }
	      }
	    else 
	      {
		fatal_insn ("internal compiler error. Invalid memory insn:",
			    operands[0]);
	      }
	  }
	else if (REG_P (x))
	  {
	    if (scarts32_regno_reg_class(true_regnum(x)) == POINTER_REGS)
	      {
		output_asm_insn ("st%0 %A1,0", operands);
		output_asm_insn ("st%0 %B1,1", operands);
	      }
	    else
	      {
		output_asm_insn ("mov r13,%0", operands);
		output_asm_insn ("stw %A1,r13", operands);
		output_asm_insn ("addi r13, 4", operands);
		output_asm_insn ("stw %B1,r13", operands);
	      }
	  }
	else
	  {
	    fatal_insn ("internal compiler error. Invalid memory insn:",
			operands[0]);
	  }
      }
      break;
    case 4:
      {
	/* operands: dest, src [, offset] */
	rtx x = XEXP (operands[1], 0);
	if (GET_CODE (x) == PLUS)
	  {
	    operands[1] = (XEXP (x, 0));
	    operands[2] = (XEXP (x, 1));

	    if (REG_P (XEXP (x, 0)) && (GET_CODE (XEXP (x, 1)) == CONST_INT))
	      {
		int disp = INTVAL (XEXP (x, 1));

		if ((disp >= (-16*UNITS_PER_WORD)) && (disp <= (14*UNITS_PER_WORD))
		    && ((disp % UNITS_PER_WORD) == 0))
		  {
		    operands[2] = gen_rtx_CONST_INT(SImode, disp/UNITS_PER_WORD);

		    output_asm_insn ("ld%1 %A0,%A2", operands);
		    output_asm_insn ("ld%1 %B0,%B2", operands);
		  }
		else
		  {
		    fatal_insn ("internal compiler error. Invalid memory insn:",
				operands[1]);
		  }
	      }
	    else
	      {
		fatal_insn ("internal compiler error. Invalid memory insn:",
			    operands[1]);
	      }
	  }
	else if (REG_P (x))
	  {
	    if (scarts32_regno_reg_class(true_regnum(x)) == POINTER_REGS)
	      {
		output_asm_insn ("ld%1 %A0,0", operands);
		output_asm_insn ("ld%1 %B0,1", operands);
	      }
	    else
	      {
		output_asm_insn ("mov r13,%1", operands);
		output_asm_insn ("ldw %A0,r13", operands);
		output_asm_insn ("addi r13, 4", operands);
		output_asm_insn ("ldw %B0,r13", operands);
	      }
	  }
	else
	  {
	    fatal_insn ("internal compiler error. Invalid memory insn:",
			operands[1]);
	  }
      }
      break;
    default:
      gcc_unreachable();
    }
  return "";
}

const char *
scarts32_out_addsi (rtx insn ATTRIBUTE_UNUSED, rtx operands [], int alternative)
{
  switch (alternative)
    {
    case 0:
      if (scarts32_regno_reg_class(true_regnum(operands[2])) == POINTER_REGS)
	{
	  operands[2] = gen_rtx_CONST_INT(SImode, ptrreg_to_addr(true_regnum(operands[2])));
	  output_asm_insn ("ldli r13, %2", operands);
	  output_asm_insn ("ldw r13, r13", operands);
	  output_asm_insn ("add %0, r13", operands);
	}
      else
	{
	  output_asm_insn ("add %0,%2", operands);
	}
      break;
    case 1:
      output_asm_insn ("addi %0,%2", operands);
      break;
    default:
      gcc_unreachable();
    }
  return "";
}

static int ptrreg_to_addr(int reg)
{
  if (reg == PTR_W)
    {
      return -24;
    }
  else if (reg == PTR_X)
    {
      return -20;
    }
  else if (reg == PTR_Y)
    {
      return -16;
    }
  else if (reg == PTR_Z)
    {
      return -12;
    }

  gcc_unreachable();
}

static rtx next_cc_user(rtx insn)
{
  rtx user = next_active_insn(insn);

  /* find real user of condition code */
  while (regno_use_in(CC_REGNO, PATTERN (user) ) == NULL_RTX)
    {
      /* must be an unconditional jump */
      if (JUMP_P(user))
	{
	  /* follow the jump */
	  user = next_active_insn(follow_jumps(JUMP_LABEL(user))); 
	}
      else
	{
	  /* get next insn */
	  user = next_active_insn(user);
	}
    }

  return user;
}

const char *
scarts32_out_compare (rtx insn, rtx operands [])
{
  enum rtx_code code;

  rtx user = next_cc_user(insn);

  /* which comparison do we want */
  if (GET_CODE(PATTERN (user)) == COND_EXEC)
    {
      code = GET_CODE ( COND_EXEC_TEST ( PATTERN (user) ));
    }
  else
    {
      code = GET_CODE ( XEXP ( XEXP ( PATTERN (user), 1), 0));
    }

  if (GET_MODE(operands[0]) == SImode)
    {
      switch(code)
	{
	case NE: /* inverse jump */
	case EQ: /* straight jump */
	  if (CONSTANT_P(operands[1]))
	    output_asm_insn ("cmpi_eq %0,%1", operands);
	  else
	    output_asm_insn ("cmp_eq %0,%1", operands);
	  break;
	case GE: /* inverse jump */ 
	case LT: /* straight jump */
	  if (CONSTANT_P(operands[1]))
	    output_asm_insn ("cmpi_lt %0,%1", operands);
	  else
	    output_asm_insn ("cmp_lt %0,%1", operands);
	  break;
	case GEU: /* inverse jump */ 
	case LTU: /* straight jump */
	  if (CONSTANT_P(operands[1]))
	    {
	      output_asm_insn ("ldli r13,%1", operands);
	      output_asm_insn ("cmpu_lt %0,r13", operands);
	    }
	  else
	    output_asm_insn ("cmpu_lt %0,%1", operands);
	  break;
	case LE: /* inverse jump */ 
	case GT: /* straight jump */
	  if (CONSTANT_P(operands[1]))
	    output_asm_insn ("cmpi_gt %0,%1", operands);
	  else
	    output_asm_insn ("cmp_gt %0,%1", operands);
	  break;
	case LEU: /* inverse jump */ 
	case GTU: /* straight jump */
	  if (CONSTANT_P(operands[1]))
	    {
	      output_asm_insn ("ldli r13,%1", operands);
	      output_asm_insn ("cmpu_gt %0,r13", operands);
	    }
	  else
	    output_asm_insn ("cmpu_gt %0,%1", operands);
	  break;
	default:
	  fatal_insn ("internal compiler error.  Unknown operator:", user);
	}
    }
  else if (GET_MODE(operands[0]) == DImode)
    {
      switch(code)
	{
	case NE: /* inverse jump */
	case EQ: /* straight jump */
	  output_asm_insn ("cmp_eq %B0,%B1", operands);
	  output_asm_insn ("jmpi_cf .T%=", operands);
	  output_asm_insn ("cmp_eq %A0,%A1\n.T%=:", operands);
	  break;
	case GE: /* inverse jump */
	case LT: /* straight jump */
	  output_asm_insn ("cmp_lt %B0,%B1", operands);
	  output_asm_insn ("jmpi_ct .T%=", operands);
	  output_asm_insn ("cmp_gt %B0,%B1", operands);
	  output_asm_insn ("jmpi_ct .F%=", operands);
	  output_asm_insn ("cmpu_lt %A0,%A1", operands);
	  output_asm_insn ("jmpi_ct .T%=", operands);
	  output_asm_insn (".F%=: cmp_lt r13,r13", operands);
	  output_asm_insn (".T%=:", operands);
	  break;
	case GEU: /* inverse jump */
	case LTU: /* straight jump */
	  output_asm_insn ("cmpu_lt %B0,%B1", operands);
	  output_asm_insn ("jmpi_ct .T%=", operands);
	  output_asm_insn ("cmpu_gt %B0,%B1", operands);
	  output_asm_insn ("jmpi_ct .F%=", operands);
	  output_asm_insn ("cmpu_lt %A0,%A1", operands);
	  output_asm_insn ("jmpi_ct .T%=", operands);
	  output_asm_insn (".F%=: cmp_lt r13,r13", operands);
	  output_asm_insn (".T%=:", operands);
	  break;
	case LE: /* inverse jump */
	case GT: /* straight jump */
	  output_asm_insn ("cmp_gt %B0,%B1", operands);
	  output_asm_insn ("jmpi_ct .T%=", operands);
	  output_asm_insn ("cmp_lt %B0,%B1", operands);
	  output_asm_insn ("jmpi_ct .F%=", operands);
	  output_asm_insn ("cmpu_gt %A0,%A1", operands);
	  output_asm_insn ("jmpi_ct .T%=", operands);
	  output_asm_insn (".F%=: cmp_lt r13,r13", operands);
	  output_asm_insn (".T%=:", operands);
	  break;
	case LEU: /* inverse jump */
	case GTU: /* straight jump */ 
	  output_asm_insn ("cmpu_gt %B0,%B1", operands);
	  output_asm_insn ("jmpi_ct .T%=", operands);
	  output_asm_insn ("cmpu_lt %B0,%B1", operands);
	  output_asm_insn ("jmpi_ct .F%=", operands);
	  output_asm_insn ("cmpu_gt %A0,%A1", operands);
	  output_asm_insn ("jmpi_ct .T%=", operands);
	  output_asm_insn (".F%=: cmp_lt r13,r13", operands);
	  output_asm_insn (".T%=:", operands);
	  break;
	default:
	  fatal_insn ("internal compiler error.  Unknown operator:", user);
	}
    }
  else
    {
      fatal_insn ("internal compiler error.  Unknown or unsupported mode:", insn);
    }

  return "";
}

const char *
scarts32_out_bittest (rtx insn, rtx operands [])
{
  enum rtx_code code;

  rtx cond;
  rtx user = next_cc_user(insn);

  rtx op0, op1;

  /* which comparison do we want */
  if (GET_CODE(PATTERN (user)) == COND_EXEC)
    {
      cond = COND_EXEC_TEST ( PATTERN (user) );
    }
  else
    {
      cond = XEXP ( XEXP ( PATTERN (user), 1), 0);
    }

  code = GET_CODE(cond);
  
  /* copy operands, as they might be clobbered by the following */
  op0 = operands[0];
  op1 = operands[1];

  /* we have to reverse the condition for bit tests */
  validate_replace_rtx (cond, reversed_condition (cond), user);

  /* copy back operands */
  operands[0] = op0;
  operands[1] = op1;

  if (GET_MODE(operands[0]) == SImode)
    {
      switch(code)
	{
	case EQ:
	case LT:
	case LTU:
	case GT:
	case GTU:
	case NE:
	case GE:
	case GEU:
	case LE:
	case LEU:
	  output_asm_insn ("btest %0,%1", operands);
    	  break;
	default:
	  fatal_insn ("internal compiler error.  Unknown operator:", user);
	}
    }
  else
    {
      fatal_insn ("internal compiler error.  Unknown or unsupported mode:", insn);
    }

  return "";
}

const char *
scarts32_out_branch (rtx insn, rtx operands [], enum rtx_code code)
{
  int inverse_jump = 0;
  int far_jump = (scarts32_jump_mode(operands[0], insn) == SCARTS32_FAR_JUMP);

  switch(code)
    {
    case EQ:
    case LT:
    case LTU:
    case GT:
    case GTU:
      inverse_jump = 0;
      break;
    case NE:
    case GE:
    case GEU:
    case LE:
    case LEU:
      inverse_jump = 1;
      break;
    default:
      fatal_insn ("internal compiler error.  Unknown operator:", insn);
    }

  if (far_jump)
    {
      output_asm_insn ("ldhi  r13,4th(%0)", operands);
      output_asm_insn ("ldliu r13,3rd(%0)", operands);
      output_asm_insn ("sli   r13,8", operands);
      output_asm_insn ("ldliu r13,hi(%0)", operands);
      output_asm_insn ("sli   r13,8", operands);
      output_asm_insn ("ldliu r13,lo(%0)", operands);

      if (!inverse_jump)
	{
	  output_asm_insn ("jmp_ct r13", operands);
	}
      else
	{
	  output_asm_insn ("jmp_cf r13", operands);
	}
    }
  else
    {
      if (!inverse_jump)
	{
	  output_asm_insn ("jmpi_ct %0", operands);
	}
      else
	{
	  output_asm_insn ("jmpi_cf %0", operands);
	}
    }

  return "";
}

const char *
scarts32_out_jump (rtx insn, rtx operands [])
{
  int far_jump;

  far_jump = (scarts32_jump_mode(operands[0], insn) == SCARTS32_FAR_JUMP);
  if (far_jump)
    {
      output_asm_insn ("ldhi  r13,4th(%0)", operands);
      output_asm_insn ("ldliu r13,3rd(%0)", operands);
      output_asm_insn ("sli   r13,8", operands);
      output_asm_insn ("ldliu r13,hi(%0)", operands);
      output_asm_insn ("sli   r13,8", operands);
      output_asm_insn ("ldliu r13,lo(%0)", operands);
      output_asm_insn ("jmp r13", operands);
    }
  else
    {
      output_asm_insn ("jmpi %0", operands);
    }

  return "";
}

void
scarts32_output_aligned_common(FILE *stream, const char *name, int size, int align)
{
  bss_section();
  ASM_OUTPUT_ALIGN (stream, floor_log2 (align / BITS_PER_UNIT));
  fprintf (stream, "\t.comm\t");
  assemble_name (stream, name);
  fprintf (stream, ",%d\n", size);
}

void
scarts32_output_aligned_local(FILE *stream, const char *name, int size, int align)
{
  bss_section();
  ASM_OUTPUT_ALIGN (stream, floor_log2 (align / BITS_PER_UNIT));
  fprintf (stream, "\t.lcomm\t");
  assemble_name (stream, name);
  fprintf (stream, ",%d\n", size);
}

void
scarts32_output_aligned_bss(FILE *stream, tree decl ATTRIBUTE_UNUSED,
			   const char *name, int size, int align)
{
  bss_section();
  ASM_OUTPUT_ALIGN (stream, floor_log2 (align / BITS_PER_UNIT));
  ASM_OUTPUT_LABEL (stream, name);
  fprintf (stream, "\t.skip\t%d\n", size);
}

void
scarts32_asm_named_section(const char *name,
                          unsigned int flags ATTRIBUTE_UNUSED,
                          tree decl ATTRIBUTE_UNUSED)
{
  fprintf (asm_out_file, "\t.section\t%s\n", name);
}

/* Return an RTX indicating where the return address to the
   calling function can be found. */
rtx
scarts32_return_addr (int count, rtx frame ATTRIBUTE_UNUSED)
{
  if (count != 0)
    return NULL_RTX;

  return get_hard_reg_initial_val (Pmode, RA_REGNO);
}

