; CPU family related simulator generator, excluding decoding and model support.
; Copyright (C) 2000, 2001, 2009 Red Hat, Inc.
; This file is part of CGEN.

; Notes:
; - Add support to generate copies of semantic code and perform constant
;   folding based on selected mach.  This would collapse out untaken branches
;   of tests on (current-mach).

; Utilities of cgen-cpu.h.

; Print various parameters of the cpu family.
; A "cpu family" here is a collection of variants of a particular architecture
; that share sufficient commonality that they can be handled together.

(define (-gen-cpu-defines)
  (string-append
   "\
/* Maximum number of instructions that are fetched at a time.
   This is for LIW type instructions sets (e.g. m32r).  */
#define MAX_LIW_INSNS " (number->string (state-liw-insns))
   "\n\

/* Maximum number of instructions that can be executed in parallel.  */
#define MAX_PARALLEL_INSNS " (number->string (state-parallel-insns))
   "\n\n"
;   (gen-enum-decl '@cpu@_virtual
;		  "@cpu@ virtual insns"
;		  "@ARCH@_INSN_" ; not @CPU@ to match CGEN_INSN_TYPE in opc.h
;		  '((x-invalid 0)
;		    (x-before -1) (x-after -2)
;		    (x-begin -3) (x-chain -4) (x-cti-chain -5)))
   )
)

; Return a boolean indicating if hardware element HW needs storage allocated
; for it in the SIM_CPU struct.

(define (hw-need-storage? hw)
  (and (register? hw) (not (obj-has-attr? hw 'VIRTUAL)))
)

; Subroutine of -gen-hardware-types to generate the struct containing
; hardware elements of one isa.

(define (-gen-hardware-struct hw-list)
  (if (null? hw-list)
      ; If struct is empty, leave it out to simplify generated code.
      ""
      (string-list-map (lambda (hw)
			 (string-list
			  (gen-decl hw)
			  (gen-obj-sanitize hw
					    (string-list
					     (send hw 'gen-get-macro)
					     (send hw 'gen-set-macro)))))
		       (find hw-need-storage? hw-list)))
  )

; Return C type declarations of all of the hardware elements.
; The name of the type is prepended with the cpu family name.

(define (-gen-hardware-types)
  (string-list
   "/* CPU state information.  */\n"
   "typedef struct {\n"
   "  /* Hardware elements.  */\n"
   "  struct {\n"
   (-gen-hardware-struct 
    (find (lambda (hw)
	    (or (not (with-multiple-isa?))
		(>= (count-common
		     (current-keep-isa-name-list)
		     (bitset-attr->list (obj-attr-value hw 'ISA)))
		    1)))
	  (current-hw-list))
    )
   "  } hardware;\n"
   "#define CPU_CGEN_HW(cpu) (& (cpu)->cpu_data.hardware)\n"
   ;"  /* CPU profiling state information.  */\n"
   ;"  struct {\n"
   ;(string-list-map (lambda (hw) (send hw 'gen-profile-decl))
   ;		    (find hw-profilable? (current-hw-list)))
   ;"  } profile;\n"
   ;"#define CPU_CGEN_PROFILE(cpu) (& (cpu)->cpu_data.profile)\n"
   "} @CPU@_CPU_DATA;\n\n"
   ; If there are any virtual regs, output get/set macros for them.
   (let ((virtual-regs (find (lambda (hw)
			       (and (register? hw)
				    (obj-has-attr? hw 'VIRTUAL)))
			     (current-hw-list)))
	 (orig-with-parallel? (with-parallel?))
	 (result ""))
     (set-with-parallel?! #f)
     (if (not (null? virtual-regs))
	 (set! result
	       (string-list
		"/* Virtual regs.  */\n\n"
		(string-list-map (lambda (hw)
				   (logit 3 "Generating get/set for " (obj:name hw)
					  " ...\n")
				   (gen-obj-sanitize hw
						     (string-list
						      (send hw 'gen-get-macro)
						      (send hw 'gen-set-macro))))
				 virtual-regs)
		"\n"
		)))
     (set-with-parallel?! orig-with-parallel?)
     result)
   )
)

; Return the declaration of register access functions.

(define (-gen-cpu-reg-access-decls)
  (string-list
   "/* Cover fns for register access.  */\n"
   (string-list-map (lambda (hw)
		      (gen-reg-access-decl hw
					   "@cpu@"
					   (gen-type hw)
					   (hw-scalar? hw)))
		    (find register? (current-hw-list)))
   "\n"
   "/* These must be hand-written.  */\n"
   "extern CPUREG_FETCH_FN @cpu@_fetch_register;\n"
   "extern CPUREG_STORE_FN @cpu@_store_register;\n"
   "\n")
)

; Generate type of struct holding model state while executing.

(define (-gen-model-decls)
  (logit 2 "Generating model decls ...\n")
  (string-list
   (string-list-map
    (lambda (model)
      (string-list
       "typedef struct {\n"
       (if (null? (model:state model))
	   "  int empty;\n" ; ensure struct isn't empty so it compiles
	   (string-map (lambda (var)
			 (string-append "  "
					(mode:c-type (mode:lookup (cadr var)))
					" "
					(gen-c-symbol (car var))
					";\n"))
		       (model:state model)))
       "} MODEL_" (string-upcase (gen-sym model)) "_DATA;\n\n"
       ))
    (current-model-list))
   )
)

; Utility of -gen-extract-macros to generate a macro to define the local
; vars to contain extracted field values and the code to assign them
; for <iformat> IFMT.

(define (-gen-extract-ifmt-macro ifmt)
  (logit 2 "Processing format " (obj:name ifmt) " ...\n")
  (string-list
   (gen-define-ifmt-ifields ifmt "" #t #f)
   (gen-extract-ifmt-ifields ifmt "" #t #f)
   ; We don't need an extra blank line here as gen-extract-ifields adds one.
   )
)

; Generate macros to extract instruction fields.

(define (-gen-extract-macros)
  (logit 2 "Generating extraction macros ...\n")
  (string-list
   "\
/* Macros to simplify extraction, reading and semantic code.
   These define and assign the local vars that contain the insn's fields.  */
\n"
   (string-list-map -gen-extract-ifmt-macro (current-ifmt-list))
   )
)

; Utility of -gen-parallel-exec-type to generate the definition of one
; structure in PAREXEC.
; SFMT is an <sformat> object.

(define (-gen-parallel-exec-elm sfmt)
  (string-append
   "    struct { /* " (obj:comment sfmt) " */\n"
   (let ((sem-ops
	  ((if (with-parallel-write?) sfmt-out-ops sfmt-in-ops) sfmt)))
     (if (null? sem-ops)
	 "      int empty;\n" ; ensure struct isn't empty so it compiles
	 (string-map
	  (lambda (op)
	    (logit 2 "Processing operand " (obj:name op) " of format "
		   (obj:name sfmt) " ...\n")
	      (if (with-parallel-write?)
		  (let ((index-type (and (op-save-index? op)
					 (gen-index-type op sfmt))))
		    (string-append "      " (gen-type op)
				   " " (gen-sym op) ";\n"
				   (if index-type
				       (string-append "      " index-type 
						      " " (gen-sym op) "_idx;\n")
				       "")))
		  (string-append "      "
				 (gen-type op)
				 " "
				 (gen-sym op)
				 ";\n")))
	  sem-ops)))
   "    } " (gen-sym sfmt) ";\n"
   )
)

; Generate the definition of the structure that holds register values, etc.
; for use during parallel execution.  When instructions are executed parallelly
; either
; - their inputs are read before their outputs are written.  Thus we have to
; fetch the input values of several instructions before executing any of them.
; - or their outputs are queued here first and then written out after all insns
; have executed.
; The fetched/queued values are stored in an array of PAREXEC structs, one
; element per instruction.

(define (-gen-parallel-exec-type)
  (logit 2 "Generating PAREXEC type ...\n")
  (string-append
   (if (with-parallel-write?)
       "/* Queued output values of an instruction.  */\n"
       "/* Fetched input values of an instruction.  */\n")
   "\

struct parexec {
  union {\n"
   (string-map -gen-parallel-exec-elm (current-sfmt-list))
   "\
  } operands;
  /* For conditionally written operands, bitmask of which ones were.  */
  int written;
};\n\n"
   )
)

; Generate the TRACE_RECORD struct definition.
; This struct will hold all necessary data for doing tracing and profiling
; (e.g. register numbers).  The goal is to remove all tracing code from the
; semantic code.  Then the fast/full distinction needn't use conditionals to
; discard/include the tracing/profiling code.

(define (-gen-trace-record-type)
  (string-list
   "\
/* Collection of various things for the trace handler to use.  */

typedef struct trace_record {
  IADDR pc;
  /* FIXME:wip */
} TRACE_RECORD;
\n"
   )
)

; Utilities of cgen-cpu.c

; Get/set fns for every register.

(define (-gen-cpu-reg-access-defns)
  (string-list-map
   (lambda (hw)
     (let ((scalar? (hw-scalar? hw))
	   (name (obj:name hw))
	   (getter (hw-getter hw))
	   (setter (hw-setter hw)))
       (gen-reg-access-defn hw
			    "@cpu@"
			    (gen-type hw)
			    scalar?
			    (if getter
				(string-append
				 "  return GET_"
				 (string-upcase (gen-c-symbol name))
				 " ("
				 (if scalar? "" "regno")
				 ");\n")
				(string-append
				 "  return CPU ("
				 (gen-c-symbol name)
				 (if scalar? "" "[regno]")
				 ");\n"))
			    (if setter
				(string-append
				 "  SET_"
				 (string-upcase (gen-c-symbol name))
				 " ("
				 (if scalar? "" "regno, ")
				 "newval);\n")
				(string-append
				 "  CPU ("
				 (gen-c-symbol name)
				 (if scalar? "" "[regno]")
				 ") = newval;\n")))))
   (find (lambda (hw) (register? hw))
	 (current-hw-list)))
)

; Generate a function to record trace results in a trace record.

(define (-gen-cpu-record-results)
  (string-list
   "\
/* Record trace results for INSN.  */

void
@cpu@_record_trace_results (SIM_CPU *current_cpu, CGEN_INSN *insn,
			    int *indices, TRACE_RECORD *tr)
{\n"
   "}\n"
   )
)

; Utilities of cgen-read.c.
; Parallel-read support is not currently used by any port and this code
; has been left to bitrot.  Don't delete it just yet.

; Return C code to fetch and save all input operands to instructions with
; <sformat> SFMT.

(define (-gen-read-args sfmt)
  (string-map (lambda (op) (op:read op sfmt))
	      (sfmt-in-ops sfmt))
)

; Utility of -gen-read-switch to generate a switch case for <sformat> SFMT.

(define (-gen-read-case sfmt)
  (logit 2 "Processing read switch case for \"" (obj:name sfmt) "\" ...\n")
  (string-list
   "    CASE (read, READ_" (string-upcase (gen-sym sfmt)) ") : "
   "/* " (obj:comment sfmt) " */\n"
   "    {\n"
   (gen-define-field-macro (if (with-scache?) sfmt #f))
   (gen-define-parallel-operand-macro sfmt)
   (gen-define-ifields (sfmt-iflds sfmt) (sfmt-length sfmt) "      " #f)
   (gen-extract-ifields (sfmt-iflds sfmt) (sfmt-length sfmt) "      " #f)
   (-gen-read-args sfmt)
   (gen-undef-parallel-operand-macro sfmt)
   (gen-undef-field-macro sfmt)
   "    }\n"
   "    BREAK (read);\n\n"
   )
)

; Generate the guts of a C switch statement to read insn operands.
; The switch is based on instruction formats.

(define (-gen-read-switch)
  (logit 2 "Processing readers ...\n")
  (string-write-map -gen-read-case (current-sfmt-list))
)

; Utilities of cgen-write.c.

; This is the other way of implementing parallel execution support.
; Instead of fetching all the input operands first, write all the output
; operands and their addresses to holding variables, and then run a
; post-processing pass to update the cpu state.
;
; There are separate implementations for semantics as functions and semantics
; as one big switch.  For the function case we create a function that is a
; switch on each semantic format and loops writing each insn's results back.
; For the switch case we add cases to the switch to handle the write back,
; and it is up to the pbb compiler to include them in the generated "code".

; Return C code to fetch and save all output operands to instructions with
; <sformat> SFMT.

(define (-gen-write-args sfmt)
  (string-map (lambda (op) (op:write op sfmt))
	      (sfmt-out-ops sfmt))
)

; Utility of gen-write-switch to generate a switch case for <sformat> SFMT.
; If INSN is non-#f, it is the <insn> object of the insn in which case
; the case is named after the insn not the format.  This is done because
; current sem-switch support emits one handler per insn instead of per sfmt.

(define (-gen-write-case sfmt insn)
  (logit 2 "Processing write switch case for \"" (obj:name sfmt) "\" ...\n")
  (string-list
   (if insn
       (string-list /indent
		    "CASE (sem, INSN_WRITE_"
		    (string-upcase (gen-sym insn)) ") : ")
       (string-list /indent
		    "case @CPU@_"
		    (string-upcase (gen-sym sfmt)) " : "))
   "/* "
   (if insn
       (string-list (insn-syntax insn))
       (obj:comment sfmt))
   " */\n"
   /indent "  {\n"
   (if insn
       (string-list
	/indent
	"    SEM_ARG sem_arg = SEM_SEM_ARG (vpc, sc);\n"
	/indent
	"    const ARGBUF *abuf = SEM_ARGBUF (sem_arg)->fields.write.abuf;\n")
       "")
   (gen-define-field-macro (if (with-scache?) sfmt #f))
   (gen-define-parallel-operand-macro sfmt)
   /indent
   "    int UNUSED written = abuf->written;\n"
   ;(gen-define-ifields (sfmt-iflds sfmt) (sfmt-length sfmt) "  " #f) - used by cgen-read.c
   ;(gen-extract-ifields (sfmt-iflds sfmt) (sfmt-length sfmt) "  " #f) - used by cgen-read.c
   (if insn
       (string-list /indent "    IADDR UNUSED pc = abuf->addr;\n")
       "")
   (if (and insn (insn-cti? insn))
       (string-list /indent
		    "    SEM_BRANCH_INIT\n") ; no trailing `;' on purpose
       "")
   (if insn
       (string-list /indent "    vpc = SEM_NEXT_VPC (sem_arg, pc, 0);\n")
       "")
   "\n"
   (/indent-add 4)
   (-gen-write-args sfmt)
   (/indent-add -4)
   "\n"
   (if (and insn (insn-cti? insn))
       (string-list /indent "  SEM_BRANCH_FINI (vpc);\n")
       "")
   (gen-undef-parallel-operand-macro sfmt)
   (gen-undef-field-macro sfmt)
   /indent "  }\n"
   (if insn
       (string-list /indent "  NEXT (vpc);\n")
       (string-list /indent "  break;\n"))
   "\n"
   )
)

; Generate the guts of a C switch statement to write insn operands.
; The switch is based on instruction formats.
; ??? This will generate cases for formats that don't need it.
; E.g. on the m32r all 32 bit insns can't be executed in parallel.
; It's easier to generate the code anyway so we do.

(define (-gen-write-switch)
  (logit 2 "Processing writers ...\n")
  (string-write-map (lambda (sfmt)
		      (-gen-write-case sfmt #f))
		    (current-sfmt-list))
)

; Utilities of cgen-semantics.c.

; Return name of semantic fn for INSN.

(define (-gen-sem-fn-name insn)
  ;(string-append "sem_" (gen-sym insn))
  (gen-sym insn)
)

; Return semantic fn table entry for INSN.

(define (-gen-sem-fn-table-entry insn)
  (string-list
   "  { "
   "@PREFIX@_INSN_"
   (string-upcase (gen-sym insn))
   ", "
   "SEM_FN_NAME (@prefix@," (-gen-sem-fn-name insn) ")"
   " },\n"
   )
)

; Return C code to define a table of all semantic fns and a function to
; add the info to the insn descriptor table.

(define (-gen-semantic-fn-table)
  (string-write
   "\
/* Table of all semantic fns.  */

static const struct sem_fn_desc sem_fns[] = {\n"

   (lambda ()
     (string-write-map -gen-sem-fn-table-entry
		       (non-alias-insns (current-insn-list))))

   "\
  { 0, 0 }
};

/* Add the semantic fns to IDESC_TABLE.  */

void
SEM_FN_NAME (@prefix@,init_idesc_table) (SIM_CPU *current_cpu)
{
  IDESC *idesc_table = CPU_IDESC (current_cpu);
  const struct sem_fn_desc *sf;
  int mach_num = MACH_NUM (CPU_MACH (current_cpu));

  for (sf = &sem_fns[0]; sf->fn != 0; ++sf)
    {
      const CGEN_INSN *insn = idesc_table[sf->index].idata;
      int valid_p = (CGEN_INSN_VIRTUAL_P (insn)
		     || CGEN_INSN_MACH_HAS_P (insn, mach_num));
#if FAST_P
      if (valid_p)
	idesc_table[sf->index].sem_fast = sf->fn;
      else
	idesc_table[sf->index].sem_fast = SEM_FN_NAME (@prefix@,x_invalid);
#else
      if (valid_p)
	idesc_table[sf->index].sem_full = sf->fn;
      else
	idesc_table[sf->index].sem_full = SEM_FN_NAME (@prefix@,x_invalid);
#endif
    }
}
\n"
   )
)

; Return C code to perform the semantics of INSN.

(define (gen-semantic-code insn)
  (string-append
   (if (and (insn-real? insn)
	    (isa-setup-semantics (current-isa)))
       (string-append
	"  "
	(rtl-c VOID (isa-setup-semantics (current-isa)) nil
	       #:rtl-cover-fns? #t
	       #:owner insn)
	"\n")
       "")

   ; Indicate generating code for INSN.
   ; Use the compiled form if available.
   ; The case when they're not available is for virtual insns.
   (let ((sem (insn-compiled-semantics insn)))
     (if sem
	 (rtl-c-parsed VOID sem nil
		       #:rtl-cover-fns? #t #:owner insn)
	 (rtl-c VOID (insn-semantics insn) nil
		#:rtl-cover-fns? #t #:owner insn))))
)

; Return definition of C function to perform INSN.
; This version handles the with-scache case.

(define (-gen-scache-semantic-fn insn)
  (logit 2 "Processing semantics for " (obj:name insn) ": \"" (insn-syntax insn) "\" ...\n")
  (set! -with-profile? -with-profile-fn?)
  (let ((profile? (and (with-profile?)
		       (not (obj-has-attr? insn 'VIRTUAL))))
	(parallel? (with-parallel?))
	(cti? (insn-cti? insn))
	(insn-len (insn-length-bytes insn)))
    (string-list
     "/* " (obj:str-name insn) ": " (insn-syntax insn) " */\n\n"
     "static SEM_PC\n"
     "SEM_FN_NAME (@prefix@," (gen-sym insn) ")"
     (if (and parallel? (not (with-generic-write?)))
	 " (SIM_CPU *current_cpu, SEM_ARG sem_arg, PAREXEC *par_exec)\n"
	 " (SIM_CPU *current_cpu, SEM_ARG sem_arg)\n")
     "{\n"
     (gen-define-field-macro (insn-sfmt insn))
     (if (and parallel? (not (with-generic-write?)))
	 (gen-define-parallel-operand-macro (insn-sfmt insn))
	 "")
     "  ARGBUF *abuf = SEM_ARGBUF (sem_arg);\n"
     ; Unconditionally written operands are not recorded here.
     "  int UNUSED written = 0;\n"
     ; The address of this insn, needed by extraction and semantic code.
     ; Note that the address recorded in the cpu state struct is not used.
     ; For faster engines that copy will be out of date.
     "  IADDR UNUSED pc = abuf->addr;\n"
     (if (and cti? (not parallel?))
	 "  SEM_BRANCH_INIT\n" ; no trailing `;' on purpose
	 "")
     (string-list "  SEM_PC vpc = SEM_NEXT_VPC (sem_arg, pc, "
		  (number->string insn-len)
		  ");\n")
     "\n"
     (gen-semantic-code insn) "\n"
     ; Only update what's been written if some are conditionally written.
     ; Otherwise we know they're all written so there's no point in
     ; keeping track.
     (if (-any-cond-written? (insn-sfmt insn))
	 "  abuf->written = written;\n"
	 "")
     (if (and cti? (not parallel?))
	 "  SEM_BRANCH_FINI (vpc);\n"
	 "")
     "  return vpc;\n"
     (if (and parallel? (not (with-generic-write?)))
	 (gen-undef-parallel-operand-macro (insn-sfmt insn))
	 "")
     (gen-undef-field-macro (insn-sfmt insn))
     "}\n\n"
     ))
)

; Return definition of C function to perform INSN.
; This version handles the without-scache case.
; ??? TODO: multiword insns.

(define (-gen-no-scache-semantic-fn insn)
  (logit 2 "Processing semantics for " (obj:name insn) ": \"" (insn-syntax insn) "\" ...\n")
  (set! -with-profile? -with-profile-fn?)
  (let ((profile? (and (with-profile?)
		       (not (obj-has-attr? insn 'VIRTUAL))))
	(parallel? (with-parallel?))
	(cti? (insn-cti? insn))
	(insn-len (insn-length-bytes insn)))
    (string-list
     "/* " (obj:str-name insn) ": " (insn-syntax insn) " */\n\n"
     "static SEM_STATUS\n"
     "SEM_FN_NAME (@prefix@," (gen-sym insn) ")"
     (if (and parallel? (not (with-generic-write?)))
	 " (SIM_CPU *current_cpu, SEM_ARG sem_arg, PAREXEC *par_exec, CGEN_INSN_INT insn)\n"
	 " (SIM_CPU *current_cpu, SEM_ARG sem_arg, CGEN_INSN_INT insn)\n")
     "{\n"
     (if (and parallel? (not (with-generic-write?)))
	 (gen-define-parallel-operand-macro (insn-sfmt insn))
	 "")
     "  SEM_STATUS status = 0;\n" ; ??? wip
     "  ARGBUF *abuf = SEM_ARGBUF (sem_arg);\n"
     (gen-define-field-macro (if (with-scache?) (insn-sfmt insn) #f))
     ; Unconditionally written operands are not recorded here.
     "  int UNUSED written = 0;\n"
     "  IADDR UNUSED pc = GET_H_PC ();\n"
     (if (and cti? (not parallel?))
	 "  SEM_BRANCH_INIT\n" ; no trailing `;' on purpose
	 "")
     (string-list "  SEM_PC vpc = SEM_NEXT_VPC (sem_arg, pc, "
		  (number->string insn-len)
		  ");\n")
     (string-list (gen-define-ifmt-ifields (insn-ifmt insn) "  " #f #t)
		  (gen-sfmt-op-argbuf-defns (insn-sfmt insn))
		  (gen-extract-ifmt-ifields (insn-ifmt insn) "  " #f #t)
		  (gen-sfmt-op-argbuf-assigns (insn-sfmt insn)))
     "\n"
     (gen-semantic-code insn) "\n"
     ; Only update what's been written if some are conditionally written.
     ; Otherwise we know they're all written so there's no point in
     ; keeping track.
     (if (-any-cond-written? (insn-sfmt insn))
	 "  abuf->written = written;\n"
	 "")
     ; SEM_{,N}BRANCH_FINI are user-supplied macros.
     (if (not parallel?)
	 (string-list
	  (if cti?
	      "  SEM_BRANCH_FINI (vpc, "
	      "  SEM_NBRANCH_FINI (vpc, ")
	  (gen-bool-attrs (obj-atlist insn) gen-attr-mask)
	  ");\n")
	 "")
     (gen-undef-field-macro (insn-sfmt insn))
     "  return status;\n"
     (if (and parallel? (not (with-generic-write?)))
	 (gen-undef-parallel-operand-macro (insn-sfmt insn))
	 "")
     "}\n\n"
     ))
)

(define (-gen-all-semantic-fns)
  (logit 2 "Processing semantics ...\n")
  (let ((insns (non-alias-insns (current-insn-list))))
    (if (with-scache?)
	(string-write-map -gen-scache-semantic-fn insns)
	(string-write-map -gen-no-scache-semantic-fn insns)))
)

; Utility of -gen-sem-case to return the mask of operands always written
; to in <sformat> SFMT.
; ??? Not currently used.

(define (-uncond-written-mask sfmt)
  (apply + (map (lambda (op)
		  (if (op:cond? op)
		      0
		      (logsll 1 (op:num op))))
		(sfmt-out-ops sfmt)))
)

; Utility of -gen-sem-case to return #t if any operand in <sformat> SFMT is
; conditionally written to.

(define (-any-cond-written? sfmt)
  (any-true? (map op:cond? (sfmt-out-ops sfmt)))
)

; Generate a switch case to perform INSN.

(define (-gen-sem-case insn parallel?)
  (logit 2 "Processing "
	 (if parallel? "parallel " "")
	 "semantic switch case for \"" (insn-syntax insn) "\" ...\n")
  (set! -with-profile? -with-profile-sw?)
  (let ((cti? (insn-cti? insn))
	(insn-len (insn-length-bytes insn)))
    (string-list
     ; INSN_ is prepended here and not elsewhere to avoid name collisions
     ; with symbols like AND, etc.
     "  CASE (sem, "
     "INSN_"
     (if parallel? "PAR_" "")
     (string-upcase (gen-sym insn)) ") : "
     "/* " (insn-syntax insn) " */\n"
     "{\n"
     "  SEM_ARG sem_arg = SEM_SEM_ARG (vpc, sc);\n"
     "  ARGBUF *abuf = SEM_ARGBUF (sem_arg);\n"
     (gen-define-field-macro (if (with-scache?) (insn-sfmt insn) #f))
     (if (and parallel? (not (with-generic-write?)))
	 (gen-define-parallel-operand-macro (insn-sfmt insn))
	 "")
     ; Unconditionally written operands are not recorded here.
     "  int UNUSED written = 0;\n"
     ; The address of this insn, needed by extraction and semantic code.
     ; Note that the address recorded in the cpu state struct is not used.
     "  IADDR UNUSED pc = abuf->addr;\n"
     (if (and cti? (not parallel?))
	 "  SEM_BRANCH_INIT\n" ; no trailing `;' on purpose
	 "")
     (if (with-scache?)
	 ""
	 (string-list (gen-define-ifmt-ifields (insn-ifmt insn) "  " #f #t)
		      (gen-extract-ifmt-ifields (insn-ifmt insn) "  " #f #t)
		      "\n"))
     (string-list "  vpc = SEM_NEXT_VPC (sem_arg, pc, "
		  (number->string insn-len)
		  ");\n")
     "\n"
     (gen-semantic-code insn) "\n"
     ; Only update what's been written if some are conditionally written.
     ; Otherwise we know they're all written so there's no point in
     ; keeping track.
     (if (-any-cond-written? (insn-sfmt insn))
	 "  abuf->written = written;\n"
	 "")
     (if (and cti? (not parallel?))
	 "  SEM_BRANCH_FINI (vpc);\n"
	 "")
     (if (and parallel? (not (with-generic-write?)))
	 (gen-undef-parallel-operand-macro (insn-sfmt insn))
	 "")
     (gen-undef-field-macro (insn-sfmt insn))
     "}\n"
     "  NEXT (vpc);\n\n"
     ))
)

(define (-gen-sem-switch)
  (logit 2 "Processing semantic switch ...\n")
  ; Turn parallel execution support off.
  (let ((orig-with-parallel? (with-parallel?)))
    (set-with-parallel?! #f)
    (let ((result
	   (string-write-map (lambda (insn) (-gen-sem-case insn #f))
			     (non-alias-insns (current-insn-list)))))
      (set-with-parallel?! orig-with-parallel?)
      result))
)

; Generate the guts of a C switch statement to execute parallel instructions.
; This switch is included after the non-parallel instructions in the semantic
; switch.
;
; ??? We duplicate the writeback case for each insn, even though we only need
; one case per insn format.  The former keeps the code for each insn
; together and might improve cache usage.  On the other hand the latter
; reduces the amount of code, though it is believed that in this particular
; instance the win isn't big enough.

(define (-gen-parallel-sem-switch)
  (logit 2 "Processing parallel insn semantic switch ...\n")
  ; Turn parallel execution support on.
  (let ((orig-with-parallel? (with-parallel?)))
    (set-with-parallel?! #t)
    (let ((result
	   (string-write-map (lambda (insn)
			       (string-list (-gen-sem-case insn #t)
					    (-gen-write-case (insn-sfmt insn) insn)))
			     (parallel-insns (current-insn-list)))))
      (set-with-parallel?! orig-with-parallel?)
      result))
)

; Top level file generators.

; Generate cpu-<cpu>.h

(define (cgen-cpu.h)
  (logit 1 "Generating " (gen-cpu-name) "'s cpu.h ...\n")

  (sim-analyze-insns!)

  ; Turn parallel execution support on if cpu needs it.
  (set-with-parallel?! (state-parallel-exec?))

  ; Tell the rtl->c translator we're not the simulator.
  ; ??? Minimizes changes in generated code until this is changed.
  ; RTL->C happens for field decoding.
  (rtl-c-config! #:rtl-cover-fns? #f)

  (string-write
   (gen-c-copyright "CPU family header for @cpu@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#ifndef CPU_@CPU@_H
#define CPU_@CPU@_H

"
   -gen-cpu-defines
   -gen-hardware-types
   -gen-cpu-reg-access-decls
   -gen-model-decls

   (if (not (with-multiple-isa?))
     (string-list
       (lambda () (gen-argbuf-type #t))
       (lambda () (gen-scache-type #t))
       -gen-extract-macros)
     "")

   (if (and (with-parallel?) (not (with-generic-write?)))
       -gen-parallel-exec-type
       "")
   -gen-trace-record-type
   "#endif /* CPU_@CPU@_H */\n"
   )
)

; Generate defs-<isa>.h.

(define (cgen-defs.h)
  (logit 1 "Generating " (obj:name (current-isa)) "'s defs.h ...\n")

  (sim-analyze-insns!)

  ; Tell the rtl->c translator we're not the simulator.
  ; ??? Minimizes changes in generated code until this is changed.
  ; RTL->C happens for field decoding.
  (rtl-c-config! #:rtl-cover-fns? #f)

  (string-write
   (gen-c-copyright (string-append
                  "ISA definitions header for "
                  (obj:str-name (current-isa))
                  ".")
                 CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#ifndef DEFS_@PREFIX@_H
#define DEFS_@PREFIX@_H

"
   (lambda () (gen-argbuf-type #t))
   (lambda () (gen-scache-type #t))
   -gen-extract-macros

   "#endif /* DEFS_@PREFIX@_H */\n"
   )
)

; Generate cpu-<cpu>.c

(define (cgen-cpu.c)
  (logit 1 "Generating " (gen-cpu-name) "'s cpu.c ...\n")

  (sim-analyze-insns!)

  ; Turn parallel execution support on if cpu needs it.
  (set-with-parallel?! (state-parallel-exec?))

  ; Initialize rtl generation.
  (rtl-c-config! #:rtl-cover-fns? #t)

  (string-write
   (gen-c-copyright "Misc. support for CPU family @cpu@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#define WANT_CPU @cpu@
#define WANT_CPU_@CPU@

#include \"sim-main.h\"
#include \"cgen-ops.h\"

"
   -gen-cpu-reg-access-defns
   -gen-cpu-record-results
   )
)

; Generate read.c

(define (cgen-read.c)
  (logit 1 "Generating " (gen-cpu-name) "'s read.c ...\n")

  (sim-analyze-insns!)

  ; Turn parallel execution support off.
  (set-with-parallel?! #f)

  ; Tell the rtx->c translator we are the simulator.
  (rtl-c-config! #:rtl-cover-fns? #t)

  (string-write
   (gen-c-copyright (string-append "Simulator instruction operand reader for "
				   (symbol->string (current-arch-name)) ".")
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#ifdef DEFINE_LABELS

  /* The labels have the case they have because the enum of insn types
     is all uppercase and in the non-stdc case the fmt symbol is built
     into the enum name.  */

  static struct {
    int index;
    void *label;
  } labels[] = {\n"

   (lambda ()
     (string-write-map (lambda (insn)
			 (string-append "    { "
					"@PREFIX@_INSN_"
					(string-upcase (gen-sym insn))
					", && case_read_READ_"
					(string-upcase (gen-sym (insn-sfmt insn)))
					" },\n"))
		       (non-alias-insns (current-insn-list))))

   "    { 0, 0 }
  };
  int i;

  for (i = 0; labels[i].label != 0; ++i)
    CPU_IDESC (current_cpu) [labels[i].index].read = labels[i].label;

#undef DEFINE_LABELS
#endif /* DEFINE_LABELS */

#ifdef DEFINE_SWITCH

{\n"
   (if (with-scache?)
       "\
  SEM_ARG sem_arg = sc;
  ARGBUF *abuf = SEM_ARGBUF (sem_arg);

  SWITCH (read, sem_arg->read)\n"
       "\
  SWITCH (read, decode->read)\n")
   "\
    {

"

   -gen-read-switch

   "\
    }
  ENDSWITCH (read) /* End of read switch.  */
}

#undef DEFINE_SWITCH
#endif /* DEFINE_SWITCH */
"
   )
)

; Generate write.c

(define (cgen-write.c)
  (logit 1 "Generating " (gen-cpu-name) "'s write.c ...\n")

  (sim-analyze-insns!)

  ; Turn parallel execution support off.
  (set-with-parallel?! #f)

  ; Tell the rtx->c translator we are the simulator.
  (rtl-c-config! #:rtl-cover-fns? #t)

  (string-write
   (gen-c-copyright (string-append "Simulator instruction operand writer for "
				   (symbol->string (current-arch-name)) ".")
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
/* Write cached results of 1 or more insns executed in parallel.  */

void
@cpu@_parallel_write (SIM_CPU *cpu, SCACHE *sbufs, PAREXEC *pbufs, int ninsns)
{\n"
   (if (with-scache?)
       "\
  SEM_ARG sem_arg = sc;
  ARGBUF *abuf = SEM_ARGBUF (sem_arg);\n"
       "")
   "\

  do
    {
      ARGBUF *abuf = SEM_ARGBUF (sbufs);

      switch (abuf->idesc->write)
	{
\n"

   ;(/indent-add 8)
   -gen-write-switch
   ;(/indent-add -8)

   "\
	}
    }
  while (--ninsns > 0);
}
"
   )
)

; Generate semantics.c
; Each instruction is implemented in its own function.

(define (cgen-semantics.c)
  (logit 1 "Generating " (gen-cpu-name) "'s semantics.c ...\n")

  (sim-analyze-insns!)

  ; Turn parallel execution support on if cpu needs it.
  (set-with-parallel?! (state-parallel-exec?))

  ; Tell the rtx->c translator we are the simulator.
  (rtl-c-config! #:rtl-cover-fns? #t)

  (string-write
   (gen-c-copyright "Simulator instruction semantics for @cpu@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#define WANT_CPU @cpu@
#define WANT_CPU_@CPU@

#include \"sim-main.h\"
#include \"cgen-mem.h\"
#include \"cgen-ops.h\"

#undef GET_ATTR
"
   (gen-define-with-symcat "GET_ATTR(cpu, num, attr) \
CGEN_ATTR_VALUE (NULL, abuf->idesc->attrs, CGEN_INSN_" "attr)")
"
/* This is used so that we can compile two copies of the semantic code,
   one with full feature support and one without that runs fast(er).
   FAST_P, when desired, is defined on the command line, -DFAST_P=1.  */
#if FAST_P
#define SEM_FN_NAME(cpu,fn) XCONCAT3 (cpu,_semf_,fn)
#undef TRACE_RESULT
#define TRACE_RESULT(cpu, abuf, name, type, val)
#else
#define SEM_FN_NAME(cpu,fn) XCONCAT3 (cpu,_sem_,fn)
#endif
\n"

   -gen-all-semantic-fns
   ; Put the table at the end so we don't have to declare all the sem fns.
   -gen-semantic-fn-table
   )
)

; Generate sem-switch.c.
; Each instruction is a case in a switch().
; This file consists of just the switch().  It is included by mainloop.c.

(define (cgen-sem-switch.c)
  (logit 1 "Generating " (gen-cpu-name) "'s sem-switch.c ...\n")

  (sim-analyze-insns!)

  ; Turn parallel execution support off.
  ; It is later turned on/off when generating the actual semantic code.
  (set-with-parallel?! #f)

  ; Tell the rtx->c translator we are the simulator.
  (rtl-c-config! #:rtl-cover-fns? #t)

  (string-write
   (gen-c-copyright "Simulator instruction semantics for @cpu@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)

   "\
#ifdef DEFINE_LABELS

  /* The labels have the case they have because the enum of insn types
     is all uppercase and in the non-stdc case the insn symbol is built
     into the enum name.  */

  static struct {
    int index;
    void *label;
  } labels[] = {\n"

   (lambda ()
     (string-write-map (lambda (insn)
			 (string-append "    { "
					"@PREFIX@_INSN_"
					(string-upcase (gen-sym insn))
					", && case_sem_INSN_"
					(string-upcase (gen-sym insn))
					" },\n"))
		       (non-alias-insns (current-insn-list))))

   (if (state-parallel-exec?)
       (lambda ()
	 (string-write-map (lambda (insn)
			     (string-append "    { "
					    "@CPU@_INSN_PAR_"
					    (string-upcase (gen-sym insn))
					    ", && case_sem_INSN_PAR_"
					    (string-upcase (gen-sym insn))
					    " },\n"
					    "    { "
					    "@CPU@_INSN_WRITE_"
					    (string-upcase (gen-sym insn))
					    ", && case_sem_INSN_WRITE_"
					    (string-upcase (gen-sym insn))
					    " },\n"))
			   (parallel-insns (current-insn-list))))
       "")

   "    { 0, 0 }
  };
  int i;

  for (i = 0; labels[i].label != 0; ++i)
    {
#if FAST_P
      CPU_IDESC (current_cpu) [labels[i].index].sem_fast_lab = labels[i].label;
#else
      CPU_IDESC (current_cpu) [labels[i].index].sem_full_lab = labels[i].label;
#endif
    }

#undef DEFINE_LABELS
#endif /* DEFINE_LABELS */

#ifdef DEFINE_SWITCH

/* If hyper-fast [well not unnecessarily slow] execution is selected, turn
   off frills like tracing and profiling.  */
/* FIXME: A better way would be to have TRACE_RESULT check for something
   that can cause it to be optimized out.  Another way would be to emit
   special handlers into the instruction \"stream\".  */

#if FAST_P
#undef TRACE_RESULT
#define TRACE_RESULT(cpu, abuf, name, type, val)
#endif

#undef GET_ATTR
"
   (gen-define-with-symcat "GET_ATTR(cpu, num, attr) \
CGEN_ATTR_VALUE (NULL, abuf->idesc->attrs, CGEN_INSN_" "attr)")
"
{

#if WITH_SCACHE_PBB

/* Branch to next handler without going around main loop.  */
#define NEXT(vpc) goto * SEM_ARGBUF (vpc) -> semantic.sem_case
SWITCH (sem, SEM_ARGBUF (vpc) -> semantic.sem_case)

#else /* ! WITH_SCACHE_PBB */

#define NEXT(vpc) BREAK (sem)
#ifdef __GNUC__
#if FAST_P
  SWITCH (sem, SEM_ARGBUF (sc) -> idesc->sem_fast_lab)
#else
  SWITCH (sem, SEM_ARGBUF (sc) -> idesc->sem_full_lab)
#endif
#else
  SWITCH (sem, SEM_ARGBUF (sc) -> idesc->num)
#endif

#endif /* ! WITH_SCACHE_PBB */

    {

"

   -gen-sem-switch

   (if (state-parallel-exec?)
       -gen-parallel-sem-switch
       "")

   "
    }
  ENDSWITCH (sem) /* End of semantic switch.  */

  /* At this point `vpc' contains the next insn to execute.  */
}

#undef DEFINE_SWITCH
#endif /* DEFINE_SWITCH */
"
   )
)

; Generate mainloop.in.
; ??? Not currently used.

(define (cgen-mainloop.in)
  (logit 1 "Generating mainloop.in ...\n")

  (string-write
   "cat <<EOF >/dev/null\n"
   (gen-c-copyright "Simulator main loop for @arch@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "EOF\n"
   "\

# Syntax:
# /bin/sh mainloop.in init|support|{full,fast}-{extract,exec}-{scache,nocache}

# ??? There's lots of conditional compilation here.
# After a few more ports are done, revisit.

case \"x$1\" in

xsupport)

cat <<EOF
/*xsupport*/
EOF

;;

xinit)

cat <<EOF
/*xinit*/
EOF

;;

xfull-extract-* | xfast-extract-*)

cat <<EOF
{
"
   (rtl-c VOID insn-extract nil #:rtl-cover-fns? #t)
"}
EOF

;;

xfull-exec-* | xfast-exec-*)

cat <<EOF
{
"
   (rtl-c VOID insn-execute nil #:rtl-cover-fns? #t)
"}
EOF

;;

*)
  echo \"Invalid argument to mainloop.in: $1\" >&2
  exit 1
  ;;

esac
"
   )
)
