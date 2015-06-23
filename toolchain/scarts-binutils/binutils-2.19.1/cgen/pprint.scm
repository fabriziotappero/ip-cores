;;;; pprint.scm --- pretty-printing objects for CGEN
;;;; Copyright (C) 2005, 2009 Red Hat, Inc.
;;;; This file is part of CGEN.
;;;; See file COPYING.CGEN for details.

;;; This file defines a printing function PPRINT, and some hooks to
;;; let you print certain kind of objects in a summary way, and get at
;;; their full values later.

;;; PPRINT is a printer for Scheme objects that prints lists or
;;; vectors that contain shared structure or cycles and prints them in
;;; a finite, legible way.
;;;
;;; Ordinary values print in the usual way:
;;;
;;;   guile> (pprint '(1 #(2 3) 4))
;;;   (1 #(2 3) 4)
;;;
;;; Values can share structure:
;;; 
;;;   guile> (let* ((c (list 1 2))
;;;                 (d (list c c)))
;;;            (write d)
;;;            (newline))
;;;   ((1 2) (1 2))
;;;
;;; In that list, the two instances of (1 2) are actually the same object;
;;; the top-level list refers to the same object twice.
;;;
;;; Printing that structure with PPRINT shows the sharing:
;;; 
;;;   guile> (let* ((c (list 1 2))
;;;                 (d (list c c)))
;;;            (pprint d))
;;;   (#0=(1 2) #0#)
;;;
;;; Here the "#0=" before the list (1 2) labels it with the number
;;; zero.  Then, the "#0#" as the second element of the top-level list
;;; indicates that the object appears here, too, referring to it by
;;; its label.
;;;
;;; If you have several objects that appear more than once, they each
;;; get a separate label:
;;;
;;;   guile> (let* ((a (list 1 2))
;;;                 (b (list 3 4))
;;;                 (c (list a b a b)))
;;;            (pprint c))
;;;   (#0=(1 2) #1=(3 4) #0# #1#)
;;;
;;; Cyclic values just share structure with themselves:
;;;
;;;   guile> (let* ((a (list 1 #f)))
;;;            (set-cdr! a a)
;;;            (pprint a))
;;;   #0=(1 . #0#)
;;;
;;;
;;; PPRINT also consults the function ELIDE? and ELIDED-NAME to see
;;; whether it should print a value in a summary form.  You can
;;; re-define those functions to customize PPRINT's behavior;
;;; cos-pprint.scm defines them to handle COS objects and classes
;;; nicely.
;;;
;;; (ELIDE? OBJ) should return true if OBJ should be elided.
;;; (ELIDED-NAME OBJ) should return a (non-cyclic!) object to be used
;;; as OBJ's abbreviated form.
;;;
;;; PPRINT prints an elided object as a list ($ N NAME), where NAME is
;;; the value returned by ELIDED-NAME to stand for the object, and N
;;; is a number; each elided object gets its own number.  You can refer
;;; to the elided object number N as ($ N).
;;;
;;; For example, if you've loaded CGEN, pprint.scm, and cos-pprint.scm
;;; (you must load cos-pprint.scm *after* loading pprint.scm), you can
;;; print a list containing the <insn> and <ident> classes:
;;;
;;;   guile> (pprint (list <insn> <ident>))
;;;   (($ 1 (class <insn>)) ($ 2 (class <ident>)))
;;;   guile> (class-name ($ 1))
;;;   <insn>
;;;   guile> (class-name ($ 2))
;;;   <ident>
;;;
;;; As a special case, PPRINT never elides the object that was passed
;;; to it directly.  So you can look inside an elided object by doing
;;; just that:
;;;
;;;   guile> (pprint ($ 2))
;;;   #0=#("class" <ident> () ((name #:unbound #f . 0) ...
;;;


;;; A list of elided objects, larger numbers first, and the number of
;;; the first element.
(define elide-table '())
(define elide-table-last -1)

;;; Add OBJ to the elided object list, and return its number.
(define (add-elided-object obj)
  (set! elide-table (cons obj elide-table))
  (set! elide-table-last (+ elide-table-last 1))
  elide-table-last)

;;; Referencing elided objects.
(define ($ n)
  (if (<= 0 n elide-table-last)
      (list-ref elide-table (- elide-table-last n))
      "no such object"))

;;; A default predicate for elision.
(define (elide? obj) #f)

;;; If (elide? OBJ) is true, return some sort of abbreviated list
;;; structure that might be helpful to the user in identifying the
;;; elided object.
;;; A default definition.
(define (elided-name obj) "")

;;; This is a pretty-printer that handles cyclic and shared structure.
(define (pprint original-obj)

  ;; Return true if OBJ should be elided in this call to pprint.
  ;; (We never elide the object we were passed itself.)
  (define (elide-this-call? obj)
    (and (not (eq? obj original-obj))
	 (elide? obj)))

  ;; First, traverse OBJ and build a hash table mapping objects
  ;; referenced more than once to #t, and everything else to #f.
  ;; (Only include entries for objects that might be interior nodes:
  ;; pairs and vectors.)
  (let ((shared
	 ;; Guile's stupid hash tables don't resize the table; the
	 ;; chains just get longer and longer.  So we need a big value here.
	 (let ((seen   (make-hash-table 65521))
	       (shared (make-hash-table 4093)))
	   (define (walk! obj)
	     (if (or (pair? obj) (vector? obj))
		 (if (hashq-ref seen obj)
		     (hashq-set! shared obj #t)
		     (begin
		       (hashq-set! seen obj #t)
		       (cond ((elide-this-call? obj))
			     ((pair? obj) (begin (walk! (car obj))
						 (walk! (cdr obj))))
			     ((vector? obj) (do ((i 0 (+ i 1)))
						 ((>= i (vector-length obj)))
					       (walk! (vector-ref obj i))))
			     (else (error "unhandled interior type")))))))
	   (walk! original-obj)
	   shared)))

    ;; A counter for shared structure labels.
    (define fresh-shared-label
      (let ((n 0))
	(lambda ()
	  (let ((l n))
	    (set! n (+ n 1))
	    l))))

    (define (print obj)
      (print-with-label obj (hashq-ref shared obj)))

    ;; Print an object OBJ, which SHARED maps to L.
    ;; L is always (hashq-ref shared obj), but we have that value handy
    ;; at times, so this entry point lets us avoid looking it up again.
    (define (print-with-label obj label)
      (if (number? label)
	  ;; If we've already visited this object, just print a
	  ;; reference to its label.
	  (map display `("#" ,label "#"))
	  (begin
	    ;; If it needs a label, attach one now.
	    (if (eqv? label #t) (let ((label (fresh-shared-label)))
				  (hashq-set! shared obj label)
				  (map display `("#" ,label "="))))
	    ;; Print the object.
	    (cond ((elide-this-call? obj)
		   (write (list '$ (add-elided-object obj) (elided-name obj))))
		  ((pair? obj) (begin (display "(")
				      (print-tail obj)))
		  ((vector? obj) (begin (display "#(")
					(do ((i 0 (+ i 1)))
					    ((>= i (vector-length obj)))
					  (print (vector-ref obj i))
					  (if (< (+ i 1) (vector-length obj))
					      (display " ")))
					(display ")")))
		  (else (write obj))))))

    ;; Print a pair P as if it were the tail of a list; assume the
    ;; opening paren and any previous elements have been printed.
    (define (print-tail obj)
      (print (car obj))
      (force-output)
      (let ((tail (cdr obj)))
	(if (null? tail)
	    (display ")")
	    ;; We use the dotted pair syntax if the cdr isn't a pair, but
	    ;; also if it needs to be labeled.
	    (let ((tail-label (hashq-ref shared tail)))
	      (if (or (not (pair? tail)) tail-label)
		  (begin (display " . ")
			 (print-with-label tail tail-label)
			 (display ")"))
		  (begin (display " ")
			 (print-tail tail)))))))

    (print original-obj)
    (newline)))

