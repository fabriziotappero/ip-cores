/* Linker script for OR1200 program */

/* Linking for loading into high SDRAM */

MEMORY    
{
    ld_info     : ORIGIN = 0x01000000, LENGTH = 0x000000F0 
    vectors     : ORIGIN = 0x01000100, LENGTH = 0x00000D00 - 0x100
    flash       : ORIGIN = 0x01000D00, LENGTH = 0x00002000 - 0x0A00
    ram         : ORIGIN = 0x01003000, LENGTH = 0x00fffff0
}


/* Linking for loading into external SDRAM */

/*
MEMORY    
{
    ld_info     : ORIGIN = 0x00000000, LENGTH = 0x000000F0 
    vectors     : ORIGIN = 0x00000100, LENGTH = 0x00000D00 - 0x100
    flash       : ORIGIN = 0x00000D00, LENGTH = 0x00002000 - 0x0A00
    ram         : ORIGIN = 0x00003000, LENGTH = 0x00001000
}
*/
/*
  The following section defines where to put the different input sections.
  .text contains the code.
  .data contains the initialized data.
  .bss contains uninitialized data.
  .sdata contains small constant data.
*/

SECTIONS
{

/*
      .ld_info :
      {
        revision.o(.data)        
      } > ld_info
*/
    .vectors :   { *(.vectors) }    > vectors

    .text :     { *(.text)  }       > ram
    .rodata :   { *(.rodata)}       > ram
    .data :     { *(.data)  }       > ram
    .bss :      { *(.bss)   }       > ram
     
    .stack :
    {
        __STACK_TOP    = . ;
        . = . + 0x00000500;
        __STACK_BOTTOM = . ;
    }                               > ram
}

/*
  Definitions of identifiers that control initialization and memory allocation:
  These two symbols must be present.
   __BSS_START  : Start of uninitialized data
   __BSS_END    : End of data to be cleared
*/

__CODE_START  = ADDR( .text );
__CODE_END    = ADDR( .text ) + SIZEOF( .text );

__DATA_START  = ADDR( .bss );
__DATA_END    = ADDR( .bss ) + SIZEOF( .bss );
