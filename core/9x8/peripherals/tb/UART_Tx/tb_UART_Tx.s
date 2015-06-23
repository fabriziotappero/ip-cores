; Copyright 2012, Sinclair R.F., Inc.
;
; Test bench for UART_Tx peripheral.

.main

  .call(load_message) :loop1 .outport(O_UART1_TX) .jumpc(loop1,nop) drop
  .call(load_message) :loop2 .outport(O_UART2_TX) .jumpc(loop2,nop) drop
  .call(load_message) :loop3 .outport(O_UART3_TX) :wait3 .inport(I_UART3_TX) .jumpc(wait3) .jumpc(loop3,nop) drop

  :wait .inport(I_UART3_TX) .jumpc(wait)
  1 .outport(O_DONE)

  :infinite .jump(infinite)


.function load_message
  N"ello World!"
.return('H')
