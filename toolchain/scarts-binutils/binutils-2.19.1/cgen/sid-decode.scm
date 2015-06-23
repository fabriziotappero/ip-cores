; Decoder generation.
; Copyright (C) 2000, 2002, 2003, 2009 Red Hat, Inc.
; This file is part of CGEN.

; Return decode entries for each insn.
; ??? At one point we generated one variable per instruction rather than one
; big array.  It doesn't matter too much (yet).  Generating one big array is
; simpler.

(define (-gen-decode-insn-globals insn-list)
  ; Print the higher detailed stuff at higher verbosity.
  (logit 2 "Processing decode insn globals ...\n")

  (let* ((all-attrs (current-insn-attr-list))
	 (last-insn (string-upcase (gen-c-symbol (caar (list-take -1
                      (gen-obj-list-enums (non-multi-insns (current-insn-list)))))))))

    (string-write
     "
// The instruction descriptor array. 
\n"

     (if (with-pbb?)
	 "\
// Have label pointers been initialized?
// XXX: Note that this is also needed by when semantics are implemented as
// functions to handle machine variants.
bool @prefix@_idesc::idesc_table_initialized_p = false;\n\n"
	 "")

     "\
@prefix@_idesc @prefix@_idesc::idesc_table[@PREFIX@_INSN_" last-insn " + 1] =
{\n"

     (string-map
      (lambda (insn)
	(let ((name (gen-sym insn))
              (sfmt (insn-sfmt insn))
	      (pbb? (obj-has-attr? insn 'PBB))
	      (virtual? (obj-has-attr? insn 'VIRTUAL)))
	  (string-append
	   "  { "
	   (if (with-pbb?)
	       "0, "
	       "")
	   (if (with-scache?)
	       (if pbb?
		   "0, "
		   (string-append (-gen-sem-fn-name insn) ", "))
	       "") 
	   "\"" (string-upcase name) "\", "
	   (gen-cpu-insn-enum (current-cpu) insn)
	   ", "
	   (gen-obj-attr-sid-defn 'insn insn all-attrs)
	   " },\n")))
      insn-list)

     "\n};\n\n"
     ))
)

; Return a function that lookups up virtual insns.

(define (-gen-virtual-insn-finder)
  (string-list
   "\
// Given a canonical virtual insn id, return the target specific one.

@prefix@_insn_type
@prefix@_idesc::lookup_virtual (virtual_insn_type vit)
{
  switch (vit)
    {
      case VIRTUAL_INSN_INVALID: return @PREFIX@_INSN_X_INVALID;
"

   (if (with-pbb?)
       "\
      case VIRTUAL_INSN_BEGIN: return @PREFIX@_INSN_X_BEGIN;
      case VIRTUAL_INSN_CHAIN: return @PREFIX@_INSN_X_CHAIN;
      case VIRTUAL_INSN_CTI_CHAIN: return @PREFIX@_INSN_X_CTI_CHAIN;
      case VIRTUAL_INSN_BEFORE: return @PREFIX@_INSN_X_BEFORE;
      case VIRTUAL_INSN_AFTER: return @PREFIX@_INSN_X_AFTER;
"
       "")
   (if (and (with-pbb?)
	    (state-conditional-exec?))
       "\
      case VIRTUAL_INSN_COND: return @PREFIX@_INSN_X_COND;
"
       ; Unused, but may still be requested.  Just return X_INVALID.
       "\
      case VIRTUAL_INSN_COND: return @PREFIX@_INSN_X_INVALID;
")
   "\
    }
  abort ();
}\n\n"
   )
)

; Return enum name of format FMT.

(define (-gen-fmt-enum fmt)
  (string-upcase (gen-sym fmt))
)

; Return names of semantic fns for INSN.
; ??? Make global, call from gen-semantic-fn, blah blah blah.

(define (-gen-sem-fn-name insn)
  (string-append "@prefix@_sem_" (gen-sym insn))
)

; Return decls of each semantic fn.

(define (-gen-sem-fn-decls)
  (string-write
   "// Decls of each semantic fn.\n\n"
   "using @cpu@::@prefix@_sem_fn;\n"
   (string-list-map (lambda (insn)
		      (string-list "extern @prefix@_sem_fn "
				   (-gen-sem-fn-name insn)
				   ";\n"))
		    (scache-engine-insns))
   "\n"
   )
)




; idesc, argbuf, and scache types

; Generate decls for the insn descriptor table type IDESC.

(define (-gen-idesc-decls)
  (string-append 
   "
// Forward decls.
struct @cpu@_cpu;
struct @prefix@_scache;
"
   (if (with-parallel?)
       "typedef void (@prefix@_sem_fn) (@cpu@_cpu* cpu, @prefix@_scache* sem, int tick, @prefix@::write_stacks &buf);"
       "typedef sem_status (@prefix@_sem_fn) (@cpu@_cpu* cpu, @prefix@_scache* sem);")
   "\n"
   "\n"   
"
// Instruction descriptor.

struct @prefix@_idesc {
\n"

   (if (with-pbb?)
       "\
  // computed-goto label pointer (pbb engine)
  // FIXME: frag case to be redone (should instead point to usage table).
  cgoto_label cgoto;\n\n"
       "")

   (if (with-scache?)
       "\
  // scache engine executor for this insn
  @prefix@_sem_fn* execute;\n\n"
       "")

   "\
  const char* insn_name;
  enum @prefix@_insn_type sem_index;
  @arch@_insn_attr attrs;

  // idesc table: indexed by sem_index
  static @prefix@_idesc idesc_table[];
"

   (if (with-pbb?)
      "\

  // semantic label pointers filled_in?
  static bool idesc_table_initialized_p;\n"
      "")

   "\

  static @prefix@_insn_type lookup_virtual (virtual_insn_type vit);
};

")
)

; Utility of -gen-argbuf-fields-union to generate the definition for
; <sformat-abuf> SBUF.

(define (-gen-argbuf-elm sbuf)
  (logit 2 "Processing sbuf format " (obj:name sbuf) " ...\n")
  (string-list
   "  struct { /* " (obj:comment sbuf) " */\n"
   (let ((elms (sbuf-elms sbuf)))
     (if (null? elms)
	 "    int empty;\n"
	 (string-list-map (lambda (elm)
			    (string-append "    "
					   (cadr elm)
					   " "
					   (car elm)
					   ";\n"))
			  (sbuf-elms sbuf))))
   "  } " (gen-sym sbuf) ";\n")
)

; Utility of -gen-scache-decls to generate the union of extracted ifields.

(define (-gen-argbuf-fields-union)
  (string-list
   "\
// Instruction argument buffer.

union @prefix@_sem_fields {\n"
   (string-list-map -gen-argbuf-elm (current-sbuf-list))
   "\
  // This one is for chain/cti-chain virtual insns.
  struct {
    // Number of insns in pbb.
    unsigned insn_count;
    // This is used by chain insns and by untaken conditional branches.
    @prefix@_scache* next;
    @prefix@_scache* branch_target;
  } chain;
  // This one is for `before' virtual insns.
  struct {
    // The cache entry of the real insn.
    @prefix@_scache* insn;
  } before;
};\n\n"
   )
)

(define (-gen-scache-decls)
  (string-list
   (-gen-argbuf-fields-union)
   "\
// Simulator instruction cache.

struct @prefix@_scache {
  // executor
  union {
    cgoto_label cgoto;
    @prefix@_sem_fn* fn;
  } execute;
\n"
   
   (if (state-conditional-exec?)
       "\
  // condition
  UINT cond;
\n"
       "")

   "\
  // PC of this instruction.
  PCADDR addr;

  // instruction class
  @prefix@_idesc* idesc;

  // argument buffer
  @prefix@_sem_fields fields;

" (if (with-any-profile?)
      (string-append "
  // writeback flags
  // Only used if profiling or parallel execution support enabled during
  // file generation.
  unsigned long long written;
")
      "") "

  // decode given instruction
  void decode (@cpu@_cpu* current_cpu, PCADDR pc, @prefix@_insn_word base_insn, @prefix@_insn_word entire_insn);
};

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
		      (gen-cpu-ref (hw-isas self) (gen-sym (op:type op)))
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
    (logit 3 "sfmt = " (obj:name sfmt) " operands=" (string-map obj:name operands))
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
     "  if (UNLIKELY(current_cpu->trace_extract_p))\n"
     "    {\n"
     "      current_cpu->trace_stream \n"
     "        << \"0x\" << hex << pc << dec << \" (" (gen-sym sfmt) ")\\t\"\n"
     ; NB: The following is not necessary any more, as the ifield list 
     ;     is a subset of the operand list.
     ; (string-list-map (lambda (f) 
     ;			(string-list
     ;			 "        << \" " (gen-sym f) ":0x\" << hex << " (gen-sym f) " << dec\n"))
     ;		      iflds)
     (string-list-map (lambda (ifld) 
			(string-list
			 "        << \" " (gen-extracted-ifld-value ifld) ":0x\" << hex << "
					; Add (SI) or (USI) cast for byte-wide data, to prevent C++ iostreams
					; from printing byte as plain raw char.
			 (cond ((not ifld) "")
			       ((mode:eq? 'QI (ifld-decode-mode ifld)) "(SI) ")
			       ((mode:eq? 'UQI (ifld-decode-mode ifld)) "(USI) ")
			       (else ""))
			 (gen-extracted-ifld-value ifld)
			 " << dec\n"))
		      iflds)
     "        << endl;\n"
     "    }\n"
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
    (if (or (not (with-any-profile?)) (and (null? in-ops) (null? out-ops)))
	""
	(string-list
	 "  /* Record the fields for profiling.  */\n"
	 "  if (UNLIKELY (current_cpu->trace_counter_p || current_cpu->final_insn_count_p))\n"
	 "    {\n"
	 (string-list-map (lambda (op) (op:record-profile op sfmt #f))
			  in-ops)
	 (string-list-map (lambda (op) (op:record-profile op sfmt #t))
			  out-ops)
	 "    }\n"
	 )))
)

; Return C code that extracts the fields of <sformat> SFMT.
;
; Extraction is based on formats to reduce the amount of code generated.
; However, we also need to emit code which records the hardware elements used
; by the semantic code.  This is currently done by recording this information
; with the format.

(define (-gen-extract-fn sfmt)
  (logit 2 "Processing extractor for \"" (sfmt-key sfmt) "\" ...\n")
  (string-list
   "void
@prefix@_extract_" (gen-sym sfmt) " (@prefix@_scache* abuf, @cpu@_cpu* current_cpu, PCADDR pc, @prefix@_insn_word base_insn, @prefix@_insn_word entire_insn)"
   "{\n"
   "    @prefix@_insn_word insn = "
   (if (adata-integral-insn? CURRENT-ARCH)
       "entire_insn;\n"
       "base_insn;\n")
   (gen-define-field-macro sfmt)
   (gen-define-ifields (sfmt-iflds sfmt) (sfmt-length sfmt) "    " #f)
   "\n"
   (gen-extract-ifields (sfmt-iflds sfmt) (sfmt-length sfmt) "    " #f)
   "\n"
   (-gen-record-args sfmt)
   "\n"
   (-gen-record-profile-args sfmt)
   (gen-undef-field-macro sfmt)
   "}\n\n"
   )
)

; For each format, return its extraction function.

(define (-define-all-extractor-fns)
  (logit 2 "Processing extractor fn bodies ...\n")
  (string-list-map -gen-extract-fn (current-sfmt-list))
)

(define (-declare-all-extractor-fns)
  (logit 2 "Processing extractor fn declarations ...\n")
  (string-map (lambda (sfmt)
		(string-append "
static void
@prefix@_extract_" (gen-sym sfmt) " (@prefix@_scache* abuf, @cpu@_cpu* current_cpu, PCADDR pc, @prefix@_insn_word base_insn, @prefix@_insn_word entire_insn);"))
	      (current-sfmt-list))
)


; Generate top level decoder.
; INITIAL-BITNUMS is a target supplied list of bit numbers to use to
; build the first decode table.  If nil, we compute 8 bits of it (FIXME)
; ourselves.
; LSB0? is non-#f if bit number 0 is the least significant bit.

(define (-gen-decode-fn insn-list initial-bitnums lsb0?)
  (assert (with-scache?))

  ; Compute the initial DECODE-BITSIZE as the minimum of all insn lengths.
  ; The caller of @prefix@_decode must fetch and pass exactly this number of bits
  ; of the instruction.
  ; ??? Make this a parameter later but only if necessary.

  (let ((decode-bitsize (state-base-insn-bitsize)))

    ; Compute INITIAL-BITNUMS if not supplied.
    ; 0 is passed for the start bit (it is independent of lsb0?)
    (if (null? initial-bitnums)
	(set! initial-bitnums
	      (if (= 0 (length insn-list))
		  (list 0) ; dummy value
		  (decode-get-best-bits insn-list nil
					0 ; startbit
					8 ; max
					decode-bitsize
					lsb0?))))
	
    ; All set.  gen-decoder does the hard part, we just print out the result. 
    (let ((decode-code (gen-decoder insn-list initial-bitnums
				    decode-bitsize
				    "    " lsb0?
				    (current-insn-lookup 'x-invalid)
				    #t)))

      (string-write
       "
// Declare extractor functions
"
       -declare-all-extractor-fns

       "

// Fetch & decode instruction
void
@prefix@_scache::decode (@cpu@_cpu* current_cpu, PCADDR pc, @prefix@_insn_word base_insn, @prefix@_insn_word entire_insn)
{
  /* Result of decoder.  */
  @PREFIX@_INSN_TYPE itype;

  {
    @prefix@_insn_word insn = base_insn;
\n"
       decode-code
       "
  }

  /* The instruction has been decoded and fields extracted.  */
  done:
"
       (if (state-conditional-exec?)
	   (let ((cond-ifld (current-ifld-lookup (car (isa-condition (current-isa))))))
	     (string-append
	      "  {\n"
	      (gen-ifld-extract-decl cond-ifld "    " #f)
	      (gen-ifld-extract cond-ifld "    "
				(state-base-insn-bitsize)
				(state-base-insn-bitsize)
				"base_insn" nil #f)
	      "    this->cond = " (gen-sym cond-ifld) ";\n"
	      "  }\n"))
	   "")

       "
  this->addr = pc;
  // FIXME: To be redone (to handle ISA variants).
  this->idesc = & @prefix@_idesc::idesc_table[itype];
  // ??? record semantic handler?
  assert(this->idesc->sem_index == itype);
}

"

       -define-all-extractor-fns
       )))
)

; Entry point.  Generate decode.h.

(define (cgen-decode.h)
  (logit 1 "Generating " (gen-cpu-name) "-decode.h ...\n")

  (sim-analyze-insns!)

  ; Turn parallel execution support on if cpu needs it.
  (set-with-parallel?! (state-parallel-exec?))

  (string-write
   (gen-c-copyright "Decode header for @prefix@."
		  copyright-red-hat package-red-hat-simulators)
   "\
#ifndef @PREFIX@_DECODE_H
#define @PREFIX@_DECODE_H

"
   (if (with-parallel?)
       "\
namespace @prefix@ {
// forward declaration of struct in -defs.h
struct write_stacks;
}

"
       "")
"\
namespace @cpu@ {

using namespace cgen;
using namespace @arch@;

typedef UINT @prefix@_insn_word;

"
   (lambda () (gen-cpu-insn-enum-decl (current-cpu)
				      (non-multi-insns (non-alias-insns (current-insn-list)))))
   -gen-idesc-decls
   -gen-scache-decls

   "\
} // end @cpu@ namespace
\n"

   ; ??? The semantic functions could go in the cpu's namespace.
   ; There's no pressing need for it though.
   (if (with-scache?)
       -gen-sem-fn-decls
       "")

   "\
#endif /* @PREFIX@_DECODE_H */\n"
   )
)

; Entry point.  Generate decode.cxx.

(define (cgen-decode.cxx)
  (logit 1 "Generating " (gen-cpu-name) "-decode.cxx ...\n")

  (sim-analyze-insns!)

  ; Turn parallel execution support on if cpu needs it.
  (set-with-parallel?! (state-parallel-exec?))

  ; Tell the rtx->c translator we are the simulator.
  (rtl-c-config! #:rtl-cover-fns? #t)

  (string-write
   (gen-c-copyright "Simulator instruction decoder for @prefix@."
		  copyright-red-hat package-red-hat-simulators)
   "\

#if HAVE_CONFIG_H
#include \"config.h\"
#endif
#include \"@cpu@.h\"

using namespace @cpu@; // FIXME: namespace organization still wip
\n"

   (lambda () (-gen-decode-insn-globals (non-multi-insns (non-alias-insns (current-insn-list)))))
   -gen-virtual-insn-finder
   (lambda () (-gen-decode-fn (non-multi-insns (real-insns (current-insn-list)))
			      (state-decode-assist)
			      (current-arch-insn-lsb0?)))
   )
)
