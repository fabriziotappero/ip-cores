; CGEN Debugging support.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; This file is loaded in during an interactive guile session to
; develop and debug CGEN.  The user visible procs are:
;
; (use-c)
; (load-opc)
; (load-sim)
; (load-sid)
; (load-testsuite)
; (cload #:arch path-to-cpu-file #:machs "mach-list" #:isas "isa-list"
;        #:options "options" #:trace "trace-options")

; First load guile.scm to coerce guile into something we've been using.
; Guile is always in flux.
(load "guile.scm")

(define srcdir ".")
(set! %load-path (cons srcdir %load-path))

; Utility to enable/disable compiled-in C code.

(define (use-c) (set! CHECK-LOADED? #t))
(define (no-c) (set! CHECK-LOADED? #f))

; Also defined in read.scm, but we need it earlier.
(define APPLICATION 'UNKNOWN)

; Supply the path name and suffic for the .cpu file and delete the analyzer
; arg from cpu-load to lessen the typing.

(define (cload . args)
  (let ((cpu-file #f)
	(keep-mach "all")
	(keep-isa "all")
	(options "")
	(trace-options ""))

    ; Doesn't check if (cadr args) exists or if #:arch was specified, but
    ; this is a debugging tool!
    (let loop ((args args))
      (if (null? args)
	  #f ; done
	  (begin
	    (case (car args)
	      ((#:arch) (set! cpu-file (cadr args)))
	      ((#:machs) (set! keep-mach (cadr args)))
	      ((#:isas) (set! keep-isa (cadr args)))
	      ((#:options) (set! options (cadr args)))
	      ((#:trace) (set! trace-options (cadr args)))
	      (else (error "unknown option:" (car args))))
	    (loop (cddr args)))))

    (case APPLICATION
      ((UNKNOWN) (error "application not loaded"))
      ((DESC) (cpu-load cpu-file
			keep-mach keep-isa options trace-options
			desc-init!
			desc-finish!
			desc-analyze!))
      ((DOC) (cpu-load cpu-file
			keep-mach keep-isa options trace-options
			doc-init!
			doc-finish!
			doc-analyze!))
      ((OPCODES) (cpu-load cpu-file
			   keep-mach keep-isa options trace-options
			   opcodes-init!
			   opcodes-finish!
			   opcodes-analyze!))
      ((GAS-TEST) (cpu-load cpu-file
			    keep-mach keep-isa options trace-options
			    gas-test-init!
			    gas-test-finish!
			    gas-test-analyze!))
      ((SIMULATOR) (cpu-load cpu-file
			     keep-mach keep-isa options trace-options
			     sim-init!
			     sim-finish!
			     sim-analyze!))
      ((SID-SIMULATOR) (cpu-load cpu-file
			     keep-mach keep-isa options trace-options
			     sim-init!
			     sim-finish!
			     sim-analyze!))
      ((SIM-TEST) (cpu-load cpu-file
			    keep-mach keep-isa options trace-options
			    sim-test-init!
			    sim-test-finish!
			    sim-test-analyze!))
      ((TESTSUITE) (cpu-load cpu-file
			     keep-mach keep-isa options trace-options
			     testsuite-init!
			     testsuite-finish!
			     testsuite-analyze!))
      (else (error "unknown application:" APPLICATION))))
)

; Use the debugging evaluator.
(if (not (defined? 'DEBUG-EVAL))
    (define DEBUG-EVAL #t))

; Tell maybe-load to always load the file.
(if (not (defined? 'CHECK-LOADED?))
    (define CHECK-LOADED? #f))

(define (load-doc)
  (load "read")
  (load "desc")
  (load "desc-cpu")
  (load "html")
  ; ??? Necessary for the following case, dunno why.
  ; bash$ guile -l dev.scm
  ; guile> (load-doc)
  ; guile> (cload #:arch "./cpu/m32r.cpu")
  (set! APPLICATION 'DOC)
)

(define (load-opc)
  (load "read")
  (load "desc")
  (load "desc-cpu")
  (load "opcodes")
  (load "opc-asmdis")
  (load "opc-ibld")
  (load "opc-itab")
  (load "opc-opinst")
  (set! verbose-level 3)
  (set! APPLICATION 'OPCODES)
)

(define (load-gtest)
  (load-opc)
  (load "gas-test")
  (set! verbose-level 3)
  (set! APPLICATION 'GAS-TEST)
)

(define (load-sid)
  (load "read")
  (load "utils-sim")
  (load "sid")
  (load "sid-cpu")
  (load "sid-model")
  (load "sid-decode")
  (set! verbose-level 3)
  (set! APPLICATION 'SID-SIMULATOR)
)

(define (load-sim)
  (load "read")
  (load "desc")
  (load "desc-cpu")
  (load "utils-sim")
  (load "sim")
  (load "sim-arch")
  (load "sim-cpu")
  (load "sim-model")
  (load "sim-decode")
  (set! verbose-level 3)
  (set! APPLICATION 'SIMULATOR)
)

(define (load-stest)
  (load-opc)
  (load "sim-test")
  (set! verbose-level 3)
  (set! APPLICATION 'SIM-TEST)
)

(define (load-testsuite)
  (load "read")
  (load "desc")
  (load "desc-cpu")
  (load "testsuite.scm")
  (set! verbose-level 3)
  (set! APPLICATION 'TESTSUITE)
)

(display "
First enable compiled in C code if desired.

(use-c)

Then choose the application via one of:

(load-doc)
(load-opc)
(load-gtest)
(load-sim)
(load-stest)
(load-testsuite)
")

(display "(load-sid)\n")

(display "\

Then load the .cpu file with:

(cload #:arch \"path-to-cpu-file\" #:machs \"keep-mach\" #:isas \"keep-isa\" #:options \"options\" #:trace \"trace-options\")

Only the #:arch parameter is mandatory, the rest are optional.

keep-mach:
comma separated list of machs to keep or `all'

keep-isa:
comma separated list of isas to keep or `all'

#:options specifies a list of application-specific options

doc options:
[none yet]

opcode options:
[none yet]
Remember to call (set-opc-file-path! \"/path/to/cpu.opc\").

gas test options:
[none yet]
\n")

(display "\
sim options:
with-scache
with-profile=fn

sim test options:
[none yet]
\n")

(display "\
sid options:
[wip]
\n")

(display "\
trace-options: (comma-separated list of options)
commands - trace cgen command invocation
pmacros - trace pmacro expansion
all - trace everything
\n")

; If ~/.cgenrc exists, load it.

(let ((cgenrc (string-append (getenv "HOME") "/.cgenrc")))
  (if (file-exists? cgenrc)
      (load cgenrc))
)
