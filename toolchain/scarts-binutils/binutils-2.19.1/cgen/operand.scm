; Operands
; Copyright (C) 2000, 2001, 2005, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; Operands map a set of values (registers, whatever) to an instruction field
; or other indexing mechanism.  Operands are also how the semantic code refers
; to hardware elements.

; The `<operand>' class.
;
; ??? Need a new lighterweight version for instances in semantics.
; This should only contain the static elements from the description file.
;
; ??? Derived operands don't use all the current class members.  Perhaps
; split <operand> into two.

(define <operand>
  (class-make '<operand>
	      '(<source-ident>)
	      '(
		; Name as used in semantic code.
		; Generally this is the same as NAME.  It is changed by the
		; `operand:' rtx function.  One reason is to set a "pretty"
		; name in tracing output (most useful in memory operands).
		; A more important reason is to help match semantic operands
		; with function unit input/output arguments.
		sem-name

		; Pretty name as used in tracing code.
		; Generally this is the same as the hardware element's name.
		pretty-sem-name

		; Semantic name of hardware element refered to by this operand.
		hw-name

		; Hardware type of operand, a subclass of <hardware-base>.
		; This is computed lazily from HW-NAME as many hardware
		; elements can have the same semantic name.  Applications
		; that require a unique hardware element to be refered to are
		; required to ensure duplicates are discarded (usually done
		; by keeping the appropriate machs).
		; FIXME: Rename to hw.
		(type . #f)

		; Name of mode, as specified in description file.
		; This needn't be the actual mode, as WI will get coerced
		; to the actual word int mode.
		mode-name

		; The mode TYPE is being referenced in.
		; This is also looked up lazily for the same reasons as TYPE.
		(mode . #f)

		; Selector.
		; A number or #f used to select a variant of the hardware
		; element.  An example is ASI's on sparc.
		; ??? I really need to be better at picking names.
		(selector . #f)

		; Index into type, class <hw-index>.
		; For example in the case of an array of registers
		; it can be an instruction field or in the case of a memory
		; reference it can be a register operand (or general rtx).
		; ??? At present <hw-index> is a facade over the real index
		; type.  Not sure what the best way to do this is.
		(index . #f)

		; Code to run when the operand is read or #f meaning pass
		; the request on to the hardware object.
		(getter . #f)

		; Code to run when the operand is written or #f meaning pass
		; the request on to the hardware object.
		(setter . #f)

		; Associative list of (symbol . "handler") entries.
		; Each entry maps an operation to its handler (which is up to
		; the application but is generally a function name).
		(handlers . ())

		; Ordinal number of the operand in an insn's semantic
		; description.  There is no relation between the number and
		; where in the semantics the operand appears.  An operand that
		; is both read and written are given separate ordinal numbers
		; (inputs are treated separately from outputs).
		(num . -1)

		; Boolean indicating if the operand is conditionally
		; referenced.  #f means the operand is always referenced by
		; the instruction.
		(cond? . #f)
		
		; whether (and by how much) this instance of the operand is
		; delayed.
		(delayed . #f)
		)
	      nil)
)

; The default make! assigns the default h/w selector.

(method-make!
 <operand> 'make!
 (lambda (self location name comment attrs
	       hw-name mode-name index handlers getter setter)
   (elm-set! self 'location location)
   (elm-set! self 'name name)
   (elm-set! self 'sem-name name)
   (elm-set! self 'pretty-sem-name hw-name)
   (elm-set! self 'comment comment)
   (elm-set! self 'attrs attrs)
   (elm-set! self 'hw-name hw-name)
   (elm-set! self 'mode-name mode-name)
   (elm-set! self 'selector hw-selector-default)
   (elm-set! self 'index index)
   (elm-set! self 'handlers handlers)
   (elm-set! self 'getter getter)
   (elm-set! self 'setter setter)
   self)
)

; FIXME: The prefix field- doesn't seem right.  Indices needn't be
; ifields, though for operands defined in .cpu files they usually are.
(method-make-forward! <operand> 'index '(field-start field-length))

; Accessor fns

(define op:sem-name (elm-make-getter <operand> 'sem-name))
(define op:set-sem-name! (elm-make-setter <operand> 'sem-name))
(define op:set-pretty-sem-name! (elm-make-setter <operand> 'pretty-sem-name))
(define op:hw-name (elm-make-getter <operand> 'hw-name))
(define op:mode-name (elm-make-getter <operand> 'mode-name))
(define op:selector (elm-make-getter <operand> 'selector))
; FIXME: op:index should be named op:hwindex.
(define op:index (elm-make-getter <operand> 'index))
(define op:handlers (elm-make-getter <operand> 'handlers))
(define op:getter (elm-make-getter <operand> 'getter))
(define op:setter (elm-make-getter <operand> 'setter))
(define op:num (elm-make-getter <operand> 'num))
(define op:set-num! (elm-make-setter <operand> 'num))
(define op:cond? (elm-make-getter <operand> 'cond?))
(define op:set-cond?! (elm-make-setter <operand> 'cond?))
(define op:delay (elm-make-getter <operand> 'delayed))
(define op:set-delay! (elm-make-setter <operand> 'delayed))

; Compute the hardware type lazily.
; FIXME: op:type should be named op:hwtype or some such.

(define op:type
  (let ((getter (elm-make-getter <operand> 'type)))
    (lambda (op)
      (let ((type (getter op)))
	(if type
	    type
	    (let* ((hw-name (op:hw-name op))
		   (hw-objs (current-hw-sem-lookup hw-name)))
	      (if (!= (length hw-objs) 1)
		  (error "cannot resolve h/w reference" hw-name))
	      ((elm-make-setter <operand> 'type) op (car hw-objs))
	      (car hw-objs))))))
)

; Compute the operand's mode lazily (depends on hardware type which is
; computed lazily).

(define op:mode
  (let ((getter (elm-make-getter <operand> 'mode)))
    (lambda (op)
      (let ((mode (getter op)))
	(if mode
	    mode
	    (let ((mode-name (op:mode-name op))
		  (type (op:type op)))
	      (let ((mode (if (eq? mode-name 'DFLT)
			      (hw-default-mode type)
			      (mode:lookup mode-name))))
		((elm-make-setter <operand> 'mode) op mode)
		mode))))))
)

(method-make! <operand> 'get-mode (lambda (self) (op:mode self)))

; FIXME: wip
; Result is the <ifield> object or #f if there is none.

(define (op-ifield op)
  (logit 4 "  op-ifield op= " (obj:name op)
	 ", indx= " (obj:name (op:index op)) "\n")
  (let ((indx (op:index op)))
    (if indx
	(let ((maybe-ifld (hw-index:value (op:index op))))
	  (logit 4 "  ifld=" (obj:name maybe-ifld) "\n")
	  (cond ((ifield? maybe-ifld) maybe-ifld)
		((derived-ifield? maybe-ifld) maybe-ifld)
		((ifield? indx) indx)
		((derived-ifield? indx) indx)
		(else #f)))
	#f))
)

; Return mode to use for index or #f if scalar.
; This can't use method-make-forward! as we need to call op:type to
; resolve the hardware reference.

(method-make!
 <operand> 'get-index-mode
 (lambda (self) (send (op:type self) 'get-index-mode))
)

; Return the operand's enum.

(define (op-enum op)
  (string-upcase (string-append "@ARCH@_OPERAND_" (gen-sym op)))
)

; Return a boolean indicating if X is an operand.

(define (operand? x) (class-instance? <operand> x))

; Default gen-pretty-name method.
; Return a C string of the name intended for users.
;
; FIXME: The current implementation is a quick hack.  Parallel execution
; support can create operands with long names.  e.g. h-memory-add-WI-src2-slo16
; The eventual way this will be handled is to record with each operand the
; entry number (or some such) in the operand instance table so that for
; registers we can compute the register's name.

(method-make!
 <operand> 'gen-pretty-name
 (lambda (self mode)
   (let* ((name (->string (if (elm-bound? self 'pretty-sem-name)
			      (elm-get self 'pretty-sem-name) 
			      (if (elm-bound? self 'sem-name)
				  (elm-get self 'sem-name)
				  (obj:name self)))))
	  (pname (cond ((string=? "h-memory" (string-take 8 name)) "memory")
		       ((string=? "h-" (string-take 2 name)) (string-drop 2 name))
		       (else name))))
     (string-append "\"" pname "\"")))
)

; PC support.
; This is a subclass of <operand>, used to give the simulator a place to
; hang a couple of methods.
; At the moment we only support one pc, a reasonable place to stop for now.

(define <pc> (class-make '<pc> '(<operand>) nil nil))

(method-make!
 <pc> 'make!
 (lambda (self)
   (send-next self 'make! (builtin-location) 'pc "program counter"
	      (atlist-parse (make-prefix-context "make! of pc")
			    '(SEM-ONLY) "cgen_operand")
	      'h-pc
	      'DFLT
	      (make <hw-index> 'anonymous
		    'ifield 'UINT (current-ifld-lookup 'f-nil))
	      nil ; handlers
	      #f #f) ; getter setter
   self)
)

; Return a boolean indicating if operand op is the pc.
; This must not call op:type.  op:type will try to resolve a hardware
; element that may be multiply specified, and this is used in contexts
; where that's not possible.

(define (pc? op) (class-instance? <pc> op))

; Mode support.

; Create a copy of operand OP in mode NEW-MODE-NAME.
; NOTE: Even if the mode isn't changing this creates a copy.
; If OP has been subclassed the result must contain the complete class
; (e.g. the behaviour of `object-copy-top').

(define (op:new-mode op new-mode-name)
  (let ((result (object-copy-top op)))
    ; (logit 1 "op:new-mode op=" (op:sem-name op) 
    ;   " class=" (object-class-name op)
    ;   " hw-name=" (op:hw-name op)
    ;   " mode=" (op:mode op)
    ;   " newmode=" new-mode-name)
    (if (or (eq? new-mode-name 'DFLT)
	    (eq? new-mode-name 'VOID) ; temporary: for upward compatibility
	    (mode:eq? new-mode-name (op:mode op)))
	; Mode isn't changing.
	result
	; See if new mode is supported by the hardware.
	(if (hw-mode-ok? (op:type op) new-mode-name (op:index op))
	    (let ((new-mode (mode:lookup new-mode-name)))
	      (if (not new-mode)
		  (error "op:new-mode: internal error, bad mode"
			 new-mode-name))
	      (elm-xset! result 'mode-name new-mode-name)
	      (elm-xset! result 'mode new-mode)
	      result)
	    (parse-error (make-obj-context op "op:new-mode")
			 (string-append "invalid mode for operand `"
					(->string (obj:name op))
					"'")
			 new-mode-name))))
)

; Return #t if operand OP references its h/w element in its natural mode.

(define (op-natural-mode? op)
  (or (eq? (op:mode-name op) 'DFLT)
      (mode-compatible? 'samesize (op:mode op) (hw-default-mode (op:type op))))
)

; Ifield support.

; Return list of ifields used by OP.

(define (op-iflds-used op)
  (if (derived-operand? op)
      (collect op-iflds-used (derived-args op))
      ; else
      (let ((indx (op:index op)))
	(if (and (eq? (hw-index:type indx) 'ifield)
		 (not (= (ifld-length (hw-index:value indx)) 0)))
	    (ifld-needed-iflds (hw-index:value indx))
	    nil)))
)

; The `hw-index' class.
; [Was named `index' but that conflicts with the C library function and caused
; problems when using Hobbit.  And `index' is too generic a name anyway.]
;
; An operand combines a hardware object with its index.
; e.g. in an array of registers an operand serves to combine the register bank
; with the instruction field that chooses which one.
; Hardware elements are accessed via other means as well besides instruction
; fields so we need a way to designate something as being an index.
; The `hw-index' class does that.  It serves as a facade to the underlying
; details.
; ??? Not sure whether this is the best way to handle this or not.
;
; NAME is the name of the index or 'anonymous.
; This is used, for example, to give a name to the simulator extraction
; structure member.
; TYPE is a symbol that indicates what VALUE is.
; scalar: the hardware object is a scalar, no index is required
;         [MODE and VALUE are #f to denote "undefined" in this case]
; constant: a (non-negative) integer
; str-expr: a C expression as a string
; rtx: an rtx to be expanded
; ifield: an ifield object
; operand: an operand object
; ??? A useful simplification may be to always record the value as an rtx
; [which may require extensions to rtl so is deferred].
; ??? We could use runtime type identification, but doing things this way
; adds more structure.
;
; MODE is the mode of VALUE.  If DFLT, mode must be obtained from VALUE.
; DFLT is only allowable for rtx and operand types.

(define <hw-index> (class-make '<hw-index> nil '(name type mode value) nil))

; Accessors.
; Use obj:name for `name'.
(define hw-index:type (elm-make-getter <hw-index> 'type))
(define hw-index:mode (elm-make-getter <hw-index> 'mode))
(define hw-index:value (elm-make-getter <hw-index> 'value))

; Allow the mode to be specified by its name.
(method-make!
 <hw-index> 'make!
 (lambda (self name type mode value)
   (elm-set! self 'name name)
   (elm-set! self 'type type)
   (elm-set! self 'mode (mode:lookup mode))
   (elm-set! self 'value value)
   self)
)

; get-name handler
(method-make!
 <hw-index> 'get-name
 (lambda (self)
   (elm-get self 'name))
)

; get-atlist handler
(method-make!
 <hw-index> 'get-atlist
 (lambda (self)
   (case (hw-index:type self)
     ((ifield) (obj-atlist (hw-index:value self)))
     (else atlist-empty)))
)

; ??? Until other things settle.
(method-make!
 <hw-index> 'field-start
 (lambda (self word-len)
   (if (eq? (hw-index:type self) 'ifield)
       (send (hw-index:value self) 'field-start #f)
       0))
)
(method-make!
 <hw-index> 'field-length
 (lambda (self)
   (if (eq? (hw-index:type self) 'ifield)
       (send (hw-index:value self) 'field-length)
       0))
)

; There only ever needs to be one of these objects, so create one.

(define hw-index-scalar
  ; We can't use `make' here as the make! method calls mode:lookup which
  ; (a) doesn't exist if we're compiled with Hobbit and mode.scm isn't
  ; and (b) will fail anyway since #f isn't a valid mode.
  (let ((scalar-index (new <hw-index>)))
    (elm-xset! scalar-index 'name 'hw-index-scalar)
    (elm-xset! scalar-index 'type 'scalar)
    (elm-xset! scalar-index 'mode #f)
    (elm-xset! scalar-index 'value #f)
    (lambda () scalar-index))
)

; Placeholder for indices of "anyof" operands.
; There only needs to be one of these, so we create one and always use that.

(define hw-index-anyof
  ; We can't use `make' here as the make! method calls mode:lookup which
  ; (a) doesn't exist if we're compiled with Hobbit and mode.scm isn't
  ; and (b) will fail anyway since #f isn't a valid mode.
  (let ((anyof-index (new <hw-index>)))
    (elm-xset! anyof-index 'name 'hw-index-anyof)
    (elm-xset! anyof-index 'type 'scalar)
    (elm-xset! anyof-index 'mode #f)
    (elm-xset! anyof-index 'value #f)
    (lambda () anyof-index))
)

(define hw-index-derived
  ; We can't use `make' here as the make! method calls mode:lookup which
  ; (a) doesn't exist if we're compiled with Hobbit and mode.scm isn't
  ; and (b) will fail anyway since #f isn't a valid mode.
  (let ((derived-index (new <hw-index>)))
    (elm-xset! derived-index 'name 'hw-index-derived)
    (elm-xset! derived-index 'type 'scalar)
    (elm-xset! derived-index 'mode #f)
    (elm-xset! derived-index 'value #f)
    (lambda () derived-index))
)

; Hardware selector support.
;
; A hardware "selector" is like an index except is along an atypical axis
; and thus is rarely used.  It exists to support things like ASI's on Sparc.

; What to pass to indicate "default selector".
; (??? value is temporary choice to be revisited).
(define hw-selector-default '(symbol NONE))

(define (hw-selector-default? sel) (equal? sel hw-selector-default))

; Hardware support.

; Return list of hardware elements refered to in OP-LIST
; with no duplicates.

(define (op-nub-hw op-list)
  ; Build a list of hw elements.
  (let ((hw-list (map (lambda (op)
			(if (hw-ref? op) ; FIXME: hw-ref? is undefined
			    op
			    (op:type op)))
		      op-list)))
    ; Now build an alist of (name . obj) elements, take the nub, then the cdr.
    ; ??? These lists tend to be small so sorting first is probably overkill.
    (map cdr
	 (alist-nub (alist-sort (map (lambda (hw) (cons (obj:name hw) hw))
				     hw-list)))))
)

; Parsing support.

; Utility of -operand-parse-[gs]etter to build the expected syntax,
; for use in error messages.

(define (-operand-g/setter-syntax rank setter?)
  (string-append "("
		 (string-drop1
		  (numbers->string (iota rank) " index"))
		 (if setter?
		     (if (>= rank 1)
			 " newval"
			 "newval")
		     "")
		 ") (expression)")
)

; Parse a getter spec.
; The syntax is (([index-names]) (... code ...)).
; Omit `index-names' for scalar objects.
; {rank} is the required number of elements in {index-names}.

(define (-operand-parse-getter context getter rank)
  (if (null? getter)
      #f ; use default
      (let ()
	(if (or (not (list? getter))
		(!= (length getter) 2)
		(not (and (list? (car getter))
			  (= (length (car getter)) rank))))
	    (parse-error context
			 (string-append "invalid getter, should be "
					(-operand-g/setter-syntax rank #f))
			 getter))
	(if (not (rtx? (cadr getter)))
	    (parse-error context "invalid rtx expression" getter))
	getter))
)

; Parse a setter spec.
; The syntax is (([index-names] newval) (... code ...)).
; Omit `index-names' for scalar objects.
; {rank} is the required number of elements in {index-names}.

(define (-operand-parse-setter context setter rank)
  (if (null? setter)
      #f ; use default
      (let ()
	(if (or (not (list? setter))
		(!= (length setter) 2)
		(not (and (list? (car setter))
			  (= (+ 1 (length (car setter)) rank)))))
	    (parse-error context
			 (string-append "invalid setter, should be "
					(-operand-g/setter-syntax rank #t))
			 setter))
	(if (not (rtx? (cadr setter)))
	    (parse-error context "invalid rtx expression" setter))
	setter))
)

; Parse an operand definition.
; This is the main routine for building an operand object from a
; description in the .cpu file.
; All arguments are in raw (non-evaluated) form.
; The result is the parsed object or #f if object isn't for selected mach(s).
; ??? This only takes insn fields as the index.  May need another proc (or an
; enhancement of this one) that takes other kinds of indices.

(define (-operand-parse context name comment attrs hw mode ifld handlers getter setter)
  (logit 2 "Processing operand " name " ...\n")

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name))
	 (atlist-obj (atlist-parse context attrs "cgen_operand")))

    (if (keep-atlist? atlist-obj #f)

	(let ((hw-objs (current-hw-sem-lookup hw))
	      (mode-obj (parse-mode-name context mode))
	      (ifld-val (if (integer? ifld)
			    ifld
			    (current-ifld-lookup ifld))))

	  (if (not mode-obj)
	      (parse-error context "unknown mode" mode))
	  (if (not ifld-val)
	      (parse-error context "unknown insn field" ifld))
	  ; Disallow some obviously invalid numeric indices.
	  (if (and (integer? ifld-val)
		   (< ifld-val 0))
	      (parse-error context "invalid integer index" ifld-val))
	  ; Don't validate HW until we know whether this operand will be kept
	  ; or not.  If not, HW may have been discarded too.
	  (if (null? hw-objs)
	      (parse-error context "unknown hardware element" hw))

	  ; At this point IFLD-VAL is either an integer or an <ifield> object.
	  ; Since we can't look up the hardware element at this time
	  ; [well, actually we should be able to with a bit of work],
	  ; we determine scalarness from the index.
	  (let* ((scalar? (or (integer? ifld-val) (ifld-nil? ifld-val)))
		 (hw-index
		  (if (integer? ifld-val)
		      (make <hw-index> (symbol-append 'i- name)
			    ; FIXME: constant -> const
			    'constant 'UINT ifld-val)
		      (if scalar?
			  (hw-index-scalar)
			  (make <hw-index> (symbol-append 'i- name)
				'ifield 'UINT ifld-val)))))
	    (make <operand>
	      (context-location context)
	      name
	      (parse-comment context comment)
	      ; Copy FLD's attributes so one needn't duplicate attrs like
	      ; PCREL-ADDR, etc.  An operand inherits the attributes of
	      ; its field.  They are overridable of course, which is why we use
	      ; `atlist-append' here.
	      (if (integer? ifld-val)
		  atlist-obj
		  (atlist-append atlist-obj (obj-atlist ifld-val)))
	      hw   ; note that this is the hw's name, not an object
	      mode ; ditto, this is a name, not an object
	      hw-index
	      (parse-handlers context '(parse print) handlers)
	      (-operand-parse-getter context getter (if scalar? 0 1))
	      (-operand-parse-setter context setter (if scalar? 0 1))
	      )))

	(begin
	  (logit 2 "Ignoring " name ".\n")
	  #f)))
)

; Read an operand description.
; This is the main routine for analyzing operands in the .cpu file.
; CONTEXT is a <context> object for error messages.
; ARG-LIST is an associative list of field name and field value.
; -operand-parse is invoked to create the <operand> object.

(define (-operand-read context . arg-list)
  (let (
	(name nil)
	(comment nil)
	(attrs nil)
	(type nil)
	(mode 'DFLT)     ; use default mode of TYPE
	(index nil)
	(handlers nil)
	(getter nil)
	(setter nil)
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
	      ((type) (set! type (cadr arg)))
	      ((mode) (set! mode (cadr arg)))
	      ((index) (set! index (cadr arg)))
	      ((handlers) (set! handlers (cdr arg)))
	      ((getter) (set! getter (cdr arg)))
	      ((setter) (set! setter (cdr arg)))
	      (else (parse-error context "invalid operand arg" arg)))
	    (loop (cdr arg-list)))))

    ; Now that we've identified the elements, build the object.
    (-operand-parse context name comment attrs type mode index handlers
		    getter setter))
)

; Define an operand object, name/value pair list version.

(define define-operand
  (lambda arg-list
    (let ((op (apply -operand-read (cons (make-current-context "define-operand")
					 arg-list))))
      (if op
	  (current-op-add! op))
      op))
)

; Define an operand object, all arguments specified.

(define (define-full-operand name comment attrs type mode index handlers getter setter)
  (let ((op (-operand-parse (make-current-context "define-full-operand")
			    name comment attrs
			    type mode index handlers getter setter)))
    (if op
	(current-op-add! op))
    op)
)

; Derived operands.
;
; Derived operands are used to implement operands more complex than just
; the mapping of an instruction field to a register bank.  Their present
; raison d'etre is to create a new axis on which to implement the complex
; addressing modes of the i386 and m68k.  The brute force way of describing
; these instruction sets would be to have one `dni' per addressing mode
; per instruction.  What's needed is to abstract away the various addressing
; modes within something like operands.
;
; ??? While internally we end up with the "brute force" approach, in and of
; itself that's ok because it's an internal implementation issue.
; See <multi-insn>.
;
; ??? Another way to go is to have one dni per addressing mode.  That seems
; less clean though as one dni would be any of add, sub, and, or, xor, etc.
;
; ??? Some addressing modes have side-effects (e.g. pre-dec, etc. like insns).
; This can be represented, but if two operands have side-effects special
; trickery may be required to get the order of side-effects right.  Need to
; avoid any "trickery" at all.
;
; ??? Not yet handled are modelling parameters.
; ??? Not yet handled are the handlers,getter,setter spec of normal operands.
;
; ??? Division of class members b/w <operand> and <derived-operand> is wip.
; ??? As is potential introduction of other classes to properly organize
; things.

(define <derived-operand>
  (class-make '<derived-operand>
	      '(<operand>)
	      '(
		; Args (list of <operands> objects).
		args

		; Syntax string.
		syntax

		; Base ifield, common to all choices.
		; ??? experiment
		base-ifield

		; <derived-ifield> object.
		encoding

		; Assertions of any ifield values or #f if none.
		(ifield-assertion . #f)
		)
	      '())
)

(method-make-make! <derived-operand>
		   '(name comment attrs mode
			  args syntax base-ifield encoding ifield-assertion
			  getter setter)
)

(define (derived-operand? x) (class-instance? <derived-operand> x))

(define-getters <derived-operand> derived
  (args syntax base-ifield encoding ifield-assertion)
)

; "anyof" operands are subclassed from derived operands.
; They typically handle multiple addressing modes of CISC architectures.

(define <anyof-operand>
  (class-make '<anyof-operand>
	      '(<operand>)
	      '(
		; Base ifield, common to all choices.
		; FIXME: wip
		base-ifield

		; List of <derived-operand> objects.
		; ??? Maybe allow <operand>'s too?
		choices
		)
	      '())
)

(define (anyof-operand? x) (class-instance? <anyof-operand> x))

(method-make!
 <anyof-operand> 'make!
 (lambda (self name comment attrs mode base-ifield choices)
   (elm-set! self 'name name)
   (elm-set! self 'comment comment)
   (elm-set! self 'attrs attrs)
   (elm-set! self 'mode-name mode)
   (elm-set! self 'base-ifield base-ifield)
   (elm-set! self 'choices choices)
   ; Set index to a special marker value.
   (elm-set! self 'index (hw-index-anyof))
   self)
)

(define-getters <anyof-operand> anyof (choices))

; Derived/Anyof parsing support.

; Subroutine of -derived-operand-parse to parse the encoding.
; The result is a <derived-ifield> object.
; The {owner} member still needs to be set!

(define (-derived-parse-encoding context operand-name encoding)
  (if (or (null? encoding)
	  (not (list? encoding)))
      (parse-error context "encoding not a list" encoding))
  (if (not (eq? (car encoding) '+))
      (parse-error context "encoding must begin with `+'" encoding))

  ; ??? Calling -parse-insn-format is a quick hack.
  ; It's an internal routine of some other file.
  (let ((iflds (-parse-insn-format context encoding)))
    (make <derived-ifield>
	  operand-name
	  'derived-ifield ; (string-append "<derived-ifield> for " operand-name)
	  atlist-empty
	  #f ; owner
	  iflds ; subfields
	  ))
)

; Subroutine of -derived-operand-parse to parse the ifield assertion.
; The ifield assertion is either () or an RTL expression asserting something
; about the ifield values of the containing insn.
; Operands are specified by name, but what is used is their indices (there's
; an implicit `index-of' going on).

(define (-derived-parse-ifield-assertion context args ifield-assertion)
  ; FIXME: for now
  (if (null? ifield-assertion)
      #f
      ifield-assertion)
)

; Parse a derived operand definition.
; This is the main routine for building a derived operand object from a
; description in the .cpu file.
; All arguments are in raw (non-evaluated) form.
; The result is the parsed object or #f if object isn't for selected mach(s).
;
; ??? Currently no support for handlers(,???) found in normal operands.
; Later, when necessary.

(define (-derived-operand-parse context name comment attrs mode
				args syntax
				base-ifield encoding ifield-assertion
				getter setter)
  (logit 2 "Processing derived operand " name " ...\n")

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name))
	 (atlist-obj (atlist-parse context attrs "cgen_operand")))

    (if (keep-atlist? atlist-obj #f)

	(let ((mode-obj (parse-mode-name context mode))
	      (parsed-encoding (-derived-parse-encoding context name encoding)))

	  (if (not mode-obj)
	      (parse-error context "unknown mode" mode))

	  (let ((result
		 (make <derived-operand>
		       name
		       (parse-comment context comment)
		       atlist-obj
		       mode-obj
		       (map (lambda (a)
			      (if (not (symbol? a))
				  (parse-error context "arg not a symbol" a))
			      (let ((op (current-op-lookup a)))
				(if (not op)
				    (parse-error context "not an operand" a))
				op))
			    args)
		       syntax
		       base-ifield ; FIXME: validate
		       parsed-encoding
		       (-derived-parse-ifield-assertion context args ifield-assertion)
		       (if (null? getter)
			   #f
			   (-operand-parse-getter context
						  (list args
							(rtx-canonicalize context getter))
						  (length args)))
		       (if (null? setter)
			   #f
			   (-operand-parse-setter context
						  (list (append args '(newval))
							(rtx-canonicalize context setter))
						  (length args)))
		       )))
	    (elm-set! result 'hw-name (obj:name (hardware-for-mode mode-obj)))
	    ;(elm-set! result 'hw-name (obj:name parsed-encoding))
	    ;(elm-set! result 'hw-name base-ifield)
	    (elm-set! result 'index parsed-encoding)
	    ; (elm-set! result 'index (hw-index-derived)) ; A temporary dummy
	    (logit 2 "  new derived-operand; name= " name
		   ", hw-name= " (op:hw-name result) 
		   ", index=" (obj:name parsed-encoding) "\n")
	    (derived-ifield-set-owner! parsed-encoding result)
	    result))

	(begin
	  (logit 2 "Ignoring " name ".\n")
	  #f)))
)

; Read a derived operand description.
; This is the main routine for analyzing derived operands in the .cpu file.
; CONTEXT is a <context> object for error messages.
; ARG-LIST is an associative list of field name and field value.
; -derived-operand-parse is invoked to create the <derived-operand> object.

(define (-derived-operand-read context . arg-list)
  (let (
	(name nil)
	(comment nil)
	(attrs nil)
	(mode 'DFLT)     ; use default mode of TYPE
	(args nil)
	(syntax nil)
	(base-ifield nil)
	(encoding nil)
	(ifield-assertion nil)
	(getter nil)
	(setter nil)
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
	      ((mode) (set! mode (cadr arg)))
	      ((args) (set! args (cadr arg)))
	      ((syntax) (set! syntax (cadr arg)))
	      ((base-ifield) (set! base-ifield (cadr arg)))
	      ((encoding) (set! encoding (cadr arg)))
	      ((ifield-assertion) (set! ifield-assertion (cadr arg)))
	      ((getter) (set! getter (cadr arg)))
	      ((setter) (set! setter (cadr arg)))
	      (else (parse-error context "invalid derived-operand arg" arg)))
	    (loop (cdr arg-list)))))

    ; Now that we've identified the elements, build the object.
    (-derived-operand-parse context name comment attrs mode args
			    syntax base-ifield encoding ifield-assertion
			    getter setter))
)

; Define a derived operand object, name/value pair list version.

(define define-derived-operand
  (lambda arg-list
    (let ((op (apply -derived-operand-read
		     (cons (make-current-context "define-derived-operand")
			   arg-list))))
      (if op
	  (current-op-add! op))
      op))
)

; Define a derived operand object, all arguments specified.
; ??? Not supported (yet).
;
;(define (define-full-derived-operand name comment attrs mode ...)
;  (let ((op (-derived-operand-parse (make-current-context "define-full-derived-operand")
;				    name comment attrs
;				    mode ...)))
;    (if op
;	(current-op-add! op))
;    op)
;)

; Parse an "anyof" choice, which is a derived-operand name.
; The result is {choice} unchanged.

(define (-anyof-parse-choice context choice)
  (if (not (symbol? choice))
      (parse-error context "anyof choice not a symbol" choice))
  (let ((op (current-op-lookup choice)))
    (if (not (derived-operand? op))
	(parse-error context "anyof choice not a derived-operand" choice))
    op)
)

; Parse an "anyof" derived operand.
; This is the main routine for building a derived operand object from a
; description in the .cpu file.
; All arguments are in raw (non-evaluated) form.
; The result is the parsed object or #f if object isn't for selected mach(s).
;
; ??? Currently no support for handlers(,???) found in normal operands.
; Later, when necessary.

(define (-anyof-operand-parse context name comment attrs mode
			      base-ifield choices)
  (logit 2 "Processing anyof operand " name " ...\n")

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name))
	 (atlist-obj (atlist-parse context attrs "cgen_operand")))

    (if (keep-atlist? atlist-obj #f)

	(let ((mode-obj (parse-mode-name context mode)))
	  (if (not mode-obj)
	      (parse-error context "unknown mode" mode))

	  (make <anyof-operand>
		name
		(parse-comment context comment)
		atlist-obj
		mode
		base-ifield
		(map (lambda (c)
		       (-anyof-parse-choice context c))
		     choices)))

	(begin
	  (logit 2 "Ignoring " name ".\n")
	  #f)))
)

; Read an anyof operand description.
; This is the main routine for analyzing anyof operands in the .cpu file.
; CONTEXT is a <context> object for error messages.
; ARG-LIST is an associative list of field name and field value.
; -anyof-operand-parse is invoked to create the <anyof-operand> object.

(define (-anyof-operand-read context . arg-list)
  (let (
	(name nil)
	(comment nil)
	(attrs nil)
	(mode 'DFLT)     ; use default mode of TYPE
	(base-ifield nil)
	(choices nil)
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
	      ((mode) (set! mode (cadr arg)))
	      ((base-ifield) (set! base-ifield (cadr arg)))
	      ((choices) (set! choices (cdr arg)))
	      (else (parse-error context "invalid anyof-operand arg" arg)))
	    (loop (cdr arg-list)))))

    ; Now that we've identified the elements, build the object.
    (-anyof-operand-parse context name comment attrs mode base-ifield choices))
)

; Define an anyof operand object, name/value pair list version.

(define define-anyof-operand
  (lambda arg-list
    (let ((op (apply -anyof-operand-read
		     (cons (make-current-context "define-anyof-operand")
			   arg-list))))
      (if op
	  (current-op-add! op))
      op))
)

; Utilities to flatten out the <anyof-operand> derivation heirarchy.

; Utility class used when instantiating insns with derived operands.
; This collects together in one place all the appropriate data of an
; instantiated "anyof" operand.

(define <anyof-instance>
  (class-make '<anyof-instance>
	      '(<derived-operand>)
	      '(
		; <anyof-operand> object we were instantiated from.
		parent
		)
	      nil)
)

(method-make-make! <anyof-instance>
		   '(name comment attrs mode
			  args syntax base-ifield encoding ifield-assertion
			  getter setter parent)
)

(define-getters <anyof-instance> anyof-instance (parent))

(define (anyof-instance? x) (class-instance? <anyof-instance> x))

; Return initial list of known ifield values in {anyof-instance}.

(define (-anyof-initial-known anyof-instance)
  (assert (derived-operand? anyof-instance))
  (let ((encoding (derived-encoding anyof-instance)))
    (assert (derived-ifield? encoding))
    (ifld-known-values (derived-ifield-subfields encoding)))
)

; Return true if {anyof-instance} satisfies its ifield assertions.
; {known-values} is the {known} argument to rtx-solve.

(define (anyof-satisfies-assertions? anyof-instance known-values)
  (assert (derived-operand? anyof-instance))
  (let ((assertion (derived-ifield-assertion anyof-instance)))
    (if assertion
	(rtx-solve #f ; FIXME: context
		   anyof-instance ; owner
		   assertion
		   known-values)
	#t))
)

; Subroutine of -anyof-merge-subchoices.
; Merge syntaxes of VALUE-NAMES/VALUES into SYNTAX.
;
; Example:
; If SYNTAX is "$a+$b", and VALUE-NAMES is (b), and VALUES is
; ("$c+$d"-object), then return "$a+$c+$d".

(define (-anyof-syntax anyof-instance)
  (elm-get anyof-instance 'syntax)
)

(define (-anyof-name anyof-instance)
  (elm-get anyof-instance 'name)
)

(define (-anyof-merge-syntax syntax value-names values)
  (let ((syntax-elements (syntax-break-out syntax)))
    (syntax-make (map (lambda (e)
			(if (anyof-operand? e)
			    (let* ((name (obj:name e))
				   (indx (element-lookup-index name value-names 0)))
			      (if (not indx)
				(error "Name " name " not one of " values)
				)
			      (-anyof-syntax (list-ref values indx)))
			    e))
		      syntax-elements)))
)

; Subroutine of -anyof-merge-subchoices.
; Merge syntaxes of {value-names}/{values} into <derived-ifield> {encoding}.
; The result is a new <derived-ifield> object with subfields matching
; {value-names} replaced with {values}.
; {container} is the containing <anyof-operand>.
;
; Example:
; If {encoding} is (a-ifield-object b-anyof-ifield-object), and {value-names}
; is (b), and {values} is (c-choice-of-b-object), then return
; (a-ifield-object c-choice-of-b-ifield-object).

(define (-anyof-merge-encoding container encoding value-names values)
  (assert (derived-ifield? encoding))
  (let ((subfields (derived-ifield-subfields encoding))
	(result (object-copy-top encoding)))
    ; Delete all the elements that are being replaced with ifields from
    ; {values} and add the new ifields.
    (derived-ifield-set-subfields! result
				   (append
				    (find (lambda (f)
					    (not (memq (obj:name f) value-names)))
					  subfields)
				    (map derived-encoding values)))
    result)
)

; Subroutine of -anyof-merge-subchoices.
; Merge semantics of VALUE-NAMES/VALUES into GETTER.
;
; Example:
; If GETTER is (mem QI foo), and VALUE-NAMES is (foo), and VALUES is
; ((add a b)-object), then return (mem QI (add a b)).

(define (-anyof-merge-getter getter value-names values)
  ;(debug-repl-env getter value-names values)
  ; ??? This implementation is a quick hack, intended to evolve or be replaced.
  (cond ((not getter)
	 #f)
	(else
	 (map (lambda (e)
		(cond ((symbol? e)
		       (let ((indx (element-lookup-index e value-names 0)))
			 (if indx
			     (op:getter (list-ref values indx))
			     e)))
		      ((pair? e) ; pair? -> cheap non-null-list?
		       (-anyof-merge-getter e value-names values))
		      (else
		       e)))
	      getter)))
)

; Subroutine of -anyof-merge-subchoices.
; Merge semantics of VALUE-NAMES/VALUES into SETTER.
;
; Example:
; If SETTER is (set (mem QI foo) newval), and VALUE-NAMES is (foo),
; and VALUES is ((add a b)-object), then return
; (set (mem QI (add a b)) newval).
;
; ??? `newval' in this context is a reserved word.

(define (-anyof-merge-setter setter value-names values)
  ;(debug-repl-env setter value-names values)
  ; ??? This implementation is a quick hack, intended to evolve or be replaced.
  (cond ((not setter)
	 #f)
	((rtx-single-set? setter)
	 (let ((src (rtx-set-src setter))
	       (dest (rtx-set-dest setter))
	       (mode (rtx-mode setter))
	       (options (rtx-options setter)))
	   (if (rtx-kind 'mem dest)
	       (set! dest
		     (rtx-change-address dest
					 (-anyof-merge-getter
					  (rtx-mem-addr dest)
					  value-names values))))
	   (set! src (-anyof-merge-getter src value-names values))
	   (rtx-make 'set options mode dest src)))
	(else
	 (error "-anyof-merge-setter: unsupported form" (car setter))))
)

; Subroutine of -sub-insn-make!.
; Merge semantics of VALUE-NAMES/VALUES into SEMANTICS.
; Defined here and not in insn.scm to keep it with the getter/setter mergers.
;
; Example:
; If SEMANTICS is (mem QI foo), and VALUE-NAMES is (foo), and VALUES is
; ((add a b)-object), then return (mem QI (add a b)).

(define (anyof-merge-semantics semantics value-names values)
  ;(debug-repl-env semantics value-names values)
  ; ??? This implementation is a quick hack, intended to evolve or be replaced.
  (let ((result
	 (cond ((not semantics)
		#f)
	       (else
		(map (lambda (e)
		       (cond ((symbol? e)
			      (let ((indx (element-lookup-index e value-names 0)))
				(if indx
				    (-anyof-name (list-ref values indx))
				    ; (op:sem-name (list-ref values indx))
				    e)))
			     ((pair? e) ; pair? -> cheap non-null-list?
			      (anyof-merge-semantics e value-names values))
			     (else
			      e)))
		     semantics)))))
    (logit 4 "  merged semantics: [" semantics "] -> [" result "]\n")
    result)
)

; Subroutine of -anyof-merge-subchoices.
; Merge assertion of VALUE-NAMES/VALUES into ASSERTION.
;
; Example:
; If ASSERTION is (ne f-base-reg 5), and VALUE-NAMES is
; (foo), and VALUES is ((ne f-mod 0)), then return
; (andif (ne f-base-reg 5) (ne f-mod 0)).
;
; FIXME: Perform simplification pass, based on combined set of known
; ifield values.

(define (-anyof-merge-ifield-assertion assertion value-names values)
  (let ((assertions (find identity
			  (cons assertion
				(map derived-ifield-assertion values)))))
    (if (null? assertions)
	#f
	(rtx-combine 'andif assertions)))
)

; Subroutine of -anyof-all-subchoices.
; Return a copy of <derived-operand> CHOICE with NEW-ARGS from ANYOF-ARGS
; merged in.  This is for when a derived operand is itself composed of
; anyof operands.
; ANYOF-ARGS is a list of <anyof-operand>'s to be replaced in CHOICE.
; NEW-ARGS is a corresponding list of values (<derived-operands>'s) of each
; element in ANYOF-ARGS.
; CONTAINER is the <anyof-operand> containing CHOICE.

(define (-anyof-merge-subchoices container choice anyof-args new-args)
  (assert (all-true? (map anyof-operand? anyof-args)))
  (assert (all-true? (map derived-operand? new-args)))

  (let* ((arg-names (map obj:name anyof-args))
	 (encoding (-anyof-merge-encoding container (derived-encoding choice)
					  arg-names new-args))
	 (result
	  (make <anyof-instance>
		(apply symbol-append
		       (cons (obj:name choice)
			     (map (lambda (anyof)
				    (symbol-append '- (obj:name anyof)))
				  new-args)))
		(obj:comment choice)
		(obj-atlist choice)
		(op:mode choice)
		(derived-args choice)
		(-anyof-merge-syntax (derived-syntax choice)
				     arg-names new-args)
		(derived-base-ifield choice)
		encoding
		(-anyof-merge-ifield-assertion (derived-ifield-assertion choice)
					       anyof-args new-args)
		(-anyof-merge-getter (op:getter choice)
				     arg-names new-args)
		(-anyof-merge-setter (op:setter choice)
				     arg-names new-args)
		container)))

    (elm-set! result 'index encoding)
    ; Creating the link from {encoding} to {result}.
    (derived-ifield-set-owner! encoding result)
    result)
)

; Subroutine of -anyof-all-choices-1.
; Return a list of all possible subchoices of <derived-operand> ANYOF-CHOICE,
; known to use <anyof-operand>'s itself.
; CONTAINER is the containing <anyof-operand>.

(define (-anyof-all-subchoices container anyof-choice)
  ; Split args into anyof and non-anyof elements.
  (let* ((args (derived-args anyof-choice))
	 (anyof-args (find anyof-operand? args)))

    (assert (not (null? anyof-args)))

    ; Iterate over all combinations.
    ; {todo} is a list with one element for each anyof argument.
    ; Each element is in turn a list of all <derived-operand> choices for the
    ; <anyof-operand>.  The result we want is every possible combination.
    ; Example:
    ; If {todo} is ((1 2 3) (a) (B C)) the result we want is
    ; ((1 a B) (1 a C) (2 a B) (2 a C) (3 a B) (3 a C)).
    ;
    ; Note that some of these values may be derived from nested
    ; <anyof-operand>'s which is why we recursively call -anyof-all-choices-1.
    ; ??? -anyof-all-choices-1 should cache the results.

    (let* ((todo (map -anyof-all-choices-1 anyof-args))
	   (lengths (map length todo))
	   (total (apply * lengths))
	   (result nil))

      ; ??? One might prefer a `do' loop here, but every time I see one I
      ; have to spend too long remembering its syntax.
      (let loop ((i 0))
	(if (< i total)
	    (let* ((indices (split-value lengths i))
		   (new-args (map list-ref todo indices)))
	      ;(display "new-args: " (current-error-port))
	      ;(display (map obj:name new-args) (current-error-port))
	      ;(newline (current-error-port))
	      (set! result
		    (cons (-anyof-merge-subchoices container
						   anyof-choice
						   anyof-args
						   new-args)
			  result))
	      (loop (+ i 1)))))

      result))
)

; Return an <anyof-instance> object from <derived-operand> {derop}, which is a
; choice of {anyof-operand}.

(define (-anyof-instance-from-derived anyof-operand derop)
  (let* ((encoding (object-copy-top (derived-encoding derop)))
	 (result
	  (make <anyof-instance>
		(obj:name derop)
		(obj:comment derop)
		(obj-atlist derop)
		(op:mode derop)
		(derived-args derop)
		(derived-syntax derop)
		(derived-base-ifield derop)
		encoding
		(derived-ifield-assertion derop)
		(op:getter derop)
		(op:setter derop)
		anyof-operand)))
    ; Creating the link from {encoding} to {result}.
    (derived-ifield-set-owner! encoding result)
    result)
)

; Return list of <anyof-instance> objects, one for each possible variant of
; ANYOF-OPERAND.
;
; One could move this up into the cpu description file using pmacros.
; However, that's not the right way to go.  How we currently implement
; the notion of derived operands is separate from the notion of having them
; in the description language.  pmacros are not "in" the language (to the
; extent that the cpu description file reader "sees" them), they live
; above it.  And the right way to do this is with something "in" the language.
; Derived operands are the first cut at it.  They'll evolve or be replaced
; (and it's the implementation of them that will evolve first).

(define (-anyof-all-choices-1 anyof-operand)
  (assert (anyof-operand? anyof-operand))

  (let ((result nil))

    ; For each choice, scan the operands for further derived operands.
    ; If found, replace the choice with the list of its subchoices.
    ; If not found, create an <anyof-instance> object for it.  This is
    ; basically just a copy of the object, but {anyof-operand} is recorded
    ; with it so that we can later resolve `follows' specs.

    (let loop ((choices (anyof-choices anyof-operand)))
      (if (not (null? choices))
	  (let* ((this (car choices))
		 (args (derived-args this)))

	    (if (any-true? (map anyof-operand? args))

		; This operand has "anyof" operands so we need to turn this
		; choice into a list of all possible subchoices.
		(let ((subchoices (-anyof-all-subchoices anyof-operand this)))
		  (set! result
			(append subchoices result)))

		; No <anyof-operand> arguments.
		(set! result
		      (cons (-anyof-instance-from-derived anyof-operand this)
			    result)))

	    (loop (cdr choices)))))

    (assert (all-true? (map anyof-instance? result)))
    result)
)

; Cover fn of -anyof-all-choices-1.
; Return list of <anyof-instance> objects, one for each possible variant of
; ANYOF-OPERAND.
; We want to delete choices that fail their ifield assertions, but since
; -anyof-all-choices-1 can recursively call itself, assertion checking is
; defered until it returns.

(define (anyof-all-choices anyof-operand)
  (let ((all-choices (-anyof-all-choices-1 anyof-operand)))

    ; Delete ones that fail their ifield assertions.
    ; Sometimes there isn't enough information yet to completely do this.
    ; When that happens it is the caller's responsibility to deal with it.
    ; However, it is our responsibility to assert as much as we can.
    (find (lambda (op)
	    (anyof-satisfies-assertions? op
					 (-anyof-initial-known op)))
	  all-choices))
)

; Operand utilities.

; Look up operand NAME in the operand table.
; This proc isolates the strategy we use to record operand objects.

; Look up an operand via SEM-NAME.

(define (op:lookup-sem-name op-list sem-name)
  (let loop ((op-list op-list))
    (cond ((null? op-list) #f)
	  ((eq? sem-name (op:sem-name (car op-list))) (car op-list))
	  (else (loop (cdr op-list)))))
)

; Given an operand, return the starting bit number.
; Note that the field isn't necessarily contiguous.

(define (op:start operand) (send operand 'field-start #f))

; Given an operand, return the total length in bits.
; Note that the field isn't necessarily contiguous.

(define (op:length operand) (send operand 'field-length))

; Return the nub of a list of operands, base on their names.

(define (op-nub op-list)
  (nub op-list obj:name)
)

; Return a sorted list of operand lists.
; Each element in the inner list is an operand with the same name, but for
; whatever reason were defined separately.
; The outer list is sorted by name.

(define (op-sort op-list)
  ; We assume there is at least one operand.
  (if (null? op-list)
      (error "op-sort: no operands!"))
  ; First sort by name.
  (let ((sorted-ops (alpha-sort-obj-list op-list)))
    (let loop ((result nil)
	       ; Current set of operands with same name.
	       (this-elm (list (car sorted-ops)))
	       (ops (cdr sorted-ops))
	       )
      (if (null? ops)
	  ; Reverse things to keep them in file order (minimizes random
	  ; changes in generated files).
	  (reverse! (cons (reverse! this-elm) result))
	  ; Not done.  Check for new set.
	  (if (eq? (obj:name (car ops)) (obj:name (car this-elm)))
	      (loop result (cons (car ops) this-elm) (cdr ops))
	      (loop (cons (reverse! this-elm) result) (list (car ops))
		    (cdr ops))))))
)

; FIXME: Not used anymore but leave in for now.
; Objects used in assembler syntax ($0, $1, ...).
;
;(define <syntax-operand>
;  (class-make '<syntax-operand> nil '(number value) nil))
;(method-make-make! <syntax-operand> '(number))
;
;(define $0 (make <syntax-operand> 0))
;(define $1 (make <syntax-operand> 1))
;(define $2 (make <syntax-operand> 2))
;(define $3 (make <syntax-operand> 3))

; Called before/after loading the .cpu file to initialize/finalize.

; Builtins.
; The pc operand used in rtl expressions.
(define pc nil)

; Called before reading a .cpu file in.

(define (operand-init!)
  (reader-add-command! 'define-operand
		       "\
Define an operand, name/value pair list version.
"
		       nil 'arg-list define-operand)
  (reader-add-command! 'define-full-operand
		       "\
Define an operand, all arguments specified.
"
		       nil '(name comment attrs hw-type mode hw-index handlers getter setter)
		       define-full-operand)

  (reader-add-command! 'define-derived-operand
		       "\
Define a derived operand, name/value pair list version.
"
		       nil 'arg-list define-derived-operand)

  (reader-add-command! 'define-anyof-operand
		       "\
Define an anyof operand, name/value pair list version.
"
		       nil 'arg-list define-anyof-operand)

  *UNSPECIFIED*
)

; Install builtin operands.

(define (operand-builtin!)
  ; Standard operand attributes.
  ; ??? Some of these can be combined into one.

  (define-attr '(for operand) '(type boolean) '(name NEGATIVE)
    '(comment "value is negative"))

  ; Operand plays a part in RELAXABLE/RELAXED insns.
  (define-attr '(for operand) '(type boolean) '(name RELAX)
    '(comment "operand is the relax participant"))

  ; ??? Might be able to make SEM-ONLY go away (or machine compute it)
  ; by scanning which operands are refered to by the insn syntax strings.
  (define-attr '(for operand) '(type boolean) '(name SEM-ONLY)
    '(comment "operand is for semantic use only"))

  ; Also (defined elsewhere): PCREL-ADDR ABS-ADDR.

  (set! pc (make <pc>))
  (current-op-add! pc)

  *UNSPECIFIED*
)

; Called after a .cpu file has been read in.

(define (operand-finish!)
  *UNSPECIFIED*
)
