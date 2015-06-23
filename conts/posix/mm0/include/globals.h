#ifndef __GLOBALS_H__
#define __GLOBALS_H__

struct global_list {
	int total;
	struct link list;
};

extern struct global_list global_vm_files;
extern struct global_list global_vm_objects;
extern struct global_list global_tasks;

#endif /* __GLOBALS_H__ */
