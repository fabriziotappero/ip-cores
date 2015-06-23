; Macro instruction definitions.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; Expansion:
; If the macro expands to a string, arguments in the input string
; are refered to with %N.  Multiple insns are separated with '\n'.
; String expansion is a special case of the normal form which is a Scheme
; expression that controls the expansion.  The Scheme expression will be able
; to refer to the current assembly state to decide how to perform the
; expansion.  Special expression `emit' is used to call the assembler emitter
; for a particular insn.  Special expression `expand' is used to return a
; string to be reparsed (which is special cased).

; Parse a list of macro-instruction expansion descriptions.
; This is the main routine for building an minsn-expansion object from a
; description in the .cpu file.
; All arguments are in raw (non-evaluated) form.

; ??? At present we only support macros that are aliases of one real insn.

; Object to describe a macro-insn.

(define <macro-insn>
  (class-make '<macro-insn>
	      '(<source-ident>)
	      '(
		; syntax of the macro
		syntax
		; list of expansion expressions
		expansions
		)
	      nil)
)

(method-make-make! <macro-insn>
		   '(location name comment attrs syntax expansions))

; Accessor fns

(define minsn-syntax (elm-make-getter <macro-insn> 'syntax))
(define minsn-expansions (elm-make-getter <macro-insn> 'expansions))

; Return a list of the machs that support MINSN.

(define (minsn-machs minsn)
  nil
)

; Return macro-instruction mnemonic.
; This is computed from the syntax string.

(define minsn-mnemonic insn-mnemonic)

; Return enum cgen_minsn_types value for MINSN.

(define (minsn-enum minsn)
  (string-upcase (string-append "@ARCH@_MINSN_" (gen-sym minsn)))
)

; Parse a macro-insn expansion description.
; ??? At present we only support unconditional simple expansion.

(define (-minsn-parse-expansion context expn)
  (if (not (form? expn))
      (parse-error context "invalid macro expansion" expn))
  (if (not (eq? 'emit (car expn)))
      (parse-error context "invalid macro expansion, must be `(emit ...)'" expn))
  expn
)

; Parse a macro-instruction description.
; This is the main routine for building a macro-insn object from a
; description in the .cpu file.
; All arguments are in raw (non-evaluated) form.
; The result is the parsed object or #f if object isn't for selected mach(s).

(define (-minsn-parse context name comment attrs syntax expansions)
  (logit 2 "Processing macro-insn " name " ...\n")

  (if (not (list? expansions))
      (parse-error context "invalid macro expansion list" expansions))

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name))
	 (atlist-obj (atlist-parse context attrs "cgen_minsn")))

    (if (keep-atlist? atlist-obj #f)

	(let ((result (make <macro-insn>
			(context-location context)
			name
			(parse-comment context comment)
			atlist-obj
			(parse-syntax context syntax)
			(map (lambda (e) (-minsn-parse-expansion context e))
			     expansions))))
	  result)

	(begin
	  (logit 2 "Ignoring " name ".\n")
	  #f)))
)

; Read a macro-insn description
; This is the main routine for analyzing macro-insns in the .cpu file.
; CONTEXT is a <context> object for error messages.
; ARG-LIST is an associative list of field name and field value.
; -minsn-parse is invoked to create the `macro-insn' object.

(define (-minsn-read context . arg-list)
  (let (
	(name nil)
	(comment "")
	(attrs nil)
	(syntax "")
	(expansions nil)
	)

    ; Loop over each element in ARG-LIST, recording what's found.
    (let loop ((arg-list arg-list))
      (if (null? arg-list)
	  nil
	  (let ((arg (car arg-list))
		(elm-name (caar arg-list)))
	    (case elm-name
	      ((name) (set! name (cadr arg)))
	      ((comment) (set! comment (cadr arg)))
	      ((attrs) (set! attrs (cdr arg)))
	      ((syntax) (set! syntax (cadr arg)))
	      ((expansions) (set! expansions (cdr arg)))
	      (else (parse-error context "invalid macro-insn arg" arg)))
	    (loop (cdr arg-list)))))

    ; Now that we've identified the elements, build the object.
    (-minsn-parse context name comment attrs syntax expansions))
)

; Define a macro-insn object, name/value pair list version.

(define define-minsn
  (lambda arg-list
    (if (eq? APPLICATION 'SIMULATOR)
	#f ; don't waste time if simulator
	(let ((m (apply -minsn-read (cons (make-current-context "define-minsn")
					  arg-list))))
	  (if m
	      (current-minsn-add! m))
	  m)))
)

; Define a macro-insn object, all arguments specified.
; This only supports one expansion.
; Use define-minsn for the general case (??? which is of course not implemented
; yet :-).

(define (define-full-minsn name comment attrs syntax expansion)
  (if (eq? APPLICATION 'SIMULATOR)
      #f ; don't waste time if simulator
      (let ((m (-minsn-parse (make-current-context "define-full-minsn")
			     name comment
			     (cons 'ALIAS attrs)
			     syntax (list expansion))))
	(if m
	    (current-minsn-add! m))
	m))
)

; Compute the ifield list for an alias macro-insn.
; This involves making a copy of REAL-INSN's ifield list and assigning
; known quantities to operands that have fixed values in the macro-insn.

(define (-minsn-compute-iflds context minsn-iflds real-insn)
  (let* ((iflds (list-copy (insn-iflds real-insn)))
	 ; List of "free variables", i.e. operands.
	 (ifld-ops (find ifld-operand? iflds))
	 ; Names of fields in `ifld-ops'.  As elements of minsn-iflds are
	 ; parsed the associated element in ifld-names is deleted.  At the
	 ; end ifld-names must be empty.  delq! can't delete the first
	 ; element in a list, so we insert a fencepost.
	 (ifld-names (cons #f (map obj:name ifld-ops))))
    ;(logit 3 "Computing ifld list, operand field names: " ifld-names "\n")
    ; For each macro-insn ifield expression, look it up in the real insn's
    ; ifield list.  If an operand without a prespecified value, leave
    ; unchanged.  If an operand or ifield with a value, assign the value to
    ; the ifield entry.
    (for-each (lambda (f)
		(let* ((op-name (if (pair? f) (car f) f))
		       (op-obj (current-op-lookup op-name))
		       ; If `op-name' is an operand, use its ifield.
		       ; Otherwise `op-name' must be an ifield name.
		       (f-name (if op-obj
				   (obj:name (hw-index:value (op:index op-obj)))
				   op-name))
		       (ifld-pair (object-memq f-name iflds)))
		  ;(logit 3 "Processing ifield " f-name " ...\n")
		  (if (not ifld-pair)
		      (parse-error context "unknown operand" f))
		  ; Ensure `f' is an operand.
		  (if (not (memq f-name ifld-names))
		      (parse-error context "not an operand" f))
		  (if (pair? f)
		      (set-car! ifld-pair (ifld-new-value (car ifld-pair) (cadr f))))
		  (delq! f-name ifld-names)))
	      minsn-iflds)
    (if (not (equal? ifld-names '(#f)))
	(parse-error context "incomplete operand list, missing: " (cdr ifld-names)))
    iflds)
)

; Create an aliased real insn from an alias macro-insn.

(define (minsn-make-alias context minsn)
  (if (or (not (has-attr? minsn 'ALIAS))
	  ; Must emit exactly one real insn.
	  (not (eq? 'emit (caar (minsn-expansions minsn)))))
      (parse-error context "not an alias macro-insn" minsn))

  (let* ((expn (car (minsn-expansions minsn)))
	 (alias-of (current-insn-lookup (cadr expn))))

    (if (not alias-of)
	(parse-error context "unknown real insn in expansion" minsn))

    (let ((i (make <insn>
		   (context-location context)
		   (obj:name minsn)
		   (obj:comment minsn)
		   (obj-atlist minsn)
		   (minsn-syntax minsn)
		   (-minsn-compute-iflds (context-append context
							 (string-append ": " (obj:str-name minsn)))
					 (cddr expn) alias-of)
		   #f ; ifield-assertion
		   #f ; semantics
		   #f ; timing
		   )))
      ; FIXME: use same format entry as real insn,
      ; build mask and test value at run time.
      (insn-set-ifmt! i (ifmt-build i -1 #f (insn-iflds i))) ; (car (ifmt-analyze i #f))))
      ;(insn-set-ifmt! i (insn-ifmt alias-of))
      i))
)

; Called before a .cpu file is read in.

(define (minsn-init!)
  (reader-add-command! 'define-minsn
		       "\
Define a macro instruction, name/value pair list version.
"
		       nil 'arg-list define-minsn)
  (reader-add-command! 'define-full-minsn
		       "\
Define a macro instruction, all arguments specified.
"
		       nil '(name comment attrs syntax expansion)
		       define-full-minsn)

  *UNSPECIFIED*
)

; Called after the .cpu file has been read in.

(define (minsn-finish!)
  *UNSPECIFIED*
)
