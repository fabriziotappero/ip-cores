; Copyright 2012, Sinclair R.F., Inc.
;
; Ensure that the high-order data bits for function calls are correctly stored/recalled.

.main

  ; Fill half of the code space so that we're in the upper half of the address space.
  .jump(skip_fill)
  0*${C_OPCODE_SIZE/2-3}
  :skip_fill

  ; Call a function in the upper half of memory
  .call(upper_function)

  ; terminate the simulation
  .outstrobe(O_DONE_STROBE)

  :infinite .jump(infinite)

.function upper_function
  .return
