; Generate .c/.h versions of main elements of cpu description file.
; Copyright (C) 2000, 2001, 2002, 2003, 2005, 2009 Red Hat, Inc.
; This file is part of CGEN.

; ISA support code.

(define (-gen-isa-table-defns)
  (logit 2 "Generating isa table defns ...\n")

  (string-list
   "\
/* Instruction set variants.  */

static const CGEN_ISA @arch@_cgen_isa_table[] = {
"
   (string-list-map (lambda (isa)
		      (gen-obj-sanitize
		       isa
		       (string-append "  { "
				      "\"" (obj:str-name isa) "\", "
				      (number->string
				       (isa-default-insn-bitsize isa))
				      ", "
				      (number->string
				       (isa-base-insn-bitsize isa))
				      ", "
				      (number->string
				       (isa-min-insn-bitsize isa))
				      ", "
				      (number->string
				       (isa-max-insn-bitsize isa))
				      " },\n")))
		    (current-isa-list))
   "\
  { 0, 0, 0, 0, 0 }
};
\n"
   )
)

; Mach support code.

; Return C code to describe the various cpu variants.
; Currently this is quite simple, the various cpu names and their mach numbers
; are recorded in a "keyword" table.
; ??? No longer used as there is the mach attribute.
;
;(set! mach-table (make <keyword> 'mach "machine list"
;			(make <attr-list> "" nil) ; FIXME: sanitization?
;			(map (lambda (elm) (list (obj:name elm) (mach-number elm)))
;			     (current-mach-list))))

(define (-gen-mach-table-decls)
  (logit 2 "Generating machine table decls ...\n")
  "" ; (gen-decl mach-table)
)

(define (-gen-mach-table-defns)
  (logit 2 "Generating machine table defns ...\n")

  (string-list
   "\
/* Machine variants.  */

static const CGEN_MACH @arch@_cgen_mach_table[] = {
"
   (string-list-map (lambda (mach)
		      (gen-obj-sanitize
		       mach
		       (string-append "  { "
				      "\"" (obj:str-name mach) "\", "
				      "\"" (mach-bfd-name mach) "\", "
				      (mach-enum mach) ", "
				      (number->string (cpu-insn-chunk-bitsize (mach-cpu mach)))
				      " },\n")))
		    (current-mach-list))
   "\
  { 0, 0, 0, 0 }
};
\n"
   )
)

; Attribute support code.

; Return C code to describe the various attributes.

(define (-gen-attr-table-decls)
  (logit 2 "Generating attribute table decls ...\n")
  (string-append
   "/* Attributes.  */\n"
   "extern const CGEN_ATTR_TABLE @arch@_cgen_hardware_attr_table[];\n"
   "extern const CGEN_ATTR_TABLE @arch@_cgen_ifield_attr_table[];\n"
   "extern const CGEN_ATTR_TABLE @arch@_cgen_operand_attr_table[];\n"
   "extern const CGEN_ATTR_TABLE @arch@_cgen_insn_attr_table[];\n"
   "\n"
   )
)

; Alternative GEN-MASK argument to gen-bool-attrs.
; This uses the `A' macro to abbreviate the attribute definition.

(define (gen-A-attr-mask prefix name)
  (string-append "A(" (string-upcase (gen-c-symbol name)) ")")
)

; Instruction fields support code.

; Return C code to declare various ifield bits.

(define (gen-ifld-decls)
  (logit 2 "Generating instruction field decls ...\n")
  (string-list
   "/* Ifield support.  */\n\n"
   "/* Ifield attribute indices.  */\n\n"
   (gen-attr-enum-decl "cgen_ifld" (current-ifld-attr-list))
   (-gen-attr-accessors "cgen_ifld" (current-ifld-attr-list))
   (gen-enum-decl 'ifield_type "@arch@ ifield types"
		  "@ARCH@_"
		  (append (gen-obj-list-enums (non-derived-ifields (current-ifld-list)))
			  '((f-max))))
   "#define MAX_IFLD ((int) @ARCH@_F_MAX)\n\n"
   )
)

; Return C code to define the instruction field table,
; and any other ifield related definitions.

(define (gen-ifld-defns)
  (logit 2 "Generating ifield table ...\n")
  (let* ((ifld-list (current-ifld-list))
	 (all-attrs (current-ifld-attr-list))
	 (num-non-bools (attr-count-non-bools all-attrs)))
    (string-list
     "
/* The instruction field table.  */

"
     (gen-define-with-symcat "A(a) (1 << CGEN_IFLD_" "a)")
     "
const CGEN_IFLD @arch@_cgen_ifld_table[] =
{
"
     (string-list-map
      (lambda (ifld)
	(gen-obj-sanitize ifld
			  (string-append
			   "  { "
			   (ifld-enum ifld) ", "
			   "\"" (obj:str-name ifld) "\", "
                           (if
                            (or (has-attr? ifld 'VIRTUAL)
                                (derived-ifield? ifld))
                             "0, 0, 0, 0,"
                             (string-append
		              (number->string (ifld-word-offset ifld)) ", "
			      (number->string (ifld-word-length ifld)) ", "
			      (number->string (ifld-start ifld #f)) ", "
			      (number->string (ifld-length ifld)) ", "))
			   (gen-obj-attr-defn 'ifld ifld all-attrs
				      num-non-bools gen-A-attr-mask)
			   "  },\n")))
      ifld-list)
     "\
  { 0, 0, 0, 0, 0, 0, " (gen-obj-attr-end-defn all-attrs num-non-bools) " }
};

#undef A

"
     ))
)

; Hardware support.

; Return C code to declare the various hardware bits
; that can be (or must be) defined before including opcode/cgen.h.

(define (gen-hw-decls)
  (logit 2 "Generating hardware decls ...\n")
  (string-list
   "/* Hardware attribute indices.  */\n\n"
   (gen-attr-enum-decl "cgen_hw" (current-hw-attr-list))
   (-gen-attr-accessors "cgen_hw" (current-hw-attr-list))
   (gen-enum-decl 'cgen_hw_type "@arch@ hardware types"
		  "HW_" ; FIXME: @ARCH@_
		  (append (nub (map (lambda (hw)
				      (cons (hw-sem-name hw)
					    (cons '-
						  (atlist-attrs
						   (obj-atlist hw)))))
				    (current-hw-list))
			       (lambda (elm) (car elm)))
			  '((max))))
   "#define MAX_HW ((int) HW_MAX)\n\n"
   )
)

; Return declarations of variables tables used by HW.

(define (-gen-hw-decl hw)
  (string-append
   (if (hw-indices hw)
       (gen-decl (hw-indices hw))
       "")
   (if (hw-values hw)
       (gen-decl (hw-values hw))
       "")
   )
)

; Return C code to declare the various hardware bits
; that must be defined after including opcode/cgen.h.

(define (gen-hw-table-decls)
  (logit 2 "Generating hardware table decls ...\n")
  (string-list
   "/* Hardware decls.  */\n\n"
   (string-map -gen-hw-decl (current-hw-list))
   "\n"
   "extern const CGEN_HW_ENTRY @arch@_cgen_hw_table[];\n"
   )
)

; Return definitions of variables tables used by HW.
; Only do this for `PRIVATE' elements.  Public ones are emitted elsewhere.

(define (-gen-hw-defn hw)
  (string-append
   (if (and (hw-indices hw)
	    (obj-has-attr? (hw-indices hw) 'PRIVATE))
       (gen-defn (hw-indices hw))
       "")
   (if (and (hw-values hw)
	    (obj-has-attr? (hw-values hw) 'PRIVATE))
       (gen-defn (hw-values hw))
       "")
   )
)

; Generate the tables for the various hardware bits (register names, etc.).
; A table is generated for each element, and then another table is generated
; which collects them all together.
; Uses include looking up a particular register set so that a new reg
; can be added to it [at runtime].

(define (gen-hw-table-defns)
  (logit 2 "Generating hardware table ...\n")
  (let* ((all-attrs (current-hw-attr-list))
	 (num-non-bools (attr-count-non-bools all-attrs)))
    (string-list
     (string-list-map gen-defn (current-kw-list))
     (string-list-map -gen-hw-defn (current-hw-list))
     "
/* The hardware table.  */

"
     (gen-define-with-symcat "A(a) (1 << CGEN_HW_" "a)")
     "
const CGEN_HW_ENTRY @arch@_cgen_hw_table[] =
{
"
     (string-list-map
      (lambda (hw)
	(gen-obj-sanitize hw
			  (string-list
			   "  { "
			   "\"" (obj:str-name hw) "\", "
			   (hw-enum hw) ", "
			   ; ??? No element currently requires both indices and
			   ; values specs so we only output the needed one.
			   (or (and (hw-indices hw)
				    (send (hw-indices hw) 'gen-table-entry))
			       (and (hw-values hw)
				    (send (hw-values hw) 'gen-table-entry))
			       "CGEN_ASM_NONE, 0, ")
			   (gen-obj-attr-defn 'hw hw all-attrs
					      num-non-bools gen-A-attr-mask)
			   " },\n")))
      (current-hw-list))
     "\
  { 0, 0, CGEN_ASM_NONE, 0, " (gen-obj-attr-end-defn all-attrs num-non-bools) " }
};

#undef A

"
     ))
)

; Utilities of cgen-opc.h.

; Return #define's of several constants.
; FIXME: Some of these to be moved into table of structs, one per cpu family.

(define (-gen-hash-defines)
  (logit 2 "Generating #define's ...\n")
  (string-list
   "#include \"opcode/cgen-bitset.h\"\n"
   "\n"
   "#define CGEN_ARCH @arch@\n\n"
   "/* Given symbol S, return @arch@_cgen_<S>.  */\n"
   (gen-define-with-symcat "CGEN_SYM(s) @arch@" "_cgen_" "s")
   "\n\n/* Selected cpu families.  */\n"
   ; FIXME: Move to sim's arch.h.
   (string-map (lambda (cpu)
		 (gen-obj-sanitize cpu
				   (string-append "#define HAVE_CPU_"
						  (string-upcase (gen-sym cpu))
						  "\n")))
	       (current-cpu-list))
   "\n"
   "#define CGEN_INSN_LSB0_P " (if (current-arch-insn-lsb0?) "1" "0")
   "\n\n"
   "/* Minimum size of any insn (in bytes).  */\n"
   "#define CGEN_MIN_INSN_SIZE "
   (number->string (bits->bytes
		    (apply min (map isa-min-insn-bitsize (current-isa-list)))))
   "\n\n"
   "/* Maximum size of any insn (in bytes).  */\n"
   "#define CGEN_MAX_INSN_SIZE "
   (number->string (bits->bytes
		    (apply max (map isa-max-insn-bitsize (current-isa-list)))))
   "\n\n"
   ; This tells the assembler/disassembler whether or not it can use an int to
   ; record insns, which is faster.  Since this controls the typedef of the
   ; insn buffer, only enable this if all isas support it.
   "#define CGEN_INT_INSN_P "
   (if (all-true? (map isa-integral-insn? (current-isa-list))) "1" "0")
   "\n"
   "\n"
   "/* Maximum number of syntax elements in an instruction.  */\n"
   "#define CGEN_ACTUAL_MAX_SYNTAX_ELEMENTS "
   ; The +2 account for the leading "MNEM" and trailing 0.
   (number->string (+ 2 (apply max (map (lambda (insn) 
					  (length (syntax-break-out (insn-syntax insn))))
					(current-insn-list)))))
   "\n"
   "\n"
   "/* CGEN_MNEMONIC_OPERANDS is defined if mnemonics have operands.\n"
   "   e.g. In \"b,a foo\" the \",a\" is an operand.  If mnemonics have operands\n"
   "   we can't hash on everything up to the space.  */\n"
   (if strip-mnemonic?
       "/*#define CGEN_MNEMONIC_OPERANDS*/\n"
       "#define CGEN_MNEMONIC_OPERANDS\n")
   "\n"
   ; "/* Maximum number of operands any insn or macro-insn has.  */\n"
   ; FIXME: Should compute.
   ; "#define CGEN_MAX_INSN_OPERANDS 16\n"
   ; "\n"
   "/* Maximum number of fields in an instruction.  */\n"
   "#define CGEN_ACTUAL_MAX_IFMT_OPERANDS "
   (number->string (apply max (map (lambda (f) (length (ifmt-ifields f)))
				   (current-ifmt-list))))
   "\n\n"
  )
)

; Operand support.

; Return C code to declare various operand bits.

(define (gen-operand-decls)
  (logit 2 "Generating operand decls ...\n")
  (string-list
   "/* Operand attribute indices.  */\n\n"
   (gen-attr-enum-decl "cgen_operand" (current-op-attr-list))
   (-gen-attr-accessors "cgen_operand" (current-op-attr-list))
   (gen-enum-decl 'cgen_operand_type "@arch@ operand types"
		  "@ARCH@_OPERAND_"
		  (nub (append (gen-obj-list-enums (current-op-list))
			       '((max)))
		       car))
   "/* Number of operands types.  */\n"
   "#define MAX_OPERANDS " (number->string (length (gen-obj-list-enums (current-op-list)))) "\n\n"
   ; was: "#define MAX_OPERANDS ((int) @ARCH@_OPERAND_MAX)\n\n"
   "/* Maximum number of operands referenced by any insn.  */\n"
   "#define MAX_OPERAND_INSTANCES "
   (number->string (max-operand-instances))
   "\n\n"
   )
)

; Generate C code to define the operand table.

(define ifld-number-cache #f)
(define (ifld-number f)
  (if (not ifld-number-cache)
      (let* ((ls (find (lambda (f) (not (has-attr? f 'VIRTUAL)))
		       (non-derived-ifields (current-ifld-list))))
	     (numls (iota (length ls))))
	(set! ifld-number-cache 
	      (map (lambda (elt num) (cons (obj:name elt) num)) 
		   ls numls))))
  (number->string (cdr (assoc (obj:name f) ifld-number-cache))))

(define (gen-maybe-multi-ifld-of-op op)
  (let* ((idx (op:index op))
	 (ty (hw-index:type idx))
	 (fld (hw-index:value idx)))
    (gen-maybe-multi-ifld ty fld)))

(define (gen-maybe-multi-ifld ty fld)
  (let* ((field-ref "0")
	 (field-count "0"))
    (if (equal? ty 'ifield)
	(if (multi-ifield? fld) 
	    (begin
	      (set! field-ref (string-append "&" (ifld-enum fld) "_MULTI_IFIELD[0]"))
	      (set! field-count (number->string (length (elm-get fld 'subfields)))))
	    ; else	    
	      (set! field-ref (string-append "&@arch@_cgen_ifld_table[" (ifld-enum fld) "]"))))
    (string-append "{ " field-count ", { (const PTR) " field-ref " } }")))

(define (gen-multi-ifield-nodes)
  (let ((multis (find multi-ifield? (current-ifld-list))))
    (apply string-append
	   (append 
	    
	    '("\n\n/* multi ifield declarations */\n\n")
	    (map   
	     (lambda (ifld) 
	       (string-append 
		"const CGEN_MAYBE_MULTI_IFLD " 
		(ifld-enum ifld) "_MULTI_IFIELD [];\n"))
	     multis)

	    '("\n\n/* multi ifield definitions */\n\n")
	    (map   
	     (lambda (ifld)
	       (string-append
		"const CGEN_MAYBE_MULTI_IFLD " 
		(ifld-enum ifld) "_MULTI_IFIELD [] =\n{"
		(apply string-append 
		       (map (lambda (x) (string-append "\n    " (gen-maybe-multi-ifld 'ifield x) ",")) 
			    (elm-get ifld 'subfields)))
		"\n    { 0, { (const PTR) 0 } }\n};\n"))
	     multis)))))

(define (gen-operand-table)
  (logit 2 "Generating operand table ...\n")
  (let* ((all-attrs (current-op-attr-list))
	 (num-non-bools (attr-count-non-bools all-attrs)))
    (string-list
     "
/* The operand table.  */

"
     (gen-define-with-symcat "A(a) (1 << CGEN_OPERAND_" "a)")
     (gen-define-with-symcat "OPERAND(op) @ARCH@_OPERAND_" "op")
"
const CGEN_OPERAND @arch@_cgen_operand_table[] =
{
"
     (string-list-map
      (lambda (op)
	(gen-obj-sanitize op
			  (string-append
			   "/* " (obj:str-name op) ": " (obj:comment op) " */\n"
                          (if (or (derived-operand? op)
                                  (anyof-operand? op))
                              ""
                              (string-append 
			         "  { "
    		   	         "\"" (obj:str-name op) "\", "
			         (op-enum op) ", "
			         (hw-enum (op:hw-name op)) ", "
			         (number->string (op:start op)) ", "
			         (number->string (op:length op)) ",\n"
			         "    "
                                 (gen-maybe-multi-ifld-of-op op) ", \n"
			         "    "
			         (gen-obj-attr-defn 'operand op all-attrs
				       	            num-non-bools gen-A-attr-mask)
			         "  },\n"
			      )))))
      (current-op-list))
     "/* sentinel */\n\
  { 0, 0, 0, 0, 0,\n    { 0, { (const PTR) 0 } },\n    " (gen-obj-attr-end-defn all-attrs num-non-bools) " }
};

#undef A

"
     )
    )
)

; Instruction table support.

; Return C code to declare various insn bits.

(define (gen-insn-decls)
  (logit 2 "Generating instruction decls ...\n")
  (string-list
   "/* Insn attribute indices.  */\n\n"
   (gen-attr-enum-decl "cgen_insn" (current-insn-attr-list))
   (-gen-attr-accessors "cgen_insn" (current-insn-attr-list))
   )
)

; Generate an insn table entry for INSN.
; ALL-ATTRS is a list of all instruction attributes.
; NUM-NON-BOOLS is the number of non-boolean insn attributes.

(define (gen-insn-table-entry insn all-attrs num-non-bools)
  (gen-obj-sanitize
   insn
   (string-list
    "/* " (insn-syntax insn) " */\n"
    "  {\n"
    "    "
    (if (has-attr? insn 'ALIAS) "-1" (insn-enum insn)) ", "
    "\"" (obj:str-name insn) "\", "
    "\"" (insn-mnemonic insn) "\", "
    ;(if (has-attr? insn 'ALIAS) "0" (number->string (insn-length insn))) ",\n"
    (number->string (insn-length insn)) ",\n"
; ??? There is currently a problem with embedded newlines, and this might
; best be put in another file [the table is already pretty big].
; Might also wish to output bytecodes instead.
;    "    "
;    (if (insn-semantics insn)
;	(string-append "\""
;		       (with-output-to-string
;			 ; ??? Should we do macro expansion here?
;			 (lambda () (display (insn-semantics insn))))
;		       "\"")
;	"0")
;    ",\n"
    ; ??? Might wish to output the raw format spec here instead
    ; (either as plain text or bytecodes).
    ; Values could be lazily computed and cached.
    "    "
    (gen-obj-attr-defn 'insn insn all-attrs num-non-bools gen-A-attr-mask)
    "\n  },\n"))
)

; Generate insn table.

(define (gen-insn-table)
  (logit 2 "Generating instruction table ...\n")
  (let* ((all-attrs (current-insn-attr-list))
	 (num-non-bools (attr-count-non-bools all-attrs)))
    (string-write
     "
/* The instruction table.  */

#define OP(field) CGEN_SYNTAX_MAKE_FIELD (OPERAND (field))
"
     (gen-define-with-symcat "A(a) (1 << CGEN_INSN_" "a)")
"
static const CGEN_IBASE @arch@_cgen_insn_table[MAX_INSNS] =
{
  /* Special null first entry.
     A `num' value of zero is thus invalid.
     Also, the special `invalid' insn resides here.  */
  { 0, 0, 0, 0, " (gen-obj-attr-end-defn all-attrs num-non-bools) " },\n"

     (lambda ()
       (string-write-map (lambda (insn)
                           (logit 3 "Generating insn table entry for " (obj:name insn) " ...\n")
                           (gen-insn-table-entry insn all-attrs num-non-bools))
                         (non-multi-insns (current-insn-list))))

     "\
};

#undef OP
#undef A

"
     )
    )
)

; Cpu table handling support.
;
; ??? A lot of this can live in a machine independent file, but there's
; currently no place to put this file (there's no libcgen).  libopcodes is the
; wrong place as some simulator ports use this but they don't use libopcodes.

; Return C routines to open/close a cpu description table.
; This is defined here and not in cgen-opc.in because it refers to
; CGEN_{ASM,DIS}_HASH and insn_table/macro_insn_table which is defined
; earlier in the file.  ??? Things can certainly be rearranged though
; and opcodes/cgen.sh modified to insert the generated part into the middle
; of the file like is done for assembler/disassembler support.

(define (-gen-cpu-open)
  (string-append
   "\
static const CGEN_MACH * lookup_mach_via_bfd_name (const CGEN_MACH *, const char *);
static void build_hw_table      (CGEN_CPU_TABLE *);
static void build_ifield_table  (CGEN_CPU_TABLE *);
static void build_operand_table (CGEN_CPU_TABLE *);
static void build_insn_table    (CGEN_CPU_TABLE *);
static void @arch@_cgen_rebuild_tables (CGEN_CPU_TABLE *);

/* Subroutine of @arch@_cgen_cpu_open to look up a mach via its bfd name.  */

static const CGEN_MACH *
lookup_mach_via_bfd_name (const CGEN_MACH *table, const char *name)
{
  while (table->name)
    {
      if (strcmp (name, table->bfd_name) == 0)
	return table;
      ++table;
    }
  abort ();
}

/* Subroutine of @arch@_cgen_cpu_open to build the hardware table.  */

static void
build_hw_table (CGEN_CPU_TABLE *cd)
{
  int i;
  int machs = cd->machs;
  const CGEN_HW_ENTRY *init = & @arch@_cgen_hw_table[0];
  /* MAX_HW is only an upper bound on the number of selected entries.
     However each entry is indexed by it's enum so there can be holes in
     the table.  */
  const CGEN_HW_ENTRY **selected =
    (const CGEN_HW_ENTRY **) xmalloc (MAX_HW * sizeof (CGEN_HW_ENTRY *));

  cd->hw_table.init_entries = init;
  cd->hw_table.entry_size = sizeof (CGEN_HW_ENTRY);
  memset (selected, 0, MAX_HW * sizeof (CGEN_HW_ENTRY *));
  /* ??? For now we just use machs to determine which ones we want.  */
  for (i = 0; init[i].name != NULL; ++i)
    if (CGEN_HW_ATTR_VALUE (&init[i], CGEN_HW_MACH)
	& machs)
      selected[init[i].type] = &init[i];
  cd->hw_table.entries = selected;
  cd->hw_table.num_entries = MAX_HW;
}

/* Subroutine of @arch@_cgen_cpu_open to build the hardware table.  */

static void
build_ifield_table (CGEN_CPU_TABLE *cd)
{
  cd->ifld_table = & @arch@_cgen_ifld_table[0];
}

/* Subroutine of @arch@_cgen_cpu_open to build the hardware table.  */

static void
build_operand_table (CGEN_CPU_TABLE *cd)
{
  int i;
  int machs = cd->machs;
  const CGEN_OPERAND *init = & @arch@_cgen_operand_table[0];
  /* MAX_OPERANDS is only an upper bound on the number of selected entries.
     However each entry is indexed by it's enum so there can be holes in
     the table.  */
  const CGEN_OPERAND **selected = xmalloc (MAX_OPERANDS * sizeof (* selected));

  cd->operand_table.init_entries = init;
  cd->operand_table.entry_size = sizeof (CGEN_OPERAND);
  memset (selected, 0, MAX_OPERANDS * sizeof (CGEN_OPERAND *));
  /* ??? For now we just use mach to determine which ones we want.  */
  for (i = 0; init[i].name != NULL; ++i)
    if (CGEN_OPERAND_ATTR_VALUE (&init[i], CGEN_OPERAND_MACH)
	& machs)
      selected[init[i].type] = &init[i];
  cd->operand_table.entries = selected;
  cd->operand_table.num_entries = MAX_OPERANDS;
}

/* Subroutine of @arch@_cgen_cpu_open to build the hardware table.
   ??? This could leave out insns not supported by the specified mach/isa,
   but that would cause errors like \"foo only supported by bar\" to become
   \"unknown insn\", so for now we include all insns and require the app to
   do the checking later.
   ??? On the other hand, parsing of such insns may require their hardware or
   operand elements to be in the table [which they mightn't be].  */

static void
build_insn_table (CGEN_CPU_TABLE *cd)
{
  int i;
  const CGEN_IBASE *ib = & @arch@_cgen_insn_table[0];
  CGEN_INSN *insns = xmalloc (MAX_INSNS * sizeof (CGEN_INSN));

  memset (insns, 0, MAX_INSNS * sizeof (CGEN_INSN));
  for (i = 0; i < MAX_INSNS; ++i)
    insns[i].base = &ib[i];
  cd->insn_table.init_entries = insns;
  cd->insn_table.entry_size = sizeof (CGEN_IBASE);
  cd->insn_table.num_init_entries = MAX_INSNS;
}

/* Subroutine of @arch@_cgen_cpu_open to rebuild the tables.  */

static void
@arch@_cgen_rebuild_tables (CGEN_CPU_TABLE *cd)
{
  int i;
  CGEN_BITSET *isas = cd->isas;
  unsigned int machs = cd->machs;

  cd->int_insn_p = CGEN_INT_INSN_P;

  /* Data derived from the isa spec.  */
#define UNSET (CGEN_SIZE_UNKNOWN + 1)
  cd->default_insn_bitsize = UNSET;
  cd->base_insn_bitsize = UNSET;
  cd->min_insn_bitsize = 65535; /* Some ridiculously big number.  */
  cd->max_insn_bitsize = 0;
  for (i = 0; i < MAX_ISAS; ++i)
    if (cgen_bitset_contains (isas, i))
      {
	const CGEN_ISA *isa = & @arch@_cgen_isa_table[i];

	/* Default insn sizes of all selected isas must be
	   equal or we set the result to 0, meaning \"unknown\".  */
	if (cd->default_insn_bitsize == UNSET)
	  cd->default_insn_bitsize = isa->default_insn_bitsize;
	else if (isa->default_insn_bitsize == cd->default_insn_bitsize)
	  ; /* This is ok.  */
	else
	  cd->default_insn_bitsize = CGEN_SIZE_UNKNOWN;

	/* Base insn sizes of all selected isas must be equal
	   or we set the result to 0, meaning \"unknown\".  */
	if (cd->base_insn_bitsize == UNSET)
	  cd->base_insn_bitsize = isa->base_insn_bitsize;
	else if (isa->base_insn_bitsize == cd->base_insn_bitsize)
	  ; /* This is ok.  */
	else
	  cd->base_insn_bitsize = CGEN_SIZE_UNKNOWN;

	/* Set min,max insn sizes.  */
	if (isa->min_insn_bitsize < cd->min_insn_bitsize)
	  cd->min_insn_bitsize = isa->min_insn_bitsize;
	if (isa->max_insn_bitsize > cd->max_insn_bitsize)
	  cd->max_insn_bitsize = isa->max_insn_bitsize;
      }

  /* Data derived from the mach spec.  */
  for (i = 0; i < MAX_MACHS; ++i)
    if (((1 << i) & machs) != 0)
      {
	const CGEN_MACH *mach = & @arch@_cgen_mach_table[i];

	if (mach->insn_chunk_bitsize != 0)
	{
	  if (cd->insn_chunk_bitsize != 0 && cd->insn_chunk_bitsize != mach->insn_chunk_bitsize)
	    {
	      fprintf (stderr, \"@arch@_cgen_rebuild_tables: conflicting insn-chunk-bitsize values: `%d' vs. `%d'\\n\",
		       cd->insn_chunk_bitsize, mach->insn_chunk_bitsize);
	      abort ();
	    }

 	  cd->insn_chunk_bitsize = mach->insn_chunk_bitsize;
	}
      }

  /* Determine which hw elements are used by MACH.  */
  build_hw_table (cd);

  /* Build the ifield table.  */
  build_ifield_table (cd);

  /* Determine which operands are used by MACH/ISA.  */
  build_operand_table (cd);

  /* Build the instruction table.  */
  build_insn_table (cd);
}

/* Initialize a cpu table and return a descriptor.
   It's much like opening a file, and must be the first function called.
   The arguments are a set of (type/value) pairs, terminated with
   CGEN_CPU_OPEN_END.

   Currently supported values:
   CGEN_CPU_OPEN_ISAS:    bitmap of values in enum isa_attr
   CGEN_CPU_OPEN_MACHS:   bitmap of values in enum mach_attr
   CGEN_CPU_OPEN_BFDMACH: specify 1 mach using bfd name
   CGEN_CPU_OPEN_ENDIAN:  specify endian choice
   CGEN_CPU_OPEN_END:     terminates arguments

   ??? Simultaneous multiple isas might not make sense, but it's not (yet)
   precluded.

   ??? We only support ISO C stdargs here, not K&R.
   Laziness, plus experiment to see if anything requires K&R - eventually
   K&R will no longer be supported - e.g. GDB is currently trying this.  */

CGEN_CPU_DESC
@arch@_cgen_cpu_open (enum cgen_cpu_open_arg arg_type, ...)
{
  CGEN_CPU_TABLE *cd = (CGEN_CPU_TABLE *) xmalloc (sizeof (CGEN_CPU_TABLE));
  static int init_p;
  CGEN_BITSET *isas = 0;  /* 0 = \"unspecified\" */
  unsigned int machs = 0; /* 0 = \"unspecified\" */
  enum cgen_endian endian = CGEN_ENDIAN_UNKNOWN;
  va_list ap;

  if (! init_p)
    {
      init_tables ();
      init_p = 1;
    }

  memset (cd, 0, sizeof (*cd));

  va_start (ap, arg_type);
  while (arg_type != CGEN_CPU_OPEN_END)
    {
      switch (arg_type)
	{
	case CGEN_CPU_OPEN_ISAS :
	  isas = va_arg (ap, CGEN_BITSET *);
	  break;
	case CGEN_CPU_OPEN_MACHS :
	  machs = va_arg (ap, unsigned int);
	  break;
	case CGEN_CPU_OPEN_BFDMACH :
	  {
	    const char *name = va_arg (ap, const char *);
	    const CGEN_MACH *mach =
	      lookup_mach_via_bfd_name (@arch@_cgen_mach_table, name);

	    machs |= 1 << mach->num;
	    break;
	  }
	case CGEN_CPU_OPEN_ENDIAN :
	  endian = va_arg (ap, enum cgen_endian);
	  break;
	default :
	  fprintf (stderr, \"@arch@_cgen_cpu_open: unsupported argument `%d'\\n\",
		   arg_type);
	  abort (); /* ??? return NULL? */
	}
      arg_type = va_arg (ap, enum cgen_cpu_open_arg);
    }
  va_end (ap);

  /* Mach unspecified means \"all\".  */
  if (machs == 0)
    machs = (1 << MAX_MACHS) - 1;
  /* Base mach is always selected.  */
  machs |= 1;
  if (endian == CGEN_ENDIAN_UNKNOWN)
    {
      /* ??? If target has only one, could have a default.  */
      fprintf (stderr, \"@arch@_cgen_cpu_open: no endianness specified\\n\");
      abort ();
    }

  cd->isas = cgen_bitset_copy (isas);
  cd->machs = machs;
  cd->endian = endian;
  /* FIXME: for the sparc case we can determine insn-endianness statically.
     The worry here is where both data and insn endian can be independently
     chosen, in which case this function will need another argument.
     Actually, will want to allow for more arguments in the future anyway.  */
  cd->insn_endian = endian;

  /* Table (re)builder.  */
  cd->rebuild_tables = @arch@_cgen_rebuild_tables;
  @arch@_cgen_rebuild_tables (cd);

  /* Default to not allowing signed overflow.  */
  cd->signed_overflow_ok_p = 0;
  
  return (CGEN_CPU_DESC) cd;
}

/* Cover fn to @arch@_cgen_cpu_open to handle the simple case of 1 isa, 1 mach.
   MACH_NAME is the bfd name of the mach.  */

CGEN_CPU_DESC
@arch@_cgen_cpu_open_1 (const char *mach_name, enum cgen_endian endian)
{
  return @arch@_cgen_cpu_open (CGEN_CPU_OPEN_BFDMACH, mach_name,
			       CGEN_CPU_OPEN_ENDIAN, endian,
			       CGEN_CPU_OPEN_END);
}

/* Close a cpu table.
   ??? This can live in a machine independent file, but there's currently
   no place to put this file (there's no libcgen).  libopcodes is the wrong
   place as some simulator ports use this but they don't use libopcodes.  */

void
@arch@_cgen_cpu_close (CGEN_CPU_DESC cd)
{
  unsigned int i;
  const CGEN_INSN *insns;

  if (cd->macro_insn_table.init_entries)
    {
      insns = cd->macro_insn_table.init_entries;
      for (i = 0; i < cd->macro_insn_table.num_init_entries; ++i, ++insns)
	if (CGEN_INSN_RX ((insns)))
	  regfree (CGEN_INSN_RX (insns));
    }

  if (cd->insn_table.init_entries)
    {
      insns = cd->insn_table.init_entries;
      for (i = 0; i < cd->insn_table.num_init_entries; ++i, ++insns)
	if (CGEN_INSN_RX (insns))
	  regfree (CGEN_INSN_RX (insns));
    }  

  if (cd->macro_insn_table.init_entries)
    free ((CGEN_INSN *) cd->macro_insn_table.init_entries);

  if (cd->insn_table.init_entries)
    free ((CGEN_INSN *) cd->insn_table.init_entries);

  if (cd->hw_table.entries)
    free ((CGEN_HW_ENTRY *) cd->hw_table.entries);

  if (cd->operand_table.entries)
    free ((CGEN_HW_ENTRY *) cd->operand_table.entries);

  free (cd);
}

")
)

; General initialization C code
; Code is appended during processing.

(define -cputab-init-code "")
(define (cputab-add-init! code)
  (set! -cputab-init-code (string-append -cputab-init-code code))
)

; Return the C code to define the various initialization functions.
; This does not include assembler/disassembler specific stuff.
; Generally, this function doesn't do anything.
; It exists to allow a global-static-constructor kind of thing should
; one ever be necessary.

(define (gen-init-fns)
  (logit 2 "Generating init fns ...\n")
  (string-append
   "\
/* Initialize anything needed to be done once, before any cpu_open call.  */

static void
init_tables (void)
{\n"
   -cputab-init-code
   "}\n\n"
  )
)

; Top level C code generators

; FIXME: Create enum objects for all the enums we explicitly declare here.
; Then they'd be usable and we wouldn't have to special case them here.

(define (cgen-desc.h)
  (logit 1 "Generating " (current-arch-name) "-desc.h ...\n")
  (string-write
   (gen-c-copyright "CPU data header for @arch@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#ifndef @ARCH@_CPU_H
#define @ARCH@_CPU_H

"
   -gen-hash-defines
   ; This is defined in arch.h.  It's not defined here as there is yet to
   ; be a need for it in the assembler/disassembler.
   ;(gen-enum-decl 'model_type "model types"
   ;		  "MODEL_"
   ;		  (append (map list (map obj:name (current-model-list))) '((max))))
   ;"#define MAX_MODELS ((int) MODEL_MAX)\n\n"
   "/* Enums.  */\n\n"
   (string-map gen-decl (current-enum-list))
   "/* Attributes.  */\n\n"
   (string-map gen-decl (current-attr-list))
   "/* Number of architecture variants.  */\n"
   ; If there is only 1 isa, leave out special handling.  */
   (if (= (length (current-isa-list)) 1)
       "#define MAX_ISAS  1\n"
       "#define MAX_ISAS  ((int) ISA_MAX)\n")
   "#define MAX_MACHS ((int) MACH_MAX)\n\n"
   gen-ifld-decls
   gen-hw-decls
   gen-operand-decls
   gen-insn-decls
   "/* cgen.h uses things we just defined.  */\n"
   "#include \"opcode/cgen.h\"\n\n"
   "extern const struct cgen_ifld @arch@_cgen_ifld_table[];\n\n"
   -gen-attr-table-decls
   -gen-mach-table-decls
   gen-hw-table-decls
   "\n"
   (lambda ()
     (if (opc-file-provided?)
	 (gen-extra-cpu.h (opc-file-path) (current-arch-name))
	 ""))
   "

#endif /* @ARCH@_CPU_H */
"
   )
)

; This file contains the "top level" definitions of the cpu.
; This includes various elements of the description file, expressed in C.
;
; ??? A lot of this file can go in a machine-independent file!  However,
; some simulators don't use the cgen opcodes support so there is currently
; no place to put this file.  To be revisited when we do have such a place.

(define (cgen-desc.c)
  (logit 1 "Generating " (current-arch-name) "-desc.c ...\n")
  (string-write
   (gen-c-copyright "CPU data for @arch@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#include \"sysdep.h\"
#include <stdio.h>
#include <stdarg.h>
#include \"ansidecl.h\"
#include \"bfd.h\"
#include \"symcat.h\"
#include \"@arch@-desc.h\"
#include \"@arch@-opc.h\"
#include \"opintl.h\"
#include \"libiberty.h\"
#include \"xregex.h\"
\n"
   (lambda ()
     (if (opc-file-provided?)
	 (gen-extra-cpu.c (opc-file-path) (current-arch-name))
	 ""))
   gen-attr-table-defns
   -gen-isa-table-defns
   -gen-mach-table-defns
   gen-hw-table-defns
   gen-ifld-defns
   gen-multi-ifield-nodes
   gen-operand-table
   gen-insn-table
   gen-init-fns
   -gen-cpu-open
   )
)
