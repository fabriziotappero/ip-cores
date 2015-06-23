; GCC "intrinsics" file entry point.
;
; This is invoked to build support files for registering intrinsic
; functions within gcc. this code has a fair bit of target-specific
; code in it. it's not a general-purpose module yet.
;
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
;
; This is a standalone script, we don't load anything until we parse the
; -s argument (keeps reliance off of environment variables, etc.).

; Load the various support routines.

(define (load-files srcdir)
  ; Fix up Scheme to be what we use (guile is always in flux).
  (primitive-load-path (string-append srcdir "/guile.scm"))

  (load (string-append srcdir "/read.scm"))
  (load (string-append srcdir "/intrinsics.scm"))
)

(define intrinsics-isas '())

(define intrinsics-arguments
  (list
   (list "-K" "isa" "keep isa <isa> in intrinsics" #f
	 (lambda (args)
	   (for-each
	    (lambda (arg) (set! intrinsics-isas (cons (string->symbol arg) intrinsics-isas)))
	    (string-cut args #\,))))
   (list "-M" "file" "generate insns.md in <file>" #f
	 (lambda (arg) (file-write arg insns.md)))
   (list "-N" "file" "generate intrinsics.h in <file>" #f
	 (lambda (arg) (file-write arg intrinsics.h)))
   (list "-P" "file" "generate intrinsic-protos.h in <file>" #f
	 (lambda (arg) (file-write arg intrinsic-protos.h)))
   (list "-T" "file" "generate intrinsic-testsuite.c in <file>" #f
	 (lambda (arg) (file-write arg intrinsic-testsuite.c)))))

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

(define (cgen-intrinsics argv)
  (let ()

    ; Find and set srcdir, then load all Scheme code.
    ; Drop the first argument, it is the script name (i.e. argv[0]).
    (set! srcdir (find-srcdir (cdr argv)))
    (set! %load-path (cons srcdir %load-path))
    (load-files srcdir)

    (display-argv argv)

    (cgen #:argv argv
	  #:app-name "intrinsics"
	  #:arg-spec intrinsics-arguments
	  #:analyze intrinsics-analyze!)
    )
)

(cgen-intrinsics (program-arguments))
