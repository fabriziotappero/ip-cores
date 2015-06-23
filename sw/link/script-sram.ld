SEARCH_DIR(/cygdrive/c/edk/gnu/microblaze/nt/lib/gcc/microblaze/3.4.1);
SEARCH_DIR(/cygdrive/c/edk/gnu/microblaze/nt/microblaze/lib);

SEARCH_DIR(/cygdrive/d/xilinx/microblaze/lib/gcc/microblaze/3.4.1);
SEARCH_DIR(/cygdrive/d/xilinx/microblaze/microblaze/lib);

_STACK_START = DEFINED(_STACK_START) ? _STACK_START : 0x040e2000; /* initial stack at end of sram (non video)*/
_SRAM_START  = DEFINED(_SRAM_START)  ? _SRAM_START  : 0x04000000; /* external sram starts here */

INPUT( -lgcc );
GROUP( libc.a libm.a );
INPUT( -lgcc );

ENTRY (_start)
MEMORY {
	flatmem : ORIGIN = 0x0, LENGTH = 0xfffffff		/* flat memory model */
}

SECTIONS {
	.text _SRAM_START : {
		. = ALIGN(0x4) ;
		_stext = . ;
		*(.text)
		*(.text.*)
		*(.gnu.warning)
		*(.stub)
		*(.gnu.linkonce.t*)
		*(.glue_7t)
		*(.glue_7)
		*(.jcr)
		*(.init)
		*(.fini)

		*(.rodata)
		*(.rodata1)
		*(.rodata.*)

		/* This is special code area at the end of the normal
		   text section.  It contains a small lookup table at
		   the start followed by the code pointed to by entries
		   in the lookup table.  */
		. = ALIGN (0x4) ;
		PROVIDE(__ctbp = .);
		*(.call_table_data)
		*(.call_table_text)

		. = ALIGN(0x4) ;
		_etext = . ;
	} > flatmem
	.data : {
		. = ALIGN(0x4) ;
		_sdata = . ;
		__data_start = . ;
		data_start = . ;
		*(.got.plt)
		*(.got)
/*		FILL(0) ;
		. = ALIGN(0x04) ; 
		LONG(-1)
		. = ALIGN(0x04) ; */
		*(.rodata)
		*(.rodata1)
		*(.rodata.*)
		*(.gnu.linkonce.r*)
		*(.data)
		*(.data1)
		*(.data.*)
		*(.gnu.linkonce.d*)
		*(.data1)
		*(.eh_frame)
		*(.gcc_except_table)

		/* Microblaze has .sdata and .sbss (small bss).  They must
		   be contiguous, so please don't move any of this. JW */
		_ssrw = . ;			
		*(.sdata) 
		*(.sdata.*)
		__sbss_start = . ;
		*(.sbss)			/* Don't move this! */
		__sbss_end = . ;
		_essrw = . ;

		_ssrw_size = _essrw - _ssrw;
		PROVIDE(_SDA_BASE_ = _ssrw + (_ssrw_size / 2));

		*(.gnu.linkonce.s.*)
		*(__libc_atexit)
		*(__libc_subinit)
		*(__libc_subfreeres)
		*(.note.ABI-tag)

		/* microblaze-specific read-only small data area
		   and associated locating symbols */
		_ssro = . ;
		*(.sdata2)
		_essro = . ;
		_ssro_size = _essro - _ssro;
		PROVIDE(_SDA2_BASE_ = _ssro + (_ssro_size / 2));

		. = ALIGN(4) ;
		__CTOR_LIST__ = .;
		LONG((__CTOR_END__ - __CTOR_LIST__) / 4 - 2)
		*(.ctors)
		LONG(0)
		__CTOR_END__ = .;
		__DTOR_LIST__ = .;
		LONG((__DTOR_END__ - __DTOR_LIST__) / 4 - 2)
		*(.dtors)
		LONG(0)
		__DTOR_END__ = .;

		. = ALIGN(0x4) ; 
		_edata = . ;
	} > flatmem
	.bss : {
		. = ALIGN(0x4) ;
		_sbss = ALIGN(0x4) ;
		__bss_start = . ;
		*(.dynsbss)
		*(.sbss)
		*(.sbss.*)
		*(.scommon)
		*(.dynbss)
		*(.bss)
		*(.bss.*)
		*(.bss*)
		*(.gnu.linkonce.b*)
		*(COMMON)
		__bss_end = . ;
		_ebss = . ;
		_end = . ;
		end = . ;
	} > flatmem

	.junk 0 : { *(.rel*) *(.rela*) }
	/* Stabs debugging sections.    */
	.stab 0 : { *(.stab) }
	.stabstr 0 : { *(.stabstr) }
	.stab.excl 0 : { *(.stab.excl) }
	.stab.exclstr 0 : { *(.stab.exclstr) }
	.stab.index 0 : { *(.stab.index) }
	.stab.indexstr 0 : { *(.stab.indexstr) }
	.comment 0 : { *(.comment) }
	.debug_abbrev 0 : { *(.debug_abbrev) }
	.debug_info 0 : { *(.debug_info) }
	.debug_line 0 : { *(.debug_line) }
	.debug_pubnames 0 : { *(.debug_pubnames) }
	.debug_aranges 0 : { *(.debug_aranges) }
}
