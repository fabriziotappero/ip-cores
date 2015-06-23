; Standard RTL functions.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; THIS FILE CONTAINS ONE BIG FUNCTION: def-rtx-funcs.
;
; It is ok for this file to use procs "internal" to rtl.scm.
;
; Each rtx functions has two leading operands: &options, &mode;
; though `&mode' may be spelled differently.
; The "&" prefix is to indicate that the parsing of these operands is handled
; differently.  They are optional and are written with leading colons
; (e.g. :SI).  The leading ":" is to help the parser - all leading optional
; operands begin with ":".  The order of the arguments is &options then &mode
; though there is no imposed order in written RTL.

(define (def-rtx-funcs)

; Do not change the indentation here.
(let
(
 ; These are defined in rtl.scm.
 (drn define-rtx-node)
 (drsn define-rtx-syntax-node)
 (dron define-rtx-operand-node)
 (drmn define-rtx-macro-node)
)

; The reason for the odd indenting above is so that emacs begins indenting the
; following code at column 1.

; Error reporting.
; MODE is present for use in situations like non-VOID mode cond's.

(drn (error &options &mode message)
     (OPTIONS ANYMODE STRING) (NA NA NA)
     MISC
     (estate-error *estate* "error in rtl" message)
)

; Enums
; Default mode is INT.

(drn (enum &options &mode enum-name)
     (OPTIONS NUMMODE SYMBOL) (NA NA NA)
     ARG
     ; When computing a value, return the enum's value.
     (enum-lookup-val enum-name)
)

; Instruction fields
; These are used in the encode/decode specs of other ifields as well as in
; instruction semantics.
; Ifields are normally specified by name, but they are subsequently wrapped
; in this.

(dron (ifield &options &mode ifld-name)
      (OPTIONS DFLTMODE SYMBOL) (NA NA NA)
      ARG
      (let ((f (current-ifld-lookup ifld-name)))
	(make <operand> (obj-location f)
	      ifld-name (string-append ifld-name " used as operand")
	      (atlist-cons (bool-attr-make 'SEM-ONLY #t)
			   (obj-atlist f))
	      (obj:name (ifld-hw-type f))
	      (obj:name (ifld-mode f))
	      (make <hw-index> 'anonymous 'ifield (ifld-mode f) f)
	      nil #f #f))
)

; Specify an operand.
; Operands are normally specified by name, but they are subsequently wrapped
; in this.

(dron (operand &options &mode op-name)
      (OPTIONS DFLTMODE SYMBOL) (NA NA NA)
      ARG
      (current-op-lookup op-name)
)

; Operand naming/numbering.
; Operands are given names so that the operands as used in the semantics can
; be matched with arguments of function units.  With good name choices of
; operands and function unit arguments, this is rarely necessary, but
; sometimes it is.
;
; ??? This obfuscates the semantic code a fair bit.  Another way to do this
; would be to add new elements to <insn> to specify operands outside of
; the semantic code.  E.g.
; (define-insn ...
;   (inputs (in-gr1 src1) (in-gr2 src2))
;   (outputs (out-pc pc) (out-gr dr) (reg-14 (reg WI h-gr 14)))
;   ...)
; The intent here is to continue to allow the semantic code to use names
; of operands, and not overly complicate the input/output description.
;
; In instructions, operand numbers are recorded as well, to implement
; profiling and result writeback of parallel insns.

; Rename operand VALUE to NEW-NAME.
; VALUE is an expression whose result is an object of type <operand>.
; It can be the name of an existing operand.
; ??? Might also support numbering by allowing NEW-NAME to be a number.

(drsn (name &options &mode new-name value)
      (OPTIONS DFLTMODE SYMBOL RTX) (NA NA NA ANY)
      ARG
      (let ((result (object-copy (rtx-get 'DFLT value))))
	(op:set-sem-name! result new-name)
	result)
)

; Operands are generally compiled to an internal form first.
; There is a fair bit of state associated with them, and it's easier to
; work with an object than source [which might get fairly complicated if
; it expresses all the state].
; Compiled operands are wrapped in this so that they still look like rtx.

(dron (xop &options &mode object)
      (OPTIONS DFLTMODE OBJECT) (NA NA NA)
      ARG
      object
)

;(dron (opspec: &options &mode op-name op-num hw-ref attrs)
;      (OPTIONS ANYMODE SYMBOL NUMBER RTX ATTRS) (NA NA NA NA ANY NA)
;      ARG
;      (let ((opval (rtx-eval-with-estate hw-ref mode *estate*)))
;	(assert (operand? opval))
;	; Set the specified mode, ensuring it's ok.
;	; This also makes a copy as we don't want to modify predefined
;	; operands.
;	(let ((operand (op:new-mode opval mode)))
;	  (op:set-sem-name! operand op-name)
;	  (op:set-num! operand op-num)
;	  (op:set-cond?! operand (attr-value attrs 'COND-REF #f))
;	  operand))
;)

; Specify a reference to a local variable.
; Local variables are normally specified by name, but they are subsequently
; wrapped in this.

(dron (local &options &mode local-name)
      (OPTIONS DFLTMODE SYMBOL) (NA NA NA)
      ARG
      (rtx-temp-lookup (tstate-env *tstate*) local-name)
)

; FIXME: This doesn't work.  See s-operand.
;(define (s-dup estate op-name)
;  (if (not (insn? (estate-owner estate)))
;      (error "dup: not processing an insn"))
;  (vector-ref (insn:operands (current-current-context))
;	       (op:lookup-num (insn:operands (estate-owner estate)) op-name))
;)
;
; ??? Since operands are given names and not numbers this isn't currently used.
;
;(drsn (dup &options &mode op-name)
;     (OPTIONS DFLTMODE SYMBOL) (NA NA NA)
;     ;(s-dup *estate* op-name)
;     (begin
;       (if (not (insn? (estate-owner *estate*)))
;	   (error "dup: not processing an insn"))
;       (vector-ref (insn:operands (estate-owner *estate*))
;		   (op:lookup-num (insn:operands (estate-owner *estate*)) op-name)))
;     #f
;)

; Returns non-zero if operand NAME was referenced (read if input operand
; and written if output operand).
; ??? What about input/output operands.

(drsn (ref &options &mode name)
      (OPTIONS DFLTMODE SYMBOL) (NA NA NA)
      ARG
      #f
)

; Return the index of an operand.
; For registers this is the register number.
; ??? Mode handling incomplete.

(dron (index-of &options &mode op-rtx)
      (OPTIONS DFLTMODE RTX) (NA NA ANY)
      ARG
      (let* ((operand (rtx-eval-with-estate op-rtx 'DFLT *estate*))
	     (f (hw-index:value (op:index operand)))
	     (f-name (obj:name f)))
	(make <operand> (if (source-ident? f) (obj-location f) #f)
	      f-name f-name
	      (atlist-cons (bool-attr-make 'SEM-ONLY #t)
			   (obj-atlist f))
	      (obj:name (ifld-hw-type f))
	      (obj:name (ifld-mode f))
	      (make <hw-index> 'anonymous
		    'ifield
		    (ifld-mode f)
		    ; (send (op:type op) 'get-index-mode)
		    f)
	      nil #f #f))
)

; Same as index-of, but improves readability for registers.

(drmn (regno reg)
      (list 'index-of reg)
)

; Hardware elements.

; Describe a random hardware object.
; If INDX is missing, assume the element is a scalar.  We pass 0 so s-hw
; doesn't have to unpack the list that would be passed if it were defined as
; (hw mode hw-name . indx).  This is an internal implementation detail
; and thus harmless to the description language.
; These are implemented as syntax nodes as we must pass INDX to `s-hw'
; unevaluated.
; ??? Not currently supported.  Not sure whether it should be.
;(drsn (hw &options &mode hw-elm . indx-sel)
;      (OPTIONS ANYMODE SYMBOL . RTX) (NA NA NA . INT)
;      ARG
;      (let ((indx (if (pair? indx-sel) (car indx-sel) 0))
;            (selector (if (and (pair? indx-sel) (pair? (cdr indx-sel)))
;                          (cadr indx-sel)
;                          hw-selector-default))))
;      (s-hw *estate* mode hw-elm indx selector)
;)

; Register accesses.
; INDX-SEL is an optional index and possible selector.
(dron (reg &options &mode hw-elm . indx-sel)
      (OPTIONS ANYMODE SYMBOL . RTX) (NA NA NA . INT)
      ARG
      (let ((indx (if (pair? indx-sel) (car indx-sel) 0))
	    (selector (if (and (pair? indx-sel) (pair? (cdr indx-sel)))
			  (cadr indx-sel)
			  hw-selector-default)))
	(s-hw *estate* mode hw-elm indx selector))	    
)

; A raw-reg bypasses the getter/setter stuff.  It's usually used in
; getter/setter definitions.

(dron (raw-reg &options &mode hw-elm . indx-sel)
      (OPTIONS ANYMODE SYMBOL . RTX) (NA NA NA . INT)
      ARG
      (let ((indx (if (pair? indx-sel) (car indx-sel) 0))
	    (selector (if (and (pair? indx-sel) (pair? (cdr indx-sel)))
			  (cadr indx-sel)
			  hw-selector-default)))
	(let ((result (s-hw *estate* mode hw-elm indx selector)))
	  (obj-cons-attr! result (bool-attr-make 'RAW #t))
	  result))
)

; Memory accesses.
(dron (mem &options &mode addr . sel)
      (OPTIONS EXPLNUMMODE RTX . RTX) (NA NA AI . INT)
      ARG
      (s-hw *estate* mode 'h-memory addr
	    (if (pair? sel) (car sel) hw-selector-default))
)

; Instruction execution support.
; There are no jumps, per se.  A jump is a set of `pc'.

; The program counter.
; ??? Hmmm... needed?  The pc is usually specified as `pc' which is shorthand
; for (operand pc).
(dron (pc) () () ARG s-pc)

; Fetch bytes from the instruction stream of size MODE.
; FIXME: Later need to augment this by passing an indicator to the mem-fetch
; routines that we're doing an ifetch.
; ??? wip!

(drmn (ifetch mode pc)
      (list 'mem mode pc) ; hw-selector-ispace
)

; NUM is the instruction number.  Generally it is zero but if more than one
; insn is decoded at a time, it is non-zero.  This is used, for example, to
; index into the scache [as an offset from the first insn].
; ??? wip!

(drmn (decode mode pc insn num)
      (list 'c-call mode 'EXTRACT pc insn num)
)

; NUM is the same number passed to `decode'.
; ??? wip!

(drmn (execute mode num)
      (list 'c-call mode 'EXECUTE num)
)

; Control Transfer Instructions

; Sets of pc are handled like other sets so there are no branch rtx's.

; Indicate there are N delay slots in the processing of RTX.
; N is a `const' node.
; ??? wip!

(drn (delay &options &mode n rtx)
     (OPTIONS DFLTMODE RTX RTX) (NA NA INT ANY)
     MISC
     #f ; (s-sequence *estate* VOID '() rtx) ; wip!
)

; Annul the following insn if YES? is non-zero.
; PC is the address of the annuling insn.
; The target is required to define SEM_ANNUL_INSN.
; ??? wip!

(drmn (annul yes?)
      ; The pc reference here is hidden in c-code to not generate a spurious
      ; pc input operand.
      (list 'c-call 'VOID "SEM_ANNUL_INSN" (list 'c-code 'IAI "pc") yes?)
)

; Skip the following insn if YES? is non-zero.
; The target is required to define SEM_SKIP_INSN.
; ??? This is similar to annul.  Deletion of one of them defered.
; ??? wip!

(drn (skip &options &mode yes?)
     (OPTIONS DFLTMODE RTX) (NA NA INT)
     MISC
     #f
)

; Attribute support.

; Return a boolean indicating if attribute named ATTR is VALUE in OWNER.
; If VALUE is a list, return "true" if ATTR is any of the listed values.
; ??? Don't yet support !VALUE.
; OWNER is the result of either (current-insn) or (current-mach)
; [note that canonicalization will turn them into
; (current-{insn,mach} () DFLT)].
; The result is always of mode INT.
; FIXME: wip
;
; This is a syntax node so the args are not pre-evaluated.
; We just want the symbols.
; FIXME: Hmmm... it currently isn't a syntax node.

(drn (eq-attr &options &mode owner attr value)
      (OPTIONS DFLTMODE RTX SYMBOL SYMORNUM) (NA NA ANY NA NA)
      MISC
      (let ((atval (if owner
		       (obj-attr-value owner attr)
		       (attr-lookup-default attr #f))))
	(if (list? value)
	    (->bool (memq atval value))
	    (eq? atval value)))
)

; Get the value of attribute ATTR-NAME.
; OBJ is the result of either (current-insn) or (current-mach)
; [note that canonicalization will turn them into
; (current-{insn,mach} () DFLT)].
; FIXME:wip

(drn (attr &options &mode obj attr-name)
     (OPTIONS DFLTMODE RTX SYMBOL) (NA NA NA NA)
     MISC
     #f
)

; Same as `quote', for use in attributes cus "quote" sounds too jargonish.
; [Ok, not a strong argument for using "symbol", but so what?]

(drsn (symbol &options &mode name)
      (OPTIONS DFLTMODE SYMBOL) (NA NA NA)
      ARG
      name
)

; Return the current instruction.

(drn (current-insn &options &mode)
     (OPTIONS DFLTMODE) (NA NA)
     MISC
     (let ((obj (estate-owner *estate*)))
       (if (not (insn? obj))
	   (error "current context not an insn"))
       obj)
)

; Return the currently selected machine.
; This can either be a compile-time or run-time value.

(drn (current-mach &options &mode)
     (OPTIONS DFLTMODE) (NA NA)
     MISC
     -rtx-current-mach
)

; Constants.

; FIXME: Need to consider 64 bit hosts.
(drn (const &options &mode c)
     (OPTIONS NUMMODE NUMBER) (NA NA NA)
     ARG
     ; When computing a value, just return the constant unchanged.
     c
)

; Large mode support.

; Combine smaller modes into a larger one.
; Arguments are specified most significant to least significant.
; ??? May also want an endian dependent argument order.  That can be
; implemented on top of or beside this.
; ??? Not all of the combinations are supported in the simulator.
; They'll get added as necessary.
(drn (join &options &out-mode in-mode arg1 . arg-rest)
     (OPTIONS NUMMODE NUMMODE RTX . RTX) (NA NA NA ANY . ANY)
     MISC
     ; FIXME: Ensure correct number of args for in/out modes.
     ; FIXME: Ensure compatible modes.
     #f
)

; GCC's subreg.
; Called subword 'cus it's not exactly subreg.
; Word numbering is from most significant (word 0) to least (word N-1).
; ??? May also want an endian dependent word ordering.  That can be
; implemented on top of or beside this.
; ??? GCC plans to switch to SUBREG_BYTE.  Keep an eye out for the switch
; (which is extensive so probably won't happen anytime soon).
;
; The mode spec of operand0 use to be OP0, but subword is not a normal rtx.
; The mode of operand0 is not necessarily the same as the mode of the result,
; and code which analyzes it would otherwise use the result mode (specified by
; `&mode') for the mode of operand0.

(drn (subword &options &mode value word-num)
     (OPTIONS NUMMODE RTX RTX) (NA NA ANY INT)
     ARG
     #f
)

; ??? The split and concat stuff is just an experiment and should not be used.
; What's there now is just "thoughts put down on paper."

(drmn (split split-mode in-mode di)
      ; FIXME: Ensure compatible modes
      ;(list 'c-raw-call 'BLK (string-append "SPLIT" in-mode split-mode) di)
      '(const 0)
)

(drmn (concat modes arg1 . arg-rest)
      ; FIXME: Here might be the place to ensure
      ; (= (length modes) (length (cons arg1 arg-rest))).
      ;(cons 'c-raw-call (cons modes (cons "CONCAT" (cons arg1 arg-rest))))
      '(const 0)
)

; Support for explicit C code.
; ??? GCC RTL calls this "unspec" which is arguably a more application
; independent name.

(drn (c-code &options &mode text)
     (OPTIONS ANYMODE STRING) (NA NA NA)
     UNSPEC
     #f
)

; Invoke C functions passing them arguments from the semantic code.
; The arguments are passed as is, no conversion is done here.
; Usage is:
;           (c-call mode name arg1 arg2 ...)
; which is converted into a C function call:
;           name (current_cpu, arg1, arg2, ...)
; Mode is the mode of the result.
; If it is VOID this call is a statement and ';' is appended.
; Otherwise it is part of an expression.

(drn (c-call &options &mode name . args)
     (OPTIONS ANYMODE STRING . RTX) (NA NA NA . ANY)
     UNSPEC
     #f
)

; Same as c-call but without implicit first arg of `current_cpu'.

(drn (c-raw-call &options &mode name . args)
     (OPTIONS ANYMODE STRING . RTX) (NA NA NA . ANY)
     UNSPEC
     #f
)

; Set/get/miscellaneous

(drn (nop &options &mode)
     (OPTIONS VOIDMODE) (NA NA)
     MISC
     #f
)

; Clobber - mark an object as modified without explaining why or how.

(drn (clobber &options &mode object)
     (OPTIONS ANYMODE RTX) (NA NA OP0)
     MISC
     #f
)

; The `set' rtx.
; MODE is the mode of DST.  If DFLT, use DST's default mode.
; The mode of the result is always VOID.
;
; ??? It might be more consistent to rename set -> set-trace, but that's
; too wordy.  The `set' rtx is the normal one and we want the normal one to
; be the verbose one (prints result tracing messages).  `set-quiet' is the
; atypical one, it doesn't print tracing messages.  It may also turn out that
; a different mechanism (rather than the name "set-quiet") is used some day.
; One way would be to record the "quietness" state with the traversal state and
; use something like (with-quiet (set foo bar)) akin to with-output-to-string
; in Guile.
;
; i.e. set -> gen-set-trace
;      set-quiet -> gen-set-quiet
;
; ??? One might want a `!' suffix as in `set!', but methinks that's following
; Scheme too closely.

(drn (set &options &mode dst src)
     (OPTIONS ANYMODE SETRTX RTX) (NA NA OP0 MATCH1)
     SET
     #f
)

(drn (set-quiet &options &mode dst src)
     (OPTIONS ANYMODE SETRTX RTX) (NA NA OP0 MATCH1)
     SET
     #f
)

; Standard arithmetic operations.

; It's nice emitting macro calls to the actual C operation in that the RTX
; expression is preserved, albeit in C.  On the one hand it's one extra thing
; the programmer has to know when looking at the code.  But on the other it's
; trivial stuff, and having a layer between RTX and C allows the
; macros/functions to be modified to handle unexpected situations.
; 
; We do emit C directly for cases other than cpu semantics
; (e.g. the assembler).
;
; The language is defined such that we assume ANSI C semantics while avoiding
; implementation defined areas, with as few exceptions as possible.
;
; Current exceptions:
; - signed shift right assumes the sign bit is replicated.
;
; Additional notes [perhaps repeating what's in ANSI C for emphasis]:
; - callers of division and modulus fns must test for 0 beforehand
;   if necessary
; - division and modulus fns have unspecified behavior for negative args
;   [yes I know the C standard says implementation defined, here its
;   unspecified]
; - later add versions of div/mod that have an explicit behaviour for -ve args
; - signedness is part of the rtx operation name, and is not determined
;   from the arguments [elsewhere is a description of the tradeoffs]
; - ???

(drn (neg &options &mode s1)
     (OPTIONS ANYMODE RTX) (NA NA OP0)
     UNARY
     #f
)

(drn (abs &options &mode s1)
     (OPTIONS ANYMODE RTX) (NA NA OP0)
     UNARY
     #f
)

; For integer values this is a bitwise operation (each bit inverted).
; For floating point values this produces 1/x.
; ??? Might want different names.
(drn (inv &options &mode s1)
     (OPTIONS ANYMODE RTX) (NA NA OP0)
     UNARY
     #f
)

; This is a boolean operation.
; MODE is the mode of S1.  The result always has mode BI.
; ??? Perhaps `mode' shouldn't be here.
(drn (not &options &mode s1)
     (OPTIONS ANYMODE RTX) (NA NA OP0)
     UNARY
     #f
)

(drn (add &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (sub &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)

; "OF" for "overflow flag", "CF" for "carry flag",
; "s3" here must have type BI.
; For the *flag rtx's, MODE is the mode of S1,S2; the result always has
; mode BI.
(drn (addc &options &mode s1 s2 s3)
     (OPTIONS ANYMODE RTX RTX RTX) (NA NA OP0 MATCH1 BI)
     TRINARY
     #f
)
(drn (addc-cflag &options &mode s1 s2 s3)
     (OPTIONS ANYMODE RTX RTX RTX) (NA NA OP0 MATCH1 BI)
     TRINARY
     #f
)
(drn (addc-oflag &options &mode s1 s2 s3)
     (OPTIONS ANYMODE RTX RTX RTX) (NA NA OP0 MATCH1 BI)
     TRINARY
     #f
)
(drn (subc &options &mode s1 s2 s3)
     (OPTIONS ANYMODE RTX RTX RTX) (NA NA OP0 MATCH1 BI)
     TRINARY
     #f
)
(drn (subc-cflag &options &mode s1 s2 s3)
     (OPTIONS ANYMODE RTX RTX RTX) (NA NA OP0 MATCH1 BI)
     TRINARY
     #f
)
(drn (subc-oflag &options &mode s1 s2 s3)
     (OPTIONS ANYMODE RTX RTX RTX) (NA NA OP0 MATCH1 BI)
     TRINARY
     #f
)

;; ??? These are deprecated.  Delete in time.
(drn (add-cflag &options &mode s1 s2 s3)
     (OPTIONS ANYMODE RTX RTX RTX) (NA NA OP0 MATCH1 BI)
     TRINARY
     #f
)
(drn (add-oflag &options &mode s1 s2 s3)
     (OPTIONS ANYMODE RTX RTX RTX) (NA NA OP0 MATCH1 BI)
     TRINARY
     #f
)
(drn (sub-cflag &options &mode s1 s2 s3)
     (OPTIONS ANYMODE RTX RTX RTX) (NA NA OP0 MATCH1 BI)
     TRINARY
     #f
)
(drn (sub-oflag &options &mode s1 s2 s3)
     (OPTIONS ANYMODE RTX RTX RTX) (NA NA OP0 MATCH1 BI)
     TRINARY
     #f
)

; Usurp these names so that we have consistent rtl should a program generator
; ever want to infer more about what the semantics are doing.
; For now these are just macros that expand to real rtl to perform the
; operation.

; Return bit indicating if VALUE is zero/non-zero.
(drmn (zflag arg1 . rest) ; mode value)
      (if (null? rest) ; mode missing?
	  (list 'eq 'DFLT arg1 0)
	  (list 'eq arg1 (car rest) 0))
)

; Return bit indicating if VALUE is negative/non-negative.
(drmn (nflag arg1 . rest) ; mode value)
      (if (null? rest) ; mode missing?
	  (list 'lt 'DFLT arg1 0)
	  (list 'lt arg1 (car rest) 0))
)

; Multiply/divide.

(drn (mul &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
; ??? In non-sim case, ensure s1,s2 is in right C type for right result.
; ??? Need two variants, one that avoids implementation defined situations
; [both host and target], and one that specifies implementation defined
; situations [target].
(drn (div &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (udiv &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (mod &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (umod &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)

; wip: mixed mode mul/div

; various floating point routines

(drn (sqrt &options &mode s1)
     (OPTIONS FLOATMODE RTX) (NA NA OP0)
     UNARY
     #f
)

(drn (cos &options &mode s1)
     (OPTIONS FLOATMODE RTX) (NA NA OP0)
     UNARY
     #f
)

(drn (sin &options &mode s1)
     (OPTIONS FLOATMODE RTX) (NA NA OP0)
     UNARY
     #f
)

; min/max

(drn (min &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)

(drn (max &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)

(drn (umin &options &mode s1 s2)
     (OPTIONS INTMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)

(drn (umax &options &mode s1 s2)
     (OPTIONS INTMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)

; These are bitwise operations.
(drn (and &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (or &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (xor &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)

; Shift operations.

(drn (sll &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 INT)
     BINARY
     #f
)
(drn (srl &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 INT)
     BINARY
     #f
)
; ??? In non-sim case, ensure s1 is in right C type for right result.
(drn (sra &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 INT)
     BINARY
     #f
)
; Rotates don't really have a sign, so doesn't matter what we say.
(drn (ror &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 INT)
     BINARY
     #f
)
(drn (rol &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 INT)
     BINARY
     #f
)
; ??? Will also need rotate-with-carry [duh...].

; These are boolean operations (e.g. C &&, ||).
; The result always has mode BI.
; ??? 'twould be more Schemey to take a variable number of args.
; ??? 'twould also simplify several .cpu description entries.
; On the other hand, handling an arbitrary number of args isn't supported by
; ISA's, which the main goal of what we're trying to represent.
(drn (andif &options &mode s1 s2)
     (OPTIONS DFLTMODE RTX RTX) (NA NA ANY ANY)
     BINARY ; IF?
     #f
)
(drn (orif &options &mode s1 s2)
     (OPTIONS DFLTMODE RTX RTX) (NA NA ANY ANY)
     BINARY ; IF?
     #f
)

; `bitfield' is an experimental operation.
; It's not really needed but it might help simplify some things.
;
;(drn (bitfield mode src start length)
;     ...
;     ...
;)

; Conversions.

(drn (ext &options &mode s1)
     (OPTIONS INTMODE RTX) (NA NA ANY)
     UNARY
     #f
)
(drn (zext &options &mode s1)
     (OPTIONS INTMODE RTX) (NA NA ANY)
     UNARY
     #f
)
(drn (trunc &options &mode s1)
     (OPTIONS INTMODE RTX) (NA NA ANY)
     UNARY
     #f
)
(drn (fext &options &mode s1)
     (OPTIONS FLOATMODE RTX) (NA NA ANY)
     UNARY
     #f
)
(drn (ftrunc &options &mode s1)
     (OPTIONS FLOATMODE RTX) (NA NA ANY)
     UNARY
     #f
)
(drn (float &options &mode s1)
     (OPTIONS FLOATMODE RTX) (NA NA ANY)
     UNARY
     #f
)
(drn (ufloat &options &mode s1)
     (OPTIONS FLOATMODE RTX) (NA NA ANY)
     UNARY
     #f
)
(drn (fix &options &mode s1)
     (OPTIONS INTMODE RTX) (NA NA ANY)
     UNARY
     #f
)
(drn (ufix &options &mode s1)
     (OPTIONS INTMODE RTX) (NA NA ANY)
     UNARY
     #f
)

; Comparisons.
; MODE is the mode of S1,S2.  The result always has mode BI.

(drn (eq &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (ne &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
; ??? In non-sim case, ensure s1,s2 is in right C type for right result.
(drn (lt &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (le &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (gt &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (ge &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
; ??? In non-sim case, ensure s1,s2 is in right C type for right result.
(drn (ltu &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (leu &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (gtu &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)
(drn (geu &options &mode s1 s2)
     (OPTIONS ANYMODE RTX RTX) (NA NA OP0 MATCH1)
     BINARY
     #f
)

; Set membership.
; Useful in ifield assertions.

; Return a boolean (BI mode) indicating if VALUE is in SET.
; VALUE is any constant rtx.  SET is a `number-list' rtx.

(drn (member &options &mode value set)
     (OPTIONS DFLTMODE RTX RTX) (NA NA INT INT)
     MISC
     (begin
       (if (not (rtx-constant? value))
	   (estate-error *estate* "`member rtx'"
			 "value is not a constant" value))
       (if (not (rtx-kind? 'number-list set))
	   (estate-error *estate* "`member' rtx"
			 "set is not a `number-list' rtx" set))
       (if (memq (rtx-constant-value value) (rtx-number-list-values set))
	   (rtx-true)
	   (rtx-false)))
)

(drn (number-list &options &mode value-list)
     (OPTIONS INTMODE NUMBER . NUMBER) (NA NA NA . NA)
     MISC
     #f
)

; Conditional execution.

; FIXME: make syntax node?
(drn (if &options &mode cond then . else)
     (OPTIONS ANYMODE TESTRTX RTX . RTX) (NA NA ANY OP0 . MATCH2)
     IF
     (apply e-if (append! (list *estate* mode cond then) else))
)

; ??? The syntax here isn't quite that of Scheme.  A condition must be
; followed by a result expression.
; ??? Intermediate expressions (the ones before the last one) needn't have
; the same mode as the result.
(drsn (cond &options &mode . cond-code-list)
      (OPTIONS ANYMODE . CONDRTX) (NA NA . OP0)
      COND
      #f
)

; ??? Intermediate expressions (the ones before the last one) needn't have
; the same mode as the result.
(drn (case &options &mode test . case-list)
     (OPTIONS ANYMODE RTX . CASERTX) (NA NA ANY . OP0)
     COND
     #f
)

; parallel, sequence, do-count

; This has to be a syntax node as we don't want EXPRS to be pre-evaluated.
; All semantic ops must have a mode, though here it must be VOID.
; IGNORE is for consistency with sequence.  ??? Delete some day.
; ??? There's no real need for mode either, but convention requires it.

(drsn (parallel &options &mode ignore expr . exprs)
      (OPTIONS VOIDMODE LOCALS RTX . RTX) (NA NA NA VOID . VOID)
      SEQUENCE
      #f
)

; This has to be a syntax node to handle locals properly: they're not defined
; yet and thus pre-evaluating the expressions doesn't work.
; ??? This should create a closure.

(drsn (sequence &options &mode locals expr . exprs)
      (OPTIONS ANYMODE LOCALS RTX . RTX) (NA NA NA OP0 . OP0)
      SEQUENCE
      #f
)

; This has to be a syntax node to handle iter-var properly: it's not defined
; yet and thus pre-evaluating the expressions doesn't work.

(drsn (do-count &options &mode iter-var nr-times expr . exprs)
      (OPTIONS VOIDMODE ITERATION RTX RTX . RTX) (NA NA NA INT VOID . VOID)
      SEQUENCE
      #f
)

; Internal rtx to create a closure.
; Internal, so it does not appear in rtl.texi.

(drsn (closure &options &mode expr env)
      (OPTIONS DFLTMODE RTX ENV) (NA NA NA NA)
      MISC
      #f
)

)) ; End of def-rtx-funcs
