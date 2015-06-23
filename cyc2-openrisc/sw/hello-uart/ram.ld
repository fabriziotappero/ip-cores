MEMORY
        {
        vectors : ORIGIN = 0x40000000, LENGTH = 0x00002000 
        ram     : ORIGIN = 0x40002000, LENGTH = 0x00002000
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
