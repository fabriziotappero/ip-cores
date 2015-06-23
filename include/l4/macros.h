#ifndef __MACROS_H__
#define __MACROS_H__
#include "config.h"

#define __KERNELNAME__			"code0"

/*
 * This file is automatically included before the first line of any
 * source file, using gcc's -imacro command line option.  Only macro
 * definitions will be extracted.
 */
#define INC_ARCH(x)             <l4/arch/__ARCH__/x>
#define INC_SUBARCH(x)		<l4/arch/__ARCH__/__SUBARCH__/x>
#define INC_CPU(x)		<l4/arch/__ARCH__/__SUBARCH__/__CPU__/x>
#define INC_PLAT(x)             <l4/platform/__PLATFORM__/x>
#define INC_API(x)              <l4/api/x>
#define INC_GLUE(x)             <l4/glue/__ARCH__/x>

#define __initdata	SECTION(".init.data")

/*
 * FIXME: Remove __CPP__
 * This is defined in kernel linker.lds.in,
 * find some better way.
 */
#if !defined(__CPP__)
/* use this to place code/data in a certain section */
#define SECTION(x) __attribute__((section(x)))
#define ALIGN(x) __attribute__((aligned (x)))
#endif

/* Functions for critical path optimizations */
#if (__GNUC__ >= 3)
#define unlikely(x)		__builtin_expect((x), false)
#define likely(x)		__builtin_expect((x), true)
#define likelyval(x,val)	__builtin_expect((x), (val))
#else /* __GNUC__ < 3 */
#define likely(x)		(x)
#define unlikely(x)		(x)
#define likelyval(x,val)	(x)
#endif /* __GNUC__ < 3 */

/* This guard is needed because tests use host C library and NULL is defined */
#ifndef NULL
#define NULL			0
#endif
/* Convenience functions for memory sizes. */
#define SZ_1K			1024
#define SZ_2K			2048
#define SZ_4K			0x1000
#define SZ_16K			0x4000
#define SZ_32K			0x8000
#define SZ_64K			0x10000
#define SZ_1MB			0x100000
#define SZ_2MB			0x200000
#define SZ_4MB			(4*SZ_1MB)
#define SZ_8MB			(8*SZ_1MB)
#define SZ_16MB			(16*SZ_1MB)
#define SZ_1K_BITS		10
#define SZ_4K_BITS		12
#define SZ_16K_BITS		14
#define SZ_1MB_BITS		20

/* Per-cpu variables */

#if defined CONFIG_SMP
#define DECLARE_PERCPU(type, name)	\
type name[CONFIG_NCPU]

#define per_cpu(val)	(val)[smp_get_cpuid()]
#define per_cpu_byid(val, cpu)	(val)[(cpu)]

#else /* Not CONFIG_SMP */

#define DECLARE_PERCPU(type, name)	\
type name

#define per_cpu(val)	(val)
#define per_cpu_byid(val, cpu)	val

#endif /* End of Not CONFIG_SMP */

#ifndef __ASSEMBLY__
#include <stddef.h>	/* offsetof macro, defined in the `standard' way. */
#endif

#define container_of(ptr, struct_type, field)					\
({										\
	const typeof(((struct_type *)0)->field) *field_ptr = (ptr);		\
	(struct_type *)((char *)field_ptr - offsetof(struct_type, field));	\
})

/* Prefetching is noop for now */
#define	prefetch(x)		x

#if !defined(__KERNEL__)
#define printk			printf
#endif

/* Converts an int-sized field offset in a struct into a bit offset in a word */
#define FIELD_TO_BIT(type, field)	(1 << (offsetof(type, field) >> 2))

/* Functions who may either return a pointer or an error code can use these: */
#define PTR_ERR(x)		((void *)(x))
/* checks up to -1000, the rest might be valid pointers!!! E.g. 0xE0000000 */
// #define IS_ERR(x)		((((int)(x)) < 0) && (((int)(x) > -1000)))
#if !defined(__ASSEMBLY__)
#define IS_ERR(x)	is_err((int)(x))
static inline int is_err(int x)
{
	return x < 0 && x > -0x1000;
}
#endif

/* TEST: Is this type of printk well tested? */
#define BUG()			{do {								\
					printk("BUG in file: %s function: %s line: %d\n",	\
						__FILE__, __FUNCTION__, __LINE__);		\
				} while(0);							\
				while(1);}

#define BUG_ON(x)		{if (x) BUG();}

#define WARN_ON(x)	{if (x) printk("%s, %s, %s: Warning something is off here.\n", __FILE__, __FUNCTION__, __LINE__); }

#define BUG_ON_MSG(msg, x)	do {				\
					printk(msg);		\
					BUG_ON(x)		\
				} while(0)

#define BUG_MSG(msg...)	do {				\
					printk(msg);	\
					BUG();			\
				} while(0)
#endif /* __MACROS_H__ */
