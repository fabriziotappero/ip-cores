#ifndef GCC_TM_H
#define GCC_TM_H
#ifndef LIBC_GLIBC
# define LIBC_GLIBC 1
#endif
#ifndef LIBC_UCLIBC
# define LIBC_UCLIBC 2
#endif
#ifndef LIBC_BIONIC
# define LIBC_BIONIC 3
#endif
#ifndef OR1K_DELAY_DEFAULT
# define OR1K_DELAY_DEFAULT OR1K_DELAY_OFF
#endif
#ifdef IN_GCC
# include "options.h"
# include "insn-constants.h"
# include "config/or1k/or1k.h"
# include "config/dbxelf.h"
# include "config/elfos.h"
# include "config/newlib-stdint.h"
# include "config/or1k/elf.h"
# include "config/initfini-array.h"
#endif
#if defined IN_GCC && !defined GENERATOR_FILE && !defined USED_FOR_TARGET
# include "insn-flags.h"
#endif
# include "defaults.h"
#endif /* GCC_TM_H */
