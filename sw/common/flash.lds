MEMORY
{
   FLASH : ORIGIN = 0x20000000, LENGTH = 16M
}

SECTIONS
{
   .text :
   {
      *(.text)
      *(.text.*)
   } > FLASH
   .rodata :
   {
      *(.rodata)
      *(.rodata.*);
   } > FLASH
   .data :
   {
      _gp = . + 0x7ff0; /* 0x7ff0 -> middle of 64K area */
      *(.sdata)
      *(.data)
   } > FLASH
   .bss :
   {
      _bss_start = .;
      *(.bss)
      *(.sbss)
      _bss_end = .;
   } > FLASH
}
