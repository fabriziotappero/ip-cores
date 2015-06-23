; Application independent utilities for C/C++ code generation.
; Copyright (C) 2000, 2001, 2005, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; Attributes.

(define (attr-bool-gen-decl attr) "")

(define (attr-bool-gen-defn attr) "")

(define (attr-int-gen-decl attr) "")

(define (attr-int-gen-defn attr) 
  (string-append
   "static const CGEN_ATTR_ENTRY " (gen-sym attr)
   "_attr [] ATTRIBUTE_UNUSED = \n{\n  {\"integer\", " (number->string (attr-default attr)) "},\n  { 0, 0 }\n};\n\n" ))

(define (attr-gen-decl attr)
  (gen-enum-decl (symbol-append (obj:name attr) '-attr)
		 (obj:comment attr)
		 (string-append (obj:str-name attr) "_")
		 (attr-values attr))
)

(define (attr-gen-defn attr)
  (string-append
   "static const CGEN_ATTR_ENTRY "
   (gen-sym attr) "_attr"
   "[] ATTRIBUTE_UNUSED =\n{\n"
   (string-map (lambda (elm)
		 (let* ((san (and (pair? elm) (pair? (cdr elm))
				  (attr-value (cddr elm) 'sanitize #f))))
		   (gen-sanitize
		    (if (and san (not (eq? san 'none)))
			san
			#f)
		    (string-append "  { "
				   "\""
				   (gen-c-symbol (car elm))
				   "\", "
				   (string-upcase (gen-sym attr))
				   "_"
				   (string-upcase (gen-c-symbol (car elm)))
				   " },\n"))))
	       (attr-values attr))
   "  { 0, 0 }\n"
   "};\n\n")
)

(method-make! <boolean-attribute> 'gen-decl attr-bool-gen-decl)
(method-make! <bitset-attribute> 'gen-decl attr-gen-decl)
(method-make! <integer-attribute> 'gen-decl attr-int-gen-decl)
(method-make! <enum-attribute> 'gen-decl attr-gen-decl)

(method-make! <boolean-attribute> 'gen-defn attr-bool-gen-defn)
(method-make! <bitset-attribute> 'gen-defn attr-gen-defn)
(method-make! <integer-attribute> 'gen-defn attr-int-gen-defn)
(method-make! <enum-attribute> 'gen-defn attr-gen-defn)

; Ifield extraction utilities.

; Return the C data type to use to hold an extracted and decoded
; <ifield> from an insn.  Usually this is just an int, but for register
; numbers or large unsigned immediates, an unsigned int may be preferable.
; Then there's floats (??? which aren't handled yet).

(define (gen-ifld-type f)
  (mode:c-type (ifld-decode-mode f))
)

; Return C declaration of variable(s) to hold <ifield> F.
; MACRO? is #t if the result is part of a macro.

(define (gen-ifld-extract-decl f indent macro?)
  (string-append indent (gen-ifld-type f) " " (gen-sym f) ";"
		 (if macro? " \\\n" "\n"))
)

; Return C code to extract a field from the base part of an insn.
;
; TOTAL-LENGTH is the total length of the value in VAL.
; BASE-VALUE is a C expression (string) containing the base part of the insn.

(define (-gen-ifld-extract-base f total-length base-value)
  (let ((extraction
	 (string-append "EXTRACT_"
			(if (current-arch-insn-lsb0?) "LSB0_" "MSB0_")
			(case (mode:class (ifld-mode f))
			  ((INT) "INT")
			  ((UINT) "UINT")
			  (else (error "unsupported mode class"
				       (mode:class (ifld-mode f)))))
			" ("
			base-value ", "
			(number->string total-length) ", "
			; ??? Is passing total-length right here?
			(number->string (+ (ifld-start f total-length)
					   (ifld-word-offset f))) ", "
			(number->string (ifld-length f))
			")"))
	(decode (ifld-decode f)))
    ; If the field doesn't have a special decode expression,
    ; just return the raw extracted value.  Otherwise, emit
    ; the expression.
    (if (not decode)
	extraction
	; cadr: fetches expression to be evaluated
	; caar: fetches symbol in arglist
	; cadar: fetches `pc' symbol in arglist
	(rtl-c VOID (cadr decode)
	       (list (list (caar decode) 'UINT extraction)
		     (list (cadar decode) 'IAI "pc"))
	       #:rtl-cover-fns? #f #:ifield-var? #t)))
)

; Subroutine of -gen-ifld-extract-beyond to extract the relevant value
; from WORD-NAME and move it into place.

(define (-gen-extract-word word-name word-start word-length
			   field-start field-length
			   unsigned? lsb0?)
  (let* ((word-end (+ word-start word-length))
	 (start (if lsb0? (+ 1 (- field-start field-length)) field-start))
	 (end (+ start field-length))
	 (base (if (< start word-start) word-start start)))
    (string-append "("
		   "EXTRACT_"
		   (if lsb0? "LSB0" "MSB0")
		   (if (and (not unsigned?)
			    ; Only want sign extension for word with sign bit.
			    (bitrange-overlap? field-start 1
					       word-start word-length
					       lsb0?))
		       "_INT ("
		       "_UINT (")
		   ; What to extract from.
		   word-name
		   ", "
		   ; Size of this chunk.
		   (number->string word-length)
		   ", "
		   ; MSB of this chunk.
		   (number->string
		    (if lsb0?
			(if (> end word-end)
			    (- word-end 1)
			    (- end word-start 1))
			(if (< start word-start)
			    0
			    (- start word-start))))
		   ", "
		   ; Length of field within this chunk.
		   (number->string (if (< end word-end)
				       (- end base)
				       (- word-end base)))
		   ") << "
		   ; Adjustment for this chunk within a full field.
		   (number->string (if (> end word-end)
				       (- end word-end)
				       0))
		   ")"))
)

; Return C code to extract a field that extends beyond the base insn.
;
; Things get tricky in the non-integral-insn case (no kidding).
; This case includes every architecture with at least one insn larger
; than 32 bits, and all architectures where insns smaller than 32 bits
; can't be interpreted as an int.
; ??? And maybe other architectures not considered yet.
; We want to handle these reasonably fast as this includes architectures like
; the ARC and I960 where 99% of the insns are 32 bits, with a few insns that
; take a 32 bit immediate.  It would be a real shame to unnecessarily slow down
; handling of 99% of the instruction set just for a few insns.  Fortunately
; for these chips base-insn includes these insns, so things fall out naturally.
;
; BASE-LENGTH is base-insn-bitsize.
; TOTAL-LENGTH is the total length of the insn.
; VAR-LIST is a list of variables containing the insn.
; Each element in VAR-LIST is (name start length).
; The contents of the insn are in several variables: insn, word_[123...],
; where `insn' contains the "base insn" and `word_N' is a set of variables
; recording the rest of the insn, 32 bits at a time (with the last one
; containing whatever is left over).

(define (-gen-ifld-extract-beyond f base-length total-length var-list)
   ; First compute the list of variables that contains pieces of the
   ; desired value.
   (let ((start (+ (ifld-start f total-length) (ifld-word-offset f)))
	 (length (ifld-length f))
	 ;(word-start (ifld-word-offset f))
	 ;(word-length (ifld-word-length f))
	 ; extraction code
	 (extraction #f)
         ; extra processing to perform on extracted value
	 (decode (ifld-decode f))
	 (lsb0? (current-arch-insn-lsb0?)))
     ; Find which vars are needed and move the value into place.
     (let loop ((var-list var-list) (result (list ")")))
       (if (null? var-list)
	   (set! extraction (apply string-append (cons "(0" result)))
	   (let ((var-name (caar var-list))
		 (var-start (cadar var-list))
		 (var-length (caddar var-list)))
	     (if (bitrange-overlap? start length
				    var-start var-length
				    lsb0?)
		 (loop (cdr var-list)
		       (cons "|"
			     (cons (-gen-extract-word var-name
						      var-start
						      var-length
						      start length
						      (eq? (mode:class (ifld-mode f))
							   'UINT)
						      lsb0?)
				   result)))
		 (loop (cdr var-list) result)))))
     ; If the field doesn't have a special decode expression, just return the
     ; raw extracted value.  Otherwise, emit the expression.
     (if (not decode)
	 extraction
	 ; cadr: fetches expression to be evaluated
	 ; caar: fetches symbol in arglist
	 ; cadar: fetches `pc' symbol in arglist
	 (rtl-c VOID (cadr decode)
		(list (list (caar decode) 'UINT extraction)
		      (list (cadar decode) 'IAI "pc"))
		#:rtl-cover-fns? #f #:ifield-var? #t)))
)

; Return C code to extract <ifield> F.

(define (gen-ifld-extract f indent base-length total-length base-value var-list macro?)
  (string-append
   indent
   (gen-sym f)
   " = "
   (if (adata-integral-insn? CURRENT-ARCH)
       (-gen-ifld-extract-base f total-length base-value)
       (if (ifld-beyond-base? f base-length total-length)
	   (-gen-ifld-extract-beyond f base-length total-length var-list)
	   (-gen-ifld-extract-base f base-length base-value)))
   ";"
   (if macro? " \\\n" "\n")
   )
)

; Return C code to extract a <multi-ifield> from an insn.
; This must have the same signature as gen-ifld-extract as both can be
; made methods in application code.

(define (gen-multi-ifld-extract f indent base-length total-length base-value var-list macro?)
  ; The subfields must have already been extracted.
  (let* ((decode-proc (ifld-decode f))
	 (varname (gen-sym f))
	 (decode (string-list
		  ;; First, the block that extract the multi-ifield into the ifld variable
		  (rtl-c VOID (multi-ifld-extract f) nil
			 #:rtl-cover-fns? #f #:ifield-var? #t)
		  ;; Next, the decode routine that modifies it
		  (if decode-proc
		      (string-append
		       "  " varname " = "
		       (rtl-c VOID (cadr decode-proc)
			      (list (list (caar decode-proc) 'UINT varname)
				    (list (cadar decode-proc) 'IAI "pc"))
			      #:rtl-cover-fns? #f #:ifield-var? #t)
		       ";\n")
		      "")
		 )))
    (if macro?
	(backslash "\n" decode)
	decode))
)

; Return C symbol of variable containing the extracted field value
; in the extraction code.  E.g. f_rd = EXTRACT_UINT (insn, ...).

(define (gen-extracted-ifld-value f)
  (gen-sym f)
)

; Subroutine of gen-extract-ifields to compute arguments for -extract-chunk
; to extract values beyond the base insn.
; This is also used by gen-define-ifields to know how many vars are needed.
;
; The result is a list of (offset . length) pairs.
;
; ??? Here's a case where explicitly defined instruction formats can
; help - without them we can only use heuristics (which must evolve).
; At least all the details are tucked away here.

(define (-extract-chunk-specs base-length total-length alignment)
  (let ((chunk-length
	 (case alignment
	   ; For the aligned and forced case split the insn up into base-insn
	   ; sized chunks.  For the unaligned case, use a chunk-length of 32.
	   ; 32 was chosen because the values are extracted into portable ints.
	   ((aligned forced) (min base-length 32))
	   ((unaligned) 32)
	   (else (error "unknown alignment" alignment)))))
    (let loop ((start base-length)
	       (remaining (- total-length base-length))
	       (result nil))
      (if (<= remaining 0)
	  (reverse! result)
	  (loop (+ start chunk-length)
		(- remaining chunk-length)
		; Always fetch full CHUNK-LENGTH-sized chunks here,
		; even if we don't actually need that many bytes.
		; gen-ifetch only handles "normal" fetch sizes,
		; and -gen-extract-word already knows how to find what
		; it needs if we give it too much.
		(cons (cons start chunk-length)
		      result)))))
)

; Subroutine of gen-define-ifmt-ifields and gen-extract-ifmt-ifields to
; insert the subfields of any multi-ifields present into IFLDS.
; Subfields are inserted before their corresponding multi-ifield as they
; are initialized in order.

(define (-extract-insert-subfields iflds)
  (let loop ((result nil) (iflds iflds))
    (cond ((null? iflds)
	   (reverse! result))
	  ((multi-ifield? (car iflds))
	   (loop (cons (car iflds)
		       ; There's no real need to reverse the subfields here
		       ; other than to keep them in order.
		       (append (reverse (multi-ifld-subfields (car iflds)))
			       result))
		 (cdr iflds)))
	  (else
	   (loop (cons (car iflds) result) (cdr iflds)))))
)

; Return C code to define local vars to contain IFIELDS.
; All insns using the result have the same TOTAL-LENGTH (in bits).
; INDENT is a string prepended to each line.
; MACRO? is #t if the code is part of a macro (and thus '\\' must be appended
; to each line).

(define (gen-define-ifields ifields total-length indent macro?)
  (let* ((base-length (if (adata-integral-insn? CURRENT-ARCH)
			  32
			  (state-base-insn-bitsize)))
	 (chunk-specs (-extract-chunk-specs base-length total-length
					    (current-arch-default-alignment))))
    (string-list
     (string-list-map (lambda (f)
			(gen-ifld-extract-decl f indent macro?))
		      ifields)
     ; Define enough ints to hold the trailing part of the insn,
     ; N bits at a time.
     ; ??? This could be more intelligent of course.  Later.
     ; ??? Making these global to us would allow filling them during
     ; decoding.
     (if (> total-length base-length)
	 (string-list
	  indent
	  "/* Contents of trailing part of insn.  */"
	  (if macro? " \\\n" "\n")
	  (string-list-map (lambda (chunk-num)
			     (string-list indent
					  "UINT word_"
					  (number->string chunk-num)
					  (if macro? "; \\\n" ";\n")))
			   (iota (length chunk-specs) 1)))
	 "")))
)

; Return C code to define local vars to contain IFIELDS of <iformat> IFMT.
; INDENT is a string prepended to each line.
; MACRO? is #t if the code is part of a macro (and thus '\\' must be appended
; to each line).
; USE-MACRO? is #t if instead of generating the fields, we return the macro
; that does that.

(define (gen-define-ifmt-ifields ifmt indent macro? use-macro?)
  (let ((macro-name (string-append
		     "EXTRACT_" (string-upcase (gen-sym ifmt))
		     "_VARS"))
	(ifields (-extract-insert-subfields (ifmt-ifields ifmt))))
    (if use-macro?
	(string-list indent macro-name
		     " /*"
		     (string-list-map (lambda (fld)
					(string-append " " (obj:str-name fld)))
				      ifields)
		     " */\n")
	(let ((indent (if macro? (string-append indent "  ") indent)))
	  (string-list
	   (if macro?
	       (string-list "#define " macro-name " \\\n")
	       (string-list indent "/* Instruction fields.  */\n"))
	   (gen-define-ifields ifields (ifmt-length ifmt) indent macro?)
	   indent "unsigned int length;"
	   ; The last line doesn't have a trailing '\\'.
	   "\n"
	   ))))
)

; Subroutine of gen-extract-ifields to fetch one value into VAR-NAME.

(define (-extract-chunk offset bits var-name macro?)
  (string-append
   "  "
   var-name
   " = "
   (gen-ifetch "pc" offset bits)
   ";"
   (if macro? " \\\n" "\n"))
)

; Subroutine of gen-extract-ifields to compute the var-list arg to
; gen-ifld-extract-beyond.
; The result is a list of `(name start length)' elements describing the
; variables holding the parts of the insn.
; CHUNK-SPECS is a list of (offset . length) pairs.

(define (-gen-extract-beyond-var-list base-length var-prefix chunk-specs lsb0?)
  ; ??? lsb0? support ok?
  (cons (list "insn" 0 base-length)
	(map (lambda (chunk-num chunk-spec)
	       (list (string-append var-prefix (number->string chunk-num))
		     (car chunk-spec)
		     (cdr chunk-spec)))
	     (iota (length chunk-specs) 1)
	     chunk-specs))
)

; Return C code to extract IFIELDS.
; All insns using the result have the same TOTAL-LENGTH (in bits).
; MACRO? is #t if the code is part of a macro (and thus '\\' must be appended
; to each line).
;
; Here is where we handle integral-insn vs non-integeral-insn architectures.
;
; Examples of architectures that can be handled as integral-insns are:
; sparc, m32r, mips, etc.
;
; Examples of architectures that can't be handled as integral insns are:
; arc, i960, fr30, i386, m68k.
; [i386,m68k are only mentioned for completeness.  cgen ports of these
; would be great, but more thought is needed first]
;
; C variable `insn' is assumed to contain the base part of the insn
; (max base-insn-bitsize insn-bitsize).  In the m32r case insn-bitsize
; can be less than base-insn-bitsize.
;
; ??? Need to see how well gcc optimizes this.
;
; ??? Another way to do this is to put this code in an inline function that
; gets passed pointers to each ifield variable.  GCC is smart enough to
; produce optimal code for this, but other compilers may not have inlining
; or the indirection removal.  I think the slowdown for a non-scache simulator
; would be phenomenal and while one can say "too bad, use gcc", I'm defering
; doing this for now.

(define (gen-extract-ifields ifields total-length indent macro?)
  (let* ((base-length (if (adata-integral-insn? CURRENT-ARCH)
			  32
			  (state-base-insn-bitsize)))
	 (chunk-specs (-extract-chunk-specs base-length total-length
					    (current-arch-default-alignment))))
    (string-list
     ; If the insn has a trailing part, fetch it.
     ; ??? Could have more intelligence here.  Later.
     (if (> total-length base-length)
	 (let ()
	   (string-list-map (lambda (chunk-spec chunk-num)
			      (-extract-chunk (car chunk-spec)
					      (cdr chunk-spec)
					      (string-append
					       "word_"
					       (number->string chunk-num))
					      macro?))
			    chunk-specs
			    (iota (length chunk-specs) 1)))
	 "")
     (string-list-map
      (lambda (f)
	; Dispatching on a method works better, as would a generic fn.
	; ??? Written this way to pass through Hobbit, doesn't handle
	; ((if foo a b) (arg1 arg2)).
	(if (multi-ifield? f)
	    (gen-multi-ifld-extract
	     f indent base-length total-length "insn"
	     (-gen-extract-beyond-var-list base-length "word_"
					   chunk-specs
					   (current-arch-insn-lsb0?))
	     macro?)
	    (gen-ifld-extract
	     f indent base-length total-length "insn"
	     (-gen-extract-beyond-var-list base-length "word_"
					   chunk-specs
					   (current-arch-insn-lsb0?))
	     macro?)))
      ifields)
     ))
)

; Return C code to extract the fields of <iformat> IFMT.
; MACRO? is #t if the code is part of a macro (and thus '\\' must be appended
; to each line).
; USE-MACRO? is #t if instead of generating the fields, we return the macro
; that does that.

(define (gen-extract-ifmt-ifields ifmt indent macro? use-macro?)
  (let ((macro-name (string-append
		     "EXTRACT_" (string-upcase (gen-sym ifmt))
		     "_CODE"))
	(ifields (-extract-insert-subfields (ifmt-ifields ifmt))))
    (if use-macro?
	(string-list indent macro-name "\n")
	(let ((indent (if macro? (string-append indent "  ") indent)))
	  (string-list
	   (if macro?
	       (string-list "#define " macro-name " \\\n")
	       "")
	   indent "length = "
	   (number->string (bits->bytes (ifmt-length ifmt)))
	   ";"
	   (if macro? " \\\n" "\n")
	   (gen-extract-ifields ifields (ifmt-length ifmt) indent macro?)
	   ; The last line doesn't have a trailing '\\'.
	   "\n"
	   ))))
)

; Instruction format utilities.

(define (gen-sfmt-enum-decl sfmt-list)
  (gen-enum-decl "@prefix@_sfmt_type"
		 "semantic formats in cpu family @cpu@"
		 "@PREFIX@_"
		 (map (lambda (sfmt) (cons (obj:name sfmt) nil))
		      sfmt-list))
)
