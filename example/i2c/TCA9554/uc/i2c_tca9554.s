; Copyright 2014, Sinclair R.F., Inc.
;
; Notes:
;   - This uses a simple board with 5 on/off switches connected to the TCA9554
;     on pins P0, P1, P2, P4, and P5 and with an LED connected to P3.  The 3
;     address pins are held to ground by pull-down resistors.
;   - run in 400 kHz mode

.constant I2C_WR_ADDR   0x40
.constant I2C_RD_ADDR   0x41

.constant I2C_INPUT     0x00
.constant I2C_OUTPUT    0x01
.constant I2C_INVERT    0x02
.constant I2C_CONFIG    0x03

.include char.s

.include ../../lib_i2c.s

.main

N"\r\nUC Started\r\n" .call(uart_tx)

; Configure P3 as an output.  Hang if a NACK is received.
; Note:  bit=0 ==> output, bit=1 ==> input.
.call(i2c_send_start)
.call(i2c_send_byte,I2C_WR_ADDR)
.call(i2c_send_byte,I2C_CONFIG)  or
.call(i2c_send_byte,0xF7)        or
.call(i2c_send_stop)
.jumpc(hang)

; Configure P3 with a low signal to turn on the LED.  Hang if a NACK is received.
.call(i2c_send_start)
.call(i2c_send_byte,I2C_WR_ADDR)
.call(i2c_send_byte,I2C_OUTPUT)  or
.call(i2c_send_byte,0xF7)        or
.call(i2c_send_stop)
.jumpc(hang)

; Push the current state onto the data stack.
.call(read_state) 

:infinite

  ; Wait for the interrupt.
  ; Note:  This is disabled because the interrupt line either goes low for a
  ;        long time or goes low for a very short time.  The observed behavior
  ;        is not consistent with the data sheet.
  ; :wait_for_interrupt .inport(I_INT) 0= .jumpc(wait_for_interrupt)

  ; Read the device state until it changes and then display the new value.
  :wait_change .call(read_state) swap over - 0= .jumpc(wait_change)
  >r N"\r\n" r@ .call(char__byte_to_2hex) .call(uart_tx) r>

.jump(infinite)

; Error stack for NACK failure.
:hang
  N"NACK received\r\n" .call(uart_tx)
  :in_hang .jump(in_hang)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Read the switch settings.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ( - u )
.function read_state
  .call(i2c_send_start)
  .call(i2c_send_byte,I2C_WR_ADDR) drop
  .call(i2c_send_byte,I2C_INPUT)   drop
  .call(i2c_send_restart)
  .call(i2c_send_byte,I2C_RD_ADDR) drop
  .call(i2c_read_byte,1)
  .return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Output the null terminated string on the data stack.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ( '\0' u ... u - )
.function uart_tx
  :loop
    ; Wait for the UART to not be busy (there is no output FIFO).
    .inport(I_UART_TX_BUSY) .jumpc(loop)
    ; Send the next character
    .outport(O_UART_TX)
  ; Continue the loop if the next character is not the null character.
  .jumpc(loop,nop)
  ; Return and drop the terminating null character.
  .return(drop)
