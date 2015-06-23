#ifndef __MM0_UTCB_H__
#define __MM0_UTCB_H__

int utcb_pool_init();

void *utcb_new_address(int npages);
int utcb_delete_address(void *shm_addr, int npages);
unsigned long utcb_slot(struct utcb_desc *desc);
unsigned long task_new_utcb_desc(struct tcb *task);
int task_setup_utcb(struct tcb *task);
int task_destroy_utcb(struct tcb *task);


#endif /* __MM0_UTCB_H__ */
