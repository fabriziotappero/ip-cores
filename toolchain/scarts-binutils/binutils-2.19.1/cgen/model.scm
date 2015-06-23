; CPU implementation description.
; Copyright (C) 2000, 2003, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; A model is an implementation of a mach.
; NOTE: wip [with all the caveats that implies].
; The intent here is to define the aspects of a CPU that affect performance,
; usable by any tool (but for the immediate future a simulator).

; Pipeline specification.

(define <pipeline>
  (class-make '<pipeline> nil '(name comment atlist elms) nil))

(define (pipeline:length p) (length (elm-xget p 'elms)))

; Function unit specification.

; FIXME: Might wish to record which pipeline element(s) the unit is associated
; with.  At the moment pipeline data isn't used, but later.

(define <unit>
  (class-make '<unit>
	      '(<ident>)
	      '(
		; wip
		issue done
		; Lists of (name mode) pairs that record unit state.
		state
		; Lists of (name mode [default-value]).
		inputs outputs
		; RTL of code to invoke to do profiling.
		; `nil' means use the default
		; ??? Not currently used since all profiling handlers
		; are user-written.
		profile
		; Model this unit is associated with.
		model-name
		)
	      nil))

; ??? Rather than create a circularity, we record the model's symbol in
; the `model' element.
; FIXME: Shouldn't use current-model-lookup.  Guile is better at printing
; things with circularities now, so should probably put back the circularity
; and delete the current-model-lookup reference.
(define (unit:model u) (current-model-lookup (elm-xget u 'model-name)))
(define unit:issue (elm-make-getter <unit> 'issue))
(define unit:done (elm-make-getter <unit> 'done))
(define unit:state (elm-make-getter <unit> 'state))
(define unit:inputs (elm-make-getter <unit> 'inputs))
(define unit:outputs (elm-make-getter <unit> 'outputs))
(define unit:profile (elm-make-getter <unit> 'profile))

; Create a copy of unit U with new values for ISSUE and DONE.
; This is used when recording an instruction's timing information.
; ??? This might be better recorded in a different class from UNIT
; since we're not creating a new unit, we're just special casing it for
; one instruction.
; FIXME: No longer used.

(define (unit:make-insn-timing u issue done)
  (let ((result (object-copy-top u)))
    (elm-xset! result 'issue issue)
    (elm-xset! result 'done done)
    result)
)

; The `<model>' class.
;
; FETCH is the instruction fetch process as it relates to the implementation.
; e.g.
; - how many instructions are fetched at once
; - how those instructions are initially processed for delivery to the
;   appropriate pipeline
; RETIRE is used to specify any final processing needed to complete an insn.
; PIPELINES is a list of pipeline objects.
; UNITS is a list of function units.
; STATE is a list of (var mode) pairs.
;
; For the more complicated cpus this can get really complicated really fast.
; No intent is made to get there in one day.

(define <model>
  (class-make '<model>
	      '(<ident>)
	      '(mach prefetch retire pipelines state units)
	      nil))

(define model:mach (elm-make-getter <model> 'mach))
(define model:prefetch (elm-make-getter <model> 'prefetch))
(define model:retire (elm-make-getter <model> 'retire))
(define model:pipelines (elm-make-getter <model> 'pipelines))
(define model:state (elm-make-getter <model> 'state))
(define model:units (elm-make-getter <model> 'units))

(define (model:enum m)
  (gen-c-symbol (string-append "MODEL_" (string-upcase (obj:str-name m))))
)

(define (models-for-mach mach)
  (let ((mach-name (obj:name mach)))
    (find (lambda (model)
	    (eq? (obj:name (model:mach model)) mach-name))
	  (current-model-list)))
)

; Parse a `prefetch' spec.

(define (-prefetch-parse context expr)
  nil
)

; Parse a `retire' spec.

(define (-retire-parse context expr)
  nil
)

; Parse a `pipeline' spec.
; ??? Perhaps we should also use name/value pairs here, but that's an
; unnecessary complication at this point in time.

(define (-pipeline-parse context model-name spec) ; name comments attrs elements)
  (if (not (= (length spec) 4))
      (parse-error context "pipeline spec not `name comment attrs elements'" spec))
  (apply make (cons <pipeline> spec))
)

; Parse a function `unit' spec.
; ??? Perhaps we should also use name/value pairs here, but that's an
; unnecessary complication at this point in time.

(define (-unit-parse context model-name spec) ; name comments attrs elements)
  (if (not (= (length spec) 9))
      (parse-error context "unit spec not `name comment attrs issue done state inputs outputs profile'" spec))
  (apply make (append (cons <unit> spec) (list model-name)))
)

; Parse a model definition.
; This is the main routine for building a model object from a
; description in the .cpu file.
; All arguments are in raw (non-evaluated) form.

(define (-model-parse context name comment attrs mach-name prefetch retire pipelines state units)
  (logit 2 "Processing model " name " ...\n")

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name))
	 (mach (current-mach-lookup mach-name)))

    (if (null? units)
	(parse-error context "there must be at least one function unit" name))

    (if mach ; is `mach' being "kept"?
	(let ((model-obj
	       (make <model>
		     name
		     (parse-comment context comment)
		     (atlist-parse context attrs "cpu")
		     mach
		     (-prefetch-parse context prefetch)
		     (-retire-parse context retire)
		     (map (lambda (p) (-pipeline-parse context name p)) pipelines)
		     state
		     (map (lambda (u) (-unit-parse context name u)) units))))
	  model-obj)

	(begin
	  ; MACH wasn't found, ignore this model.
	  (logit 2 "Nonexistant mach " mach-name ", ignoring " name ".\n")
	  #f)))
)

; Read a model description.
; This is the main routine for analyzing models in the .cpu file.
; CONTEXT is a <context> object for error messages.
; ARG-LIST is an associative list of field name and field value.
; -model-parse is invoked to create the `model' object.

(define (-model-read context . arg-list)
  (let (
	(name nil)      ; name of model
	(comment nil)   ; description of model
	(attrs nil)     ; attributes
	(mach nil)      ; mach this model implements
	(prefetch nil)  ; instruction prefetch handling
	(retire nil)    ; instruction completion handling
	(pipelines nil) ; list of pipelines
	(state nil)     ; list of (name mode) pairs to record state
	(units nil)     ; list of function units
	)

    (let loop ((arg-list arg-list))
      (if (null? arg-list)
	  nil
	  (let ((arg (car arg-list))
		(elm-name (caar arg-list)))
	    (case elm-name
	      ((name) (set! name (cadr arg)))
	      ((comment) (set! comment (cadr arg)))
	      ((attrs) (set! attrs (cdr arg)))
	      ((mach) (set! mach (cadr arg)))
	      ((prefetch) (set! prefetch (cadr arg)))
	      ((retire) (set! retire (cadr arg)))
	      ((pipeline) (set! pipelines (cons (cdr arg) pipelines)))
	      ((state) (set! state (cdr arg)))
	      ((unit) (set! units (cons (cdr arg) units)))
	      (else (parse-error context "invalid model arg" arg)))
	    (loop (cdr arg-list)))))

    ; Now that we've identified the elements, build the object.
    (-model-parse context name comment attrs mach prefetch retire pipelines state units))
)

; Define a cpu model object, name/value pair list version.

(define define-model
  (lambda arg-list
    (let ((m (apply -model-read (cons (make-current-context "define-model")
				      arg-list))))
      (if m
	  (current-model-add! m))
      m))
)

; Instruction timing.

; There is one of these for each model timing description per instruction.

(define <timing> (class-make '<timing> nil '(model units) nil))

(define timing:model (elm-make-getter <timing> 'model))
(define timing:units (elm-make-getter <timing> 'units))

; timing:units is a list of these.
; ARGS is a list of (name value) pairs.

(define <iunit> (class-make '<iunit> nil '(unit args) nil))

(define iunit:unit (elm-make-getter <iunit> 'unit))
(define iunit:args (elm-make-getter <iunit> 'args))

; Return the default unit used by MODEL.
; ??? For now this is always u-exec.

(define (model-default-unit model)
  (object-assq 'u-exec (model:units model))
)

; Subroutine of parse-insn-timing to parse the timing spec for MODEL.
; The result is a <timing> object.

(define (-insn-timing-parse-model context model spec)
  (make <timing> model
	(map (lambda (unit-timing-desc)
	       (let ((type (car unit-timing-desc))
		     (args (cdr unit-timing-desc)))
		 (case type
		   ((unit) ; syntax is `unit name (arg1 val1) ...'
		    (let ((unit (object-assq (car args)
					     (model:units model))))
		      (if (not unit)
			  (parse-error context "unknown function unit" args))
		      (make <iunit> unit (cdr args))))
		   (else (parse-error context "bad unit timing spec"
				      unit-timing-desc)))))
	     spec))
)

; Given the timing information for an instruction return an associative
; list of timing objects (one for each specified model).
; INSN-TIMING-DESC is a list of
; (model1 (unit unit1-name ...) ...) (model2 (unit unit1-name ...) ...) ...
; Entries for models not included (because the machine wasn't selected)
; are returned as (model1), i.e. an empty unit list.

(define (parse-insn-timing context insn-timing-desc)
  (logit 3 "  parse-insn-timing: context= " (context-prefix context)
	 ", desc= " insn-timing-desc "\n")
  (map (lambda (model-timing-desc)
	 (let* ((model-name (car model-timing-desc))
		(model (current-model-lookup model-name)))
	   (cons model-name
		 (if model
		     (-insn-timing-parse-model context model
					       (cdr model-timing-desc))
		     '()))))
       insn-timing-desc)
)

; Called before a .cpu file is read in.

(define (model-init!)

  (reader-add-command! 'define-model
		       "\
Define a cpu model, name/value pair list version.
"
		       nil 'arg-list define-model
  )

  *UNSPECIFIED*
)

; Called after a .cpu file has been read in.

(define (model-finish!)
  *UNSPECIFIED*
)
