(progn
  (load "cdef_lib_b1")
  (load "cdef_lib_c1")
  (load "cdef_lib_g1")
  (load "cdef_lib_l1")
  (load "cdef_lib_m1")
  (load "cdef_lib_i1")
  (load "cdef_lib_h1")
  (load "cdef_lib_pc")
  (load "cdef_lib_pv")
)

(progn
  (if (load "cdef_lib_b1") ()(message "You have to set your elisp load-path variable, i.e: (setq load-path
      (append (list nil \"/home/eiselekd/vhdl_0.8/soft/cdef\") load-path)))"))
  (load "cdef_lib_c1")
  (load "cdef_lib_g1")
  (load "cdef_lib_l1")
  (load "cdef_lib_m1")
  (load "cdef_lib_i1")
  (load "cdef_lib_h1")
  (load "cdef_lib_pc")
  (load "cdef_lib_pv")

(setq insn-help '())


;;      list order   0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31
;;                  31   30   29   28   27   26   25   24   23   22   21   20   19   18   17   16   15   14   13   12   11   10   09   08   07   06   05   04   03   02   01   00
(setq insn_dp_i_s '( c    c    c    c    0    0    0   op1  op1  op1  op1  dps  rn   rn   rn   rn   rd   rd   rd   rd   sha  sha  sha  sha  sha  sh   sh    0   rm   rm   rm   rm  ))


(setq insn '(
  insn_dp_i_s 
 ))

(setq h (create-decoder-setenc (or-insn-set insn) insn 0))
;(insert (print-decoder h 0))
;(insert (print-decoder-c-pre h))
;(insert (print-decoder-c-structs insn insn-help))
(insert (print-decoder-vhd-pre h))

)
