; Copyright 2012, Sinclair R.F., Inc.
;
; Test bench for PWMs peripheral.

.main

  ; Wait for a while to ensure the outputs are all zero before a non-zero PWM is
  ; commanded.
  .call(wait,${2-1})

  ; Issue identical commands to the singleton PWM controllers
  0xC0 .outport(O_PWM_SR)
  0xC0 .outport(O_PWM_SN)
  0xC0 .outport(O_PWM_SI)

  ; Issue a command to the triple-PWM controller using the example function
  ; from the peripheral help message.
  0xFE 0x39 0x38 O_PWM_MULTI_0 .call(set_pwm_multi,${3-1})

  ; Let the system run for 3 PWM cycles
  .call(wait,${3-1})

  ; Issue another set of PWM commands.  Cause runt pulses on unprotected PWMs
  ; for the singleton PWM channels.  Test full on and full off conditions.
  0x10 O_PWM_SR outport O_PWM_SN outport O_PWM_SI outport drop
  0xFF 0x00 0x01 O_PWM_MULTI_0 .call(set_pwm_multi,${3-1})

  ; Let the system run for 3 PWM cycles
  .call(wait,${3-1})

  ; Send the termination signal and then enter an infinite loop.
  1 .outport(O_DONE)
  :infinite .jump(infinite)


; Wait for the commanded number of complete PWM cycles
; Note:  The 100 MHz clock frequency, 6000 Hz PWM rate, and 3 clocks per
;        inner-most wait cycle means that 100e6/6000/3=5555 loop iterations
;        are needed.  Since 5555/256=21.7, a 22*256 loop will be
;        slightly longer than the desired delay and will help validate the runt
;        removal.
; ( u_wait_minus_1 - )
.function wait
  :loop_commanded
    ${22-1} :loop_outer
      ${256-1} :loop_inner .jumpc(loop_inner,1-) drop
    .jumpc(loop_outer,1-) drop
  .jumpc(loop_commanded,1-)
.return(drop)


; ( u_pwm_multi_{n-1} ... u_pwm_multi_1 u_pwm_multi_0 U_OUTPORT u_count_minus_1 - )
.function set_pwm_multi
  :loop >r swap over outport drop 1+ r> .jumpc(loop,1-) drop
.return(drop)
