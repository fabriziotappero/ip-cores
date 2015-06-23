; CPU description file generator for the simulator testsuite.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; This is invoked to build allinsn.exp and a script to run to
; generate allinsn.s and allinsn.d.

; Specify which application.
(set! APPLICATION 'SIM-TEST)

; Called before/after the .cpu file has been read.

(define (sim-test-init!) (opcodes-init!))
(define (sim-test-finish!) (opcodes-finish!))

; Called after .cpu file has been read and global error checks are done.
; We use the `tmp' member to record the syntax split up into its components.

(define (sim-test-analyze!)
  (opcodes-analyze!)
  (map (lambda
	   (insn) (elm-xset! insn 'tmp (syntax-break-out (insn-syntax insn))))
       (current-insn-list))
  *UNSPECIFIED*
)

; Methods to compute test data.
; The result is a list of strings to be inserted in the assembler
; in the operand's position.

(method-make!
 <hw-asm> 'test-data
 (lambda (self n)
   ; FIXME: floating point support
   (let ((signed (list 0 1 -1 2 -2))
	 (unsigned (list 0 1 2 3 4))
	 (mode (elm-get self 'mode)))
     (map number->string
	  (list-take n
		     (if (eq? (mode:class mode) 'UINT)
			 unsigned
			 signed)))))
)

(method-make!
 <keyword> 'test-data
 (lambda (self n)
   (let* ((values (elm-get self 'values))
	  (n (min n (length values))))
     ; FIXME: Need to handle mach variants.
     (map car (list-take n values))))
)

(method-make!
 <hw-address> 'test-data
 (lambda (self n)
   (let ((test-data '("foodata" "4" "footext" "-4")))
     (list-take n test-data)))
)

(method-make!
 <hw-iaddress> 'test-data
 (lambda (self n)
   (let ((test-data '("footext" "4" "foodata" "-4")))
     (list-take n test-data)))
)

(method-make-forward! <hw-register> 'indices '(test-data))
(method-make-forward! <hw-immediate> 'values '(test-data))

; This can't use method-make-forward! as we need to call op:type to
; resolve the hardware reference.

(method-make!
 <operand> 'test-data
 (lambda (self n)
   (send (op:type self) 'test-data n))
)

; Given an operand, return a set of N test data.
; e.g. For a keyword operand, return a random subset.
; For a number, return N numbers.

(define (operand-test-data op n)
  (send op 'test-data n)
)

; Given the broken out assembler syntax string, return the list of operand
; objects.

(define (extract-operands syntax-list)
  (let loop ((result nil) (l syntax-list))
    (cond ((null? l) (reverse result))
	  ((object? (car l)) (loop (cons (car l) result) (cdr l)))
	  (else (loop result (cdr l)))))
)

; Given a list of operands for an instruction, return the test set
; (all possible combinations).
; N is the number of testcases for each operand.
; The result has N to-the-power (length OP-LIST) elements.

(define (build-test-set op-list n)
  (let ((test-data (map (lambda (op) (operand-test-data op n)) op-list))
	(len (length op-list)))
    ; FIXME: Make slicker later.
    (cond ((=? len 0) (list (list)))
	  ((=? len 1) test-data)
	  (else (list (map car test-data)))))
)

; Given an assembler expression and a set of operands build a testcase.
; SYNTAX-LIST is a list of syntax elements (characters) and <operand> objects.
; TEST-DATA is a list of strings, one element per operand.
; FIXME: wip

(define (build-sim-testcase syntax-list test-data)
  (logit 3 "Building a testcase for: "
	 (map (lambda (sl)
		(string-append " "
			       (cond ((string? sl)
				      sl)
				     ((operand? sl)
				      (obj:name sl))
				     (else
				      (with-output-to-string
					(lambda () (display sl)))))))
	      syntax-list)
	 ", test data: "
	 (map (lambda (td) (list " " td))
	      test-data)
	 "\n")
  (let loop ((result nil) (sl syntax-list) (td test-data))
    ;(display (list result sl td "\n"))
    (cond ((null? sl)
	   (string-append "\t"
			  (apply string-append (reverse result))
			  "\n"))
	  ((string? (car sl))
	   (loop (cons (car sl) result) (cdr sl) td))
	  (else (loop (cons (car td) result) (cdr sl) (cdr td)))))
)

; Generate a set of testcases for INSN.
; FIXME: wip

(define (gen-sim-test insn)
  (logit 2 "Generating sim test set for " (obj:name insn) " ...\n")
  (string-append
   "\t.global " (gen-sym insn) "\n"
   (gen-sym insn) ":\n"
   (let* ((syntax-list (insn-tmp insn))
	  (op-list (extract-operands syntax-list))
	  (test-set (build-test-set op-list 2)))
     (string-map (lambda (test-data)
		   (build-sim-testcase syntax-list test-data))
		 test-set))
   )
)

; Generate the shell script that builds the .cgs files.
; .cgs are .s files except that there may be other .s files in the directory
; and we want the .exp driver script to easily find the files.
;
; Eventually it would be nice to generate as much of the testcase as possible.
; For now we just generate the template and leave the programmer to fill in
; the guts of the test (i.e. set up various registers, execute the insn to be
; tested, and then verify the results).
; Clearly some hand generated testcases will also be needed, but this
; provides a good start for each instruction.

(define (cgen-build.sh)
  (logit 1 "Generating sim-build.sh ...\n")
  (string-append
   "\
#/bin/sh
# Generate test result data for " (current-arch-name) " simulator testing.
# This script is machine generated.
# It is intended to be run in the testsuite source directory.
#
# Syntax: /bin/sh sim-build.sh

# Put results here, so we preserve the existing set for comparison.
rm -rf tmpdir
mkdir tmpdir
cd tmpdir
\n"

    (string-map (lambda (insn)
		  (string-append
		   "cat <<EOF > " (gen-file-name (obj:name insn)) ".cgs\n"
		   ; FIXME: Need to record assembler line comment char in .cpu.
		   "# " (current-arch-name) " testcase for " (backslash "$" (insn-syntax insn)) " -*- Asm -*-\n"
		   "# mach: "
		   (let ((machs (insn-machs insn)))
		     (if (null? machs)
			 "all"
			 (string-drop1 (string-map (lambda (mach)
						     (string-append "," mach))
						   machs))))
		   "\n\n"
		   "\t.include \"testutils.inc\"\n\n"
		   "\tstart\n\n"
		   (gen-sim-test insn)
		   "\n\tpass\n"
		   "EOF\n\n"))
		(non-alias-insns (current-insn-list)))
   )
)

; Generate the dejagnu allinsn.exp file that drives the tests.

(define (cgen-allinsn.exp)
  (logit 1 "Generating sim-allinsn.exp ...\n")
  (string-append
   "\
# " (string-upcase (current-arch-name)) " simulator testsuite.

if [istarget " (current-arch-name) "*-*-*] {
    # load support procs (none yet)
    # load_lib cgen.exp

    # all machines
    set all_machs \""
   (string-drop1 (string-map (lambda (m)
			       (string-append " "
					      (gen-sym m)))
			     (current-mach-list)))
   "\"

    # The .cgs suffix is for \"cgen .s\".
    foreach src [lsort [glob -nocomplain $srcdir/$subdir/*.cgs]] {
	# If we're only testing specific files and this isn't one of them,
	# skip it.
	if ![runtest_file_p $runtests $src] {
	    continue
	}

	run_sim_test $src $all_machs
    }
}\n"
   )
)
