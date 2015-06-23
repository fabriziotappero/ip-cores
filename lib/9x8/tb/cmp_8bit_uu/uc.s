; Copyright 2013, Sinclair R.F., Inc.
; Test bench for ../../cmp_8bit_uu.s

.include cmp_8bit_uu.s

.main

  ; Test all combinations of msbs where the second argument is smaller than the
  ; first argument.
  0x08 0x04 .call(test)
  0x88 0x04 .call(test)
  0x88 0x84 .call(test)

  ; terminate and wait forever
  .outstrobe(O_TERMINATE) :infinite .jump(infinite)

; Test all combinations of the 8-bit comparison operations against the two
; provided values.
; ( u_larger u_smaller - )
.function test

  over over      .call(cmp_8bit_uu_eq) .outport(O_VALUE) ;  0
  over over swap .call(cmp_8bit_uu_eq) .outport(O_VALUE) ;  0
  over dup       .call(cmp_8bit_uu_eq) .outport(O_VALUE) ; -1

  over over      .call(cmp_8bit_uu_ne) .outport(O_VALUE) ; -1
  over over swap .call(cmp_8bit_uu_ne) .outport(O_VALUE) ; -1
  over dup       .call(cmp_8bit_uu_ne) .outport(O_VALUE) ;  0

  over over      .call(cmp_8bit_uu_lt) .outport(O_VALUE) ;  0
  over over swap .call(cmp_8bit_uu_lt) .outport(O_VALUE) ; -1
  over dup       .call(cmp_8bit_uu_lt) .outport(O_VALUE) ;  0

  over over      .call(cmp_8bit_uu_ge) .outport(O_VALUE) ; -1
  over over swap .call(cmp_8bit_uu_ge) .outport(O_VALUE) ;  0
  over dup       .call(cmp_8bit_uu_ge) .outport(O_VALUE) ; -1

  over over      .call(cmp_8bit_uu_le) .outport(O_VALUE) ;  0
  over over swap .call(cmp_8bit_uu_le) .outport(O_VALUE) ; -1
  over dup       .call(cmp_8bit_uu_le) .outport(O_VALUE) ; -1

  over over      .call(cmp_8bit_uu_gt) .outport(O_VALUE) ; -1
  over over swap .call(cmp_8bit_uu_gt) .outport(O_VALUE) ;  0
  over dup       .call(cmp_8bit_uu_gt) .outport(O_VALUE) ;  0

  over over      .call(min_u8)         .outport(O_VALUE)
  over over swap .call(min_u8)         .outport(O_VALUE)
  over dup       .call(min_u8)         .outport(O_VALUE)

  drop .return(drop)
