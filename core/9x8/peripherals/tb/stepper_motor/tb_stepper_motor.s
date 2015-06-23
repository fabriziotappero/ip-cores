; Copyright 2015, Sinclair R.F., Inc.
;
; Test bench for stepper_motor peripheral.

.macro push16
.macro push24

.main

  ; Forward acceleration.
  .push24(${10-1})      ; 10 steps
  .push16(3436)         ; 50_000 step/sec^2 (50e3*2**34/F**2 where F=5.e5)
  .push16(0)            ; initial rate = 0
  .call(push_command)

  ; Continue uniform motion.
  .push24(${10-1})      ; 10 steps
  .push16(0)            ; no acceleration
  .push16(131)          ; 1000 step/sec (1.e3*2**16/F)
  .call(push_command)

  ; Decelerate to stop motion.
  .push24(${10-1})      ; 10 steps
  .push16(-3432)        ; -50_000 step/sec^2 (actual -v**2/(2*10) ==> 3432.2)
  .push16(131)          ; 1000 step/sec
  .call(push_command)

  ; Accelerate in negative direction.
  .push24(${10-1})      ; 10 steps
  .push16(-3436)        ; -50_000 step/sec^2
  .push16(-1)           ; ~0 step/sec
  .call(push_command)

  ; Continue uniform motion.
  .push24(${10-1})      ; 10 steps
  .push16(0)            ; no acceleration
  .push16(-131)         ; 1000 step/sec (1.e3*2**23/F)
  .call(push_command)

  ; Decelerate to stop motion.
  .push24(${10-1})      ; 10 steps
  .push16(3432)         ; -50_000 step/sec^2
  .push16(-131)         ; 1000 step/sec (1.e3*2**23/F)
  .call(push_command)

  ; Command the motion profile to run.
  .outstrobe(O_GO)

  ; Wait for the profile to finish.
  :loop_wait .inport(I_DONE) 0= .jumpc(loop_wait)

  ; Wait about 10 usec
  ${(10*8)/3} :wait_done .jumpc(wait_done,1-) drop

  ; Indicate termination to the test bench.
  1 .outport(O_DONE)

  ; Wait forever
  :infinite .jump(infinite)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Stepper motor utilities.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.constant       C_RATE_WIDTH    ${C_RATE_RES-C_RATE_SCALE+1}
.constant       C_ACCEL_WIDTH   ${1+C_ACCEL_RES-C_ACCEL_SCALE}
.constant       C_NBYTES        ${int((C_RATE_WIDTH+7)/8)+int((C_ACCEL_WIDTH+7)/8)+int((C_COUNT_WIDTH+7)/8)}

; Send the control word on the stack to the stepper motor peripheral and record it in the FIFO.
; ( u_count_LSB ... u_accel_LSB ... u_rate_MSB - )
.function push_command
  ${C_NBYTES-1} :loop swap .outport(O_CONTROLWORD) .jumpc(loop,1-) drop
  .outstrobe(O_CONTROLWORD_WR)
  .return
