; Konrad Eisele <eiselekd@web.de>
; cdef_lib_g1.el: Some bit grouping functions
;-----------------------------------------------------------------------


(defun make-setbit-groups-rec (a) 
   (if (> (length a) 0)
      (let ((n (count-bits a))
	    (e (nth 0 a)))
	(append (make-setbit-groups-rec (nthcdr n a)) `(,(make-list n e)))
      )
      '()
   )
)

;a:      (1 1 1 0 0 1 1 0 0)
;result: ((1 1 1) (0 0) (1 1) (0 0))
;(make-setbit-groups-rec '(1 1 1 0 0 1 1 0 0))
(defun make-setbit-groups (a) 
   "Raise the consecutive 1s"
   (reverse (make-setbit-groups-rec a)))


;-----------------------------------------------------------------------

;l:        (0  0  0  0  0)
;p1:     1     x
;p2:     3         |<x
;result:  ((0)(1  1)( 0 0))
;(or-split-setbit-copy-list '(0  0  0  0  0) 1 3)

(defun or-split-setbit-copy-list (l p1 p2 )
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
	       (if (and (<= p1 0) (>= p2 size))
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
	(or-split-setbit-copy-list x (- start curstart) (- end curstart)
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
  "Split and or 2 raised setbit groups using '1"
  (let ((value a)
	(off 0)
	)
    (dolist (elt b value)
      (if (eq (nth 0 elt) 1)
	  (setq value (or-setbit-groups-into value off elt))
      )
      (setq off (+ off (length elt)))
      )))

;-----------------------------------------------------------------------

;l:      ((1  1  1)(0  0)(1  1))
;off:  2         x
;elt: (x x)
;result: ((1  1)(1)(1)(0)(1  1))
;(and-setbit-groups-into '((1  1  1)(0  0)(1  1)) 2 '(0 0))

(defun and-setbit-groups-into (l off elt)
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
	(and-split-setbit-copy-list x (- start curstart) (- end curstart)
	    )))) l )
     v)
      (setq v (append v e))
      )
))

;l:        (1  1  1  1  1)
;p1:     1     x
;p2:     3         |<x
;result:  ((1)(0  0)( 1 1))
;(and-split-setbit-copy-list '(1 1 1 1 1) 1 3)

(defun and-split-setbit-copy-list (l p1 p2 )
  "Splits list between [p1,p2]  and fill [p1,p2] with ones"
  (let 
      ((r l)
       (size (length l)))
    (if (and (in-bound-p 1 size p1)(in-bound-p 1 size p2))  ; split into 3
	( 
	  `( ( ,(cut-copy-list l 0 p1) ) ( ,(make-list (- p2 p1) 0) ) ( ,(cut-copy-list l p2 size)))
	 )
        (if (in-bound-p 1 size p1)                          ; split into 2
           (
	    `( ( ,(cut-copy-list l 0 p1) ) ( ,(make-list (- size p1) 0) ) )
	    )
  	   (if (in-bound-p 1 size p2)                       ; split into 2
	       (
		`( ( ,(make-list p2 0) ) (  ,(cut-copy-list l p2 size) ) )
	       )
	       (if (and (<= p1 0) (>= p2 size))
		   `( ,(make-list size 0) )
		   `( ,l);                                       ; do not split
	       )
           )
        )
    )
    ))
    
;a:      ((1  1  1)(0  0)(1  1))
;b:      ((0)(1  1  1)(0  0)(1))
;result: ((0)(1  1)(0)(0)(0)(1))
;(and-setbit-groups '((1  1  1)(1  0)(1  1)) '((0  0 0)( 0 0 0)(0)))

(defun and-setbit-groups (a b) 
  "Split and or 2 raised setbit groups using '0"
  (let ((value a)
	(off 0)
	)
    (dolist (elt b value)
      (if (eq (nth 0 elt) 0)
	  (setq value (and-setbit-groups-into value off elt))
      )
      (setq off (+ off (length elt)))
      )))

;-----------------------------------------------------------------------

; l:             ((1)(1  1)(1)(0 0 0))
; (f start end): (f 0 1) (f 1 3) (f 3 4)
;(defun func1 (start end)
;   `(,start ,end)
;)
;(mapcar-setbit 'func1 '((1)(1  1)(1)(0 0 0)))

(defun mapcar-setbit (f finest i)
  ;call func <(f start end i)> for every setbit part
  (if (not (memq 'nil finest))              
      (let ((off 0))
	( mapcar (function (lambda (x) 
	     (let ((cur off))
	       (setq off (+ off (length x)))
	       (if (eq (nth 0 x) 1)
		   (funcall f cur (+ cur (length x)) i))))) finest ))))
