/* INCLUDE linkcmds.memory */

MEMORY
{
    ROM : ORIGIN = 0xb0000000, LENGTH = 1M
    RAM : ORIGIN = 0x00000000, LENGTH = 1M
}

/* 
    Put everything in XRAM area (16-bit SRAM in the DE-1 board).
    This means the program will have to be 'bootloaded' onto XRAM. See the 
    sdboot demo for an example.
*/
REGION_ALIAS("REGION_TEXT", RAM);
REGION_ALIAS("REGION_RODATA", RAM);
REGION_ALIAS("REGION_DATA", RAM);
REGION_ALIAS("REGION_BSS", RAM);


SECTIONS
{
    .text :
    {
        *(.text)
    } > REGION_TEXT
    .rodata :
    {
        *(.rodata)
        *(.rodata.*);
        rodata_end = .;
    } > REGION_RODATA
    .data : AT (rodata_end)
    {
        data_start = .;
        _gp = . + 0x7ff0; /* 0x7ff0 -> middle of 64K area */
        *(.data)
    } > REGION_DATA
    
    data_size = SIZEOF(.data);
    data_load_start = LOADADDR(.data);
    .bss :
    {
        __bss_start = .;
        *(.bss)
        _end = .;
    } > REGION_BSS
}
