; Copyright 2015, Sinclair R.F., Inc.
;
; Test bench for servo_motor peripheral.

.main

; Wait for two cycles of the default servo settings pass.
${2-1} :loop_startup .inport(I_triple) 0= .jumpc(loop_startup) .jumpc(loop_startup,1-) drop

; Modify the servo settings and wait for two cycles.
  0 .outport(O_triple_0)
125 .outport(O_triple_1)
250 .outport(O_triple_2)
${2-1} :loop_first .inport(I_triple) 0= .jumpc(loop_first) .jumpc(loop_first,1-) drop

; Signal program termination.
0x01 .outport(O_DONE)

; Wait forever.
:infinite .jump(infinite)
