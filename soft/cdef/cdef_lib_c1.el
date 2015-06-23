; Konrad Eisele <eiselekd@web.de>
; cdef_lib_c1.el: Some hex to bitvector conversion functions
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


