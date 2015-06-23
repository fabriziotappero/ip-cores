; Copyright 2012, Sinclair R.F., Inc.
;
; Example LED flasher using 8-bit data

; Consume 256*5+3 clock cycles.
; ( - )
.function pause
  0 :inner 1- dup .jumpc(inner) drop
.return

; Repeat "pause" 256 times.
; ( - )
.function repause
  0 :inner .call(pause) 1- dup .jumpc(inner) drop
.return

; main program (as an infinite loop)
.main
  0 :inner 1 ^ dup .outport(O_LED) .call(repause) .jump(inner)
