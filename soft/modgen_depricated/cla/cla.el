(progn
  (load "../g1")
  (load "../l1")
  (load "../b1")
  (load "c1")

  (setq b 128)
  (setq w 4)
  (setq h (gen-tree b w ))
  
  (insert (print-generate-propagate-rec h))

)


