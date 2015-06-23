;;; {Profile}
;;; Copyright (C) 2009 Red Hat, Inc.
;;; This file is part of CGEN.
;;; See file COPYING.CGEN for details.
;;;
;;; This code is just an experimental prototype (e. g., it is not
;;; thread safe), but since it's at the same time useful, it's
;;; included anyway.
;;;
;;; This is copied from the tracing support in debug.scm.
;;; If merged into the main distribution it will need an efficiency
;;; and layout cleanup pass.

; FIXME: Prefix "proc-" added to not collide with cgen stuff.

; Put this stuff in the debug module since we need the trace facilities.
(define-module (ice-9 profile) :use-module (ice-9 debug))

(define profiled-procedures '())

(define-public (profile-enable . args)
  (if (null? args)
      (nameify profiled-procedures)
      (begin
	(for-each (lambda (proc)
		    (if (not (procedure? proc))
			(error "profile: Wrong type argument:" proc))
		    ; `trace' is a magic property understood by guile
		    (set-procedure-property! proc 'trace #t)
		    (if (not (memq proc profiled-procedures))
			(set! profiled-procedures
			      (cons proc profiled-procedures))))
		  args)
	(set! apply-frame-handler profile-entry)
	(set! exit-frame-handler profile-exit)
	(debug-enable 'trace)
	(nameify args))))

(define-public (profile-disable . args)
  (if (and (null? args)
	   (not (null? profiled-procedures)))
      (apply profile-disable profiled-procedures)
      (begin
	(for-each (lambda (proc)
		    (set-procedure-property! proc 'trace #f)
		    (set! profiled-procedures (delq! proc profiled-procedures)))
		  args)
	(if (null? profiled-procedures)
	    (debug-disable 'trace))
	(nameify args))))

(define (nameify ls)
  (map (lambda (proc)
	 (let ((name (procedure-name proc)))
	   (or name proc)))
       ls))

; Subroutine of profile-entry to find the calling procedure.
; Result is name of calling procedure or #f.

(define (find-caller frame)
  (let ((prev (frame-previous frame)))
    (if prev
	; ??? Not sure this is right.  The goal is to find the real "caller".
	(if (and (frame-procedure? prev)
		 ;(or (frame-real? prev) (not (frame-evaluating-args? prev)))
		 (not (frame-evaluating-args? prev))
		 )
	    (let ((name (procedure-name (frame-procedure prev))))
	      (if name name 'lambda))
	    (find-caller prev))
	'top-level))
)

; Return the current time.
; The result is a black box understood only by elapsed-time.

(define (current-time) (gettimeofday))

; Return the elapsed time in milliseconds since START.

(define (elapsed-time start)
  (let ((now (gettimeofday)))
    (+ (* (- (car now) (car start)) 1000)
       (quotient (- (cdr now) (cdr start)) 1000)))
)

; Handle invocation of profiled procedures.

(define (profile-entry key cont tail)
  (if (eq? (stack-id cont) 'repl-stack)
      (let* ((stack (make-stack cont))
	     (frame (stack-ref stack 0))
	     (proc (frame-procedure frame)))
	(if proc
	    ; procedure-property returns #f if property not present
	    (let ((counts (procedure-property proc 'profile-count)))
	      (set-procedure-property! proc 'entry-time (current-time))
	      (if counts
		  (let* ((caller (find-caller frame))
			 (count-elm (assq caller counts)))
		    (if count-elm
			(set-cdr! count-elm (1+ (cdr count-elm)))
			(set-procedure-property! proc 'profile-count
						 (acons caller 1 counts)))))))))

  ; SCM_TRACE_P is reset each time by the interpreter
  ;(display "entry\n" (current-error-port))
  (debug-enable 'trace)
  ;; It's not necessary to call the continuation since
  ;; execution will continue if the handler returns
  ;(cont #f)
)

; Handle exiting of profiled procedures.

(define (profile-exit key cont retval)
  ;(display "exit\n" (current-error-port))
  (display (list key cont retval)) (newline)
  (display (stack-id cont)) (newline)
  (if (eq? (stack-id cont) 'repl-stack)
      (let* ((stack (make-stack cont))
	     (frame (stack-ref stack 0))
	     (proc (frame-procedure frame)))
	(display stack) (newline)
	(display frame) (newline)
	(if proc
	    (set-procedure-property!
	     proc 'total-time
	     (+ (procedure-property proc 'total-time)
		(elapsed-time (procedure-property proc 'entry-time)))))))

  ; ??? Need to research if we have to do this or not.
  ; SCM_TRACE_P is reset each time by the interpreter
  (debug-enable 'trace)
)

; Called before something is to be profiled.
; All desired procedures to be profiled must have been previously selected.
; Property `profile-count' is an association list of caller name and call
; count.
; ??? Will eventually want to use a hash table or some such.

(define-public (profile-init)
  (for-each (lambda (proc)
	      (set-procedure-property! proc 'profile-count '())
	      (set-procedure-property! proc 'total-time 0))
	    profiled-procedures)
)

; Called after execution to print profile counts.
; If ARGS contains 'all, stats on all profiled procs are printed, not just
; those that were actually called.

(define-public (profile-stats . args)
  (let ((stats (map (lambda (proc)
		      (cons (procedure-name proc)
			    (procedure-property proc 'profile-count)))
		    profiled-procedures))
	(all? (memq 'all args))
	(sort (if (defined? 'sort) (local-ref '(sort)) (lambda args args))))

    (display "Profiling results:\n\n")

    ; Print the procs in sorted order.
    (let ((stats (sort stats (lambda (a b) (string<? (car a) (car b))))))
      (for-each (lambda (proc-stats)
		  (if (or all? (not (null? (cdr proc-stats))))
		      ; Print by decreasing frequency.
		      (let ((calls (sort (cdr proc-stats) (lambda (a b) (> (cdr a) (cdr b))))))
			(display (string-append (car proc-stats) "\n"))
			(for-each (lambda (call)
				    (display (string-append "  "
							    (number->string (cdr call))
							    " "
							    (car call)
							    "\n")))
				  calls)
			(display "  ")
			(display (apply + (map cdr calls)))
			(display " -- total\n\n"))))
		stats)))
)
