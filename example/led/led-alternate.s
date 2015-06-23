; Copyright 2012, Sinclair R.F., Inc.
;
; Example LED flasher using 8-bit data

; push the LED setting onto the stack
0

; target for the outer loop
:l00

; update the LED setting
1 ^ dup .output(C_LED)

; consume 256 iteractions of the clock cycle consumpsion
0 :l01
  ; consume 256*6+2 clock cycles
  0 :l02 1 - dup .jumpc(l02) drop
1 - dup .jumpc(l01) drop

; outer loop
.jump(l00)
