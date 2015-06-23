/*
 * Example working linker script for this container.
 *
 * Copyright (C) 2009 B Labs Ltd.
 */

vma_start = 0xa0000000;
lma_start = 0x100000;
offset = vma_start - lma_start;

ENTRY(_start)

SECTIONS
{
	. = vma_start;
	.text : AT (ADDR(.text) - offset) { *(.text.head) *(.text) }
	.rodata : AT (ADDR(.rodata) - offset) { *(.rodata) }
	.rodata1 : AT (ADDR(.rodata1) - offset) { *(.rodata1) }

	. = ALIGN(4K);
	__data_start = .;
	.data : AT (ADDR(.data) - offset) { *(.data) }
	__data_end = .;

	__bss_start = .;
	.bss : AT (ADDR(.bss) - offset) { *(.bss) }
	__bss_end = .;

	__stack_start = .;
	.stack : AT (ADDR(.stack) - offset)
	{
		. += 0x3000;
		. = ALIGN(4K);
		__stack = .;
	}
	__stack_end = .;
	__end = .;
}
