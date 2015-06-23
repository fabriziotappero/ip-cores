;(get-zero 2 1)
(defun get-zero (l r)
  (let ((str "")
	(e 0))
    (dotimes (e (+ (abs (- l r)) 1))
      (setq str (concat str "0"))
    )
    `,str
  )
)

;(get-cond 't '(1 2)
(defun get-cond (first l) 
  (let ((e ""))
    (if first
       (setq e (concat e "if")) 
       (setq e (concat e "elsif")) 
    )
    (setq e (concat e " data(" (number-to-string (get-right l)) " downto " (number-to-string (get-left l)) ") /= \"" (get-zero (get-right l) (get-left l)) "\" then\n" ))
    `,e
  )
)

;(get-num 0 3)
(defun get-num (p w) 
  (let ((c (ceiling (log w 2)))
	(e 0)
	(v ""))
    (dotimes (e c v)
      (if (eq (logand p (lsh 1 e)) 0)
	  (setq v (concat "0" v )) 
	  (setq v (concat "1" v )) 
      )
    )
  )
)


;(get-depth '(1 2))
;(get-output-from '((1 2) (3 4)) 0 "base" 1)
(defun get-output-from (l o w path depth)
  (format "%s_d%.2d(%d downto %d)" path depth (- (* (+ o 1) (* (ceiling (log w 2)) (get-depth l))) 1) (* o (* (ceiling (log w 2)) (get-depth l))))
)

(defun get-depth-range (l o)
  (format "(%d downto %d)" (* (+ o 1) (get-depth l)) (* o (get-depth l)))
)

;(setq l '((1 2)(3 4)))
;(setq d (get-depth l))
;(print-cnt l d 0 2 "base")
;<l>    : cond list
;<depth>: depth level (descending)
;<o>    : parent pos ...l:(x(1 2)x(3 4))...
;<w>    : dec width
;<path> : basename
(defun print-cnt-rec (l depth o w path)
  "vhdl counter"
  (let ((e 0)
	(p 0)
	(v "")
	(v2 "")
	(c "")
	(co "")
	(pb "")
	(first 't))
    (dolist (e l v)
      (setq co (concat co (get-cond first e)))
      (setq c "")
      (setq pb (get-output-from l o w path depth))
      (if (listp e) 
	  (progn 
	    (setq v (concat v (print-cnt-rec e (- depth 1) (+ (* o w) p) w path)))
	    (setq c (concat "&" (get-output-from e (+ (* o w) p) w path (- depth 1))))  
	  )
      )
      (setq co (concat co pb "=\"" (get-num p w) "\"" c ";\n"))
      (setq first '())
      (setq p (+ p 1))
    )
    
    (setq co (concat co "end if;\n\n"))
    (setq v (concat v co))
    
    `,v
  )
)

(defun print-cnt (l w base)
  (print-cnt-rec l (get-depth l) 0 w base)
)











