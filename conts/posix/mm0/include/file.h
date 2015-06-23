#ifndef __MM0_FILE_H__
#define __MM0_FILE_H__

#include <l4/lib/list.h>
#include <l4lib/types.h>
#include <posix/sys/types.h>	/* FIXME: Remove this and refer to internal headers */
#include <task.h>

int vfs_read(struct vnode *v, unsigned long f_offset,
	     unsigned long npages, void *pagebuf);
int vfs_write(struct vnode *v, unsigned long f_offset,
	      unsigned long npages, void *pagebuf);
int sys_read(struct tcb *sender, int fd, void *buf, int count);
int sys_write(struct tcb *sender, int fd, void *buf, int count);
int sys_lseek(struct tcb *sender, int fd, off_t offset, int whence);
int sys_close(struct tcb *sender, int fd);
int sys_fsync(struct tcb *sender, int fd);
int file_open(struct tcb *opener, int fd);

int vfs_open_bypath(const char *pathname, unsigned long *vnum, unsigned long *length);

struct vm_file *do_open2(struct tcb *task, int fd, unsigned long vnum, unsigned long length);
int flush_file_pages(struct vm_file *f);
int read_file_pages(struct vm_file *vmfile, unsigned long pfn_start,
		    unsigned long pfn_end);

struct vm_file *vfs_file_create(void);


extern struct link vm_file_list;

#endif /* __MM0_FILE_H__ */
