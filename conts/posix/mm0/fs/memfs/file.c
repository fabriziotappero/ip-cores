/*
 * Memfs file operations
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <fs.h>
#include <vfs.h>
#include <file.h>
#include <memfs/memfs.h>
#include <stdio.h>
#include <string.h>
#include <l4/macros.h>
#include <l4/api/errno.h>
#include INC_GLUE(memory.h)


#if 0

/*
 * FIXME: read_write() could be more layered using these functions.
 */
void *memfs_read_block(struct vnode *v, int blknum)
{
	void *buf = vfs_alloc_block();

	if (!buf)
		return PTR_ERR(-ENOMEM);

	if(!v->block[blknum])
		return PTR_ERR(-EEXIST);

	memcpy(buf, &v->block[blknum], v->sb->blocksize);
	return buf;
}

int memfs_write_block(struct vnode *v, int blknum, void *buf)
{
	if(!v->block[blknum])
		return -EEXIST;

	memcpy(&v->block[blknum], buf, v->sb->blocksize);
	return 0;
}
#endif

/*
 * Handles both read and writes since most details are common.
 *
 * TODO: Think about whether to use inode or the vnode's fields (e.g. size)
 * and when updated, which one is to be updated first. Normally if you use and
 * update inode, then you sync vnode via read_vnode. but this is not really meant for
 * this use, its meant for retrieving an unknown inode under the vnode with valid vnum.
 * here we already have the inode.
 */
int memfs_file_read_write(struct vnode *v, unsigned int pfn,
			  unsigned int npages, void *buf, int wr)
{
	struct memfs_inode *i;
	struct memfs_superblock *memfs_sb;
	unsigned int start, end, count;
	u32 blocksize;

	/* Don't support different block and page sizes for now */
	BUG_ON(v->sb->blocksize != PAGE_SIZE);

	/* Buffer must be page aligned */
	BUG_ON(!is_page_aligned(buf));

	/* Low-level fs refs must be valid */
	BUG_ON(!(i = v->inode));
	BUG_ON(!(memfs_sb = v->sb->fs_super));
	blocksize = v->sb->blocksize;

	/* Check filesystem per-file size limit */
	if ((pfn + npages) > memfs_sb->fmaxblocks) {
		printf("%s: fslimit: Trying to %s outside maximum file range: %x-%x\n",
		       __FUNCTION__, (wr) ? "write" : "read", pfn, pfn + npages);
		return -EINVAL;	/* Same error that posix llseek returns */
	}

	/* Read-specific operations */
	if (!wr) {
		/* Find read boundaries from expected range and file's current range */
		start = pfn < __pfn(v->size) ? pfn : __pfn(v->size);
		end = pfn + npages < __pfn(page_align_up(v->size))
		      ? pfn + npages : __pfn(page_align_up(v->size));
		count = end - start;

		/* Copy the data from inode blocks into page buffer */
		for (int x = start, bufpage = 0; x < end; x++, bufpage++)
			memcpy(((void *)buf) + (bufpage * blocksize),
			       i->block[x], blocksize);
		return (int)(count * blocksize);
	} else { /* Write-specific operations */
		/* Is the write beyond current file size? */
		if (v->size < ((pfn + npages) * (blocksize))) {
			unsigned long pagediff = pfn + npages - __pfn(v->size);
			unsigned long holes;

			/*
			 * If write is not consecutively after the currently
			 * last file block, the gap must be filled in by holes.
			 */
			if (pfn > __pfn(v->size))
				holes = pfn - __pfn(v->size);
			else
				holes = 0;

			/* Allocate new blocks */
			for (int x = 0; x < pagediff; x++)
				if (!(i->block[__pfn(v->size) + x] =
				      memfs_alloc_block(v->sb->fs_super)))
					return -ENOSPC;

			/* Zero out the holes. FIXME: How do we zero out non-page-aligned bytes?` */
			for (int x = 0; x < holes; x++)
				memset(i->block[__pfn(v->size) + x], 0, blocksize);
		}

		/* Copy the data from page buffer into inode blocks */
		for (int x = pfn, bufpage = 0; x < pfn + npages; x++, bufpage++)
			memcpy(i->block[x], ((void *)buf) + (bufpage * blocksize), blocksize);
	}

	return (int)(npages * blocksize);
}

int memfs_file_write(struct vnode *v, unsigned long pfn, unsigned long npages, void *buf)
{
	return memfs_file_read_write(v, pfn, npages, buf, 1);
}

int memfs_file_read(struct vnode *v, unsigned long pfn, unsigned long npages, void *buf)
{
	return memfs_file_read_write(v, pfn, npages, buf, 0);
}

struct file_ops memfs_file_operations = {
	.read = memfs_file_read,
	.write = memfs_file_write,
};

