MEMORY {
/* internal SRAM maping used SRAM0(4KByte) */
	vectors		: ORIGIN = 0x00000000, LENGTH = 0x00001000	/* 4KByte of SRAM0 8KByte(Physical:1kbyte) */
	/* icm		: ORIGIN = 0x00001000, LENGTH = 0x00000c00 */   /* 4KByte of SRAM0 8KByte(Physical:3kbyte) */

/* internal SRAM maping used SRAM0(4KByte) or SRAM1(8KByte) */
	/* databss	: ORIGIN = 0x01000000, LENGTH = 0x00001000 */	/* 4KByte of SRAM1 8KByte */
	/* stack	: ORIGIN = 0x01001000, LENGTH = 0x00001000 */	/* 4KByte of SRAM1 8KByte */

/* qmem maping 0x0080_0000 - 0x0080_2000(8KByte) */
	icm		: ORIGIN = 0x00800000, LENGTH = 0x00001000 	/* 4KByte of QMEM 8KByte */
	/* icm		: ORIGIN = 0x02000000, LENGTH = 0x00800000 */	/* reserved TMP */

	databss		: ORIGIN = 0x00801000, LENGTH = 0x00000800	/* 2KByte of QMEM 8KByte */ /* QMEM support byte order,change qmem_top,but clmode=x2 NG? */
	stack		: ORIGIN = 0x00801800, LENGTH = 0x00000800	/* 2KByte of QMEM 8KByte */ /* QMEM support byte order,change qmem_top,but clmode=x2 NG? */
	/* databss	: ORIGIN = 0x02000000, LENGTH = 0x00400000 */	/* 2KByte of QMEM 8KByte */ /* QMEM support byte order,change qmem_top */
	/* stack	: ORIGIN = 0x02400000, LENGTH = 0x00400000 */	/* 2KByte of QMEM 8KByte */ /* QMEM support byte order,change qmem_top */

	extdatabss	: ORIGIN = 0x02800000, LENGTH = 0x00800000	/* reserved TMP */
	vga		: ORIGIN = 0x03000000, LENGTH = 0x01000000	/* reserved VGA */
	flash		: ORIGIN = 0x04000000, LENGTH = 0x00200000
}

SECTIONS {
	.reset			: {
		*(.reset)
	} > flash

	.text ALIGN(0x04)	: {
		*(.text)
	} > flash

	.rodata			: {
		*(.rodata)
		*(.rodata.*)
        } > flash
 
	.dummy ALIGN(0x04)	: {
		_src_beg = .;
	} > flash
 
	.vectors		: AT ( ADDR (.dummy) ) {
		_vec_start = .;
		*(.vectors)
		_vec_end = .;
	} > vectors

	.icm			: AT ( ADDR (.dummy) + SIZEOF (.vectors) ) {
		_icm_start = .;
		*(.icm)
		_icm_end = .;
	} > icm

	.data			: AT ( ADDR (.dummy) + SIZEOF (.vectors) + SIZEOF (.icm) ) {
		_dst_beg = .;
		*(.data)
		_dst_end = .;
	} > databss

	.extdata		: AT ( ADDR (.dummy) + SIZEOF (.vectors) + SIZEOF (.icm) + SIZEOF (.data) ) {
		_extdst_beg = .;
		*(.extdata)
		_extdst_end = .;
	} > extdatabss

	.extbss			: AT ( ADDR (.dummy) + SIZEOF (.vectors) + SIZEOF (.icm) + SIZEOF (.data) + SIZEOF (.extdata) ) {
		*(.extbss)
	} > extdatabss

	.bss			: AT ( ADDR (.dummy) + SIZEOF (.vectors) + SIZEOF (.icm) + SIZEOF (.data) + SIZEOF (.extdata) + SIZEOF (.extbss) ) {
	        *(.bss)
	} > databss

	.stack (NOLOAD) 	: {
		*(.stack)
		_src_addr = .;
	} > stack

}
