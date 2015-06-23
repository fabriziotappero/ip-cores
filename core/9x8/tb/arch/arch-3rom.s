; Copyright 2013, Sinclair R.F., Inc.
;
; Validate contents of three ROMs

.include init.s

.main
  ; Read the contents of the first ROM
  ${size['rom_z']-1} :read_z dup .fetch(rom_z) drop .jumpc(read_z,1-) drop

  ; Read the contents of the second ROM
  ${size['rom_y']-1} :read_y dup .fetch(rom_y) drop .jumpc(read_y,1-) drop

  ; Read the contents of the third ROM
  ${size['rom_x']-1} :read_x dup .fetch(rom_x) drop .jumpc(read_x,1-) drop

  ; Terminate the simulation.
  .outstrobe(O_DONE_STROBE)

  ; Sit in an infinite loop.
  :infinite .jump(infinite)
