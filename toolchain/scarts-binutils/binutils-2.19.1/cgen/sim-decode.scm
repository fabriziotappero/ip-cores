; Decoder generation.
; Copyright (C) 2000, 2001, 2009 Red Hat, Inc.
; This file is part of CGEN.

; Names of various global vars.

; Name of insn descriptor table var.
(define IDESC-TABLE-VAR "@prefix@_insn_data")

; Return decode entries for each insn.
; ??? At one point we generated one variable per instruction rather than one
; big array.  It doesn't matter too much (yet).  Generating one big array is
; simpler.

(define (-gen-decode-insn-globals insn-list)
  ; Print the higher detailed stuff at higher verbosity.
  (logit 2 "Processing decode insn globals ...\n")

  (string-write

   (if (and (with-parallel?) (not (with-parallel-only?)))
       "\
/* Insn can't be executed in parallel.
   Or is that \"do NOt Pass to Air defense Radar\"? :-) */
#define NOPAR (-1)
\n"
       "")

   "\
/* The instruction descriptor array.
   This is computed at runtime.  Space for it is not malloc'd to save a
   teensy bit of cpu in the decoder.  Moving it to malloc space is trivial
   but won't be done until necessary (we don't currently support the runtime
   addition of instructions nor an SMP machine with different cpus).  */
static IDESC " IDESC-TABLE-VAR "[@PREFIX@_INSN__MAX];

/* Commas between elements are contained in the macros.
   Some of these are conditionally compiled out.  */

static const struct insn_sem @prefix@_insn_sem[] =
{\n"

   (string-list-map
    (lambda (insn)
      (let ((name (gen-sym insn))
	    (pbb? (obj-has-attr? insn 'PBB))
	    (virtual? (insn-virtual? insn)))
	(string-list
	 "  { "
	 (if virtual?
	     (string-append "VIRTUAL_INSN_" (string-upcase name) ", ")
	     (string-append "@ARCH@_INSN_" (string-upcase name) ", "))
         (string-append "@PREFIX@_INSN_" (string-upcase name) ", ")
	 "@PREFIX@_" (-gen-fmt-enum (insn-sfmt insn))
	 (if (and (with-parallel?) (not (with-parallel-only?)))
	     (string-list
	      (if (insn-parallel? insn)
		  (string-append ", @PREFIX@_INSN_PAR_"
				 (string-upcase name)
				 ", "
				 (if (with-parallel-read?)
				     "@PREFIX@_INSN_READ_"
				     "@PREFIX@_INSN_WRITE_")
				 (string-upcase name))
		  ", NOPAR, NOPAR "))
	     "")
	 " },\n")))
    insn-list)

   "\
};

static const struct insn_sem @prefix@_insn_sem_invalid = {
  VIRTUAL_INSN_X_INVALID, @PREFIX@_INSN_X_INVALID, @PREFIX@_SFMT_EMPTY"
   (if (and (with-parallel?) (not (with-parallel-only?)))
       ", NOPAR, NOPAR"
       "")
   "
};
\n"
   )
)

; Return enum name of format FMT.

(define (-gen-fmt-enum fmt)
  (string-upcase (gen-sym fmt))
)

; Generate decls for the insn descriptor table type IDESC.

(define (-gen-idesc-decls)
  (string-append "\
extern const IDESC *@prefix@_decode (SIM_CPU *, IADDR,
                                  CGEN_INSN_INT,"
  (if (adata-integral-insn? CURRENT-ARCH)
      " CGEN_INSN_INT,\n"
      "\n")
  "\
                                  ARGBUF *);
extern void @prefix@_init_idesc_table (SIM_CPU *);
extern void @prefix@_sem_init_idesc_table (SIM_CPU *);
extern void @prefix@_semf_init_idesc_table (SIM_CPU *);
\n")
)

; Return definition of C function to initialize the IDESC table.
; @prefix@_init_idesc_table is defined here as it depends on with-parallel?
; and thus can't be defined in sim/common.

(define (-gen-idesc-init-fn)
  (string-append "\
/* Initialize an IDESC from the compile-time computable parts.  */

static INLINE void
init_idesc (SIM_CPU *cpu, IDESC *id, const struct insn_sem *t)
{
  const CGEN_INSN *insn_table = CGEN_CPU_INSN_TABLE (CPU_CPU_DESC (cpu))->init_entries;

  id->num = t->index;
  id->sfmt = t->sfmt;
  if ((int) t->type <= 0)
    id->idata = & cgen_virtual_insn_table[- (int) t->type];
  else
    id->idata = & insn_table[t->type];
  id->attrs = CGEN_INSN_ATTRS (id->idata);
  /* Oh my god, a magic number.  */
  id->length = CGEN_INSN_BITSIZE (id->idata) / 8;

#if WITH_PROFILE_MODEL_P
  id->timing = & MODEL_TIMING (CPU_MODEL (cpu)) [t->index];
  {
    SIM_DESC sd = CPU_STATE (cpu);
    SIM_ASSERT (t->index == id->timing->num);
  }
#endif

  /* Semantic pointers are initialized elsewhere.  */
}

/* Initialize the instruction descriptor table.  */

void
@prefix@_init_idesc_table (SIM_CPU *cpu)
{
  IDESC *id,*tabend;
  const struct insn_sem *t,*tend;
  int tabsize = @PREFIX@_INSN__MAX;
  IDESC *table = " IDESC-TABLE-VAR ";

  memset (table, 0, tabsize * sizeof (IDESC));

  /* First set all entries to the `invalid insn'.  */
  t = & @prefix@_insn_sem_invalid;
  for (id = table, tabend = table + tabsize; id < tabend; ++id)
    init_idesc (cpu, id, t);

  /* Now fill in the values for the chosen cpu.  */
  for (t = @prefix@_insn_sem, tend = t + sizeof (@prefix@_insn_sem) / sizeof (*t);
       t != tend; ++t)
    {
      init_idesc (cpu, & table[t->index], t);\n"

   (if (and (with-parallel?) (not (with-parallel-only?)))
       "\
      if (t->par_index != NOPAR)
	{
	  init_idesc (cpu, &table[t->par_index], t);
	  table[t->index].par_idesc = &table[t->par_index];
	}\n"
       "")

   (if (and (with-parallel-write?) (not (with-parallel-only?)))
       "\
      if (t->par_index != NOPAR)
	{
	  init_idesc (cpu, &table[t->write_index], t);
	  table[t->par_index].par_idesc = &table[t->write_index];
	}\n"
       "")

   "\
    }

  /* Link the IDESC table into the cpu.  */
  CPU_IDESC (cpu) = table;
}

")
)

; Instruction field extraction support.
; Two implementations are provided, one for !with-scache and one for
; with-scache.
;
; Extracting ifields is a three phase process.  First the ifields are
; extracted and stored in local variables.  Then any ifields requiring
; additional processing for operands are handled.  Then in the with-scache
; case the results are stored in a struct for later retrieval by the semantic
; code.
;
; The !with-scache case does this processing in the semantic function,
; except it doesn't need the last step (it doesn't need to store the results
; in a struct for later use).
;
; The with-scache case extracts the ifields in the decode function.
; Furthermore, we use <sformat-argbuf> to reduce the quantity of structures
; created (this helps semantic-fragment pbb engines).

; Return C code to record <ifield> F for the semantic handler
; in a local variable rather than an ARGBUF struct.

(define (-gen-record-argbuf-ifld f sfmt)
  (string-append "  " (gen-ifld-argbuf-ref f)
		 " = " (gen-extracted-ifld-value f) ";\n")
)

; Return three of arguments to TRACE:
; string argument to fprintf, character indicating type of third arg, value.
; The type is one of: x.

(define (-gen-trace-argbuf-ifld f sfmt)
  (string-append
   ; FIXME: Add method to return fprintf format string.
   ", \"" (gen-sym f) " 0x%x\""
   ", 'x'"
   ", " (gen-extracted-ifld-value f))
)

; Instruction field extraction support cont'd.
; Hardware support.

; gen-extract method.
; For the default case we use the ifield as is, which is output elsewhere.

(method-make!
 <hardware-base> 'gen-extract
 (lambda (self op sfmt local?)
   "")
)

; gen-trace-extract method.
; Return appropriate arguments for TRACE_EXTRACT.

(method-make!
 <hardware-base> 'gen-trace-extract
 (lambda (self op sfmt)
   "")
)

; Extract the necessary fields into ARGBUF.

(method-make!
 <hw-register> 'gen-extract
 (lambda (self op sfmt local?)
   (if (hw-cache-addr? self)
       (string-append "  "
		      (if local?
			  (gen-hw-index-argbuf-name (op:index op))
			  (gen-hw-index-argbuf-ref (op:index op)))
		      " = & "
		      (gen-cpu-ref (gen-sym (op:type op)))
		      (gen-array-ref (gen-extracted-ifld-value (op-ifield op)))
		      ";\n")
       ""))
)

; Return appropriate arguments for TRACE_EXTRACT.

(method-make!
 <hw-register> 'gen-trace-extract
 (lambda (self op sfmt)
   (if (hw-cache-addr? self)
       (string-append
	; FIXME: Add method to return fprintf format string.
	", \"" (gen-sym op) " 0x%x\""
	", 'x'"
	", " (gen-extracted-ifld-value (op-ifield op)))
       ""))
)

; Extract the necessary fields into ARGBUF.

(method-make!
 <hw-address> 'gen-extract
 (lambda (self op sfmt local?)
   (string-append "  "
		  (if local?
		      (gen-hw-index-argbuf-name (op:index op))
		      (gen-hw-index-argbuf-ref (op:index op)))
		  " = "
		  (gen-extracted-ifld-value (op-ifield op))
		  ";\n"))
)

; Return appropriate arguments for TRACE_EXTRACT.

(method-make!
 <hw-address> 'gen-trace-extract
 (lambda (self op sfmt)
   (string-append
    ; FIXME: Add method to return fprintf format string.
    ", \"" (gen-sym op) " 0x%x\""
    ", 'x'"
    ", " (gen-extracted-ifld-value (op-ifield op))))
)

; Instruction field extraction support cont'd.
; Operand support.

; Return C code to record the field for the semantic handler.
; In the case of a register, this is usually the address of the register's
; value (if CACHE-ADDR).
; LOCAL? indicates whether to record the value in a local variable or in
; the ARGBUF struct.
; ??? Later allow target to provide an `extract' expression.

(define (-gen-op-extract op sfmt local?)
  (send (op:type op) 'gen-extract op sfmt local?)
)

; Return three of arguments to TRACE_EXTRACT:
; string argument to fprintf, character indicating type of third arg, value.
; The type is one of: x.

(define (-gen-op-trace-extract op sfmt)
  (send (op:type op) 'gen-trace-extract op sfmt)
)

; Return C code to define local vars to hold processed ifield data for
; <sformat> SFMT.
; This is used when !with-scache.
; Definitions of the extracted ifields is handled elsewhere.

(define (gen-sfmt-op-argbuf-defns sfmt)
  (let ((operands (sfmt-extracted-operands sfmt)))
    (string-list-map (lambda (op)
		       (let ((var-spec (sfmt-op-sbuf-elm op sfmt)))
			 (if var-spec
			     (string-append "  "
					    (cadr var-spec)
					    " "
					    (car var-spec)
					    ";\n")
			     "")))
		     operands))
)

; Return C code to assign values to the local vars that hold processed ifield
; data for <sformat> SFMT.
; This is used when !with-scache.
; Assignment of the extracted ifields is handled elsewhere.

(define (gen-sfmt-op-argbuf-assigns sfmt)
  (let ((operands (sfmt-extracted-operands sfmt)))
    (string-list-map (lambda (op)
		       (-gen-op-extract op sfmt #t))
		     operands))
)

; Instruction field extraction support cont'd.
; Emit extraction section of decode function.

; Return C code to record insn field data for <sformat> SFMT.
; This is used when with-scache.

(define (-gen-record-args sfmt)
  (let ((operands (sfmt-extracted-operands sfmt))
	(iflds (sfmt-needed-iflds sfmt)))
    (string-list
     "  /* Record the fields for the semantic handler.  */\n"
     (string-list-map (lambda (f) (-gen-record-argbuf-ifld f sfmt))
		      iflds)
     (string-list-map (lambda (op) (-gen-op-extract op sfmt #f))
		      operands)
     "  TRACE_EXTRACT (current_cpu, abuf, (current_cpu, pc, "
     "\"" (gen-sym sfmt) "\""
     (string-list-map (lambda (f) (-gen-trace-argbuf-ifld f sfmt))
		      iflds)
     (string-list-map (lambda (op) (-gen-op-trace-extract op sfmt))
		      operands)
     ", (char *) 0));\n"
     ))
)

; Return C code to record insn field data for profiling.
; Also recorded are operands not mentioned in the fields but mentioned
; in the semantic code.
;
; FIXME: Register usage may need to be tracked as an array of longs.
; If there are more than 32 regs, we can't know which until build time.
; ??? For now we only handle reg sets of 32 or less.
;
; ??? The other way to obtain register numbers is to defer computing them
; until they're actually needed.  It will speed up execution when not doing
; profiling, though the speed up is only for the extraction phase.
; On the other hand the current way has one memory reference per register
; number in the profiling routines.  For RISC this can be a lose, though for
; more complicated instruction sets it could be a win as all the computation
; is kept to the extraction phase.  If someone wants to put forth some real
; data, this might then be changed (or at least noted).

(define (-gen-record-profile-args sfmt)
  (let ((in-ops (find op-profilable? (sfmt-in-ops sfmt)))
	(out-ops (find op-profilable? (sfmt-out-ops sfmt)))
	)
    (if (and (null? in-ops) (null? out-ops))
	""
	(string-list
	 "#if WITH_PROFILE_MODEL_P\n"
	 "  /* Record the fields for profiling.  */\n"
	 "  if (PROFILE_MODEL_P (current_cpu))\n"
	 "    {\n"
	 (string-list-map (lambda (op) (op:record-profile op sfmt #f))
			  in-ops)
	 (string-list-map (lambda (op) (op:record-profile op sfmt #t))
			  out-ops)
	 "    }\n"
	 "#endif\n"
	 )))
)

; Return C code that extracts the fields of <sformat> SFMT.
;
; Extraction is based on formats to reduce the amount of code generated.
; However, we also need to emit code which records the hardware elements used
; by the semantic code.  This is currently done by recording this information
; with the format.

(define (-gen-extract-case sfmt)
  (logit 2 "Processing extractor for \"" (sfmt-key sfmt) "\" ...\n")
  (string-list
   " extract_" (gen-sym sfmt) ":\n"
   "  {\n"
   "    const IDESC *idesc = &" IDESC-TABLE-VAR "[itype];\n"
   (if (> (length (sfmt-iflds sfmt)) 0)
       (string-append
	"    CGEN_INSN_INT insn = "
	(if (adata-integral-insn? CURRENT-ARCH)
	    "entire_insn;\n"
	    "base_insn;\n"))
       "")
   (gen-define-field-macro sfmt)
   (gen-define-ifields (sfmt-iflds sfmt) (sfmt-length sfmt) "    " #f)
   "\n"
   (gen-extract-ifields (sfmt-iflds sfmt) (sfmt-length sfmt) "    " #f)
   "\n"
   (-gen-record-args sfmt)
   "\n"
   (-gen-record-profile-args sfmt)
   (gen-undef-field-macro sfmt)
   "    return idesc;\n"
   "  }\n\n"
   )
)

; For each format, return its extraction function.

(define (-gen-all-extractors)
  (logit 2 "Processing extractors ...\n")
  (string-list-map -gen-extract-case (current-sfmt-list))
)

; Generate top level decoder.
; INITIAL-BITNUMS is a target supplied list of bit numbers to use to
; build the first decode table.  If nil, we compute 8 bits of it (FIXME)
; ourselves.
; LSB0? is non-#f if bit number 0 is the least significant bit.

(define (-gen-decode-fn insn-list initial-bitnums lsb0?)

  ; Compute the initial DECODE-BITSIZE as the minimum of all insn lengths.
  ; The caller of @prefix@_decode must fetch and pass exactly this number of bits
  ; of the instruction.
  ; ??? Make this a parameter later but only if necessary.

  (let ((decode-bitsize (apply min (map insn-base-mask-length insn-list))))

    ; Compute INITIAL-BITNUMS if not supplied.
    ; 0 is passed for the start bit (it is independent of lsb0?)
    (if (null? initial-bitnums)
	(set! initial-bitnums (decode-get-best-bits insn-list nil
						    0 ; startbit
						    8 ; max
						    decode-bitsize
						    lsb0?)))

    ; All set.  gen-decoder does the hard part, we just print out the result. 
    (let ((decode-code (gen-decoder insn-list initial-bitnums
				    decode-bitsize
				    "    " lsb0?
				    (current-insn-lookup 'x-invalid)
				    #f)))

      (string-write
       "\
/* Given an instruction, return a pointer to its IDESC entry.  */

const IDESC *
@prefix@_decode (SIM_CPU *current_cpu, IADDR pc,
              CGEN_INSN_INT base_insn,"
       (if (adata-integral-insn? CURRENT-ARCH)
	   " CGEN_INSN_INT entire_insn,\n"
	   "\n")
       "\
              ARGBUF *abuf)
{
  /* Result of decoder.  */
  @PREFIX@_INSN_TYPE itype;

  {
    CGEN_INSN_INT insn = base_insn;
\n"

       decode-code

       "\
  }
\n"

       (if (with-scache?)
           (string-list "\
  /* The instruction has been decoded, now extract the fields.  */\n\n"
            -gen-all-extractors)
	   ; Without the scache, extraction is defered until the semantic code.
	   (string-list "\
  /* Extraction is defered until the semantic code.  */

 done:
  return &" IDESC-TABLE-VAR "[itype];\n"))

       "\
}\n"
       )))
)

; Entry point.  Generate decode.h.

(define (cgen-decode.h)
  (logit 1 "Generating " (gen-cpu-name) "'s decode.h ...\n")

  (sim-analyze-insns!)

  ; Turn parallel execution support on if cpu needs it.
  (set-with-parallel?! (state-parallel-exec?))

  (string-write
   (gen-c-copyright "Decode header for @prefix@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#ifndef @PREFIX@_DECODE_H
#define @PREFIX@_DECODE_H

"
   -gen-idesc-decls
   (lambda () (gen-cpu-insn-enum-decl (current-cpu)
				      (non-multi-insns (non-alias-insns (current-insn-list)))))
   (lambda () (gen-sfmt-enum-decl (current-sfmt-list)))
   gen-model-fn-decls
   "#endif /* @PREFIX@_DECODE_H */\n"
   )
)

; Entry point.  Generate decode.c.

(define (cgen-decode.c)
  (logit 1 "Generating " (gen-cpu-name) "'s decode.c ...\n")

  (sim-analyze-insns!)

  ; Turn parallel execution support on if cpu needs it.
  (set-with-parallel?! (state-parallel-exec?))

  ; Tell the rtx->c translator we are the simulator.
  (rtl-c-config! #:rtl-cover-fns? #t)

  (string-write
   (gen-c-copyright "Simulator instruction decoder for @prefix@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#define WANT_CPU @cpu@
#define WANT_CPU_@CPU@

#include \"sim-main.h\"
#include \"sim-assert.h\"\n\n"

   (lambda () (-gen-decode-insn-globals (non-multi-insns (non-alias-insns (current-insn-list)))))
   -gen-idesc-init-fn
   (lambda () (-gen-decode-fn (non-multi-insns (real-insns (current-insn-list)))
			      (state-decode-assist)
			      (current-arch-insn-lsb0?)))
   )
)
