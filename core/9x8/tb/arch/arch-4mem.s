; Copyright 2013, Sinclair R.F., Inc.
;
; Test memory I/O

.memory RAM ram_a
.variable a 0*${size['ram_a']}

.memory RAM ram_b
.variable b 0*${size['ram_b']}

.memory RAM ram_c
.variable c 0*${size['ram_c']}

.memory RAM ram_d
.variable d 0*${size['ram_d']}

.main

  ;
  ; Write to the memories a couple of times at slightly different locations and with different values.
  ;

  ${size['ram_a']/2} :loop_write_a0 0xA5 over ^ over .store(ram_a) drop     .jumpc(loop_write_a0,0>>) drop
  ${size['ram_b']/2} :loop_write_b0 0x96 over ^ over .store(ram_b) drop     .jumpc(loop_write_b0,0>>) drop
  ${size['ram_c']/2} :loop_write_c0 0xFF over ^ over .store(ram_c) drop     .jumpc(loop_write_c0,0>>) drop
  ${size['ram_d']/2} :loop_write_d0 0x95 over ^ over .store(ram_d) drop     .jumpc(loop_write_d0,0>>) drop
  ${size['ram_a']/2} :loop_write_a1 0x5A over ^ over .store(ram_a) drop 0>> .jumpc(loop_write_a1,0>>) drop
  ${size['ram_b']/4} :loop_write_b1 0x69 over ^ over .store(ram_b) drop 0>> .jumpc(loop_write_b1,0>>) drop
  ${size['ram_c']/8} :loop_write_c1 0x00 over ^ over .store(ram_c) drop 0>> .jumpc(loop_write_c1,0>>) drop

  ;
  ; Read all the final memory values and the locations writes were performed.
  ;

  ${size['ram_a']/2} :loop_read_a dup .fetch(ram_a) drop .jumpc(loop_read_a,0>>) drop
  ${size['ram_b']/2} :loop_read_b dup .fetch(ram_b) drop .jumpc(loop_read_b,0>>) drop
  ${size['ram_c']/2} :loop_read_c dup .fetch(ram_c) drop .jumpc(loop_read_c,0>>) drop
  ${size['ram_d']/2} :loop_read_d dup .fetch(ram_d) drop .jumpc(loop_read_d,0>>) drop

  ; Terminate the simulation.
  .outstrobe(O_DONE_STROBE)

  ; Sit in an infinite loop.
  :infinite .jump(infinite)
