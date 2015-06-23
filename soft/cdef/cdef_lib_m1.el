; Konrad Eisele <eiselekd@web.de>
; cdef_lib_m1.el: Some math functions
;-----------------------------------------------------------------------

(defun in-bound-p (start end pos) 
  (and (>= pos start) (< pos end)))


(defun insn32o (n)      
  (- 31 n))

(defun insn32o (n)      
  (+ (- 31 n) 1))

