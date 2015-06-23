
#ifndef __PRINTK_H__
#define __PRINTK_H__

#include <stdarg.h>

#if !defined(__KERNEL__)
#define	printk 		printf
#else
int printk(char *format, ...) __attribute__((format (printf, 1, 2)));
extern void putc(char c);
void init_printk_lock(void);
#endif

#endif /* __PRINTK_H__ */
