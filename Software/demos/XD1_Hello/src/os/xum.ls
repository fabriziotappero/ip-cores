/* Linker script for MIPS32 (Single Core) FPGA, intended for XUM */


/* Entry Point
 *
 * Set it to be the label "boot" (likely in boot.asm)
 *
 */
/*ENTRY(boot)*/


/* Memory Section
 *
 * The FPGA currently uses one region of Block RAM, which is 592 KB.
 * 
 * Instruction Memory starts at address 0.
 *
 * Data Memory ends 592KB later, at address 0x00094000 (the last
 * usable word address is 0x00093ffc).
 *
 *   Instructions :    0x00000000 -> 0x0000fffc    ( 64KB)
 *   Data / BSS   :    0x00001000 -> 0x00017ffc    ( 32KB)
 *   Stack / Heap :    0x00018000 -> 0x00093ffc    (496KB)
 * 
 *
 */

/* Sections
 *
 */

SECTIONS
{
	_sp = 0x00094000;

	. = 0 ;

	.text :
	{
		vectors.o(.text)
		. = 0x10 ;
		boot.o(.text)
		exceptions.o(.text)
		*(.*text*)
	}

	. = 0x00001000 ;

	.data :
	{
		*(.rodata*)
		*(.data*)
	}

	_gp = ALIGN(16) + 0x7ff0;

	.got :
	{
		*(.got)
	}

	.sdata :
	{
		*(.*sdata*)
	}

	_bss_start = . ;

	.sbss :
	{
		*(.*sbss)
	}

	.bss :
	{
		*(.*bss)
	}

	_bss_end = . ;

}


