/* ------------------------------ */
/* link script */
/* ------------------------------ */

MEMORY
        {
        boot_vector_rom   : ORIGIN = 0x00000000, LENGTH = 0x00000010
        boot_rom_0        : ORIGIN = 0x04000000, LENGTH = 0x04000000
        boot_rom_1        : ORIGIN = 0x08000000, LENGTH = 0x04000000
        boot_rom_2        : ORIGIN = 0x0c000000, LENGTH = 0x04000000
        mem_bank_1        : ORIGIN = 0x10000000, LENGTH = 0x10000000
        mem_bank_2        : ORIGIN = 0x20000000, LENGTH = 0x10000000
        mem_bank_3        : ORIGIN = 0x30000000, LENGTH = 0x10000000
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
        } > boot_rom_0

        .rodata :
        {
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
        } > boot_rom_0

        .data :
        {
        *(.data)
        } > mem_bank_3

        .bss :
        {
        *(.bss)
        } > mem_bank_3

        .stack (NOLOAD) :
        {
        *(.stack)
        } > mem_bank_3
}
