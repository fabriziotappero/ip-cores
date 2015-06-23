; Copyright 2013, Sinclair R.F., Inc.
;
; Test bench for big_output peripheral.

.main

  ; Write 64 unqiue values to the FIFO whenever possible.
  ${64-1} :loop
    .inport(I_FULL) .jumpc(loop)
    O_DATA outport
  .jumpc(loop,1-) drop

  ; Wait for the FIFO to become empty
  :wait .inport(I_EMPTY) 0= .jumpc(wait)

  ; Send the termination signal and then enter an infinite loop.
  1 .outport(O_DONE)
  :infinite .jump(infinite)
