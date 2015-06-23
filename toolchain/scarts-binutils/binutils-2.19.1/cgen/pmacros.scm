; Preprocessor-like macro support.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; TODO:
; - Like C preprocessor macros, there is no scoping [one can argue
;   there should be].  Maybe in time (??? Hmmm... done?)
; - Support for multiple macro tables.

; Non-standard required routines:
; Provided by Guile:
;   make-hash-table, hashq-ref, hashq-set!, symbol-append,
;   source-properties
; Provided by CGEN:
;   location-property, location-property-set!,
;   source-properties-location->string,
;   single-location->string, location-top, unspecified-location,
;   reader-process-expanded!, num-args-ok?, *UNSPECIFIED*.

; The convention we use says `-' begins "local" objects.
; At some point this might also use the Guile module system.

; This uses Guile's source-properties system to track source location.
; The chain of macro invocations is tracked and stored in the result as
; object property "location-property".

; Exported routines:
;
; pmacro-init! - initialize the pmacro system
;
; define-pmacro - define a symbolic or procedural pmacro
;
;	(define-pmacro symbol ["comment"] expansion)
;	(define-pmacro (symbol [args]) ["comment"] (expansion))
;
; ARGS is a list of `symbol' or `(symbol default-value)' elements.
;
; pmacro-expand - expand all pmacros in an expression
;
;	(pmacro-expand expression loc)
;
; pmacro-trace - same as pmacro-expand, but trace macro expansion
;                Output is sent to current-error-port.
;
;	(pmacro-trace expression loc)
;
; pmacro-dump - expand all pmacros in an expression, for debugging purposes
;
;	(pmacro-dump expression)

; pmacro-debug - expand all pmacros in an expression,
;                printing various debugging messages.
;                This does not process .exec.
;
;	(pmacro-debug expression)

; Builtin pmacros:
;
; (.sym symbol1 symbol2 ...)          - symbolstr-append
; (.str string1 string2 ...)          - stringsym-append
; (.hex number [width])               - convert to hex string
; (.upcase string)
; (.downcase string)
; (.substring string start end)       - get part of a string
; (.splice a b (.unsplice c) d e ...) - splice list into another list
; (.iota count [start [increment]])   - number generator
; (.map pmacro arg1 . arg-rest)
; (.for-each pmacro arg1 . arg-rest)
; (.eval expr)                        - expand (or evaluate it) expr
; (.exec expr)                        - execute expr immediately
; (.apply pmacro-name arg)
; (.pmacro (arg-list) expansion)      - akin go lambda in Scheme
; (.pmacro? arg)
; (.let (var-list) expr1 . expr-rest) - akin to let in Scheme
; (.let* (var-list) expr1 . expr-rest) - akin to let* in Scheme
; (.if expr then [else])
; (.case expr ((case-list1) stmt) [case-expr-stmt-list] [(else stmt)])
; (.cond (expr stmt) [(cond-expr-stmt-list)] [(else stmt)])
; (.begin . stmt-list)
; (.print . exprs)                    - for debugging messages
; (.dump expr)                        - dump expr in readable format
; (.error . message)                  - print error message and exit
; (.list . exprs)
; (.ref l n)                          - extract the n'th element of list l
; (.length x)                         - length of symbol, string, or list
; (.replicate n expr)                 - return list of expr replicated n times
; (.find pred l)                      - return elements of list l matching pred
; (.equals x y)                       - deep comparison
; (.andif expr . rest)                - && in C
; (.orif expr . rest)                 - || in C
; (.not expr)                         - ! in C
; (.eq x y)
; (.ne x y)
; (.lt x y)
; (.gt x y)
; (.le x y)
; (.ge x y)
; (.add x y)
; (.sub x y)
; (.mul x y)
; (.div x y)                          - integer division
; (.rem x y)                          - integer remainder
; (.sll x n)                          - shift left logical
; (.srl x n)                          - shift right logical
; (.sra x n)                          - shift right arithmetic
; (.and x y)                          - bitwise and
; (.or x y)                           - bitwise or
; (.xor x y)                          - bitwise xor
; (.inv x)                            - bitwise invert
; (.car l)
; (.cdr l)
; (.caar l)
; (.cadr l)
; (.cdar l)
; (.cddr l)
; (.internal-test expr)               - testsuite internal use only
;
; NOTE: .cons currently absent on purpose
;
; .sym and .str convert numbers to symbols/strings as necessary (base 10).
;
; .pmacro is for constructing pmacros on-the-fly, like lambda, and is currently
; only valid as arguments to other pmacros or assigned to a local in a {.let}
; or {.let*}.
;
; NOTE: While Scheme requires tail recursion to be implemented as a loop,
; we do not.  We might some day, but not today.
;
; ??? Methinks .foo isn't a valid R5RS symbol.  May need to change 
; to something else.

; True if doing pmacro expansion via pmacro-debug.
(define -pmacro-debug? #f)
; True if doing pmacro expansion via pmacro-trace.
(define -pmacro-trace? #f)

; The pmacro table.
(define -pmacro-table #f)
(define (-pmacro-lookup name) (hashq-ref -pmacro-table name))
(define (-pmacro-set! name val) (hashq-set! -pmacro-table name val))

; A copy of syntactic pmacros is kept separately.
(define -smacro-table #f)
(define (-smacro-lookup name) (hashq-ref -smacro-table name))
(define (-smacro-set! name val) (hashq-set! -smacro-table name val))

; Marker to indicate a value is a pmacro.
; NOTE: Naming this "<pmacro>" is intentional.  It makes them look like
; objects of class <pmacro>.  However we don't use COS in part to avoid
; a dependency on COS and in part because displaying COS objects isn't well
; supported (displaying them in debugging dumps adds a lot of noise).
(define -pmacro-marker '<pmacro>)

; Utilities to create and access pmacros.
(define (-pmacro-make name arg-spec default-values
		      syntactic-form? transformer comment)
  (vector -pmacro-marker name arg-spec default-values
	  syntactic-form? transformer comment)
)
(define (-pmacro? x) (and (vector? x) (eq? (vector-ref x 0) -pmacro-marker)))
(define (-pmacro-name pmac) (vector-ref pmac 1))
(define (-pmacro-arg-spec pmac) (vector-ref pmac 2))
(define (-pmacro-default-values pmac) (vector-ref pmac 3))
(define (-pmacro-syntactic-form? pmac) (vector-ref pmac 4))
(define (-pmacro-transformer pmac) (vector-ref pmac 5))
(define (-pmacro-comment pmac) (vector-ref pmac 6))

; Cover functions to manage an "environment" in case a need or desire for
; another method arises.

(define (-pmacro-env-make prev-env names values)
  (append! (map cons names values) prev-env)
)
(define (-pmacro-env-ref env name) (assq name env))

; Error message generator.

(define (-pmacro-error msg expr)
  (error (string-append
	  (or (port-filename (current-input-port)) "<input>")
	  ":"
	  (number->string (port-line (current-input-port)))
	  ":"
	  msg
	  ":")
	 expr)
)

; Issue an error where a number was expected.

(define (-pmacro-expected-number op n)
  (-pmacro-error (string-append "invalid arg for " op ", expected number") n)
)

; Verify N is a number.

(define (-pmacro-verify-number op n)
  (if (not (number? n))
      (-pmacro-expected-number op n))
)

; Issue an error where an integer was expected.

(define (-pmacro-expected-integer op n)
  (-pmacro-error (string-append "invalid arg for " op ", expected integer") n)
)

; Verify N is an integer.

(define (-pmacro-verify-integer op n)
  (if (not (integer? n))
      (-pmacro-expected-integer op n))
)

; Issue an error where a non-negative integer was expected.

(define (-pmacro-expected-non-negative-integer op n)
  (-pmacro-error (string-append "invalid arg for " op ", expected non-negative integer") n)
)

; Verify N is a non-negative integer.

(define (-pmacro-verify-non-negative-integer op n)
  (if (or (not (integer? n))
	  (< n 0))
      (-pmacro-expected-non-negative-integer op n))
)

; Expand a list of expressions, in order.
; The result is the value of the last one.

(define (-pmacro-expand-expr-list exprs env loc)
  (let ((result nil))
    (for-each (lambda (expr)
		(set! result (-pmacro-expand expr env loc)))
	      exprs)
    result)
)

; Process list of keyword/value specified arguments.

(define (-pmacro-process-keyworded-args arg-spec default-values args)
  ; Build a list of default values, then override ones specified in ARGS,
  (let ((result-alist (alist-copy default-values)))
    (let loop ((args args))
      (cond ((null? args)
	     #f) ; done
	    ((and (pair? args) (keyword? (car args)))
	     (let ((elm (assq (car args) result-alist)))
	       (if (not elm)
		   (-pmacro-error "not an argument name" (car args)))
	       (if (null? (cdr args))
		   (-pmacro-error "missing argument to #:keyword" (car args)))
	       (set-cdr! elm (cadr args))
	       (loop (cddr args))))
	    (else
	     (-pmacro-error "bad keyword/value argument list" args))))

    ; Ensure each element has a value.
    (let loop ((to-scan result-alist))
      (if (null? to-scan)
	  #f ; done
	  (begin
	    (if (not (cdar to-scan))
		(-pmacro-error "argument value not specified" (caar to-scan)))
	    (loop (cdr to-scan)))))

    ; If varargs pmacro, adjust result.
    (if (list? arg-spec)
	(map cdr result-alist) ; not varargs
	(let ((nr-args (length (result-alist))))
	  (append! (map cdr (list-head result-alist (- nr-args 1)))
		   (cdr (list-tail result-alist (- nr-args 1)))))))
)

; Process a pmacro argument list.
; ARGS is either a fully specified position dependent argument list,
; or is a list of keyword/value pairs with missing values coming from
; DEFAULT-VALUES.

(define (-pmacro-process-args-1 arg-spec default-values args)
  (if (and (pair? args) (keyword? (car args)))
      (-pmacro-process-keyworded-args arg-spec default-values args)
      args)
)

; Subroutine of -pmacro-apply/-smacro-apply to simplify them.
; Process the arguments, verify the correct number is present.

(define (-pmacro-process-args macro args)
  (let ((arg-spec (-pmacro-arg-spec macro))
	(default-values (-pmacro-default-values macro)))
    (let ((processed-args (-pmacro-process-args-1 arg-spec default-values args)))
      (if (not (num-args-ok? (length processed-args) arg-spec))
	  (-pmacro-error (string-append
			  "wrong number of arguments to pmacro "
			  (with-output-to-string
			    (lambda ()
			      (write (cons (-pmacro-name macro)
					   (-pmacro-arg-spec macro))))))
			 args))
      processed-args))
)

; Invoke a pmacro.

(define (-pmacro-apply macro args)
  (apply (-pmacro-transformer macro)
	 (-pmacro-process-args macro args))
)

; Invoke a syntactic-form pmacro.
; ENV, LOC are handed down from -pmacro-expand.

(define (-smacro-apply macro args env loc)
  (apply (-pmacro-transformer macro)
	 (cons loc (cons env (-pmacro-process-args macro args))))
)

;; Expand expression EXP using ENV, an alist of variable assignments.
;; LOC is the location stack thus far.

(define (-pmacro-expand exp env loc)

  (define cep (current-error-port))

  ;; If the symbol is in `env', return its value.
  ;; Otherwise see if symbol is a globally defined pmacro.
  ;; Otherwise return the symbol unchanged.

  (define (scan-symbol sym)
    (let ((val (-pmacro-env-ref env sym)))
      (if val
	  (cdr val) ;; cdr is value of (name . value) pair
	  (let ((val (-pmacro-lookup sym)))
	    (if val
		;; Symbol is a pmacro.
		;; If this is a procedural pmacro, let caller perform expansion.
		;; Otherwise, return the pmacro's value.
		(if (procedure? (-pmacro-transformer val))
		    val
		    (-pmacro-transformer val))
		;; Return symbol unchanged.
		sym)))))

  ;; See if (car exp) is a pmacro.
  ;; Return pmacro or #f.

  (define (check-pmacro exp)
    (if -pmacro-debug?
	(begin
	  (display "Checking for pmacro: " cep)
	  (write exp cep)
	  (newline cep)))
    (and (-pmacro? (car exp)) (car exp)))

  ;; Subroutine of scan-list to simplify it.
  ;; Macro expand EXP which is known to be a non-null list.
  ;; LOC is the location stack thus far.

  (define (scan-list1 exp loc)
    ;; Check for syntactic forms.
    ;; They are handled differently in that we leave it to the transformer
    ;; routine to evaluate the arguments.
    ;; Note that we also don't support passing syntactic form functions
    ;; as arguments: We look up (car exp) here, not its expansion.
    (let ((sform (-smacro-lookup (car exp))))
      (if sform
	  (begin
	    ;; ??? Is it useful to trace these?
	    (-smacro-apply sform (cdr exp) env loc))
	  ;; Not a syntactic form.
	  ;; See if we have a pmacro.  Do this before evaluating all the
	  ;; arguments (even though we will eventually evaluate all the
	  ;; arguments before invoking the pmacro) so that tracing is more
	  ;; legible (we print the expression we're about to evaluate *before*
	  ;; we evaluate its arguments).
	  (let ((scanned-car (scan (car exp) loc)))
	    (if (-pmacro? scanned-car)
		(begin
		  ;; Trace expansion here, we know we have a pmacro.
		  (if -pmacro-trace?
		      (let ((src-props (source-properties exp))
			    (indent (spaces (* 2 (length (location-list loc))))))
			;; We use `write' to display `exp' to see strings quoted.
			(display indent cep)
			(display "Expanding: " cep)
			(write exp cep)
			(newline cep)
			(display indent cep)
			(display "      env: " cep)
			(write env cep)
			(newline cep)
			(if (not (null? src-props))
			    (begin
			      (display indent cep)
			      (display " location: " cep)
			      (display (source-properties-location->string src-props) cep)
			      (newline cep)))))
		  ;; Evaluate all the arguments before invoking the pmacro.
		  (let* ((scanned-args (map (lambda (e) (scan e loc))
					    (cdr exp)))
			 (result (if (procedure? (-pmacro-transformer scanned-car))
				     (-pmacro-apply scanned-car scanned-args)
				     (cons (-pmacro-transformer scanned-car) scanned-args))))
		    (if -pmacro-trace?
			(let ((indent (spaces (* 2 (length (location-list loc))))))
			  (display indent cep)
			  (display "   result: " cep)
			  (write result cep)
			  (newline cep)))
		    result))
		;; Not a pmacro.
		(cons scanned-car (map (lambda (e) (scan e loc))
				       (cdr exp))))))))

  ;; Macro expand EXP which is known to be a non-null list.
  ;; LOC is the location stack thus far.
  ;;
  ;; This uses scan-list1 to do the real work, this handles location tracking.

  (define (scan-list exp loc)
    (let ((src-props (source-properties exp))
	  (new-loc loc))
      (if (not (null? src-props))
	  (let ((file (assq-ref src-props 'filename))
		(line (assq-ref src-props 'line))
		(column (assq-ref src-props 'column)))
	    (set! new-loc (location-push-single loc file line column #f))))
      (let ((result (scan-list1 exp new-loc)))
	(if (pair? result) ;; pair? -> cheap non-null-list?
	    (begin
	      ;; Copy source location to new expression.
	      (if (null? (source-properties result))
		  (set-source-properties! result src-props))
	      (let ((loc-prop (location-property result)))
		(if loc-prop
		    (location-property-set! result (location-push new-loc loc-prop))
		    (location-property-set! result new-loc)))))
	result)))

  ;; Scan EXP, an arbitrary value.
  ;; LOC is the location stack thus far.

  (define (scan exp loc)
    (let ((result (cond ((symbol? exp)
			 (scan-symbol exp))
			((pair? exp) ;; pair? -> cheap non-null-list?
			 (scan-list exp loc))
			;; Not a symbol or expression, return unchanged.
			(else
			 exp))))
      ;; Re-examining `result' to see if it is another pmacro invocation
      ;; allows doing things like ((.sym a b c) arg1 arg2)
      ;; where `abc' is a pmacro.  Scheme doesn't work this way, but then
      ;; this is CGEN.
      (if (symbol? result) (scan-symbol result) result)))

  (scan exp loc)
)

; Return the argument spec from ARGS.
; ARGS is a [possibly improper] list of `symbol' or `(symbol default-value)'
; elements.  For varargs pmacros, ARGS must be an improper list
; (e.g. (a b . c)) with the last element being a symbol.

(define (-pmacro-get-arg-spec args)
  (let ((parse-arg
	 (lambda (arg)
	   (cond ((symbol? arg)
		  arg)
		 ((and (pair? arg) (symbol? (car arg)))
		  (car arg))
		 (else
		  (-pmacro-error "argument not `symbol' or `(symbol . default-value)'"
				 arg))))))
    (if (list? args)
	(map parse-arg args)
	(letrec ((parse-improper-list
		  (lambda (args)
		    (cond ((symbol? args)
			   args)
			  ((pair? args)
			   (cons (parse-arg (car args))
				 (parse-improper-list (cdr args))))
			  (else
			   (-pmacro-error "argument not `symbol' or `(symbol . default-value)'"
					  args))))))
	  (parse-improper-list args))))
)

; Return the default values specified in ARGS.
; The result is an alist of (#:arg-name . default-value) elements.
; ARGS is a [possibly improper] list of `symbol' or `(symbol . default-value)'
; elements.  For varargs pmacros, ARGS must be an improper list
; (e.g. (a b . c)) with the last element being a symbol.
; Unspecified default values are recorded as #f.

(define (-pmacro-get-default-values args)
  (let ((parse-arg
	 (lambda (arg)
	   (cond ((symbol? arg)
		  (cons (symbol->keyword arg) #f))
		 ((and (pair? arg) (symbol? (car arg)))
		  (cons (symbol->keyword (car arg)) (cdr arg)))
		 (else
		  (-pmacro-error "argument not `symbol' or `(symbol . default-value)'"
				 arg))))))
    (if (list? args)
	(map parse-arg args)
	(letrec ((parse-improper-list
		  (lambda (args)
		    (cond ((symbol? args)
			   (cons (parse-arg args) nil))
			  ((pair? args)
			   (cons (parse-arg (car args))
				 (parse-improper-list (cdr args))))
			  (else
			   (-pmacro-error "argument not `symbol' or `(symbol . default-value)'"
					  args))))))
	  (parse-improper-list args))))
)

; Build a procedure that performs a pmacro expansion.

; Earlier version, doesn't work with LOC as a <location> object,
; COS objects don't pass through eval1.
;(define (-pmacro-build-lambda prev-env params expansion)
;  (eval1 `(lambda ,params
;	    (-pmacro-expand ',expansion
;			    (-pmacro-env-make ',prev-env
;					      ',params (list ,@params))))
;)

(define (-pmacro-build-lambda loc prev-env params expansion)
  (lambda args
    (-pmacro-expand expansion
		    (-pmacro-env-make prev-env params args)
		    loc))
)

; While using `define-macro' seems preferable, boot-9.scm uses it and
; I'd rather not risk a collision.  I could of course make the association
; during parsing, maybe later.
; On the other hand, calling them pmacros removes all ambiguity.
; In the end the ambiguity removal is the deciding win.
;
; The syntax is one of:
; (define-pmacro symbol expansion)
; (define-pmacro symbol ["comment"] expansion)
; (define-pmacro (name args ...) expansion)
; (define-pmacro (name args ...) "documentation" expansion)
;
; If `expansion' is the name of a pmacro, its value is used (rather than its
; name).
; ??? The goal here is to follow Scheme's define/lambda, but not all variants
; are supported yet.  There's also the difference that we treat undefined
; symbols as being themselves (i.e. "self quoting" so-to-speak).
;
; ??? We may want user-definable "syntactic" pmacros some day.  Later.

(define (define-pmacro header arg1 . arg-rest)
  (if (and (not (symbol? header))
	   (not (list? header)))
      (-pmacro-error "invalid pmacro header" header))
  (let ((name (if (symbol? header) header (car header)))
	(arg-spec (if (symbol? header) #f (-pmacro-get-arg-spec (cdr header))))
	(default-values (if (symbol? header) #f (-pmacro-get-default-values (cdr header))))
	(comment (if (null? arg-rest) "" arg1))
	(expansion (if (null? arg-rest) arg1 (car arg-rest))))
    ;;(if (> (length arg-rest) 1)
	;;(-pmacro-error "extraneous arguments to define-pmacro" (cdr arg-rest)))
    ;;(if (not (string? comment))
	;;(-pmacro-error "invalid pmacro comment, expected string" comment))
    (if (symbol? header)
	(if (symbol? expansion)
	    (let ((maybe-pmacro (-pmacro-lookup expansion)))
	      (if maybe-pmacro
		  (-pmacro-set! name
				(-pmacro-make name
					      (-pmacro-arg-spec maybe-pmacro)
					      (-pmacro-default-values maybe-pmacro)
					      #f ; syntactic-form?
					      (-pmacro-transformer maybe-pmacro)
					      comment))
		  (-pmacro-set! name (-pmacro-make name #f #f #f expansion comment))))
	    (-pmacro-set! name (-pmacro-make name #f #f #f expansion comment)))
	(-pmacro-set! name
		      (-pmacro-make name arg-spec default-values #f
				    (-pmacro-build-lambda (current-reader-location)
							  nil
							  arg-spec
							  expansion)
				    comment))))
    *UNSPECIFIED*
)

; Expand any pmacros in EXPR.
; LOC is the <location> of EXPR.

(define (pmacro-expand expr loc)
  (-pmacro-expand expr '() loc)
)

; Debugging routine to trace pmacro expansion.

(define (pmacro-trace expr loc)
  ; FIXME: Need unwind protection.
  (let ((old-trace -pmacro-trace?)
	(src-props (and (pair? expr) (source-properties expr)))
	(cep (current-error-port)))
    (set! -pmacro-trace? #t)
    ;; We use `write' to display `expr' to see strings quoted.
    (display "Pmacro expanding: " cep) (write expr cep) (newline cep)
    ;;(display "Top level env: " cep) (display nil cep) (newline cep)
    (display "Pmacro location: " cep)
    (if (and src-props (not (null? src-props)))
	(display (source-properties-location->string src-props) cep)
	(display (single-location->string (location-top loc)) cep))
    (newline cep)
    (let ((result (-pmacro-expand expr '() loc)))
      (display "Pmacro result: " cep) (write result cep) (newline cep)
      (set! -pmacro-trace? old-trace)
      result))
)

; Debugging utility to expand a pmacro, with no initial source location.

(define (pmacro-dump expr)
  (-pmacro-expand expr '() (unspecified-location))
)

; Expand any pmacros in EXPR, printing various debugging messages.
; This does not process .exec.

(define (pmacro-debug expr)
  ; FIXME: Need unwind protection.
  (let ((old-debug -pmacro-debug?))
    (set! -pmacro-debug? #t)
    (let ((result (pmacro-trace expr (unspecified-location))))
      (set! -pmacro-debug? old-debug)
      result))
)

; Builtin pmacros.

; (.sym symbol1 symbol2 ...) - symbol-append, auto-convert numbers

(define -pmacro-builtin-sym
  (lambda args
    (string->symbol
     (apply string-append
	    (map (lambda (elm)
		   (cond ((number? elm) (number->string elm))
			 ((symbol? elm) (symbol->string elm))
			 ((string? elm) elm)
			 (else
			  (-pmacro-error "invalid argument to .str" elm))))
		 args))))
)

; (.str string1 string2 ...) - string-append, auto-convert numbers

(define -pmacro-builtin-str
  (lambda args
    (apply string-append
	   (map (lambda (elm)
		  (cond ((number? elm) (number->string elm))
			((symbol? elm) (symbol->string elm))
			((string? elm) elm)
			(else
			 (-pmacro-error "invalid argument to .str" elm))))
		args)))
)

; (.hex number [width]) - convert number to hex string
; WIDTH, if present, is the number of characters in the result, beginning
; from the least significant digit.

(define (-pmacro-builtin-hex num . width)
  (if (> (length width) 1)
      (-pmacro-error "wrong number of arguments to .hex"
		     (cons '.hex (cons num width))))
  (let ((str (number->string num 16)))
    (if (null? width)
	str
	(let ((len (string-length str)))
	  (substring (string-append (make-string (car width) #\0) str)
		     len (+ len (car width))))))
)

; (.upcase string) - convert a string or symbol to uppercase

(define (-pmacro-builtin-upcase str)
  (cond
   ((string? str) (string-upcase str))
   ((symbol? str) (string->symbol (string-upcase (symbol->string str))))
   (else (-pmacro-error "invalid argument to .upcase" str)))
)

; (.downcase string) - convert a string or symbol to lowercase

(define (-pmacro-builtin-downcase str)
  (cond
   ((string? str) (string-downcase str))
   ((symbol? str) (string->symbol (string-downcase (symbol->string str))))
   (else (-pmacro-error "invalid argument to .downcase" str)))
)

; (.substring string start end) - get part of a string
; `end' can be the symbol `end'.

(define (-pmacro-builtin-substring str start end)
  (if (not (integer? start)) ;; FIXME: non-negative-integer
      (-pmacro-error "start not an integer" start))
  (if (and (not (integer? end))
	   (not (eq? end 'end)))
      (-pmacro-error "end not an integer nor symbol `end'" end))
  (cond ((string? str)
	 (if (eq? end 'end)
	     (substring str start)
	     (substring str start end)))
	((symbol? str)
	 (if (eq? end 'end)
	     (string->symbol (substring (symbol->string str) start))
	     (string->symbol (substring (symbol->string str) start end))))
	(else
	 (-pmacro-error "invalid argument to .substring" str)))
)

; .splice - splicing support
; Splice lists into the outer list.
;
; E.g. (define-pmacro '(splice-test a b c) '(.splice a (.unsplice b) c))
; (pmacro-expand '(splice-test (1 (2) 3))) --> (1 2 3)
;
; Similar to `(1 ,@'(2) 3) in Scheme, though the terminology is slightly
; different (??? may need to revisit).  In Scheme there's quasi-quote,
; unquote, unquote-splicing.  Here we have splice, unsplice; with the proviso
; that pmacros don't have the concept of "quoting", thus all subexpressions
; are macro-expanded first, before performing any unsplicing.
; [??? Some may want a quoting facility, but I'd like to defer adding it as
; long as possible (and ideally never add it).]
;
; NOTE: The implementation relies on .unsplice being undefined so that
; (.unsplice (42)) is expanded unchanged.

(define -pmacro-builtin-splice
  (lambda arg-list
    ; ??? Not the most efficient implementation.
    (let loop ((arg-list arg-list) (result '()))
      (cond ((null? arg-list) result)
	    ((and (pair? (car arg-list)) (eq? '.unsplice (caar arg-list)))
	     (if (= (length (car arg-list)) 2)
		 (if (list? (cadar arg-list))
		     (loop (cdr arg-list) (append result (cadar arg-list)))
		     (-pmacro-error "argument to .unsplice must be a list"
				    (car arg-list)))
		 (-pmacro-error "wrong number of arguments to .unsplice"
				(car arg-list))))
	    (else
	     (loop (cdr arg-list) (append result (list (car arg-list))))))))
)

; .iota
; Usage:
; (.iota count)            ; start=0, incr=1
; (.iota count start)      ; incr=1
; (.iota count start incr)

(define (-pmacro-builtin-iota count . start-incr)
  (if (> (length start-incr) 2)
      (-pmacro-error "wrong number of arguments to .iota"
		     (cons '.iota (cons count start-incr))))
  (if (< count 0)
      (-pmacro-error "count must be non-negative"
		     (cons '.iota (cons count start-incr))))
  (let ((start (if (pair? start-incr) (car start-incr) 0))
	(incr (if (= (length start-incr) 2) (cadr start-incr) 1)))
    (let loop ((i start) (count count) (result '()))
      (if (= count 0)
	  (reverse! result)
	  (loop (+ i incr) (- count 1) (cons i result)))))
)

; (.map pmacro arg1 . arg-rest)

(define (-pmacro-builtin-map pmacro arg1 . arg-rest)
  (if (not (-pmacro? pmacro))
      (-pmacro-error "not a pmacro" pmacro))
  (let ((transformer (-pmacro-transformer pmacro)))
    (if (not (procedure? transformer))
	(-pmacro-error "not a procedural pmacro" pmacro))
    (apply map (cons transformer (cons arg1 arg-rest))))
)

; (.for-each pmacro arg1 . arg-rest)

(define (-pmacro-builtin-for-each pmacro arg1 . arg-rest)
  (if (not (-pmacro? pmacro))
      (-pmacro-error "not a pmacro" pmacro))
  (let ((transformer (-pmacro-transformer pmacro)))
    (if (not (procedure? transformer))
	(-pmacro-error "not a procedural pmacro" pmacro))
    (apply for-each (cons transformer (cons arg1 arg-rest)))
    nil) ; need to return something the reader will accept and ignore
)

; (.eval expr)
; NOTE: This is implemented as a syntactic form in order to get ENV and LOC.
; That's an implementation detail, and this is not really a syntactic form.
;
; ??? I debated whether to call this .expand, .eval has been a source of
; confusion/headaches.

(define (-pmacro-builtin-eval loc env expr)
  ;; -pmacro-expand is invoked twice because we're implemented as a syntactic
  ;; form:  We *want* to be passed an evaluated expression, and then we
  ;; re-evaluate it.  But syntactic forms pass parameters unevaluated, so we
  ;; have to do the first one ourselves.
  (-pmacro-expand (-pmacro-expand expr env loc) env loc)
)

; (.exec expr)

(define (-pmacro-builtin-exec expr)
  ;; If we're expanding pmacros for debugging purposes, don't execute,
  ;; just return unchanged.
  (if -pmacro-debug?
      (list '.exec expr)
      (begin
	(reader-process-expanded! expr)
	nil)) ;; need to return something the reader will accept and ignore
)

; (.apply pmacro-name arg)

(define (-pmacro-builtin-apply pmacro arg-list)
  (if (not (-pmacro? pmacro))
      (-pmacro-error "not a pmacro" pmacro))
  (let ((transformer (-pmacro-transformer pmacro)))
    (if (not (procedure? transformer))
	(-pmacro-error "not a procedural pmacro" pmacro))
    (apply transformer arg-list))
)

; (.pmacro (arg-list) expansion)
; NOTE: syntactic form

(define (-pmacro-builtin-pmacro loc env params expansion)
  ;; ??? Prohibiting improper lists seems unnecessarily restrictive here.
  ;; e.g. (define (foo bar . baz) ...)
  (if (not (list? params))
      (-pmacro-error ".pmacro parameter-spec is not a list" params))
  (-pmacro-make '.anonymous params #f #f
		(-pmacro-build-lambda loc env params expansion) "")
)

; (.pmacro? arg)

(define (-pmacro-builtin-pmacro? arg)
  (-pmacro? arg)
)

; (.let (var-list) expr1 . expr-rest)
; NOTE: syntactic form

(define (-pmacro-builtin-let loc env locals expr1 . expr-rest)
  (if (not (list? locals))
      (-pmacro-error "locals is not a list" locals))
  (if (not (all-true? (map (lambda (l)
			     (and (list? l)
				  (= (length l) 2)
				  (symbol? (car l))))
			   locals)))
      (-pmacro-error "syntax error in locals list" locals))
  (let* ((evald-locals (map (lambda (l)
			      (cons (car l) (-pmacro-expand (cadr l) env loc)))
			    locals))
	 (new-env (append! evald-locals env)))
    (-pmacro-expand-expr-list (cons expr1 expr-rest) new-env loc))
)

; (.let* (var-list) expr1 . expr-rest)
; NOTE: syntactic form

(define (-pmacro-builtin-let* loc env locals expr1 . expr-rest)
  (if (not (list? locals))
      (-pmacro-error "locals is not a list" locals))
  (if (not (all-true? (map (lambda (l)
			     (and (list? l)
				  (= (length l) 2)
				  (symbol? (car l))))
			   locals)))
      (-pmacro-error "syntax error in locals list" locals))
  (let loop ((locals locals) (new-env env))
    (if (null? locals)
	(-pmacro-expand-expr-list (cons expr1 expr-rest) new-env loc)
	(loop (cdr locals) (acons (caar locals)
				  (-pmacro-expand (cadar locals) new-env loc)
				  new-env))))
)

; (.if expr then [else])
; NOTE: syntactic form

(define (-pmacro-builtin-if loc env expr then-clause . else-clause)
  (case (length else-clause)
    ((0) (if (-pmacro-expand expr env loc)
	     (-pmacro-expand then-clause env loc)
	     nil))
    ((1) (if (-pmacro-expand expr env loc)
	     (-pmacro-expand then-clause env loc)
	     (-pmacro-expand (car else-clause) env loc)))
    (else (-pmacro-error "too many elements in else-clause, expecting 0 or 1" else-clause)))
)

; (.case expr ((case-list1) stmt) [case-expr-stmt-list] [(else stmt)])
; NOTE: syntactic form
; NOTE: this uses "member" for case comparison (Scheme uses memq I think)

(define (-pmacro-builtin-case loc env expr case1 . rest)
  (let ((evald-expr (-pmacro-expand expr env loc)))
    (let loop ((cases (cons case1 rest)))
      (if (null? cases)
	  nil
	  (begin
	    (if (not (list? (car cases)))
		(-pmacro-error "case statement not a list" (car cases)))
	    (if (= (length (car cases)) 1)
		(-pmacro-error "case statement has case but no expr" (car cases)))
	    (if (and (not (eq? (caar cases) 'else))
		     (not (list? (caar cases))))
		(-pmacro-error "case must be \"else\" or list of choices" (caar cases)))
	    (cond ((eq? (caar cases) 'else)
		   (-pmacro-expand-expr-list (cdar cases) env loc))
		  ((member evald-expr (caar cases))
		   (-pmacro-expand-expr-list (cdar cases) env loc))
		  (else
		   (loop (cdr cases))))))))
)

; (.cond (expr stmt) [(cond-expr-stmt-list)] [(else stmt)])
; NOTE: syntactic form

(define (-pmacro-builtin-cond loc env expr1 . rest)
  (let loop ((exprs (cons expr1 rest)))
    (cond ((null? exprs)
	   nil)
	  ((eq? (car exprs) 'else)
	   (-pmacro-expand-expr-list (cdar exprs) env loc))
	  (else
	   (let ((evald-expr (-pmacro-expand (caar exprs) env loc)))
	     (if evald-expr
		 (-pmacro-expand-expr-list (cdar exprs) env loc)
		 (loop (cdr exprs)))))))
)

; (.begin . stmt-list)
; NOTE: syntactic form

(define (-pmacro-builtin-begin loc env . rest)
  (-pmacro-expand-expr-list rest env loc)
)

; (.print . expr)
; Strings have quotes removed.

(define (-pmacro-builtin-print . exprs)
  (apply message exprs)
  nil ; need to return something the reader will accept and ignore
)

; (.dump expr)
; Strings do not have quotes removed.

(define (-pmacro-builtin-dump expr)
  (write expr (current-error-port))
  nil ; need to return something the reader will accept and ignore
)

; (.error . expr)

(define (-pmacro-builtin-error . exprs)
  (apply error exprs)
)

; (.list expr1 ...)

(define (-pmacro-builtin-list . exprs)
  exprs
)

; (.ref expr index)

(define (-pmacro-builtin-ref l n)
  (if (not (list? l))
      (-pmacro-error "invalid arg for .ref, expected list" l))
  (if (not (integer? n)) ;; FIXME: call non-negative-integer?
      (-pmacro-error "invalid arg for .ref, expected non-negative integer" n))
  (list-ref l n)
)

; (.length x)

(define (-pmacro-builtin-length x)
  (cond ((symbol? x) (string-length (symbol->string x)))
	((string? x) (string-length x))
	((list? x) (length x))
	(else
	 (-pmacro-error "invalid arg for .length, expected symbol, string, or list" x)))
)

; (.replicate n expr)

(define (-pmacro-builtin-replicate n expr)
  (if (not (integer? n)) ;; FIXME: call non-negative-integer?
      (-pmacro-error "invalid arg for .replicate, expected non-negative integer" n))
  (make-list n expr)
)

; (.find pred l)

(define (-pmacro-builtin-find pred l)
  (if (not (-pmacro? pred))
      (-pmacro-error "not a pmacro" pred))
  (if (not (list? l))
      (-pmacro-error "not a list" l))
  (let ((transformer (-pmacro-transformer pred)))
    (if (not (procedure? transformer))
	(-pmacro-error "not a procedural macro" pred))
    (find transformer l))
)

; (.equals x y)

(define (-pmacro-builtin-equals x y)
  (equal? x y)
)

; (.andif . rest)
; NOTE: syntactic form
; Elements of EXPRS are evaluated one at a time.
; Unprocessed elements are not evaluated.

(define (-pmacro-builtin-andif loc env . exprs)
  (if (null? exprs)
      #t
      (let loop ((exprs exprs))
	(let ((evald-expr (-pmacro-expand (car exprs) env loc)))
	  (cond ((null? (cdr exprs)) evald-expr)
		(evald-expr (loop (cdr exprs)))
		(else #f)))))
)

; (.orif . rest)
; NOTE: syntactic form
; Elements of EXPRS are evaluated one at a time.
; Unprocessed elements are not evaluated.

(define (-pmacro-builtin-orif loc env . exprs)
  (let loop ((exprs exprs))
    (if (null? exprs)
	#f
	(let ((evald-expr (-pmacro-expand (car exprs) env loc)))
	  (if evald-expr
	      evald-expr
	      (loop (cdr exprs))))))
)

; (.not expr)

(define (-pmacro-builtin-not x)
  (not x)
)

; Verify x,y are compatible for eq/ne comparisons.

(define (-pmacro-compatible-for-equality x y)
  (or (and (symbol? x) (symbol? y))
      (and (string? x) (string? y))
      (and (number? x) (number? y)))
)

; (.eq expr)

(define (-pmacro-builtin-eq x y)
  (cond ((symbol? x)
	 (if (symbol? y)
	     (eq? x y)
	     (-pmacro-error "incompatible args for .eq, expected symbol" y)))
	((string? x)
	 (if (string? y)
	     (string=? x y)
	     (-pmacro-error "incompatible args for .eq, expected string" y)))
	((number? x)
	 (if (number? y)
	     (= x y)
	     (-pmacro-error "incompatible args for .eq, expected number" y)))
	(else
	 (-pmacro-error "unsupported args for .eq" (list x y))))
)

; (.ne expr)

(define (-pmacro-builtin-ne x y)
  (cond ((symbol? x)
	 (if (symbol? y)
	     (not (eq? x y))
	     (-pmacro-error "incompatible args for .ne, expected symbol" y)))
	((string? x)
	 (if (string? y)
	     (not (string=? x y))
	     (-pmacro-error "incompatible args for .ne, expected string" y)))
	((number? x)
	 (if (number? y)
	     (not (= x y))
	     (-pmacro-error "incompatible args for .ne, expected number" y)))
	(else
	 (-pmacro-error "unsupported args for .ne" (list x y))))
)

; (.lt expr)

(define (-pmacro-builtin-lt x y)
  (-pmacro-verify-number ".lt" x)
  (-pmacro-verify-number ".lt" y)
  (< x y)
)

; (.gt expr)

(define (-pmacro-builtin-gt x y)
  (-pmacro-verify-number ".gt" x)
  (-pmacro-verify-number ".gt" y)
  (> x y)
)

; (.le expr)

(define (-pmacro-builtin-le x y)
  (-pmacro-verify-number ".le" x)
  (-pmacro-verify-number ".le" y)
  (<= x y)
)

; (.ge expr)

(define (-pmacro-builtin-ge x y)
  (-pmacro-verify-number ".ge" x)
  (-pmacro-verify-number ".ge" y)
  (>= x y)
)

; (.add x y)

(define (-pmacro-builtin-add x y)
  (-pmacro-verify-number ".add" x)
  (-pmacro-verify-number ".add" y)
  (+ x y)
)

; (.sub x y)

(define (-pmacro-builtin-sub x y)
  (-pmacro-verify-number ".sub" x)
  (-pmacro-verify-number ".sub" y)
  (- x y)
)

; (.mul x y)

(define (-pmacro-builtin-mul x y)
  (-pmacro-verify-number ".mul" x)
  (-pmacro-verify-number ".mul" y)
  (* x y)
)

; (.div x y) - integer division

(define (-pmacro-builtin-div x y)
  (-pmacro-verify-integer ".div" x)
  (-pmacro-verify-integer ".div" y)
  (quotient x y)
)

; (.rem x y) - integer remainder
; ??? Need to decide behavior.

(define (-pmacro-builtin-rem x y)
  (-pmacro-verify-integer ".rem" x)
  (-pmacro-verify-integer ".rem" y)
  (remainder x y)
)

; (.sll x n) - shift left logical

(define (-pmacro-builtin-sll x n)
  (-pmacro-verify-integer ".sll" x)
  (-pmacro-verify-non-negative-integer ".sll" n)
  (ash x n)
)

; (.srl x n) - shift right logical
; X must be non-negative, otherwise behavior is undefined.
; [Unless we introduce a size argument: How do you logical shift right
; an arbitrary precision negative number?]

(define (-pmacro-builtin-srl x n)
  (-pmacro-verify-non-negative-integer ".srl" x)
  (-pmacro-verify-non-negative-integer ".srl" n)
  (ash x (- n))
)

; (.sra x n) - shift right arithmetic

(define (-pmacro-builtin-sra x n)
  (-pmacro-verify-integer ".sra" x)
  (-pmacro-verify-non-negative-integer ".sra" n)
  (ash x (- n))
)

; (.and x y) - bitwise and

(define (-pmacro-builtin-and x y)
  (-pmacro-verify-integer ".and" x)
  (-pmacro-verify-integer ".and" y)
  (logand x y)
)

; (.or x y) - bitwise or

(define (-pmacro-builtin-or x y)
  (-pmacro-verify-integer ".or" x)
  (-pmacro-verify-integer ".or" y)
  (logior x y)
)

; (.xor x y) - bitwise xor

(define (-pmacro-builtin-xor x y)
  (-pmacro-verify-integer ".xor" x)
  (-pmacro-verify-integer ".xor" y)
  (logxor x y)
)

; (.inv x) - bitwise invert

(define (-pmacro-builtin-inv x)
  (-pmacro-verify-integer ".inv" x)
  (lognot x)
)

; (.car expr)

(define (-pmacro-builtin-car l)
  (if (pair? l)
      (car l)
      (-pmacro-error "invalid arg for .car, expected pair" l))
)

; (.cdr expr)

(define (-pmacro-builtin-cdr l)
  (if (pair? l)
      (cdr l)
      (-pmacro-error "invalid arg for .cdr, expected pair" l))
)

; (.caar expr)

(define (-pmacro-builtin-caar l)
  (if (and (pair? l) (pair? (car l)))
      (caar l)
      (-pmacro-error "invalid arg for .caar" l))
)

; (.cadr expr)

(define (-pmacro-builtin-cadr l)
  (if (and (pair? l) (pair? (cdr l)))
      (cadr l)
      (-pmacro-error "invalid arg for .cadr" l))
)

; (.cdar expr)

(define (-pmacro-builtin-cdar l)
  (if (and (pair? l) (pair? (car l)))
      (cdar l)
      (-pmacro-error "invalid arg for .cdar" l))
)

; (.cddr expr)

(define (-pmacro-builtin-cddr l)
  (if (and (pair? l) (pair? (cdr l)))
      (cddr l)
      (-pmacro-error "invalid arg for .cddr" l))
)

; (.internal-test expr)
; This is an internal builtin for use by the testsuite.
; EXPR is a Scheme expression that is executed to verify proper
; behaviour of something.  It must return #f for FAIL, non-#f for PASS.
; The result is #f for FAIL, #t for PASS.
; This must be used in an expression, it is not sufficient to do
; (.internal-test mumble) because the reader will see #f or #t and complain.

(define (-pmacro-builtin-internal-test expr)
  (and (eval1 expr) #t)
)

; Initialization.

(define (pmacros-init!)
  (set! -pmacro-table (make-hash-table 127))
  (set! -smacro-table (make-hash-table 41))

  ; Some "predefined" pmacros.

  (let ((macros
	 ;; name arg-spec syntactic? function description
	 (list
	  (list '.sym 'symbols #f -pmacro-builtin-sym "symbol-append")
	  (list '.str 'strings #f -pmacro-builtin-str "string-append")
	  (list '.hex '(number . width) #f -pmacro-builtin-hex "convert to -hex, with optional width")
	  (list '.upcase '(string) #f -pmacro-builtin-upcase "string-upcase")
	  (list '.downcase '(string) #f -pmacro-builtin-downcase "string-downcase")
	  (list '.substring '(string start end) #f -pmacro-builtin-substring "get start of a string")
	  (list '.splice 'arg-list #f -pmacro-builtin-splice "splice lists into the outer list")
	  (list '.iota '(count . start-incr) #f -pmacro-builtin-iota "iota number generator")
	  (list '.map '(pmacro list1 . rest) #f -pmacro-builtin-map "map a pmacro over a list of arguments")
	  (list '.for-each '(pmacro list1 . rest) #f -pmacro-builtin-for-each "execute a pmacro over a list of arguments")
	  (list '.eval '(expr) #t -pmacro-builtin-eval "expand(evaluate) expr")
	  (list '.exec '(expr) #f -pmacro-builtin-exec "execute expr immediately")
	  (list '.apply '(pmacro arg-list) #f -pmacro-builtin-apply "apply a pmacro to a list of arguments")
	  (list '.pmacro '(params expansion) #t -pmacro-builtin-pmacro "create a pmacro on-the-fly")
	  (list '.pmacro? '(arg) #f -pmacro-builtin-pmacro? "return true if arg is a pmacro")
	  (list '.let '(locals expr1 . rest) #t -pmacro-builtin-let "create a binding context, let-style")
	  (list '.let* '(locals expr1 . rest) #t -pmacro-builtin-let* "create a binding context, let*-style")
	  (list '.if '(expr then . else) #t -pmacro-builtin-if "if expr is true, process then, else else")
	  (list '.case '(expr case1 . rest) #t -pmacro-builtin-case "process statement that matches expr")
	  (list '.cond '(expr1 . rest) #t -pmacro-builtin-cond "process first statement whose expr succeeds")
	  (list '.begin 'rest #t -pmacro-builtin-begin "process a sequence of statements")
	  (list '.print 'exprs #f -pmacro-builtin-print "print exprs, for debugging purposes")
	  (list '.dump '(expr)  #f-pmacro-builtin-dump "dump expr, for debugging purposes")
	  (list '.error 'message #f -pmacro-builtin-error "print error message and exit")
	  (list '.list 'exprs #f -pmacro-builtin-list "return a list of exprs")
	  (list '.ref '(l n) #f -pmacro-builtin-ref "return n'th element of list l")
	  (list '.length '(x) #f -pmacro-builtin-length "return length of symbol, string, or list")
	  (list '.replicate '(n expr) #f -pmacro-builtin-replicate "return list of expr replicated n times")
	  (list '.find '(pred l) #f -pmacro-builtin-find "return elements of list l matching pred")
	  (list '.equals '(x y) #f -pmacro-builtin-equals "deep comparison of x and y")
	  (list '.andif 'rest #t -pmacro-builtin-andif "return first #f element, otherwise return last element")
	  (list '.orif 'rest #t -pmacro-builtin-orif "return first non-#f element found, otherwise #f")
	  (list '.not '(x) #f -pmacro-builtin-not "return !x")
	  (list '.eq '(x y) #f -pmacro-builtin-eq "return true if x == y")
	  (list '.ne '(x y) #f -pmacro-builtin-ne "return true if x != y")
	  (list '.lt '(x y) #f -pmacro-builtin-lt "return true if x < y")
	  (list '.gt '(x y) #f -pmacro-builtin-gt "return true if x > y")
	  (list '.le '(x y) #f -pmacro-builtin-le "return true if x <= y")
	  (list '.ge '(x y) #f -pmacro-builtin-ge "return true if x >= y")
	  (list '.add '(x y) #f -pmacro-builtin-add "return x + y")
	  (list '.sub '(x y) #f -pmacro-builtin-sub "return x - y")
	  (list '.mul '(x y) #f -pmacro-builtin-mul "return x * y")
	  (list '.div '(x y) #f -pmacro-builtin-div "return x / y")
	  (list '.rem '(x y) #f -pmacro-builtin-rem "return x % y")
	  (list '.sll '(x n) #f -pmacro-builtin-sll "return logical x << n")
	  (list '.srl '(x n) #f -pmacro-builtin-srl "return logical x >> n")
	  (list '.sra '(x n) #f -pmacro-builtin-sra "return arithmetic x >> n")
	  (list '.and '(x y) #f -pmacro-builtin-and "return x & y")
	  (list '.or '(x y) #f -pmacro-builtin-or "return x | y")
	  (list '.xor '(x y) #f -pmacro-builtin-xor "return x ^ y")
	  (list '.inv '(x) #f -pmacro-builtin-inv "return ~x")
	  (list '.car '(x) #f -pmacro-builtin-car "return (car x)")
	  (list '.cdr '(x) #f -pmacro-builtin-cdr "return (cdr x)")
	  (list '.caar '(x) #f -pmacro-builtin-caar "return (caar x)")
	  (list '.cadr '(x) #f -pmacro-builtin-cadr "return (cadr x)")
	  (list '.cdar '(x) #f -pmacro-builtin-cdar "return (cdar x)")
	  (list '.cddr '(x) #f -pmacro-builtin-cddr "return (cddr x)")
	  (list '.internal-test '(expr) #f -pmacro-builtin-internal-test "testsuite use only")
	  )))
    (for-each (lambda (x)
		(let ((name (list-ref x 0))
		      (arg-spec (list-ref x 1))
		      (syntactic? (list-ref x 2))
		      (pmacro (list-ref x 3))
		      (comment (list-ref x 4)))
		  (-pmacro-set! name
				(-pmacro-make name arg-spec #f syntactic? pmacro comment))
		  (if syntactic?
		      (-smacro-set! name
				    (-pmacro-make name arg-spec #f syntactic? pmacro comment)))))
	      macros))
)

; Initialize so we're ready to use after loading.
(pmacros-init!)
