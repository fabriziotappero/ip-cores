; Copyright 2013, Sinclair R.F., Inc.
; Test bench for synthesis tools:  simple LED flasher

.main

  0x01
  :forever

    ; toggle the LED
    0x01 ^ O_LED outport

    ; pause for 256*256*3 or so clock cycles
    0xFF :outer 0xFF :inner .jumpc(inner,1-) drop .jumpc(outer,1-) drop

  .jump(forever)
