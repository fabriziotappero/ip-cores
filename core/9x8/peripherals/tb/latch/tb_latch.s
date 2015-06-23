; Copyright 2012, Sinclair R.F., Inc.
;
; Test bench for latch peripheral.

.main
  
  ${3-1} :loop

    ; test 9-bit latch
    O_9LATCH outport
    0 .outport(O_9ADDR) .inport(I_9READ) .outport(O_TEST)
    1 .outport(O_9ADDR) .inport(I_9READ) .outport(O_TEST)

    ; test 24-bit latch
    O_24LATCH outport
    0 .outport(O_24ADDR) .inport(I_24READ) .outport(O_TEST)
    1 .outport(O_24ADDR) .inport(I_24READ) .outport(O_TEST)
    2 .outport(O_24ADDR) .inport(I_24READ) .outport(O_TEST)

    .jumpc(loop,1-) drop

  ; end of test
  1 .outport(O_DONE)
  :infinite .jump(infinite)
