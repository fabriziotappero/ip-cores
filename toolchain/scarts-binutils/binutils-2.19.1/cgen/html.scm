; CPU documentation generator, html output
; Copyright (C) 2003, 2009 Doug Evans
; This file is part of CGEN.  See file COPYING.CGEN for details.
;
; TODO:
; - assumes names, comments, etc. don't interfere with html.
;   Just like in generation of C there are routines to C-ize symbols,
;   we need to pass output through an html-izer.
; - make generated html more readable, e.g. more indentation
; - should really print the semantics in pseudo-C, a much better form for
;   the intended audience
; - registers that have multiple independent fields (like x86 eflags)
;   need to be printed like instruction formats are
; - uses some deprecated html, use css at very least
; - multi-ifields ok?
; - mapping from operands to h/w isn't as clear as it needs to be
; - for insn formats, if field is large consider printing "n ... m",
;   would want "n" left justified and "m" right justified though
; - for insn formats, consider printing them better,
;   e.g. maybe generate image and include that instead
; - need ability to specify more prose for each architecture
; - assembler support
; - need to add docs to website that can be linked to here, rather than
;   including generic cgen documentation here
; - function units, timing, etc.
; - instruction framing

; Global state variables.

; Specify which application.
(set! APPLICATION 'DOC)

; String containing copyright text.
(define CURRENT-COPYRIGHT #f)

; String containing text defining the package we're generating code for.
(define CURRENT-PACKAGE #f)

(define copyright-doc
  (cons "\
THIS FILE IS MACHINE GENERATED WITH CGEN.

See the input .cpu file(s) for copyright information.
"
	"\
"))

; Initialize the options.

(define (option-init!)
  (set! CURRENT-COPYRIGHT copyright-doc)
  (set! CURRENT-PACKAGE package-cgen)
  *UNSPECIFIED*
)

; Handle an option passed in from the command line.

(define (option-set! name value)
  (case name
    ((copyright) (cond ((equal?  value '("doc"))
			(set! CURRENT-COPYRIGHT copyright-doc))
		       (else (error "invalid copyright value" value))))
    ((package) (cond ((equal?  value '("cgen"))
		      (set! CURRENT-PACKAGE package-cgen))
		     (else (error "invalid package value" value))))
    (else (error "unknown option" name))
    )
  *UNSPECIFIED*
)

; Misc utilities.

; Return COPYRIGHT, with FILE-DESC as the first line
; and PACKAGE as the name of the package which the file belongs in.
; COPYRIGHT is a pair of (header . trailer).

(define (gen-html-copyright file-desc copyright package)
  (string-append "<! " file-desc "\n\n"
		 (car copyright)
		 "\n" package "\n"
		 (cdr copyright)
		 "\n>\n\n")
)

; KIND is one of "Architecture" or "Instruction".
; TODO: Add author arg so all replies for this arch go to right person.

(define (gen-html-header kind)
  (let* ((arch (symbol->string (current-arch-name)))
	 (ARCH (string-upcase arch)))
    (string-list
     "<!doctype html public \"-//w3c//dtd html 4.0 transitional//en\">\n"
     "<html>\n"
     "<head>\n"
     "  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">\n"
     "  <meta name=\"description\" content=\"" ARCH " " kind " Documentation\">\n"
     "  <meta name=\"language\" content=\"en-us\">\n"
     "  <meta name=\"owner\" content=\"dje@sebabeach.org (Doug Evans)\">\n"
     "  <meta name=\"reply-to\" content=\"dje@sebabeach.org (Doug Evans)\">\n"
     "  <title>" ARCH " " kind " Documentation</title>\n"
     "</head>\n"
     "<body bgcolor=\"#F0F0F0\" TEXT=\"#003333\" LINK=\"#FF0000\" VLINK=\"#444444\" alink=\"#000000\">\n"
     )
    )
)

(define (gen-html-trailer)
  (string-list
   "\n"
   "<p><hr><p>\n"
   "This documentation was machine generated from the cgen cpu description\n"
   "files for this architecture.\n"
   "<br>\n"
   "<a href=\"http://sources.redhat.com/cgen/\">http://sources.redhat.com/cgen/</a>\n"
   "</body>\n"
   "</html>\n"
   )
)

; INSN-FILE is the name of the .html file containing instruction definitions.

(define (gen-table-of-contents insn-file)
  (let ((ARCH (string-upcase (symbol->string (current-arch-name)))))
    (string-list
     "<h1>\n"
     (string-append ARCH " Architecture Documentation")
     "</h1>\n"
     "\n"
     "<br>\n"
     "DISCLAIMER: This documentation is derived from the cgen cpu description\n"
     "of this architecture, and does not represent official documentation\n"
     "of the chip maker.\n"
     "<p><hr><p>\n"
     "\n"
     "<ul>\n"
     "<li><a href=\"#arch\">Architecture</a></li>\n"
     "<li><a href=\"#machines\">Machine variants</a></li>\n"
     "<li><a href=\"#models\">Model variants</a></li>\n"
     "<li><a href=\"#registers\">Registers</a></li>\n"
     "<li><a href=\"" insn-file "#insns\">Instructions</a></li>\n"
     "<li><a href=\"" insn-file "#macro-insns\">Macro instructions</a></li>\n"
     "<li><a href=\"#assembler\">Assembler supplemental</a></li>\n"
     "</ul>\n"
     "<br>\n"
     ; TODO: Move this to the cgen website, and include a link here.
     "In cgen-parlance, an architecture consists of machines and models.\n"
     "A `machine' is the specification of a variant of the architecture,\n"
     "and a `model' is the implementation of that specification.\n"
     "Typically there is a one-to-one correspondance between machine and model.\n"
     "The distinction allows for separation of what application programs see\n"
     "(the machine), and how to tune for the chip (what the compiler sees).\n"
     "<br>\n"
     "A \"cpu family\" is a cgen concoction to help organize the generated code.\n"
     "Chip variants that are quite dissimilar can be treated separately by the\n"
     "generated code even though they're both members of the same architecture.\n"
      ))
)

; Utility to print a list entry for NAME/COMMENT, kind KIND
; which is a link to the entry's description.
; KIND is one of "mach", "model", etc.

(define (gen-list-entry name comment kind)
  (string-append "<li>"
		 "<a href=\"#" kind "-" (->string name) "\">"
		 (->string name)
		 " - "
		 comment
		 "</a>\n"
		 "</li>\n")
)

; Cover-fn to gen-list-entry for use with objects.

(define (gen-obj-list-entry o kind)
  (gen-list-entry (obj:name o) (obj:comment o) kind)
)

; Utility to print the header for the description of TEXT.

(define (gen-doc-header text anchor-name)
  (string-list
   "<a name=\"" anchor-name "\"></a>\n"
   "<h3>" text "</h3>\n"
   )
)

; Cover-fn to gen-doc-header for use with objects.
; KIND is one of "mach", "model", etc.

(define (gen-obj-doc-header o kind)
  (gen-doc-header (string-append (obj:str-name o) " - " (obj:comment o))
		  (string-append kind "-" (obj:str-name o)))
)

; Architecture page.

(define (gen-cpu-intro cpu)
  (string-list
   "<li>\n"
   (obj:str-name cpu) " - " (obj:comment cpu) "\n"
   "<br>\n"
   "<br>\n"
   "Machines:\n"
   "<ul>\n"
   (string-list-map gen-mach-intro
		    (alpha-sort-obj-list (machs-for-cpu cpu)))
   "</ul>\n"
   "</li>\n"
   "<br>\n"
   )
)

(define (gen-mach-intro mach)
  (string-list
   "<li>\n"
   (obj:str-name mach) " - " (obj:comment mach) "\n"
   "<br>\n"
   "<br>\n"
   "Models:\n"
   "<ul>\n"
   (string-list-map gen-model-intro
		    (alpha-sort-obj-list (models-for-mach mach)))
   "</ul>\n"
   "</li>\n"
   "<br>\n"
   )
)

(define (gen-model-intro model)
  (string-list
   "<li>\n"
   (obj:str-name model) " - " (obj:comment model) "\n"
   "<br>\n"
   "</li>\n"
   )
)

(define (gen-isa-intro isa)
  (string-list
   "<li>\n"
   (obj:str-name isa) " - " (obj:comment isa) "\n"
   "<br>\n"
   ; FIXME: wip
   ; I'd like to include the .cpu file tag here, but using English text
   ; feels more appropriate.  Having both is excessive.
   ; Pick one, and have a link to its description/tag.
   ; I'm leaning toward using the cgen tag here as we'll probably want
   ; access (via an html tag) to more than one-liner descriptions.
   "<ul>\n"
   "<li>default-insn-word-bitsize: "
   (number->string (isa-default-insn-word-bitsize isa))
   "</li>\n"
   "<br>\n"
   "<li>default-insn-bitsize: "
   (number->string (isa-default-insn-bitsize isa))
   "</li>\n"
   "<br>\n"
   "<li>base-insn-bitsize: "
   (number->string (isa-base-insn-bitsize isa))
   "</li>\n"
   "<br>\n"
   "<li>decode-assist: "
   (string-map (lambda (n) (string-append " " (number->string n)))
	       (isa-decode-assist isa))
   "</li>\n"
   "<br>\n"
   "<li>decode-splits: "
   (string-map (lambda (n) (string-append " " (number->string n)))
	       (isa-decode-splits isa))
   "</li>\n"
   "<br>\n"
   (if (> (isa-liw-insns isa) 1)
       (string-append "<li>liw-insns: "
		      (number->string (isa-liw-insns isa))
		      "</li>\n"
		      "<br>\n")
       "")
   (if (> (isa-parallel-insns isa) 1)
       (string-append "<li>parallel-insns: "
		      (number->string (isa-parallel-insns isa))
		      "</li>\n"
		      "<br>\n")
       "")
   (if (isa-condition isa)
       (string-append "<li>condition-field: "
		      (symbol->string (car (isa-condition isa)))
		      "</li>\n"
		      "<br>\n"
		      "<li>condition:\n"
		      "<font size=+2>\n"
		      "<pre>" ; no trailing newline here on purpose
		      (with-output-to-string
			(lambda ()
			  (pretty-print (cadr (isa-condition isa)))))
		      "</pre></font>\n"
		      "</li>\n"
		      "<br>\n")
       "")
   (if (isa-setup-semantics isa)
       (string-append "<li>setup-semantics:\n"
		      "<font size=+2>\n"
		      "<pre>" ; no trailing newline here on purpose
		      (with-output-to-string
			(lambda ()
			  (pretty-print (cdr (isa-setup-semantics isa)))))
		      "</pre></font>\n"
		      "</li>\n"
		      "<br>\n")
       "")
   "</ul>\n"
   "</li>\n"
   )
)

(define (gen-arch-intro)
  ; NOTE: This includes cpu families.
  (let ((ARCH (string-upcase (symbol->string (current-arch-name))))
	(isas (current-isa-list))
	(cpus (current-cpu-list))
	)
    (string-list
     "\n"
     "<hr>\n"
     "<a name=\"arch\"></a>\n"
     "<h2>" ARCH " Architecture</h2>\n"
     "<p>\n"
     "This section describes various things about the cgen description of\n"
     "the " ARCH " architecture.  Familiarity with cgen cpu descriptions\n"
     "is assumed.\n"
     "<p>\n"
     "Bit number orientation (arch.lsb0?): "
     (if (current-arch-insn-lsb0?) "lsb = 0" "msb = 0")
     "\n"
     "<p>\n"
     "<h3>ISA description</h3>\n"
     ; NOTE: For the normal case there's only one isa, thus specifying it in
     ; a list is excessive.  Later.
     "<p>\n"
     "<ul>\n"
     (string-list-map gen-isa-intro
		      (alpha-sort-obj-list isas))
     "</ul>\n"
     "<p>\n"
     "<h3>CPU Families</h3>\n"
     "<ul>\n"
     (string-list-map gen-cpu-intro
		      (alpha-sort-obj-list cpus))
     "</ul>\n"
     ))
)

; Machine page.

(define (gen-machine-doc-1 mach)
  (string-list
   (gen-obj-doc-header mach "mach")
   "<ul>\n"
   "<li>\n"
   "bfd-name: "
   (mach-bfd-name mach)
   "\n"
   "</li>\n"
   "<li>\n"
   "isas: "
   (string-map (lambda (isa)
		 (string-append " " (obj:str-name isa)))
	       (mach-isas mach))
   "\n"
   "</li>\n"
   "</ul>\n"
   )
)

(define (gen-machine-docs)
  (let ((machs (alpha-sort-obj-list (current-mach-list))))
    (string-list
     "\n"
     "<hr>\n"
     "<a name=\"machines\"></a>\n"
     "<h2>Machine variants</h2>\n"
     "<ul>\n"
     (string-map (lambda (o)
		   (gen-obj-list-entry o "mach"))
		 machs)
     "</ul>\n"
     (string-list-map gen-machine-doc-1 machs)
     ))
)

; Model page.

(define (gen-model-doc-1 model)
  (string-list
   (gen-obj-doc-header model "model")
   "<ul>\n"
   "</ul>\n"
   )
)

(define (gen-model-docs)
  (let ((models (alpha-sort-obj-list (current-model-list))))
    (string-list
     "\n"
     "<hr>\n"
     "<a name=\"models\"></a>\n"
     "<h2>Model variants</h2>\n"
     "<ul>\n"
     (string-map (lambda (o)
		   (gen-obj-list-entry o "model"))
		 models)
     "</ul>\n"
     (string-list-map gen-model-doc-1 models)
     ))
)

; Register page.
;
; TODO: Provide tables of regs for each mach.

; Subroutine of gen-reg-doc-1 to simplify it.
; Generate a list of names of registers in register array REG.
; The catch is that we want to shrink r0,r1,r2,...,r15 to r0...r15.

(define (gen-pretty-reg-array-names reg)
  ; We currently only support arrays of rank 1 (vectors).
  (if (!= (hw-rank reg) 1)
      (error "gen-pretty-reg-array-names: unsupported rank" (hw-rank reg)))
  (let ((indices (hw-indices reg)))
    (if (class-instance? <keyword> indices)
	(let ((values (kw-values indices)))
	  (string-list
	   "<br>\n"
	   "names:\n"
	   "<br>\n"
	   "<table frame=border border=2>\n"
	   "<tr>\n"
	   (string-list-map (lambda (v)
			      (string-list "<tr>\n"
					   "<td>"
					   (car v)
					   "</td>\n"
					   "<td>"
					   (number->string (cadr v))
					   "</td>\n"
					   "</tr>\n"))
			    values)))
	""))
)

(define (gen-reg-doc-1 reg)
  (string-list
   (gen-obj-doc-header reg "reg")
   "<ul>\n"
   "<li>\n"
   "machines: "
   (string-map (lambda (mach)
		 (string-append " " (symbol->string mach)))
	       (bitset-attr->list (obj-attr-value reg 'MACH)))
   "\n"
   "</li>\n"
   "<li>\n"
   "bitsize: "
   (number->string (hw-bits reg))
   "\n"
   "</li>\n"
   (if (not (hw-scalar? reg))
       (string-list "<li>\n"
		    "array: "
		    (string-map (lambda (dim)
				  (string-append "[" (number->string dim) "]"))
				(hw-shape reg))
		    "\n"
		    (gen-pretty-reg-array-names reg)
		    "</li>\n")
       "")
   "</ul>\n"
   )
)

(define (gen-register-docs)
  (let ((regs (alpha-sort-obj-list (find register? (current-hw-list)))))
    (string-list
     "\n"
     "<hr>\n"
     "<a name=\"registers\"></a>\n"
     "<h2>Registers</h2>\n"
     "<ul>\n"
     (string-map (lambda (o)
		   (gen-obj-list-entry o "reg"))
		 regs)
     "</ul>\n"
     (string-list-map gen-reg-doc-1 regs)
     ))
)

; Instruction page.

; Generate a diagram typically used to display instruction fields.
; OPERANDS is a list of numbers (for constant valued ifields)
; or operand names.

(define (gen-iformat-table-1 bitnums names operands)
  (string-list
   "<table frame=border border=2>\n"
   "<tr>\n"
   (string-list-map (lambda (b)
		      (string-list "<td>\n"
				   (string-map (lambda (n)
						 (string-append " "
								(number->string n)))
					       b)
				   "\n"
				   "</td>\n"))
		    bitnums)
   "</tr>\n"
   "<tr>\n"
   (string-list-map (lambda (n)
		      (string-list "<td>\n"
				   n
				   "\n"
				   "</td>\n"))
		    names)
   "</tr>\n"
   "<tr>\n"
   (string-list-map (lambda (o)
		      (string-list "<td>\n"
				   (if (number? o)
				       (string-append "0x"
						      (number->string o 16))
				       o)
				   "\n"
				   "</td>\n"))
		    operands)
   "</tr>\n"
   "</table>\n")
)

; Compute the list of field bit-numbers for each field.

(define (get-ifield-bitnums widths lsb0?)
  (let* ((total-width (apply + widths))
	 (bitnums (iota total-width
			(if lsb0? (1- total-width) 0)
			(if lsb0? -1 1))))
    (let loop ((result '()) (widths widths) (bitnums bitnums))
      (if (null? widths)
	  (reverse! result)
	  (loop (cons (list-take (car widths) bitnums)
		      result)
		(cdr widths)
		(list-drop (car widths) bitnums)))))
)

; Generate a diagram typically used to display instruction fields.

(define (gen-iformat-table insn)
  (let* ((lsb0? (current-arch-insn-lsb0?))
	 (sorted-iflds (sort-ifield-list (insn-iflds insn) (not lsb0?))))
    (let ((widths (map ifld-length sorted-iflds))
	  (names (map obj:name sorted-iflds))
	  (operands (map (lambda (f)
			   (if (ifld-constant? f)
			       (ifld-get-value f)
			       (obj:name (ifld-get-value f))))
			 sorted-iflds)))
      (gen-iformat-table-1 (get-ifield-bitnums widths lsb0?) names operands)))
)

(define (gen-insn-doc-1 insn)
  (string-list
   (gen-obj-doc-header insn "insn")
   "<ul>\n"
   "<li>\n"
   "machines: "
   (string-map (lambda (mach)
		 (string-append " " (symbol->string mach)))
	       (bitset-attr->list (obj-attr-value insn 'MACH)))
   "\n"
   "</li>\n"
   "<br>\n"
   "<li>\n"
   "syntax: "
   "<tt><font size=+2>"
   (insn-syntax insn)
   "</font></tt>\n"
   "</li>\n"
   "<br>\n"
   "<li>\n"
   "format:\n"
   (gen-iformat-table insn)
   "</li>\n"
   "<br>\n"
   (if (insn-ifield-assertion insn)
       (string-append "<li>\n"
		      "instruction field constraint:\n"
		      "<font size=+2>\n"
		      "<pre>" ; no trailing newline here on purpose
		      (with-output-to-string
			(lambda ()
			  (pretty-print (insn-ifield-assertion insn))))
		      "</pre></font>\n"
		      "</li>\n"
		      "<br>\n")
       "")
   "<li>\n"
   "semantics:\n"
   "<font size=+2>\n"
   "<pre>" ; no trailing newline here on purpose
   (with-output-to-string
     (lambda ()
       ; Print the const-folded semantics, computed in `tmp'.
       (pretty-print (rtx-trim-for-doc (insn-tmp insn)))))
   "</pre></font>\n"
   "</li>\n"
   ; "<br>\n" ; not present on purpose
   (if (not (null? (insn-timing insn)))
       (string-list "<li>\n"
		    "execution unit(s):\n"
		    "<br>\n"
		    "<br>\n"
		    "<ul>\n"
		    (string-list-map
		     (lambda (t)
		       (string-append "<li>\n"
				      (->string (car t))
				      ": "
				      (string-map (lambda (u)
						    (string-append " "
								   (obj:str-name (iunit:unit u))))
						  (timing:units (cdr t)))
				      "\n"
				      "</li>\n"))
		     ; ignore timings for discarded
		     (find (lambda (t) (not (null? (cdr t))))
			   (insn-timing insn)))
		    "</ul>\n"
		    "</li>\n"
		    "<br>\n")
       "")
   "</ul>\n"
   )
)

(define (gen-insn-doc-list mach name comment insns)
  (string-list
   "<hr>\n"
   (gen-doc-header (string-append (obj:str-name mach)
				  " "
				  (->string name)
				  (if (string=? comment "")
				      ""
				      (string-append " - " comment)))
		   (string-append "mach-insns-"
				  (obj:str-name mach)
				  "-"
				  (->string name)))
   "<ul>\n"
   (string-list-map (lambda (o)
		      (gen-obj-list-entry o "insn"))
		    insns)
   "</ul>\n"
   )
)

; Return boolean indicating if INSN sets the pc.

(define (insn-sets-pc? insn)
  (or (obj-has-attr? insn 'COND-CTI)
      (obj-has-attr? insn 'UNCOND-CTI)
      (obj-has-attr? insn 'SKIP-CTI))
)

; Traverse the semantics of INSN and return a list of symbols
; indicating various interesting properties we find.
; This is taken from `semantic-attrs' which does the same thing to find the
; CTI attributes.
; The result is list of properties computed from the semantics.
; The possibilities are: MEM, FPU.

(define (get-insn-properties insn)
  (let*
      ((context #f) ; ??? do we need a better context?

       ; List of attributes computed from SEM-CODE-LIST.
       ; The first element is just a dummy so that append! always works.
       (sem-attrs (list #f))

       ; Called for expressions encountered in SEM-CODE-LIST.
       (process-expr!
	(lambda (rtx-obj expr mode parent-expr op-pos tstate appstuff)
	  (case (car expr)

	    ((operand) (if (memory? (op:type (rtx-operand-obj expr)))
			   ; Don't change to '(MEM), since we use append!.
			   (append! sem-attrs (list 'MEM)))
		       (if (mode-float? (op:mode (rtx-operand-obj expr)))
			   ; Don't change to '(FPU), since we use append!.
			   (append! sem-attrs (list 'FPU)))
		       )

	    ((mem) (append! sem-attrs (list 'MEM)))

	    ; If this is a syntax expression, the operands won't have been
	    ; processed, so tell our caller we want it to by returning #f.
	    ; We do the same for non-syntax expressions to keep things
	    ; simple.  This requires collaboration with the traversal
	    ; handlers which are defined to do what we want if we return #f.
	    (else #f))))
       )

    ; Traverse the expression recording the attributes.
    ; We just want the side-effects of computing various properties
    ; so we discard the result.

    (rtx-traverse context
		  insn
		  ; Simplified semantics recorded in the `tmp' field.
		  (insn-tmp insn)
		  process-expr!
		  #f)

    ; Drop dummy first arg and remove duplicates.
    (nub (cdr sem-attrs) identity))
)

; Return boolean indicating if PROPS indicates INSN references memory.

(define (insn-refs-mem? insn props)
  (->bool (memq 'MEM props))
)

; Return boolean indicating if PROPS indicates INSN uses the fpu.

(define (insn-uses-fpu? insn props)
  (->bool (memq 'FPU props))
)

; Ensure INSN has attribute IDOC.
; If not specified, guess(?).

(define (guess-insn-idoc-attr! insn)
  (if (not (obj-attr-present? insn 'IDOC))
    (let ((attr #f)
	  (props (get-insn-properties insn)))
      ; Try various heuristics.
      (if (and (not attr)
	       (insn-sets-pc? insn))
	  (set! attr 'BR))
      (if (and (not attr)
	       (insn-refs-mem? insn props))
	  (set! attr 'MEM))
      (if (and (not attr)
	       (insn-uses-fpu? insn props))
	  (set! attr 'FPU))
      ; If nothing else works, assume ALU.
      (if (not attr)
	  (set! attr 'ALU))
      (obj-cons-attr! insn (enum-attr-make 'IDOC attr))))
  *UNSPECIFIED*
)

; Return subset of insns in IDOC category CAT-NAME.

(define (get-insns-for-category insns cat-name)
  (find (lambda (insn)
	  (obj-has-attr-value-no-default? insn 'IDOC cat-name))
	insns)
)

; CATEGORIES is a list of "enum value" elements for each category.
; See <enum-attribute> for the definition.
; INSNS is already alphabetically sorted and selected for just MACH.

(define (gen-categories-insn-lists mach categories insns)
  (string-list
   ; generate a table of insns for each category
   (string-list-map (lambda (c)
		      (let ((cat-insns (get-insns-for-category insns (enum-val-name c)))
			    (comment (enum-val-comment c)))
			(if (null? cat-insns)
			    ""
			    (gen-insn-doc-list mach (enum-val-name c) comment cat-insns))))
		    categories)
   ; lastly, the alphabetical list
   (gen-insn-doc-list mach (obj:name mach) (obj:comment mach) insns)
   )
)

; CATEGORIES is a list of "enum value" elements for each category.
; See <enum-attribute> for the definition.
; INSNS is already alphabetically sorted and selected for just MACH.

(define (gen-insn-categories mach categories insns)
  (string-list
   "<ul>\n"
   (string-list-map (lambda (c)
		      (let ((cat-insns (get-insns-for-category insns (enum-val-name c)))
			    (comment (enum-val-comment c)))
			(if (null? cat-insns)
			    ""
			    (string-list
			     "<li><a href=\"#mach-insns-"
			     (obj:str-name mach)
			     "-"
			     (->string (enum-val-name c))
			     "\">"
			     (->string (enum-val-name c))
			     (if (string=? comment "")
				 ""
				 (string-append " - " comment))
			     "</a></li>\n"
			     ))))
		    categories)
   "<li><a href=\"#mach-insns-"
   (obj:str-name mach)
   "-"
   (obj:str-name mach)
   "\">alphabetically</a></li>\n"
   "</ul>\n"
   )
)

; ??? There's an inefficiency here, we compute insns for each mach for each
; category twice.  Left for later if warranted.

(define (gen-insn-docs)
  ; First simplify the semantics, e.g. do constant folding.
  ; For insns built up from macros, often this will remove a lot of clutter.
  (for-each (lambda (insn)
	      (insn-set-tmp! insn (rtx-simplify-insn #f insn)))
	    (current-insn-list))

  (let ((machs (current-mach-list))
	(insns (alpha-sort-obj-list (current-insn-list)))
	(categories (attr-values (current-attr-lookup 'IDOC))))
    ; First, install IDOC attributes for insns that don't specify one.
    (for-each guess-insn-idoc-attr! insns)
    (string-list
     "\n"
     "<hr>\n"
     "<a name=\"insns\"></a>\n"
     "<h2>Instructions</h2>\n"
     "Instructions for each machine:\n"
     "<ul>\n"
;     (string-map (lambda (o)
;		   (gen-obj-list-entry o "mach-insns"))
;		 machs)
     (string-list-map (lambda (m)
			(let ((mach-insns (find (lambda (insn)
						  (mach-supports? m insn))
						insns)))
			  (string-list "<li>"
				       (obj:str-name m)
				       " - "
				       (obj:comment m)
				       "</li>\n"
				       (gen-insn-categories m categories mach-insns)
			   )))
		      machs)
     "</ul>\n"
;     (string-list-map (lambda (m)
;			(gen-insn-doc-list m insns))
;		      machs)
     (string-list-map (lambda (m)
			(let ((mach-insns (find (lambda (insn)
						  (mach-supports? m insn))
						insns)))
			  (gen-categories-insn-lists m categories mach-insns)))
		      machs)
     "<hr>\n"
     "<h2>Individual instructions descriptions</h2>\n"
     "<br>\n"
     (string-list-map gen-insn-doc-1 insns)
     ))
)

; Macro-instruction page.

(define (gen-macro-insn-doc-1 minsn)
  (string-list
   (gen-obj-doc-header minsn "macro-insn")
   "<ul>\n"
   "<li>\n"
   "syntax: "
   "<tt><font size=+2>"
   (minsn-syntax minsn)
   "</font></tt>\n"
   "</li>\n"
   "<br>\n"
   "<li>\n"
   "transformation:\n"
   "<font size=+2>\n"
   "<pre>" ; no trailing newline here on purpose
   (with-output-to-string
     (lambda ()
       (pretty-print (minsn-expansions minsn))))
   "</pre></font>\n"
   "</li>\n"
   "</ul>\n"
   )
)

(define (gen-macro-insn-doc-list mach)
  (let ((minsns (find (lambda (minsn)
			(mach-supports? mach minsn))
		      (current-minsn-list))))
    (string-list
     (gen-obj-doc-header mach "mach-macro-insns")
     "<ul>\n"
     (string-map (lambda (o)
		   (gen-obj-list-entry o "macro-insn"))
		 minsns)
     "</ul>\n"
     ))
)

(define (gen-macro-insn-docs)
  (let ((machs (current-mach-list))
	(minsns (alpha-sort-obj-list (current-minsn-list))))
    (string-list
     "\n"
     "<hr>\n"
     "<a name=\"macro-insns\"></a>\n"
     "<h2>Macro Instructions</h2>\n"
     "Macro instructions for each machine:\n"
     "<ul>\n"
     (string-map (lambda (o)
		   (gen-obj-list-entry o "mach-macro-insns"))
		 machs)
     "</ul>\n"
     (string-list-map gen-macro-insn-doc-list machs)
     "<p>\n"
     "<h2>Individual macro-instructions descriptions</h2>\n"
     "<br>\n"
     (string-list-map gen-macro-insn-doc-1 minsns)
     ))
)

; Assembler page.

(define (gen-asm-docs)
  (string-list
   "\n"
   "<hr>\n"
   "<a name=\"assembler\"></a>\n"
   "<h2>Assembler supplemental</h2>\n"
   )
)

; Documentation init,finish,analyzer support.

; Initialize any doc specific things before loading the .cpu file.

(define (doc-init!)
  (desc-init!)
  (mode-set-biggest-word-bitsizes!)
  *UNSPECIFIED*
)

; Finish any doc specific things after loading the .cpu file.
; This is separate from analyze-data! as cpu-load performs some
; consistency checks in between.

(define (doc-finish!)
  (desc-finish!)
  *UNSPECIFIED*
)

; Compute various needed globals and assign any computed fields of
; the various objects.  This is the standard routine that is called after
; a .cpu file is loaded.

(define (doc-analyze!)
  (desc-analyze!)

  ; If the IDOC attribute isn't defined, provide a default one.
  (if (not (current-attr-lookup 'IDOC))
      (define-attr
	'(for insn)
	'(type enum)
	'(name IDOC)
	'(comment "insn kind for documentation")
	'(attrs META)
	'(values
	  (MEM - () "Memory")
	  (ALU - () "ALU")
	  (FPU - () "FPU")
	  (BR - () "Branch")
	  (MISC - () "Miscellaneous"))))

  ; Initialize the rtl->c translator.
  (rtl-c-config!)

  ; Only include semantic operands when computing the format tables if we're
  ; generating operand instance tables.
  ; ??? Actually, may always be able to exclude the semantic operands.
  ; Still need to traverse the semantics to derive machine computed attributes.
  (arch-analyze-insns! CURRENT-ARCH
		       #t ; include aliases?
		       #f) ; analyze semantics?

  *UNSPECIFIED*
)

; Top level C code generators

; Set by the -N argument.
(define *insn-html-file-name* "unspecified.html")

(define (cgen.html)
  (logit 1 "Generating " (current-arch-name) ".html ...\n")
  (string-write
   (gen-html-copyright (string-append "Architecture documentation for "
				      (symbol->string (current-arch-name))
				      ".")
		       CURRENT-COPYRIGHT CURRENT-PACKAGE)
   (gen-html-header "Architecture")
   (gen-table-of-contents *insn-html-file-name*)
   gen-arch-intro
   gen-machine-docs
   gen-model-docs
   gen-register-docs
   gen-asm-docs
   gen-html-trailer
   )
)

(define (cgen-insn.html)
  (logit 1 "Generating " (current-arch-name) "-insn.html ...\n")
  (string-write
   (gen-html-copyright (string-append "Instruction documentation for "
				      (symbol->string (current-arch-name))
				      ".")
		       CURRENT-COPYRIGHT CURRENT-PACKAGE)
   (gen-html-header "Instruction")
   gen-insn-docs
   gen-macro-insn-docs
   gen-html-trailer
   )
)

; For debugging.

(define (cgen-all)
  (string-write
   cgen.html
   cgen-insn.html
   )
)
