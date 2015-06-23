MEMORY {
	textdatabss : ORIGIN = 0x02000000, LENGTH = 0x01000000
}
 
SECTIONS {
	.entry : {
		*(.entry)
	} > textdatabss

	.text ALIGN(0x04) : {
		*(.text)
        } > textdatabss

	.rodata ALIGN(0x04) : {
	        *(.rodata)
		*(.rodata.*)
	} > textdatabss
 
	.dummy ALIGN(0x04) : {
		_src_beg = .;
	} > textdatabss
 
	.data ALIGN(0x04) : AT ( ADDR (.dummy) ) {
		_dst_beg = .;
		*(.data)
		_dst_end = .;
	} > textdatabss

	.bss ALIGN(0x04) : AT ( ADDR (.dummy) + SIZEOF (.data) ) {
		*(.bss)
	} > textdatabss
}
