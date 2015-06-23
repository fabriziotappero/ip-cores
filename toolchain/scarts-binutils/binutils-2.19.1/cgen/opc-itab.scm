; Opcode table support.
; Copyright (C) 2000, 2005, 2009 Red Hat, Inc.
; This file is part of CGEN.

; Append code here to be run before insn parsing/etc.
; These are for internal use and aren't intended to appear in .cpu files.
; ??? Nothing currently uses them but that might change.

(define parse-init-code "")
(define insert-init-code "")
(define extract-init-code "")
(define print-init-code "")

; Define CGEN_INIT_{PARSE,INSERT,EXTRACT,PRINT} macros.
; ??? These were early escape hatches.  Not currently used.

(define (-gen-init-macros)
  (logit 2 "Generating init macros ...\n")
  (string-append
   "#define CGEN_INIT_PARSE(od) \\
{\\\n"
   parse-init-code
   "}\n"
   "#define CGEN_INIT_INSERT(od) \\
{\\\n"
   insert-init-code
   "}\n"
   "#define CGEN_INIT_EXTRACT(od) \\
{\\\n"
   extract-init-code
   "}\n"
   "#define CGEN_INIT_PRINT(od) \\
{\\\n"
   print-init-code
   "}\n"
  )
)

; Instruction field support.

; Return C code to declare various ifield types,decls.

(define (-gen-ifield-decls)
  (logit 2 "Generating instruction field decls ...\n")
  (string-append
   "/* This struct records data prior to insertion or after extraction.  */\n"
   "struct cgen_fields\n{\n"
   ; A special member `length' is used to record the length.
   "  int length;\n"
   (string-map gen-ifield-value-decl (non-derived-ifields (current-ifld-list)))
   "};\n\n"
   )
)

; Instruction syntax support.

; Extract the operand fields in SYNTAX-STRING.
; The result is a list of operand names.
; ??? Not currently used, but keep awhile.

(define (extract-syntax-operands syntax)
  (let loop ((syn syntax) (result nil))

    (cond ((= (string-length syn) 0)
	   (reverse! result))

	  ((char=? #\\ (string-ref syn 0))
	   (if (= (string-length syn) 1)
	       (error "missing char after '\\'" syntax))
	   (loop (string-drop 2 syn) result))

	  ((char=? #\$ (string-ref syn 0))
	   ; Extract the symbol from the string, which will be the name of
	   ; an operand.  Append it to the result.
	   (if (= (string-length syn) 1)
	       (error "missing operand name" syntax))
	   (if (char=? (string-ref syn 1) #\{)
	       (let ((n (chars-until-delimiter syn #\})))
		 ; Note that 'n' includes the leading ${.
		 (case n
		   ((0) (error "empty operand name" syntax))
		   ((#f) (error "missing '}'" syntax))
		   (else (loop (string-drop (+ n 1) syn)
			       (cons (string->symbol (substring syn 2 n))
				     result)))))
	       (let ((n (id-len (string-drop1 syn))))
		 (if (= n 0)
		     (error "empty or invalid operand name" syntax))
		 (loop (string-drop (1+ n) syn)
		       (cons (string->symbol (substring syn 1 (1+ n)))
			     result)))))

	  (else (loop (string-drop1 syn) result))))
)

; Strip the mnemonic part from SYNTAX.
; (ie: everything up to but not including the first space or '$')
; If STRIP-MNEM-OPERANDS?, strip them too.

(define (strip-mnemonic strip-mnem-operands? syntax)
  (let ((space (string-index syntax #\space)))
    (if strip-mnem-operands?
	(if space
	    (string-drop space syntax)
	    "")
	(let loop ((syn syntax))
	  (if (= (string-length syn) 0)
	      ""
	      (case (string-ref syn 0)
		((#\space) syn)
		((#\\) (loop (string-drop 2 syn)))
		((#\$) syn)
		(else (loop (string-drop1 syn))))))))
)

; Compute the sequence of syntax bytes for SYNTAX.
; STRIP-MNEMONIC? is #t if the mnemonic part is to be stripped off.
; STRIP-MNEM-OPERANDS? is #t if any mnemonic operands are to be stripped off.
; SYNTAX is a string of text and operands.
; OP-MACRO is the macro to call that computes an operand's value.
; The resulting syntax is expressed as a sequence of bytes.
; Values < 128 are characters that must be matched.
; Values >= 128 are 128 + the index into the operand table.

(define (compute-syntax strip-mnemonic? strip-mnem-operands? syntax op-macro)
  (let ((context (make-prefix-context "syntax computation"))
	(syntax (if strip-mnemonic?
		    (strip-mnemonic strip-mnem-operands? syntax)
		    syntax)))

    (let loop ((syn syntax) (result ""))

      (cond ((= (string-length syn) 0)
	     (string-append result "0"))

	    ((char=? #\\ (string-ref syn 0))
	     (if (= (string-length syn) 1)
		 (parse-error context "missing char after '\\'" syntax))
	     (let ((escaped-char (string-ref syn 1))
		   (remainder (string-drop 2 syn)))
	       (if (char=? #\\ escaped-char)
		   (loop remainder (string-append result "'\\\\', "))
		   (loop remainder (string-append result "'" (string escaped-char) "', ")))))

	    ((char=? #\$ (string-ref syn 0))
	     ; Extract the symbol from the string, which will be the name of
	     ; an operand.  Append it to the result.
	     (if (= (string-length syn) 1)
		 (parse-error context "missing operand name" syntax))
	     ; Is it $foo or ${foo}?
	     (if (char=? (string-ref syn 1) #\{)
		 (let ((n (chars-until-delimiter syn #\})))
		   ; Note that 'n' includes the leading ${.
		   ; FIXME: \} not implemented yet.
		   (case n
		     ((0) (parse-error context "empty operand name" syntax))
		     ((#f) (parse-error context "missing '}'" syntax))
		     (else (loop (string-drop (+ n 1) syn)
				 (string-append result op-macro " ("
						(string-upcase
						 (gen-c-symbol
						  (substring syn 2 n)))
						"), ")))))
		 (let ((n (id-len (string-drop1 syn))))
		   (if (= n 0)
		       (parse-error context "empty or invalid operand name" syntax))
		   (let ((operand (string->symbol (substring syn 1 (1+ n)))))
		     (if (not (current-op-lookup operand))
			 (parse-error context "undefined operand " operand syntax)))
		   (loop (string-drop (1+ n) syn)
			 (string-append result op-macro " ("
					(string-upcase
					 (gen-c-symbol
					  (substring syn 1 (1+ n))))
					"), ")))))

	    ; Append the character to the result.
	    (else (loop (string-drop1 syn)
			(string-append result
				       "'" (string-take1 syn) "', "))))))
)

; Return C code to define the syntax string for SYNTAX
; MNEM is the C value to use to represent the instruction's mnemonic.
; OP is the C macro to use to compute an operand's syntax value.

(define (gen-syntax-entry mnem op syntax)
  (string-append
   "{ { "
   mnem ", "
   ; `mnem' is used to represent the mnemonic, so we always want to strip it
   ; from the syntax string, regardless of the setting of `strip-mnemonic?'.
   (compute-syntax #t #f syntax op)
   " } }")
)

; Instruction format table support.

; Return the table for IFMT, an <iformat> object.

(define (-gen-ifmt-table-1 ifmt)
  (gen-obj-sanitize
   (ifmt-eg-insn ifmt) ; sanitize based on the example insn
   (string-list
    "static const CGEN_IFMT " (gen-sym ifmt) " ATTRIBUTE_UNUSED = {\n"
    "  "
    (number->string (ifmt-mask-length ifmt)) ", "
    (number->string (ifmt-length ifmt)) ", "
    "0x" (number->string (ifmt-mask ifmt) 16) ", "
    "{ "
    (string-list-map (lambda (ifld)
		       (string-list "{ F (" (ifld-enum ifld #f) ") }, "))
		     (ifmt-ifields ifmt))
    "{ 0 } }\n};\n\n"))
)

; Generate the insn format table.

(define (-gen-ifmt-table)
  (string-write
   "/* Instruction formats.  */\n\n"
   (gen-define-with-symcat "F(f) & @arch@_cgen_ifld_table[@ARCH@_" "f]")
   (string-list-map -gen-ifmt-table-1 (current-ifmt-list))
   "#undef F\n\n"
   )
)

; Parse/insert/extract/print handlers.
; Each handler type is recorded in the assembler/disassembler as an array of
; pointers to functions.  The value recorded in the operand table is the index
; into this array. The first element in the array is reserved as index 0 is
; special (the "default").
;
; The handlers are recorded here as associative lists in case we ever want
; to record more than just the name.
;
; Adding a new handler involves
; - specifying its name in the .cpu file
; - getting its name appended to these tables
; - writing the C code
;
; ??? It might be useful to define the handler in Scheme.  Later.

(define opc-parse-handlers '((insn-normal)))
(define opc-insert-handlers '((insn-normal)))
(define opc-extract-handlers '((insn-normal)))
(define opc-print-handlers '((insn-normal)))

; FIXME: There currently isn't a spot for specifying special handlers for
; each instruction.  For now assume we always use the same ones.

(define (insn-handlers insn)
  (string-append
   (number->string (assq-lookup-index 'insn-normal opc-parse-handlers 0))
   ", "
   (number->string (assq-lookup-index 'insn-normal opc-insert-handlers 0))
   ", "
   (number->string (assq-lookup-index 'insn-normal opc-extract-handlers 0))
   ", "
   (number->string (assq-lookup-index 'insn-normal opc-print-handlers 0))
   )
)

; Return C code to define the cgen_opcode_handler struct for INSN.
; This is intended to be the ultimate escape hatch for the parse/insert/
; extract/print handlers.  Each entry is an index into a table of handlers.
; The escape hatch isn't used yet.

(define (gen-insn-handlers insn)
  (string-append
   "{ "
   (insn-handlers insn)
   " }"
   )
)

; Handler table support.
; There are tables for each of parse/insert/extract/print.

; Return C code to define the handler table for NAME with values VALUES.

(define (gen-handler-table name values)
  (string-append
   "cgen_" name "_fn * const @arch@_cgen_" name "_handlers[] = \n{\n"
   (string-map (lambda (elm)
		 (string-append "  " name "_"
				(gen-c-symbol (car elm))
				",\n"))
	       values)
   "};\n\n"
   )
)

; Instruction table support.

; Return a declaration of an enum for all insns.

(define (-gen-insn-enum)
  (logit 2 "Generating instruction enum ...\n")
  (let ((insns (gen-obj-list-enums (non-multi-insns (current-insn-list)))))
    (string-list
     (gen-enum-decl 'cgen_insn_type "@arch@ instruction types"
		    "@ARCH@_INSN_"
		    (cons '(invalid) insns))
     "/* Index of `invalid' insn place holder.  */\n"
     "#define CGEN_INSN_INVALID @ARCH@_INSN_INVALID\n\n"
     "/* Total number of insns in table.  */\n"
     "#define MAX_INSNS ((int) @ARCH@_INSN_"
     (string-upcase (gen-c-symbol (caar (list-take -1 insns)))) " + 1)\n\n"
   )
  )
)

; Return a reference to the format table entry of INSN.

(define (gen-ifmt-entry insn)
  (string-append "& " (gen-sym (insn-ifmt insn)))
)

; Return the definition of an instruction value entry.

(define (gen-ivalue-entry insn)
  (string-list "{ "
	       "0x" (number->string (insn-value insn) 16)
	       (if #f ; (ifmt-opcodes-beyond-base? (insn-ifmt insn))
		   (string-list ", { "
				; ??? wip: opcode values beyond the base insn
				"0 }")
		   "")
	       " }")
)

; Generate an insn opcode entry for INSN.
; ALL-ATTRS is a list of all instruction attributes.
; NUM-NON-BOOLS is the number of non-boolean insn attributes.

(define (-gen-insn-opcode-entry insn all-attrs num-non-bools)
  (gen-obj-sanitize
   insn
   (string-list
    "/* " (insn-syntax insn) " */\n"
    "  {\n"
    "    " (gen-insn-handlers insn) ",\n"
    "    " (gen-syntax-entry "MNEM" "OP" (insn-syntax insn)) ",\n"
    ; ??? 'twould save space to put a pointer here and record format separately
    "    " (gen-ifmt-entry insn) ", "
    ;"0x" (number->string (insn-value insn) 16) ",\n"
    (gen-ivalue-entry insn) "\n"
    "  },\n"))
)

; Generate insn table.

(define (-gen-insn-opcode-table)
  (logit 2 "Generating instruction opcode table ...\n")
  (let* ((all-attrs (current-insn-attr-list))
	 (num-non-bools (attr-count-non-bools all-attrs)))
    (string-write
     (gen-define-with-symcat "A(a) (1 << CGEN_INSN_" "a)")
     (gen-define-with-symcat "OPERAND(op) @ARCH@_OPERAND_" "op")
     "\
#define MNEM CGEN_SYNTAX_MNEMONIC /* syntax value for mnemonic */
#define OP(field) CGEN_SYNTAX_MAKE_FIELD (OPERAND (field))

/* The instruction table.  */

static const CGEN_OPCODE @arch@_cgen_insn_opcode_table[MAX_INSNS] =
{
  /* Special null first entry.
     A `num' value of zero is thus invalid.
     Also, the special `invalid' insn resides here.  */
  { { 0, 0, 0, 0 }, {{0}}, 0, {0}},\n"

     (lambda ()
       (string-write-map (lambda (insn)
                           (logit 3 "Generating insn opcode entry for " (obj:name insn) " ...\n")
                           (-gen-insn-opcode-entry insn all-attrs
						   num-non-bools))
                         (non-multi-insns (current-insn-list))))

     "\
};

#undef A
#undef OPERAND
#undef MNEM
#undef OP

"
     )
    )
)

; Return assembly/disassembly hashing support.

(define (-gen-hash-fns)
  (string-list
   "\
#ifndef CGEN_ASM_HASH_P
#define CGEN_ASM_HASH_P(insn) 1
#endif

#ifndef CGEN_DIS_HASH_P
#define CGEN_DIS_HASH_P(insn) 1
#endif

/* Return non-zero if INSN is to be added to the hash table.
   Targets are free to override CGEN_{ASM,DIS}_HASH_P in the .opc file.  */

static int
asm_hash_insn_p (insn)
     const CGEN_INSN *insn ATTRIBUTE_UNUSED;
{
  return CGEN_ASM_HASH_P (insn);
}

static int
dis_hash_insn_p (insn)
     const CGEN_INSN *insn;
{
  /* If building the hash table and the NO-DIS attribute is present,
     ignore.  */
  if (CGEN_INSN_ATTR_VALUE (insn, CGEN_INSN_NO_DIS))
    return 0;
  return CGEN_DIS_HASH_P (insn);
}

#ifndef CGEN_ASM_HASH
#define CGEN_ASM_HASH_SIZE 127
#ifdef CGEN_MNEMONIC_OPERANDS
#define CGEN_ASM_HASH(mnem) (*(unsigned char *) (mnem) % CGEN_ASM_HASH_SIZE)
#else
#define CGEN_ASM_HASH(mnem) (*(unsigned char *) (mnem) % CGEN_ASM_HASH_SIZE) /*FIXME*/
#endif
#endif

/* It doesn't make much sense to provide a default here,
   but while this is under development we do.
   BUFFER is a pointer to the bytes of the insn, target order.
   VALUE is the first base_insn_bitsize bits as an int in host order.  */

#ifndef CGEN_DIS_HASH
#define CGEN_DIS_HASH_SIZE 256
#define CGEN_DIS_HASH(buf, value) (*(unsigned char *) (buf))
#endif

/* The result is the hash value of the insn.
   Targets are free to override CGEN_{ASM,DIS}_HASH in the .opc file.  */

static unsigned int
asm_hash_insn (mnem)
     const char * mnem;
{
  return CGEN_ASM_HASH (mnem);
}

/* BUF is a pointer to the bytes of the insn, target order.
   VALUE is the first base_insn_bitsize bits as an int in host order.  */

static unsigned int
dis_hash_insn (buf, value)
     const char * buf ATTRIBUTE_UNUSED;
     CGEN_INSN_INT value ATTRIBUTE_UNUSED;
{
  return CGEN_DIS_HASH (buf, value);
}
\n"
   )
)

; Hash support decls.

(define (-gen-hash-decls)
  (string-list
   "\
/* The hash functions are recorded here to help keep assembler code out of
   the disassembler and vice versa.  */

static int asm_hash_insn_p        (const CGEN_INSN *);
static unsigned int asm_hash_insn (const char *);
static int dis_hash_insn_p        (const CGEN_INSN *);
static unsigned int dis_hash_insn (const char *, CGEN_INSN_INT);
\n"
   )
)

; Macro insn support.

; Return a macro-insn expansion entry.

(define (-gen-miexpn-entry entry)
   ; FIXME: wip
  "0, "
)

; Return a macro-insn table entry.
; ??? wip, not currently used.

(define (-gen-minsn-table-entry minsn all-attrs num-non-bools)
  (gen-obj-sanitize
   minsn
   (string-list
    "  /* " (minsn-syntax minsn) " */\n"
    "  {\n"
    "    "
    "-1, " ; macro-insns are not currently enumerated, no current need to
    "\"" (obj:str-name minsn) "\", "
    "\"" (minsn-mnemonic minsn) "\",\n"
    "    " (gen-syntax-entry "MNEM" "OP" (minsn-syntax minsn)) ",\n"
    "    (PTR) & macro_" (gen-sym minsn) "_expansions[0],\n"
    "    "
    (gen-obj-attr-defn 'minsn minsn all-attrs num-non-bools gen-insn-attr-mask)
    "\n"
    "  },\n"))
)

; Return a macro-insn opcode table entry.
; ??? wip, not currently used.

(define (-gen-minsn-opcode-entry minsn all-attrs num-non-bools)
  (gen-obj-sanitize
   minsn
   (string-list
    "  /* " (minsn-syntax minsn) " */\n"
    "  {\n"
    "    "
    "-1, " ; macro-insns are not currently enumerated, no current need to
    "\"" (obj:str-name minsn) "\", "
    "\"" (minsn-mnemonic minsn) "\",\n"
    "    " (gen-syntax-entry "MNEM" "OP" (minsn-syntax minsn)) ",\n"
    "    (PTR) & macro_" (gen-sym minsn) "_expansions[0],\n"
    "    "
    (gen-obj-attr-defn 'minsn minsn all-attrs num-non-bools gen-insn-attr-mask)
    "\n"
    "  },\n"))
)

; Macro insn expansion has one basic form, but we optimize the common case
; of unconditionally expanding the input text to one instruction.
; The general form is a Scheme expression that is interpreted at runtime to
; decide how to perform the expansion.  Yes, that means having a (perhaps
; minimal) Scheme interpreter in the assembler.
; Another thing to do is have a builder for each real insn so instead of
; expanding to text, the macro-expansion could invoke the builder for each
; expanded-to insn.

(define (-gen-macro-insn-table)
  (logit 2 "Generating macro-instruction table ...\n")
  (let* ((minsn-list (map (lambda (minsn)
			    (if (has-attr? minsn 'ALIAS)
				(minsn-make-alias (make-prefix-context "gen-macro-insn-table")
						  minsn)
				minsn))
			  (current-minsn-list)))
	 (all-attrs (current-insn-attr-list))
	 (num-non-bools (attr-count-non-bools all-attrs)))
    (string-write
     "/* Formats for ALIAS macro-insns.  */\n\n"
     (gen-define-with-symcat "F(f) & @arch@_cgen_ifld_table[@ARCH@_" "f]")
     (lambda ()
       (string-write-map -gen-ifmt-table-1
			 (map insn-ifmt (find (lambda (minsn)
						(has-attr? minsn 'ALIAS))
					      minsn-list))))
     "#undef F\n\n"
     "/* Each non-simple macro entry points to an array of expansion possibilities.  */\n\n"
     (lambda () 
       (string-write-map (lambda (minsn)
			   (if (has-attr? minsn 'ALIAS)
			       ""
			       (string-append
				"static const CGEN_MINSN_EXPANSION macro_" (gen-sym minsn) "_expansions[] =\n"
				"{\n"
				(string-map -gen-miexpn-entry
					    (minsn-expansions minsn))
				"  { 0, 0 }\n};\n\n")))
			 minsn-list))
     (gen-define-with-symcat "A(a) (1 << CGEN_INSN_" "a)")
     (gen-define-with-symcat "OPERAND(op) @ARCH@_OPERAND_" "op")
     "\
#define MNEM CGEN_SYNTAX_MNEMONIC /* syntax value for mnemonic */
#define OP(field) CGEN_SYNTAX_MAKE_FIELD (OPERAND (field))

/* The macro instruction table.  */

static const CGEN_IBASE @arch@_cgen_macro_insn_table[] =
{
"
     (lambda ()
       (string-write-map (lambda (minsn)
			   (logit 3 "Generating macro-insn table entry for " (obj:name minsn) " ...\n")
			   ; Simple macro-insns are emitted as aliases of real insns.
			   (if (has-attr? minsn 'ALIAS)
			       (gen-insn-table-entry minsn all-attrs num-non-bools)
			       (-gen-minsn-table-entry minsn all-attrs num-non-bools)))
			 minsn-list))
     "\
};

/* The macro instruction opcode table.  */

static const CGEN_OPCODE @arch@_cgen_macro_insn_opcode_table[] =
{\n"
     (lambda ()
       (string-write-map (lambda (minsn)
			   (logit 3 "Generating macro-insn table entry for " (obj:name minsn) " ...\n")
			   ; Simple macro-insns are emitted as aliases of real insns.
			   (if (has-attr? minsn 'ALIAS)
			       (-gen-insn-opcode-entry minsn all-attrs num-non-bools)
			       (-gen-minsn-opcode-entry minsn all-attrs num-non-bools)))
			 minsn-list))
     "\
};

#undef A
#undef OPERAND
#undef MNEM
#undef OP
\n"
    ))
)

; Emit a function to call to initialize the opcode table.

(define (-gen-opcode-init-fn)
  (string-write
   "\
/* Set the recorded length of the insn in the CGEN_FIELDS struct.  */

static void
set_fields_bitsize (CGEN_FIELDS *fields, int size)
{
  CGEN_FIELDS_BITSIZE (fields) = size;
}

/* Function to call before using the operand instance table.
   This plugs the opcode entries and macro instructions into the cpu table.  */

void
@arch@_cgen_init_opcode_table (CGEN_CPU_DESC cd)
{
  int i;
  int num_macros = (sizeof (@arch@_cgen_macro_insn_table) /
		    sizeof (@arch@_cgen_macro_insn_table[0]));
  const CGEN_IBASE *ib = & @arch@_cgen_macro_insn_table[0];
  const CGEN_OPCODE *oc = & @arch@_cgen_macro_insn_opcode_table[0];
  CGEN_INSN *insns = xmalloc (num_macros * sizeof (CGEN_INSN));

  /* This test has been added to avoid a warning generated
     if memset is called with a third argument of value zero.  */
  if (num_macros >= 1)
    memset (insns, 0, num_macros * sizeof (CGEN_INSN));
  for (i = 0; i < num_macros; ++i)
    {
      insns[i].base = &ib[i];
      insns[i].opcode = &oc[i];
      @arch@_cgen_build_insn_regex (& insns[i]);
    }
  cd->macro_insn_table.init_entries = insns;
  cd->macro_insn_table.entry_size = sizeof (CGEN_IBASE);
  cd->macro_insn_table.num_init_entries = num_macros;

  oc = & @arch@_cgen_insn_opcode_table[0];
  insns = (CGEN_INSN *) cd->insn_table.init_entries;
  for (i = 0; i < MAX_INSNS; ++i)
    {
      insns[i].opcode = &oc[i];
      @arch@_cgen_build_insn_regex (& insns[i]);
    }

  cd->sizeof_fields = sizeof (CGEN_FIELDS);
  cd->set_fields_bitsize = set_fields_bitsize;

  cd->asm_hash_p = asm_hash_insn_p;
  cd->asm_hash = asm_hash_insn;
  cd->asm_hash_size = CGEN_ASM_HASH_SIZE;

  cd->dis_hash_p = dis_hash_insn_p;
  cd->dis_hash = dis_hash_insn;
  cd->dis_hash_size = CGEN_DIS_HASH_SIZE;
}
"
   )
)

; Top level C code generators

; FIXME: Create enum objects for all the enums we explicitly declare here.
; Then they'd be usable and we wouldn't have to special case them here.

(define (cgen-opc.h)
  (logit 1 "Generating " (current-arch-name) "-opc.h ...\n")
  (string-write
   (gen-c-copyright "Instruction opcode header for @arch@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#ifndef @ARCH@_OPC_H
#define @ARCH@_OPC_H

"
   (lambda () (gen-extra-opc.h (opc-file-path) (current-arch-name)))
   -gen-insn-enum
   -gen-ifield-decls
   -gen-init-macros
   "

#endif /* @ARCH@_OPC_H */
"
   )
)

; This file contains the instruction opcode table.

(define (cgen-opc.c)
  (logit 1 "Generating " (current-arch-name) "-opc.c ...\n")
  (string-write
   (gen-c-copyright "Instruction opcode table for @arch@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#include \"sysdep.h\"
#include \"ansidecl.h\"
#include \"bfd.h\"
#include \"symcat.h\"
#include \"@prefix@-desc.h\"
#include \"@prefix@-opc.h\"
#include \"libiberty.h\"
\n"
   (lambda () (gen-extra-opc.c (opc-file-path) (current-arch-name)))
   -gen-hash-decls
   -gen-ifmt-table
   -gen-insn-opcode-table
   -gen-macro-insn-table
   -gen-hash-fns
   -gen-opcode-init-fn
   )
)
