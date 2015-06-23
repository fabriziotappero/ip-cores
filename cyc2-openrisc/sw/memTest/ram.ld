MEMORY
        {
        vectors : ORIGIN = 0x00000000, LENGTH = 0x00000200 
        ram     : ORIGIN = 0x00000200, LENGTH = 0x00001e00
        }
 
SECTIONS
{
        .vectors :
        {
        *(.vectors)
        } > vectors

        .text :
        {
        *(.text)
        } > ram

        .data :
        {
        *(.data)
        } > ram

        .rodata :
        {
        *(.rodata)
        } > ram

        .bss :
        {
        *(.bss)
        } > ram

        .stack ALIGN(0x4):
        {
        *(.stack)
        _src_addr = .;
        } > ram
}
