; Copyright 2014, Sinclair R.F., Inc.
; Test bench for UART peripheral with CTS/CTSn and RTR/RTRn flow controls
; enabled.

.main

; Put a message significantly longer than 24 bytes on the data stack.
N"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

; Transmit bytes to UART1 until its FIFO is full.
:out_uart1 .outport(O_UART1_TX) .inport(I_UART1_TX_BUSY) 0= .jumpc(out_uart1)

; Wait 100 usec on a 10 MHz clock ==> wait 1000 clock cycles.
${(1000/4)-1} :wait nop .jumpc(wait,1-) drop

; Loop until the 'z' makes it out from UART4.
:loop
  dup 0= .jumpc(no_UART1)
    .inport(I_UART1_TX_BUSY) .jumpc(no_UART1)
    .outport(O_UART1_TX)
  :no_UART1
  .inport(I_UART2_RX_EMPTY) .inport(I_UART2_TX_BUSY) or .jumpc(no_UART2)
    .inport(I_UART2_RX) .outport(O_UART2_TX)
  :no_UART2
  .inport(I_UART3_RX_EMPTY) .inport(I_UART3_TX_BUSY) or .jumpc(no_UART3)
    .inport(I_UART3_RX) .outport(O_UART3_TX)
  :no_UART3
  .inport(I_UART4_RX_EMPTY) .jumpc(loop)
  .inport(I_UART4_RX)
  O_DATA outport
  'z' - .jumpc(loop)

; Signal program termination.
0x01 .outport(O_DONE)

; Wait forever.
:infinite .jump(infinite)
