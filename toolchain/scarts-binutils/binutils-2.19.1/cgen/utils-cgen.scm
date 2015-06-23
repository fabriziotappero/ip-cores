; CGEN Utilities.
; Copyright (C) 2000, 2002, 2003, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.
;
; This file contains utilities specific to cgen.
; Generic utilities should go in utils.scm.

; True if text of sanitize markers are to be emitted.
; This is a debugging tool only, though it could have use in sanitized trees.
(define include-sanitize-marker? #t)

; Utility to display command line invocation for debugging purposes.

(define (display-argv argv)
  (let ((cep (current-error-port)))
    (display "cgen -s " cep)
    (for-each (lambda (arg)
		; Output double-quotes if string has a space for better
		; correspondence to how to specify string to shell.
		(if (string-index arg #\space)
		    (write arg cep)
		    (display arg cep))
		(display " " cep))
	      argv)
    (newline cep))
)

; COS utilities.
; Perhaps these should be provided with cos (cgen-object-system), but for
; now they live here.

; Define the getter for a list of elements of a class.

(defmacro define-getters (class class-prefix elm-names)
  (cons 'begin
	(map (lambda (elm-name)
	       (if (pair? elm-name)
		   `(define ,(symbol-append class-prefix '- (cdr elm-name))
		      (elm-make-getter ,class (quote ,(car elm-name))))
		   `(define ,(symbol-append class-prefix '- elm-name)
		      (elm-make-getter ,class (quote ,elm-name)))))
	     elm-names))
)

; Define the setter for a list of elements of a class.

(defmacro define-setters (class class-prefix elm-names)
  (cons 'begin
	(map (lambda (elm-name)
	       (if (pair? elm-name)
		   `(define ,(symbol-append class-prefix '-set- (cdr elm-name) '!)
		      (elm-make-setter ,class (quote ,(car elm-name))))
		   `(define ,(symbol-append class-prefix '-set- elm-name '!)
		      (elm-make-setter ,class (quote ,elm-name)))))
	     elm-names))
)

; Make an object, specifying values for particular elements.
; ??? Eventually move to cos.scm/cos.c.

(define (vmake class . args)
  (let ((obj (new class)))
    (let ((unrecognized (send obj 'vmake! args)))
      (if (null? unrecognized)
	  obj
	  (error "vmake: unknown options:" unrecognized))))
)

;;; Source locations are recorded as a stack, with (ideally) one extra level
;;; for each macro invocation.

(define <location> (class-make '<location>
			       nil
			       '(
				 ;; A list of "single-location" objects,
				 ;; sorted by most recent location first.
				 list
				 )
			       nil))

(define-getters <location> location (list))
(define-setters <location> location (list))

;;; A single source location.
;;; This is recorded as a vector for simplicity.
;;; END? is true if the location marks the end of the expression.
;;; NOTE: LINE and COLUMN are origin-0 (the first line is line 0).

(define (make-single-location file line column end?)
  (vector file line column end?)
)

(define (single-location-file sloc) (vector-ref sloc 0))
(define (single-location-line sloc) (vector-ref sloc 1))
(define (single-location-column sloc) (vector-ref sloc 2))
(define (single-location-end? sloc) (vector-ref sloc 3))

;;; Return a single-location in a readable form.

(define (single-location->string sloc)
  ;; +1: numbers are recorded origin-0
  (string-append (single-location-file sloc)
		 ":"
		 (number->string (+ (single-location-line sloc) 1))
		 ":"
		 (number->string (+ (single-location-column sloc) 1))
		 (if (single-location-end? sloc) "(end)" ""))
)

;;; Same as single-location->string, except omit any directory info in
;;; the file name.

(define (single-location->simple-string sloc)
  ;; +1: numbers are recorded origin-0
  (string-append (basename (single-location-file sloc))
		 ":"
		 (number->string (+ (single-location-line sloc) 1))
		 ":"
		 (number->string (+ (single-location-column sloc) 1))
		 (if (single-location-end? sloc) "(end)" ""))
)

;;; Return a location in a readable form.

(define (location->string loc)
  (let ((ref-from " referenced from:"))
    (string-drop
     (- 0 (string-length ref-from) 1)
     (string-drop1
      (apply string-append
	     (map (lambda (sloc)
		    (string-append "\n"
				   (single-location->string sloc)
				   ":"
				   ref-from))
		  (location-list loc))))))
)

;;; Return the location information in Guile's source-properties
;;; in a readable form.

(define (source-properties-location->string src-props)
  (let ((file (assq-ref src-props 'filename))
	(line (assq-ref src-props 'line))
	(column (assq-ref src-props 'column)))
    (string-append file
		   ":"
		   (number->string (+ line 1))
		   ":"
		   (number->string (+ column 1))))
)

;;; Return the top location on LOC's stack.

(define (location-top loc)
  (car (location-list loc))
)

;;; Return a new <location> with FILE, LINE pushed onto the stack.

(define (location-push-single loc file line column end?)
  (make <location> (cons (make-single-location file line column end?)
			 (location-list loc)))
)

;;; Return a new <location> with NEW-LOC preappended to LOC.

(define (location-push loc new-loc)
  (make <location> (append (location-list new-loc)
			   (location-list loc)))
)

;;; Return an unspecified <location>.
;;; This is mainly for use in debugging utilities.
;;; Ideally for .cpu-file related stuff we always have a location,
;;; but that's not always true.

(define (unspecified-location)
  (make <location> (list (make-single-location "unspecified" 0 0 #f)))
)

;;; Return a location denoting a builtin object.

(define (builtin-location)
  (make <location> (list (make-single-location "builtin" 0 0 #f)))
)

;;; Return a <location> object for the current input port.
;;; END? is true if the location marks the end of the expression.

(define (current-input-location end?)
  (let ((cip (current-input-port)))
    (make <location> (list (make-single-location (port-filename cip)
						 (port-line cip)
						 (port-column cip)
						 end?))))
)

;;; An object property for tracking source locations during macro expansion.

(define location-property (make-object-property))

;;; Set FORM's location to LOC.

(define (location-property-set! form loc)
  (set! (location-property form) loc)
  *UNSPECIFIED*
)

; Each named entry in the description file typically has these three members:
; name, comment attrs.

(define <ident> (class-make '<ident> '() '(name comment attrs) '()))

(method-make! <ident> 'get-name (lambda (self) (elm-get self 'name)))
(method-make! <ident> 'get-comment (lambda (self) (elm-get self 'comment)))
(method-make! <ident> 'get-atlist (lambda (self) (elm-get self 'attrs)))

(method-make! <ident> 'set-name!
	      (lambda (self newval) (elm-set! self 'name newval)))
(method-make! <ident> 'set-comment!
	      (lambda (self newval) (elm-set! self 'comment newval)))
(method-make! <ident> 'set-atlist!
	      (lambda (self newval) (elm-set! self 'attrs newval)))

; All objects defined in the .cpu file have these elements.
; Where in the class hierarchy they're recorded depends on the object.
; Additionally most objects have `name', `comment' and `attrs' elements.

(define (obj:name obj) (send obj 'get-name))
(define (obj-set-name! obj name) (send obj 'set-name! name))
(define (obj:comment obj) (send obj 'get-comment))

; Utility to return the name as a string.

(define (obj:str-name obj) (symbol->string (obj:name obj)))

; Subclass of <ident> for use by description file objects.
;
; Records the source location of the object.
;
; We also record an internally generated entry, ordinal, to record the
; relative position within the description file.  It's generally more efficient
; to record some kinds of objects (e.g. insns) in a hash table.  But we also
; want to emit these objects in file order.  Recording the object's relative
; position lets us generate an ordered list when we need to.
; We can't just use the line number because we want an ordering over multiple
; input files.

(define <source-ident>
  (class-make '<source-ident> '(<ident>)
	      '(
		;; A <location> object.
		(location . #f)
		;; #f for ordinal means "unassigned"
		(ordinal . #f)
		)
	      '()))

(method-make! <source-ident> 'get-location
	      (lambda (self) (elm-get self 'location)))
(method-make! <source-ident> 'set-location!
	      (lambda (self newval) (elm-set! self 'location newval)))
(define (obj-location obj) (send obj 'get-location))
(define (obj-set-location! obj location) (send obj 'set-location! location))

(method-make! <source-ident> 'get-ordinal
	      (lambda (self) (elm-get self 'ordinal)))
(method-make! <source-ident> 'set-ordinal!
	      (lambda (self newval) (elm-set! self 'ordinal newval)))
(define (obj-ordinal obj) (send obj 'get-ordinal))
(define (obj-set-ordinal! obj ordinal) (send obj 'set-ordinal! ordinal))

; Return a boolean indicating if X is a <source-ident>.

(define (source-ident? x) (class-instance? <source-ident> x))

; Parsing utilities

;;; A parsing/processing context, used to give better error messages.
;;; LOCATION must be an object created with make-location.

(define <context>
  (class-make '<context> nil
	      '(
		;; Location of the object being processed,
		;; or #f if unknown (or there is none).
		(location . #f)
		;; Error message prefix or #f if there is none.
		(prefix . #f)
		)
	      nil)
)

; Accessors.

(define-getters <context> context (location prefix))

; Create a <context> object that is just a prefix.

(define (make-prefix-context prefix)
  (make <context> #f prefix)
)

; Create a <context> object that (current-reader-location) with PREFIX.

(define (make-current-context prefix)
  (make <context> (current-reader-location) prefix)
)

; Create a <context> object from <source-ident> object OBJ.

(define (make-obj-context obj prefix)
  (make <context> (obj-location obj) prefix)
)

; Create a new context from CONTEXT with TEXT appended to the prefix.

(define (context-append context text)
  (make <context> (context-location context)
	(string-append (context-prefix context) text))
)

; Create a new context from CONTEXT with NAME appended to the prefix.

(define (context-append-name context name)
  (context-append context (stringsym-append ":" name))
)

; Call this to issue an error message when all you have is a context.
; CONTEXT is a <context> object or #f if there is none.
; INTRO is a general introduction to what cgen was doing.
; ERRMSG is, yes, you guessed it, the error message.
; EXPR is the value that had the error if there is one.

(define (context-error context intro errmsg . expr)
  (apply context-owner-error
	 (cons context
	       (cons #f
		     (cons intro
			   (cons errmsg expr)))))
)

; Call this to issue an error message when you have a context and an
; <ident> or <source-ident> object (we call the "owner").
; CONTEXT is a <context> object or #f if there is none.
; OWNER is an <ident> or <source-ident> object or #f if there is none.
; INTRO is a general introduction to what cgen was doing.
;   If OWNER is non-#f, the text " of <object-name>" is appended.
; ERRMSG is, yes, you guessed it, the error message.
; EXPR is the value that had the error if there is one.

(define (context-owner-error context owner intro errmsg . expr)
  ;; If we don't have a context, look at the owner to try to find one.
  ;; We want to include the source location in the error if we can.
  (if (and (not context)
	   owner
	   (source-ident? owner))
      (set! context (make-obj-context owner #f)))
  (if (not context)
      (set! context (make-prefix-context #f)))

  (let* ((loc (context-location context))
	 (top-sloc (and loc (location-top loc)))
	 (intro (string-append intro
			       (if owner
				   (string-append " of "
						  (obj:str-name owner))
				   "")))
	 (prefix (or (context-prefix context) "Error"))
	 (text (string-append prefix ": " errmsg)))

    (if loc

	(apply error
	       (cons
		(simple-format
		 #f
		 "\n~A:\n@ ~A:\n\n~A: ~A:"
		 intro
		 (location->string loc)
		 (single-location->simple-string top-sloc)
		 text)
		expr))

	(apply error
	       (cons
		(simple-format
		 #f
		 "\n~A:\n~A:"
		 intro
		 text)
		expr))))
)

; Parse an object name.
; NAME is either a symbol or a list of symbols which are concatenated
; together.  Each element can in turn be a list of symbols, and so on.
; This supports symbol concatenation in the description file without having
; to using string-append or some such.

(define (parse-name context name)
  (string->symbol
   (let parse ((name name))
     (cond
      ((symbol? name) (symbol->string name))
      ((string? name) name)
      ((number? name) (number->string name))
      ((list? name) (string-map parse name))
      (else (parse-error context "improper name" name)))))
)

; Parse an object comment.
; COMMENT is either a string or a list of strings, each element of which may
; in turn be a list of strings.

(define (parse-comment context comment)
  (cond ((string? comment) comment)
	((symbol? comment) (symbol->string comment))
	((number? comment) (number->string comment))
	((list? comment)
	 (string-map (lambda (elm) (parse-comment context elm)) comment))
	(else (parse-error context "improper comment" comment)))
)

; Parse a symbol.

(define (parse-symbol context value)
  (if (and (not (symbol? value)) (not (string? value)))
      (parse-error context "not a symbol or string" value))
  (->symbol value)
)

; Parse a string.

(define (parse-string context value)
  (if (and (not (symbol? value)) (not (string? value)))
      (parse-error context "not a string or symbol" value))
  (->string value)
)

; Parse a number.
; VALID-VALUES is a list of numbers and (min . max) pairs.

(define (parse-number context value . valid-values)
  (if (not (number? value))
      (parse-error context "not a number" value))
  (if (any-true? (map (lambda (test)
			(if (pair? test)
			    (and (>= value (car test))
				 (<= value (cdr test)))
			    (= value test)))
		      valid-values))
      value
      (parse-error context "invalid number" value valid-values))
)

; Parse a boolean value

(define (parse-boolean context value)
  (if (boolean? value)
      value
      (parse-error context "not a boolean (#f/#t)" value))
)

; Parse a list of handlers.
; Each entry is (symbol "string").
; These map function to a handler for it.
; The meaning is up to the application but generally the handler is a
; C/C++ function name.
; ALLOWED is a list valid values for the symbol or #f if anything is allowed.
; The result is handlers unchanged.

(define (parse-handlers context allowed handlers)
  (if (not (list? handlers))
      (parse-error context "bad handler spec" handlers))
  (for-each (lambda (arg)
	      (if (not (list-elements-ok? arg (list symbol? string?)))
		  (parse-error context "bad handler spec" arg))
	      (if (and allowed (not (memq (car arg) allowed)))
		  (parse-error context "unknown handler type" (car arg))))
	    handlers)
  handlers
)

; Return a boolean indicating if X is a keyword.
; This also handles symbols named :foo because Guile doesn't stablely support
; :keywords (how does one enable :keywords? read-options doesn't appear to
; work).

(define (keyword-list? x)
  (and (list? x)
       (not (null? x))
       (or (keyword? (car x))
	   (and (symbol? (car x))
		(char=? (string-ref (symbol->string (car x)) 0) #\:))))
)

; Convert a list like (#:key1 val1 #:key2 val2 ...) to
; ((#:key1 val1) (#:key2 val2) ...).
; Missing values are specified with an empty list.
; This also supports (:sym1 val1 ...) because Guile doesn't stablely support
; :keywords (#:keywords work, but #:foo shouldn't appear in the description
; language).

(define (keyword-list->arg-list kl)
  ; Scan KL backwards, building up each element as we go.
  (let loop ((result nil) (current nil) (rkl (reverse kl)))
    (cond ((null? rkl)
	   result)
	  ((keyword? (car rkl))
	   (loop (acons (keyword->symbol (car rkl)) current result)
		 nil
		 (cdr rkl)))
	  ((and (symbol? (car rkl))
		(char=? (string-ref (symbol->string (car rkl)) 0) #\:))
	   (loop (acons (string->symbol
			 (substring (car rkl) 1 (string-length (car rkl))))
			current result)
		 nil
		 (cdr rkl)))
	  (else
	   (loop result
		 (cons (car rkl) current)
		 (cdr rkl)))))
)

; Signal an error if the argument name is not a symbol.
; This is done by each of the argument validation routines so the caller
; doesn't need to make two calls.

(define (arg-list-validate-name context arg-spec)
  (if (null? arg-spec)
      (parse-error context "empty argument spec" arg-spec))
  (if (not (symbol? (car arg-spec)))
      (parse-error context "argument name not a symbol" arg-spec))
  *UNSPECIFIED*
)

; Signal a parse error if an argument was specified with a value.
; ARG-SPEC is (name value).

(define (arg-list-check-no-args context arg-spec)
  (arg-list-validate-name context arg-spec)
  (if (not (null? (cdr arg-spec)))
      (parse-error context (string-append (car arg-spec)
					  " takes zero arguments")))
  *UNSPECIFIED*
)

; Validate and return a symbol argument.
; ARG-SPEC is (name value).

(define (arg-list-symbol-arg context arg-spec)
  (arg-list-validate-name context arg-spec)
  (if (or (!= (length (cdr arg-spec)) 1)
	  (not (symbol? (cadr arg-spec))))
      (parse-error context (string-append (car arg-spec)
					  ": argument not a symbol")))
  (cadr arg-spec)
)

; Sanitization

; Sanitization is handled via attributes.  Anything that must be sanitized
; has a `sanitize' attribute with the value being the keyword to sanitize on.
; Ideally most, if not all, of the guts of the generated sanitization is here.

; Utility to simplify expression in .cpu file.
; Usage: (sanitize keyword entry-type entry-name1 [entry-name2 ...])
; Enum attribute `(sanitize keyword)' is added to the entry.
; It's written this way so Hobbit can handle it.

(define (sanitize keyword entry-type . entry-names)
  (for-each (lambda (entry-name)
	      (let ((entry #f))
		(case entry-type
		  ((attr) (set! entry (current-attr-lookup entry-name)))
		  ((enum) (set! entry (current-enum-lookup entry-name)))
		  ((isa) (set! entry (current-isa-lookup entry-name)))
		  ((cpu) (set! entry (current-cpu-lookup entry-name)))
		  ((mach) (set! entry (current-mach-lookup entry-name)))
		  ((model) (set! entry (current-model-lookup entry-name)))
		  ((ifield) (set! entry (current-ifld-lookup entry-name)))
		  ((hardware) (set! entry (current-hw-lookup entry-name)))
		  ((operand) (set! entry (current-op-lookup entry-name)))
		  ((insn) (set! entry (current-insn-lookup entry-name)))
		  ((macro-insn) (set! entry (current-minsn-lookup entry-name)))
		  (else (parse-error (make-prefix-context "sanitize")
				     "unknown entry type" entry-type)))

		; ENTRY is #f in the case where the element was discarded
		; because its mach wasn't selected.  But in the case where
		; we're keeping everything, ensure ENTRY is not #f to
		; catch spelling errors.

		(if entry

		    (begin
		      (obj-cons-attr! entry (enum-attr-make 'sanitize keyword))
		      ; Propagate the sanitize attribute to class members
		      ; as necessary.
		      (case entry-type
			((hardware)
			 (if (hw-indices entry)
			     (obj-cons-attr! (hw-indices entry)
					     (enum-attr-make 'sanitize
							     keyword)))
			 (if (hw-values entry)
			     (obj-cons-attr! (hw-values entry)
					     (enum-attr-make 'sanitize
							     keyword))))
			))

		    (if (and (eq? APPLICATION 'OPCODES) (keep-all?))
			(parse-error (make-prefix-context "sanitize")
				     (string-append "unknown " entry-type)
				     entry-name)))))
	    entry-names)

  #f ; caller eval's our result, so return a no-op
)

; Return TEXT sanitized with KEYWORD.
; TEXT must exist on a line (or lines) by itself.
; i.e. it is assumed that it begins at column 1 and ends with a newline.
; If KEYWORD is #f, no sanitization is generated.

(define (gen-sanitize keyword text)
  (cond ((null? text) "")
	((pair? text) ; pair? -> cheap list?
	 (if (and keyword include-sanitize-marker?)
	     (string-list
	      ; split string to avoid removal
	      "/* start-"
	      "sanitize-" keyword " */\n"
	      text
	      "/* end-"
	      "sanitize-" keyword " */\n")
	     text))
	(else
	 (if (= (string-length text) 0)
	     ""
	     (if (and keyword include-sanitize-marker?)
		 (string-append
		  ; split string to avoid removal
		  "/* start-"
		  "sanitize-" keyword " */\n"
		  text
		  "/* end-"
		  "sanitize-" keyword " */\n")
		 text))))
)

; Return TEXT sanitized with OBJ's sanitization, if it has any.
; OBJ may be #f.

(define (gen-obj-sanitize obj text)
  (if obj
      (let ((san (obj-attr-value obj 'sanitize)))
	(gen-sanitize (if (or (not san) (eq? san 'none)) #f san)
		      text))
      (gen-sanitize #f text))
)

; Cover procs to handle generation of object declarations and definitions.
; All object output should be routed through gen-decl and gen-defn.

; Send the gen-decl message to OBJ, and sanitize the output if necessary.

(define (gen-decl obj)
  (logit 3 "Generating decl for "
	 (cond ((method-present? obj 'get-name) (send obj 'get-name))
	       ((elm-present? obj 'name) (elm-get obj 'name))
	       (else "unknown"))
	 " ...\n")
  (cond ((and (method-present? obj 'gen-decl) (not (has-attr? obj 'META)))
	 (gen-obj-sanitize obj (send obj 'gen-decl)))
	(else ""))
)

; Send the gen-defn message to OBJ, and sanitize the output if necessary.

(define (gen-defn obj)
  (logit 3 "Generating defn for "
	 (cond ((method-present? obj 'get-name) (send obj 'get-name))
	       ((elm-present? obj 'name) (elm-xget obj 'name))
	       (else "unknown"))
	 " ...\n")
  (cond ((and (method-present? obj 'gen-defn) (not (has-attr? obj 'META)))
	 (gen-obj-sanitize obj (send obj 'gen-defn)))
	(else ""))
)

; Attributes

; Return the C/C++ type to use to hold a value for attribute ATTR.

(define (gen-attr-type attr)
  (if (string=? (string-downcase (gen-sym attr)) "isa")
      "CGEN_BITSET"
      (case (attr-kind attr)
	((boolean) "int")
	((bitset)  "unsigned int")
	((integer) "int")
	((enum)    (string-append "enum " (string-downcase (gen-sym attr)) "_attr"))
	))
)

; Return C macros for accessing an object's attributes ATTRS.
; PREFIX is one of "cgen_ifld", "cgen_hw", "cgen_operand", "cgen_insn".
; ATTRS is an alist of attribute values.  The value is unimportant except that
; it is used to determine bool/non-bool.
; Non-bools need to be separated from bools as they're each recorded
; differently.  Non-bools are recorded in an int for each.  All bools are
; combined into one int to save space.
; ??? We assume there is at least one bool.

(define (-gen-attr-accessors prefix attrs)
  (string-append
   "/* " prefix " attribute accessor macros.  */\n"
   (string-map (lambda (attr)
		 (string-append
		  "#define CGEN_ATTR_"
		  (string-upcase prefix)
		  "_"
		  (string-upcase (gen-sym attr))
		  "_VALUE(attrs) "
		  (if (bool-attr? attr)
		      (string-append
		       "(((attrs)->bool & (1 << "
		       (string-upcase prefix)
		       "_"
		       (string-upcase (gen-sym attr))
		       ")) != 0)")
		      (string-append
		       "((attrs)->nonbool["
		       (string-upcase prefix)
		       "_"
		       (string-upcase (gen-sym attr))
		       "-"
		       (string-upcase prefix)
		       "_START_NBOOLS-1]."
		       (case (attr-kind attr)
			 ((bitset)
			  (if (string=? (string-downcase (gen-sym attr)) "isa")
			      ""
			      "non"))
			 (else "non"))
		       "bitset)"))
		  "\n"))
	       attrs)
   "\n")
)
; Return C code to declare an enum of attributes ATTRS.
; PREFIX is one of "cgen_ifld", "cgen_hw", "cgen_operand", "cgen_insn".
; ATTRS is an alist of attribute values.  The value is unimportant except that
; it is used to determine bool/non-bool.
; Non-bools need to be separated from bools as they're each recorded
; differently.  Non-bools are recorded in an int for each.  All bools are
; combined into one int to save space.
; ??? We assume there is at least one bool.

(define (gen-attr-enum-decl prefix attrs)
  (string-append
   (gen-enum-decl (string-append prefix "_attr")
		  (string-append prefix " attrs")
		  (string-append prefix "_")
		  (attr-list-enum-list attrs))
   "/* Number of non-boolean elements in " prefix "_attr.  */\n"
   "#define " (string-upcase prefix) "_NBOOL_ATTRS "
   "(" (string-upcase prefix) "_END_NBOOLS - "
   (string-upcase prefix) "_START_NBOOLS - 1)\n"
   "\n")
)

; Return name of symbol ATTR-NAME.
; PREFIX is the prefix arg to gen-attr-enum-decl.

(define (gen-attr-name prefix attr-name)
  (string-upcase (gen-c-symbol (string-append prefix "_"
					      (symbol->string attr-name))))
)

; Normal gen-mask argument to gen-bool-attrs.
; Returns "(1<< PREFIX_NAME)" where PREFIX is from atlist-prefix and
; NAME is the name of the attribute.
; ??? This used to return PREFIX_NAME-CGEN_ATTR_BOOL_OFFSET.
; The tradeoff is simplicity vs perceived maximum number of boolean attributes
; needed.  In the end the maximum number needn't be fixed, and the simplicity
; of the current way is good.

(define (gen-attr-mask prefix name)
  (string-append "(1<<" (gen-attr-name prefix name) ")")
)

; Return C expression of bitmasks of boolean attributes in ATTRS.
; ATTRS is an <attr-list> object, it need not be pre-sorted.
; GEN-MASK is a procedure that returns the C code of the mask.

(define (gen-bool-attrs attrs gen-mask)
  (let loop ((result "0")
	     (alist (attr-remove-meta-attrs-alist
		     (attr-nub (atlist-attrs attrs)))))
    (cond ((null? alist) result)
	  ((and (boolean? (cdar alist)) (cdar alist))
	   (loop (string-append result
				; `|' is used here instead of `+' so we don't
				; have to care about duplicates.
				"|" (gen-mask (atlist-prefix attrs)
					      (caar alist)))
		 (cdr alist)))
	  (else (loop result (cdr alist)))))
)

; Return the C definition of OBJ's attributes.
; TYPE is one of 'ifld, 'hw, 'operand, 'insn.
; [Other objects have attributes but these are the only ones we currently
; emit definitions for.]
; OBJ is any object that supports the 'get-atlist message.
; ALL-ATTRS is an ordered alist of all attributes.
; "ordered" means all the non-boolean attributes are at the front and
; duplicate entries have been removed.
; GEN-MASK is the gen-mask arg to gen-bool-attrs.

(define (gen-obj-attr-defn type obj all-attrs num-non-bools gen-mask)
  (let* ((attrs (obj-atlist obj))
	 (non-bools (attr-non-bool-attrs (atlist-attrs attrs)))
	 (all-non-bools (list-take num-non-bools all-attrs)))
  (string-append
   "{ "
   (gen-bool-attrs attrs gen-mask)
   ", {"
   ; For the boolean case, we can (currently) get away with only specifying
   ; the attributes that are used since they all fit in one int and the
   ; default is currently always #f (and won't be changed without good
   ; reason).  In the non-boolean case order is important since each value
   ; has a specific spot in an array, all of them must be specified.
   (if (null? all-non-bools)
       " 0"
       (string-drop1 ; drop the leading ","
	(string-map (lambda (attr)
		      (let ((val (or (assq-ref non-bools (obj:name attr))
				     (attr-default attr))))
			; FIXME: Are we missing attr-prefix here?
			(string-append ", "
				       (send attr 'gen-value-for-defn val))))
		    all-non-bools)))
   " } }"
   ))
)

; Return the C definition of the terminating entry of an object's attributes.
; ALL-ATTRS is an ordered alist of all attributes.
; "ordered" means all the non-boolean attributes are at the front and
; duplicate entries have been removed.

(define (gen-obj-attr-end-defn all-attrs num-non-bools)
  (let ((all-non-bools (list-take num-non-bools all-attrs)))
    (string-append
     "{ 0, {"
     (if (null? all-non-bools)
	 " { 0, 0 }"
	 (string-drop1 ; drop the leading ","
	  (string-map (lambda (attr)
			(let ((val (attr-default attr)))
					; FIXME: Are we missing attr-prefix here?
			  (string-append ", "
					 (send attr 'gen-value-for-defn val))))
		      all-non-bools)))
     " } }"
     ))
)
; Return a boolean indicating if ATLIST indicates a CTI insn.

(define (atlist-cti? atlist)
  (or (atlist-has-attr? atlist 'UNCOND-CTI)
      (atlist-has-attr? atlist 'COND-CTI))
)

; Misc. gen-* procs

; Return name of obj as a C symbol.

(define (gen-sym obj) (gen-c-symbol (obj:name obj)))

; Return the name of the selected cpu family.
; An error is signalled if more than one has been selected.

(define (gen-cpu-name)
  ; FIXME: error checking
  (gen-sym (current-cpu))
)

; Return HAVE_CPU_<CPU>.

(define (gen-have-cpu cpu)
  (string-append "HAVE_CPU_"
		 (string-upcase (gen-sym cpu)))
)

; Return the bfd mach name for MACH.

(define (gen-mach-bfd-name mach)
  (string-append "bfd_mach_" (gen-c-symbol (mach-bfd-name mach)))
)

; Return definition of C macro to get the value of SYM.

(define (gen-get-macro sym index-args expr)
  (string-append
   "#define GET_" (string-upcase sym) "(" index-args ") " expr "\n")
)

; Return definition of C macro to set the value of SYM.

(define (gen-set-macro sym index-args lvalue)
  (string-append
   "#define SET_" (string-upcase sym)
   "(" index-args
   (if (equal? index-args "") "" ", ")
   "x) (" lvalue " = (x))\n")
)

; Return definition of C macro to set the value of SYM, version 2.
; EXPR is one or more C statements *without* proper \newline handling,
; we prepend \ to each line.

(define (gen-set-macro2 sym index-args newval-arg expr)
  (string-append
   "#define SET_" (string-upcase sym)
   "(" index-args
   (if (equal? index-args "") "" ", ")
   newval-arg ") \\\n"
   "do { \\\n"
   (backslash "\n" expr)
   ";} while (0)\n")
)

; Misc. object utilities.

; Sort a list of objects with get-name methods alphabetically.

(define (alpha-sort-obj-list l)
  (sort l
	(lambda (o1 o2)
	  (symbol<? (obj:name o1) (obj:name o2))))
)

; Called before loading the .cpu file to initialize.

(define (utils-init!)
  (reader-add-command! 'sanitize
		       "\
Mark an entry as being sanitized.
"
		       nil '(keyword entry-type . entry-names) sanitize)

  *UNSPECIFIED*
)

; Return a pair of definitions for a C macro that concatenates its
; argument symbols.  The definitions are conditional on ANSI C
; semantics: one contains ANSI concat operators (##), and the other
; uses the empty-comment trick (/**/).  We must do this, rather than
; use CONCATn(...) as defined in include/symcat.h, in order to avoid
; spuriously expanding our macro's args.

(define (gen-define-with-symcat head . args)
  (string-append
   "\
#if defined (__STDC__) || defined (ALMOST_STDC) || defined (HAVE_STRINGIZE)
#define "
   head (string-map (lambda (elm) (string-append "##" elm)) args)
   "
#else
#define "
   head (string-map (lambda (elm) (string-append "/**/" elm)) args)
   "
#endif
"
   )
)
