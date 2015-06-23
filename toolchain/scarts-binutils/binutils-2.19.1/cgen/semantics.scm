; Routines for instruction semantic analysis.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.
;
; Semantic expression compilation.
; This is more involved than normal rtx compilation as we need to keep
; track of the inputs and outputs.  Various attributes that can be derived
; from the code are also computed.

; Subroutine of -rtx-find-op to determine if two modes are equivalent.
; Two modes are equivalent if they're equal, or if their sem-mode fields
; are equal.

(define (-rtx-mode-equiv? m1 m2)
  (or (eq? m1 m2)
      (let ((mode1 (mode:lookup m1))
	    (mode2 (mode:lookup m2)))
	(let ((s1 (mode:sem-mode mode1))
	      (s2 (mode:sem-mode mode2)))
	  (eq? (if s1 (obj:name s1) m1) (if s2 (obj:name s2) m2)))))
)

; Subroutine of semantic-compile to find OP in OP-LIST.
; OP-LIST is a list of operand expressions: (type expr mode name indx-sel).
; The result is the list element or #f if not found.
; TYPE is one of -op- reg mem.
; EXPR is the constructed `xop' rtx expression for the operand,
;   ignored in the search.
; MODE must match, as defined by -rtx-mode-equiv?.
; NAME is the hardware element name, ifield name, or '-op-'.
; INDX-SEL must match if present in either.
;
; ??? Does this need to take "conditionally-referenced" into account?

(define (-rtx-find-op op op-list)
  (let ((type (car op))
	(mode (caddr op))
	(name (cadddr op))
	(indx-sel (car (cddddr op))))
    ; The first cdr is to drop the dummy first arg.
    (let loop ((op-list (cdr op-list)))
      (cond ((null? op-list) #f)
	    ((eq? type (caar op-list))
	     (let ((try (car op-list)))
	       (if (and (eq? name (cadddr try))
			(-rtx-mode-equiv? mode (caddr try))
			(equal? indx-sel (car (cddddr try))))
		   try
		   (loop (cdr op-list)))))
	    (else (loop (cdr op-list))))))
)

; Subroutine of semantic-compile to determine how the operand in
; position OP-POS of EXPR is used.
; The result is one of 'use, 'set, 'set-quiet.
; "use" means "input operand".

(define (-rtx-ref-type expr op-pos)
  ; operand 0 is the option list, operand 1 is the mode
  ; (if you want to complain, fine, it's not like it would be unexpected)
  (if (= op-pos 2)
      (case (car expr)
	((set) 'set)
	((set-quiet clobber) 'set-quiet)
	(else 'use))
      'use)
)

; Subroutine of semantic-compile:process-expr!, to simplify it.
; Looks up the operand in the current set, returns it if found,
; otherwise adds it.
; REF-TYPE is one of 'use, 'set, 'set-quiet.
; Adds COND-CTI/UNCOND-CTI to SEM-ATTRS if the operand is a set of the pc.

(define (-build-operand! op-name op mode tstate ref-type op-list sem-attrs)
  ;(display (list op-name mode ref-type)) (newline) (force-output)
  (let* ((mode (mode-real-name (if (eq? mode 'DFLT)
				   (op:mode op)
				   mode)))
         ; The first #f is a placeholder for the object.
	 (try (list '-op- #f mode op-name #f))
	 (existing-op (-rtx-find-op try op-list)))

    (if (and (pc? op)
	     (memq ref-type '(set set-quiet)))
	(append! sem-attrs
		 (list (if (tstate-cond? tstate) 'COND-CTI 'UNCOND-CTI))))

    ; If already present, return the object, otherwise add it.
    (if existing-op

	(cadr existing-op)

	; We can't set the operand number yet 'cus we don't know it.
	; However, when it's computed we'll need to set all associated
	; operands.  This is done by creating shared rtx (a la gcc) - the
	; operand number then need only be updated in one place.

	(let ((xop (op:new-mode op mode)))
	  (op:set-cond?! xop (tstate-cond? tstate))
	  ; Set the object rtx in `try', now that we have it.
	  (set-car! (cdr try) (rtx-make 'xop xop))
	  ; Add the operand to in/out-ops.
	  (append! op-list (list try))
	  (cadr try))))
)

; Subroutine of semantic-compile:process-expr!, to simplify it.

(define (-build-reg-operand! expr tstate op-list)
  (let* ((hw-name (rtx-reg-name expr))
	 (hw (current-hw-sem-lookup-1 hw-name)))

    (if hw
	; If the mode is DFLT, use the object's natural mode.
	(let* ((mode (mode-real-name (if (eq? (rtx-mode expr) 'DFLT)
					 (obj:name (hw-mode hw))
					 (rtx-mode expr))))
	       (indx-sel (rtx-reg-index-sel expr))
	       ; #f is a place-holder for the object (filled in later)
	       (try (list 'reg #f mode hw-name indx-sel))
	       (existing-op (-rtx-find-op try op-list)))

	  ; If already present, return the object, otherwise add it.
	  (if existing-op

	      (cadr existing-op)

	      (let ((xop (apply reg (cons (tstate->estate tstate)
					  (cons mode
						(cons hw-name indx-sel))))))
		(op:set-cond?! xop (tstate-cond? tstate))
		; Set the object rtx in `try', now that we have it.
		(set-car! (cdr try) (rtx-make 'xop xop))
		; Add the operand to in/out-ops.
		(append! op-list (list try))
		(cadr try))))

	(parse-error (tstate-context tstate) "unknown reg" expr)))
)

; Subroutine of semantic-compile:process-expr!, to simplify it.

(define (-build-mem-operand! expr tstate op-list)
  (let ((mode (rtx-mode expr))
	(indx-sel (rtx-mem-index-sel expr)))

    (if (memq mode '(DFLT VOID))
	(parse-error (tstate-context tstate)
		     "memory must have explicit mode" expr))

    (let* ((try (list 'mem #f mode 'h-memory indx-sel))
	   (existing-op (-rtx-find-op try op-list)))

      ; If already present, return the object, otherwise add it.
      (if existing-op

	  (cadr existing-op)

	  (let ((xop (apply mem (cons (tstate->estate tstate)
				      (cons mode indx-sel)))))
	    (op:set-cond?! xop (tstate-cond? tstate))
	    ; Set the object in `try', now that we have it.
	    (set-car! (cdr try) (rtx-make 'xop xop))
	    ; Add the operand to in/out-ops.
	    (append! op-list (list try))
	    (cadr try)))))
)

; Subroutine of semantic-compile:process-expr!, to simplify it.

(define (-build-ifield-operand! expr tstate op-list)
  (let* ((f-name (rtx-ifield-name expr))
	 (f (current-ifld-lookup f-name)))

    (if (not f)
	(parse-error (tstate-context tstate) "unknown ifield" f-name))

    (let* ((mode (obj:name (ifld-mode f)))
	   (try (list '-op- #f mode f-name #f))
	   (existing-op (-rtx-find-op try op-list)))

      ; If already present, return the object, otherwise add it.
      (if existing-op

	  (cadr existing-op)

	  (let ((xop (make <operand> (obj-location f)
			   f-name f-name
			   (atlist-cons (bool-attr-make 'SEM-ONLY #t)
					(obj-atlist f))
			   (obj:name (ifld-hw-type f))
			   mode
			   (make <hw-index> 'anonymous
				 'ifield (ifld-mode f) f)
			   nil #f #f)))
	    (set-car! (cdr try) (rtx-make 'xop xop))
	    (append! op-list (list try))
	    (cadr try)))))
)

; Subroutine of semantic-compile:process-expr!, to simplify it.
;
; ??? There are various optimizations (both space usage in ARGBUF and time
; spent in semantic code) that can be done on code that uses index-of
; (see i960's movq insn).  Later.

(define (-build-index-of-operand! expr tstate op-list)
  (if (not (and (rtx? (rtx-index-of-value expr))
		(rtx-kind? 'operand (rtx-index-of-value expr))))
      (parse-error (tstate-context tstate)
		   "only `(index-of operand)' is currently supported"
		   expr))

  (let ((op (rtx-operand-obj (rtx-index-of-value expr))))
    (let ((indx (op:index op)))
      (if (not (eq? (hw-index:type indx) 'ifield))
	  (parse-error (tstate-context tstate)
		       "only ifield indices are currently supported"
		       expr))
      (let* ((f (hw-index:value indx))
	     (f-name (obj:name f)))
	; The rest of this is identical to -build-ifield-operand!.
	(let* ((mode (obj:name (ifld-mode f)))
	       (try (list '-op- #f mode f-name #f))
	       (existing-op (-rtx-find-op try op-list)))

	  ; If already present, return the object, otherwise add it.
	  (if existing-op

	      (cadr existing-op)

	      (let ((xop (make <operand> (if (source-ident? f) (obj-location f) #f)
			       f-name f-name
			       (atlist-cons (bool-attr-make 'SEM-ONLY #t)
					    (obj-atlist f))
			       (obj:name (ifld-hw-type f))
			       mode
			       (make <hw-index> 'anonymous
				     'ifield
				     (ifld-mode f)
				     ; (send (op:type op) 'get-index-mode)
				     f)
			       nil #f #f)))
		(set-car! (cdr try) (rtx-make 'xop xop))
		(append! op-list (list try))
		(cadr try)))))))
)

; Build the tstate known value list for INSN.
; This is built from the ifield-assertion list.

(define (insn-build-known-values insn)
  (let ((expr (insn-ifield-assertion insn)))
    (if expr
	(case (rtx-name expr)
	  ((eq)
	   (if (and (rtx-kind? 'ifield (rtx-cmp-op-arg expr 0))
		    (rtx-constant? (rtx-cmp-op-arg expr 1)))
	       (list (cons (rtx-ifield-name (rtx-cmp-op-arg expr 0))
			   (rtx-cmp-op-arg expr 1)))
	       nil))
	  ((member)
	   (if (rtx-kind? 'ifield (rtx-member-value expr))
	       (list (cons (rtx-ifield-name (rtx-member-value expr))
			   (rtx-member-set expr)))
	       nil))
	  (else nil))
	nil))
)

; Structure to record the result of semantic-compile.

(define (csem-make compiled-code inputs outputs attributes)
  (vector compiled-code inputs outputs attributes)
)

; Accessors.

(define (csem-code csem) (vector-ref csem 0))
(define (csem-inputs csem) (vector-ref csem 1))
(define (csem-outputs csem) (vector-ref csem 2))
(define (csem-attrs csem) (vector-ref csem 3))

; Traverse each element in SEM-CODE, converting them to canonical form,
; and computing the input and output operands.
; The result is an object of four elements (built with csem-make).
; The first is a list of the canonical form of each element in SEM-CODE:
; operand and ifield elements specified without `operand' or `ifield' have it
; prepended, and operand numbers are computed for each operand.
; Operand numbers are needed when emitting "write" handlers for LIW cpus.
; Having the operand numbers available is also useful for efficient
; modeling: recording operand references can be done with a bitmask (one host
; insn), and the code to do the modeling can be kept out of the code that
; performs the insn.
; The second is the list of input <operand> objects.
; The third is the list of output <operand> objects.
; The fourth is an <attr-list> object of attributes that can be computed from
; the semantics.
; The possibilities are: UNCOND-CTI, COND-CTI, SKIP-CTI, DELAY-SLOT.
; ??? Combine *-CTI into an enum attribute.
;
; CONTEXT is a <context> object or #f if there is none.
; INSN is the <insn> object.
;
; ??? Specifying operand ordinals in the source would simplify this and speed
; it up.  On the other hand that makes the source form more complex.  Maybe the
; complexity will prove necessary, but following the goal of "incremental
; complication", we don't do this yet.
; Another way to simplify this and speed it up would be to add lists of
; input/output operands to the instruction description.
;
; ??? This calls rtx-simplify which calls rtx-traverse as it's simpler to
; simplify EXPR first, and then compile it.  On the other hand it's slower
; (two calls to rtx-traverse!).

(define (semantic-compile context insn sem-code)
  (assert (rtx? sem-code))

  (let*
      (
       ; These record the result of traversing SEM-CODE.
       ; They're lists of (type object mode name [args ...]).
       ; TYPE is one of: -op- reg mem.
       ; `-op-' is just something unique and is only used internally.
       ; OBJECT is the constructed <operand> object.
       ; The first element is just a dummy so that append! always works.
       (in-ops (list (list #f)))
       (out-ops (list (list #f)))

       ; List of attributes computed from SEM-CODE.
       ; The first element is just a dummy so that append! always works.
       (sem-attrs (list #f))

       ; Called for expressions encountered in SEM-CODE.
       ; Don't waste cpu here, this is part of the slowest piece in CGEN.
       (process-expr!
	(lambda (rtx-obj expr mode parent-expr op-pos tstate appstuff)
	  (case (car expr)

	    ; Registers.
	    ((reg) (let ((ref-type (-rtx-ref-type parent-expr op-pos))
			 ; ??? could verify reg is a scalar
			 (regno (or (rtx-reg-number expr) 0)))
		     ; The register number is either a number or an
		     ; expression.
		     ; ??? This is a departure from GCC RTL that might have
		     ; significant ramifications.  On the other hand in cases
		     ; where it matters the expression could always be
		     ; required to reduce to a constant (or some such).
		     (cond ((number? regno) #t)
			   ((form? regno)
			    (rtx-traverse-operands rtx-obj expr tstate appstuff))
			   (else (parse-error (tstate-context tstate)
					      "invalid register number"
					      regno)))
		     (-build-reg-operand! expr tstate
					  (if (eq? ref-type 'use)
					      in-ops
					      out-ops))))

	    ; Memory.
	    ((mem) (let ((ref-type (-rtx-ref-type parent-expr op-pos)))
		     (rtx-traverse-operands rtx-obj expr tstate appstuff)
		     (-build-mem-operand! expr tstate
					  (if (eq? ref-type 'use)
					      in-ops
					      out-ops))))

	    ; Operands.
	    ((operand) (let ((op (rtx-operand-obj expr))
			     (ref-type (-rtx-ref-type parent-expr op-pos)))
			 (-build-operand! (obj:name op) op mode tstate ref-type
					  (if (eq? ref-type 'use)
					      in-ops
					      out-ops)
					  sem-attrs)))

	    ; Give operand new name.
	    ((name) (let ((result (-rtx-traverse (caddr expr) 'RTX mode
						 parent-expr op-pos tstate appstuff)))
		      (if (not (operand? result))
			  (error "name: invalid argument:" expr result))
		      (op:set-sem-name! result (cadr expr))
		      ; (op:set-num! result (caddr expr))
		      result))

	    ; Specify a reference to a local variable
	    ((local) expr) ; nothing to do

	    ; Instruction fields.
	    ((ifield) (let ((ref-type (-rtx-ref-type parent-expr op-pos)))
			(if (not (eq? ref-type 'use))
			    (parse-error (tstate-context tstate)
					 "can't set an `ifield'" expr))
			(-build-ifield-operand! expr tstate in-ops)))

	    ; Hardware indices.
	    ; For registers this is the register number.
	    ; For memory this is the address.
	    ; For constants, this is the constant.
	    ((index-of) (let ((ref-type (-rtx-ref-type parent-expr op-pos)))
			  (if (not (eq? ref-type 'use))
			      (parse-error (tstate-context tstate)
					   "can't set an `index-of'" expr))
			  (-build-index-of-operand! expr tstate in-ops)))

	    ; Machine generate the SKIP-CTI attribute.
	    ((skip) (append! sem-attrs (list 'SKIP-CTI)) #f)

	    ; Machine generate the DELAY-SLOT attribute.
	    ((delay) (append! sem-attrs (list 'DELAY-SLOT)) #f)

	    ; If this is a syntax expression, the operands won't have been
	    ; processed, so tell our caller we want it to by returning #f.
	    ; We do the same for non-syntax expressions to keep things
	    ; simple.  This requires collaboration with the traversal
	    ; handlers which are defined to do what we want if we return #f.
	    (else #f))))

       ; Whew.  We're now ready to traverse the expression.
       ; Traverse the expression recording the operands and building objects
       ; for most elements in the source representation.
       ; This also performs various simplifications.
       ; In particular machine dependent code for non-selected machines
       ; is discarded.
       (compiled-expr (rtx-traverse
		       context
		       insn
		       (rtx-simplify context insn sem-code
				     (insn-build-known-values insn))
		       process-expr!
		       #f))
       )

    ;(display "in:  ") (display in-ops) (newline)
    ;(display "out: ") (display out-ops) (newline)
    ;(force-output)

    ; Now that we have the nub of all input and output operands,
    ; we can assign operand numbers.  Inputs and outputs are not defined
    ; separately, output operand numbers follow inputs.  This simplifies the
    ; code which keeps track of such things: it can use one variable.
    ; The assignment is defined to be arbitrary.  If there comes a day
    ; when we need to prespecify operand numbers, revisit.
    ; The operand lists are sorted to avoid spurious differences in generated
    ; code (for example unnecessary extra entries can be created in the
    ; ARGBUF struct).

    ; Drop dummy first arg and sort operand lists.
    (let ((sorted-ins
	   (alpha-sort-obj-list (map (lambda (op)
				       (rtx-xop-obj (cadr op)))
				     (cdr in-ops))))
	  (sorted-outs
	   (alpha-sort-obj-list (map (lambda (op)
				       (rtx-xop-obj (cadr op)))
				     (cdr out-ops))))
	  (sem-attrs (cdr sem-attrs)))

      (let ((in-op-nums (iota (length sorted-ins)))
	    (out-op-nums (iota (length sorted-outs) (length sorted-ins))))

	(for-each (lambda (op num) (op:set-num! op num))
		  sorted-ins in-op-nums)
	(for-each (lambda (op num) (op:set-num! op num))
		  sorted-outs out-op-nums)

	(let ((dump (lambda (op)
		      (string/symbol-append "  "
					    (obj:name op)
					    " "
					    (number->string (op:num op))
					    "\n"))))
	  (logit 4
		 "Input operands:\n"
		 (map dump sorted-ins)
		 "Output operands:\n"
		 (map dump sorted-outs)
		 "End of operands.\n"))

	(csem-make compiled-expr sorted-ins sorted-outs
		   (atlist-parse context sem-attrs "")))))
)

; Traverse SEM-CODE, computing attributes derivable from it.
; The result is an <attr-list> object of attributes that can be computed from
; the semantics.
; The possibilities are: UNCOND-CTI, COND-CTI, SKIP-CTI, DELAY-SLOT.
; This computes the same values as semantic-compile, but for speed is
; focused on attributes only.
; ??? Combine *-CTI into an enum attribute.
;
; CONTEXT is a <context> object or #f if there is none.
; INSN is the <insn> object.

(define (semantic-attrs context insn sem-code)
  (assert (rtx? sem-code))

  (let*
      (
       ; List of attributes computed from SEM-CODE.
       ; The first element is just a dummy so that append! always works.
       (sem-attrs (list #f))

       ; Called for expressions encountered in SEM-CODE.
       (process-expr!
	(lambda (rtx-obj expr mode parent-expr op-pos tstate appstuff)
	  (case (car expr)

	    ((operand) (if (and (eq? 'pc (obj:name (rtx-operand-obj expr)))
				(memq (-rtx-ref-type parent-expr op-pos)
				      '(set set-quiet)))
			   (append! sem-attrs
				    (if (tstate-cond? tstate)
					; Don't change these to '(FOO), since
					; we use append!.
					(list 'COND-CTI)
					(list 'UNCOND-CTI)))))
	    ((skip) (append! sem-attrs (list 'SKIP-CTI)) #f)
	    ((delay) (append! sem-attrs (list 'DELAY-SLOT)) #f)

	    ; If this is a syntax expression, the operands won't have been
	    ; processed, so tell our caller we want it to by returning #f.
	    ; We do the same for non-syntax expressions to keep things
	    ; simple.  This requires collaboration with the traversal
	    ; handlers which are defined to do what we want if we return #f.
	    (else #f))))

       ; Traverse the expression recording the attributes.
       (traversed-expr (rtx-traverse
			context
			insn
			(rtx-simplify context insn sem-code
				      (insn-build-known-values insn))
			process-expr!
			#f))
       )

    (let
	; Drop dummy first arg.
	((sem-attrs (cdr sem-attrs)))
      (atlist-parse context sem-attrs "")))
)
