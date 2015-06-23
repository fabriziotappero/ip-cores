(progn
  (load "../g1")
  (load "../l1")
  (load "../b1")
  (load "m1")
  (load "c1")
  (load "compressor")
  (load "components")
  
  (setq b 128)
  (setq w 4)
  (setq h (gen-tree b w ))
  (setq booth (generate-booth b))
  (setq net (generate-adder-network-from-booth both))
)




