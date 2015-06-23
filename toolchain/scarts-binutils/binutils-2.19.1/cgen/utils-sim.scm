; Generic simulator application utilities.
; Copyright (C) 2000, 2005, 2006, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; The cache-addr? method.
; Return #t if the hardware element's address is stored in the scache buffer.
; This saves doing the index calculation during semantic processing.

(method-make!
 <hardware-base> 'cache-addr?
 (lambda (self)
   (and (with-scache?)
	(has-attr? self 'CACHE-ADDR)))
)

(define (hw-cache-addr? hw) (send hw 'cache-addr?))

; The needed-iflds method.
; Return list of ifields needed during semantic execution by hardware element
; SELF referenced by <operand> OP in <sformat> SFMT.

(method-make!
 <hardware-base> 'needed-iflds
 (lambda (self op sfmt)
   (list (op-ifield op)))
)

(method-make!
 <hw-register> 'needed-iflds
 (lambda (self op sfmt)
   (list (op-ifield op)))
; Instead of the following, we now arrange to store the ifield in the
; argbuf, even for CACHE-ADDR operands.  This way, the ifield values 
; (register numbers, etc.) remain available during semantics tracing.
;   (if (hw-cache-addr? self)
;       nil
;       (list (op-ifield op))))
)

; For addresses this is none because we make our own copy of the ifield
; [because we want to use a special type].

(method-make!
 <hw-address> 'needed-iflds
 (lambda (self op sfmt)
   nil)
)

(define (hw-needed-iflds hw op sfmt) (send hw 'needed-iflds op sfmt))

; Return a list of ifields of <operand> OP that must be recorded in ARGBUF
; for <sformat> SFMT.
; ??? At the moment there can only be at most one, but callers must not
; assume this.

(define (op-needed-iflds op sfmt)
  (let ((indx (op:index op)))
    (logit 4 "op-needed-iflds op=" (obj:name op) " indx=" (obj:name indx)
	   " indx-type=" (hw-index:type indx) " sfmt=" (obj:name sfmt) "\n")
    (cond
     ((and 
       (eq? (hw-index:type indx) 'ifield)
       (not (= (ifld-length (hw-index:value indx)) 0)))
      (hw-needed-iflds (op:type op) op sfmt))
     ((eq? (hw-index:type indx) 'derived-ifield)
      (ifld-needed-iflds indx))
     (else nil)))
  )

; Operand extraction (ARGBUF) support code.
;
; Any operand that uses a non-empty ifield needs extraction support.
; Normally we just record the ifield's value.  However, in cases where
; hardware elements have CACHE-ADDR specified or where the mode of the
; hardware index isn't compatible with the mode of the decoded ifield
; (this can happen for pc-relative instruction address), we need to record
; something else.

; Return a boolean indicating if <operand> OP needs any extraction processing.

(define (op-extract? op)
  (let* ((indx (op:index op))
	 (extract?
	  (if (derived-operand? op)
	      (any-true? (map op-extract? (derived-args op)))
	      (and (eq? (hw-index:type indx) 'ifield)
		   (not (= (ifld-length (hw-index:value indx)) 0))))))
    (logit 4 "op-extract? op=" (obj:name op) " =>" extract? "\n")
    extract?)
)

; Return a list of operands that need special extraction processing.
; SFMT is an <sformat> object.

(define (sfmt-extracted-operands sfmt)
  (let ((in-ops (sfmt-in-ops sfmt))
	(out-ops (sfmt-out-ops sfmt)))
    (let ((ops (append (find op-extract? in-ops)
		       (find op-extract? out-ops))))
      (nub ops obj:name)))
)

; Return a list of ifields that are needed by the semantic code.
; SFMT is an <sformat> object.
; ??? This redoes a lot of the calculation that sfmt-extracted-operands does.

(define (sfmt-needed-iflds sfmt)
  (let ((in-ops (sfmt-in-ops sfmt))
	(out-ops (sfmt-out-ops sfmt)))
    (let ((ops (append (find op-extract? in-ops)
		       (find op-extract? out-ops))))
      (nub (apply append (map (lambda (op)
				(op-needed-iflds op sfmt))
			      ops))
	   obj:name)))
)

; Sformat argument buffer.
;
; This contains the details needed to create an argument buffer `fields' union
; entry for the containing sformats.

(define <sformat-argbuf>
  (class-make '<sformat-argbuf>
	      '(<ident>)
	      ; From <ident>:
	      ; - NAME is derived from one of the containing sformats.
	      '(
		; List of structure elements.
		; Each element is ("var name" "C type" bitsize).
		; The list is sorted by decreasing size, then C type,
		; then var name.
		elms
		)
	      nil)
)

(define-getters <sformat-argbuf> sbuf (sfmts elms))

; Subroutine of -sfmt-contents to return an ifield element.
; The result is ("var-name" "C-type" bitsize).

(define (-sfmt-ifld-elm f sfmt)
  (let ((real-mode (mode-real-mode (ifld-decode-mode f))))
    (list (gen-sym f)
	  (mode:c-type real-mode)
	  (mode:bits real-mode)))
)

; sbuf-elm method.
; The result is ("var-name" "C-type" approx-bitsize) or #f if unneeded.
; For the default case we use the ifield as is, which is computed elsewhere.

(method-make!
 <hardware-base> 'sbuf-elm
 (lambda (self op ifmt)
   #f)
)

(method-make!
 <hw-register> 'sbuf-elm
 (lambda (self op ifmt)
   (if (hw-cache-addr? self)
       (list (gen-sym (op:index op))
	     (string-append (gen-type self) "*")
	     ; Use 64 bits for size.  Doesn't really matter, just put them
	     ; near the front.
	     64)
       #f))
)

; We want to use ADDR/IADDR in ARGBUF for addresses

(method-make!
 <hw-address> 'sbuf-elm
 (lambda (self op ifmt)
   (list (gen-sym (op:index op))
	 "ADDR"
	 ; Use 64 bits for size.  Doesn't really matter, just put them
	 ; near the front.
	 64))
)

(method-make!
 <hw-iaddress> 'sbuf-elm
 (lambda (self op ifmt)
   (list (gen-sym (op:index op))
	 "IADDR"
	 ; Use 64 bits for size.  Doesn't really matter, just put them
	 ; near the front.
	 64))
)

; Subroutine of -sfmt-contents to return an operand element.
; These are in addition (or instead of) the actual ifields.
; This is also used to compute definitions of local vars needed in the
; !with-scache case.
; The result is ("var-name" "C-type" approx-bitsize) or #f if unneeded.

(define (sfmt-op-sbuf-elm op sfmt)
  (send (op:type op) 'sbuf-elm op sfmt)
)

; Subroutine of compute-sformat-bufs! to compute list of structure elements
; needed by <sformat> SFMT.
; The result is
; (SFMT ("var-name1" "C-type1" size1) ("var-name2" "C-type2" size2) ...)
; and is sorted by decreasing size, then C type, then variable name
; (as <sformat-argbuf> wants it).

(define (-sfmt-contents sfmt)
  (let ((needed-iflds (sfmt-needed-iflds sfmt))
	(extracted-ops (sfmt-extracted-operands sfmt))
	(in-ops (sfmt-in-ops sfmt))
	(out-ops (sfmt-out-ops sfmt))
	(sort-elms (lambda (a b)
		     ; Sort by descending size, then ascending C type name,
		     ; then ascending name.
		     (cond ((> (caddr a) (caddr b))
			    #t)
			   ((= (caddr a) (caddr b))
			    (cond ((string<? (cadr a) (cadr b))
				   #t)
				  ((string=? (cadr a) (cadr b))
				   (string<? (car a) (car b)))
				  (else
				   #f)))
			   (else
			    #f))))
	)
    (logit 4 
	   "-sfmt-contents sfmt=" (obj:name sfmt) 
	   " needed-iflds=" (string-map obj:str-name needed-iflds)
	   " extracted-ops=" (string-map obj:str-name extracted-ops)
	   " in-ops=" (string-map obj:str-name in-ops)
	   " out-ops=" (string-map obj:str-name out-ops)
	   "\n")
    (cons sfmt
	  (sort
	   ; Compute list of all things we need to record at extraction time.
	   (find (lambda (x)
		   ; Discard #f entries, they indicate "unneeded".
		   x)
		 (append
		  (map (lambda (f)
			 (-sfmt-ifld-elm f sfmt))
		       needed-iflds)
		  (map (lambda (op)
			 (sfmt-op-sbuf-elm op sfmt))
		       extracted-ops)
		  (cond ((with-any-profile?)
			 (append
			  ; Profiling support.  ??? This stuff is in flux.
			  (map (lambda (op)
				 (sfmt-op-profile-elm op sfmt #f))
			       (find op-profilable? in-ops))
			  (map (lambda (op)
				 (sfmt-op-profile-elm op sfmt #t))
			       (find op-profilable? out-ops))))
			(else 
			 (append)))))
	   sort-elms)))
)

; Return #t if ELM-LIST is a subset of SBUF.
; SBUF is an <sformat-argbuf> object.

(define (-sbuf-subset? elm-list sbuf)
  ; We take advantage of the fact that elements in each are already sorted.
  ; FIXME: Can speed up.
  (let loop ((elm-list elm-list) (sbuf-elm-list (sbuf-elms sbuf)))
    (cond ((null? elm-list)
	   #t)
	  ((null? sbuf-elm-list)
	   #f)
	  ((equal? (car elm-list) (car sbuf-elm-list))
	   (loop (cdr elm-list) (cdr sbuf-elm-list)))
	  (else
	   (loop elm-list (cdr sbuf-elm-list)))))
)

; Subroutine of compute-sformat-bufs!.
; Lookup ELM-LIST in SBUF-LIST.  A match is found if ELM-LIST
; is a subset of one in SBUF-LIST.
; Return the containing <sformat-argbuf> object if found, otherwise return #f.
; SBUF-LIST is a list of <sformat-argbuf> objects.
; ELM-LIST is (elm1 elm2 ...).

(define (-sbuf-lookup elm-list sbuf-list)
  (let loop ((sbuf-list sbuf-list))
    (cond ((null? sbuf-list)
	   #f)
	  ((-sbuf-subset? elm-list (car sbuf-list))
	   (car sbuf-list))
	  (else
	   (loop (cdr sbuf-list)))))
)

; Compute and record the set of <sformat-argbuf> objects needed for SFMT-LIST,
; a list of all sformats.
; The result is the computed list of <sformat-argbuf> objects.
;
; This is used to further reduce the number of entries in the argument buffer's
; `fields' union.  Some sformats have structs with the same contents or one is
; a subset of another's, thus there is no need to distinguish them as far as
; the struct is concerned (there may be other reasons to distinguish them of
; course).
; The consequence of this is fewer semantic fragments created in with-sem-frags
; pbb engines.

(define (compute-sformat-argbufs! sfmt-list)
  (logit 1 "Computing sformat argument buffers ...\n")

  (let ((sfmt-contents
	 ; Sort by descending length.  This helps building the result: while
	 ; iterating over each element, its sbuf is either a subset of a
	 ; previous entry or requires a new entry.
	 (sort (map -sfmt-contents sfmt-list)
	       (lambda (a b)
		 (> (length a) (length b)))))
	; Build an <sformat-argbuf> object.
	(build-sbuf (lambda (sfmt-data)
		      (make <sformat-argbuf>
			(obj:name (car sfmt-data))
			""
			atlist-empty
			(cdr sfmt-data))))
	)
    ; Start off with the first sfmt.
    ; Also build an empty sbuf.  Which sbuf to use for an empty argument list
    ; is rather arbitrary.  Rather than pick one, keep the empty sbuf unto
    ; itself.
    (let ((nub-sbufs (list (build-sbuf (car sfmt-contents))))
	  (empty-sbuf (make <sformat-argbuf>
			'fmt-empty "no operands" atlist-empty
			nil))
	  )
      (sfmt-set-sbuf! (caar sfmt-contents) (car nub-sbufs))

      ; Now loop over the remaining sfmts.
      (let loop ((sfmt-contents (cdr sfmt-contents)))
	(if (not (null? sfmt-contents))
	    (let ((sfmt-data (car sfmt-contents)))
	      (if (null? (cdr sfmt-data))
		  (sfmt-set-sbuf! (car sfmt-data) empty-sbuf)
		  (let ((sbuf (-sbuf-lookup (cdr sfmt-data) nub-sbufs)))
		    (if (not sbuf)
			(begin
			  (set! sbuf (build-sbuf sfmt-data))
			  (set! nub-sbufs (cons sbuf nub-sbufs))))
		    (sfmt-set-sbuf! (car sfmt-data) sbuf)))
	      (loop (cdr sfmt-contents)))))

      ; Done.
      ; Note that the result will be sorted by ascending number of elements
      ; (because the search list was sorted by descending length and the result
      ; is built up in reverse order of that).
      ; Not that it matters, but that's kinda nice.
      (cons empty-sbuf nub-sbufs)))
)

; Profiling support.

; By default hardware elements are not profilable.

(method-make! <hardware-base> 'profilable? (lambda (self) #f))

(method-make!
 <hw-register> 'profilable?
 (lambda (self) (has-attr? self 'PROFILE))
)

; Return boolean indicating if HW is profilable.

(define (hw-profilable? hw) (send hw 'profilable?))

; Return a boolean indicating if OP is profilable.

(define (op-profilable? op)
  (hw-profilable? (op:type op))
)

; sbuf-profile-data method.
; Return a list of C type and size to use in an sformat's argument buffer.

(method-make!
 <hardware-base> 'sbuf-profile-data
 (lambda (self)
   (error "sbuf-profile-elm not supported for this hw type"))
)

(method-make!
 <hw-register> 'sbuf-profile-data
 (lambda (self)
   ; Don't unnecessarily bloat size of argument buffer.
   (if (<= (hw-num-elms self) 255)
       (list "unsigned char" 8)
       (list "unsigned short" 16)))
)

; Utility to return name of variable/structure-member to use to record
; profiling data for SYM.

(define (gen-profile-sym sym out?)
  (string-append (if out? "out_" "in_")
		 (if (symbol? sym) (symbol->string sym) sym))
)

; Return name of variable/structure-member to use to record data needed for
; profiling operand SELF.

(method-make!
 <operand> 'sbuf-profile-sym
 (lambda (self out?)
   (gen-profile-sym (gen-sym self) out?))
)

; sbuf-profile-elm method.
; Return the ARGBUF member needed for profiling SELF in <sformat> SFMT.
; The result is (var-name "C-type" approx-bitsize) or #f if unneeded.

(method-make!
 <operand> 'sbuf-profile-elm
 (lambda (self sfmt out?)
   (if (hw-scalar? (op:type self))
       #f
       (cons (send self 'sbuf-profile-sym out?)
	     (send (op:type self) 'sbuf-profile-data))))
)

; Subroutine of -sfmt-contents to return an operand's profile element.
; The result is (var-name "C-type" approx-bitsize) or #f if unneeded.

(define (sfmt-op-profile-elm op sfmt out?)
  (send op 'sbuf-profile-elm sfmt out?)
)

; ARGBUF accessor support.

; Define and undefine C macros to tuck away details of instruction format used
; in the extraction and semantic code.  Instruction format names can
; change frequently and this can result in unnecessarily large diffs from one
; generated version of the file to the next.  Secondly, tucking away details of
; the extracted argument structure from the extraction code is a good thing.

; Name of macro to access fields in ARGBUF.
(define c-argbuf-macro "FLD")

; NB: If sfmt is #f, then define the macro to pass through the argument
; symbol.  This is appropriate for "simple" (non-scache) simulators
; that have no abuf/scache in the sem.c routines, but rather plain
; local variables.
(define (gen-define-argbuf-macro sfmt)
  (string-append "#define " c-argbuf-macro "(f) "
		 (if sfmt
		     (string-append
		      "abuf->fields."
		      (gen-sym (sfmt-sbuf sfmt))
		      ".f\n")
		     "f\n"))
)

(define (gen-undef-argbuf-macro sfmt)
  (string-append "#undef " c-argbuf-macro "\n")
)

; For old code.  Delete in time.
(define gen-define-field-macro gen-define-argbuf-macro)
(define gen-undef-field-macro gen-undef-argbuf-macro)

; Return a C reference to an ARGBUF field value.

(define (gen-argbuf-ref name)
  (string-append c-argbuf-macro " (" name ")")
)

; Return name of ARGBUF member for extracted <field> F.

(define (gen-ifld-argbuf-name f)
  (gen-sym f)
)

; Return the C reference to a cached ifield.

(define (gen-ifld-argbuf-ref f)
  (gen-argbuf-ref (gen-ifld-argbuf-name f))
)

; Return name of ARGBUF member holding processed from of extracted
; ifield value for <hw-index> index.

(define (gen-hw-index-argbuf-name index)
  (gen-sym index)
)

; Return C reference to a processed <hw-index> in ARGBUF.

(define (gen-hw-index-argbuf-ref index)
  (gen-argbuf-ref (gen-hw-index-argbuf-name index))
)

; Decode support.

; Main procedure call tree:
; cgen-decode.{c,cxx}
;     -gen-decode-fn
;         gen-decoder [our entry point]
;             decode-build-table
;             -gen-decoder-switch
;                 -gen-decoder-switch
;
; decode-build-table is called to construct a tree of "table-guts" elements
; (??? Need better name obviously),
; and then gen-decoder is recursively called on each of these elements.

; Return C/C++ code that fetches the desired decode bits from C value VAL.
; SIZE is the size in bits of val (the MSB is 1 << (size - 1)) which we
; treat as bitnum 0.
; BITNUMS must be monotonically increasing.
; LSB0? is non-#f if bit number 0 is the least significant bit.
; FIXME: START may not be handled right in words beyond first.
;
; ENTIRE-VAL is passed as a hack for cgen 1.1 which would previously generate
; negative shifts.  FIXME: Revisit for 1.2.
;
; e.g. (-gen-decode-bits '(0 1 2 3 8 9 10 11) 0 16 "insn" #f)
; --> "(((insn >> 8) & 0xf0) | ((insn >> 4) & 0xf))"
; FIXME: The generated code has some inefficiencies in edge cases.  Later.

(define (-gen-decode-bits bitnums start size val entire-val lsb0?)

  ; Compute a list of lists of three numbers:
  ; (first bitnum in group, position in result (0=LSB), bits in result)

  (let ((groups
	 ; POS = starting bit position of current group.
	 ; COUNT = number of bits in group.
	 ; Work from least to most significant bit so reverse bitnums.
	 (let loop ((result nil) (pos 0) (count 0) (bitnums (reverse bitnums)))
	   ;(display (list result pos count bitnums)) (newline)
	   (if (null? bitnums)
	       result
	       (if (or (= (length bitnums) 1)
		       ; Are numbers not next to each other?
		       (not (= (- (car bitnums) (if lsb0? -1 1))
			       (cadr bitnums))))
		   (loop (cons (list (car bitnums) pos (+ 1 count))
			       result)
			 (+ pos count 1) 0
			 (cdr bitnums))
		   (loop result
			 pos (+ 1 count)
			 (cdr bitnums)))))))
    (string-append
     ; While we could just always emit "(0" to handle the case of an empty set,
     ; keeping the code more readable for the normal case is important.
     (if (< (length groups) 1)
	 "(0"
	 "(")
     (string-drop 3
		  (string-map
		   (lambda (group)
		     (let* ((first (car group))
			    (pos (cadr group))
			    (bits (caddr group))
			    ; Difference between where value is and where
			    ; it needs to be.
			    (shift (- (if lsb0?
					  (- first bits -1)
					  (- (+ start size) (+ first bits)))
				      pos)))
		       ; FIXME: There should never be a -ve shift here,
		       ; but it can occur on the m32r.  Compensate here
		       ; with hack and fix in 1.2.
		       (if (< shift 0)
			   (begin
			     (set! val entire-val)
			     (set! shift (+ shift size))))
		       ; END-FIXME
		       (string-append
			" | ((" val " >> " (number->string shift)
			") & ("
			(number->string (- (integer-expt 2 bits) 1))
			" << " (number->string pos) "))")))
		   groups))
     ")"))
)

; Convert decoder table into C code.

; Return code for the default entry of each switch table
;
(define (-gen-decode-default-entry indent invalid-insn fn?)
  (string-append
   "itype = "
   (gen-cpu-insn-enum (current-cpu) invalid-insn)
   ";"
   (if (with-scache?)
       (if fn?
	   " @prefix@_extract_sfmt_empty (this, current_cpu, pc, base_insn, entire_insn); goto done;\n"
	   " goto extract_sfmt_empty;\n")
       " goto done;\n")
  )
)

; Return code for one insn entry.
; REST is the remaining entries.

(define (-gen-decode-insn-entry entry rest indent invalid-insn fn?)
  (assert (eq? 'insn (dtable-entry-type entry)))
  (logit 3 "Generating decode insn entry for " (obj:name (dtable-entry-value entry)) " ...\n")

  (let* ((insn (dtable-entry-value entry))
	 (fmt-name (gen-sym (insn-sfmt insn))))

    (cond

     ; Leave invalids to the default case.
     ((eq? (obj:name insn) 'x-invalid)
      "")

     ; If same contents as next case, fall through.
     ; FIXME: Can reduce more by sorting cases.  Much later.
     ((and (not (null? rest))
	   ; Ensure both insns.
	   (eq? 'insn (dtable-entry-type (car rest)))
	   ; Ensure same insn.
	   (eq? (obj:name insn)
		(obj:name (dtable-entry-value (car rest)))))
      (string-append indent "  case "
		     (number->string (dtable-entry-index entry))
		     " : /* fall through */\n"))

     (else
      (string-append indent "  case "
		     (number->string (dtable-entry-index entry)) " :\n"
		     ; Compensate for base-insn-size > current-insn-size by adjusting entire_insn.
		     ; Activate this logic only for sid simulators; they are consistent in
		     ; interpreting base-insn-bitsize this way.
		     (if (and (equal? APPLICATION 'SID-SIMULATOR)
			      (> (state-base-insn-bitsize) (insn-length insn)))
			 (string-append
			  indent "    entire_insn = entire_insn >> "
			  (number->string (- (state-base-insn-bitsize) (insn-length insn)))
			  ";\n")
			 "")
		     ; Generate code to check that all of the opcode bits for this insn match
		     indent "    if (("
		     (if (adata-integral-insn? CURRENT-ARCH) "entire_insn" "base_insn")
		     " & 0x" (number->hex (insn-base-mask insn)) ") == 0x" (number->hex (insn-value insn)) ")\n" 
		     indent "      { itype = " (gen-cpu-insn-enum (current-cpu) insn) ";"
		     (if (with-scache?)
			 (if fn?
			     (string-append " @prefix@_extract_" fmt-name " (this, current_cpu, pc, base_insn, entire_insn); goto done;")
			     (string-append " goto extract_" fmt-name ";"))
			 " goto done;")
		     " }\n"
		     indent "    " (-gen-decode-default-entry indent invalid-insn fn?)))))
)

; Subroutine of -decode-expr-ifield-tracking.
; Return a list of all possible values for ifield IFLD-NAME.
; FIXME: Quick-n-dirty implementation.  Should use bit arrays.

(define (-decode-expr-ifield-values ifld-name)
  (let* ((ifld (current-ifld-lookup ifld-name))
	 (bits (ifld-length ifld)))
    (if (mode-unsigned? (ifld-mode ifld))
	(iota (logsll 1 bits))
	(iota (logsll 1 bits) (- (logsll 1 (- bits 1))))))
)

; Subroutine of -decode-expr-ifield-tracking,-decode-expr-ifield-mark-used.
; Create the search key for tracking table lookup.

(define (-decode-expr-ifield-tracking-key insn ifld-name)
  (symbol-append (obj:name (insn-ifmt insn)) '-x- ifld-name)
)

; Subroutine of -gen-decode-expr-entry.
; Return a table to track used ifield values.
; The table is an associative list of (key . value-list).
; KEY is "iformat-name-x-ifield-name".
; VALUE-LIST is a list of the unused values.

(define (-decode-expr-ifield-tracking expr-list)
  (let ((table1
	 (apply append
		(map (lambda (entry)
		       (map (lambda (ifld-name)
			      (cons (exprtable-entry-insn entry)
				    (cons ifld-name
					  (-decode-expr-ifield-values ifld-name))))
			    (exprtable-entry-iflds entry)))
		     expr-list))))
    ; TABLE1 is a list of (insn ifld-name value1 value2 ...).
    (nub (map (lambda (elm)
		(cons
		 (-decode-expr-ifield-tracking-key (car elm) (cadr elm))
		 (cddr elm)))
	      table1)
	 car))
)

; Subroutine of -decode-expr-ifield-mark-used!.
; Return list of values completely used for ifield IFLD-NAME in EXPR.
; "completely used" here means the value won't appear elsewhere.
; e.g. in (andif (eq f-rd 15) (eq f-rx 14)) we don't know what happens
; for the (ne f-rx 14) case.

(define (-decode-expr-ifield-values-used ifld-name expr)
  (case (rtx-name expr)
    ((eq)
     (if (and (rtx-kind? 'ifield (rtx-cmp-op-arg expr 0))
	      (rtx-constant? (rtx-cmp-op-arg expr 1)))
	 (list (rtx-constant-value (rtx-cmp-op-arg expr 1)))
	 nil))
    ((member)
     (if (rtx-kind? 'ifield (rtx-member-value expr))
	 (rtx-member-set expr)
	 nil))
    ; FIXME: more needed
    (else nil))
)

; Subroutine of -gen-decode-expr-entry.
; Mark ifield values used by EXPR-ENTRY in TRACKING-TABLE.

(define (-decode-expr-ifield-mark-used! tracking-table expr-entry)
  (let ((insn (exprtable-entry-insn expr-entry))
	(expr (exprtable-entry-expr expr-entry))
	(ifld-names (exprtable-entry-iflds expr-entry)))
    (for-each (lambda (ifld-name)
		(let ((table-entry
		       (assq (-decode-expr-ifield-tracking-key insn ifld-name)
			     tracking-table))
		      (used (-decode-expr-ifield-values-used ifld-name expr)))
		  (for-each (lambda (value)
			      (delq! value table-entry))
			    used)
		  ))
	      ifld-names))
  *UNSPECIFIED*
)

; Subroutine of -gen-decode-expr-entry.
; Return code to set `itype' and branch to the extraction phase.

(define (-gen-decode-expr-set-itype indent insn-enum fmt-name fn?)
  (string-append
   indent
   "{ itype = "
   insn-enum
   "; "
   (if (with-scache?)
       (if fn?
	   (string-append "@prefix@_extract_" fmt-name " (this, current_cpu, pc, base_insn, entire_insn);  goto done;")
	   (string-append "goto extract_" fmt-name ";"))
       "goto done;")
   " }\n"
   )
)

; Generate code to decode the expression table in ENTRY.
; INVALID-INSN is the <insn> object of the pseudo insn to handle invalid ones.

(define (-gen-decode-expr-entry entry indent invalid-insn fn?)
  (assert (eq? 'expr (dtable-entry-type entry)))
  (logit 3 "Generating decode expr entry for " (exprtable-name (dtable-entry-value entry)) " ...\n")

  (let ((expr-list (exprtable-insns (dtable-entry-value entry))))
    (string-list
     indent "  case "
     (number->string (dtable-entry-index entry))
     " :\n"

     (let ((iflds-tracking (-decode-expr-ifield-tracking expr-list))
	   (indent (string-append indent "    ")))

       (let loop ((expr-list expr-list) (code nil))

	 (if (null? expr-list)

	     ; All done.  If we used up all field values we don't need to
	     ; "fall through" and select the invalid insn marker.

	     (if (all-true? (map null? (map cdr iflds-tracking)))
		 code
		 (append! code
			  (list
			   (-gen-decode-expr-set-itype
			    indent
			    (gen-cpu-insn-enum (current-cpu) invalid-insn)
			    "sfmt_empty"
			    fn?))))

	     ; Not all done, process next expr.

	     (let ((insn (exprtable-entry-insn (car expr-list)))
		   (expr (exprtable-entry-expr (car expr-list)))
		   (ifld-names (exprtable-entry-iflds (car expr-list))))

	       ; Mark of those ifield values we use first.
	       ; If there are none left afterwards, we can unconditionally
	       ; choose this insn.
	       (-decode-expr-ifield-mark-used! iflds-tracking (car expr-list))

	       (let ((next-code
		      ; If this is the last expression, and it uses up all
		      ; remaining ifield values, there's no need to perform any
		      ; test.
		      (if (and (null? (cdr expr-list))
			       (all-true? (map null? (map cdr iflds-tracking))))

			  ; Need this in a list for a later append!.
			  (string-list
			   (-gen-decode-expr-set-itype
			    indent
			    (gen-cpu-insn-enum (current-cpu) insn)
			    (gen-sym (insn-sfmt insn))
			    fn?))

			  ; We don't use up all ifield values, so emit a test.
			   (let ((iflds (map current-ifld-lookup ifld-names)))
			     (string-list
			      indent "{\n"
			      (gen-define-ifields iflds
						  (insn-length insn)
						  (string-append indent "  ")
						  #f)
			      (gen-extract-ifields iflds
						   (insn-length insn)
						   (string-append indent "  ")
						   #f)
			      indent "  if ("
			      (rtl-c 'BI expr nil #:ifield-var? #t)
			      ")\n"
			      (-gen-decode-expr-set-itype
			       (string-append indent "    ")
			       (gen-cpu-insn-enum (current-cpu) insn)
			       (gen-sym (insn-sfmt insn))
			       fn?)
			      indent "}\n")))))

		 (loop (cdr expr-list)
		       (append! code next-code)))))))
     ))
)

; Generate code to decode TABLE.
; REST is the remaining entries.
; SWITCH-NUM, STARTBIT, DECODE-BITSIZE, INDENT, LSB0?, INVALID-INSN are same
; as for -gen-decoder-switch.

(define (-gen-decode-table-entry table rest switch-num startbit decode-bitsize indent lsb0? invalid-insn fn?)
  (assert (eq? 'table (dtable-entry-type table)))
  (logit 3 "Generating decode table entry for case " (dtable-entry-index table) " ...\n")

  (string-list
   indent "  case "
   (number->string (dtable-entry-index table))
   " :"
   ; If table is same as next, just emit a "fall through" to cut down on
   ; generated code.
   (if (and (not (null? rest))
	    ; Ensure both tables.
	    (eq? 'table (dtable-entry-type (car rest)))
	    ; Ensure same table.
	    (eqv? (subdtable-key (dtable-entry-value table))
		  (subdtable-key (dtable-entry-value (car rest)))))
       " /* fall through */\n"
       (string-list
	"\n"
	(-gen-decoder-switch switch-num
			     startbit
			     decode-bitsize
			     (subdtable-table (dtable-entry-value table))
			     (string-append indent "    ")
			     lsb0?
			     invalid-insn
			     fn?))))
)

; Subroutine of -decode-sort-entries.
; Return a boolean indicating if A,B are equivalent entries.

(define (-decode-equiv-entries? a b)
  (let ((a-type (dtable-entry-type a))
	(b-type (dtable-entry-type b)))
    (if (eq? a-type b-type)
	(case a-type
	  ((insn)
	   (let ((a-name (obj:name (dtable-entry-value a)))
		 (b-name (obj:name (dtable-entry-value b))))
	    (eq? a-name b-name)))
	  ((expr)
	   ; Ignore expr entries for now.
	   #f)
	  ((table)
	   (let ((a-name (subdtable-key (dtable-entry-value a)))
		 (b-name (subdtable-key (dtable-entry-value b))))
	     (eq? a-name b-name))))
	; A and B are not the same type.
	#f))
)

; Subroutine of -gen-decoder-switch, sort ENTRIES according to desired
; print order (maximizes amount of fall-throughs, but maintains numerical
; order as much as possible).
; ??? This is an O(n^2) algorithm.  An O(n Log(n)) algorithm can be done
; but it seemed more complicated than necessary for now.

(define (-decode-sort-entries entries)
  (let ((find-equiv!
	 ; Return list of entries in non-empty list L that have the same decode
	 ; entry as the first entry.  Entries found are marked with #f so
	 ; they're not processed again.
	 (lambda (l)
	   ; Start off the result with the first entry, then see if the
	   ; remaining ones match it.
	   (let ((first (car l)))
	     (let loop ((l (cdr l)) (result (cons first nil)))
	       (if (null? l)
		   (reverse! result)
		   (if (and (car l) (-decode-equiv-entries? first (car l)))
		       (let ((lval (car l)))
			 (set-car! l #f)
			 (loop (cdr l) (cons lval result)))
		       (loop (cdr l) result)))))))
	)
    (let loop ((entries (list-copy entries)) (result nil))
      (if (null? entries)
	  (apply append (reverse! result))
	  (if (car entries)
	      (loop (cdr entries)
		    (cons (find-equiv! entries)
			  result))
	      (loop (cdr entries) result)))))
)

; Generate switch statement to decode TABLE-GUTS.
; SWITCH-NUM is for compatibility with the computed goto decoder and
; isn't used.
; STARTBIT is the bit offset of the instruction value that C variable `insn'
; holds (note that this is independent of LSB0?).
; DECODE-BITSIZE is the number of bits of the insn that `insn' holds.
; LSB0? is non-#f if bit number 0 is the least significant bit.
; INVALID-INSN is the <insn> object of the pseudo insn to handle invalid ones.

; FIXME: for the few-alternative case (say, 2), generating
; if (0) {}
; else if (val == 0) { ... }
; else if (val == 1) { ... }
; else {}
; may well be less stressful on the compiler to optimize than small switch() stmts.

(define (-gen-decoder-switch switch-num startbit decode-bitsize table-guts
			     indent lsb0? invalid-insn fn?)
  ; For entries that are a single insn, we're done, otherwise recurse.

  (string-list
   indent "{\n"
   ; Are we at the next word?
   (if (not (= startbit (dtable-guts-startbit table-guts)))
       (begin
	 (set! startbit (dtable-guts-startbit table-guts))
	 (set! decode-bitsize (dtable-guts-bitsize table-guts))
	 ; FIXME: Bits may get fetched again during extraction.
	 (string-append indent "  unsigned int val;\n"
			indent "  /* Must fetch more bits.  */\n"
			indent "  insn = "
			(gen-ifetch "pc" startbit decode-bitsize)
			";\n"
			indent "  val = "))
       (string-append indent "  unsigned int val = "))
   (-gen-decode-bits (dtable-guts-bitnums table-guts)
		     (dtable-guts-startbit table-guts)
		     (dtable-guts-bitsize table-guts)
		     "insn" "entire_insn" lsb0?)
   ";\n"
   indent "  switch (val)\n"
   indent "  {\n"

   ; The code is more readable, and icache use is improved, if we collapse
   ; common code into one case and use "fall throughs" for all but the last of
   ; a set of common cases.
   ; FIXME: We currently rely on -gen-decode-foo-entry to recognize the fall
   ; through.  We should take care of it ourselves.

   (let loop ((entries (-decode-sort-entries (dtable-guts-entries table-guts)))
	      (result nil))
     (if (null? entries)
	 (reverse! result)
	 (loop
	  (cdr entries)
	  (cons (case (dtable-entry-type (car entries))
		  ((insn)
		   (-gen-decode-insn-entry (car entries) (cdr entries) indent invalid-insn fn?))
		  ((expr)
		   (-gen-decode-expr-entry (car entries) indent invalid-insn fn?))
		  ((table)
		   (-gen-decode-table-entry (car entries) (cdr entries)
					    switch-num startbit decode-bitsize
					    indent lsb0? invalid-insn fn?))
		  )
		result))))

   ; ??? Can delete if all cases are present.
   indent "  default : "
   (-gen-decode-default-entry indent invalid-insn fn?)
   indent "  }\n"
   indent "}\n"
   )
)

; Decoder generation entry point.
; Generate code to decode INSN-LIST.
; BITNUMS is the set of bits to initially key off of.
; DECODE-BITSIZE is the number of bits of the instruction that `insn' holds.
; LSB0? is non-#f if bit number 0 is the least significant bit.
; INVALID-INSN is the <insn> object of the pseudo insn to handle invalid ones.
; FN? is non-#f if the extractors are functions rather than inline code

(define (gen-decoder insn-list bitnums decode-bitsize indent lsb0? invalid-insn fn?)
  (logit 3 "Building decode tree.\n"
	 "bitnums = " (stringize bitnums " ") "\n"
	 "decode-bitsize = " (number->string decode-bitsize) "\n"
	 "lsb0? = " (if lsb0? "#t" "#f") "\n"
	 "fn? = " (if fn? "#t" "#f") "\n"
	 )

  ; First build a table that decodes the instruction set.

  (let ((table-guts (decode-build-table insn-list bitnums
					decode-bitsize lsb0?
					invalid-insn)))

    ; Now print it out.

    (-gen-decoder-switch "0" 0 decode-bitsize table-guts indent lsb0?
			 invalid-insn fn?)
    )
)
