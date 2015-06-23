/*
 * Linker Script for the Potato Processor test applications.
 * (c) Kristian Klomsten Skordal 2014 - 2015 <kristian.skordal@wafflemail.net>
 * Report bugs and issues on <http://opencores.org/project,potato,bugtracker>
 */

/*
 * The linker script assumes that default testbench settings are used, that is,
 * 2048 bytes (each) of separate instruction and data memory.
 */

ENTRY(_start);

SECTIONS
{
	.text 0x0 :
	{
		*(.init*)
		*(.text*)
	}

	.data 0x800 :
	{
		__data_begin = .;
		*(.data*)
	}

	.bss :
	{
		__bss_begin = .;
		*(.bss*)
		__bss_end = .;
	}
	__data_end = .;

	__stack_top = 0x1000;
}

