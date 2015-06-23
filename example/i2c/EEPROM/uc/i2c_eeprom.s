; Copyright 2012, Sinclair R.F., Inc.
;
; I2C EEPROM design example:
; Write a 16-byte string to the EEPROM and then read and display it.

.constant C_I2C_EEPROM_ADDR ${0xa*16+0x4*2}

.include ../../lib_i2c.s

.memory RAM ram
.variable ram__msg 0*16

.memory ROM messages
.variable msg__bad_device_number        N"Bad Device Number"
.variable msg__write_address_rejected   N"Write Address Rejected"
.variable msg__rejected_data            N"Data Rejected"
.variable msg__read_address_rejected    N"Read Address Rejected"
.variable msg__read_state_rejected      N"Read State Rejected"

.main

  ; Write a 16-byte, null-terminated string to the EEPROM.
  C"Hello World!!\r\n\0"
  .call(i2c_send_start)
  .call(i2c_send_byte,${C_I2C_EEPROM_ADDR|0}) .jumpc(error__bad_device_number)
  .call(i2c_send_byte,0) .jumpc(error__write_address_rejected)
  :write_loop
    1- .call(i2c_send_byte,swap) .jumpc(error__rejected_data)
    .jumpc(write_loop,nop) drop
  .call(i2c_send_stop)

  ;
  ; Read the null-terminated string from the EEPROM (after the write cycle finishes)
  ;

  ; Put the address on the bus until the EEPROM acknowledges it.
  :write_wait
    .call(i2c_send_start)
    ${C_I2C_EEPROM_ADDR|0} .call(i2c_send_byte) 0= .jumpc(write_wait_done)
    .call(i2c_send_stop)
    .jump(write_wait)
  :write_wait_done

  ; Send the start address for the reads followed by a start (with no stop)
  0 .call(i2c_send_byte) .jumpc(error__read_address_rejected)
  .call(i2c_send_restart)

  ; Put the EEPROM into the read state
  ${C_I2C_EEPROM_ADDR|1} .call(i2c_send_byte) .jumpc(error__read_state_rejected)

  ; Read the EEPROM and write each byte to memory until the null terminator is
  ; encountered.  Add the CRLF pair
  ram__msg >r
  :read_loop
    .call(i2c_read_byte,0)
    dup r> .store+(ram) >r .jumpc(read_loop)
  r> drop

  ; Send the string copied from the EEPROM to the UART.
  ram__msg
  :uart_loop .fetch+(ram) over 0= .jumpc(uart_done)
    swap .outport(O_UART_TX)
    :uart_wait .inport(I_UART_TX) .jumpc(uart_wait)
    .jump(uart_loop)
  :uart_done
    drop drop .jump(infinite)

  :error__bad_device_number
    .jump(error_with_clear,msg__bad_device_number)
  :error__write_address_rejected
    .jump(error_with_clear,msg__write_address_rejected)
  :error__rejected_data
    .jump(error_with_clear,msg__rejected_data)
  :error__read_address_rejected
    .jump(error_print_done,msg__read_address_rejected)
  :error__read_state_rejected
    .jump(error_print_done,msg__read_state_rejected)
  ; Print the error message and then wait forever.
  :error_with_clear
    >r
    ; clear the count-encoded string from the data stack
    :clear 1- .jumpc(clear,nip) drop
    ; read and display the error message
    r>
  :error_print_loop
    .fetch+(messages) over 0= .jumpc(error_print_done)
    swap .outport(O_UART_TX)
    :error_print_wait .inport(I_UART_TX) .jumpc(error_print_wait)
    .jump(error_print_loop)
  :error_print_done
    drop drop

  :infinite
    .jump(infinite)

