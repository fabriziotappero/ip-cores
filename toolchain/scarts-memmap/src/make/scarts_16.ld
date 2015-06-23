ENTRY(_start)
OUTPUT_FORMAT("elf32-scarts_16", "elf32-scarts_16", "elf32-scarts_16")
OUTPUT_ARCH(scarts_16)
SEARCH_DIR(@SCARTS_SEARCH_DIR@)

/*
 * This is the map for the code memory (addresses grow downwards)
 * +--------------------+ <- @SCARTS_CODEMEM_VMA_START@
 * | .text              |
 * +--------------------+ <- @SCARTS_CODEMEM_USABLE_VMA_END@
 *
 * This is the map for the data memory (addresses grow downwards)
 * +--------------------+ <- @SCARTS_DATAMEM_VMA_START@
 * | .rodata            | constant data goes here
 * +--------------------+
 * | .data              | initialized data goes here
 * +--------------------+
 * | .bss               |
 * |        __bss_start | start of bss
 * |        _end        | start of heap
 * +--------------------+
 * .                    .
 * .                    .
 * .                    .
 * |        __stack     | top of stack
 * +--------------------+ <- @SCARTS_DATAMEM_USABLE_VMA_END@
 */

/* MWA: please see important comments on the allocation of various sections in
   memory throughout this document. */
MEMORY
{
  ROM     (rx)  : ORIGIN = @SCARTS_CODEMEM_VMA_START@, LENGTH = @SCARTS_CODEMEM_USABLE_SIZE@
  ROM_LMA (rx)  : ORIGIN = @SCARTS_CODEMEM_LMA_START@, LENGTH = @SCARTS_CODEMEM_USABLE_SIZE@
  RAM     (!rx) : ORIGIN = @SCARTS_DATAMEM_VMA_START@, LENGTH = @SCARTS_DATAMEM_USABLE_SIZE@
  RAM_LMA (!rx) : ORIGIN = @SCARTS_DATAMEM_LMA_START@, LENGTH = @SCARTS_DATAMEM_USABLE_SIZE@
}

/* Allocate the stack at the top of the data memory, since the stack grows down. */
PROVIDE (__stack = @SCARTS_DATAMEM_USABLE_SIZE@);

SECTIONS
{
  /* Read-only sections, merged into text segment: */
  PROVIDE (__executable_start = 0); . = 0;
  .interp         : { *(.interp) }
  .note.gnu.build-id : { *(.note.gnu.build-id) }
  .hash           : { *(.hash) }
  .gnu.hash       : { *(.gnu.hash) }
  .dynsym         : { *(.dynsym) }
  .dynstr         : { *(.dynstr) }
  .gnu.version    : { *(.gnu.version) }
  .gnu.version_d  : { *(.gnu.version_d) }
  .gnu.version_r  : { *(.gnu.version_r) }
  .rel.init       : { *(.rel.init) }
  .rela.init      : { *(.rela.init) }
  .rel.text       : { *(.rel.text .rel.text.* .rel.gnu.linkonce.t.*) }
  .rela.text      : { *(.rela.text .rela.text.* .rela.gnu.linkonce.t.*) }
  .rel.fini       : { *(.rel.fini) }
  .rela.fini      : { *(.rela.fini) }
  .rel.rodata     : { *(.rel.rodata .rel.rodata.* .rel.gnu.linkonce.r.*) }
  .rela.rodata    : { *(.rela.rodata .rela.rodata.* .rela.gnu.linkonce.r.*) }
  .rel.data.rel.ro   : { *(.rel.data.rel.ro* .rel.gnu.linkonce.d.rel.ro.*) }
  .rela.data.rel.ro   : { *(.rela.data.rel.ro* .rela.gnu.linkonce.d.rel.ro.*) }
  .rel.data       : { *(.rel.data .rel.data.* .rel.gnu.linkonce.d.*) }
  .rela.data      : { *(.rela.data .rela.data.* .rela.gnu.linkonce.d.*) }
  .rel.tdata	  : { *(.rel.tdata .rel.tdata.* .rel.gnu.linkonce.td.*) }
  .rela.tdata	  : { *(.rela.tdata .rela.tdata.* .rela.gnu.linkonce.td.*) }
  .rel.tbss	  : { *(.rel.tbss .rel.tbss.* .rel.gnu.linkonce.tb.*) }
  .rela.tbss	  : { *(.rela.tbss .rela.tbss.* .rela.gnu.linkonce.tb.*) }
  .rel.ctors      : { *(.rel.ctors) }
  .rela.ctors     : { *(.rela.ctors) }
  .rel.dtors      : { *(.rel.dtors) }
  .rela.dtors     : { *(.rela.dtors) }
  .rel.got        : { *(.rel.got) }
  .rela.got       : { *(.rela.got) }
  .rel.sdata      : { *(.rel.sdata .rel.sdata.* .rel.gnu.linkonce.s.*) }
  .rela.sdata     : { *(.rela.sdata .rela.sdata.* .rela.gnu.linkonce.s.*) }
  .rel.sbss       : { *(.rel.sbss .rel.sbss.* .rel.gnu.linkonce.sb.*) }
  .rela.sbss      : { *(.rela.sbss .rela.sbss.* .rela.gnu.linkonce.sb.*) }
  .rel.sdata2     : { *(.rel.sdata2 .rel.sdata2.* .rel.gnu.linkonce.s2.*) }
  .rela.sdata2    : { *(.rela.sdata2 .rela.sdata2.* .rela.gnu.linkonce.s2.*) }
  .rel.sbss2      : { *(.rel.sbss2 .rel.sbss2.* .rel.gnu.linkonce.sb2.*) }
  .rela.sbss2     : { *(.rela.sbss2 .rela.sbss2.* .rela.gnu.linkonce.sb2.*) }
  .rel.bss        : { *(.rel.bss .rel.bss.* .rel.gnu.linkonce.b.*) }
  .rela.bss       : { *(.rela.bss .rela.bss.* .rela.gnu.linkonce.b.*) }
  .rel.plt        : { *(.rel.plt) }
  .rela.plt       : { *(.rela.plt) }
  .init           :
  {
    KEEP (*(.init))
  } =0
  .plt            : { *(.plt) }
  .text           :
  {
    *(.text .stub .text.* .gnu.linkonce.t.*)
    KEEP (*(.text.*personality*))
    /* .gnu.warning sections are handled specially by elf32.em.  */
    *(.gnu.warning)
  } >ROM AT>ROM_LMA
  .fini           :
  {
    KEEP (*(.fini))
  } =0
  PROVIDE (__etext = .);
  PROVIDE (_etext = .);
  PROVIDE (etext = .);
  /* MWA: The .rodata section is allocated in RAM, not in ROM, since, in the
     SCARTS architecture, the ROM can only be addressed instruction-wise. As
     a result, the address for the data segment is reset before the .rodata
     section is defined. */
  /* Adjust the address for the data segment.  We want to adjust up to
     the same address within the page on the next page up.  */
  . = 0;
  /* MWA: For some, yet unknown, reason, large data types may be misaligned at
     the LMA, but be correctly aligned at the VMA. As an imperfect workaround
     we enforce proper alignment by the following simple address arithmetic:
     LMA(x) = VMA(x) (for RAM == RAM_LMA) */
/* .rodata         : { *(.rodata .rodata.* .gnu.linkonce.r.*) } >RAM AT>RAM_LMA */
  .rodata         : AT(ADDR(.rodata))
  {
    *(.rodata .rodata.* .gnu.linkonce.r.*)
  } >RAM
  .rodata1        : { *(.rodata1) }
  .sdata2         :
  {
    *(.sdata2 .sdata2.* .gnu.linkonce.s2.*)
  }
  .sbss2          : { *(.sbss2 .sbss2.* .gnu.linkonce.sb2.*) }
  .eh_frame_hdr : { *(.eh_frame_hdr) }
  .eh_frame       : ONLY_IF_RO { KEEP (*(.eh_frame)) }
  .gcc_except_table   : ONLY_IF_RO { *(.gcc_except_table .gcc_except_table.*) }
  /* Exception handling  */
  .eh_frame       : ONLY_IF_RW { KEEP (*(.eh_frame)) }
  .gcc_except_table   : ONLY_IF_RW { *(.gcc_except_table .gcc_except_table.*) }
  /* Thread Local Storage sections  */
  .tdata	  : { *(.tdata .tdata.* .gnu.linkonce.td.*) }
  .tbss		  : { *(.tbss .tbss.* .gnu.linkonce.tb.*) *(.tcommon) }
  .preinit_array     :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  }
  .init_array     :
  {
     PROVIDE_HIDDEN (__init_array_start = .);
     KEEP (*(SORT(.init_array.*)))
     KEEP (*(.init_array))
     PROVIDE_HIDDEN (__init_array_end = .);
  }
  .fini_array     :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(.fini_array))
    KEEP (*(SORT(.fini_array.*)))
    PROVIDE_HIDDEN (__fini_array_end = .);
  }
  .ctors          :
  {
    /* gcc uses crtbegin.o to find the start of
       the constructors, so we make sure it is
       first.  Because this is a wildcard, it
       doesn't matter if the user does not
       actually link against crtbegin.o; the
       linker won't look for a file to match a
       wildcard.  The wildcard also means that it
       doesn't matter which directory crtbegin.o
       is in.  */
    KEEP (*crtbegin.o(.ctors))
    KEEP (*crtbegin?.o(.ctors))
    /* We don't want to include the .ctor section from
       the crtend.o file until after the sorted ctors.
       The .ctor section from the crtend file contains the
       end of ctors marker and it must be last */
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
  }
  .dtors          :
  {
    KEEP (*crtbegin.o(.dtors))
    KEEP (*crtbegin?.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
  }
  .jcr            : { KEEP (*(.jcr)) }
  .data.rel.ro : { *(.data.rel.ro.local* .gnu.linkonce.d.rel.ro.local.*) *(.data.rel.ro* .gnu.linkonce.d.rel.ro.*) }
  .dynamic        : { *(.dynamic) }
  /* MWA: For some, yet unknown, reason, large data types may be misaligned at
     the LMA, but be correctly aligned at the VMA. As an imperfect workaround
     we enforce proper alignment by the following simple address arithmetic:
     LMA(x) = VMA(x) (for RAM == RAM_LMA) */
  /* .data           :
  {
    *(.data .data.* .gnu.linkonce.d.*)
    KEEP (*(.gnu.linkonce.d.*personality*))
    SORT(CONSTRUCTORS)
  } >RAM AT>RAM_LMA */
  .data           : AT(ADDR(.data))
  {
    *(.data .data.* .gnu.linkonce.d.*)
    KEEP (*(.gnu.linkonce.d.*personality*))
    SORT(CONSTRUCTORS)
  } >RAM
  .data1          : { *(.data1) }
  .got            : { *(.got.plt) *(.got) }
  /* We want the small data sections together, so single-instruction offsets
     can access them all, and initialized data all before uninitialized, so
     we can shorten the on-disk segment size.  */
  .sdata          :
  {
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  }
  _edata = .; PROVIDE (edata = .);
  __bss_start = .;
  .sbss           :
  {
    *(.dynsbss)
    *(.sbss .sbss.* .gnu.linkonce.sb.*)
    *(.scommon)
  }
  /* MWA: For some, yet unknown, reason, large data types may be misaligned at
     the LMA, but be correctly aligned at the VMA. As an imperfect workaround
     we enforce proper alignment by the following simple address arithmetic:
     LMA(x) = VMA(x) (for RAM == RAM_LMA) */
  /* .bss            :
  {
   *(.dynbss)
   *(.bss .bss.* .gnu.linkonce.b.*)
   *(COMMON)
   . = ALIGN(. != 0 ? 1 : 1);
  } >RAM AT>RAM_LMA */
  .bss            : AT(ADDR(.bss))
  {
   *(.dynbss)
   *(.bss .bss.* .gnu.linkonce.b.*)
   *(COMMON)
   /* Align here to ensure that the .bss section occupies space up to
      _end.  Align after .bss to ensure correct alignment even if the
      .bss section disappears because there are no input sections.
      FIXME: Why do we need it? When there is no .bss section, we don't
      pad the .data section.  */
   . = ALIGN(. != 0 ? 1 : 1);
  } >RAM
  . = ALIGN(1);
  . = ALIGN(1);
  _end = .; PROVIDE (end = .);
  /* Stabs debugging sections.  */
  .stab          0 : { *(.stab) }
  .stabstr       0 : { *(.stabstr) }
  .stab.excl     0 : { *(.stab.excl) }
  .stab.exclstr  0 : { *(.stab.exclstr) }
  .stab.index    0 : { *(.stab.index) }
  .stab.indexstr 0 : { *(.stab.indexstr) }
  .comment       0 : { *(.comment) }
  /* DWARF debug sections.
     Symbols in the DWARF debugging sections are relative to the beginning
     of the section so we begin them at 0.  */
  /* DWARF 1 */
  .debug          0 : { *(.debug) }
  .line           0 : { *(.line) }
  /* GNU DWARF 1 extensions */
  .debug_srcinfo  0 : { *(.debug_srcinfo) }
  .debug_sfnames  0 : { *(.debug_sfnames) }
  /* DWARF 1.1 and DWARF 2 */
  .debug_aranges  0 : { *(.debug_aranges) }
  .debug_pubnames 0 : { *(.debug_pubnames) }
  /* DWARF 2 */
  .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
  .debug_abbrev   0 : { *(.debug_abbrev) }
  .debug_line     0 : { *(.debug_line) }
  .debug_frame    0 : { *(.debug_frame) }
  .debug_str      0 : { *(.debug_str) }
  .debug_loc      0 : { *(.debug_loc) }
  .debug_macinfo  0 : { *(.debug_macinfo) }
  /* SGI/MIPS DWARF 2 extensions */
  .debug_weaknames 0 : { *(.debug_weaknames) }
  .debug_funcnames 0 : { *(.debug_funcnames) }
  .debug_typenames 0 : { *(.debug_typenames) }
  .debug_varnames  0 : { *(.debug_varnames) }
  /* DWARF 3 */
  .debug_pubtypes 0 : { *(.debug_pubtypes) }
  .debug_ranges   0 : { *(.debug_ranges) }
  .gnu.attributes 0 : { KEEP (*(.gnu.attributes)) }
  /DISCARD/ : { *(.note.GNU-stack) *(.gnu_debuglink) }
}
