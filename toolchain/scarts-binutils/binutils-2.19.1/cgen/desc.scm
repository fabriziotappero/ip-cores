; General cpu info generator support.
; Copyright (C) 2000, 2003, 2009 Red Hat, Inc.
; This file is part of CGEN.
;
; This file generates C versions of the more salient parts of the description
; file.  It's currently part of opcodes or simulator support,
; and doesn't exist as its own "application" (i.e. user of cgen),
; though that's not precluded.

; strip-mnemonic?: If each mnemonic is constant, the insn table doesn't need
; to record them in the syntax field as the mnemonic field also contains it.
; Furthermore, the insn table can be hashed on complete mnemonic.
; ??? Should live in <derived-arch-data> or some such.

(define strip-mnemonic? #f)

; Attribute support code.

(define (gen-attr-table-defn type attr-list)
  (string-append
   "const CGEN_ATTR_TABLE "
   "@arch@_cgen_" type "_attr_table[] =\n{\n"
   (string-map (lambda (attr)
		 (gen-obj-sanitize
		  attr
		  (string-append "  { "
				 "\""
				 (string-upcase (obj:str-name attr))
				 "\", "
				 (if (class-instance? <boolean-attribute> attr)
				     "&bool_attr[0], &bool_attr[0]"
				     (string-append "& " (gen-sym attr)
						    "_attr[0], & "
						    (gen-sym attr)
						    "_attr[0]"))
				 " },\n")))
	       attr-list)
   "  { 0, 0, 0 }\n"
   "};\n\n")
)

(define (gen-attr-table-defns)
  (logit 2 "Generating attribute table defns ...\n")
  (string-append
   "\
/* Attributes.  */

static const CGEN_ATTR_ENTRY bool_attr[] =
{
  { \"#f\", 0 },
  { \"#t\", 1 },
  { 0, 0 }
};

"
   ; Generate tables mapping names to values for all the non-boolean attrs.
   (string-map gen-defn (current-attr-list))
   ; Generate tables for each domain (ifld, insn, etc.) mapping attribute type
   ; to index.
   (gen-attr-table-defn "ifield" (current-ifld-attr-list))
   (gen-attr-table-defn "hardware" (current-hw-attr-list))
   (gen-attr-table-defn "operand" (current-op-attr-list))
   (gen-attr-table-defn "insn" (current-insn-attr-list))
   )
)

; HW-ASM is the base class for supporting hardware elements in the opcode table
; (aka assembler/disassembler).

; Return the C declaration.
; It is up to a derived class to redefine this as necessary.

(method-make! <hw-asm> 'gen-decl (lambda (self) ""))

; Return the C definition.
; It is up to a derived class to redefine this as necessary.

(method-make! <hw-asm> 'gen-defn (lambda (self) ""))

(method-make! <hw-asm> 'gen-ref (lambda (self) "0"))

(method-make! <hw-asm> 'gen-init (lambda (self) ""))

(method-make! <hw-asm> 'gen-table-entry (lambda (self) "CGEN_ASM_NONE, 0, "))

; Prefix of global variables describing operand values.

(define hw-asm-prefix "@arch@_cgen_opval_")

; Emit a C reference to a value operand.
; Usually the operand's details are stored in a struct so in the default
; case return that struct (?correct?).  The caller must add the "&" if desired.

(define (gen-hw-asm-ref name)
  (string-append hw-asm-prefix (gen-c-symbol name))
)

; Keyword support.

; Keyword operands.
; Return the C declaration of a keyword list.

(method-make!
 <keyword> 'gen-decl
 (lambda (self)
   (string-append
    "extern CGEN_KEYWORD "
    (gen-hw-asm-ref (elm-get self 'name))
    ";\n"))
)

; Return the C definition of a keyword list.

(method-make!
 <keyword> 'gen-defn
 (lambda (self)
   (string-append
    "static CGEN_KEYWORD_ENTRY "
    (gen-hw-asm-ref (elm-get self 'name)) "_entries"
    "[] =\n{\n"
    (string-drop -2 ; Delete trailing ",\n" [don't want the ,]
		 (string-map (lambda (e)
			       (string-append
				"  { \""
				(->string (elm-get self 'name-prefix))
				(->string (car e)) ; operand name
				"\", "
				(if (string? (cadr e))
				    (cadr e)
				    (number->string (cadr e))) ; value
				", {0, {{{0, 0}}}}, 0, 0"
				" },\n"
				))
			     (elm-get self 'values)))
    "\n};\n\n"
    "CGEN_KEYWORD "
    (gen-hw-asm-ref (elm-get self 'name))
    " =\n{\n"
    "  & " (gen-hw-asm-ref (elm-get self 'name)) "_entries[0],\n"
    "  " (number->string (length (elm-get self 'values))) ",\n"
    "  0, 0, 0, 0, \"\"\n"
    "};\n\n"
    )
   )
)

; Return a reference to a keyword table.

(method-make!
 <keyword> 'gen-ref
 (lambda (self) (string-append "& " (gen-hw-asm-ref (elm-get self 'name))))
)

(method-make!
 <keyword> 'gen-table-entry
 (lambda (self)
   (string-append "CGEN_ASM_KEYWORD, (PTR) " (send self 'gen-ref) ", "))
)

; Return the C code to initialize a keyword.
; If the `hash' attr is present, the values are hashed.  Currently this is
; done by calling back to GAS to have it add the registers to its symbol table.
; FIXME: Currently unused.  Should be done either in the open routine or
; lazily upon lookup.

(method-make!
 <keyword> 'gen-init
 (lambda (self)
   (cond ((has-attr? self 'HASH)
	  (string-append
	   "  @arch@_cgen_asm_hash_keywords ("
	   (send self 'gen-ref)
	   ");\n"
	   ))
	 (else ""))
   )
)

; Operand support.

; Return a reference to the operand's attributes.

(method-make!
 <operand> 'gen-attr-ref
 (lambda (self)
   (string-append "& CGEN_OPERAND_ATTRS (CGEN_SYM (operand_table)) "
		  "[" (op-enum self) "]"))
)

; Name of C variable that is a pointer to the fields struct.

(define ifields-var "fields")

; Given FIELD, an `ifield' object, return an lvalue for the operand in
; IFIELDS-VAR.

(define (gen-operand-result-var field)
  (string-append ifields-var "->" (gen-sym field))
)

; Basic description init,finish,analyzer support.

; Return a boolean indicating if all insns have a constant mnemonic
; (ie: no $'s in insn's name in `syntax' field).
; If constant, one can build the assembler hash table using the entire
; mnemonic.

(define (constant-mnemonics?)
  #f ; FIXME
)

; Initialize any "desc" specific things before loading the .cpu file.
; N.B. Since "desc" is always a part of another application, that
; application's init! routine must call this one.

(define (desc-init!)
  *UNSPECIFIED*
)

; Finish any "desc" specific things after loading the .cpu file.
; This is separate from analyze-data! as cpu-load performs some
; consistency checks in between.
; N.B. Since "desc" is always a part of another application, that
; application's finish! routine must call this one.

(define (desc-finish!)
  *UNSPECIFIED*
)

; Compute various needed globals and assign any computed fields of
; the various objects.  This is the standard routine that is called after
; a .cpu file is loaded.
; N.B. Since "desc" is always a part of another application, that
; application's analyze! routine must call this one.

(define (desc-analyze!)
  (set! strip-mnemonic? (constant-mnemonics?))

  *UNSPECIFIED*
)
