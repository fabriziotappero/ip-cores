; Type system.
; This provides the low level classes for describing data, except for
; the actual type (confusingly enough) which is described in mode.scm.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; Array type.
; DIMENSIONS has a suitable initial value so (new <scalar>) to works.

(define <array> (class-make '<array> nil '(mode (dimensions . ())) nil))

; Return number of elements in array.

(method-make!
 <array> 'get-num-elms
 (lambda (self)
   (apply * (elm-get self 'dimensions)))
)

; Return mode of the array.

(method-make! <array> 'get-mode (lambda (self) (elm-get self 'mode)))

; Return the rank of the array (number of dimensions).

(method-make! <array> 'get-rank (lambda (self) (length (elm-get self 'dimensions)))
)

; Return shape of array

(method-make! <array> 'get-shape (lambda (self) (elm-get self 'dimensions))
)

; Return #t if X is an array.

(define (array? x) (class-instance? <array> x))

; Scalar type.

(define <scalar> (class-make '<scalar> '(<array>) nil nil))

(method-make-make! <scalar> '(mode))

; Return #t if X is a scalar.

(define (scalar? x) (and (array? x) (= (send x 'get-rank) 0)))

; Return number of bits in an element of TYPE.

(define (type-bits type)
  (mode:bits (send type 'get-mode))
)

; Integers.
; These are like scalars but are specified in bits.
; BITS is the size in bits.
; ATTRS contains !UNSIGNED [or nothing] or UNSIGNED.
;
; A mode is needed so we know how big a field is needed to record the value.
; It might be more appropriate to use a host mode though.
;
; FIXME: Need to separate rank from type.  scalar/array are not types.
;
;(define <integer> (class-make '<integer> nil '(attrs bits) nil))
;
;(method-make! <integer> 'get-atlist (lambda (self) (elm-get self 'attrs)))
;
;(method-make!
; <integer> 'get-mode 
; (lambda (self)
;   (mode-find (elm-get self 'bits)
;	      (if (has-attr? self 'UNSIGNED) 'UINT 'INT))
;   )
;)
;
; FIXME: Quick hack.  Revisit.
;
;(method-make! <integer> 'get-rank (lambda (self) 0))

; Structures.
; FIXME: Unfinished.

(define <struct> (class-make '<struct> nil '(members) nil))

; Parse a type spec.
; TYPE-SPEC is: (mode [(dimensions ...)])
;           or: ((mode bits) [(dimensions ...)])

(define (parse-type context type-spec)
  ; Preliminary error checking.
  (let ((expected
	 ", expected (mode [(dimensions)]) or ((mode bits) [(dimensions)])"))
    (if (not (list? type-spec))
	(parse-error context (string-append "invalid type spec" expected)
		     type-spec))
    (let ((len (length type-spec)))
      (if (or (< len 1)
	      (> len 2))
	  (parse-error context (string-append "invalid type spec" expected)
		       type-spec))
      ; Validate the mode spec.
      (cond ((symbol? (car type-spec))
	     #t) ; ok
	    ((list? (car type-spec))
	     (begin
	       (if (not (= (length (car type-spec)) 2))
		   (parse-error context
				(string-append "invalid mode in type spec"
					       expected)
				type-spec))
	       (if (not (symbol? (caar type-spec)))
		   (parse-error context
				(string-append "invalid mode in type spec"
					       expected)
				type-spec))
	       (if (not (integer? (cadar type-spec)))
		   (parse-error context
				(string-append "invalid #bits in type spec"
					       expected)
				type-spec))
	       ))
	     (else
	      (parse-error context
			   (string-append "invalid mode in type spec" expected)
			   type-spec)))
      ; Validate the dimension list if present.
      (if (= len 2)
	  (if (or (not (list? (cadr type-spec)))
		  (not (all-true? (map non-negative-integer?
				       (cadr type-spec)))))
	      (parse-error context
			   (string-append "invalid dimension spec in type spec"
					  expected)
			   type-spec)))
      ))

  ; Pick out the arguments.
  (let ((mode (if (list? (car type-spec)) (caar type-spec) (car type-spec)))
	(bits (if (list? (car type-spec)) (cadar type-spec) #f))
	(dims (if (> (length type-spec) 1) (cadr type-spec) nil)))

    ; Look up the mode and create the mode object.
    (let* ((base-mode (parse-mode-name context mode))
	   (mode-obj
	    (cond ((eq? mode 'INT)
		   (mode-make-int bits))
		  ((eq? mode 'UINT)
		   (mode-make-uint bits))
		  (else
		   (if (and bits (!= bits (mode:bits base-mode)))
		       (parse-error context "wrong number of bits for mode"
				    bits))
		   base-mode))))

      ; All done, create the <array> object.
      ; ??? Special casing scalars is a concession for apps that think
      ; scalars aren't arrays.  Not sure it should stay.
      (if (null? dims)
	  (make <scalar> mode-obj)
	  (make <array> mode-obj dims))))
)

; Bit ranges.
; ??? Perhaps this should live in a different source file, but for now
; it's here.
;
; Endianness is not recorded with the bitrange.
; Values are operated on a "word" at a time.
; This is to handle bi-endian systems: we don't want two copies of
; every bitrange.
;
; Instruction word sizes are based on the "base insn length" which is the
; number of bytes the cpu first looks at to decode an insn.  In cases where
; the total length is longer than the base insn length, the word length
; for the rest of the insn is the base insn length replicated as many times
; as necessary.  The trailing part [last few bytes] of the insn may not fill
; the entire word, in which case the numbering is adjusted for it.
; ??? Might need to have an insn-base-length and an insn-word-length.
;
; Instructions that have words of one endianness and sub-words of a different
; endianness are handled at a higher level.
;
; Bit numbering examples:
; [each byte is represented MSB to LSB, low address to high address]
;
; lsb0? = #f
; insn-word-length = 2
; endian = little
; | 8 ... 15 | 0 ... 7 | 24 ... 31 | 16 ... 23 | 40 ... 47 | 32 ... 39 |
;
; lsb0? = #t
; insn-word-length = 2
; endian = little
; [note that this is the little endian canonical form (*)
;  - word length is irrelevant]
; | 7 ... 0 | 15 ... 8 | 23 ... 16 | 31 ... 24 | 39 ... 32 | 47 ... 40 |
;
; lsb0? = #f
; insn-word-length = 2
; endian = big
; [note that this is the big endian canonical form (*)
;  - word length is irrelevant]
; | 0 ... 7 | 8 ... 15 | 16 ... 23 | 24 ... 31 | 32 ... 39 | 40 ... 47 |
;
; lsb0? = #t
; insn-word-length = 2
; endian = big
; | 15 ... 8 | 7 ... 0 | 31 ... 24 | 23 ... 16 | 47 ... 40 | 39 ... 32 |
;
; (*) NOTE: This canonical form should not be confused with what might be
; called the canonical form when writing .cpu ifield descriptions: lsb0? = #f.
; The ifield canonical form is lsb0? = #f because the starting bit number of
; ifields is defined to be the MSB.
; ---
; At the bitrange level, insns with different sized words is supported.
; This is because each <bitrange> contains the specs of the word it resides in.
; For example a 48 bit insn with a 16 bit opcode and a 32 bit immediate value
; might [but not necessarily] consist of one 16 bit "word" and one 32 bit
; "word".
;
; Examples:
;
; lsb0? = #f
; insn-word-length = 2, 4
; endian = little
; | 8 ... 15 | 0 ... 7 | 40 ... 47 | 32 ... 39 | 24 ... 31 | 16 ... 23 |
;
; lsb0? = #t
; insn-word-length = 2, 4
; endian = little
; | 7 ... 0 | 15 ... 8 | 23 ... 16 | 31 ... 24 | 39 ... 32 | 47 ... 40 |
;
; lsb0? = #f
; insn-word-length = 2, 4
; endian = big
; | 0 ... 7 | 8 ... 15 | 16 ... 23 | 24 ... 31 | 32 ... 39 | 40 ... 47 |
;
; lsb0? = #t
; insn-word-length = 2, 4
; endian = big
; | 15 ... 8 | 7 ... 0 | 47 ... 40 | 39 ... 32 | 31 ... 24 | 23 ... 16 |

(define <bitrange>
  (class-make '<bitrange>
	      nil
	      '(
		; offset in bits from the start of the insn of the word
		; in which the value resides [must be divisible by 8]
		; [this allows the bitrange to be independent of the lengths
		; of words preceding this one]
		word-offset
		; starting bit number within the word,
		; this is the MSB of the bitrange within the word
		; [externally, = word-offset + start]
		start
		; number of bits in the value
		length
		; length of word in which the value resides
		word-length
		; lsb = bit number 0?
		lsb0?
		)
	      nil)
)

; Accessor fns.

(define-getters <bitrange> bitrange
  (word-offset start length word-length lsb0?)
)

(define-setters <bitrange> bitrange
  ; lsb0? left out on purpose: not sure changing it should be allowed
  (word-offset start length word-length)
)

; Return a boolean indicating if two bitranges overlap.
;
; lsb0? = #t: 31 ...  0
; lsb0? = #f: 0  ... 31

(define (bitrange-overlap? start1 length1 start2 length2 lsb0?)
  (if lsb0?
      (let ((end1 (- start1 length1))
	    (end2 (- start2 length2)))
	(and (< end1 start2)
	     (> start1 end2)))
      (let ((end1 (+ start1 length1))
	    (end2 (+ start2 length2)))
	(and (> end1 start2)
	     (< start1 end2))))
)

; Return a boolean indicating if BITPOS is beyond bitrange START,LEN.
; ??? This needs more thought.

(define (bitpos-beyond? bitpos start length word-length lsb0?)
  (>= bitpos (+ start length))
)

; Return the offset of the word after <bitrange> br.

(define (bitrange-next-word br)
  (let ((word-offset (bitrange-word-offset br))
	(start (bitrange-start br))
	(length (bitrange-length br))
	(word-length (bitrange-word-length br))
	(lsb0? (bitrange-lsb0? br)))
    ; ??? revisit
    (+ word-offset word-length))
)

; Initialize/finalize support.

(define (types-init!)
  *UNSPECIFIED*
)

(define (types-finish!)
  *UNSPECIFIED*
)
