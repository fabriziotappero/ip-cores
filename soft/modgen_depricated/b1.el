(defun mapcar* (function &rest args)
  "Apply FUNCTION to successive cars of all ARGS. Return the list of results."
  ;; If no list is exhausted,
  (if (not (memq 'nil args))              
      ;; apply function to CARs.
      (cons (apply function (mapcar 'car args))  
            (apply 'mapcar* function             
                   ;; Recurse for rest of elements.
                   (mapcar 'cdr args)))))


;(is-nil-list '(()()()))
;(is-nil-list '(()()(1)))
(defun is-nil-list (l)
  (let ((v 't)
	(e '()))
    (dolist (e l v)
      (if (not (null e))
	  (setq v '())
      )
    )
  )  
)

(defun mapcar*-nil (function &rest args)
  "Apply FUNCTION to successive cars of all ARGS. Return the list of results."
  ;; If no list is exhausted,
  (if (not (is-nil-list args))              
      ;; apply function to CARs.
      (cons (apply function (mapcar 'car args))  
            (apply 'mapcar* function             
                   ;; Recurse for rest of elements.
                   (mapcar 'cdr args)))))


(defun mappos (function args)
  ;; apply function to CARs.
  (let ((v '())
	(e '())
	(c 0))
    (dolist (e args v)
      (setq v (append v `(,(funcall function e c))))
      (setq c (+ c 1))
    )
  )
)

(defun add-log (l v op b1 b2)
  (let ((op1 l)
        (op2 v))
    (if (and b1 (not (string= op1 "")))
      (setq op1 (concat "(" op1 ")"))
    )
    (if (and b2 (not (string= op2 "")))
      (setq op2 (concat "(" op2 ")"))
    )
    (if (string= op1 "")
      `,op2
      (if (string= op2 "")
	`,op1
	(concat op1 op op2)
      )
    )
  )
)

;(add-and "a" "b")
(defun add-and (l v b1 b2)
  (add-log l v " and " b1 b2) 
)

;(add-or "a" "b")
(defun add-or (l v b1 b2)
  (add-log l v " or " b1 b2) 
)






