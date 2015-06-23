; Instruction formats.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; Instruction formats are computed after the .cpu file has been read in.
; ??? May also wish to allow programmer to specify formats, but not sure this
; will complicate things more than it simplifies them, so it's defered.
;
; Two kinds of formats are defined here: iformat and sformat.
; (pronounced "I-format" and "S-format")
;
; Iformats are the instruction format as specified by the instructions' fields,
; and are the machine computed version of the generally known notion of an
; "instruction format".  No semantic information is attributed to iformats.
;
; Sformats are the same as iformats except that semantics are used to
; distinguish them.  For example, if an operand is refered to in one mode by
; one instruction and in a different mode by another instruction, then these
; two insns would have different sformats but the same iformat.  Sformats
; are used in simulator extraction code to collapse the number of cases that
; must be handled.  They can also be used to collapse the number of cases
; in the modeling code.
;
; The "base length" is the length of the insn that is initially fetched for
; decoding purposes.
; Formats are fixed in length.  For variable instruction length architectures
; there are separate formats for each insn's possible length.

(define <iformat>
  (class-make '<iformat>
	      '(<ident>)
		; From <ident>:
		; - NAME is derived from number, but we might have user
		;   specified formats someday [though I wouldn't add them
		;   without a clear need].
		; - COMMENT is the assembler syntax of an example insn that
		;   uses the format.
	      '(
		; Index into the iformat table.
		number

		; Sort key, used to determine insns with identical formats.
		key

		; List of <ifield> objects.
		ifields

		; min (insn-length, base-insn-size)
		mask-length

		; total length of insns with this format
		length

		; mask of base part
		mask

		; An example insn that uses the format.
		eg-insn
		)
	      nil)
)

; Accessor fns.

(define-getters <iformat> ifmt
  (number key ifields mask-length length mask eg-insn)
)

; Traverse the ifield list to collect all base (non-derived) ifields used in it.
(define (ifields-base-ifields ifld-list)
  (collect (lambda (ifld)
	     (ifld-base-ifields ifld))
	   ifld-list)
)

; Return enum cgen_fmt_type value for FMT.
; ??? Not currently used.

(define (ifmt-enum fmt)
  (string-append "@CPU@_" (string-upcase (gen-sym fmt)))
)

; Given FLD-LIST, compute the length of the insn in bits.
; This is done by adding up all the field sizes.
; All bits must be represent exactly once.

(define (compute-insn-length fld-list)
  (apply + (map ifld-length (collect ifld-base-ifields fld-list)))
)

; Given FLD-LIST, compute the base length in bits.
;
; For variable length instruction sets, or with cpus with multiple
; instruction sets, compute the base appropriate for this set of
; ifields.  Check that ifields are not shared among isas with
; inconsistent base insn lengths.

(define (compute-insn-base-mask-length fld-list)
  (let* ((isa-base-bitsizes
	  (remove-duplicates
	   (map isa-base-insn-bitsize
		(map current-isa-lookup
		     (collect (lambda (ifld) 
				(bitset-attr->list (atlist-attr-value (obj-atlist ifld) 'ISA #f)))
			      fld-list))))))
    (if (= 1 (length isa-base-bitsizes))
	(min (car isa-base-bitsizes) (compute-insn-length fld-list))
	(error "ifields have inconsistent isa/base-insn-size values:" isa-base-bitsizes)))
)

; Given FLD-LIST, compute the bitmask of constant values in the base part
; of the insn (i.e. the opcode field).
;
; FIXME: Need to add support for constant fields appearing outside the base
; insn.  One way would be to record with each insn the value for each constant
; field.  That would allow code to straightforwardly fetch it.  Another would
; be to only record constant values appearing outside the base insn.
;
; See also (insn-value).
;
(define (compute-insn-base-mask fld-list)
  (let* ((mask-len (compute-insn-base-mask-length fld-list))
	 (lsb0? (ifld-lsb0? (car fld-list)))
	 (mask-bitrange (make <bitrange>
			      0 ; word-offset
			      (if lsb0? (- mask-len 1) 0) ; start
			      mask-len ; length
			      mask-len ; word-length
			      lsb0?)))
    (apply +
	   (map (lambda (fld) (ifld-mask fld mask-len mask-bitrange))
		; Find the fields that have constant values.
		(find ifld-constant? (collect ifld-base-ifields fld-list)))
	   )
    )
)

; Return the <iformat> search key for a sorted field list.
; This determines how iformats differ from each other.
; It also speeds up searching as the search key can be anything
; (though at present searching isn't as fast as it could be).
; INSN is passed so that we can include its sanytize attribute, if present,
; so sanytized sources work (needed formats don't disappear).

(define (-ifmt-search-key insn sorted-ifld-list)
  (string-map (lambda (ifld)
		(string-append " ("
			       (or (->string (obj-attr-value insn 'sanitize))
				   "-nosan-")
			       " "
			       (obj:str-name ifld)
			       " "
			       (ifld-ilk ifld)
			       ")"))
	      sorted-ifld-list)
)

; Create an <iformat> object for INSN.
; INDEX is the ordinal to assign to the result or -1 if unknown.
; SEARCH-KEY is the search key used to determine the iformat's uniqueness.
; IFLDS is a sorted list of INSN's ifields.

(define (ifmt-build insn index search-key iflds)
  (make <iformat>
    (symbol-append 'ifmt- (obj:name insn))
    (string-append "e.g. " (insn-syntax insn))
    atlist-empty
    index
    search-key
    iflds
    (compute-insn-base-mask-length iflds)
    (compute-insn-length iflds)
    (compute-insn-base-mask iflds)
    insn)
)

; Sformats.

(define <sformat>
  (class-make '<sformat>
	      '(<ident>)
	      ; From <ident>:
	      ; - NAME is derived from number.
	      ; - COMMENT is the assembler syntax of an example insn that
	      ;   uses the format.
	      '(
		; Index into the sformat table.
		number

		; Sort key, used to determine insns with identical formats.
		key

		; Non-#f if insns with this format are cti insns.
		cti?

		; IN-OPS is a list of input operands.
		; OUT-OPS is a list of output operands.
		; These are used to distinguish the format from others,
		; so that the extract and read operations can be based on the
		; sformat.
		; The extract fns use this data to record the necessary
		; information for profiling [which isn't necessarily a property
		; of the field list].  We could have one extraction function
		; per instruction, but there's a *lot* of duplicated code, and
		; the semantic operands rarely contribute to extra formats.
		; The parallel execution support uses this data to record the
		; input (or output) values based on the instruction format,
		; again cutting down on duplicated code.
		in-ops
		out-ops

		; Length of all insns with this format.
		; Since insns with different iformats can have the same sformat
		; we need to ensure ifield extraction works among the various
		; iformats.  We do this by ensuring all insns with the same
		; sformat have the same length.
		length

		; Cached list of all ifields used.
		; This can be derived from IN-OPS/OUT-OPS but is computed once
		; and cached here for speed.
		iflds

		; An example insn that uses the format.
		; This is used for debugging purposes, but also to help get
		; sanytization (spelled wrong on purpose) right.
		eg-insn

		; <sformat-argbuf> entry
		; FIXME: Temporary location, to be moved elsewhere
		(sbuf . #f)
		)
	      nil)
)

; Accessor fns.

(define-getters <sformat> sfmt
  (number key cti? in-ops out-ops length iflds eg-insn sbuf)
)

(define-setters <sformat> sfmt (sbuf))

(method-make-make! <sformat>
		   '(name comment attrs
		     number key cti? in-ops out-ops length iflds eg-insn)
)

; Return the <sformat> search key for a sorted field list and semantic
; operands.
; This determines how sformats differ from each other.
; It also speeds up searching as the search key can be anything
; (though at present searching isn't as fast as it could be).
;
; INSN is passed so that we can include its sanytize attribute, if present,
; so sanytized sources work (needed formats don't disappear).
; SORTED-USED-IFLDS is a sorted list of ifields used by SEM-{IN,OUT}-OPS.
; Note that it is not the complete set of ifields used by INSN.
;
; We assume INSN's <iformat> has been recorded.
;
; Note: It's important to minimize the number of created sformats.  It keeps
; the generated code smaller (and sometimes faster - more usable common
; fragments in pbb simulators).  Don't cause spurious differences.

(define (-sfmt-search-key insn cti? sorted-used-iflds sem-in-ops sem-out-ops)
  (let ((op-key (lambda (op)
		  (string-append " ("
				 (or (->string (obj-attr-value insn 'sanitize))
				     "-nosan-")
				 " "
				 (obj:str-name op)
				 ; ??? Including memory operands currently
				 ; isn't necessary and it can account for some
				 ; spurious differences.  On the other hand
				 ; leaving it out doesn't seem like the right
				 ; thing to do.
				 (if (memory? (op:type op))
				     ""
				     (string-append " "
						    (obj:str-name (op:mode op))))
				 ; CGEN_OPERAND_INSTANCE_COND_REF is stored
				 ; with the operand in the operand instance
				 ; table thus formats must be distinguished
				 ; by this.
				 (if (op:cond? op) " cond" "")
				 ")")))
	)
    (list
     cti?
     (insn-length insn)
     (string-map (lambda (ifld)
		   (string-append " (" (obj:str-name ifld) " " (ifld-ilk ifld) ")"))
		 sorted-used-iflds)
     (string-map op-key
		 sem-in-ops)
     (string-map op-key
		 sem-out-ops)
     ))
)

; Create an <sformat> object for INSN.
; INDEX is the ordinal to assign to the result or -1 if unknown.
; SEARCH-KEY is the search key used to determine the sformat's uniqueness.
; {IN,OUT}-OPS are lists of INSN's input/output operands.
; SORTED-USED-IFLDS is a sorted list of ifields used by {IN,OUT}-OPS.
; Note that it is not the complete set of ifields used by INSN.
;
; We assume INSN's <iformat> has already been recorded.

(define (sfmt-build insn index search-key cti? in-ops out-ops sorted-used-iflds)
  (make <sformat>
    (symbol-append 'sfmt- (obj:name insn))
    (string-append "e.g. " (insn-syntax insn))
    atlist-empty
    index
    search-key
    cti?
    in-ops
    out-ops
    (insn-length insn)
    sorted-used-iflds
    insn)
)

; Sort IFLDS by dependencies and then by starting bit number.

(define (-sfmt-order-iflds iflds)
  (let ((up? 
	 ; ??? Something like this is preferable.
	 ;(not (ifld-lsb0? (car ifld-list)))
	 (not (current-arch-insn-lsb0?))))
    (let loop ((independent nil) (dependent nil) (iflds iflds))
      (cond ((null? iflds)
	     (append (sort-ifield-list independent up?)
		     (sort-ifield-list dependent up?)))
	    ; FIXME: quick hack.
	    ((multi-ifield? (car iflds))
	     (loop independent (cons (car iflds) dependent) (cdr iflds)))
	    (else
	     (loop (cons (car iflds) independent) dependent (cdr iflds))))))
)

; Return a sorted list of ifields used by IN-OPS, OUT-OPS.
; The ifields are sorted by dependencies and then by start bit.
; The important points are to help distinguish sformat's by the ifields used
; and to put ifields that others depend on first.

(define (-sfmt-used-iflds in-ops out-ops)
  (let ((in-iflds (map op-iflds-used in-ops))
	(out-iflds (map op-iflds-used out-ops)))
    (let ((all-iflds (nub (append (apply append in-iflds)
				  (apply append out-iflds))
			  obj:name)))
      (-sfmt-order-iflds all-iflds)))
)

; The format descriptor is used to sort formats.
; This is a utility class internal to this file.
; There is one instance per insn.

(define <fmt-desc>
  (class-make '<fmt-desc>
	      nil
	      '(
		; #t if insn is a cti insn
		cti?

		; sorted list of insn's ifields
		iflds

		; computed set of input/output operands
		in-ops out-ops

		; set of ifields used by IN-OPS,OUT-OPS.
		used-iflds

		; computed set of attributes
		attrs
		)
	      nil)
)

; Accessors.

(define-getters <fmt-desc> -fmt-desc
  (cti? iflds in-ops out-ops used-iflds attrs)
)

; Compute an iformat descriptor used to build an <iformat> object for INSN.
;
; If COMPUTE-SFORMAT? is #t compile the semantics and compute the semantic
; format (same as instruction format except that operands are used to
; distinguish insns).
; Attributes derivable from the semantics are also computed.
; This is all done at the same time to minimize the number of times the
; semantic code is traversed.
;
; The result is (descriptor compiled-semantics attrs).
; `descriptor' is #f for insns with an empty field list
; (this happens for virtual insns).
; `compiled-semantics' is #f if COMPUTE-SFORMAT? is #f.
; `attrs' is an <attr-list> object of attributes derived from the semantics.
;
; ??? We never traverse the semantics of virtual insns.

(define (ifmt-analyze insn compute-sformat?)
  ; First sort by starting bit number the list of fields in INSN.
  (let ((sorted-ifields
	 (sort-ifield-list (insn-iflds insn)
			   ; ??? Something like this is preferable, but
			   ; if the first insn is a virtual insn there are
			   ; no fields.
			   ;(not (ifld-lsb0? (car (insn-iflds insn))))
			   (not (current-arch-insn-lsb0?))
			   )))

    (if (null? sorted-ifields)

	; Field list is unspecified.
	(list #f #f atlist-empty)

	; FIXME: error checking (e.g. missing or overlapping bits)
	(let* ((sem (insn-semantics insn))
	       ; Compute list of input and output operands if asked for.
	       (sem-ops (if compute-sformat?
			    (semantic-compile #f ; FIXME: context
					      insn sem)
			    (csem-make #f #f #f
				       (if sem
					   (semantic-attrs #f ; FIXME: context
							   insn sem)
					   atlist-empty))))
	       )
	  (let ((compiled-sem (csem-code sem-ops))
		(in-ops (csem-inputs sem-ops))
		(out-ops (csem-outputs sem-ops))
		(attrs (csem-attrs sem-ops))
		(cti? (or (atlist-cti? (csem-attrs sem-ops))
			  (insn-cti? insn))))
	    (list (make <fmt-desc>
		    cti? sorted-ifields in-ops out-ops
		    (if (and in-ops out-ops)
			(-sfmt-used-iflds in-ops out-ops)
			#f)
		    attrs)
		  compiled-sem
		  attrs)))))
)

; Subroutine of ifmt-compute!, to simplify it.
; Lookup INSN's iformat in IFMT-LIST and if not found add it.
; FMT-DESC is INSN's <fmt-desc> object.
; IFMT-LIST is append!'d to and the found iformat is stored in INSN.

(define (-ifmt-lookup-ifmt! insn fmt-desc ifmt-list)
  (let* ((search-key (-ifmt-search-key insn (-fmt-desc-iflds fmt-desc)))
	 (ifmt (find-first (lambda (elm)
			     (equal? (ifmt-key elm) search-key))
			   ifmt-list)))

    (if ifmt

	; Format was found, use it.
	(begin
	  (logit 3 "Using iformat " (number->string (ifmt-number ifmt)) ".\n")
	  (insn-set-ifmt! insn ifmt)
	  )

	; Format wasn't found, create new entry.
	(let* ((ifmt-index (length ifmt-list))
	       (ifmt (ifmt-build insn ifmt-index search-key
				 (ifields-base-ifields (-fmt-desc-iflds fmt-desc)))))
	  (logit 3 "Creating iformat " (number->string ifmt-index) ".\n")
	  (insn-set-ifmt! insn ifmt)
	  (append! ifmt-list (list ifmt))
	  )
	))

  *UNSPECIFIED*
)

; Subroutine of ifmt-compute!, to simplify it.
; Lookup INSN's sformat in SFMT-LIST and if not found add it.
; FMT-DESC is INSN's <fmt-desc> object.
; SFMT-LIST is append!'d to and the found sformat is stored in INSN.
;
; We assume INSN's <iformat> has already been recorded.

(define (-ifmt-lookup-sfmt! insn fmt-desc sfmt-list)
  (let* ((search-key (-sfmt-search-key insn (-fmt-desc-cti? fmt-desc)
				       (-fmt-desc-used-iflds fmt-desc)
				       (-fmt-desc-in-ops fmt-desc)
				       (-fmt-desc-out-ops fmt-desc)))
	 (sfmt (find-first (lambda (elm)
			     (equal? (sfmt-key elm) search-key))
			   sfmt-list)))

    (if sfmt

	; Format was found, use it.
	(begin
	  (logit 3 "Using sformat " (number->string (sfmt-number sfmt)) ".\n")
	  (insn-set-sfmt! insn sfmt)
	  )

	; Format wasn't found, create new entry.
	(let* ((sfmt-index (length sfmt-list))
	       (sfmt (sfmt-build insn sfmt-index search-key
				 (-fmt-desc-cti? fmt-desc)
				 (-fmt-desc-in-ops fmt-desc)
				 (-fmt-desc-out-ops fmt-desc)
				 (ifields-base-ifields (-fmt-desc-used-iflds fmt-desc)))))
	  (logit 3 "Creating sformat " (number->string sfmt-index) ".\n")
	  (insn-set-sfmt! insn sfmt)
	  (append! sfmt-list (list sfmt))
	  )
	))

  *UNSPECIFIED*
)

; Main entry point.

; Given a list of insns, compute the set of instruction formats, semantic
; formats, semantic attributes, and compiled semantics for each insn.
;
; The computed <iformat> object is stored in the `ifmt' field of each insn.
;
; Attributes derived from the semantic code are added to the insn's attributes,
; but they don't override any prespecified values.
;
; If COMPUTE-SFORMAT? is #t, the computed <sformat> object is stored in the
; `sfmt' field of each insn, and the processed semantic code is stored in the
; `compiled-semantics' field of each insn.
;
; The `fmt-desc' field of each insn is used to store an <fmt-desc> object
; which contains the search keys, sorted field list, input-operands, and
; output-operands, and is not used outside this procedure.
;
; The result is a list of two lists: the set of computed iformats, and the
; set of computed sformats.
;
; *** This is the most expensive calculation in CGEN.   ***
; *** (mainly because of the detailed semantic parsing) ***

(define (ifmt-compute! insn-list compute-sformat?)
  (logit 2 "Computing instruction formats and analyzing semantics ...\n")

  ; First analyze each insn, storing the result in fmt-desc.
  ; If asked to, convert the semantic code to a compiled form to simplify more
  ; intelligent processing of it later.

  (for-each (lambda (insn)
	      (logit 3 "Scanning operands of " (obj:name insn) ": "
		     (insn-syntax insn) " ...\n")
	      (let ((sem-ops (ifmt-analyze insn compute-sformat?)))
		(insn-set-fmt-desc! insn (car sem-ops))
		(if (and compute-sformat? (cadr sem-ops))
		    (let ((compiled-sem (cadr sem-ops)))
		      (insn-set-compiled-semantics! insn compiled-sem)))
		(obj-set-atlist! insn
				 (atlist-append (obj-atlist insn)
						(caddr sem-ops)))
		))
	    insn-list)

  ; Now for each insn, look up the ifield list in the format table (and if not
  ; found add it), and set the ifmt/sfmt elements of the insn.

  (let* ((empty-ifmt (make <iformat>
			  'ifmt-empty
			  "empty iformat for unspecified field list"
			  atlist-empty ; attrs
			  -1 ; number
			  #f ; key
			  nil ; fields
			  0 ; mask-length
			  0 ; length
			  0 ; mask
			  #f)) ; eg-insn
	 (empty-sfmt (make <sformat>
			  'sfmt-empty
			  "empty sformat for unspecified field list"
			  atlist-empty ; attrs
			  -1 ; number
			  #f ; key
			  #f ; cti?
			  nil ; sem-in-ops
			  nil ; sem-out-ops
			  0 ; length
			  nil ; used iflds
			  #f)) ; eg-insn
	 (ifmt-list (list empty-ifmt))
	 (sfmt-list (list empty-sfmt))
	 )

    (for-each (lambda (insn)
		(logit 3 "Processing format for " (obj:name insn) ": "
		       (insn-syntax insn) " ...\n")

		(let ((fmt-desc (insn-fmt-desc insn)))

		  (if fmt-desc

		      (begin
			; Must compute <iformat> before <sformat>, the latter
			; needs the former.
			(-ifmt-lookup-ifmt! insn fmt-desc ifmt-list)
			(if compute-sformat?
			    (-ifmt-lookup-sfmt! insn fmt-desc sfmt-list)))

		      ; No field list present, use empty format.
		      (begin
			(insn-set-ifmt! insn empty-ifmt)
			(if compute-sformat?
			    (insn-set-sfmt! insn empty-sfmt))))))

	      (non-multi-insns insn-list))

    ; Done.  Return the computed iformat and sformat lists.
    (list ifmt-list sfmt-list)
    )
)
