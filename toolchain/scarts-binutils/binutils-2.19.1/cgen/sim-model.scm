; Simulator model support, plus misc. things associated with a cpu family.
; Copyright (C) 2000, 2003, 2009 Red Hat, Inc.
; This file is part of CGEN.

; Return C code to define cpu implementation properties.

(define (unit:enum u)
  (gen-c-symbol (string-append "UNIT_"
			       (string-upcase (obj:str-name (unit:model u)))
			       "_"
			       (string-upcase (obj:str-name u))))
)

(define (-gen-cpu-imp-properties)
  (string-list
   "\
/* The properties of this cpu's implementation.  */

static const MACH_IMP_PROPERTIES @cpu@_imp_properties =
{
  sizeof (SIM_CPU),
#if WITH_SCACHE
  sizeof (SCACHE)
#else
  0
#endif
};\n\n"
   )
)

; Insn modeling support.

; Generate code to profile hardware elements.
; ??? Not currently used.

(define (-gen-hw-profile-code)
  ; Fetch profilable input and output operands of the semantic code.
  (let ((in-ops (find op-profilable? (sfmt-in-ops (insn-sfmt insn))))
	(out-ops (find op-profilable? (sfmt-out-ops (insn-sfmt insn)))))
    (string-list
     ; For each operand, record its being get/set.
     (string-list-map (lambda (op) (send op 'gen-profile-code insn #f))
		      in-ops)
     (string-list-map (lambda (op) (send op 'gen-profile-code insn #t))
		      out-ops)
     ))
)

; Return decls of hardware element profilers.
; ??? Not currently used.

(define (-gen-hw-profile-decls)
  (string-list
   "/* Hardware profiling handlers.  */\n\n"
   (string-list-map (lambda (hw)
		      (string-append "extern void @cpu@_model_mark_get_"
				     (gen-sym hw) " (SIM_CPU *"
				     (if (hw-scalar? hw)
					 ""
					 ", int") ; FIXME: get index type
				     ");\n"
				     "extern void @cpu@_model_mark_set_"
				     (gen-sym hw) " (SIM_CPU *"
				     (if (hw-scalar? hw)
					 ""
					 ", int") ; FIXME: get index type
				     ");\n"))
		    (find hw-profilable? (current-hw-list)))
   "\n"
   )
)

; Return name of profiling handler for MODEL, UNIT.
; Also called by sim.scm.

(define (gen-model-unit-fn-name model unit)
  (string-append "@cpu@_model_" (gen-sym model) "_" (gen-sym unit))
)

; Return decls of all insn model handlers.
; This is called from sim-decode.scm.

(define (gen-model-fn-decls)
  (let ((gen-args (lambda (args)
		    (gen-c-args (map (lambda (arg)
				       (stringsym-append
					(mode:c-type (mode:lookup (cadr arg)))
					" /*" (car arg) "*/"))
				     (find (lambda (arg)
					     ; Indices of scalars not passed.
					     (not (null? (cdr arg))))
					   args)))))
	)

    (string-list
     ; -gen-hw-profile-decls
     "/* Function unit handlers (user written).  */\n\n"
     (string-list-map
      (lambda (model)
	(string-list-map (lambda (unit)
			   (stringsym-append
			    "extern int "
			    (gen-model-unit-fn-name model unit)
			    " (SIM_CPU *, const IDESC *,"
			    " int /*unit_num*/, int /*referenced*/"
			    (gen-args (unit:inputs unit))
			    (gen-args (unit:outputs unit))
			    ");\n"))
			 (model:units model)))
      (current-model-list))
     "\n"
     "/* Profiling before/after handlers (user written) */\n\n"
     "extern void @cpu@_model_insn_before (SIM_CPU *, int /*first_p*/);\n"
     "extern void @cpu@_model_insn_after (SIM_CPU *, int /*last_p*/, int /*cycles*/);\n"
     "\n"
     ))
)

; Return name of profile handler for INSN, MODEL.

(define (-gen-model-insn-fn-name model insn)
  (string-append "model_" (gen-sym model) "_" (gen-sym insn))
)

; Return function to model INSN.

(define (-gen-model-insn-fn model insn)
  (logit 2 "Processing modeling for " (obj:name insn) ": \"" (insn-syntax insn) "\" ...\n")
  (string-list
   "static int\n"
   (-gen-model-insn-fn-name model insn)
   ; sem_arg is a void * to keep cgen specific stuff out of sim-model.h
   " (SIM_CPU *current_cpu, void *sem_arg)\n"
   "{\n"
   (if (with-scache?)
       (gen-define-field-macro (insn-sfmt insn))
       "")
   "  const ARGBUF * UNUSED abuf = SEM_ARGBUF ((SEM_ARG) sem_arg);\n"
   "  const IDESC * UNUSED idesc = abuf->idesc;\n"
   ; or: idesc = & CPU_IDESC (current_cpu) ["
   ; (gen-cpu-insn-enum (mach-cpu (model:mach model)) insn)
   ; "];\n"
   "  int cycles = 0;\n"
   (send insn 'gen-profile-locals model)
   (if (with-scache?)
       ""
       (string-list
	"  IADDR UNUSED pc = GET_H_PC ();\n"
	"  CGEN_INSN_INT insn = abuf->insn;\n"
	(gen-define-ifmt-ifields (insn-ifmt insn) "  " #f #t)
	(gen-sfmt-op-argbuf-defns (insn-sfmt insn))
	(gen-extract-ifmt-ifields (insn-ifmt insn) "  " #f #t)
	(gen-sfmt-op-argbuf-assigns (insn-sfmt insn))))
   ; Emit code to model the insn.  Function units are handled here.
   (send insn 'gen-profile-code model "cycles")
   "  return cycles;\n"
   (if (with-scache?)
       (gen-undef-field-macro (insn-sfmt insn))
       "")
   "}\n\n")
)

; Return insn modeling handlers.
; ??? Might wish to reduce the amount of output by combining identical cases.
; ??? Modelling of insns could be table driven, but that puts constraints on
; generality.

(define (-gen-model-insn-fns)
  (string-write
   "/* Model handlers for each insn.  */\n\n"
   (lambda () (string-write-map
	       (lambda (model)
		 (string-write-map
		  (lambda (insn) (-gen-model-insn-fn model insn))
		  (real-insns (current-insn-list))))
	       (current-model-list)))
   )
)

; Generate timing table entry for function unit U while executing INSN.
; U is a <unit> object.
; ARGS is a list of overriding arguments from INSN.

(define (-gen-insn-unit-timing model insn u args)
  (string-append
   "{ "
   "(int) " (unit:enum u) ", "
   (number->string (unit:issue u)) ", "
   (let ((cycles (assq-ref args 'cycles)))
     (if cycles
	 (number->string (car cycles))
	 (number->string (unit:done u))))
   " }, "
   )
)

; Generate timing table entry for MODEL for INSN.

(define (-gen-insn-timing model insn)
  ; Instruction timing is stored as an associative list based on the model.
  (let ((timing (assq (obj:name model) (insn-timing insn))))
    ;(display timing) (newline)
    (string-list
     "  { "
     (gen-cpu-insn-enum (mach-cpu (model:mach model)) insn)
     ", "
     (if (obj-has-attr? insn 'VIRTUAL)
	 "0"
	 (-gen-model-insn-fn-name model insn))
     ", { "
     (string-drop
      -2
      (if (not timing)
	  (-gen-insn-unit-timing model insn (model-default-unit model) nil)
	  (let ((units (timing:units (cdr timing))))
	    (string-map (lambda (iunit)
			  (-gen-insn-unit-timing model insn
						 (iunit:unit iunit)
						 (iunit:args iunit)))
			units))))
     " } },\n"
     ))
)

; Generate model timing table for MODEL.

(define (-gen-model-timing-table model)
  (string-write
   "/* Model timing data for `" (obj:str-name model) "'.  */\n\n"
   "static const INSN_TIMING " (gen-sym model) "_timing[] = {\n"
   (lambda () (string-write-map (lambda (insn) (-gen-insn-timing model insn))
				(non-alias-insns (current-insn-list))))
   "};\n\n"
   )
)

; Return C code to define model profiling support stuff.

(define (-gen-model-profile-data)
  (string-write
   "/* We assume UNIT_NONE == 0 because the tables don't always terminate\n"
   "   entries with it.  */\n\n"
   (lambda () (string-write-map -gen-model-timing-table (current-model-list)))
   )
)

; Return C code to define the model table for MACH.

(define (-gen-mach-model-table mach)
  (string-list
   "\
static const MODEL " (gen-sym mach) "_models[] =\n{\n"
   (string-list-map (lambda (model)
		      (string-list "  { "
				   "\"" (obj:str-name model) "\", "
				   "& " (gen-sym (model:mach model)) "_mach, "
				   (model:enum model) ", "
				   "TIMING_DATA (& "
				   (gen-sym model)
				   "_timing[0]), "
				   (gen-sym model) "_model_init"
				   " },\n"))
		    (find (lambda (model) (eq? (obj:name mach)
					       (obj:name (model:mach model))))
			  (current-model-list)))
   "  { 0 }\n"
   "};\n\n"
   )
)

; Return C code to define model init fn.

(define (-gen-model-init-fn model)
  (string-list "\
static void\n"
(gen-sym model) "_model_init (SIM_CPU *cpu)
{
  CPU_MODEL_DATA (cpu) = (void *) zalloc (sizeof (MODEL_"
   (string-upcase (gen-sym model))
   "_DATA));
}\n\n"
   )
)

; Return C code to define model data and support fns.

(define (-gen-model-defns)
  (string-write
   (lambda () (string-write-map -gen-model-init-fn (current-model-list)))
   "#if WITH_PROFILE_MODEL_P
#define TIMING_DATA(td) td
#else
#define TIMING_DATA(td) 0
#endif\n\n"
   (lambda () (string-write-map -gen-mach-model-table (current-mach-list)))
   )
)

; Return C definitions for this cpu family variant.

(define (-gen-cpu-defns)
  (string-list "\

static void
@cpu@_prepare_run (SIM_CPU *cpu)
{
  if (CPU_IDESC (cpu) == NULL)
    @cpu@_init_idesc_table (cpu);
}

static const CGEN_INSN *
@cpu@_get_idata (SIM_CPU *cpu, int inum)
{
  return CPU_IDESC (cpu) [inum].idata;
}

")
)

; Return C code to define the machine data.

(define (-gen-mach-defns)
  (string-list-map
   (lambda (mach)
     (gen-obj-sanitize
      mach
      (string-list "\
static void\n"
(gen-sym mach) "_init_cpu (SIM_CPU *cpu)
{
  CPU_REG_FETCH (cpu) = " (gen-sym (mach-cpu mach)) "_fetch_register;
  CPU_REG_STORE (cpu) = " (gen-sym (mach-cpu mach)) "_store_register;
  CPU_PC_FETCH (cpu) = " (gen-sym (mach-cpu mach)) "_h_pc_get;
  CPU_PC_STORE (cpu) = " (gen-sym (mach-cpu mach)) "_h_pc_set;
  CPU_GET_IDATA (cpu) = @cpu@_get_idata;
  CPU_MAX_INSNS (cpu) = @PREFIX@_INSN__MAX;
  CPU_INSN_NAME (cpu) = cgen_insn_name;
  CPU_FULL_ENGINE_FN (cpu) = @prefix@_engine_run_full;
#if WITH_FAST
  CPU_FAST_ENGINE_FN (cpu) = @prefix@_engine_run_fast;
#else
  CPU_FAST_ENGINE_FN (cpu) = @prefix@_engine_run_full;
#endif
}

const MACH " (gen-sym mach) "_mach =
{
  \"" (obj:str-name mach) "\", "
  "\"" (mach-bfd-name mach) "\", "
  (mach-enum mach) ",\n"
  "  " (number->string (cpu-word-bitsize (mach-cpu mach))) ", "
  ; FIXME: addr-bitsize: delete
  (number->string (cpu-word-bitsize (mach-cpu mach))) ", "
  "& " (gen-sym mach) "_models[0], "
  "& " (gen-sym (mach-cpu mach)) "_imp_properties,
  " (gen-sym mach) "_init_cpu,
  @cpu@_prepare_run
};

")))

   (current-mach-list))
)

; Top level file generators.

; Generate model.c

(define (cgen-model.c)
  (logit 1 "Generating " (gen-cpu-name) "'s model.c ...\n")

  (sim-analyze-insns!)

  ; Turn parallel execution support on if cpu needs it.
  (set-with-parallel?! (state-parallel-exec?))

  (string-write
   (gen-c-copyright "Simulator model support for @cpu@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#define WANT_CPU @cpu@
#define WANT_CPU_@CPU@

#include \"sim-main.h\"

/* The profiling data is recorded here, but is accessed via the profiling
   mechanism.  After all, this is information for profiling.  */

#if WITH_PROFILE_MODEL_P

"
   -gen-model-insn-fns
   -gen-model-profile-data
"#endif /* WITH_PROFILE_MODEL_P */\n\n"

   -gen-model-defns
   -gen-cpu-imp-properties
   -gen-cpu-defns
   -gen-mach-defns
   )
)
