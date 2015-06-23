;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Copyright 2012, Sinclair R.F., Inc.
;
; Print "Hello World" over a serial port.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.main

  C"Hello World\r\n"
  :loop 1- swap .outport(O_UART_TX) :wait .inport(I_UART_TX_BUSY) .jumpc(wait) .jumpc(loop,nop) drop

; Wait forever after the message is printed.
:forever .jump(forever)
