; intrinsics support generator support routines.
; 
; This entire file is deeply littered with mep-specific logic. You have
; been warned.
;
; Copyright (C) 2000, 2001, 2002, 2003, 2009 Red Hat, Inc.
; This file is part of CGEN.

; Specify which application.
(set! APPLICATION 'INTRINSICS)

(debug-enable 'backtrace)

; String containing copyright text.
(define CURRENT-COPYRIGHT #f)

; String containing text defining the package we're generating code for.
(define CURRENT-PACKAGE #f)

; Initialize the options.
(define (option-init!)
  (set! CURRENT-COPYRIGHT copyright-fsf)
  (set! CURRENT-PACKAGE package-gnu-simulators)
  *UNSPECIFIED*
  )

(define (intrinsics-analyze!)
  (arch-analyze-insns! CURRENT-ARCH
		       #t  ; include aliases
		       #t) ; do analyze the semantics
  )

;; Shortcuts for commonly-used functions.
(define sa string-append)
(define (st x) (stringize x " "))

;; HELPER FUNCTIONS
;; ----------------

;; True if FN returns the same value for FIRST and SECOND.
(define (same? fn first second)
  (equal? (fn first) (fn second)))

;; True if predicate FN holds for both FIRST and SECOND.
(define (both? fn first second)
  (and (fn first) (fn second)))

;; True if FN holds for every element of LIST.
(define (for-all? fn list)
  (let loop ((list list))
    (or (null? list)
	(and (fn (car list))
	     (loop (cdr list))))))

;; True if FN holds for one element of LIST.
(define (exists? fn list)
  (let loop ((list list))
    (and (pair? list)
	 (or (fn (car list))
	     (loop (cdr list))))))

;; True if LIST1 and LIST2 are the same length and (FN X Y) holds for
;; each (X Y) in the zipped list.
(define (for-all-pairs? fn list1 list2)
  (let loop ((list1 list1) (list2 list2))
    (or (both? null? list1 list2)
	(and (both? pair? list1 list2)
	     (fn (car list1) (car list2))
	     (loop (cdr list1) (cdr list2))))))

;; Use (SETTER ELEM INDEX) to assign some number INDEX to each element
;; ELEM of LIST.  BASE is the index of the first element; other elements
;; are numbered incrementally.  Return the first unused index value.
(define (number-list setter list base)
  (let loop ((list list) (index base))
    (if (null? list)
	index
	(begin
	  (setter (car list) index)
	  (loop (cdr list) (+ index 1))))))

;; Apply FN to every list of arguments in ARGS.
(define (apply-list fn args)
  (for-each (lambda (list) (apply fn list)) args))

;; Sort list ELEMS with partial order FN, where (FN X Y) is true iff X "<=" Y.
(define (sort-partial elems fn)
  (if (null? elems)
      elems
      (let ((sorted (list (car elems))))
	(for-each
	 (lambda (elem)
	   (let loop ((pos sorted))
	     (if (fn elem (car pos))
		 (begin
		   (set-cdr! pos (cons (car pos) (cdr pos)))
		   (set-car! pos elem))
		 (if (null? (cdr pos))
		     (set-cdr! pos (list elem))
		     (loop (cdr pos))))))
	 (cdr elems))
	sorted)))

;; Generate preprocessor macro names, suitable for use as bitmasks.
(define (bitmask-name prefix name)
  (string-upcase (sa prefix "_" (gen-c-symbol name))))

;; Return an inclusive OR of every bitmask member in NAMES.
(define (bitmask prefix names)
  (if (null? names)
      "0"
      (stringize (map (lambda (x) (bitmask-name prefix x)) names) "|")))

;; Assign values to every bitmask in NAMES.
(define (define-bitmasks prefix names)
  (number-list
   (lambda (name index)
     (string-write "#define " (bitmask-name prefix name)
		   " " (st (logsll 1 index)) "\n"))
   names 0)
  (string-write "\n"))

;; Convert ISA symbol ISA into a target-frobbed string
(define (convert-isa isa)
  (target:frob-isa-name (symbol->string isa)))

;; PRETTY-PRINTER SUPPORT
;; ----------------------

;; How many spaces to indent the next line.
(define indentation 0)

;; End the current line and indent the new one.
(define (line-break)
  (string-write "\n" (make-string indentation #\space)))

;; Helper functions, useful as arguments to WRITE-LIST.
(define (comma-break)
  (string-write ", "))

(define (comma-line-break)
  (string-write ",")
  (line-break))

;; Execute BODY so that every call to LINE-BREAK will indent by
;; INDENT more spaces than it does now.
(defmacro write-with-indent (indent . body)
  `(begin
     (set! indentation (+ indentation ,indent))
     ,(cons 'begin body)
     (set! indentation (- indentation ,indent))))

;; Write PREFIX, then execute BODY so that every call to LINE-BREAK
;; will indent to the end of the prefix.  Write SUFFIX afterwards.
;;
;; This function should only be called at the start of a new line.
(defmacro write-construct (prefix suffix . body)
  `(begin
     (string-write ,prefix)
     (write-with-indent (string-length ,prefix) ,(cons 'begin body))
     (string-write ,suffix)))

;; Write out each element of LIST individually using WRITE.  Use (BREAK)
;; to separate the elements.
(define (write-list break list write)
  (if (pair? list)
      (begin
	(write (car list))
	(for-each (lambda (x) (break) (write x)) (cdr list)))))

;; Like WRITE-LIST, but write DUMMY if the list is empty.
(define (write-nonempty-list break list write dummy)
  (if (null? list)
      (string-write dummy)
      (write-list break list write)))

;; MACROS
;; ------

;; little macro for making assoc tables with nice names
(defmacro deftable (basename)
  (let* ((table (symbol-append basename '-table))
	 (initializer (symbol-append 'init- basename '!))
	 (keys (symbol-append basename '-keys))
	 (getter (symbol-append 'get- basename))
	 (setter (symbol-append 'set- basename '!)))
    `(begin
       (define ,table '())
       (define (,initializer) (set! ,table '()))
       (define (,keys) (map car ,table))
       (define (,getter k) 
	 (let ((pair (assoc k ,table)))
	   (if pair (cdr pair) pair)))
       (define (,setter k v) 
	 (let ((pair (assoc k ,table)))
	   (if pair
	       (set-cdr! pair v)
	       (set! ,table (cons (cons k v) ,table))))))))

;; Make a very simple structure interface.  NAME is the structure's name
;; and FIELDS is a list of its fields.
;;
;;    (make-struct foo (f1 f2 f3 ...))
;;
;; defines the following functions:
;;
;;    (foo:make f1 f2 f3 ...)
;;	  Create a new object with the given values for fields F1, F2, F3...
;;
;;    (foo:f1 object)
;;	  Return the value of OBJECT's F1 field, or #f if OBJECT itself is #f.
;;
;;    (foo:set-f1! object value)
;;	  Set OBJECT's F1 field to VALUE.
;;
;; ... and likewise for the other fields.  Each structure is represented
;; as a vector of its elements.
(defmacro make-struct (name fields)
  (let ((commands (list `(define ,(symbol-append name ':make)
			   (lambda ,fields ,(cons 'vector fields))))))
    (number-list
     (lambda (field index)
       (let* ((setname (symbol-append name ':set- field '!))
	      (getname (symbol-append name ': field))
	      (setter `(define (,setname x val) (vector-set! x ,index val)))
	      (getter `(define (,getname x) (and x (vector-ref x ,index)))))
	 (set! commands (cons setter (cons getter commands)))))
     fields
     0)
    (cons 'begin commands)))


;; MEP-SPECIFIC DETAILS
;; --------------------

;; Predicates for recognizing coprocessor register set hardware names.
;; HW is the hardware name: a symbol, or #:unbound in some cases.
;;
;; At the moment, we do this by looking at the hardware's name as a
;; string; it would be more graceful to handle this with an attribute.
;;
;; Older MeP .cpu files call the coprocessor register sets h-cr,
;; h-cr64, and h-ccr.  Newer versions of a2cgen suffix the hardware
;; names for the coprocessor's registers with the name of the
;; coprocessor, and the me_module number.  So, for example, if
;; me_module 3 has an rhcop coprocessor, its register sets will be
;; called h-cr64-rhcop-3, h-cr-rhcop-3, and h-ccr-rhcop-3.

;; Return a predicate that recognizes hardware names that start with
;; PREFIX.  PREFIX is a string, like "h-cr"; the returned predicate
;; will return true if its argument is the symbol whose name is
;; PREFIX, (e.g. 'h-cr), or any symbol whose name begins with PREFIX
;; followed by a hyphen (e.g. 'h-cr-rhcop-1).
(define (suffixed-hardware-recognizer prefix)
  ;; Precompute some stuff.
  (let* ((no-hyphen-sym (string->symbol prefix))
         (hyphenated (string-append prefix "-"))
         (hyphenated-len (string-length hyphenated)))
    (lambda (obj)
      (or (eq? obj no-hyphen-sym)
          (and (symbol? obj)
               (let ((name (symbol->string obj)))
                 (and (>= (string-length name) hyphenated-len)
                      (string=? (substring name 0 hyphenated-len)
                                hyphenated))))))))

(define is-h-cr64?    (suffixed-hardware-recognizer "h-cr64"))
(define is-h-cr?      (suffixed-hardware-recognizer "h-cr"))
(define is-h-ccr?     (suffixed-hardware-recognizer "h-ccr"))

;; Return the gcc rtl mode that should be used for operand OP.
;; Return #f to use the default, target-independent choice.
(define (target:guess-mode op)
  (cond
   ((equal? (md-operand:cdata op) 'FMAX_INT) "SI")
   ((equal? (md-operand:cdata op) 'FMAX_FLOAT) "SF")
   ((is-h-cr64? (md-operand:hw op)) "DI")
   ((is-h-cr? (md-operand:hw op)) "SI")
   ((not (memory? (md-operand:type op))) "SI")
   (else #f)))

;; Return the list of arguments for an intrinsic function.  ARGUMENTS is
;; a list of the operands found in the instruction's syntax string, in the
;; order they appear.  OUTPUT-OPERANDS is a list of all the instruction's
;; output operands (no particular order).  Both lists contain md-operands.
;;
;; Normally ARGUMENTS itself is the correct return value, but we
;; need a couple of MeP-specific hacks:
;;
;;   - Instructions that write to r0 do not make r0 a syntactic
;;   operand.  Instead, they embed "\\$0" in the syntax string.
;;   Cope with this by adding $0 to the beginning of the list
;;   if written.
;;
;;   - $spr and $tpr can appear in the syntax string but are
;;   not supposed to be treated as arguments to the intrinsic.
(define (target:frob-arguments arguments output-operands)
  (set! arguments (find (lambda (op)
			  (not (member (md-operand:name op) '(tpr spr))))
			arguments))
  (let ((r0-writes (find (lambda (op)
			   (equal? (md-operand:fixed-register op) 0))
			 output-operands)))
    (if (pair? r0-writes)
	(set! arguments (cons (car r0-writes) arguments))))
  arguments)

;; Convert the given cgen ISA name into its gcc equivalent.
;; cgen names such as 'ext_core<X>' and 'ext_cop<X>_YY' become 'ext<X>'.
(define (target:frob-isa-name isa)
  (cond
   ((equal? "ext_cop" (string-take 7 isa))
    (sa "ext" (string-drop 7 (string-drop -3 isa))))

   ((equal? "ext_core" (string-take 8 isa))
    (sa "ext" (string-drop 8 isa)))

   (else isa)))

;; Apply FN once for each ISA.  The first argument to FN is a user-readable
;; string that describes the ISA.  The second argument is the ISA name
;; returned by frob-isa-name.
(define (target:for-each-isa! fn)
  (for-each (lambda (entry)
	      (apply fn (car entry) (sa "ext" (st (cadr entry))) '()))
	    (cdr (attr-values (current-attr-lookup 'CONFIG)))))

;; Return the number of the first register belonging to the given
;; hardware element.
(define (target:base-reg hw)
  (cond
   ((eq? hw 'h-gpr) 0)             ; core registers
   ((eq? hw 'h-csr) 16)            ; control registers
   ((is-h-cr? hw) 48)              ; 32-bit coprocessor registers
   ((is-h-cr64? hw) 48)            ; 64-bit coprocessor registers (same)
   ((is-h-ccr? hw) 80)             ; coprocessor control registers
   (else 0)))

;; Return the constraint string for register operand OP.
(define (target:reg-constraint op)
  (case (md-operand:fixed-register op)
    ((0) "z")
    ((23) "h") ;; hi
    ((24) "l") ;; lo
    (else
     (cond
      ;; "tiny" registers, in the range 0..7
      ((equal? (md-operand:ifield op) 'f-rn3) "t")

      (else
       (let ((hw (md-operand:hw op)))
         (cond
          ((eq? hw 'h-gpr) "r")    ; core registers
          ((eq? hw 'h-csr) "c")    ; control registers
	  ((or (is-h-cr64? hw)	   ; 32-bit coprocessor registers
	       (is-h-cr? hw))	   ; 64-bit coprocessor registers
	   (if (equal? (md-operand:length op) 4) "em" "x"))
          ((is-h-ccr? hw) "y")     ; coprocessor control registers
          (else "r"))))))))

;; The first hard register available to the intrinsics generator.
(define target:first-unused-register 113)

;; The instructions mapped to a particular intrinsic can be subdivided
;; into groups, each representing a particular form of code generation.
;; In the MeP case, we have one group for __vliw functions and one group
;; for normal functions.
(define target:groups '(normal vliw))

;; True if INSN belongs to GROUP, where GROUP is a membmer of TARGET:GROUPS.
(define (target:belongs-to-group? insn group)
  (case (obj-attr-value (md-insn:cgen-insn insn) 'SLOT)
    ((NONE)
     (if (obj-attr-value (md-insn:cgen-insn insn) 'SLOTS)
	 (case (obj-attr-value (md-insn:cgen-insn insn) 'SLOTS)
	   ((CORE) #t)
	   ((C3) (equal? group 'normal))
	   (else (equal? group 'vliw))
	   )
	 (equal? group 'normal)))
    ((C3) (equal? group 'normal))
    ((V1 V3) (equal? group 'vliw))))

;; Convert an intrinsic's cgen name into the name of its builtin function.
(define (target:builtin-name name)
  (string-append "mep_" (gen-c-symbol name)))

;; Helper functions for getting the values of certain mep-specific gcc
;; attributes.  In each case INSN is a cgen instruction (not an md-insn).
(define (-may-trap-attribute insn)
  (if (obj-has-attr? insn 'MAY_TRAP) "yes" "no"))

(define (-slot-attribute insn)
  (if (exists? (lambda (isa)
		 (or (equal? isa 'mep)
		     (equal? (string-take 8 (st isa)) "ext_core")))
	       (bitset-attr->list (obj-attr-value insn 'ISA)))
      "core"
      "cop"))

(define (-latency-attribute insn)
  (if (obj-attr-value insn 'LATENCY)
      (st (obj-attr-value insn 'LATENCY))
      "0"))

(define (-length-attribute insn)
  (st (/ (insn-length insn) 8)))

(define (-stall-attribute insn)
  (string-downcase (st (obj-attr-value insn 'STALL))))

(define (-slots-attribute insn)
  (let ((slots (obj-attr-value insn 'SLOTS)))
    (if slots
	(string-downcase (gen-c-symbol (st slots)))
	"core")))

;; Return the define_insn attributes for INSN as a list of (NAME . VALUE)
;; pairs.
(define (target:attributes insn)
  (let ((cgen-insn (md-insn:cgen-insn insn)))
    (list (cons 'may_trap (-may-trap-attribute cgen-insn))
	  (cons 'latency (-latency-attribute cgen-insn))
	  (cons 'length (-length-attribute cgen-insn))
	  (cons 'slot (-slot-attribute cgen-insn))
	  (cons 'slots (-slots-attribute cgen-insn))
	  (if (eq? (obj-attr-value cgen-insn 'STALL) 'SHIFTI)
	      (cons 'shiftop "operand2")
	      (cons 'stall (-stall-attribute cgen-insn))))))

;; Define target-specific fields of cgen_insn.  In the MeP case, we want
;; to record how long the intruction is.
(define (target:declare-fields)
  (sa "\n"
      "  /* The length of the instruction, in bytes.  */\n"
      "  int length;\n"))

;; Initialize the fields described above.
(define (target:initialize-fields insn)
  (comma-line-break)
  (string-write (-length-attribute (md-insn:cgen-insn insn))))

;; Use WELL-KNOWN-INTRINSIC to define the names of builtins that
;; gcc might treat specially.
(define (target:add-well-known-intrinsics)
  (apply-list (lambda args
		(apply well-known-intrinsic args)
		(apply well-known-intrinsic (sa (car args) "3") (cdr args))
		(apply well-known-intrinsic (sa (car args) "i") (cdr args))
		(apply well-known-intrinsic (sa (car args) "i3") (cdr args)))
	      `(("cadd" plus)
		("csub" minus)
		("cand" and)
		("cor" ior)
		("cnor" nor)
		("cxor" xor)
		("csll" ashift)
		("csrl" lshiftrt)
		("csra" ashiftrt)))

  (apply-list well-known-intrinsic
	      `(("cmov")
		("cpmov")
		("cmovi" set)
		("cmov1")
		("cmov2")
		("cmovc1")
		("cmovc2")
		("cmovh1")
		("cmovh2")
		("cneg" neg)
		("cmula0")
		("xmula0")
		("cextuh")
		("cextub")
		("cexth")
		("cextb")
		("fmovs")
		("fadds" plus "TARGET_FMAX")
		("fsubs" minus "TARGET_FMAX")
		("fmuls" mult "TARGET_FMAX")
		("fdivs" div "TARGET_FMAX")
		("fsqrts" sqrt "TARGET_FMAX")
		("fabss" abs "TARGET_FMAX")
		("fnegs" neg "TARGET_FMAX")
		("ftruncws" fix "TARGET_FMAX")
		("fcvtsw" float "TARGET_FMAX")
		("fcmpus" unordered "TARGET_FMAX")
		("fcmpues" uneq "TARGET_FMAX")
		("fcmpuls" unlt "TARGET_FMAX")
		("fcmpules" unle "TARGET_FMAX")
		("fcmpes" eq "TARGET_FMAX")
		("fcmplis" lt "TARGET_FMAX")
		("fcmpleis" le "TARGET_FMAX"))))

;; INTRINSIC OPERANDS
;; ------------------
;;
;; Each intrinsic operand is represented by a unique MD-OPERAND.
;; These objects refer back to normal cgen operands but add the extra
;; information needed for intrinsics support.  Each MD-OPERAND belongs
;; to exactly one MD-INSN.
;;
;;    OP is the cgen operand
;;
;;    IFIELD-VALUE is the constant value that the instruction assigns
;;    to the operand's field, or #f if the field isn't constant.
;;
;;    ARG-INDEX is the position of this operand in the intrinsic's
;;    argument list, or #f if the operand is not an argument.
;;
;;    READ-INDEX is the match_operand number assigned to this operand
;;    when it appears in a right-hand context.  The value is #f if we
;;    never generate such a match_operand, either because the operand
;;    is a strict lvalue or because ARG-INDEX is #f.
;;
;;    WRITE-INDEX is like READ-INDEX but is used for left-hand contexts.
;;
;;    MODE is the operand's gcc mode (SI, etc.).
(make-struct md-operand (op ifield-value arg-index
			 read-index write-index mode))

;; Helper functions to extract commonly-used fields from the
;; underlying cgen operand.
(define (md-operand:name op) (op:sem-name (md-operand:op op)))
(define (md-operand:type op) (op:type (md-operand:op op)))
(define (md-operand:register? op) (register? (md-operand:type op)))
(define (md-operand:index op) (op:index (md-operand:op op)))
(define (md-operand:length op) (op:length (md-operand:op op)))
(define (md-operand:hw op) (op:hw-name (md-operand:op op)))
(define (md-operand:ifield op)
  (let ((ifield (op-ifield (md-operand:op op))))
    (and ifield (obj:name ifield))))

;; Functions to access well-known operand attributes.
(define (md-operand:cdata op) (obj-attr-value (md-operand:op op) 'CDATA))
(define (md-operand:alignment op) (obj-attr-value (md-operand:op op) 'ALIGN))
(define (md-operand:sem-only? op) (obj-has-attr? (md-operand:op op) 'SEM-ONLY))

;; Return true if operand OP represents the program counter.
(define (md-operand:pc? op)
  (or (equal? (md-operand:name op) 'pc)
      (pc? (md-operand:type op))))

;; Return true if operand OP must be mapped to a label.  This is only
;; ever true of argument operands.
(define (md-operand:label? op)
  (and (class-instance? <hw-immediate> (md-operand:type op))
       (equal? (md-operand:cdata op) 'LABEL)))

;; Return true if OP is an immediate operand.
(define (md-operand:immediate? op)
  (class-instance? <hw-immediate> (md-operand:type op)))

;; Return true if operand OP is an index into a register file.  gcc will
;; convert them into REG rtxes.
(define (md-operand:regnum? op)
  (equal? (md-operand:cdata op) 'REGNUM))

;; If operand OP is a fixed hard register, return the number GCC assigns
;; to it, otherwise return #f.
(define (md-operand:fixed-register op)
  (and (not (md-operand:pc? op))
       (md-operand:register? op)
       (let ((constant (if (equal? 'constant
				   (hw-index:type (md-operand:index op)))
			   (hw-index:value (md-operand:index op))
			   (md-operand:ifield-value op))))
	 (and constant
	      (+ constant (target:base-reg (md-operand:hw op)))))))

;; SPECIFIC TO 32-BIT TARGETS
;; Guess the gcc rtl mode for operand OP.  First see whether it uses
;; a known hardware element, then try the CDATA attribute.
(define (md-operand:guess-mode op)
  (or (target:guess-mode op)
      (case (md-operand:cdata op)
	((SHORT USHORT) "HI")
	((CHAR UCHAR) "QI")
	(else "SI"))))

;; Return true if operand OP is a signed immediate.
(define (md-operand:signed? op)
  (equal? (md-operand:hw op) 'h-sint))

;; If OP accepts only CONST_INTs, return the lowest value it accepts.
(define (md-operand:lower-bound op)
  (if (md-operand:signed? op)
      (- (logsll 1 (+ (md-operand:alignment op)
		      (md-operand:length op)
		      -2)))
      0))

;; Likewise the highest value + 1.
(define (md-operand:upper-bound op)
  (logsll 1 (+ (md-operand:alignment op)
	       (md-operand:length op)
	       (if (md-operand:signed? op) -2 -1))))

;; Return the name of an immediate predicate for operand OP, assuming
;; that OP should accept only CONST_INTs.  We define these predicates
;; in the gcc include file.
(define (md-operand:immediate-predicate op)
  (gen-c-symbol (sa "cgen_" (st (md-operand:hw op)) "_"
		    (st (md-operand:length op))
		    "a" (st (md-operand:alignment op))
		    "_immediate")))

;; Return the match_operand predicate for operand OP.
(define (md-operand:predicate op lvalue?)
  (cond
   ((memory? (md-operand:type op)) "memory_operand")
   ((md-operand:label? op) "immediate_operand")
   ((md-operand:immediate? op) (md-operand:immediate-predicate op))
   (lvalue? "nonimmediate_operand")
   (else "general_operand")))


;; Return the gcc rtx for non-argument operand OP.
(define (md-operand:fixed-rtx op)
  (cond
   ((memory? (md-operand:type op))
    (sa "(mem:" (md-operand:mode op) " (scratch:SI))"))

   ((md-operand:fixed-register op)
    (sa "(reg:" (md-operand:mode op) " "
	(st (md-operand:fixed-register op)) ")"))

   (else
    (error (sa "bad intrinsic operand \"" (st (md-operand:name op))
	       "\": need constant or ifield indexed register, got "
	       (st (hw-index:type (md-operand:index op))))))))

;; Return the constraint string for operand OP.  LVALUE? is true if the
;; operand is appearing in a left-hand context.  For read-write operands,
;; the rvalue operand should have a numerical constraint giving the
;; number of the lvalue.
(define (md-operand:constraint lvalue? op)
  (cond
   ((and (not lvalue?) (md-operand:write-index op))
    (st (md-operand:write-index op)))
   ((md-operand:immediate? op) "")
   (else (target:reg-constraint op))))

;; Return the rtl pattern for operand OP.  CONTEXT is LHS if the operand
;; is being used as an lvalue, RHS if it is being used as an rvalue in the
;; first set of a pattern and RHS-COPY if it is being used as an rvalue
;; in subsequent sets.
(define (md-operand:to-string context op)
  (cond
   ((md-operand:pc? op) "(pc)")
   (else
    (let* ((lvalue? (equal? context 'lhs))
	   (index (if lvalue?
		      (md-operand:write-index op)
		      (md-operand:read-index op))))
      (cond
       ((not index) (md-operand:fixed-rtx op))
       ((equal? context 'rhs-copy) (sa "(match_dup " (st index) ")"))
       (else
	(sa "(match_operand:"
	    (md-operand:mode op) " " (st index) " \""
	    (md-operand:predicate op lvalue?) "\" \"" (if lvalue? "=" "")
	    (md-operand:constraint lvalue? op) "\")")))))))


;; GCC INSTRUCTION PATTERNS
;; ------------------------
;;
;; If we need to generate a define_insn pattern for a particular cgen
;; instruction, we will create a unique MD-INSN for it.  Each MD-INSN
;; is associated with a (shared) INTRINSIC object.
;;
;;    MD-NAME is the name of the define_insn pattern
;;
;;    INDEX is a unique number given to this instruction.  Instructions
;;    are numbered according to their position in the .md output file,
;;    the first instruction having index 0.
;;
;;    INTRINSIC is the intrinsic object to which this instruction belongs.
;;
;;    CGEN-INSN is the underlying cgen insn.
;;
;;    SYNTAX is the output of syntax-break-out with cgen operands
;;    converted to md-operands.
;;
;;    ARGUMENTS is a list of the operands that act as formal arguments
;;    to the intrinsic function.  Usually this is the same as SYNTAX
;;    with strings removed, but there can be target-specific reasons
;;    for using a different argument list.
;;
;;    INPUTS is a list of the operands that appear in a right-hand
;;    context within the define_insn pattern.  If a member of this
;;    list is also in ARGUMENTS, it will have a valid READ-INDEX.
;;
;;    OUTPUTS is like INPUTS except that it lists the operands that
;;    appear in a left-hand context.  Argument operands in this list
;;    will have a valid WRITE-INDEX.
;;
;;    OPERANDS is a concatenation of OUTPUTS and INPUTS.
;;
;;    CPTYPE is the type to use for coprocessor operands (like V4HI)
;;
;;    CRET? is set if the first argument is returned rather than passed.

(make-struct md-insn (md-name index intrinsic cgen-insn syntax arguments
		      inputs outputs operands cptype cret?))

;; Return the name of the underlying cgen insn, mostly used for
;; error reporting.
(define (md-insn:cgen-name insn) (obj:name (md-insn:cgen-insn insn)))

;; Return true if INSN is inherently volatile, meaning that it has
;; important effects that are not described by its gcc rtx pattern.
;; This is true for any instruction with the VOLATILE attribute,
;; any instruction without output operands (including those with
;; no semantics at all) and any instruction that reads from or
;; writes to a REGNUM operand.
(define (md-insn:volatile? insn)
  (or (null? (md-insn:outputs insn))
      (exists? md-operand:regnum? (md-insn:operands insn))
      (obj-has-attr? (md-insn:cgen-insn insn) 'VOLATILE)))

;; Return the list of ISAs that implement INSN.  Ignore those that
;; were excluded on the command line.
(define (md-insn:isas insn)
  (map convert-isa
       (find (lambda (isa) (member isa intrinsics-isas))
	     (bitset-attr->list
	      (obj-attr-value (md-insn:cgen-insn insn) 'ISA)))))

;; The full list of instruction groups.  As well target-specific groups,
;; this includes "known-code", meaning that the instruction uses a specific
;; rtl code instead of an unspec.
(define md-insn-groups (cons 'known-code target:groups))

;; Return the list of groups to which INSN belongs.
(define (md-insn:groups insn)
  (let ((target-groups (find (lambda (group)
			       (target:belongs-to-group? insn group))
			     target:groups)))
    (if (intrinsic:unspec-version (md-insn:intrinsic insn))
	(cons 'known-code target-groups)
	target-groups)))

;; Partial ordering of syntax elements.  Return true if ELEM1 and ELEM2
;; are compatible and ELEM2's range is a superset of ELEM1's.  The rules
;; are that:
;;
;;    - Identical syntax strings are compatible.
;;
;;    - Immediate operands are compatible if the range of one is contained
;;    within the range of the other.
;;
;;    - Other types of operand are compatible if they use the same
;;    hardware element and have the same length.
(define (syntax<=? elem1 elem2)
  (or (and (both? vector? elem1 elem2)
	   (if (both? md-operand:immediate? elem1 elem2)
	       (and (>= (md-operand:alignment elem1)
			(md-operand:alignment elem2))
		    (>= (md-operand:lower-bound elem1)
			(md-operand:lower-bound elem2))
		    (<= (md-operand:upper-bound elem1)
			(md-operand:upper-bound elem2)))
	       (and (same? md-operand:hw elem1 elem2)
		    (same? md-operand:length elem1 elem2))))
      (and (both? string? elem1 elem2)
	   (string=? elem1 elem2))))

;; Helper functions for comparing lists of operands or lists of syntax
;; pieces using the above ordering.
(define (md-insn:operands<=? insn1 insn2)
  (for-all-pairs? syntax<=?
		  (md-insn:operands insn1)
		  (md-insn:operands insn2)))

(define (md-insn:syntax<=? insn1 insn2)
  (for-all-pairs? syntax<=?
		  (md-insn:syntax insn1)
		  (md-insn:syntax insn2)))


;; INTRINSICS
;; ----------
;;
;; Intrinsics have two names, the one that appears in the cgen file
;; and the one that is given to the builtin function.  The former is
;; its "cgen name" and is only relevant during the analysis phase.
;;
;;    NAME is the name of the intrinsic's builtin function.  It is
;;    generated from the cgen name by TARGET:BUILTIN-NAME.
;;
;;    INDEX is the index of this intrinsic in the global INTRINSICS list.
;;
;;    UNSPEC is the unspec number to use for the right hand side of the
;;    first SET pattern.  Add 2 for each subsequent output (so that real
;;    and shadow registers can use different unspec numbers).
;;
;;    HOOK is the gcc-hook object associated with this intrinsic,
;;    or #f if none.
;;
;;    ISAS maps ISA names to the most general implementation of the
;;    intrinsic for that ISA.  Used for error checking.
(make-struct intrinsic (name index unspec hook isas))

;; Short-cut functions
(define (intrinsic:unspec-version intrinsic)
  (gcc-hook:unspec-version (intrinsic:hook intrinsic)))

;; Return the maximum of HIGHEST and the length of insn property PROPERTY
;; for any implementation of INSTRINSIC.  PROPERTY can the something
;; like MD-INSN:INPUTS or MD-INSN:OUTPUTS.
(define (intrinsic:max highest property intrinsic)
  (for-each
   (lambda (isa)
     (set! highest (max highest (length (apply property (cdr isa) '())))))
   (intrinsic:isas intrinsic))
  highest)

;; GLOBAL VARIABLES
;; ----------------

;; Maps cgen intrinsic names to intrinsic objects.
(deftable intrinsic)

;; The list of all intrinsics.  After the analysis phase, this list
;; is in index order.
(define intrinsics '())

;; The list of all instructions, in the order they appear in the .md file.
;; When two instructions are compatible, but one is more general than
;; the other, the more general one will come after the less general one.
(define md-insns '())

;; Maps fixed hard registers onto shadow global registers.
(define shadow-registers '())

;; Create an intrinsic with the given cgen name and gcc hook.  Add it to
;; INTRINSICS and INTRINSIC-TABLE.
(define (add-intrinsic name hook)
  (let ((intrinsic (intrinsic:make (target:builtin-name name) #f #f hook '())))
    (set! intrinsics (cons intrinsic intrinsics))
    (set-intrinsic! name intrinsic)
    intrinsic))

;; Return a shadow version of hard register REG.
(define (get-shadow reg)
  (or (assoc-ref shadow-registers reg)
      (let ((retval (+ target:first-unused-register
		       (length shadow-registers))))
	(set! shadow-registers
	      (append! shadow-registers (list (cons reg retval))))
	retval)))

;; WELL-KNOWN INTRINSICS
;; ---------------------

;; gcc might have a special use for certain intrinsics.  Such intrinsics
;; have a GCC-HOOK structure attached.
;;
;;    RTL-CODE is an rtl code that can be used in the define_insn
;;    pattern instead of usual unspec or unspec_volatile.  Usually
;;    the field is an arithmetic or logic code, but it can also be:
;;
;;        - 'set': the intrinsic implements a move of some sort.
;;        - 'nor': represented in gcc as (and (not X) (not Y)).
;;	  - #f: use unspecs as normal.
;;
;;    CONDITION is a condition that must be true for the RTL-CODE
;;    version of the instruction to be available.
;;
;;    UNSPEC-VERSION is a version of the same intrinsic that has no
;;    gcc-hook structure.  It is sometimes useful to have two versions
;;    of the same instrinsic, one with a specific rtl-code and one
;;    with a general unspec.  The former will allow more optimisations
;;    while the latter will act more like an inline asm statement.
(make-struct gcc-hook (rtl-code condition unspec-version))

;; Declare a well-known intrinsic with the given cgen name and
;; gcc-hook fields.
(define (well-known-intrinsic name . args)
  (let* ((rtl-code (and (> (length args) 0) (car args)))
	 (condition (and (> (length args) 1) (cadr args)))
	 (unspec-version (and rtl-code (add-intrinsic name #f))))
    (add-intrinsic name (gcc-hook:make rtl-code condition unspec-version))))

(target:add-well-known-intrinsics)


;; ANALYSIS PHASE
;; --------------

;; The next available unspec number.
(define next-unspec 1000)

;; Given cgen instruction INSN, return the cgen name of its intrinsic.
(define (intrinsic-name insn)
  (let ((name (obj-attr-value insn 'INTRINSIC)))
    (if (equal? name "") (symbol->string (obj:name insn)) name)))

;; Look up an intrinsic by its cgen name.  Create a new intrinsic
;; if the name hasn't been used yet.
(define (find-intrinsic name)
  (or (get-intrinsic name)
      (add-intrinsic name #f)))

;; If instruction INSN assigns to a constant value to OP's field,
;; record it in IFIELD-VALUE.
(define (check-ifield-value op insn)
  (let* ((name (md-operand:ifield op))
	 (ifield (and name (object-assq name (insn-iflds insn)))))
    (if (and ifield (ifld-constant? ifield))
	(md-operand:set-ifield-value! op (ifld-get-value ifield)))))

;; Create an md-insn from the given cgen instruction and add it to MD-INSNS.
(define (add-md-insn insn intrinsic md-prefix)
  (let* ((sfmt (insn-sfmt insn))
	 (operands '())

	 ;; Create a new md-operand for OP.
	 (new-operand (lambda (op)
			(let ((created (md-operand:make op #f #f #f #f #f)))
			  (set! operands (cons created operands))
			  (check-ifield-value created insn)
			  created)))

	 ;; Find an md-operand for OP, create a new one if we
	 ;; haven't seen it before.
	 (make-operand (lambda (op)
			 (let loop ((entry operands))
			   (if (null? entry)
			       (new-operand op)
			       (if (equal? (op:sem-name op)
					   (md-operand:name (car entry)))
				   (car entry)
				   (loop (cdr entry)))))))

	 ;; A partial order on md-operands.  Sort them by their position
	 ;; in the argument list, putting non-argument operands last.
	 ;;
	 ;; This ordering is needed when non-commutative intrinsics
	 ;; use a specific gcc rtl code.  For example, if we have
	 ;; an intrinsic:
	 ;;
	 ;;      sub (op0, op1, op2)
	 ;;
	 ;; which is known to do subtraction, we might use the MINUS
	 ;; rtl code in the define_insn pattern.  op1 must then be
	 ;; the first input operand and op2 must be the second:
	 ;;
	 ;;      (set op0 (minus op1 op2))
	 (op<= (lambda (x y)
		 (let ((xpos (md-operand:arg-index x))
		       (ypos (md-operand:arg-index y)))
		   (or (not ypos) (and xpos (<= xpos ypos))))))

	 ;; Create a version of the broken-out syntax in which
	 ;; each cgen operand is replaced by an md-operand.
	 (syntax (map (lambda (x)
			(if (operand? x) (make-operand x) x))
		      (syntax-break-out (insn-syntax insn))))

	 ;; All relevant outputs.
	 (outputs (find (lambda (op)
			  (or (md-operand:pc? op)
			      (md-operand:fixed-register op)
			      (not (md-operand:sem-only? op))))
			(map make-operand (sfmt-out-ops sfmt))))

	 ;; The arguments to the intrinsic function, represented as
	 ;; a list of operands.  Usually this is taken directly from
	 ;; the assembler syntax, but allow machine-specific hacks
	 ;; to modify the list.
	 (arguments (target:frob-arguments (find vector? syntax) outputs))

	 ;; The operands that we know to be inputs.  For tidiness' sake,
	 ;; remove (pc), which was no real meaning inside an unspec or
	 ;; unspec_volatile.
	 (inputs (find (lambda (op)
			 (and (not (md-operand:pc? op))
			      (or (md-operand:fixed-register op)
				  (not (md-operand:sem-only? op)))))
		       (map make-operand (sfmt-in-ops sfmt))))

	 ;; If an argument has not been classified as an input
	 ;; or an output, treat it as an input.  This helps us to
	 ;; deal with insns whose semantics have not been given.
	 (quiet-inputs (find (lambda (op)
			       (and (not (memq op inputs))
				    (not (memq op outputs))))
			     arguments))

	 ;; Allow an intrinsic to specify a type for coprocessor
	 ;; operands, as they tend to be insn-specific vector types.
	 (cptype (obj-attr-value insn 'CPTYPE))

	 (cret? (equal? (obj-attr-value insn 'CRET) 'FIRST))
	 )

    ;; Number each argument operand according to its position in the list.
    (number-list md-operand:set-arg-index! arguments 0)

    ;; Sort the inputs and outputs as described above.
    (set! inputs (sort-partial (append inputs quiet-inputs) op<=))
    (set! outputs (sort-partial outputs op<=))

    ;; Assign match_operand numbers to each argument.  Outputs should
    ;; have lower numbers than inputs.
    (number-list md-operand:set-read-index!
		 (find md-operand:arg-index inputs)
		 (number-list md-operand:set-write-index!
			      (find md-operand:arg-index outputs)
			      0))

    ;; Assign a mode to each operand.  If we have an output operand,
    ;; use its mode for all immediate operands.  This is mainly for
    ;; intrinsics which use rtl codes like 'plus': the source operands
    ;; are then expected to have the same mode as the destination.
    (for-each (lambda (op)
		(if (and (pair? outputs) (md-operand:immediate? op))
		    (md-operand:set-mode! op (md-operand:mode (car outputs)))
		    (md-operand:set-mode! op (md-operand:guess-mode op))))
	      (append outputs inputs))

    (set! md-insns
	  (cons (md-insn:make (sa md-prefix (gen-c-symbol (obj:name insn)))
			      #f intrinsic insn syntax
			      arguments inputs outputs
			      (append outputs inputs) cptype cret?)
		md-insns))))

;; Make INSN available when generating code for ISA, updating INSN's
;; intrinsic structure accordingly.  Insns are passed to this function
;; in .md file order.
(define (add-intrinsic-for-isa insn isa)
  (let* ((intrinsic (md-insn:intrinsic insn))
	 (entry (assoc isa (intrinsic:isas intrinsic))))
    (if (not entry)
	;; We haven't yet seen an implementation of this intrinsic for ISA.
	(intrinsic:set-isas! intrinsic
			     (cons (cons isa insn)
				   (intrinsic:isas intrinsic)))

	;; The intrinsic has already been implemented for ISA.
	;; Check whether INSN is at least as general as the bellwether
	;; implementation.  If it isn't, report an error, otherwise
	;; use INSN as the new bellwether.
	(let ((bellwether (cdr entry)))

;; This is temporarily disabled as some IVC2 intrinsics *do* have the
;; same actual signature and operands, but different bit encodings
;; depending on the slot.  This different syntax makes them not match.

;;	  (if (not (md-insn:syntax<=? bellwether insn))
;;	      (error (sa "instructions \"" (md-insn:cgen-name insn)
;;			 "\" and \"" (md-insn:cgen-name bellwether)
;;			 "\" are both mapped to intrinsic \""
;;			 (intrinsic:name intrinsic)
;;			 "\" but do not have a compatible syntax")))

;;	  (if (not (md-insn:operands<=? bellwether insn))
;;	      (error (sa "instructions \"" (md-insn:cgen-name insn)
;;			 "\" and \"" (md-insn:cgen-name bellwether)
;;			 "\" are both mapped to intrinsic \""
;;			 (intrinsic:name intrinsic)
;;			 "\" but do not have compatible semantics")))

	  (set-cdr! entry insn)))))

;; Return true if the given insn should be included in the output files.
(define (need-insn? insn)
  (not (member (insn-mnemonic insn) '("--unused--" "--reserved--" "--syscall--"))))

;; Set up global variables, if we haven't already.
(define (analyze-intrinsics!)
  (if (null? md-insns)
      (begin
	(message "Analyzing intrinsics...\n")

	;; Set up the global lists.
	(for-each
	 (lambda (insn)
	   (if (need-insn? insn)
	       (let ((intrinsic (find-intrinsic (intrinsic-name insn))))
		 (add-md-insn insn intrinsic "cgen_intrinsic_")
		 (if (intrinsic:unspec-version intrinsic)
		     (add-md-insn insn (intrinsic:unspec-version intrinsic)
				  "cgen_intrinsic_unspec_")))))
	 (current-insn-list))

	(set! md-insns (sort-partial md-insns md-insn:syntax<=?))

	;; Tell each object what position it has in its respective list.
	(number-list md-insn:set-index! md-insns 0)
	(number-list intrinsic:set-index! intrinsics 0)

	;; Check whether the mapping of instructions to intrinsics is OK.
	(for-each
	 (lambda (insn)
	   (for-each
	    (lambda (isa) (add-intrinsic-for-isa insn isa))
	    (md-insn:isas insn)))
	 md-insns)

	;; Assign unspec numbers to each intrinsic.
	(for-each
	 (lambda (intrinsic)
	   (intrinsic:set-unspec! intrinsic next-unspec)
	   (set! next-unspec
		 (+ next-unspec
		    (* 2 (intrinsic:max 1 md-insn:outputs intrinsic)))))
	 intrinsics))))


;; ITERATION FUNCTIONS
;; -------------------

(define (for-each-md-insn fn)
  (for-each fn md-insns))

(define (for-each-argument fn)
  (for-each-md-insn
   (lambda (insn)
     (for-each (lambda (op) (fn insn op))
	       (md-insn:arguments insn)))))

;; .MD GENERATOR
;; -------------

;; Write the output template for INSN's define_insn.
;; ??? Still MeP-specific.
(define (write-syntax insn)
  (let ((in-mnemonic? #t))
    (for-each
     (lambda (part)
       (cond
	((vector? part)
	 (let* ((name (md-operand:name part))
		(pos (lambda () (st (or (md-operand:read-index part)
					(md-operand:write-index part))))))
	   (cond
	    ((equal? name 'tpr) (string-write "$tp"))
	    ((equal? name 'spr) (string-write "$sp"))
	    ((equal? name 'csrn) (string-write "%" (pos)))
	    ((md-operand:label? part) (string-write "%l" (pos)))
	    (else (string-write "%" (pos))))))

	((and in-mnemonic? (equal? " " part))
	 (set! in-mnemonic? #f)
	 (string-write "\\\\t"))

	(else (string-write part))))
     (md-insn:syntax insn))))

;; Write the inputs to INSN, wrapped in an unspec, unspec_volatile,
;; or intrinsic-specific rtl code.  MODE is the mode should go after
;; the wrapper's rtl-code, such as "" or ":SI".  UNSPEC is the unspec
;; number to use, if an unspec is needed, and CONTEXT is as for
;; MD-OPERAND:TO-STRING.
(define (write-inputs context insn mode unspec)
  (let* ((code (gcc-hook:rtl-code (intrinsic:hook (md-insn:intrinsic insn))))
	 (inputs (map (lambda (op)
			(md-operand:to-string context op))
		      (md-insn:inputs insn))))
    (if (not code)
	(begin
	  (string-write (if (md-insn:volatile? insn)
			    "(unspec_volatile"
			    "(unspec")
			mode " [")
	  (write-with-indent 2
	    (line-break)
	    (if (null? inputs)
		(string-write "(const_int 0)")
		(write-list line-break inputs string-write)))
	  (line-break)
	  (string-write "] " (st unspec) ")"))
	(cond
	 ((equal? code 'set)
	  (string-write (car inputs)))

	 ((equal? code 'nor)
	  (write-construct (sa "(and" mode " ") ")"
	    (write-list line-break inputs
			(lambda (op)
			  (string-write "(not" mode " " op ")")))))

	 (else
	  (write-construct (sa "(" (st code) mode " ") ")"
	    (write-list line-break inputs string-write)))))))

;; Write a "(set ...)" pattern for the given output.  CONTEXT is RHS
;; for the first output and RHS-COPY for the rest.  UNSPEC is an unspec
;; number to use for this output.
(define (write-to-one-output context insn output unspec)
  (write-construct "(set " ")"
    (string-write (md-operand:to-string 'lhs output))
    (line-break)
    (let ((branch-labels (and (md-operand:pc? output)
			      (find md-operand:label?
				    (md-insn:inputs insn)))))
      (if (pair? branch-labels)
	  (write-construct "(if_then_else " ")"
	    (write-construct "(eq " ")"
	      (write-inputs context insn "" unspec)
	      (line-break)
	      (string-write "(const_int 0)"))
	    (line-break)
	    (string-write "(match_dup "
			  (st (md-operand:read-index (car branch-labels)))
			  ")")
	    (line-break)
	    (string-write "(pc)"))
	  (let ((mode (md-operand:mode output)))
	    (write-inputs context insn (sa ":" mode) unspec)))))
  ;; If this instruction is used for expanding intrinsics, and if the
  ;; output is a fixed register that is not mapped to an intrinsic
  ;; argument, treat the instruction as setting a global register.
  ;; This isn't necessary for volatile instructions since gcc will
  ;; not try to second-guess what they do.
  (if (and (not (intrinsic:unspec-version (md-insn:intrinsic insn)))
	   (not (md-insn:volatile? insn))
	   (not (md-operand:write-index output))
	   (md-operand:fixed-register output))
      (let ((reg (get-shadow (md-operand:fixed-register output))))
	(line-break)
	(write-construct "(set " ")"
	  (string-write "(reg:SI " (st reg) ")")
	  (line-break)
	  (write-inputs 'rhs-copy insn ":SI" (+ unspec 1))))))


;; Write a define_insn for INSN.
(define (write-insn insn)
  (string-write "\n\n(define_insn \"" (md-insn:md-name insn) "\"\n")
  (write-construct "  [" "]"
    (let ((outputs (md-insn:outputs insn))
	  (unspec (intrinsic:unspec (md-insn:intrinsic insn))))
      (if (null? outputs)
	  (write-inputs 'rhs insn "" unspec)
	  (begin
	    (write-to-one-output 'rhs insn (car outputs) unspec)
	    (number-list
	     (lambda (output index)
	       (line-break)
	       (write-to-one-output 'rhs-copy insn output
				    (+ unspec (* 2 index))))
	     (cdr outputs) 1)))))
  (line-break)

  ;; C predicate.
  (string-write "  \"CGEN_ENABLE_INSN_P (" (st (md-insn:index insn)) ")")
  (let ((hook (intrinsic:hook (md-insn:intrinsic insn))))
    (if (gcc-hook:condition hook)
	(string-write " && (" (gcc-hook:condition hook) ")")))
  (string-write "\"\n")

  ;; assembly syntax
  (string-write "  \"")
  (write-syntax insn)
  (string-write "\"\n")

  ;; attributes
  (write-construct "  [" "]"
    (write-list line-break (target:attributes insn)
		(lambda (attribute)
		  (string-write "(set_attr \"" (car attribute)
				"\" \"" (cdr attribute) "\")"))))
  (string-write ")\n"))
	
(define (insns.md) 
  (string-write 
   "\n\n"
   ";; DO NOT EDIT: This file is automatically generated by CGEN.\n"
   ";; Any changes you make will be discarded when it is next regenerated.\n"
   "\n\n")
  (analyze-intrinsics!)
  (message "Generating .md file...\n")

  (init-immediate-predicate!)
  (for-each-argument note-immediates)

  ;; Define the immediate predicates.
  (for-each
   (lambda (entry)
     (let* ((op (cdr entry))
	    (align-mask (- (md-operand:alignment op) 1)))
       (string-write
	"(define_predicate \""
	(car entry) "\"\n"
	"  (and (match_code \"const_int\")\n"
	"        (match_test \"(INTVAL (op) & " (st align-mask) ") == 0\n"
	"                   && INTVAL (op) >= " (st (md-operand:lower-bound op)) "\n"
	"                   && INTVAL (op) < " (st (md-operand:upper-bound op)) "\")))\n"
	"\n")))
   immediate-predicate-table)

  (for-each-md-insn write-insn)
  (string-write "\n")
  "")


;; GCC SOURCE CODE GENERATOR
;; -------------------------

;; Maps the names of immediate predicates to an example of an operand
;; which needs it.
(deftable immediate-predicate)

;; If OP is an immediate predicate, make sure that it has an entry
;; in IMMEDIATE-PREDICATES.
(define (note-immediates insn op)
  (if (and (md-operand:immediate? op)
	   (not (md-operand:label? op)))
      (let ((name (md-operand:immediate-predicate op)))
	(if (not (get-immediate-predicate name))
	    (set-immediate-predicate! name op)))))

(define (enum-type op cptype)
  (cond
   ((is-h-cr64? (md-operand:hw op))
    (case cptype
      ((V8QI) "cgen_regnum_operand_type_V8QI")
      ((V4HI) "cgen_regnum_operand_type_V4HI")
      ((V2SI) "cgen_regnum_operand_type_V2SI")
      ((V8UQI) "cgen_regnum_operand_type_V8UQI")
      ((V4UHI) "cgen_regnum_operand_type_V4UHI")
      ((V2USI) "cgen_regnum_operand_type_V2USI")
      ((VECT) "cgen_regnum_operand_type_VECTOR")
      ((CP_DATA_BUS_INT) "cgen_regnum_operand_type_CP_DATA_BUS_INT")
      (else "cgen_regnum_operand_type_DI")))
   ((is-h-cr?   (md-operand:hw op))
    "cgen_regnum_operand_type_SI")
   (else
    (case (md-operand:cdata op)
      ((POINTER)         "cgen_regnum_operand_type_POINTER") 
      ((LABEL) 	         "cgen_regnum_operand_type_LABEL") 
      ((LONG) 	         "cgen_regnum_operand_type_LONG") 
      ((ULONG) 	         "cgen_regnum_operand_type_ULONG") 
      ((SHORT) 	         "cgen_regnum_operand_type_SHORT") 
      ((USHORT)          "cgen_regnum_operand_type_USHORT") 
      ((CHAR) 	         "cgen_regnum_operand_type_CHAR") 
      ((UCHAR) 	         "cgen_regnum_operand_type_UCHAR") 
      (else              "cgen_regnum_operand_type_DEFAULT")))))

;; Write out the cgen_insn initialiser for INSN.
(define (write-cgen-insn insn)
  (write-construct "  { " " }"
    (string-write (st (intrinsic:index (md-insn:intrinsic insn))))

    (comma-line-break)
    (string-write (bitmask "ISA" (md-insn:isas insn)))

    (comma-line-break)
    (string-write (bitmask "GROUP" (md-insn:groups insn)))

    (comma-line-break)
    (string-write "CODE_FOR_" (md-insn:md-name insn))

    (comma-line-break)
    (string-write (st (length (md-insn:arguments insn))))

    (comma-line-break)
    (string-write (if (md-insn:cret? insn) "1" "0"))

    (comma-line-break)
    (write-construct "{ " " }"
      (write-nonempty-list
	comma-break
	(find md-operand:arg-index (md-insn:operands insn))
	(lambda (op) (string-write (st (md-operand:arg-index op))))
	"0"))

   (comma-line-break)
   (write-construct "{ " " }"
     (write-nonempty-list
        comma-break
	(md-insn:arguments insn)
	(lambda (op)
	  (if (md-operand:regnum? op)
	      (string-write
	       "{ " (st (md-operand:upper-bound op))
	       ", " (st (target:base-reg (md-operand:hw op))))
	      (string-write "{ 0, 0"))
	  (string-write ", " (enum-type op (md-insn:cptype insn))
			", " (if (and (not (equal? (md-operand:cdata op) 'REGNUM))
				      (md-operand:write-index op))
				 "1" "0")
			" }"))
	"{ 0, 0, cgen_regnum_operand_type_DEFAULT, 0}"))

    (target:initialize-fields insn)))

(define (intrinsics.h) ; i.e., mep-intrin.h
  (string-write 
   "\n\n"
   "/* DO NOT EDIT: This file is automatically generated by CGEN.\n"
   "   Any changes you make will be discarded when it is next regenerated. */\n"
   "\n")
  (analyze-intrinsics!)
  (message "Generating gcc include file...\n")
  (init-immediate-predicate!)
  (for-each-argument note-immediates)

  (string-write "#ifdef WANT_GCC_DECLARATIONS\n")

  ;; Declare the range of shadow registers
  (string-write "#define FIRST_SHADOW_REGISTER "
		(st target:first-unused-register) "\n")
  (string-write "#define LAST_SHADOW_REGISTER "
		(st (+ target:first-unused-register
		       (length shadow-registers)
		       -1)) "\n")
  (string-write "#define FIXED_SHADOW_REGISTERS \\\n  ")
  (write-list comma-break
	      shadow-registers
	      (lambda (entry) (string-write "1")))
  (string-write "\n")
  (string-write "#define CALL_USED_SHADOW_REGISTERS FIXED_SHADOW_REGISTERS\n")
  (string-write "#define SHADOW_REG_ALLOC_ORDER \\\n  ")
  (write-list comma-break
	      shadow-registers
	      (lambda (entry) (string-write (st (cdr entry)))))
  (string-write "\n")
  (string-write "#define SHADOW_REGISTER_NAMES \\\n  ")
  (write-list comma-break
	      shadow-registers
	      (lambda (entry)
		(string-write "\"$shadow" (st (car entry)) "\"")))
  (string-write "\n\n")

  ;; Declare the index values for well-known intrinsics.
  (string-write "\n\n#ifndef __MEP__\n")
  (string-write "enum {\n")
  (write-list comma-line-break
	      (find intrinsic:hook intrinsics)
	      (lambda (intrinsic)
		(string-write "  " (intrinsic:name intrinsic)
			      " = " (st (intrinsic:index intrinsic)))))
  (string-write "\n};\n")
  (string-write "#endif /* ! defined (__MEP__) */\n")

  ;; Define the structure used to describe intrinsic insns.
  (string-write
   "\n\n"
   "enum cgen_regnum_operand_type {\n"
   "  cgen_regnum_operand_type_POINTER,         /* long *          */\n"
   "  cgen_regnum_operand_type_LABEL,           /* void *          */\n"
   "  cgen_regnum_operand_type_LONG,            /* long            */\n"
   "  cgen_regnum_operand_type_ULONG,           /* unsigned long   */\n"
   "  cgen_regnum_operand_type_SHORT,           /* short           */\n"
   "  cgen_regnum_operand_type_USHORT,          /* unsigned short  */\n"
   "  cgen_regnum_operand_type_CHAR,            /* char            */\n"
   "  cgen_regnum_operand_type_UCHAR,           /* unsigned char   */\n"
   "  cgen_regnum_operand_type_SI,           /* __cop long      */\n"
   "  cgen_regnum_operand_type_DI,           /* __cop long long */\n"
   "  cgen_regnum_operand_type_CP_DATA_BUS_INT, /* cp_data_bus_int */\n"
   "  cgen_regnum_operand_type_VECTOR,		/* opaque vector type */\n"
   "  cgen_regnum_operand_type_V8QI,		/* V8QI vector type */\n"
   "  cgen_regnum_operand_type_V4HI,		/* V4HI vector type */\n"
   "  cgen_regnum_operand_type_V2SI,		/* V2SI vector type */\n"
   "  cgen_regnum_operand_type_V8UQI,		/* V8UQI vector type */\n"
   "  cgen_regnum_operand_type_V4UHI,		/* V4UHI vector type */\n"
   "  cgen_regnum_operand_type_V2USI,		/* V2USI vector type */\n"
   "  cgen_regnum_operand_type_DEFAULT = cgen_regnum_operand_type_LONG\n"
   "};\n"
   "\n"
   "struct cgen_regnum_operand {\n"
   "  /* The number of addressable registers, 0 for non-regnum operands.  */\n"
   "  unsigned char count;\n"
   "\n"
   "  /* The first register.  */\n"
   "  unsigned char base;\n"
   "\n"
   "  /* The type of the operand.  */\n"
   "  enum cgen_regnum_operand_type type;\n"
   "\n"
   "  /* Is it passed by reference?  */\n"
   "  int reference_p;\n"
   "};\n\n"
   "struct cgen_insn {\n"
   "  /* An index into cgen_intrinsics[].  */\n"
   "  unsigned int intrinsic;\n"
   "\n"
   "  /* A bitmask of the ISAs which include this instruction.  */\n"
   "  unsigned int isas;\n"
   "\n"
   "  /* A bitmask of the target-specific groups to which this instruction\n"
   "     belongs.  */\n"
   "  unsigned int groups;\n"
   "\n"
   "  /* The insn_code for this instruction.  */\n"
   "  int icode;\n"
   "\n"
   "  /* The number of arguments to the intrinsic function.  */\n"
   "  unsigned int num_args;\n"
   "\n"
   "  /* If true, the first argument is the return value.  */\n"
   "  unsigned int cret_p;\n"
   "\n"
   "  /* Maps operand numbers to argument numbers.  */\n"
   "  unsigned int op_mapping[10];\n"
   "\n"
   "  /* Array of regnum properties, indexed by argument number.  */\n"
   "  struct cgen_regnum_operand regnums[10];\n"
   (target:declare-fields)
   "};\n")

  ;; Declare the arrays that we define later.
  (string-write
   "\n"
   "extern const struct cgen_insn cgen_insns[];\n"
   "extern const char *const cgen_intrinsics[];\n")

  ;; Macro used by the .md file.
  (string-write
   "\n"
   "/* Is the instruction described by cgen_insns[INDEX] enabled?  */\n"
   "#define CGEN_ENABLE_INSN_P(INDEX) \\\n"
   "  ((CGEN_CURRENT_ISAS & cgen_insns[INDEX].isas) != 0 \\\n"
   "   && (CGEN_CURRENT_GROUP & cgen_insns[INDEX].groups) != 0)\n\n")

  (define-bitmasks "ISA"
    (remove-duplicates (sort (map convert-isa intrinsics-isas) string<?)))

  (define-bitmasks "GROUP" md-insn-groups)

  (string-write "#endif\n")

  (string-write "#ifdef WANT_GCC_DEFINITIONS\n")

  ;; Create an array describing the range and alignment of immediate
  ;; predicates.
  (string-write
   "struct cgen_immediate_predicate {\n"
   "  insn_operand_predicate_fn predicate;\n"
   "  int lower, upper, align;\n"
   "};\n\n"
   "const struct cgen_immediate_predicate cgen_immediate_predicates[] = {\n")

  (write-list comma-line-break immediate-predicate-table
	      (lambda (entry)
		(let ((op (cdr entry)))
		  (string-write
		   "  { " (car entry)
		   ", " (st (md-operand:lower-bound op))
		   ", " (st (md-operand:upper-bound op))
		   ", " (st (md-operand:alignment op)) " }"))))

  (string-write "\n};\n\n")

  ;; Create an array containing the names of all the available intrinsinics.
  (string-write "const char *const cgen_intrinsics[] = {\n")
  (write-list comma-line-break intrinsics
	      (lambda (intrinsic)
		(string-write "  \"" (intrinsic:name intrinsic) "\"")))
  (string-write "\n};\n\n")

  ;; Create an array describing each .md file instruction.
  (string-write "const struct cgen_insn cgen_insns[] = {\n")
  (write-list comma-line-break md-insns write-cgen-insn)
  (string-write "\n};\n")

  (string-write "#endif\n"))


;; PROTOTYPE GENERATOR
;; -------------------

(define (runtime-type op cptype retval)
  (sa (case (md-operand:cdata op)
	((POINTER) "long *")
	((LABEL) "void *")
	((LONG) "long")
	((ULONG) "unsigned long")
	((SHORT) "short")
	((USHORT) "unsigned short")
	((CHAR) "char")
	((UCHAR) "unsigned char")
	((CP_DATA_BUS_INT)
	 ;;(logit 0 "op " (md-operand:cdata op) " cptype " cptype "\n")
	 (case cptype
	   ((V2SI) "cp_v2si")
	   ((V4HI) "cp_v4hi")
	   ((V8QI) "cp_v8qi")
	   ((V2USI) "cp_v2usi")
	   ((V4UHI) "cp_v4uhi")
	   ((V8UQI) "cp_v8uqi")
	   ((VECT) "cp_vector")
	    (else "cp_data_bus_int")))
	(else "long"))
      (if (and (not (equal? (md-operand:cdata op) 'REGNUM))
	       (md-operand:write-index op)
	       (not retval))
	  "*" "")))

(define (intrinsic-protos.h) ; i.e., intrinsics.h
  (string-write 
   "\n\n"
   "/* DO NOT EDIT: This file is automatically generated by CGEN.\n"
   "   Any changes you make will be discarded when it is next regenerated.\n"
   "*/\n\n"
   "/* GCC defines these internally, as follows... \n";
   "#if __MEP_CONFIG_CP_DATA_BUS_WIDTH == 64\n"
   "  typedef long long cp_data_bus_int;\n"
   "#else\n"
   "  typedef long cp_data_bus_int;\n"
   "#endif\n"
   "typedef          char  cp_v8qi  __attribute__((vector_size(8)));\n"
   "typedef unsigned char  cp_v8uqi __attribute__((vector_size(8)));\n"
   "typedef          short cp_v4hi  __attribute__((vector_size(8)));\n"
   "typedef unsigned short cp_v4uhi __attribute__((vector_size(8)));\n"
   "typedef          int   cp_v2si  __attribute__((vector_size(8)));\n"
   "typedef unsigned int   cp_v2usi __attribute__((vector_size(8)));\n"
   "*/\n\n")
  (analyze-intrinsics!)
  (message "Generating prototype file...\n")
  (target:for-each-isa!
   (lambda (name isa)
     (string-write "\n// " name "\n")
     (for-each
      (lambda (intrinsic)
	(let ((entry (assoc isa (intrinsic:isas intrinsic))))
	  (if entry
	      (let* ((insn (cdr entry))
		     (arguments (md-insn:arguments insn))
		     (retval (if (md-insn:cret? insn)
				 (runtime-type (car arguments) (md-insn:cptype insn) #t)
				 "void"))
		     (proto (sa retval " " (intrinsic:name intrinsic)
				" (" (stringize (map (lambda (arg)
						       (runtime-type arg
								     (md-insn:cptype insn) #f))
						       (if (md-insn:cret? insn)
							   (cdr arguments)
							   arguments)
						       )
						", ")
				");"))
		     (proto-len (string-length proto))
		     (attrs '()))

		(if (md-insn:volatile? insn)
		    (set! attrs (cons "volatile" attrs)))

		(string-write proto)
		(if (pair? attrs)
		    (string-write (make-string (max 1 (- 40 proto-len))
					       #\space)
				  "// " (stringize attrs " ")))
		(string-write "\n")))))
      intrinsics)))
  "")


;; The rest of this file has not been converted to use the INTRINSICS
;; attribute.  The code isn't used at the moment anyway.

(define (intrinsic-testsuite.c)
  (map-intrinsics!)
  (for-each (maybe-do-all declare-intrinsic-test) intrinsic-insns)
  (string-write "\n")
  "")

(define (test-val is-retval? op vbase)
  (let ((mode (op:mode op))
	(cdata (obj-attr-value op 'CDATA)))
    (cond 
     ((equal? cdata 'REGNUM) "7")
     ((equal? cdata 'LABEL) "&&lab")
     ((treat-op-as-immediate? op)             
      (let* ((field (fetch-ifield-for-op-in-current-insn op))
	     (align-bits (case (obj:name field) 
			   ((f-8s8a2 f-12s4a2 f-17s16a2 f-24s5a2n f-24u5a2n f-7u9a2 f-8s24a2) 1)
			   ((f-7u9a4 f-8s24a4 f-24u8a4n) 2)
			   ((f-8s24a8) 3)
			   (else 0)))
	     (val (ash (send field 'max-value) align-bits)))
	(string-append "0x" (number->string val 16))))
     (else (let* ((expr-suffix (if is-retval? "" 
				   (if (get-gcc-write-index op) "" " + 1")))
		  (val
		   (case cdata
		     ((POINTER) "p")
		     ((LONG) "l")
		     ((ULONG) "ul")
		     ((SHORT) "s")
		     ((USHORT) "us")
		     ((CHAR) "c")
		     ((UCHAR) "uc")
		     ((CP_DATA_BUS_INT) "cpdbi")
		     (else "l"))))
	     (sa vbase val expr-suffix))))))
  
(define (declare-intrinsic-test name insn others)
  (set! curr-insn insn)
  (scan-syntax insn)
  (scan-read-write insn)

  (let* ((mnem (insn-mnemonic insn))
	 (syntax (insn-syntax insn))
	 (first #t)
	 (comma-not-first (lambda () (if first (begin (set! first #f) "") ", ")))
	 (vars '("x" "y" "z" "t" "w"))
	 (operands syntactic-operands))
    
    (cond ((equal? mnem "--unused--") '())
	  ((equal? mnem "--reserved--") '())
	  (else
	   (begin	  
	     (string-write (target:builtin-name (intrinsic-name insn)) " (")
	     (for-each (lambda (operand) 
			 (string-write (sa (comma-not-first) 
					   (test-val #f operand (car vars))
					   ))
			 (set! vars (cdr vars))) operands)
	     (string-write ");\n")))
	  )))
