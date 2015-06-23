/* Definitions of target machine for GNU compiler,
   for the SCARTS32 micro controller.
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

/* Names to predefine in the preprocessor for this target machine. */

#define TARGET_CPU_CPP_BUILTINS()                       \
  do                                                    \
    {                                                   \
      builtin_define("__SCARTS_32__");                  \
      builtin_define_std ("SCARTS_32");                 \
      if (scarts32_base_arch_macro)                      \
	builtin_define (scarts32_base_arch_macro);       \
      if (scarts32_extra_arch_macro)                     \
	builtin_define (scarts32_extra_arch_macro);      \
    }                                                   \
  while (0)

extern const char *scarts32_base_arch_macro;
extern const char *scarts32_extra_arch_macro;

#define TARGET_VERSION fprintf (stderr, " (SCARTS32)");

#define OVERRIDE_OPTIONS scarts32_override_options ()

#define OPTIMIZATION_OPTIONS(level, size) scarts32_optimization_options (level, size)

#define CAN_DEBUG_WITHOUT_FP

#define BITS_BIG_ENDIAN 0

#define BYTES_BIG_ENDIAN 0

#define WORDS_BIG_ENDIAN 0

#define BITS_PER_UNIT 8

#define BITS_PER_WORD 32

#define UNITS_PER_WORD 4

#define POINTER_SIZE 32

#define PARM_BOUNDARY 32

#define STACK_BOUNDARY 32

#define FUNCTION_BOUNDARY 8

#define EMPTY_FIELD_BOUNDARY 32

#define BIGGEST_ALIGNMENT 128

#define STRICT_ALIGNMENT 1

#define INT_TYPE_SIZE 32

#define SHORT_TYPE_SIZE 16

#define LONG_TYPE_SIZE 32

#define LONG_LONG_TYPE_SIZE 64

#define FLOAT_TYPE_SIZE 32

#define DOUBLE_TYPE_SIZE 64

#define LONG_DOUBLE_TYPE_SIZE 64

#define CHAR_TYPE_SIZE 8

#define DEFAULT_SIGNED_CHAR 1

#define MAX_FIXED_MODE_SIZE 64

#define SIZE_TYPE ("long unsigned int")

#define PTRDIFF_TYPE ("long int")

#define WCHAR_TYPE ("int")

#define WINT_TYPE ("unsigned int")


#define FIRST_PSEUDO_REGISTER 21

#define FIXED_REGISTERS {\
  0,0,0,0,0,0,0,0,0,  /* r0-r8, temporary unpreserved */\
  0,0,0,0,            /* r9-r12, temporary preserved */\
  1,                  /* r13, used as __tmp_reg__ */\
  0,                  /* r14, return address */\
  1,                  /* r15, exception/ISR return address */\
  0,                  /* fpW, temporary unpreserved */\
  0,                  /* fpX, arg pointer */\
  1,                  /* fpY, frame pointer */\
  1,                  /* fpZ, stack pointer */\
  1                   /* cc,  condition code */ }

#define CALL_USED_REGISTERS {\
  1,1,1,1,1,1,1,1,1,  /* r0-r8, temporary unpreserved */\
  0,0,0,0,            /* r9-r12, temporary unpreserved */\
  1,                  /* r13, used as __tmp_reg__ */\
  0,                  /* r14, return address */\
  1,                  /* r15, Exception/ISR return address */\
  1,                  /* fpW, temporary unpreserved */\
  1,                  /* fpX, arg pointer */\
  1,                  /* fpY, frame pointer */\
  1,                  /* fpZ, stack pointer */\
  1                   /* cc,  condition code */ }

#define REG_ALLOC_ORDER {\
    0,1,2,3,4,5,6,7,8,       /* temporary unsaved */\
    9,10,11,12,              /* temporary saved */\
    16,                      /* universal pointer */\
    17,                      /* arg pointer */\
    13,	                     /* tmp */\
    14, 		     /* return address */\
    15,			     /* exception/ISR return address */\
    18,                      /* frame pointer */\
    19,                      /* stack pointer */\
    20                       /* condition code */ }

#define HARD_REGNO_NREGS(REGNO, MODE) ((GET_MODE_SIZE (MODE) + UNITS_PER_WORD - 1) / UNITS_PER_WORD)

#define HARD_REGNO_MODE_OK(REGNO, MODE) \
(((REGNO == PTR_W) || (REGNO == PTR_X) || (REGNO == PTR_Y) || (REGNO == PTR_Z)) ? \
  (MODE == SImode) : 1)

#define MODES_TIEABLE_P(MODE1, MODE2) 1

enum reg_class {
  NO_REGS,
  POINTER_REGS,			/* r16 - r19 */
  GENERAL_REGS,			/* r0 - r15 */
  ALL_REGS, LIM_REG_CLASSES
};

#define N_REG_CLASSES (int)LIM_REG_CLASSES

#define REG_CLASS_NAMES {\
		   "NO_REGS",\
		   "POINTER_REGS",  /* r16 - r19 */\
		   "GENERAL_REGS",  /* r0 - r15 */\
		   "ALL_REGS" }

#define PTR_W 16
#define PTR_X 17
#define PTR_Y 18
#define PTR_Z 19

#define REG_CLASS_CONTENTS {\
  {0x000000},	/* NO_REGS */\
  {(1 << PTR_W)|(1 << PTR_X)|(1 << PTR_Y)|(1 << PTR_Z)},\
		/* POINTER_REGS, r16 - r19 */\
  {0x00ffff},	/* GENERAL_REGS, r0 - r15 */\
  {0x1fffff}	/* ALL_REGS */\
}

#define REGNO_REG_CLASS(R) scarts32_regno_reg_class(R)

#define BASE_REG_CLASS GENERAL_REGS

#define INDEX_REG_CLASS NO_REGS

#define REG_CLASS_FROM_LETTER(C) scarts32_reg_class_from_letter(C)

#define REGNO_OK_FOR_BASE_P(r) ((r == PTR_W) || (r == PTR_X) || (r == PTR_Y) || (r == PTR_Z))

#define REGNO_OK_FOR_INDEX_P(r) 0

#define PREFERRED_RELOAD_CLASS(X, CLASS) CLASS

#define SMALL_REGISTER_CLASSES 1

#define CLASS_LIKELY_SPILLED_P(CLASS) (CLASS == POINTER_REGS)

#define CLASS_MAX_NREGS(CLASS, MODE) \
 ((GET_MODE_SIZE (MODE) + UNITS_PER_WORD - 1) / UNITS_PER_WORD)

#define CONST_OK_FOR_LETTER_P(VALUE, C) scarts32_const_ok_for_letter(VALUE, C)

#define CONST_DOUBLE_OK_FOR_LETTER_P(VALUE, C) 0

#define EXTRA_CONSTRAINT(x, c) extra_constraint(x, c)

#define PUSH_ARGS 0

/* Basic Stack Layout */

/* Define this macro if pushing a word onto the stack moves the stack pointer
 * to a smaller address. When we say, "define this macro if ...," it means that
 * the compiler checks this macro only with #ifdef so the precise definition
 * used does not matter. */
#define STACK_GROWS_DOWNWARD 1

/* This macro defines the operation used when something is pushed on the stack.
 * In RTL, a push operation will be (set (mem (STACK_PUSH_CODE (reg sp))) ...)
 * The choices are PRE_DEC, POST_DEC, PRE_INC, and POST_INC. Which of these is
 * correct depends on the stack direction and on whether the stack pointer
 * points to the last item on the stack or whether it points to the space for
 * the next item on the stack.
 * The default is PRE_DEC when STACK_GROWS_DOWNWARD is defined, which is almost
 * always right, and PRE_INC otherwise, which is often wrong. */
#define STACK_PUSH_CODE PRE_DEC

/* Define this macro if the addresses of local variable slots are at negative
 * offsets from the frame pointer. */
#define FRAME_GROWS_DOWNWARD 1

/* Offset from the frame pointer to the first local variable slot to be
 * allocated. If FRAME_GROWS_DOWNWARD, find the next slot's offset by
 * subtracting the first slot's length from STARTING_FRAME_OFFSET.
 * Otherwise, it is found by adding the length of the first slot to the
 * value STARTING_FRAME_OFFSET. */
#define STARTING_FRAME_OFFSET 0

/* Offset from the stack pointer register to the first location at which
 * outgoing arguments are placed. If not specified, the default value of zero
 * is used. This is the proper value for most machines. If ARGS_GROW_DOWNWARD,
 * this is the offset to the location above the first location at which outgoing
 * arguments are placed. */
#define STACK_POINTER_OFFSET FIRST_PARM_OFFSET (0)

/* Offset from the argument pointer register to the first argument's address.
 * On some machines it may depend on the data type of the function.
 * If ARGS_GROW_DOWNWARD, this is the offset to the location above the first
 * argument's address. */
#define FIRST_PARM_OFFSET(FUNDECL) 0 /* FIXME */

/* A C expression whose value is RTL representing the value of the return
 * address for the frame count steps up from the current frame, after the
 * prologue. frameaddr is the frame pointer of the count frame, or the frame
 * pointer of the count − 1 frame if RETURN_ADDR_IN_PREVIOUS_FRAME is defined.
 * The value of the expression must always be the correct address when count is
 * zero, but may be NULL_RTX if there is no way to determine the return address
 * of other frames. */
#define RETURN_ADDR_RTX(COUNT, FRAMEADDR) \
  scarts32_return_addr (COUNT, FRAMEADDR)

/* A C expression whose value is RTL representing the location of the incoming
 * return address at the beginning of any function, before the prologue. This
 * RTL is either a REG, indicating that the return value is saved in `REG', or
 * a MEM representing a location in the stack.
 * You only need to define this macro if you want to support call frame
 * debugging information like that provided by DWARF 2.
 * If this RTL is a REG, you should also define DWARF_FRAME_RETURN_COLUMN to
 * DWARF_FRAME_REGNUM (REGNO). */
#define INCOMING_RETURN_ADDR_RTX \
  gen_rtx_REG (SImode, RA_REGNO)

#define DWARF_FRAME_RETURN_COLUMN \
  DWARF_FRAME_REGNUM (RA_REGNO)

/* A C expression whose value is an integer giving the offset, in bytes, from
 * the value of the stack pointer register to the top of the stack frame at the
 * beginning of any function, before the prologue. The top of the frame is
 * defined to be the value of the stack pointer in the previous frame, just
 * before the call instruction.
 * You only need to define this macro if you want to support call frame
 * debugging information like that provided by DWARF 2. */
#define INCOMING_FRAME_SP_OFFSET 0 /* FIXME */

#define FRAME_POINTER_CFA_OFFSET(FNDECL) 0

#define STACK_POINTER_REGNUM PTR_Z

#define FRAME_POINTER_REGNUM PTR_Y

#define ARG_POINTER_REGNUM PTR_X

#define STATIC_CHAIN_REGNUM PTR_W

#define FRAME_POINTER_REQUIRED frame_pointer_required_p()

#define ELIMINABLE_REGS \
   {{ARG_POINTER_REGNUM, FRAME_POINTER_REGNUM}, \
    {ARG_POINTER_REGNUM, STACK_POINTER_REGNUM}, \
    {FRAME_POINTER_REGNUM, STACK_POINTER_REGNUM}}

#define CAN_ELIMINATE(FROM, TO) 1

#define INITIAL_ELIMINATION_OFFSET(FROM, TO, OFFSET) \
   OFFSET = initial_elimination_offset (FROM, TO)

#define PUSH_ROUNDING(NPUSHED) (((NPUSHED) + 3) & ~3)

#define RETURN_POPS_ARGS(FUNDECL, FUNTYPE, STACK_SIZE) 0

#define FUNCTION_ARG(CUM, MODE, TYPE, NAMED) \
   (function_arg (&(CUM), MODE, TYPE, NAMED))

typedef struct scarts32_args {
  int nregs;			/* # registers available for passing */
  int regno;			/* next available register number */
} CUMULATIVE_ARGS;

#define INIT_CUMULATIVE_ARGS(CUM, FNTYPE, LIBNAME, FNDECL, N_NAMED_ARGS) \
  (init_cumulative_args (&(CUM), FNTYPE, LIBNAME, FNDECL))

#define FUNCTION_ARG_ADVANCE(CUM, MODE, TYPE, NAMED) \
  (function_arg_advance (&CUM, MODE, TYPE, NAMED))

#define FUNCTION_ARG_REGNO_P(r) function_arg_regno_p(r)

extern int scarts32_reg_order[];

#define RET_REGISTER RET_REGNO

#define FUNCTION_VALUE(VALTYPE, FUNC) scarts32_function_value (VALTYPE, FUNC)

#define LIBCALL_VALUE(MODE) scarts32_libcall_value (MODE)

#define FUNCTION_VALUE_REGNO_P(N) ((N) == RET_REGISTER)

#define RETURN_IN_MEMORY(TYPE) ((TYPE_MODE (TYPE) == BLKmode) \
  ? 1 : GET_MODE_SIZE (TYPE_MODE(TYPE)) > UNITS_PER_WORD)

#define STRUCT_VALUE 0

#define EPILOGUE_USES(REGNO) 0

/* Special kinds of addressing.  */
#define HAVE_POST_INCREMENT 1
#define HAVE_POST_DECREMENT 1

#define HAVE_POST_MODIFY_DISP 1

#define CONSTANT_ADDRESS_P(X) CONSTANT_P (X)

#define MAX_REGS_PER_ADDRESS 1

#ifdef REG_OK_STRICT
#  define GO_IF_LEGITIMATE_ADDRESS(mode, operand, ADDR)	\
{							\
  if (legitimate_address_p (mode, operand, 1))		\
    goto ADDR;						\
}
#  else
#  define GO_IF_LEGITIMATE_ADDRESS(mode, operand, ADDR)	\
{							\
  if (legitimate_address_p (mode, operand, 0))		\
    goto ADDR;						\
}
#endif

#define REG_OK_FOR_BASE_NOSTRICT_P(X) \
   (REGNO (X) >= FIRST_PSEUDO_REGISTER || REG_OK_FOR_BASE_STRICT_P(X))

#define REG_OK_FOR_BASE_STRICT_P(X) REGNO_OK_FOR_BASE_P (REGNO (X))

#ifdef REG_OK_STRICT
#  define REG_OK_FOR_BASE_P(X) REG_OK_FOR_BASE_STRICT_P (X)
#else
#  define REG_OK_FOR_BASE_P(X) REG_OK_FOR_BASE_NOSTRICT_P (X)
#endif

#define REG_OK_FOR_INDEX_P(X) 0

#define LEGITIMIZE_ADDRESS(X, OLDX, MODE, WIN)				\
do {                                                                    \
  GO_IF_LEGITIMATE_ADDRESS (MODE, X, WIN)                               \
} while(0)
/* NOTE: maybe something else is more useful */

#define LEGITIMIZE_RELOAD_ADDRESS(X, MODE, OPNUM, TYPE, IND_LEVELS, WIN)    \
do {									    \
    /* do nothing */				                            \
   } while(0)
/* NOTE: maybe something else is more useful */
	
#define GO_IF_MODE_DEPENDENT_ADDRESS(ADDR,LABEL) \
do { \
  if (GET_CODE (ADDR) == POST_INC || GET_CODE (ADDR) == POST_DEC) \
    goto LABEL; \
} while(0)

#define LEGITIMATE_CONSTANT_P(X) 1

#define REGISTER_MOVE_COST(MODE, FROM, TO) ((MODE)==QImode ? 2 : \
					    (MODE)==HImode ? 2 : \
					    (MODE)==SImode ? 2 : \
					    (MODE)==SFmode ? 2 : 4)

#define MEMORY_MOVE_COST(MODE,CLASS,IN) ((MODE)==QImode ? 4 : \
					 (MODE)==HImode ? 4 : \
					 (MODE)==SImode ? 4 : \
					 (MODE)==SFmode ? 4 : 8)

#define MAX_CONDITIONAL_EXECUTE 4

#define REVERSIBLE_CC_MODE(MODE) ((MODE) == CCmode)

#define SLOW_BYTE_ACCESS 1

#define EXTRA_SECTIONS in_rodata

#define EXTRA_SECTION_FUNCTIONS						      \
void									      \
rodata_section (void)							      \
{									      \
  if (in_section != in_rodata)						      \
    {									      \
      fprintf (asm_out_file, "\t.section\t.rodata\n");                        \
      in_section = in_rodata;						      \
    }									      \
}

#define TEXT_SECTION_ASM_OP "\t.section\t.text"

#define DATA_SECTION_ASM_OP "\t.section\t.data"

#define BSS_SECTION_ASM_OP "\t.section\t.bss"

#define READONLY_DATA_SECTION rodata_section

#define JUMP_TABLES_IN_TEXT_SECTION 0

#define ASM_COMMENT_START " ; "

#define ASM_APP_ON "/* #APP */\n"

#define ASM_APP_OFF "/* #NOAPP */\n"

#define IS_ASM_LOGICAL_LINE_SEPARATOR(C) ((C) == '\n' || ((C) == '|'))

#define ASM_OUTPUT_ALIGNED_COMMON(STREAM, NAME, SIZE, ALIGN) \
   scarts32_output_aligned_common ((STREAM), (NAME), (SIZE), (ALIGN))

#define ASM_OUTPUT_ALIGNED_LOCAL(STREAM, NAME, SIZE, ALIGN) \
   scarts32_output_aligned_local ((STREAM), (NAME), (SIZE), (ALIGN))

#define ASM_OUTPUT_ALIGNED_BSS(STREAM, DECL, NAME, SIZE, ALIGN) \
   scarts32_output_aligned_bss ((STREAM), (DECL), (NAME), (SIZE), (ALIGN))

#undef TYPE_OPERAND_FMT
#define TYPE_OPERAND_FMT	"@%s"

#define ASM_OUTPUT_LABELREF(STREAM, NAME) \
    fprintf ((STREAM), "%s", (NAME))

#define ASM_DECLARE_FUNCTION_NAME(FILE, NAME, DECL)                     \
do {                                                                    \
    fprintf(FILE, "\t.type\t%s, ",                                      \
      (* targetm.strip_name_encoding)                                   \
        (IDENTIFIER_POINTER                                             \
        (DECL_ASSEMBLER_NAME (current_function_decl))));                \
    fprintf (FILE, TYPE_OPERAND_FMT, "function");                       \
    putc('\n', FILE);                                                   \
                                                                        \
    ASM_OUTPUT_LABEL (FILE, NAME);                                      \
} while (0)

#define ASM_DECLARE_FUNCTION_SIZE(FILE, NAME, DECL)                     \
  do                                                                    \
    {                                                                   \
      if (!flag_inhibit_size_directive)                                 \
        {                                                               \
          fprintf(FILE, "\t.size\t%s, .-%s\n\n",                        \
            (* targetm.strip_name_encoding)                             \
              (IDENTIFIER_POINTER                                       \
              (DECL_ASSEMBLER_NAME (current_function_decl))),           \
            (* targetm.strip_name_encoding)                             \
              (IDENTIFIER_POINTER                                       \
              (DECL_ASSEMBLER_NAME (current_function_decl))));          \
        }                                                               \
    }                                                                   \
  while (0)

#define GLOBAL_ASM_OP "\t.global\t"

#define ESCAPES \
"\1\1\1\1\1\1\1\1btn\1fr\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\
\0\0\"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\\\0\0\0\
\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\
\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\
\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\
\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\
\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1"

#define STRING_LIMIT  0
#define STRING_ASM_OP NULL

#define ASM_GENERATE_INTERNAL_LABEL(STRING, PREFIX, NUM) \
  sprintf (STRING, "*.%s%d", PREFIX, NUM)

#define ASM_FORMAT_PRIVATE_NAME(OUTPUT, NAME, LABELNO)	\
( (OUTPUT) = (char *) alloca (strlen ((NAME)) + 10),	\
  sprintf ((OUTPUT), ".%s.%d", (NAME), (LABELNO)))

#define HAS_INIT_SECTION 1

#define REGISTER_NAMES {				\
    "r0","r1","r2","r3","r4","r5","r6","r7",		\
    "r8","r9","r10","r11","r12","r13","r14","r15",      \
    "fpw", "fpx", "fpy", "fpz",                         \
    "cc"}

#define FINAL_PRESCAN_INSN(insn, operand, nop) \
  final_prescan_insn (insn, operand,nop)

#define PRINT_OPERAND(STREAM, X, CODE) print_operand((STREAM), X, CODE)

#define PRINT_OPERAND_ADDRESS(STREAM, X) print_operand((STREAM), X, '@')

#define USER_LABEL_PREFIX ""

#define ASM_OUTPUT_SKIP(STREAM, N) fprintf((STREAM), "\t.skip\t%lu\n", N)

#define ASM_OUTPUT_ALIGN(STREAM, POWER) \
do { \
  if ((POWER) != 0) \
    fprintf((STREAM), "\t.p2align\t%d\n", POWER); \
} while (0)

#define CASE_VECTOR_MODE SImode

extern int scarts32_case_values_threshold;

#define CASE_VALUES_THRESHOLD scarts32_case_values_threshold

#undef WORD_REGISTER_OPERATIONS

#define MOVE_MAX UNITS_PER_WORD

#define TRULY_NOOP_TRUNCATION(OUTPREC, INPREC) 1

#define Pmode SImode

#define FUNCTION_MODE SImode

#define DOLLARS_IN_IDENTIFIERS 0

#define NO_DOLLAR_IN_LABEL 1

#define TRAMPOLINE_SIZE 0

#define INITIALIZE_TRAMPOLINE(TRAMP, FNADDR, CXT) \
   internal_error ("trampolines not supported")

#define FUNCTION_PROFILER(FILE, LABELNO)  \
  fprintf (FILE, "/* profiler %d */\n", (LABELNO))

#define ADJUST_INSN_LENGTH(INSN, LENGTH) \
  (LENGTH = adjust_insn_length (INSN, LENGTH))

#define CPP_SPEC "%{posix:-D_POSIX_SOURCE}"

#define CC1_SPEC "%{profile:-p}"

#define CC1PLUS_SPEC "%{!frtti:-fno-rtti} \
    %{!fenforce-eh-specs:-fno-enforce-eh-specs} \
    %{!fexceptions:-fno-exceptions}"

/* Undefine this, because we do not have a regular `as' anyway */
#undef USE_AS_TRADITIONAL_FORMAT

#define LIB_SPEC "-lc -lnosys"
#define LIBGCC_SPEC "-lgcc"
#define STARTFILE_SPEC "crt0.o%s"
#define LINK_GCC_C_SEQUENCE_SPEC "%G %G %L %G %L %G"

#define LINKER_NAME "ld"

#define TEST_HARD_REG_CLASS(CLASS, REGNO) \
  TEST_HARD_REG_BIT (reg_class_contents[ (int) (CLASS)], REGNO)

/* return register r0 */
#define RET_REGNO 0

/* argument 0 register r1*/
#define ARG0_REGNO 1
/* argument 1 register r2*/
#define ARG1_REGNO 2
/* argument 2 register r3*/
#define ARG2_REGNO 3
/* argument 3 register r4*/
#define ARG3_REGNO 4

/* tmp register r13 */
#define TMP_REGNO 13

/* return address register r14*/
#define RA_REGNO 14

/* pseudo-hard register for condition code */
#define CC_REGNO 20

#define SCARTS32_NEAR_JUMP 1
#define SCARTS32_FAR_JUMP  2

/* MWA: stabs debugging format is deprecated
#define DBX_DEBUGGING_INFO    1
#define PREFERRED_DEBUGGING_TYPE DBX_DEBUG

#define DBX_FUNCTION_FIRST
*/

/* Macros for DWARF Output */
#undef PREFERRED_DEBUGGING_TYPE
#define PREFERRED_DEBUGGING_TYPE DWARF2_DEBUG

#define DWARF2_DEBUGGING_INFO 1
#define DWARF2_ASM_LINE_DEBUG_INFO 1
#define DWARF2_UNWIND_INFO 0
#define DWARF2_FRAME_INFO 0

