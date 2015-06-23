; Copyright 2014, Sinclair R.F., Inc.
;
; Test bench for wide_strobe peripheral.

.main

  ; Wait a while
  ${25-1} :wait_startup .jumpc(wait_startup,1-) drop

  ; Exercise the minimum-width peripheral
  0x00 .outport(O_MIN)
  0x01 .outport(O_MIN)

  ; Exercise the medium-width peripheral
  ${2**4-1} :loop_medium O_MED outport .jumpc(loop_medium,1-) drop

  ; Exercise the maximum-width peripheral
  0x03 ${12-1} :loop_maximum >r O_MAX outport <<msb r> .jumpc(loop_maximum,1-) drop drop

  ; Wait a few clock cycles.
  ${3-1} :wait_end .jumpc(wait_end,1-) drop

  ; Send the termination signal and then enter an infinite loop.
  1 .outport(O_DONE)
  :infinite .jump(infinite)
