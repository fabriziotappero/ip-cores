; Top level file for reading and recording .cpu file contents.
; Copyright (C) 2000, 2001, 2006, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; This file [and its subordinates] contain no C code (well, as little as
; possible).  That lives at a layer above us.

; A .cpu file consists of several sections:
;
; - basic definitions (e.g. cpu variants, word size, endianness, etc.)
; - enums (enums are used throughout so by convention there is a special
;   section in which they're defined)
; - attributes
; - instruction fields and formats
; - hardware descriptions (e.g. registers, allowable immediate values)
; - model descriptions (e.g. pipelines, latencies, etc.)
; - instruction operands (mapping of insn fields to associated hardware)
; - instruction definitions
; - macro instruction definitions

; TODO:
; - memory access, layout, etc.
; - floating point quirks
; - ability to describe an ABI
; - anything else that comes along

; Notes:
; - by convention most objects are subclasses of <ident> (having name, comment,
;   and attrs elements and they are the first three elements of any .cpu file
;   entry

; Guidelines:
; - Try to conform to R5RS, try to limit guile-ness.
;   The current code is undoubtedly off in many places.

; Conventions:
; [I want there to be a plethora of conventions and I want them strictly
; adhered to.  ??? There's probably a few violations here and there.
; No big deal - fix them!]
; These conventions are subject to revision.
;
; - procs/vars local to a file are named "-foo"
; - only routines that emit application code begin with "gen-"
; - symbols beginning with "c-" are either variables containing C code
;   or procedures that generate C code, similarily for C++ and "c++-"
; - variables containing C code begin with "c-"
; - only routines that emit an entire file begin with "cgen-"
; - all .cpu file elements shall have -foo-parse and -foo-read procedures
; - global vars containing class definitions shall be named "<class-name>"
; - procs related to a particular class shall be named "class-name-proc-name",
;   class-name may be abbreviated
; - procs that test whether something is an object of a particular class
;   shall be named "class-name?"
; - in keeping with Scheme conventions, predicates shall have a "?" suffix
; - in keeping with Scheme conventions, methods and procedures that modify an
;   argument or have other side effects shall have a "!" suffix,
;   usually these procs return "*UNSPECIFIED*"
; - all -foo-parse,parse-foo procs shall have `context' as the first arg
;   [FIXME: not all such procs have been converted]
; - stay away from non-portable C symbols.

; Variables representing misc. global constants.

; A list of three numbers designating the cgen version: major minor fixlevel.
; The "50" is a generic indicator that we're between 1.1 and 1.2.
(define -CGEN-VERSION '(1 1 50))
(define (cgen-major) (car -CGEN-VERSION))
(define (cgen-minor) (cadr -CGEN-VERSION))
(define (cgen-fixlevel) (caddr -CGEN-VERSION))

; A list of two numbers designating the description language version.
; Note that this is different from -CGEN-VERSION.
; See section "RTL Versions" of the docs.
(define -CGEN-RTL-VERSION '(0 7))
(define (cgen-rtl-version) -CGEN-RTL-VERSION)
(define (cgen-rtl-major) (car -CGEN-RTL-VERSION))
(define (cgen-rtl-minor) (cadr -CGEN-RTL-VERSION))

;; List of supported versions
(define -supported-rtl-versions '((0 7) (0 8)))

(define (-cmd-define-rtl-version major minor)
  (if (not (non-negative-integer? major))
      (parse-error #f "Invalid major version number" major))
  (if (not (non-negative-integer? minor))
      (parse-error #f "Invalid minor version number" minor))

  (let ((new-version (list major minor)))
    (if (not (member new-version -supported-rtl-versions))
	(parse-error #f "Unsupported/invalid rtl version" new-version))
    (logit 1 "Setting RTL version to " major "." minor " ...\n")
    (set! -CGEN-RTL-VERSION new-version))
)

; Which application is in use (UNKNOWN, DESC, OPCODES, SIMULATOR, ???).
; This is mostly for descriptive purposes.
(define APPLICATION 'UNKNOWN)

; Things are organized so that files can be compiled with Hobbit for
; experimentation.  Thus we need one file that loads all the other files.
; This is that file, though it would make sense to move the code in this
; file to another.

; If a routine to initialize compiled-in code is defined, run it.
(if (defined? 'cgen-init-c) (cgen-init-c))

; If this is set to #f, the file is always loaded.
; Don't override any current setting, e.g. from dev.scm.
(if (not (defined? 'CHECK-LOADED?))
    (define CHECK-LOADED? #t))

; Unlink file if we're reloaded (say in an interactive session).
; Dynamic loading is enabled by setting LIBCPU.SO to the pathname of the .so.
(if (and (defined? 'libcpu.so) (dynamic-object? libcpu.so))
    (dynamic-unlink libcpu.so))
(define libcpu.so #f)
(if (and (defined? 'LIBCPU.SO)
	 (file-exists? LIBCPU.SO))
    (set! libcpu.so (dynamic-link LIBCPU.SO))
)

; List of loaded files.

(if (not (defined? '-loaded-file-list))
    (define -loaded-file-list '()))

; Return non-zero if FILE was loaded last time through.

(define (-loaded-file? file)
  (->bool (memq (string->symbol file) -loaded-file-list))
)

; Record FILE as compiled in.

(define (-loaded-file-record! file)
  (let ((file (string->symbol file)))
    (if (not (memq file -loaded-file-list))
	(set! -loaded-file-list (cons file -loaded-file-list))))
)

; Load FILE if SYM is not compiled in.

(define (maybe-load file init-func sym)
  ; Return non-#f if FUNC is present in DYNOBJ.
  (define (dynamic-func? func dynobj)
    (catch #t
	   (lambda () (dynamic-func func dynobj))
	   (lambda args #f))
    )

  (let ((init-func (string-append "init_" (if init-func init-func file))))
    (cond ((and libcpu.so
		(dynamic-func? init-func libcpu.so))
	   (dynamic-call init-func libcpu.so)
	   (display (string-append "Skipping " file ", dynamically loaded.\n")))
	  ((or (not CHECK-LOADED?)
	       (not (defined? sym))
	       (-loaded-file? file))
	   (-loaded-file-record! file)
	   (load file))
	  (else
	   (display (string-append "Skipping " file ", already loaded.\n")))))
)

(maybe-load "pmacros" #f 'define-pmacro)
(maybe-load "cos" #f 'make)
(maybe-load "slib/logical" #f 'logical:logand)
(maybe-load "slib/sort" #f 'sort)
; Used to pretty-print debugging messages.
(maybe-load "slib/pp" #f 'pretty-print)
; Used by pretty-print.
(maybe-load "slib/random" #f 'random)
(maybe-load "slib/genwrite" #f 'generic-write)
(maybe-load "utils" #f 'logit)
(maybe-load "utils-cgen" "utils_cgen" 'obj:name)
(maybe-load "attr" #f '<attribute>)
(maybe-load "enum" #f '<enum>)
(maybe-load "mach" #f '<mach>)
(maybe-load "model" #f '<model>)
(maybe-load "types" #f '<scalar>)
(maybe-load "mode" #f '<mode>)
(maybe-load "ifield" #f '<ifield>)
(maybe-load "iformat" #f '<iformat>)
(maybe-load "hardware" #f '<hardware-base>)
(maybe-load "operand" #f '<operand>)
(maybe-load "insn" #f '<insn>)
(maybe-load "minsn" #f '<macro-insn>)
(maybe-load "decode" #f 'decode-build-table)
(maybe-load "rtl" "rtl" '<rtx-func>)
(maybe-load "rtl-traverse" "rtl_traverse" 'rtx-traverse)
(maybe-load "rtl-xform" "rtx_simplify" 'rtx-simplify)
(maybe-load "rtx-funcs" "rtx_funcs" 'def-rtx-funcs)
(maybe-load "rtl-c" "rtl_c" '<c-expr>)
(maybe-load "semantics" #f 'semantic-compile)
(maybe-load "sem-frags" "sem_frags" 'gen-threaded-engine)
(maybe-load "utils-gen" "utils_gen" 'attr-gen-decl)
(maybe-load "pgmr-tools" "pgmr_tools" 'pgmr-pretty-print-insn-format)

; Reader state data.
; All state regarding the reading of a .cpu file is kept in an object of
; class <reader>.

; Class to record info for each top-level `command' (for lack of a better
; word) in the description file.
; Top level commands are things like define-*.

(define <command>
  (class-make '<command>
	      '(<ident>)
	      '(
		; argument spec to `lambda'
		arg-spec
		; lambda that processes the entry
		handler
		)
	      nil)
)

(define command-arg-spec (elm-make-getter <command> 'arg-spec))
(define command-handler (elm-make-getter <command> 'handler))

; Return help text for COMMAND.

(define (command-help cmd)
  (string-append
   (obj:comment cmd)
   "Arguments: "
   (with-output-to-string (lambda () (write (command-arg-spec cmd))))
   "\n")
)

; A pair of two lists: machs to keep, machs to drop.
; The default is "keep all machs", "drop none".

(define -keep-all-machs '((all)))

; Main reader state class.

(define <reader>
  (class-make '<reader>
	      nil
	      (list
	       ; Selected machs to keep.
	       ; A pair of two lists: the car lists the machs to keep, the cdr
	       ; lists the machs to drop.  Two special entries are `all' and
	       ; `base'.  Both are only valid in the keep list.  `base' is a
	       ; place holder for objects that are common to all machine
	       ; variants in the architecture, it is the default value of the
	       ; MACH attribute.  If `all' is present the drop list is still
	       ; processed.
	       (cons 'keep-mach -keep-all-machs)

	       ; Selected isas to keep or `all'.
	       '(keep-isa . (all))

	       ; Boolean indicating if command tracing is on.
	       (cons 'trace-commands? #f)

	       ; Boolean indicating if pmacro tracing is on.
	       (cons 'trace-pmacros? #f)

	       ; Currently select cpu family, computed from `keep-mach'.
	       ; Some applications don't care, and this is moderately
	       ; expensive to compute so we use delay/force.
	       'current-cpu

	       ; Associative list of file entry commands
	       ; (e.g. define-insn, etc.).
	       ; Each entry is (name . command-object).
	       (cons 'commands nil)

	       ; The current source location.
	       ; This is recorded here by the higher level reader and is
	       ; fetched by commands as necessary.
	       'location
	       )
	      nil)
)

; Accessors.

(define-getters <reader> reader
  (keep-mach keep-isa
   trace-commands? trace-pmacros?
   current-cpu commands location))
(define-setters <reader> reader
  (keep-mach keep-isa
   trace-commands? trace-pmacros?
   current-cpu commands location))

(define (reader-add-command! name comment attrs arg-spec handler)
  (reader-set-commands! CURRENT-READER
			(acons name
			       (make <command> name comment attrs
				     arg-spec handler)
			       (reader-commands CURRENT-READER)))
)

(define (-reader-lookup-command name)
  (assq-ref (reader-commands CURRENT-READER) name)
)

; Reader state for current .cpu file.

(define CURRENT-READER #f)

; Return the current source location in readable form.
; FIXME: Currently unused, keep for reference for awhile.

(define (-readable-current-location)
  (let ((loc (current-reader-location)))
    (if loc
	(location->string loc)
	;; Blech, we don't have a current reader location.  That's odd.
	;; Fall back to the current input port's location.
	(string-append (or (port-filename (current-input-port))
			    "<input>")
			":"
			(number->string (port-line (current-input-port)))
			":")))
)

;;; Signal a parse error while reading a .cpu file.
;;; If CONTEXT is #f, use a default context of the current reader location
;;; and an empty prefix.
;;; If MAYBE-HELP-TEXT is specified, elide the last trailing \n.
;;; Multiple lines of help text need embedded newlines, and should be no longer
;;; than 79 characters.

(define (parse-error context message expr . maybe-help-text)
  (if (not context)
      (set! context (make <context> (current-reader-location) #f)))

  (let* ((loc (or (context-location context) (unspecified-location)))
	 (top-sloc (location-top loc))
	 (intro "While reading description")
	 (prefix (or (context-prefix context) "Error"))
	 (text (string-append prefix ": " message)))

    (error
     (simple-format
      #f
      "\n~A:\n@ ~A:\n\n~A: ~A: ~S~A"
      intro
      (location->string loc)
      (single-location->simple-string top-sloc)
      text
      expr
      (if (null? maybe-help-text)
	  ""
	  (string-append "\n\n" (car maybe-help-text))))))
)

; Return the current source location.
;
; If CURRENT-READER is uninitialized, return "unspecified" location.
; This is done so that things like define-pmacro work in interactive mode.

(define (current-reader-location)
  (if CURRENT-READER
      (reader-location CURRENT-READER)
      (unspecified-location))
)

; Process a macro-expanded entry.

(define (-reader-process-expanded-1! entry)
  (let ((location (location-property entry)))

    ;; Set the current source location for better diagnostics.
    ;; Access with current-reader-location.
    (reader-set-location! CURRENT-READER location)

    (if (reader-trace-commands? CURRENT-READER)
	(message "Processing command:\n  @ "
		 (if location (location->string location) "location unknown")
		 "\n"
		 (with-output-to-string (lambda () (pretty-print entry)))))

    (let ((command (-reader-lookup-command (car entry)))
	  (context (make-current-context #f)))

      (if command

	  (let* ((handler (command-handler command))
		 (arg-spec (command-arg-spec command))
		 (num-args (num-args arg-spec)))
	    (if (cdr num-args)
		;; Variable number of trailing arguments.
		(if (< (length (cdr entry)) (car num-args))
		    (parse-error context
				 (string-append "Incorrect number of arguments to "
						(symbol->string (car entry))
						", expecting at least "
						(number->string (car num-args)))
				 entry
				 (command-help command))
		    (apply handler (cdr entry)))
		;; Fixed number of arguments.
		(if (!= (length (cdr entry)) (car num-args))
		    (parse-error context
				 (string-append "Incorrect number of arguments to "
						(symbol->string (car entry))
						", expecting "
						(number->string (car num-args)))
				 entry
				 (command-help command))
		    (apply handler (cdr entry)))))

	  (parse-error context "unknown entry type" entry))))

  *UNSPECIFIED*
)

;; Process 1 or more macro-expanded entries.
;; ENTRY is expected to have a location-property object property.

;; NOTE: This is "public" so the .eval pmacro can use it.
;; This is also used by -cmd-if.

(define (reader-process-expanded! entry)
  ;; () is used to indicate a no-op
  (cond ((null? entry)
	 #f) ;; nothing to do
	;; `begin' is used to group a collection of entries into one,
	;; since pmacro can only return one expression (borrowed from
	;; Scheme of course).
	;; Recurse in case there are nested begins.
	((eq? (car entry) 'begin)
	 (for-each reader-process-expanded!
		   (cdr entry)))
	(else
	 (-reader-process-expanded-1! entry)))

  *UNSPECIFIED*
)

; Process file entry ENTRY.
; LOC is a <location> object for ENTRY.

(define (-reader-process! entry loc)
  (if (not (form? entry))
      (parse-error loc "improperly formed entry" entry))

  ; First do macro expansion, but not if define-pmacro of course.
  ; ??? Singling out define-pmacro this way seems a bit odd.  The way to look
  ; at it, I guess, is to think of define-pmacro as (currently) the only
  ; "syntactic" command (it doesn't pre-evaluate its arguments).
  (let ((expansion (if (eq? (car entry) 'define-pmacro)
		       (begin (location-property-set! entry loc) entry)
		       (if (reader-trace-pmacros? CURRENT-READER)
			   (pmacro-trace entry loc)
			   (pmacro-expand entry loc)))))
    (reader-process-expanded! expansion))

  *UNSPECIFIED*
)

; Read in and process FILE.
;
; It would be nice to get the line number of the beginning of the object,
; but that's extra work, so for now we do the simple thing and use
; port-line after we've read an entry.

(define (reader-read-file! file)
  (let ((readit (lambda ()
		  (let loop ((entry (read)))
		    (if (eof-object? entry)
			#t ; done
			(begin
			  ;; ??? The location we pass here isn't ideal.
			  ;; Ideally we'd pass the start location of the
			  ;; expression, instead we currently pass the end
			  ;; location (it's easier).
			  ;; ??? Use source-properties of entry, and only if
			  ;; not present fall back on current-input-location.
			  (-reader-process! entry (current-input-location #t))
			  (loop (read)))))))
	)

    (with-input-from-file file readit))

  *UNSPECIFIED*
)

; Cpu data is recorded in an object of class <arch>.
; This is necessary as we need to allow recording of multiple cpu descriptions
; simultaneously.
; Class <arch> is defined in mach.scm.

; Global containing all data of the currently selected architecture.

(define CURRENT-ARCH #f)

; `keep-mach' processing.

; Return the currently selected cpu family.
; If a specific cpu family has been selected, each machine that is kept must
; be in that cpu family [so there's no ambiguity in the result].
; This is a moderately expensive computation so use delay/force.

(define (current-cpu) (force (reader-current-cpu CURRENT-READER)))

; Return a boolean indicating if CPU-NAME is to be kept.
; ??? Currently this is always true.  Note that this doesn't necessarily apply
; to machs in CPU-NAME.

(define (keep-cpu? cpu-name) #t)

; Cover proc to set `keep-mach'.
; MACH-NAME-LIST is a comma separated string of machines to keep and drop
; (if prefixed with !).

(define (-keep-mach-set! mach-name-list)
  (let* ((mach-name-list (string-cut mach-name-list #\,))
	 (keep (find (lambda (name) (not (char=? (string-ref name 0) #\!)))
		     mach-name-list))
	 (drop (map (lambda (name) (string->symbol (string-drop 1 name)))
		    (find (lambda (name) (char=? (string-ref name 0) #\!))
			  mach-name-list))))
    (reader-set-keep-mach! CURRENT-READER
			   (cons (map string->symbol keep)
				 (map string->symbol drop)))
    ; Reset current-cpu.
    (reader-set-current-cpu!
     CURRENT-READER
     (delay (let ((selected-machs (find (lambda (mach)
					  (keep-mach? (list (obj:name mach))))
					(current-mach-list))))
	      (if (= (length selected-machs) 0)
		  (error "no machs selected"))
	      (if (not (all-true? (map (lambda (mach)
					 (eq? (obj:name (mach-cpu mach))
					      (obj:name (mach-cpu (car selected-machs)))))
				       selected-machs)))
		  (error "machs from different cpu families selected"))
	      (mach-cpu (car selected-machs)))))

    *UNSPECIFIED*)
)

; Validate the user-provided keep-mach list against the list of machs
; specified in the .cpu file (in define-arch).

(define (keep-mach-validate!)
  (let ((mach-names (cons 'all (current-arch-mach-name-list)))
	(keep-mach (reader-keep-mach CURRENT-READER)))
    (for-each (lambda (mach)
		(if (not (memq mach mach-names))
		    (error "unknown mach to keep:" mach)))
	      (car keep-mach))
    (for-each (lambda (mach)
		(if (not (memq mach mach-names))
		    (error "unknown mach to drop:" mach)))
	      (cdr keep-mach))
    )
  *UNSPECIFIED*
)

; Return #t if a machine in MACH-LIST, a list of symbols, is to be kept.
; If any machine in MACH-LIST is to be kept, the result is #t.
; If MACH-LIST is the empty list (no particular mach specified, thus the base
; mach), the result is #t.

(define (keep-mach? mach-list)
  (if (null? mach-list)
      #t
      (let* ((keep-mach (reader-keep-mach CURRENT-READER))
	     (keep (cons 'base (car keep-mach)))
	     (drop (cdr keep-mach))
	     (keep? (map (lambda (m) (memq m keep)) mach-list))
	     (all? (memq 'all keep))
	     (drop? (map (lambda (m) (memq m drop)) mach-list)))
	(any-true? (map (lambda (k d)
			  ; keep if K(ept) or ALL? and not D(ropped)
			  (->bool (and (or k all?) (not d))))
			keep? drop?))))
)

; Return non-#f if the object containing ATLIST is to be kept.
; OBJ is the container object or #f if there is none.
; The object is kept if its attribute list specifies a `MACH' that is
; kept (and not dropped) or does not have the `MACH' attribute (which means
; it has the default value which means it's for use with all machines).

(define (keep-mach-atlist? atlist obj)
  ; The MACH attribute is not created until the .cpu file is read in which
  ; is too late for us [we will get called for builtin objects].
  ; Thus we peek inside the attribute list directly.
  ; ??? Maybe postpone creation of builtins until after define-arch?
  (let ((machs (atlist-attr-value-no-default atlist 'MACH obj)))
    (if (null? machs)
	#t
	(keep-mach? (bitset-attr->list machs))))
)

; Return a boolean indicating if the object containing ATLIST is to be kept.
; OBJ is the container object or #f if there is none.
; The object is kept if both its isa and its mach are kept.

(define (keep-atlist? atlist obj)
  (and (keep-mach-atlist? atlist obj)
       (keep-isa-atlist? atlist obj))
)

; Return a boolean indicating if multiple cpu families are being kept.

(define (keep-multiple?)
  (let ((selected-machs (find (lambda (mach)
				(keep-mach? (list (obj:name mach))))
			      (current-mach-list))))
    (not (all-true? (map (lambda (mach)
			   (eq? (obj:name (mach-cpu mach))
				(obj:name (mach-cpu (car selected-machs)))))
			 selected-machs))))
)

; Return a boolean indicating if everything is kept.

(define (keep-all?)
  (equal? (reader-keep-mach CURRENT-READER) -keep-all-machs)
)

; Ensure all cpu families were kept, necessary for generating files that
; encompass the entire architecture.

(define (assert-keep-all)
  (if (not (keep-all?))
      (error "no can do, all cpu families not selected"))
  *UNSPECIFIED*
)

; Ensure exactly one cpu family was kept, necessary for generating files that
; are specific to one cpu family.

(define (assert-keep-one)
  (if (keep-multiple?)
      (error "no can do, multiple cpu families selected"))
  *UNSPECIFIED*
)

; `keep-isa' processing.

; Cover proc to set `keep-isa'.
; ISA-NAME-LIST is a comma separated string of isas to keep.
; ??? We don't support the !drop notation of keep-mach processing.
; Perhaps we should as otherwise there are two different styles the user
; has to remember.  On the other hand, !drop support is moderately complicated,
; and it can be added in an upward compatible manner later.

(define (-keep-isa-set! isa-name-list)
  (let ((isa-name-list (map string->symbol (string-cut isa-name-list #\,))))
    (reader-set-keep-isa! CURRENT-READER isa-name-list)
    )
  *UNSPECIFIED*
)

; Validate the user-provided keep-isa list against the list of isas
; specified in the .cpu file (in define-arch).

(define (keep-isa-validate!)
  (let ((isa-names (cons 'all (current-arch-isa-name-list)))
	(keep-isa (reader-keep-isa CURRENT-READER)))
    (for-each (lambda (isa)
		(if (not (memq isa isa-names))
		    (error "unknown isa to keep:" isa)))
	      keep-isa)
    )
  *UNSPECIFIED*
)

; Return currently selected isa (there must be exactly one).

(define (current-isa)
  (let ((keep-isa (reader-keep-isa CURRENT-READER)))
    (if (equal? keep-isa '(all))
	(let ((isas (current-isa-list)))
	  (if (= (length isas) 1)
	      (car isas)
	      (error "multiple isas selected" keep-isa)))
	(if (= (length keep-isa) 1)
	    (current-isa-lookup (car keep-isa))
	    (error "multiple isas selected" keep-isa))))
)

; Return #t if an isa in ISA-LIST, a list of symbols, is to be kept.
; If any isa in ISA-LIST is to be kept, the result is #t.
; If ISA-LIST is the empty list (no particular isa specified) use the default
; isa.

(define (keep-isa? isa-list)
  (if (null? isa-list)
      (set! isa-list (list (car (current-arch-isa-name-list)))))
  (let* ((keep (reader-keep-isa CURRENT-READER))
	 (keep? (map (lambda (i)
		       (or (memq i keep)
			   (memq 'all keep)))
		     isa-list)))
    (any-true? keep?))
)

; Return #t if the object containing ATLIST is to be kept.
; OBJ is the container object or #f if there is none.
; The object is kept if its attribute list specifies an `ISA' that is
; kept or does not have the `ISA' attribute (which means it has the default
; value) and the default isa is being kept.

(define (keep-isa-atlist? atlist obj)
  (let ((isas (atlist-attr-value atlist 'ISA obj)))
    (keep-isa? (bitset-attr->list isas)))
)

; Return non-#f if object OBJ is to be kept, according to its ISA attribute.

(define (keep-isa-obj? obj)
  (keep-isa-atlist? (obj-atlist obj) obj)
)

; Return a boolean indicating if multiple isas are being kept.

(define (keep-isa-multiple?)
  (let ((keep (reader-keep-isa CURRENT-READER)))
    (or (> (length keep) 1)
	(and (memq 'all keep)
	     (> (length (current-arch-isa-name-list)) 1))))
)

; Return list of isa names currently being kept.

(define (current-keep-isa-name-list)
  (reader-keep-isa CURRENT-READER)
)

;; Tracing support.
;; This is akin to the "logit" support, but is for specific things that
;; can be named (whereas logit support is based on a simple integer verbosity
;; level).

;;; Enable the specified tracing.
;;; TRACE-OPTIONS is a comma-separated list of things to trace.
;;;
;;; Currently supported tracing:
;;; commands - trace invocation of description file commands (e.g. define-insn)
;;; pmacros  - trace pmacro expansion
;;; all      - trace everything
;;;
;;; [If we later need to support disabling some tracing, one way is to
;;; recognize an "-" in front of an option.]

(define (-set-trace-options! trace-options)
  (let ((all (list "commands" "pmacros"))
	(requests (string-cut trace-options #\,)))
    (if (member "all" requests)
	(append! requests all))
    (for-each (lambda (item)
	      (cond ((string=? "commands" item)
		     (reader-set-trace-commands?! CURRENT-READER #t))
		    ((string=? "pmacros" item)
		     (reader-set-trace-pmacros?! CURRENT-READER #t))
		    ((string=? "all" item)
		     #t) ;; handled above
		    (else
		     (cgen-usage 'unknown (string-append "-t " item)
				 common-arguments))))
	      requests))

  *UNSPECIFIED*
)

; If #f, treat reserved fields as operands and extract them with the insn.
; Code can then be emitted in the extraction routines to validate them.
; If #t, treat reserved fields as part of the opcode.
; This complicates the decoding process as these fields have to be
; checked too.
; ??? Unimplemented.

(define option:reserved-as-opcode? #f)

; Process options passed in on the command line.
; OPTIONS is a space separated string of name=value values.
; Each application is required to provide: option-init!, option-set!.

(define (set-cgen-options! options)
  (option-init!)
  (for-each (lambda (opt)
	      (if (null? opt)
		  #t ; ignore extraneous spaces
		  (let ((name (string->symbol (car opt)))
			(value (cdr opt)))
		    (logit 1 "Setting option `" name "' to \""
			   (apply string-append value) "\".\n")
		    (option-set! name value))))
	    (map (lambda (opt) (string-cut opt #\=))
		 (string-cut options #\space)))
)

; Application specific object creation support.
;
; Each entry in the .cpu file has a basic container class.
; Each application adds functionality by subclassing the container
; and registering with set-for-new! the proper class to create.
; ??? Not sure this is the best way to handle this, but it does keep the
; complexity down while not requiring as dynamic a language as I had before.
; ??? Class local variables would provide a more efficient way to do this.
; Assuming one wants to continue on this route.

(define -cpu-new-class-list nil)

(define (set-for-new! parent child)
  (set! -cpu-new-class-list (acons parent child -cpu-new-class-list))
)

; Lookup the class registered with set-for-new!
; If none registered, return PARENT.

(define (lookup-for-new parent)
  (let ((child (assq-ref -cpu-new-class-list parent)))
    (if child
	child
	parent))
)

; .cpu file loader support

;; Initialize a new <reader> object.
;; This doesn't add cgen-specific commands, leaving each element (ifield,
;; hardware, etc.) to add their own.
;; The "result" is stored in global CURRENT-READER.

(define (-init-reader!)
  (set! CURRENT-READER (new <reader>))

  (reader-add-command! 'define-rtl-version
		       "Specify the RTL version being used.\n"
		       nil '(major minor) -cmd-define-rtl-version)

  (reader-add-command! 'include
		       "Include a file.\n"
		       nil '(file) -cmd-include)
  (reader-add-command! 'if
		       "(if test then . else)\n"
		       nil '(test then . else) -cmd-if)

  ; Rather than add cgen-internal specific stuff to pmacros.scm, we create
  ; the pmacro commands here.
  (pmacros-init!)
  (reader-add-command! 'define-pmacro
		       "\
Define a preprocessor-style macro.
"
		       nil '(name arg1 . arg-rest) define-pmacro)

  *UNSPECIFIED*
)

; Prepare to parse a .cpu file.
; This initializes the application independent tables.
; KEEP-MACH specifies what machs to keep.
; KEEP-ISA specifies what isas to keep.
; OPTIONS is a list of options to control code generation.
; The values are application dependent.

(define (-init-parse-cpu! keep-mach keep-isa options)
  (set! -cpu-new-class-list nil)

  (set! CURRENT-ARCH (new <arch>))
  (-keep-mach-set! keep-mach)
  (-keep-isa-set! keep-isa)
  (set-cgen-options! options)

  ; The order here is important.
  (arch-init!) ; Must be done first.
  (enum-init!)
  (attr-init!)
  (types-init!)
  (mach-init!)
  (model-init!)
  (mode-init!)
  (ifield-init!)
  (hardware-init!)
  (operand-init!)
  (insn-init!)
  (minsn-init!)
  (rtl-init!)
  (rtl-c-init!)
  (utils-init!)

  *UNSPECIFIED*
)

; Install any builtin objects.
; This is deferred until define-arch is read.
; One reason is that attributes MACH and ISA don't exist until then.

(define (reader-install-builtin!)
  ; The order here is important.
  (attr-builtin!)
  (mode-builtin!)
  (ifield-builtin!)
  (hardware-builtin!)
  (operand-builtin!)
  ; This is mainly for the insn attributes.
  (insn-builtin!)
  (rtl-builtin!)
  *UNSPECIFIED*
)

; Do anything necessary for the application independent parts after parsing
; a .cpu file.
; The lists get cons'd in reverse order.  One thing this does is change them
; back to file order, it makes things easier for the human viewer.

(define (-finish-parse-cpu!)
  ; The order here is generally the reverse of init-parse-cpu!.
  (rtl-finish!)
  (minsn-finish!)
  (insn-finish!)
  (operand-finish!)
  (hardware-finish!)
  (ifield-finish!)
  (mode-finish!)
  (model-finish!)
  (mach-finish!)
  (types-finish!)
  (attr-finish!)
  (enum-finish!)
  (arch-finish!) ; Must be done last.

  *UNSPECIFIED*
)

; Perform a global error checking pass after the .cpu file has been read in.

(define (-global-error-checks)
  ; ??? None yet.
  ; TODO:
  ; - all hardware elements with same name must have same rank and
  ;   compatible modes (which for now means same float mode or all int modes)
  #f
)

; .cpu file include mechanism

(define (-cmd-include file)
  (logit 1 "Including file " (string-append arch-path "/" file) " ...\n")
  (reader-read-file! (string-append arch-path "/" file))
  (logit 2 "Resuming previous file ...\n")
)

; Version of `if' invokable at the top level of a description file.
; This is a work-in-progress.  Its presence in the description file is ok,
; but the implementation will need to evolve.

(define (-cmd-if test then . else)
  (if (> (length else) 1)
      (parse-error #f
		   "wrong number of arguments to `if'"
		   (cons 'if (cons test (cons then else)))))
  ; ??? rtx-eval test
  (if (or (not (pair? test))
	  (not (memq (car test) '(keep-isa? keep-mach? application-is?))))
      (parse-error #f
		   "only (if (keep-mach?|keep-isa?|application-is? ...) ...) are currently supported"
		   test))
  (case (car test)
    ((keep-isa?)
     (if (keep-isa? (cadr test))
	 (reader-process-expanded! then)
	 (if (null? else)
	     #f
	     (reader-process-expanded! (car else)))))
    ((keep-mach?)
     (if (keep-mach? (cadr test))
	 (reader-process-expanded! then)
	 (if (null? else)
	     #f
	     (reader-process-expanded! (car else)))))
    ((application-is?)
     (if (eq? APPLICATION (cadr test))
	 (reader-process-expanded! then)
	 (if (null? else)
	     #f
	     (reader-process-expanded! (car else))))))
)

; Top level routine for loading .cpu files.
; FILE is the name of the .cpu file to load.
; KEEP-MACH is a string of comma separated machines to keep
; (or not keep if prefixed with !).
; KEEP-ISA is a string of comma separated isas to keep.
; OPTIONS is the OPTIONS argument to -init-parse-cpu!.
; TRACE-OPTIONS is a random list of things to trace.
; APP-INITER! is an application specific zero argument proc (thunk)
; to call after -init-parse-cpu!
; APP-FINISHER! is an application specific zero argument proc to call after
; -finish-parse-cpu!
; ANALYZER! is a zero argument proc to call after loading the .cpu file.
; It is expected to set up various tables and things useful for the application
; in question.
;
; This function isn't local because it's used by dev.scm.

(define (cpu-load file keep-mach keep-isa options trace-options
		  app-initer! app-finisher! analyzer!)
  (-init-reader!)
  (-init-parse-cpu! keep-mach keep-isa options)
  (-set-trace-options! trace-options)
  (app-initer!)
  (logit 1 "Loading cpu description " file " ...\n")
  (set! arch-path (dirname file))
  (reader-read-file! file)
  (logit 2 "Processing cpu description " file " ...\n")
  (-finish-parse-cpu!)
  (app-finisher!)
  (-global-error-checks)
  (analyzer!)
  *UNSPECIFIED*
)

; Argument parsing utilities.

; Generate a usage message.
; ERRTYPE is one of 'help, 'unknown, 'missing.
; OPTION is the option that had the error or "" if ERRTYPE is 'help.

(define (cgen-usage errtype option arguments)
  (let ((cep (current-error-port)))
    (case errtype
      ((help) #f)
      ((unknown) (display (string-append "Unknown option: " option "\n") cep))
      ((missing) (display (string-append "Missing argument: " option "\n") cep))
      (else (display "Unknown error!\n" cep)))
    (display "Usage: cgen arguments ...\n" cep)
    (for-each (lambda (arg)
		(display (string-append
			  (let ((arg-str (string-append (car arg) " "
							(or (cadr arg) ""))))
			    (if (< (string-length arg-str) 16)
				(string-take 16 arg-str)
				arg-str))
			  "  - " (caddr arg)
			  (apply string-append
				 (map (lambda (text)
					(string-append "\n"
						       (string-take 20 "")
						       text))
				      (cdddr arg)))
			  "\n")
			 cep))
	      arguments)
    (display "...\n" cep)
    (case errtype
      ((help) (quit 0))
      ((unknown missing) (quit 1))
      (else (quit 2))))
)

; Poor man's getopt.
; [We don't know where to find the real one until we've parsed the args,
; and this isn't something we need to get too fancy about anyways.]
; The result is always ((a . b) . c).
; If the argument is valid, the result is ((opt-spec . arg) . remaining-argv),
; or (('unknown . option) . remaining-argv) if `option' isn't recognized,
; or (('missing . option) . remaining argv) if `option' is missing a required
; argument,
; or ((#f . #f) . #f) if there are no more arguments.
; OPT-SPEC is a list of option specs.
; Each element is an alist of at least 3 elements: option argument help-text.
; `option' is a string or symbol naming the option.  e.g. -a, --help, "-i".
; symbols are supported for backward compatibility, -i is a complex number.
; `argument' is a string naming the argument or #f if the option takes no
; arguments.
; `help-text' is a string that is printed with the usage information.
; Elements beyond `help-text' are ignored.

(define (-getopt argv opt-spec)
  (if (null? argv)
      (cons (cons #f #f) #f)
      (let ((opt (assoc (car argv) opt-spec)))
	(cond ((not opt) (cons (cons 'unknown (car argv)) (cdr argv)))
	      ((and (cadr opt) (null? (cdr argv)))
	       (cons (cons 'missing (car argv)) (cdr argv)))
	      ((cadr opt) (cons (cons opt (cadr argv)) (cddr argv)))
	      (else ; must be option that doesn't take an argument
	       (cons (cons opt #f) (cdr argv))))))
)

; Return (cadr args) or print a pretty error message if not possible.

(define (option-arg args)
  (if (and (pair? args) (pair? (cdr args)))
      (cadr args)
      (parse-error (make-prefix-context "option processing")
		   "missing argument to"
		   (car args)))
)

; List of common arguments.
;
; ??? Another useful arg would be one that says "do file generation with
; arguments specified up til now, then continue with next batch of args".

(define common-arguments
  '(("-a" "arch-file" "specify path of .cpu file to load")
    ("-b" #f          "use debugging evaluator, for backtraces")
    ("-d" #f          "start interactive debugging session")
    ("-f" "flags"     "specify a set of flags to control code generation")
    ("-h" #f          "print usage information")
    ("--help" #f      "print usage information")
    ("-i" "isa-list"  "specify isa-list entries to keep")
    ("-m" "mach-list" "specify mach-list entries to keep")
    ("-s" "srcdir"    "set srcdir")
    ("-t" "trace-options" "specify list of things to trace"
                       "Options:"
                       "commands - trace cgen commands (e.g. define-insn)"
                       "pmacros  - trace pmacro expansion"
		       "all      - trace everything")
    ("-v" #f          "increment verbosity level")
    ("--version" #f   "print version info")
    )
)

; Default place to look.
; This gets overridden to point to the directory of the loaded .cpu file.
; ??? Ideally this would be local to this file.

(define arch-path (string-append srcdir "/cpu"))

; Accessors for application option specs

(define (opt-get-first-pass opt)
  (or (list-ref opt 3) (lambda args #f)))
(define (opt-get-second-pass opt)
  (or (list-ref opt 4) (lambda args #f)))

; Parse options and call generators.
; ARGS is a #:keyword delimited list of arguments.
; #:app-name name
; #:arg-spec optspec ; FIXME: rename to #:opt-spec
; #:init init-routine
; #:finish finish-routine
; #:analyze analysis-routine
; #:argv command-line-arguments
;
; ARGSPEC is a list of (option option-arg comment option-handler) elements.
; OPTION-HANDLER is either (lambda () ...) or (lambda (arg) ...) and
; processes the option.

(define -cgen
  (lambda args
    (let ((app-name "unknown")
	  (opt-spec nil)
	  (app-init! (lambda () #f))
	  (app-finish! (lambda () #f))
	  (app-analyze! (lambda () #f))
	  (argv (list "cgen"))
	  )
      (let loop ((args args))
	(if (not (null? args))
	    (case (car args)
	      ((#:app-name) (begin
			      (set! app-name (option-arg args))
			      (loop (cddr args))))
	      ((#:arg-spec) (begin
			      (set! opt-spec (option-arg args))
			      (loop (cddr args))))
	      ((#:init) (begin
			  (set! app-init! (option-arg args))
			  (loop (cddr args))))
	      ((#:finish) (begin
			    (set! app-finish! (option-arg args))
			    (loop (cddr args))))
	      ((#:analyze) (begin
			     (set! app-analyze! (option-arg args))
			     (loop (cddr args))))
	      ((#:argv) (begin
			  (set! argv (option-arg args))
			  (loop (cddr args))))
	      (else (error "cgen: unknown argument" (car args))))))

      ; ARGS has been processed, now we can process ARGV.

      (let (
	    (opt-spec (append common-arguments opt-spec))
	    (app-args nil)    ; application's args are queued here
	    (repl? #f)
	    (arch-file #f)
	    (keep-mach "all") ; default is all machs
	    (keep-isa "all")  ; default is all isas
	    (flags "")
	    (moreopts? #t)
	    (debugging #f)    ; default is off, for speed
	    (trace-options "")
	    (cep (current-error-port))
	    (str=? string=?)
	    )

	(let loop ((argv (cdr argv)))
	  (let* ((new-argv (-getopt argv opt-spec))
		 (opt (caar new-argv))
		 (arg (cdar new-argv)))
	    (case opt
	      ((#f) (set! moreopts? #f))
	      ((unknown) (cgen-usage 'unknown arg opt-spec))
	      ((missing) (cgen-usage 'missing arg opt-spec))
	      (else
	       (cond ((str=? "-a" (car opt))
		      (set! arch-file arg)
		      )
		     ((str=? "-b" (car opt))
		      (set! debugging #t)
		      )
		     ((str=? "-d" (car opt))
		      (let ((prompt (string-append "cgen-" app-name "> ")))
			(set! repl? #t)
			(set-repl-prompt! prompt)
			(if (feature? 'readline)
			    (set-readline-prompt! prompt))
			))
		     ((str=? "-f" (car opt))
		      (set! flags arg)
		      )
		     ((str=? "-h" (car opt))
		      (cgen-usage 'help "" opt-spec)
		      )
		     ((str=? "--help" (car opt))
		      (cgen-usage 'help "" opt-spec)
		      )
		     ((str=? "-i" (car opt))
		      (set! keep-isa arg)
		      )
		     ((str=? "-m" (car opt))
		      (set! keep-mach arg)
		      )
		     ((str=? "-s" (car opt))
		      #f ; ignore, already processed by caller
		      )
		     ((str=? "-t" (car opt))
		      (set! trace-options arg)
		      )
		     ((str=? "-v" (car opt))
		      (verbose-inc!)
		      )
		     ((str=? "--version" (car opt))
		      (begin
			(display "Cpu tools GENerator version ")
			(display (cgen-major))
			(display ".")
			(display (cgen-minor))
			(display ".")
			(display (cgen-fixlevel))
			(newline)
			(display "RTL version ")
			(display (cgen-rtl-major))
			(display ".")
			(display (cgen-rtl-minor))
			(newline)
			(quit 0)
			))
		     ; Else this is an application specific option.
		     (else
		      ; Record it for later processing.  Note that they're
		      ; recorded in reverse order (easier).  This is undone
		      ; later.
		      (set! app-args (acons opt arg app-args)))
		     )))
	    (if moreopts? (loop (cdr new-argv)))
	    )
	  ) ; end of loop

	; All arguments have been parsed.

	(cgen-call-with-debugging
	 debugging
	 (lambda ()

	   (if (not arch-file)
	       (error "-a option missing, no architecture specified"))

	   (if repl?
	       (debug-repl nil))

	   (cpu-load arch-file
		     keep-mach keep-isa flags trace-options
		     app-init! app-finish! app-analyze!)

	   ;; Start another repl loop if -d.
	   ;; Awkward.  Both places are useful, though this is more useful.
	   (if repl?
	       (debug-repl nil))

	   ;; Done with processing the arguments.  Application arguments
	   ;; are processed in two passes.  This is because the app may
	   ;; have arguments that specify things that affect file
	   ;; generation (e.g. to specify another input file) and we
	   ;; don't want to require an ordering of the options.
	   (for-each (lambda (opt-arg)
		       (let ((opt (car opt-arg))
			     (arg (cdr opt-arg)))
			 (if (cadr opt)
			     ((opt-get-first-pass opt) arg)
			     ((opt-get-first-pass opt)))))
		     (reverse app-args))

	   (for-each (lambda (opt-arg)
		       (let ((opt (car opt-arg))
			     (arg (cdr opt-arg)))
			 (if (cadr opt)
			     ((opt-get-second-pass opt) arg)
			     ((opt-get-second-pass opt)))))
		     (reverse app-args))))
	)
      )
    #f) ; end of lambda
)

; Main entry point called by application file generators.

(define cgen
  (lambda args
    (cgen-debugging-stack-start -cgen args))
)
