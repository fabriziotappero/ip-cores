; Copyright 2013, Sinclair R.F., Inc.
; Test bench for UARTx peripheral.

.main

; Put a message into the output FIFO on UART1 including the null terminator.

N"Hello World!\r\n"
:out_loop O_UART1_Tx outport .jumpc(out_loop)

; Echo the input on UART1 to the output on UART2 up to and including the null
; terminator.

:echo_loop .inport(I_UART1_RX_EMPTY) .jumpc(echo_loop)
  .inport(I_UART1_Rx) O_UART2_Tx outport .jumpc(echo_loop)

; Copy the UART2 input FIFO to the output port up to and including the null
; terminator.

:copy_loop .inport(I_UART2_RX_EMPTY) .jumpc(copy_loop)
  .inport(I_UART2_Rx) O_DATA outport .jumpc(copy_loop)

; Signal program termination.

0x01 .outport(O_DONE)

; Wait forever.

:infinite .jump(infinite)
