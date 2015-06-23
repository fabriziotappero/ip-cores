; CPU architecture description.
; Copyright (C) 2000, 2003, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; Top level class that records everything about a cpu.
; FIXME: Rename this to something else and rename <arch-data> to <arch>
; for consistency with other classes (define-foo -> <foo> object).

(define <arch>
  (class-make '<arch>
	      nil
	      '(
		; An object of type <arch-data>.
		data

		;; ??? All should really be assumed to be a black-box table.
		(attr-list . (() . ()))
		(enum-list . ())
		(kw-list . ())
		(isa-list . ())
		(cpu-list . ())
		(mach-list . ())
		(model-list . ())
		(ifld-table . ())
		(hw-list . ())
		(op-table . ())
		(ifmt-list . ())
		(sfmt-list . ())
		(insn-table . ())
		(minsn-table . ())
		(subr-list . ())

		(insn-extract . #f) ; FIXME: wip (and move elsewhere)
		(insn-execute . #f) ; FIXME: wip (and move elsewhere)

		; standard values derived from the input data
		derived

		; #t if instructions have been analyzed
		(insns-analyzed? . #f)
		; #t if semantics were included in the analysis
		(semantics-analyzed? . #f)
		; #t if alias insns were included in the analysis
		(aliases-analyzed? . #f)

		; ordinal of next object that needs one
		(next-ordinal . 0)
		)
	      nil)
)

; Accessors.
; Each getter is arch-foo.
; Each setter is arch-set-foo!.

(define-getters <arch> arch
  (data
   attr-list enum-list kw-list
   isa-list cpu-list mach-list model-list
   ifld-table hw-list op-table ifmt-list sfmt-list
   insn-table minsn-table subr-list
   derived
   insns-analyzed? semantics-analyzed? aliases-analyzed?
   next-ordinal
   )
)

(define-setters <arch> arch 
  (data
   attr-list enum-list kw-list
   isa-list cpu-list mach-list model-list
   ifld-table hw-list op-table ifmt-list sfmt-list
   insn-table minsn-table subr-list
   derived
   insns-analyzed? semantics-analyzed? aliases-analyzed?
   next-ordinal
   )
)

; For elements recorded as a table, return a sorted list.
; ??? All elements should really be assumed to be a black-box table.

(define (arch-ifld-list arch)
  (-ident-object-table->list (arch-ifld-table arch))
)

(define (arch-op-list arch)
  (-ident-object-table->list (arch-op-table arch))
)

(define (arch-insn-list arch)
  (-ident-object-table->list (arch-insn-table arch))
)

(define (arch-minsn-list arch)
  (-ident-object-table->list (arch-minsn-table arch))
)

;; Get the next ordinal and increment it for the next time.

(define (-get-next-ordinal! arch)
  (let ((ordinal (arch-next-ordinal arch)))
    (arch-set-next-ordinal! arch (+ ordinal 1))
    ordinal)
)

;; FIXME: temp hack for current-ifld-lookup, current-op-lookup.
;; Return the element of list L with the lowest ordinal.

(define (-get-lowest-ordinal l)
  (let ((lowest-obj #f)
	(lowest-ord (-get-next-ordinal! CURRENT-ARCH)))
    (for-each (lambda (elm)
		(if (< (obj-ordinal elm) lowest-ord)
		    (begin
		      (set! lowest-obj elm)
		      (set! lowest-ord (obj-ordinal elm)))))
	      l)
    lowest-obj)
)

;; Table of <source-ident> objects with two access styles:
;; hash lookup, ordered list.
;; The main table is the hash table, the list is lazily created and cached.
;; The table is recorded as (hash-table . list).
;; The list is #f if it needs to be computed.
;; Each entry in the hash table is a list, multiple objects can have the same
;; key (e.g. insns from different isas can have the same name).
;;
;; This relies on the ordinal element of <source-ident> objects to build the
;; ordered list.

(define (-make-ident-object-table hash-size)
  (cons (make-hash-table hash-size) #f)
)

;; Return ordered list.
;;
;; To allow splicing in new objects we recognize two kinds of ordinal numbers:
;; integer and (integer . integer) where the latter is a pair of
;; major-ordinal-number and minor-ordinal-number.

(define (-ident-object-table->list iot)
  (if (cdr iot)
      (cdr iot)
      (let ((unsorted (hash-fold (lambda (key value prior)
				   ;; NOTE: {value} usually contains just
				   ;; one element.
				   (append value prior))
				 '()
				 (car iot))))
	(set-cdr! iot
		  (sort unsorted (lambda (a b)
				   ;; Ordinals are either an integer or
				   ;; (major . minor).
				   (let ((oa (obj-ordinal a))
					 (ob (obj-ordinal b)))
				     ;; Quick test for common case.
				     (if (and (number? oa) (number? ob))
					 (< oa ob)
					 (let ((maj-a (if (pair? oa) (car oa) oa))
					       (maj-b (if (pair? ob) (car ob) ob))
					       (min-a (if (pair? oa) (cdr oa) 0))
					       (min-b (if (pair? ob) (cdr ob) 0)))
					   (cond ((< maj-a maj-b) #t)
						 ((= maj-a maj-b) (< min-a min-b))
						 (else #f))))))))
	(cdr iot)))
)

;; Add an entry to an ident-object-table.

(define (-ident-object-table-add! arch iot key object)
  ;; Give OBJECT an ordinal if it doesn't have one already.
  (if (not (obj-ordinal object))
      (obj-set-ordinal! object (-get-next-ordinal! arch)))

  ;; Remember: Elements in the hash table are lists of objects, this is because
  ;; multiple objects can have the same key if they come from different isas.
  (let ((elm (hashq-ref (car iot) key)))
    (if elm
	(hashq-set! (car iot) key (cons object elm))
	(hashq-set! (car iot) key (cons object nil))))

  ;; Need to recompute the sorted list.
  (set-cdr! iot #f)

  *UNSPECIFIED*
)

;; Look up KEY in an ident-object-table.

(define (-ident-object-table-lookup iot key)
  (hashq-ref iot key)
)

; Class for recording things specified in `define-arch'.
; This simplifies define-arch as the global arch object CURRENT-ARCH
; must exist before loading the .cpu file.

(define <arch-data>
  (class-make '<arch-data>
	      '(<ident>)
	      '(
		; Default alignment of memory operations.
		; One of aligned, unaligned, forced.
		default-alignment

		; Orientation of insn bit numbering (#f->msb=0, #t->lsb=0).
		insn-lsb0?

		; List of all machs.
		; Each element is pair of (mach-name . sanitize-key)
		; where sanitize-key is #f if there is none.
		; blah blah blah ... ooohhh, evil sanitize key, blah blah blah
		machs

		; List of all isas (instruction set architecture).
		; Each element is a pair of (isa-name . sanitize-key)
		; where sanitize-key is #f if there is none.
		; There is usually just one.  ARM has two (arm, thumb).
		; blah blah blah ... ooohhh, evil sanitize key, blah blah blah
		isas

		; ??? Defaults for other things should be here.
		)
	      nil)
)

(define-getters <arch-data> adata
  (default-alignment insn-lsb0? machs isas)
)

; Add, list, lookup accessors for <arch>.
;
; For the lookup routines, the result is the object or #f if not found.
; For some, if X is already an object, return that.

(define (current-arch-name) (obj:name (arch-data CURRENT-ARCH)))

(define (current-arch-comment) (obj:comment (arch-data CURRENT-ARCH)))

(define (current-arch-atlist) (obj-atlist (arch-data CURRENT-ARCH)))

(define (current-arch-default-alignment)
  (adata-default-alignment (arch-data CURRENT-ARCH)))

(define (current-arch-insn-lsb0?)
  (adata-insn-lsb0? (arch-data CURRENT-ARCH)))

(define (current-arch-mach-name-list)
  (map car (adata-machs (arch-data CURRENT-ARCH)))
)

(define (current-arch-isa-name-list)
  (map car (adata-isas (arch-data CURRENT-ARCH)))
)

; Attributes.
; Recorded as a pair of lists.
; The car is a list of <attribute> objects.
; The cdr is an associative list of (name . <attribute>) elements, for lookup.
; Could use a hash table except that there currently aren't that many.

(define (current-attr-list) (car (arch-attr-list CURRENT-ARCH)))

(define (current-attr-add! a)
  ; NOTE: While putting this test in define-attr feels better, having it here
  ; is more robust, internal calls get checked too.  Thus it's here.
  ; Ditto for all the other such tests in this file.
  (if (current-attr-lookup (obj:name a))
      (parse-error (make-current-context "define-attr")
		   "attribute already defined" (obj:name a)))
  (let ((adata (arch-attr-list CURRENT-ARCH)))
    ; Build list in normal order so we don't have to reverse it at the end
    ; (since our format is non-trivial).
    (if (null? (car adata))
	(arch-set-attr-list! CURRENT-ARCH
			     (cons (cons a nil)
				   (acons (obj:name a) a nil)))
	(begin
	  (append! (car adata) (cons a nil))
	  (append! (cdr adata) (acons (obj:name a) a nil)))))
  *UNSPECIFIED*
)

(define (current-attr-lookup attr-name)
  (assq-ref (cdr (arch-attr-list CURRENT-ARCH)) attr-name)
)

; Enums.

(define (current-enum-list) (arch-enum-list CURRENT-ARCH))

(define (current-enum-add! e)
  (if (current-enum-lookup (obj:name e))
      (parse-error (make-current-context "define-enum")
		   "enum already defined" (obj:name e)))
  (arch-set-enum-list! CURRENT-ARCH (cons e (arch-enum-list CURRENT-ARCH)))
  *UNSPECIFIED*
)

(define (current-enum-lookup enum-name)
  (object-assq enum-name (current-enum-list))
)

; Keywords.

(define (current-kw-list) (arch-kw-list CURRENT-ARCH))

(define (current-kw-add! kw)
  (if (current-kw-lookup (obj:name kw))
      (parse-error (make-current-context "define-keyword")
		   "keyword already defined" (obj:name kw)))
  (arch-set-kw-list! CURRENT-ARCH (cons kw (arch-kw-list CURRENT-ARCH)))
  *UNSPECIFIED*
)

(define (current-kw-lookup kw-name)
  (object-assq kw-name (current-kw-list))
)

; Instruction sets.

(define (current-isa-list) (arch-isa-list CURRENT-ARCH))

(define (current-isa-add! i)
  (if (current-isa-lookup (obj:name i))
      (parse-error (make-current-context "define-isa")
		   "isa already defined" (obj:name i)))
  (arch-set-isa-list! CURRENT-ARCH (cons i (arch-isa-list CURRENT-ARCH)))
  *UNSPECIFIED*
)

(define (current-isa-lookup isa-name)
  (object-assq isa-name (current-isa-list))
)

; Cpu families.

(define (current-cpu-list) (arch-cpu-list CURRENT-ARCH))

(define (current-cpu-add! c)
  (if (current-cpu-lookup (obj:name c))
      (parse-error (make-current-context "define-cpu")
		   "cpu already defined" (obj:name c)))
  (arch-set-cpu-list! CURRENT-ARCH (cons c (arch-cpu-list CURRENT-ARCH)))
  *UNSPECIFIED*
)

(define (current-cpu-lookup cpu-name)
  (object-assq cpu-name (current-cpu-list))
)

; Machines.

(define (current-mach-list) (arch-mach-list CURRENT-ARCH))

(define (current-mach-add! m)
  (if (current-mach-lookup (obj:name m))
      (parse-error (make-current-context "define-mach")
		   "mach already defined" (obj:name m)))
  (arch-set-mach-list! CURRENT-ARCH (cons m (arch-mach-list CURRENT-ARCH)))
  *UNSPECIFIED*
)

(define (current-mach-lookup mach-name)
  (object-assq mach-name (current-mach-list))
)

; Models.

(define (current-model-list) (arch-model-list CURRENT-ARCH))

(define (current-model-add! m)
  (if (current-model-lookup (obj:name m))
      (parse-error (make-current-context "define-model")
		   "model already defined" (obj:name m)))
  (arch-set-model-list! CURRENT-ARCH (cons m (arch-model-list CURRENT-ARCH)))
  *UNSPECIFIED*
)

(define (current-model-lookup model-name)
  (object-assq model-name (current-model-list))
)

; Hardware elements.

(define (current-hw-list) (arch-hw-list CURRENT-ARCH))

(define (current-hw-add! hw)
  (if (current-hw-lookup (obj:name hw))
      (parse-error (make-current-context "define-hardware")
		   "hardware already defined" (obj:name hw)))
  (arch-set-hw-list! CURRENT-ARCH (cons hw (arch-hw-list CURRENT-ARCH)))
  *UNSPECIFIED*
)

(define (current-hw-lookup hw)
  (if (object? hw)
      hw
      ; This doesn't use object-assq on purpose.  Hardware objects handle
      ; get-name specially.
      (find-first (lambda (hw-obj) (eq? (send hw-obj 'get-name) hw))
		  (current-hw-list)))
)

; Instruction fields.

(define (current-ifld-list)
  (-ident-object-table->list (arch-ifld-table CURRENT-ARCH))
)

(define (current-ifld-add! f)
  (if (-ifld-already-defined? f)
      (parse-error (make-obj-context f "define-ifield")
		   "ifield already defined" (obj:name f)))
  (-ident-object-table-add! CURRENT-ARCH (arch-ifld-table CURRENT-ARCH)
			    (obj:name f) f)
  *UNSPECIFIED*
)

;; Look up ifield X in the current architecture.
;;
;; If X is an <ifield> object, just return it.
;; This is to handle ???
;; Otherwise X is the name of the ifield to look up.
;;
;; ??? This doesn't work if there are multiple operands with the same name
;; for different isas.

(define (current-ifld-lookup x)
  (if (ifield? x)
      x
      (let ((f-list (-ident-object-table-lookup (car (arch-ifld-table CURRENT-ARCH))
						x)))
	(if f-list
	    (if (= (length f-list) 1)
		(car f-list)
		;; FIXME: For now just return the first one,
		;; same behaviour as before.
		;; Here "first one" means "first defined".
		(-get-lowest-ordinal f-list))
	    #f)))
)

; Return a boolean indicating if <ifield> F is currently defined.
; This is slightly complicated because multiple isas can have different
; ifields with the same name.

(define (-ifld-already-defined? f)
  (let ((iflds (-ident-object-table-lookup (car (arch-ifld-table CURRENT-ARCH))
					   (obj:name f))))
    ; We've got all the ifields with the same name,
    ; now see if any have the same ISA as F.
    (if iflds
	(let ((result #f)
	      (f-isas (obj-isa-list f)))
	  (for-each (lambda (ff)
		      (if (not (null? (intersection f-isas (obj-isa-list ff))))
			  (set! result #t)))
		    iflds)
	  result)
	#f))
)

; Operands.

(define (current-op-list)
  (-ident-object-table->list (arch-op-table CURRENT-ARCH))
)

(define (current-op-add! op)
  (if (-op-already-defined? op)
      (parse-error (make-obj-context op "define-operand")
		   "operand already defined" (obj:name op)))
  (-ident-object-table-add! CURRENT-ARCH (arch-op-table CURRENT-ARCH)
			    (obj:name op) op)
  *UNSPECIFIED*
)

; ??? This doesn't work if there are multiple operands with the same name
; for different isas.

(define (current-op-lookup name)
  (let ((op-list (-ident-object-table-lookup (car (arch-op-table CURRENT-ARCH))
					     name)))
    (if op-list
	(if (= (length op-list) 1)
	    (car op-list)
	    ;; FIXME: For now just return the first one, same behaviour as before.
	    ;; Here "first one" means "first defined".
	    (-get-lowest-ordinal op-list))
	#f))
)

; Return a boolean indicating if <operand> OP is currently defined.
; This is slightly complicated because multiple isas can have different
; operands with the same name.

(define (-op-already-defined? op)
  (let ((ops (-ident-object-table-lookup (car (arch-op-table CURRENT-ARCH))
					 (obj:name op))))
    ; We've got all the operands with the same name,
    ; now see if any have the same ISA as OP.
    (if ops
	(let ((result #f)
	      (op-isas (obj-isa-list op)))
	  (for-each (lambda (o)
		      (if (not (null? (intersection op-isas (obj-isa-list o))))
			  (set! result #t)))
		    ops)
	  result)
	#f))
)

; Instruction field formats.

(define (current-ifmt-list) (arch-ifmt-list CURRENT-ARCH))

; Semantic formats (akin to ifmt's, except includes semantics to distinguish
; insns).

(define (current-sfmt-list) (arch-sfmt-list CURRENT-ARCH))

; Instructions.

(define (current-insn-list)
  (-ident-object-table->list (arch-insn-table CURRENT-ARCH))
)

(define (current-insn-add! i)
  (if (-insn-already-defined? i)
      (parse-error (make-obj-context i "define-insn")
		   "insn already defined" (obj:name i)))
  (-ident-object-table-add! CURRENT-ARCH (arch-insn-table CURRENT-ARCH)
			    (obj:name i) i)
  *UNSPECIFIED*
)

; ??? This doesn't work if there are multiple insns with the same name
; for different isas.

(define (current-insn-lookup name)
  (let ((i (-ident-object-table-lookup (car (arch-insn-table CURRENT-ARCH))
				       name)))
    (if i
	(begin
	  (if (= (length i) 1)
	      (car i)
	      ;; FIXME: For now just flag an error.
	      ;; Later add an isa-list arg to distinguish.
	      (error "multiple insns with name:" name)))
	#f))
)

; Return a boolean indicating if <insn> INSN is currently defined.
; This is slightly complicated because multiple isas can have different
; insns with the same name.

(define (-insn-already-defined? insn)
  (let ((insns (-ident-object-table-lookup (car (arch-insn-table CURRENT-ARCH))
					   (obj:name insn))))
    ; We've got all the insns with the same name,
    ; now see if any have the same ISA as INSN.
    (if insns
	(let ((result #f)
	      (insn-isas (obj-isa-list insn)))
	  (for-each (lambda (i)
		      (if (not (null? (intersection insn-isas (obj-isa-list i))))
			  (set! result #t)))
		    insns)
	  result)
	#f))
)

; Macro instructions.

(define (current-minsn-list)
  (-ident-object-table->list (arch-minsn-table CURRENT-ARCH))
)

(define (current-minsn-add! m)
  (if (-minsn-already-defined? m)
      (parse-error (make-obj-context m "define-minsn")
		   "macro-insn already defined" (obj:name m)))
  (-ident-object-table-add! CURRENT-ARCH (arch-minsn-table CURRENT-ARCH)
			    (obj:name m) m)
  *UNSPECIFIED*
)

; ??? This doesn't work if there are multiple minsns with the same name
; for different isas.

(define (current-minsn-lookup name)
  (let ((m (-ident-object-table-lookup (car (arch-minsn-table CURRENT-ARCH))
				       name)))
    (if m
	(begin
	  (if (= (length m) 1)
	      (car m)
	      ;; FIXME: For now just flag an error.
	      ;; Later add an isa-list arg to distinguish.
	      (error "multiple macro-insns with name:" name)))
	#f))
)

; Return a boolean indicating if <macro-insn> MINSN is currently defined.
; This is slightly complicated because multiple isas can have different
; macro-insns with the same name.

(define (-minsn-already-defined? m)
  (let ((minsns (-ident-object-table-lookup (car (arch-minsn-table CURRENT-ARCH))
					    (obj:name m))))
    ; We've got all the macro-insns with the same name,
    ; now see if any have the same ISA as M.
    (if minsns
	(let ((result #f)
	      (m-isas (obj-isa-list m)))
	  (for-each (lambda (mm)
		      (if (not (null? (intersection m-isas (obj-isa-list mm))))
			  (set! result #t)))
		    minsns)
	  result)
	#f))
)

; rtx subroutines.

(define (current-subr-list) (map cdr (arch-subr-list CURRENT-ARCH)))

(define (current-subr-add! s)
  (if (current-subr-lookup (obj:name s))
      (parse-error (make-current-context "define-subr")
		   "subroutine already defined" (obj:name s)))
  (arch-set-subr-list! CURRENT-ARCH
		       (acons (obj:name s) s (arch-subr-list CURRENT-ARCH)))
  *UNSPECIFIED*
)

(define (current-subr-lookup name)
  (assq-ref (arch-subr-list CURRENT-ARCH) name)
)

; Arch parsing support.

; Parse an alignment spec.

(define (-arch-parse-alignment context alignment)
  (if (memq alignment '(aligned unaligned forced))
      alignment
      (parse-error context "invalid alignment" alignment))
)

; Parse an arch mach spec.
; The value is a list of mach names or (mach-name sanitize-key) elements.
; The result is a list of (mach-name . sanitize-key) elements.

(define (-arch-parse-machs context machs)
  (for-each (lambda (m)
	      (if (or (symbol? m)
		      (and (list? m) (= (length m) 2)
			   (symbol? (car m)) (symbol? (cadr m))))
		  #t ; ok
		  (parse-error context "bad arch mach spec" m)))
	    machs)
  (map (lambda (m)
	 (if (symbol? m)
	     (cons m #f)
	     (cons (car m) (cadr m))))
       machs)
)

; Parse an arch isa spec.
; The value is a list of isa names or (isa-name sanitize-key) elements.
; The result is a list of (isa-name . sanitize-key) elements.

(define (-arch-parse-isas context isas)
  (for-each (lambda (m)
	      (if (or (symbol? m)
		      (and (list? m) (= (length m) 2)
			   (symbol? (car m)) (symbol? (cadr m))))
		  #t ; ok
		  (parse-error context "bad arch isa spec" m)))
	    isas)
  (map (lambda (m)
	 (if (symbol? m)
	     (cons m #f)
	     (cons (car m) (cadr m))))
       isas)
)

; Parse an architecture description
; This is the main routine for building an arch object from a cpu
; description in the .cpu file.
; All arguments are in raw (non-evaluated) form.

(define (-arch-parse context name comment attrs
		     default-alignment insn-lsb0?
		     machs isas)
  (logit 2 "Processing arch " name " ...\n")
  (make <arch-data>
    (parse-name context name)
    (parse-comment context comment)
    (atlist-parse context attrs "arch")
    (-arch-parse-alignment context default-alignment)
    (parse-boolean context insn-lsb0?)
    (-arch-parse-machs context machs)
    (-arch-parse-isas context isas))
)

; Read an architecture description.
; This is the main routine for analyzing an arch description in the .cpu file.
; ARG-LIST is an associative list of field name and field value.
; parse-arch is invoked to create the `arch' object.

(define -arch-read
  (lambda arg-list
    (let ((context "arch-read")
	  ; <arch-data> object members and default values
	  (name "unknown")
	  (comment "")
	  (attrs nil)
	  (default-alignment 'aligned)
	  (insn-lsb0? #f)
	  (machs #f)
	  (isas #f)
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
      		((default-alignment) (set! default-alignment (cadr arg)))
      		((insn-lsb0?) (set! insn-lsb0? (cadr arg)))
      		((machs) (set! machs (cdr arg)))
      		((isas) (set! isas (cdr arg)))
		(else (parse-error context "invalid arch arg" arg)))
	      (loop (cdr arg-list)))))
      ; Ensure required fields are present.
      (if (not machs)
	  (parse-error context "missing machs spec"))
      (if (not isas)
	  (parse-error context "missing isas spec"))
      ; Now that we've identified the elements, build the object.
      (-arch-parse context name comment attrs default-alignment insn-lsb0?
		   machs isas)
      )
    )
)

; Define an arch object, name/value pair list version.

(define define-arch
  (lambda arg-list
    (let ((a (apply -arch-read arg-list)))
      (arch-set-data! CURRENT-ARCH a)
      (def-mach-attr! (adata-machs a))
      (keep-mach-validate!)
      (def-isa-attr! (adata-isas a))
      (keep-isa-validate!)
      ; Install the builtin objects now that we have an arch, and now that
      ; attributes MACH and ISA exist.
      (reader-install-builtin!)
      a))
)

; Mach/isa processing.

; Create the MACH attribute.
; MACHS is the canonicalized machs spec to define-arch: (name . sanitize-key).

(define (def-mach-attr! machs)
  (let ((mach-enums (append
		     '((base))
		     (map (lambda (mach)
			    (cons (car mach)
				  (cons '-
					(if (cdr mach)
					    (list (cons 'sanitize (cdr mach)))
					    nil))))
			  machs)
		     '((max)))))
    (define-attr '(type bitset) '(name MACH)
      '(comment "machine type selection")
      '(default base) (cons 'values mach-enums))
    )

  *UNSPECIFIED*
)

; Return #t if MACH is supported by OBJ.
; This is done by looking for the MACH attribute in OBJ.
; By definition, objects that support the default (base) mach support
; all machs.

(define (mach-supports? mach obj)
  (let ((machs (bitset-attr->list (obj-attr-value obj 'MACH)))
	(name (obj:name mach)))
    (or (memq name machs)
	(memq 'base machs)))
	;(let ((deflt (attr-lookup-default 'MACH obj)))
	;  (any-true? (map (lambda (m) (memq m deflt)) machs)))))
)

; Create the ISA attribute.
; ISAS is the canonicalized isas spec to define-arch: (name . sanitize-key).
; ISAS is a list of isa names.

(define (def-isa-attr! isas)
  (let ((isa-enums (append
		    (map (lambda (isa)
			   (cons (car isa)
				 (cons '-
				       (if (cdr isa)
					   (list (cons 'sanitize (cdr isa)))
					   nil))))
			 isas)
		    '((max)))))
    ; Using a bitset attribute here implies something could be used by two
    ; separate isas.  This seems highly unlikely but we don't [as yet]
    ; preclude it.  The other thing to consider is whether the cpu table
    ; would ever want to be opened for multiple isas.
    (define-attr '(type bitset) '(name ISA)
      '(comment "instruction set selection")
      ; If there's only one isa, don't (yet) pollute the tables with a value
      ; for it.
      (if (= (length isas) 1)
	  '(for)
	  '(for ifield operand insn hardware))
      (cons 'values isa-enums))
    )

  *UNSPECIFIED*
)

; Return the bitset attr value for all isas.

(define (all-isas-attr-value)
  (stringize (current-arch-isa-name-list) ",")
)

; Return an ISA attribute of all isas.
; This is useful for things like f-nil which exist across all isas.

(define (all-isas-attr)
  (bitset-attr-make 'ISA (all-isas-attr-value))
)

; Return list of ISA names specified by attribute object ATLIST.

(define (attr-isa-list atlist)
  (bitset-attr->list (atlist-attr-value atlist 'ISA #f))
)

; Return list of ISA names specified by OBJ.

(define (obj-isa-list obj)
  (bitset-attr->list (obj-attr-value obj 'ISA))
)

; Return #t if <isa> ISA is supported by OBJ.
; This is done by looking for the ISA attribute in OBJ.

(define (isa-supports? isa obj)
  (let ((isas (obj-isa-list obj))
	(name (obj:name isa)))
    (->bool (memq name isas)))
)

; The fetch/decode/execute process.
; "extract" is a fancy word for fetch/decode.
; FIXME: wip, not currently used.
; FIXME: move to inside define-isa, and maybe elsewhere.
;
;(defmacro
;  define-extract (code)
;  ;(arch-set-insn-extract! CURRENT-ARCH code)
;  *UNSPECIFIED*
;)
;
;(defmacro
;  define-execute (code)
;  ;(arch-set-insn-execute! CURRENT-ARCH code)
;  *UNSPECIFIED*
;)

; ISA specification.
; Each architecture is generally one isa, but in the case of ARM (and a few
; others) there is more than one.
;
; ??? "ISA" has a very well defined meaning, and our usage of it one might
; want to quibble over.  A better name would be welcome.

; Associated with an instruction set is its framing.
; This refers to how instructions are laid out at the liw level (where several
; insns are framed together and executed sequentially or in parallel).
; ??? If one defines the term "format" as being how an individual instruction
; is laid out then formatting can be thought of as being different from
; framing.  However, it's possible for a particular ISA to intertwine the two.
; Thus this will need to evolve.
; ??? Not used yet, wip.

(define <iframe> ; pronounced I-frame
  (class-make '<iframe> '(<ident>)
	      '(
		; list of <itype> objects that make up the frame
		insns

		; assembler syntax
		syntax

		; list of (length value) elements that make up the format
		; Length is in bits.  Value is either a number or a $number
		; symbol refering to the insn specified in `insns'.
		value

		; Initial bitnumbers to decode insns by.
		; ??? At present the rest of the decoding is determined
		; algorithmically.  May wish to give the user more control
		; [like psim].
		decode-assist

		; rtl that executes instructions in `value'
		; Fields specified in `value' can be used here.
		action
		)
	      nil)
)

; Accessors.

(define-getters <iframe> iframe (insns syntax value decode-assist action))

; Instruction types, recorded in <iframe>.
; ??? Not used yet, wip.

(define <itype>
  (class-make '<itype> '(<ident>)
	      '(
		; length in bits, or initial part if variable length (wip)
		length

		; constraint specifying which insns are included
		constraint

		; Initial bitnumbers to decode insns by.
		; ??? At present the rest of the decoding is determined
		; algorithmically.  May wish to give the user more control
		; [like psim].
		decode-assist
		)
	      nil)
)

; Accessors.

(define-getters <itype> itype (length constraint decode-assist))

; Simulator instruction decode splitting.
; FIXME: Should live in simulator specific code.  Requires class handling
; cleanup first.
;
; Instructions can be split by particular values for an ifield.
; The ARM port uses this to split insns into those that set the pc and
; those that don't.

(define <decode-split>
  (class-make '<decode-split> '()
	      '(
		; Name of ifield to split on.
		name

		; Constraint.  Only insns satifying this constraint are
		; split.  #f if no constraint.
		constraint

		; List of ifield splits.
		; Each element is one of (name value) or (name (values)).
		values
		)
	      nil
	      )
)

; Accessors.

(define-getters <decode-split> decode-split (name constraint values))

; Parse a decode-split spec.
; SPEC is (ifield-name constraint value-list).
; CONSTRAINT is an rtl expression.  Only insns satifying the constraint
; are split.
; Each element of VALUE-LIST is one of (name value) or (name (values)).
; FIXME: All possible values must be specified.  Need an `else' clause.
; Ranges would also be useful.

(define (-isa-parse-decode-split context spec)
  (if (!= (length spec) 3)
      (parse-error context "decode-split spec is (ifield-name constraint value-list)" spec))

  (let ((name (parse-name (car spec) context))
	(constraint (cadr spec))
	(value-list (caddr spec)))

    ; FIXME: more error checking.

    (make <decode-split>
      name
      (if (null? constraint) #f constraint)
      value-list))
)

; Parse a list of decode-split specs.

(define (-isa-parse-decode-splits context spec-list)
  (map (lambda (spec)
	 (-isa-parse-decode-split context spec))
       spec-list)
)

; Top level class to describe an isa.

(define <isa>
  (class-make '<isa> '(<ident>)
	      '(
		; Default length to record in ifields.
		; This is used in calculations involving bit numbers.
		default-insn-word-bitsize

		; Length of an unknown instruction.  Used by disassembly
		; and by the simulator's invalid insn handler.
		default-insn-bitsize

		; Number of bytes of insn that can be initially fetched.
		; In non-LIW isas this would be the length of the smallest
		; insn.  For LIW isas it depends - only one LIW isa is
		; currently supported (m32r).
		base-insn-bitsize

		; Initial bitnumbers to decode insns by.
		; ??? At present the rest of the decoding is determined
		; algorithmically.  May wish to give the user more control
		; [like psim].
		decode-assist

		; Number of instructions that can be fetched at a time
		; [e.g. 2 on m32r].
		liw-insns

		; Maximum number of instructions the cpu can execute in
		; parallel.
		; FIXME: Rename to max-parallel-insns.
		parallel-insns

		; List of <iframe> objects.
		;frames

		; Condition tested before execution of any instruction or
		; #f if there is none.  For architectures like ARM, ARC.
		; If specified it is a pair of
		; (condition-field-name . rtl-for-condition)
		(condition . #f)

		; Code to execute after CONDITION and prior to SEMANTICS.
		; This is rtl in source form or #f if there is none.
		; This is generally unused.  It is used on the ARM to set
		; R15 to the correct value.
		; The reason it's not specified with SEMANTICS is that it is
		; believed some applications won't need/want this.
		; ??? It is a bit of a hack though, as it is used to aid
		; implementation of apps (e.g. simulator).  Arguably something
		; that doesn't belong here.  Maybe as more architectures are
		; ported that have the PC as a general register, a better way
		; to do this will arise.
		(setup-semantics . #f)

		; list of simulator instruction splits
		; FIXME: should live in simulator file (needs class cleanup).
		(decode-splits . ())

		; ??? More may need to migrate here.
		)
	      nil)
)

; Accessors.

(define-getters <isa> isa
  (base-insn-bitsize default-insn-bitsize default-insn-word-bitsize
   decode-assist liw-insns parallel-insns condition
   setup-semantics decode-splits)
)

(define-setters <isa> isa
  (decode-splits)
)

(define (isa-enum isa) (string-append "ISA_" (string-upcase (gen-sym isa))))

; Return minimum/maximum size in bits of all insns in the isa.

(define (isa-min-insn-bitsize isa)
  ; add `65535' in case list is nil (avoids crash)
  ; [a language with infinite precision can't have min-reduce-iota-0 :-)]
  (apply min (cons 65535
		   (map insn-length (find (lambda (insn)
					    (and (not (has-attr? insn 'ALIAS))
						 (isa-supports? isa insn)))
					  (non-multi-insns (current-insn-list))))))
)

(define (isa-max-insn-bitsize isa)
  ; add `0' in case list is nil (avoids crash)
  ; [a language with infinite precision can't have max-reduce-iota-0 :-)]
  (apply max (cons 0
		   (map insn-length (find (lambda (insn)
					    (and (not (has-attr? insn 'ALIAS))
						 (isa-supports? isa insn)))
					  (non-multi-insns (current-insn-list))))))
)

; Return a boolean indicating if instructions in ISA can be kept in a
; portable int.

(define (isa-integral-insn? isa)
  (<= (isa-max-insn-bitsize isa) 32)
)

; Parse an isa condition spec.
; `condition' here refers to the condition performed by architectures like
; ARM and ARC before each insn.

(define (-isa-parse-condition context spec)
  (if (null? spec)
      #f
      (begin
	(if (or (!= (length spec) 2)
		(not (symbol? (car spec)))
		(not (form? (cadr spec))))
	    (parse-error context
			 "condition spec not `(ifield-name rtl-code)'" spec))
	spec))
)

; Parse a setup-semantics spec.

(define (-isa-parse-setup-semantics context spec)
  (if (not (null? spec))
      spec
      #f)
)

; Parse an isa spec.
; The result is the <isa> object.
; All arguments are in raw (non-evaluated) form.

(define (-isa-parse context name comment attrs
		    base-insn-bitsize default-insn-bitsize default-insn-word-bitsize
		    decode-assist liw-insns parallel-insns condition
		    setup-semantics decode-splits)
  (logit 2 "Processing isa " name " ...\n")

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name)))

    (if (not (memq name (current-arch-isa-name-list)))
	(parse-error context "isa name is not present in `define-arch'" name))

    ; Isa's are always kept - we need them to validate later uses, even if
    ; the then resulting object won't be kept.  All isas are also needed to
    ; compute a proper value for the isas-cache member of <hardware-base>
    ; for builtin objects.
    (make <isa>
      name
      (parse-comment context comment)
      (atlist-parse context attrs "isa")
      (parse-number (context-append context
				    ": default-insn-word-bitsize")
		    default-insn-word-bitsize '(8 . 128))
      (parse-number (context-append context
				    ": default-insn-bitsize")
		    default-insn-bitsize '(8 . 128))
      (parse-number (context-append context
				    ": base-insn-bitsize")
		    base-insn-bitsize '(8 . 128))
      decode-assist
      liw-insns
      parallel-insns
      (-isa-parse-condition context condition)
      (-isa-parse-setup-semantics context setup-semantics)
      (-isa-parse-decode-splits context decode-splits)
      ))
)

; Read an isa entry.
; ARG-LIST is an associative list of field name and field value.

(define (-isa-read context . arg-list)
  (let (
	(name #f)
	(attrs nil)
	(comment "")
	(base-insn-bitsize #f)
	(default-insn-bitsize #f)
	(default-insn-word-bitsize #f)
	(decode-assist nil)
	(liw-insns 1)
	;; FIXME: Hobbit computes the wrong symbol for `parallel-insns'
	;; in the `case' expression below because there is a local var
	;; of the same name ("__1" gets appended to the symbol name).
	(parallel-insns- 1)
	(condition nil)
	(setup-semantics nil)
	(decode-splits nil)
	)

    (let loop ((arg-list arg-list))
      (if (null? arg-list)
	  nil
	  (let ((arg (car arg-list))
		(elm-name (caar arg-list)))
	    (case elm-name
	      ((name) (set! name (cadr arg)))
	      ((comment) (set! comment (cadr arg)))
	      ((attrs) (set! attrs (cdr arg)))
	      ((default-insn-word-bitsize)
	       (set! default-insn-word-bitsize (cadr arg)))
	      ((default-insn-bitsize) (set! default-insn-bitsize (cadr arg)))
	      ((base-insn-bitsize) (set! base-insn-bitsize (cadr arg)))
	      ((decode-assist) (set! decode-assist (cadr arg)))
	      ((liw-insns) (set! liw-insns (cadr arg)))
	      ((parallel-insns) (set! parallel-insns- (cadr arg)))
	      ((condition) (set! condition (cdr arg)))
	      ((setup-semantics) (set! setup-semantics (cadr arg)))
	      ((decode-splits) (set! decode-splits (cdr arg)))
	      ((insn-types) #t) ; ignore for now
	      ((frame) #t) ; ignore for now
	      (else (parse-error context "invalid isa arg" arg)))
	    (loop (cdr arg-list)))))

    ;; Now that we've identified the elements, build the object.
    (-isa-parse context name comment attrs
		base-insn-bitsize
		(if default-insn-word-bitsize
		    default-insn-word-bitsize
		    base-insn-bitsize)
		(if default-insn-bitsize
		    default-insn-bitsize
		    base-insn-bitsize)
		decode-assist liw-insns parallel-insns- condition
		setup-semantics decode-splits))
)

; Define a <isa> object, name/value pair list version.

(define define-isa
  (lambda arg-list
    (let ((i (apply -isa-read (cons (make-current-context "define-isa")
				    arg-list))))
      (if i
	  (current-isa-add! i))
      i))
)

; Subroutine of modify-isa to process one add-decode-split spec.

(define (-isa-add-decode-split! context isa spec)
  (let ((decode-split (-isa-parse-decode-split context spec)))
    (isa-set-decode-splits! (cons decode-split (isa-decode-splits isa)))
    *UNSPECIFIED*)
)

; Main routine for modifying existing isa definitions

(define modify-isa
  (lambda arg-list
    (let ((context (make-current-context "modify-isa"))
	  (isa-spec (assq 'name arg-list)))
      (if (not isa-spec)
	  (parse-error context "isa name not specified"))

      (let ((isa (current-isa-lookup (arg-list-symbol-arg context isa-spec))))
	(if (not isa)
	    (parse-error context "undefined isa" isa-spec))

	(let loop ((args arg-list))
	  (if (null? args)
	      #f ; done
	      (let ((arg-spec (car args)))
		(case (car arg-spec)
		  ((name) #f) ; ignore, already processed
		  ((add-decode-split)
		   (-isa-add-decode-split! context isa (cdr arg-spec)))
		  (else
		   (parse-error context "invalid/unsupported option" (car arg-spec))))
		(loop (cdr args)))))))

    *UNSPECIFIED*)
)

; Return boolean indicating if ISA supports parallel execution.

(define (isa-parallel-exec? isa) (> (isa-parallel-insns isa) 1))

; Return a boolean indicating if ISA supports conditional execution
; of all instructions.

(define (isa-conditional-exec? isa) (->bool (isa-condition isa)))

; The `<cpu>' object collects together various details about a particular
; subset of the architecture (e.g. perhaps all 32 bit variants of the sparc
; architecture).
; This is called a "cpu-family".
; ??? May be renamed to <family> (both internally and in the .cpu file).
; ??? Another way to do this would be to discard the family notion and allow
; machs to inherit from other machs, as well as use isas to distinguish
; sufficiently dissimilar machs.  This would remove a fuzzy illspecified
; notion with a concrete one.
; ??? Maybe a better way to organize sparc32 vs sparc64 is via an isa.

(define <cpu>
  (class-make '<cpu>
	      '(<ident>)
	      '(
		; one of big/little/either/#f.
		; If #f, then {insn,data,float}-endian are used.
		; Otherwise they're ignored.
		endian

		; one of big/little/either.
		insn-endian

		; one of big/little/either/big-words/little-words.
		; If big-words then each word is little-endian.
		; If little-words then each word is big-endian.
		data-endian

		; one of big/little/either/big-words/little-words.
		float-endian

		; number of bits in a word.
		word-bitsize

		; number of bits in a chunk of an instruction word, for
		; endianness conversion purposes; 0 = no chunking
		insn-chunk-bitsize

		; Transformation to use in generated files should one be
		; needed.  At present the only supported value is a string
		; which is the file suffix.
		; ??? A dubious element of the description language, but given
		; the quantity of generated files, some machine generated
		; headers may need to #include other machine generated headers
		; (e.g. cpuall.h).
		file-transform

		; Allow a cpu family to override the isa parallel-insns spec.
		; ??? Concession to the m32r port which can go away, in time.
		parallel-insns

		; Computed: maximum number of insns which may pass before there
		; an insn writes back its output operands.
		max-delay

		)
	      nil)
)

; Accessors.

(define-getters <cpu> cpu (word-bitsize insn-chunk-bitsize file-transform parallel-insns max-delay))
(define-setters <cpu> cpu (max-delay))

; Return endianness of instructions.

(define (cpu-insn-endian cpu)
  (let ((endian (elm-xget cpu 'endian)))
    (if endian
	endian
	(elm-xget cpu 'insn-endian)))
)

; Return endianness of data.

(define (cpu-data-endian cpu)
  (let ((endian (elm-xget cpu 'endian)))
    (if endian
	endian
	(elm-xget cpu 'data-endian)))
)

; Return endianness of floats.

(define (cpu-float-endian cpu)
  (let ((endian (elm-xget cpu 'endian)))
    (if endian
	endian
	(elm-xget cpu 'float-endian)))
)

; Parse a cpu family description
; This is the main routine for building a <cpu> object from a cpu
; description in the .cpu file.
; All arguments are in raw (non-evaluated) form.

(define (-cpu-parse context name comment attrs
		    endian insn-endian data-endian float-endian
		    word-bitsize insn-chunk-bitsize file-transform parallel-insns)
  (logit 2 "Processing cpu family " name " ...\n")

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name)))

    (if (keep-cpu? name)
	(make <cpu>
	      name
	      (parse-comment context comment)
	      (atlist-parse context attrs "cpu")
	      endian insn-endian data-endian float-endian
	      word-bitsize
	      insn-chunk-bitsize
	      file-transform
	      parallel-insns
	      0 ; default max-delay. will compute correct value
	      )
	(begin
	  (logit 2 "Ignoring " name ".\n")
	  #f))) ; cpu is not to be kept
)

; Read a cpu family description
; This is the main routine for analyzing a cpu description in the .cpu file.
; CONTEXT is a <context> object for error messages.
; ARG-LIST is an associative list of field name and field value.
; -cpu-parse is invoked to create the <cpu> object.

(define (-cpu-read context . arg-list)
  (let (
	(name nil)
	(comment nil)
	(attrs nil)
	(endian #f)
	(insn-endian #f)
	(data-endian #f)
	(float-endian #f)
	(word-bitsize #f)
	(insn-chunk-bitsize 0)
	(file-transform "")
	;; FIXME: Hobbit computes the wrong symbol for `parallel-insns'
	;; in the `case' expression below because there is a local var
	;; of the same name ("__1" gets appended to the symbol name).
	(parallel-insns- #f)
	)

    ;; Loop over each element in ARG-LIST, recording what's found.
    (let loop ((arg-list arg-list))
      (if (null? arg-list)
	  nil
	  (let ((arg (car arg-list))
		(elm-name (caar arg-list)))
	    (case elm-name
	      ((name) (set! name (cadr arg)))
	      ((comment) (set! comment (cadr arg)))
	      ((attrs) (set! attrs (cdr arg)))
	      ((endian) (set! endian (cadr arg)))
	      ((insn-endian) (set! insn-endian (cadr arg)))
	      ((data-endian) (set! data-endian (cadr arg)))
	      ((float-endian) (set! float-endian (cadr arg)))
	      ((word-bitsize) (set! word-bitsize (cadr arg)))
	      ((insn-chunk-bitsize) (set! insn-chunk-bitsize (cadr arg)))
	      ((file-transform) (set! file-transform (cadr arg)))
	      ((parallel-insns) (set! parallel-insns- (cadr arg)))
	      (else (parse-error context "invalid cpu arg" arg)))
	    (loop (cdr arg-list)))))

    ;; Now that we've identified the elements, build the object.
    (-cpu-parse context name comment attrs
		endian insn-endian data-endian float-endian
		word-bitsize insn-chunk-bitsize file-transform parallel-insns-))
)

; Define a cpu family object, name/value pair list version.

(define define-cpu
  (lambda arg-list
    (let ((c (apply -cpu-read (cons (make-current-context "define-cpu")
				    arg-list))))
      (if c
	  (begin
	    (current-cpu-add! c)
	    (mode-set-word-modes! (cpu-word-bitsize c))
	    (hw-update-word-modes!)
	    ))
      c))
)

; The `<mach>' object describes one member of a `cpu' family.

(define <mach>
  (class-make '<mach> '(<ident>)
	      '(
		; cpu family this mach is a member of
		cpu
		; bfd name of mach
		bfd-name
		; list of <isa> objects
		isas
		)
	      nil)
)

; Accessors.

(define-getters <mach> mach (cpu bfd-name isas))

(define (mach-enum obj)
  (string-append "MACH_" (string-upcase (gen-sym obj)))
)

(define (mach-number obj) (mach-enum obj))

(define (machs-for-cpu cpu)
  (let ((cpu-name (obj:name cpu)))
    (find (lambda (mach)
	    (eq? (obj:name (mach-cpu mach)) cpu-name))
	  (current-mach-list)))
)

; Parse a machine entry.
; The result is a <mach> object or #f if the mach isn't to be kept.
; All arguments are in raw (non-evaluated) form.

(define (-mach-parse context name comment attrs cpu bfd-name isas)
  (logit 2 "Processing mach " name " ...\n")

  ;; Pick out name first to augment the error context.
  (let* ((name (parse-name context name))
	 (context (context-append-name context name)))

    (if (not (list? isas))
	(parse-error context "isa spec not a list" isas))
    (let ((cpu-obj (current-cpu-lookup cpu))
	  (isa-list (map current-isa-lookup isas)))
      (if (not (memq name (current-arch-mach-name-list)))
	  (parse-error context "mach name is not present in `define-arch'" name))
      (if (null? cpu)
	  (parse-error context "missing cpu spec" cpu))
      (if (not cpu-obj)
	  (parse-error context "unknown cpu" cpu))
      (if (null? isas)
	  (parse-error context "missing isas spec" isas))
      (if (not (all-true? isa-list))
	  (parse-error context "unknown isa in" isas))
      (if (not (string? bfd-name))
	  (parse-error context "bfd-name not a string" bfd-name))

      (if (keep-mach? (list name))

	  (make <mach>
		name
		(parse-comment context comment)
		(atlist-parse context attrs "mach")
		cpu-obj
		bfd-name
		isa-list)

	  (begin
	    (logit 2 "Ignoring " name ".\n")
	    #f)))) ; mach is not to be kept
)

; Read a mach entry.
; CONTEXT is a <context> object for error messages.
; ARG-LIST is an associative list of field name and field value.

(define (-mach-read context . arg-list)
  (let (
	(name nil)
	(attrs nil)
	(comment nil)
	(cpu nil)
	(bfd-name #f)
	(isas #f)
	)

    (let loop ((arg-list arg-list))
      (if (null? arg-list)
	  nil
	  (let ((arg (car arg-list))
		(elm-name (caar arg-list)))
	    (case elm-name
	      ((name) (set! name (cadr arg)))
	      ((comment) (set! comment (cadr arg)))
	      ((attrs) (set! attrs (cdr arg)))
	      ((cpu) (set! cpu (cadr arg)))
	      ((bfd-name) (set! bfd-name (cadr arg)))
	      ((isas) (set! isas (cdr arg)))
	      (else (parse-error context "invalid mach arg" arg)))
	    (loop (cdr arg-list)))))

    ;; Now that we've identified the elements, build the object.
    (-mach-parse context name comment attrs cpu
		 ;; Default bfd-name is same as object's name.
		 (if bfd-name bfd-name (symbol->string name))
		 ;; Default isa is the first one.
		 (if isas isas (list (obj:name (car (current-isa-list)))))))
)

; Define a <mach> object, name/value pair list version.

(define define-mach
  (lambda arg-list
    (let ((m (apply -mach-read (cons (make-current-context "define-mach")
				     arg-list))))
      (if m
	  (current-mach-add! m))
      m))
)

; Miscellaneous state derived from the input data.
; FIXME: being redone

; Size of a word in bits.
; All selected cpu families must have same value or error.
; Ergo, don't use this if multiple word-bitsize values are expected.
; E.g. opcodes support for architectures with both 32 and 64 variants.

(define (state-word-bitsize)
  (let* ((wb-list (map cpu-word-bitsize (current-cpu-list)))
	 (result (car wb-list)))
    (for-each (lambda (wb)
		(if (!= result wb)
		    (error "multiple word-bitsize values" wb-list)))
	      wb-list)
    result)
)

; Return maximum word bitsize.

(define (state-max-word-bitsize)
  (apply max (map cpu-word-bitsize (current-cpu-list)))
)

; Size of normal instruction.
; All selected isas must have same value or error.

(define (state-default-insn-bitsize)
  (let ((dib (map isa-default-insn-bitsize (current-isa-list))))
    ; FIXME: ensure all have same value.
    (car dib))
)

; Number of bytes of insn we can initially fetch.
; All selected isas must have same value or error.

(define (state-base-insn-bitsize)
  (let ((bib (map isa-base-insn-bitsize (current-isa-list))))
    ; FIXME: ensure all have same value.
    (car bib))
)

; Return parallel-insns spec.

(define (state-parallel-insns)
  ; Assert only one cpu family has been selected.
  (assert-keep-one)

  (let ((par-insns (map isa-parallel-insns (current-isa-list)))
	(cpu-par-insns (cpu-parallel-insns (current-cpu))))
    ; ??? The m32r does have parallel execution, but to keep support for the
    ; base mach simpler, a cpu family is allowed to override the isa spec.
    (or cpu-par-insns
	; FIXME: ensure all have same value.
	(car par-insns)))
)

; Return boolean indicating if parallel execution support is required.

(define (state-parallel-exec?)
  (> (state-parallel-insns) 1)
)

; Return liw-insns spec.

(define (state-liw-insns)
  (let ((liw-insns (map isa-liw-insns (current-isa-list))))
    ; FIXME: ensure all have same value.
    (car liw-insns))
)

; Return decode-assist spec.

(define (state-decode-assist)
  (isa-decode-assist (current-isa))
)

; Return boolean indicating if current isa conditionally executes all insn.

(define (state-conditional-exec?)
  (isa-conditional-exec? (current-isa))
)

; Architecture or cpu wide values derived from other data.

(define <derived-arch-data>
  (class-make '<derived-arch-data>
	      nil
	      '(
		; whether all insns can be recorded in a host int
		integral-insn?
		)
	      nil)
)

; Called after the .cpu file has been read in to prime derived value
; computation.
; Often this data isn't needed so we only computed it if we have to.

(define (-adata-set-derived! arch)
  ; Don't compute this data unless we need to.
  (arch-set-derived!
   arch
   (make <derived-arch-data>
     ; integral-insn?
     (delay (isa-integral-insn? (current-isa)))
     ))
)

; Accessors.

(define (adata-integral-insn? arch)
  (force (elm-xget (arch-derived arch) 'integral-insn?))
)

; Instruction analysis control.

;; The maximum number of virtual insns.
;; They can be recorded with negative ordinals, and multi-insns are currently
;; also recorded as negative numbers, so leave enough space.
(define MAX-VIRTUAL-INSNS 100)

; Analyze the instruction set.
; The name is explicitly vague because it's intended that all insn analysis
; would be controlled here.
; If the instruction set has already been sufficiently analyzed, do nothing.
; INCLUDE-ALIASES? is #t if alias insns are to be included.
; ANALYZE-SEMANTICS? is #t if insn semantics are to be analyzed.
;
; This is a very expensive operation, so we only do it as necessary.
; There are (currently) two different kinds of users: assemblers and
; simulators.  Assembler style apps don't always need to analyze the semantics.
; Simulator style apps don't want to include the alias insns.

(define (arch-analyze-insns! arch include-aliases? analyze-semantics?)
  ; Catch apps that haven't set word sizes yet.
  (mode-ensure-word-sizes-defined)

  (if (or (not (arch-insns-analyzed? arch))
	  (not (eq? analyze-semantics? (arch-semantics-analyzed? arch)))
	  (not (eq? include-aliases? (arch-aliases-analyzed? arch))))

      (begin

	;; FIXME: This shouldn't be calling current-insn-list,
	;; it should use (arch-insn-list arch).
	;; Then again various subroutines assume arch == CURRENT-ARCH.
	;; Still, something needs to be cleaned up.
	(if (any-true? (map multi-insn? (current-insn-list)))
	    (begin
	      ; Instantiate sub-insns of all multi-insns.
	      (logit 1 "Instantiating multi-insns ...\n")

	      ;; FIXME: Hack to remove differences in generated code when we
	      ;; switched to recording insns in hash tables.
	      ;; Multi-insn got instantiated after the list of insns had been
	      ;; reversed and they got added to the front of the list, in
	      ;; reverse order.  Blech!
	      ;; Eventually remove this, have a flag day, and check in the
	      ;; updated files.
	      ;; NOTE: This causes major diffs to opcodes/m32c-*.[ch].
	      (let ((orig-ord (arch-next-ordinal arch)))
		(arch-set-next-ordinal! arch (- MAX-VIRTUAL-INSNS))
		(for-each (lambda (insn)
			    (multi-insn-instantiate! insn))
			  (multi-insns (current-insn-list)))
		(arch-set-next-ordinal! arch orig-ord))
	      ))

	; This is expensive so indicate start/finish.
	(logit 1 "Analyzing instruction set ...\n")

	(let ((fmt-lists
	       (ifmt-compute! (non-multi-insns 
			       (if include-aliases?
				   (arch-insn-list arch)
				   (non-alias-insns (arch-insn-list arch))))
			      analyze-semantics?)))

	  (arch-set-ifmt-list! arch (car fmt-lists))
	  (arch-set-sfmt-list! arch (cadr fmt-lists))
	  (arch-set-insns-analyzed?! arch #t)
	  (arch-set-semantics-analyzed?! arch analyze-semantics?)
	  (arch-set-aliases-analyzed?! arch include-aliases?)

	  (logit 1 "Done analysis.\n")
	  ))
      )

  *UNSPECIFIED*
)

; Called before a .cpu file is read in.

(define (arch-init!)

  (reader-add-command! 'define-arch
		       "\
Define an architecture, name/value pair list version.
"
		       nil 'arg-list define-arch)

  (reader-add-command! 'define-isa
		       "\
Define an instruction set architecture, name/value pair list version.
"
		       nil 'arg-list define-isa)
  (reader-add-command! 'modify-isa
		       "\
Modify an isa, name/value pair list version.
"
		       nil 'arg-list modify-isa)

  (reader-add-command! 'define-cpu
		       "\
Define a cpu family, name/value pair list version.
"
		       nil 'arg-list define-cpu)

  *UNSPECIFIED*
)

; Called before a .cpu file is read in.

(define (mach-init!)
  (let ((arch CURRENT-ARCH))
    (arch-set-ifld-table! arch (-make-ident-object-table 127))
    (arch-set-op-table! arch (-make-ident-object-table 127))
    (arch-set-insn-table! arch (-make-ident-object-table 509))
    (arch-set-minsn-table! arch (-make-ident-object-table 127))
    )

  (reader-add-command! 'define-mach
		       "\
Define a machine, name/value pair list version.
"
		       nil 'arg-list define-mach)

  *UNSPECIFIED*
)

; Called after .cpu file is read in.

(define (arch-finish!)
  (let ((arch CURRENT-ARCH))

    ; Lists are constructed in the reverse order they appear in the file
    ; [for simplicity and efficiency].  Restore them to file order for the
    ; human reader/debugger.
    ; We don't need to do this for ifld, op, insn, minsn lists because
    ; they are handled differently.
    (arch-set-enum-list! arch (reverse (arch-enum-list arch)))
    (arch-set-kw-list! arch (reverse (arch-kw-list arch)))
    (arch-set-isa-list! arch (reverse (arch-isa-list arch)))
    (arch-set-cpu-list! arch (reverse (arch-cpu-list arch)))
    (arch-set-mach-list! arch (reverse (arch-mach-list arch)))
    (arch-set-model-list! arch (reverse (arch-model-list arch)))
    (arch-set-hw-list! arch (reverse (arch-hw-list arch)))
    (arch-set-subr-list! arch (reverse (arch-subr-list arch)))
    )

  *UNSPECIFIED*
)

; Called after .cpu file is read in.

(define (mach-finish!)
  (-adata-set-derived! CURRENT-ARCH)

  *UNSPECIFIED*
)
