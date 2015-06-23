/*  linkcmds
 *
 *  $Id: linkcmds,v 1.8.2.1 2000/05/24 17:06:38 joel Exp $
 */

OUTPUT_ARCH(sparc)
__DYNAMIC  =  0;

/*
 * The memory map looks like this:
 * +--------------------+ <- low memory
 * | .text              |
 * |        etext       |
 * |        ctor list   | the ctor and dtor lists are for
 * |        dtor list   | C++ support
 * |        _endtext    |
 * +--------------------+
 * | .data              | initialized data goes here
 * |        _sdata      |
 * |        _edata      |
 * +--------------------+
 * | .bss               |
 * |        __bss_start | start of bss, cleared by crt0
 * |        _end        | start of heap, used by sbrk()
 * +--------------------+
 * |    heap space      |
 * |        _ENDHEAP    |
 * |    stack space     | 
 * |        __stack     | top of stack
 * +--------------------+ <- high memory
 */


/* Default values, can be overridden */

_PROM_SIZE = 2M;
_RAM_SIZE = 4M;

_RAM_START = 0x02000000;
_RAM_END = _RAM_START + _RAM_SIZE;

_PROM_START = 0x00000000;
_PROM_END = _PROM_START + _PROM_SIZE;

/*
 *  Alternate names without leading _.
 */

PROM_START = _PROM_START;
PROM_SIZE = _PROM_SIZE;
PROM_END = _PROM_END;

RAM_START = _RAM_START;
RAM_SIZE = _RAM_SIZE;
RAM_END = _RAM_END;

_LEON_REG = 0x80000000;
LEON_REG = 0x80000000;

/* these are the maximum values */

MEMORY
{
  rom     : ORIGIN = 0x00000000, LENGTH = 16M
  ram     : ORIGIN = 0x40000000, LENGTH = 1024M
}

SECTIONS
{
  .text :
  {
    CREATE_OBJECT_SYMBOLS
    text_start = .;
    _text_start = .;
    *(.text)
    . = ALIGN (16);

    *(.eh_frame)
    . = ALIGN (16);

    *(.gnu.linkonce.t*)

    /*
     * C++ constructors
     */
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

    _rodata_start = . ;
    *(.rodata*)
    *(.gnu.linkonce.r*)
    _erodata = ALIGN( 0x10 ) ;

    etext = ALIGN(0x10);
    _etext = .;
    *(.init)
    *(.fini)
    *(.lit)
    *(.shdata)
    . = ALIGN (16);
    _endtext = .;
  } > rom
  .dynamic	  : { *(.dynamic) 	} >ram
  .got		  : { *(.got) 		} >ram
  .plt   	  : { *(.plt) 		} >ram
  .hash		  : { *(.hash)		} >ram
  .dynrel	  : { *(.dynrel)	} >ram
  .dynsym	  : { *(.dynsym)	} >ram
  .dynstr	  : { *(.dynstr)	} >ram
  .hash		  : { *(.hash)		} >ram
  .data :
  {
    data_start = .;
    _data_start = .;
    _sdata = . ;
    *(.data)
    *(.gnu.linkonce.d*)
    *(.gcc_except_table)
    . = ALIGN(0x10);
    edata = .;
    _edata = .;
  } > ram
  .shbss :
  {
    *(.shbss)
  } > ram
  .bss :
  {
    __bss_start = ALIGN(0x8);
    _bss_start = .;
    bss_start = .;
    *(.bss)
    *(COMMON)
    end = .;
    _end = ALIGN(0x8);
    __end = ALIGN(0x8);
  } > ram
  .jcr . (NOLOAD)  : { *(.jcr) 		}
  .stab . (NOLOAD) :
  {
    [ .stab ]
  }
  .stabstr . (NOLOAD) :
  {
    [ .stabstr ]
  }
}
