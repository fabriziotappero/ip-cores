; Generic Utilities.
; Copyright (C) 2000, 2005, 2006, 2007, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; These utilities are neither object nor cgen centric.
; They're generic, non application-specific utilities.
; There are a few exceptions, keep them to a minimum.
;
; Conventions:
; - the prefix "gen-" comes from cgen's convention that procs that return C
;   code, and only those procs, are prefixed with "gen-"

(define nil '())

; Hobbit support code; for when not using hobbit.
; FIXME: eliminate this stuff ASAP.

(defmacro /fastcall-make (proc) proc)

(defmacro fastcall4 (proc arg1 arg2 arg3 arg4)
  (list proc arg1 arg2 arg3 arg4)
)

(defmacro fastcall5 (proc arg1 arg2 arg3 arg4 arg5)
  (list proc arg1 arg2 arg3 arg4 arg5)
)

(defmacro fastcall6 (proc arg1 arg2 arg3 arg4 arg5 arg6)
  (list proc arg1 arg2 arg3 arg4 arg5 arg6)
)

(defmacro fastcall7 (proc arg1 arg2 arg3 arg4 arg5 arg6 arg7)
  (list proc arg1 arg2 arg3 arg4 arg5 arg6 arg7)
)

; Value doesn't matter too much here, just ensure it's portable.
(define *UNSPECIFIED* (if #f 1))

(define assert-fail-msg "assertion failure:")

(defmacro assert (expr)
  `(if (not ,expr)
       (error assert-fail-msg ',expr))
)

(define verbose-level 0)

(define (verbose-inc!)
  (set! verbose-level (+ verbose-level 1))
)

(define (verbose? level) (>= verbose-level level))

; Print to stderr, takes an arbitrary number of objects, possibly nested.
; ??? Audit callers, can we maybe just use "display" here (except that
; we still might want some control over the output).

(define message
  (lambda args
    (for-each (lambda (str)
		(if (pair? str)
		    (if (list? str)
			;; ??? Incorrect for improper lists, later.
			(begin
			  (message "(")
			  (for-each (lambda (s) (message s " ")) str)
			  (message ")"))
			(message "(" (car str) " . " (cdr str) ")"))
		    (display str (current-error-port))))
	      args))
)

; Print a message if the verbosity level calls for it.
; This is a macro as a bit of cpu may be spent computing args,
; and we only want to spend it if the result will be printed.

(defmacro logit (level . args)
  `(if (>= verbose-level ,level) (message ,@args))
)

; Return a string of N spaces.

(define (spaces n) (make-string n #\space))

; Write N spaces to PORT, or the current output port if elided.

(define (write-spaces n . port)
  (let ((port (if (null? port) (current-output-port) (car port))))
    (write (spaces n) port))
)

; Concatenate all the arguments and make a string.  Symbols are
; converted to strings.
(define (string/symbol-append . sequences)
  (define (sequence->string o) (if (symbol? o) (symbol->string o) o))
  (apply string-append (map sequence->string sequences)))

; Often used idiom.

(define (string-map fn . args) (apply string-append (apply map (cons fn args))))

; Collect a flat list of returned sublists from the lambda fn applied over args.

(define (collect fn . args) (apply append (apply map (cons fn args))))

; Map over value entries in an alist.
; 'twould be nice if this were a primitive.

(define (amap fn args)
  (map fn (map cdr args))
)

; Like map but accept a proper or improper list.
; An improper list is (a b c . d).
; FN must be a proc of one argument.

(define (map1-improper fn l)
  (let ((result nil))
    (let loop ((last #f) (l l))
      (cond ((null? l)
	     result)
	    ((pair? l)
	     (if last
		 (begin
		   (set-cdr! last (cons (fn (car l)) nil))
		   (loop (cdr last) (cdr l)))
		 (begin
		   (set! result (cons (fn (car l)) nil))
		   (loop result (cdr l)))))
	    (else
	     (if last
		 (begin
		   (set-cdr! last (fn l))
		   result)
		 (fn l))))))
)

; Turn string or symbol STR into a proper C symbol.
; The result is a string.
; We assume STR has no leading digits.
; All invalid characters are turned into '_'.
; FIXME: Turn trailing "?" into "_p".

(define (gen-c-symbol str)
  (if (not (or (string? str) (symbol? str)))
      (error "gen-c-symbol: not symbol or string:" str))
  (map-over-string (lambda (c) (if (id-char? c) c #\_))
		   (->string str))
)

; Turn string or symbol STR into a proper file name, which is
; defined to be the same as gen-c-symbol except use -'s instead of _'s.
; The result is a string.

(define (gen-file-name str)
  (if (not (or (string? str) (symbol? str)))
      (error "gen-file-name: not symbol or string:" str))
  (map-over-string (lambda (c) (if (id-char? c) c #\-))
		   (->string str))
)

; Turn STR into lowercase.

(define (string-downcase str)
  (map-over-string (lambda (c) (char-downcase c)) str)
)

; Turn STR into uppercase.

(define (string-upcase str)
  (map-over-string (lambda (c) (char-upcase c)) str)
)

; Turn SYM into lowercase.

(define (symbol-downcase sym)
  (string->symbol (string-downcase (symbol->string sym)))
)

; Turn SYM into uppercase.

(define (symbol-upcase sym)
  (string->symbol (string-upcase (symbol->string sym)))
)

; Symbol sorter.

(define (symbol<? a b)
  (string<? (symbol->string a) (symbol->string b))
)

; Drop N chars from string S.
; If N is negative, drop chars from the end.
; It is ok to drop more characters than are in the string, the result is "".

(define (string-drop n s)
  (cond ((>= n (string-length s)) "")
	((< n 0) (substring s 0 (+ (string-length s) n)))
	(else (substring s n (string-length s))))
)

; Drop the leading char from string S (assumed to have at least 1 char).

(define (string-drop1 s)
  (string-drop 1 s)
)

; Return the leading N chars from string STR.
; This has APL semantics:
; N > length: FILLER chars are appended
; N < 0: take from the end of the string and prepend FILLER if necessary

(define (string-take-with-filler n str filler)
  (let ((len (string-length str)))
    (if (< n 0)
	(let ((n (- n)))
	  (string-append (if (> n len)
			     (make-string (- n len) filler)
			     "")
			 (substring str (max 0 (- len n)) len)))
	(string-append (substring str 0 (min len n))
		       (if (> n len)
			   (make-string (- n len) filler)
			   ""))))
)

(define (string-take n str)
  (string-take-with-filler n str #\space)
)

; Return the leading char from string S (assumed to have at least 1 char).

(define (string-take1 s)
  (substring s 0 1)
)

; Return the index of char C in string S or #f if not found.

(define (string-index s c)
  (let loop ((i 0))
    (cond ((= i (string-length s)) #f)
	  ((char=? c (string-ref s i)) i)
	  (else (loop (1+ i)))))
)

; Cut string S into a list of strings using delimiter DELIM (a character).

(define (string-cut s delim)
  (let loop ((start 0)
	     (end 0)
	     (length (string-length s))
	     (result nil))
    (cond ((= end length)
	   (if (> end start)
	       (reverse! (cons (substring s start end) result))
	       (reverse! result)))
	  ((char=? (string-ref s end) delim)
	   (loop (1+ end) (1+ end) length (cons (substring s start end) result)))
	  (else (loop start (1+ end) length result))))
)

; Convert a list of elements to a string, inserting DELIM (a string)
; between elements.
; L can also be a string or a number.

(define (stringize l delim)
  (cond ((string? l) l)
	((number? l) (number->string l))
	((symbol? l) (symbol->string l))
	((list? l)
	 (string-drop
	  (string-length delim)
	  (string-map (lambda (elm)
			(string-append delim
				       (stringize elm delim)))
		      l)))
	(else (error "stringize: can't handle:" l)))
)

; Same as string-append, but accepts symbols too.
; PERF: This implementation may be unacceptably slow.  Revisit.

(define stringsym-append
  (lambda args
    (apply string-append
	   (map (lambda (s)
		  (if (symbol? s)
		      (symbol->string s)
		      s))
		args)))
)

; Same as symbol-append, but accepts strings too.

(define symbolstr-append
  (lambda args
    (string->symbol (apply stringsym-append args)))
)

; Given a symbol or a string, return the string form.

(define (->string s)
  (if (symbol? s)
      (symbol->string s)
      s)
)

; Given a symbol or a string, return the symbol form.

(define (->symbol s)
  (if (string? s)
      (string->symbol s)
      s)
)

; Output routines.

;; Given some state that has a setter function (SETTER NEW-VALUE) and
;; a getter function (GETTER), call THUNK with the state set to VALUE,
;; and restore the original value when THUNK returns.  Ensure that the
;; original value is restored whether THUNK returns normally, throws
;; an exception, or invokes a continuation that leaves the call's
;; dynamic scope.

(define (setter-getter-fluid-let setter getter value thunk)
  (let ((swap (lambda ()
		(let ((temp (getter)))
		  (setter value)
		  (set! value temp)))))
    (dynamic-wind swap thunk swap)))
      

;; Call THUNK with the current input and output ports set to PORT, and
;; then restore the current ports to their original values.
;; 
;; This ensures the current ports get restored whether THUNK exits
;; normally, throws an exception, or leaves the call's dynamic scope
;; by applying a continuation.

(define (with-input-and-output-to port thunk)
  (setter-getter-fluid-let
   set-current-input-port current-input-port port
   (lambda ()
     (setter-getter-fluid-let
      set-current-output-port current-output-port port
      thunk))))


; Extension to the current-output-port.
; Only valid inside string-write.

(define -current-print-state #f)

; Create a print-state object.
; This is written in portable Scheme so we don't use COS objects, etc.

(define (make-print-state)
  (vector 'print-state 0)
)

; print-state accessors.

(define (pstate-indent pstate) (vector-ref pstate 1))
(define (pstate-set-indent! pstate indent) (vector-set! pstate 1 indent))

; Special print commands (embedded in args).

(define (pstate-cmd? x) (and (vector? x) (eq? (vector-ref x 0) 'pstate)))

;(define /endl (vector 'pstate '/endl)) ; ??? needed?
(define /indent (vector 'pstate '/indent))
(define (/indent-set n) (vector 'pstate '/indent-set n))
(define (/indent-add n) (vector 'pstate '/indent-add n))

; Process a pstate command.

(define (pstate-cmd-do pstate cmd)
  (assert (pstate-cmd? cmd))
  (case (vector-ref cmd 1)
    ((/endl)
     "\n")
    ((/indent)
     (let ((indent (pstate-indent pstate)))
       (string-append (make-string (quotient indent 8) #\tab)
		      (make-string (remainder indent 8) #\space))))
    ((/indent-set)
     (pstate-set-indent! pstate (vector-ref cmd 2))
     "")
    ((/indent-add)
     (pstate-set-indent! pstate (+ (pstate-indent pstate)
				   (vector-ref cmd 2)))
     "")
    (else
     (error "unknown pstate command" (vector-ref cmd 1))))
)

; Write STRINGS to current-output-port.
; STRINGS is a list of things to write.  Supported types are strings, symbols,
; lists, procedures.  Lists are printed by applying string-write recursively.
; Procedures are thunks that return the string to write.
;
; The result is the empty string.  This is for debugging where this
; procedure is modified to return its args, rather than write them out.

(define string-write
  (lambda strings
    (let ((pstate (make-print-state)))
      (set! -current-print-state pstate)
      (for-each (lambda (elm) (-string-write pstate elm))
		strings)
      (set! -current-print-state #f)
      ""))
)

; Subroutine of string-write and string-write-map.

(define (-string-write pstate expr)
  (cond ((string? expr) (display expr)) ; not write, we want raw text
	((symbol? expr) (display expr))
	((procedure? expr) (-string-write pstate (expr)))
	((pstate-cmd? expr) (display (pstate-cmd-do pstate expr)))
	((list? expr) (for-each (lambda (x) (-string-write pstate x)) expr))
	(else (error "string-write: bad arg:" expr)))
  *UNSPECIFIED*
)

; Combination of string-map and string-write.

(define (string-write-map proc arglist)
  (let ((pstate -current-print-state))
    (for-each (lambda (arg) (-string-write pstate (proc arg)))
	      arglist))
  ""
)

; Build up an argument for string-write.

(define string-list list)
(define string-list-map map)

; Subroutine of string-list->string.  Does same thing -string-write does.

(define (-string-list-flatten pstate strlist)
  (cond ((string? strlist) strlist)
	((symbol? strlist) strlist)
	((procedure? strlist) (-string-list-flatten pstate (strlist)))
	((pstate-cmd? strlist) (pstate-cmd-do pstate strlist))
	((list? strlist) (apply string-append
				(map (lambda (str)
				       (-string-list-flatten pstate str))
				     strlist)))
	(else (error "string-list->string: bad arg:" strlist)))
)

; Flatten out a string list.

(define (string-list->string strlist)
  (-string-list-flatten (make-print-state) strlist)
)

; Prefix CHARS, a string of characters, with backslash in STR.
; STR is either a string or list of strings (to any depth).
; ??? Quick-n-dirty implementation.

(define (backslash chars str)
  (if (string? str)
      ; quick check for any work to do
      (if (any-true? (map (lambda (c)
			    (string-index str c))
			  (string->list chars)))
	  (let loop ((result "") (str str))
	    (if (= (string-length str) 0)
		result
		(loop (string-append result
				     (if (string-index chars (string-ref str 0))
					 "\\"
					 "")
				     (substring str 0 1))
		      (substring str 1 (string-length str)))))
	  str)
      ; must be a list
      (if (null? str)
	  nil
	  (cons (backslash chars (car str))
		(backslash chars (cdr str)))))
)

; Return a boolean indicating if S is bound to a value.
;(define old-symbol-bound? symbol-bound?)
;(define (symbol-bound? s) (old-symbol-bound? #f s))

; Return a boolean indicating if S is a symbol and is bound to a value.

(define (bound-symbol? s)
  (and (symbol? s)
       (or (symbol-bound? #f s)
	   ;(module-bound? cgen-module s)
	   ))
)

; Return X.

(define (identity x) x)

; Test whether X is a `form' (non-empty list).
; ??? Is `form' the right word to use here?
; One can argue we should also test for a valid car.  If so, it's the
; name that's wrong not the code (because the code is what I want).

(define (form? x) (and (not (null? x)) (list? x)))

; Return the number of arguments to ARG-SPEC, a valid argument list
; of `lambda'.
; The result is a pair: number of fixed arguments, varargs indicator (#f/#t).

(define (num-args arg-spec)
  (if (symbol? arg-spec)
      '(0 . #t)
      (let loop ((count 0) (arg-spec arg-spec))
	(cond ((null? arg-spec) (cons count #f))
	      ((null? (cdr arg-spec)) (cons (+ count 1) #f))
	      ((pair? (cdr arg-spec)) (loop (+ count 1) (cdr arg-spec)))
	      (else (cons (+ count 1) #t)))))
)

; Return a boolean indicating if N args is ok to pass to a proc with
; an argument specification of ARG-SPEC (a valid argument list of `lambda').

(define (num-args-ok? n arg-spec)
  (let ((processed-spec (num-args arg-spec)))
    (and
     ; Ensure enough fixed arguments.
     (>= n (car processed-spec))
     ; If more args than fixed args, ensure varargs.
     (or (= n (car processed-spec))
	 (cdr processed-spec))))
)

; Take N elements from list L.
; If N is negative, take elements from the end.
; If N is larger than the length, the extra elements are NIL.
; FIXME: incomplete
; FIXME: list-tail has args reversed (we should conform)

(define (list-take n l)
  (let ((len (length l)))
    (if (< n 0)
	(list-tail l (+ len n))
	(let loop ((result nil) (l l) (i 0))
	  (if (= i n)
	      (reverse! result)
	      (loop (cons (car l) result) (cdr l) (+ i 1))))))
)

; Drop N elements from list L.
; FIXME: list-tail has args reversed (we should conform)

(define (list-drop n l)
  (let loop ((n n) (l l))
    (if (> n 0)
	(loop (- n 1) (cdr l))
	l))
)

; Drop N elements from the end of L.
; FIXME: list-tail has args reversed (we should conform)

(define (list-tail-drop n l)
  (reverse! (list-drop n (reverse l)))
)

;; left fold

(define (foldl kons accum lis) 
  (if (null? lis) accum 
      (foldl kons (kons accum (car lis)) (cdr lis))))

;; right fold

(define (foldr kons knil lis) 
  (if (null? lis) knil 
      (kons (car lis) (foldr kons knil (cdr lis)))))

;; filter list on predicate

(define (filter p ls)
  (foldr (lambda (x a) (if (p x) (cons x a) a)) 
	 '() ls))

; APL's +\ operation on a vector of numbers.

(define (plus-scan l)
  (letrec ((-plus-scan (lambda (l result)
			 (if (null? l)
			     result
			     (-plus-scan (cdr l)
					 (cons (if (null? result)
						   (car l)
						   (+ (car l) (car result)))
					       result))))))
    (reverse! (-plus-scan l nil)))
)

; Remove duplicate elements from sorted list L.
; Currently supported elements are symbols (a b c) and lists ((a) (b) (c)).
; NOTE: Uses equal? for comparisons.

(define (remove-duplicates l)
  (let loop ((l l) (result nil))
    (cond ((null? l) (reverse! result))
	  ((null? result) (loop (cdr l) (cons (car l) result)))
	  ((equal? (car l) (car result)) (loop (cdr l) result))
	  (else (loop (cdr l) (cons (car l) result)))
	  )
    )
)

; Return a boolean indicating if each element of list satisfies its
; corresponding predicates.  The length of L must be equal to the length
; of PREDS.

(define (list-elements-ok? l preds)
  (and (list? l)
       (= (length l) (length preds))
       (all-true? (map (lambda (pred elm) (pred elm)) preds l)))
)

; Remove duplicates from unsorted list L.
; KEY-GENERATOR is a lambda that takes a list element as input and returns
; an equal? key to use to determine duplicates.
; The first instance in a set of duplicates is always used.
; This is not intended to be applied to large lists with an expected large
; result (where sorting the list first would be faster), though one could
; add such support later.
;
; ??? Rename to follow memq/memv/member naming convention.

(define (nub l key-generator)
  (let loop ((l l) (keys (map key-generator l)) (result nil))
    (if (null? l)
	(reverse! (map cdr result))
	(if (assv (car keys) result)
	    (loop (cdr l) (cdr keys) result)
	    (loop (cdr l) (cdr keys) (acons (car keys) (car l)
					     result)))))
)

; Return a boolean indicating if list L1 is a subset of L2.
; Uses memq.

(define (subset? l1 l2)
  (let loop ((l1 l1))
    (if (null? l1)
	#t
	(if (memq (car l1) l2)
	    (loop (cdr l1))
	    #f)))
)

; Return intersection of two lists.

(define (intersection a b) 
  (foldl (lambda (l e) (if (memq e a) (cons e l) l)) '() b))

; Return union of two lists.

(define (union a b) 
  (foldl (lambda (l e) (if (memq e l) l (cons e l))) a b))

; Return a count of the number of elements of list L1 that are in list L2.
; Uses memq.

(define (count-common l1 l2)
  (let loop ((result 0) (l1 l1))
    (if (null? l1)
	result
	(if (memq (car l1) l2)
	    (loop (+ result 1) (cdr l1))
	    (loop result (cdr l1)))))
)

; Remove duplicate elements from sorted alist L.
; L must be sorted by name.

(define (alist-nub l)
  (let loop ((l l) (result nil))
    (cond ((null? l) (reverse! result))
	  ((null? result) (loop (cdr l) (cons (car l) result)))
	  ((eq? (caar l) (caar result)) (loop (cdr l) result))
	  (else (loop (cdr l) (cons (car l) result)))
	  )
    )
)

; Return a copy of alist L.

(define (alist-copy l)
  ; (map cons (map car l) (map cdr l)) ; simple way
  ; presumably more efficient way (less cons cells created)
  (map (lambda (elm)
	 (cons (car elm) (cdr elm)))
       l)
)

; Return the order in which to select elements of L sorted by SORT-FN.
; The result is origin 0.

(define (sort-grade l sort-fn)
  (let ((sorted (sort (map cons (iota (length l)) l)
		      (lambda (a b) (sort-fn (cdr a) (cdr b))))))
    (map car sorted))
)

; Return ALIST sorted on the name in ascending order.

(define (alist-sort alist)
  (sort alist
	(lambda (a b)
	  (string<? (symbol->string (car a))
		    (symbol->string (car b)))))
)

; Return a boolean indicating if C is a leading id char.
; '@' is treated as an id-char as it's used to delimit something that
; sed will alter.

(define (leading-id-char? c)
  (or (char-alphabetic? c)
      (char=? c #\_)
      (char=? c #\@))
)

; Return a boolean indicating if C is an id char.
; '@' is treated as an id-char as it's used to delimit something that
; sed will alter.

(define (id-char? c)
  (or (leading-id-char? c)
      (char-numeric? c))
)

; Return the length of the identifier that begins S.
; Identifiers are any of letter, digit, _, @.
; The first character must not be a digit.
; ??? The convention is to use "-" between cgen symbols, not "_".
; Try to handle "-" here as well.

(define (id-len s)
  (if (leading-id-char? (string-ref s 0))
      (let ((len (string-length s)))
	(let loop ((n 0))
	  (if (and (< n len)
		   (id-char? (string-ref s n)))
	      (loop (1+ n))
	      n)))
      0)
)

; Return number of characters in STRING until DELIMITER.
; Returns #f if DELIMITER not present.
; FIXME: Doesn't yet support \-prefixed delimiter (doesn't terminate scan).

(define (chars-until-delimiter string delimiter)
  (let loop ((str string) (result 0))
    (cond ((= (string-length str) 0)
	   #f)
	  ((char=? (string-ref str 0) delimiter)
	   result)
	  (else (loop (string-drop1 str) (1+ result)))))
)

; Apply FN to each char of STR.

(define (map-over-string fn str)
  (do ((tmp (string-copy (if (symbol? str) (symbol->string str) str)))
       (i (- (string-length str) 1) (- i 1)))
      ((< i 0) tmp)
    (string-set! tmp i (fn (string-ref tmp i)))
    )
)

; Return a range.
; It must be distinguishable from a list of numbers.

(define (minmax min max) (cons min max))

; Move VALUE of LENGTH bits to position START in a word of SIZE bits.
; LSB0? is non-#f if bit numbering goes LSB->MSB.
; Otherwise it goes MSB->LSB.
; START-LSB? is non-#f if START denotes the least significant bit.
; Otherwise START denotes the most significant bit.
; N is assumed to fit in the field.

(define (word-value start length size lsb0? start-lsb? value)
  (if lsb0?
      (if start-lsb?
	  (logsll value start)
	  (logsll value (+ (- start length) 1)))
      (if start-lsb?
	  (logsll value (- size start 1))
	  (logsll value (- size (+ start length)))))
)

; Return a bit mask of LENGTH bits in a word of SIZE bits starting at START.
; LSB0? is non-#f if bit numbering goes LSB->MSB.
; Otherwise it goes MSB->LSB.
; START-LSB? is non-#f if START denotes the least significant bit.
; Otherwise START denotes the most significant bit.

(define (word-mask start length size lsb0? start-lsb?)
  (if lsb0?
      (if start-lsb?
	  (logsll (mask length) start)
	  (logsll (mask length) (+ (- start length) 1)))
      (if start-lsb?
	  (logsll (mask length) (- size start 1))
	  (logsll (mask length) (- size (+ start length)))))
)

; Extract LENGTH bits at bit number START in a word of SIZE bits from VALUE.
; LSB0? is non-#f if bit numbering goes LSB->MSB.
; Otherwise it goes MSB->LSB.
; START-LSB? is non-#f if START denotes the least significant bit.
; Otherwise START denotes the most significant bit.
;
; ??? bit-extract takes a big-number argument but still uses logand
; which doesn't so we don't use it

(define (word-extract start length size lsb0? start-lsb? value)
  (if lsb0?
      (if start-lsb?
	  (remainder (logslr value start) (integer-expt 2 length))
	  (remainder (logslr value (+ (- start length) 1)) (integer-expt 2 length)))
      (if start-lsb?
	  (remainder (logslr value (- size start 1)) (integer-expt 2 length))
	  (remainder (logslr value (- size (+ start length))) (integer-expt 2 length))))
)

; Return a bit mask of size SIZE beginning at the LSB.

(define (mask size)
  (- (logsll 1 size) 1)
)

; Split VAL into pieces of bit size LENGTHS.
; e.g. (split-bits '(8 2) 997) -> (229 3)
; There are as many elements in the result as there are in LENGTHS.
; Note that this can result in a loss of information.

(define (split-bits lengths val)
  (letrec ((split1
	    (lambda (lengths val result)
	      (if (null? lengths)
		  result
		  (split1 (cdr lengths)
			  (quotient val (integer-expt 2 (car lengths)))
			  (cons (remainder val (integer-expt 2 (car lengths)))
				result))))))
    (reverse! (split1 lengths val nil)))
)

; Generalized version of split-bits.
; e.g. (split-value '(10 10 10) 1234) -> (4 3 2 1) ; ??? -> (1 2 3 4) ?
; (split-value '(10 10) 1234) -> (4 3)
; There are as many elements in the result as there are in BASES.
; Note that this can result in a loss of information.

(define (split-value bases val)
  (letrec ((split1
	    (lambda (bases val result)
	      (if (null? bases)
		  result
		  (split1 (cdr bases)
			  (quotient val (car bases))
			  (cons (remainder val (car bases))
				result))))))
    (reverse! (split1 bases val nil)))
)

; Convert bits to bytes.

(define (bits->bytes bits) (quotient (+ 7 bits) 8))

; Convert bytes to bits.

(define (bytes->bits bytes) (* bytes 8))

; Return a list of integers.
; Usage:
; (.iota count)            ; start=0, incr=1
; (.iota count start)      ; incr=1
; (.iota count start incr)

(define (iota count . start-incr)
  (if (> (length start-incr) 2)
      (error "iota: wrong number of arguments:" start-incr))
  (if (< count 0)
      (error "iota: count must be non-negative:" n))
  (let ((start (if (pair? start-incr) (car start-incr) 0))
	(incr (if (= (length start-incr) 2) (cadr start-incr) 1)))
    (let loop ((i start) (count count) (result '()))
      (if (= count 0)
	  (reverse! result)
	  (loop (+ i incr) (- count 1) (cons i result)))))
)

; Return a list of the first N powers of 2.

(define (powers-of-2 n)
  (cond ((= n 0) nil)
	(else (cons (integer-expt 2 (1- n)) (powers-of-2 (1- n))))
	)
  ; Another way: (map (lambda (n) (ash 1 n)) (iota n))
)

; I'm tired of writing (not (= foo bar)).

(define (!= a b) (not (= a b)))

; Return #t if BIT-NUM (which is starting from LSB), is set in the binary
; representation of non-negative integer N.

(define (bit-set? n bit-num)
  ; ??? Quick hack to work around missing bignum support.
  ;(= 1 (cg-logand (logslr n bit-num) 1))
  (if (>= n #x20000000)
      (if (>= bit-num 16)
	  (logbit? (- bit-num 16) (logslr n 16))
	  (logbit? bit-num (remainder n 65536)))
      (logbit? bit-num n))
)

; Return #t if each element of bools is #t.  Since Scheme considers any
; non-#f value as #t we do too.
; (all-true? '()) is #t since that is the identity element.

(define (all-true? bools)
  (cond ((null? bools) #t)
	((car bools) (all-true? (cdr bools)))
	(else #f))
)

; Return #t if any element of BOOLS is #t.
; If BOOLS is empty, return #f.

(define (any-true? bools)
  (cond ((null? bools) #f)
	((car bools) #t)
	(else (any-true? (cdr bools))))
)

; Return count of true values.

(define (count-true flags)
  (let loop ((result 0) (flags flags))
    (if (null? flags)
	result
	(loop (+ result (if (car flags) 1 0))
	      (cdr flags))))
)

; Return count of all ones in BITS.

(define (count-bits bits)
  (let loop ((result 0) (bits bits))
    (if (= bits 0)
	result
	(loop (+ result (remainder bits 2)) (quotient bits 2))))
)

; Convert bits in N #f/#t.
; LENGTH is the length of N in bits.

(define (bits->bools n length)
  (do ((result (make-list length #f))
       (i 0 (+ i 1)))
      ((= i length) (reverse! result))
    (list-set! result i (if (bit-set? n i) #t #f))
    )
)

; Print a C integer.

(define (gen-integer val)
  (cond ((and (<= #x-80000000 val) (> #x80000000 val))
	 (number->string val))
	((and (<= #x80000000 val) (>= #xffffffff val))
	 ; ??? GCC complains if not affixed with "U" but that's not k&r.
	 ;(string-append (number->string val) "U"))
	 (string-append "0x" (number->string val 16)))
	(else (error "Number too large for gen-integer:" val)))
)

; Return higher/lower part of double word integer.

(define (high-part val)
  (logslr val 32)
)
(define (low-part val)
  (remainder val #x100000000)
)

; Logical operations.

(define (logslr val shift) (ash val (- shift)))
(define logsll ash) ; (logsll val shift) (ash val shift))
; logand, logior, logxor defined by guile so we don't need to
; (define (logand a b) ...)
; (define (logxor a b) ...)
; (define (logior a b) ...)
;
; On the other hand they didn't support bignums, so the cgen-binary
; defines cg-log* that does.  These are just a quick hack that only
; handle what currently needs handling.

(define (cg-logand a b)
  (if (or (>= a #x20000000)
	  (>= b #x20000000))
      (+ (logsll (logand (logslr a 16) (logslr b 16)) 16)
	 (logand (remainder a 65536) (remainder b 65536)))
      (logand a b))
)

(define (cg-logxor a b)
  (if (or (>= a #x20000000)
	  (>= b #x20000000))
      (+ (logsll (logxor (logslr a 16) (logslr b 16)) 16)
	 (logxor (remainder a 65536) (remainder b 65536)))
      (logxor a b))
)

; Return list of bit values for the 1's in X.

(define (bit-vals x)
  (let loop ((result nil) (mask 65536))
    (cond ((= mask 0) result)
	  ((> (logand x mask) 0) (loop (cons mask result) (logslr mask 1)))
	  (else (loop result (logslr mask 1)))))
)

; Return bit representation of N in LEN bits.
; e.g. (bit-rep 6 3) -> (1 1 0)

(define (bit-rep n len)
  (cond ((= len 0) nil)
	((> (logand n (logsll 1 (- len 1))) 0)
	 (cons 1 (bit-rep n (- len 1))))
	(else (cons 0 (bit-rep n (- len 1))))))

; Return list of all bit values from 0 to N.
; e.g. (bit-patterns 3) -> ((0 0 0) (0 0 1) (0 1 0) ... (1 1 1))

(define (bit-patterns len)
  (map (lambda (x) (bit-rep x len)) (iota (logsll 1 len)))
)

; Compute the list of all indices from bits missing in MASK.
; e.g. (missing-bit-indices #xff00 #xffff) -> (0 1 2 3 ... 255)

(define (missing-bit-indices mask full-mask)
  (let* ((bitvals (bit-vals (logxor mask full-mask)))
	 (selectors (bit-patterns (length bitvals)))
	 (map-star (lambda (sel) (map * sel bitvals)))
	 (compute-indices (lambda (sel) (apply + (map-star sel)))))
    (map compute-indices selectors))
)

; Return #t if n is a non-negative integer.

(define (non-negative-integer? n)
  (and (integer? n)
       (>= n 0))
)

; Convert a list of numbers to a string, separated by SEP.
; The result is prefixed by SEP too.

(define (numbers->string nums sep)
  (string-map (lambda (elm) (string-append sep (number->string elm))) nums)
)

; Convert a number to a hex string.

(define (number->hex num)
  (number->string num 16)
)

; Given a list of numbers NUMS, generate text to pass them as arguments to a
; C function.  We assume they're not the first argument and thus have a
; leading comma.

(define (gen-int-args nums)
  (numbers->string nums ", ")
)

; Given a C expression or a list of C expressions, return a comma separated
; list of them.
; In the case of more than 0 elements the leading ", " is present so that
; there is no edge case in the case of 0 elements when the caller is appending
; the result to an initial set of arguments (the number of commas equals the
; number of elements).  The caller is responsible for dropping the leading
; ", " if necessary.  Note that `string-drop' can handle the case where more
; characters are dropped than are present.

(define (gen-c-args exprs)
  (cond ((null? exprs) "")
	((pair? exprs) (string-map (lambda (elm) (string-append ", " elm))
				   exprs))
	((equal? exprs "") "")
	(else (string-append ", " exprs)))
)

; Return a list of N macro argument names.

(define (macro-args n)
  (map (lambda (i) (string-append "a" (number->string i)))
       (map 1+ (iota n)))
)

; Return C code for N macro argument names.
; (gen-macro-args 4) -> ", a1, a2, a3, a4"

(define (gen-macro-args n)
  (gen-c-args (macro-args n))
)

; Return a string to reference an array.
; INDICES is either a (possibly empty) list of indices or a single index.
; The values can either be numbers or strings (/symbols).

(define (gen-array-ref indices)
  (let ((gen-index (lambda (idx)
		     (string-append "["
				    (cond ((number? idx) (number->string idx))
					  (else idx))
				    "]"))))
    (cond ((null? indices) "")
	  ((pair? indices) ; list of indices?
	   (string-map gen-index indices))
	  (else (gen-index indices))))
)

; Return list element N or #f if list L is too short.

(define (list-maybe-ref l n)
  (if (> (length l) n)
      (list-ref l n)
      #f)
)

; Return list of index numbers of elements in list L that satisfy PRED.
; I is usually 0.

(define (find-index i pred l)
  (define (find1 i pred l result)
    (cond ((null? l) result)
	  ((pred (car l)) (find1 (+ 1 i) pred (cdr l) (cons i result)))
	  (else (find1 (+ 1 i) pred (cdr l) result))))
  (reverse! (find1 i pred l nil))
)

; Return list of elements of L that satisfy PRED.

(define (find pred l)
  (define (find1 pred l result)
    (cond ((null? l) result)
	  ((pred (car l)) (find1 pred (cdr l) (cons (car l) result)))
	  (else (find1 pred (cdr l) result))))
  (reverse! (find1 pred l nil))
)

; Return first element of L that satisfies PRED or #f if there is none.

(define (find-first pred l)
  (cond ((null? l) #f)
	((pred (car l)) (car l))
	(else (find-first pred (cdr l))))
)

; Return list of FN applied to elements of L that satisfy PRED.

(define (find-apply fn pred l)
  (cond ((null? l) nil)
	((pred (car l)) (cons (fn (car l)) (find-apply fn pred (cdr l))))
	(else (find-apply fn pred (cdr l))))
)

; Given a list L, look up element ELM and return its index.
; If not found, return #f.
; I is added to the result.
; (Yes, in one sense I is present to simplify the implementation.  Sue me.)

(define (eqv-lookup-index elm l i)
  (cond ((null? l) #f)
	((eqv? elm (car l)) i)
	(else (eqv-lookup-index elm (cdr l) (1+ i))))
)

; Given an associative list L, look up entry for symbol S and return its index.
; If not found, return #f.
; Eg: (lookup 'element2 '((element1 1) (element2 2)))
; I is added to the result.
; (Yes, in one sense I is present to simplify the implementation.  Sue me.)
; NOTE: Uses eq? for comparisons.

(define (assq-lookup-index s l i)
  (cond ((null? l) #f)
	((eqv? s (caar l)) i)
	(else (assq-lookup-index s (cdr l) (1+ i))))
)

; Return the index of element ELM in list L or #f if not found.
; If found, I is added to the result.
; (Yes, in one sense I is present to simplify the implementation.  Sue me.)
; NOTE: Uses equal? for comparisons.

(define (element-lookup-index elm l i)
  (cond ((null? l) #f)
	((equal? elm (car l)) i)
	(else (element-lookup-index elm (cdr l) (1+ i))))
)

; Return #t if ELM is in ELM-LIST.
; NOTE: Uses equal? for comparisons (via `member').

(define (element? elm elm-list)
  (->bool (member elm elm-list))
)

; Return the set of all possible combinations of elements in list L
; according to the following rules:
; - each element of L is either an atom (non-list) or a list
; - each list element is (recursively) interpreted as a set of choices
; - the result is a list of all possible combinations of elements
;
; Example: (list-expand '(a b (1 2 (3 4)) c (5 6)))
; --> ((a b 1 c d 5)
;      (a b 1 c d 6)
;      (a b 2 c d 5)
;      (a b 2 c d 6)
;      (a b 3 c d 5)
;      (a b 3 c d 6)
;      (a b 4 c d 5)
;      (a b 4 c d 6))

(define (list-expand l)
  #f ; ??? wip
)

; Given X, a number or symbol, reduce it to a constant if possible.
; Numbers always reduce to themselves.
; Symbols are reduced to a number if they're defined as such,
; or to an enum constant if one exists; otherwise X is returned unchanged.
; Requires: symbol-bound? enum-lookup-val

(define (reduce x)
  (if (number? x)
      x
      ; A symbol bound to a number?
      (if (and (symbol? x) (symbol-bound? #f x) (number? (eval1 x)))
	  (eval1 x)
	  ; An enum value that has a known numeric value?
	  (let ((e (enum-lookup-val x)))
	    (if (number? (car e))
		(car e)
		; Otherwise return X unchanged.
		x))))
)

; If OBJ has a dump method call it, otherwise return OBJ untouched.

(define (dump obj)
  (if (method-present? obj 'dump)
      (send obj 'dump)
      obj)
)

; Copyright messages.

; Pair of header,trailer parts of copyright.

(define copyright-fsf
  (cons "\
THIS FILE IS MACHINE GENERATED WITH CGEN.

Copyright 1996-2009 Free Software Foundation, Inc.
"
	"\
   This file is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3, or (at your option)
   any later version.

   It is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
   License for more details.

   You should have received a copy of the GNU General Public License along
   with this program; if not, write to the Free Software Foundation, Inc.,
   51 Franklin Street - Fifth Floor, Boston, MA 02110-1301, USA.
"
))

; Pair of header,trailer parts of copyright.

(define copyright-red-hat
  (cons "\
THIS FILE IS MACHINE GENERATED WITH CGEN.

Copyright (C) 2000-2009 Red Hat, Inc.
"
	"\
"))

; Set this to one of copyright-fsf, copyright-red-hat.

(define CURRENT-COPYRIGHT copyright-fsf)

; Packages.

(define package-gnu-binutils-gdb "\
This file is part of the GNU Binutils and/or GDB, the GNU debugger.
")

(define package-gnu-simulators "\
This file is part of the GNU simulators.
")

(define package-red-hat-simulators "\
This file is part of the Red Hat simulators.
")

(define package-cgen "\
This file is part of CGEN.
")

; Return COPYRIGHT, with FILE-DESC as the first line
; and PACKAGE as the name of the package which the file belongs in.
; COPYRIGHT is a pair of (header . trailer).

(define (gen-c-copyright file-desc copyright package)
  (string-append "/* " file-desc "\n\n"
		 (car copyright)
		 "\n" package "\n"
		 (cdr copyright)
		 "\n*/\n\n")
)

; File operations.

; Delete FILE, handling the case where it doesn't exist.

(define (delete-file-noerr file)
  ; This could also use file-exists?, but it's nice to have a few examples
  ; of how to use `catch' lying around.
  (catch 'system-error (lambda () (delete-file file))
	 (lambda args #f))
)

; Create FILE, point current-output-port to it, and call WRITE-FN.
; FILE is always overwritten.
; GEN-FN either writes output to stdout or returns the text to write,
; the last thing we do is write the text returned by WRITE-FN to FILE.

(define (file-write file write-fn)
  (delete-file-noerr file)
  (let ((left-over-text (with-output-to-file file write-fn)))
    (let ((port (open-file file "a")))
      (display left-over-text port)
      (close-port port))
    #t)
)

; Return the size in bytes of FILE.

(define (file-size file)
  (let ((stat (%stat file)))
    (if stat
	(vector-ref (%stat file) 7)
	-1))
)

; Time operations.

; Return the current time.
; The result is a black box understood only by time-elapsed.

(define (time-current) (gettimeofday))

; Return the elapsed time in milliseconds since START.

(define (time-elapsed start)
  (let ((now (gettimeofday)))
    (+ (* (- (car now) (car start)) 1000)
       (quotient (- (cdr now) (cdr start)) 1000)))
)

; Run PROC and return the number of milliseconds it took to execute it N times.

(define (time-proc n proc)
  (let ((now (time-current)))
    (do ((i 0 (+ i 1))) ((= i n) (time-elapsed now))
      (proc)))
)

;; Debugging repls.

; Record of arguments passed to debug-repl, so they can be accessed in
; the repl loop.

(define debug-env #f)

; Return list of recorded variables for debugging.

(define (debug-var-names) (map car debug-env))

; Return value of recorded var NAME.

(define (debug-var name) (assq-ref debug-env name))

; A handle on /dev/tty, so we can be sure we're talking with the user.
; We open this the first time we actually need it.

(define debug-tty #f)

; Return the port we should use for interacting with the user,
; opening it if necessary.

(define (debug-tty-port)
  (if (not debug-tty)
      (set! debug-tty (open-file "/dev/tty" "r+")))
  debug-tty)

; Enter a repl loop for debugging purposes.
; Use (quit) to exit cgen completely.
; Use (debug-quit) or (quit 0) to exit the debugging session and
; resume argument processing.
;
; ENV-ALIST can be anything, but it is intended to be an alist of values
; the caller will want to be able to access in the repl loop.
; It is stored in global `debug-env'.

(define (debug-repl env-alist)
  (with-input-and-output-to
   (debug-tty-port)
   (lambda ()
     (set! debug-env env-alist)
     (let loop ()
       (let ((rc (top-repl)))
	 (if (null? rc)
	     (quit 1))			; indicate error to `make'
	 (if (not (equal? rc '(0)))
	     (loop))))))
)

; Utility for debug-repl.

(define (debug-quit)
  ; Keep around for later debugging.
  ;(set! debug-env #f)

  (quit 0)
)

; Macro to simplify calling debug-repl.
; Usage: (debug-repl-env var-name1 var-name2 ...)
;
; This is for debugging cgen itself, and is inserted into code at the point
; where one wants to start a repl.

(defmacro debug-repl-env var-names
  (let ((env (map (lambda (var-name)
		    (list 'cons (list 'quote var-name) var-name))
		  var-names)))
    (list 'debug-repl (cons 'list env)))
)
