/*
 * These functions here do run-time checks on all fields
 * of tasks, vmas, and vm objects to see that they
 * have expected values.
 *
 * Copyright (C) 2008 Bahadir Balban
 */

#include <vm_area.h>
#include <mmap.h>
#include <shm.h>
#include <globals.h>

struct vm_statistics {
	int tasks;		/* All tasks counted on the system */
	int vm_objects;		/* All objects counted on the system */
	int shadow_objects;	/* Shadows counted by hand (well almost!) */
	int shadows_referred;	/* Shadows that objects say they have */
	int file_objects;	/* Objects that are found to be files */
	int vm_files;		/* All files counted on the system */
	int shm_files;		/* SHM files counted */
	int boot_files;		/* Boot files counted */
	int vfs_files;		/* VFS files counted */
	int devzero;		/* Devzero count, must be 1 */
};

/* Count links in objects link list, and compare with nlinks */
int vm_object_test_link_count(struct vm_object *vmo)
{
	int links = 0;
	struct vm_obj_link *l;

	list_foreach_struct(l, &vmo->link_list, linkref)
		links++;

	BUG_ON(links != vmo->nlinks);
	return 0;
}

int vm_object_test_shadow_count(struct vm_object *vmo)
{
	struct vm_object *sh;
	int shadows = 0;

	list_foreach_struct(sh, &vmo->shdw_list, shref)
		shadows++;

	BUG_ON(shadows != vmo->shadows);
	return 0;
}

/* TODO:
 * Add checking that total open file descriptors are
 * equal to total opener count of all files
 */
#if defined (DEBUG_FAULT_HANDLING)
int mm0_test_global_vm_integrity(void)
{
	struct tcb *task;
	struct vm_object *vmo;
	struct vm_statistics vmstat;
	struct vm_file *f;


	memset(&vmstat, 0, sizeof(vmstat));

	/* Count all shadow and file objects */
	list_foreach_struct(vmo, &global_vm_objects.list, list) {
		vmstat.shadows_referred += vmo->shadows;
		if (vmo->flags & VM_OBJ_SHADOW)
			vmstat.shadow_objects++;
		if (vmo->flags & VM_OBJ_FILE)
			vmstat.file_objects++;
		vmstat.vm_objects++;
		vm_object_test_shadow_count(vmo);
		vm_object_test_link_count(vmo);
	}

	/* Count all registered vmfiles */
	list_foreach_struct(f, &global_vm_files.list, list) {
		vmstat.vm_files++;
		if (f->type == VM_FILE_SHM)
			vmstat.shm_files++;
		else if (f->type == VM_FILE_VFS)
			vmstat.vfs_files++;
		else if (f->type == VM_FILE_DEVZERO)
			vmstat.devzero++;
		else BUG();
	}

	if (vmstat.vm_files != global_vm_files.total) {
		printf("Total counted files don't match "
		       "global_vm_files total\n");
		BUG();
	}

 	if (vmstat.vm_objects != global_vm_objects.total) {
		printf("Total counted vm_objects don't "
		       "match global_vm_objects total\n");
		BUG();
	}

	/* Total file objects must be equal to total vm files */
	if (vmstat.vm_files != vmstat.file_objects) {
		printf("\nTotal files don't match total file objects.\n");
		printf("vm files:\n");
		vm_print_files(&global_vm_files.list);
		printf("\nvm objects:\n");
		vm_print_objects(&global_vm_objects.list);
		printf("\n");
		BUG();
	}

	/* Counted and referred shadows must match */
	BUG_ON(vmstat.shadow_objects != vmstat.shadows_referred);

	/* Count all tasks */
	list_foreach_struct(task, &global_tasks.list, list)
		vmstat.tasks++;

 	if (vmstat.tasks != global_tasks.total) {
		printf("Total counted tasks don't match global_tasks total\n");
		BUG();
	}
	return 0;
}
#else /* End of DEBUG_FAULT_HANDLING */

int mm0_test_global_vm_integrity(void) { return 0; }

#endif /* End of !DEBUG_FAULT_HANDLING */
