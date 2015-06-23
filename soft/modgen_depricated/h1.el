; Konrad Eisele <eiselekd@web.de>
; xh1.el: Some hash functions
;-----------------------------------------------------------------------

(defun hash-exist-p (hash k)
  (not (eq (gethash k hash '()) '())))

(defun case-fold-string= (a b)
  (compare-strings a nil nil b nil nil t))

(defun case-fold-string-hash (a)
  (sxhash (upcase a)))


