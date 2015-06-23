; Attributes.
; Copyright (C) 2000, 2003, 2005, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; There are 4 kinds of attributes: boolean, integer, enum, and bitset.  Boolean
; attributes are really enum attributes with two possible values, but they
; occur frequently enough that they are special cased.
;
; All objects that use attributes must have two methods:
; - 'get-atlist - returns the object's attr-list
; - 'set-atlist! - set the object's attr-list
;
; In .cpu files, attribute lists are associative lists of (NAME VALUE).
; Boolean attributes are specified as (NAME #t) or (NAME #f),
; but for convenience ATTR and !ATTR are also supported.
; integer/enum attrs are specified as (ATTR value).
; string attrs are specified as (ATTR value).
; Bitset attrs are specified as (ATTR val1,val2,val3).
; In all cases the value needn't be constant, and can be an expression,
; though expressions are currently only supported for META-attributes
; (attributes that don't appear in any generated code).
;
; Example:
; (FOO1 !FOO2 (BAR 3) (FOO3 X) (MACH sparc,sparclite))
;
; ??? Implementation of expressions is being postponed as long
; as possible, avoiding adding complications for complication's sake, and
; because I'm not completely sure how I want to do them.
; The syntax for an expression value is (ATTR (rtx-func ...)).
;
; ??? May wish to allow a bitset attribute like (ATTR val1,!val2), where `!'
; means to turn off that particular bit (or bits if val2 refers to several).
;
; ??? May wish to allow specifying enum attributes by only having to
; specify the value (move names into "enum space" or some such).

; An attr-list (or "atlist") is a collection of attributes.
; Attributes are stored as an associative list.
; There is possible confusion between "alist" (associative-list) and
; "atlist" (attribute-list) but in practice I haven't had a problem.
; ??? May wish to change this to a list of objects, as the alist doesn't carry
; enough info.  However the alist is simple and fast.

(define <attr-list> (class-make '<attr-list> nil '(prefix attrs) nil))

(define atlist-prefix (elm-make-getter <attr-list> 'prefix))
(define atlist-attrs (elm-make-getter <attr-list> 'attrs))

(define (atlist? x) (class-instance? <attr-list> x))

; An empty attribute-list.

(define atlist-empty (make <attr-list> "" nil))

; The attribute baseclass.
; The attributes of <ident> are the set of attributes for this attribute
; [meaning attributes themselves can have attributes].
; [Ya, that's clumsily written.  I left it that way for fun.]
; An odd notion that is of some use.  It's current raison d'etre is to
; support sanitization of attributes [which is implemented with the
; `sanitize' attribute].

(define <attribute>
  (class-make '<attribute>
	      '(<ident>)
	      '(
		; List of object types this attribute is for.
		; Possible element values are:
		; attr, enum, cpu, mach, model, ifield, hardware, operand,
		; insn
		; A value of #f means the attribute is for everything.
		for
		)
	      nil)
)

; Accessors.

(define atlist-for (elm-make-getter <attribute> 'for))

; A class for each type of attribute.

; `values' exists for boolean-attribute to simplify the code, it's ignored.
; Ditto for `default'.  The default for boolean-attribute is always #f.

(define <boolean-attribute>
  (class-make '<boolean-attribute>
	      '(<attribute>)
	      '(default values)
	      nil)
)

; VALUES is ignored for string-attribute.

(define <string-attribute>
  (class-make '<string-attribute>
	      '(<attribute>)
	      '(default values)
	      nil)
)

; For bitset attributes VALUES is a list of
; (symbol bit-number-or-#f attr-list comment-or-#f),
; one for each bit.
; If bit-number is #f (unspecified), cgen will choose.
; Int's are used to record the bitset in the generated code so there's a limit
; of 32 elements, though there's nothing inherent in the description language
; that precludes removing the limit.
; NOTE: While one might want to record each element as an object, there's
; currently no need for the added complexity.

(define <bitset-attribute>
  (class-make '<bitset-attribute>
	      '(<attribute>)
	      '(default values)
	      nil)
)

; For integer attributes VALUES is a list of (int),
; one for each possible value,
; or the empty list of all values are permissible.
; Note that each element is itself a list.  This is for consistency.

(define <integer-attribute>
  (class-make '<integer-attribute>
	      '(<attribute>)
	      '(default values)
	      nil)
)

; For enum attributes VALUES is a list of
; (symbol enum-value-or-#f attr-list comment-or-#f),
; one for each possible.
; If enum-value is #f (unspecified) cgen will apply the standard rule for
; assigning enum values.
; NOTE: While one might want to record each element as an object, there's
; currently no need for the added complexity.

(define <enum-attribute>
  (class-make '<enum-attribute>
	      '(<attribute>)
	      '(default values)
	      nil)
)

; Return a boolean indicating if X is a <boolean-attribute> object.

(define (bool-attr? x) (class-instance? <boolean-attribute> x))

; Return a boolean indicating if X is a <bitset-attribute> object.

(define (bitset-attr? x) (class-instance? <bitset-attribute> x))

; Return a symbol indicating the kind of attribute ATTR is.
; The result is one of boolean,integer,enum,bitset or string.

(define (attr-kind attr)
  (case (object-class-name attr)
    ((<boolean-attribute>) 'boolean)
    ((<string-attribute>)  'string)
    ((<integer-attribute>) 'integer)
    ((<enum-attribute>)    'enum)
    ((<bitset-attribute>)  'bitset)
    (else (error "attr-kind: internal error, not an attribute class"
		 (object-class-name attr))))
)

; Accessors.

(define (attr-default attr) (elm-xget attr 'default))
(define (attr-values attr) (elm-xget attr 'values))

; Create an attribute.
; Attributes are stored in attribute lists using the actual value
; rather than an object containing the value, so we only have to cons
; NAME and VALUE rather than building some object.  This is for simplicity
; and speed.  We try to incrementally complicate things, only as necessary.

; VALUE must be #f or #t.

(define (bool-attr-make name value) (cons name value))

; VALUES must be a comma separated list of symbols
; (e.g. val1,val2 not (val1 val2)).
; FIXME: require values to be a string (i.e. "val1,val2")

(define (bitset-attr-make name values) (cons name values))

; VALUE must be a number (or maybe a symbol).

(define (int-attr-make name value) (cons name value))

; VALUE must be a symbol.

(define (enum-attr-make name value) (cons name value))

;;; Return a procedure to parse an attribute.
;;; RIGHT-TYPE? is a procedure that verifies the value is the right type.
;;; MESSAGE is printed if there is an error.

(define (-parse-simple-attribute right-type? message)
  (lambda (self context val)
    (if (and (not (null? val))
	     (right-type? (car val))
	     (null? (cdr val)))
	(cons (obj:name self) (car val))
	(parse-error context message (cons (obj:name self) val))))
)

; A boolean attribute's value is either #t or #f.

(method-make!
 <boolean-attribute> 'parse-value
 (-parse-simple-attribute boolean? "boolean attribute not one of #f/#t")
)

(method-make!
 <string-attribute> 'parse-value
 (-parse-simple-attribute string? "invalid argument to string attribute"))

; A bitset attribute's value is a comma separated list of elements.
; We don't validate the values.  In the case of the MACH attribute,
; there's no current mechanism to create it after all define-mach's have
; been read in.
; ??? Need to decide whether all define-mach's must appear before any
; define-insn's.  It would be nice to be able to spread an architecture's
; description over several .cpu files.
; ??? On the other hand, all machs are specified in define-arch.
; Perhaps creation of builtins could be defered until then.

(method-make!
 <bitset-attribute> 'parse-value
 (-parse-simple-attribute (lambda (x) (or (symbol? x) (string? x)))
			  "improper bitset attribute")
)

; An integer attribute's value is a number
; (or maybe a symbol representing that value).

(method-make!
 <integer-attribute> 'parse-value
 (-parse-simple-attribute (lambda (x) (or (number? x) (symbol? x)))
			  "improper integer attribute")
)

; An enum attribute's value is a symbol representing that value.

(method-make!
 <enum-attribute> 'parse-value
 (-parse-simple-attribute (lambda (x) (or (symbol? x) (string? x)))
			  "improper enum attribute")
)

; Parse a boolean attribute's value definition.

(method-make!
 <boolean-attribute> 'parse-value-def
 (lambda (self context values)
   (if (equal? values '(#f #t))
       values
       (parse-error context "boolean value list must be (#f #t)" values)))
)

; Ignore values for strings.  We can't do any error checking since
; the default value is (#f #t).

(method-make!
 <string-attribute> 'parse-value-def
 (lambda (self context values) #f)
)

; Parse a bitset attribute's value definition.
; FIXME: treated as enum?

(method-make!
 <bitset-attribute> 'parse-value-def
 (lambda (self context values)
   (parse-enum-vals context "" values))
)

; Parse an integer attribute's value definition.
; VALUES may be #f which means any value is ok.

(method-make!
 <integer-attribute> 'parse-value-def
 (lambda (self context values)
   (if values
       (for-each (lambda (val)
		   (if (or (not (list? val))
			   (not (number? (car val))))
		       (parse-error context
				    "invalid element in integer attribute list"
				    val)))
		 values))
   values)
)

; Parse an enum attribute's value definition.
; See parse-enum-vals for more info.

(method-make!
 <enum-attribute> 'parse-value-def
 (lambda (self context values)
   (parse-enum-vals context "" values))
)

; Make an attribute list object from a list of name/value pairs.

(define (atlist-make prefix . attrs) (make <attr-list> prefix attrs))

; Parse an attribute definition.
; This is the main routine for building an attribute object from a
; description in the .cpu file.
; All arguments are in raw (non-evaluated) form.
; TYPE-CLASS is the class of the object to create.
; i.e. one of <{boolean,bitset,integer,enum,string}-attribute>.
; If DEFAULT is #f, use the first value.
; ??? Allowable values for integer attributes is wip.

(define (-attr-parse context type-class name comment attrs for default values)
  (logit 2 "Processing attribute " name " ...\n")

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name))
	 (result (new type-class))
	 (parsed-values (send result 'parse-value-def context values)))

    (elm-xset! result 'name name)
    (elm-xset! result 'comment (parse-comment context comment))
    (elm-xset! result 'attrs (atlist-parse context attrs ""))
    (elm-xset! result 'for for)
    ; Set the default.
    (case (class-name type-class)
      ((<boolean-attribute>)
       (if (and (not (memq default '(#f #t)))
		(not (rtx? default)))
	   (parse-error context "invalid default" default))
       (elm-xset! result 'default default))
      ((<string-attribute>)
       (let ((default (or default "")))
	 (if (and (not (string? default))
		  (not (rtx? default)))
	     (parse-error context "invalid default" default))
	 (elm-xset! result 'default default)))
      ((<integer-attribute>)
       (let ((default (if default default (if (null? values) 0 (car values)))))
	 (if (and (not (integer? default))
		  (not (rtx? default)))
	     (parse-error context "invalid default" default))
	 (elm-xset! result 'default default)))
      ((<bitset-attribute> <enum-attribute>)
       (let ((default (if default default (caar parsed-values))))
	 (if (and (not (assq default parsed-values))
		  (not (rtx? default)))
	     (parse-error context "invalid default" default))
	 (elm-xset! result 'default default))))
    (elm-xset! result 'values parsed-values)

    result)
)

; Read an attribute description
; This is the main routine for analyzing attributes in the .cpu file.
; CONTEXT is a <context> object for error messages.
; ARG-LIST is an associative list of field name and field value.
; -attr-parse is invoked to create the attribute object.

(define (-attr-read context . arg-list)
  (let (
	(type-class 'not-set) ; attribute type
	(name #f)
	(comment "")
	(attrs nil)
	(for #f) ; assume for everything
	(default #f) ; #f indicates "not set"
	(values #f) ; #f indicates "not set"
	)

    ; Loop over each element in ARG-LIST, recording what's found.
    (let loop ((arg-list arg-list))
      (if (null? arg-list)
	  nil
	  (let ((arg (car arg-list))
		(elm-name (caar arg-list)))
	    (case elm-name
	      ((type) (set! type-class (case (cadr arg)
					((boolean) <boolean-attribute>)
					((string) <string-attribute>)
					((bitset) <bitset-attribute>)
					((integer) <integer-attribute>)
					((enum) <enum-attribute>)
					(else (parse-error
					       context
					       "invalid attribute type"
					       (cadr arg))))))
	      ((name) (set! name (cadr arg)))
	      ((comment) (set! comment (cadr arg)))
	      ((attrs) (set! attrs (cdr arg)))
	      ((for) (set! for (cdr arg)))
	      ((default) (set! default (cadr arg)))
	      ((values) (set! values (cdr arg)))
	      (else (parse-error context "invalid attribute arg" arg)))
	    (loop (cdr arg-list)))))

    ; Must have type now.
    (if (eq? type-class 'not-set)
	(parse-error context "type not specified") arg-list)
    ; Establish proper defaults now that we know the type.
    (case (class-name type-class)
      ((<boolean-attribute>)
       (if (eq? default #f)
	   (set! default #f)) ; really a nop, but for consistency
       (if (eq? values #f)
	   (set! values '(#f #t))))
      ((bitset-attribute>) ;; FIXME
       (if (eq? default #f)
	   (parse-error context "bitset-attribute default not specified"
			arg-list))
       (if (eq? values #f)
	   (parse-error context "bitset-attribute values not specified"
			arg-list)))
      ((integer-attribute>) ;; FIXME
       (if (eq? default #f)
	   (set! default 0))
       (if (eq? values #f)
	   (set! values #f))) ; really a nop, but for consistency
      ((enum-attribute>) ;; FIXME
       (if (eq? default #f)
	   (parse-error context "enum-attribute default not specified"
			arg-list))
       (if (eq? values #f)
	   (parse-error context "bitset-attribute values not specified"
			arg-list)))
      )

    ; Now that we've identified the elements, build the object.
    (-attr-parse context type-class name comment attrs for default values))
)

; Main routines for defining attributes in .cpu files.

(define define-attr
  (lambda arg-list
    (let ((a (apply -attr-read (cons (make-current-context "define-attr")
				     arg-list))))
      (current-attr-add! a)
      a))
)

; Query routines.

; Lookup ATTR-NAME in ATTR-LIST.
; The result is the object or #f if not found.

(define (attr-lookup attr-name attr-list)
  (object-assq attr-name attr-list)
)

; Return a boolean indicating if boolean attribute ATTR is "true" in
; attribute alist ALIST.
; Note that if the attribute isn't present, it is defined to be #f.

(method-make!
 <attr-list> 'has-attr?
 (lambda (self attr)
   (let ((a (assq attr (elm-get self 'attrs))))
     (cond ((not a) a)
	   ((boolean? (cdr a)) (cdr a))
	   (else (error "Not a boolean attribute:" attr)))))
)

(define (atlist-has-attr? atlist attr)
  (send atlist 'has-attr? attr)
)

; Return a boolean indicating if attribute ATTR is present in
; attribute alist ALIST.

(method-make!
 <attr-list> 'attr-present?
 (lambda (self attr)
   (->bool (assq attr (elm-get self 'attrs))))
)

(define (atlist-attr-present? atlist attr)
  (send atlist 'attr-present? attr)
)

; Expand attribute value ATVAL, which is an rtx expression.
; OWNER is the containing object or #f if there is none.
; OWNER is needed if an attribute is defined in terms of other attributes.
; If it's #f obviously ATVAL can't be defined in terms of others.

(define (-attr-eval atval owner)
  (let* ((estate (estate-make-for-eval #f owner))
	 (expr (rtx-compile #f (rtx-simplify #f owner atval nil) nil))
	 (value (rtx-eval-with-estate expr 'DFLT estate)))
    (cond ((symbol? value) value)
	  ((number? value) value)
	  (error "-attr-eval: internal error, unsupported result:" value)))
)

; Return value of ATTR in attribute alist ALIST.
; If not present, return the default value.
; OWNER is the containing object or #f if there is none.

(define (attr-value alist attr owner)
  (let ((a (assq-ref alist attr)))
    (if a
	(if (pair? a) ; pair? -> cheap non-null-list?
	    (-attr-eval a owner)
	    a)
	(attr-lookup-default attr owner)))
)

; Return the value of ATTR in ATLIST.
; OWNER is the containing object or #f if there is none.

(define (atlist-attr-value atlist attr owner)
  (attr-value (atlist-attrs atlist) attr owner)
)

; Same as atlist-attr-value but return nil if attribute not present.

(define (atlist-attr-value-no-default atlist attr owner)
  (let ((a (assq-ref (atlist-attrs atlist) attr)))
    (if a
	(if (pair? a) ; pair? -> cheap non-null-list?
	    (-attr-eval a owner)
	    a)
	nil))
)

; Return the default for attribute A.
; If A isn't a non-boolean attribute, we assume it's a boolean one, and
; return #f (??? for backward's compatibility, to be removed in time).
; OWNER is the containing object or #f if there is none.

(define (attr-lookup-default a owner)
  (let ((at (current-attr-lookup a)))
    (if at
	(if (bool-attr? at)
	    #f
	    (let ((deflt (attr-default at)))
	      (if deflt
		  (if (pair? deflt) ; pair? -> cheap non-null-list?
		      (-attr-eval deflt owner)
		      deflt)
		  ; If no default was provided, use the first value.
		  (caar (attr-values at)))))
	#f))
)

; Return a boolean indicating if X is present in BITSET.
; Bitset values are recorded as val1,val2,....

(define (bitset-attr-member? x bitset)
  (->bool (memq x (bitset-attr->list bitset)))
)

; Routines for accessing attributes in objects.

; Get/set attributes of OBJ.
; OBJ is any object which supports the get-atlist message.

(define (obj-atlist obj)
  (let ((result (send obj 'get-atlist)))
    ; As a speed up, we allow objects to specify an empty attribute list
    ; with #f or (), rather than creating an attr-list object.
    ; ??? There is atlist-empty now which should be used directly.
    (if (or (null? result) (not result))
	atlist-empty
	result))
)

(define (obj-set-atlist! obj attrs) (send obj 'set-atlist! attrs))

; Add attribute ATTR to OBJ.
; The attribute is prepended to the front so it overrides any existing
; definition.

(define (obj-cons-attr! obj attr)
  (obj-set-atlist! obj (atlist-cons attr (obj-atlist obj)))
)

; Add attribute list ATLIST to OBJ.
; Attributes in ATLIST override existing values, so ATLIST is "prepended".

(define (obj-prepend-atlist! obj atlist)
  ; Must have same prefix.
  (assert (equal? (atlist-prefix (obj-atlist obj))
		  (atlist-prefix atlist)))
  (obj-set-atlist! obj (atlist-append atlist (obj-atlist obj)))
)

; Return boolean of whether OBJ has boolean attribute ATTR or not.
; OBJ is any object that supports attributes.

(define (obj-has-attr? obj attr)
  (atlist-has-attr? (obj-atlist obj) attr)
)

; FIXME: for backward compatibility.  Delete in time.
(define has-attr? obj-has-attr?)

; Return a boolean indicating if attribute ATTR is present in OBJ.

(define (obj-attr-present? obj attr)
  (atlist-attr-present? (obj-atlist obj) attr)
)

; Return value of attribute ATTR in OBJ.
; If the attribute isn't present, the default is returned.
; OBJ is any object that supports the get-atlist method.

(define (obj-attr-value obj attr)
  (let ((atlist (obj-atlist obj)))
    (atlist-attr-value atlist attr obj))
)

; Return boolean of whether OBJ has attribute ATTR value VALUE or not.
; OBJ is any object that supports attributes.
; NOTE: The default value of the attribute IS considered.

(define (obj-has-attr-value? obj attr value)
  (let ((a (obj-attr-value obj attr)))
    (eq? a value))
)

; Return boolean of whether OBJ explicitly has attribute ATTR value VALUE
; or not.
; OBJ is any object that supports attributes.
; NOTE: The default value of the attribute IS NOT considered.

(define (obj-has-attr-value-no-default? obj attr value)
  (let* ((atlist (obj-atlist obj))
	 (objs-value (atlist-attr-value-no-default atlist attr obj)))
    (and (not (null? objs-value)) (eq? value objs-value)))
)

; Utilities.

; Convert a bitset value "a,b,c" into a list (a b c).

(define (bitset-attr->list x)
  (map string->symbol (string-cut (->string x) #\,))
)

; Generate a list representing a bit mask of the indices of 'values'
; within 'all-values'. Each element in the resulting list represents a byte.
; Both bits and bytes are indexed from left to right starting at 0
; with 8 bits in a byte.
(define (charmask-bytes values all-values vec-length)
  (logit 3 "charmask-bytes for " values " " all-values "\n")
  (let ((result (make-vector vec-length 0))
	(indices (map (lambda (name)
			(list-ref (map cadr all-values)
				  (element-lookup-index name (map car all-values) 0)))
		      values)))
    (logit 3 "indices: " indices "\n")
    (for-each (lambda (x)
		(let* ((byteno (quotient x 8))
		       (bitno (- 7 (remainder x 8)))
		       (byteval (logior (vector-ref result byteno)
					(ash 1 bitno))))
		  (vector-set! result byteno byteval)))
	      indices)
    (logit 3 "result: " (vector->list result) "\n")
    (vector->list result))
)

; Convert a bitset value into a bit string based on the
; index of each member in values
(define (bitset-attr->charmask value values)
  (let* ((values-names (map car values))
	 (values-values (map cadr values))
	 (vec-length (+ 1 (quotient (apply max values-values) 8))))
    (string-append "{ " (number->string vec-length) ", \""
		   (string-map (lambda (x)
				 (string-append "\\x" (number->hex x)))
			       (charmask-bytes (bitset-attr->list value)
					       values vec-length))
		   "\" }"))
)
; Return the enum of ATTR-NAME for type TYPE.
; TYPE is one of 'ifld, 'hw, 'operand, 'insn.

(define (gen-attr-enum type attr-name)
  (string-upcase (string-append "CGEN_" type "_" (gen-sym attr-name)))
)

; Return a list of enum value definitions for gen-enum-decl.
; Attributes numbers are organized as follows: booleans are numbered 0-31.
; The range is because that's what fits in a portable int.  Unused numbers
; are left unused.  Non-booleans are numbered starting at 32.
; An alternative is start numbering the booleans at 32.  The generated code
; is simpler with the current way (the "- 32" to get back the bit number or
; array index number occurs less often).
;
; Three special values are created:
; END-BOOLS - mark end of boolean attributes
; END-NBOOLS - mark end of non-boolean attributes
; START-NBOOLS - marks the start of the non-boolean attributes
; (needed in case first non-bool is sanytized out).
;
; ATTR-OBJ-LIST is a list of <attribute> objects (always subclassed of course).

(define (attr-list-enum-list attr-obj-list)
  (let ((sorted-attrs (-attr-sort (attr-remove-meta-attrs attr-obj-list))))
    (assert (<= (length (car sorted-attrs)) 32))
    (append!
     (map (lambda (bool-attr)
	    (list (obj:name bool-attr) '-
		  (atlist-attrs (obj-atlist bool-attr))))
	  (car sorted-attrs))
     (list '(END-BOOLS))
     (list '(START-NBOOLS 31))
     (map (lambda (nbool-attr)
	    (list (obj:name nbool-attr) '-
		  (atlist-attrs (obj-atlist nbool-attr))))
	  (cdr sorted-attrs))
     (list '(END-NBOOLS))
     ))
)

; Sort an alist of attributes so non-boolean attributes are at the front.
; This is used to sort a particular object's attributes.
; This is required by the C support code (cgen.h:CGEN_ATTR_VALUE).
; Boolean attributes appear as (NAME . #t/#f), non-boolean ones appear as
; (NAME . VALUE).  Attributes of the same type are sorted by name.

(define (-attr-sort-alist alist)
  (sort alist
	(lambda (a b)
	  ;(display (list a b "\n"))
	  (cond ((and (boolean? (cdr a)) (boolean? (cdr b)))
		 (string<? (symbol->string (car a)) (symbol->string (car b))))
		((boolean? (cdr a)) #f) ; we know b is non-bool here
		((boolean? (cdr b)) #t) ; we know a is non-bool here
		(else (string<? (symbol->string (car a))
				(symbol->string (car b)))))))
)

; Sort ATTR-LIST into two lists: bools and non-bools.
; The car of the result is the bools, the cdr is the non-bools.
; Attributes requiring a fixed index have the INDEX attribute,
; and used for the few special attributes that are refered to by
; architecture independent code.
; For each of non-bools and bools, put attributes with the INDEX attribute
; first.  This is used to sort a list of attributes for output (e.g. define
; the attr enum).
;
; FIXME: Record index number with the INDEX attribute and sort on it.
; At present it's just a boolean.

(define (-attr-sort attr-list)
  (let loop ((fixed-non-bools nil)
	     (non-fixed-non-bools nil)
	     (fixed-bools nil)
	     (non-fixed-bools nil)
	     (attr-list attr-list))
    (cond ((null? attr-list)
	   (cons (append! (reverse! fixed-bools)
			  (reverse! non-fixed-bools))
		 (append! (reverse! fixed-non-bools)
			  (reverse! non-fixed-non-bools))))
	  ((bool-attr? (car attr-list))
	   (if (obj-has-attr? (car attr-list) 'INDEX)
	       (loop fixed-non-bools non-fixed-non-bools
		     (cons (car attr-list) fixed-bools) non-fixed-bools
		     (cdr attr-list))
	       (loop fixed-non-bools non-fixed-non-bools
		     fixed-bools (cons (car attr-list) non-fixed-bools)
		     (cdr attr-list))))
	  (else
	   (if (obj-has-attr? (car attr-list) 'INDEX)
	       (loop (cons (car attr-list) fixed-non-bools) non-fixed-non-bools
		     fixed-bools non-fixed-bools
		     (cdr attr-list))
	       (loop fixed-non-bools (cons (car attr-list) non-fixed-non-bools)
		     fixed-bools non-fixed-bools
		     (cdr attr-list))))))
)

; Return number of non-bools in attributes ATLIST.

(define (attr-count-non-bools atlist)
  (count-true (map (lambda (a) (not (bool-attr? a)))
		   atlist))
)

; Given an alist of attributes, return the non-bools.

(define (attr-non-bool-attrs alist)
  (let loop ((result nil) (alist alist))
    (cond ((null? alist) (reverse! result))
	  ((boolean? (cdar alist)) (loop result (cdr alist)))
	  (else	(loop (cons (car alist) result) (cdr alist)))))
)

; Given an alist of attributes, return the bools.

(define (attr-bool-attrs alist)
  (let loop ((result nil) (alist alist))
    (cond ((null? alist) (reverse! result))
	  ((boolean? (cdar alist))
	   (loop (cons (car alist) result) (cdr alist)))
	  (else	(loop result (cdr alist)))))
)

; Parse an attribute spec.
; CONTEXT is a <context> object or #f if there is none.
; ATTRS is a list of attribute specs (e.g. (FOO !BAR (BAZ 3))).
; The result is the attribute alist.

(define (attr-parse context attrs)
  (if (not (list? attrs))
      (parse-error context "improper attribute list" attrs))
  (let ((alist nil))
    (for-each (lambda (elm)
		(cond ((symbol? elm)
		       ; boolean attribute
		       (if (char=? (string-ref (symbol->string elm) 0) #\!)
			   (set! alist (acons (string->symbol (string-drop1 (symbol->string elm))) #f alist))
			   (set! alist (acons elm #t alist)))
		       (if (not (current-attr-lookup (caar alist)))
			   (parse-error context "unknown attribute" (caar alist))))
		      ((and (list? elm) (pair? elm) (symbol? (car elm)))
		       (let ((a (current-attr-lookup (car elm))))
			 (if (not a)
			     (parse-error context "unknown attribute" elm))
			 (set! alist (cons (send a 'parse-value
						 context (cdr elm))
					   alist))))
		      (else (parse-error context "improper attribute" elm))))
	      attrs)
    alist)
)

; Parse an object attribute spec.
; ATTRS is a list of attribute specs (e.g. (FOO !BAR (BAZ 3))).
; The result is an <attr-list> object.

(define (atlist-parse context attrs prefix)
  (make <attr-list> prefix (attr-parse context attrs))
)

; Return the source form of an atlist's values.
; Externally attributes are ((name1 value1) (name2 value2) ...).
; Internally they are ((name1 . value1) (name2 . value2) ...).

(define (atlist-source-form atlist)
  (map (lambda (attr)
	 (list (car attr) (cdr attr)))
       (atlist-attrs atlist))
)

; Cons an attribute to an attribute list to create a new attribute list.
; ATLIST is either an attr-list object or #f or () (both of the latter two
; signify an empty attribute list, in which case we make the prefix of the
; result "").

(define (atlist-cons attr atlist)
  (if (or (not atlist) (null? atlist))
      (make <attr-list> "" (cons attr nil))
      (make <attr-list> (atlist-prefix atlist) (cons attr (atlist-attrs atlist))))
)

; Append one attribute list to another.
; The prefix for the new atlist is taken from the first one.

(define (atlist-append attr-list1 attr-list2)
  (make <attr-list>
	(atlist-prefix attr-list1)
	(append (atlist-attrs attr-list1) (atlist-attrs attr-list2)))
)

; Remove meta-attributes from ALIST.
; "meta" may be the wrong adjective to use here.
; The attributes in question are not intended to appear in generated files.
; They started out being attributes of attributes, hence the name "meta".

(define (attr-remove-meta-attrs-alist alist)
  (let ((all-attrs (current-attr-list)))
    ; FIXME: Why not use find?
    (let loop ((result nil) (alist alist))
      (if (null? alist)
	  (reverse! result)
	  (let ((attr (attr-lookup (caar alist) all-attrs)))
	    (if (and attr (has-attr? attr 'META))
		(loop result (cdr alist))
		(loop (cons (car alist) result) (cdr alist)))))))
)

; Remove meta-attributes from ATTR-LIST.
; "meta" may be the wrong adjective to use here.
; The attributes in question are not intended to appear in generated files.
; They started out being attributes of attributes, hence the name "meta".

(define (attr-remove-meta-attrs attr-list)
  ; FIXME: Why not use find?
  (let loop ((result nil) (attr-list attr-list))
    (cond ((null? attr-list)
	   (reverse! result))
	  ((has-attr? (car attr-list) 'META)
	   (loop result (cdr attr-list)))
	  (else
	   (loop (cons (car attr-list) result) (cdr attr-list)))))
)

; Remove duplicates from ATTRS, a list of attributes.
; Attribute lists are typically small so we use a simple O^2 algorithm.
; The leading entry of an attribute overrides subsequent ones so this is
; defined to pick the first entry of each attribute.

(define (attr-nub attrs)
  (let loop ((result nil) (attrs attrs))
    (cond ((null? attrs) (reverse! result))
	  ((assq (caar attrs) result) (loop result (cdr attrs)))
	  (else (loop (cons (car attrs) result) (cdr attrs)))))
)

; Return a list of all attrs in TABLE-LIST, a list of lists of arbitrary
; elements.   A list of lists is passed to simplify computation of insn
; attributes where the insns and macro-insns are on separate lists and
; appending them into one list would be unnecessarily expensive.
; ACCESSOR is a function to access the attrs field from TABLE-LIST.
; Duplicates are eliminated and the list is sorted so non-boolean attributes
; are at the front (required by the C code that fetches attribute values).
; STD-ATTRS is an `attr-list' object of attrs that are always available.
; The actual values returned are random (e.g. #t vs #f).  We could
; canonicalize them.
; The result is an alist of all the attributes that are used in TABLE-LIST.
; ??? The cdr of each element is some random value.  Perhaps it should be
; the default value or perhaps we should just return a list of names.
; ??? No longer used.

(define (attr-compute-all table-list accessor std-attrs)
  (let ((accessor (lambda (elm) (atlist-attrs (accessor elm)))))
    (attr-remove-meta-attrs-alist
     (attr-nub
      (-attr-sort-alist
       (append
	(apply append
	       (map (lambda (table-elm)
		      (apply append
			     (find-apply accessor
					 (lambda (e)
					   (let ((attrs (accessor e)))
					     (not (null? attrs))))
					 table-elm)))
		    table-list))
	(atlist-attrs std-attrs))))))
)

; Return lists of attributes for particular object types.
; FIXME: The output shouldn't be required to be sorted.

(define (current-attr-list-for type)
  (let ((sorted (-attr-sort (find (lambda (a)
				    (if (atlist-for a)
					(memq type (atlist-for a))
					#t))
				  (attr-remove-meta-attrs
				   (current-attr-list))))))
    ; Current behaviour puts the non-bools at the front.
    (append! (cdr sorted) (car sorted)))
)
(define (current-ifld-attr-list)
  (current-attr-list-for 'ifield)
)
(define (current-hw-attr-list)
  (current-attr-list-for 'hardware)
)
(define (current-op-attr-list)
  (current-attr-list-for 'operand)
)
(define (current-insn-attr-list)
  (current-attr-list-for 'insn)
)

; Methods to emit the C value of an attribute.
; These don't _really_ belong here (C code doesn't belong in the appl'n
; independent part of CGEN), but there isn't a better place for them
; (maybe utils-cgen.scm?) and there's only a few of them.

(method-make!
 <boolean-attribute> 'gen-value-for-defn-raw
 (lambda (self value)
   (if (not value)
       "0"
       "1"))
 ;(string-upcase (string-append (obj:str-name self) "_" value)))
)

(method-make!
 <boolean-attribute> 'gen-value-for-defn
 (lambda (self value)
   (send self 'gen-value-for-defn-raw value))
)

(method-make!
 <bitset-attribute> 'gen-value-for-defn-raw
 (lambda (self value)
   (if (string=? (string-downcase (gen-sym self)) "isa")
       (bitset-attr->charmask value (elm-get self 'values))
       (string-drop1
	(string-upcase
	 (string-map (lambda (x)
		       (string-append "|(1<<"
				      (gen-sym self)
				      "_" (gen-c-symbol x) ")"))
		     (bitset-attr->list value)))))
 )
)

(method-make!
 <bitset-attribute> 'gen-value-for-defn
 (lambda (self value)
   (string-append
    "{ "
    (if (string=? (string-downcase (gen-sym self)) "isa")
	(bitset-attr->charmask value (elm-get self 'values))
	(string-append
	 "{ "
	 (string-drop1
	  (string-upcase
	   (string-map (lambda (x)
			 (string-append "|(1<<"
					(gen-sym self)
					"_" (gen-c-symbol x) ")"))
		       (bitset-attr->list value))))
	 ", 0 }"))
    " }")
 )
)

(method-make!
 <integer-attribute> 'gen-value-for-defn-raw
 (lambda (self value)
   (number->string value)
 )
)

(method-make!
 <integer-attribute> 'gen-value-for-defn
 (lambda (self value)
   (string-append
    "{ { "
    (send self 'gen-value-for-defn-raw value)
    ", 0 } }")
 )
)

(method-make!
 <enum-attribute> 'gen-value-for-defn-raw
 (lambda (self value)
   (string-upcase
    (gen-c-symbol (string-append (obj:str-name self)
				 "_"
				 (symbol->string value))))
 )
)

(method-make!
 <enum-attribute> 'gen-value-for-defn
 (lambda (self value)
   (string-append
    "{ { "
     (send self 'gen-value-for-defn-raw value)
     ", 0 } }")
 )
)

;; Doesn't handle escape sequences.
(method-make!
 <string-attribute> 'gen-value-for-defn-raw
 (lambda (self value)
   (string-append "\"" value "\""))
)

(method-make!
 <string-attribute> 'gen-value-for-defn
 (lambda (self value)
   (send self 'gen-value-for-defn-raw value))
)


; Called before loading a .cpu file to initialize.

(define (attr-init!)

  (reader-add-command! 'define-attr
		       "\
Define an attribute, name/value pair list version.
"
		       nil 'arg-list define-attr)

  *UNSPECIFIED*
)

; Called before a . cpu file is read in to install any builtins.
; One thing this does is define all attributes requiring a fixed index,
; keeping them all in one place.
; ??? Perhaps it would make sense to define all predefined attributes here.

(define (attr-builtin!)
  (define-attr '(type boolean) '(name VIRTUAL) '(comment "virtual object"))

  ; The meta attribute is used for attributes that aren't to appear in
  ; generated output (need a better name).
  (define-attr '(for attr) '(type boolean) '(name META))

  ; Objects to keep local to a generated file.
  (define-attr '(for keyword) '(type boolean) '(name PRIVATE))

  ; Attributes requiring fixed indices.
  (define-attr '(for attr) '(type boolean) '(name INDEX) '(attrs META))

  ; ALIAS is used for instructions that are aliases of more general insns.
  ; ALIAS insns are ignored by the simulator.
  (define-attr '(for insn) '(type boolean) '(name ALIAS)
    '(comment "insn is an alias of another")
    '(attrs INDEX))

  *UNSPECIFIED*
)

; Called after loading a .cpu file to perform any post-processing required.

(define (attr-finish!)
  *UNSPECIFIED*
)
