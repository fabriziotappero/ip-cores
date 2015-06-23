; Programmer development tools.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.
;
; This file contains a collection of programmer debugging tools.
; They're mainly intended for using cgen to debug other things,
; but any kind of debugging tool can go here.
; All routines require the application independent part of cgen to be loaded
; and the .cpu file to be loaded.  They do not require any particular
; application though (opcodes, simulator, etc.).  If they do, that's a bug.
; It may be that the appication has a generally useful routine that should
; live elsewhere, but that's it.
;
; These tools don't have to be particularily efficient (within reason).
; It's more important that they be simple and clear.
;
; Some tools require ifmt-compute! to be run.
; They will run it if necessary.
;
; Table of contents:
;
; pgmr-pretty-print-insn-format
;   cgen debugging tool, pretty prints the iformat of an <insn> object
;
; pgmr-pretty-print-insn-value
;   break out an instruction's value into its component fields
;
; pgmr-lookup-insn
;   given a random bit pattern for an instruction, lookup the insn and return
;   its <insn> object

; Pretty print the instruction's opcode value, for debugging.
; INSN is an <insn> object.

(define (pgmr-pretty-print-insn-format insn)

  (define (to-width width n-str)
    (string-take-with-filler (- width)
			     n-str
			     #\0))

  (define (dump-insn-mask mask insn-length)
    (string-append "0x" (to-width (quotient insn-length 4)
				  (number->string mask 16))
		   ", "
		   (string-map
		    (lambda (n)
		      (string-append " " (to-width 4 (number->string n 2))))
		    (reverse
		     (split-bits (make-list (quotient insn-length 4) 4)
				 mask)))))

  ; Print VALUE with digits not in MASK printed as "X".
  (define (dump-insn-value value mask insn-length)
    (string-append "0x" (to-width (quotient insn-length 4)
				  (number->string value 16))
		   ", "
		   (string-map
		    (lambda (n mask)
		      (string-append
		       " "
		       (list->string
			(map (lambda (char in-mask?)
			       (if in-mask? char #\X))
			     (string->list (to-width 4 (number->string n 2)))
			     (bits->bools mask 4)))))
		    (reverse
		     (split-bits (make-list (quotient insn-length 4) 4)
				 value))
		    (reverse
		     (split-bits (make-list (quotient insn-length 4) 4)
				 mask)))))

  (define (dump-ifield f)
    (string-append " Name: "
		   (obj:name f)
		   ", "
		   "Start: "
		   (number->string
		    (+ (bitrange-word-offset (-ifld-bitrange f))
		       (bitrange-start (-ifld-bitrange f))))
		   ", "
		   "Length: "
		   (number->string (ifld-length f))
		   "\n"))

  (let* ((iflds (sort-ifield-list (insn-iflds insn)
				  (not (current-arch-insn-lsb0?))))
	 (mask (compute-insn-base-mask iflds))
	 (mask-length (compute-insn-base-mask-length iflds)))

    (display
     (string-append
      "Instruction: " (obj:name insn)
      "\n"
      "Syntax: "
      (insn-syntax insn)
      "\n"
      "Fields:\n"
      (string-map dump-ifield iflds)
      "Instruction length (computed from ifield list): "
      (number->string (apply + (map ifld-length iflds)))
      "\n"
      "Mask:  "
      (dump-insn-mask mask mask-length)
      "\n"
      "Value: "
      (let ((value (apply +
			  (map (lambda (fld)
				 (ifld-value fld mask-length
					     (ifld-get-value fld)))
			       (find ifld-constant? (collect ifld-base-ifields (insn-iflds insn)))))))
	(dump-insn-value value mask mask-length))
      ; TODO: Print value spaced according to fields.
      "\n"
      )))
)

; Pretty print an instruction's value.

(define (pgmr-pretty-print-insn-value insn value)
  (define (dump-ifield ifld value name-width)
    (string-append
     (string-take name-width (obj:str-name ifld))
     ": "
     (number->string value)
     ", 0x"
     (number->hex value)
     "\n"))

  (let ((ifld-values (map (lambda (ifld)
			    (ifld-extract ifld insn value))
			  (insn-iflds insn)))
	(max-name-length (apply max
				(map string-length
				     (map obj:name
					  (insn-iflds insn)))))
	)

    (display
     (string-append
      "Instruction: " (obj:name insn)
      "\n"
      "Fields:\n"
      (string-map (lambda (ifld value)
		    (dump-ifield ifld value max-name-length))
		  (insn-iflds insn)
		  ifld-values)
      )))
)

; Return the <insn> object matching VALUE.
; VALUE is either a single number of size base-insn-bitsize,
; or a list of numbers for variable length ISAs.
; LENGTH is the total length of VALUE in bits.

(define (pgmr-lookup-insn length value)
  (arch-analyze-insns! CURRENT-ARCH
		       #t ; include aliases
		       #f) ; don't need to analyze semantics

  ; Return a boolean indicating if BASE matches the base part of <insn> INSN.
  (define (match-base base insn)
    (let ((mask (compute-insn-base-mask (insn-iflds insn)))
	  (ivalue (insn-value insn)))
      ; return (value & mask) == ivalue
      (= (logand base mask) ivalue)))

  (define (match-rest value insn)
    #t)

  (let ((base (if (list? value) (car value) value)))
    (let loop ((insns (current-insn-list)))
      (if (null? insns)
	  #f
	  (let ((insn (car insns)))
	    (if (and (= length (insn-length insn))
		     (match-base base insn)
		     (match-rest value insn))
		insn
		(loop (cdr insns)))))))
)
