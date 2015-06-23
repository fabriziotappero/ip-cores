/*
 * Filesystem initialisation.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <fs.h>
#include <vfs.h>
#include <bdev.h>
#include <task.h>
#include <stdio.h>
#include <string.h>
#include <l4/lib/list.h>
#include <l4/api/errno.h>
#include <memfs/memfs.h>

struct link fs_type_list;

struct superblock *vfs_probe_filesystems(void *block)
{
	struct file_system_type *fstype;
	struct superblock *sb;

	list_foreach_struct(fstype, &fs_type_list, list) {
		/* Does the superblock match for this fs type? */
		if ((sb = fstype->ops.get_superblock(block))) {
			/*
			 * Add this to the list of superblocks this
			 * fs already has.
			 */
			list_insert(&sb->list, &fstype->sblist);
			return sb;
		}
	}

	return PTR_ERR(-ENODEV);
}

/*
 * Registers each available filesystem so that these can be
 * used when probing superblocks on block devices.
 */
void vfs_register_filesystems(void)
{
	/* Initialise fstype list */
	link_init(&fs_type_list);

	/* Call per-fs registration functions */
	memfs_register_fstype(&fs_type_list);
}

/*
 * Filesystem initialisation.
 */
int vfs_init(void)
{
	void *rootdev_blocks;
	struct superblock *root_sb;

	/* Initialize superblock ids */
	vfs_fsidx_pool = id_pool_new_init(VFS_FSIDX_SIZE);

	/*
	 * Waste first one so that vnums
	 * always orr with a non-zero value
	 */
	id_new(vfs_fsidx_pool);

	/* Get standard init data from microkernel */
	// request_initdata(&initdata);

	/* Register compiled-in filesystems with vfs core. */
	vfs_register_filesystems();

	/* Get a pointer to first block of root block device */
	rootdev_blocks = vfs_rootdev_open();

	/*
	 * Since the *only* filesystem we have is a temporary memory
	 * filesystem, we create it on the root device first.
	 */
	memfs_format_filesystem(rootdev_blocks);

	/* Search for a filesystem on the root device */
	BUG_ON(IS_ERR(root_sb = vfs_probe_filesystems(rootdev_blocks)));

	/* Mount the filesystem on the root device */
	vfs_mount_root(root_sb);

	printf("%s: Mounted memfs root filesystem.\n", __TASKNAME__);

	return 0;
}

