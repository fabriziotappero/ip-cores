/* ------------------------------ */
/* link script */
/* ------------------------------ */

MEMORY
        {
        flash             : ORIGIN = 0x00000000, LENGTH = 0x00400000
        aram              : ORIGIN = 0x04000000, LENGTH = 0x00020000
        emem              : ORIGIN = 0x08000000, LENGTH = 0x00002000
        qmem              : ORIGIN = 0xffe00000, LENGTH = 0x00002000
        }

SECTIONS
{
        .text :
        {
        . = 0x100;
        reset_func = .;
        *(.vectors)
        . = 0x8000;
        *(.text)
        } > flash

        .rodata :
        {
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
        } > flash

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
