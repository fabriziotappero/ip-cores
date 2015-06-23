
;----------------------------------------------------------------

;(setq l (gen-4-2 "a1" "b1" "c1" "dd1" "carry1"))
;(print-list l)
(defun gen-4-2 (a1 b1 c1 d1 carry)
  (let ((id (get_comp_id))
	(cmp )
       )
       (setq cmp (create-component (get-4-2-name id)))
       (create-input cmp "ia" a1)
       (create-input cmp "ib" b1)
       (create-input cmp "ic" c1)
       (create-input cmp "id" d1)
       (create-input cmp "icarry" carry)
       (create-output cmp "osum" (get-4-2-sum id))
       (create-output cmp "ocarry" (get-4-2-carry id))
       (create-output cmp "ocout" (get-4-2-cout id))
       `(,id ,cmp)
  )
)

(defun get-4-2-name (i)
  (format "comp_4_2_id%.3i" i)
)

(defun get-4-2-sum (i)
  (format "comp_4_2_%.3i_sum" i)
)

(defun get-4-2-carry (i)
  (format "comp_4_2_%.3i_c" i)
)

(defun get-4-2-cout (i)
  (format "comp_4_2_%.3i_cout" i)
)

;----------------------------------------------------------------

;(setq l (gen-fa "a1" "b1" "carry1"))
;(print-list l)
(defun gen-fa (a1 b1 carry)
  (let ((id (get_comp_id))
	(cmp )
       )
       (setq cmp (create-component (get-fa-name id)))
       (create-input cmp "ia" a1)
       (create-input cmp "ib" b1)
       (create-input cmp "icarry" carry)
       (create-output cmp "osum" (get-fa-sum id))
       (create-output cmp "ocout" (get-fa-cout id))
       `(,id ,cmp)
  )
)

(defun get-fa-name (i)
  (format "comp_fa_id%.3i" i)
)

(defun get-fa-sum (i)
  (format "comp_fa_%.3i_sum" i)
)

(defun get-fa-cout (i)
  (format "comp_fa_%.3i_cout" i)
)

