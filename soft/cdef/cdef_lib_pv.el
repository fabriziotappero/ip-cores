; Konrad Eisele <eiselekd@web.de>
; cdef_lib_i1.el: Some vhdl printing functions
;-----------------------------------------------------------------------

; binary list to hex string
; (conv-hex-vhd '(0 0 1 1 1 ))
; (conv-hex-vhd (make-list 10 1))
(defun conv-hex-vhd (k)
  (concat "\"" (mapconcat 'number-to-string k "") "\"")
)

(defun print-decode-vhd-hash (dec depth)
  (cond 
     ((hash-table-p dec)
     (let ((p ""))
       ( maphash (function (lambda (k v)
	 (let ((p2 ""))
	   (setq p2 (concat p2 (space-string (- depth 1) " ") "when " (conv-hex-vhd k) "=>\n"   ))
	   (if (is-decoder v)
	       (setq p2 (concat p2 (print-decoder-vhd v depth)))
	       (setq p2 (concat p2 (space-string depth  " ") "return " (mapconcat 'symbol-name v "," ) ";\n"))
	   )
	   (setq p (concat p p2))
	 ))) dec )
       `,p
     ))
     ((listp dec)
      (mapconcat 'print-list dec " ")
     )
     ((t) ('"?")))
)

;(print-insnrange-vhd 10 1)
(defun print-insnrange-vhd (l r)
  (concat "insn(" (number-to-string l) " downto " (number-to-string r) ")")
)

(defun print-decoder-vhd (d depth)
  (let ((l (- 31 (nth 1 d)))
	(r (+ (- 31 (nth 2 d)) 1))
	(dec (nth 3 d))
	(def (nth 4 d))
        (p ""))
    (if (not (and (eq l 31) (eq r 32)))
        (progn
	  (setq p (concat p (space-string depth " ") "case " (print-insnrange-vhd l r) " is  \n"  ))
	  (setq p (concat p (print-decode-vhd-hash dec (+ 1 depth) ) ))
	  (setq p (concat p (space-string depth " ") "when others =>\n" (space-string depth " ") "end case;\n"))
        )
    )
    (if (eq (length def) 5)
	(if (and (eq (nth 0 def) 0) (eq (nth 1 def) 0) (> (length (nth 4 def)) 0))
	    (setq p (concat p (space-string depth " ")  "return " (mapconcat 'symbol-name (nth 4 def)  " ") "; --default\n" ))
	    (setq p (concat p (space-string depth " ")  " -- default:\n" (space-string depth " ") (print-decoder-vhd def depth)  ) )
	)
    )
    `,p
  )
)

(defun print-decoder-vhd-pre (d)
  (let ((v ""))
    (setq v (print-decoder-vhd d 0))
    ;(setq v (concat "unsigned int decode(unsigned int insn, insn_union *s) {\n" v "\n};"))
    `,v
  )
)
  
;-----------------------------------------------------------------------

