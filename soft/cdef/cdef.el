;-----------------------------------------------------------------------

(defun int-to-bitstring-rec (n m size)
  "Return a bitstring reverse order"
  (if (> size 0)
      (if (eq (logand n m) 0)
	  (cons '0 (int-to-bitstring-rec n (lsh m 1) (- size 1)) )
	  (cons '1 (int-to-bitstring-rec n (lsh m 1) (- size 1)) )
      )
      '()
    )
)

(defun int-to-bitstring (n m size)
  "Return a bitstring"
  (reverse (int-to-bitstring-rec n m size))
)

(defun hexchar-to-bitstring (hexchar)
  "Convert char to bit sequence"
  ( let ((n (downcase hexchar)))
    (if (and (>= n ?a) (<= n ?f))
      (int-to-bitstring (+ (- n ?a) 10) 1 4 )
      (if (and (>= n ?0) (<= n ?9))
        (int-to-bitstring (- n ?0) 1 4 )
      ) 
    )
  ) 
)

(defun hex-to-bitstring (hex)
  "Convert hex string into bitstring"
  (if (> (length hex) 0)
    ( append (hexchar-to-bitstring (elt hex 0)) (hex-to-bitstring (substring hex 1 (length hex)))) 
    '()
  )
)

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
    '1
    '0
  )
)

(defun and-bitstring (a b) 
  "And bitstring" 
  (mapcar' 'and-bit (mapcar* 'list a b))
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


;-----------------------------------------------------------------------

(defun in-bound-p (start end pos) 
  (and (>= pos start) (< pos end)))
      
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


(defun make-setbit-groups-rec (a) 
   (if (> (length a) 0)
      (let ((n (count-bits a))
	    (e (nth 0 a)))
	(append (make-setbit-groups-rec (nthcdr n a)) `(,(make-list n e)))
      )
      '()
   )
)


(defun make-setbit-groups (a) 
   "Raise the consecutive 1s"
   (reverse (make-setbit-groups-rec a)))


(defun or-setbit-groups-func (l)
  (let ((a (nth 0 l))
	(b (nth 1 l))
	(al (length (nth 0 l)))
	(bl (length (nth 1 l)))
	(ae (nth 0 (nth 0 l)))
	(be (nth 0 (nth 1 l)))
	(oe (logior (nth 0 (nth 0 l)) (nth 0 (nth 1 l))))
	)
    (insert (number-to-string oe))
    ( if (eq al bl)
        (
	 if (> al bl)
	    ()
	    ()
	)  
    )
    ))



(defun rec-copy-list-func (e)
  (if (listp e)
      (mapcar 'rec-copy-list-func e)
   `,e)
)

(defun rec-copy-list (l)
  "Copy list"
  (mapcar 'rec-copy-list-func l)
)

(defun cut-copy-list (l start end)
  "Copy list and cut range"
  (let ((c (rec-copy-list l)))
    (if (<= end 0)
	(setq c '())
	(if (<= end (length c))
	    (setcdr (nthcdr (- end 1) c) '())
	)
    )
    (nthcdr start c)
  )
)

;l:        (0  0  0  0  0)
;p1:     1     x
;p2:     3         |<x
;result:  ((0)(1  1)( 0 0))
;(split-setbit-copy-list '(0  0  0  0  0) 1 3)

(defun split-setbit-copy-list (l p1 p2 )
  "Splits list between [p1,p2]  and fill [p1,p2] with ones"
  (let 
      ((r l)
       (size (length l)))
    (if (and (in-bound-p 1 size p1)(in-bound-p 1 size p2))  ; split into 3
	( 
	  `( ( ,(cut-copy-list l 0 p1) ) ( ,(make-list (- p2 p1) 1) ) ( ,(cut-copy-list l p2 size)))
	 )
        (if (in-bound-p 1 size p1)                          ; split into 2
           (
	    `( ( ,(cut-copy-list l 0 p1) ) ( ,(make-list (- size p1) 1) ) )
	    )
  	   (if (in-bound-p 1 size p2)                       ; split into 2
	       (
		`( ( ,(make-list p2 1) ) (  ,(cut-copy-list l p2 size) ) )
	       )
	       (if (and (< p1 0) (>= p2 size))
		   `( ,(make-list size 1) )
		   `( ,l);                                       ; do not split
	       )
           )
        )
    )
    ))
    

;l:      ((1  1  1)(0  0)(1  1))
;off:  2         x
;elt: (x x)
;result: ((1  1)(1)(1)(0)(1  1))
;(or-setbit-groups-into '((1  1  1)(0  0)(1  1)) 2 '(0 0))

(defun or-setbit-groups-into (l off elt)
  "Insert splitting range element <elt> into list <l> at offset <off>"
  (let ((cur 0)
	(start off)
	(end (+ off (length elt)))
	(v '())
	)
    (dolist (e (mapcar (function (lambda (x) 
      (let ((curstart cur)
	    (curend (+ cur (length x))))
	(setq cur curend)
	(split-setbit-copy-list x (- start curstart) (- end curstart)
	    )))) l )
     v)
      (setq v (append v e))
      )
))

;a:      ((1  1  1)(0  0)(1  1))
;b:      ((0)(1  1  1)(0  0)(1))
;result: ((1)(1  1)(1)(0)(1)(1))
;(or-setbit-groups '((1  1  1)(0  0)(1  1)) '((0)(1  1  1)(0  0)(1)))

(defun or-setbit-groups (a b) 
  "Split and or 2 raised setbit groups"
  (let ((value a)
	(off 0)
	)
    (dolist (elt b value)
      (if (eq (nth 0 elt) 1)
	  (setq value (or-setbit-groups-into value off elt))
      )
      (setq off (+ off (length elt)))
      )))


(setq a '(1 1 0 0))
(setq b '(1 0 0 0))
(setq c '(1 1 0 1))
(setq ac (make-setbit-groups a))
(setq bc (make-setbit-groups b))
(setq cc (make-setbit-groups c))

(setq dc (or-setbit-groups ac bc))
(or-setbit-groups dc cc)

(or-setbit-groups-func '((0) (1 1 )))1


(setq l '(2 3 4))
(setcdr l '(4))
l

(setq a1 (hex-to-bitstring "ff"))
(setq b1 (hex-to-bitstring "f0"))
(setq c1 (make-undef-bitstring a b))

(setq a2 (hex-to-bitstring "ff"))
(setq b2 (hex-to-bitstring "f8"))
(setq c2 (make-undef-bitstring a b))

(setq cc c2)

(setq cu (make-set-bitstring c2))




(setq h (make-hash-table))
(puthash 'a a h)
(puthash 'b 2 h)
(puthash 'c 3 h)

(list (gethash 'c h) (gethash 'a h))


