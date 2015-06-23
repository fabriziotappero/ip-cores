; Copyright 2013, Sinclair R.F., Inc.
;
; Validate contents of a single ROM

.include init.s

.main
  ; Read the contents of the ROM
  ${size['rom_z']-1} :read_z dup .fetch(rom_z) drop .jumpc(read_z,1-) drop

  ; Terminate the simulation.
  .outstrobe(O_DONE_STROBE)

  ; Sit in an infinite loop.
  :infinite .jump(infinite)
