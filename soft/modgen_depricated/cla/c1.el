;<l>: generate combined generate and propagate for <l>  
(defun print-generate-propagate-rec (l )
  (let ((e 0)
	(g "")
	(p "")
	(v ""))
    (if (listp l)
      (let ((gen "")
            (prop "")
            (c (length l)))
	(dotimes (p c gen)
	  (let ((genprop "")) 
	    (mapcar (function (lambda (e)
	      (setq genprop (add-and genprop (concat "prop" (get-range e)) '() '()))
	    )) (nthcdr (+ p 1) l))
	    (setq gen (add-or gen (add-and genprop (concat "genr" (get-range (nth p l))) '() '()) '() 't))
          )
        )
	(mapcar (function (lambda (e)
	  (setq prop (add-and prop (concat "prop" (get-range e)) '() '()))
        )) l)
	(setq v (mapconcat 'print-generate-propagate-rec l ""))
	(setq v (concat v (concat "genr" (get-range l)) "=" gen ";\n" (concat "prop" (get-range l)) "="  prop ";\n"))
      )
      (let ((gen "")
	    (prop ""))
	(setq gen (concat "a(" (number-to-string l) ") and b(" (number-to-string l) ")" ))
	(setq prop (concat "a(" (number-to-string l) ") or b(" (number-to-string l) ")" ))
	(setq v (concat (concat "genr" (get-range l)) "=" gen ";\n" (concat "prop" (get-range l)) "="  prop ";\n"))
      )
    )
  )
)

  







