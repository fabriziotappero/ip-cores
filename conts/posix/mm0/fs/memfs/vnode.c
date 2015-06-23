/*
 * Inode and vnode implementation.
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <fs.h>
#include <vfs.h>
#include <memfs/memfs.h>
#include <memfs/file.h>
#include <l4/lib/list.h>
#include <l4/api/errno.h>
#include <l4/macros.h>
#include <malloc/malloc.h>
#include <stdio.h>


struct memfs_inode *memfs_alloc_inode(struct memfs_superblock *sb)
{
	struct mem_cache *cache;
	struct memfs_inode *i;
	void *free_block;

	/* Ask existing inode caches for a new inode */
	list_foreach_struct(cache, &sb->inode_cache_list, list) {
		if (cache->free)
			if (!(i =  mem_cache_zalloc(cache)))
				return PTR_ERR(-ENOSPC);
			else
				return i;
		else
			continue;
	}

	/* Ask existing block caches for a new block */
	if (IS_ERR(free_block = memfs_alloc_block(sb)))
		return PTR_ERR(free_block);

	/* Initialise it as an inode cache */
	cache = mem_cache_init(free_block, sb->blocksize,
			       sizeof(struct memfs_inode), 0);
	list_insert(&cache->list, &sb->inode_cache_list);

	if (!(i =  mem_cache_zalloc(cache)))
		return PTR_ERR(-ENOSPC);
	else
		return i;
}

/*
 * O(n^2) complexity but its simple, yet it would only reveal on high numbers.
 */
int memfs_free_inode(struct memfs_superblock *sb, struct memfs_inode *i)
{
	struct mem_cache *c, *tmp;

	list_foreach_removable_struct(c, tmp, &sb->inode_cache_list, list) {
		/* Free it, if success */
		if (!mem_cache_free(c, i)) {
			/* If cache completely emtpy */
			if (mem_cache_is_empty(c)) {
				/* Free the block, too. */
				list_remove(&c->list);
				memfs_free_block(sb, c);
			}
			return 0;
		}
	}
	return -EINVAL;
}

/* Allocates *and* initialises the inode */
struct memfs_inode *memfs_create_inode(struct memfs_superblock *sb)
{
	struct memfs_inode *i;

	/* Allocate the inode */
	if (PTR_ERR(i = memfs_alloc_inode(sb)) < 0)
		return i;

	/* Allocate a new inode number */
	if ((i->inum = id_new(sb->ipool)) < 0)
		return i;

	/* Put a reference to this inode in the inode table at this index */
	sb->inode[i->inum] = i;

	return i;
}

/* Deallocate the inode and any other closely relevant structure */
int memfs_destroy_inode(struct memfs_superblock *sb, struct memfs_inode *i)
{
	int inum = i->inum;

	/* Deallocate the inode */
	if (memfs_free_inode(sb, i) < 0)
		return -EINVAL;

	/* Deallocate the inode number */
	if (id_del(sb->ipool, inum) < 0)
		return -EINVAL;

	/* Clear the ref in inode table */
	sb->inode[inum] = 0;

	return 0;
}

/* Allocates both an inode and a vnode and associates the two together */
struct vnode *memfs_alloc_vnode(struct superblock *sb)
{
	struct memfs_inode *i;
	struct vnode *v;

	/* Get a (pseudo-disk) memfs inode */
	if (IS_ERR(i = memfs_create_inode(sb->fs_super)))
		return PTR_ERR(i);

	/* Get a vnode */
	if (!(v = vfs_alloc_vnode()))
		return PTR_ERR(-ENOMEM);

	/* Associate the two together */
	v->inode = i;
	v->vnum = i->inum | sb->fsidx;	/* Globalize by fsidx */

	/* Associate memfs-specific fields with vnode */
	v->ops = memfs_vnode_operations;
	v->fops = memfs_file_operations;
	v->sb = sb;

	/* Return the vnode */
	return v;
}

/* Frees the inode and the corresponding vnode */
int memfs_free_vnode(struct superblock *sb, struct vnode *v)
{
	struct memfs_inode *i = v->inode;

	BUG_ON(!i); /* Vnodes that come here must have valid inodes */

	/* Destroy on-disk inode */
	memfs_destroy_inode(sb->fs_super, i);

	/* Free vnode */
	vfs_free_vnode(v);

	return 0;
}

/*
 * Given a vnode with a valid vnum, this retrieves the corresponding
 * inode from the filesystem.
 */
struct memfs_inode *memfs_read_inode(struct superblock *sb, struct vnode *v)
{
	struct memfs_superblock *fssb = sb->fs_super;

	BUG_ON(!fssb->inode[v->vnum]);

	return fssb->inode[v->vnum];
}

/*
 * Given a preallocated vnode with a valid vnum, this reads the corresponding
 * inode from the filesystem and fills in the vnode's fields.
 */
int memfs_read_vnode(struct superblock *sb, struct vnode *v)
{
	struct memfs_inode *i = memfs_read_inode(sb, v);

	if (!i)
		return -EEXIST;

	/* Simply copy common fields */
	v->vnum = i->inum | sb->fsidx;
	v->size = i->size;
	v->mode = i->mode;
	v->owner = i->owner;
	v->atime = i->atime;
	v->mtime = i->mtime;
	v->ctime = i->ctime;

	return 0;
}

/* Writes a valid vnode's fields back to its fs-specific inode */
int memfs_write_vnode(struct superblock *sb, struct vnode *v)
{
	struct memfs_inode *i = v->inode;

	/* Vnodes that come here must have valid inodes */
	BUG_ON(!i);

	/* Simply copy common fields */
	i->inum = v->vnum & ~VFS_FSIDX_MASK;
	i->size = v->size;
	i->mode = v->mode;
	i->owner = v->owner;
	i->atime = v->atime;
	i->mtime = v->mtime;
	i->ctime = v->ctime;

	return 0;
}


/*
 * Creates ordinary files and directories at the moment. In the future,
 * other file types will be added. Returns the created node.
 */
struct vnode *memfs_vnode_mknod(struct vnode *v, const char *dirname,
				unsigned int mode)
{
	struct dentry *d, *parent = link_to_struct(v->dentries.next,
					       struct dentry, vref);
	struct memfs_dentry *memfsd;
	struct dentry *newd;
	struct vnode *newv;
	int err;

	/*
	 * Precautions to prove that parent is the *only* dentry,
	 * since directories can't have multiple dentries associated
	 * with them.
	 */
	BUG_ON(list_empty(&v->dentries));
	BUG_ON(parent->vref.next != &v->dentries);
	BUG_ON(!vfs_isdir(v));

	/* Populate the children */
	if ((err = v->ops.readdir(v)) < 0)
		return PTR_ERR(err);

	/* Check there's no existing child with same name */
	list_foreach_struct(d, &parent->children, child) {
		/* Does the name exist as a child? */
		if(d->ops.compare(d, dirname))
			return PTR_ERR(-EEXIST);
	}

	/* Allocate a new vnode for the new directory */
	if (IS_ERR(newv = v->sb->ops->alloc_vnode(v->sb)))
		return newv;

	/* Initialise the vnode */
	vfs_set_type(newv, mode);

	/* Get the next directory entry available on the parent vnode */
	if (v->dirbuf.npages * PAGE_SIZE <= v->size)
		return PTR_ERR(-ENOSPC);

	/* Fill in the new entry to parent directory entry */
	memfsd = (struct memfs_dentry *)&v->dirbuf.buffer[v->size];
	memfsd->offset = v->size;
	memfsd->rlength = sizeof(*memfsd);
	memfsd->inum = ((struct memfs_inode *)newv->inode)->inum;
	strncpy((char *)memfsd->name, dirname, MEMFS_DNAME_MAX);
	memfsd->name[MEMFS_DNAME_MAX - 1] = '\0';

	/* Write the updated directory buffer back to disk block */
	if ((err = v->fops.write(v, 0, 1, v->dirbuf.buffer)) < 0)
		return PTR_ERR(err); /* FIXME: free all you allocated so far */

	/* Update parent vnode size */
	v->size += sizeof(*memfsd);
	v->sb->ops->write_vnode(v->sb, v);

	/* Allocate a new vfs dentry */
	if (!(newd = vfs_alloc_dentry()))
		return PTR_ERR(-ENOMEM);

	/* Initialise it */
	newd->ops = generic_dentry_operations;
	newd->parent = parent;
	newd->vnode = newv;
	strncpy(newd->name, dirname, VFS_DNAME_MAX);

	/* Associate dentry with its vnode */
	list_insert(&newd->vref, &newd->vnode->dentries);

	/* Associate dentry with its parent */
	list_insert(&newd->child, &parent->children);

	/* Add both vnode and dentry to their flat caches */
	list_insert(&newd->cache_list, &dentry_cache);
	list_insert(&newv->cache_list, &vnode_cache);

	return newv;
}

/*
 * Reads the vnode directory contents into vnode's buffer in a posix-compliant
 * struct dirent format.
 *
 * Reading the buffer, allocates and populates all dentries and their
 * corresponding vnodes that are the direct children of vnode v. This means
 * that by each call to readdir, the vfs layer increases its cache of filesystem
 * tree by one level beneath that directory.
 */
int memfs_vnode_readdir(struct vnode *v)
{
	int err;
	struct memfs_dentry *memfsd;
	struct dentry *parent = link_to_struct(v->dentries.next,
					   struct dentry, vref);

	/*
	 * Precautions to prove that parent is the *only* dentry,
	 * since directories can't have multiple dentries associated
	 * with them.
	 */
	BUG_ON(parent->vref.next != &v->dentries);
	BUG_ON(!vfs_isdir(v));

	/* If a buffer is there, it means the directory is already read */
	if (v->dirbuf.buffer)
		return 0;

	/* This is as big as a page */
	if (IS_ERR(v->dirbuf.buffer = vfs_alloc_dirpage(v))) {
		printf("%s: Could not allocate dirbuf.\n", __FUNCTION__);
		return (int)v->dirbuf.buffer;
	}
	v->dirbuf.npages = 1;

	/*
	 * Fail if vnode size is bigger than a page. Since this allocation
	 * method is to be origaced, we can live with this limitation for now.
	 */
	BUG_ON(v->size > PAGE_SIZE);

	/* Read memfsd contents into the buffer */
	if ((err = v->fops.read(v, 0, 1, v->dirbuf.buffer)))
		return err;

	memfsd = (struct memfs_dentry *)v->dirbuf.buffer;

	/* Read fs-specific directory entry into vnode and dentry caches. */
	for (int i = 0; i < (v->size / sizeof(struct memfs_dentry)); i++) {
		struct dentry *newd;
		struct vnode *newv;

		/* Allocate a vfs dentry */
		if (!(newd = vfs_alloc_dentry()))
			return -ENOMEM;

		/* Initialise it */
		newd->ops = generic_dentry_operations;
		newd->parent = parent;
		list_insert(&newd->child, &parent->children);

		/*
		 * Lookup the vnode for dentry by its vnode number. We call
		 * vnode_lookup_byvnum instead of directly reading it because
		 * this dentry might just be a link to a vnode that's already
		 * in the vnode cache. If it's not there, the lookup function
		 * allocates and reads it for us as well.
		 */
		newv = newd->vnode = vfs_vnode_lookup_byvnum(v->sb, memfsd[i].inum);
		if (!newv) {
			printf("Filesystem seems to be broken. Directory has"
			       "inode number: %d, but no such inode found.\n",
				memfsd[i].inum);
			BUG();
		}

		/* Assing this dentry as a name of its vnode */
		list_insert(&newd->vref, &newd->vnode->dentries);

		/* Increase link count */
		newv->links++;

		/* Copy fields into generic dentry */
		memcpy(newd->name, memfsd[i].name, MEMFS_DNAME_MAX);

		/* Add both vnode and dentry to their caches */
		list_insert(&newd->cache_list, &dentry_cache);
		list_insert(&newv->cache_list, &vnode_cache);
	}

	return 0;
}

/*
 * Copies fs-specific dirent data into user buffer in
 * generic struct dirent format.
 */
int memfs_vnode_filldir(void *userbuf, struct vnode *v, int count)
{
	int nbytes;
	int err;

	/* Bytes to read, minimum of vnode size and count requested */
	nbytes = (v->size <= count) ? v->size : count;

	/* Read the dir content from fs, if haven't done so yet */
	if ((err = v->ops.readdir(v)) < 0)
		return err;

	/* Do we have those bytes at hand? */
	if (v->dirbuf.buffer && (v->dirbuf.npages * PAGE_SIZE) >= nbytes) {
		/*
		 * Memfs does a direct copy since memfs dirent format
		 * is the same as generic dirent format.
		 */
		memcpy(userbuf, v->dirbuf.buffer, nbytes);
		return nbytes;
	}
	return 0;
}

struct vnode_ops memfs_vnode_operations = {
	.readdir = memfs_vnode_readdir,
	.filldir = memfs_vnode_filldir,
	.mknod = memfs_vnode_mknod,
	.lookup = generic_vnode_lookup,
};

struct superblock_ops memfs_superblock_operations = {
	.read_vnode = memfs_read_vnode,
	.write_vnode = memfs_write_vnode,
	.alloc_vnode = memfs_alloc_vnode,
	.free_vnode = memfs_free_vnode,
};

