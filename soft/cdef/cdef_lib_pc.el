; Konrad Eisele <eiselekd@web.de>
; cdef_lib_i1.el: Some c printing functions
;-----------------------------------------------------------------------

; binary list to hex string
; (conv-hex-c '(0 0 1 1 1 ))
; (conv-hex-c (make-list 10 1))
(defun conv-hex-c (k)
  (let ((e 0)
	(i 1)
	(v 0))
  (dolist (e k v)
     (if (eq e 1)
	 (setq v (+ v i))
     )
     (setq i (* i 2))
  )
  (format "0x%x" v)
  )
)

(defun print-decode-c-hash (dec depth)
  (cond 
     ((hash-table-p dec)
     (let ((p ""))
       ( maphash (function (lambda (k v)
	 (let ((p2 ""))
	   (setq p2 (concat p2 (space-string (- depth 1) " ") "case " (conv-hex-c k) ":\n" (space-string (- depth 1) " ") "{" ))
	   (if (is-decoder v)
	       (setq p2 (concat p2 "\n" (print-decoder-c v depth)))
	       (setq p2 (concat p2 "return init_" (mapconcat 'symbol-name v "," ) "(insn,s);\n"))
	   )
	   (setq p (concat p p2 (space-string (- depth 1) " ") "};break;\n"))
	 ))) dec )
       `,p
     ))
     ((listp dec)
      (mapconcat 'print-list dec " ")
     )
     ((t) ('"?")))
)

(defun print-insnrange-c (l r)
  (concat "((insn>>" (number-to-string r) ")&" (conv-hex-c (make-list (+ (- l r) 1) 1)) ")")
)

(defun print-decoder-c (d depth)
  (let ((l (- 31 (nth 1 d)))
	(r (+ (- 31 (nth 2 d)) 1))
	(dec (nth 3 d))
	(def (nth 4 d))
        (p ""))
    (if (not (and (eq l 31) (eq r 32)))
        (progn
	  (setq p (concat p (space-string depth " ") "{\n" (space-string depth " ") "switch (" (print-insnrange-c l r) ") { \n"  ))
	  (setq p (concat p (print-decode-c-hash dec (+ 1 depth) ) (space-string depth " ") "}}\n" ))
        )
    )
    (if (eq (length def) 5)
	(if (and (eq (nth 0 def) 0) (eq (nth 1 def) 0) (> (length (nth 4 def)) 0))
	    (setq p (concat p (space-string depth " ")  "/*default:*/ return init_" (mapconcat 'symbol-name (nth 4 def)  " ") "(insn,s);\n" ))
	    (setq p (concat p (space-string depth " ")  "/*default:*/\n" (print-decoder-c def depth)))
	)
    )
    `,p
  )
)

(defun print-decoder-c-pre (d)
  (let ((v ""))
    (setq v (print-decoder-c d 0))
    (setq v (concat "unsigned int decode(unsigned int insn, insn_union *s) {\n" v "\n};"))
    `,v
  )
)
  
;-----------------------------------------------------------------------

(defun retrive-help (insn-help entry)
  (let ((v "")
	(e '()))
    (dolist (e insn-help v)
      (if (eq (symbol-name (nth 0 e)) entry)
	  (setq v (nth 1 e))
      )
    )
  )
)

(defun print-decoder-c-struct-rec (a) 
   (if (> (length a) 0)
      (let ((n (count-bits a))
	    (e (nth 0 a)))
	(append (print-decoder-c-struct-rec (nthcdr n a)) `((,n ,e)))
      )
      '()
   )
)

(defun print-decoder-c-structs (insn insn-help)
  (let ((a 0)
	(v1 "")
	(v2 "")
	(v3 "typedef union _insn_union {\n")
	(v4 ""))
    (dolist (a insn)
      (let ((e 0)
	    (v '())
	    (l 31)
	    (r 32))
	(setq v (reverse (print-decoder-c-struct-rec (symbol-value a))))
	(setq v1 (concat v1 "typedef struct _" (symbol-name a) "_struct {\n/*" (retrive-help insn-help (symbol-name a)) "*/\n  int (*func) (struct _" (symbol-name a) "_struct *s, proc_state *state);\n"))
	(setq v2 (concat v2 "unsigned int init_" (symbol-name a) "(unsigned int insn, insn_union *s) {\n" "s->"(symbol-name a) ".func=func_" (symbol-name a) ";\n"  ))
	(setq v3 (concat v3 "  " (symbol-name a) "_struct " (symbol-name a) ";\n"))
	(setq v4 (concat v4 "int func_" (symbol-name a) " (struct _" (symbol-name a) "_struct *s, proc_state *state) {\n/*" (retrive-help insn-help (symbol-name a)) "*/\n};\n"))
	(dolist (e v)
	  (setq r (- r (nth 0 e)))
	  (if (not (or (eq (nth 1 e) 1) (eq (nth 1 e) 0)))
	    (progn 
	      (setq v1 (concat v1 "  unsigned int " (print-list (nth 1 e)) ": " (number-to-string (+ (- l r) 2)) "; /*" (retrive-help insn-help (print-list (nth 1 e)))  "*/\n" ))
	      (setq v2 (concat v2 "s->"(symbol-name a) "." (print-list (nth 1 e)) "=" (print-insnrange-c l r ) ";\n" ))
	    )
          )
	  (setq l (- r 1));
	)
	(setq v1 (concat v1 "} " (symbol-name a) "_struct;\n"))
	(setq v2 (concat v2 " return 1;};\n "))
      )
    )


    (setq v3 (concat v3 "} insn_union;\n "))
    (concat "typedef struct _proc_state {} proc_state;\n" v1 v3 v4 v2  )
  )
)


;-----------------------------------------------------------------------

