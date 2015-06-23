; Copyright 2013, Sinclair R.F., Inc.
;
; Test bench for big_output peripheral.

.main

  ; Write a 26-bit value.
  0x01 .outport(O_VB)
  0x02 .outport(O_VB)
  0x03 .outport(O_VB)
  0x04 .outport(O_VB)
  .outstrobe(O_WR_26BIT)

  ; Write an 18-bit value.
  0x10 0x20 0x03
  ${3-1} :loop swap .outport(O_VB) .jumpc(loop,1-) drop
  .outstrobe(O_WR_18BIT)

  ; Write a couple of 9-bit values.
  0x00 .outport(O_MIN)
  0x5A .outport(O_MIN)
  .outstrobe(O_WR_9BIT)
  0x01 .outport(O_MIN)
  0xA5 .outport(O_MIN)
  .outstrobe(O_WR_9BIT)

  ; Wait a few clock cycles.
  ${3-1} :wait .jumpc(wait,1-) drop

  ; Send the termination signal and then enter an infinite loop.
  1 .outport(O_DONE)
  :infinite .jump(infinite)
