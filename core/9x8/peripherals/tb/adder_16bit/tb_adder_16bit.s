; Copyright 2012, Sinclair R.F., Inc.
;
; Test bench for adder_16bit peripheral.

.include adder_16bit.s

.main

  ; eat a few cycles
  ${2-1} :loop .jumpc(loop,1-) drop

  ; 0x1234 + 0x5678
  0x34 0x12 0x78 0x56 .call(addsub_u16_u16__u16,0) .outport(O_V_OUT) .outport(O_V_OUT)
  ; 0x5678 - 0x1234
  0x78 0x56 0x34 0x12 .call(addsub_u16_u16__u16,1) .outport(O_V_OUT) .outport(O_V_OUT)
  ; 0xFFFF + 0x0001
  0xFF 0xFF 0x01 0x00 .call(addsub_u16_u16__u16,0) .outport(O_V_OUT) .outport(O_V_OUT)
  ; 0xFFFF + 0x0100
  0xFF 0xFF 0x00 0x01 .call(addsub_u16_u16__u16,0) .outport(O_V_OUT) .outport(O_V_OUT)
  ; 0x0000 - 0x0001
  0x00 0x00 0x01 0x00 .call(addsub_u16_u16__u16,1) .outport(O_V_OUT) .outport(O_V_OUT)

  ; signal the end of the test and enter an infinite loop.
  1 .outport(O_DONE)
  :infinite .jump(infinite)
