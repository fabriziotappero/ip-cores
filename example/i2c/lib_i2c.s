;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Copyright 2012, 2014, Sinclair R.F., Inc.
;
; Major I2C functions:
;   i2c_send_start      ( - )           send the start condition
;   i2c_send_restart    ( - )           send a restart after ACK during write
;   i2c_send_byte       ( u - f )       send a byte (address, register, data, ...)
;   i2c_read_byte       ( f - u )       read a byte and either ACK (f=0) or STOP (f=1)
;   i2c_send_stop       ( - )           send a stop after ACK during write
;
; Example to set a single register (ignoring returned ACK/NACK value)
;   .call(i2c_send_start)
;   .call(i2c_send_byte,write_address) drop
;   .call(i2c_send_byte,register) drop
;   .call(i2c_send_byte,data) drop
;   .call(i2c_send_stop)
;
; Example to read two bytes (ignoring returned ACK/NACK value)
;   .call(i2c_send_start)
;   .call(i2c_send_byte,write_address) drop
;   .call(i2c_send_byte,register) drop
;   .call(i2c_send_restart)
;   .call(i2c_send_byte,read_address) drop
;   .call(i2c_read_byte,0)
;   .call(i2c_read_byte,1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Compute how many iterations in the quarter-clock-cycle function are required.
;   ceil(100 MHz / 400 kHz / 4) ==> 63 clock cycles per I2C SCL quarter cycle
;   The function consumes:
;     3 clock cycles to call the function
;     3 clock cycles for the "outport(O_SCL)"
;     1 clock cycle to initialize the loop count
;     2 clock cycles to return
;     9 TOTAL
;   Add 2 to ensure rounding up when evaluting the integer fraction.
;   The loop is 3 clock cycles per iteration
.IFNDEF C_I2C_QUARTER_CYCLE
.constant C_I2C_QUARTER_CYCLE ${max(1,(63-9+2)/3)}
.ENDIF

; ( - )
.function i2c_send_start
  0 .outport(O_SDA)
  .call(i2c_quarter_cycle,1)
  .call(i2c_quarter_cycle,0)
.return

; Set a start without the preceding stop.
; ( - )
.function i2c_send_restart
  .call(i2c_quarter_cycle,0)
  .call(i2c_quarter_cycle,1)
  0 .outport(O_SDA) .call(i2c_quarter_cycle,1)
  .call(i2c_quarter_cycle,0)
.return

; Send the byte and indicate false if the acknowledge bit was received.
; ( u - f )
.function i2c_send_byte
  ; send the byte, msb first
  ; ( u - )
  ${8-1} :outer
    ; send the next bit
    swap <<msb swap
    .call(i2c_clock_cycle,over) drop
  .jumpc(outer,1-) drop drop
  ; get the acknowledge bit at the middle of the high portion of SCL
  ; ( - f )
  .call(i2c_clock_cycle,1)
.return

; Read the next byte from the device and generate an ACK or a STOP.
; ( f - u )
.function i2c_read_byte
  ; Read 8 bits and pack them into the returned value.
  ; ( f - u f )
  0 ${8-1} :loop
    swap <<0 .call(i2c_clock_cycle,1) or swap
  .jumpc(loop,1-) drop
  swap
  ; Generate the ACK/STOP based on f.
  ; ( u f - u )
  0 .outport(O_SDA)
  .call(i2c_quarter_cycle,0)
  .call(i2c_quarter_cycle,1)
  O_SDA outport
  .call(i2c_quarter_cycle,1)
  .call(i2c_quarter_cycle)      ; SCL is high on STOP, low on ACK, consumes f
.return

; Send a stop by bringing SDA high while SCL is high.
; ( - )
.function i2c_send_stop
  0 .outport(O_SDA) .call(i2c_quarter_cycle,0)
  .call(i2c_quarter_cycle,1)
  1 .outport(O_SDA) .call(i2c_quarter_cycle,1)
.return

; Send the clock as a "0110" pattern and sample SDA in the middle of the high
; portion.
; ( u_sda_out - u_sda_in )
.function i2c_clock_cycle
  .outport(O_SDA)
  .call(i2c_quarter_cycle,0)
  .call(i2c_quarter_cycle,1)
  .inport(I_SDA)
  .call(i2c_quarter_cycle,1)
  .call(i2c_quarter_cycle,0)
.return

; Output the I2C SCL value and then wait for a quarter of the I2C clock cycle.
; ( u_scl - )
.function i2c_quarter_cycle
  .outport(O_SCL)
  ${C_I2C_QUARTER_CYCLE-1} :loop .jumpc(loop,1-)
.return(drop)
