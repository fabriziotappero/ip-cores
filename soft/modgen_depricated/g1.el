
;(gen-list 32)
(defun gen-list (c) 
   "Generate 0-c list"
   (let ((v '())
         (e 0))
     (dotimes (e c v) 
       (setq v (append v `(,e)))
     )
   )
)

;(gen-tree 32 8 )
(defun gen-tree (c w)
  "Generate recursive lists with width w and elementcount c"
  (let ((l (gen-list c)))
    (while (> (length l) w)
      (let ((v '())
	    (e 0)
	    (c 0))
	(while (< e (length l))
	  (if (> (+ e w) (length l))
	      (setq c (- (length l) e))
	    (setq c w)
	  )
	  (setq v (append v `(,(cut-copy-list l e (+ e c)))))
	  (setq e (+ e w))
        )
	(setq l v)
      )
    )
    `,l
  )
)

; (is-base '(1 2 3 4))
; (is-base '((1 2) 3 4))
(defun is-base (l)
  "Check weather this is no nested list"
  (let ((v 't)
	(e '()))
    (dolist (e l v)
      (if (listp e)
	  (setq v '())
      )
    )
  )
)

;(get-depth  '((1 2) (3 4) (5 6)))
;(get-depth  '((1 2)))
;(get-depth (gen-tree 32 4))
(defun get-depth (l)
  "Get list nesting level"
  (if (is-base l)
     '1
    (let ((v 1)
	  (e '())
	  (c 1)
	  (d 0))
      (dolist (e l v)
	(setq d 1)
	(if (listp e)
	    (setq d (+ 1 (get-depth e)))
	)
	(if (> d v)
	    (setq v d)
	)
      )
    )
  )
)

(defun get-range (l)
  (format "%.3d_%.3d" (get-right l) (get-left l))
)

;(get-first '((1 2 3) 2 4))
(defun get-left (l)
  "Get the leftmost element"
  (if (listp l)
    (get-left (nth 0 l))
    `,l
  )
)

;(get-last '((1 2 3) 2 4))
(defun get-right (l)
  "Get the rightmost element"
  (if (listp l)
    (get-right (nth (- (length l) 1) l))
    `,l
  )
)



