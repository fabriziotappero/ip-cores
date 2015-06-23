; Instruction fields.
; Copyright (C) 2000, 2002, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; The `<ifield>' class.
; (pronounced "I-field")
;
; These describe raw data, little semantic content is attributed to them.
; The goal being to avoid interfering with future applications.
;
; FIXME: Move start, word-offset, word-length into the instruction format?
; - would require proper ordering of fields in insns, but that's ok.
;   (??? though the sparc64 description shows a case where its useful to
;   not have to worry about instruction ordering - different versions of an
;   insn take different fields and these fields are passed via a macro)
;
; ??? One could treat all ifields as being unsigned.  They could be thought of
; as indices into a table of values, be they signed, unsigned, floating point,
; whatever.  Just an idea.
;
; ??? Split into two?  One for definition, and one for value.

(define <ifield>
  (class-make '<ifield>
	      '(<source-ident>)
	      '(
		; The mode the raw value is to be interpreted in.
		mode

		; A <bitrange> object.
		; This contains the field's offset, start, length, word-length,
		; and orientation (msb==0, lsb==0).  The orientation is
		; recorded to keep the <bitrange> object self-contained.
		; Endianness is not recorded.
		bitrange

		; Argument to :follows, as an object.
		; FIXME: wip
		(follows . #f)

		; ENCODE/DECODE operate on the raw value, absent of any context
		; save `pc' and mode of field.
		; If #f, no special processing is required.
		; ??? It's not clear where the best place to process fields is.
		; An earlier version had insert/extract fields in operands to
		; handle more complicated cases.  Following the goal of
		; incremental complication, the special handling for m32r's
		; f-disp8 field is handled entirely here, rather than partially
		; here and partially in the operand.
		encode decode

		; Value of field, if there is one.
		; Possible types are: integer, <operand>, ???
		value
		)
	      nil)
)

; {ordinal} is missing on purpose, it's handled at a higher level.
; {value},{follows} are missing on purpose.
; {value} is handled specially.
; {follows} is rarely used
(method-make-make! <ifield>
		   '(location name comment attrs mode bitrange encode decode))

; Accessor fns
; ??? `value' is treated specially, needed anymore?

(define-getters <ifield> ifld (mode encode decode follows))

(define-setters <ifield> ifld (follows))

; internal fn
(define -ifld-bitrange (elm-make-getter <ifield> 'bitrange))

(define (ifld-word-offset f) (bitrange-word-offset (-ifld-bitrange f)))
(define (ifld-word-length f) (bitrange-word-length (-ifld-bitrange f)))

; Return the mode of the value passed to the encode rtl.
; This is the mode of the result of the decode rtl.

(define (ifld-encode-mode f)
  (if (ifld-decode f)
      ; cadr/cadr gets WI in ((value pc) (sra WI ...))
      ; FIXME: That's wrong for a fully canonical expression like
      ; ((value pc) (sra () WI ...)).
      (mode:lookup (cadr (cadr (ifld-decode f))))
      (ifld-mode f))
)

; Return the mode of the value passed to the decode rtl.
; This is the mode of the field.

(define (ifld-decode-mode f) (ifld-mode f))

; Return start of ifield.

(method-make-virtual!
 <ifield> 'field-start
 (lambda (self word-len)
   (bitrange-start (-ifld-bitrange self)))
)

(define (ifld-start ifld word-len)
  (send ifld 'field-start word-len)
)

(method-make-virtual!
 <ifield> 'field-length
 (lambda (self)
   (bitrange-length (elm-get self 'bitrange)))
)

(define (ifld-length f) (send f 'field-length))

; FIXME: It might make things more "readable" if enum values were preserved in
; their symbolic form and the get-field-value method did the lookup.

(method-make!
 <ifield> 'get-field-value
 (lambda (self)
   (elm-get self 'value))
)
(define (ifld-get-value self)
  (send self 'get-field-value)
)
(method-make!
 <ifield> 'set-field-value!
 (lambda (self new-val)
   (elm-set! self 'value new-val))
)
(define (ifld-set-value! self new-val)
  (send self 'set-field-value! new-val)
)

; Return a boolean indicating if X is an <ifield>.

(define (ifield? x) (class-instance? <ifield> x))

; Return ilk of field as a string.
; ("ilk" sounds klunky but "type" is too ambiguous.  Here "ilk" means
; the kind of the hardware element, enum, etc.)
; The result is a character string naming the field type.

(define (ifld-ilk fld)
  (let ((value (elm-xget fld 'value)))
    ; ??? One could require that the `value' field always be an object.
    ; I can't get too worked up over it yet.
    (if (object? value)
	(symbol->string (obj:name value)) ; send 'get-name to fetch the name
	"#")) ; # -> "it's a number"
)

; Generate the name of the enum for instruction field ifld.
; If PREFIX? is present and #f, the @ARCH@_ prefix is omitted.

(define (ifld-enum ifld . prefix?)
  (string-upcase (string-append (if (or (null? prefix?) (car prefix?))
				    "@ARCH@_"
				    "")
				(gen-sym ifld)))
)

; Return a boolean indicating if ifield F is an opcode field
; (has a constant value).

(define (ifld-constant? f)
  (number? (ifld-get-value f))
;  (and (number? (ifld-get-value f))
;       (if option:reserved-as-opcode?
;	   #t
;	   (not (has-attr? f 'RESERVED))))
)

; Return a boolean indicating if ifield F is an operand.
; FIXME: Should check for operand? or some such.

(define (ifld-operand? f) (not (number? (ifld-get-value f))))

; Return known value table for rtx-simplify of <ifield> list ifld-list.

(define (ifld-known-values ifld-list)
  (let ((constant-iflds (find ifld-constant? (collect ifld-base-ifields ifld-list))))
    (map (lambda (f)
	   (cons (obj:name f)
		 (rtx-make-const 'INT (ifld-get-value f))))
	 constant-iflds))
)

; Return mask to use for a field in <bitrange> CONTAINER.
; If the bitrange is outside the range of the field, return 0.
; If CONTAINER is #f, use the recorded bitrange.
; BASE-LEN, if non-#f, overrides the base insn length of the insn.
; BASE-LEN is present for architectures like the m32r where there are insns
; smaller than the base insn size (LIW).
;
; Simplifying restrictions [to be relaxed as necessary]:
; - the field must either be totally contained within CONTAINER or totally
;   outside it, partial overlaps aren't handled
; - CONTAINER must be an integral number of bytes, beginning on a
;   byte boundary [simplifies things]
; - both SELF's bitrange and CONTAINER must have the same word length
; - LSB0? of SELF's bitrange and CONTAINER must be the same

(method-make!
 <ifield> 'field-mask
 (lambda (self base-len container)
   (let* ((container (or container (-ifld-bitrange self)))
	  (bitrange (-ifld-bitrange self))
	  (recorded-word-length (bitrange-word-length bitrange))
	  (word-offset (bitrange-word-offset bitrange)))
     (let ((lsb0? (bitrange-lsb0? bitrange))
	   (start (bitrange-start bitrange))
	   (length (bitrange-length bitrange))
	   (word-length (or (and (= word-offset 0) base-len)
			    recorded-word-length))
	   (container-word-offset (bitrange-word-offset container))
	   (container-word-length (bitrange-word-length container)))
       (cond
	; must be same lsb0
	((not (eq? lsb0? (bitrange-lsb0? container)))
	 (error "field-mask: different lsb0? values"))
	((not (= word-length container-word-length))
	 0)
	; container occurs after?
	((<= (+ word-offset word-length) container-word-offset)
	 0)
	; container occurs before?
	((>= word-offset (+ container-word-offset container-word-length))
	 0)
	(else
	 (word-mask start length word-length lsb0? #f))))))
)

(define (ifld-mask ifld base-len container)
  (send ifld 'field-mask base-len container)
)

; Return VALUE inserted into the field's position.
; BASE-LEN, if non-#f, overrides the base insn length of the insn.
; BASE-LEN is present for architectures like the m32r where there are insns
; smaller than the base insn size (LIW).

(method-make!
 <ifield> 'field-value
 (lambda (self base-len value)
   (let* ((bitrange (-ifld-bitrange self))
	  (recorded-word-length (bitrange-word-length bitrange))
	  (word-offset (bitrange-word-offset bitrange))
	  (word-length (or (and (= word-offset 0) base-len)
			   recorded-word-length)))
     (word-value (ifld-start self base-len)
		 (bitrange-length bitrange)
		 word-length
		 (bitrange-lsb0? bitrange) #f
		 value)))
)

; FIXME: confusion with ifld-get-value.
(define (ifld-value f base-len value)
  (send f 'field-value base-len value)
)

; Return a list of ifields required to compute <ifield> F's value.
; Normally this is just F itself.  For multi-ifields it will be more.
; ??? It can also be more if F's value is derived from other fields but
; that isn't supported yet.

(method-make!
 <ifield> 'needed-iflds
 (lambda (self)
   (list self))
)

(define (ifld-needed-iflds f)
  (send f 'needed-iflds)
)

; Extract <ifield> IFLD's value out of VALUE in <insn> INSN.
; VALUE is the entire insn's value if it fits in a word, or is a list
; of values, one per word (not implemented, sigh).
; ??? The instruction's format should specify where the word boundaries are.

(method-make!
 <ifield> 'field-extract
 (lambda (self insn value)
   (let ((base-len (insn-base-mask-length insn)))
     (word-extract (ifld-start self base-len)
		   (ifld-length self)
		   base-len
		   (ifld-lsb0? self)
		   #f ; start is msb
		   value)))
)

(define (ifld-extract ifld value insn)
  (send ifld 'field-extract value insn)
)

; Return a boolean indicating if bit 0 is the least significant bit.

(method-make!
 <ifield> 'field-lsb0?
 (lambda (self)
   (bitrange-lsb0? (-ifld-bitrange self)))
)

(define (ifld-lsb0? f) (send f 'field-lsb0?))

; Return the minimum value of a field.

(method-make!
 <ifield> 'min-value
 (lambda (self)
  (case (mode:class (ifld-mode self))
    ((INT) (- (integer-expt 2 (- (ifld-length self) 1))))
    ((UINT) 0)
    (else (error "unsupported mode class" (mode:class (ifld-mode self))))))
)

; Return the maximum value of a field.

(method-make!
 <ifield> 'max-value
 (lambda (self)
  (case (mode:class (ifld-mode self))
    ((INT) (- (integer-expt 2 (- (ifld-length self) 1)) 1))
    ((UINT) (- (integer-expt 2 (ifld-length self)) 1))
    (else (error "unsupported mode class" (mode:class (ifld-mode self))))))
)

; Create a copy of field F with value VALUE.
; VALUE is either ... ???

(define (ifld-new-value f value)
  (let ((new-f (object-copy-top f)))
    (ifld-set-value! new-f value)
    new-f)
)

; Change the offset of the word containing an ifield to {word-offset}.

(method-make!
 <ifield> 'set-word-offset!
 (lambda (self word-offset)
   (let ((bitrange (object-copy-top (-ifld-bitrange self))))
     (bitrange-set-word-offset! bitrange word-offset)
     (elm-set! self 'bitrange bitrange)
     *UNSPECIFIED*))
)
(define (ifld-set-word-offset! f word-offset)
  (send f 'set-word-offset! word-offset)
)

; Return a copy of F with new {word-offset}.

(define (ifld-new-word-offset f word-offset)
  (let ((new-f (object-copy-top f)))
    (ifld-set-word-offset! new-f word-offset)
    new-f)
)

; Return the bit offset of the word after the word <ifield> F is in.
; What a `word' here is defined by F in its bitrange.

(method-make!
 <ifield> 'next-word
 (lambda (self)
  (let ((br (-ifld-bitrange f)))
    (bitrange-next-word br)))
)

(define (ifld-next-word f) (send f 'next-word))

; Return a boolean indicating if <ifield> F1 precedes <ifield> F2.
; FIXME: Move into a method as different subclasses will need
; different handling.

(define (ifld-precedes? f1 f2)
  (let ((br1 (-ifld-bitrange f1))
	(br2 (-ifld-bitrange f2)))
    (cond ((< (bitrange-word-offset br1) (bitrange-word-offset br2))
	   #t)
	  ((= (bitrange-word-offset br1) (bitrange-word-offset br2))
	   (begin
	     (assert (eq? (bitrange-lsb0? br1) (bitrange-lsb0? br2)))
	     (assert (= (bitrange-word-length br1) (bitrange-word-length br1)))
	     ; ??? revisit
	     (if (bitrange-lsb0? br1)
		 (> (bitrange-start br1) (bitrange-start br2))
		 (< (bitrange-start br1) (bitrange-start br2)))))
	  (else
	   #f)))
)

; Parse an ifield definition.
; This is the main routine for building an ifield object from a
; description in the .cpu file.
; All arguments are in raw (non-evaluated) form.
; The result is the parsed object or #f if object isn't for selected mach(s).
;
; Two forms of specification are supported, loosely defined as the RISC way
; and the CISC way.  The reason for the distinction is to simplify ifield
; specification of RISC-like cpus.
; Note that VLIW's are another way.  These are handled like the RISC way, with
; the possible addition of instruction framing (which is, surprise surprise,
; wip).
;
; RISC:
; WORD-OFFSET and WORD-LENGTH are #f.  Insns are assumed to be N copies of
; (isa-default-insn-word-bitsize).  WORD-OFFSET is computed from START.
; START is the offset in bits from the start of the insn.
; FLENGTH is the length of the field in bits.
;
; CISC:
; WORD-OFFSET is the offset in bits from the start to the first byte of the
; word containing the ifield.
; WORD-LENGTH is the length in bits of the word containing the ifield.
; START is the starting bit number in the word.  Bit numbering is taken from
; (current-arch-insn-lsb0?).
; FLENGTH is the length in bits of the ifield.  It is named that way to avoid
; collision with the proc named `length'.
;
; FIXME: More error checking.

(define (-ifield-parse context name comment attrs
		       word-offset word-length start flength follows
		       mode encode decode)
  (logit 2 "Processing ifield " name " ...\n")

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name))
	 (atlist (atlist-parse context attrs "cgen_ifld"))
	 (isas (bitset-attr->list (atlist-attr-value atlist 'ISA #f))))

    ; No longer ensure only one isa specified.
    ;(if (!= (length isas) 1)
    ;	(parse-error context "can only specify 1 isa" attrs))

    (if (not (eq? (->bool word-offset)
		  (->bool word-length)))
	(parse-error context "either both or neither of word-offset,word-length can be specified"))

    (if (keep-isa-atlist? atlist #f)

	(let ((isa (current-isa-lookup (car isas)))
	      (word-offset (and word-offset
				(parse-number context word-offset '(0 . 256))))
	      (word-length (and word-length
				(parse-number context word-length '(0 . 128))))
	      ; ??? 0.127 for now
	      (start (parse-number context start '(0 . 127)))
	      ; ??? 0.127 for now
	      (flength (parse-number context flength '(0 . 127)))
	      (lsb0? (current-arch-insn-lsb0?))
	      (mode-obj (parse-mode-name context mode))
	      (follows-obj (-ifld-parse-follows context follows))
	      )

	  ; Calculate the <bitrange> object.
	  ; ??? Move positional info to format?
	  (let ((bitrange
		 (if word-offset

		     ; CISC-like. Easy. Everything must be specified.
		     (make <bitrange>
		       word-offset start flength word-length lsb0?)

		     ; RISC-like. Hard. Have to make best choice of start,
		     ; flength. This doesn't have to be perfect, just easily
		     ; explainable.  Cases this doesn't handle can explicitly
		     ; specify word-offset,word-length.
		     ; One can certainly argue the choice of the term
		     ; "RISC-like" is inaccurate.  Perhaps.
		     (let* ((diwb (isa-default-insn-word-bitsize isa))
			    (word-offset (-get-ifld-word-offset start flength diwb lsb0?))
			    (word-length (-get-ifld-word-length start flength diwb lsb0?))
			    (start (- start word-offset))
			    )
		       (make <bitrange>
			 word-offset
			 start
			 flength
			 word-length
			 lsb0?))))
		 )

	    (let ((result
		   (make <ifield>
			 (context-location context)
			 name
			 (parse-comment context comment)
			 atlist
			 mode-obj
			 bitrange
			 (-ifld-parse-encode context encode)
			 (-ifld-parse-decode context decode))))
	      (if follows-obj
		  (ifld-set-follows! result follows-obj))
	      result)))

	; Else ignore entry.
	(begin
	  (logit 2 "Ignoring " name ".\n")
	  #f)))
)

; Subroutine of -ifield-parse to simplify it.
; Given START,FLENGTH, return the "best" choice for the offset to the word
; containing the ifield.
; This is easy to visualize, hard to put into words.
; Imagine several words of size DIWB laid out from the start of the insn.
; On top of that lay the ifield.
; Now pick the minimal set of words that are required to contain the ifield.
; That's what we want.
; No claim is made that this is always the correct choice for any
; particular architecture.  For those where this isn't correct, the ifield
; must be fully specified (i.e. word-offset,word-length explicitly specified).

(define (-get-ifld-word-offset start flength diwb lsb0?)
  (if lsb0?
      ; Convert to non-lsb0 case, then it's easy.
      ; NOTE: The conversion is seemingly wrong because `start' is misnamed.
      ; It's now `end'.
      (set! start (+ (- start flength) 1)))
  (- start (remainder start diwb))
)

; Subroutine of -ifield-parse to simplify it.
; Given START,FLENGTH, return the "best" choice for the length of the word
; containing the ifield.
; DIWB = default insn word bitsize
; See -get-ifld-word-offset for more info.

(define (-get-ifld-word-length start flength diwb lsb0?)
  (if lsb0?
      ; Convert to non-lsb0 case, then it's easy.
      ; NOTE: The conversion is seemingly wrong because `start' is misnamed.
      ; It's now `end'.
      (set! start (+ (- start flength) 1)))
  (* (quotient (+ (remainder start diwb) flength (- diwb 1))
	       diwb)
     diwb)
)

; Read an instruction field description.
; This is the main routine for analyzing instruction fields in the .cpu file.
; CONTEXT is a <context> object for error messages.
; ARG-LIST is an associative list of field name and field value.
; -ifield-parse is invoked to create the <ifield> object.

(define (-ifield-read context . arg-list)
  (let (
	(name #f)
	(comment "")
	(attrs nil)
	(word-offset #f)
	(word-length #f)
	(start 0)
	; FIXME: Hobbit computes the wrong symbol for `length'
	; in the `case' expression below because there is a local var
	; of the same name ("__1" gets appended to the symbol name).
	; As a workaround we name it "length-".
	(length- 0)
	(follows #f)
	(mode 'UINT)
	(encode #f)
	(decode #f)
	)

    ; Loop over each element in ARG-LIST, recording what's found.
    (let loop ((arg-list arg-list))
      (if (null? arg-list)
	  nil
	  (let ((arg (car arg-list))
		(elm-name (caar arg-list)))
	    (case elm-name
	      ((name) (set! name (cadr arg)))
	      ((comment) (set! comment (cadr arg)))
	      ((attrs) (set! attrs (cdr arg)))
	      ((mode) (set! mode (cadr arg)))
	      ((word-offset) (set! word-offset (cadr arg)))
	      ((word-length) (set! word-length (cadr arg)))
	      ((start) (set! start (cadr arg)))
	      ((length) (set! length- (cadr arg)))
	      ((follows) (set! follows (cadr arg)))
	      ((encode) (set! encode (cdr arg)))
	      ((decode) (set! decode (cdr arg)))
	      (else (parse-error context "invalid ifield arg" arg)))
	    (loop (cdr arg-list)))))

    ; See if encode/decode were specified as "unspecified".
    ; This happens with shorthand macros.
    (if (and (pair? encode)
	     (eq? (car encode) #f))
	(set! encode #f))
    (if (and (pair? decode)
	     (eq? (car decode) #f))
	(set! decode #f))

    ; Now that we've identified the elements, build the object.
    (-ifield-parse context name comment attrs
		   word-offset word-length start length- follows
		   mode encode decode))
)

; Parse a `follows' spec.

(define (-ifld-parse-follows context follows)
  (if follows
      (let ((follows-obj (current-op-lookup follows)))
	(if (not follows-obj)
	    (parse-error context "unknown operand to follow" follows))
	follows-obj)
      #f)
)

; Do common parts of <ifield> encode/decode processing.

(define (-ifld-parse-encode-decode context which value)
  (if value
      (begin
	(if (or (not (list? value))
		(not (= (length value) 2))
		(not (list? (car value)))
		(not (= (length (car value)) 2))
		(not (list? (cadr value))))
	    (parse-error context
			 (string-append "bad ifield " which " spec")
			 value))
	(if (or (not (> (length (cadr value)) 2))
		(not (mode:lookup (cadr (cadr value)))))
	    (parse-error context
			 (string-append which " expression must have a mode")
			 value))))
  value
)

; Parse an <ifield> encode spec.

(define (-ifld-parse-encode context encode)
  (-ifld-parse-encode-decode context "encode" encode)
)

; Parse an <ifield> decode spec.

(define (-ifld-parse-decode context decode)
  (-ifld-parse-encode-decode context "decode" decode)
)

; Define an instruction field object, name/value pair list version.

(define define-ifield
  (lambda arg-list
    (let ((f (apply -ifield-read (cons (make-current-context "define-ifield")
				       arg-list))))
      (if f
	  (current-ifld-add! f))
      f))
)

; Define an instruction field object, all arguments specified.
; ??? Leave out word-offset,word-length,follows for now (RISC version).
; FIXME: Eventually this should be fixed to take *all* arguments.

(define (define-full-ifield name comment attrs start length mode encode decode)
  (let ((f (-ifield-parse (make-current-context "define-full-ifield")
			  name comment attrs
			  #f #f start length #f mode encode decode)))
    (if f
	(current-ifld-add! f))
    f)
)

(define (-ifield-add-commands!)
  (reader-add-command! 'define-ifield
		       "\
Define an instruction field, name/value pair list version.
"
		       nil 'arg-list define-ifield)
  (reader-add-command! 'define-full-ifield
		       "\
Define an instruction field, all arguments specified.
"
		       nil '(name comment attrs start length mode encode decode)
		       define-full-ifield)
  (reader-add-command! 'define-multi-ifield
		       "\
Define an instruction multi-field, name/value pair list version.
"
		       nil 'arg-list define-multi-ifield)
  (reader-add-command! 'define-full-multi-ifield
		       "\
Define an instruction multi-field, all arguments specified.
"
		       nil '(name comment attrs mode subflds insert extract)
		       define-full-multi-ifield)

  *UNSPECIFIED*
)

; Instruction fields consisting of multiple parts.

(define <multi-ifield>
  (class-make '<multi-ifield>
	      '(<ifield>)
	      '(
		; List of <ifield> objects.
		subfields
		; rtl to set SUBFIELDS from self
		insert
		; rtl to set self from SUBFIELDS
		extract
		)
	      nil)
)

(method-make-make! <multi-ifield> '(name comment attrs
				    mode bitrange encode decode
				    subfields insert extract))

; Accessors

(define-getters <multi-ifield> multi-ifld
  (subfields insert extract)
)

; Return a boolean indicating if X is an <ifield>.

(define (multi-ifield? x) (class-instance? <multi-ifield> x))

(define (non-multi-ifields ifld-list)
  (find (lambda (ifld) (not (multi-ifield? ifld))) ifld-list)
)

(define (non-derived-ifields ifld-list)
  (find (lambda (ifld) (not (derived-ifield? ifld))) ifld-list)
)


; Return the starting bit number of the first field.

(method-make-virtual!
 <multi-ifield> 'field-start
 (lambda (self word-len)
   (apply min (map (lambda (f) (ifld-start f #f)) (elm-get self 'subfields))))
)

; Return the total length.

(method-make-virtual!
 <multi-ifield> 'field-length
 (lambda (self)
   (apply + (map ifld-length (elm-get self 'subfields))))
)

; Return the bit offset of the word after the last word SELF is in.
; What a `word' here is defined by subfields in their bitranges.

(method-make!
 <multi-ifield> 'next-word
 (lambda (self)
   (apply max (map (lambda (f)
		     (bitrange-next-word (-ifld-bitrange f)))
		   (multi-ifld-subfields self))))
)

; Return mask of field in bitrange CONTAINER.

(method-make!
 <multi-ifield> 'field-mask
 (lambda (self base-len container)
   (apply + (map (lambda (f) (ifld-mask f base-len container)) (elm-get self 'subfields))))
)

; Return VALUE inserted into the field's position.
; The value is spread out over the various subfields in sorted order.
; We assume the subfields have been sorted by starting bit position.

(method-make!
 <multi-ifield> 'field-value
 (lambda (self base-len value)
   (apply + (map (lambda (f) (ifld-value f base-len value)) (elm-get self 'subfields))))
)

; Return a list of ifields required to compute the field's value.

(method-make!
 <multi-ifield> 'needed-iflds
 (lambda (self)
   (cons self (elm-get self 'subfields)))
)

; Extract <ifield> IFLD's value out of VALUE in <insn> INSN.
; VALUE is the entire insn's value if it fits in a word, or is a list
; of values, one per word (not implemented, sigh).
; ??? The instruction's format should specify where the word boundaries are.

(method-make!
 <multi-ifield> 'field-extract
 (lambda (self insn value)
   (let* ((subflds (sort-ifield-list (elm-get self 'subfields)
				     (not (ifld-lsb0? self))))
	  (subvals (map (lambda (subfld)
			  (ifld-extract subfld insn value))
			subflds))
	 )
     ; We have each subfield's value, now concatenate them.
     (letrec ((plus-scan (lambda (lengths current)
			   ; do the -1 drop here as it's easier
			   (if (null? (cdr lengths))
			       nil
			       (cons current
				     (plus-scan (cdr lengths)
						(+ current (car lengths))))))))
       (apply + (map logsll
		     subvals
		     (plus-scan (map ifld-length subflds) 0))))))
)

; Return a boolean indicating if bit 0 is the least significant bit.

(method-make!
 <multi-ifield> 'field-lsb0?
 (lambda (self)
   (ifld-lsb0? (car (elm-get self 'subfields))))
)

; Multi-ifield parsing.

; Subroutine of -multi-ifield-parse to build the default insert expression.

(define (-multi-ifield-make-default-insert container-name subfields)
  (let* ((lengths (map ifld-length subfields))
	 (shifts (list-tail-drop 1 (plus-scan (cons 0 lengths)))))
    ; Build RTL expression to shift and mask each ifield into right spot.
    (let ((exprs (map (lambda (f length shift)
			(rtx-make 'and (rtx-make 'srl container-name shift)
				  (mask length)))
		      subfields lengths shifts)))
      ; Now set each ifield with their respective values.
      (apply rtx-make (cons 'sequence
			    (cons nil
				  (map (lambda (f expr)
					 (rtx-make-set f expr))
				       subfields exprs))))))
)

; Subroutine of -multi-ifield-parse to build the default extract expression.

(define (-multi-ifield-make-default-extract container-name subfields)
  (let* ((lengths (map ifld-length subfields))
	 (shifts (list-tail-drop 1 (plus-scan (cons 0 lengths)))))
    ; Build RTL expression to shift and mask each ifield into right spot.
    (let ((exprs (map (lambda (f length shift)
			(rtx-make 'sll (rtx-make 'and (obj:name f)
						 (mask length))
				  shift))
		      subfields lengths shifts)))
      ; Now set {container-name} with all the values or'd together.
      (rtx-make-set container-name
		    (rtx-combine 'or exprs))))
)

; Parse a multi-ifield spec.
; This is the main routine for building the object from the .cpu file.
; All arguments are in raw (non-evaluated) form.
; The result is the parsed object or #f if object isn't for selected mach(s).

(define (-multi-ifield-parse context name comment attrs mode
			     subfields insert extract encode decode)
  (logit 2 "Processing multi-ifield element " name " ...\n")

  (if (null? subfields)
      (parse-error context "empty subfield list" subfields))

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name))
	 (atlist (atlist-parse context attrs "cgen_ifld"))
	 (isas (bitset-attr->list (atlist-attr-value atlist 'ISA #f))))

    ; No longer ensure only one isa specified.
    ; (if (!= (length isas) 1)
    ;     (parse-error context "can only specify 1 isa" attrs))

    (if (keep-isa-atlist? atlist #f)

	(begin
	  (let ((result (new <multi-ifield>))
		(subfields (map (lambda (subfld)
				  (let ((f (current-ifld-lookup subfld)))
				    (if (not f)
					(parse-error context "unknown ifield"
						     subfld))
				    f))
				subfields)))

	    (elm-xset! result 'name name)
	    (elm-xset! result 'comment (parse-comment context comment))
	    (elm-xset! result 'attrs
		       ;; multi-ifields are always VIRTUAL
		       (atlist-parse context (cons 'VIRTUAL attrs)
				     "multi-ifield"))
	    (elm-xset! result 'mode (parse-mode-name context mode))
	    (elm-xset! result 'encode (-ifld-parse-encode context encode))
	    (elm-xset! result 'decode (-ifld-parse-encode context decode))
	    (if insert
		(elm-xset! result 'insert insert)
		(elm-xset! result 'insert
			   (-multi-ifield-make-default-insert name subfields)))
	    (if extract
		(elm-xset! result 'extract extract)
		(elm-xset! result 'extract
			   (-multi-ifield-make-default-extract name subfields)))
	    (elm-xset! result 'subfields subfields)
	    result))

	; else don't keep isa
	#f))
)

; Read an instruction multi-ifield.
; This is the main routine for analyzing multi-ifields in the .cpu file.
; CONTEXT is a <context> object for error messages.
; ARG-LIST is an associative list of field name and field value.
; -multi-ifield-parse is invoked to create the `multi-ifield' object.

(define (-multi-ifield-read context . arg-list)
  (let (
	(name nil)
	(comment "")
	(attrs nil)
	(mode 'UINT)
	(subflds nil)
	(insert #f)
	(extract #f)
	(encode #f)
	(decode #f)
	)

    ; Loop over each element in ARG-LIST, recording what's found.
    (let loop ((arg-list arg-list))
      (if (null? arg-list)
	  nil
	  (let ((arg (car arg-list))
		(elm-name (caar arg-list)))
	    (case elm-name
	      ((name) (set! name (cadr arg)))
	      ((comment) (set! comment (cadr arg)))
	      ((attrs) (set! attrs (cdr arg)))
	      ((mode) (set! mode (cadr arg)))
	      ((subfields) (set! subflds (cdr arg)))
	      ((insert) (set! insert (cadr arg)))
	      ((extract) (set! extract (cadr arg)))
	      ((encode) (set! encode (cdr arg)))
	      ((decode) (set! decode (cdr arg)))
	      (else (parse-error context "invalid ifield arg" arg)))
	    (loop (cdr arg-list)))))

    ; Now that we've identified the elements, build the object.
    (-multi-ifield-parse context name comment attrs mode subflds
			 insert extract encode decode))
)

; Define an instruction multi-field object, name/value pair list version.

(define define-multi-ifield
  (lambda arg-list
    (let ((f (apply -multi-ifield-read (cons (make-current-context "define-multi-ifield")
					     arg-list))))
      (if f
	  (current-ifld-add! f))
      f))
)

; Define an instruction multi-field object, all arguments specified.
; FIXME: encode/decode arguments are missing.

(define (define-full-multi-ifield name comment attrs mode subflds insert extract)
  (let ((f (-multi-ifield-parse (make-current-context "define-full-multi-ifield")
				name comment attrs
				mode subflds insert extract #f #f)))
    (current-ifld-add! f)
    f)
)

; Derived ifields (ifields based on one or more other ifields).
; These support the complicated requirements of CISC instructions
; where one "ifield" is actually a placeholder for an addressing mode
; which can consist of several ifields.
; These are also intended to support other complex ifield usage.
;
; Derived ifields are (currently) always machine generated from other
; elements of the description file so there is no reader support.
;
; ??? experimental and wip!
; ??? These are kind of like multi-ifields but I don't want to disturb them
; while this is still experimental.

(define <derived-ifield>
  (class-make '<derived-ifield>
	      '(<ifield>)
	      '(
		; Operand that uses this ifield.
		; Unlike other ifields, derived ifields have a one-to-one
		; correspondence with the operand that uses them.
		; ??? Not true in -anyof-merge-subchoices.
		owner

		; List of ifields that make up this ifield.
		subfields
		)
	      nil)
)

(method-make!
 <derived-ifield> 'needed-iflds
 (lambda (self)
   (find (lambda (ifld) (not (ifld-constant? ifld)))
	 (elm-get self 'subfields)))
)

(method-make!
 <derived-ifield> 'make!
 (lambda (self name comment attrs owner subfields)
   (elm-set! self 'name name)
   (elm-set! self 'comment comment)
   (elm-set! self 'attrs attrs)
   (elm-set! self 'mode UINT)
   (elm-set! self 'bitrange (make <bitrange> 0 0 0 0 #f))
   (elm-set! self 'owner owner)
   (elm-set! self 'subfields subfields)
   self)
)

; Accessors.

(define-getters <derived-ifield> derived-ifield (owner subfields))

(define-setters <derived-ifield> derived-ifield (owner subfields))

(define (derived-ifield? x) (class-instance? <derived-ifield> x))

; Return a boolean indicating if F is a derived ifield with a derived operand
; for a value.
; ??? The former might imply the latter so some simplification may be possible.

(define (ifld-derived-operand? f)
  (and (derived-ifield? f)
       (derived-operand? (ifld-get-value f)))
)

; Return the bit offset of the word after the last word SELF is in.
; What a `word' here is defined by subfields in their bitranges.

(method-make!
 <derived-ifield> 'next-word
 (lambda (self)
   (apply max (map (lambda (f)
		     (bitrange-next-word (-ifld-bitrange f)))
		   (derived-ifield-subfields self))))
)

; Traverse the ifield to collect all base (non-derived) ifields used in it.

(define (ifld-base-ifields ifld)
  (cond ((derived-ifield? ifld) (collect (lambda (subfield) (ifld-base-ifields subfield))
					 (derived-ifield-subfields ifld)))
	; ((multi-ifield? ifld) (collect (lambda (subfield) (ifld-base-ifields subfield))
	; 			       (multi-ifld-subfields ifld)))
	(else (list ifld)))
)

; Misc. utilities.

; Sort a list of fields (sorted by the starting bit number).
; This must be carefully defined to pass through Hobbit.
; (define foo (if x bar baz)) is ok.
; (if x (define foo bar) (define foo baz)) is not ok.
;
; ??? Usually there aren't that many fields and the range of values is fixed,
; so I think this needn't use a general purpose sort routine (should it become
; an issue).

(define sort-ifield-list
  (if (and (defined? 'cgh-qsort) (defined? 'cgh-qsort-int-cmp))
      (lambda (fld-list up?)
	(cgh-qsort fld-list
		   (if up?
		       (lambda (a b)
			 (cgh-qsort-int-cmp (ifld-start a #f)
					    (ifld-start b #f)))
		       (lambda (a b)
			 (- (cgh-qsort-int-cmp (ifld-start a #f)
					       (ifld-start b #f)))))))
      (lambda (fld-list up?)
	(sort fld-list
	      (if up?
		  (lambda (a b) (< (ifld-start a #f)
				   (ifld-start b #f)))
		  (lambda (a b) (> (ifld-start a #f)
				   (ifld-start b #f)))))))
)

; Return a boolean indicating if field F extends beyond the base insn.

(define (ifld-beyond-base? f base-bitsize total-bitsize)
  ; old way
  ;(< base-bitsize (+ (ifld-start f total-bitsize) (ifld-length f)))
  (> (ifld-word-offset f) 0)
)

; Return the mode of the decoded value of <ifield> F.
; ??? This is made easy because we require the decode expression to have
; an explicit mode.

(define (ifld-decode-mode f)
  (if (not (elm-bound? f 'decode))
      (ifld-mode f)
      (let ((d (ifld-decode f)))
	(if d
	    (mode:lookup (cadr (cadr d)))
	    (ifld-mode f))))
)

; Return <hardware> object to use to hold value of <ifield> F.
; i.e. one of h-uint, h-sint.
; NB: Should be defined in terms of `hardware-for-mode'.
(define (ifld-hw-type f)
  (case (mode:class (ifld-mode f))
    ((INT) h-sint)
    ((UINT) h-uint)
    (else (error "unsupported mode class" (mode:class (ifld-mode f)))))
)

; Builtin fields, attributes, init/fini support.

; The f-nil field is a placeholder when building operands out of hardware
; elements that aren't indexed by an instruction field (scalars).
(define f-nil #f)

(define (ifld-nil? f)
  (eq? (obj:name f) 'f-nil)
)

; The f-anyof field is a placeholder when building "anyof" operands.
(define f-anyof #f)

(define (ifld-anyof? f)
  (eq? (obj:name f) 'f-anyof)
)

; Return a boolean indicating if F is an anyof ifield with an anyof operand
; for a value.
; ??? The former implies the latter so some simplification is possible.

(define (ifld-anyof-operand? f)
  (and (ifld-anyof? f)
       (anyof-operand? (ifld-get-value f)))
)

; Called before loading the .cpu file to initialize.

(define (ifield-init!)
  (-ifield-add-commands!)

  *UNSPECIFIED*
)

; Called before loading the .cpu file to create any builtins.

(define (ifield-builtin!)
  ; Standard ifield attributes.
  ; ??? Some of these can be combined into one, booleans are easier to
  ; work with.
  (define-attr '(for ifield operand) '(type boolean) '(name PCREL-ADDR)
    '(comment "pc relative address"))
  (define-attr '(for ifield operand) '(type boolean) '(name ABS-ADDR)
    '(comment "absolute address"))
  (define-attr '(for ifield) '(type boolean) '(name RESERVED)
    '(comment "field is reserved"))
  (define-attr '(for ifield operand) '(type boolean) '(name SIGN-OPT)
    '(comment "value is signed or unsigned"))
  ; ??? This is an internal attribute for implementation purposes only.
  ; To be revisited.
  (define-attr '(for ifield operand) '(type boolean) '(name SIGNED)
    '(comment "value is unsigned"))
  ; Also (defined elsewhere): VIRTUAL

  (set! f-nil (make <ifield> (builtin-location)
		    'f-nil "empty ifield"
		    (atlist-cons (all-isas-attr) nil)
		    UINT
		    (make <bitrange> 0 0 0 0 #f)
		    #f #f)) ; encode/decode
  (current-ifld-add! f-nil)

  (set! f-anyof (make <ifield> (builtin-location)
		      'f-anyof "placeholder for anyof operands"
		      (atlist-cons (all-isas-attr) nil)
		      UINT
		      (make <bitrange> 0 0 0 0 #f)
		      #f #f)) ; encode/decode
  (current-ifld-add! f-anyof)

  *UNSPECIFIED*
)

; Called after the .cpu file has been read in.

(define (ifield-finish!)
  *UNSPECIFIED*
)
