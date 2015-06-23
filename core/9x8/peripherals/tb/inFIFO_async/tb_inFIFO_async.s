; Copyright 2013, Sinclair R.F., Inc.
;
; Test bench for big_output peripheral.

.main

  ; Wait a few clock cycles.
  ${3-1} :wait0 .jumpc(wait0,1-) drop

  ; Read and output 10 values from the FIFO.
  ${10-1} :loop10
    .inport(I_EMPTY) .jumpc(loop10)
    .inport(I_DATA) .outport(O_DIAG)
  .jumpc(loop10,1-) drop

  ; Wait long enough for the FIFO to get full.
  ${15-1} :wait1 .jumpc(wait1,1-) drop

  ; Read a burst of 40 data values from the FIFO as fast as possible.
  .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA)
  .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA)

  .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA)
  .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA)

  .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA)
  .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA)

  .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA)
  .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA) .inport(I_DATA)

  ; Move these 40 values to the return stack.
  ${40-1} :move40 swap >r .jumpc(move40,1-) drop

  ; Write the 40 values to the output port in the order they were received.
  ${40-1} :loop40 r> .outport(O_DIAG) .jumpc(loop40,1-) drop

  ; Wait a few clock cycles.
  ${3-1} :wait2 .jumpc(wait2,1-) drop

  ; Send the termination signal and then enter an infinite loop.
  1 .outport(O_DONE)
  :infinite .jump(infinite)
