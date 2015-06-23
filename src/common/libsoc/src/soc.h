/**
    @file soc.h 
    @brief 
    
    This mini-library is meant for use in systems where no underlying OS or 
    even a libc is available.
    
    The usual toolchains for MIPS (e.g. CodeSourcery) ship with precompiled
    libraries that target the MIPS32 architecture and are not easily useable 
    on the Ion CPU core (which is compatible to an R3000). This code is intended
    to replace libc entirely in applications that don't demand the whole POSIX 
    package.
    
    @note SOC conventionally stands for System On a Chip.
*/

#ifndef SOC_H_INCLUDED
#define SOC_H_INCLUDED

#include <stdint.h>

/*-- Library options ---------------------------------------------------------*/

/** !=0 to print a CR after each NL automatically */
#define IMPLICIT_CR_WITH_NL     (1)


/*-- Functions not present in libc -------------------------------------------*/

/** Return the time elapsed since last HW reset in clock cycles */
unsigned ctime(void);


#endif // SOC_H_INCLUDED
