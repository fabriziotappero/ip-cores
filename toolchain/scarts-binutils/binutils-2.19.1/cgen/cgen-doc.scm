; CPU description file generator for CGEN cpu documentation
; This is invoked to build: $arch.html.
; Copyright (C) 2003, 2009 Doug Evans
; This file is part of CGEN.
;
; This is a standalone script, we don't load anything until we parse the
; -s argument (keeps reliance off of environment variables, etc.).

; Load the various support routines.

(define (load-files srcdir)
  (load (string-append srcdir "/read.scm"))
  (load (string-append srcdir "/desc.scm"))
  (load (string-append srcdir "/desc-cpu.scm"))
  (load (string-append srcdir "/html.scm"))
)

(define doc-arguments
  (list
   (list "-H" "file" "generate $arch.html in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen.html)))
   (list "-I" "file" "generate $arch-insn.html in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-insn.html)))
   (list "-N" "file" "specify name of insn.html file"
	 #f
	 (lambda (arg) (set! *insn-html-file-name* arg)))
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

(define (cgen-doc argv)
  (let ()

    ; Find and set srcdir, then load all Scheme code.
    ; Drop the first argument, it is the script name (i.e. argv[0]).
    (set! srcdir (find-srcdir (cdr argv)))
    (set! %load-path (cons srcdir %load-path))
    (load-files srcdir)

    (display-argv argv)

    (cgen #:argv argv
	  #:app-name "doc"
	  #:arg-spec doc-arguments
	  #:init doc-init!
	  #:finish doc-finish!
	  #:analyze doc-analyze!)
    )
)

(cgen-doc (program-arguments))
