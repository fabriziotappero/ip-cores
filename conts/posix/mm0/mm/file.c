/*
 * File read, write, open and close.
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <init.h>
#include <vm_area.h>
#include <malloc/malloc.h>
#include <mm/alloc_page.h>
#include <l4/macros.h>
#include <l4/api/errno.h>
#include <l4lib/types.h>
#include L4LIB_INC_ARCH(syscalls.h)
#include L4LIB_INC_ARCH(syslib.h)
#include <l4lib/ipcdefs.h>
#include <l4/api/kip.h>
#include <posix/sys/types.h>
#include <string.h>
#include <globals.h>
#include <file.h>
#include <user.h>
#include <test.h>

#include <lib/pathstr.h>
#include <malloc/malloc.h>
#include <stdio.h>
#include <task.h>
#include <stat.h>
#include <vfs.h>
#include <alloca.h>
#include <path.h>
#include <syscalls.h>

#include INC_GLUE(message.h)

/* Copy from one page's buffer into another page */
int page_copy(struct page *dst, struct page *src,
	      unsigned long dst_offset, unsigned long src_offset,
	      unsigned long size)
{
	void *dstvaddr, *srcvaddr;

	BUG_ON(dst_offset + size > PAGE_SIZE);
	BUG_ON(src_offset + size > PAGE_SIZE);

	dstvaddr = page_to_virt(dst);
	srcvaddr = page_to_virt(src);
/*
	printf("%s: Copying from page with offset %lx to page with offset %lx\n"
	       "src copy offset: 0x%lx, dst copy offset: 0x%lx, copy size: %lx\n",
	       __FUNCTION__, src->offset, dst->offset, src_offset, dst_offset,
	       size);
*/
//	printf("%s: Copying string: %s, source: %lx\n", __FUNCTION__,
//		       (char *)(srcvaddr + src_offset), (unsigned long)srcvaddr+src_offset);

	memcpy(dstvaddr + dst_offset, srcvaddr + src_offset, size);

	return 0;
}

int vfs_read(struct vnode *v, unsigned long file_offset,
	     unsigned long npages, void *pagebuf)
{
	/* Ensure vnode is not a directory */
	if (vfs_isdir(v))
		return -EISDIR;

	return v->fops.read(v, file_offset, npages, pagebuf);
}

/* Directories only for now */
void print_vnode(struct vnode *v)
{
	struct dentry *d, *c;

	printf("Vnode names:\n");
	list_foreach_struct(d, &v->dentries, vref) {
		printf("%s\n", d->name);
		printf("Children dentries:\n");
		list_foreach_struct(c, &d->children, child)
			printf("%s\n", c->name);
	}
}


/* Creates a node under a directory, e.g. a file, directory. */
struct vnode *vfs_vnode_create(struct tcb *task, struct pathdata *pdata,
			       unsigned int mode)
{
	struct vnode *vparent, *newnode;
	const char *nodename;

	/* The last component is to be created */
	nodename = pathdata_last_component(pdata);

	/* Check that the parent directory exists. */
	if (IS_ERR(vparent = vfs_vnode_lookup_bypath(pdata)))
		return vparent;

	/* The parent vnode must be a directory. */
	if (!vfs_isdir(vparent))
		return PTR_ERR(-ENOENT);

	/* Create new directory under the parent */
	if (IS_ERR(newnode = vparent->ops.mknod(vparent, nodename, mode)))
		return newnode;

	// print_vnode(vparent);
	return newnode;
}

int sys_mkdir(struct tcb *task, const char *pathname, unsigned int mode)
{
	struct pathdata *pdata;
	struct vnode *v;
	int ret = 0;

	/* Parse path data */
	if (IS_ERR(pdata = pathdata_parse(pathname,
					  alloca(strlen(pathname) + 1),
					  task)))
		return (int)pdata;

	/* Make sure we create a directory */
	mode |= S_IFDIR;

	/* Create the directory or fail */
	if (IS_ERR(v = vfs_vnode_create(task, pdata, mode)))
		ret = (int)v;

	/* Destroy extracted path data */
	pathdata_destroy(pdata);
	return ret;
}

int sys_chdir(struct tcb *task, const char *pathname)
{
	struct vnode *v;
	struct pathdata *pdata;
	int ret = 0;

	/* Parse path data */
	if (IS_ERR(pdata = pathdata_parse(pathname,
					  alloca(strlen(pathname) + 1),
					  task)))
		return (int)pdata;

	/* Get the vnode */
	if (IS_ERR(v = vfs_vnode_lookup_bypath(pdata))) {
		ret = (int)v;
		goto out;
	}

	/* Ensure it's a directory */
	if (!vfs_isdir(v)) {
		ret = -ENOTDIR;
		goto out;
	}

	/* Assign the current directory pointer */
	task->fs_data->curdir = v;

out:
	/* Destroy extracted path data */
	pathdata_destroy(pdata);
	return ret;
}

void fill_kstat(struct vnode *v, struct kstat *ks)
{
	ks->vnum = (u64)v->vnum;
	ks->mode = v->mode;
	ks->links = v->links;
	ks->uid = v->owner & 0xFFFF;
	ks->gid = (v->owner >> 16) & 0xFFFF;
	ks->size = v->size;
	ks->blksize = v->sb->blocksize;
	ks->atime = v->atime;
	ks->mtime = v->mtime;
	ks->ctime = v->ctime;
}

int sys_fstat(struct tcb *task, int fd, void *statbuf)
{
	/* Check that fd is valid */
	if (fd < 0 || fd > TASK_FILES_MAX ||
	    !task->files->fd[fd].vmfile)
		return -EBADF;

	/* Fill in the c0-style stat structure */
	fill_kstat(task->files->fd[fd].vmfile->vnode, statbuf);

	return 0;
}

/*
 * Returns codezero-style stat structure which in turn is
 * converted to posix style stat structure via the libposix
 * library in userspace.
 */
int sys_stat(struct tcb *task, const char *pathname, void *statbuf)
{
	struct vnode *v;
	struct pathdata *pdata;
	int ret = 0;

	/* Parse path data */
	if (IS_ERR(pdata = pathdata_parse(pathname,
					  alloca(strlen(pathname) + 1),
					  task)))
		return (int)pdata;

	/* Get the vnode */
	if (IS_ERR(v = vfs_vnode_lookup_bypath(pdata))) {
		ret = (int)v;
		goto out;
	}

	/* Fill in the c0-style stat structure */
	fill_kstat(v, statbuf);

out:
	/* Destroy extracted path data */
	pathdata_destroy(pdata);
	return ret;
}


/*
 * Inserts the page to vmfile's list in order of page frame offset.
 * We use an ordered list instead of a better data structure for now.
 */
int insert_page_olist(struct page *this, struct vm_object *vmo)
{
	struct page *before, *after;

	/* Add if list is empty */
	if (list_empty(&vmo->page_cache)) {
		list_insert_tail(&this->list, &vmo->page_cache);
		return 0;
	}

	/* Else find the right interval */
	list_foreach_struct(before, &vmo->page_cache, list) {
		after = link_to_struct(before->list.next, struct page, list);

		/* If there's only one in list */
		if (before->list.next == &vmo->page_cache) {
			/* Add as next if greater */
			if (this->offset > before->offset)
				list_insert(&this->list, &before->list);
			/* Add  as previous if smaller */
			else if (this->offset < before->offset)
				list_insert_tail(&this->list, &before->list);
			else
				BUG();
			return 0;
		}

		/* If this page is in-between two other, insert it there */
		if (before->offset < this->offset &&
		    after->offset > this->offset) {
			list_insert(&this->list, &before->list);
			return 0;
		}
		BUG_ON(this->offset == before->offset);
		BUG_ON(this->offset == after->offset);
	}
	BUG();
}

/*
 * This reads-in a range of pages from a file and populates the page cache
 * just like a page fault, but its not in the page fault path.
 */
int read_file_pages(struct vm_file *vmfile, unsigned long pfn_start,
		    unsigned long pfn_end)
{
	struct page *page;

	for (int f_offset = pfn_start; f_offset < pfn_end; f_offset++) {
		page = vmfile->vm_obj.pager->ops.page_in(&vmfile->vm_obj,
							 f_offset);
		if (IS_ERR(page)) {
			printf("%s: %s:Could not read page %d "
			       "from file with vnum: 0x%lu\n", __TASKNAME__,
			       __FUNCTION__, f_offset, vmfile->vnode->vnum);
			return (int)page;
		}
	}

	return 0;
}

/*
 * The buffer must be contiguous by page, if npages > 1.
 */
int vfs_write(struct vnode *v, unsigned long file_offset,
	      unsigned long npages, void *pagebuf)
{
	int fwrite_end;
	int ret;

	// printf("%s/%s\n", __TASKNAME__, __FUNCTION__);

	/* Ensure vnode is not a directory */
	if (vfs_isdir(v))
		return -EISDIR;

	//printf("%s/%s: Writing to vnode %lu, at pgoff 0x%x, %d pages, buf at 0x%x\n",
	//	__TASKNAME__, __FUNCTION__, vnum, f_offset, npages, pagebuf);

	if ((ret = v->fops.write(v, file_offset, npages, pagebuf)) < 0)
		return ret;

	/*
	 * If the file is extended, write silently extends it.
	 * We update the extended size here. Otherwise subsequent write's
	 * may fail by relying on wrong file size.
	 */
	fwrite_end = __pfn_to_addr(file_offset) + ret;
	if (v->size < fwrite_end) {
		v->size = fwrite_end;
		v->sb->ops->write_vnode(v->sb, v);
	}

	return ret;
}

/* Writes updated file stats back to vfs. (e.g. new file size) */
int vfs_update_file_stats(struct vm_file *f)
{
	struct vnode *v = f->vnode;

	v->size = f->length;
	v->sb->ops->write_vnode(v->sb, v);

	return 0;
}

/* Writes pages in cache back to their file */
int write_file_pages(struct vm_file *f, unsigned long pfn_start,
		     unsigned long pfn_end)
{
	int err;

	/* We have only thought of vfs files for this */
	BUG_ON(f->type != VM_FILE_VFS);

	/* Need not flush files that haven't been written */
	if (!(f->vm_obj.flags & VM_DIRTY))
		return 0;

	BUG_ON(pfn_end != __pfn(page_align_up(f->length)));
	for (int f_offset = pfn_start; f_offset < pfn_end; f_offset++) {
		err = f->vm_obj.pager->ops.page_out(&f->vm_obj, f_offset);
		if (err < 0) {
			printf("%s: %s:Could not write page %d "
			       "to file with vnum: 0x%lu\n", __TASKNAME__,
			       __FUNCTION__, f_offset, f->vnode->vnum);
			return err;
		}
	}

	return 0;
}

/* Flush all dirty file pages and update file stats */
int flush_file_pages(struct vm_file *f)
{
	int err;

	if ((err = write_file_pages(f, 0, __pfn(page_align_up(f->length)))) < 0)
		return err;

	if ((err = vfs_update_file_stats(f)) < 0)
		return err;

	return 0;
}

/* Given a task and fd, syncs all IO on it */
int fsync_common(struct tcb *task, int fd)
{
	int err;

	/* Check fd validity */
	if (fd < 0 || fd > TASK_FILES_MAX)
		return -EINVAL;

	/*
	 * If we don't know about the file, even if it was
	 * opened by the vfs, it is sure that there's no
	 * pending IO on it. We simply return.
	 */
	if (!task->files->fd[fd].vmfile)
		return 0;

	/*
	printf("Thread %d flushing fd: %d, vnum: 0x%lx, vnode: %p\n",
	       task->tid, fd, task->files->fd[fd].vmfile->vnode->vnum,
	       task->files->fd[fd].vmfile->vnode);
	*/

	/* Finish I/O on file */
	if ((err = flush_file_pages(task->files->fd[fd].vmfile)) < 0)
		return err;

	return 0;
}

void vm_file_put(struct vm_file *file)
{
	/* Reduce file's opener count */
	if (!(file->openers--))
		/* No openers left, check any mappers */
		if (!file->vm_obj.nlinks)
			/* No links or openers, delete the file */
			vm_file_delete(file);

	/* FIXME:
	 * Shall we delete the cached vnode here as well???
	 */
}

/*
 * FIXME: fsync + close could be done under a single "close" ipc
 * from pager. Currently there are 2 ipcs: 1 fsync + 1 fd close.
 */

/* Closes the file descriptor and notifies vfs */
int do_close(struct tcb *task, int fd)
{
	int err;

	 //printf("%s: Closing fd: %d on task %d\n", __FUNCTION__,
	 //      fd, task->tid);

	if ((err = id_del(task->files->fdpool, fd)) < 0) {
		printf("%s: Error releasing fd identifier.\n",
		       __FUNCTION__);
		return err;
	}

	if (!task->files->fd[fd].vmfile)
		return 0;

	/* Reduce file refcount etc. */
	vm_file_put(task->files->fd[fd].vmfile);

	task->files->fd[fd].cursor = 0;
	task->files->fd[fd].vmfile = 0;

	return 0;
}

int sys_close(struct tcb *task, int fd)
{
	int ret;

	/* Sync the file and update stats */
	if ((ret = fsync_common(task, fd)) < 0)
		return ret;

	/* Close the file descriptor. */
	return do_close(task, fd);
}

int sys_fsync(struct tcb *task, int fd)
{
	/* Sync the file and update stats */
	return fsync_common(task, fd);
}

/* FIXME: Add error handling to this */
/* Extends a file's size by adding it new pages */
int new_file_pages(struct vm_file *f, unsigned long start, unsigned long end)
{
	unsigned long npages = end - start;
	struct page *page;
	void *paddr;

	/* Allocate the memory for new pages */
	if (!(paddr = alloc_page(npages)))
		return -ENOMEM;

	/* Process each page */
	for (unsigned long i = 0; i < npages; i++) {
		page = phys_to_page(paddr + PAGE_SIZE * i);
		page_init(page);
		page->refcnt++;
		page->owner = &f->vm_obj;
		page->offset = start + i;
		page->virtual = 0;

		/* Add the page to file's vm object */
		BUG_ON(!list_empty(&page->list));
		insert_page_olist(page, &f->vm_obj);
	}

	/* Update vm object */
	f->vm_obj.npages += npages;

	return 0;
}

#define page_offset(x)	((unsigned long)(x) & PAGE_MASK)


/*
 * Reads a page range from an ordered list of pages into a buffer,
 * from those pages, or from the buffer, into those pages, depending on
 * the read flag.
 *
 * NOTE:
 * This assumes the page range is consecutively available in the cache
 * and count bytes are available. To ensure this,
 * read/write/new_file_pages must have been called first and count
 * must have been checked. Since it has these checking assumptions,
 * count must be satisfied.
 */
int copy_cache_pages(struct vm_file *vmfile, struct tcb *task, void *buf,
		     unsigned long pfn_start, unsigned long pfn_end,
		     unsigned long cursor_offset, int count, int read)
{
	struct page *file_page;
	unsigned long task_offset; /* Current copy offset on the task buffer */
	unsigned long file_offset; /* Current copy offset on the file */
	int copysize, left;
	int empty;

	task_offset = (unsigned long)buf;
	file_offset = cursor_offset;
	left = count;

	/* Find the head of consecutive pages */
	list_foreach_struct(file_page, &vmfile->vm_obj.page_cache, list) {
		if (file_page->offset < pfn_start)
			continue;
		else if (file_page->offset == pfn_end || left == 0)
			break;

		empty = PAGE_SIZE - page_offset(file_offset);

		/* Copy until a single page cache page is filled */
		while (empty && left) {
			copysize = min(PAGE_SIZE - page_offset(file_offset), left);
		     	copysize = min(copysize, PAGE_SIZE - page_offset(task_offset));

			if (read)
				page_copy(task_prefault_smart(task, task_offset,
							      VM_READ | VM_WRITE),
					  file_page,
					  page_offset(task_offset),
					  page_offset(file_offset),
					  copysize);
			else
				page_copy(file_page,
					  task_prefault_smart(task, task_offset,
							      VM_READ),
					  page_offset(file_offset),
					  page_offset(task_offset),
					  copysize);

			empty -= copysize;
			left -= copysize;
			task_offset += copysize;
			file_offset += copysize;
		}
	}
	BUG_ON(left != 0);

	return count - left;
}

int sys_read(struct tcb *task, int fd, void *buf, int count)
{
	unsigned long pfn_start, pfn_end;
	unsigned long cursor;
	struct vm_file *vmfile;
	int ret = 0;

	/* Check that fd is valid */
	if (fd < 0 || fd > TASK_FILES_MAX ||
	    !task->files->fd[fd].vmfile)
		return -EBADF;


	/* Check count validity */
	if (count < 0)
		return -EINVAL;
	else if (!count)
		return 0;

	/* Check user buffer validity. */
	if ((ret = pager_validate_user_range(task, buf,
				       (unsigned long)count,
				       VM_READ)) < 0)
		return -EFAULT;

	vmfile = task->files->fd[fd].vmfile;
	cursor = task->files->fd[fd].cursor;

	/* If cursor is beyond file end, simply return 0 */
	if (cursor >= vmfile->length)
		return 0;

	/* Start and end pages expected to be read by user */
	pfn_start = __pfn(cursor);
	pfn_end = __pfn(page_align_up(cursor + count));

	/* But we can read up to maximum file size */
	pfn_end = __pfn(page_align_up(vmfile->length)) < pfn_end ?
		  __pfn(page_align_up(vmfile->length)) : pfn_end;

	/* If trying to read more than end of file, reduce it to max possible */
	if (cursor + count > vmfile->length)
		count = vmfile->length - cursor;

	/* Read the page range into the cache from file */
	if ((ret = read_file_pages(vmfile, pfn_start, pfn_end)) < 0)
		return ret;

	/* Read it into the user buffer from the cache */
	if ((count = copy_cache_pages(vmfile, task, buf, pfn_start, pfn_end,
				      cursor, count, 1)) < 0)
		return count;

	/* Update cursor on success */
	task->files->fd[fd].cursor += count;

	return count;
}

/* FIXME:
 *
 * Error:
 * We find the page buffer is in, and then copy from the *start* of the page
 * rather than buffer's offset in that page. - I think this is fixed.
 */
int sys_write(struct tcb *task, int fd, void *buf, int count)
{
	unsigned long pfn_wstart, pfn_wend;	/* Write start/end */
	unsigned long pfn_fstart, pfn_fend;	/* File start/end */
	unsigned long pfn_nstart, pfn_nend;	/* New pages start/end */
	unsigned long cursor;
	struct vm_file *vmfile;
	int ret = 0;

	/* Check that fd is valid */
	if (fd < 0 || fd > TASK_FILES_MAX ||
	    !task->files->fd[fd].vmfile)
		return -EBADF;

	/* Check count validity */
	if (count < 0)
		return -EINVAL;
	else if (!count)
		return 0;

	/* Check user buffer validity. */
	if ((ret = pager_validate_user_range(task, buf,
					     (unsigned long)count,
					     VM_WRITE | VM_READ)) < 0)
		return -EINVAL;

	vmfile = task->files->fd[fd].vmfile;
	cursor = task->files->fd[fd].cursor;

	//printf("Thread %d writing to fd: %d, vnum: 0x%lx, vnode: %p\n",
	//task->tid, fd, vmfile->vnode->vnum, vmfile->vnode);

	/* See what pages user wants to write */
	pfn_wstart = __pfn(cursor);
	pfn_wend = __pfn(page_align_up(cursor + count));

	/* Get file start and end pages */
	pfn_fstart = 0;
	pfn_fend = __pfn(page_align_up(vmfile->length));

	/*
	 * Find the intersection to determine which pages are
	 * already part of the file, and which ones are new.
	 */
	if (pfn_wstart < pfn_fend) {
		pfn_fstart = pfn_wstart;

		/*
		 * Shorten the end if end page is
		 * less than file size
		 */
		if (pfn_wend < pfn_fend) {
			pfn_fend = pfn_wend;

			/* This also means no new pages in file */
			pfn_nstart = 0;
			pfn_nend = 0;
		} else {

			/* The new pages start from file end,
			 * and end by write end. */
			pfn_nstart = pfn_fend;
			pfn_nend = pfn_wend;
		}

	} else {
		/* No intersection, its all new pages */
		pfn_fstart = 0;
		pfn_fend = 0;
		pfn_nstart = pfn_wstart;
		pfn_nend = pfn_wend;
	}

	/*
	 * Read in the portion that's already part of the file.
	 */
	if ((ret = read_file_pages(vmfile, pfn_fstart, pfn_fend)) < 0)
		return ret;

	/* Create new pages for the part that's new in the file */
	if ((ret = new_file_pages(vmfile, pfn_nstart, pfn_nend)) < 0)
		return ret;

	/*
	 * At this point be it new or existing file pages, all pages
	 * to be written are expected to be in the page cache. Write.
	 */
	//byte_offset = PAGE_MASK & cursor;
	if ((ret = copy_cache_pages(vmfile, task, buf, pfn_wstart,
				     pfn_wend, cursor, count, 0)) < 0)
		return ret;

	/*
	 * Update the file size, and cursor. vfs will be notified
	 * of this change when the file is flushed (e.g. via fflush()
	 * or close())
	 */
	if (task->files->fd[fd].cursor + count > vmfile->length)
		vmfile->length = task->files->fd[fd].cursor + count;

	task->files->fd[fd].cursor += count;

	return count;
}

/* FIXME: Check for invalid cursor values. Check for total, sometimes negative. */
int sys_lseek(struct tcb *task, int fd, off_t offset, int whence)
{
	int retval = 0;
	unsigned long long total, cursor;

	/* Check that fd is valid */
	if (fd < 0 || fd > TASK_FILES_MAX ||
	    !task->files->fd[fd].vmfile)
		return -EBADF;

	/* Offset validity */
	if (offset < 0)
		return -EINVAL;

	switch (whence) {
	case SEEK_SET:
		retval = task->files->fd[fd].cursor = offset;
		break;
	case SEEK_CUR:
		cursor = (unsigned long long)task->files->fd[fd].cursor;
		if (cursor + offset > 0xFFFFFFFF)
			retval = -EINVAL;
		else
			retval = task->files->fd[fd].cursor += offset;
		break;
	case SEEK_END:
		cursor = (unsigned long long)task->files->fd[fd].cursor;
		total = (unsigned long long)task->files->fd[fd].vmfile->length;
		if (cursor + total > 0xFFFFFFFF)
			retval = -EINVAL;
		else {
			retval = task->files->fd[fd].cursor =
				task->files->fd[fd].vmfile->length + offset;
		}
	default:
		retval = -EINVAL;
		break;
	}

	return retval;
}

/*
 * FIXME: Here's how this should have been:
 * v->ops.readdir() -> Reads fs-specific directory contents. i.e. reads
 * the directory buffer, doesn't care however contained vnode details are
 * stored.
 *
 * After reading, it converts the fs-spceific contents into generic vfs
 * dentries and populates the dentries of those vnodes.
 *
 * If vfs_readdir() is issued, those generic dentries are converted into
 * the posix-defined directory record structure. During this on-the-fly
 * generation, pseudo-entries such as . and .. are also added.
 *
 * If this layering is not done, i.e. the low-level dentry buffer already
 * keeps this record structure and we try to return that, then we wont
 * have a chance to add the pseudo-entries . and .. These record entries
 * are essentially created from parent vnode and current vnode but using
 * the names . and ..
 */

int fill_dirent(void *buf, unsigned long vnum, int offset, char *name)
{
	struct dirent *d = buf;

	d->inum = (unsigned int)vnum;
	d->offset = offset;
	d->rlength = sizeof(struct dirent);
	strncpy((char *)d->name, name, DIRENT_NAME_MAX);

	return d->rlength;
}


/*
 * Reads @count bytes of posix struct dirents into @buf. This implements
 * the raw dirent read syscall upon which readdir() etc. posix calls
 * can be built in userspace.
 *
 * FIXME: Ensure buf is in shared utcb, and count does not exceed it.
 */
int sys_readdir(struct tcb *t, int fd, int count, char *dirbuf)
{
	int dirent_size = sizeof(struct dirent);
	int total = 0, nbytes = 0;
	struct vnode *v;
	struct dentry *d;
	char *buf = dirbuf;

	// printf("%s/%s\n", __TASKNAME__, __FUNCTION__);

	/*
	 * FIXME:
	 * Add dirbuf overflow checking
	 */

	/* Check address is in task's utcb */

	if (fd < 0 || fd > TASK_FILES_MAX ||
	    !t->files->fd[fd].vmfile->vnode)
		return -EBADF;

	v = t->files->fd[fd].vmfile->vnode;

	d = link_to_struct(v->dentries.next, struct dentry, vref);

	/* Ensure vnode is a directory */
	if (!vfs_isdir(v))
		return -ENOTDIR;

	/* Write pseudo-entries . and .. to user buffer */
	if (count < dirent_size)
		return 0;

	fill_dirent(buf, v->vnum, nbytes, VFS_STR_CURDIR);
	nbytes += dirent_size;
	buf += dirent_size;
	count -= dirent_size;

	if (count < dirent_size)
		return 0;

	fill_dirent(buf, d->parent->vnode->vnum, nbytes, VFS_STR_PARDIR);
	nbytes += dirent_size;
	buf += dirent_size;
	count -= dirent_size;

	/* Copy fs-specific dir to buf in struct dirent format */
	if ((total = v->ops.filldir(buf, v, count)) < 0)
		return total;

	return nbytes + total;
}

/* FIXME:
 * - Is it already open?
 * - Check flags and mode.
 */
int sys_open(struct tcb *task, const char *pathname,
	     int flags, unsigned int mode)
{
	struct pathdata *pdata;
	struct vnode *v;
	struct vm_file *vmfile;
	int retval;
	int fd;


	/* Parse path data */
	if (IS_ERR(pdata = pathdata_parse(pathname,
					  alloca(strlen(pathname) + 1),
					  task)))
		return (int)pdata;

	/* Creating new file */
	if (flags & O_CREAT) {
		/* Make sure mode identifies a file */
		mode |= S_IFREG;

		/* Create new vnode */
		if (IS_ERR(v = vfs_vnode_create(task, pdata, mode))) {
			retval = (int)v;
			goto out;
		}
	} else {
		/* Not creating. Get the existing vnode */
		if (IS_ERR(v = vfs_vnode_lookup_bypath(pdata))) {
			retval = (int)v;
			goto out;
		}
	}

	/* Get a new fd */
	BUG_ON((fd = id_new(task->files->fdpool)) < 0);
	retval = fd;

	/* Check if that vm_file is already in the list */
	list_foreach_struct(vmfile, &global_vm_files.list, list) {

		/* Compare vnode pointer */
		if (vmfile->vnode == v) {
			/* Add a reference to it from the task */
			task->files->fd[fd].vmfile = vmfile;

			vmfile->openers++;
			goto out;
		}
	}

	/* Create a new vm_file for this vnode */
	if (IS_ERR(vmfile = vfs_file_create())) {
		retval = (int)vmfile;
		goto out;
	}

	/* Assign file information */
	vmfile->vnode = v;
	vmfile->length = vmfile->vnode->size;

	/* Add a reference to it from the task */
	vmfile->vm_obj.pager = &file_pager;
	task->files->fd[fd].vmfile = vmfile;
	vmfile->openers++;

	/* Add to file list */
	global_add_vm_file(vmfile);

out:
	pathdata_destroy(pdata);
	return retval;
}

