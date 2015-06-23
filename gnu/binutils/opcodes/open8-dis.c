/* Disassemble Open8 instructions.
   Copyright 1999, 2000, 2002, 2004, 2005, 2006, 2007, 2008, 2010, 2011
   Free Software Foundation, Inc.

   Contributed by Kirk Hays <khays@hayshaus.com>

   This file is part of libopcodes.

   This library is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3, or (at your option)
   any later version.

   It is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
   License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
   MA 02110-1301, USA.  */

#include "sysdep.h"
#include "dis-asm.h"
#include "opintl.h"
#include "libiberty.h"

struct open8_opcodes_s
{
  char *name;
  char *constraints;
  char *opcode;
  int insn_size;		/* In bytes.  */
  int isa;
  unsigned long long opcode_bits;
  unsigned long long opcode_mask;
};

#define OPEN8_INSN(NAME, CONSTR, OPCODE, SIZE, ISA, BIN, MASK)	\
  {#NAME, CONSTR, OPCODE, SIZE, ISA, BIN, MASK},

const struct open8_opcodes_s open8_opcodes[] =
  {
#include "opcode/open8.h"
    {NULL, NULL, NULL, 0, 0, 0, 0}
  };

static const char * comment_start = "0x";

static int
open8_operand (unsigned long long insn,
	       int constraint,
	       char *buf,
	       int buf_len,
	       char *comment,
	       int comment_len,
	       int *sym,
	       bfd_vma *sym_addr)
{
  int ok = 1;
  *sym = 0;

  switch (constraint)
    {
      /* Any register operand.  */
    case 'r':
      snprintf (buf, buf_len, "r%d", (int) ((insn & REG_MASK) >> REG_SHIFT));
      break;

      /* Even numbered register.  */
    case 'e':
      snprintf (buf, buf_len, "r%d", (int) ((insn & EREG_MASK) >> EREG_SHIFT));
      break;

      /* Unsigned offset expression, 8 bits.  */
    case 'u':
      snprintf (buf, buf_len, "%u", (int) ((insn & U_MASK) >> U_SHIFT));
      break;

      /* Signed pc-relative offset expression, 8 bits.  */
    case 's':
      {
	int8_t t = ((insn & S_MASK) >> S_SHIFT);
	snprintf (buf, buf_len, "%d", (int)t);  /* Propagate sign bit.  */
      }
      break;

      /* Immediate value expression, signed, 8 bits.  */
    case 'i':
      {
	int8_t t = ((insn & I_MASK) >> I_SHIFT);
	snprintf (buf, buf_len, "%d", (int)t);  /* Propagate sign bit.  */
      }
      break;

      /* Immediate value expression, 3 bits.  */
    case 'n':
      {
	snprintf (buf, buf_len, "%u", (int) ((insn & N_MASK) >> N_SHIFT));
      }
      break;

      /* Immediate value expression, 3 bits, indexing PSR.  */
    case 'b':
      {
	snprintf (buf, buf_len, "%u", (int) ((insn & B_MASK) >> B_SHIFT));
      }
      break;

      /* Memory reference, 16 bits, unsigned.  */
    case 'M':
      {
	*sym = 1;
	*sym_addr = (bfd_vma) ((insn & M_MASK) >> M_SHIFT);
	snprintf (buf, buf_len, "%#lx", (unsigned long) *sym_addr);
	strncpy (comment, comment_start, comment_len);
      }
      break;

      /* JSR/JMP reference, 16 bits, unsigned.  */
    case 'h':
      {
	*sym = 1;
	*sym_addr = (bfd_vma) ((insn & H_MASK) >> H_SHIFT);
	snprintf (buf, buf_len, "%#lx", (unsigned long) *sym_addr);
	strncpy (comment, comment_start, comment_len);
      }
      break;

      /* JSR/JMP reference, 16 bits, unsigned, in composite branch.  */
    case 'H':
      {
	*sym = 1;
	*sym_addr = (bfd_vma) ((insn & BIG_H_MASK) >> BIG_H_SHIFT);
	snprintf (buf, buf_len, "%#lx", (unsigned long) *sym_addr);
	strncpy (comment, comment_start, comment_len);
      }
      break;

      /* autoincrement operator.  */
    case 'a':
      {
	if (insn & A_MASK)
	  {
	    snprintf (buf, buf_len, "%s", "++");
	  }
      }
      break;

      /* syntactic sugar - comma.  */
    case ',':
      {
	snprintf (buf, buf_len, "%s", ",");
      }
      break;

    default:
      {
	snprintf (buf, buf_len, "??");
	fprintf (stderr, _("unknown constraint `%c'"), constraint);
	ok = 0;
      }
    }

  return ok;
}

static unsigned long long
open8_dis_opcode (bfd_vma addr, disassemble_info *info)
{
  bfd_byte buffer[sizeof (unsigned long long)];
  int status;

  int readsize = sizeof buffer;

  /* Make sure we don't try to read past the end of the section.  */
  if (addr + readsize >= info->section->size)
    {
      readsize = info->section->size - addr;
      memset (buffer, 0, sizeof buffer);
    }

  status = info->read_memory_func (addr, buffer, readsize, info);

  if (status == 0)
    return bfd_getl64 (buffer);

  info->memory_error_func (status, addr, info);
  return -1;
}


int
print_insn_open8 (bfd_vma addr, disassemble_info *info)
{
  unsigned long long insn;
  const struct open8_opcodes_s *opcode;
  void *stream = info->stream;
  fprintf_ftype prin = info->fprintf_func;
  int ok = 0;
  char op1[20], op2[20], op3[20], comment1[40], comment2[40], comment3[40];
  int comma1 = 0, comma2 = 0;
  int sym_op1 = 0, sym_op2 = 0, sym_op3 = 0;
  bfd_vma sym_addr1, sym_addr2, sym_addr3;

  if (info->symtab_size == 0)
    comment_start = " ";

  insn = open8_dis_opcode (addr, info);

  /* Scan the opcode descriptors, looking for an opcode match.  */
  for (opcode = open8_opcodes;
       opcode->name;
       opcode++)
    {
      /* If the memory anded with the mask matches required opcode bits,
	 then we have a match.  */
      if ((insn & opcode->opcode_mask) == opcode->opcode_bits)
	{
	  break;
	}
    }

  op1[0] = 0;
  op2[0] = 0;
  op3[0] = 0;
  comment1[0] = 0;
  comment2[0] = 0;
  comment3[0] = 0;

  /* Parse the binary value using the constraints.  */
  if (opcode->name)
    {
      char *op = opcode->constraints;

      ok = 1;

      if (*op)
	{
	  /* Grab the first operand.  */
	  ok = open8_operand (insn, 
			      *op++, 
			      op1, 
			      sizeof op1 - strlen (op1), 
			      comment1,
			      sizeof comment1 - strlen (comment1),
			      &sym_op1, 
			      &sym_addr1);

	  /* Note a comma.  */
	  if (ok && *op == ',')
	    {
	      comma1++;
	      op++;
	    }

	  /* Grab the second operand.  */
	  if (ok && *op)
	    {
	      ok = open8_operand (insn, 
				  *op++, 
				  op2,
				  sizeof op2 - strlen (op2), 
				  (*comment1 
				   ? comment2 
				   : comment1),
				  (*comment1 
				   ? sizeof comment2 - strlen (comment2)
				   : sizeof comment1 - strlen (comment1)),
				  &sym_op2, 
				  &sym_addr2);
	    }

	  /* Note a comma.  */
	  if (ok && *op == ',')
	    {
	      comma2++;
	      op++;
	    }

	  /* Grab the third operand.  */
	  if (ok && *op)
	    {
	      ok = open8_operand (insn, 
				  *op++, 
				  op3,
				  sizeof op3 - strlen (op3),
				  (*comment1 
				   ? (*comment2
				      ? comment3
				      : comment2)
				   : comment1),
				  (*comment1 
				   ? (*comment2 
				      ? sizeof comment3 - strlen (comment3)
				      : sizeof comment2 - strlen (comment2))
				   : sizeof comment1 - strlen (comment1)),
				  &sym_op3, &sym_addr3);
	    }

	}
    }

  if (!ok)
    {
      /* Unknown opcode, or invalid combination of operands.  */
      snprintf (op1, sizeof op1, "0x%04x", (unsigned int)insn);
      op2[0] = 0;
      op3[0] = 0;
      snprintf (comment1, sizeof comment1, "????");
      comment2[0] = 0;
      comment3[0] = 0;
    }

  (*prin) (stream, "%s", ok ? opcode->name : ".word");

  if (*op1)
    (*prin) (stream, "\t%s", op1);

  if (comma1)
    (*prin) (stream, "%s",",");

  if (*op2)
    (*prin) (stream, " %s", op2);

  if (comma2)
    (*prin) (stream, "%s",",");

  if (*op3)
    (*prin) (stream, " %s", op3);

  if (*comment1)
    (*prin) (stream, "\t; %s", comment1);

  if (sym_op1)
    info->print_address_func (sym_addr1, info);

  if (*comment2)
    (*prin) (stream, " %s", comment2);

  if (sym_op2)
    info->print_address_func (sym_addr2, info);

  if (*comment3)
    (*prin) (stream, " %s", comment3);

  if (sym_op3)
    info->print_address_func (sym_addr3, info);

  return opcode->insn_size;
}
