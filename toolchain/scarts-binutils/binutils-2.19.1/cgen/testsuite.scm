; CGEN testsuite driver.
; Copyright (C) 2009 Doug Evans
; This file is part of CGEN.

; Global state variables.

; Specify which application.
(set! APPLICATION 'TESTSUITE)

; Initialize the options.

(define (option-init!)
  ;;(set! CURRENT-COPYRIGHT copyright-fsf)
  ;;(set! CURRENT-PACKAGE package-cgen)
  *UNSPECIFIED*
)

; Testsuite init,finish,analyzer support.

; Initialize any testsuite specific things before loading the .cpu file.

(define (testsuite-init!)
  (desc-init!)
  (mode-set-biggest-word-bitsizes!)
  *UNSPECIFIED*
)

; Finish any testsuite specific things after loading the .cpu file.
; This is separate from analyze-data! as cpu-load performs some
; consistency checks in between.

(define (testsuite-finish!)
  (desc-finish!)
  *UNSPECIFIED*
)

; Compute various needed globals and assign any computed fields of
; the various objects.  This is the standard routine that is called after
; a .cpu file is loaded.

(define (testsuite-analyze!)
  (desc-analyze!)

  ; Initialize the rtl->c translator.
  (rtl-c-config!)

  ; Only include semantic operands when computing the format tables if we're
  ; generating operand instance tables.
  ; ??? Actually, may always be able to exclude the semantic operands.
  ; Still need to traverse the semantics to derive machine computed attributes.
;;  (arch-analyze-insns! CURRENT-ARCH
;;		       #t ; include aliases?
;;		       #f ; build operand instance table?
;;		       )

  *UNSPECIFIED*
)

;; 

(define (cgen-test.h)
  (logit 1 "Generating testsuite.out ...\n")
  (string-write "CGEN Testsuite")
)
