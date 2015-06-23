MEMORY
{
   BRAM : ORIGIN = 0x00000000, LENGTH = 16K
}

SECTIONS
{
   .text :
   {
      *(.text)
      *(.text.*)
   } > BRAM
   .rodata :
   {
      *(.rodata)
      *(.rodata.*);
   } > BRAM
   .data :
   {
      _gp = . + 0x7ff0; /* 0x7ff0 -> middle of 64K area */
      *(.sdata)
      *(.data)
   } > BRAM
   .bss :
   {
      _bss_start = .;
      *(.bss)
      *(.sbss)
      _bss_end = .;
   } > BRAM
}
