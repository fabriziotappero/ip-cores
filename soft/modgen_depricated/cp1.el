; Konrad Eisele <eiselekd@web.de>
; cp1.el: Some component hash functions
;-----------------------------------------------------------------------

(setq comp_id 0)

;(get_comp_id)
(defun get_comp_id ()
  (setq comp_id (+ comp_id 1))
  `,comp_id
)

(defun create-component (n)
  (let ((dec))
    (define-hash-table-test 'contents-hash 'equal 'sxhash)
    (setq d (make-hash-table :test 'contents-hash))
    (puthash "name" n d)
    `,d
  )
)

;(progn 
; (load "h1")
; (load "l1")
; (setq c (create-component "cla"))
; (create-input c "in1" "sig1")
; (create-input c "in2" "sig2")
; (create-output c "out2" "sig2")
; (get-input c "in2")
; (print-list c)
;)
(defun create-input (c n s)
  (puthash "in" (cons (list n s) (gethash "in" c '()) ) c )
)

(defun create-output (c n s)
  (puthash "out" (cons (list n s) (gethash "out" c '()) ) c )
)




(defun is-component (c)
  "Check for (<id> <component hash>) list"
  (and (listp c)(numberp (nth 0 c))(hash-table-p (nth 1 c)))
)

(defun get-input (c n)
  (if (is-component c)
    (let ((v (gethash "in" (nth 1 c) '()))
	  (f '()))
      ( if (listp v)
	  (mapcar (function (lambda (e)
	      (if (and (listp e) (string= n (nth 0 e)))
		  (setq f (nth 1 e))
	      )
    	  )) v )
      )
      `,f
    )
    '()
  )
)

(defun get-output (c n)
  (if (is-component c)
    (let ((v (gethash "out" (nth 1 c) '()))
	  (f '()))
      ( if (listp v)
	  (mapcar (function (lambda (e)
	      (if (and (listp e) (string= n (nth 0 e)))
		  (setq f (nth 1 e))
	      )
    	  )) v )
      )
      `,f
    )
    '()
  )
)


