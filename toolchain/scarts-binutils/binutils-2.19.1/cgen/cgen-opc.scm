; CPU description file generator for the GNU Binutils.
; This is invoked to build: $arch-desc.[ch], $arch-opinst.c,
; $arch-opc.h, $arch-opc.c, $arch-asm.in, $arch-dis.in, and $arch-ibld.[ch].
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
;
; This is a standalone script, we don't load anything until we parse the
; -s argument (keeps reliance off of environment variables, etc.).

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
)

(define opc-arguments
  (list
   (list "-OPC" "file" "specify path to .opc file"
	 (lambda (arg) (set-opc-file-path! arg))
	 #f)
   (list "-H" "file" "generate $arch-desc.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-desc.h)))
   (list "-C" "file" "generate $arch-desc.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-desc.c)))
   (list "-O" "file" "generate $arch-opc.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-opc.h)))
   (list "-P" "file" "generate $arch-opc.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-opc.c)))
   (list "-Q" "file" "generate $arch-opinst.c in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-opinst.c)))
   (list "-B" "file" "generate $arch-ibld.h in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-ibld.h)))
   (list "-L" "file" "generate $arch-ibld.in in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-ibld.in)))
   (list "-A" "file" "generate $arch-asm.in in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-asm.in)))
   (list "-D" "file" "generate $arch-dis.in in <file>"
	 #f
	 (lambda (arg) (file-write arg cgen-dis.in)))
   )
)

; (-R "file" "generate $cpu-reloc.h") ; FIXME: wip (rename to -abi.h?)
; (-S "file" "generate cpu-$cpu.c") ; FIXME: wip (bfd's cpu-$cpu.c)
; ((-R) (file-write *arg* cgen-reloc.c))
; ((-S) (file-write *arg* cgen-bfdcpu.c))

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

(define (cgen-opc argv)
  (let ()

    ; Find and set srcdir, then load all Scheme code.
    ; Drop the first argument, it is the script name (i.e. argv[0]).
    (set! srcdir (find-srcdir (cdr argv)))
    (set! %load-path (cons srcdir %load-path))
    (load-files srcdir)

    (display-argv argv)

    (cgen #:argv argv
	  #:app-name "opcodes"
	  #:arg-spec opc-arguments
	  #:init opcodes-init!
	  #:finish opcodes-finish!
	  #:analyze opcodes-analyze!)
    )
)

(cgen-opc (program-arguments))
