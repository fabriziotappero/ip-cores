(in-package #:sexptomem)

(sexp-to-memory
 (%nil
  %t
  %if
  %quote
  %lambda
  %progn
  %cons
  %car
  %cdr
  %eval
  %apply
  %type
  %make-array
  %array-size
  %array-get
  %array-set
  %make-symbol
  %symbol-to-string
  %char-to-int
  %int-to-char
  %get-char
  %put-char
  %num-devices
  %device-type
  %set-address
  %get-address
  %error
  %add
  %sub
  %mul
  %div
  %bitwise-and
  %bitwise-or
  %bitwise-not
  %bitwise-shift
  %current-environment
  %make-eval-state
  %eval-partial
  %define
  %undefine
  %eq?
  %num-eq?
  %char-eq?
  %less-than?
  %mod
  %set!
  %set-car!
  %set-cdr!

  %phase-eval
  %phase-eval-args
  %phase-apply
  %phase-eval-if
  %phase-initial
  %phase-env-lookup
  %phase-env-lookup-local
  %phase-apply-function
  %phase-bind-args
  %phase-eval-progn
  %phase-eval-args-top
  %phase-eval-args-cdr
  %phase-eval-args-cons
  %phase-eval-symbol
  %phase-set!

  xxx3F

  %timeout
  %err-invalid-phase
  %err-unbound-symbol
  %err-invalid-param-list
  %err-too-few-args
  %err-too-many-args
  %err-invalid-state
  %err-invalid-arg-list
  %err-type-error
  %err-not-a-list
  %err-not-a-function
  %err-invalid-function
  %err-malformed-form
  %err-invalid-builtin
  %err-invalid-array-index
  %err-invalid-env
  %err-not-a-pair)
 :1000
 (%progn
  (%define (%quote =) (%lambda (a b) (%num-eq? a b)))
  (%define (%quote -) (%lambda (a b) (%sub a b)))
  (%define (%quote +) (%lambda (a b) (%add a b)))
  (%define (%quote *) (%lambda (a b) (%mul a b)))

;;   (%define (%quote print-string)
;; 	   (%lambda (str devnr)
;; 		    (%progn
;; 		     (%define (%quote iter)
;; 			      (%lambda (n) (%if (= n (%array-size str))
;; 						%nil
;; 						(%progn
;; 						 (%put-char devnr (%array-get str n))
;; 						 (iter (+ n 1))))))
;; 		     (iter 0))))

  (%put-char 1 #\h)
  (%put-char 1 #\e)
  (%put-char 1 #\l)
  (%put-char 1 #\l)
  (%put-char 1 #\o)
  (%put-char 1 #\Newline)

  (%define (%quote count)
	   (%lambda (a b)
		    (%progn
		     (%define (%quote iter)
			      (%lambda (n)
				       (%if (= n b) n (iter (+ n 1)))))
		     (iter a))))

;;  (count 0 #x1000000)


  (%define (%quote echo)
 	   (%lambda (devnr)
 		    (%progn (%put-char devnr (%get-char devnr)) (echo devnr))))
;;  (echo 1)

  (%define (%quote a) (%make-array 5 2))

  (%array-get a 0)
  (%array-set a 1 (+ (%array-get a 0)
		     (%array-get a 1)))
  (%array-set a 1 (+ (%array-get a 0)
		     (%array-get a 1)))
  (%define (%quote r) %nil)
  (%set! (%quote r) 2)
  (%define
   (%quote fact)
   (%lambda (n) (%if (= n 1) 1 (* n (fact (- n 1))))))
  (%set! (%quote r) (fact (- 12 (* (+ 3 1) 2))))
  (%set! (%quote r) (%array-get a 1))
  (%set! (%quote r) (%cons r a))
  ;;(%error (%quote foo))

  ;;(%define (%quote foo) (%lambda (a . foo) foo))
  (%set! (%quote r) (foo 1 2 3))

  r))

;;  (%add 2 3)
;;  (%eval-partial
;;   (%make-eval-state (%quote (%add 11 5))
;; 		    (%current-environment))
;;   0)
;;  (%apply
;;   (%lambda (p n) (%apply p (%cons p (%cons n %nil))))
;;   (%cons (%lambda (p n)
;; 		  (%if (%num-eq? n 1)
;; 		       1
;; 		       (%mul n (%apply p (%cons p (%cons (%sub n 1) %nil))))))
;; 	 (%cons 4 %nil)))
;;  (%apply (%lambda (a b) (%add a (%mul b 2))) (%quote (4 5))))

;; (sexp-to-memory
;;  (%if nil (%add 5 2) 3))
