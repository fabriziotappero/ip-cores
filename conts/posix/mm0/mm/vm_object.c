/*
 * vm object utility functions.
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <file.h>
#include <vm_area.h>
#include <l4/macros.h>
#include <l4/api/errno.h>
#include <malloc/malloc.h>
#include <globals.h>

/* Global list of all in-memory files on the system */
struct global_list global_vm_files = {
	.list = { &global_vm_files.list, &global_vm_files.list },
	.total = 0,
};

/* Global list of in-memory vm objects in the system */
struct global_list global_vm_objects = {
	.list = { &global_vm_objects.list, &global_vm_objects.list },
	.total = 0,
};


void global_add_vm_object(struct vm_object *obj)
{
	BUG_ON(!list_empty(&obj->list));
	list_insert(&obj->list, &global_vm_objects.list);
	global_vm_objects.total++;
}

void global_remove_vm_object(struct vm_object *obj)
{
	BUG_ON(list_empty(&obj->list));
	list_remove_init(&obj->list);
	BUG_ON(--global_vm_objects.total < 0);
}

void global_add_vm_file(struct vm_file *f)
{
	BUG_ON(!list_empty(&f->list));
	list_insert(&f->list, &global_vm_files.list);
	global_vm_files.total++;

	global_add_vm_object(&f->vm_obj);
}

void global_remove_vm_file(struct vm_file *f)
{
	BUG_ON(list_empty(&f->list));
	list_remove_init(&f->list);
	BUG_ON(--global_vm_files.total < 0);

	global_remove_vm_object(&f->vm_obj);
}

void print_cache_pages(struct vm_object *vmo)
{
	struct page *p;

	if (!list_empty(&vmo->page_cache))
		printf("Pages:\n======\n");

	list_foreach_struct(p, &vmo->page_cache, list) {
		dprintf("Page offset: 0x%lx, virtual: 0x%lx, refcnt: %d\n", p->offset,
		       p->virtual, p->refcnt);
	}
}

void vm_object_print(struct vm_object *vmo)
{
	struct vm_file *f;

	printf("Object type: %s %s. links: %d, shadows: %d, Pages in cache: %d.\n",
	       vmo->flags & VM_WRITE ? "writeable" : "read-only",
	       vmo->flags & VM_OBJ_FILE ? "file" : "shadow", vmo->nlinks, vmo->shadows,
	       vmo->npages);
	if (vmo->flags & VM_OBJ_FILE) {
		f = vm_object_to_file(vmo);
		char *ftype;

		if (f->type == VM_FILE_DEVZERO)
			ftype = "devzero";
		else if (f->type == VM_FILE_SHM)
			ftype = "shm file";
		else if (f->type == VM_FILE_VFS)
			ftype = "regular";
		else
			BUG();

		printf("File type: %s\n", ftype);
	}
	// print_cache_pages(vmo);
	// printf("\n");
}

void vm_print_files(struct link *files)
{
	struct vm_file *f;

	list_foreach_struct(f, files, list)
		vm_object_print(&f->vm_obj);
}

void vm_print_objects(struct link *objects)
{
	struct vm_object *vmo;

	list_foreach_struct(vmo, objects, list)
		vm_object_print(vmo);
}

struct vm_object *vm_object_init(struct vm_object *obj)
{
	link_init(&obj->list);
	link_init(&obj->shref);
	link_init(&obj->shdw_list);
	link_init(&obj->page_cache);
	link_init(&obj->link_list);

	return obj;
}

/* Allocate and initialise a vmfile, and return it */
struct vm_object *vm_object_create(void)
{
	struct vm_object *obj;

	if (!(obj = kzalloc(sizeof(*obj))))
		return 0;

	return vm_object_init(obj);
}

struct vm_file *vm_file_create(void)
{
	struct vm_file *f;

	if (!(f = kzalloc(sizeof(*f))))
		return PTR_ERR(-ENOMEM);

	link_init(&f->list);
	vm_object_init(&f->vm_obj);
	f->vm_obj.flags = VM_OBJ_FILE;

	return f;
}

/*
 * Populates the priv_data with vfs-file-specific
 * information.
 */
struct vm_file *vfs_file_create(void)
{
	struct vm_file *f = vm_file_create();

	if (IS_ERR(f))
		return f;

	f->type = VM_FILE_VFS;

	return f;
}

/* Deletes the object via its base, along with all its pages */
int vm_object_delete(struct vm_object *vmo)
{
	struct vm_file *f;

	// vm_object_print(vmo);

	/* Release all pages */
	vmo->pager->ops.release_pages(vmo);

	/* Remove from global list */
	if (vmo->flags & VM_OBJ_FILE)
		global_remove_vm_file(vm_object_to_file(vmo));
	else if (vmo->flags & VM_OBJ_SHADOW)
		global_remove_vm_object(vmo);
	else BUG();

	/* Check any references */
	BUG_ON(vmo->nlinks);
	BUG_ON(vmo->shadows);
	BUG_ON(!list_empty(&vmo->shdw_list));
	BUG_ON(!list_empty(&vmo->link_list));
	BUG_ON(!list_empty(&vmo->page_cache));
	BUG_ON(!list_empty(&vmo->shref));

	/* Obtain and free via the base object */
	if (vmo->flags & VM_OBJ_FILE) {
		f = vm_object_to_file(vmo);
		BUG_ON(!list_empty(&f->list));
		if (f->private_file_data) {
			if (f->destroy_priv_data)
				f->destroy_priv_data(f);
			else
				kfree(f->private_file_data);
		}
		kfree(f);
	} else if (vmo->flags & VM_OBJ_SHADOW)
		kfree(vmo);
	else BUG();

	return 0;
}

int vm_file_delete(struct vm_file *f)
{
	/* Delete file via base object */
	return vm_object_delete(&f->vm_obj);
}

