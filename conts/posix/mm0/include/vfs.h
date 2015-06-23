#ifndef __VFS_H__
#define __VFS_H__

#include <fs.h>
#include <malloc/malloc.h>
#include <l4/lib/list.h>
#include <memfs/memfs.h>
#include <l4/macros.h>
#include <stdio.h>
#include <task.h>
#include <path.h>

/* Top nibble of vnum indicates filesystem index */
#define VFS_FSIDX_MASK		0xF0000000
#define VFS_FSIDX_SHIFT		28
#define VFS_FSIDX_SIZE		16

extern struct link vnode_cache;
extern struct link dentry_cache;
extern struct id_pool *vfs_fsidx_pool;

/*
 * This is a temporary origacement for page cache support provided by mm0.
 * Normally mm0 tracks all vnode pages, but this is used to track pages in
 * directory vnodes, which are normally never mapped by tasks.
 */
static inline void *vfs_alloc_dirpage(struct vnode *v)
{
	/*
	 * Urgh, we allocate from the block cache of memfs to store generic vfs directory
	 * pages. This is currently the quickest we can allocate page-aligned memory.
	 */
	return memfs_alloc_block(v->sb->fs_super);
}

static inline void vfs_free_dirpage(struct vnode *v, void *block)
{
	memfs_free_block(v->sb->fs_super, block);
}

static inline struct dentry *vfs_alloc_dentry(void)
{
	struct dentry *d = kzalloc(sizeof(struct dentry));

	link_init(&d->child);
	link_init(&d->children);
	link_init(&d->vref);
	link_init(&d->cache_list);

	return d;
}

static inline void vfs_free_dentry(struct dentry *d)
{
	return kfree(d);
}

static inline struct vnode *vfs_alloc_vnode(void)
{
	struct vnode *v = kzalloc(sizeof(struct vnode));

	link_init(&v->dentries);
	link_init(&v->cache_list);

	return v;
}

static inline void vfs_free_vnode(struct vnode *v)
{
	BUG(); /* Are the dentries freed ??? */
	list_remove(&v->cache_list);
	kfree(v);
}

static inline struct superblock *vfs_alloc_superblock(void)
{
	struct superblock *sb = kmalloc(sizeof(struct superblock));
	int fsidx = id_new(vfs_fsidx_pool);

	sb->fsidx = fsidx << VFS_FSIDX_SHIFT;
	link_init(&sb->list);

	return sb;
}

struct vfs_mountpoint {
	struct superblock *sb;	/* The superblock of mounted filesystem */
	struct vnode *pivot;	/* The dentry upon which we mount */
};

extern struct vfs_mountpoint vfs_root;

int vfs_mount_root(struct superblock *sb);
struct vnode *generic_vnode_lookup(struct vnode *thisnode, struct pathdata *p,
				   const char *component);
struct vnode *vfs_vnode_lookup_bypath(struct pathdata *p);
struct vnode *vfs_vnode_lookup_byvnum(struct superblock *sb, unsigned long vnum);

int vfs_init(void);

#endif /* __VFS_H__ */
