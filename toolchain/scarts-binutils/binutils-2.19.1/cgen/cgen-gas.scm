; CPU description file generator for the GAS testsuite.
; Copyright (C) 2000, 2001, 2009 Red Hat, Inc.
; This file is part of CGEN.

; This is invoked to build several .s files and a "build script",
; which generates the .d files and .exp DejaGNU test case.

; Load the various support routines.

(define (load-files srcdir)
  (load (string-append srcdir "/read.scm"))
  (load (string-append srcdir "/desc.scm"))
  (load (string-append srcdir "/desc-cpu.scm"))
  (load (string-append srcdir "/opcodes.scm"))
  (load (string-append srcdir "/opc-asmdis.scm"))
  (load (string-append srcdir "/opc-ibld.scm"))
  (load (string-append srcdir "/opc-itab.scm"))
  (load (string-append srcdir "/opc-opinst.scm"))
  (load (string-append srcdir "/gas-test.scm"))
)

(define gas-arguments
  (list
   (list "-B" "file" "generate build script in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-build.sh)))
   (list "-E" "file" "generate allinsn.exp in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-allinsn.exp)))
   )
)

; Kept global so it's available to the other .scm files.
(define srcdir ".")

; Scan argv for -s srcdir.
; We can't process any other args until we find the cgen source dir.
; The result is srcdir.
; We assume "-s" isn't the argument to another option.  Unwise, yes.
; Alternatives are to require it to be the first argument or at least preceed
; any option with a "-s" argument, or to put knowledge of the common argument
; set and common argument parsing code in every top level file.

(define (find-srcdir argv)
  (let loop ((argv argv))
    (if (null? argv)
	(error "`-s srcdir' not present, can't load cgen"))
    (if (string=? "-s" (car argv))
	(begin
	  (if (null? (cdr argv))
	      (error "missing srcdir arg to `-s'"))
	  (cadr argv))
	(loop (cdr argv))))	
)

; Main routine, parses options and calls generators.

(define (cgen-gas argv)
  (let ()

    ; Find and set srcdir, then load all Scheme code.
    ; Drop the first argument, it is the script name (i.e. argv[0]).
    (set! srcdir (find-srcdir (cdr argv)))
    (set! %load-path (cons srcdir %load-path))
    (load-files srcdir)

    (display-argv argv)

    (cgen #:argv argv
	  #:app-name "gas-test"
	  #:arg-spec gas-arguments
	  #:init gas-test-init!
	  #:finish gas-test-finish!
	  #:analyze gas-test-analyze!)
    )
)

(cgen-gas (program-arguments))
