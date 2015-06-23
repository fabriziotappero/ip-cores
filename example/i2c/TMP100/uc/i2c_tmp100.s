; Copyright 2012, 2014, Sinclair R.F., Inc.
;
; TMP100:
;   run in 400 kHz mode

.constant C_TMP100_U14 ${9*16+2*2}
.constant C_TMP100_U15 ${9*16+0*2}
.constant C_TMP100_U16 ${9*16+6*2}
.constant C_TMP100_U18 ${9*16+4*2}

.include ../../lib_i2c.s

.main

  :infinite
    "\r\n\0"
    ${C_TMP100_U18|0x01} .call(get_i2c_temp)    ; right-most displayed value
    ${C_TMP100_U16|0x01} .call(get_i2c_temp)
    ${C_TMP100_U15|0x01} .call(get_i2c_temp)
    ${C_TMP100_U14|0x01} .call(get_i2c_temp)
    :print_loop
      .outport(O_UART_TX)
      :print_wait .inport(I_UART_TX) .jumpc(print_wait)
      .jumpc(print_loop,nop) drop
    .call(wait_1_sec)
  .jump(infinite)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Read the I2C temperature sensor and put the ascii value on the stack.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.function get_i2c_temp
  0x20
  .call(i2c_send_start)
  .call(i2c_send_byte,swap) .jumpc(error)
    .call(i2c_read_byte,0) >r
    .call(i2c_read_byte,0) .call(byte_to_hex)
    r> .call(byte_to_hex)
    .jump(no_error)
  :error
    "----"
  :no_error
  .call(i2c_send_stop)
.return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Convert a byte to a two digit hex value.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.memory RAM ram
.variable nibble_to_ascii "0123456789ABCDEF"

; ( u - ascii(lower_nibble(u)) ascii(upper_nibble(u)) )
.function byte_to_hex

  dup 0x0F & .fetchindexed(nibble_to_ascii)
  swap 0>> 0>> 0>> 0>> .fetchindexed(nibble_to_ascii)

.return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Wait one second with a 100 MHz clock.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.function wait_1_sec

  ; 100 iterations
  ${100-1} :outer
    ; 1000 iterations
    ${4-1} :mid_outer
      ${250-1} :mid_inner
        ; 1000 clock cycles (250 iterations of 4 clock loop)
        250 :inner 1- .jumpc(inner,nop) drop
      .jumpc(mid_inner,1-) drop
    .jumpc(mid_outer,1-) drop
  .jumpc(outer,1-) drop

.return
