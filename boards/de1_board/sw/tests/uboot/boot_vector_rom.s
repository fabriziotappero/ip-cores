

.section .boot_vector_rom, "ax"
.org 0x0

_boot_reset:
  
  /* Jump to main */
  l.movhi r2,hi(reset_func)
  l.ori   r2,r2,lo(reset_func)
  l.jr    r2
  l.nop
  