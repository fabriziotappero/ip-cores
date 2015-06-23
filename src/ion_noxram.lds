/**
* ion_noxram.lds -- Linker script file for ION project (with no RAM or cache)
*
* WARNING: This script is no longer used by any makefile, to be removed or
* refactored.
*
* The ion cpu has separate buses for code and data (Harvard architecture) and 
* can be used with no cache. This linker script targets that 'bare' 
* system configuration. It is meant for early testing and debugging.
*
* This script will split the object file in two areas so that they can be put 
* in separate memory blocks:
* 1.- Code area (text output section)
* 2.- Data area (sdata, data and bss output sections)
*
* Since data constants can't be reached from the code bus, constant data 
* (usually in section rodata) needs to be put in the same space as other data.
* This is the main purpose of this file.
* Alternatively, we might just implement a 3-port memory and leave all sections
* adjacent, but that would be too expensive (3-port memory would take about 
* twice as many memory blocks for the same memory size).
*
* FIXME code and data RAM block sizes hardcoded
* FIXME code and data start addresses hardcoded
*/
/*
# Known problems:
#
# 1.- LINK PROBLEM IF FLAG '-G0' NOT USED
#       If flag '-G0' is not used on gcc, linker fails with 'relocation 
#       truncated to fit: R_MIPS_GPREL16' error message.
#       This only happens when you use global or static veriables, initialized 
#       or not.
#       (See explaination in the project docs about $gp indexed addressing in
#       MIPS architectures and the -G0 flag).
#
#     SUSPECTED CAUSE:
#       I'm sure there is something wrong with my linker script.
#       With the default link scripts this does not happen. Yet we need to use
#       a script so that we can split code and data (including read-only) to
#       different sections (and later to different ram blocks).
#       
#     WORKAROUND: 
#       Use -G0 flag so that _gp indexing is disabled. There is a performance
#       hit, though. In effect we're telling the compiler to NOT use $gp for
#       indexed access to any global variables.
#       This is only necessary for the 'bare' target (no external ram and no
#       cache) and will have to be fixed for regular targets (by using a 
#       standard link script or fixing mine).

*/


/* Make sure the first linked file is ths startup code from boot.s */
/* (We might put boot.o in the ld command line, BEFORE all other files) */
STARTUP(boot.o)

/* Default object output format is ELF big endian */
OUTPUT_FORMAT(elf32-big)



SECTIONS {
    /* Put all code at CODE area */
    .text 0x00000000 : {
        _ftext = . ;
        * (.text);

        
    } = 0 /* fill gaps with zeros */
    
    /* Mark end of executable code */
    _ecode = .;
    /* mark end of read-only code */
    _etext = .;
    PROVIDE (etext = .);
    
    
    /**** Put all data, including read-only, at DATA area */
    
    .data 0x80000000 : {
        _fdata = . ;
        * (.data);
        * (.data.*);
        
        /* Conventionally, symbol _gp points to the middle of a 64K area at the 
           start of the sdata section ('small data section'). Register $gp is 
           loaded with _gp at program startup (in boot.s) so that data in that 
           area can be reached with just one instruction.
           Note that the compiler/assembler will put data in the sdata section 
           only if it is small enough (see as/gcc docs, -G option and others).
           FIXME this feature has not been tested.
        */
        _gp = . + 0x7ff0; /* 0x7ff0 -> middle of 64K area */
        *(.lit8);
        *(.lit4);
        *(.sdata);
        *(.sbss);
        *(.gnu.linkonce.s*);
        *(.rodata);
        *(.rodata.*);
        /* mark end of initialised data */
        _edata  =  .;
        PROVIDE (edata = .);
        
        /* start bss on dword boundary for easier clearing */
        . = ALIGN(8);
        
    }
    
    /* start bss on dword boundary for easier clearing */
    . = ALIGN(8);
    
    /* mark start of uninitialised data */
    __bss_start = .;
    _fbss = __bss_start;
    
    .bss : {
        /* *(.sbss); */
        *(.dynbss);
        *(COMMON);
        * (.bss);
        _end = . ; 
    } 
    /* mark end of uninitialised data */
    _end = . ;
    PROVIDE (end = .);
}
