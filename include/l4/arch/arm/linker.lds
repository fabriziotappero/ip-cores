/*
 * Simple linker script
 *
 * Copyright (C) 2007 Bahadir Balban
 */

/* FIXME:
 * Currently we can't include cpp #defines in linker script.
 * Check that below offsets are coherent with offsets.h
 */
kernel_offset		= 0xF0000000;
kernel_physical		= 0x8000;
kernel_virtual		= kernel_physical + kernel_offset;

/* A temporary boot stack is used before a proper kernel stack is set up */
_bootstack_physical	= _bootstack - kernel_offset;

/* The symbols are linked at virtual addresses. So is _start.
 * We must set the entry point to a physical address, so that
 * when the image is loaded, it doesn't jump to a non existing
 * virtual address.
 */
ENTRY(kernel_physical)

SECTIONS
{
	. = kernel_virtual;
	_start_kernel = .;
	.text : AT (ADDR(.text) - kernel_offset)
	{
		_start_text = .;
		/* Make sure head.S comes first */
		/* *head.o(.text) This only works when given its full path. Bad limitation. */
		*(.text.head)
		*(.text)
		_end_text = .;
	}
	. = ALIGN(4);
	/* rodata is needed else your strings will link at physical! */
	.rodata : AT (ADDR(.rodata) - kernel_offset) { *(.rodata) }
	.rodata1 : AT (ADDR(.rodata1) - kernel_offset) { *(.rodata1) }
	.data : AT (ADDR(.data) - kernel_offset)
	{
		_start_data = .;
		*(.data)
		_start_vectors = .;
		*(.data.vectors)
		. = ALIGN(4K);
		_end_vectors = .;
		_start_kip = .;
		*(.data.kip)
		. = ALIGN(4K);
		_end_kip = .;
		_start_syscalls = .;
		*(.data.syscalls)
		. = ALIGN(4K);
		_end_syscalls = .;
		_end_data = .;
	}
	.bss : AT (ADDR(.bss) - kernel_offset)
	{
		*(.bss)
	}
	. = ALIGN(4K);
	. += 0x2000;		/* This is required as the link counter does not seem
				 * to increment for the bss section
				 * TODO: Change this with PAGE_SIZE */

	/* Below part is to be discarded after boot */
	_start_init = .;
	.init : AT (ADDR(.init) - kernel_offset)
	{
		. = ALIGN(16K);	/* For initial pgd */
		*(.init.pgd)
		*(.init.bootmem)
		*(.init.data)
	}
	/* Space for boot stack */
	. += 0x1000;
	. = ALIGN(4K);	/* A page aligned stack of at least 4KB */
	_end_init = .;
	_bootstack = .;
	_end_kernel = .;
	_end = .;
}
