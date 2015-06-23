; Instruction builder support.
; Copyright (C) 2000, 2001, 2005, 2009 Red Hat, Inc.
; This file is part of CGEN.

; Instruction field support.

(define (-gen-fget-switch)
  (logit 2 "Generating field get switch ...\n")
  (string-list
   "\
int @arch@_cgen_get_int_operand     (CGEN_CPU_DESC, int, const CGEN_FIELDS *);
bfd_vma @arch@_cgen_get_vma_operand (CGEN_CPU_DESC, int, const CGEN_FIELDS *);

/* Getting values from cgen_fields is handled by a collection of functions.
   They are distinguished by the type of the VALUE argument they return.
   TODO: floating point, inlining support, remove cases where result type
   not appropriate.  */

int
@arch@_cgen_get_int_operand (CGEN_CPU_DESC cd ATTRIBUTE_UNUSED,
			     int opindex,
			     const CGEN_FIELDS * fields)
{
  int value;

  switch (opindex)
    {
"
   (gen-switch 'fget)
"
    default :
      /* xgettext:c-format */
      fprintf (stderr, _(\"Unrecognized field %d while getting int operand.\\n\"),
		       opindex);
      abort ();
  }

  return value;
}

bfd_vma
@arch@_cgen_get_vma_operand (CGEN_CPU_DESC cd ATTRIBUTE_UNUSED,
			     int opindex,
			     const CGEN_FIELDS * fields)
{
  bfd_vma value;

  switch (opindex)
    {
"
   (gen-switch 'fget)
"
    default :
      /* xgettext:c-format */
      fprintf (stderr, _(\"Unrecognized field %d while getting vma operand.\\n\"),
		       opindex);
      abort ();
  }

  return value;
}
\n")
)

(define (-gen-fset-switch)
  (logit 2 "Generating field set switch ...\n")
  (string-list
   "\
void @arch@_cgen_set_int_operand  (CGEN_CPU_DESC, int, CGEN_FIELDS *, int);
void @arch@_cgen_set_vma_operand  (CGEN_CPU_DESC, int, CGEN_FIELDS *, bfd_vma);

/* Stuffing values in cgen_fields is handled by a collection of functions.
   They are distinguished by the type of the VALUE argument they accept.
   TODO: floating point, inlining support, remove cases where argument type
   not appropriate.  */

void
@arch@_cgen_set_int_operand (CGEN_CPU_DESC cd ATTRIBUTE_UNUSED,
			     int opindex,
			     CGEN_FIELDS * fields,
			     int value)
{
  switch (opindex)
    {
"
   (gen-switch 'fset)
"
    default :
      /* xgettext:c-format */
      fprintf (stderr, _(\"Unrecognized field %d while setting int operand.\\n\"),
		       opindex);
      abort ();
  }
}

void
@arch@_cgen_set_vma_operand (CGEN_CPU_DESC cd ATTRIBUTE_UNUSED,
			     int opindex,
			     CGEN_FIELDS * fields,
			     bfd_vma value)
{
  switch (opindex)
    {
"
   (gen-switch 'fset)
"
    default :
      /* xgettext:c-format */
      fprintf (stderr, _(\"Unrecognized field %d while setting vma operand.\\n\"),
		       opindex);
      abort ();
  }
}
\n")
)

; Utilities of cgen-ibld.h.

; Return a list of operands the assembler syntax uses.
; This is a subset of the fields of the insn.

(define (ifmt-opcode-operands ifmt)
  (map ifld-get-value
       (find (lambda (elm) (not (number? (ifld-get-value elm))))
	     (ifmt-ifields ifmt)))
)

; Subroutine of gen-insn-builders to generate the builder for one insn.
; FIXME: wip.

(define (gen-insn-builder insn)
  (let* ((ifmt (insn-ifmt insn))
	 (operands (ifmt-opcode-operands ifmt))
	 (length (ifmt-length ifmt)))
    (gen-obj-sanitize
     insn
     (string-append
      "#define @ARCH@_IBLD_"
      (string-upcase (gen-sym insn))
      "(endian, buf, lenp"
      (gen-c-args (map gen-sym operands))
      ")\n"
      "\n")))
)

(define (gen-insn-builders)
  (string-write
   "\
/* For each insn there is an @ARCH@_IBLD_<NAME> macro that builds the
   instruction in the supplied buffer.  For architectures where it's
   possible to represent all machine codes as host integer values it
   would be nicer to have these return the instruction rather than store
   it in BUF.  For consistency with variable length ISA's this does not.  */

"
   (lambda () (string-write-map gen-insn-builder (current-insn-list)))
   )
)

; Generate the C code for dealing with operands.

(define (-gen-insert-switch)
  (logit 2 "Generating insert switch ...\n")
  (string-list
   "\
const char * @arch@_cgen_insert_operand
  (CGEN_CPU_DESC, int, CGEN_FIELDS *, CGEN_INSN_BYTES_PTR, bfd_vma);

/* Main entry point for operand insertion.

   This function is basically just a big switch statement.  Earlier versions
   used tables to look up the function to use, but
   - if the table contains both assembler and disassembler functions then
     the disassembler contains much of the assembler and vice-versa,
   - there's a lot of inlining possibilities as things grow,
   - using a switch statement avoids the function call overhead.

   This function could be moved into `parse_insn_normal', but keeping it
   separate makes clear the interface between `parse_insn_normal' and each of
   the handlers.  It's also needed by GAS to insert operands that couldn't be
   resolved during parsing.  */

const char *
@arch@_cgen_insert_operand (CGEN_CPU_DESC cd,
			     int opindex,
			     CGEN_FIELDS * fields,
			     CGEN_INSN_BYTES_PTR buffer,
			     bfd_vma pc ATTRIBUTE_UNUSED)
{
  const char * errmsg = NULL;
  unsigned int total_length = CGEN_FIELDS_BITSIZE (fields);

  switch (opindex)
    {
"
   (gen-switch 'insert)
"
    default :
      /* xgettext:c-format */
      fprintf (stderr, _(\"Unrecognized field %d while building insn.\\n\"),
	       opindex);
      abort ();
  }

  return errmsg;
}\n\n")
)

(define (-gen-extract-switch)
  (logit 2 "Generating extract switch ...\n")
  (string-list
   "\
int @arch@_cgen_extract_operand
  (CGEN_CPU_DESC, int, CGEN_EXTRACT_INFO *, CGEN_INSN_INT, CGEN_FIELDS *, bfd_vma);

/* Main entry point for operand extraction.
   The result is <= 0 for error, >0 for success.
   ??? Actual values aren't well defined right now.

   This function is basically just a big switch statement.  Earlier versions
   used tables to look up the function to use, but
   - if the table contains both assembler and disassembler functions then
     the disassembler contains much of the assembler and vice-versa,
   - there's a lot of inlining possibilities as things grow,
   - using a switch statement avoids the function call overhead.

   This function could be moved into `print_insn_normal', but keeping it
   separate makes clear the interface between `print_insn_normal' and each of
   the handlers.  */

int
@arch@_cgen_extract_operand (CGEN_CPU_DESC cd,
			     int opindex,
			     CGEN_EXTRACT_INFO *ex_info,
			     CGEN_INSN_INT insn_value,
			     CGEN_FIELDS * fields,
			     bfd_vma pc)
{
  /* Assume success (for those operands that are nops).  */
  int length = 1;
  unsigned int total_length = CGEN_FIELDS_BITSIZE (fields);

  switch (opindex)
    {
"
   (gen-switch 'extract)
"
    default :
      /* xgettext:c-format */
      fprintf (stderr, _(\"Unrecognized field %d while decoding insn.\\n\"),
	       opindex);
      abort ();
    }

  return length;
}\n\n")
)

; Utilities of cgen-ibld.in.

; Emit a function to call to initialize the ibld tables.

(define (-gen-ibld-init-fn)
  (string-write
   "\
/* Function to call before using the instruction builder tables.  */

void
@arch@_cgen_init_ibld_table (CGEN_CPU_DESC cd)
{
  cd->insert_handlers = & @arch@_cgen_insert_handlers[0];
  cd->extract_handlers = & @arch@_cgen_extract_handlers[0];

  cd->insert_operand = @arch@_cgen_insert_operand;
  cd->extract_operand = @arch@_cgen_extract_operand;

  cd->get_int_operand = @arch@_cgen_get_int_operand;
  cd->set_int_operand = @arch@_cgen_set_int_operand;
  cd->get_vma_operand = @arch@_cgen_get_vma_operand;
  cd->set_vma_operand = @arch@_cgen_set_vma_operand;
}
"
   )
)

; Generate the C header for building instructions.

(define (cgen-ibld.h)
  (logit 1 "Generating " (current-arch-name) "-ibld.h ...\n")
  (string-write
   (gen-c-copyright "Instruction builder for @arch@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#ifndef @ARCH@_IBLD_H
#define @ARCH@_IBLD_H

"
   (lambda () (gen-extra-ibld.h (opc-file-path) (current-arch-name)))
   "\n"
   gen-insn-builders
   "
#endif /* @ARCH@_IBLD_H */
"
   )
)

; Generate the C support for building instructions.

(define (cgen-ibld.in)
  (logit 1 "Generating " (current-arch-name) "-ibld.in ...\n")
  (string-write
   ; No need for copyright, appended to file with one.
   "\n"
   -gen-insert-switch
   -gen-extract-switch
   (lambda () (gen-handler-table "insert" opc-insert-handlers))
   (lambda () (gen-handler-table "extract" opc-extract-handlers))
   -gen-fget-switch
   -gen-fset-switch
   -gen-ibld-init-fn
   )
)
