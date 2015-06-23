/*
 * A simple read/writeable memory-only filesystem.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */
#include <init.h>
#include <fs.h>
#include <vfs.h>
#include <task.h>
#include <stdio.h>
#include <memfs/memfs.h>
#include <memfs/vnode.h>
#include <lib/idpool.h>
#include <l4/macros.h>
#include <l4/types.h>
#include <l4/api/errno.h>
#include INC_GLUE(memory.h)

struct memfs_superblock *memfs_superblock;

/* Initialise allocation caches as part of superblock initialisation */
int memfs_init_caches(struct memfs_superblock *sb)
{
	void *free_block;
	struct mem_cache *block_cache;
	struct mem_cache *inode_cache;

	/* Use the whole filesystem space to initialise block cache */
	free_block = (void *)sb + sizeof(*sb);
	block_cache = mem_cache_init(free_block, sb->fssize - sizeof(*sb),
				     sb->blocksize, 1);
	list_insert(&block_cache->list, &sb->block_cache_list);

	/* Allocate a block and initialise it as first inode cache */
	free_block = mem_cache_alloc(block_cache);
	inode_cache = mem_cache_init(free_block, sb->blocksize,
				     sizeof(struct memfs_inode), 0);
	list_insert(&inode_cache->list, &sb->inode_cache_list);

	return 0;
}

/*
 * Given an empty block buffer, initialises a filesystem there.
 */
int memfs_format_filesystem(void *buffer)
{
	struct memfs_superblock *sb = buffer;	/* Buffer is the first block */

	/* Zero initialise the superblock area */
	memset(sb, 0, sizeof(*sb));

	/* Initialise filesystem parameters */
	sb->magic = MEMFS_MAGIC;
	memcpy(sb->name, MEMFS_NAME, MEMFS_NAME_SIZE);
	sb->blocksize = MEMFS_BLOCK_SIZE;
	sb->fmaxblocks = MEMFS_FMAX_BLOCKS;
	sb->fssize = MEMFS_TOTAL_SIZE;

	/* Initialise block and inode index pools */
	sb->ipool = id_pool_new_init(MEMFS_TOTAL_INODES);
	sb->bpool = id_pool_new_init(MEMFS_TOTAL_BLOCKS);

	/* Initialise bitmap allocation lists for blocks and inodes */
	link_init(&sb->block_cache_list);
	link_init(&sb->inode_cache_list);
	memfs_init_caches(sb);

	return 0;
}

/* Allocates a block of unused buffer */
void *memfs_alloc_block(struct memfs_superblock *sb)
{
	struct mem_cache *cache;

	list_foreach_struct(cache, &sb->block_cache_list, list) {
		if (cache->free)
			return mem_cache_zalloc(cache);
		else
			continue;
	}
	return PTR_ERR(-ENOSPC);
}

/*
 * Even though on a list, block allocation is currently from a single cache.
 * This frees a block back to the free buffer cache.
 */
int memfs_free_block(struct memfs_superblock *sb, void *block)
{
	struct mem_cache *c, *tmp;

	list_foreach_removable_struct(c, tmp, &sb->block_cache_list, list)
		if (!mem_cache_free(c, block))
			return 0;
		else
			return -EINVAL;
	return -EINVAL;
}

struct superblock *memfs_get_superblock(void *block);

struct file_system_type memfs_fstype = {
	.name = "memfs",
	.magic = MEMFS_MAGIC,
	.ops = {
		.get_superblock = memfs_get_superblock,
	},
};

/*
 * Initialise root inode as a directory, as in the mknod() call
 * but differently since root is parentless and is the parent of itself.
 */
int memfs_init_rootdir(struct superblock *sb)
{
	struct memfs_superblock *msb = sb->fs_super;
	struct dentry *d;
	struct vnode *v;

	/*
	 * Create the root vnode. Since this is memfs, root vnode is
	 * not read-in but dynamically created here. We expect this
	 * first vnode to have vnum = 0.
	 */
	v = sb->root = sb->ops->alloc_vnode(sb);
	msb->root_vnum = sb->root->vnum;
	BUG_ON(msb->root_vnum == 0);

	/* Initialise fields */
	vfs_set_type(v, S_IFDIR);

	/* Allocate a new vfs dentry */
	if (!(d = vfs_alloc_dentry()))
		return -ENOMEM;

	/*
	 * Initialise root dentry.
	 *
	 * NOTE: Root's parent is itself.
	 * Here's how it looks like in structures:
	 * root's parent is root. But root's child is not root.
	 *
	 * NOTE: Root has no name. This helps since splitpath
	 * cuts out the '/' and "" is left for root name search.
	 */
	strncpy(d->name, VFS_STR_ROOTDIR, VFS_DNAME_MAX);
	d->ops = generic_dentry_operations;
	d->parent = d;
	d->vnode = v;

	/* Associate dentry with its vnode */
	list_insert(&d->vref, &d->vnode->dentries);

	/* Add both vnode and dentry to their flat caches */
	list_insert(&d->cache_list, &dentry_cache);
	list_insert(&v->cache_list, &vnode_cache);

	return 0;
}

/* Copies fs-specific superblock into generic vfs superblock */
struct superblock *memfs_fill_superblock(struct memfs_superblock *sb,
					 struct superblock *vfs_sb)
{
	vfs_sb->fs = &memfs_fstype;
	vfs_sb->ops = &memfs_superblock_operations;
	vfs_sb->fs_super = sb;
	vfs_sb->fssize = sb->fssize;
	vfs_sb->blocksize = sb->blocksize;

	/* We initialise the root vnode as the root directory */
	memfs_init_rootdir(vfs_sb);

	return vfs_sb;
}

/*
 * Probes block buffer for a valid memfs superblock, if found,
 * allocates and copies data to a vfs superblock, and returns it.
 */
struct superblock *memfs_get_superblock(void *block)
{
	struct memfs_superblock *sb = block;
	struct superblock *vfs_sb;

	// printf("%s: %s: Reading superblock.\n", __TASKNAME__, __FUNCTION__);
	/* We don't do sanity checks here, just confirm id. */
	if (strcmp(sb->name, "memfs")) {
		printf("%s: Name does not match: %s\n", __FUNCTION__, sb->name);
		return 0;
	}
	if (sb->magic != MEMFS_MAGIC) {
		printf("%s: Magic number not match: %u\n", __FUNCTION__, sb->magic);
		return 0;
	}

	/* Allocate a vfs superblock. */
	vfs_sb = vfs_alloc_superblock();

	/* Fill generic sb from fs-specific sb */
	return memfs_fill_superblock(sb, vfs_sb);
}

/* Registers sfs as an available filesystem type */
void memfs_register_fstype(struct link *fslist)
{
	/* Initialise superblock list for this fstype */
	link_init(&memfs_fstype.sblist);

	/* Add this fstype to list of available fstypes. */
	list_insert(&memfs_fstype.list, fslist);
}

