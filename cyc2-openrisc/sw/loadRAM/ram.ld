MEMORY
        {
        vectors : ORIGIN = 0x00000000, LENGTH = 0x00000200 
        ram     : ORIGIN = 0x00000200, LENGTH = 0x00001e00
        }
 
SECTIONS
{
        .vectors ALIGN(0x4):
        {
        *(.vectors)
        } > vectors

        .text ALIGN(0x4):
        {
        *(.text)
        } > ram

        .data ALIGN(0x4):
        {
        *(.data)
        } > ram

        .rodata ALIGN(0x4):
        {
        *(.rodata)
        } > ram

        .bss ALIGN(0x4):
        {
        *(.bss)
        } > ram

        .stack ALIGN(0x4):
        {
        *(.stack)
        _src_addr = .;
        } > ram
}

