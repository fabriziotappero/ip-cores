; Simulator generator support routines.
; Copyright (C) 2000, 2001, 2002, 2006, 2009 Red Hat, Inc.
; This file is part of CGEN.

; One goal of this file is to provide cover functions for all methods.
; i.e. this file fills in the missing pieces of the interface between
; the application independent part of CGEN (i.e. the code loaded by read.scm)
; and the application dependent part (i.e. sim-*.scm).
; `send' is not intended to appear in sim-*.scm.
; [It still does but that's to be fixed.]

; Specify which application.
(set! APPLICATION 'SIMULATOR)

; Cover functions for various methods.

; Return the C type of something.  This isn't always a mode.

(define (gen-type self) (send self 'gen-type))

; Return the C type of an index's value or #f if not needed (scalar).

(define (gen-index-type op sfmt)
  (let ((index-mode (send op 'get-index-mode)))
    (if index-mode
	(mode:c-type index-mode)
	#f))
)

; Misc. state info.

; Currently supported options:
; with-scache
;	generate code to use the scache
;	This is an all or nothing option, either scache is used or it's not.
; with-profile fn|sw
;	generate code to do profiling in the semantic function
;	code (fn) or in the semantic switch (sw)
; with-generic-write
;	For architectures that have parallel execution.
;	Execute the semantics by recording the results in a generic buffer,
;	and doing a post-semantics writeback pass.
; with-parallel-only
;	Only generate parallel versions of each insn.
; with-multiple-isa
;	Enable multiple-isa support (eg. arm+thumb).
; copyright fsf|redhat
;	emit an FSF or Cygnus copyright (temporary, pending decision)
; package gnusim|cygsim
;	indicate the software package

; #t if the scache is being used
(define -with-scache? #f)
(define (with-scache?) -with-scache?)

; #t if we're generating profiling code
; Each of the function and switch semantic code can have profiling.
; The options as passed are stored in -with-profile-{fn,sw}?, and
; -with-profile? is set at code generation time.
(define -with-profile-fn? #f)
(define -with-profile-sw? #f)
(define -with-profile? #f)
(define (with-profile?) -with-profile?)
(define (with-any-profile?) (or -with-profile-fn? -with-profile-sw?))

; #t if multiple isa support is enabled
(define -with-multiple-isa? #f)
(define (with-multiple-isa?) -with-multiple-isa?)

; Handle parallel execution with generic writeback pass.
(define -with-generic-write? #f)
(define (with-generic-write?) -with-generic-write?)

; Only generate parallel versions of each insn.
(define -with-parallel-only? #f)
(define (with-parallel-only?) -with-parallel-only?)

; String containing copyright text.
(define CURRENT-COPYRIGHT #f)

; String containing text defining the package we're generating code for.
(define CURRENT-PACKAGE #f)

; Initialize the options.

(define (option-init!)
  (set! -with-scache? #f)
  (set! -with-profile-fn? #f)
  (set! -with-profile-sw? #f)
  (set! -with-multiple-isa? #f)
  (set! -with-generic-write? #f)
  (set! -with-parallel-only? #f)
  (set! CURRENT-COPYRIGHT copyright-fsf)
  (set! CURRENT-PACKAGE package-gnu-simulators)
  *UNSPECIFIED*
)

; Handle an option passed in from the command line.

(define (option-set! name value)
  (case name
    ((with-scache) (set! -with-scache? #t))
    ((with-profile) (cond ((equal? value '("fn"))
			   (set! -with-profile-fn? #t))
			  ((equal? value '("sw"))
			   (set! -with-profile-sw? #t))
			  (else (error "invalid with-profile value" value))))
    ((with-multiple-isa) (set! -with-multiple-isa? #t))
    ((with-generic-write) (set! -with-generic-write? #t))
    ((with-parallel-only) (set! -with-parallel-only? #t))
    ((copyright) (cond ((equal?  value '("fsf"))
			(set! CURRENT-COPYRIGHT copyright-fsf))
		       ((equal? value '("redhat"))
			(set! CURRENT-COPYRIGHT copyright-red-hat))
		       (else (error "invalid copyright value" value))))
    ((package) (cond ((equal?  value '("gnusim"))
		      (set! CURRENT-PACKAGE package-gnu-simulators))
		     ((equal? value '("cygsim"))
		      (set! CURRENT-PACKAGE package-red-hat-simulators))
		     (else (error "invalid package value" value))))
    (else (error "unknown option" name))
    )
  *UNSPECIFIED*
)

; #t if the cpu can execute insns parallely.
; This one isn't passed on the command line, but we follow the convention
; of prefixing these things with `with-'.
; While processing operand reading (or writing), parallel execution support
; needs to be turned off, so it is up to the appropriate cgen-foo.c proc to
; set-with-parallel?! appropriately.
(define -with-parallel? #f)
(define (with-parallel?) -with-parallel?)
(define (set-with-parallel?! flag) (set! -with-parallel? flag))

; Kind of parallel support.
; If 'read, read pre-processing is done.
; If 'write, write post-processing is done.
; ??? At present we always use write post-processing, though the previous
; version used read pre-processing.  Not sure supporting both is useful
; in the long run.
(define -with-parallel-kind 'write)
; #t if parallel support is provided by read pre-processing.
(define (with-parallel-read?)
  (and -with-parallel? (eq? -with-parallel-kind 'read))
)
; #t if parallel support is provided by write post-processing.
(define (with-parallel-write?)
  (and -with-parallel? (eq? -with-parallel-kind 'write))
)

; Misc. utilities.

; All machine generated cpu elements are accessed through a cover macro
; to hide the details of the underlying implementation.

(define c-cpu-macro "CPU")

(define (gen-cpu-ref sym)
  (string-append c-cpu-macro " (" sym ")")
)


; Return C code to fetch a value from instruction memory.
; PC-VAR is the C expression containing the address of the start of the
; instruction.
; ??? Aligned/unaligned support?

(define (gen-ifetch pc-var bitoffset bitsize)
  (string-append "GETIMEM"
		 (case bitsize
		   ((8) "UQI")
		   ((16) "UHI")
		   ((32) "USI")
		   (else (error "bad bitsize argument to gen-ifetch" bitsize)))
		 " (current_cpu, "
		 pc-var " + " (number->string (quotient bitoffset 8))
		 ")")
)

; Instruction field support code.

; Return a <c-expr> object of the value of an ifield.

(define (-cxmake-ifld-val mode f)
  (if (with-scache?)
      ; ??? Perhaps a better way would be to defer evaluating the src of a
      ; set until the method processing the dest.
      (cx:make-with-atlist mode (gen-ifld-argbuf-ref f)
			   (atlist-make "" (bool-attr-make 'CACHED #t)))
      (cx:make mode (gen-extracted-ifld-value f)))
)

; Type system.

; Methods:
; gen-type - return C code representing the type
; gen-sym-decl - generate decl using the provided symbol
; gen-sym-get-macro - generate GET macro for accessing CPU elements
; gen-sym-set-macro - generate SET macro for accessing CPU elements

; Scalar type

(method-make!
 <scalar> 'gen-type
 (lambda (self) (mode:c-type (elm-get self 'mode)))
)

(method-make!
 <scalar> 'gen-sym-decl
 (lambda (self sym comment)
   (string-append
    "  /* " comment " */\n"
    "  " (send self 'gen-type) " "
    (gen-c-symbol sym) ";\n"))
)

(method-make!
 <scalar> 'gen-sym-get-macro
 (lambda (self sym comment)
   (let ((sym (gen-c-symbol sym)))
     (gen-get-macro sym "" (gen-cpu-ref sym))))
)

(method-make!
 <scalar> 'gen-sym-set-macro
 (lambda (self sym comment)
   (let ((sym (gen-c-symbol sym)))
     (gen-set-macro sym "" (gen-cpu-ref sym))))
)

(method-make! <scalar> 'gen-ref (lambda (self sym index estate) sym))

; Array type

(method-make!
 <array> 'gen-type
 (lambda (self) (mode:c-type (elm-get self 'mode)))
)

(method-make!
 <array> 'gen-sym-decl
 (lambda (self sym comment)
   (string-append
    "  /* " comment " */\n"
    "  " (send self 'gen-type) " "
    (gen-c-symbol sym)
    (gen-array-ref (elm-get self 'dimensions))
    ";\n")
   )
)

(method-make!
 <array> 'gen-sym-get-macro
 (lambda (self sym comment)
   (let ((sym (gen-c-symbol sym))
	 (rank (length (elm-get self 'dimensions))))
     (string-append
      "#define GET_" (string-upcase sym)
      "(" (string-drop 2 (gen-macro-args rank)) ") "
      (gen-cpu-ref sym) (gen-array-ref (macro-args rank)) "\n"
      )))
)

(method-make!
 <array> 'gen-sym-set-macro
 (lambda (self sym comment)
   (let ((sym (gen-c-symbol sym))
	 (rank (length (elm-get self 'dimensions))))
     (string-append
      "#define SET_" (string-upcase sym)
      "(" (string-drop 2 (gen-macro-args rank)) ", x) "
      "(" (gen-cpu-ref sym) (gen-array-ref (macro-args rank))
      " = (x))\n"
      )))
)

; Return a reference to the array.
; SYM is the name of the array.
; INDEX is either a single index object or a (possibly empty) list of objects,
; one object per dimension.

(method-make!
 <array> 'gen-ref
 (lambda (self sym index estate)
   (let ((gen-index1 (lambda (idx)
		       (string-append "["
				      (-gen-hw-index idx estate)
				      "]"))))
     (string-append sym
		    (cond ((list? index) (string-map gen-index1 index))
			  (else (gen-index1 index))))))
)

; Integers
;
;(method-make!
; <integer> 'gen-type
; (lambda (self)
;   (mode:c-type (mode-find (elm-get self 'bits)
;			   (if (has-attr? self 'UNSIGNED)
;			       'UINT 'INT)))
;   )
;)
;
;(method-make! <integer> 'gen-sym-decl (lambda (self sym comment) ""))
;(method-make! <integer> 'gen-sym-get-macro (lambda (self sym comment) ""))
;(method-make! <integer> 'gen-sym-set-macro (lambda (self sym comment) ""))

; Hardware descriptions support code.
;
; Various operations are required for each h/w object to support the various
; things the simulator will want to do with it.
;
; Methods:
; gen-decl
; gen-get-macro - Generate definition of the GET access macro.
; gen-set-macro - Generate definition of the SET access macro.
; gen-write     - Same as gen-read except done on output operands
; cxmake-get    - Return a <c-expr> object to fetch the value.
; gen-set-quiet - Set the value.
;                 ??? Could just call this gen-set as there is no gen-set-trace
;                 but for consistency with the messages passed to operands
;                 we use this same.
; gen-type      - C type to use to record value, as a string.
;                 ??? Delete and just use get-mode?
; save-index?   - return #t if an index needs to be saved for parallel
;                 execution post-write processing
; gen-profile-decl
; gen-record-profile
; get-mode
; gen-profile-locals
; gen-sym-decl  - Return a C declaration using the provided symbol.
; gen-sym-get-macro - Generate default GET access macro.
; gen-sym-set-macro - Generate default SET access macro.
; gen-ref       - Return a C reference to the object.

; Generate CPU state struct entries.

(method-make!
 <hardware-base> 'gen-decl
 (lambda (self)
   (send self 'gen-sym-decl (obj:name self) (obj:comment self)))
)

(method-make-virtual! <hardware-base> 'gen-sym-decl (lambda (self sym comment) ""))

; Return a C reference to a hardware object.

(method-make! <hardware-base> 'gen-ref (lambda (self sym index estate) sym))

; Each hardware type must provide its own gen-write method.

(method-make!
 <hardware-base> 'gen-write
 (lambda (self estate index mode sfmt op access-macro)
   (error "gen-write method not overridden:" self))
)

; gen-type handler, must be overridden

(method-make-virtual!
 <hardware-base> 'gen-type
 (lambda (self) (error "gen-type not overridden:" self))
)

(method-make! <hardware-base> 'gen-profile-decl (lambda (self) ""))

; Default gen-record-profile method.

(method-make!
 <hardware-base> 'gen-record-profile
 (lambda (self index sfmt estate)
   "") ; nothing to do
)

; Default cxmake-get method.
; Return a <c-expr> object of the value of SELF.
; ESTATE is the current rtl evaluator state.
; INDEX is a <hw-index> object.  It must be an ifield.
; SELECTOR is a hardware selector RTX.

(method-make!
 <hardware-base> 'cxmake-get
 (lambda (self estate mode index selector)
   (if (not (eq? 'ifield (hw-index:type index)))
       (error "not an ifield hw-index" index))
   (-cxmake-ifld-val mode (hw-index:value index)))
)

; Handle gen-get-macro/gen-set-macro.

(method-make!
 <hardware-base> 'gen-get-macro
 (lambda (self)
   "")
)

(method-make!
 <hardware-base> 'gen-set-macro
 (lambda (self)
   "")
)

; PC support

; 'gen-set-quiet helper for PC values.
; NEWVAL is a <c-expr> object of the value to be assigned.
; If OPTIONS contains #:direct, set the PC directly, bypassing semantic
; code considerations.
; ??? OPTIONS support wip.  Probably want a new form (or extend existing form)
; of rtx: that takes a variable number of named arguments.
; ??? Another way to get #:direct might be (raw-reg h-pc).

(define (-hw-gen-set-quiet-pc self estate mode index selector newval . options)
  (if (not (send self 'pc?)) (error "Not a PC:" self))
  (cond ((memq #:direct options)
	 (-hw-gen-set-quiet self estate mode index selector newval))
	((has-attr? newval 'CACHED)
	 (string-append "SEM_BRANCH_VIA_CACHE (current_cpu, sem_arg, "
			(cx:c newval)
			", vpc);\n"))
	(else
	 (string-append "SEM_BRANCH_VIA_ADDR (current_cpu, sem_arg, "
			(cx:c newval)
			", vpc);\n")))
)

(method-make! <hw-pc> 'gen-set-quiet -hw-gen-set-quiet-pc)

; Handle updates of the pc during parallel execution.
; This is done in a post-processing pass after semantic evaluation.
; SFMT is the <sformat>.
; OP is the operand.
; ACCESS-MACRO is the runtime C macro to use to fetch indices computed
; during semantic evaluation.
;
; ??? This wouldn't be necessary if gen-set-quiet were a virtual method.
; At this point I'm reluctant to willy nilly make methods virtual.

(method-make!
 <hw-pc> 'gen-write
 (lambda (self estate index mode sfmt op access-macro)
   (string-append "  "
		  (send self 'gen-set-quiet estate VOID index hw-selector-default
			(cx:make DFLT (string-append access-macro
						   " (" (gen-sym op) ")")))))
)

(method-make!
 <hw-pc> 'cxmake-skip
 (lambda (self estate yes?)
   (cx:make VOID
	    (string-append "if ("
			   yes?
			   ")\n"
			   "  SEM_SKIP_INSN (current_cpu, sem_arg, vpc);\n")))
)

; Registers.

; Forward these methods onto TYPE.
(method-make-virtual-forward! <hw-register> 'type '(gen-type gen-sym-decl))
(method-make-forward! <hw-register> 'type '(gen-ref
					    gen-sym-get-macro
					    gen-sym-set-macro))

; For parallel instructions supported by queueing outputs for later update,
; return a boolean indicating if an index needs to be recorded.
; An example of when the index isn't needed is if the index can be determined
; during extraction.

(method-make!
 <hw-register> 'save-index?
 (lambda (self op)
   ; FIXME: Later handle case where register number is determined at runtime.
   #f)
)

; Handle updates of registers during parallel execution.
; This is done in a post-processing pass after semantic evaluation.
; SFMT is the <sformat>.
; OP is the <operand>.
; ACCESS-MACRO is the runtime C macro to use to fetch indices computed
; during semantic evaluation.
; FIXME: May need mode of OP.

(method-make!
 <hw-register> 'gen-write
 (lambda (self estate index mode sfmt op access-macro)
   ; First get a hw-index object to use during indexing.
   ; Some indices, e.g. memory addresses, are computed during semantic
   ; evaluation.  Others are computed during the extraction phase.
   (let ((index (send index 'get-write-index self sfmt op access-macro)))
     (string-append "  "
		    (send self 'gen-set-quiet estate mode index hw-selector-default
			  (cx:make DFLT (string-append access-macro
						     " (" (gen-sym op) ")"))))))
)

(method-make!
 <hw-register> 'gen-profile-decl
 (lambda (self)
   (string-append
    "  /* " (obj:comment self) " */\n"
    "  unsigned long " (gen-c-symbol (obj:name self)) ";\n"))
)

(method-make!
 <hw-register> 'gen-record-profile
 (lambda (self index sfmt estate)
   ; FIXME: Need to handle scalars.
   (-gen-hw-index-raw index estate))
)

(method-make!
 <hw-register> 'gen-get-macro
 (lambda (self)
   (let ((getter (elm-get self 'get))
	 (mode (send self 'get-mode)))
     (if getter
	 (let ((args (car getter))
	       (expr (cadr getter)))
	   (gen-get-macro (gen-sym self)
			  (if (hw-scalar? self) "" "index")
			  (rtl-c mode expr
				 (if (hw-scalar? self)
				     nil
				     (list (list (car args) 'UINT "index")))
				 #:rtl-cover-fns? #t)))
	 (send self 'gen-sym-get-macro
	       (obj:name self) (obj:comment self)))))
)

(method-make!
 <hw-register> 'gen-set-macro
 (lambda (self)
   (let ((setter (elm-get self 'set))
	 (mode (send self 'get-mode)))
     (if setter
	 (let ((args (car setter))
	       (expr (cadr setter)))
	   (gen-set-macro2 (gen-sym self)
			   (if (hw-scalar? self)
			       ""
			       "index")
			   "x"
			   (rtl-c VOID ; not `mode', sets have mode VOID
				  expr
				  (if (hw-scalar? self)
				      (list (list (car args) (hw-mode self) "(x)"))
				      (list (list (car args) 'UINT "(index)")
					    (list (cadr args) (hw-mode self) "(x)")))
				  #:rtl-cover-fns? #t #:macro? #t)))
	 (send self 'gen-sym-set-macro
	       (obj:name self) (obj:comment self)))))
)

; Utility to build a <c-expr> object to fetch the value of a register.

(define (-hw-cxmake-get hw estate mode index selector)
  (let ((mode (if (mode:eq? 'DFLT mode)
		  (send hw 'get-mode)
		  mode))
	(getter (hw-getter hw)))
    ; If the register is accessed via a cover function/macro, do it.
    ; Otherwise fetch the value from the cached address or from the CPU struct.
    (cx:make mode
	     (cond (getter
		    (let ((scalar? (hw-scalar? hw))
			  (c-index (-gen-hw-index index estate)))
		      (string-append "GET_"
				     (string-upcase (gen-sym hw))
				     " ("
				     (if scalar? "" c-index)
				     ")")))
		   ((and (hw-cache-addr? hw) ; FIXME: redo test
			 (eq? 'ifield (hw-index:type index)))
		    (string-append
		     "* "
		     (if (with-scache?)
			 (gen-hw-index-argbuf-ref index)
			 (gen-hw-index-argbuf-name index))))
		   (else (gen-cpu-ref (send hw 'gen-ref
					    (gen-sym hw) index estate))))))
)

(method-make! <hw-register> 'cxmake-get -hw-cxmake-get)

; raw-reg: support
; ??? raw-reg: support is wip

(method-make!
 <hw-register> 'cxmake-get-raw
 (lambda (self estate mode index selector)
  (let ((mode (if (mode:eq? 'DFLT mode)
		  (send self 'get-mode)
		  mode)))
    (cx:make mode (gen-cpu-ref (send self 'gen-ref
				     (gen-sym self) index estate)))))
)

; Utilities to generate C code to assign a variable to a register.

(define (-hw-gen-set-quiet hw estate mode index selector newval)
  (let ((setter (hw-setter hw)))
    (cond (setter
	   (let ((scalar? (hw-scalar? hw))
		 (c-index (-gen-hw-index index estate)))
	     (string-append "SET_"
			    (string-upcase (gen-sym hw))
			    " ("
			    (if scalar? "" (string-append c-index ", "))
			    (cx:c newval)
			    ");\n")))
	  ((and (hw-cache-addr? hw) ; FIXME: redo test
		(eq? 'ifield (hw-index:type index)))
	   (string-append "* "
			  (if (with-scache?)
			      (gen-hw-index-argbuf-ref index)
			      (gen-hw-index-argbuf-name index))
			  " = " (cx:c newval) ";\n"))
	  (else (string-append (gen-cpu-ref (send hw 'gen-ref
						  (gen-sym hw) index estate))
			       " = " (cx:c newval) ";\n"))))
)

(method-make! <hw-register> 'gen-set-quiet -hw-gen-set-quiet)

; raw-reg: support
; ??? wip

(method-make!
 <hw-register> 'gen-set-quiet-raw
 (lambda (self estate mode index selector newval)
   (string-append (gen-cpu-ref (send self 'gen-ref
				     (gen-sym self) index estate))
		  " = " (cx:c newval) ";\n"))
)

; Return name of C access function for getting/setting a register.

(define (gen-reg-getter-fn hw prefix)
  (string-append prefix "_" (gen-sym hw) "_get")
)

(define (gen-reg-setter-fn hw prefix)
  (string-append prefix "_" (gen-sym hw) "_set")
)

; Generate decls for access fns of register HW, beginning with
; PREFIX, using C type TYPE.
; SCALAR? is #t if the register is a scalar.  Otherwise it is #f and the
; register is a bank of registers.

(define (gen-reg-access-decl hw prefix type scalar?)
  (string-append
   type " "
   (gen-reg-getter-fn hw prefix)
   " (SIM_CPU *"
   (if scalar? "" ", UINT")
   ");\n"
   "void "
   (gen-reg-setter-fn hw prefix)
   " (SIM_CPU *, "
   (if scalar? "" "UINT, ")
   type ");\n"
   )
)

; Generate defns of access fns of register HW, beginning with
; PREFIX, using C type TYPE.
; SCALAR? is #t if the register is a scalar.  Otherwise it is #f and the
; register is a bank of registers.
; GET/SET-CODE are C fragments to get/set the value.
; ??? Inlining left for later.

(define (gen-reg-access-defn hw prefix type scalar? get-code set-code)
  (string-append
   "/* Get the value of " (obj:str-name hw) ".  */\n\n"
   type "\n"
   (gen-reg-getter-fn hw prefix)
   " (SIM_CPU *current_cpu"
   (if scalar? "" ", UINT regno")
   ")\n{\n"
   get-code
   "}\n\n"
   "/* Set a value for " (obj:str-name hw) ".  */\n\n"
   "void\n"
   (gen-reg-setter-fn hw prefix)
   " (SIM_CPU *current_cpu, "
   (if scalar? "" "UINT regno, ")
   type " newval)\n"
   "{\n"
   set-code
   "}\n\n")
)

; Memory support.

(method-make!
 <hw-memory> 'cxmake-get
 (lambda (self estate mode index selector)
   (let ((mode (if (mode:eq? 'DFLT mode)
		   (hw-mode self)
		   mode))
	 (default-selector? (hw-selector-default? selector)))
     (cx:make mode
	      (string-append "GETMEM" (obj:str-name mode)
			     (if default-selector? "" "ASI")
			     " ("
			     "current_cpu, pc, "
			     (-gen-hw-index index estate)
			     (if default-selector?
				 ""
				 (string-append ", "
						(-gen-hw-selector selector)))
			     ")"))))
)

(method-make!
 <hw-memory> 'gen-set-quiet
 (lambda (self estate mode index selector newval)
   (let ((mode (if (mode:eq? 'DFLT mode)
		   (hw-mode self)
		   mode))
	 (default-selector? (hw-selector-default? selector)))
     (string-append "SETMEM" (obj:str-name mode)
		    (if default-selector? "" "ASI")
		    " ("
		    "current_cpu, pc, "
		    (-gen-hw-index index estate)
		    (if default-selector?
			""
			(string-append ", "
				       (-gen-hw-selector selector)))
		    ", " (cx:c newval) ");\n")))
)

(method-make-virtual-forward! <hw-memory> 'type '(gen-type))
(method-make-virtual! <hw-memory> 'gen-sym-decl (lambda (self sym comment) ""))
(method-make! <hw-memory> 'gen-sym-get-macro (lambda (self sym comment) ""))
(method-make! <hw-memory> 'gen-sym-set-macro (lambda (self sym comment) ""))

; For parallel instructions supported by queueing outputs for later update,
; return the type of the index or #f if not needed.

(method-make!
 <hw-memory> 'save-index?
 (lambda (self op)
   ; In the case of the complete memory address being an immediate
   ; argument, we can return #f (later).
   AI)
)

(method-make!
 <hw-memory> 'gen-write
 (lambda (self estate index mode sfmt op access-macro)
   (let ((index (send index 'get-write-index self sfmt op access-macro)))
     (string-append "  "
		    (send self 'gen-set-quiet estate mode index
			  hw-selector-default
			  (cx:make DFLT (string-append access-macro " ("
						     (gen-sym op)
						     ")"))))))
)

; Immediates, addresses.

; Forward these methods onto TYPE.
(method-make-virtual-forward! <hw-immediate> 'type '(gen-type gen-sym-decl))
(method-make-forward! <hw-immediate> 'type '(gen-sym-get-macro
					     gen-sym-set-macro))

(method-make!
 <hw-immediate> 'gen-write
 (lambda (self estate index mode sfmt op access-macro)
   (error "gen-write of <hw-immediate> shouldn't happen"))
)

; FIXME.
(method-make-virtual! <hw-address> 'gen-type (lambda (self) "ADDR"))
(method-make-virtual! <hw-address> 'gen-sym-decl (lambda (self sym comment) ""))
(method-make! <hw-address> 'gen-sym-get-macro (lambda (self sym comment) ""))
(method-make! <hw-address> 'gen-sym-set-macro (lambda (self sym comment) ""))

; Return a <c-expr> object of the value of SELF.
; ESTATE is the current rtl evaluator state.
; INDEX is a hw-index object.  It must be an ifield.
; Needed because we record our own copy of the ifield in ARGBUF.
; SELECTOR is a hardware selector RTX.

(method-make!
 <hw-address> 'cxmake-get
 (lambda (self estate mode index selector)
   (if (not (eq? 'ifield (hw-index:type index)))
       (error "not an ifield hw-index" index))
   (if (with-scache?)
       (cx:make mode (gen-hw-index-argbuf-ref index))
       (cx:make mode (gen-hw-index-argbuf-name index))))
)

(method-make!
 <hw-address> 'gen-write
 (lambda (self estate index mode sfmt op access-macro)
   (error "gen-write of <hw-address> shouldn't happen"))
)

; FIXME: revisit.
(method-make-virtual! <hw-iaddress> 'gen-type (lambda (self) "IADDR"))

; Return a <c-expr> object of the value of SELF.
; ESTATE is the current rtl evaluator state.
; INDEX is a <hw-index> object.  It must be an ifield.
; Needed because we record our own copy of the ifield in ARGBUF,
; *and* because we want to record in the result the 'CACHED attribute
; since instruction addresses based on ifields are fixed [and thus cacheable].
; SELECTOR is a hardware selector RTX.

(method-make!
 <hw-iaddress> 'cxmake-get
 (lambda (self estate mode index selector)
   (if (not (eq? 'ifield (hw-index:type index)))
       (error "not an ifield hw-index" index))
   (if (with-scache?)
       ; ??? Perhaps a better way would be to defer evaluating the src of a
       ; set until the method processing the dest.
       (cx:make-with-atlist mode (gen-hw-index-argbuf-ref index)
			    (atlist-make "" (bool-attr-make 'CACHED #t)))
       (cx:make mode (gen-hw-index-argbuf-name index))))
)

; Hardware index support code.

; Return the index to use by the gen-write method.
; In the cases where this is needed (the index isn't known until insn
; execution time), the index is computed along with the value to be stored,
; so this is easy.

(method-make!
 <hw-index> 'get-write-index
 (lambda (self hw sfmt op access-macro)
   (if (memq (hw-index:type self) '(scalar constant str-expr ifield))
       self
       (let ((index-mode (send hw 'get-index-mode)))
	 (if index-mode
	     (make <hw-index> 'anonymous 'str-expr index-mode
		   (string-append access-macro " (" (-op-index-name op) ")"))
	     (hw-index-scalar)))))
)

; Return the name of the PAREXEC structure member holding a hardware index
; for operand OP.

(define (-op-index-name op)
  (string-append (gen-sym op) "_idx")
)

; Cover fn to hardware indices to generate the actual C code.
; INDEX is the hw-index object (i.e. op:index).
; The result is a string of C code.
; FIXME:wip

(define (-gen-hw-index-raw index estate)
  (let ((type (hw-index:type index))
	(mode (hw-index:mode index))
	(value (hw-index:value index)))
    (case type
      ((scalar) "")
      ; special case UINT to cut down on unnecessary verbosity.
      ; ??? May wish to handle more similarily.
      ((constant) (if (mode:eq? 'UINT mode)
		      (number->string value)
		      (string-append "((" (mode:c-type mode) ") "
				     (number->string value)
				     ")")))
      ((str-expr) value)
      ((rtx) (rtl-c-with-estate estate mode value))
      ((ifield) (if (= (ifld-length value) 0)
		    ""
		    (gen-extracted-ifld-value value)))
      ((operand) (cx:c (send value 'cxmake-get estate mode (op:index value)
			     (op:selector value) #f)))
      (else (error "-gen-hw-index-raw: invalid index:" index))))
)

; Same as -gen-hw-index-raw except used where speedups are possible.
; e.g. doing array index calcs at extraction time.

(define (-gen-hw-index index estate)
  (let ((type (hw-index:type index))
	(mode (hw-index:mode index))
	(value (hw-index:value index)))
    (case type
      ((scalar) "")
      ((constant) (string-append "((" (mode:c-type mode) ") "
				 (number->string value)
				 ")"))
      ((str-expr) value)
      ((rtx) (rtl-c-with-estate estate mode value))
      ((ifield) (if (= (ifld-length value) 0)
		    ""
		    (cx:c (-cxmake-ifld-val mode value))))
      ((operand) (cx:c (send value 'cxmake-get estate mode (op:index value)
			     (op:selector value))))
      (else (error "-gen-hw-index: invalid index:" index))))
)

; Return address where HW is stored.

(define (-gen-hw-addr hw estate index)
  (let ((setter (hw-setter hw)))
    (cond ((and (hw-cache-addr? hw) ; FIXME: redo test
		(eq? 'ifield (hw-index:type index)))
	   (if (with-scache?)
	       (gen-hw-index-argbuf-ref index)
	       (gen-hw-index-argbuf-name index)))
	  (else
	   (string-append "& "
			  (gen-cpu-ref (send hw 'gen-ref
					     (gen-sym hw) index estate))))))
)

; Return a <c-expr> object of the value of a hardware index.

(method-make!
 <hw-index> 'cxmake-get
 (lambda (self estate mode)
   (let ((mode (if (mode:eq? 'DFLT mode) (elm-get self 'mode) mode)))
     ; If MODE is VOID, abort.
     (if (mode:eq? 'VOID mode)
	 (error "hw-index:cxmake-get: result needs a mode" self))
     (cx:make (if (mode:host? mode)
		  ; FIXME: Temporary hack to generate same code as before.
		  (let ((xmode (object-copy-top mode)))
		    (obj-cons-attr! xmode (bool-attr-make 'FORCE-C #t))
		    xmode)
		  mode)
	      (-gen-hw-index self estate))))
)

; Hardware selector support code.

; Generate C code for SEL.

(define (-gen-hw-selector sel)
  (rtl-c 'INT sel nil)
)

; Instruction operand support code.

; Methods:
; gen-type      - Return C type to use to hold operand's value.
; gen-read      - Record an operand's value prior to parallely executing
;                 several instructions.  Not used if gen-write used.
; gen-write     - Write back an operand's value after parallely executing
;                 several instructions.  Not used if gen-read used.
; cxmake-get    - Return C code to fetch the value of an operand.
; gen-set-quiet - Return C code to set the value of an operand.
; gen-set-trace - Return C code to set the value of an operand, and print
;                 a result trace message.  ??? Ideally this will go away when
;                 trace record support is complete.

; Return the C type of an operand.
; Generally we forward things on to TYPE, but for the actual type we need to
; use the get-mode method.

;(method-make-forward! <operand> 'type '(gen-type))
(method-make!
 <operand> 'gen-type
 (lambda (self)
   ; First get the mode.
   (let ((mode (send self 'get-mode)))
     ; If it's VOID use the type's type.
     (if (mode:eq? 'DFLT mode)
	 (send (op:type self) 'gen-type)
	 (mode:c-type mode))))
)

; Extra pc operand methods.

(method-make!
 <pc> 'cxmake-get
 (lambda (self estate mode index selector)
   (let ((mode (if (mode:eq? 'DFLT mode)
		   (send self 'get-mode)
		   mode)))
     ; The enclosing function must set `pc' to the correct value.
     (cx:make mode "pc")))
)

(method-make!
 <pc> 'cxmake-skip
 (lambda (self estate yes?)
   (send (op:type self) 'cxmake-skip estate
	 (rtl-c INT yes? nil #:rtl-cover-fns? #t)))
)

; For parallel write post-processing, we don't want to defer setting the pc.
; ??? Not sure anymore.
;(method-make!
; <pc> 'gen-set-quiet
; (lambda (self estate mode index selector newval)
;   (-op-gen-set-quiet self estate mode index selector newval)))
;(method-make!
; <pc> 'gen-set-trace
; (lambda (self estate mode index selector newval)
;   (-op-gen-set-trace self estate mode index selector newval)))

; Name of C macro to access parallel execution operand support.

(define -par-operand-macro "OPRND")

; Return C code to fetch an operand's value and save it away for the
; semantic handler.  This is used to handle parallel execution of several
; instructions where all inputs of all insns are read before any outputs are
; written.
; For operands, the word `read' is only used in this context.

(define (op:read op sfmt)
  (let ((estate (estate-make-for-normal-rtl-c nil nil)))
    (send op 'gen-read estate sfmt -par-operand-macro))
)

; Return C code to write an operand's value.
; This is used to handle parallel execution of several instructions where all
; outputs are written to temporary spots first, and then a final
; post-processing pass is run to update cpu state.
; For operands, the word `write' is only used in this context.

(define (op:write op sfmt)
  (let ((estate (estate-make-for-normal-rtl-c nil nil)))
    (send op 'gen-write estate sfmt -par-operand-macro))
)

; Default gen-read method.
; This is used to help support targets with parallel insns.
; Either this or gen-write (but not both) is used.

(method-make!
 <operand> 'gen-read
 (lambda (self estate sfmt access-macro)
   (string-append "  "
		  access-macro " ("
		  (gen-sym self)
		  ") = "
		  ; Pass #f for the index -> use the operand's builtin index.
		  ; Ditto for the selector.
		  (cx:c (send self 'cxmake-get estate DFLT #f #f))
		  ";\n"))
)

; Forward gen-write onto the <hardware> object.

(method-make!
 <operand> 'gen-write
 (lambda (self estate sfmt access-macro)
   (let ((write-back-code (send (op:type self) 'gen-write estate
				(op:index self) (op:mode self)
				sfmt self access-macro)))
     ; If operand is conditionally written, we have to check that first.
     ; ??? If two (or more) operands are written based on the same condition,
     ; all the tests can be collapsed together.  Not sure that's a big
     ; enough win yet.
     (if (op:cond? self)
	 (string-append "  if (written & (1 << "
			(number->string (op:num self))
			"))\n"
			"    {\n"
			"    " write-back-code
			"    }\n")
	 write-back-code)))
)

; Return <c-expr> object to get the value of an operand.
; ESTATE is the current rtl evaluator state.
; If INDEX is non-#f use it, otherwise use (op:index self).
; This special handling of #f for INDEX is *only* supported for operands
; in cxmake-get, gen-set-quiet, and gen-set-trace.
; Ditto for SELECTOR.

(method-make!
 <operand> 'cxmake-get
 (lambda (self estate mode index selector)
   (let ((mode (if (mode:eq? 'DFLT mode)
		   (send self 'get-mode)
		   mode))
	 (index (if index index (op:index self)))
	 (selector (if selector selector (op:selector self))))
     ; If the instruction could be parallely executed with others and we're
     ; doing read pre-processing, the operand has already been fetched, we
     ; just have to grab the cached value.
     ; ??? reg-raw: support wip
     (cond ((obj-has-attr? self 'RAW)
	    (send (op:type self) 'cxmake-get-raw estate mode index selector))
	   ((with-parallel-read?)
	    (cx:make-with-atlist mode
				 (string-append -par-operand-macro
						" (" (gen-sym self) ")")
				 nil)) ; FIXME: want CACHED attr if present
	   ((op:getter self)
	    (let ((args (car (op:getter self)))
		  (expr (cadr (op:getter self))))
	      (rtl-c-expr mode expr
			  (if (= (length args) 0)
			      nil
			      (list (list (car args) 'UINT index)))
			  #:rtl-cover-fns? #t)))
	   (else
	    (send (op:type self) 'cxmake-get estate mode index selector)))))
)

; Utilities to implement gen-set-quiet/gen-set-trace.

(define (-op-gen-set-quiet op estate mode index selector newval)
  (send (op:type op) 'gen-set-quiet estate mode index selector newval)
)

; Return C code to call the appropriate queued-write handler.
; ??? wip

(define (-op-gen-queued-write op estate mode index selector newval)
  (let* ((hw (op:type op))
	 (setter (hw-setter hw))
	 (sem-mode (mode:sem-mode mode)))
    (string-append
     "    "
     "sim_queue_"
     ; FIXME: clean up (pc? op) vs (memory? hw)
     ; FIXME: (send 'pc?) is a temporary hack, (pc? op) didn't work
     (cond ((send hw 'pc?)
	    (string-append
	     (if setter
		 "fn_"
		 "")
	     "pc"))
	   (else
	    (string-append
	     (cond ((memory? hw)
		    "mem_")
		   ((hw-scalar? hw)
		    "scalar_")
		   (else ""))
	     (if setter
		 "fn_"
		 "")
	     (string-downcase (symbol->string (if sem-mode
				  (mode-real-name sem-mode)
				  (mode-real-name mode)))))))
     "_write (current_cpu"
     ; ??? May need to include h/w id some day.
     (if setter
	 (string-append ", " (gen-reg-setter-fn hw "@cpu@"))
	 "")
     (cond ((hw-scalar? hw)
	    "")
	   (setter
	    (string-append ", " (-gen-hw-index index estate)))
	   ((memory? hw)
	    (string-append ", " (-gen-hw-index index estate)))
	   (else
	    (string-append ", " (-gen-hw-addr (op:type op) estate index))))
     ", "
     newval
     ");\n"))
)

(define (-op-gen-set-quiet-parallel op estate mode index selector newval)
  (if (with-generic-write?)
      (-op-gen-queued-write op estate mode index selector (cx:c newval))
      (string-append
       (if (op-save-index? op)
	   (string-append "    "
			  -par-operand-macro " (" (-op-index-name op) ")"
			  " = " (-gen-hw-index index estate) ";\n")
	   "")
       "    "
       -par-operand-macro " (" (gen-sym op) ")"
       " = " (cx:c newval) ";\n"))
)

(define (-op-gen-set-trace op estate mode index selector newval)
  (string-append
   "  {\n"
   "    " (mode:c-type mode) " opval = " (cx:c newval) ";\n"
   ; Dispatch to setter code if appropriate
   "    "
   (if (op:setter op)
       (let ((args (car (op:setter op)))
	     (expr (cadr (op:setter op))))
	 (rtl-c 'VOID expr
		(if (= (length args) 0)
		    (list (list 'newval mode "opval"))
		    (list (list (car args) 'UINT index)
			  (list 'newval mode "opval")))
		#:rtl-cover-fns? #t))
       ;else
       (send (op:type op) 'gen-set-quiet estate mode index selector
	     (cx:make-with-atlist mode "opval" (cx:atlist newval))))
   (if (op:cond? op)
       (string-append "    written |= (1 << "
		      (number->string (op:num op))
		      ");\n")
       "")
; TRACE_RESULT_<MODE> (cpu, abuf, hwnum, opnum, value);
; For each insn record array of operand numbers [or indices into
; operand instance table].
; Could just scan the operand table for the operand or hardware number,
; assuming the operand number is stored in `op'.
   "    TRACE_RESULT (current_cpu, abuf"
   ", " (send op 'gen-pretty-name mode)
   ", " (mode:printf-type mode)
   ", opval);\n"
   "  }\n")
)

(define (-op-gen-set-trace-parallel op estate mode index selector newval)
  (string-append
   "  {\n"
   "    " (mode:c-type mode) " opval = " (cx:c newval) ";\n"
   (if (with-generic-write?)
       (-op-gen-queued-write op estate mode index selector "opval")
       (string-append
	(if (op-save-index? op)
	    (string-append "    "
			   -par-operand-macro " (" (-op-index-name op) ")"
			   " = " (-gen-hw-index index estate) ";\n")
	    "")
	"    " -par-operand-macro " (" (gen-sym op) ")"
	" = opval;\n"))
   (if (op:cond? op)
       (string-append "    written |= (1 << "
		      (number->string (op:num op))
		      ");\n")
       "")
; TRACE_RESULT_<MODE> (cpu, abuf, hwnum, opnum, value);
; For each insn record array of operand numbers [or indices into
; operand instance table].
; Could just scan the operand table for the operand or hardware number,
; assuming the operand number is stored in `op'.
   "    TRACE_RESULT (current_cpu, abuf"
   ", " (send op 'gen-pretty-name mode)
   ", " (mode:printf-type mode)
   ", opval);\n"
   "  }\n")
)

; Return C code to set the value of an operand.
; NEWVAL is a <c-expr> object of the value to store.
; If INDEX is non-#f use it, otherwise use (op:index self).
; This special handling of #f for INDEX is *only* supported for operands
; in cxmake-get, gen-set-quiet, and gen-set-trace.
; Ditto for SELECTOR.

(method-make!
 <operand> 'gen-set-quiet
 (lambda (self estate mode index selector newval)
   (let ((mode (if (mode:eq? 'DFLT mode)
		   (send self 'get-mode)
		   mode))
	 (index (if index index (op:index self)))
	 (selector (if selector selector (op:selector self))))
     ; ??? raw-reg: support wip
     (cond ((obj-has-attr? self 'RAW)
	    (send (op:type self) 'gen-set-quiet-raw estate mode index selector newval))
	   ((with-parallel-write?)
	    (-op-gen-set-quiet-parallel self estate mode index selector newval))
	   (else
	    (-op-gen-set-quiet self estate mode index selector newval)))))
)

; Return C code to set the value of an operand and print TRACE_RESULT message.
; NEWVAL is a <c-expr> object of the value to store.
; If INDEX is non-#f use it, otherwise use (op:index self).
; This special handling of #f for INDEX is *only* supported for operands
; in cxmake-get, gen-set-quiet, and gen-set-trace.
; Ditto for SELECTOR.

(method-make!
 <operand> 'gen-set-trace
 (lambda (self estate mode index selector newval)
   (let ((mode (if (mode:eq? 'DFLT mode)
		   (send self 'get-mode)
		   mode))
	 (index (if index index (op:index self)))
	 (selector (if selector selector (op:selector self))))
     ; ??? raw-reg: support wip
     (cond ((obj-has-attr? self 'RAW)
	    (send (op:type self) 'gen-set-quiet-raw estate mode index selector newval))
	   ((with-parallel-write?)
	    (-op-gen-set-trace-parallel self estate mode index selector newval))
	   (else
	    (-op-gen-set-trace self estate mode index selector newval)))))
)

; Define and undefine C macros to tuck away details of instruction format used
; in the parallel execution functions.  See gen-define-field-macro for a
; similar thing done for extraction/semantic functions.

(define (gen-define-parallel-operand-macro sfmt)
  (string-append "#define " -par-operand-macro "(f) "
		 "par_exec->operands."
		 (gen-sym sfmt)
		 ".f\n")
)

(define (gen-undef-parallel-operand-macro sfmt)
  (string-append "#undef " -par-operand-macro "\n")
)

; Operand profiling and parallel execution support.

(method-make!
 <operand> 'save-index?
 (lambda (self) (send (op:type self) 'save-index? self))
)

; Return boolean indicating if operand OP needs its index saved
; (for parallel write post-processing support).

(define (op-save-index? op)
  (send op 'save-index?)
)

; Return C code to record profile data for modeling use.
; In the case of a register, this is usually the register's number.
; This shouldn't be called in the case of a scalar, the code should be
; smart enough to know there is no need.

(define (op:record-profile op sfmt out?)
  (let ((estate (estate-make-for-normal-rtl-c nil nil)))
    (send op 'gen-record-profile sfmt out? estate))
)

; Return C code to record the data needed for profiling operand SELF.
; This is done during extraction.

(method-make!
 <operand> 'gen-record-profile
 (lambda (self sfmt out? estate)
   (if (hw-scalar? (op:type self))
       ""
       (string-append "      "
		      (gen-argbuf-ref (send self 'sbuf-profile-sym out?))
		      " = "
		      (send (op:type self) 'gen-record-profile
			    (op:index self) sfmt estate)
		      ";\n")))
)

; Return C code to track profiling of operand SELF.
; This is usually called by the x-after handler.

(method-make!
 <operand> 'gen-profile-code
 (lambda (self insn out?)
   (string-append "  "
		  "@cpu@_model_mark_"
		  (if out? "set_" "get_")
		  (gen-sym (op:type self))
		  " (current_cpu"
		  (if (hw-scalar? (op:type self))
		      ""
		      (string-append ", "
				     (gen-argbuf-ref
				      (send self 'sbuf-profile-sym out?))))
		  ");\n"))
)

; CPU, mach, model support.

; Return the declaration of the cpu/insn enum.

(define (gen-cpu-insn-enum-decl cpu insn-list)
  (gen-enum-decl "@prefix@_insn_type"
		 "instructions in cpu family @cpu@"
		 "@PREFIX@_INSN_"
		 (append! (map (lambda (i)
				 (cons (obj:name i)
				       (cons '-
					     (atlist-attrs (obj-atlist i)))))
			       insn-list)
			  (if (with-parallel?)
			      (apply append!
				     (map (lambda (i)
					    (list
					     (cons (symbol-append 'par- (obj:name i))
						   (cons '-
							 (atlist-attrs (obj-atlist i))))
					     (cons (symbol-append 'write- (obj:name i))
						   (cons '-
							 (atlist-attrs (obj-atlist i))))))
					  (parallel-insns insn-list)))
			      nil)
			  (list '(-max))))
)

; Return the enum of INSN in cpu family CPU.
; In addition to CGEN_INSN_TYPE, an enum is created for each insn in each
; cpu family.  This collapses the insn enum space for each cpu to increase
; cache efficiently (since the IDESC table is similarily collapsed).

(define (gen-cpu-insn-enum cpu insn)
  (string-upcase (string-append "@PREFIX@_INSN_" (gen-sym insn)))
)

; Return C code to declare the machine data.

(define (-gen-mach-decls)
  (string-append
   (string-map (lambda (mach)
		 (gen-obj-sanitize mach
				   (string-append "extern const MACH "
						  (gen-sym mach)
						  "_mach;\n")))
	       (current-mach-list))
   "\n")
)

; Return C code to define the machine data.

(define (-gen-mach-data)
  (string-append
   "const MACH *sim_machs[] =\n{\n"
   (string-map (lambda (mach)
		 (gen-obj-sanitize
		  mach
		  (string-append "#ifdef " (gen-have-cpu (mach-cpu mach)) "\n"
				 "  & " (gen-sym mach) "_mach,\n"
				 "#endif\n")))
	       (current-mach-list))
   "  0\n"
   "};\n\n"
   )
)

; Return C declarations of cpu model support stuff.
; ??? This goes in arch.h but a better place is each cpu.h.

(define (-gen-arch-model-decls)
  (string-append
   (gen-enum-decl 'model_type "model types"
		  "MODEL_"
		  (append (map (lambda (model)
				 (cons (obj:name model)
				       (cons '-
					     (atlist-attrs (obj-atlist model)))))
			       (current-model-list))
			  '((max))))
   "#define MAX_MODELS ((int) MODEL_MAX)\n\n"
   (gen-enum-decl 'unit_type "unit types"
		  "UNIT_"
		  (cons '(none)
			(append
			 ; "apply append" squeezes out nils.
			 (apply append
				; create <model_name>-<unit-name> for each unit
				(map (lambda (model)
				       (let ((units (model:units model)))
					 (if (null? units)
					     nil
					     (map (lambda (unit)
						    (cons (symbol-append (obj:name model) '-
									 (obj:name unit))
							  (cons '- (atlist-attrs (obj-atlist model)))))
						  units))))
				     (current-model-list)))
			 '((max)))))
   ; FIXME: revisit MAX_UNITS
   "#define MAX_UNITS ("
   (number->string
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
		     (current-insn-list)))))
   ")\n\n"
   )
)

; Function units.

(method-make! <unit> 'gen-decl (lambda (self) ""))

; Lookup operand named OP-NAME in INSN.
; Returns #f if OP-NAME is not an operand of INSN.
; IN-OUT is 'in to request an input operand, 'out to request an output operand,
; and 'in-out to request either (though if an operand is used for input and
; output then the input version is returned).
; FIXME: Move elsewhere.

(define (insn-op-lookup op-name insn in-out)
  (letrec ((lookup (lambda (op-list)
		     (cond ((null? op-list) #f)
			   ((eq? op-name (op:sem-name (car op-list))) (car op-list))
			   (else (lookup (cdr op-list)))))))
    (case in-out
      ((in) (lookup (sfmt-in-ops (insn-sfmt insn))))
      ((out) (lookup (sfmt-out-ops (insn-sfmt insn))))
      ((in-out) (or (lookup (sfmt-in-ops (insn-sfmt insn)))
		    (lookup (sfmt-out-ops (insn-sfmt insn)))))
      (else (error "insn-op-lookup: bad arg:" in-out))))
)

; Return C code to profile a unit's usage.
; UNIT-NUM is number of the unit in INSN.
; OVERRIDES is a list of (name value) pairs, where
; - NAME is a spec name, one of cycles, pred, in, out.
;   The only ones we're concerned with are in,out.  They map operand names
;   as they appear in the semantic code to operand names as they appear in
;   the function unit spec.
; - VALUE is the operand to NAME.  For in,out it is (NAME VALUE) where
;   - NAME is the name of an input/output arg of the unit.
;   - VALUE is the name of the operand as it appears in semantic code.
;
; ??? This is a big sucker, though half of it is just the definitions
; of utility fns.

(method-make!
 <unit> 'gen-profile-code
 (lambda (self unit-num insn overrides cycles-var-name)
   (let (
	 (inputs (unit:inputs self))
	 (outputs (unit:outputs self))

	  ; Return C code to initialize UNIT-REFERENCED-VAR to be a bit mask
	  ; of operands of UNIT that were read/written by INSN.
	  ; INSN-REFERENCED-VAR is a bitmask of operands read/written by INSN.
	  ; All we have to do is map INSN-REFERENCED-VAR to
	  ; UNIT-REFERENCED-VAR.
	  ; ??? For now we assume all input operands are read.
	  (gen-ref-arg (lambda (arg num in-out)
			 (let* ((op-name (assq-ref overrides (car arg)))
				(op (insn-op-lookup (if op-name
							(car op-name)
							(car arg))
						    insn in-out))
				(insn-referenced-var "insn_referenced")
				(unit-referenced-var "referenced"))
			   (if op
			       (if (op:cond? op)
				   (string-append "    "
						  "if ("
						  insn-referenced-var
						  " & (1 << "
						  (number->string (op:num op))
						  ")) "
						  unit-referenced-var
						  " |= 1 << "
						  (number->string num)
						  ";\n")
				   (string-append "    "
						  unit-referenced-var
						  " |= 1 << "
						  (number->string num)
						  ";\n"))
			       ""))))

	  ; Initialize unit argument ARG.
	  ; OUT? is #f for input args, #t for output args.
	  (gen-arg-init (lambda (arg out?)
			  (if (or
			       ; Ignore scalars.
			       (null? (cdr arg))
			       ; Ignore remapped arg, handled elsewhere.
			       (assq (car arg) overrides)
			       ; Ignore operands not in INSN.
			       (not (insn-op-lookup (car arg) insn
						    (if out? 'out 'in))))
			      ""
			      (let ((sym (gen-profile-sym (gen-c-symbol (car arg))
							   out?)))
				(string-append "    "
					       sym
					       " = "
					       (gen-argbuf-ref sym)
					       ";\n")))))

	  ; Return C code to declare variable to hold unit argument ARG.
	  ; OUT? is #f for input args, #t for output args.
	  (gen-arg-decl (lambda (arg out?)
			  (if (null? (cdr arg)) ; ignore scalars
			      ""
			      (string-append "    "
					     (mode:c-type (mode:lookup (cadr arg)))
					     " "
					     (gen-profile-sym (gen-c-symbol (car arg))
							      out?)
					     " = "
					     (if (null? (cddr arg))
						 "0"
						 (number->string (caddr arg)))
					     ";\n"))))

	  ; Return C code to pass unit argument ARG to the handler.
	  ; OUT? is #f for input args, #t for output args.
	  (gen-arg-arg (lambda (arg out?)
			 (if (null? (cdr arg)) ; ignore scalars
			     ""
			     (string-append ", "
					    (gen-profile-sym (gen-c-symbol (car arg))
							     out?)))))
	  )

     (string-list
      "  {\n"
      "    int referenced = 0;\n"
      "    int UNUSED insn_referenced = abuf->written;\n"
      ; Declare variables to hold unit arguments.
      (string-map (lambda (arg) (gen-arg-decl arg #f))
		  inputs)
      (string-map (lambda (arg) (gen-arg-decl arg #t))
		  outputs)
      ; Initialize 'em, being careful not to initialize an operand that
      ; has an override.
      (let (; Make a list of names of in/out overrides.
	    (in-overrides (find-apply cadr
				      (lambda (elm) (eq? (car elm) 'in))
				      overrides))
	    (out-overrides (find-apply cadr
				      (lambda (elm) (eq? (car elm) 'out))
				      overrides)))
	(string-list
	 (string-map (lambda (arg)
		       (if (memq (car arg) in-overrides)
			   ""
			   (gen-arg-init arg #f)))
		     inputs)
	 (string-map (lambda (arg)
		       (if (memq (car arg) out-overrides)
			   ""
			   (gen-arg-init arg #t)))
		     outputs)))
      (string-map (lambda (arg)
		    (case (car arg)
		      ((pred) "")
		      ((cycles) "")
		      ((in)
		       (if (caddr arg)
			   (string-append "    "
					  (gen-profile-sym (gen-c-symbol (cadr arg)) #f)
					  " = "
					  (gen-argbuf-ref
					   (gen-profile-sym (gen-c-symbol (caddr arg)) #f))
					  ";\n")
			   ""))
		      ((out)
		       (if (caddr arg)
			   (string-append "    "
					  (gen-profile-sym (gen-c-symbol (cadr arg)) #t)
					  " = "
					  (gen-argbuf-ref
					   (gen-profile-sym (gen-c-symbol (caddr arg)) #t))
					  ";\n")
			   ""))
		      (else
		       (parse-error (make-prefix-context "insn function unit spec")
				    "invalid spec" arg))))
		  overrides)
      ; Create bitmask indicating which args were referenced.
      (string-map (lambda (arg num) (gen-ref-arg arg num 'in))
		  inputs
		  (iota (length inputs)))
      (string-map (lambda (arg num) (gen-ref-arg arg num 'out))
		  outputs
		  (iota (length outputs)
			(length inputs)))
      ; Emit the call to the handler.
      "    " cycles-var-name " += "
      (gen-model-unit-fn-name (unit:model self) self)
      " (current_cpu, idesc"
      ", " (number->string unit-num)
      ", referenced"
      (string-map (lambda (arg) (gen-arg-arg arg #f))
		  inputs)
      (string-map (lambda (arg) (gen-arg-arg arg #t))
		  outputs)
      ");\n"
      "  }\n"
      )))
)

; Return C code to profile an insn-specific unit's usage.
; UNIT-NUM is number of the unit in INSN.

(method-make!
 <iunit> 'gen-profile-code
 (lambda (self unit-num insn cycles-var-name)
   (let ((args (iunit:args self))
	 (unit (iunit:unit self)))
     (send unit 'gen-profile-code unit-num insn args cycles-var-name)))
)

; ARGBUF generation.
; ARGBUF support is put in cpuall.h, which doesn't depend on sim-cpu.scm,
; so this support is here.

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

; Utility of gen-argbuf-type to generate the union of extracted ifields.

(define (-gen-argbuf-fields-union)
  (string-list
   "\
/* Instruction argument buffer.  */

union sem_fields {\n"
   (string-list-map -gen-argbuf-elm (current-sbuf-list))
   "\
#if WITH_SCACHE_PBB
  /* Writeback handler.  */
  struct {
    /* Pointer to argbuf entry for insn whose results need writing back.  */
    const struct argbuf *abuf;
  } write;
  /* x-before handler */
  struct {
    /*const SCACHE *insns[MAX_PARALLEL_INSNS];*/
    int first_p;
  } before;
  /* x-after handler */
  struct {
    int empty;
  } after;
  /* This entry is used to terminate each pbb.  */
  struct {
    /* Number of insns in pbb.  */
    int insn_count;
    /* Next pbb to execute.  */
    SCACHE *next;
    SCACHE *branch_target;
  } chain;
#endif
};\n\n"
   )
)

; Generate the definition of the structure that records arguments.
; This is a union of structures with one structure for each insn format.
; It also includes hardware profiling information and miscellaneous
; administrivia.
; CPU-DATA? is #t if data for the currently selected cpu is to be included.

(define (gen-argbuf-type cpu-data?)
  (logit 2 "Generating ARGBUF type ...\n")
  (string-list
   (if (and cpu-data? (with-scache?))
       (-gen-argbuf-fields-union)
       "")
   (if cpu-data? "" "#ifndef WANT_CPU\n")
   "\
/* The ARGBUF struct.  */
struct argbuf {
  /* These are the baseclass definitions.  */
  IADDR addr;
  const IDESC *idesc;
  char trace_p;
  char profile_p;
  /* ??? Temporary hack for skip insns.  */
  char skip_count;
  char unused;
  /* cpu specific data follows */\n"
   (if cpu-data?
       (if (with-scache?)
	    "\
  union sem semantic;
  int written;
  union sem_fields fields;\n"
	    "\
  CGEN_INSN_INT insn;
  int written;\n")
       "")
   "};\n"
   (if cpu-data? "" "#endif\n")
   "\n"
   )
)

; Generate the definition of the structure that records a cached insn.
; This is cpu family specific (member `argbuf' is) so it is machine generated.
; CPU-DATA? is #t if data for the currently selected cpu is to be included.

(define (gen-scache-type cpu-data?)
  (logit 2 "Generating SCACHE type ...\n")
  (string-append
   (if cpu-data? "" "#ifndef WANT_CPU\n")
   "\
/* A cached insn.

   ??? SCACHE used to contain more than just argbuf.  We could delete the
   type entirely and always just use ARGBUF, but for future concerns and as
   a level of abstraction it is left in.  */

struct scache {
  struct argbuf argbuf;\n"
   (if (with-generic-write?) "\
  int first_insn_p;
  int last_insn_p;\n" "")
   "};\n"
   (if cpu-data? "" "#endif\n")
   "\n"
  )
)

; Mode support.

; Generate a table of mode data.
; For now all we need is the names.

(define (gen-mode-defs)
  (string-append
   "const char *mode_names[] = {\n"
   (string-map (lambda (m)
		 (string-append "  \"" (string-upcase (obj:str-name m)) "\",\n"))
	       ; We don't treat aliases as being different from the real
	       ; mode here, so ignore them.
	       (mode-list-non-alias-values))
   "};\n\n"
   )
)

; Insn profiling support.

; Generate declarations for local variables needed for modelling code.

(method-make!
 <insn> 'gen-profile-locals
 (lambda (self model)
;   (let ((cti? (or (has-attr? self 'UNCOND-CTI)
;		   (has-attr? self 'COND-CTI))))
;     (string-append
;      (if cti? "  int UNUSED taken_p = 0;\n" "")
;      ))
   "")
)

; Generate C code to profile INSN.

(method-make!
 <insn> 'gen-profile-code
 (lambda (self model cycles-var-name)
   (string-list
    (let ((timing (assq-ref (insn-timing self) (obj:name model))))
      (if timing
	  (string-list-map (lambda (iunit unit-num)
			     (send iunit 'gen-profile-code unit-num self cycles-var-name))
			   (timing:units timing)
			   (iota (length (timing:units timing))))
	  (send (model-default-unit model) 'gen-profile-code 0 self nil cycles-var-name)))
    ))
)

; .cpu file loading support

; Only run sim-analyze-insns! once.
(define -sim-insns-analyzed? #f)

; List of computed sformat argument buffers.
(define -sim-sformat-abuf-list #f)
(define (current-sbuf-list) -sim-sformat-abuf-list)

; Called before/after the .cpu file has been read in.

(define (sim-init!)
  (set! -sim-insns-analyzed? #f)
  (set! -sim-sformat-abuf-list #f)
  *UNSPECIFIED*
)

;; Subroutine of -create-virtual-insns!.
;; Add virtual insn INSN to the database.
;; We put virtual insns ahead of normal insns because they're kind of special,
;; and it helps to see them first in lists.
;; ORDINAL is a used to place the insn ahead of normal insns;
;; it is a pair so we can do the update for the next virtual insn here.

(define (-virtual-insn-add! ordinal insn)
  (obj-set-ordinal! insn (cdr ordinal))
  (current-insn-add! insn)
  (set-cdr! ordinal (- (cdr ordinal) 1))
)

; Create the virtual insns.

(define (-create-virtual-insns!)
  (let ((all (all-isas-attr-value))
	(context (make-prefix-context "virtual insns"))
	;; Record as a pair so -virtual-insn-add! can update it.
	(ordinal (cons #f -1)))

    (-virtual-insn-add!
     ordinal
     (insn-read context
		'(name x-begin)
		'(comment "pbb begin handler")
		`(attrs VIRTUAL PBB (ISA ,all))
		'(syntax "--begin--")
		'(semantics (c-code VOID "\
  {
#if WITH_SCACHE_PBB_@PREFIX@
#if defined DEFINE_SWITCH || defined FAST_P
    /* In the switch case FAST_P is a constant, allowing several optimizations
       in any called inline functions.  */
    vpc = @prefix@_pbb_begin (current_cpu, FAST_P);
#else
#if 0 /* cgen engine can't handle dynamic fast/full switching yet.  */
    vpc = @prefix@_pbb_begin (current_cpu, STATE_RUN_FAST_P (CPU_STATE (current_cpu)));
#else
    vpc = @prefix@_pbb_begin (current_cpu, 0);
#endif
#endif
#endif
  }
"))
		))

    (-virtual-insn-add!
     ordinal
     (insn-read context
		'(name x-chain)
		'(comment "pbb chain handler")
		`(attrs VIRTUAL PBB (ISA ,all))
		'(syntax "--chain--")
		'(semantics (c-code VOID "\
  {
#if WITH_SCACHE_PBB_@PREFIX@
    vpc = @prefix@_pbb_chain (current_cpu, sem_arg);
#ifdef DEFINE_SWITCH
    BREAK (sem);
#endif
#endif
  }
"))
		))

    (-virtual-insn-add!
     ordinal
     (insn-read context
		'(name x-cti-chain)
		'(comment "pbb cti-chain handler")
		`(attrs VIRTUAL PBB (ISA ,all))
		'(syntax "--cti-chain--")
		'(semantics (c-code VOID "\
  {
#if WITH_SCACHE_PBB_@PREFIX@
#ifdef DEFINE_SWITCH
    vpc = @prefix@_pbb_cti_chain (current_cpu, sem_arg,
			       pbb_br_type, pbb_br_npc);
    BREAK (sem);
#else
    /* FIXME: Allow provision of explicit ifmt spec in insn spec.  */
    vpc = @prefix@_pbb_cti_chain (current_cpu, sem_arg,
			       CPU_PBB_BR_TYPE (current_cpu),
			       CPU_PBB_BR_NPC (current_cpu));
#endif
#endif
  }
"))
		))

    (-virtual-insn-add!
     ordinal
     (insn-read context
		'(name x-before)
		'(comment "pbb begin handler")
		`(attrs VIRTUAL PBB (ISA ,all))
		'(syntax "--before--")
		'(semantics (c-code VOID "\
  {
#if WITH_SCACHE_PBB_@PREFIX@
    @prefix@_pbb_before (current_cpu, sem_arg);
#endif
  }
"))
		))

    (-virtual-insn-add!
     ordinal
     (insn-read context
		'(name x-after)
		'(comment "pbb after handler")
		`(attrs VIRTUAL PBB (ISA ,all))
		'(syntax "--after--")
		'(semantics (c-code VOID "\
  {
#if WITH_SCACHE_PBB_@PREFIX@
    @prefix@_pbb_after (current_cpu, sem_arg);
#endif
  }
"))
		))

    (-virtual-insn-add!
     ordinal
     (insn-read context
		'(name x-invalid)
		'(comment "invalid insn handler")
		`(attrs VIRTUAL (ISA ,all))
		'(syntax "--invalid--")
		(list 'semantics (list 'c-code 'VOID (string-append "\
  {
    /* Update the recorded pc in the cpu state struct.
       Only necessary for WITH_SCACHE case, but to avoid the
       conditional compilation ....  */
    SET_H_PC (pc);
    /* Virtual insns have zero size.  Overwrite vpc with address of next insn
       using the default-insn-bitsize spec.  When executing insns in parallel
       we may want to queue the fault and continue execution.  */
    vpc = SEM_NEXT_VPC (sem_arg, pc, " (number->string (bits->bytes (state-default-insn-bitsize))) ");
    vpc = sim_engine_invalid_insn (current_cpu, pc, vpc);
  }
")))
		))
    )
)

(define (sim-finish!)
  ; Add begin,chain,before,after,invalid handlers if not provided.
  ; The code generators should first look for x-foo-@prefix@, then for x-foo.
  ; ??? This is good enough for the first pass.  Will eventually need to use
  ; less C and more RTL.
  (-create-virtual-insns!)

  *UNSPECIFIED*
)

; Called after file is read in and global error checks are done
; to initialize tables.

(define (sim-analyze!)
  *UNSPECIFIED*
)

; Scan insns, analyzing semantics and computing instruction formats.
; 'twould be nice to do this in sim-analyze! but it doesn't know whether this
; needs to be done or not (which is determined by what files are being
; generated).  Since this is an expensive operation, we defer doing this
; to the files that need it.

(define (sim-analyze-insns!)
  ; This can only be done if one isa and one cpu family is being kept.
  (assert-keep-one)

  (if (not -sim-insns-analyzed?)

      (begin
	(arch-analyze-insns! CURRENT-ARCH
			     #f ; don't include aliases
			     #t) ; do analyze the semantics

	; Compute the set of sformat argument buffers.
	(set! -sim-sformat-abuf-list (compute-sformat-argbufs! (current-sfmt-list)))

	(set! -sim-insns-analyzed? #t)))

  ; Do our own error checking.
  (assert (current-insn-lookup 'x-invalid))

  *UNSPECIFIED*
)

; For debugging.

(define (cgen-all-arch)
  (string-write
   cgen-arch.h
   cgen-arch.c
   cgen-cpuall.h
   ;cgen-mem-ops.h
   ;cgen-sem-ops.h
   ;cgen-ops.c
   )
)

(define (cgen-all-cpu)
  (string-write
   cgen-cpu.h
   cgen-cpu.c
   cgen-decode.h
   cgen-decode.c
   ;cgen-extract.c
   cgen-read.c
   cgen-write.c
   cgen-semantics.c
   cgen-sem-switch.c
   cgen-model.c
   ;cgen-mainloop.in
   )
)
