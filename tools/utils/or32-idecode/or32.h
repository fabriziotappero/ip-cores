/* Table of opcodes for the OpenRISC 1000 ISA.
   Copyright 2002, 2003 Free Software Foundation, Inc.
   Contributed by Damjan Lampret (lampret@opencores.org).
   
   This file is part of or1k_gen_isa, or1ksim, GDB and GAS.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston, MA 02110-1301, USA.  */

/* We treat all letters the same in encode/decode routines so
   we need to assign some characteristics to them like signess etc.  */

#ifndef OR32_H_ISA
#define OR32_H_ISA

#define NUM_UNSIGNED (0)
#define NUM_SIGNED (1)

#define MAX_GPRS 32
#define PAGE_SIZE 8192
#undef __HALF_WORD_INSN__

#define OPERAND_DELIM (',')

#define OR32_IF_DELAY (1)
#define OR32_W_FLAG   (2)
#define OR32_R_FLAG   (4)

#if defined(HAS_EXECUTION)
# if SIMPLE_EXECUTION
#  include "simpl32_defs.h"
# elif DYNAMIC_EXECUTION
#  include "dyn32_defs.h"
# else
extern void l_none (void);
# endif
#else
extern void l_none (void);
#endif

struct or32_letter
{
  char letter;
  int  sign;
  /* int  reloc; relocation per letter ??  */
};

enum insn_type {
  it_unknown,
  it_exception,
  it_arith,
  it_shift,
  it_compare,
  it_branch,
  it_jump,
  it_load,
  it_store,
  it_movimm,
  it_move,
  it_extend,
  it_nop,
  it_mac,
  it_float };

/* Main instruction specification array.  */
struct or32_opcode
{
  /* Name of the instruction.  */
  char *name;

  /* A string of characters which describe the operands.
     Valid characters are:
     ,() Itself.  Characters appears in the assembly code.
     rA	 Register operand.
     rB  Register operand.
     rD  Register operand.
     I	 An immediate operand, range -32768 to 32767.
     J	 An immediate operand, range . (unused)
     K	 An immediate operand, range 0 to 65535.
     L	 An immediate operand, range 0 to 63.
     M	 An immediate operand, range . (unused)
     N	 An immediate operand, range -33554432 to 33554431.
     O	 An immediate operand, range . (unused).  */
  char *args;
  
  /* Opcode and operand encoding.  */
  char *encoding;

#ifdef HAS_EXECUTION
# if COMPLEX_EXECUTION
  char *function_name;
# elif SIMPLE_EXECUTION
  void (*exec)(struct iqueue_entry *);
# else /* DYNAMIC_EXECUTION */
  void (*exec)(struct op_queue *opq, int param_t[3], orreg_t param[3], int);
# endif
#else  /* HAS_EXECUTION */
  void (*exec)(void);
#endif

  unsigned int flags;
  enum insn_type func_unit;
};

#define OPTYPE_LAST (0x80000000)
#define OPTYPE_OP   (0x40000000)
#define OPTYPE_REG  (0x20000000)
#define OPTYPE_SIG  (0x10000000)
#define OPTYPE_DIS  (0x08000000)
#define OPTYPE_DST  (0x04000000)
#define OPTYPE_SBIT (0x00001F00)
#define OPTYPE_SHR  (0x0000001F)
#define OPTYPE_SBIT_SHR (8)

/* MM: Data how to decode operands.  */
extern struct insn_op_struct
{
  unsigned long type;
  unsigned long data;
} **op_start;

/* Leaf flag used in automata building */
#define LEAF_FLAG         (0x80000000)

struct temp_insn_struct
{
  unsigned long insn;
  unsigned long insn_mask;
  int in_pass;
};

extern unsigned long *automata;
extern struct temp_insn_struct *ti;

extern const struct or32_letter or32_letters[];

extern const struct  or32_opcode or32_opcodes[];

extern const unsigned int or32_num_opcodes;

/* Calculates instruction length in bytes.  Always 4 for OR32.  */
extern int insn_len (int);

/* Is individual insn's operand signed or unsigned?  */
extern int letter_signed (char);

/* Number of letters in the individual lettered operand.  */
extern int letter_range (char);

/* MM: Returns index of given instruction name.  */
extern int insn_index (char *);

/* MM: Returns instruction name from index.  */
extern const char *insn_name (int);

/* MM: Constructs new FSM, based on or32_opcodes.  */ 
extern void build_automata (void);

/* MM: Destructs FSM.  */ 
extern void destruct_automata (void);

/* MM: Decodes instruction using FSM.  Call build_automata first.  */
extern int insn_decode (unsigned int);

/* Disassemble one instruction from insn to disassemble.
   Return the size of the instruction.  */
int disassemble_insn (unsigned long);

/* Extract instruction */
extern unsigned long insn_extract(char,char*);
     
/* Disassemble one instruction from insn index.
   Return the size of the instruction.  */
int disassemble_index (unsigned long,int);

/* FOR INTERNAL USE ONLY */
/* Automatically does zero- or sign- extension and also finds correct
   sign bit position if sign extension is correct extension. Which extension
   is proper is figured out from letter description. */
unsigned long extend_imm(unsigned long,char);

#endif
