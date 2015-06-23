#ifndef __ARCH_TYPES_H__
#define __ARCH_TYPES_H__

#if !defined(__ASSEMBLY__)
typedef unsigned long long u64;
typedef unsigned int u32;
typedef unsigned short u16;
typedef unsigned char u8;
typedef signed long long s64;
typedef signed int s32;
typedef signed short s16;
typedef signed char s8;

/* Thread/Space id type */
typedef unsigned int l4id_t;

#endif /* !__ASSEMBLY__ */
#endif /* !__ARCH_TYPES_H__ */
