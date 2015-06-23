#ifndef __USER_H__
#define __USER_H__

#include <task.h>

int pager_validate_user_range(struct tcb *user, void *userptr, unsigned long size,
			      unsigned int vm_flags);
void *pager_get_user_page(struct tcb *user, void *userptr,
			  unsigned long size, unsigned int vm_flags);
int copy_user_args(struct tcb *task, struct args_struct *args,
		   void *argv_user, int args_max);
int copy_user_buf(struct tcb *task, void *buf, char *user, int maxlength,
		  int elem_size);
int copy_user_string(struct tcb *task, void *buf, char *user, int maxlength);
int copy_to_user(struct tcb *task, char *user, void *buf, int size);
int copy_from_user(struct tcb *task, void *buf, char *user, int size);

#endif /* __USER_H__ */
