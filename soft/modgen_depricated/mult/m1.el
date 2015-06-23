
;(generate-booth 3)
(defun generate-booth (b)
  (let ((l -1)
	(both '()))
    (while (< l b)
      (let ((e 0)
	    (v '()))
	(dotimes (e 3 v)
	  (if (and (>= (+ l e) 0)(< (+ l e) b))
	      (setq v (append v (list (format "x%i" (+ l e)))))
	      (setq v (append v (list 0)))
	  )
	)
	(setq both (cons v both ))
      )	
      (setq l (+ l 2))
    )
    (reverse both)
  )
)

(defun get-booth-input (p i) 
  (format "b%.2i_i%i" p i)
)

(defun get-booth-sign (p) 
  (format "b%.2i_s" p)
)

(defun get-booth-sign-neg (p) 
  (format "b%.2i_s_neg" p)
)

;(setq l (generate-booth 4))
;(setq b (generate-adder-network-from-booth l 4))
;(insert (print-list b))    

(defun generate-adder-network-from-booth (booth b)
  (let ((p 0)
        (v '()))
   (mapcar (function (lambda (e)
     (let ((i 0)
	   (c 0))
       (dotimes (i (- b 1))
	 (setq v (add-in2 v (+ (* p 2) i) p (get-booth-input p i)))
       )
       (setq v (add-in2 v (* p 2) (+ p 1) (get-booth-sign p)))                 ;negate + 1
       (setq v (add-in2 v (+ (* p 2) (- b 1)) p (get-booth-sign-neg p))) ;sign
       (setq v (add-in2 v (+ (* p 2) b) p '1))                           ;sign prop
       ;(if (= p 0)  
       ;     (setq v (add-in v (+ (* p 2) (- b 1)) '1))                 ;add to first pp
       ;)
     )
     (setq p (+ p 1))
   )) booth )
   `,v
  )
)

