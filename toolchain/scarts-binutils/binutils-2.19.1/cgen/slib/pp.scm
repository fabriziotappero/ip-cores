;"pp.scm" Pretty-print

; (pretty-print obj port) pretty prints 'obj' on 'port'.  The current
; output port is used if 'port' is not specified.

(define (pp:pretty-print obj . opt)
  (let ((port (if (pair? opt) (car opt) (current-output-port))))
    (generic-write obj #f 79 (lambda (s) (display s port) #t))))

(define pretty-print pp:pretty-print)
