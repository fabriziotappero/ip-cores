; Simulator model support, plus misc. things associated with a cpu family.
; Copyright (C) 2000, 2002, 2003, 2006, 2009 Red Hat, Inc.
; This file is part of CGEN.

(define (unit:enum u)
  (gen-c-symbol (string-append "UNIT_"
			       (string-upcase (obj:str-name u))))
)

; Return C code to define cpu implementation properties.

(define (-gen-cpu-imp-properties)
  (string-list
   "\
/* The properties of this cpu's implementation.  */

static const MACH_IMP_PROPERTIES @cpu@_imp_properties =
{
  sizeof (@cpu@_cpu),
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
		      (string-append "extern void @prefix@_model_mark_get_"
				     (gen-sym hw) " (@cpu@_cpu *"
				     (if (hw-scalar? hw)
					 ""
					 ", int") ; FIXME: get index type
				     ");\n"
				     "extern void @prefix@_model_mark_set_"
				     (gen-sym hw) " (@cpu@_cpu *"
				     (if (hw-scalar? hw)
					 ""
					 ", int") ; FIXME: get index type
				     ");\n"))
		    (find hw-profilable? (current-hw-list)))
   "\n"
   )
)

; Return the name of the class representing the given MODEL.
(define (gen-model-class-name model)
  (string-append "@prefix@_" (gen-sym model) "_model")
)

; Return name of profiling handler for MODEL, UNIT.
; Also called by sim.scm.

(define (gen-model-unit-fn-name model unit when)
  (string-append "model_" (gen-sym unit) "_" (symbol->string when))
)

(define (gen-model-unit-fn-decl model unit when)
  (let ((gen-args (lambda (args)
		    (gen-c-args (map (lambda (arg)
				       (string-append
					(mode:c-type (mode:lookup (cadr arg)))
					" /*" (symbol->string (car arg)) "*/"))
				     (find (lambda (arg)
					     ; Indices of scalars not passed.
					     (not (null? (cdr arg))))
					   args)))))
	)
    (string-append
     "  virtual UINT "
     (gen-model-unit-fn-name model unit when)
     " (@cpu@_cpu *cpu, const struct @prefix@_idesc *idesc,"
     " int unit_num"
     (if (equal? when 'after)
	 ", unsigned long long referenced" "")
     (gen-args (unit:inputs unit))
     (gen-args (unit:outputs unit))
     ")\n"))
)

; Return decls of all insn model handlers.

(define (gen-model-fn-decls model)
  (string-list
   "\n"
   "// Function unit handlers\n"
   "// To be overridden as needed.\n"
   (string-list-map (lambda (unit)
		      (string-append
		       (gen-model-unit-fn-decl model unit 'before)
		       "    {\n"
		       "      return 0;\n"
		       "    }\n"
		       (gen-model-unit-fn-decl model unit 'after)
		       "    {\n"
		       "      return timing[idesc->sem_index].units[unit_num].done;\n"
		       "    }\n"))
		    (model:units model))
  )
)

; Return name of profile handler for INSN, MODEL.

(define (-gen-model-insn-fn-name model insn when)
  (string-append "model_" (gen-sym insn) "_" (symbol->string when))
)

(define (-gen-model-insn-qualified-fn-name model insn when)
  (string-append (gen-model-class-name model) "::" (-gen-model-insn-fn-name model insn when))
)

; Return declaration of function to model INSN.

(define (-gen-model-insn-fn-decl model insn when)
  (string-list
   "UINT "
   (-gen-model-insn-fn-name model insn when)
   " (@cpu@_cpu *current_cpu, @prefix@_scache *sem);\n"
  )
)

(define (-gen-model-insn-fn-decls model)
  (string-list
   "  // These methods call the appropriate unit modeller(s) for each insn.\n"
   (string-list-map
    (lambda (insn)
      (string-list
       "  " (-gen-model-insn-fn-decl model insn 'before)
       "  " (-gen-model-insn-fn-decl model insn 'after)))
    (non-multi-insns (real-insns (current-insn-list))))
  )
)

; Return function to model INSN.

(define (-gen-model-insn-fn model insn when)
  (logit 2 "Processing modeling for " (obj:name insn) ": \"" (insn-syntax insn) "\" ...\n")
  (let ((sfmt (insn-sfmt insn)))
    (string-list
     "UINT\n"
     (-gen-model-insn-qualified-fn-name model insn when)
     " (@cpu@_cpu *current_cpu, @prefix@_scache *sem)\n"
     "{\n"
     (if (with-scache?)
	 (gen-define-field-macro sfmt)
	 "")
     "  const @prefix@_scache* abuf = sem;\n"
     "  const @prefix@_idesc* idesc = abuf->idesc;\n"
     ; or: idesc = & CPU_IDESC (current_cpu) ["
     ; (gen-cpu-insn-enum (mach-cpu (model:mach model)) insn)
     ; "];\n"
     "  int cycles = 0;\n"
     (send insn 'gen-profile-locals model)
     (if (with-scache?)
	 ""
	 (string-list
	  "  PCADDR UNUSED pc = current_cpu->hardware.h_pc;\n"
	  "  @prefix@_insn_word insn = abuf->insn;\n"
	  (gen-define-ifields (sfmt-iflds sfmt) (sfmt-length sfmt) "  " #f)
	  (gen-sfmt-argvars-defns sfmt)
	  (gen-extract-ifields (sfmt-iflds sfmt) (sfmt-length sfmt) "  " #f)
	  (gen-sfmt-argvars-assigns sfmt)))
     ; Emit code to model the insn.  Function units are handled here.
     (send insn 'gen-profile-code model when "cycles")
     "  return cycles;\n"
     (if (with-scache?)
	 (gen-undef-field-macro sfmt)
	 "")
     "}\n\n"))
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
		 (string-write
		  ; Generate the model constructor.
		  (gen-model-class-name model) "::" (gen-model-class-name model) " (@cpu@_cpu *cpu)\n"
		  "  : cgen_model (cpu)\n"
		  "{\n"
		  "}\n"
		  "\n")
		 (string-write-map
		  (lambda (insn)
		    (string-list
		     (-gen-model-insn-fn model insn 'before)
		     (-gen-model-insn-fn model insn 'after)))
		  (non-multi-insns (real-insns (current-insn-list)))))
	       (current-model-list)))
   )
)

(define (-gen-model-class-decls model)
  (string-append
   "\n"
   "  "
   (gen-enum-decl 'unit_number "unit types"
		  "UNIT_"
		  (cons '(none)
			(append
			 ; "apply append" squeezes out nils.
			 (apply append
				(list 
				 ; create <model_name>-<unit-name> for each unit
				 (let ((units (model:units model)))
				   (if (null? units)
				       nil
				       (map (lambda (unit)
					      (cons (obj:name unit)
						    (cons '- (atlist-attrs (obj-atlist model)))))
					    units)))))
			 '((max)))))
   "  struct unit {\n"
   "    unit_number unit;\n"
   "    UINT issue;\n"
   "    UINT done;\n"
   "  };\n\n"

   ; FIXME: revisit MAX_UNITS
  "  static const int MAX_UNITS = "
  (number->string
   (let ((insn-list (non-multi-insns (real-insns (current-insn-list)))))
     (if (null? insn-list)
	 1
	 (apply max
		(map (lambda (lengths) (apply max lengths))
		     (map (lambda (insn)
			    (let ((timing (insn-timing insn)))
			      (if (null? timing)
				  '(1)
				  (map (lambda (insn-timing)
					 (if (null? (cdr insn-timing))
					     '1
					     (length (timing:units (cdr insn-timing)))))
				       timing))))
			  insn-list))))))
   ";\n"
  )
)

; Return the C++ class representing the given model.
(define (gen-model-class model)
  (string-list
   "\
class " (gen-model-class-name model) " : public cgen_model
{
public:
  " (gen-model-class-name model) " (@cpu@_cpu *cpu);

  // Call the proper unit modelling function for the given insn.
  UINT model_before (@cpu@_cpu *current_cpu, @prefix@_scache* sem)
    {
      return (this->*(timing[sem->idesc->sem_index].model_before)) (current_cpu, sem);
    } 
  UINT model_after (@cpu@_cpu *current_cpu, @prefix@_scache* sem)
    {
      return (this->*(timing[sem->idesc->sem_index].model_after)) (current_cpu, sem);
    } 
"
   (gen-model-fn-decls model)
   "\

protected:
"
   (-gen-model-insn-fn-decls model)
   (-gen-model-class-decls model)
"\

  typedef UINT (" (gen-model-class-name model) "::*model_function) (@cpu@_cpu* current_cpu, @prefix@_scache* sem);

  struct insn_timing {
    // This is an integer that identifies this insn.
    UINT num;
    // Functions to handle insn-specific profiling.
    model_function model_before;
    model_function model_after;
    // Array of function units used by this insn.
    unit units[MAX_UNITS];
  };

  static const insn_timing timing[];
};
"
  )
)

; Return the C++ classes representing the current list of models.
(define (gen-model-classes)
   (string-list-map
    (lambda (model)
      (string-list
       "\n"
       (gen-model-class model)))
    (current-model-list))
)

; Generate timing table entry for function unit U while executing INSN.
; U is a <unit> object.
; ARGS is a list of overriding arguments from INSN.

(define (-gen-insn-unit-timing model insn u args)
  (string-append
   "{ "
   (gen-model-class-name model) "::" (unit:enum u) ", "
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
	 "0, 0"
	 (string-append
	  "& " (-gen-model-insn-qualified-fn-name model insn 'before) ", "
	  "& " (-gen-model-insn-qualified-fn-name model insn 'after)))
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
   "/* Model timing data for `" (obj:name model) "'.  */\n\n"
   "const " (gen-model-class-name model) "::insn_timing " (gen-model-class-name model) "::timing[] = {\n"
   (lambda () (string-write-map (lambda (insn) (-gen-insn-timing model insn))
				(non-multi-insns (non-alias-insns (current-insn-list)))))
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
				   "\"" (obj:name model) "\", "
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
(gen-sym model) "_model_init (@cpu@_cpu *cpu)
{
  cpu->model_data = new @PREFIX@_MODEL_DATA;
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
  "" 
)

; Return C code to define the machine data.

(define (-gen-mach-defns)
  (string-list-map
   (lambda (mach)
     (gen-obj-sanitize
      mach
      (string-list "\
static void\n"
(gen-sym mach) "_init_cpu (@cpu@_cpu *cpu)
{
  @prefix@_init_idesc_table (cpu);
}

const MACH " (gen-sym mach) "_mach =
{
  \"" (obj:name mach) "\", "
  "\"" (mach-bfd-name mach) "\",
  " (number->string (cpu-word-bitsize (mach-cpu mach))) ", "
  ; FIXME: addr-bitsize: delete
  (number->string (cpu-word-bitsize (mach-cpu mach))) ", "
  "& " (gen-sym mach) "_models[0], "
  "& " (gen-sym (mach-cpu mach)) "_imp_properties,
  " (gen-sym mach) "_init_cpu
};

")))

   (current-mach-list))
)

; Top level file generators.

; Generate model.cxx

(define (cgen-model.cxx)
  (logit 1 "Generating " (gen-cpu-name) "-model.cxx ...\n")
  (assert-keep-one)

  ; Turn parallel execution support on if cpu needs it.
  (set-with-parallel?! (state-parallel-exec?))

  (string-write
   (gen-c-copyright "Simulator model support for @prefix@."
		  copyright-red-hat package-red-hat-simulators)
   "\

#if HAVE_CONFIG_H
#include \"config.h\"
#endif
#include \"@cpu@.h\"

using namespace @cpu@; // FIXME: namespace organization still wip

/* The profiling data is recorded here, but is accessed via the profiling
   mechanism.  After all, this is information for profiling.  */

"
   -gen-model-insn-fns
   -gen-model-profile-data
;  not adapted for sid yet
;   -gen-model-defns
;   -gen-cpu-imp-properties
;   -gen-cpu-defns
;   -gen-mach-defns
   )
)

(define (cgen-model.h)
  (logit 1 "Generating " (gen-cpu-name) "-model.h ...\n")
  (assert-keep-one)

  (string-write
   (gen-c-copyright "Simulator model support for @prefix@."
		  copyright-red-hat package-red-hat-simulators)
   "\
#ifndef @PREFIX@_MODEL_H
#define @PREFIX@_MODEL_H

#include \"cgen-cpu.h\"
#include \"cgen-model.h\"

namespace @cpu@
{
using namespace cgen;
"
   (gen-model-classes)
   "\

} // namespace @cpu@

#endif // @PREFIX@_MODEL_H
"
  )
)
