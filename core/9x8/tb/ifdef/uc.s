; Copyright 2013, Sinclair R.F., Inc.
; Test Bench for conditional compilation

.IFDEF I_SCL
.main
  .ifdef(O_UART_TX) N"I2C Bus included\r\n" .call(uart_tx) .endif
  :infinite_1 .jump(infinite_1)
.ELSE
.main
  N"No I2C Bus\r\n" .call(uart_tx)
  :infinite_2 .jump(infinite_2)
.ENDIF

.function uart_tx
  .ifndef(O_UART_TX)
    ; Throw away the message.
    :loop_1 .jumpc(loop_1) .return
  .else
    ; Transmit the message bytes as the UART becomes available.
    :loop_2 .inport(I_UART_TX_BUSY) .jumpc(loop_2) .outport(O_UART_TX) .jumpc(loop_2,nop) .return(drop)
  .endif
