
; Copyright 2013, Sinclair R.F., Inc.
;
; Test memory I/O

.memory RAM ram_a
.variable a 0*${size['ram_a']}

.memory RAM ram_b
.variable b 0*${size['ram_b']}

.include init.s

.main

  ;
  ; Write to memory a, then memory b, then memory a again (to help detect write
  ; errors for any memory configuration).
  ;

  ${size['ram_a']/2} :loop_write_a0 0xA5 over ^ over .store(ram_a) drop .jumpc(loop_write_a0,0>>) drop
  ${size['ram_b']/2} :loop_write_b0 0x96 over ^ over .store(ram_b) drop .jumpc(loop_write_b0,0>>) drop
  ${size['ram_a']/2} :loop_write_a1 0x5A over ^ over .store(ram_a) drop .jumpc(loop_write_a1,0>>) drop

  ; Read the final memory values.
  ${size['ram_a']/2} :loop_read_a dup .fetch(ram_a) drop .jumpc(loop_read_a,0>>) drop
  ${size['ram_b']/2} :loop_read_b dup .fetch(ram_b) drop .jumpc(loop_read_b,0>>) drop
  ${size['rom_z']-1} :loop_read_z dup .fetch(rom_z) drop .jumpc(loop_read_z,1-)  drop
  ${size['rom_y']-1} :loop_read_y dup .fetch(rom_y) drop .jumpc(loop_read_y,1-)  drop

  ; Terminate the simulation.
  .outstrobe(O_DONE_STROBE)

  ; Sit in an infinite loop.
  :infinite .jump(infinite)
