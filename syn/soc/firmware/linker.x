MEMORY 
{
  ram  : ORIGIN = 0xBFC00000, LENGTH = 4096
}

SECTIONS
{
  .text : { *(.text) } > ram
  .data : { *(.data) } > ram
  __bss_start = .;
  .bss : { *(.bss) } > ram
  __bss_stop = .;
}
