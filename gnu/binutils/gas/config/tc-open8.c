/* tc-open8.c -- Assembler code for the Open8/V8/ARClite MCU

   Copyright 1999, 2000, 2001, 2002, 2004, 2005, 2006, 2007, 2008, 2009,
   2010, 2011  Free Software Foundation, Inc.

   Contributed by Kirk Hays <khays@hayshaus.com>

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
#include "safe-ctype.h"
#include "subsegs.h"

struct open8_opcodes_s
{
  char *        name;
  char *        constraints;
  int           insn_size;              /* In bytes.  */
  int           isa;
  unsigned long long bin_opcode;
};

#define OPEN8_INSN(NAME, CONSTR, OPCODE, SIZE, ISA, BIN, MASK)  \
  {#NAME, CONSTR, SIZE, ISA, BIN},

struct open8_opcodes_s open8_opcodes[] =
  {
#include "opcode/open8.h"
    {NULL, NULL, 0, 0, 0}
  };

const char comment_chars[] = ";";
const char line_comment_chars[] = "#";
const char line_separator_chars[] = "$";

const char *md_shortopts = "m:";
struct mcu_type_s
{
  char *name;
  int isa;
  int mach;
};

static struct mcu_type_s mcu_types[] =
  {
    {"open8",      OPEN8_ISA_OPEN8,      bfd_mach_open8_1},
    {NULL, 0, 0}
  };

/* Current MCU type.  */
static struct mcu_type_s default_mcu = {"open8",
                                        OPEN8_ISA_OPEN8,
                                        bfd_mach_open8_1};
static struct mcu_type_s * open8_mcu = &default_mcu;

/* OPEN8 target-specific switches.  */
struct open8_opt_s
{
  int all_opcodes; /* -mall-opcodes: accept all known OPEN8 opcodes.  */
};

static struct open8_opt_s open8_opt = { 0 };

const char EXP_CHARS[] = "eE";
const char FLT_CHARS[] = "dD";

static void open8_set_arch (int);

/* The target specific pseudo-ops which we support.  */
const pseudo_typeS md_pseudo_table[] =
  {
    {"arch", open8_set_arch,    0},
    { NULL,     NULL,           0}
  };

#define EXP_MOD_NAME(i)       (exp_mod[i].name)
#define EXP_MOD_RELOC(i)      (exp_mod[i].reloc)
#define EXP_MOD_NEG_RELOC(i)  (exp_mod[i].neg_reloc)

struct exp_mod_s
{
  char *                    name;
  bfd_reloc_code_real_type  reloc;
  bfd_reloc_code_real_type  neg_reloc;
};

static struct exp_mod_s exp_mod[] =
  {
    {"hi8", BFD_RELOC_OPEN8_HI8_LDI, BFD_RELOC_OPEN8_HI8_LDI_NEG},
    {"lo8", BFD_RELOC_OPEN8_LO8_LDI, BFD_RELOC_OPEN8_LO8_LDI_NEG},
  };

/* A union used to store indicies into the exp_mod[] array
   in a hash table which expects void * data types.  */
typedef union
{
  void * ptr;
  int    index;
} mod_index;

/* Opcode hash table.  */
static struct hash_control *open8_hash;

/* Reloc modifiers hash control (hi8,lo8).  */
static struct hash_control *open8_mod_hash;

#define OPTION_MMCU 'm'
enum options
  {
    OPTION_ALL_OPCODES = OPTION_MD_BASE + 1
  };

struct option md_longopts[] =
  {
    { "mmcu",   required_argument, NULL, OPTION_MMCU        },
    { "mall-opcodes", no_argument, NULL, OPTION_ALL_OPCODES },
    { NULL, no_argument, NULL, 0 }
  };

size_t md_longopts_size = sizeof (md_longopts);

/* Display nicely formatted list of known MCU names.  */

static void
show_mcu_list (FILE *stream)
{
  int i, x;

  fprintf (stream, _("Known MCU names:"));
  x = 1000;

  for (i = 0; mcu_types[i].name; i++)
    {
      int len = strlen (mcu_types[i].name);

      x += len + 1;

      if (x < 75)
        fprintf (stream, " %s", mcu_types[i].name);
      else
        {
          fprintf (stream, "\n  %s", mcu_types[i].name);
          x = len + 2;
        }
    }

  fprintf (stream, "\n");
}

static inline char *
skip_space (char *s)
{
  while (*s == ' ' || *s == '\t')
    ++s;
  return s;
}

/* Extract one word from FROM and copy it to TO.  */

static char *
extract_word (char *from, char *to, int limit)
{
  char *op_end;
  int size = 0;

  /* Drop leading whitespace.  */
  from = skip_space (from);
  *to = 0;

  /* Find the op code end.  */
  for (op_end = from; *op_end != 0 && is_part_of_name (*op_end);)
    {
      to[size++] = *op_end++;
      if (size + 1 >= limit)
        break;
    }

  to[size] = 0;
  return op_end;
}

int
md_estimate_size_before_relax (fragS *fragp ATTRIBUTE_UNUSED,
                               asection *seg ATTRIBUTE_UNUSED)
{
  abort ();
  return 0;
}

void
md_show_usage (FILE *stream)
{
  fprintf (stream,
           _("OPEN8 options:\n"
             "  -mmcu=[open8-name] select microcontroller variant\n"
             "                [open8-name] can be:\n"
             "                    open8   - open8 RISC from `OpenCores.org'.\n"
             ""));
  fprintf (stream,
           _("  -mall-opcodes accept all opcodes\n"
             ""));
  show_mcu_list (stream);
}

static void
open8_opcode_hash (void)
{

  struct open8_opcodes_s *opcode;

  /* Discard any prior opcode hash table.  */
  if (open8_hash)
    {
      hash_die (open8_hash);
    }

  /* Create a new opcode hash table.  */
  open8_hash = hash_new ();

  /* Insert unique names into hash table.  This hash table then provides a
     quick index to the first opcode with a particular name in the opcode
     table.  */
  for (opcode = open8_opcodes; opcode->name; opcode++)
    {
      if (open8_opt.all_opcodes || open8_mcu->isa & opcode->isa)
        {
          hash_insert (open8_hash, opcode->name, (char *) opcode);
        }
    }
}

static void
open8_set_arch (int dummy ATTRIBUTE_UNUSED)
{
  char str[20];

  input_line_pointer = extract_word (input_line_pointer, str, 20);
  md_parse_option (OPTION_MMCU, str);
  bfd_set_arch_mach (stdoutput, TARGET_ARCH, open8_mcu->mach);

  /* Rebuild the opcode hash.  */
  open8_opcode_hash ();
}

int
md_parse_option (int c, char *arg)
{
  switch (c)
    {
    case OPTION_MMCU:
      {
        int i;
        char *s = alloca (strlen (arg) + 1);

        /* Accept mixed case in options, force to lower case
         * to simplify recognition.
         */
        {
          char *t = s;
          char *arg1 = arg;

          do
            {
              *t = TOLOWER (*arg1++);
            }
          while (*t++);
        }

        for (i = 0; mcu_types[i].name; ++i)
          {
            if (strcmp (mcu_types[i].name, s) == 0)
              break;
          }

        if (!mcu_types[i].name)
          {
            show_mcu_list (stderr);
            as_fatal (_("unknown MCU: %s\n"), arg);
          }

        /* It is OK to redefine mcu type within the same open8 bfd machine
           type - this for allows passing -mmcu=... via gcc ASM_SPEC as well
           as `.arch' in the asm output at the same time.  */
        if (open8_mcu == &default_mcu || open8_mcu->mach == mcu_types[i].mach)
          {
            open8_mcu = &mcu_types[i];
          }
        else
          {
            as_fatal (_("redefinition of mcu type `%s' to `%s'"),
                      open8_mcu->name, mcu_types[i].name);
          }
        return 1;
      }
    case OPTION_ALL_OPCODES:
      {
        open8_opt.all_opcodes = 1;
        return 1;
      }
    }

  return 0;
}

symbolS *
md_undefined_symbol (char *name ATTRIBUTE_UNUSED)
{
  return NULL;
}

char *
md_atof (int type, char *litP, int *sizeP)
{
  return ieee_md_atof (type, litP, sizeP, FALSE);
}

void
md_convert_frag (bfd *abfd ATTRIBUTE_UNUSED,
                 asection *sec ATTRIBUTE_UNUSED,
                 fragS *fragP ATTRIBUTE_UNUSED)
{
  abort ();
}

void
md_begin (void)
{
  unsigned int i;

  /* Setup the valid opcodes for this architecture.  */
  open8_opcode_hash ();

  open8_mod_hash = hash_new ();

  for (i = 0; i < ARRAY_SIZE (exp_mod); ++i)
    {
      mod_index m;

      m.index = i + 10;
      hash_insert (open8_mod_hash, EXP_MOD_NAME (i), m.ptr);
    }

  bfd_set_arch_mach (stdoutput, TARGET_ARCH, open8_mcu->mach);
}

/* Resolve STR as an unsigned constant expression and return the result.
   If result greater than MAX then error.  */

static unsigned int
open8_get_uconstant (char *str, int max)
{
  expressionS ex;

  str = skip_space (str);
  input_line_pointer = str;
  expression (& ex);

  if (ex.X_op != O_constant)
    as_bad (_("constant value required"));

  if (ex.X_add_number > max || ex.X_add_number < 0)
    as_bad (_("number must be positive and less than %d"), max + 1);

  return ex.X_add_number;
}

/* Parse ordinary expression.  */

static char *
parse_exp (char *s, expressionS *op)
{
  input_line_pointer = s;
  expression (op);
  if (op->X_op == O_absent)
    as_bad (_("missing operand"));
  return input_line_pointer;
}

/* Parse special expressions (needed for LDI command):
   xx8 (address)
   xx8 (-address)
   where xx is: hi, lo.  */

static bfd_reloc_code_real_type
open8_ldi_expression (expressionS *exp)
{
  char *str = input_line_pointer;
  char *tmp;
  char op[8];
  int mod;

  tmp = str;

  str = extract_word (str, op, sizeof (op));

  if (op[0])
    {
      mod_index m;

      m.ptr = hash_find (open8_mod_hash, op);
      mod = m.index;

      if (mod)
        {
          int closes = 0;

          mod -= 10;
          str = skip_space (str);

          if (*str == '(')
            {
              bfd_reloc_code_real_type  reloc_to_return;
              int neg_p = 0;

              ++str;

              if (*str == '-' && *(str + 1) == '(')
                {
                  neg_p ^= 1;
                  ++closes;
                  str += 2;
                }

              input_line_pointer = str;
              expression (exp);

              do
                {
                  if (*input_line_pointer != ')')
                    {
                      as_bad (_("`)' required"));
                      break;
                    }
                  input_line_pointer++;
                }
              while (closes--);

              reloc_to_return =
                neg_p ? EXP_MOD_NEG_RELOC (mod) : EXP_MOD_RELOC (mod);
              return reloc_to_return;
            }
        }
    }

  input_line_pointer = tmp;
  expression (exp);

  /* Warn about expressions that fail to use lo8 ().  */
  if (exp->X_op == O_constant)
    {
      int x = exp->X_add_number;

      if (x < -128 || x > 255)
        as_warn (_("constant out of 8-bit range: %d"), x);
    }

  return BFD_RELOC_OPEN8_LO8_LDI;
}

/* Parse one instruction operand.
   Return operand bitmask.  Also fixups can be generated.  */

static unsigned long long
open8_operand (int where,
               char *op,
               char **line)
{
  expressionS op_expr;
  unsigned long long op_mask = 0;
  char *str = skip_space (*line);

  switch (*op)
    {
      /* Any register operand.  */
    case 'r':
    case 'e':
      {
        if (*str == 'r' || *str == 'R')
          {
            char r_name[20];
            str = extract_word (str, r_name, sizeof (r_name));
            op_mask = 0xff;
            if (ISDIGIT (r_name[1]))
              {
                if (r_name[2] == '\0')
                  op_mask = r_name[1] - '0';
              }
          }

        if (op_mask <= 7)
          {
            switch (*op)
              {
              case 'e':
                /* Enforce even register requirement.  */
                if (op_mask & 1)
                  as_bad (_("register r0, r2, r4, or r6 required"));
                break;

              case 'r':
                break;

              }
            break;
          }

        as_bad (_("register name from r0 to r7 required"));
      }
    break;

    /* Unsigned offset expression, eight bits, range 0 to 255.  */
    case 'u':
      {
        str = parse_exp (str, &op_expr);
        fix_new_exp (frag_now, where + 1, 1,
                     &op_expr, FALSE, BFD_RELOC_8);
      }
      break;

      /* Signed pc-relative offset expression, eight bits,
	 range -128 to 127, or a symbol.  */
    case 's':
      {
        str = parse_exp (str, &op_expr);
	fix_new_exp (frag_now, where + 1, 1,
		     &op_expr, FALSE, BFD_RELOC_OPEN8_PCREL);
      }
      break;

      /* Parse expression for the ldi instruction.  */
    case 'i':
      {
        bfd_reloc_code_real_type r_type;

        input_line_pointer = str;
        r_type = open8_ldi_expression (&op_expr);
        str = input_line_pointer;
        fix_new_exp (frag_now, where+1, 1,
                     &op_expr, FALSE, r_type);
      }
      break;

      /* Unsigned constant in the range 0..7.  */
    case 'n':
    case 'b':
      {
        unsigned int x;

        x = open8_get_uconstant (str, 7);
        str = input_line_pointer;
        op_mask |= x;
      }
    break;

    /* Unsigned 16 bit address expression for JMP or JSR.  */
    case 'h':
      {
        str = parse_exp (str, &op_expr);
        fix_new_exp (frag_now, where + 1, 2,
                     &op_expr, FALSE, BFD_RELOC_OPEN8_CALL);
      }
      break;

    /* Unsigned 16 bit address expression for composed JMP variant.  */
    case 'H':
      {
        str = parse_exp (str, &op_expr);
        fix_new_exp (frag_now, where + 3, 2,
                     &op_expr, FALSE, BFD_RELOC_OPEN8_CALL);
      }
      break;

    /* Unsigned 16 bit address expression for load or store instructions.  */
    case 'M':
      {
        str = parse_exp (str, &op_expr);
        fix_new_exp (frag_now, where + 1, 2,
                     &op_expr, FALSE, BFD_RELOC_16);
      }
      break;

      /* Autoincrement operator on index.  */
    case 'a':
      {
        if (str[0] == '+' && str[1] == '+')
          {
            str = skip_space (str + 2);
            op_mask = 0x1;
          }
      }
      break;

    default:
      as_bad (_("unknown constraint `%c'"), *op);
    }

  *line = str;
  return op_mask;
}

/* Parse instruction operands.
   Return binary opcode.  */

static unsigned long long
open8_operands (struct open8_opcodes_s *opcode, char **line)
{
  char *op = opcode->constraints;
  unsigned long long bin = opcode->bin_opcode;
  unsigned long long reg1 = 0, reg2 = 0, reg3 = 0;
  char *frag = frag_more (opcode->insn_size);
  char *str = *line;
  int where = frag - frag_now->fr_literal;

  /* Opcodes optionally have operands.  */
  /* The operand patterns are:
     <empty> |
     op1 |
     op1 op2 |
     op1,op2 |
     op1 op2,op3
  */
  if (*op)
    {
      /* Parse first operand.  */
      reg1 = open8_operand (where, op, &str);
      ++op;

      /* Parse second operand, if present.  */
      if (*op)
        {
          str = skip_space (str);

          /* require a comma, if present in the pattern.  */
          if (*op == ',')
            {
              ++op;
              if (*str++ != ',')
                {
                  as_bad (_("`,' required"));
                }
              str = skip_space (str);
            }

          reg2 = open8_operand (where, op, &str);
          ++op;
        }

      /* Parse third operand, if present.  */
      if (*op)
        {

          str = skip_space (str);

          /* require a comma, if present in the pattern.  */
          if (*op == ',')
            {
              ++op;
              if (*str++ != ',')
                {
                  as_bad (_("`,' required"));
                }
              str = skip_space (str);
            }

          reg3 = open8_operand (where, op, &str);
        }
    }

  bin |= reg1 | reg2 | reg3;

  unsigned long long scr = bin;

  /* Copy the instruction bytes to the frag, supporting
   * only instructions sizes that are defined for the OPEN8.
   * NB: note the fallthroughs.  */
  switch (opcode->insn_size)
    {
    case 5:
      *frag++ = (unsigned char)scr;
      scr >>= 8;
      *frag++ = (unsigned char)scr;
      scr >>= 8;
      /* FALLTHROUGH.  */
    case 3:
      *frag++ = (unsigned char)scr;
      scr >>= 8;
      /* FALLTHROUGH.  */
    case 2:
      *frag++ = (unsigned char)scr;
      scr >>= 8;
      /* FALLTHROUGH.  */
    case 1:
      *frag++ = (unsigned char)scr;
      break;

    default:
      as_fatal (_("unsupported instruction size: %d\n"), opcode->insn_size);
    }

  *line = str;
  return bin;
}

/* GAS will call this function for each section at the end of the assembly,
   to permit the CPU backend to adjust the alignment of a section.  */

valueT
md_section_align (asection *seg, valueT addr)
{
  int align = bfd_get_section_alignment (stdoutput, seg);
  return ((addr + (1 << align) - 1) & (-1 << align));
}

/* If you define this macro, it should return the offset between the
   address of a PC relative fixup and the position from which the PC
   relative adjustment should be made.  On many processors, the base
   of a PC relative instruction is the next instruction, so this
   macro would return the length of an instruction.  */

long
md_pcrel_from_section (fixS *fixp, segT sec)
{
  if (fixp->fx_addsy != (symbolS *) NULL
      && (!S_IS_DEFINED (fixp->fx_addsy)
          || (S_GET_SEGMENT (fixp->fx_addsy) != sec)))
    return 0;

  return fixp->fx_frag->fr_address + fixp->fx_where;
}

/* GAS will call this for each fixup.  It should store the correct
   value in the object file.  */

void
md_apply_fix (fixS *fixP, valueT * valP, segT seg)
{
  unsigned char *where;
#if 0
  unsigned long insn;
#endif
  long value = *valP;

  if (fixP->fx_addsy == (symbolS *) NULL)
    fixP->fx_done = 1;

  else if (fixP->fx_pcrel)
    {
      segT s = S_GET_SEGMENT (fixP->fx_addsy);

      if (s == seg || s == absolute_section)
        {
          value += S_GET_VALUE (fixP->fx_addsy);
          fixP->fx_done = 1;
        }
    }

  /* We don't actually support subtracting a symbol.  */
  if (fixP->fx_subsy != (symbolS *) NULL)
    as_bad_where (fixP->fx_file, fixP->fx_line, _("expression too complex"));

  switch (fixP->fx_r_type)
    {
    default:
      fixP->fx_no_overflow = 1;
      break;
    case BFD_RELOC_32:
    case BFD_RELOC_16:
    case BFD_RELOC_OPEN8_CALL:
      break;
    }

  if (fixP->fx_done)
    {
      /* Fetch the instruction, insert the fully resolved operand
         value, and stuff the instruction back again.  */
      where = (unsigned char *) fixP->fx_frag->fr_literal + fixP->fx_where;
#if 0
      insn = bfd_getl16 (where);
#endif
      switch (fixP->fx_r_type)
        {
        case BFD_RELOC_32:
          bfd_putl16 ((bfd_vma) value, where);
          break;

        case BFD_RELOC_16:
          if (value > 65535 || value < -32768)
            {
              as_warn_where (fixP->fx_file, fixP->fx_line,
                             _("operand out of range: %ld"), value);
            }
          bfd_putl16 ((bfd_vma) value, where);
          break;

        case BFD_RELOC_8:
          if (value > 255 || value < -128)
            {
              as_warn_where (fixP->fx_file, fixP->fx_line,
                             _("operand out of range: %ld"), value);
            }
          *where = value;
          break;

        case BFD_RELOC_OPEN8_LO8_LDI:
          *where = value;
          break;

        case BFD_RELOC_OPEN8_HI8_LDI:
          *where = value >> 8;
          break;

        case BFD_RELOC_OPEN8_LO8_LDI_NEG:
          *where = -value;
          break;

        case BFD_RELOC_OPEN8_HI8_LDI_NEG:
          *where = -value >> 8;
          break;

        case BFD_RELOC_OPEN8_CALL:
          {
            if (value > 65535 || value < -32768)
              {
                as_warn_where (fixP->fx_file, fixP->fx_line,
                               _("operand out of range: %ld"), value);
              }
            bfd_putl16 ((bfd_vma) value, where);
          }
          break;

        case BFD_RELOC_OPEN8_PCREL:

          if ((value < -128) || (value > 127))
            {
              as_bad_where (fixP->fx_file, fixP->fx_line,
                            _("operand out of range[-128..127]: %ld"), value);
            }
          *where = value;
          break;

        default:
          as_fatal (_("line %d: unknown relocation type: 0x%x"),
                    fixP->fx_line, fixP->fx_r_type);
          break;
        }
    }
  else
    {
      switch ((int) fixP->fx_r_type)
        {
        case -BFD_RELOC_OPEN8_HI8_LDI_NEG:
        case -BFD_RELOC_OPEN8_HI8_LDI:
        case -BFD_RELOC_OPEN8_LO8_LDI_NEG:
        case -BFD_RELOC_OPEN8_LO8_LDI:
          as_bad_where (fixP->fx_file, fixP->fx_line,
                        _("only constant expression allowed"));
          fixP->fx_done = 1;
          break;
        default:
          break;
        }
    }
}

/* GAS will call this to generate a reloc, passing the resulting reloc
   to `bfd_install_relocation'.  This currently works poorly, as
   `bfd_install_relocation' often does the wrong thing, and instances of
   `tc_gen_reloc' have been written to work around the problems, which
   in turns makes it difficult to fix `bfd_install_relocation'.  */

/* If while processing a fixup, a reloc really needs to be created
   then it is done here.  */

arelent *
tc_gen_reloc (asection *seg ATTRIBUTE_UNUSED,
              fixS *fixp)
{
  arelent *reloc;

  if (fixp->fx_addsy && fixp->fx_subsy)
    {
      long value = 0;

      if ((S_GET_SEGMENT (fixp->fx_addsy) != S_GET_SEGMENT (fixp->fx_subsy))
          || S_GET_SEGMENT (fixp->fx_addsy) == undefined_section)
        {
          as_bad_where (fixp->fx_file, fixp->fx_line,
                        "Difference of symbols in different sections"
                        " is not supported");
          return NULL;
        }

      /* We are dealing with two symbols defined in the same section.
         Let us fix-up them here.  */
      value += S_GET_VALUE (fixp->fx_addsy);
      value -= S_GET_VALUE (fixp->fx_subsy);

      /* When fx_addsy and fx_subsy both are zero, md_apply_fix
         only takes it's second operands for the fixup value.  */
      fixp->fx_addsy = NULL;
      fixp->fx_subsy = NULL;
      md_apply_fix (fixp, (valueT *) &value, NULL);

      return NULL;
    }

  reloc = xmalloc (sizeof (arelent));

  reloc->sym_ptr_ptr = xmalloc (sizeof (asymbol *));
  *reloc->sym_ptr_ptr = symbol_get_bfdsym (fixp->fx_addsy);

  reloc->address = fixp->fx_frag->fr_address + fixp->fx_where;
  reloc->howto = bfd_reloc_type_lookup (stdoutput, fixp->fx_r_type);
  if (reloc->howto == (reloc_howto_type *) NULL)
    {
      as_bad_where (fixp->fx_file, fixp->fx_line,
                    _("reloc %d not supported by object file format"),
                    (int) fixp->fx_r_type);
      return NULL;
    }

  if (fixp->fx_r_type == BFD_RELOC_VTABLE_INHERIT
      || fixp->fx_r_type == BFD_RELOC_VTABLE_ENTRY)
    reloc->address = fixp->fx_offset;

  reloc->addend = fixp->fx_offset;

  return reloc;
}

void
md_assemble (char *str)
{
  struct open8_opcodes_s *opcode;
  char op[11];

  str = skip_space (extract_word (str, op, sizeof (op)));

  if (!op[0])
    as_bad (_("can't find opcode "));

  opcode = (struct open8_opcodes_s *) hash_find (open8_hash, op);

  if (opcode == NULL)
    {
      as_bad (_("unknown opcode `%s'"), op);
      return;
    }

  /* Check to see if opcode allowed.  */
  if (!open8_opt.all_opcodes
      && ((opcode->isa & open8_mcu->isa) != open8_mcu->isa))
    {
      as_bad (_("illegal opcode \"%s\" for mcu %s"),
              opcode->name,
              open8_mcu->name);
    }

  dwarf2_emit_insn (0);

  /* We used to set input_line_pointer to the result of get_operands,
     but that is wrong.  Our caller assumes we don't change it.  */
  {
    char *t = input_line_pointer;

    open8_operands (opcode, &str);
    if (*skip_space (str))
      as_bad (_("garbage at end of line"));
    input_line_pointer = t;
  }
}

