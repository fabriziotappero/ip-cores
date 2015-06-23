(progn
  (load "cdef_lib_b1")
  (load "cdef_lib_c1")
  (load "cdef_lib_g1")
  (load "cdef_lib_l1")
  (load "cdef_lib_m1")
)

(setq a '(1 1 0 0))
(setq b '(1 0 0 0))
(setq c '(1 1 0 1))
(setq ac (make-setbit-groups a))
(setq bc (make-setbit-groups b))
(setq cc (make-setbit-groups c))

(setq dc (or-setbit-groups ac bc))
(or-setbit-groups dc cc)

(or-setbit-groups-func '((0) (1 1 )))1


(setq l '(2 3 4))
(setcdr l '(4))
l

(setq a1 (hex-to-bitstring "ff"))
(setq b1 (hex-to-bitstring "f0"))
(setq c1 (make-undef-bitstring a b))

(setq a2 (hex-to-bitstring "ff"))
(setq b2 (hex-to-bitstring "f8"))
(setq c2 (make-undef-bitstring a b))

(setq cc c2)

(setq cu (make-set-bitstring c2))




(setq h (make-hash-table))
(puthash 'a a h)
(puthash 'b 2 h)
(puthash 'c 3 h)

(list (gethash 'c h) (gethash 'a h))


