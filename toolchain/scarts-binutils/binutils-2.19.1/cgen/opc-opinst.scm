; Operand instance support.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.

; Return C code to define one instance of operand object OP.
; TYPE is one of "INPUT" or "OUTPUT".

(define (-gen-operand-instance op type)
  (let ((index (op:index op)))
    (string-append "  { "
		   type ", "
		   "\"" (gen-sym op) "\", "
		   (hw-enum (op:type op)) ", "
		   ; FIXME: Revisit CGEN_ prefix, use MODE (FOO) instead.
		   "CGEN_" (mode:enum (op:mode op)) ", "
		   ; FIXME: We don't handle memory properly yet.  Later.
		   (cond ((memory? (op:type op))
			  "0, 0")
			 ((has-attr? op 'SEM-ONLY)
			  "0, 0")
			 ((eq? (hw-index:type index) 'ifield)
			  (if (= (ifld-length (hw-index:value index)) 0)
			      "0, 0"
			      (string-append "OP_ENT ("
					     (string-upcase (gen-sym op))
					     "), 0")))
			 ((eq? (hw-index:type index) 'constant)
			  (string-append "0, "
					 (number->string (hw-index:value index))))
			 (else "0, 0"))
		   ", " (if (op:cond? op) "COND_REF" "0")
		   " },\n"))
)

; Return C code to define arrays of operand instances read from and written
; to by <sformat> SFMT.
; This is based on the semantics of the instruction.
; ??? All runtime chosen values (e.g. a particular register in a register bank)
; is assumed to be selected statically by the instruction.  When some cpu
; violates this assumption (say because a previous instruction determines
; which register(s) the next instruction operates on), this will need
; additional support.

(define (-gen-operand-instance-table sfmt)
  (let ((ins (sfmt-in-ops sfmt))
	(outs (sfmt-out-ops sfmt)))
    ; This used to exclude outputing anything if there were no ins or outs.
    (gen-obj-sanitize
     (sfmt-eg-insn sfmt) ; sanitize based on the example insn
     (string-append
      "static const CGEN_OPINST "
      (gen-sym sfmt) "_ops[] ATTRIBUTE_UNUSED = {\n"
      (string-map (lambda (op) (-gen-operand-instance op "INPUT"))
		  ins)
      (string-map (lambda (op)  (-gen-operand-instance op "OUTPUT"))
		  outs)
      "  { END, (const char *)0, (enum cgen_hw_type)0, (enum cgen_mode)0, (enum cgen_operand_type)0, 0, 0 }\n};\n\n")))
)

(define (-gen-operand-instance-tables)
  (string-write
   "\
/* Operand references.  */

"
   (gen-define-with-symcat "OP_ENT(op) @ARCH@_OPERAND_" "op")
"\
#define INPUT CGEN_OPINST_INPUT
#define OUTPUT CGEN_OPINST_OUTPUT
#define END CGEN_OPINST_END
#define COND_REF CGEN_OPINST_COND_REF

"
   (lambda () (string-write-map -gen-operand-instance-table (current-sfmt-list)))
   "\
#undef OP_ENT
#undef INPUT
#undef OUTPUT
#undef END
#undef COND_REF

"
   )
)

; Return C code for INSN's operand instance table.

(define (gen-operand-instance-ref insn)
  (let* ((sfmt (insn-sfmt insn))
	 (ins (sfmt-in-ops sfmt))
	 (outs (sfmt-out-ops sfmt)))
    (if (and (null? ins) (null? outs))
	"0"
	(string-append "& " (gen-sym sfmt) "_ops[0]")))
)

; Return C code to define a table to lookup an insn's operand instance table.

(define (-gen-insn-opinst-lookup-table)
  (string-list
   "/* Operand instance lookup table.  */\n\n"
   "static const CGEN_OPINST *@arch@_cgen_opinst_table[MAX_INSNS] = {\n"
   "  0,\n" ; null first entry
   (string-list-map
    (lambda (insn)
      (gen-obj-sanitize
       insn
       (string-append "  & " (gen-sym (insn-sfmt insn)) "_ops[0],\n")))
    (current-insn-list))
   "};\n\n"
   "\
/* Function to call before using the operand instance table.  */

void
@arch@_cgen_init_opinst_table (cd)
     CGEN_CPU_DESC cd;
{
  int i;
  const CGEN_OPINST **oi = & @arch@_cgen_opinst_table[0];
  CGEN_INSN *insns = (CGEN_INSN *) cd->insn_table.init_entries;
  for (i = 0; i < MAX_INSNS; ++i)
    insns[i].opinst = oi[i];
}
"
   )
)

; Return the maximum number of operand instances used by any insn.
; If not generating the operand instance table, use a heuristic.

(define (max-operand-instances)
  (if -opcodes-build-operand-instance-table?
      (apply max
	     (map (lambda (insn)
		    (+ (length (sfmt-in-ops (insn-sfmt insn)))
		       (length (sfmt-out-ops (insn-sfmt insn)))))
		  (current-insn-list)))
      8) ; FIXME: for now
)

; Generate $arch-opinst.c.

(define (cgen-opinst.c)
  (logit 1 "Generating " (current-arch-name) "-opinst.c ...\n")

  ; If instruction semantics haven't been analyzed, do that now.
  (if (not (arch-semantics-analyzed? CURRENT-ARCH))
      (begin
	(logit 1 "Instruction semantics weren't analyzed when .cpu file was loaded.\n")
	(logit 1 "Doing so now ...\n")
	(arch-analyze-insns! CURRENT-ARCH
			     #t ; include aliases
			     #t) ; -opcodes-build-operand-instance-table?
	))

  (string-write
   (gen-c-copyright "Semantic operand instances for @arch@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#include \"sysdep.h\"
#include \"ansidecl.h\"
#include \"bfd.h\"
#include \"symcat.h\"
#include \"@prefix@-desc.h\"
#include \"@prefix@-opc.h\"
\n"
   -gen-operand-instance-tables
   -gen-insn-opinst-lookup-table
   )
)
