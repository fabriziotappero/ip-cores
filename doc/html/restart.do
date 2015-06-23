;# This is a Modelsim PE/Plus 5.3a_p1 macro file.
;#

;# Compile pAVR test architectures.
do test_pavr_compile.do

;# Restart simulation
restart -f

;# General test 1
run 150000

;# General test 2
;#run 15000


