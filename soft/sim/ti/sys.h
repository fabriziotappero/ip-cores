// 2003: Konrad Eisele <eiselekd@web.de>
#ifndef TI_SYS_H
#define TI_SYS_H

#include <limits.h>
#include <float.h>

#ifdef NT
#ifdef TMKI_BUILD
#define EXTERN __declspec(dllexport) extern
#else
#define EXTERN __declspec(dllimport) extern
#endif /* TMKI_BUILD */
#else
#define EXTERN extern
#endif /* NT */

#define TI_ALIGN(x,y) (((x)+((y)-1))&~((y)-1))
#define TI_MEMALIGN(x) TI_ALIGN(x,sizeof(int))
#define TI_PTRADD(x,y) (((unsigned long)(x))+(y))

#endif
