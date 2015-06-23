; Simulator generator support routines.
; Copyright (C) 2000, 2005, 2009 Red Hat, Inc.
; This file is part of CGEN.

; One goal of this file is to provide cover functions for all methods.
; i.e. this file fills in the missing pieces of the interface between
; the application independent part of CGEN (i.e. the code loaded by read.scm)
; and the application dependent part (i.e. sim-*.scm).
; `send' is not intended to appear in sim-*.scm.
; [It still does but that's to be fixed.]

; Specify which application.
(set! APPLICATION 'SID-SIMULATOR)

; Misc. state info.

; Currently supported options:
; with-scache
;	generate code to use the scache engine
; with-pbb
;	generate code to use the pbb engine
; with-sem-frags
;	generate semantic fragment engine (requires with-pbb)
; with-profile fn|sw
;	generate code to do profiling in the semantic function
;	code (fn) or in the semantic switch (sw)
; with-multiple-isa
;	enable multiple-isa support (e.g. arm+thumb)
;	??? wip.
; copyright fsf|redhat
;	emit an FSF or Red Hat copyright (temporary, pending decision)
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

; #t if semantics are generated as pbb computed-goto engine
(define -with-pbb? #f)
(define (with-pbb?) -with-pbb?)

; #t if the semantic fragment engine is to be used.
; This involves combining common fragments of each insn into one.
(define -with-sem-frags? #f)
(define (with-sem-frags?) -with-sem-frags?)

; String containing copyright text.
(define CURRENT-COPYRIGHT #f)

; String containing text defining the package we're generating code for.
(define CURRENT-PACKAGE #f)

; Initialize the options.

(define (option-init!)
  (set! -with-scache? #f)
  (set! -with-pbb? #f)
  (set! -with-sem-frags? #f)
  (set! -with-profile-fn? #f)
  (set! -with-profile-sw? #f)
  (set! -with-multiple-isa? #f)
  (set! CURRENT-COPYRIGHT copyright-fsf)
  (set! CURRENT-PACKAGE package-gnu-simulators)
  *UNSPECIFIED*
)

; Handle an option passed in from the command line.

(define (option-set! name value)
  (case name
    ((with-scache) (set! -with-scache? #t))
    ((with-pbb) (set! -with-pbb? #t))
    ((with-sem-frags) (set! -with-sem-frags? #t))
    ((with-profile) (cond ((equal? value '("fn"))
			   (set! -with-profile-fn? #t))
			  ((equal? value '("sw"))
			   (set! -with-profile-sw? #t))
			  (else (error "invalid with-profile value" value))))
    ((with-multiple-isa) (set! -with-multiple-isa? #t))
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

; #t if we're currently generating a pbb engine.
(define -current-pbb-engine? #f)
(define (current-pbb-engine?) -current-pbb-engine?)
(define (set-current-pbb-engine?! flag) (set! -current-pbb-engine? flag))

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

; Misc. utilities.

; Return reference to hardware element SYM.
; ISAS is a list of <isa> objects.
; The idea is that in multiple isa architectures (e.g. arm) the elements
; common to all isas are kept in one class and the elements specific to each
; isa are kept in separate classes.

(define (gen-cpu-ref isas sym)
  (if (and (with-multiple-isa?)
	   (= (length isas) 1))
      (string-append "current_cpu->@cpu@_hardware." sym)
      (string-append "current_cpu->hardware." sym))
)

; Attribute support.

; Return C code to fetch a value from instruction memory.
; PC-VAR is the C expression containing the address of the start of the
; instruction.
;
; We don't bother trying to handle bitsizes that don't have a
; corresponding GETIMEM method.  Doing so would require us to take
; endianness into account just to ensure that the requested bits end
; up at the proper place in the result.  It's easier just to make the
; caller ask us for something we can do directly.
;
; ??? Aligned/unaligned support?

(define (gen-ifetch pc-var bitoffset bitsize)
  (string-append "current_cpu->GETIMEM"
		 (case bitsize
		   ((8) "UQI")
		   ((16) "UHI")
		   ((32) "USI")
		   (else (error "bad bitsize argument to gen-ifetch" bitsize)))
		 " (pc, "
		 pc-var " + " (number->string (quotient bitoffset 8))
		 ")")
)

; Return definition of an object's attributes.
; This is like gen-obj-attr-defn, except split for sid.
; TYPE is one of 'ifld, 'hw, 'operand, 'insn.
; [Only 'insn is currently needed.]
; ALL-ATTRS is an ordered alist of all attributes.
; "ordered" means all the non-boolean attributes are at the front and
; duplicate entries have been removed.

(define (gen-obj-attr-sid-defn type obj all-attrs)
  (let* ((attrs (obj-atlist obj))
	 (non-bools (attr-non-bool-attrs (atlist-attrs attrs)))
	 (all-non-bools (list-take (attr-count-non-bools all-attrs) all-attrs))
	 )
    (string-append
     "{ "
     (gen-bool-attrs attrs gen-attr-mask)
     ","
     (if (null? all-non-bools)
	 " 0"
	 (string-drop1 ; drop the leading ","
	  (string-map (lambda (attr)
			(let ((val (or (assq-ref non-bools (obj:name attr))
				       (attr-default attr))))
			  ; FIXME: Are we missing attr-prefix here?
			  (string-append ", "
					 (send attr 'gen-value-for-defn-raw val))))
		      all-non-bools)))
     " }"))
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
; gen-write     - Same as gen-read except done on output operands
; cxmake-get    - Return a <c-expr> object to fetch the value.
; gen-set-quiet - Set the value.
;                 ??? Could just call this gen-set as there is no gen-set-trace
;                 but for consistency with the messages passed to operands
;                 we use this same.
; gen-type      - C type to use to record value.
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
   ;(if (not (eq? 'ifield (hw-index:type index)))
   ;    (error "not an ifield hw-index" index))
   (-cxmake-ifld-val mode (hw-index:value index)))
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
	((current-pbb-engine?)
	 (string-append "npc = " (cx:c newval) ";"
			(if (obj-has-attr? newval 'CACHED)
			    " br_status = BRANCH_CACHEABLE;"
			    " br_status = BRANCH_UNCACHEABLE;")
			(if (assq #:delay (estate-modifiers estate))
			    (string-append " current_cpu->delay_slot_p = true;"
					   " current_cpu->delayed_branch_address = npc;\n")
			    "\n")
			))
	((assq #:delay (estate-modifiers estate))
	 (string-append "current_cpu->delayed_branch (" (cx:c newval) ", npc, status);\n"))
	(else
	 (string-append "current_cpu->branch (" (cx:c newval) ", npc, status);\n")))
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
			(cx:make VOID (string-append access-macro
						   " (" (gen-sym op) ")")))))
)

(method-make!
 <hw-pc> 'cxmake-skip
 (lambda (self estate yes?)
   (cx:make VOID
	    (string-append "if ("
			   yes?
			   ") {\n"
			   (if (current-pbb-engine?)
			       (string-append "  vpc = current_cpu->skip (vpc);\n")
			       (string-append "  npc = current_cpu->skip (pc);\n"))
			   "}\n")))
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
   ; For array registers, we need to store away the index. 
   (if (hw-scalar? (op:type op))
       #f
       UINT))
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
			  (cx:make VOID (string-append access-macro
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
   (-gen-hw-index-raw index estate)
   ;(send index 'gen-extracted-field-value)
   )
)

; Utilities to generate register accesses via cover functions.

(define (-hw-gen-fun-get reg estate mode index)
  (let ((scalar? (hw-scalar? reg))
	(c-index (-gen-hw-index index estate)))
    (string-append "current_cpu->"
		   (gen-reg-get-fun-name reg)
		   " ("
		   (if scalar? "" (string-drop 2 (gen-c-args c-index)))
		   ")"))
)

(define (-hw-gen-fun-set reg estate mode index newval)
  (let ((scalar? (hw-scalar? reg))
	(c-index (-gen-hw-index index estate)))
    (string-append "current_cpu->"
		   (gen-reg-set-fun-name reg)
		   " ("
		   (if scalar? "" (string-append (string-drop 2 (gen-c-args c-index)) ", "))
		   (cx:c newval)
		   ");\n"))
)

; Utility to build a <c-expr> object to fetch the value of a register.

(define (-hw-cxmake-get hw estate mode index selector)
  (let ((mode (if (mode:eq? 'DFLT mode)
		  (send hw 'get-mode)
		  mode)))
    ; If the register is accessed via a cover function/macro, do it.
    ; Otherwise fetch the value from the cached address or from the CPU struct.
    (cx:make mode
	     (cond ((or (hw-getter hw)
			(obj-has-attr? hw 'FUN-GET))
		    (-hw-gen-fun-get hw estate mode index))
		   ((and (hw-cache-addr? hw) ; FIXME: redo test
			 (eq? 'ifield (hw-index:type index)))
		    (string-append
		     "* "
		     (if (with-scache?)
			 (gen-hw-index-argbuf-ref index)
			 (gen-hw-index-argbuf-name index))))
		   (else (gen-cpu-ref (hw-isas hw)
				      (send hw 'gen-ref
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
    (cx:make mode (gen-cpu-ref (hw-isas self)
			       (send self 'gen-ref
				     (gen-sym self) index estate)))))
)

; Utilities to generate C code to assign a variable to a register.

(define (-hw-gen-set-quiet hw estate mode index selector newval)
  (cond ((or (hw-setter hw)
	     (obj-has-attr? hw 'FUN-SET))
	 (-hw-gen-fun-set hw estate mode index newval))
	((and (hw-cache-addr? hw) ; FIXME: redo test
	      (eq? 'ifield (hw-index:type index)))
	 (string-append "* "
			(if (with-scache?)
			    (gen-hw-index-argbuf-ref index)
			    (gen-hw-index-argbuf-name index))
			" = " (cx:c newval) ";\n"))
	(else (string-append (gen-cpu-ref (hw-isas hw)
					  (send hw 'gen-ref
						(gen-sym hw) index estate))
			     " = " (cx:c newval) ";\n")))
)

(method-make! <hw-register> 'gen-set-quiet -hw-gen-set-quiet)

; raw-reg: support
; ??? wip

(method-make!
 <hw-register> 'gen-set-quiet-raw
 (lambda (self estate mode index selector newval)
   (string-append (gen-cpu-ref (hw-isas self)
			       (send self 'gen-ref
				     (gen-sym self) index estate))
		  " = " (cx:c newval) ";\n"))
)

; Return method name of access function.
; Common elements have no prefix.
; Elements specific to a particular isa are prefixed with @prefix@_.

(define (gen-reg-get-fun-name hw)
  (string-append (if (and (with-multiple-isa?)
			  (= (length (hw-isas hw)) 1))
		     (string-append (gen-sym (car (hw-isas hw))) "_")
		     "")
		 (gen-sym hw)
		 "_get")
)

(define (gen-reg-set-fun-name hw)
  (string-append (if (and (with-multiple-isa?)
			  (= (length (hw-isas hw)) 1))
		     (string-append (gen-sym (car (hw-isas hw))) "_")
		     "")
		 (gen-sym hw)
		 "_set")
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
	      (string-append "current_cpu->GETMEM" (obj:str-name mode)
			     (if default-selector? "" "ASI")
			     " ("
			     "pc, "
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
     (string-append "current_cpu->SETMEM" (obj:str-name mode)
		    (if default-selector? "" "ASI")
		    " ("
		    "pc, "
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
  (rtl-c++ 'INT sel nil)
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
     ; If default mode, use the type's type.
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
	 (rtl-c++ INT yes? nil #:rtl-cover-fns? #t)))
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
	 (string-append "  if (written & (1ULL << "
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
   (let* ((mode (if (mode:eq? 'DFLT mode)
		    (send self 'get-mode)
		    mode))
	  (hw (op:type self))
	  (index (if index index (op:index self)))
	  (idx (if index (-gen-hw-index index estate) ""))
	  (idx-args (if (equal? idx "") "" (string-append ", " idx)))
	  (selector (if selector selector (op:selector self)))
	  (delayval (op:delay self))
	  (md (mode:c-type mode))
	  (name (if 
		 (eq? (obj:name hw) 'h-memory)
		 (string-append md "_memory")
		 (gen-c-symbol (obj:name hw))))
	  (getter (op:getter self))
	  (def-val (cond ((obj-has-attr? self 'RAW)
			  (send hw 'cxmake-get-raw estate mode index selector))
			 (getter
			  (let ((args (car getter))
				(expr (cadr getter)))
			    (rtl-c-expr mode expr
					(if (= (length args) 0) nil
					    (list (list (car args) 'UINT index)))
					#:rtl-cover-fns? #t
					#:output-language (estate-output-language estate))))
			 (else
			  (send hw 'cxmake-get estate mode index selector)))))
     
     (logit 4 "<operand> cxmake-get self=" (obj:name self) " mode=" (obj:name mode)
	    " index=" (obj:name index) " selector=" selector "\n")
     
     (if delayval
	 (cx:make mode (string-append "lookahead ("
				      (number->string delayval)
				      ", tick, " 
				      "buf." name "_writes, " 
				      (cx:c def-val) 
				      idx-args ")"))
	 def-val)))
)


; Utilities to implement gen-set-quiet/gen-set-trace.

(define (-op-gen-set-quiet op estate mode index selector newval)
  (send (op:type op) 'gen-set-quiet estate mode index selector newval)
)

(define (-op-gen-delayed-set-quiet op estate mode index selector newval)
  (-op-gen-delayed-set-maybe-trace op estate mode index selector newval #f))


(define (-op-gen-set-trace op estate mode index selector newval)
  (string-append
   "  {\n"
   "    " (mode:c-type mode) " opval = " (cx:c newval) ";\n"
   (if (and (with-profile?)
	    (op:cond? op))
       (string-append "    written |= (1ULL << "
		      (number->string (op:num op))
		      ");\n")
       "")
; TRACE_RESULT_<MODE> (cpu, abuf, hwnum, opnum, value);
; For each insn record array of operand numbers [or indices into
; operand instance table].
; Could just scan the operand table for the operand or hardware number,
; assuming the operand number is stored in `op'.
   (if (current-pbb-engine?)
       ""
       (string-append
	"    if (UNLIKELY(current_cpu->trace_result_p))\n"
	"      current_cpu->trace_stream << "
	(send op 'gen-pretty-name mode)
	(if (send op 'get-index-mode)
	    (string-append
	     " << '['"
	     " << " 
	     ; print memory addresses in hex
	     (if (string=? (send op 'gen-pretty-name mode) "\"memory\"")
		 " \"0x\" << hex << (UDI) "
		 "")
	     (-gen-hw-index index estate)
	     (if (string=? (send op 'gen-pretty-name mode) "\"memory\"")
		 " << dec"
		 "")
	     " << ']'")
	    "")
	" << \":=0x\" << hex << "
	; Add (SI) or (USI) cast for byte-wide data, to prevent C++ iostreams
	; from printing byte as plain raw char.
	(if (mode:eq? 'QI mode)
	    "(SI) "
	    (if (mode:eq? 'UQI mode)
		"(USI) "
		""))
	"opval << dec << \"  \";\n"))
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
		#:rtl-cover-fns? #t
		#:output-language (estate-output-language estate)))
       ;else
       (send (op:type op) 'gen-set-quiet estate mode index selector
		(cx:make-with-atlist mode "opval" (cx:atlist newval))))
   "  }\n")
)

(define (-op-gen-delayed-set-trace op estate mode index selector newval)
  (-op-gen-delayed-set-maybe-trace op estate mode index selector newval #t))

(define (-op-gen-delayed-set-maybe-trace op estate mode index selector newval do-trace?)
  (let* ((pad "    ")
	 (hw (op:type op))
	 (delayval (op:delay op))
	 (md (mode:c-type mode))
	 (name (if 
		(eq? (obj:name hw) 'h-memory)
		(string-append md "_memory")
		(gen-c-symbol (obj:name hw))))
	 (val (cx:c newval))
	 (idx (if index (-gen-hw-index index estate) ""))
	 (idx-args (if (equal? idx "") "" (string-append ", " idx)))
	 )
    
    (if delayval
	(if (eq? (obj:name hw) 'h-memory)
	    (set write-stack-memory-mode-names (cons md write-stack-memory-mode-names))
	    (elm-set! hw 'used-in-delay-rtl? #t)))

    (string-append
     "  {\n"

     (if delayval 

	 ;; delayed write: push it to the appropriate buffer
	 (string-append	    
	  pad md " opval = " val ";\n"
	  pad "buf." name "_writes [(tick + " (number->string delayval)
	  ") % @prefix@::pipe_sz].push (@prefix@::write<" md ">(pc, opval" idx-args "));\n")

	 ;; else, uh, we should never have been called!
	 (error "-op-gen-delayed-set-maybe-trace called on non-delayed operand"))       
     
     
     (if do-trace?

	 (string-append
; TRACE_RESULT_<MODE> (cpu, abuf, hwnum, opnum, value);
; For each insn record array of operand numbers [or indices into
; operand instance table].
; Could just scan the operand table for the operand or hardware number,
; assuming the operand number is stored in `op'.
   "    if (UNLIKELY(current_cpu->trace_result_p))\n"
   "      current_cpu->trace_stream << "
   (send op 'gen-pretty-name mode)
   (if (send op 'get-index-mode)
       (string-append
	" << '['"
	" << " 
					; print memory addresses in hex
	(if (string=? (send op 'gen-pretty-name mode) "\"memory\"")
	    " \"0x\" << hex << (UDI) "
	    "")
	(-gen-hw-index index estate)
	(if (string=? (send op 'gen-pretty-name mode) "\"memory\"")
	    " << dec"
	    "")
	" << ']'")
       "")
   " << \":=0x\" << hex << "
   ;; Add (SI) or (USI) cast for byte-wide data, to prevent C++ iostreams
   ;; from printing byte as plain raw char.
   (if (mode:eq? 'QI mode)
       "(SI) "
       (if (mode:eq? 'UQI mode)
	   "(USI) "
	   ""))
   "opval << dec << \"  \";\n"
   "  }\n")
	 ;; else no tracing is emitted
	 ""))))

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
     (cond ((obj-has-attr? self 'RAW)
	    (send (op:type self) 'gen-set-quiet-raw estate mode index selector newval))
	   ((op:delay self)
	    (-op-gen-delayed-set-quiet self estate mode index selector newval))
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
     (cond ((obj-has-attr? self 'RAW)
	    (send (op:type self) 'gen-set-quiet-raw estate mode index selector newval))
	   ((op:delay self)
	    (-op-gen-delayed-set-trace self estate mode index selector newval))
	   (else
	    (-op-gen-set-trace self estate mode index selector newval)))))
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
  (let ((estate (vmake <rtl-c-eval-state>
		       #:rtl-cover-fns? #t
		       #:output-language "c++")))
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
		      (gen-argbuf-ref (string-append (if out? "out_" "in_")
						     (gen-sym self)))
		      " = "
		      (send (op:type self) 'gen-record-profile
			    (op:index self) sfmt estate)
		      ";\n")))
)

; Return C code to track profiling of operand SELF.
; This is usually called by the x-after handler.

(method-make!
 <operand> 'gen-profile-code
 (lambda (self insn when out?)
   (string-append "  "
		  "@prefix@_model_mark_"
		  (if out? "set_" "get_")
		  (gen-sym (op:type self))
		  "_" when
		  " (current_cpu"
		  (if (hw-scalar? (op:type self))
		      ""
		      (string-append ", "
				     (gen-argbuf-ref
				      (string-append (if out? "out_" "in_")
						     (gen-sym self)))))
		  ");\n"))
)

; CPU, mach, model support.

; Return the declaration of the cpu/insn enum.

(define (gen-cpu-insn-enum-decl cpu insn-list)
  (gen-enum-decl "@prefix@_insn_type"
		 "instructions in cpu family @prefix@"
		 "@PREFIX@_INSN_"
		 (append (map (lambda (i)
				(cons (obj:name i)
				      (cons '-
					    (atlist-attrs (obj-atlist i)))))
			      insn-list)
			 (if (with-parallel?)
			     (apply append
				    (map (lambda (i)
					   (list
					    (cons (symbol-append 'par- (obj:name i))
						  (cons '-
							(atlist-attrs (obj-atlist i))))
					    (cons (symbol-append 'write- (obj:name i))
						  (cons '-
							(atlist-attrs (obj-atlist i))))))
					 (parallel-insns insn-list)))
			     nil)))
)

; Return the enum of INSN in cpu family CPU.
; In addition to CGEN_INSN_TYPE, an enum is created for each insn in each
; cpu family.  This collapses the insn enum space for each cpu to increase
; cache efficiently (since the IDESC table is similarily collapsed).

(define (gen-cpu-insn-enum cpu insn)
  (string-append "@PREFIX@_INSN_" (string-upcase (gen-sym insn)))
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
 (lambda (self unit-num insn when overrides cycles-var-name)
   (logit 3 "  'gen-profile-code\n")
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
			 (logit 3 "    gen-ref-arg\n")
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
			 (logit 3 "    gen-arg-unit\n")
			  (if (or
			       ; Ignore scalars.
			       (null? (cdr arg))
			       ; Ignore remapped arg, handled elsewhere.
			       (assq (car arg) overrides)
			       ; Ignore operands not in INSN.
			       (not (insn-op-lookup (car arg) insn
						    (if out? 'out 'in))))
			      ""
			      (string-append "    "
					     (if out? "out_" "in_")
					     (gen-c-symbol (car arg))
					     " = "
					     (gen-argbuf-ref
					      (string-append (if out? "out_" "in_")
							     (gen-c-symbol (car arg))))
					     ";\n"))))

	  ; Return C code to declare variable to hold unit argument ARG.
	  ; OUT? is #f for input args, #t for output args.
	  (gen-arg-decl (lambda (arg out?)
			 (logit 3 "    gen-arg-decl " arg out? "\n")
			  (if (null? (cdr arg)) ; ignore scalars
			      ""
			      (string-append "    "
					     (mode:c-type (mode:lookup (cadr arg)))
					     " "
					     (if out? "out_" "in_")
					     (gen-c-symbol (car arg))
					     " = "
					     (if (null? (cddr arg))
						 "0"
						 (number->string (caddr arg)))
					     ";\n"))))

	  ; Return C code to pass unit argument ARG to the handler.
	  ; OUT? is #f for input args, #t for output args.
	  (gen-arg-arg (lambda (arg out?)
			 (logit 3 "    gen-arg-arg\n")
			 (if (null? (cdr arg)) ; ignore scalars
			     ""
			     (string-append ", "
					    (if out? "out_" "in_")
					    (gen-c-symbol (car arg))))))
	  )

     (string-append
      "  {\n"
      (if (equal? when 'after)
	  (string-append
	   "    int referenced = 0;\n"
	   "    unsigned long long insn_referenced = abuf->written;\n")
	  "")
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
	(string-append
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
			   (string-append "    in_"
					  (gen-c-symbol (cadr arg))
					  " = "
					  (gen-argbuf-ref
					   (string-append
					    "in_"
					    (gen-c-symbol (caddr arg))))
					  ";\n")
			   ""))
		      ((out)
		       (if (caddr arg)
			   (string-append "    out_"
					  (gen-c-symbol (cadr arg))
					  " = "
					  (gen-argbuf-ref
					   (string-append
					    "out_"
					    (gen-c-symbol (caddr arg))))
					  ";\n")
			   ""))
		      (else
		       (parse-error (make-prefix-context "insn function unit spec")
				    "invalid spec" arg))))
		  overrides)
      ; Create bitmask indicating which args were referenced.
      (if (equal? when 'after)
	  (string-append
	   (string-map (lambda (arg num) (gen-ref-arg arg num 'in))
		       inputs
		       (iota (length inputs)))
	   (string-map (lambda (arg num) (gen-ref-arg arg num 'out))
		       outputs
		       (iota (length outputs)
			     (length inputs))))
	  "")
      ; Emit the call to the handler.
      "    " cycles-var-name " += "
      (gen-model-unit-fn-name (unit:model self) self when)
      " (current_cpu, idesc"
      ", " (number->string unit-num)
      (if (equal? when 'after) ", referenced" "")
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
 (lambda (self unit-num insn when cycles-var-name)
   (let ((args (iunit:args self))
	 (unit (iunit:unit self)))
     (send unit 'gen-profile-code unit-num insn when args cycles-var-name)))
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
 (lambda (self model when cycles-var-name)
   (string-append
    (let ((timing (assq-ref (insn-timing self) (obj:name model))))
      (if timing
	  (string-map (lambda (iunit unit-num)
			(send iunit 'gen-profile-code unit-num self when cycles-var-name))
		      (timing:units timing)
		      (iota (length (timing:units timing))))
	  (send (model-default-unit model) 'gen-profile-code 0 self when nil cycles-var-name)))
    ))
)

; Instruction support.

; Return list of all instructions to use for scache engine.
; This is all real insns plus the `invalid' and `cond' virtual insns.
; It does not include the pbb virtual insns.

(define (scache-engine-insns)
  (non-multi-insns (non-alias-pbb-insns (current-insn-list)))
)

; Return list of all instructions to use for pbb engine.
; This is all real insns plus the `invalid' and `cond' virtual insns.

(define (pbb-engine-insns)
  (non-multi-insns (real-insns (current-insn-list)))
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

(define (-create-virtual-insns! isa)
  (let ((isa-name (obj:name isa))
	(context (make-prefix-context "virtual insns"))
	;; Record as a pair so -virtual-insn-add! can update it.
	(ordinal (cons #f -1)))

    (-virtual-insn-add!
     ordinal
     (insn-read context
		'(name x-invalid)
		'(comment "invalid insn handler")
		`(attrs VIRTUAL (ISA ,isa-name))
		'(syntax "--invalid--")
		'(semantics (c-code VOID "\
  {
    current_cpu->invalid_insn (pc);
    assert (0);
    /* NOTREACHED */
  }
"))
		))

    (if (with-pbb?)
	(begin
	  (-virtual-insn-add!
	   ordinal
	   (insn-read context
		      '(name x-begin)
		      '(comment "pbb begin handler")
		      `(attrs VIRTUAL PBB (ISA ,isa-name))
		      '(syntax "--begin--")
		      '(semantics (c-code VOID "\
  {
    vpc = current_cpu->@prefix@_pbb_begin (current_cpu->h_pc_get ());
  }
"))
		      ))

	  (-virtual-insn-add!
	   ordinal
	   (insn-read context
		      '(name x-chain)
		      '(comment "pbb chain handler")
		      `(attrs VIRTUAL PBB (ISA ,isa-name))
		      '(syntax "--chain--")
		      '(semantics (c-code VOID "\
  {
    vpc = current_cpu->@prefix@_engine.pbb_chain (current_cpu, abuf);
    // If we don't have to give up control, don't.
    // Note that we may overrun step_insn_count since we do the test at the
    // end of the block.  This is defined to be ok.
    if (UNLIKELY(current_cpu->stop_after_insns_p (abuf->fields.chain.insn_count)))
      BREAK (vpc);
  }
"))
		      ))

	  (-virtual-insn-add!
	   ordinal
	   (insn-read context
		      '(name x-cti-chain)
		      '(comment "pbb cti-chain handler")
		      `(attrs VIRTUAL PBB (ISA ,isa-name))
		      '(syntax "--cti-chain--")
		      '(semantics (c-code VOID "\
  {
    vpc = current_cpu->@prefix@_engine.pbb_cti_chain (current_cpu, abuf, pbb_br_status, pbb_br_npc);
    // If we don't have to give up control, don't.
    // Note that we may overrun step_insn_count since we do the test at the
    // end of the block.  This is defined to be ok.
    if (UNLIKELY(current_cpu->stop_after_insns_p (abuf->fields.chain.insn_count)))
      BREAK (vpc);
  }
"))
		      ))

	  (-virtual-insn-add!
	   ordinal
	   (insn-read context
		      '(name x-before)
		      '(comment "pbb before handler")
		      `(attrs VIRTUAL PBB (ISA ,isa-name))
		      '(syntax "--before--")
		      '(semantics (c-code VOID "\
  {
    current_cpu->@prefix@_engine.pbb_before (current_cpu, abuf);
  }
"))
		      ))

	  (-virtual-insn-add!
	   ordinal
	   (insn-read context
		      '(name x-after)
		      '(comment "pbb after handler")
		      `(attrs VIRTUAL PBB (ISA ,isa-name))
		      '(syntax "--after--")
		      '(semantics (c-code VOID "\
  {
    current_cpu->@prefix@_engine.pbb_after (current_cpu, abuf);
  }
"))
		      ))

	  ))

    ; If entire instruction set is conditionally executed, create a virtual
    ; insn to handle that.
    (if (and (with-pbb?)
	     (isa-conditional-exec? isa))
	(-virtual-insn-add!
	 ordinal
	 (insn-read context
		    '(name x-cond)
		    '(syntax "conditional exec test")
		    `(attrs VIRTUAL PBB (ISA ,isa-name))
		    '(syntax "--cond--")
		    (list 'semantics (list 'c-code 'VOID
					   (string-append "\
  {
    // Assume branch not taken.
    pbb_br_status = BRANCH_UNTAKEN;
    UINT cond_code = abuf->cond;
    BI exec_p = "
    (rtl-c++ DFLT (cadr (isa-condition isa)) '((cond-code UINT "cond_code"))
	     #:rtl-cover-fns? #t)
    ";
    if (! exec_p)
      ++vpc;
  }
")))
		    )))
    )
)

; Return a boolean indicating if INSN should be split.

(define (-decode-split-insn? insn isa)
  (let loop ((split-specs (isa-decode-splits isa)))
    (cond ((null? split-specs)
	   #f)
	  ((let ((f-name (decode-split-name (car split-specs))))
	     (and (insn-has-ifield? insn f-name)
		  (let ((constraint
			 (decode-split-constraint (car split-specs))))
		    (or (not constraint)
			(rtl-eval -FIXME-unfinished-)))))
	   #t)
	  (else (loop (cdr split-specs)))))		  
)

; Subroutine of -decode-split-insn-1.
; Build the ifield-assertion for ifield F-NAME.
; VALUE is either a number or a non-empty list of numbers.

(define (-decode-split-build-assertion f-name value)
  (if (number? value)
      (rtx-make 'eq 'INT (rtx-make 'ifield f-name) (rtx-make 'const 'INT value))
      (rtx-make 'member (rtx-make 'ifield f-name)
		(apply rtx-make (cons 'number-list (cons 'INT value)))))
)

; Subroutine of -decode-split-insn.
; Specialize INSN according to <decode-split> dspec.

(define (-decode-split-insn-1 insn dspec)
  (let ((f-name (decode-split-name dspec))
	(values (decode-split-values dspec)))
    (let ((result (map object-copy-top (make-list (length values) insn))))
      (for-each (lambda (insn-copy value)
		  (obj-set-name! insn-copy
				 (symbol-append (obj:name insn-copy)
						'-
						(car value)))
		  (obj-cons-attr! insn-copy (bool-attr-make 'DECODE-SPLIT #t))
		  (let ((existing-assertion (insn-ifield-assertion insn-copy))
			(split-assertion 
			 (-decode-split-build-assertion f-name (cadr value))))
		    (insn-set-ifield-assertion!
		     insn-copy
		     (if existing-assertion
			 (rtx-make 'andif split-assertion existing-assertion)
			 split-assertion)))
		  )
		result values)
      result))
)

; Split INSN.
; The result is a list of the split copies of INSN.

(define (-decode-split-insn insn isa)
  (logit 3 "Splitting " (obj:name insn) " ...\n")
  (let loop ((splits (isa-decode-splits isa)) (result nil))
    (cond ((null? splits)
	   result)
	  ; FIXME: check constraint
	  ((insn-has-ifield? insn (decode-split-name (car splits)))
	   ; At each iteration, split the result of the previous.
	   (loop (cdr splits)
		 (if (null? result)
		     (-decode-split-insn-1 insn (car splits))
		     (apply append
			    (map (lambda (insn)
				   (-decode-split-insn-1 insn (car splits)))
				 result)))))
	  (else
	   (loop (cdr splits) result))))
)

; Create copies of insns to be split.
; ??? better phrase needed?  Possible confusion with gcc's define-split.
; The original insns are then marked as aliases so the simulator ignores them.

(define (-fill-sim-insn-list!)
  (let ((isa (current-isa)))

    (if (not (null? (isa-decode-splits isa)))

	(begin
	  (logit 1 "Splitting instructions ...\n")
	  (for-each (lambda (insn)
		      (if (and (insn-real? insn)
			       (insn-semantics insn)
			       (-decode-split-insn? insn isa))
			  (let ((ord (obj-ordinal insn))
				(sub-ord 1))
			    (for-each (lambda (new-insn)
					;; Splice new insns next to original.
					;; Keeps things tidy and generated code
					;; easier to read for human viewer.
					;; This is done by using an ordinal of
					;; (major . minor).
					(obj-set-ordinal! new-insn
							  (cons ord sub-ord))
					(current-insn-add! new-insn)
					(set! sub-ord (+ sub-ord 1)))
				      (-decode-split-insn insn isa))
			    (obj-cons-attr! insn (bool-attr-make 'ALIAS #t)))))
		    (current-insn-list))
	  (logit 1 "Done splitting.\n"))
	))

  *UNSPECIFIED*
)

; .cpu file loading support

; Only run sim-analyze-insns! once.
(define -sim-insns-analyzed? #f)

; List of computed sformat argument buffers.
(define -sim-sformat-argbuf-list #f)
(define (current-sbuf-list) -sim-sformat-argbuf-list)

; Called before the .cpu file has been read in.

(define (sim-init!)
  (set! -sim-insns-analyzed? #f)
  (set! -sim-sformat-argbuf-list #f)
  (if (with-sem-frags?)
      (sim-sfrag-init!))
  *UNSPECIFIED*
)

; Called after the .cpu file has been read in.

(define (sim-finish!)
  ; Specify FUN-GET/SET in the .sim file to cause all hardware references to
  ; go through methods, thus allowing the programmer to override them.
  (define-attr '(for hardware) '(type boolean) '(name FUN-GET)
    '(comment "read hardware elements via cover functions/methods"))
  (define-attr '(for hardware) '(type boolean) '(name FUN-SET)
    '(comment "write hardware elements via cover functions/methods"))

  ; If there is a .sim file, load it.
  (let ((sim-file (string-append srcdir "/cpu/"
				 (symbol->string (current-arch-name))
				 ".sim")))
    (if (file-exists? sim-file)
	(begin
	  (display (string-append "Loading sim file " sim-file " ...\n"))
	  (reader-read-file! sim-file))))

  ; If we're building files for an isa, create the virtual insns.
  (if (not (keep-isa-multiple?))
      (-create-virtual-insns! (current-isa)))

  *UNSPECIFIED*
)

; Called after file is read in and global error checks are done
; to initialize tables.

(define (sim-analyze!)
  *UNSPECIFIED*
)

; Scan insns, copying them to the simulator insn list, splitting the
; requested insns, then analyze the semantics and compute instruction formats.
; 'twould be nice to do this in sim-analyze! but it doesn't know whether this
; needs to be done or not (which is determined by what files are being
; generated).  Since this is an expensive operation, we defer doing this
; to the files that need it.

(define (sim-analyze-insns!)
  ; This can only be done if one isa and one cpu family is being kept.
  (assert-keep-one)

  (if (not -sim-insns-analyzed?)

      (begin
	(-fill-sim-insn-list!)

	(arch-analyze-insns! CURRENT-ARCH
			     #f ; don't include aliases
			     #t) ; do analyze the semantics

	; Compute the set of sformat argument buffers.
	(set! -sim-sformat-argbuf-list
	      (compute-sformat-argbufs! (current-sfmt-list)))

	(set! -sim-insns-analyzed? #t)
	))

  ; Do our own error checking.
  (assert (current-insn-lookup 'x-invalid))

  *UNSPECIFIED*
)
