; Enums.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; Enums having attribute PREFIX have their symbols prepended with
; the enum class' name.
; Member PREFIX is always prepended to the symbol names.
;
; Enum values are looked up with `enum-lookup-val'.  The value to search for
; has PREFIX prepended.
;
; Enums always have mode INT.

(define <enum>
  (class-make '<enum>
	      '(<ident>)
	      '(prefix vals)
	      nil)
)

; FIXME: this make! method is required by <insn-enum> for some reason.

(method-make!
 <enum> 'make!
 (lambda (self name comment attrs prefix vals)
   (elm-set! self 'name name)
   (elm-set! self 'comment comment)
   (elm-set! self 'attrs attrs)
   (elm-set! self 'prefix prefix)
   (elm-set! self 'vals vals)
   self)
)

(define enum-prefix (elm-make-getter <enum> 'prefix))

(method-make! <enum> 'enum-values (lambda (self) (elm-get self 'vals)))

; Parse a list of enum name/value entries.
; PREFIX is prepended to each name.
; Elements are any of: symbol, (symbol), (symbol value)
; (symbol - attrs), (symbol value attrs), (symbol - attrs comment),
; (symbol value attrs comment).
; The - or #f means "use the next value".
; SYMBOL may be - which means "skip this value".
; The result is the same list, except values are filled in where missing,
; and each symbol is prepended with `prefix'.

(define (parse-enum-vals context prefix vals)
  ; Scan the value list, building up RESULT as we go.
  ; Each element's value is 1+ the previous, unless there's an explicit value.
  (let loop ((result nil) (last -1) (remaining vals))
    (if (null? remaining)
	(reverse! result)
	(let
	    ; Compute the numeric value the next entry will have.
	    ((val (if (and (pair? (car remaining))
			   (not (null? (cdar remaining))))
		      (if (eq? '- (cadar remaining))
			  (+ last 1)
			  (cadar remaining))
		      (+ last 1))))
	  (if (eq? (car remaining) '-)
	      (loop result val (cdr remaining))
	      (let ((name (symbolstr-append prefix
					    (if (pair? (car remaining))
						(caar remaining)
						(car remaining))))
		    (attrs (if (and (pair? (car remaining))
				    (pair? (cdar remaining))
				    (pair? (cddar remaining)))
			       (caddar remaining)
			       nil))
		    (comment (if (and (pair? (car remaining))
				      (pair? (cdar remaining))
				      (pair? (cddar remaining))
				      (pair? (cdddar remaining)))
				 (car (cdddar remaining))
				 "")))
		(loop (cons (list name val attrs comment) result)
		      val
		      (cdr remaining)))))))
)

; Accessors for the various elements of an enum val.

(define (enum-val-name ev) (list-ref ev 0))
(define (enum-val-value ev) (list-ref ev 1))
(define (enum-val-attrs ev) (list-ref ev 2))
(define (enum-val-comment ev) (list-ref ev 3))

; Convert the names in the result of parse-enum-vals to uppercase.

(define (enum-vals-upcase vals)
  (map (lambda (elm)
	 (cons (symbol-upcase (car elm)) (cdr elm)))
       vals)
)

; Parse an enum definition.

; Utility of -enum-parse to parse the prefix.

(define (-enum-parse-prefix context prefix)
  (if (symbol? prefix)
      (set! prefix (symbol->string prefix)))

  (if (not (string? prefix))
      (parse-error context "prefix is not a string" prefix))

  ; Prefix must not contain lowercase chars (enforced style rule, sue me).
  (if (any-true? (map char-lower-case? (string->list prefix)))
      (parse-error context "prefix must be uppercase" prefix))

  prefix
)

; This is the main routine for building an enum object from a
; description in the .cpu file.
; All arguments are in raw (non-evaluated) form.

(define (-enum-parse context name comment attrs prefix vals)
  (logit 2 "Processing enum " name " ...\n")

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name)))

    (make <enum>
	  name
	  (parse-comment context comment)
	  (atlist-parse context attrs "enum")
	  (-enum-parse-prefix context prefix)
	  (parse-enum-vals context prefix vals)))
)

; Read an enum description
; This is the main routine for analyzing enums in the .cpu file.
; CONTEXT is a <context> object for error messages.
; ARG-LIST is an associative list of field name and field value.
; -enum-parse is invoked to create the `enum' object.

(define (-enum-read context . arg-list)
  (let (
	(name #f)
	(comment "")
	(attrs nil)
	(prefix "")
	(values nil)
	)

    ; Loop over each element in ARG-LIST, recording what's found.
    (let loop ((arg-list arg-list))
      (if (null? arg-list)
	  nil
	  (let ((arg (car arg-list))
		(elm-name (caar arg-list)))
	    (case elm-name
	      ((name) (set! name (cadr arg)))
	      ((comment) (set! comment (cadr arg)))
	      ((attrs) (set! attrs (cdr arg)))
	      ((prefix) (set! prefix (cadr arg)))
	      ((values) (set! values (cadr arg)))
	      (else (parse-error context "invalid enum arg" arg)))
	    (loop (cdr arg-list)))))

    ; Now that we've identified the elements, build the object.
    (-enum-parse context name comment attrs prefix values))
)

; Define an enum object, name/value pair list version.

(define define-enum
  (lambda arg-list
    (let ((e (apply -enum-read (cons (make-current-context "define-enum")
				     arg-list))))
      (current-enum-add! e)
      e))
)

; Define an enum object, all arguments specified.

(define (define-full-enum name comment attrs prefix vals)
  (let ((e (-enum-parse (make-current-context "define-full-enum")
			name comment attrs prefix vals)))
    (current-enum-add! e)
    e)
)

; Lookup SYM in all recorded enums.
; The result is (value . enum-obj) or #f if not found.

(define (enum-lookup-val name)
  (let loop ((elist (current-enum-list)))
    (if (null? elist)
	#f
	(let ((e (assq name (send (car elist) 'enum-values))))
	  ;(display e) (newline)
	  (if e
	      (begin
		; sanity check, ensure the enum has a value
		(if (null? (cdr e)) (error "enum-lookup-val: enum missing value: " (car e)))
		(cons (cadr e) (car elist)))
	      (loop (cdr elist)))
	  )
	)
    )
)

; Enums support code.

; Return #t if VALS is a sequential list of enum values.
; VALS is a list of enums.  e.g. ((sym1) (sym2 3) (sym3 - attr1 (attr2 4)))
; FIXME: Doesn't handle gaps in specified values.
; e.g. (sym1 val1) sym2 (sym3 val3)

(define (enum-sequential? vals)
  (let loop ((last -1) (remaining vals))
    (if (null? remaining)
	#t
	(let ((val (if (and (pair? (car remaining))
			    (not (null? (cdar remaining))))
		       (cadar remaining)
		       (+ last 1))))
	  (if (eq? val '-)
	      (loop (+ last 1) (cdr remaining))
	      (if (not (= val (+ last 1)))
		  #f
		  (loop val (cdr remaining)))))))
)

; Return C code to declare enum SYM with values VALS.
; COMMENT is inserted in "/* Enum declaration for <...>.  */".
; PREFIX is added to each element of VALS.
; All enum symbols are uppercase.
; If the list of vals is sequential beginning at 0, don't output them.
; This simplifies the output and is necessary for sanitized values where
; some values may be cut out.
; VALS may have '- for the value, signifying use the next value as in C.

(define (gen-enum-decl name comment prefix vals)
  (logit 2 "Generating enum decl for " name " ...\n")
  ; Build result up as a list and then flatten it into a string.
  ; We could just return a string-list but that seems like too much to ask
  ; of callers.
  (string-list->string
   (append!
    (string-list
     "/* Enum declaration for " comment ".  */\n"
     "typedef enum "
     (string-downcase (gen-c-symbol name))
     " {")
    (let loop ((n 0) ; `n' is used to track the number of entries per line only
	       (sequential? (enum-sequential? vals))
	       (vals vals)
	       (result (list "")))
      (if (null? vals)
	  result
	  (let* ((e (car vals))
		 (attrs (if (null? (cdr e)) nil (cddr e)))
		 (san-code (attr-value attrs 'sanitize #f))
		 (san? (and san-code (not (eq? san-code 'none)))))
	    (loop
	     (if san?
		 4 ; reset to beginning of line (but != 0)
		 (+ n 1))
	     sequential?
	     (cdr vals)
	     (append!
	      result
	      (string-list
	       (if san?
		   (string-append "\n"
				  (if include-sanitize-marker?
				      ; split string to avoid removal
				      (string-append "/* start-"
						     "sanitize-"
						     san-code " */\n")
				      "")
				  " ")
		   "")
	       (string-upcase
		(string-append
		 (if (and (not san?) (=? (remainder n 4) 0))
		     "\n "
		     "")
		 (if (= n 0)
		     " "
		     ", ")
		 (gen-c-symbol prefix)
		 (gen-c-symbol (car e))
		 (if (or sequential?
			 (null? (cdr e))
			 (eq? '- (cadr e)))
		     ""
		     (string-append " = "
				    (if (number? (cadr e))
					(number->string (cadr e))
					(cadr e))))
		 ))
	       (if (and san? include-sanitize-marker?)
		   ; split string to avoid removal
		   (string-append "\n/* end-"
				  "sanitize-" san-code " */")
		   "")))))))
    (string-list
     "\n} "
     (string-upcase (gen-c-symbol name))
     ";\n\n")
    ))
)

; Return a list of enum value definitions for gen-enum-decl.
; OBJ-LIST is a list of objects that support obj:name, obj-atlist.

(define (gen-obj-list-enums obj-list)
  (map (lambda (o)
	 (cons (obj:name o) (cons '- (atlist-attrs (obj-atlist o)))))
       obj-list)
)

; Return C code that declares[/defines] an enum.

(method-make!
 <enum> 'gen-decl
 (lambda (self)
   (gen-enum-decl (elm-get self 'name)
		  (elm-get self 'comment)
		  (if (has-attr? self 'PREFIX)
		      (string-append (elm-get self 'name) "_")
		      "")
		  (elm-get self 'vals)))
)

; Return the C symbol of an enum value named VAL.

(define (gen-enum-sym enum-obj val)
  (string-upcase (gen-c-symbol (string-append (enum-prefix enum-obj) val)))
)

; Instruction code enums.
; These associate an enum with an instruction field so that the enum values
; can be used in instruction field lists.

(define <insn-enum> (class-make '<insn-enum> '(<enum>) '(fld) nil))

(method-make!
 <insn-enum> 'make!
 (lambda (self name comment attrs prefix fld vals)
   (send (object-parent self <enum>) 'make! name comment attrs prefix vals)
   (elm-set! self 'fld fld)
   self
   )
)

(define ienum:fld (elm-make-getter <insn-enum> 'fld))

; Same as enum-lookup-val except returned enum must be an insn-enum.

(define (ienum-lookup-val name)
  (let ((result (enum-lookup-val name)))
    (if (and result (eq? (object-class-name (cdr result)) '<insn-enum>))
	result
	#f))
)

; Define an insn enum, all arguments specified.

(define (define-full-insn-enum name comment attrs prefix fld vals)
  (let* ((context (make-current-context "define-full-insn-enum"))
	 (atlist (atlist-parse context attrs "insn-enum"))
	 (fld-obj (current-ifld-lookup fld)))

    (if (keep-isa-atlist? atlist #f)
	(begin
	  (if (not fld-obj)
	      (parse-error context "unknown insn field" fld))
	  ; Create enum object and add it to the list of enums.
	  (let ((e (make <insn-enum>
		     (parse-name context name)
		     (parse-comment context comment)
		     atlist
		     (-enum-parse-prefix context prefix)
		     fld-obj
		     (parse-enum-vals context prefix vals))))
	    (current-enum-add! e)
	    e))))
)

(define (enum-init!)

  (reader-add-command! 'define-enum
		       "\
Define an enum, name/value pair list version.
"
		       nil 'arg-list define-enum)
  (reader-add-command! 'define-full-enum
		       "\
Define an enum, all arguments specified.
"
		       nil '(name comment attrs prefix vals) define-full-enum)
  (reader-add-command! 'define-full-insn-enum
		       "\
Define an instruction opcode enum, all arguments specified.
"
		       nil '(name comment attrs prefix ifld vals)
		       define-full-insn-enum)

  *UNSPECIFIED*
)

(define (enum-finish!)
  *UNSPECIFIED*
)
