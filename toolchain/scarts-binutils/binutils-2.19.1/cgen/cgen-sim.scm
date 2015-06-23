; Simulator generator entry point.
; This is invoked to build: arch.h, cpu-<cpu>.h, memops.h, semops.h, decode.h,
; decode.c, defs.h, extract.c, semantics.c, ops.c, model.c, mainloop.in.
;
; memops.h, semops.h, ops.c, mainloop.in are either deprecated or wip.
;
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
;
; This is a standalone script, we don't load anything until we parse the
; -s argument (keeps reliance off of environment variables, etc.).

; Load the various support routines.

(define (load-files srcdir)
  (load (string-append srcdir "/read.scm"))
  (load (string-append srcdir "/utils-sim.scm"))
  (load (string-append srcdir "/sim.scm"))
  (load (string-append srcdir "/sim-arch.scm"))
  (load (string-append srcdir "/sim-cpu.scm"))
  (load (string-append srcdir "/sim-model.scm"))
  (load (string-append srcdir "/sim-decode.scm"))
)

(define sim-arguments
  (list
   (list "-A" "file" "generate arch.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-arch.h)))
   (list "-B" "file" "generate arch.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-arch.c)))
   (list "-C" "file" "generate cpu-<cpu>.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-cpu.h)))
   (list "-U" "file" "generate cpu-<cpu>.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-cpu.c)))
   (list "-N" "file" "generate cpu-all.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-cpuall.h)))
   (list "-F" "file" "generate memops.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-mem-ops.h)))
   (list "-G" "file" "generate defs.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-defs.h)))
   (list "-P" "file" "generate semops.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-sem-ops.h)))
   (list "-T" "file" "generate decode.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-decode.h)))
   (list "-D" "file" "generate decode.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-decode.c)))
   (list "-E" "file" "generate extract.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-extract.c)))
   (list "-R" "file" "generate read.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-read.c)))
   (list "-W" "file" "generate write.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-write.c)))
   (list "-S" "file" "generate semantics.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-semantics.c)))
   (list "-X" "file" "generate sem-switch.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-sem-switch.c)))
   (list "-O" "file" "generate ops.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-ops.c)))
   (list "-M" "file" "generate model.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-model.c)))
   (list "-L" "file" "generate mainloop.in in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-mainloop.in)))
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
