; RTL->C translation support.
; Copyright (C) 2000, 2005, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; Generating C from RTL
; ---------------------
; The main way to generate C code from an RTL expression is:
;
; (rtl-c mode '(func mode ...) nil)
;
; E.g.
; (rtl-c DFLT '(add SI (const SI 1) (const SI 2)) nil)
; -->
; "ADDSI (1, 2)"
; Mode `DFLT' (DEFAULTmode) means "use the default/natural mode".
;
; The expression is in source form or may be already compiled (with
; rtx-compile).
;
; The `set' rtx needs to be handled a little carefully.
; Both the dest and src are processed first, and then code to perform the
; assignment is computed.  However, the dest may require more than a simple
; C assignment.  Therefore set dests are converted to the specified object
; (e.g. a hardware operand) and then a message is sent to this object to
; perform the actual code generation.
;
; All interesting operands (e.g. regs, mem) are `operand' objects.
; The following messages must be supported by operand objects.
; - get-mode      - return mode of operand
; - cxmake-get    - return <c-expr> object containing operand's value
; - gen-set-quiet - return string of C code to set operand's value (no tracing)
; - gen-set-trace - return string of C code to set operand's value
;
; Instruction fields are refered to by name.
; (estate-owner estate) must be an instruction that has the field.
; Instruction ifields must have these methods:
; - get-mode
; - cxmake-get
;
; Conventions used in this file:
; - see rtl.scm

; The <c-expr> object.
; This is a fully translated expression (i.e. C code).

(define <c-expr>
  (class-make '<c-expr> nil
	      '(
		; The mode of C-CODE.
		mode
		; The translated C code.
		c-code
		; The source expression, for debugging.
		expr
		; Attributes of the expression.
		atlist
		; List of temporaries required to compute the expression.
		; ??? wip.  These would be combined as the expression is
		; built up.  Then in sets and other statements, the temporaries
		; would be declared.
		;(tmps . nil)
		)
	      nil)
)

(method-make!
 <c-expr> 'make!
 (lambda (self mode c-code atlist)
   ; FIXME: Extend COS to allow specifying member predicates.
   (assert (mode? mode))
   (assert (string? c-code))
   ;(assert (atlist? atlist)) ; FIXME: What should this be?
   (elm-set! self 'mode mode)
   (elm-set! self 'c-code c-code)
   (elm-set! self 'atlist atlist)
   self)
)

; Accessor fns

(define cx:mode (elm-make-getter <c-expr> 'mode))
(define cx:c-code (elm-make-getter <c-expr> 'c-code))
(define cx:expr (elm-make-getter <c-expr> 'expr))
(define cx:atlist (elm-make-getter <c-expr> 'atlist))
;(define cx:tmps (elm-make-getter <c-expr> 'tmps))

; Any object with attributes requires the get-atlist method.

(method-make! <c-expr> 'get-atlist (lambda (self) (elm-get self 'atlist)))

; Respond to 'get-mode messages.

(method-make! <c-expr> 'get-mode (lambda (self) (elm-get self 'mode)))

; Respond to 'get-name messages for rtx-dump.

(method-make!
 <c-expr> 'get-name
 (lambda (self)
   (string-append "(" (obj:str-name (elm-get self 'mode)) ") "
		  (cx:c self)))
)

; Return C code to perform an assignment.
; NEWVAL is a <c-expr> object of the value to be assigned to SELF.

(method-make! <c-expr> 'gen-set-quiet
	      (lambda (self estate mode indx selector newval)
		(string-append "  " (cx:c self) " = " (cx:c newval) ";\n"))
)

(method-make! <c-expr> 'gen-set-trace
	      (lambda (self estate mode indx selector newval)
		(string-append "  " (cx:c self) " = " (cx:c newval) ";\n"))
)

; Return the C code of CX.
; ??? This used to handle lazy evaluation of the expression.
; Maybe it will again, so it's left in, as a cover fn to cx:c-code.

(define (cx:c cx)
  (cx:c-code cx)
)

; Main routine to create a <c-expr> node object.
; MODE is either the mode's symbol (e.g. 'QI) or a mode object.
; CODE is a string of C code.

(define (cx:make mode code)
  (make <c-expr> (mode:lookup mode) code nil)
)

; Make copy of CX in new mode MODE.
; MODE must be a <mode> object.

(define (cx-new-mode mode cx)
  (make <c-expr> mode (cx:c cx) (cx:atlist cx))
)

; Same as cx:make except with attributes.

(define (cx:make-with-atlist mode code atlist)
  (make <c-expr> (mode:lookup mode) code atlist)
)

; Return a boolean indicated if X is a <c-expr> object.

(define (c-expr? x) (class-instance? <c-expr> x))

; RTX environment support.

(method-make!
 <rtx-temp> 'cxmake-get
 (lambda (self estate mode indx selector)
   (cx:make mode (rtx-temp-value self)))
)

(method-make!
 <rtx-temp> 'gen-set-quiet
 (lambda (self estate mode indx selector src)
   (string-append "  " (rtx-temp-value self) " = " (cx:c src) ";\n"))
)

(method-make!
 <rtx-temp> 'gen-set-trace
 (lambda (self estate mode indx selector src)
   (string-append "  " (rtx-temp-value self) " = " (cx:c src) ";\n"))
)

(define (gen-temp-defs estate env)
  (string-map (lambda (temp)
		(let ((temp-obj (cdr temp)))
		  (string-append "  " (mode:c-type (rtx-temp-mode temp-obj))
				 " " (rtx-temp-value temp-obj) ";\n")))
	      env)
)

; Top level routines to handle rtl->c translation.

; rtl->c configuration parameters

; #t -> emit calls to rtl cover fns, otherwise emit plain C where possible.
(define -rtl-c-rtl-cover-fns? #f)

; Called before emitting code to configure the generator.
; ??? I think this can go away now (since cover-fn specification is also
; done at each call to rtl-c).

(define (rtl-c-config! . args)
  (set! -rtl-c-rtl-cover-fns? #f)
  (let loop ((args args))
    (if (null? args)
	#f ; done
	(begin
	  (case (car args)
	    ((#:rtl-cover-fns?)
	     (set! -rtl-c-rtl-cover-fns? (cadr args)))
	    (else (error "rtl-c-config: unknown option:" (car args))))
	  (loop (cddr args)))))
  *UNSPECIFIED*
)

; Subclass of <eval-state> to record additional things needed for rtl->c.

(define <rtl-c-eval-state>
  (class-make '<rtl-c-eval-state> '(<eval-state>)
	      '(
		; #t -> emit calls to rtl cover fns.
		(rtl-cover-fns? . #f)

		; name of output language, "c" or "c++"
		(output-language . "c")

		; #t if generating code for a macro.
		; Each newline is then preceeded with '\\'.
		(macro? . #f)

		; #f -> reference ifield values using FLD macro.
		; #t -> use C variables.
		; ??? This is only needed to get correct ifield references
		; in opcodes, decoder, and semantics.  Maybe a better way to
		; go would be to specify the caller's name so there'd be just
		; one of these, rather than an increasing number.  However,
		; for now either way is the same.
		; An alternative is to specify a callback to try first.
		(ifield-var? . #f)
		)
	      nil)
)

; FIXME: involves upcasting.
(define-getters <rtl-c-eval-state> estate
  (rtl-cover-fns? output-language macro? ifield-var?)
)

; Return booleans indicating if output language is C/C++.

(define (estate-output-language-c? estate)
  (string=? (estate-output-language estate) "c")
)
(define (estate-output-language-c++? estate)
  (string=? (estate-output-language estate) "c++")
)

(method-make!
 <rtl-c-eval-state> 'vmake!
 (lambda (self args)
   ; Initialize parent class first.
   (let loop ((args (send-next self 'vmake! args)) (unrecognized nil))
     (if (null? args)
	 (reverse! unrecognized) ; ??? Could invoke method to initialize here.
	 (begin
	   (case (car args)
	     ((#:rtl-cover-fns?)
	      (elm-set! self 'rtl-cover-fns? (cadr args)))
	     ((#:output-language)
	      (elm-set! self 'output-language (cadr args)))
	     ((#:macro?)
	      (elm-set! self 'macro? (cadr args)))
	     ((#:ifield-var?)
	      (elm-set! self 'ifield-var? (cadr args)))
	     (else
	      ; Build in reverse order, as we reverse it back when we're done.
	      (set! unrecognized
		    (cons (cadr args) (cons (car args) unrecognized)))))
	   (loop (cddr args) unrecognized)))))
)

; Build an estate for use in generating C.
; CONTEXT is a <context> object or #f if there is none.
; OWNER is the owner of the expression or #f if there is none.
; EXTRA-VARS-ALIST is an association list of (symbol <mode> value)
; elements to be used during value lookup.
; OVERRIDES is a #:keyword/value list of parameters to apply last.

(define (estate-make-for-rtl-c context owner extra-vars-alist
			       rtl-cover-fns? macro? overrides)
  (apply vmake
	 (append!
	  (list
	   <rtl-c-eval-state>
	   #:context context
	   #:owner owner
	   #:expr-fn (lambda (rtx-obj expr mode estate)
		       (rtl-c-generator rtx-obj))
	   #:env (rtx-env-init-stack1 extra-vars-alist)
	   #:rtl-cover-fns? rtl-cover-fns?
	   #:macro? macro?)
	   overrides))
)

(define (estate-make-for-normal-rtl-c extra-vars-alist overrides)
  (estate-make-for-rtl-c
   #f ; FIXME: context
   #f ; FIXME: owner
   extra-vars-alist
   -rtl-c-rtl-cover-fns?
   #f ; macro?
   overrides)
)

; Translate RTL expression EXPR to C.
; ESTATE is the current rtx evaluation state.

(define (rtl-c-with-estate estate mode expr)
  (cx:c (rtl-c-get estate mode (rtx-eval-with-estate expr mode estate)))
)

; Translate parsed RTL expression X to a string of C code.
; X must have already been fed through rtx-parse/rtx-compile.
; MODE is the desired mode of the value or DFLT for "natural mode".
; EXTRA-VARS-ALIST is an association list of extra (symbol <mode> value)
; elements to be used during value lookup.
; OVERRIDES is a #:keyword/value list of arguments to build the eval state
; with.
; ??? Maybe EXTRA-VARS-ALIST should be handled this way.

(define (rtl-c-parsed mode x extra-vars-alist . overrides)
  (let ((estate (estate-make-for-normal-rtl-c extra-vars-alist overrides)))
    (rtl-c-with-estate estate mode x))
)

; Same as rtl-c-parsed but X is unparsed.

(define (rtl-c mode x extra-vars-alist . overrides)
  ; ??? rtx-compile could return a closure, then we wouldn't have to
  ; pass EXTRA-VARS-ALIST to two routines here.
  (let ((estate (estate-make-for-normal-rtl-c extra-vars-alist overrides)))
    (rtl-c-with-estate estate mode (rtx-compile #f x extra-vars-alist)))
)

; Same as rtl-c-with-estate except return a <c-expr> object.

(define (rtl-c-expr-with-estate estate mode expr)
  (rtl-c-get estate mode (rtx-eval-with-estate expr mode estate))
)

; Same as rtl-c-parsed except return a <c-expr> object.

(define (rtl-c-expr-parsed mode x extra-vars-alist . overrides)
  (let ((estate (estate-make-for-normal-rtl-c extra-vars-alist overrides)))
    (rtl-c-expr-with-estate estate mode x))
)

; Same as rtl-c-expr-parsed but X is unparsed.

(define (rtl-c-expr mode x extra-vars-alist . overrides)
  ; ??? rtx-compile could return a closure, then we wouldn't have to
  ; pass EXTRA-VARS-ALIST to two routines here.
  (let ((estate (estate-make-for-normal-rtl-c extra-vars-alist overrides)))
    (rtl-c-expr-with-estate estate mode (rtx-compile #f x extra-vars-alist)))
)

; C++ versions of rtl-c routines.

; Build an estate for use in generating C++.
; EXTRA-VARS-ALIST is an association list of (symbol <mode> value)
; elements to be used during value lookup.
; OVERRIDES is a #:keyword/value list of parameters to apply last.

(define (estate-make-for-normal-rtl-c++ extra-vars-alist overrides)
  (estate-make-for-rtl-c
   #f ; FIXME: context
   #f ; FIXME: owner
   extra-vars-alist
   -rtl-c-rtl-cover-fns?
   #f ; macro?
   (cons #:output-language (cons "c++" overrides)))
)

; Translate parsed RTL expression X to a string of C++ code.
; X must have already been fed through rtx-parse/rtx-compile.
; MODE is the desired mode of the value or DFLT for "natural mode".
; EXTRA-VARS-ALIST is an association list of extra (symbol <mode> value)
; elements to be used during value lookup.
; OVERRIDES is a #:keyword/value list of arguments to build the eval state
; with.
; ??? Maybe EXTRA-VARS-ALIST should be handled this way.

(define (rtl-c++-parsed mode x extra-vars-alist . overrides)
  (let ((estate (estate-make-for-normal-rtl-c++ extra-vars-alist overrides)))
    (rtl-c-with-estate estate mode x))
)

; Same as rtl-c-parsed but X is unparsed.

(define (rtl-c++ mode x extra-vars-alist . overrides)
  ; ??? rtx-compile could return a closure, then we wouldn't have to
  ; pass EXTRA-VARS-ALIST to two routines here.
  (let ((estate (estate-make-for-normal-rtl-c++ extra-vars-alist overrides)))
    (rtl-c-with-estate estate mode (rtx-compile #f x extra-vars-alist)))
)

; Top level routines for getting/setting values.

; Return a <c-expr> node to get the value of SRC in mode MODE.
; ESTATE is the current rtl evaluation state.
; SRC is one of:
; - <c-expr> node
; - rtl expression (e.g. '(add WI dr sr))
; - sequence's local variable name
; - sequence's local variable object
; - operand name
; - operand object
; - a string of C code
; FIXME: Reduce acceptable values of SRC.
; The result has mode MODE, unless MODE is the "default mode indicator"
; (DFLT) in which case the mode of the result is derived from SRC.
; If SRC is a string, MODE can't be VOID or DFLT.
;
; ??? mode compatibility checks are wip

(define (-rtl-c-get estate mode src)
  (let ((mode (mode:lookup mode)))

    (cond ((c-expr? src)
	   (cond ((or (mode:eq? 'VOID mode)
		      (mode:eq? 'DFLT mode)
		      (mode:eq? (cx:mode src) mode))
		  src)
		 ((-rtx-mode-compatible? mode (cx:mode src))
		  (cx-new-mode mode src))
		 (else
		  (estate-error
		   estate
		   (string-append "incompatible mode for "
				  "(" (obj:name (cx:mode src)) " vs "
				  (obj:name mode) ") in "
				  "\"" (cx:c src) "\""
				  ": ")
		   (obj:name mode)))))

	  ; The recursive call to -rtl-c-get is in case the result of rtx-eval
	  ; is a hardware object, rtx-func object, or another rtl expression.
	  ((rtx? src)
	   (let ((evald-src (rtx-eval-with-estate src mode estate)))
	     ; There must have been some change, otherwise we'll loop forever.
	     (assert (not (eq? src evald-src)))
	     (-rtl-c-get estate mode evald-src)))

	  ((or (and (symbol? src) (current-op-lookup src))
	       (operand? src))
	   (begin
	     (if (symbol? src)
		 (set! src (current-op-lookup src)))
	     (cond ((mode:eq? 'DFLT mode)
		    ; FIXME: If we fetch the mode here, operands can assume
		    ; they never get called with "default mode".
		    (send src 'cxmake-get estate mode #f #f))
		   ((-rtx-mode-compatible? mode (op:mode src))
		    (let ((mode (-rtx-lazy-sem-mode mode)))
		      (send src 'cxmake-get estate mode #f #f)))
		   (else
		    (estate-error
		     estate
		     (string-append "operand " (obj:str-name src)
				    " referenced in incompatible mode: ")
		     (obj:name mode))))))

	  ((or (and (symbol? src) (rtx-temp-lookup (estate-env estate) src))
	       (rtx-temp? src))
	   (begin
	     (if (symbol? src)
		 (set! src (rtx-temp-lookup (estate-env estate) src)))
	     (cond ((mode:eq? 'DFLT mode)
		    (send src 'cxmake-get estate (rtx-temp-mode src) #f #f))
		   ((-rtx-mode-compatible? mode (rtx-temp-mode src))
		    (let ((mode (-rtx-lazy-sem-mode mode)))
		      (send src 'cxmake-get estate mode #f #f)))
		   (else (estate-error
			  estate
			  (string-append "sequence temp " (rtx-temp-name src)
					 " referenced in incompatible mode: ")
			  (obj:name mode))))))

	  ((integer? src)
	   ; Default mode of string argument is INT.
	   (if (or (mode:eq? 'DFLT mode) (mode:eq? 'VOID mode))
	       (cx:make INT (number->string src))
	       (cx:make mode (number->string src))))

	  ((string? src)
	   ; Default mode of string argument is INT.
	   (if (or (mode:eq? 'DFLT mode) (mode:eq? 'VOID mode))
	       (cx:make INT src)
	       (cx:make mode src)))

	  (else (estate-error estate "-rtl-c-get: invalid argument:" src))))
)

(define (rtl-c-get estate mode src)
  (logit 4 (spaces (estate-depth estate))
	 "(rtl-c-get " (mode-real-name mode) " " (rtx-strdump src) ")\n")
  (let ((result (-rtl-c-get estate mode src)))
    (logit 4 (spaces (estate-depth estate))
	   "(rtl-c-get " (mode-real-name mode) " " (rtx-strdump src) ") => "
	   (cx:c result) "\n")
    result)
)

; Return a <c-expr> object to set the value of DEST to SRC.
; ESTATE is the current rtl evaluation state.
; DEST is one of:
; - <c-expr> node
; - rtl expression (e.g. '(mem QI dr))
; SRC is a <c-expr> object.
; The mode of the result is always VOID (void).

(define (rtl-c-set-quiet estate mode dest src)
  ;(display (list 'rtl-c-set-quiet mode dest src)) (newline)
  (let ((xdest (cond ((c-expr? dest)
		      dest)
		     ((rtx? dest)
		      (rtx-eval-with-estate dest mode estate))
		     (else
		      (estate-error estate
				    "rtl-c-set-quiet: invalid dest:"
				    dest)))))
    (if (not (object? xdest))
	(estate-error estate "rtl-c-set-quiet: invalid dest:" dest))
    (let ((mode (if (mode:eq? 'DFLT mode)
		    (-rtx-obj-mode xdest)
		    (-rtx-lazy-sem-mode mode))))
      (assert (mode? mode))
      (cx:make VOID (send xdest 'gen-set-quiet
			estate mode #f #f
			(rtl-c-get estate mode src)))))
)

; Same as rtl-c-set-quiet except also print TRACE_RESULT message.
; ??? One possible change is to defer the (rtl-c-get src) call to dest's
; set handler.  Such sources would be marked accordingly and rtl-c-get
; would recognize them.  This would allow, for example, passing the address
; of the result to the computation.

(define (rtl-c-set-trace estate mode dest src)
  ;(display (list 'rtl-c-set-trace mode dest src)) (newline)
  (let ((xdest (cond ((c-expr? dest)
		      dest)
		     ((rtx? dest)
		      (rtx-eval-with-estate dest mode estate))
		     (else
		      (estate-error estate
				    "rtl-c-set-trace: invalid dest:"
				    dest)))))
    (if (not (object? xdest))
	(estate-error estate "rtl-c-set-trace: invalid dest:" dest))
    (let ((mode (if (mode:eq? 'DFLT mode)
		    (-rtx-obj-mode xdest) ; FIXME: internal routines
		    (-rtx-lazy-sem-mode mode))))
      (assert (mode? mode))
      (cx:make VOID (send xdest 'gen-set-trace
			estate mode #f #f
			(rtl-c-get estate mode src)))))
)

; Emit C code for each rtx function.

; Table mapping rtx function to C generator.

(define -rtl-c-gen-table #f)

; Return the C generator for <rtx-func> F.

(define (rtl-c-generator f)
  (vector-ref -rtl-c-gen-table (rtx-num f))
)

; Support for explicit C/C++ code.
; ??? Actually, "support for explicit foreign language code".
; s-c-call needs a better name but "unspec" seems like obfuscation.
; ??? Need to distinguish owner of call (cpu, ???).

(define (s-c-call estate mode name . args)
  (cx:make mode
	   (string-append
	    (if (estate-output-language-c++? estate)
		(string-append "current_cpu->" name " (")
		; FIXME: Prepend @cpu@_ to name here, and delete @cpu@_ from
		; description file.
		(string-append name " (current_cpu"))
	    (let ((c-args
		   (string-map (lambda (arg)
				 (string-append
				  ", "
				  (cx:c (rtl-c-get estate DFLT arg))))
			       args)))
	      (if (estate-output-language-c++? estate)
		  (string-drop 2 c-args)
		  c-args))
	    ; If the mode is VOID, this is a statement.
	    ; Otherwise it's an expression.
	    ; ??? Bad assumption!  VOID expressions may be used
	    ; within sequences without local vars, which are translated
	    ; to comma-expressions.
	    (if (or (mode:eq? 'DFLT mode)
		    (mode:eq? 'VOID mode))
		");\n"
		")")
	    ))
)

; Same as c-call except there is no particular owner of the call.
; In general this means making a call to a non-member function,
; whereas c-call makes calls to member functions (in C++ parlance).

(define (s-c-raw-call estate mode name . args)
  (cx:make mode
	   (string-append
	    name " ("
	    (string-drop 2
			 (string-map (lambda (elm)
				       (string-append
					", " (cx:c (rtl-c-get estate DFLT elm))))
				     args))
	    ; If the mode is VOID, this is a statement.
	    ; Otherwise it's an expression.
	    ; ??? Bad assumption!  VOID expressions may be used
	    ; within sequences without local vars, which are translated
	    ; to comma-expressions.
	    (if (or (mode:eq? 'DFLT mode)
		    (mode:eq? 'VOID mode))
		");\n"
		")")
	    ))
)

; Standard arithmetic operations.

; Return a boolean indicating if a cover function/macro should be emitted
; to perform an operation.
; C-OP is a string containing the C operation or #f if there is none.
; MODE is the mode of the operation.

(define (-rtx-use-sem-fn? estate c-op mode)
  ; If no C operation has been provided, use a macro, or
  ; if this is the simulator and MODE is not a host mode, use a macro.
;  (or (not c-op)
;      (and (estate-rtl-cover-fns? estate)
;	   (not (mode:host? mode))))
  ; FIXME: The current definition is a temporary hack while host/target-ness
  ; of INT/UINT is unresolved.
  (and (not (obj-has-attr? mode 'FORCE-C))
       (or (not c-op)
	   (and (estate-rtl-cover-fns? estate)
		(or (insn? (estate-owner estate))
		    (not (mode:host? mode))))))
)

; One operand referenced, result is in same mode.

(define (s-unop estate name c-op mode src)
  (let* ((val (rtl-c-get estate mode src))
	 ; Refetch mode in case it was DFLT and ensure unsigned->signed.
	 (mode (cx:mode val))
	 (sem-mode (-rtx-sem-mode mode)))
    ; FIXME: Argument checking.

    (if (-rtx-use-sem-fn? estate c-op mode)
	(if (mode-float? mode)
	    (cx:make sem-mode
		     (string-append "CGEN_CPU_FPU (current_cpu)->ops->"
				    (string-downcase name)
				    (string-downcase (obj:str-name sem-mode))
				    " (CGEN_CPU_FPU (current_cpu), "
				    (cx:c val) ")"))
	    (cx:make sem-mode
		     (string-append name (obj:str-name sem-mode)
				    " (" (cx:c val) ")")))
	(cx:make mode ; not sem-mode on purpose
		 (string-append "(" c-op " ("
				(cx:c val) "))"))))
)

; Two operands referenced in the same mode producing a result in the same mode.
; If MODE is DFLT, use the mode of SRC1.
;
; ??? Will eventually want to handle floating point modes specially.  Since
; bigger modes may get clumsily passed (there is no pass by reference in C) and
; since we want to eventually handle lazy transformation, FP values could be
; passed by reference.  This is easy in C++.  C requires more work and is
; defered until it's warranted.
; Implementing this should probably be via a new cxmake-get-ref method,
; rather then complicating cxmake-get.  Ditto for rtl-c-get-ref/rtl-c-get.

(define (s-binop estate name c-op mode src1 src2)
  (let* ((val1 (rtl-c-get estate mode src1))
	 ; Refetch mode in case it was DFLT and ensure unsigned->signed.
	 (mode (cx:mode val1))
	 (sem-mode (-rtx-sem-mode mode))
	 (val2 (rtl-c-get estate mode src2)))
    ; FIXME: Argument checking.

    (if (-rtx-use-sem-fn? estate c-op mode)
	(if (mode-float? mode)
	    (cx:make sem-mode
		     (string-append "CGEN_CPU_FPU (current_cpu)->ops->"
				    (string-downcase name)
				    (string-downcase (obj:str-name sem-mode))
				    " (CGEN_CPU_FPU (current_cpu), "
				    (cx:c val1) ", "
				    (cx:c val2) ")"))
	    (cx:make sem-mode
		     (string-append name (obj:str-name sem-mode)
				    " (" (cx:c val1) ", "
				    (cx:c val2) ")")))
	(cx:make mode ; not sem-mode on purpose
		 (string-append "(("
				(cx:c val1)
				") " c-op " ("
				(cx:c val2)
				"))"))))
)

; Same as s-binop except there's a third argument which is always one bit.

(define (s-binop-with-bit estate name mode src1 src2 src3)
  (let* ((val1 (rtl-c-get estate mode src1))
	 ; Refetch mode in case it was DFLT and ensure unsigned->signed.
	 (mode (-rtx-sem-mode (cx:mode val1)))
	 (val2 (rtl-c-get estate mode src2))
	 (val3 (rtl-c-get estate 'BI src3)))
    ; FIXME: Argument checking.
    (cx:make mode
	  (string-append name (obj:str-name mode)
			 " ("
			 (cx:c val1) ", "
			 (cx:c val2) ", "
			 (cx:c val3)
			 ")")))
)

; Shift operations are slightly different than binary operations:
; the mode of src2 is any integral mode.
; ??? Note that some cpus have a signed shift left that is semantically
; different from a logical one.  May need to create `sla' some day.  Later.

(define (s-shop estate name c-op mode src1 src2)
  (let* ((val1 (rtl-c-get estate mode src1))
	 ; Refetch mode in case it was DFLT and ensure unsigned->signed
	 ; [sign of operation is determined from operation name, not mode].
	 (mode (cx:mode val1))
	 (sem-mode (-rtx-sem-mode mode))
	 (val2 (rtl-c-get estate mode src2)))
    ; FIXME: Argument checking.

    (if (-rtx-use-sem-fn? estate c-op mode)
	(cx:make sem-mode
		 (string-append name (obj:str-name sem-mode)
				" (" (cx:c val1) ", "
				(cx:c val2) ")"))
	(cx:make mode ; not sem-mode on purpose
		 (string-append "("
				; Ensure correct sign of shift.
				(cond ((equal? name "SRL")
				       (string-append "("
						      (if (eq? (mode:class mode) 'UINT)
							  ""
							  "unsigned ")
						      (mode:non-mode-c-type mode)
						      ") "))
				      ((equal? name "SRA")
				       (string-append "("
						      (mode:non-mode-c-type mode)
						      ") "))
				      (else ""))
				"(" (cx:c val1) ") "
				c-op
				" (" (cx:c val2) "))"))))
)

; Process andif, orif.
; SRC1 and SRC2 have any arithmetic mode.
; The result has mode BI.
; ??? May want to use INT as BI may introduce some slowness
; in the generated code.

(define (s-boolifop estate name c-op src1 src2)
  (let* ((val1 (rtl-c-get estate DFLT src1))
	 (val2 (rtl-c-get estate DFLT src2)))
    ; FIXME: Argument checking.
    ; If this is the simulator and MODE is not a host mode, use a macro.
    ; ??? MODE here being the mode of SRC1.  Maybe later.
    (if (estate-rtl-cover-fns? estate)
	(cx:make (mode:lookup 'BI)
		 (string-append name ; "BI", leave off mode, no need for it
				" (" (cx:c val1) ", "
				(cx:c val2) ")"))
	(cx:make (mode:lookup 'BI)
		 (string-append "(("
				(cx:c val1)
				") " c-op " ("
				(cx:c val2)
				"))"))))
)

; Mode conversions.

(define (s-convop estate name mode s1)
  ; Get S1 in its normal mode, then convert.
  (let ((s (rtl-c-get estate DFLT s1))
	(mode (mode:lookup mode)))
    (if (and (not (estate-rtl-cover-fns? estate))
	     (mode:host? (cx:mode s)))
	(cx:make mode
		 (string-append "((" (obj:str-name mode) ")"
				" (" (obj:str-name (cx:mode s)) ")"
				" (" (cx:c s) "))"))
	(if (or (mode-float? mode)
		(mode-float? (cx:mode s)))
	    (cx:make mode
		     (string-append "CGEN_CPU_FPU (current_cpu)->ops->"
				    (string-downcase name)
				    (string-downcase (obj:str-name (-rtx-sem-mode (cx:mode s))))
				    (string-downcase (obj:str-name (-rtx-sem-mode mode)))
				    " (CGEN_CPU_FPU (current_cpu), "
				    (cx:c s) ")"))
	    (cx:make mode
		     (string-append name
				    (obj:str-name (-rtx-sem-mode (cx:mode s)))
				    (obj:str-name (-rtx-sem-mode mode))
				    " (" (cx:c s) ")")))))
)

; Compare SRC1 and SRC2 in mode MODE.  The result has mode BI.
; NAME is one of eq,ne,lt,le,gt,ge,ltu,leu,gtu,geu.
; ??? May want a host int mode result as BI may introduce some slowness
; in the generated code.

(define (s-cmpop estate name c-op mode src1 src2)
  (let* ((val1 (rtl-c-get estate mode src1))
	 ; Refetch mode in case it was DFLT.
	 (mode (cx:mode val1))
	 (val2 (rtl-c-get estate mode src2)))
    ; FIXME: Argument checking.

    ; If no C operation has been provided, use a macro, or
    ; if this is the simulator and MODE is not a host mode, use a macro.
    (if (-rtx-use-sem-fn? estate c-op mode)
	(if (mode-float? mode)
	    (cx:make (mode:lookup 'BI)
		     (string-append "CGEN_CPU_FPU (current_cpu)->ops->"
				    (string-downcase (symbol->string name))
				    (string-downcase (obj:str-name (-rtx-sem-mode mode)))
				    " (CGEN_CPU_FPU (current_cpu), "
				    (cx:c val1) ", "
				    (cx:c val2) ")"))
	    (cx:make (mode:lookup 'BI)
		     (string-append (string-upcase (symbol->string name))
				    (if (memq name '(eq ne))
					(obj:str-name (-rtx-sem-mode mode))
					(obj:str-name mode))
				    " (" (cx:c val1) ", "
				    (cx:c val2) ")")))
	(cx:make (mode:lookup 'BI)
		 (string-append "(("
				(cx:c val1)
				") " c-op " ("
				(cx:c val2)
				"))"))))
)

; Conditional execution.

; `if' in RTL has a result, like ?: in C.
; We support both: one with a result (non VOID mode), and one without (VOID mode).
; The non-VOID case must have an else part.
; MODE is the mode of the result, not the comparison.
; The comparison is expected to return a zero/non-zero value.
; ??? Perhaps this should be a syntax-expr.  Later.

(define (s-if estate mode cond then . else)
  (if (> (length else) 1)
      (estate-error estate "if: too many elements in `else' part" else))
  (let ()
    (if (or (mode:eq? 'DFLT mode)
	    (mode:eq? 'VOID mode))
	(cx:make mode
		 (string-append "if (" (cx:c (rtl-c-get estate DFLT cond)) ")"
				" {\n" (cx:c (rtl-c-get estate mode then)) "}"
				(if (not (null? else))
				    (string-append " else {\n"
						   (cx:c (rtl-c-get estate mode (car else)))
						   "}\n")
				    "\n")
				))
	(if (= (length else) 1)
	    (cx:make mode
		     (string-append "(("
				    (cx:c (rtl-c-get estate DFLT cond))
				    ") ? ("
				    (cx:c (rtl-c-get estate mode then))
				    ") : ("
				    (cx:c (rtl-c-get estate mode (car else)))
				    "))"))
	    (estate-error estate "non-void-mode `if' must have `else' part"))))
)

; A multiway `if'.
; If MODE is VOID emit a series of if/else's.
; If MODE is not VOID, emit a series of ?:'s.
; COND-CODE-LIST is a list of lists, each sublist is a list of two elements:
; condition, code.  The condition part must return a zero/non-zero value, and
; the code part is treated as a `sequence'.
; This defer argument evaluation, the syntax
; ((... condition ...) ... action ...)
; needs special parsing.
; FIXME: Need more error checking of arguments.

(define (s-cond estate mode . cond-code-list)
  (let ((vm? (or (mode:eq? 'DFLT mode) (mode:eq? 'VOID mode))))
    (if (null? cond-code-list)
	(estate-error estate "empty `cond'"))
    (let ((if-part (if vm?  "if (" "("))
	  (then-part (if vm? ") " ") ? "))
	  (elseif-part (if vm? " else if (" " : ("))
	  (else-part (if vm? " else " " : "))
	  (fi-part (if vm? "" ")")))
      (let loop ((result
		  (string-append
		   if-part
		   (cx:c (rtl-c-get estate DFLT (caar cond-code-list)))
		   then-part
		   (cx:c (apply s-sequence
				(cons estate
				      (cons mode
					    (cons nil
						  (cdar cond-code-list))))))))
		 (ccl (cdr cond-code-list)))
	(cond ((null? ccl) (cx:make mode result))
	      ((eq? (caar ccl) 'else)
	       (cx:make mode
			(string-append
			 result
			 else-part
			 (cx:c (apply s-sequence
				      (cons estate
					    (cons mode
						  (cons nil
							(cdar ccl)))))))))
	      (else (loop (string-append
			   result
			   elseif-part
			   (cx:c (rtl-c-get estate DFLT (caar ccl)))
			   then-part
			   (cx:c (apply s-sequence
					(cons estate
					      (cons mode
						    (cons nil
							  (cdar ccl)))))))
			  (cdr ccl)))))))
)

; Utility of s-case to print a case prefix (for lack of a better term).

(define (-gen-case-prefix val)
  (string-append "  case "
		 (cond ((number? val)
			(number->string val))
		       ((symbol? val)
			(string-upcase (gen-c-symbol val))) ; yes, upcase
		       ((string? val) val)
		       (else
			(parse-error (make-prefix-context "case:")
				     "bad case" val)))
		 " : ")
)

; Utility of s-case to handle a void result.

(define (s-case-vm estate test case-list)
  (cx:make
   VOID
   (string-append
    "  switch ("
    (cx:c (rtl-c-get estate DFLT test))
    ")\n"
    "  {\n"
    (string-map (lambda (case-entry)
		  (let ((caseval (car case-entry))
			(code (cdr case-entry)))
		    (string-append
		     (cond ((list? caseval)
			    (string-map -gen-case-prefix caseval))
			   ((eq? 'else caseval)
			    (string-append "  default : "))
			   (else
			    (-gen-case-prefix caseval)))
		     (cx:c (apply s-sequence
				  (cons estate (cons VOID (cons nil code)))))
		     "    break;\n")))
		case-list)
    "  }\n"))
)

; Utility of s-case-non-vm to generate code to perform the test.

(define (-gen-non-vm-case-test estate mode test cases)
  (assert (not (null? cases)))
  (let loop ((result "") (cases cases))
    (if (null? cases)
	result
	(let ((case (cond ((number? (car cases))
			   (car cases))
			  ((symbol? (car cases))
			   (if (enum-lookup-val (car cases))
			       (rtx-make 'enum mode (car cases))
			       (estate-error estate
					     "symbol not an enum"
					     (car cases))))
			  (else
			   (estate-error estate "invalid case" (car cases))))))
	  (loop (string-append
		 result
		 (if (= (string-length result) 0)
		     ""
		     " || ")
		 (cx:c (rtl-c-get estate mode test))
		 " == "
		 (cx:c (rtl-c-get estate mode case)))
		(cdr cases)))))
)

; Utility of s-case to handle a non-void result.
; This is expanded as a series of ?:'s.

(define (s-case-non-vm estate mode test case-list)
  (let ((if-part "(")
	(then-part ") ? ")
	(elseif-part " : (")
	(else-part " : ")
	(fi-part ")"))
    (let loop ((result
		(string-append
		 if-part
		 (-gen-non-vm-case-test estate mode test (caar case-list))
		 then-part
		 (cx:c (apply s-sequence
			      (cons estate
				    (cons mode
					  (cons nil
						(cdar case-list))))))))
	       (cl (cdr case-list)))
      (cond ((null? cl) (cx:make mode result))
	    ((eq? (caar cl) 'else)
	     (cx:make mode
		      (string-append
		       result
		       else-part
		       (cx:c (apply s-sequence
				    (cons estate
					  (cons mode
						(cons nil
						      (cdar cl)))))))))
	    (else (loop (string-append
			 result
			 elseif-part
			 (-gen-non-vm-case-test estate mode test (caar cl))
			 then-part
			 (cx:c (apply s-sequence
				      (cons estate
					    (cons mode
						  (cons nil
							(cdar cl)))))))
			(cdr cl))))))
)

; C switch statement
; To follow convention, MODE is the first arg.
; FIXME: What to allow for case choices is wip.

(define (s-case estate mode test . case-list)
  (if (or (mode:eq? 'DFLT mode) (mode:eq? 'VOID mode))
      (s-case-vm estate test case-list)
      (s-case-non-vm estate mode test case-list))
)

; Parallels and Sequences

; Temps for `parallel' are recorded differently than for `sequence'.
; ??? I believe this is because there was an interaction between the two.

(define -par-temp-list nil)

; Record a temporary needed for a parallel in mode MODE.
; We just need to record the mode with a unique name so we use a <c-expr>
; object where the "expression" is the variable's name.

(define (-par-new-temp! mode)
  (set! -par-temp-list
	(cons (cx:make mode (string-append "temp"
					   (number->string
					    (length -par-temp-list))))
	      -par-temp-list))
  (car -par-temp-list)
)

; Return the next temp from the list, and leave the list pointing to the
; next one.

(define (-par-next-temp!)
  (let ((result (car -par-temp-list)))
    (set! -par-temp-list (cdr -par-temp-list))
    result)
)

(define (-gen-par-temp-defns temp-list)
  ;(display temp-list) (newline)
  (string-append
   "  "
   ; ??? mode:c-type
   (string-map (lambda (temp) (string-append (obj:str-name (cx:mode temp))
					     " " (cx:c temp) ";"))
	       temp-list)
   "\n")
)

; Parallels are handled by converting them into two sequences.  The first has
; all set destinations replaced with temps, and the second has all set sources
; replaced with those temps.
; ??? Revisit later to see if (if ...) and (set pc ...) is ok.
; How about disallowing if's and jump's inside parallels?
; One can still put a parallel inside an `if' however.

(define (-par-replace-set-dests estate exprs)
  (let ((sets (list 'set 'set-quiet
		    (rtx-lookup 'set) (rtx-lookup 'set-quiet))))
    (letrec ((replace
	      (lambda (expr)
		(let ((name (car expr))
		      (options (rtx-options expr))
		      (mode (rtx-mode expr)))
		  (if (memq name sets)
		      (list name
			    options
			    mode
			    (-par-new-temp! ; replace dest with temp
			     (if (mode:eq? 'DFLT mode)
				 (rtx-lvalue-mode-name estate (rtx-set-dest expr))
				 mode))
			    (rtx-set-src expr))
		      (cons name
			    (cons options
				  (cons mode (replace (rtx-args expr)))))))))
	     )
      (map replace exprs)))
)

; This must process expressions in the same order as -par-replace-set-dests!

(define (-par-replace-set-srcs estate exprs)
  (let ((sets (list 'set 'set-quiet
		    (rtx-lookup 'set) (rtx-lookup 'set-quiet))))
    (letrec ((replace
	      (lambda (expr)
		(let ((name (car expr))
		      (options (rtx-options expr))
		      (mode (rtx-mode expr)))
		  (if (memq name sets)
		      (list name
			    options
			    mode
			    (rtx-set-dest expr)
			    (-par-next-temp!)) ; the source's temp
		      (cons name
			    (cons options
				  (cons mode (replace (cddr expr)))))))))
	     )
      (map replace exprs)))
)

; Return a <c-expr> node for a `parallel'.

(define (s-parallel estate . exprs)
  (begin
    ; Initialize -par-temp-list for -par-replace-set-dests.
    (set! -par-temp-list nil)
    (let* ((set-dests (string-map (lambda (e)
				    (rtl-c-with-estate estate VOID e))
				  (-par-replace-set-dests estate exprs)))
	   (temps (reverse! -par-temp-list)))
      ; Initialize -par-temp-list for -par-replace-set-srcs.
      (set! -par-temp-list temps)
      (cx:make VOID
	       (string-append
		; FIXME: do {} while (0); doesn't get "optimized out"
		; internally by gcc, meaning two labels and a loop are
		; created for it to have to process.  We can generate pretty
		; big files and can cause gcc to require *lots* of memory.
		; So let's try just {} ...
		"{\n"
		(-gen-par-temp-defns temps)
		set-dests
		(string-map (lambda (e)
			      (rtl-c-with-estate estate VOID e))
			    (-par-replace-set-srcs estate exprs))
		"}\n")
	       )))
)

; Return a <c-expr> node for a `sequence'.

(define (s-sequence estate mode env . exprs)
  (let* ((env (rtx-env-make-locals env)) ; compile env
	 (estate (estate-push-env estate env)))
    (if (or (mode:eq? 'DFLT mode)
	    (mode:eq? 'VOID mode))
	(cx:make mode
		 (string-append 
		  ; FIXME: do {} while (0); doesn't get "optimized out"
		  ; internally by gcc, meaning two labels and a loop are
		  ; created for it to have to process.  We can generate pretty
		  ; big files and can cause gcc to require *lots* of memory.
		  ; So let's try just {} ...
		  "{\n"
		  (gen-temp-defs estate env)
		  (string-map (lambda (e)
				(rtl-c-with-estate estate DFLT e))
			      exprs)
		  "}\n"))
	(cx:make mode
		 (string-append
		  ; Don't use GCC extension unless necessary.
		  (if (rtx-env-empty? env) "(" "({ ")
		  (gen-temp-defs estate env)
		  (string-drop 2
			       (string-map
				(lambda (e)
				  (string-append
				   (if (rtx-env-empty? env) ", " "; ")
				   ; Strip off gratuitous ";\n" at end of expressions that
				   ; misguessed themselves to be in statement context.
				   ; See s-c-call, s-c-call-raw above.
				   (let ((substmt (rtl-c-with-estate estate DFLT e)))
				     (if (and (rtx-env-empty? env)
					      (string=? (string-take -2 substmt) ";\n"))
					 (string-drop -2 substmt)
					 substmt))))
				exprs))
		  (if (rtx-env-empty? env) ")" "; })")))))
)

; Return a <c-expr> node for a `do-count'.

(define (s-do-count estate iter-var nr-times . exprs)
  (let* ((limit-var (rtx-make-iteration-limit-var iter-var))
	 (env (rtx-env-make-iteration-locals iter-var))
	 (estate (estate-push-env estate env))
	 (temp-iter (rtx-temp-lookup (estate-env estate) iter-var))
	 (temp-limit (rtx-temp-lookup (estate-env estate) limit-var))
	 (c-iter-var (rtx-temp-value temp-iter))
	 (c-limit-var (rtx-temp-value temp-limit)))
    (cx:make VOID
	     (string-append
	      "{\n"
	      (gen-temp-defs estate env)
	      "  " c-limit-var " = "
	      (cx:c (rtl-c-get estate (rtx-temp-mode temp-limit) nr-times))
	      ";\n"
	      "  for (" c-iter-var " = 0;\n"
	      "       " c-iter-var " < " c-limit-var ";\n"
	      "       ++" c-iter-var ")\n"
	      "  {\n"
	      (string-map (lambda (e)
			    (rtl-c-with-estate estate DFLT e))
			  exprs)
	      "  }\n"
	      "}\n"))
    )
)

; *****************************************************************************
;
; RTL->C generators for each rtx function.

; Return code to set FN as the generator for RTX.

(defmacro define-fn (rtx args expr . rest)
  `(begin
     (assert (rtx-lookup (quote ,rtx)))
     (vector-set! table (rtx-num (rtx-lookup (quote ,rtx)))
		  (lambda ,args ,@(cons expr rest))))
)

(define (rtl-c-init!)
  (set! -rtl-c-gen-table (rtl-c-build-table))
  *UNSPECIFIED*
)

; The rest of this file is one big function to return the rtl->c lookup table.

(define (rtl-c-build-table)
  (let ((table (make-vector (rtx-max-num) #f)))

; Error generation

(define-fn error (estate options mode message)
  (let ((c-call (s-c-call estate mode "cgen_rtx_error"
			  (string-append "\""
					 (backslash "\"" message)
					 "\""))))
    (if (or (mode:eq? 'DFLT mode) (mode:eq? 'VOID mode))
	c-call
	(cx:make mode (string-append "(" (cx:c c-call) ", 0)"))))
)

; Enum support

(define-fn enum (estate options mode name)
  (cx:make mode (string-upcase (gen-c-symbol name)))
)

; Instruction field support.
; ??? This should build an operand object like -build-ifield-operand! does
; in semantics.scm.
; ??? Mode support is wip.

(define-fn ifield (estate options mode ifld-name)
  (if (estate-ifield-var? estate)
      (cx:make 'UINT (gen-c-symbol ifld-name))
      (cx:make 'UINT (string-append "FLD (" (gen-c-symbol ifld-name) ")")))
;  (let ((f (current-ifld-lookup ifld-name)))
;    (make <operand> (obj-location f) ifld-name ifld-name
;	  (atlist-cons (bool-attr-make 'SEM-ONLY #t)
;		       (obj-atlist f))
;	  (obj:name (ifld-hw-type f))
;	  (obj:name (ifld-mode f))
;	  (make <hw-index> 'anonymous
;		'ifield (ifld-mode f) f)
;	  nil #f #f))
)

; Operand support

(define-fn operand (estate options mode object-or-name)
  (cond ((operand? object-or-name)
	 object-or-name)
	((symbol? object-or-name)
	 (let ((object (current-op-lookup object-or-name)))
	   (if (not object)
	       (estate-error estate "undefined operand" object-or-name))
	   object))
	(else
	 (estate-error estate "bad arg to `operand'" object-or-name)))
)

(define-fn xop (estate options mode object) 
  (let ((delayed (assoc '#:delay (estate-modifiers estate))))
    (if (and delayed
	     (equal? APPLICATION 'SID-SIMULATOR)
	     (operand? object))
	;; if we're looking at an operand inside a (delay ...) rtx, then we
	;; are talking about a _delayed_ operand, which is a different
	;; beast.  rather than try to work out what context we were
	;; constructed within, we just clone the operand instance and set
	;; the new one to have a delayed value. the setters and getters
	;; will work it out.
	(let ((obj (object-copy object))
	      (amount (cadr delayed)))
	  (op:set-delay! obj amount)
	  obj)
	;; else return the normal object
	object)))

(define-fn local (estate options mode object-or-name)
  (cond ((rtx-temp? object-or-name)
	 object-or-name)
	((symbol? object-or-name)
	 (let ((object (rtx-temp-lookup (estate-env estate) object-or-name)))
	   (if (not object)
	       (estate-error estate "undefined local" object-or-name))
	   object))
	(else
	 (estate-error estate "bad arg to `local'" object-or-name)))
)

(define-fn reg (estate options mode hw-elm . indx-sel)
  (let ((indx (or (list-maybe-ref indx-sel 0) 0))
	(sel (or (list-maybe-ref indx-sel 1) hw-selector-default)))
    (s-hw estate mode hw-elm indx sel))
)

(define-fn raw-reg (estate options mode hw-elm . indx-sel)
  (let ((indx (or (list-maybe-ref indx-sel 0) 0))
	(sel (or (list-maybe-ref indx-sel 1) hw-selector-default)))
    (let ((result (s-hw estate mode hw-elm indx sel)))
      (obj-cons-attr! result (bool-attr-make 'RAW #t))
      result))
)

(define-fn mem (estate options mode addr . sel)
  (s-hw estate mode 'h-memory addr
	(if (pair? sel) (car sel) hw-selector-default))
)

(define-fn pc (estate options mode)
  s-pc
)

(define-fn ref (estate options mode name)
  (if (not (insn? (estate-owner estate)))
      (estate-error estate "ref: not processing an insn"
		    (obj:name (estate-owner estate))))
  (cx:make 'UINT
	   (string-append
	    "(referenced & (1 << "
	    (number->string
	     (op:num (insn-lookup-op (estate-owner estate) name)))
	    "))"))
)

; ??? Maybe this should return an operand object.
(define-fn index-of (estate options mode op)
  (send (op:index (rtx-eval-with-estate op 'DFLT estate)) 'cxmake-get estate 'DFLT)
)

(define-fn clobber (estate options mode object)
  (cx:make VOID "; /*clobber*/\n")
)

(define-fn delay (estate options mode num-node rtx)
  ;; FIXME: Try to move SID stuff into sid-foo.scm.
  (case APPLICATION
    ((SID-SIMULATOR)
     (let* ((n (cadddr num-node))
	    (old-delay (let ((old (assoc '#:delay (estate-modifiers estate))))
			 (if old (cadr old) 0)))
	    (new-delay (+ n old-delay)))    
       (begin
	 ;; check for proper usage
     	 (if (let* ((hw (case (car rtx) 
			  ((operand) (op:type (rtx-operand-obj rtx)))
			  ((xop) (op:type (rtx-xop-obj rtx)))
			  (else #f))))		    	       
	       (not (and hw (or (pc? hw) (memory? hw) (register? hw)))))
	     (estate-error 
	      estate
	      "(delay ...) rtx applied to wrong type of operand, should be pc, register or memory"
	       (car rtx)))
	 ;; signal an error if we're delayed and not in a "parallel-insns" CPU
	 (if (not (with-parallel?)) 
	     (estate-error estate "delayed operand in a non-parallel cpu"
			   (car rtx)))
	 ;; update cpu-global pipeline bound
	 (cpu-set-max-delay! (current-cpu) (max (cpu-max-delay (current-cpu)) new-delay))      
	 ;; pass along new delay to embedded rtx
	 (rtx-eval-with-estate rtx mode (estate-with-modifiers estate `((#:delay ,new-delay)))))))

    ;; not in sid-land
    (else (s-sequence (estate-with-modifiers estate '((#:delay))) VOID '() rtx)))
)

; Gets expanded as a macro.
;(define-fn annul (estate yes?)
;  (s-c-call estate 'VOID "SEM_ANNUL_INSN" "pc" yes?)
;)

(define-fn skip (estate options mode yes?)
  (send pc 'cxmake-skip estate yes?)
  ;(s-c-call estate 'VOID "SEM_SKIP_INSN" "pc" yes?)
)

(define-fn eq-attr (estate options mode obj attr-name value)
  (cx:make 'INT
	   (string-append "(GET_ATTR ("
			  (gen-c-symbol attr-name)
			  ") == "
			  (gen-c-symbol value)
			  ")"))
)

(define-fn attr (estate options mode owner attr-name)
  (cond ((equal? owner '(current-insn () DFLT))
	 (s-c-raw-call estate 'INT "GET_ATTR"
		       (string-upcase (gen-c-symbol attr-name))))
	(else
	 (estate-error estate "attr: unsupported object type:" owner)))
)

(define-fn const (estate options mode c)
  (assert (not (mode:eq? 'VOID mode)))
  (if (mode:eq? 'DFLT mode)
      (set! mode 'INT))
  (let ((mode (mode:lookup mode)))
    (cx:make mode
	     (cond ((or (mode:eq? 'DI mode)
			(mode:eq? 'UDI mode)
			(< #xffffffff c)
			(> #x-80000000 c))
		    (string-append "MAKEDI ("
				   (gen-integer (high-part c)) ", "
				   (gen-integer (low-part c))
				   ")"))
		   ((and (<= #x-80000000 c) (> #x80000000 c))
		    (number->string c))
		   ((and (<= #x80000000 c) (>= #xffffffff c))
		    ; ??? GCC complains if not affixed with "U" but that's not k&r.
		    ;(string-append (number->string val) "U"))
		    (string-append "0x" (number->string c 16)))
		   ; Else punt.
		   (else (number->string c)))))
)

(define-fn join (estate options out-mode in-mode arg1 . arg-rest)
  ; FIXME: Endianness issues undecided.
  ; FIXME: Ensure correct number of args for in/out modes.
  ; Ensure compatible modes.
  (apply s-c-raw-call (cons estate
			    (cons out-mode
				  (cons (stringsym-append "JOIN"
							  in-mode
							  out-mode)
					(cons arg1 arg-rest)))))
)

(define-fn subword (estate options mode value word-num)
  (let* ((mode (mode:lookup mode))
	 (val (rtl-c-get estate DFLT value))
	 ; Refetch mode in case it was DFLT.
	 (val-mode (cx:mode val)))
    (cx:make mode
	     (string-append "SUBWORD"
			    (obj:str-name val-mode) (obj:str-name mode)
			    " (" (cx:c val)
			    (if (mode-bigger? val-mode mode)
				(string-append
				 ", "
				 (if (number? word-num)
				     (number->string word-num)
				     (cx:c (rtl-c-get estate DFLT word-num))))
				"")
			    ")")))
)

(define-fn c-code (estate options mode text)
  (cx:make mode text)
)

(define-fn c-call (estate options mode name . args)
  (apply s-c-call (cons estate (cons mode (cons name args))))
)

(define-fn c-raw-call (estate options mode name . args)
  (apply s-c-raw-call (cons estate (cons mode (cons name args))))
)

(define-fn nop (estate options mode)
  (cx:make VOID "((void) 0); /*nop*/\n")
)

(define-fn set (estate options mode dst src)
  (if (insn? (estate-owner estate))
      (rtl-c-set-trace estate mode dst (rtl-c-get estate mode src))
      (rtl-c-set-quiet estate mode dst (rtl-c-get estate mode src)))
)

(define-fn set-quiet (estate options mode dst src)
  (rtl-c-set-quiet estate mode dst (rtl-c-get estate mode src))
)

(define-fn neg (estate options mode s1)
  (s-unop estate "NEG" "-" mode s1)
)

(define-fn abs (estate options mode s1)
  (s-unop estate "ABS" #f mode s1)
)

(define-fn inv (estate options mode s1)
  (s-unop estate "INV" "~" mode s1)
)

(define-fn not (estate options mode s1)
  (s-unop estate "NOT" "!" mode s1)
)

(define-fn add (estate options mode s1 s2)
  (s-binop estate "ADD" "+" mode s1 s2)
)
(define-fn sub (estate options mode s1 s2)
  (s-binop estate "SUB" "-" mode s1 s2)
)

(define-fn addc (estate options mode s1 s2 s3)
  (s-binop-with-bit estate "ADDC" mode s1 s2 s3)
)
;; ??? Whether to rename ADDCF/ADDOF -> ADDCCF/ADDCOF is debatable.
(define-fn addc-cflag (estate options mode s1 s2 s3)
  (s-binop-with-bit estate "ADDCF" mode s1 s2 s3)
)
(define-fn addc-oflag (estate options mode s1 s2 s3)
  (s-binop-with-bit estate "ADDOF" mode s1 s2 s3)
)

(define-fn subc (estate options mode s1 s2 s3)
  (s-binop-with-bit estate "SUBC" mode s1 s2 s3)
)
;; ??? Whether to rename SUBCF/SUBOF -> SUBCCF/SUBCOF is debatable.
(define-fn subc-cflag (estate options mode s1 s2 s3)
  (s-binop-with-bit estate "SUBCF" mode s1 s2 s3)
)
(define-fn subc-oflag (estate options mode s1 s2 s3)
  (s-binop-with-bit estate "SUBOF" mode s1 s2 s3)
)

;; ??? These are deprecated.  Delete in time.
(define-fn add-cflag (estate options mode s1 s2 s3)
  (s-binop-with-bit estate "ADDCF" mode s1 s2 s3)
)
(define-fn add-oflag (estate options mode s1 s2 s3)
  (s-binop-with-bit estate "ADDOF" mode s1 s2 s3)
)
(define-fn sub-cflag (estate options mode s1 s2 s3)
  (s-binop-with-bit estate "SUBCF" mode s1 s2 s3)
)
(define-fn sub-oflag (estate options mode s1 s2 s3)
  (s-binop-with-bit estate "SUBOF" mode s1 s2 s3)
)

;(define-fn zflag (estate options mode value)
;  (list 'eq mode value (list 'const mode 0))
;)

;(define-fn nflag (estate options mode value)
;  (list 'lt mode value (list 'const mode 0))
;)

(define-fn mul (estate options mode s1 s2)
  (s-binop estate "MUL" "*" mode s1 s2)
)
(define-fn div (estate options mode s1 s2)
  (s-binop estate "DIV" "/" mode s1 s2)
)
(define-fn udiv (estate options mode s1 s2)
  (s-binop estate "UDIV" "/" mode s1 s2)
)
(define-fn mod (estate options mode s1 s2)
  (s-binop estate "MOD" "%" mode s1 s2)
)
(define-fn umod (estate options mode s1 s2)
  (s-binop estate "UMOD" "%" mode s1 s2)
)

(define-fn sqrt (estate options mode s1)
  (s-unop estate "SQRT" #f mode s1)
)
(define-fn cos (estate options mode s1)
  (s-unop estate "COS" #f mode s1)
)
(define-fn sin (estate options mode s1)
  (s-unop estate "SIN" #f mode s1)
)

(define-fn min (estate options mode s1 s2)
  (s-binop estate "MIN" #f mode s1 s2)
)
(define-fn max (estate options mode s1 s2)
  (s-binop estate "MAX" #f mode s1 s2)
)
(define-fn umin (estate options mode s1 s2)
  (s-binop estate "UMIN" #f mode s1 s2)
)
(define-fn umax (estate options mode s1 s2)
  (s-binop estate "UMAX" #f mode s1 s2)
)

(define-fn and (estate options mode s1 s2)
  (s-binop estate "AND" "&" mode s1 s2)
)
(define-fn or (estate options mode s1 s2)
  (s-binop estate "OR" "|" mode s1 s2)
)
(define-fn xor (estate options mode s1 s2)
  (s-binop estate "XOR" "^" mode s1 s2)
)

(define-fn sll (estate options mode s1 s2)
  (s-shop estate "SLL" "<<" mode s1 s2)
)
(define-fn srl (estate options mode s1 s2)
  (s-shop estate "SRL" ">>" mode s1 s2)
)
(define-fn sra (estate options mode s1 s2)
  (s-shop estate "SRA" ">>" mode s1 s2)
)
(define-fn ror (estate options mode s1 s2)
  (s-shop estate "ROR" #f mode s1 s2)
)
(define-fn rol (estate options mode s1 s2)
  (s-shop estate "ROL" #f mode s1 s2)
)

(define-fn andif (estate options mode s1 s2)
  (s-boolifop estate "ANDIF" "&&" s1 s2)
)
(define-fn orif (estate options mode s1 s2)
  (s-boolifop estate "ORIF" "||" s1 s2)
)

(define-fn ext (estate options mode s1)
  (s-convop estate "EXT" mode s1)
)
(define-fn zext (estate options mode s1)
  (s-convop estate "ZEXT" mode s1)
)
(define-fn trunc (estate options mode s1)
  (s-convop estate "TRUNC" mode s1)
)
(define-fn fext (estate options mode s1)
  (s-convop estate "FEXT" mode s1)
)
(define-fn ftrunc (estate options mode s1)
  (s-convop estate "FTRUNC" mode s1)
)
(define-fn float (estate options mode s1)
  (s-convop estate "FLOAT" mode s1)
)
(define-fn ufloat (estate options mode s1)
  (s-convop estate "UFLOAT" mode s1)
)
(define-fn fix (estate options mode s1)
  (s-convop estate "FIX" mode s1)
)
(define-fn ufix (estate options mode s1)
  (s-convop estate "UFIX" mode s1)
)

(define-fn eq (estate options mode s1 s2)
  (s-cmpop estate 'eq "==" mode s1 s2)
)
(define-fn ne (estate options mode s1 s2)
  (s-cmpop estate 'ne "!=" mode s1 s2)
)

(define-fn lt (estate options mode s1 s2)
  (s-cmpop estate 'lt "<" mode s1 s2)
)
(define-fn le (estate options mode s1 s2)
  (s-cmpop estate 'le "<=" mode s1 s2)
)
(define-fn gt (estate options mode s1 s2)
  (s-cmpop estate 'gt ">" mode s1 s2)
)
(define-fn ge (estate options mode s1 s2)
  (s-cmpop estate 'ge ">=" mode s1 s2)
)

(define-fn ltu (estate options mode s1 s2)
  (s-cmpop estate 'ltu "<" mode s1 s2)
)
(define-fn leu (estate options mode s1 s2)
  (s-cmpop estate 'leu "<=" mode s1 s2)
)
(define-fn gtu (estate options mode s1 s2)
  (s-cmpop estate 'gtu ">" mode s1 s2)
)
(define-fn geu (estate options mode s1 s2)
  (s-cmpop estate 'geu ">=" mode s1 s2)
)

(define-fn member (estate options mode value set)
  ; FIXME: Multiple evalutions of VALUE.
  (let ((c-value (rtl-c-get estate 'DFLT value))
	(set (rtx-number-list-values set)))
    (let loop ((set (cdr set))
	       (code (string-append "(" (cx:c c-value)
				    " == "
				    (gen-integer (car set))
				    ")")))
      (if (null? set)
	  (cx:make (mode:lookup 'BI) (string-append "(" code ")"))
	  (loop (cdr set)
		(string-append code
			       " || ("
			       (cx:c c-value)
			       " == "
			       (gen-integer (car set))
			       ")")))))
)

(define-fn if (estate options mode cond then . else)
  (apply s-if (append! (list estate mode cond then) else))
)

(define-fn cond (estate options mode . cond-code-list)
  (apply s-cond (cons estate (cons mode cond-code-list)))
)

(define-fn case (estate options mode test . case-list)
  (apply s-case (cons estate (cons mode (cons test case-list))))
)

(define-fn parallel (estate options mode ignore expr . exprs)
  (apply s-parallel (cons estate (cons expr exprs)))
)

(define-fn sequence (estate options mode locals expr . exprs)
  (apply s-sequence
	 (cons estate (cons mode (cons locals (cons expr exprs)))))
)

(define-fn do-count (estate options mode iter-var nr-times expr . exprs)
  (apply s-do-count
	 (cons estate (cons iter-var (cons nr-times (cons expr exprs)))))
)

(define-fn closure (estate options mode expr env)
  ; ??? estate-push-env?
  (rtl-c-with-estate (estate-new-env estate env) DFLT expr)
)

; The result is the rtl->c generator table.

table

)) ; End of rtl-c-build-table
