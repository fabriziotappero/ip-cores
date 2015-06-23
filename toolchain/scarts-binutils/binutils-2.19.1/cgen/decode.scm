; Application independent decoder support.
; Copyright (C) 2000, 2004, 2009 Red Hat, Inc.
; This file is part of CGEN.
;
; This file provides utilities for building instruction set decoders.
; At present its rather limited, and is geared towards the simulator
; where the goal is hyper-efficiency [not that there isn't room for much
; improvement, but rather that that's what the current focus is].
;
; The CPU description file provides the first pass's bit mask with the
; `decode-assist' spec.  This gives the decoder a head start on how to
; efficiently decode the instruction set.  The rest of the decoder is
; determined algorithmically.
; ??? Need to say more here.
;
; The main entry point is decode-build-table.
;
; Main procedure call tree:
; decode-build-table
;     -build-slots
;     -build-decode-table-guts
;         -build-decode-table-entry
;             -build-slots
;             -build-decode-table-guts
;
; -build-slots/-build-decode-table-guts are recursively called to construct a
; tree of "table-guts" elements, and then the application recurses on the
; result.  For example see sim-decode.scm.
;
; FIXME: Don't create more than 3 shifts (i.e. no more than 3 groups).
; FIXME: Exits when insns are unambiguously determined, even if there are more
; opcode bits to examine.

; Decoder data structures and accessors.
; The set of instruction is internally recorded as a tree of two data
; structures: "table-guts" and "table-entry".
; [The choice of "table-guts" is historical, a better name will come to mind
; eventually.]

; Decoded tables data structure, termed "table guts".
; A simple data structure of 4 elements:
; bitnums:  list of bits that have been used thus far to decode the insn
; startbit: bit offset in instruction of value in C local variable `insn'
; bitsize:  size of value in C local variable `insn', the number
;           of bits of the instruction read thus far
; entries:  list of insns that match the decoding thus far,
;           each entry in the list is a `dtable-entry' record

(define (dtable-guts-make bitnums startbit bitsize entries)
  (vector bitnums startbit bitsize entries)
)

; Accessors.
(define (dtable-guts-bitnums tg) (vector-ref tg 0))
(define (dtable-guts-startbit tg) (vector-ref tg 1))
(define (dtable-guts-bitsize tg) (vector-ref tg 2))
(define (dtable-guts-entries tg) (vector-ref tg 3))

; A decoded subtable.
; A simple data structure of 3 elements:
; key: name to distinguish this subtable from others, used for lookup
; table: a table-guts element
; name: name of C variable containing the table
;
; The implementation uses a list so the lookup can use assv.

(define (subdtable-make key table name)
  (list key table name)
)

; Accessors.
(define (subdtable-key st) (car st))
(define (subdtable-table st) (cadr st))
(define (subdtable-name st) (caddr st))

; List of decode subtables.
(define -decode-subtables nil)

(define (subdtable-lookup key) (assv key -decode-subtables))

; Add SUBTABLE-GUTS to the subtables list if not already present.
; Result is the subtable entry already present, or new entry.
; The key is computed so as to make comparisons possible with assv.

(define (subdtable-add subtable-guts name)
  (let* ((key (string->symbol
	       (string-append
		(numbers->string (dtable-guts-bitnums subtable-guts) " ")
		" " (number->string (dtable-guts-bitsize subtable-guts))
		(string-map
		 (lambda (elm)
		   (case (dtable-entry-type elm)
		     ((insn)
		      (stringsym-append " " (obj:name (dtable-entry-value elm))))
		     ((table)
		      (stringsym-append " " (subdtable-name (dtable-entry-value elm))))
		     ((expr)
		      (stringsym-append " " (exprtable-name (dtable-entry-value elm))))
		     (else (error "bad dtable entry type:"
				  (dtable-entry-type elm)))))
		 (dtable-guts-entries subtable-guts)))))
	 (entry (subdtable-lookup key)))
    (if (not entry)
	(begin
	  (set! -decode-subtables (cons (subdtable-make key subtable-guts name)
					-decode-subtables))
	  (car -decode-subtables))
	entry))
)

; An instruction and predicate for final matching.

(define (exprtable-entry-make insn expr)
  (vector insn expr (rtl-find-ifields expr))
)

; Accessors.

(define (exprtable-entry-insn entry) (vector-ref entry 0))
(define (exprtable-entry-expr entry) (vector-ref entry 1))
(define (exprtable-entry-iflds entry) (vector-ref entry 2))

; Return a pseudo-cost of processing exprentry X.

(define (exprentry-cost x)
  (let ((expr (exprtable-entry-expr x)))
    (case (rtx-name expr)
      ((member) (length (rtx-member-set expr)))
      (else 4)))
)

; Sort an exprtable, optimum choices first.
; Basically an optimum choice is a cheaper choice.

(define (exprtable-sort expr-list)
  (sort expr-list
	(lambda (a b)
	  (let ((costa (exprentry-cost a))
		(costb (exprentry-cost b)))
	    (< costa costb))))
)

; Return the name of the expr table for INSN-EXPRS,
; which is a list of exprtable-entry elements.

(define (-gen-exprtable-name insn-exprs)
  (string-map (lambda (x)
		(string-append (obj:str-name (exprtable-entry-insn x))
			       "-"
			       (rtx-strdump (exprtable-entry-expr x))))
	      insn-exprs)
)

; A set of instructions that need expressions to distinguish.
; Typically the expressions are ifield-assertion specs.
; INSN-EXPRS is a sorted list of exprtable-entry elements.
; The list is considered sorted in the sense that the first insn to satisfy
; its predicate is chosen.

(define (exprtable-make name insn-exprs)
  (vector name insn-exprs)
)

; Accessors.

(define (exprtable-name etable) (vector-ref etable 0))
(define (exprtable-insns etable) (vector-ref etable 1))

; Decoded table entry data structure.
; A simple data structure of 3 elements:
; index: index in the parent table
; entry type indicator: 'insn or 'table or 'expr
; value: the insn or subtable or exprtable

(define (dtable-entry-make index type value)
  (assert value)
  (vector index type value)
)

; Accessors.
(define (dtable-entry-index te) (vector-ref te 0))
(define (dtable-entry-type te) (vector-ref te 1))
(define (dtable-entry-value te) (vector-ref te 2))

; Return #t if BITNUM is a good bit to use for decoding.
; MASKS is a list of opcode masks.
; MASK-LENS is a list of lengths of each value in MASKS.
; BITNUM is the number of the bit to test.  It's value depends on LSB0?.
; It can be no larger than the smallest element in MASKS.
; E.g. If MASK-LENS consists of 16 and 32 and LSB0? is #f, BITNUM must
; be from 0 to 15.
; FIXME: This isn't quite right.  What if LSB0? = #t?  Need decode-bitsize.
; LSB0? is non-#f if bit number 0 is the least significant bit.
;
; FIXME: This is just a first cut, but the governing intent is to not require
; targets to specify decode tables, hints, or algorithms.
; Certainly as it becomes useful they can supply such information.
; The point is to avoid having to as much as possible.
;
; FIXME: Bit numbers shouldn't be considered in isolation.
; It would be better to compute use counts of all of them and then see
; if there's a cluster of high use counts.

(define (-usable-decode-bit? masks mask-lens bitnum lsb0?)
  (let* ((has-bit (map (lambda (msk len)
			 (bit-set? msk (if lsb0? bitnum (- len bitnum 1))))
		       masks mask-lens)))
    (or (all-true? has-bit)
	; If half or more insns use the bit, it's a good one.
	; FIXME: An empirical guess at best.
	(>= (count-true has-bit) (quotient (length has-bit) 2))
	))
)

; Compute population counts for each bit.  Return it as a vector indexed by bit
; number.  Rather than computing raw popularity, attempt to compute
; "disinguishing value" or inverse-entropy for each bit.  The idea is that the
; larger the number for any particular bit slot, the more instructions it can
; be used to distinguish.  Raw mask popularity is not enough -- popular masks
; may include useless "reserved" fields whose values don't change, and thus are
; useless in distinguishing.
;
; NOTE: mask-lens are not necessarily all the same value.
; E.g. for the m32r it can consist of both 16 and 32.
; But all masks must exist in the window specified by STARTBIT,DECODE-BITSIZE,
; and all bits in the result must live in that window.
; If no distinguishing bit fits in the window, return an empty vector.

(define (-distinguishing-bit-population masks mask-lens values lsb0?)
  (let* ((max-length (apply max mask-lens))
	 (0-population (make-vector max-length 0))
	 (1-population (make-vector max-length 0))
	 (num-insns (length masks)))
    ; Compute the 1- and 0-population vectors
    (for-each (lambda (mask len value)
		(logit 5 " population count mask=" (number->hex mask) " len=" len "\n")
		(for-each (lambda (bitno)
			    (let ((lsb-bitno (if lsb0? bitno (- len bitno 1))))
			      ; ignore this bit if it's not set in the mask
			      (if (bit-set? mask lsb-bitno)
				(let ((chosen-pop-vector (if (bit-set? value lsb-bitno)
							     1-population 0-population)))
				  (vector-set! chosen-pop-vector bitno
					       (+ 1 (vector-ref chosen-pop-vector bitno)))))))
			  (-range len)))
	      masks mask-lens values)
    ; Compute an aggregate "distinguishing value" for each bit.
    (list->vector
     (map (lambda (p0 p1)
	    (logit 4 p0 "/" p1 " ")
	    ; The most useful bits for decoding are those with counts in both
	    ; p0 and p1. These are the bits which distinguish one insn from
	    ; another. Assign these bits a high value (greater than num-insns).
	    ;
	    ; The next most useful bits are those with counts in either p0
	    ; or p1.  These bits represent specializations of other insns.
	    ; Assign these bits a value between 0 and (num-insns - 1). Note that
	    ; p0 + p1 is guaranteed to be <= num-insns. The value 0 is assigned
	    ; to bits for which p0 or p1 is equal to num_insns. These are bits
	    ; which are always 1 or always 0 in the ISA and are useless for
	    ; decoding purposes.
	    ;
	    ; Bits with no count in either p0 or p1 are useless for decoding
	    ; and should never be considered. Assigning these bits a value of
	    ; 0 ensures this.
	    (cond
	     ((= (+ p0 p1) 0) 0)
	     ((= (* p0 p1) 0) (- num-insns (+ p0 p1)))
	     (else (+ num-insns (sqrt (* p0 p1))))))
	  (vector->list 0-population) (vector->list 1-population))))
)

; Return a list (0 ... LIMIT-1).

(define (-range limit)
  (let loop ((i 0)
	     (indices (list)))
    (if (= i limit)
	(reverse! indices)
	(loop (+ i 1) (cons i indices))))
)

; Return a list (BASE ... BASE+SIZE-1).

(define (-range2 base size)
  (let loop ((i base)
	     (indices (list)))
    (if (= i (+ base size))
	(reverse! indices)
	(loop (+ i 1) (cons i indices))))
)

; Return a copy of VECTOR, with all entries with given INDICES set
; to VALUE.

(define (-vector-copy-set-all vector indices value)
  (let ((new-vector (make-vector (vector-length vector))))
    (for-each (lambda (index)
		(vector-set! new-vector index (if (memq index indices)
						  value
						  (vector-ref vector index))))
	      (-range (vector-length vector)))
    new-vector)
)

; Return a list of indices whose counts in the given vector exceed the given
; threshold.
; Sort them in decreasing order of popularity.

(define (-population-above-threshold population threshold)
  (let* ((unsorted
	  (find (lambda (index) (if (vector-ref population index)
				    (>= (vector-ref population index) threshold)
				    #f))
		(-range (vector-length population))))
	 (sorted
	  (sort unsorted (lambda (i1 i2) (> (vector-ref population i1)
					    (vector-ref population i2))))))
    sorted)
)

; Return the top few most popular indices in the population vector,
; ignoring any that are already used (marked by #f).  Don't exceed
; `size' unless the clustering is just too good to pass up.

(define (-population-top-few population size)
  (let loop ((old-picks (list))
	     (remaining-population population)
	     (count-threshold (apply max (map (lambda (value) (or value 0))
					      (vector->list population)))))
      (let* ((new-picks (-population-above-threshold remaining-population count-threshold)))
	(logit 4 "-population-top-few"
	       " desired=" size
	       " picks=(" old-picks ") pop=(" remaining-population ")"
	       " threshold=" count-threshold " new-picks=(" new-picks ")\n")
	(cond
	 ; No point picking bits with population count of zero.  This leads to
	 ; the generation of layers of subtables which resolve nothing.  Generating
	 ; these tables can slow the build by several orders of magnitude.
	 ((= 0 count-threshold)
	  (logit 2 "-population-top-few: count-threshold is zero!\n")
	  old-picks)
	 ; No new matches?
	 ((null? new-picks)
	  (if (null? old-picks)
	      (logit 2 "-population-top-few: No bits left to pick from!\n"))
	  old-picks)
	 ; Way too many matches?
	 ((> (+ (length new-picks) (length old-picks)) (+ size 3))
	  (list-take (+ 3 size) (append old-picks new-picks))) ; prefer old-picks
	 ; About right number of matches?
	 ((> (+ (length new-picks) (length old-picks)) (- size 1))
	  (append old-picks new-picks))
	 ; Not enough?  Lower the threshold a bit and try to add some more.
	 (else
	  (loop (append old-picks new-picks)
		(-vector-copy-set-all remaining-population new-picks #f)
		; Notice magic clustering decay parameter
		;  vvvv
		(* 0.75 count-threshold))))))
)

; Given list of insns, return list of bit numbers of constant bits in opcode
; that they all share (or mostly share), up to MAX elements.
; ALREADY-USED is a list of bitnums we can't use.
; STARTBIT is the bit offset of the instruction value that C variable `insn'
; holds (note that this is independent of LSB0?).
; DECODE-BITSIZE is the number of bits of the insn that `insn' holds.
; LSB0? is non-#f if bit number 0 is the least significant bit.
;
; Nil is returned if there are none, meaning that there is an ambiguity in
; the specification up to the current word as defined by startbit,
; decode-bitsize, and more bytes need to be fetched.
;
; We assume INSN-LIST matches all opcode bits before STARTBIT (if any).
; FIXME: Revisit, as a more optimal decoder is sometimes achieved by doing
; a cluster of opcode bits that appear later in the insn, and then coming
; back to earlier ones.
;
; All insns are assumed to start at the same address so we handle insns of
; varying lengths - we only analyze the common bits in all of them.
;
; Note that if we get called again to compute further opcode bits, we
; start looking at STARTBIT again (rather than keeping track of how far in
; the insn word we've progressed).  We could do this as an optimization, but
; we also have to handle the case where the initial set of decode bits misses
; some and thus we have to go back and look at them.  It may also turn out
; that an opcode bit is skipped over because it doesn't contribute much
; information to the decoding process (see -usable-decode-bit?).  As the
; possible insn list gets wittled down, the bit will become significant.  Thus
; the optimization is left for later.
; Also, see preceding FIXME: We can't proceed past startbit + decode-bitsize
; until we've processed all bits up to startbit + decode-bitsize.

(define (decode-get-best-bits insn-list already-used startbit max decode-bitsize lsb0?)
  (let* ((raw-population (-distinguishing-bit-population (map insn-base-mask insn-list)
							 (map insn-base-mask-length insn-list)
							 (map insn-value insn-list)
							 lsb0?))
	 ;; (undecoded (if lsb0?
	 ;; 		(-range2 startbit (+ startbit decode-bitsize))
	 ;;		(-range2 (- startbit decode-bitsize) startbit)))
	 (used+undecoded already-used) ; (append already-used undecoded))
	 (filtered-population (-vector-copy-set-all raw-population used+undecoded #f))
	 (favorite-indices (-population-top-few filtered-population max))
	 (sorted-indices (sort favorite-indices (lambda (a b) 
						  (if lsb0? (> a b) (< a b))))))
    (logit 3
	   "Best decode bits (prev=" already-used " start=" startbit " decode=" decode-bitsize ")"
	   "=>"
	   "(" sorted-indices ")\n")
    sorted-indices)
)

(define (OLDdecode-get-best-bits insn-list already-used startbit max decode-bitsize lsb0?)
  (let ((masks (map insn-base-mask insn-list))
	; ??? We assume mask lengths are repeatedly used for insns longer
	; than the base insn size.
	(mask-lens (map insn-base-mask-length insn-list))
	(endbit (if lsb0?
		    -1 ; FIXME: for now (gets sparc port going)
		    (+ startbit decode-bitsize)))
	(incr (if lsb0? -1 1)))
    (let loop ((result nil)
	       (bitnum (if lsb0?
			   (+ startbit (- decode-bitsize 1))
			   startbit)))
      (if (or (= (length result) max) (= bitnum endbit))
	  (reverse! result)
	  (if (and (not (memq bitnum already-used))
		   (-usable-decode-bit? masks mask-lens bitnum lsb0?))
	      (loop (cons bitnum result) (+ bitnum incr))
	      (loop result (+ bitnum incr))))
      ))
)

; Return list of decode table entry numbers for INSN's opcode bits BITNUMS.
; This is the indices into the decode table that match the instruction.
; LSB0? is non-#f if bit number 0 is the least significant bit.
;
; Example: If BITNUMS is (0 1 2 3 4 5), and the constant (i.e. opcode) part of
; the those bits of INSN is #b1100xx (where 'x' indicates a non-constant
; part), then the result is (#b110000 #b110001 #b110010 #b110011).

(define (-opcode-slots insn bitnums lsb0?)
  (letrec ((opcode (insn-value insn))
	   (insn-len (insn-base-mask-length insn))
	   (decode-len (length bitnums))
	   (compute (lambda (val insn-len decode-len bl default)
		      ;(display (list val insn-len decode-len bl)) (newline)
		      ; Oh My God.  This isn't tail recursive.
		      (if (null? bl)
			  0
			  (+ (if (or (and (>= (car bl) insn-len) (= default 1))
				     (and (< (car bl) insn-len)
					  (bit-set? val
						    (if lsb0?
							(car bl)
							(- insn-len (car bl) 1)))))
				 (integer-expt 2 (- (length bl) 1))
				 0)
			     (compute val insn-len decode-len (cdr bl) default))))))
    (let* ((opcode (compute (insn-value insn) insn-len decode-len bitnums 0))
	   (opcode-mask (compute (insn-base-mask insn) insn-len decode-len bitnums 1))
	   (indices (missing-bit-indices opcode-mask (- (integer-expt 2 decode-len) 1))))
      (logit 3 "insn =" (obj:name insn)
	     " insn-value=" (number->hex (insn-value insn))
	     " insn-base-mask=" (number->hex (insn-base-mask insn))
	     " insn-len=" insn-len
	     " decode-len=" decode-len
	     " opcode=" (number->hex opcode)
	     " opcode-mask=" (number->hex opcode-mask)
	     " indices=" indices "\n")
      (map (lambda (index) (+ opcode index)) indices)))
)

; Subroutine of -build-slots.
; Fill slot in INSN-VEC that INSN goes into.
; BITNUMS is the list of opcode bits.
; LSB0? is non-#f if bit number 0 is the least significant bit.
;
; Example: If BITNUMS is (0 1 2 3 4 5) and the constant (i.e. opcode) part of
; the first six bits of INSN is #b1100xx (where 'x' indicates a non-constant
; part), then elements 48 49 50 51 of INSN-VEC are cons'd with INSN.
; Each "slot" is a list of matching instructions.

(define (-fill-slot! insn-vec insn bitnums lsb0?)
  ;(display (string-append "fill-slot!: " (obj:str-name insn) " ")) (display bitnums) (newline)
  (let ((slot-nums (-opcode-slots insn bitnums lsb0?)))
    ;(display (list "Filling slot(s)" slot-nums "...")) (newline)
    (for-each (lambda (slot-num)
		(vector-set! insn-vec slot-num
			     (cons insn (vector-ref insn-vec slot-num))))
	      slot-nums)
    *UNSPECIFIED*
    )
)

; Given a list of constant bitnums (ones that are predominantly, though perhaps
; not always, in the opcode), record each insn in INSN-LIST in the proper slot.
; LSB0? is non-#f if bit number 0 is the least significant bit.
; The result is a vector of insn lists.  Each slot is a list of insns
; that go in that slot.

(define (-build-slots insn-list bitnums lsb0?)
  (let ((result (make-vector (integer-expt 2 (length bitnums)) nil)))
    ; Loop over each element, filling RESULT.
    (for-each (lambda (insn)
		(-fill-slot! result insn bitnums lsb0?))
	      insn-list)
    result)
)

; Compute the name of a decode table, prefixed with PREFIX.
; INDEX-LIST is a list of pairs: list of bitnums, table entry number,
; in reverse order of traversal (since they're built with cons).
; INDEX-LIST may be empty.

(define (-gen-decode-table-name prefix index-list)
  (set! index-list (reverse index-list))
  (string-append
   prefix
   "table"
   (string-map (lambda (elm) (string-append "_" (number->string elm)))
		; CDR of each element is the table index.
	       (map cdr index-list)))
)

; Generate one decode table entry for INSN-VEC at INDEX.
; INSN-VEC is a vector of slots where each slot is a list of instructions that
; map to that slot (opcode value).  If a slot is nil, no insn has that opcode
; value so the decoder marks it as being invalid.
; STARTBIT is the bit offset of the instruction value that C variable `insn'
; holds (note that this is independent of LSB0?).
; DECODE-BITSIZE is the number of bits of the insn that `insn' holds.
; INDEX-LIST is a list of pairs: list of bitnums, table entry number.
; LSB0? is non-#f if bit number 0 is the least significant bit.
; INVALID-INSN is an <insn> object to use for invalid insns.
; The result is a dtable-entry element (or "slot").

; ??? For debugging.
(define -build-decode-table-entry-args #f)

(define (-build-decode-table-entry insn-vec startbit decode-bitsize index index-list lsb0? invalid-insn)
  (let ((slot (vector-ref insn-vec index)))
    (logit 2 "Processing decode entry "
	   (number->string index)
	   " in "
	   (-gen-decode-table-name "decode_" index-list)
	   ", "
	   (cond ((null? slot) "invalid")
		 ((= 1 (length slot)) (insn-syntax (car slot)))
		 (else "subtable"))
	   " ...\n")

    (cond
     ; If no insns map to this value, mark it as invalid.
     ((null? slot) (dtable-entry-make index 'insn invalid-insn))

     ; If only one insn maps to this value, that's it for this insn.
     ((= 1 (length slot))
      ; FIXME: Incomplete: need to check further opcode bits.
      (dtable-entry-make index 'insn (car slot)))

     ; Otherwise more than one insn maps to this value and we need to look at
     ; further opcode bits.
     (else
      (logit 3 "Building subtable at index " (number->string index)
	     ", decode-bitsize = " (number->string decode-bitsize)
	     ", indices used thus far:"
	     (string-map (lambda (i) (string-append " " (number->string i)))
			 (apply append (map car index-list)))
	     "\n")

      (let ((bitnums (decode-get-best-bits slot
					   (apply append (map car index-list))
					   startbit 4
					   decode-bitsize lsb0?)))

	; If bitnums is nil, either there is an ambiguity or we need to read
	; more of the instruction in order to distinguish insns in SLOT.
	(if (and (null? bitnums)
		 (< startbit (apply min (map insn-length slot))))
	    (begin
	      ; We might be able to resolve the ambiguity by reading more bits.
	      ; We know from the < test that there are, indeed, more bits to
	      ; be read.
	      ; FIXME: It's technically possible that the next
	      ; startbit+decode-bitsize chunk has no usable bits and we have to
	      ; iterate, but rather unlikely.
	      ; The calculation of the new startbit, decode-bitsize will
	      ; undoubtedly need refinement.
	      (set! startbit (+ startbit decode-bitsize))
	      (set! decode-bitsize
		    (min decode-bitsize
			 (- (apply min (map insn-length slot))
			    startbit)))
	      (set! bitnums (decode-get-best-bits slot
						  ;nil ; FIXME: what to put here?
						  (apply append (map car index-list))
						  startbit 4
						  decode-bitsize lsb0?))))

	; If bitnums is still nil there is an ambiguity.
	(if (null? bitnums)
	    (begin
	      ; Try filtering out insns which are more general cases of
	      ; other insns in the slot.  The filtered insns will appear
	      ; in other slots as appropriate.
	      (set! slot (filter-non-specialized-ambiguous-insns slot))

	      (if (= 1 (length slot))
		  ; Only 1 insn left in the slot, so take it.
		  (dtable-entry-make index 'insn (car slot))
		  ; There is still more than one insn in 'slot',
		  ; so there is still an ambiguity.
		  (begin
		    ; If all insns are marked as DECODE-SPLIT, don't warn.
		    (if (not (all-true? (map (lambda (insn)
					       (obj-has-attr? insn 'DECODE-SPLIT))
					     slot)))
			(message "WARNING: Decoder ambiguity detected: "
				 (string-drop1 ; drop leading comma
				  (string-map (lambda (insn)
						(string-append ", " (obj:str-name insn)))
					      slot))
				 "\n"))
			; Things aren't entirely hopeless.  We've warned about
		        ; the ambiguity.  Now, if there are any identical insns,
		        ; filter them out.  If only one remains, then use it.
		    (set! slot (filter-identical-ambiguous-insns slot))
		    (if (= 1 (length slot))
			; Only 1 insn left in the slot, so take it.
			(dtable-entry-make index 'insn (car slot))
		        ; Otherwise, see if any ifield-assertion
			; specs are present.
			; FIXME: For now we assume that if they all have an
			; ifield-assertion spec, then there is no ambiguity (it's left
			; to the programmer to get it right).  This can be made more
			; clever later.
			; FIXME: May need to back up startbit if we've tried to read
			; more of the instruction.  We currently require that
			; all bits get used before advancing startbit, so this
			; shouldn't be necessary.  Verify.
			(let ((assertions (map insn-ifield-assertion slot)))
			  (if (not (all-true? assertions))
			      (begin
				; Save arguments for debugging purposes.
				(set! -build-decode-table-entry-args
				      (list insn-vec startbit decode-bitsize index index-list lsb0? invalid-insn))
				(error "Unable to resolve ambiguity (maybe need some ifield-assertion specs?)")))
				; FIXME: Punt on even simple cleverness for now.
			  (let ((exprtable-entries
				 (exprtable-sort (map exprtable-entry-make
						      slot
						      assertions))))
			    (dtable-entry-make index 'expr
					       (exprtable-make
						(-gen-exprtable-name exprtable-entries)
						exprtable-entries))))))))

	    ; There is no ambiguity so generate the subtable.
	    ; Need to build `subtable' separately because we
	    ; may be appending to -decode-subtables recursively.
	    (let* ((insn-vec (-build-slots slot bitnums lsb0?))
		   (subtable
		    (-build-decode-table-guts insn-vec bitnums startbit
					      decode-bitsize index-list lsb0?
					      invalid-insn)))
	      (dtable-entry-make index 'table
				 (subdtable-add subtable
						(-gen-decode-table-name "" index-list)))))))
     )
    )
)

; Given vector of insn slots, generate the guts of the decode table, recorded
; as a list of 3 elements: bitnums, decode-bitsize, and list of entries.
; Bitnums is recorded with the guts so that tables whose contents are
; identical but are accessed by different bitnums are treated as separate in
; -decode-subtables.  Not sure this will ever happen, but play it safe.
;
; BITNUMS is the list of bit numbers used to build the slot table.
; STARTBIT is the bit offset of the instruction value that C variable `insn'
; holds (note that this is independent of LSB0?).
; For example, it is initially zero.  If DECODE-BITSIZE is 16 and after
; scanning the first fetched piece of the instruction, more decoding is
; needed, another piece will be fetched and STARTBIT will then be 16.
; DECODE-BITSIZE is the number of bits of the insn that `insn' holds.
; INDEX-LIST is a list of pairs: list of bitnums, table entry number.
; Decode tables consist of entries of two types: actual insns and
; pointers to other tables.
; LSB0? is non-#f if bit number 0 is the least significant bit.
; INVALID-INSN is an <insn> object representing invalid insns.

(define (-build-decode-table-guts insn-vec bitnums startbit decode-bitsize index-list lsb0? invalid-insn)
  (logit 2 "Processing decoder for bits"
	 (numbers->string bitnums " ")
	 ", startbit " startbit
	 ", decode-bitsize " decode-bitsize
	 ", index-list " index-list
	 " ...\n")

  (dtable-guts-make
   bitnums startbit decode-bitsize
   (map (lambda (index)
	  (-build-decode-table-entry insn-vec startbit decode-bitsize index
				     (cons (cons bitnums index)
					   index-list)
				     lsb0? invalid-insn))
	(iota (vector-length insn-vec))))
)

; Entry point.
; Return a table that efficiently decodes INSN-LIST.
; BITNUMS is the set of bits to initially key off of.
; DECODE-BITSIZE is the number of bits of the instruction that `insn' holds.
; LSB0? is non-#f if bit number 0 is the least significant bit.
; INVALID-INSN is an <insn> object representing the `invalid' insn (for
; instructions values that don't decode to any entry in INSN-LIST).

(define (decode-build-table insn-list bitnums decode-bitsize lsb0? invalid-insn)
  ; Initialize the list of subtables computed.
  (set! -decode-subtables nil)

  ; ??? Another way to handle simple forms of ifield-assertions (like those
  ; created by insn specialization) is to record a copy of the insn for each
  ; possible value of the ifield and modify its ifield list with the ifield's
  ; value.  This would then let the decoder table builder handle it normally.
  ; I wouldn't create N insns, but would rather create an intermediary record
  ; that recorded the necessary bits (insn, ifield-list, remaining
  ; ifield-assertions).

  (let ((insn-vec (-build-slots insn-list bitnums lsb0?)))
    (let ((table-guts (-build-decode-table-guts insn-vec bitnums
						0 decode-bitsize
						nil lsb0?
						invalid-insn)))
      table-guts))
)
