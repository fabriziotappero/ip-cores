;;;; "logical.scm", bit access and operations for integers for Scheme
;;; Copyright (C) 1991, 1993 Aubrey Jaffer.
;
;Permission to copy this software, to redistribute it, and to use it
;for any purpose is granted, subject to the following restrictions and
;understandings.
;
;1.  Any copy made of this software must include this copyright notice
;in full.
;
;2.  I have made no warrantee or representation that the operation of
;this software will be error-free, and I am under no obligation to
;provide any services, by way of maintenance, update, or otherwise.
;
;3.  In conjunction with products arising from the use of this
;material, there shall be no use of my name in any advertising,
;promotional, or sales literature without prior written consent in
;each case.

(define logical:integer-expt
  (if (defined? 'inexact)
      expt
      (lambda (n k)
	(logical:ipow-by-squaring n k 1 *))))

(define (logical:ipow-by-squaring x k acc proc)
  (cond ((zero? k) acc)
	((= 1 k) (proc acc x))
	(else (logical:ipow-by-squaring (proc x x)
					(quotient k 2)
					(if (even? k) acc (proc acc x))
					proc))))

(define (logical:logand n1 n2)
  (cond ((= n1 n2) n1)
	((zero? n1) 0)
	((zero? n2) 0)
	(else
	 (+ (* (logical:logand (logical:ash-4 n1) (logical:ash-4 n2)) 16)
	    (vector-ref (vector-ref logical:boole-and (modulo n1 16))
			(modulo n2 16))))))

(define (logical:logior n1 n2)
  (cond ((= n1 n2) n1)
	((zero? n1) n2)
	((zero? n2) n1)
	(else
	 (+ (* (logical:logior (logical:ash-4 n1) (logical:ash-4 n2)) 16)
	    (- 15 (vector-ref (vector-ref logical:boole-and
					  (- 15 (modulo n1 16)))
			      (- 15 (modulo n2 16))))))))

(define (logical:logxor n1 n2)
  (cond ((= n1 n2) 0)
	((zero? n1) n2)
	((zero? n2) n1)
	(else
	 (+ (* (logical:logxor (logical:ash-4 n1) (logical:ash-4 n2)) 16)
	    (vector-ref (vector-ref logical:boole-xor (modulo n1 16))
			(modulo n2 16))))))

(define (logical:lognot n) (- -1 n))

(define (logical:logtest int1 int2)
  (not (zero? (logical:logand int1 int2))))

(define (logical:logbit? index int)
  (logical:logtest (logical:integer-expt 2 index) int))

(define (logical:copy-bit index to bool)
  (if bool
      (logical:logior to (logical:ash 1 index))
      (logical:logand to (logical:lognot (logical:ash 1 index)))))

(define (logical:bit-field n start end)
  (logical:logand (- (logical:integer-expt 2 (- end start)) 1)
		  (logical:ash n (- start))))

(define (logical:bitwise-if mask n0 n1)
  (logical:logior (logical:logand mask n0)
		  (logical:logand (logical:lognot mask) n1)))

(define (logical:copy-bit-field to start end from)
  (logical:bitwise-if
   (logical:ash (- (logical:integer-expt 2 (- end start)) 1) start)
   (logical:ash from start)
   to))

(define (logical:ash int cnt)
  (if (negative? cnt)
      (let ((n (logical:integer-expt 2 (- cnt))))
	(if (negative? int)
	    (+ -1 (quotient (+ 1 int) n))
	    (quotient int n)))
      (* (logical:integer-expt 2 cnt) int)))

(define (logical:ash-4 x)
  (if (negative? x)
      (+ -1 (quotient (+ 1 x) 16))
      (quotient x 16)))

(define (logical:logcount n)
  (cond ((zero? n) 0)
	((negative? n) (logical:logcount (logical:lognot n)))
	(else
	 (+ (logical:logcount (logical:ash-4 n))
	    (vector-ref '#(0 1 1 2 1 2 2 3 1 2 2 3 2 3 3 4)
			(modulo n 16))))))

(define (logical:integer-length n)
  (case n
    ((0 -1) 0)
    ((1 -2) 1)
    ((2 3 -3 -4) 2)
    ((4 5 6 7 -5 -6 -7 -8) 3)
    (else (+ 4 (logical:integer-length (logical:ash-4 n))))))

(define logical:boole-xor
 '#(#(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)
    #(1 0 3 2 5 4 7 6 9 8 11 10 13 12 15 14)
    #(2 3 0 1 6 7 4 5 10 11 8 9 14 15 12 13)
    #(3 2 1 0 7 6 5 4 11 10 9 8 15 14 13 12)
    #(4 5 6 7 0 1 2 3 12 13 14 15 8 9 10 11)
    #(5 4 7 6 1 0 3 2 13 12 15 14 9 8 11 10)
    #(6 7 4 5 2 3 0 1 14 15 12 13 10 11 8 9)
    #(7 6 5 4 3 2 1 0 15 14 13 12 11 10 9 8)
    #(8 9 10 11 12 13 14 15 0 1 2 3 4 5 6 7)
    #(9 8 11 10 13 12 15 14 1 0 3 2 5 4 7 6)
    #(10 11 8 9 14 15 12 13 2 3 0 1 6 7 4 5)
    #(11 10 9 8 15 14 13 12 3 2 1 0 7 6 5 4)
    #(12 13 14 15 8 9 10 11 4 5 6 7 0 1 2 3)
    #(13 12 15 14 9 8 11 10 5 4 7 6 1 0 3 2)
    #(14 15 12 13 10 11 8 9 6 7 4 5 2 3 0 1)
    #(15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0)))

(define logical:boole-and
 '#(#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
    #(0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1)
    #(0 0 2 2 0 0 2 2 0 0 2 2 0 0 2 2)
    #(0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3)
    #(0 0 0 0 4 4 4 4 0 0 0 0 4 4 4 4)
    #(0 1 0 1 4 5 4 5 0 1 0 1 4 5 4 5)
    #(0 0 2 2 4 4 6 6 0 0 2 2 4 4 6 6)
    #(0 1 2 3 4 5 6 7 0 1 2 3 4 5 6 7)
    #(0 0 0 0 0 0 0 0 8 8 8 8 8 8 8 8)
    #(0 1 0 1 0 1 0 1 8 9 8 9 8 9 8 9)
    #(0 0 2 2 0 0 2 2 8 8 10 10 8 8 10 10)
    #(0 1 2 3 0 1 2 3 8 9 10 11 8 9 10 11)
    #(0 0 0 0 4 4 4 4 8 8 8 8 12 12 12 12)
    #(0 1 0 1 4 5 4 5 8 9 8 9 12 13 12 13)
    #(0 0 2 2 4 4 6 6 8 8 10 10 12 12 14 14)
    #(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)))

(define logand logical:logand)
(define logior logical:logior)
(define logxor logical:logxor)
(define lognot logical:lognot)
(define logtest logical:logtest)
(define logbit? logical:logbit?)
(define copy-bit logical:copy-bit)
(define ash logical:ash)
(define logcount logical:logcount)
(define integer-length logical:integer-length)
(define bit-field logical:bit-field)
(define bit-extract logical:bit-field)
(define copy-bit-field logical:copy-bit-field)
(define ipow-by-squaring logical:ipow-by-squaring)
(define integer-expt logical:integer-expt)
