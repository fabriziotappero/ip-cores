; Copyright 2013, Sinclair R.F., Inc.
;
; Test bench for counter peripheral.

.main

  ; Run the test 4 times.
  ${4-1} :loop_run_test
    ; Wait a while
    ${3-1} :wait_outer 0xFF :wait_inner .jumpc(wait_inner,1-) drop .jumpc(wait_outer,1-) drop
    ; Read and output the narrow count.
    .inport(I_STROBE_NARROW) 0x00 .outport(O_DIAG_MSB) .outport(O_DIAG_LSB) .outstrobe(O_DIAG_WR)
    ; Latch, read, and output the wide count.
    .outstrobe(O_LATCH_STROBE_WIDE) .inport(I_STROBE_WIDE) .inport(I_STROBE_WIDE) .outport(O_DIAG_MSB) .outport(O_DIAG_LSB) .outstrobe(O_DIAG_WR)
  .jumpc(loop_run_test,1-) drop

  ; Signal termination and then wait forever.
  .outstrobe(O_DONE) :infinity .jump(infinity)
