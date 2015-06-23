(progn
  (load "../g1")
  (load "../l1")
  (load "c1")

  (setq b 4)
  (setq w 2)
  (setq h (gen-tree b w ))
  (insert (print-cnt h w "base"))

)







