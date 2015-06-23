; Assembler/disassembler support generator.
; Copyright (C) 2000, 2001, 2005, 2009 Red Hat, Inc.
; This file is part of CGEN.

; Assembler support.

(define (-gen-parse-switch)
  (logit 2 "Generating parse switch ...\n")
  (string-list
   "\
const char * @arch@_cgen_parse_operand
  (CGEN_CPU_DESC, int, const char **, CGEN_FIELDS *);

/* Main entry point for operand parsing.

   This function is basically just a big switch statement.  Earlier versions
   used tables to look up the function to use, but
   - if the table contains both assembler and disassembler functions then
     the disassembler contains much of the assembler and vice-versa,
   - there's a lot of inlining possibilities as things grow,
   - using a switch statement avoids the function call overhead.

   This function could be moved into `parse_insn_normal', but keeping it
   separate makes clear the interface between `parse_insn_normal' and each of
   the handlers.  */

const char *
@arch@_cgen_parse_operand (CGEN_CPU_DESC cd,
			   int opindex,
			   const char ** strp,
			   CGEN_FIELDS * fields)
{
  const char * errmsg = NULL;
  /* Used by scalar operands that still need to be parsed.  */
  " (gen-ifield-default-type) " junk ATTRIBUTE_UNUSED;

  switch (opindex)
    {
"
   (gen-switch 'parse)
"
    default :
      /* xgettext:c-format */
      fprintf (stderr, _(\"Unrecognized field %d while parsing.\\n\"), opindex);
      abort ();
  }

  return errmsg;
}\n\n")
)

; Assembler initialization C code
; Code is appended during processing.

(define -asm-init-code "")
(define (add-asm-init code)
  (set! -asm-init-code (string-append -asm-init-code code))
)

; Return C code to define the assembler init function.
; This is called after opcode_open.

(define (-gen-init-asm-fn)
  (string-append
   "\
void
@arch@_cgen_init_asm (CGEN_CPU_DESC cd)
{
  @arch@_cgen_init_opcode_table (cd);
  @arch@_cgen_init_ibld_table (cd);
  cd->parse_handlers = & @arch@_cgen_parse_handlers[0];
  cd->parse_operand = @arch@_cgen_parse_operand;
#ifdef CGEN_ASM_INIT_HOOK
CGEN_ASM_INIT_HOOK
#endif
"
   -asm-init-code
"}\n\n"
   )
)

; Generate C code that is inserted into the assembler source.

(define (cgen-asm.in)
  (logit 1 "Generating " (current-arch-name) "-asm.in ...\n")
  (string-write
   ; No need for copyright, appended to file with one.
   "\n"
   (lambda () (gen-extra-asm.c (opc-file-path) (current-arch-name)))
   "\n"
   -gen-parse-switch
   (lambda () (gen-handler-table "parse" opc-parse-handlers))
   -gen-init-asm-fn
   )
)

; Disassembler support.

(define (-gen-print-switch)
  (logit 2 "Generating print switch ...\n")
  (string-list
   "\
void @arch@_cgen_print_operand
  (CGEN_CPU_DESC, int, PTR, CGEN_FIELDS *, void const *, bfd_vma, int);

/* Main entry point for printing operands.
   XINFO is a `void *' and not a `disassemble_info *' to not put a requirement
   of dis-asm.h on cgen.h.

   This function is basically just a big switch statement.  Earlier versions
   used tables to look up the function to use, but
   - if the table contains both assembler and disassembler functions then
     the disassembler contains much of the assembler and vice-versa,
   - there's a lot of inlining possibilities as things grow,
   - using a switch statement avoids the function call overhead.

   This function could be moved into `print_insn_normal', but keeping it
   separate makes clear the interface between `print_insn_normal' and each of
   the handlers.  */

void
@arch@_cgen_print_operand (CGEN_CPU_DESC cd,
			   int opindex,
			   void * xinfo,
			   CGEN_FIELDS *fields,
			   void const *attrs ATTRIBUTE_UNUSED,
			   bfd_vma pc,
			   int length)
{
  disassemble_info *info = (disassemble_info *) xinfo;

  switch (opindex)
    {
"
   (gen-switch 'print)
"
    default :
      /* xgettext:c-format */
      fprintf (stderr, _(\"Unrecognized field %d while printing insn.\\n\"),
	       opindex);
    abort ();
  }
}\n\n")
)

; Disassembler initialization C code.
; Code is appended during processing.

(define -dis-init-code "")
(define (add-dis-init code)
  (set! -dis-init-code (string-append -dis-init-code code))
)

; Return C code to define the disassembler init function.

(define (-gen-init-dis-fn)
  (string-append
   "
void
@arch@_cgen_init_dis (CGEN_CPU_DESC cd)
{
  @arch@_cgen_init_opcode_table (cd);
  @arch@_cgen_init_ibld_table (cd);
  cd->print_handlers = & @arch@_cgen_print_handlers[0];
  cd->print_operand = @arch@_cgen_print_operand;
"
   -dis-init-code
"}\n\n"
   )
)

; Generate C code that is inserted into the disassembler source.

(define (cgen-dis.in)
  (logit 1 "Generating " (current-arch-name) "-dis.in ...\n")
  (string-write
   ; No need for copyright, appended to file with one.
   "\n"
   (lambda () (gen-extra-dis.c (opc-file-path) (current-arch-name)))
   "\n"
   -gen-print-switch
   (lambda () (gen-handler-table "print" opc-print-handlers))
   -gen-init-dis-fn
   )
)
