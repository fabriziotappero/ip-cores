; CPU description file generator for the simulator testsuite.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.

; This is invoked to build several .s files and a script to run to
; generate the .d files and .exp file.
; This is invoked to build: tmp-build.sh cpu-cpu.exp

; Load the various support routines
(define (load-files srcdir)
  (load (string-append srcdir "/read.scm"))
  (load (string-append srcdir "/desc.scm"))
  (load (string-append srcdir "/desc-cpu.scm"))
  (load (string-append srcdir "/opcodes.scm"))
  (load (string-append srcdir "/opc-asmdis.scm"))
  (load (string-append srcdir "/opc-ibld.scm"))
  (load (string-append srcdir "/opc-itab.scm"))
  (load (string-append srcdir "/opc-opinst.scm"))
  (load (string-append srcdir "/sim-test.scm"))
)

(define stest-arguments
  (list
   (list "-B" "file" "generate build.sh"
	 #f
	 (lambda (arg) (file-write arg cgen-build.sh)))
   (list "-E" "file" "generate the testsuite .exp"
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

(define (cgen-stest argv)
  (let ()

    ; Find and set srcdir, then load all Scheme code.
    ; Drop the first argument, it is the script name (i.e. argv[0]).
    (set! srcdir (find-srcdir (cdr argv)))
    (set! %load-path (cons srcdir %load-path))
    (load-files srcdir)

    (display-argv argv)

    (cgen #:argv argv
	  #:app-name "sim-test"
	  #:arg-spec stest-arguments
	  #:init sim-test-init!
	  #:finish sim-test-finish!
	  #:analyze sim-test-analyze!)
    )
)

(cgen-stest (program-arguments))
