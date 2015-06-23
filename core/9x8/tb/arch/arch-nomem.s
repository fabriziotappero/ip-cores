; Copyright 2012, Sinclair R.F., Inc.
;
; Test the memory functions for various system architectures -- no memory tests.

.main

  ;
  ; test all bits of the data stack
  ;

  ; Push 0x01 ... 0x80 onto the data stack far enough to be out of T and N and into the data stack memory.
  0x01 :loop_data_stack_bits dup .jumpc(loop_data_stack_bits,<<0)

  ; Drop everything from the data stack
  ${10-1} :loop_drop_data_stack_bits nip .jumpc(loop_drop_data_stack_bits,1-) drop

  ;
  ; Test all data bits on the return stack.
  ;

  0x01 :loop_return_stack_bits dup >r .jumpc(loop_return_stack_bits,<<0) drop

  ; Drop everything from the return stack
  ${9-1} :loop_drop_return_stack_bits r> drop .jumpc(loop_drop_return_stack_bits,1-) drop

  ; test function calls mixed with return stack operations
  .call(testfn,3) drop

  ; terminate the simulation
  .outstrobe(O_DONE_STROBE)

  :infinite .jump(infinite)

.function testfn
  >r r@ 1- .callc(testfn,nop) r>
  .return(+)
