/* ------------------------------ */
/* link script */
/* ------------------------------ */

MEMORY
        {
        boot_vector_rom   : ORIGIN = 0x00000000, LENGTH = 0x00000010
        aram              : ORIGIN = 0x04000000, LENGTH = 0x00020000
        emem              : ORIGIN = 0x08000000, LENGTH = 0x00002000
        qmem              : ORIGIN = 0xffe00000, LENGTH = 0x00002000
        }

SECTIONS
{
        .boot_vector_rom :
        {
        } > boot_vector_rom

        .text :
        {
        reset_func = .;
        *(.vectors)
        *(.text)
        } > emem

        .rodata :
        {
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
        } > emem

        .data :
        {
        *(.data)
        } > emem

        .bss :
        {
        *(.bss)
        } > emem

        .stack (NOLOAD) :
        {
        *(.stack)
        } > emem
}
