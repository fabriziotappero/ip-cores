; Konrad Eisele <eiselekd@web.de>
; cdef_lib_b1.el: Some Bitvector functions
;-----------------------------------------------------------------------

(defun mapcar* (function &rest args)
  "Apply FUNCTION to successive cars of all ARGS. Return the list of results."
  ;; If no list is exhausted,
  (if (not (memq 'nil args))              
      ;; apply function to CARs.
      (cons (apply function (mapcar 'car args))  
            (apply 'mapcar* function             
                   ;; Recurse for rest of elements.
                   (mapcar 'cdr args)))))


(defun isundef-p (e)
  (not (or (eq e 0) (eq e 1))))

(defun and-bit (l) 
  "And bit using undef values"
  (if (and (eq (nth 0 l) '1) (eq (nth 1 l) '1))
    '1
    (if (or (isundef-p (nth 0 l)) (isundef-p (nth 1 l)))
      'U
      '0
    )
  )
)

(defun or-bit (l) 
  "And bit using undef values"
  (if (and (eq (nth 0 l) '0) (eq (nth 1 l) '0))
    '0
    (if (or (isundef-p (nth 0 l)) (isundef-p (nth 1 l)))
      'U
      '1
    )
  )
)

(defun make-undef-bit (l) 
  "Undef values on l[1] == 0"
  (if (eq (nth 1 l) '1)
    (nth 0 l)
    'U
  )
)

(defun make-isundef-bit (b) 
  "1 if not undef"
  (if (isundef-p b)
    '0
    '1
  )
)


(defun and-bitstring (a b) 
  "And bitstring" 
  (mapcar 'and-bit (mapcar* 'list a b))
)

(defun or-bitstring (a b) 
  "Or bitstring" 
  (mapcar 'or-bit (mapcar* 'list a b))
)

(defun make-undef-bitstring (a u) 
  "Set undefined value where u == 0" 
  (mapcar 'make-undef-bit (mapcar* 'list a u))
)

(defun make-set-bitstring (a) 
  "Make maskestring where not undefined" 
  (mapcar 'make-isundef-bit a)
)

(defun count-bits (a)
  "Count n equal bits from start"
  (let ((e (pop a))
	(n 1))
    (if (eq e '())
      (setq n 0)
      (while (eq e (nth 0 a))
	 (pop a)
	 (setq n (+ n 1))
      )
    )
    `,n
  )
)

