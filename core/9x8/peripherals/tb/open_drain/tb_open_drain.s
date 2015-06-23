; Copyright 2012, Sinclair R.F., Inc.
;
; Test bench for open_drain peripheral.

.main

  ; eat a few cycles
  ${2-1} :loop .jumpc(loop,1-) drop

  ; exercise the input and output port
  0x01 .outport(O_ENV)
  0xFF .outport(O_OD)
  0x55 .outport(O_OD)
  0x00 .outport(O_OD)
  0xAA .outport(O_OD)
  .inport(I_OD) 0xFF ^ .outport(O_OD)
  .inport(I_OD) <<msb .outport(O_OD)
  0xFF .outport(O_OD)
  0x00 .outport(O_ENV)

  ; end of test
  :infinite .jump(infinite)
