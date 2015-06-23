; Cgen's Object System.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.
;
; When Guile has an official object implementation that is stable, things will
; be switched over then.  Until such time, there's no point in getting hyper
; (although doing so is certainly fun, but only to a point).
; If the Guile team decides there won't be any official object system
; (which isn't unreasonable) then we'll pick the final object system then.
; Until such time, there are better things to do than trying to build a
; better object system.  If this is important enough to you, help the Guile
; team finish the module(/object?) system.
;
; Classes look like:
;
; #(class-tag
;   class-name
;   parent-name-list
;   elm-alist
;   method-alist
;   full-elm-initial-list
;   full-method-alist ; ??? not currently used
;   class-descriptor)
;
; PARENT-NAME-LIST is a list of the names of parent classes (the inheritance
; tree).
;
; ELM-ALIST is an alist of (symbol private? vector-index . initial-value)
; for this class only.
; Values can be looked up by name, via elm-make-[gs]etter routines, or
; methods can use elm-get/set! for speed.
; Various Lisp (or Lisp-like) OOP systems (e.g. CLOS, Dylan) call these
; "slots".  Maybe for consistency "slot" would be a better name.  Some might
; confuse that with intentions at directions.  Given that something better
; will eventually happen, being deliberately different is useful.
;
; METHOD-ALIST is an alist of (symbol . (virtual? . procedure)) for this
; class only.
;
; FULL-ELM-INITIAL-LIST is the elements of the flattened inheritance tree.
; Initially it is #f meaning it hasn't been computed yet.
; It is computed when the class is first instantiated.  During development,
; it can be reset to #f after some module has been reloaded (requires all
; object instantiation happens later of course).
;
; FULL-METHOD-ALIST is an alist of the methods of the flattened inheritance
; tree.  Each element is (symbol . (parent-list-entry . method)).
; Initially it is #f meaning it hasn't been computed yet.
; It is computed when the class is first instantiated.  During development,
; it can be reset to #f after some module has been reloaded (requires all
; object instantiation happens later of course).
;
; CLASS-DESCRIPTOR is the processed form of parent-name-list.
; There is an entry for the class and one for each parent (recursively):
; (class mi? (base-offset . delta) child-backpointer (parent1-entry) ...).
; mi? is #t if the class or any parent class has multiple inheritance.
; This is used by the element access routines.
; base-offset is the offset in the element vector of the baseclass (or first
; baseclass in the mi case).
; delta is the offset from base-offset of the class's own elements
; (as opposed to elements in any parent class).
; child-backpointer is #f in the top level object.
; ??? child->subclass, parent->superclass?
; Initially the class-descriptor is #f meaning it hasn't been computed yet.
; It is computed when the class is first instantiated.  During development,
; it can be reset to #f after some module has been reloaded (requires all
; object instantiation to happen later of course).
;
; An object is a vector of 2 elements: #(object-elements class-descriptor).
; ??? Things would be simpler if objects were a pair but that makes eval'ing
; them trickier.  Vectors are nice in that they're self-evaluating, though
; due to the self-referencing, which Guile 1.2 can't handle, apps have to
; be careful.
; ??? We could use smobs/records/whatever but the difference isn't big enough
; for me to care at this point in time.
;
; `object-elements' looks like:
;
; #(object-tag
;   class
;   element1
;   element2
;   ...)
;
; CLASS is the class the object is an instance of.
;
; User visible procs:
;
; (class-make name parents elements methods) -> class
;
; Create a class.  The result is then passed back by procedures requiring
; a class argument.  Note however that PARENTS is a list of class names,
; not the class data type.  This allows reloading the definition of a
; parent class without having to reload any subclasses.  To implement this
; classes are recorded internally, and `object-init!' must be called if any
; class has been redefined.
;
; (class-list) -> list of all defined classes
;
; (class-name class) -> name of CLASS
;
; (class-lookup class-name) -> class
;
; (class-instance? class object) -> #t if OBJECT is an instance of CLASS
;
; (object-class object) -> class of OBJECT
;
; (object-class-name object) -> class name of OBJECT
;
; (send object method-name . args) -> result of invoking METHOD-NAME
;
; (send-next object method-name . args) -> result of invoking next METHOD-NAME
;
; (new class) -> instantiate CLASS
;
; The object is initialized with values specified when CLASS
; (and its parent classes) was defined.
;
; (vmake class . args) -> instantiate class and initialize it with 'vmake!
;
; This is shorthand for (send (new class) 'vmake! args).
; ARGS is a list of option names and arguments (a la CLOS).
; ??? Not implemented yet.
;
; (method-vmake! object . args) -> modify OBJECT from ARGS
;
; This is the standard 'vmake! method, available for use by user-written
; 'vmake! methods.
; ??? Not implemented yet.
;
; (make class . args) -> instantiate CLASS and initialize it with 'make!
;
; This is shorthand for (send (new class) 'make! arg1 ...).
; This is a positional form of `new'.
;
; (method-make-make! class elm1-name elm2-name ...) -> unspecified
;
; Create a 'make! method that sets the specified elements.
;
; (object-copy object) -> copy of OBJ
;
; ??? Whether to discard the parent or keep it and retain specialization
; is undecided.
;
; (object-copy-top object) -> copy of OBJECT with spec'n discarded
;
; (object-parent object parent-path) -> parent object in OBJECT via PARENT-PATH
;
; (class? foo) -> return #t if FOO is a class
;
; (object? foo) -> return #t if FOO is an object
;
; (method-make! class name lambda) -> unspecified
;
; Add method NAME to CLASS.
;
; (method-make-virtual! class name lambda) -> unspecified
;
; Add virtual method NAME to CLASS.
;
; (method-make-forward! class elm-name methods) -> unspecified
;
; Add METHODS to CLASS that pass the "message" onto the object in element
; ELM-NAME.
;
; (method-make-virtual-forward! class elm-name methods) -> unspecified
;
; Add virtual METHODS to CLASS that pass the "message" onto the object in
; element ELM-NAME.
;
; (elm-get object elm-name) -> value of element ELM-NAME in OBJ
;
; Can only be used in methods.
;
; (elm-set! object elm-name new-value) -> unspecified
;
; Set element ELM-NAME in OBJECT to NEW-VALUE.
; Can only be used in methods.
;
; (elm-make-getter class elm-name) -> lambda
;
; Return lambda to get the value of ELM-NAME in CLASS.
;
; (elm-make-setter class elm-name) -> lambda
;
; Return lambda to set the value of ELM-NAME in CLASS.
;
; Conventions used in this file:
; - procs/vars internal to this file are prefixed with "-"
;   [Of course this could all be put in a module; later if ever since
;   once Guile has its own official object system we'll convert.  Note that
;   it currently does not.]
; - except for a few exceptions, public procs begin with one of
;   class-, object-, elm-, method-.
;   The exceptions are make, new, parent, send.

(define -class-tag "class")
(define -object-tag "object")

; List of all classes.

(define -class-list '())

; ??? Were written as a procedures for Hobbit's sake (I think).
(define -object-unspecified #:unspecified)
(define -object-unbound #:unbound)

; Associative list of classes to be traced.

(define -object-debug-classes #f)

; Associative list of elements to be traced.

(define -object-debug-elements #f)

; Associative list of messages to be traced.

(define -object-debug-methods #f)

; True if error messages are verbose and debugging messages are printed.

(define -object-verbose? #f)

; Cover fn to set verbosity.

(define (object-set-verbose! verbose?)
  (set! -object-verbose? verbose?)
)

; Signal error if not class/object.

(define (-class-check maybe-class proc-name . extra-text)
  (if (not (class? maybe-class))
      (apply -object-error
	     (append! (list proc-name maybe-class "not a class")
		      extra-text)))
  -object-unspecified
)
(define (-object-check-name maybe-name proc-name . extra-text)
  (if (not (symbol? maybe-name))
      (apply -object-error
	     (append! (list proc-name maybe-name) extra-text)))
  -object-unspecified
)
(define (-object-check maybe-object proc-name . extra-text)
  (if (not (object? maybe-object))
      (apply -object-error
	     (append! (list proc-name maybe-object "not an object")
		      extra-text)))
  -object-unspecified
)

; X is any arbitrary Scheme data.
(define (-object-error proc-name x . text)
  (error (string-append proc-name ": " (apply string-append text)
			(if (object? x)
			    (string-append
			     " (class: " (-object-class-name x)
			     (if (method-present? x 'get-name)
				 (string-append ", name: "
						(send x 'get-name))
				 "")
			     ")")
			    "")
			"")
	 x)
)

; Low level class operations.

; Return boolean indicating if X is a class.

(define (class? class)
  (and (vector? class) (eq? -class-tag (vector-ref class 0)))
)

; Accessors.

(define (-class-name class) (vector-ref class 1))
(define (-class-parents class) (vector-ref class 2))
(define (-class-elements class) (vector-ref class 3))
(define (-class-methods class) (vector-ref class 4))
(define (-class-all-initial-values class) (vector-ref class 5))
(define (-class-all-methods class) (vector-ref class 6))
(define (-class-class-desc class) (vector-ref class 7))

(define (-class-set-parents! class parents)
  (vector-set! class 2 parents)
)

(define (-class-set-elements! class elm-alist)
  (vector-set! class 3 elm-alist)
)

(define (-class-set-methods! class method-alist)
  (vector-set! class 4 method-alist)
)

(define (-class-set-all-initial-values! class init-list)
  (vector-set! class 5 init-list)
)

(define (-class-set-all-methods! class all-meth-list)
  (vector-set! class 6 all-meth-list)
)

(define (-class-set-class-desc! class parent-list)
  (vector-set! class 7 parent-list)
)

; Make a class.
; The new definition overrides any existing definition.

(define (-class-make! name parents elements methods)
  (let ((class (vector -class-tag name parents elements methods #f #f #f))
	(list-entry (assq name -class-list)))
    (if list-entry
	(set-cdr! list-entry class)
	(set! -class-list (acons name class -class-list)))
    class)
)

; Lookup a class given its name.
; The result is the class or #f if not found.

(define (class-lookup name) (assq-ref -class-list name))

; Return a list of all direct parent classes of CLASS.

(define (-class-parent-classes class)
  ; -class-parents returns the names, we want the actual classes.
  (let loop ((parents (-class-parents class))
	     (result '()))
    (if (null? parents)
	(reverse! result)
	(let ((parent (class-lookup (car parents))))
	  (if (not parent)
	      ; The proc name we pass here is made up as we don't
	      ; want it to be the name of an internal proc.
	      (-object-error "class" (car parents) "not a class"))
	  (loop (cdr parents) (cons parent result)))))
)

; Cover proc of -class-name for the outside world to use.
; The result is the name of the class or #f if CLASS is not a class.
; We could issue an error here, but to be consistent with object-class-name
; we don't.

(define (class-name class)
  (if (class? class)
      (-class-name class)
      #f)
)

; Return a boolean indicating if CLASS or any parent class has
; multiple inheritance.

(define (-class-mi? class)
  (-class-desc-mi? (-class-class-desc class))
)

; Class descriptor utilities.
; A class-descriptor is:
; (class mi? (base-offset . delta) child-backpointer (parent1-entry) ...)

;(define (-class-desc-make class offset bkptr parents)
;   (append (list class offset bkptr) parents)
;)
(define (-class-desc? maybe-class-desc)
  (and (pair? maybe-class-desc)
       (class? (car maybe-class-desc)))
)
(define -class-desc-class car)
(define -class-desc-mi? cadr)
(define -class-desc-offset caddr)
(define -class-desc-offset-base caaddr)
(define -class-desc-offset-delta cdaddr)
(define -class-desc-child cadddr)
(define -class-desc-parents cddddr)
; Note that this is an assq on the classes themselves, not their names.
; The result is the parent's class-descriptor.
(define -class-desc-lookup-parent assq)

; Compute the class descriptor of CLASS.
; OFFSET is the beginning offset in the element vector.
; We can assume the parents of CLASS have already been initialized.
;
; A class-descriptor is:
; (class mi? (base-offset . delta) child-backpointer (parent1-entry) ...)
; MI? is a boolean indicating if multiple inheritance is present.
; BASE-OFFSET is the offset into the object vector of the baseclass's elements
; (or first baseclass in the mi case).
; DELTA is the offset from BASE-OFFSET of the class's own elements.
; CHILD is the backlink to the direct child class or #f for the top class.
; ??? Is the use of `top' backwards from traditional usage?

(define (-class-compute-class-desc class offset child)

  ; OFFSET must be global to the calculation because it is continually
  ; incremented as we recurse down through the hierarchy (actually, as we
  ; traverse back up).  At any point in time it is the offset from the start
  ; of the element vector of the next class's elements.
  ; Object elements are laid out using a depth first traversal of the
  ; inheritance tree.

  (define (compute1 class child base-offset)

    ; Build the result first, then build our parents so that our parents have
    ; the right value for the CHILD-BACKPOINTER field.
    ; Use a bogus value for mi? and offset for the moment.
    ; The correct values are set later.

    (let ((result (list class #f (cons 999 999) child))
	  (mi? (> (length (-class-parents class)) 1)))

      ; Recurse on the parents.
      ; We use `append!' here as the location of `result' is now fixed so
      ; that our parent's child-backpointer remains stable.

      (append! result
	       (let loop ((parents (-class-parents class))
			  (parent-descs '())
			  (base-offset base-offset))
		 (if (null? parents)
		     (reverse! parent-descs)
		     (let ((parent (class-lookup (car parents))))
		       (if (not parent)
			   ; The proc name we pass here is made up as we don't
			   ; want it to be the name of an internal proc.
			   (-object-error "class" (car parents) "not a class"))
		       (if (and (not mi?)
				(-class-mi? parent))
			   (set! mi? #t))
		       (let ((parent-desc (compute1 parent result base-offset)))
			 (loop (cdr parents)
			       (cons parent-desc parent-descs)
			       offset))))))

      (list-set! result 1 mi?)
      (list-set! result 2 (cons base-offset (- offset base-offset)))
      (set! offset (+ offset (length (-class-elements class))))
      result))

  (compute1 class child offset)
)

; Return the top level class-descriptor of CLASS-DESC.

(define (-class-desc-top class-desc)
  (if (-class-desc-child class-desc)
      (-class-desc-top (-class-desc-child class-desc))
      class-desc)
)

; Pretty print a class descriptor.

(define (class-desc-dump class-desc)
  (let* ((cep (current-error-port))
	 (top-desc (-class-desc-top class-desc))
	 (spaces (lambda (n port)
		   (display (make-string n #\space) port)))
	 (writeln (lambda (indent port . args)
		    (spaces indent port)
		    (for-each (lambda (arg) (display arg port))
			      args)
		    (newline port)))
	 )
    (letrec ((dump (lambda (cd indent)
		     (writeln indent cep "Class: "
			      (-class-name (-class-desc-class cd)))
		     (writeln indent cep "  mi?:         "
			      (-class-desc-mi? cd))
		     (writeln indent cep "  base offset: "
			      (-class-desc-offset-base cd))
		     (writeln indent cep "  delta:       "
			      (-class-desc-offset-delta cd))
		     (writeln indent cep "  child:       "
			      (if (-class-desc-child cd)
				  (-class-name (-class-desc-class
						(-class-desc-child cd)))
				  "-top-"))
		     (for-each (lambda (parent-cd) (dump parent-cd (+ indent 4)))
			       (-class-desc-parents cd))
		     )))
      (display "Top level class: " cep)
      (display (-class-name (-class-desc-class top-desc)) cep)
      (newline cep)
      (dump class-desc 0)
      ))
)

; Low level object utilities.

; Make an object.
; All elements get initial (or unbound) values.

(define (-object-make! class)
  (-class-check-init! class)
  (vector (apply vector (append! (list -object-tag class)
				 (-class-all-initial-values class)))
	  (-class-class-desc class))
)

; Make an object using VALUES.
; VALUES must specify all elements in the class (and parent classes).

(define (-object-make-with-values! class class-desc values)
  (-class-check-init! class)
  (vector (apply vector (append! (list -object-tag class) values))
	  class-desc)
)

; Copy an object.
; If TOP?, the copy is of the top level object with any specialization
; discarded.
; WARNING: A shallow copy is currently done on the elements!

(define (-object-copy obj top?)
  (if top?
      (vector (-object-vector-copy (-object-elements obj))
	      (-class-class-desc (-object-top-class obj)))
      (vector (-object-vector-copy (-object-elements obj))
	      (-object-class-desc obj)))
)

; Specialize an object to be one from a parent class.
; The result is the same object, but with a different view (confined to
; a particular parent class).

(define (-object-specialize obj class-desc)
  (vector (-object-elements obj) class-desc)
)

; Accessors.

(define (-object-elements obj) (vector-ref obj 0))
(define (-object-class-desc obj) (vector-ref obj 1))
(define (-object-class obj) (-class-desc-class (-object-class-desc obj)))
(define (-object-class-name obj) (-class-name (-object-class obj)))
(define (-object-top-class obj) (vector-ref (-object-elements obj) 1))

(define (-object-elm-get obj class-desc elm-base-offset)
  (vector-ref (-object-elements obj)
	      (+ (-class-desc-offset-base class-desc) elm-base-offset))
)

(define (-object-elm-set! obj class-desc elm-base-offset new-val)
  (vector-set! (-object-elements obj)
	       (+ (-class-desc-offset-base class-desc) elm-base-offset)
	       new-val)
  -object-unspecified
)

; Return a boolean indicating of OBJ has multiple-inheritance.

(define (-object-mi? obj)
  (-class-mi? (-object-top-class obj))
)

; Return boolean indicating if X is an object.

(define (object? obj)
  (and (vector? obj)
       (= (vector-length obj) 2)
       (vector? (vector-ref obj 0))
       (eq? -object-tag (vector-ref (vector-ref obj 0) 0))
       (-class-desc? (vector-ref obj 1)))
)

; Return the class of an object.

(define (object-class obj)
  (-object-check obj "object-class")
  (-object-class obj)
)

; Cover proc of -object-class-name for the outside world to use.
; The result is the name of the class or #f if OBJ is not an object.

(define (object-class-name obj)
  (if (object? obj)
      (-object-class-name obj)
      #f)
)

; Class operations.

; Return the list of initial values for CLASS.
; The result does not include parent classes.

(define (-class-my-initial-values class)
  (map cadr (-class-elements class))
)

; Initialize class if not already done.
; FIXME: Need circularity check.  Later.

(define (-class-check-init! class)
  ; This should be fast the second time through, so don't do any
  ; computation until we know it's necessary.

  (if (not (-class-all-initial-values class))

      (begin

	; First pass ensures all parents are initialized.
	(for-each -class-check-init!
		  (-class-parent-classes class))

	; Next pass initializes the initial value list.
	(letrec ((get-inits
		  (lambda (class)
		    (let ((parents (-class-parent-classes class)))
		      (append (apply append (map get-inits parents))
			      (-class-my-initial-values class))))))

	  (let* ((parents (-class-parent-classes class))
		 (inits (append (apply append (map get-inits parents))
				(-class-my-initial-values class))))
	    (-class-set-all-initial-values! class inits)))

	; Next pass initializes the class's class-descriptor.
	; Object elements begin at offset 2 in the element vector.
	(-class-set-class-desc! class
				(-class-compute-class-desc class 2 #f))
	))

  -object-unspecified
)

; Make a class.
;
; PARENTS is a list of names of parent classes.  The parents need not
; exist yet, though they must exist when the class is first instantiated.
; ELMS is a either a list of either element names or name/value pairs.
; Elements without initial values are marked as "unbound".
; METHODS is an initial alist of methods.  More methods can be added with
; method-make!.

(define (class-make name parents elms methods)
  (let ((elm-list #f))

    ; Mark elements without initial values as unbound, and
    ; compute indices into the element vector (relative to the class's
    ; offset).
    ; Elements are recorded as (symbol initial-value private? . vector-index)
    ; FIXME: For now all elements are marked as "public".
    (let loop ((elm-list-tmp '()) (index 0) (elms elms))
      (if (null? elms)
	  (set! elm-list (reverse! elm-list-tmp)) ; done
	  (if (pair? (car elms))
	      (loop (acons (caar elms)
			   (cons (cdar elms) (cons #f index))
			   elm-list-tmp)
		    (+ index 1)
		    (cdr elms))
	      (loop (acons (car elms)
			   (cons -object-unbound (cons #f index))
			   elm-list-tmp)
		    (+ index 1)
		    (cdr elms)))))

    (let ((result (-class-make! name parents elm-list methods)))

      ; Create the standard `make!' method.
      ; The caller can override afterwards if desired.
      ; Note that if there are any parent classes then we don't know the names
      ; of all of the elements yet, that is only known after the class has been
      ; initialized which only happens when the class is first instantiated.
      ; This method won't be called until that happens though so we're safe.
      ; This is written without knowledge of the names, it just initializes
      ; all elements.
      (method-make! result 'make!
		    (lambda args
		      (let ((self (car args)))
			; Ensure exactly all of the elements are provided.
			(if (not (= (length args)
				    (- (vector-length (-object-elements self)) 1)))
			    (-object-error "make!" "" "wrong number of arguments to method `make!'"))
			(-object-make-with-values! (-object-top-class self)
						   (-object-class-desc self)
						   (cdr args)))))

      result))
)

; Create an object of a class CLASS.

(define (new class)
  (-class-check class "new")

  (if -object-verbose?
      (display (string-append "Instantiating class " (-class-name class) ".\n")
	       (current-error-port)))

  (-object-make! class)
)

; Make a copy of OBJ.
; WARNING: A shallow copy is done on the elements!

(define (object-copy obj)
  (-object-check obj "object-copy")
  (-object-copy obj #f)
)

; Make a copy of OBJ.
; This makes a copy of top level object, with any specialization discarded.
; WARNING: A shallow copy is done on the elements!

(define (object-copy-top obj)
  (-object-check obj "object-copy-top")
  (-object-copy obj #t)
)

; Utility to define a standard `make!' method.
; A standard make! method is one in which all it does is initialize
; fields from args.

(define (method-make-make! class args)
  (let ((lambda-expr
	 (append (list 'lambda (cons 'self args))
		 (map (lambda (elm) (list 'elm-set! 'self
					  (list 'quote elm) elm))
		      args)
		 '(self))))
    (method-make! class 'make! (eval1 lambda-expr))
    )
)

; The "standard" way to invoke `make!' is (send (new class) 'make! ...).
; This puts all that in a cover function.

(define (make class . operands)
  (apply send (append (cons (new class) '()) '(make!) operands))
)

; Return #t if class X is a subclass of BASE-NAME.

(define (-class-subclass? base-name x)
  (if (eq? base-name (-class-name x))
      #t
      (let loop ((parents (-class-parents x)))
	(if (null? parents)
	    #f
	    (if (-class-subclass? base-name (class-lookup (car parents)))
		#t
		(loop (cdr parents))))))
)

; Return #t if OBJECT is an instance of CLASS.
; This does not signal an error if OBJECT is not an object as this is
; intended to be used in class predicates.

(define (class-instance? class object)
  (-class-check class "class-instance?")
  (if (object? object)
      (-class-subclass? (-class-name class) (-object-class object))
      #f)
)

; Element operations.

; Lookup an element in a class-desc.
; The result is (class-desc . (private? . elm-offset)) or #f if not found.
; ??? We could define accessors of the result but knowledge of its format
; is restricted to this section of the source.

(define (-class-lookup-element class-desc elm-name)
  (let* ((class (-class-desc-class class-desc))
	 (elm (assq elm-name (-class-elements class))))
    (if elm
	(cons class-desc (cddr elm))
	(let loop ((parents (-class-desc-parents class-desc)))
	  (if (null? parents)
	      #f
	      (let ((elm (-class-lookup-element (car parents) elm-name)))
		(if elm
		    elm
		    (loop (cdr parents)))))
	  ))
    )
)

; Given the result of -class-lookup-element, return the element's delta
; from base-offset.

(define (-elm-delta index)
  (+ (-class-desc-offset-delta (car index))
     (cddr index))
)

; Return a boolean indicating if ELM is bound in OBJ.

(define (elm-bound? obj elm)
  (-object-check obj "elm-bound?")
  (let* ((index (-class-lookup-element (-object-class-desc obj) elm))
	 (val (-object-elm-get obj (car index) (-elm-delta index))))
    (not (eq? val -object-unbound)))
)

; Subroutine of elm-get.

(define (-elm-make-method-getter self name)
  (-object-check self "elm-get")
  (let ((index (-class-lookup-element (-object-class-desc self) name)))
    (if index
	(procedure->memoizing-macro
	 (lambda (exp env)
	   `(lambda (obj)
	      (-object-elm-get obj (-object-class-desc obj)
			       ,(-elm-delta index)))))
	(-object-error "elm-get" self "element not present: " name)))
)

; Get an element from an object.
; If OBJ is `self' then the caller is required to be a method and we emit
; memoized code.  Otherwise we do things the slow way.
; ??? There must be a better way.
; What this does is turn
; (elm-get self 'foo)
; into
; ((-elm-make-method-get self 'foo) self)
; Note the extra set of parens.  -elm-make-method-get then does the lookup of
; foo and returns a memoizing macro that returns the code to perform the
; operation with O(1).  Cute, but I'm hoping there's an easier/better way.

(defmacro elm-get (self name)
  (if (eq? self 'self)
      `(((-elm-make-method-getter ,self ,name)) ,self)
      `(elm-xget ,self ,name))
)

; Subroutine of elm-set!.

(define (-elm-make-method-setter self name)
  (-object-check self "elm-set!")
  (let ((index (-class-lookup-element (-object-class-desc self) name)))
    (if index
	(procedure->memoizing-macro
	 (lambda (exp env)
	   `(lambda (obj new-val)
	      (-object-elm-set! obj (-object-class-desc obj)
				,(-elm-delta index) new-val))))
	(-object-error "elm-set!" self "element not present: " name)))
)

; Set an element in an object.
; This can only be used by methods.
; See the comments for `elm-get'!

(defmacro elm-set! (self name new-val)
  (if (eq? self 'self)
      `(((-elm-make-method-setter ,self ,name)) ,self ,new-val)
      `(elm-xset! ,self ,name ,new-val))
)

; Get an element from an object.
; This is for invoking from outside a method, and without having to
; use elm-make-getter.  It should be used sparingly.

(define (elm-xget obj name)
  (-object-check obj "elm-xget")
  (let ((index (-class-lookup-element (-object-class-desc obj) name)))
    ; FIXME: check private?
    (if index
	(-object-elm-get obj (car index) (-elm-delta index))
	(-object-error "elm-xget" obj "element not present: " name)))
)

; Set an element in an object.
; This is for invoking from outside a method, and without having to
; use elm-make-setter.  It should be used sparingly.

(define (elm-xset! obj name new-val)
  (-object-check obj "elm-xset!")
  (let ((index (-class-lookup-element (-object-class-desc obj) name)))
    ; FIXME: check private?
    (if index
	(-object-elm-set! obj (car index) (-elm-delta index) new-val)
	(-object-error "elm-xset!" obj "element not present: " name)))
)

; Return a boolean indicating if object OBJ has element NAME.

(define (elm-present? obj name)
  (-object-check obj "elm-present?")
  (->bool (-class-lookup-element (-object-class-desc obj) name))
)

; Return lambda to get element NAME in CLASS.
; FIXME: validate name.

(define (elm-make-getter class name)
  (-class-check class "elm-make-getter")
  ; We use delay here as we can't assume parent classes have been
  ; initialized yet.
  (let ((fast-index (delay (-class-lookup-element
			    (-class-class-desc class) name))))
    (lambda (obj)
      ; ??? Should be able to use fast-index in mi case.
      ; ??? Need to involve CLASS in lookup.
      (let ((index (if (-object-mi? obj)
		       (-class-lookup-element (-object-class-desc obj) name)
		       (force fast-index))))
      (-object-elm-get obj (car index) (-elm-delta index)))))
)

; Return lambda to set element NAME in CLASS.
; FIXME: validate name.

(define (elm-make-setter class name)
  (-class-check class "elm-make-setter")
  ; We use delay here as we can't assume parent classes have been
  ; initialized yet.
  (let ((fast-index (delay (-class-lookup-element
			    (-class-class-desc class) name))))
    (lambda (obj newval)
      ; ??? Should be able to use fast-index in mi case.
      ; ??? Need to involve CLASS in lookup.
      (let ((index (if (-object-mi? obj)
		       (-class-lookup-element (-object-class-desc obj) name)
		       (force fast-index))))
	(-object-elm-set! obj (car index) (-elm-delta index) newval))))
)

; Return a list of all elements in OBJ.

(define (elm-list obj)
  (cddr (vector->list (-object-elements obj)))
)

; Method operations.

; Lookup the next method in a class.
; This means begin the search in the parents.
; ??? What should this do for virtual methods.  At present we treat them as
; non-virtual.

(define (-method-lookup-next class-desc method-name)
  (let loop ((parents (-class-desc-parents class-desc)))
    (if (null? parents)
	#f
	(let ((meth (-method-lookup (car parents) method-name #f)))
	  (if meth
	      meth
	      (loop (cdr parents))))))
)

; Lookup a method in a class.
; The result is (class-desc . method).  If the method is found in a parent
; class, the associated parent class descriptor is returned.  If the method is
; a virtual method, the appropriate subclass's class descriptor is returned.
; VIRTUAL? is #t if virtual methods are to be treated as such.
; Otherwise they're treated as normal methods.
;
; FIXME: We don't yet implement the method cache.

(define (-method-lookup class-desc method-name virtual?)
  (if -object-verbose?
      (display (string-append "Looking up method " method-name " in "
			      (-class-name (-class-desc-class class-desc)) ".\n")
	       (current-error-port)))

  (let ((meth (assq method-name (-class-methods (-class-desc-class class-desc)))))
    (if meth
	(if (and virtual? (cadr meth)) ; virtual?
	    ; Traverse back up the inheritance chain looking for overriding
	    ; methods.  The closest one to the top is the one to use.
	    (let loop ((child (-class-desc-child class-desc))
		       (goal-class-desc class-desc)
		       (goal-meth meth))
	      (if child
		  (begin
		    (if -object-verbose?
			(display (string-append "Looking up virtual method "
						method-name " in "
						(-class-name (-class-desc-class child))
						".\n")
				 (current-error-port)))
		    (let ((meth (assq method-name (-class-methods (-class-desc-class child)))))
		      (if meth
			  ; Method found, update goal object and method.
			  (loop (-class-desc-child child) child meth)
			  ; Method not found at this level.
			  (loop (-class-desc-child child) goal-class-desc goal-meth))))
		  ; Went all the way up to the top.
		  (cons goal-class-desc (cddr goal-meth))))
	    ; Non-virtual, done.
	    (cons class-desc (cddr meth)))
	; Method not found, search parents.
	(-method-lookup-next class-desc method-name)))
)

; Return a boolean indicating if object OBJ has method NAME.

(define (method-present? obj name)
  (-object-check obj "method-present?")
  (->bool (-method-lookup (-object-class-desc obj) name #f))
)

; Return method NAME of CLASS or #f if not present.
; ??? Assumes CLASS has been initialized.

(define (method-proc class name)
  (-class-check class "method-proc")
  (let ((meth (-method-lookup (-class-class-desc class) name #t)))
    (if meth
	(cdr meth)
	#f))
)

; Add a method to a class.
; FIXME: ensure method-name is a symbol

(define (method-make! class method-name method)
  (-class-check class "method-make!")
  (if (not (procedure? method))
      (-object-error "method-make!" method "method must be a procedure"))
  (-class-set-methods! class (acons method-name
				    (cons #f method)
				    (-class-methods class)))
  -object-unspecified
)

; Add a virtual method to a class.
; FIXME: ensure method-name is a symbol

(define (method-make-virtual! class method-name method)
  (-class-check class "method-make-virtual!")
  (if (not (procedure? method))
      (-object-error "method-make-virtual!" method "method must be a procedure"))
  (-class-set-methods! class (acons method-name
				    (cons #t method)
				    (-class-methods class)))
  -object-unspecified
)

; Utility to create "forwarding" methods.
; METHODS are forwarded to class member ELM-NAME, assumed to be an object.
; The created methods take a variable number of arguments.
; Argument length checking will be done by the receiving method.
; FIXME: ensure elm-name is a symbol

(define (method-make-forward! class elm-name methods)
  (for-each (lambda (method-name)
	      (method-make!
	       class method-name
	       (eval1 `(lambda args
			 (apply send
				(cons (elm-get (car args)
					       (quote ,elm-name))
				      (cons (quote ,method-name)
					    (cdr args))))))))
	    methods)
  -object-unspecified
)

; Same as method-make-forward! but creates virtual methods.
; FIXME: ensure elm-name is a symbol

(define (method-make-virtual-forward! class elm-name methods)
  (for-each (lambda (method-name)
	      (method-make-virtual!
	       class method-name
	       (eval1 `(lambda args
			 (apply send
				(cons (elm-get (car args)
					       (quote ,elm-name))
				      (cons (quote ,method-name)
					    (cdr args))))))))
	    methods)
  -object-unspecified
)

; Utility of send, send-next.

(define (-object-method-notify obj method-name maybe-next)
  (set! -object-verbose? #f)
  (display (string-append "Sending " maybe-next method-name " to"
			  (if (method-present? obj 'get-name)
			      (let ((name (send obj 'get-name)))
				(if (or (symbol? name) (string? name))
				    (string-append " object " name)
				    ""))
			      "")
			  " class " (object-class-name obj) ".\n")
	   (current-error-port))
  (set! -object-verbose? #t)
)

; Invoke a method in an object.
; When the method is invoked, the (possible parent class) object in which the
; method is found is passed to the method.
; ??? The word `send' comes from "sending messages".  Perhaps should pick
; a better name for this operation.

(define (send obj method-name . args)
  (-object-check obj "send")
  (-object-check-name method-name "send" "not a method name")
  (if -object-verbose? (-object-method-notify obj method-name ""))

  (let ((class-desc.meth (-method-lookup (-object-class-desc obj)
					 method-name #t)))
    (if class-desc.meth
	(apply (cdr class-desc.meth)
	       (cons (-object-specialize obj (car class-desc.meth))
		     args))
	(-object-error "send" obj "method not supported: " method-name)))
)

; Invoke the next method named METHOD-NAME in the heirarchy of OBJ.
; i.e. the method that would have been invoked if the calling method
; didn't exist.
; This may only be called by a method.
; ??? Ideally we shouldn't need the METHOD-NAME argument.  It could be
; removed with a bit of effort, but is it worth it?

(define (send-next obj method-name . args)
  (-object-check obj "send-next")
  (-object-check-name method-name "send-next" "not a method name")
  (if -object-verbose? (-object-method-notify obj method-name "next "))

  (let ((class-desc.meth (-method-lookup-next (-object-class-desc obj)
					      method-name)))
    (if class-desc.meth
	(apply (cdr class-desc.meth)
	       (cons (-object-specialize obj (car class-desc.meth))
		     args))
	(-object-error "send-next" obj "method not supported: " method-name)))
)

; Parent operations.

; Subroutine of `parent' to lookup a (potentially nested) parent class.
; The result is the parent's class-descriptor or #f if not found.

(define (-class-parent class-desc parent)
  (let* ((parent-descs (-class-desc-parents class-desc))
	 (desc (-class-desc-lookup-parent parent parent-descs)))
    (if desc
	desc
	(let loop ((parents parent-descs))
	  (if (null? parents)
	      #f
	      (let ((desc (-class-parent (car parents) parent)))
		(if desc
		    desc
		    (loop (cdr parents))))))))
)

; Subroutine of `parent' to lookup a parent via a path.
; PARENT-PATH, a list, is the exact path to the parent class.
; The result is the parent's class-descriptor or #f if not found.
; For completeness' sake, if PARENT-PATH is empty, CLASS-DESC is returned.

(define (-class-parent-via-path class-desc parent-path)
  (if (null? parent-path)
      class-desc
      (let ((desc (-class-desc-lookup-parent (car parent-path)
					     (-class-desc-parents class-desc))))
	(if desc
	    (if (null? (cdr parent-path))
		desc
		(-class-parent-via-path (car desc) (cdr parent-path)))
	    #f)))
)

; Lookup a parent class of object OBJ.
; CLASS is either a class or a list of classes.
; If CLASS is a list, it is a (possibly empty) "path" to the parent.
; Otherwise it is any parent and is searched for breadth-first.
; ??? Methinks this should be depth-first.
; The result is OBJ, specialized to the found parent.

(define (object-parent obj class)
  (-object-check obj "object-parent")
  (cond ((class? class) #t)
	((list? class) (for-each (lambda (class) (-class-check class
							       "object-parent"))
				 class))
	(else (-object-error "object-parent" class "invalid parent path")))
		
  ; Hobbit generates C code that passes the function
  ; -class-parent-via-path or -class-parent, not the appropriate
  ; SCM object.
; (let ((result ((if (or (null? class) (pair? class))
;		     -class-parent-via-path
;		     -class-parent)
;		   obj class)))
  ; So it's rewritten like this.
  (let ((result (if (class? class)
		    (-class-parent (-object-class-desc obj) class)
		    (-class-parent-via-path (-object-class-desc obj) class))))
    (if result
	(-object-specialize obj result)
	(-object-error "object-parent" obj "parent not present")))
  ; FIXME: should print path in error message.
)

; Make PARENT-NAME a parent of CLASS, cons'd unto the front of the search
; order.  This is used to add a parent class to a class after it has already
; been created.  Obviously this isn't something one does willy-nilly.
; The parent is added to the front of the current parent list (affects
; method lookup).

(define (class-cons-parent! class parent-name)
  (-class-check class "class-cons-parent!")
  (-object-check-name parent-name "class-cons-parent!" "not a class name")
  (-class-set-parents! class (cons parent-name (-class-parents class)))
  -object-unspecified
)

; Make PARENT-NAME a parent of CLASS, cons'd unto the end of the search order.
; This is used to add a parent class to a class after it has already been
; created.  Obviously this isn't something one does willy-nilly.
; The parent is added to the end of the current parent list (affects
; method lookup).

(define (class-append-parent! class parent-name)
  (-class-check class "class-append-parent!")
  (-object-check-name parent-name "class-append-parent!" "not a class name")
  (-class-set-parents! obj (append (-class-parents obj) (list parent-name)))
  -object-unspecified
)

; Miscellaneous publically accessible utilities.

; Reset the object system (delete all classes).

(define (object-reset!)
  (set! -class-list '())
  -object-unspecified
)

; Call once to initialize the object system.
; Only necessary if classes have been modified after objects have been
; instantiated.  This usually happens during development only.

(define (object-init!)
  (for-each (lambda (class)
	      (-class-set-all-initial-values! class #f)
	      (-class-set-all-methods! class #f)
	      (-class-set-class-desc! class #f))
	    (class-list))
  (for-each (lambda (class)
	      (-class-check-init! class))
	    (class-list))
  -object-unspecified
)

; Return list of all classes.

(define (class-list) (map cdr -class-list))

; Utility to map over a class and all its parent classes, recursively.

(define (class-map-over-class proc class)
  (cons (proc class)
	(map (lambda (class) (class-map-over-class proc class))
	     (-class-parent-classes class)))
)

; Return class tree of a class or object.

(define (class-tree class-or-object)
  (cond ((class? class-or-object)
	 (class-map-over-class class-name class-or-object))
	((object? class-or-object)
	 (class-map-over-class class-name (-object-class class-or-object)))
	(else (-object-error "class-tree" class-or-object
			     "not a class or object")))
)

; Return names of each alist.

(define (-class-alist-names class)
  (list (-class-name class)
	(map car (-class-elements class))
	(map car (-class-methods class)))
)

; Return complete layout of class-or-object.

(define (class-layout class-or-object)
  (cond ((class? class-or-object)
	 (class-map-over-class -class-alist-names class-or-object))
	((object? class-or-object)
	 (class-map-over-class -class-alist-names (-object-class class-or-object)))
	(else (-object-error "class-layout" class-or-object
			     "not a class or object")))
)

; Like assq but based on the `name' element.
; WARNING: Slow.

(define (object-assq name obj-list)
  (find-first (lambda (o) (eq? (elm-xget o 'name) name))
	      obj-list)
)

; Like memq but based on the `name' element.
; WARNING: Slow.

(define (object-memq name obj-list)
  (let loop ((r obj-list))
    (cond ((null? r) #f)
	  ((eq? name (elm-xget (car r) 'name)) r)
	  (else (loop (cdr r)))))
)

; Misc. internal utilities.

; We need a fast vector copy operation.
; If `vector-copy' doesn't exist (which is assumed to be the fast one),
; provide a simple version.
; FIXME: Need deep copier instead.

(if (defined? 'vector-copy)
    (define -object-vector-copy vector-copy)
    (define (-object-vector-copy v) (list->vector (vector->list v)))
)

; Profiling support

(if (and #f (defined? 'proc-profile))
    (begin
      (proc-profile elm-get)
      (proc-profile elm-xset!)
      (proc-profile elm-present?)
      (proc-profile -method-lookup)
      (proc-profile send)
      (proc-profile new)
      (proc-profile make)
      ))
