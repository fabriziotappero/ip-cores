; General cpu info generator support.
; Copyright (C) 2000, 2002, 2005, 2009 Red Hat, Inc.
; This file is part of CGEN.

; Global state variables.

; Specify which application.
(set! APPLICATION 'OPCODES)

; Records the -OPC arg which specifies the path to the .opc file.
(define -opc-file-path #f)
(define (opc-file-path)
  (if -opc-file-path
      -opc-file-path
      (error ".opc file unspecified, missing -OPC argument"))
)
(define (set-opc-file-path! path)
  (set! -opc-file-path path)
)

; Return #t if the -OPC parameter was specified.

(define (opc-file-provided?)
  (and -opc-file-path #t)
)

; Boolean indicating if we're to build the operand instance table.
; The default is no, since only the m32r uses it at present.
; ??? Simulator tracing support could use it.
; ??? Might be lazily built at runtime by parsing the semantic code
; (which would be recorded in the insn table).
(define -opcodes-build-operand-instance-table? #f)

; String containing copyright text.
(define CURRENT-COPYRIGHT #f)

; String containing text defining the package we're generating code for.
(define CURRENT-PACKAGE #f)

; Initialize the options.

(define (option-init!)
  (set! -opcodes-build-operand-instance-table? #f)
  (set! CURRENT-COPYRIGHT copyright-fsf)
  (set! CURRENT-PACKAGE package-gnu-binutils-gdb)
  *UNSPECIFIED*
)

; Handle an option passed in from the command line.

(define (option-set! name value)
  (case name
    ((opinst) (set! -opcodes-build-operand-instance-table? #t))
    ((copyright) (cond ((equal?  value '("fsf"))
			(set! CURRENT-COPYRIGHT copyright-fsf))
		       ((equal? value '("redhat"))
			(set! CURRENT-COPYRIGHT copyright-red-hat))
		       (else (error "invalid copyright value" value))))
    ((package) (cond ((equal?  value '("binutils"))
		      (set! CURRENT-PACKAGE package-gnu-binutils-gdb))
		     ((equal?  value '("gnusim"))
		      (set! CURRENT-PACKAGE package-gnu-simulators))
		     ((equal? value '("cygsim"))
		      (set! CURRENT-PACKAGE package-red-hat-simulators))
		     (else (error "invalid package value" value))))
    (else (error "unknown option" name))
    )
  *UNSPECIFIED*
)

; Instruction fields support code.

; Default type of variable to use to hold ifield value.

(define (gen-ifield-default-type)
  ; FIXME: Use long for now.
  "long"
)

; Given field F, return a C definition of a variable big enough to hold
; its value.

(define (gen-ifield-value-decl f)
  (gen-obj-sanitize f (string-append "  "
				     (gen-ifield-default-type)
				     " " (gen-sym f) ";\n"))
)

; Return name of function to call to insert the value of <ifield> F
; into an insn.

(define (ifld-insert-fn-name f)
  "insert_normal"
)

; Return name of function to call to extract the value of <ifield> F
; into an insn.

(define (ifld-extract-fn-name f)
  "extract_normal"
)

; Default routine to emit C code to insert a field in an insn.

(method-make!
 <ifield> 'gen-insert
 (lambda (self operand)
   (let* ((encode (elm-get self 'encode))
	  (need-extra? encode) ; use to also handle operand's `insert' field
	  (varname (gen-operand-result-var self)))
     (string-append
      (if need-extra?
	  (string-append "      {\n"
			 "        "
			 (gen-ifield-default-type)
			 " value = " varname ";\n")
	  "")
      (if encode
	  (string-append "        value = "
			 ;; NOTE: ENCODE is either, e.g.,
			 ;; ((value pc) (sra DI value 1))
			 ;; or
			 ;; (((<mode> value) (<mode> pc)) (sra DI value 1))
			 (let ((expr (cadr encode))
			       (value (if (symbol? (caar encode)) (caar encode) (cadr (caar encode))))
			       (pc (if (symbol? (cadar encode)) (cadar encode) (cadr (cadar encode)))))
			   (rtl-c DFLT expr
				  (list (list value (obj:name (ifld-encode-mode self)) "value")
					(list pc 'IAI "pc"))))
			 ";\n")
	  "")
      (if need-extra?
	  "  "
	  "")
      "      errmsg = "
      (ifld-insert-fn-name self)
      " (cd, "
      (if need-extra?
	  "value"
	  varname)
      ", "
      ; We explicitly pass the attributes here rather than look them up
      ; to give the code more optimization opportunities.
      ; ??? Maybe when fields are recorded in opc.c, stop doing this, and
      ; pass a pointer to the recorded attributes instead.
      (gen-bool-attrs (if (eq? (mode:class (ifld-mode self)) 'INT)
			  (atlist-cons (bool-attr-make 'SIGNED #t)
				       (obj-atlist self))
			  (obj-atlist self))
		      gen-attr-mask)
      ", " (number->string (ifld-word-offset self))
      ", " (number->string (ifld-start self #f))
      ", " (number->string (ifld-length self))
      ", " (number->string (ifld-word-length self))
      ", total_length"
      ", buffer"
      ");\n"
      (if need-extra?
	  "      }\n"
	  "")
      )))
)

; Default routine to emit C code to extract a field from an insn.

(method-make!
 <ifield> 'gen-extract
 (lambda (self operand)
   (let* ((decode (elm-get self 'decode))
	  (need-extra? decode) ; use to also handle operand's `extract' field
	  (varname (gen-operand-result-var self)))
     (string-append
      (if need-extra?
	  (string-append "      {\n        "
			 (gen-ifield-default-type)
			 " value;\n  ")
	  "")
      "      length = "
      (ifld-extract-fn-name self)
      " (cd, ex_info, insn_value, "
      ; We explicitly pass the attributes here rather than look them up
      ; to give the code more optimization opportunities.
      ; ??? Maybe when fields are recorded in opc.c, stop doing this, and
      ; pass a pointer to the recorded attributes instead.
      (gen-bool-attrs (if (eq? (mode:class (ifld-mode self)) 'INT)
			  (atlist-cons (bool-attr-make 'SIGNED #t)
				       (obj-atlist self))
			  (obj-atlist self))
		      gen-attr-mask)
      ", " (number->string (ifld-word-offset self))
      ", " (number->string (ifld-start self #f))
      ", " (number->string (ifld-length self))
      ", " (number->string (ifld-word-length self))
      ", total_length"
      ", pc"
      ", & "
      (if need-extra?
	  "value"
	  varname)
      ");\n"
      (if decode
	  (string-append "        value = "
			 ;; NOTE: DECODE is either, e.g.,
			 ;; ((value pc) (sll DI value 1))
			 ;; or
			 ;; (((<mode> value) (<mode> pc)) (sll DI value 1))
			 (let ((expr (cadr decode))
			       (value (if (symbol? (caar decode)) (caar decode) (cadr (caar decode))))
			       (pc (if (symbol? (cadar decode)) (cadar decode) (cadr (cadar decode)))))
			   (rtl-c DFLT expr
				  (list (list value (obj:name (ifld-decode-mode self)) "value")
					(list pc 'IAI "pc"))))
			 ";\n")
	  "")
      (if need-extra?
	  (string-append "        " varname " = value;\n"
			 "      }\n")
	  "")
      )))
)

; gen-insert of multi-ifields

(method-make!
 <multi-ifield> 'gen-insert
 (lambda (self operand)
   (let* ((varname (gen-operand-result-var self))
	  (encode (elm-get self 'encode))
	  (need-extra? encode))
     (string-list
      "      {\n"
      (if need-extra?
	  (string-append "        " varname " = "
			 (let ((expr (cadr encode))
			       (value (caar encode))
			       (pc (cadar encode)))
			   (rtl-c DFLT expr
				  (list (list value (obj:name (ifld-encode-mode self)) varname)
					(list pc 'IAI "pc"))))
			 ";\n")
	  "")
      (let ((expr (elm-get self 'insert)))
	(rtl-c VOID expr nil))
      (string-list-map (lambda (subfld)
			 (string-list
			  "  "
			  (send subfld 'gen-insert operand)
			  "        if (errmsg)\n"
			  "          break;\n"))
		       (elm-get self 'subfields))
      "      }\n"
      )))
)

; gen-insert of derived-operands

(method-make!
 <derived-operand> 'gen-insert
 (lambda (self operand)
   "      abort();\n")
)

; gen-extract of multi-ifields

(method-make!
 <multi-ifield> 'gen-extract
 (lambda (self operand)
   (let* ((varname (gen-operand-result-var self))
	  (decode (elm-get self 'decode))
	  (need-extra? decode))
     (string-list
      "      {\n"
      (string-list-map (lambda (subfld)
			 (string-list
			  "  "
			  (send subfld 'gen-extract operand)
			  "        if (length <= 0) break;\n"
			  ))
		       (elm-get self 'subfields))
      (let ((expr (elm-get self 'extract)))
	(rtl-c VOID expr nil))
      (if need-extra?
	  (string-append "        " varname " = "
			 (let ((expr (cadr decode))
			       (value (caar decode))
			       (pc (cadar decode)))
			   (rtl-c DFLT expr
				  (list (list value (obj:name (ifld-decode-mode self)) varname)
					(list pc 'IAI "pc"))))
			 ";\n")
	  "")
      "      }\n"
      )))
)


(method-make!
 <derived-operand> 'gen-extract
 (lambda (self operand)
   "      abort();\n")
)

;(method-make!
; <derived-operand> 'gen-extract
; (lambda (self operand)
;   (string-list
;    "      {\n"
;    (string-list-map (lambda (subop)
;		       (string-list
;			"  " (send subop 'gen-extract operand)
;			"        if (length <= 0)\n"
;			"          break;\n"))
;		     (elm-get self 'args))
;    "      }\n"
;    ))
;)


; Hardware index support code.

(method-make!
 <hw-index> 'gen-insert
 (lambda (self operand)
   (case (hw-index:type self)
     ((ifield)
      (send (hw-index:value self) 'gen-insert operand))
     (else
      "")))
)

(method-make!
 <hw-index> 'gen-extract
 (lambda (self operand)
   (case (hw-index:type self)
     ((ifield)
      (send (hw-index:value self) 'gen-extract operand))
     (else
      ""))))

; HW-ASM is the base class for supporting hardware elements in the opcode table
; (aka assembler/disassembler).

; Utility to return C code to parse a number of <mode> MODE for an operand.
; RESULT-VAR-NAME is a string containing the variable to store the
; parsed number in.
; PARSE-FN is the name of the function to call or #f to use the default.
; OP-ENUM is the enum of the operand.

(define (-gen-parse-number mode parse-fn op-enum result-var-name)
  (string-append
   "      errmsg = "
   ; Use operand's special parse function if there is one, otherwise compute
   ; the function's name from the mode.
   (or parse-fn
       (case (obj:name mode)
	 ((QI HI SI INT) "cgen_parse_signed_integer")
	 ((BI UQI UHI USI UINT) "cgen_parse_unsigned_integer")
	 (else (error "unsupported (as yet) mode for parsing"
		      (obj:name mode)))))
   " (cd, strp, "
   op-enum
   ", "
   ; This is to pacify gcc 4.x which will complain about
   ; incorrect signed-ness of pointers passed to functions.
   (case (obj:name mode)
	 ((QI HI SI INT) "(long *)")
	 ((BI UQI UHI USI UINT) "(unsigned long *)")
   )
   " (& " result-var-name
   "));\n"
   )
)

; Utility to return C code to parse an address.
; RESULT-VAR-NAME is a string containing the variable to store the
; parsed number in.
; PARSE-FN is the name of the function to call or #f to use the default.
; OP-ENUM is the enum of the operand.

(define (-gen-parse-address parse-fn op-enum result-var-name)
  (string-append
   "      {\n"
   "        bfd_vma value = 0;\n"
   "        errmsg = "
   ; Use operand's special parse function if there is one.
   (or parse-fn
       "cgen_parse_address")
   " (cd, strp, "
   op-enum
   ", 0, " ; opinfo arg
   "NULL, " ; result_type arg (FIXME)
   " & value);\n"
   "        " result-var-name " = value;\n"
   "      }\n"
   )
)

; Return C code to parse an expression.

(method-make!
 <hw-asm> 'gen-parse
 (lambda (self operand)
   (let ((mode (elm-get self 'mode))
	 (result-var
	  (case (hw-index:type (op:index operand))
	    ((ifield) (gen-operand-result-var (op-ifield operand)))
	    (else "junk"))))
     (if (address? (op:type operand))
	 (-gen-parse-address (send operand 'gen-function-name 'parse)
			     (op-enum operand)
			     result-var)
	 (-gen-parse-number mode (send operand 'gen-function-name 'parse)
			    (op-enum operand)
			    result-var))))
)

; Default method to emit C code to print a hardware element.

(method-make!
 <hw-asm> 'gen-print
 (lambda (self operand)
   (let ((value
	  (case (hw-index:type (op:index operand))
	    ((ifield) (gen-operand-result-var (op-ifield operand)))
	    (else "0"))))
     (string-append
      "      "
      (or (send operand 'gen-function-name 'print)
	  (and (address? (op:type operand))
	       "print_address")
	  "print_normal")
;    (or (send operand 'gen-function-name 'print)
;	(case (obj:name (elm-get self 'mode))
;	  ((QI HI SI INT) "print_signed")
;	  ((BI UQI UHI USI UINT) "print_unsigned")
;	  (else (error "unsupported (as yet) mode for printing"
;		       (obj:name (elm-get self 'mode))))))
      " (cd, info, "
      value
      ", "
      ; We explicitly pass the attributes here rather than look them up
      ; to give the code more optimization opportunities.
      (gen-bool-attrs (if (eq? (mode:class (elm-get self 'mode)) 'INT)
			  (atlist-cons (bool-attr-make 'SIGNED #t)
				       (obj-atlist operand))
			  (obj-atlist operand))
		      gen-attr-mask)
      ;(gen-bool-attrs (obj-atlist operand) gen-attr-mask)
      ", pc, length"
      ");\n"
      )))
)

; Keyword support.

; Return C code to parse a keyword.

(method-make!
 <keyword> 'gen-parse
 (lambda (self operand)
   (let ((result-var 
	  (case (hw-index:type (op:index operand))
	    ((ifield) (gen-operand-result-var (op-ifield operand)))
	    (else "junk"))))
     (string-append
      "      errmsg = "
      (or (send operand 'gen-function-name 'parse)
	  "cgen_parse_keyword")
      " (cd, strp, "
      (send self 'gen-ref) ", "
      ;(op-enum operand) ", "
      "& " result-var
      ");\n"
      )))
)

; Return C code to print a keyword.

(method-make!
 <keyword> 'gen-print
 (lambda (self operand)
   (let ((value
	  (case (hw-index:type (op:index operand))
	    ((ifield) (gen-operand-result-var (op-ifield operand)))
	    (else "0"))))
     (string-append
      "      "
      (or (send operand 'gen-function-name 'print)
	  "print_keyword")
      " (cd, "
      "info" ; The disassemble_info argument to print_insn.
      ", "
      (send self 'gen-ref)
      ", " value
      ", "
      ; We explicitly pass the attributes here rather than look them up
      ; to give the code more optimization opportunities.
      (gen-bool-attrs (obj-atlist operand) gen-attr-mask)
      ");\n"
      )))
)

; Hardware support.

; For registers, use the indices field.  Ignore values.
; ??? Not that that will always be the case.

(method-make-forward! <hw-register> 'indices '(gen-parse gen-print))

; No such support for memory yet.

(method-make!
 <hw-memory> 'gen-parse
 (lambda (self operand)
   (error "gen-parse of memory not supported yet"))
)

(method-make!
 <hw-memory> 'gen-print
 (lambda (self operand)
   (error "gen-print of memory not supported yet"))
)

; For immediates, use the values field.  Ignore indices.
; ??? Not that that will always be the case.

(method-make-forward! <hw-immediate> 'values '(gen-parse gen-print))

; For addresses, use the values field.  Ignore indices.

(method-make-forward! <hw-address> 'values '(gen-parse gen-print))

; Generate the C code for dealing with operands.
; This code is inserted into cgen-{ibld,asm,dis}.in above the insn routines
; so that it can be inlined if desired.  ??? Actually this isn't always the
; case but this is minutiae to be dealt with much later.

; Generate the guts of a C switch to handle an operation for all operands.
; WHAT is one of fget/fset/parse/insert/extract/print.
;
; The "f" prefix (e.g. set -> fset) is for "field" to distinguish the
; operations from similar ones in other contexts.  ??? I'd prefer to come
; up with better names for fget/fset but I haven't come up with anything
; satisfactory yet.

(define (gen-switch what)
  (string-list-map
   (lambda (ops)
     ; OPS is a list of operands with the same name that for whatever reason
     ; were defined separately.
     (logit 3 (string/symbol-append
	       "Processing " (obj:str-name (car ops)) " " what " ...\n"))
     (if (= (length ops) 1)
	 (gen-obj-sanitize
	  (car ops)
	  (string-list
	   "    case @ARCH@_OPERAND_"
	   (string-upcase (gen-sym (car ops)))
	   " :\n"
	   (send (car ops) (symbol-append 'gen- what) (car ops))
	   "      break;\n"))
	 (string-list
	  ; FIXME: operand name doesn't get sanitized.
	  "    case @ARCH@_OPERAND_"
	  (string-upcase (gen-sym (car ops)))
	  " :\n"
	  ; There's more than one operand defined with this name, so we
	  ; have to distinguish them.
	  ; FIXME: Unfinished.
	  (string-list-map (lambda (op)
			     (gen-obj-sanitize
			      op
			      (string-list
			       (send op (symbol-append 'gen- what) op)
			       )))
			   ops)
	  "      break;\n"
	  )))
   (op-sort (find (lambda (op) (and (not (has-attr? op 'SEM-ONLY))
				    (not (anyof-operand? op))
				    (not (derived-operand? op))))
		  (current-op-list))))
)

; Operand support.

; Return the function name to use for WHAT or #f if there isn't a special one.
; WHAT is one of fget/fset/parse/insert/extract/print.

(method-make!
 <operand> 'gen-function-name
 (lambda (self what)
   (let ((handlers (elm-get self 'handlers)))
     (let ((fn (assq-ref handlers what)))
       (and fn (string-append (symbol->string what) "_" (car fn))))))
)

; Interface fns.
; The default is to forward the request onto TYPE.
; OP is a copy of SELF so the method we forward to sees it.
; There is one case in the fget/fset/parse/insert/extract/print
; switches for each operand.
; These are invoked via gen-switch.

; Emit C code to get an operand value from the fields struct.
; Operand values are stored in a struct "indexed" by field name.
;
; The "f" prefix (e.g. set -> fset) is for "field" to distinguish the
; operations from similar ones in other contexts.  ??? I'd prefer to come
; up with better names for fget/fset but I haven't come up with anything
; satisfactory yet.

(method-make!
 <operand> 'gen-fget
 (lambda (self operand)
   (case (hw-index:type (op:index self))
     ((ifield)
      (string-append "      value = "
		     (gen-operand-result-var (op-ifield self))
		     ";\n"))
     (else
      "      value = 0;\n")))
)

(method-make!
 <derived-operand> 'gen-fget
 (lambda (self operand)
   "      abort();\n") ; should never be called
)

; Emit C code to save an operand value in the fields struct.

(method-make!
 <operand> 'gen-fset
 (lambda (self operand)
   (case (hw-index:type (op:index self))
     ((ifield)
      (string-append "      "
		     (gen-operand-result-var (op-ifield self))
		     " = value;\n"))
     (else
      ""))) ; ignore
)

(method-make!
 <derived-operand> 'gen-fset
 (lambda (self operand)
   "      abort();\n") ; should never be called
)


; Need to call op:type to resolve the hardware reference.
;(method-make-forward! <operand> 'type '(gen-parse gen-print))

(method-make!
 <operand> 'gen-parse
 (lambda (self operand)
   (send (op:type self) 'gen-parse operand))
)

(method-make!
 <derived-operand> 'gen-parse
 (lambda (self operand)
   "      abort();\n") ; should never be called
)

(method-make!
 <operand> 'gen-print
 (lambda (self operand)
   (send (op:type self) 'gen-print operand))
)

(method-make!
 <derived-operand> 'gen-print
 (lambda (self operand)
   "      abort();\n") ; should never be called
)

(method-make-forward! <operand> 'index '(gen-insert gen-extract))
; But: <derived-operand> has its own gen-insert / gen-extract.


; Return the value of PC.
; Used by insert/extract fields.

(method-make!
 <pc> 'cxmake-get
 (lambda (self estate mode index selector)
   (cx:make IAI "pc"))
)

; Opcodes init,finish,analyzer support.

; Initialize any opcodes specific things before loading the .cpu file.

(define (opcodes-init!)
  (desc-init!)
  (mode-set-biggest-word-bitsizes!)
  *UNSPECIFIED*
)

; Finish any opcodes specific things after loading the .cpu file.
; This is separate from analyze-data! as cpu-load performs some
; consistency checks in between.

(define (opcodes-finish!)
  (desc-finish!)
  *UNSPECIFIED*
)

; Compute various needed globals and assign any computed fields of
; the various objects.  This is the standard routine that is called after
; a .cpu file is loaded.

(define (opcodes-analyze!)
  (desc-analyze!)

  ; Initialize the rtl->c translator.
  (rtl-c-config!)

  ; Only include semantic operands when computing the format tables if we're
  ; generating operand instance tables.
  ; ??? Actually, may always be able to exclude the semantic operands.
  ; Still need to traverse the semantics to derive machine computed attributes.
  (arch-analyze-insns! CURRENT-ARCH
		       #t ; include aliases
		       -opcodes-build-operand-instance-table?)

  *UNSPECIFIED*
)

; Extra target specific code generation.

; Pick out a section from the .opc file.
; The section is delimited with:
; /* -- name ... */
; ...
; /* -- ... */
;
; FIXME: This is a pretty involved bit of code.  'twould be nice to split
; it up into manageable chunks.

(define (read-cpu.opc opc-file delim)
  (let ((file opc-file)
	(start-delim (string-append "/* -- " delim))
	(end-delim "/* -- "))
    (if (file-exists? file)
	(let ((port (open-file file "r"))
	      ; Extra amount is added to SIZE so substring's to fetch possible
	      ; delim won't fail, even at end of file
	      (size (+ (file-size file) (string-length start-delim))))
	  (if port
	      (let ((result (make-string size #\space)))
		(let loop ((start -1) (line 0) (index 0))
		  (let ((char (read-char port)))
		    (if (not (eof-object? char))
			(string-set! result index char))
		    (cond ((eof-object? char)
			   (begin
			     (close-port port)
			     ; End of file, did we find the text?
			     (if (=? start -1)
				 ""
				 (substring result start index))))
			  ((char=? char #\newline)
			   ; Check for start delim or end delim?
			   (if (=? start -1)
			       (if (string=? (substring result line
							(+ (string-length start-delim)
							   line))
					     start-delim)
				   (loop line (+ index 1) (+ index 1))
				   (loop -1 (+ index 1) (+ index 1)))
			       (if (string=? (substring result line
							(+ (string-length end-delim)
							   line))
					     end-delim)
				   (begin
				     (close-port port)
				     (substring result start (+ index 1)))
				   (loop start (+ index 1) (+ index 1)))))
			  (else
			   (loop start line (+ index 1)))))))
		(error "Unable to open:" file)))
	"" ; file doesn't exist
	))
)

(define (gen-extra-cpu.h opc-file arch)
  (logit 2 "Generating extra cpu.h stuff from " arch ".opc ...\n")
  (read-cpu.opc opc-file "cpu.h")
)
(define (gen-extra-cpu.c opc-file arch)
  (logit 2 "Generating extra cpu.c stuff from " arch ".opc ...\n")
  (read-cpu.opc opc-file "cpu.c")
)
(define (gen-extra-opc.h opc-file arch)
  (logit 2 "Generating extra opc.h stuff from " arch ".opc ...\n")
  (read-cpu.opc opc-file "opc.h")
)
(define (gen-extra-opc.c opc-file arch)
  (logit 2 "Generating extra opc.c stuff from " arch ".opc ...\n")
  (read-cpu.opc opc-file "opc.c")
)
(define (gen-extra-asm.c opc-file arch)
  (logit 2 "Generating extra asm.c stuff from " arch ".opc ...\n")
  (read-cpu.opc opc-file "asm.c")
)
(define (gen-extra-dis.c opc-file arch)
  (logit 2 "Generating extra dis.c stuff from " arch ".opc ...\n")
  (read-cpu.opc opc-file "dis.c")
)
(define (gen-extra-ibld.h opc-file arch)
  (logit 2 "Generating extra ibld.h stuff from " arch ".opc ...\n")
  (read-cpu.opc opc-file "ibld.h")
)
(define (gen-extra-ibld.c opc-file arch)
  (logit 2 "Generating extra ibld.c stuff from " arch ".opc ...\n")
  (read-cpu.opc opc-file "ibld.c")
)

; For debugging.

(define (cgen-all)
  (string-write
   cgen-desc.h
   cgen-desc.c
   cgen-opinst.c
   cgen-opc.h
   cgen-opc.c
   cgen-ibld.h
   cgen-ibld.in
   cgen-asm.in
   cgen-dis.in
   )
)
