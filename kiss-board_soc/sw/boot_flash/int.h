
#ifndef __INT_H
#define __INT_H

#define MAX_INT_HANDLERS	5

struct ihnd {
	void 	(*handler)(void *);
	void	*arg;
} typedef IHND;

int				int_init(void)								__attribute__ ((section(".text")));
int				int_add(unsigned long vect, void (* handler)(void *), void *arg)	__attribute__ ((section(".text")));
int				int_disable(unsigned long vect)						__attribute__ ((section(".icm")));
int				int_enable(unsigned long vect)						__attribute__ ((section(".icm")));
void				int_main(void)								__attribute__ ((section(".icm")));
void				dummy0x000_main(void)							__attribute__ ((section(".icm")));
void				dummy0x100_main(void)							__attribute__ ((section(".icm")));
void				dummy0x200_main(void)							__attribute__ ((section(".icm")));
void				dummy0x300_main(void)							__attribute__ ((section(".icm")));
void				dummy0x400_main(void)							__attribute__ ((section(".icm")));
void				dummy0x500_main(void)							__attribute__ ((section(".icm")));
void				dummy0x600_main(void)							__attribute__ ((section(".icm")));
void				dummy0x700_main(void)							__attribute__ ((section(".icm")));
void				dummy0x800_main(void)							__attribute__ ((section(".icm")));
void				dummy0x900_main(void)							__attribute__ ((section(".icm")));
void				dummy0xa00_main(void)							__attribute__ ((section(".icm")));
void				dummy0xb00_main(void)							__attribute__ ((section(".icm")));
void				dummy0xc00_main(void)							__attribute__ ((section(".icm")));
void				dummy0xd00_main(void)							__attribute__ ((section(".icm")));
void				dummy0xe00_main(void)							__attribute__ ((section(".icm")));
void				dummy0xf00_main(void)							__attribute__ ((section(".icm")));
void				dummy_main(void)							__attribute__ ((section(".icm")));

#endif
