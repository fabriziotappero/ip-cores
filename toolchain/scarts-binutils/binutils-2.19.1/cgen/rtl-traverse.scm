; RTL traversing support.
; Copyright (C) 2000, 2001, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; RTL expression traversal support.
; Traversal (and compilation) involves validating the source form and
; converting it to internal form.
; ??? At present the internal form is also the source form (easier debugging).

; Set to #t to debug rtx traversal.

(define -rtx-traverse-debug? #f)

; Container to record the current state of traversal.
; This is initialized before traversal, and modified (in a copy) as the
; traversal state changes.
; This doesn't record all traversal state, just the more static elements.
; There's no point in recording things like the parent expression and operand
; position as they change for every sub-traversal.
; The main raison d'etre for this class is so we can add more state without
; having to modify all the traversal handlers.
; ??? At present it's not a proper "class" as there's no real need.
;
; CONTEXT is a <context> object or #f if there is none.
; It is used for error messages.
;
; EXPR-FN is a dual-purpose beast.  The first purpose is to just process
; the current expression and return the result.  The second purpose is to
; lookup the function which will then process the expression.
; It is applied recursively to the expression and each sub-expression.
; It must be defined as
; (lambda (rtx-obj expr mode parent-expr op-pos tstate appstuff) ...).
; If the result of EXPR-FN is a lambda, it is applied to
; (cons TSTATE (cdr EXPR)).  TSTATE is prepended to the arguments.
; For syntax expressions if the result of EXPR-FN is #f, the operands are
; processed using the builtin traverser.
; So to repeat: EXPR-FN can process the expression, and if its result is a
; lambda then it also processes the expression.  The arguments to EXPR-FN
; are (rtx-obj expr mode parent-expr op-pos tstate appstuff).  The format
; of the result of EXPR-FN are (cons TSTATE (cdr EXPR)).
; The reason for the duality is that when trying to understand EXPR (e.g. when
; computing the insn format) EXPR-FN processes the expression itself, and
; when evaluating EXPR it's the result of EXPR-FN that computes the value.
;
; ENV is the current environment.  This is a stack of sequence locals.
;
; COND? is a boolean indicating if the current expression is on a conditional
; execution path.  This is for optimization purposes only and it is always ok
; to pass #t, except for the top-level caller which must pass #f (since the top
; level expression obviously isn't subject to any condition).
; It is used, for example, to speed up the simulator: there's no need to keep
; track of whether an operand has been assigned to (or potentially read from)
; if it's known it's always assigned to.
;
; SET? is a boolean indicating if the current expression is an operand being
; set.
;
; OWNER is the owner of the expression or #f if there is none.
; Typically it is an <insn> object.
;
; KNOWN is an alist of known values.  This is used by rtx-simplify.
; Each element is (name . value) where
; NAME is either an ifield or operand name (in the future it might be a
; sequence local name), and
; VALUE is either (const mode value) or (numlist mode value1 value2 ...).
;
; DEPTH is the current traversal depth.

(define (tstate-make context owner expr-fn env cond? set? known depth)
  (vector context owner expr-fn env cond? set? known depth)
)

(define (tstate-context state)             (vector-ref state 0))
(define (tstate-set-context! state newval) (vector-set! state 0 newval))
(define (tstate-owner state)               (vector-ref state 1))
(define (tstate-set-owner! state newval)   (vector-set! state 1 newval))
(define (tstate-expr-fn state)             (vector-ref state 2))
(define (tstate-set-expr-fn! state newval) (vector-set! state 2 newval))
(define (tstate-env state)                 (vector-ref state 3))
(define (tstate-set-env! state newval)     (vector-set! state 3 newval))
(define (tstate-cond? state)               (vector-ref state 4))
(define (tstate-set-cond?! state newval)   (vector-set! state 4 newval))
(define (tstate-set? state)                (vector-ref state 5))
(define (tstate-set-set?! state newval)    (vector-set! state 5 newval))
(define (tstate-known state)               (vector-ref state 6))
(define (tstate-set-known! state newval)   (vector-set! state 6 newval))
(define (tstate-depth state)               (vector-ref state 7))
(define (tstate-set-depth! state newval)   (vector-set! state 7 newval))

; Create a copy of STATE.

(define (tstate-copy state)
  ; A fast vector-copy would be nice, but this is simple and portable.
  (list->vector (vector->list state))
)

; Create a copy of STATE with a new environment ENV.

(define (tstate-new-env state env)
  (let ((result (tstate-copy state)))
    (tstate-set-env! result env)
    result)
)

; Create a copy of STATE with environment ENV pushed onto the existing
; environment list.
; There's no routine to pop the environment list as there's no current
; need for it: we make a copy of the state when we push.

(define (tstate-push-env state env)
  (let ((result (tstate-copy state)))
    (tstate-set-env! result (cons env (tstate-env result)))
    result)
)

; Create a copy of STATE with a new COND? value.

(define (tstate-new-cond? state cond?)
  (let ((result (tstate-copy state)))
    (tstate-set-cond?! result cond?)
    result)
)

; Create a copy of STATE with a new SET? value.

(define (tstate-new-set? state set?)
  (let ((result (tstate-copy state)))
    (tstate-set-set?! result set?)
    result)
)

; Lookup NAME in the known value table.  Returns the value or #f if not found.

(define (tstate-known-lookup tstate name)
  (let ((known (tstate-known tstate)))
    (assq-ref known name))
)

; Increment the recorded traversal depth of TSTATE.

(define (tstate-incr-depth! tstate)
  (tstate-set-depth! tstate (1+ (tstate-depth tstate)))
)

; Decrement the recorded traversal depth of TSTATE.

(define (tstate-decr-depth! tstate)
  (tstate-set-depth! tstate (1- (tstate-depth tstate)))
)

; Issue an error given a tstate.

(define (tstate-error tstate errmsg . expr)
  (apply context-owner-error
	 (cons (tstate-context tstate)
	       (cons (tstate-owner tstate)
		     (cons "During rtx traversal"
			   (cons errmsg expr)))))
)

; Traversal/compilation support.

; Return a boolean indicating if X is a mode.

(define (-rtx-any-mode? x)
  (->bool (mode:lookup x))
)

; Return a boolean indicating if X is a symbol or rtx.

(define (-rtx-symornum? x)
  (or (symbol? x) (number? x))
)

; Traverse a list of rtx's.

(define (-rtx-traverse-rtx-list rtx-list mode expr op-num tstate appstuff)
  (map (lambda (rtx)
	 ; ??? Shouldn't OP-NUM change for each element?
	 (-rtx-traverse rtx 'RTX mode expr op-num tstate appstuff))
       rtx-list)
)

; Cover-fn to tstate-error for signalling an error during rtx traversal
; of operand OP-NUM.
; RTL-EXPR must be an rtl expression.

(define (-rtx-traverse-error tstate errmsg rtl-expr op-num)
  (tstate-error tstate
		(string-append errmsg ", operand #" (number->string op-num))
		(rtx-strdump rtl-expr))
)

; Rtx traversers.
; These are defined as individual functions that are then built into a table
; so that we can use Hobbit's "fastcall" support.
;
; The result is either a pair of the parsed VAL and new TSTATE,
; or #f meaning there is no change (saves lots of unnecessarying cons'ing).

(define (-rtx-traverse-options val mode expr op-num tstate appstuff)
  #f
)

(define (-rtx-traverse-anymode val mode expr op-num tstate appstuff)
  (let ((val-obj (mode:lookup val)))
    (if (not val-obj)
	(-rtx-traverse-error tstate "expecting a mode"
			     expr op-num))
    #f)
)

(define (-rtx-traverse-intmode val mode expr op-num tstate appstuff)
  (let ((val-obj (mode:lookup val)))
    (if (and val-obj
	     (or (memq (mode:class val-obj) '(INT UINT))
		 (eq? val 'DFLT)))
	#f
	(-rtx-traverse-error tstate "expecting an integer mode"
			     expr op-num)))
)

(define (-rtx-traverse-floatmode val mode expr op-num tstate appstuff)
  (let ((val-obj (mode:lookup val)))
    (if (and val-obj
	     (or (memq (mode:class val-obj) '(FLOAT))
		 (eq? val 'DFLT)))
	#f
	(-rtx-traverse-error tstate "expecting a float mode"
			     expr op-num)))
)

(define (-rtx-traverse-nummode val mode expr op-num tstate appstuff)
  (let ((val-obj (mode:lookup val)))
    (if (and val-obj
	     (or (memq (mode:class val-obj) '(INT UINT FLOAT))
		 (eq? val 'DFLT)))
	#f
	(-rtx-traverse-error tstate "expecting a numeric mode"
			     expr op-num)))
)

(define (-rtx-traverse-explnummode val mode expr op-num tstate appstuff)
  (let ((val-obj (mode:lookup val)))
    (if (not val-obj)
	(-rtx-traverse-error tstate "expecting a mode"
			     expr op-num))
    (if (memq val '(DFLT VOID))
	(-rtx-traverse-error tstate "DFLT and VOID not allowed here"
			     expr op-num))
    #f)
)

(define (-rtx-traverse-nonvoidmode val mode expr op-num tstate appstuff)
  (if (eq? val 'VOID)
      (-rtx-traverse-error tstate "mode can't be VOID"
			   expr op-num))
  #f
)

(define (-rtx-traverse-voidmode val mode expr op-num tstate appstuff)
  (if (memq val '(DFLT VOID))
      #f
      (-rtx-traverse-error tstate "expecting mode VOID"
			   expr op-num))
)

(define (-rtx-traverse-dfltmode val mode expr op-num tstate appstuff)
  (if (eq? val 'DFLT)
      #f
      (-rtx-traverse-error tstate "expecting mode DFLT"
			   expr op-num))
)

(define (-rtx-traverse-rtx val mode expr op-num tstate appstuff)
; Commented out 'cus it doesn't quite work yet.
; (if (not (rtx? val))
;     (-rtx-traverse-error tstate "expecting an rtx"
;			   expr op-num))
  (cons (-rtx-traverse val 'RTX mode expr op-num tstate appstuff)
	tstate)
)

(define (-rtx-traverse-setrtx val mode expr op-num tstate appstuff)
  ; FIXME: Still need to turn it off for sub-exprs.
  ; e.g. (mem (reg ...))
; Commented out 'cus it doesn't quite work yet.
; (if (not (rtx? val))
;     (-rtx-traverse-error tstate "expecting an rtx"
;				  expr op-num))
  (cons (-rtx-traverse val 'SETRTX mode expr op-num
		       (tstate-new-set? tstate #t)
		       appstuff)
	tstate)
)

; This is the test of an `if'.

(define (-rtx-traverse-testrtx val mode expr op-num tstate appstuff)
; Commented out 'cus it doesn't quite work yet.
; (if (not (rtx? val))
;     (-rtx-traverse-error tstate "expecting an rtx"
;				  expr op-num))
  (cons (-rtx-traverse val 'RTX mode expr op-num tstate appstuff)
	(tstate-new-cond?
	 tstate
	 (not (rtx-compile-time-constant? val))))
)

(define (-rtx-traverse-condrtx val mode expr op-num tstate appstuff)
  (if (not (pair? val))
      (-rtx-traverse-error tstate "expecting an expression"
			   expr op-num))
  (if (eq? (car val) 'else)
      (begin
	(if (!= (+ op-num 2) (length expr))
	    (-rtx-traverse-error tstate
				 "`else' clause not last"
				 expr op-num))
	(cons (cons 'else
		    (-rtx-traverse-rtx-list
		     (cdr val) mode expr op-num
		     (tstate-new-cond? tstate #t)
		     appstuff))
	      (tstate-new-cond? tstate #t)))
      (cons (cons
	     ; ??? Entries after the first are conditional.
	     (-rtx-traverse (car val) 'RTX 'ANY expr op-num tstate appstuff)
	     (-rtx-traverse-rtx-list
	      (cdr val) mode expr op-num
	      (tstate-new-cond? tstate #t)
	      appstuff))
	    (tstate-new-cond? tstate #t)))
)

(define (-rtx-traverse-casertx val mode expr op-num tstate appstuff)
  (if (or (not (list? val))
	  (< (length val) 2))
      (-rtx-traverse-error tstate
			   "invalid `case' expression"
			   expr op-num))
  ; car is either 'else or list of symbols/numbers
  (if (not (or (eq? (car val) 'else)
	       (and (list? (car val))
		    (not (null? (car val)))
		    (all-true? (map -rtx-symornum?
				    (car val))))))
      (-rtx-traverse-error tstate
			   "invalid `case' choice"
			   expr op-num))
  (if (and (eq? (car val) 'else)
	   (!= (+ op-num 2) (length expr)))
      (-rtx-traverse-error tstate "`else' clause not last"
			   expr op-num))
  (cons (cons (car val)
	      (-rtx-traverse-rtx-list
	       (cdr val) mode expr op-num
	       (tstate-new-cond? tstate #t)
	       appstuff))
	(tstate-new-cond? tstate #t))
)

(define (-rtx-traverse-locals val mode expr op-num tstate appstuff)
  (if (not (list? val))
      (-rtx-traverse-error tstate "bad locals list"
			   expr op-num))
  (for-each (lambda (var)
	      (if (or (not (list? var))
		      (!= (length var) 2)
		      (not (-rtx-any-mode? (car var)))
		      (not (symbol? (cadr var))))
		  (-rtx-traverse-error tstate
				       "bad locals list"
				       expr op-num)))
	    val)
  (let ((env (rtx-env-make-locals val)))
    (cons val (tstate-push-env tstate env)))
)

(define (-rtx-traverse-iteration val mode expr op-num tstate appstuff)
  (if (not (symbol? val))
      (-rtx-traverse-error tstate "bad iteration variable name"
			   expr op-num))
  (let ((env (rtx-env-make-iteration-locals val)))
    (cons val (tstate-push-env tstate env)))
)

(define (-rtx-traverse-env val mode expr op-num tstate appstuff)
  ; VAL is an environment stack.
  (if (not (list? val))
      (-rtx-traverse-error tstate "environment not a list"
			   expr op-num))
  (cons val (tstate-new-env tstate val))
)

(define (-rtx-traverse-attrs val mode expr op-num tstate appstuff)
;  (cons val ; (atlist-source-form (atlist-parse (make-prefix-context "with-attr") val ""))
;	tstate)
  #f
)

(define (-rtx-traverse-symbol val mode expr op-num tstate appstuff)
  (if (not (symbol? val))
      (-rtx-traverse-error tstate "expecting a symbol"
			   expr op-num))
  #f
)

(define (-rtx-traverse-string val mode expr op-num tstate appstuff)
  (if (not (string? val))
      (-rtx-traverse-error tstate "expecting a string"
			   expr op-num))
  #f
)

(define (-rtx-traverse-number val mode expr op-num tstate appstuff)
  (if (not (number? val))
      (-rtx-traverse-error tstate "expecting a number"
			   expr op-num))
  #f
)

(define (-rtx-traverse-symornum val mode expr op-num tstate appstuff)
  (if (not (or (symbol? val) (number? val)))
      (-rtx-traverse-error tstate
			   "expecting a symbol or number"
			   expr op-num))
  #f
)

(define (-rtx-traverse-object val mode expr op-num tstate appstuff)
  #f
)

; Table of rtx traversers.
; This is a vector of size rtx-max-num.
; Each entry is a list of (arg-type-name . traverser) elements
; for rtx-arg-types.

(define -rtx-traverser-table #f)

; Return a hash table of standard operand traversers.
; The result of each traverser is a pair of the compiled form of `val' and
; a possibly new traversal state or #f if there is no change.

(define (-rtx-make-traverser-table)
  (let ((hash-tab (make-hash-table 31))
	(traversers
	 (list
	  ; /fastcall-make is recognized by Hobbit and handled specially.
	  ; When not using Hobbit it is a macro that returns its argument.
	  (cons 'OPTIONS (/fastcall-make -rtx-traverse-options))
	  (cons 'ANYMODE (/fastcall-make -rtx-traverse-anymode))
	  (cons 'INTMODE (/fastcall-make -rtx-traverse-intmode))
	  (cons 'FLOATMODE (/fastcall-make -rtx-traverse-floatmode))
	  (cons 'NUMMODE (/fastcall-make -rtx-traverse-nummode))
	  (cons 'EXPLNUMMODE (/fastcall-make -rtx-traverse-explnummode))
	  (cons 'NONVOIDMODE (/fastcall-make -rtx-traverse-nonvoidmode))
	  (cons 'VOIDMODE (/fastcall-make -rtx-traverse-voidmode))
	  (cons 'DFLTMODE (/fastcall-make -rtx-traverse-dfltmode))
	  (cons 'RTX (/fastcall-make -rtx-traverse-rtx))
	  (cons 'SETRTX (/fastcall-make -rtx-traverse-setrtx))
	  (cons 'TESTRTX (/fastcall-make -rtx-traverse-testrtx))
	  (cons 'CONDRTX (/fastcall-make -rtx-traverse-condrtx))
	  (cons 'CASERTX (/fastcall-make -rtx-traverse-casertx))
	  (cons 'LOCALS (/fastcall-make -rtx-traverse-locals))
	  (cons 'ITERATION (/fastcall-make -rtx-traverse-iteration))
	  (cons 'ENV (/fastcall-make -rtx-traverse-env))
	  (cons 'ATTRS (/fastcall-make -rtx-traverse-attrs))
	  (cons 'SYMBOL (/fastcall-make -rtx-traverse-symbol))
	  (cons 'STRING (/fastcall-make -rtx-traverse-string))
	  (cons 'NUMBER (/fastcall-make -rtx-traverse-number))
	  (cons 'SYMORNUM (/fastcall-make -rtx-traverse-symornum))
	  (cons 'OBJECT (/fastcall-make -rtx-traverse-object))
	  )))

    (for-each (lambda (traverser)
		(hashq-set! hash-tab (car traverser) (cdr traverser)))
	      traversers)

    hash-tab)
)

; Traverse the operands of EXPR, a canonicalized RTL expression.
; Here "canonicalized" means that -rtx-munge-mode&options has been called to
; insert an option list and mode if they were absent in the original
; expression.
; Note that this means that, yes, the options and mode are "traversed" too.

(define (-rtx-traverse-operands rtx-obj expr tstate appstuff)
  (if -rtx-traverse-debug?
      (begin
	(display (spaces (* 4 (tstate-depth tstate))))
	(display "Traversing operands of: ")
	(display (rtx-dump expr))
	(newline)
	(rtx-env-dump (tstate-env tstate))
	(force-output)
	))

  (let loop ((operands (cdr expr))
	     (op-num 0)
	     (arg-types (vector-ref -rtx-traverser-table (rtx-num rtx-obj)))
	     (arg-modes (rtx-arg-modes rtx-obj))
	     (result nil)
	     )

    (let ((varargs? (and (pair? arg-types) (symbol? (car arg-types)))))

      (if -rtx-traverse-debug?
	  (begin
	    (display (spaces (* 4 (tstate-depth tstate))))
	    (if (null? operands)
		(display "end of operands")
		(begin
		  (display "op-num ") (display op-num) (display ": ")
		  (display (rtx-dump (car operands)))
		  (display ", ")
		  (display (if varargs? (car arg-types) (caar arg-types)))
		  (display ", ")
		  (display (if varargs? arg-modes (car arg-modes)))
		  ))
	    (newline)
	    (force-output)
	    ))

      (cond ((null? operands)
	     ; Out of operands, check if we have the expected number.
	     (if (or (null? arg-types)
		     varargs?)
		 (reverse! result)
		 (tstate-error tstate "missing operands" (rtx-strdump expr))))

	    ((null? arg-types)
	     (tstate-error tstate "too many operands" (rtx-strdump expr)))

	    (else
	     (let ((type (if varargs? arg-types (car arg-types)))
		   (mode (let ((mode-spec (if varargs?
					      arg-modes
					      (car arg-modes))))
			   ; This is small enough that this is fast enough,
			   ; and the number of entries should be stable.
			   ; FIXME: for now
			   (case mode-spec
			     ((ANY) 'DFLT)
			     ((NA) #f)
			     ((OP0) (rtx-mode expr))
			     ((MATCH1)
			      ; If there is an explicit mode, use it.
			      ; Otherwise we have to look at operand 1.
			      (if (eq? (rtx-mode expr) 'DFLT)
				  'DFLT
				  (rtx-mode expr)))
			     ((MATCH2)
			      ; If there is an explicit mode, use it.
			      ; Otherwise we have to look at operand 2.
			      (if (eq? (rtx-mode expr) 'DFLT)
				  'DFLT
				  (rtx-mode expr)))
			     (else mode-spec))))
		   (val (car operands))
		   )

	       ; Look up the traverser for this kind of operand and perform it.
	       (let ((traverser (cdr type)))
		 (let ((traversed-val (fastcall6 traverser val mode expr op-num tstate appstuff)))
		   (if traversed-val
		       (begin
			 (set! val (car traversed-val))
			 (set! tstate (cdr traversed-val))))))

	       ; Done with this operand, proceed to the next.
	       (loop (cdr operands)
		     (+ op-num 1)
		     (if varargs? arg-types (cdr arg-types))
		     (if varargs? arg-modes (cdr arg-modes))
		     (cons val result)))))))
)

; Publically accessible version of -rtx-traverse-operands as EXPR-FN may
; need to call it.

(define rtx-traverse-operands -rtx-traverse-operands)

; Subroutine of -rtx-munge-mode&options.
; Return boolean indicating if X is an rtx option.

(define (-rtx-option? x)
  (and (symbol? x)
       (char=? (string-ref (symbol->string x) 0) #\:))
)

; Subroutine of -rtx-munge-mode&options.
; Return boolean indicating if X is an rtx option list.

(define (-rtx-option-list? x)
  (or (null? x)
      (and (pair? x)
	   (-rtx-option? (car x))))
)

; Subroutine of -rtx-traverse-expr to fill in the mode if absent and to
; collect the options into one list.
;
; ARGS is the list of arguments to the rtx function
; (e.g. (1 2) in (add 1 2)).
; ??? "munge" is an awkward name to use here, but I like it for now because
; it's easy to grep for.
; ??? An empty option list requires a mode to be present so that the empty
; list in `(sequence () foo bar)' is unambiguously recognized as the locals
; list.  Icky, sure, but less icky than the alternatives thus far.

(define (-rtx-munge-mode&options args)
  (let ((options nil)
	(mode-name 'DFLT))
    ; Pick off the option list if present.
    (if (and (pair? args)
	     (-rtx-option-list? (car args))
	     ; Handle `(sequence () foo bar)'.  If empty list isn't followed
	     ; by a mode, it is not an option list.
	     (or (not (null? (car args)))
		 (and (pair? (cdr args))
		      (mode-name? (cadr args)))))
	(begin
	  (set! options (car args))
	  (set! args (cdr args))))
    ; Pick off the mode if present.
    (if (and (pair? args)
	     (mode-name? (car args)))
	(begin
	  (set! mode-name (car args))
	  (set! args (cdr args))))
    ; Now put option list and mode back.
    (cons options (cons mode-name args)))
)

; Subroutine of -rtx-traverse to traverse an expression.
;
; RTX-OBJ is the <rtx-func> object of the (outer) expression being traversed.
;
; EXPR is the expression to be traversed.
;
; MODE is the name of the mode of EXPR.
;
; PARENT-EXPR is the expression EXPR is contained in.  The top-level
; caller must pass #f for it.
;
; OP-POS is the position EXPR appears in PARENT-EXPR.  The
; top-level caller must pass 0 for it.
;
; TSTATE is the current traversal state.
;
; APPSTUFF is for application specific use.
;
; For syntax expressions arguments are not pre-evaluated before calling the
; user's expression handler.  Otherwise they are.
;
; If (tstate-expr-fn TSTATE) wants to just scan the operands, rather than
; evaluating them, one thing it can do is call back to rtx-traverse-operands.
; If (tstate-expr-fn TSTATE) returns #f, traverse the operands normally and
; return (rtx's-name ([options]) mode traversed-operand1 ...),
; i.e., the canonicalized form.
; This is for semantic-compile's sake and all traversal handlers are
; required to do this if the expr-fn returns #f.

(define (-rtx-traverse-expr rtx-obj expr mode parent-expr op-pos tstate appstuff)
  (let* ((expr2 (cons (car expr)
		      (-rtx-munge-mode&options (cdr expr))))
	 (fn (fastcall7 (tstate-expr-fn tstate)
			rtx-obj expr2 mode parent-expr op-pos tstate appstuff)))
    (if fn
	(if (procedure? fn)
	    ; Don't traverse operands for syntax expressions.
	    (if (rtx-style-syntax? rtx-obj)
		(apply fn (cons tstate (cdr expr2)))
		(let ((operands (-rtx-traverse-operands rtx-obj expr2 tstate appstuff)))
		  (apply fn (cons tstate operands))))
	    fn)
	(let ((operands (-rtx-traverse-operands rtx-obj expr2 tstate appstuff)))
	  (cons (car expr2) operands))))
)

; Main entry point for expression traversal.
; (Actually rtx-traverse is, but it's just a cover function for this.)
;
; The result is the result of the lambda (tstate-expr-fn TSTATE) looks up
; in the case of expressions, or an operand object (usually <operand>)
; in the case of operands.
;
; EXPR is the expression to be traversed.
;
; EXPECTED is one of `-rtx-valid-types' and indicates the expected rtx type
; or #f if it doesn't matter.
;
; MODE is the name of the mode of EXPR.
;
; PARENT-EXPR is the expression EXPR is contained in.  The top-level
; caller must pass #f for it.
;
; OP-POS is the position EXPR appears in PARENT-EXPR.  The
; top-level caller must pass 0 for it.
;
; TSTATE is the current traversal state.
;
; APPSTUFF is for application specific use.
;
; All macros are expanded here.  User code never sees them.
; All operand shortcuts are also expand here.  User code never sees them.
; These are:
; - operands, ifields, and numbers appearing where an rtx is expected are
;   converted to use `operand', `ifield', or `const'.

(define (-rtx-traverse expr expected mode parent-expr op-pos tstate appstuff)
  (if -rtx-traverse-debug?
      (begin
	(display (spaces (* 4 (tstate-depth tstate))))
	(display "Traversing expr: ")
	(display expr)
	(newline)
	(display (spaces (* 4 (tstate-depth tstate))))
	(display "-expected:       ")
	(display expected)
	(newline)
	(display (spaces (* 4 (tstate-depth tstate))))
	(display "-mode:           ")
	(display mode)
	(newline)
	(force-output)
	))

  (if (pair? expr) ; pair? -> cheap non-null-list?

      (let ((rtx-obj (rtx-lookup (car expr))))
	(tstate-incr-depth! tstate)
	(let ((result
	       (if rtx-obj
		   (-rtx-traverse-expr rtx-obj expr mode parent-expr op-pos tstate appstuff)
		   (let ((rtx-obj (-rtx-macro-lookup (car expr))))
		     (if rtx-obj
			 (-rtx-traverse (-rtx-macro-expand expr rtx-evaluator)
					expected mode parent-expr op-pos tstate appstuff)
			 (tstate-error tstate "unknown rtx function" expr))))))
	  (tstate-decr-depth! tstate)
	  result))

      ; EXPR is not a list.
      ; See if it's an operand shortcut.
      (if (memq expected '(RTX SETRTX))

	  (cond ((symbol? expr)
		 (cond ((current-op-lookup expr)
			(-rtx-traverse
			 (rtx-make-operand expr) ; (current-op-lookup expr))
			 expected mode parent-expr op-pos tstate appstuff))
		       ((rtx-temp-lookup (tstate-env tstate) expr)
			(-rtx-traverse
			 (rtx-make-local expr) ; (rtx-temp-lookup (tstate-env tstate) expr))
			 expected mode parent-expr op-pos tstate appstuff))
		       ((current-ifld-lookup expr)
			(-rtx-traverse
			 (rtx-make-ifield expr)
			 expected mode parent-expr op-pos tstate appstuff))
		       ((enum-lookup-val expr)
			;; ??? If enums could have modes other than INT,
			;; we'd want to propagate that mode here.
			(-rtx-traverse
			 (rtx-make-enum 'INT expr)
			 expected mode parent-expr op-pos tstate appstuff))
		       (else
			(tstate-error tstate "unknown operand" expr))))
		((integer? expr)
		 (-rtx-traverse (rtx-make-const 'INT expr)
				expected mode parent-expr op-pos tstate appstuff))
		(else
		 (tstate-error tstate "unexpected operand" expr)))

	  ; Not expecting RTX or SETRTX.
	  (tstate-error tstate "unexpected operand" expr)))
)

; User visible procedures to traverse an rtl expression.
; These calls -rtx-traverse to do most of the work.
; See tstate-make for explanations of OWNER, EXPR-FN.
; CONTEXT is a <context> object or #f if there is none.
; LOCALS is a list of (mode . name) elements (the locals arg to `sequence').
; APPSTUFF is for application specific use.

(define (rtx-traverse context owner expr expr-fn appstuff)
  (-rtx-traverse expr #f 'DFLT #f 0
		 (tstate-make context owner expr-fn (rtx-env-empty-stack)
			      #f #f nil 0)
		 appstuff)
)

(define (rtx-traverse-with-locals context owner expr expr-fn locals appstuff)
  (-rtx-traverse expr #f 'DFLT #f 0
		 (tstate-make context owner expr-fn
			      (rtx-env-push (rtx-env-empty-stack)
					    (rtx-env-make-locals locals))
			      #f #f nil 0)
		 appstuff)
)

; Traverser debugger.

(define (rtx-traverse-debug expr)
  (rtx-traverse
   #f #f expr
   (lambda (rtx-obj expr mode parent-expr op-pos tstate appstuff)
     (display "-expr:    ")
     (display (string-append "rtx=" (obj:str-name rtx-obj)))
     (display " expr=")
     (display expr)
     (display " mode=")
     (display mode)
     (display " parent=")
     (display parent-expr)
     (display " op-pos=")
     (display op-pos)
     (display " cond?=")
     (display (tstate-cond? tstate))
     (newline)
     #f)
   #f
   )
)

; RTL evaluation state.
; Applications may subclass <eval-state> if they need to add things.
;
; This is initialized before evaluation, and modified (in a copy) as the
; evaluation state changes.
; This doesn't record all evaluation state, just the less dynamic elements.
; There's no point in recording things like the parent expression and operand
; position as they change for every sub-eval.
; The main raison d'etre for this class is so we can add more state without
; having to modify all the eval handlers.

(define <eval-state>
  (class-make '<eval-state> nil
	      '(
		; <context> object or #f if there is none
		(context . #f)

		; Current object rtl is being evaluated for.
		; We need to be able to access the current instruction while
		; generating semantic code.  However, the semantic description
		; doesn't specify it as an argument to anything (and we don't
		; want it to).  So we record the value here.
		(owner . #f)

		; EXPR-FN is a dual-purpose beast.  The first purpose is to
		; just process the current expression and return the result.
		; The second purpose is to lookup the function which will then
		; process the expression.  It is applied recursively to the
		; expression and each sub-expression.  It must be defined as
		; (lambda (rtx-obj expr mode estate) ...).
		; If the result of EXPR-FN is a lambda, it is applied to
		; (cons ESTATE (cdr EXPR)).  ESTATE is prepended to the
		; arguments.
		; For syntax expressions if the result of EXPR-FN is #f,
		; the operands are processed using the builtin evaluator.
		; FIXME: This special handling of syntax expressions is
		; not currently done.
		; So to repeat: EXPR-FN can process the expression, and if its
		; result is a lambda then it also processes the expression.
		; The arguments to EXPR-FN are
		; (rtx-obj expr mode estate).
		; The arguments to the result of EXPR-FN are
		; (cons ESTATE (cdr EXPR)).
		; The reason for the duality is mostly history.
		; In time things should be simplified.
		(expr-fn . #f)

		; Current environment.  This is a stack of sequence locals.
		(env . ())

		; Current evaluation depth.  This is used, for example, to
		; control indentation in generated output.
		(depth . 0)

		; Associative list of modifiers.
		; This is here to support things like `delay'.
		(modifiers . ())
		)
	      nil)
)

; Create an <eval-state> object using a list of keyword/value elements.
; ARGS is a list of #:keyword/value elements.
; The result is a list of the unrecognized elements.
; Subclasses should override this method and send-next it first, then
; see if they recognize anything in the result, returning what isn't
; recognized.

(method-make!
 <eval-state> 'vmake!
 (lambda (self args)
   (let loop ((args args) (unrecognized nil))
     (if (null? args)
	 (reverse! unrecognized) ; ??? Could invoke method to initialize here.
	 (begin
	   (case (car args)
	     ((#:context)
	      (elm-set! self 'context (cadr args)))
	     ((#:owner)
	      (elm-set! self 'owner (cadr args)))
	     ((#:expr-fn)
	      (elm-set! self 'expr-fn (cadr args)))
	     ((#:env)
	      (elm-set! self 'env (cadr args)))
	     ((#:depth)
	      (elm-set! self 'depth (cadr args)))
	     ((#:modifiers)
	      (elm-set! self 'modifiers (cadr args)))
	     (else
	      ; Build in reverse order, as we reverse it back when we're done.
	      (set! unrecognized
		    (cons (cadr args) (cons (car args) unrecognized)))))
	   (loop (cddr args) unrecognized)))))
)

; Accessors.

(define-getters <eval-state> estate
  (context owner expr-fn env depth modifiers)
)
(define-setters <eval-state> estate
  (context owner expr-fn env depth modifiers)
)

; Build an estate for use in producing a value from rtl.
; CONTEXT is a <context> object or #f if there is none.
; OWNER is the owner of the expression or #f if there is none.

(define (estate-make-for-eval context owner)
  (vmake <eval-state>
	 #:context context
	 #:owner owner
	 #:expr-fn (lambda (rtx-obj expr mode estate)
		     (rtx-evaluator rtx-obj)))
)

; Create a copy of ESTATE.

(define (estate-copy estate)
  (object-copy-top estate)
)

; Create a copy of ESTATE with a new environment ENV.

(define (estate-new-env estate env)
  (let ((result (estate-copy estate)))
    (estate-set-env! result env)
    result)
)

; Create a copy of ESTATE with environment ENV pushed onto the existing
; environment list.
; There's no routine to pop the environment list as there's no current
; need for it: we make a copy of the state when we push.

(define (estate-push-env estate env)
  (let ((result (estate-copy estate)))
    (estate-set-env! result (cons env (estate-env result)))
    result)
)

; Create a copy of ESTATE with the depth incremented by one.

(define (estate-deepen estate)
  (let ((result (estate-copy estate)))
    (estate-set-depth! result (1+ (estate-depth estate)))
    result)
)

; Create a copy of ESTATE with modifiers MODS.

(define (estate-with-modifiers estate mods)
  (let ((result (estate-copy estate)))
    (estate-set-modifiers! result (append mods (estate-modifiers result)))
    result)
)

; Convert a tstate to an estate.

(define (tstate->estate t)
  (vmake <eval-state>
	 #:context (tstate-context t)
	 #:env (tstate-env t))
)

; Issue an error given an estate.

(define (estate-error estate errmsg . expr)
  (apply context-owner-error
	 (cons (estate-context estate)
	       (cons (estate-owner estate)
		     (cons "During rtx evalution"
			   (cons errmsg expr)))))
)

; RTL expression evaluation.
;
; ??? These used eval2 at one point.  Not sure which is faster but I suspect
; eval2 is by far.  On the otherhand this has yet to be compiled.  And this way
; is more portable, more flexible, and works with guile 1.2 (which has
; problems with eval'ing self referential vectors, though that's one reason to
; use smobs).

; Set to #t to debug rtx evaluation.

(define -rtx-eval-debug? #f)

; RTX expression evaluator.
;
; EXPR is the expression to be eval'd.  It must be in compiled form.
; MODE is the mode of EXPR, a <mode> object or its name.
; ESTATE is the current evaluation state.

(define (rtx-eval-with-estate expr mode estate)
  (if -rtx-eval-debug?
      (begin
	(display "Traversing ")
	(display expr)
	(newline)
	(rtx-env-dump (estate-env estate))
	))

  (if (pair? expr) ; pair? -> cheap non-null-list?

      (let* ((rtx-obj (rtx-lookup (car expr)))
	     (fn ((estate-expr-fn estate) rtx-obj expr mode estate)))
	(if fn
	    (if (procedure? fn)
		(apply fn (cons estate (cdr expr)))
;		; Don't eval operands for syntax expressions.
;		(if (rtx-style-syntax? rtx-obj)
;		    (apply fn (cons estate (cdr expr)))
;		    (let ((operands
;			   (-rtx-eval-operands rtx-obj expr estate)))
;		      (apply fn (cons estate operands))))
		fn)
	    ; Leave expr unchanged.
	    expr))
;	    (let ((operands
;		   (-rtx-traverse-operands rtx-obj expr estate)))
;	      (cons rtx-obj operands))))

      ; EXPR is not a list
      (error "argument to rtx-eval-with-estate is not a list" expr))
)

; Evaluate rtx expression EXPR and return the computed value.
; EXPR must already be in compiled form (the result of rtx-compile).
; OWNER is the owner of the value, used for attribute computation,
; or #f if there isn't one.
; FIXME: context?

(define (rtx-value expr owner)
  (rtx-eval-with-estate expr 'DFLT (estate-make-for-eval #f owner))
)
