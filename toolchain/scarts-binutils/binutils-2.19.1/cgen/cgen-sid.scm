; Simulator generator entry point.
; This is invoked to build: desc.h, cpu.h, defs.h, decode.h, decode.cxx,
; semantics.cxx, sem-switch.cxx, model.h, model.cxx
; Copyright (C) 2000, 2003, 2009 Red Hat, Inc.
; This file is part of CGEN.
;
; This is a standalone script, we don't load anything until we parse the
; -s argument (keeps reliance off of environment variables, etc.).

; Load the various support routines.

(define (load-files srcdir)
  (load (string-append srcdir "/read.scm"))
  (load (string-append srcdir "/utils-sim.scm"))
  (load (string-append srcdir "/sid.scm"))
  (load (string-append srcdir "/sid-cpu.scm"))
  (load (string-append srcdir "/sid-model.scm"))
  (load (string-append srcdir "/sid-decode.scm"))
)

(define sim-arguments
  (list
   (list "-H" "file" "generate desc.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-desc.h)))
   (list "-C" "file" "generate cpu.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-cpu.h)))
   (list "-E" "file" "generate defs.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-defs.h)))
   (list "-T" "file" "generate decode.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-decode.h)))
   (list "-D" "file" "generate decode.cxx in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-decode.cxx)))
   (list "-W" "file" "generate write.cxx in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-write.cxx)))
   (list "-S" "file" "generate semantics.cxx in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-semantics.cxx)))
   (list "-X" "file" "generate sem-switch.cxx in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-sem-switch.cxx)))
   (list "-M" "file" "generate model.cxx in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-model.cxx)))
   (list "-N" "file" "generate model.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-model.h)))
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

(define (cgen-sim argv)
  (let ()

    ; Find and set srcdir, then load all Scheme code.
    ; Drop the first argument, it is the script name (i.e. argv[0]).
    (set! srcdir (find-srcdir (cdr argv)))
    (set! %load-path (cons srcdir %load-path))
    (load-files srcdir)

    (display-argv argv)

    (cgen #:argv argv
	  #:app-name "sim"
	  #:arg-spec sim-arguments
	  #:init sim-init!
	  #:finish sim-finish!
	  #:analyze sim-analyze!)
    )
)

(cgen-sim (program-arguments))
