; Copyright 2012, Sinclair R.F., Inc.
;
; Test memory I/O

.memory RAM ram_a
.variable a 0*${size['ram_a']}

.main

  ; Write different, non-zero values to several memory locations.
  ${size['ram_a']/2} :loop_write 0xA5 over ^ over .store(ram_a) drop .jumpc(loop_write,0>>) drop

  ; Read these values.
  ${size['ram_a']/2} :loop_read dup .fetch(ram_a) drop .jumpc(loop_read,0>>) drop

  ; Terminate the simulation.
  .outstrobe(O_DONE_STROBE)

  ; Sit in an infinite loop.
  :infinite .jump(infinite)
