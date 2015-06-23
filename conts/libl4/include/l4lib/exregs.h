#ifndef __MM0_EXREGS_H__
#define __MM0_EXREGS_H__

#include <l4/api/exregs.h>

void exregs_set_stack(struct exregs_data *s, unsigned long sp);
void exregs_set_mr(struct exregs_data *s, int offset, unsigned long val);
void exregs_set_pc(struct exregs_data *s, unsigned long pc);
void exregs_set_pager(struct exregs_data *s, l4id_t pagerid);
void exregs_set_utcb(struct exregs_data *s, unsigned long virt);
void exregs_set_read(struct exregs_data *exregs);

unsigned long exregs_get_utcb(struct exregs_data *s);
unsigned long exregs_get_stack(struct exregs_data *s);
/*
exregs_set_stack(unsigned long sp)
exregs_set_pc(unsigned long pc)
exregs_set_return(unsigned long retreg)
exregs_set_arg0(unsigned long arg0)
exregs_set_mr0(unsigned long mr0)
exregs_set_mr_sender(unsigned long sender)
exregs_set_mr_return(unsigned long retreg)
exregs_set_all(unsigned long arg0, unsigned long arg1, unsigned long arg2, unsigned long arg3,
	       unsigned long sp, unsigned long pc, u32 valid_vector, l4id_t pager);
*/

#endif /* __MM0_EXREGS_H__ */
