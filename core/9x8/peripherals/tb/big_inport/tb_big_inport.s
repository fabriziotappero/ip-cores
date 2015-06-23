; Copyright 2013, Sinclair R.F., Inc.
;
; Test bench for big_output peripheral.

.main

  ; Read a 26-bit value
  .outstrobe(O_VB_LATCH)
  .inport(I_VB)
  .inport(I_VB)
  .inport(I_VB)
  .inport(I_VB)

  ; Read a 9-bit value
  .outstrobe(O_MIN_LATCH)
  .inport(I_MIN)
  .inport(I_MIN)

  ; Dump all 6 bytes to the test bench
  ${6-1} :loop swap .outport(O_DIAG) .jumpc(loop,1-) drop

  ; Wait a few clock cycles.
  ${3-1} :wait .jumpc(wait,1-) drop

  ; Send the termination signal and then enter an infinite loop.
  1 .outport(O_DONE)
  :infinite .jump(infinite)
