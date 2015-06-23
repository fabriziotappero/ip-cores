(in-package #:mcasm)

(defun write-microprogram (&key (output-format :simulator))
  (with-assembly ("/tmp/microcode" :output-format output-format)
    (%set-type-imm $zero +type-int+)
    (%set-datum-imm $zero 0)
    (%set-type-imm $one +type-int+)
    (%set-datum-imm $one 1)
    (%set-type-imm $two +type-int+)
    (%set-datum-imm $two 2)

    (%set-type-imm $tmp1 +type-int+)
    (%set-type-imm $tmp2 +type-int+)

    ;; do something (here, an %add) #x42 times:
    (%set-datum-imm $tmp1 #x42)
    (%set-datum-imm $tmp2 0)
    :loop1
    (%add $tmp2 $one)
    (%decr $tmp1)
    (branchimm-false :loop1)

    ;; do something else (here, a %sub) #x4 times:
    (%set-datum-imm $tmp1 #x4)
    :loop2
    (%sub $tmp2 $one)
    (%decr $tmp1)
    (branchimm-false :loop2)

    (%halt)))
