; Copyright 3012, Sinclair R.F., Inc.
;
; Test bench for timer peripheral.

.main

; Send a strobe whenever one of the timers is detected as expired.  Terminate
; when timer 3 expires.
:infinite

  .inport(I_TIMER_0) 0= .jumpc(not_0) 0 .outport(O_EVENT) :not_0
  .inport(I_TIMER_1) 0= .jumpc(not_1) 1 .outport(O_EVENT) :not_1
  .inport(I_TIMER_2) 0= .jumpc(not_2) 2 .outport(O_EVENT) :not_2
  .inport(I_TIMER_3) 0= .jumpc(not_3) 3 .outport(O_EVENT) 1 .outport(O_DONE) :not_3

.jump(infinite)
