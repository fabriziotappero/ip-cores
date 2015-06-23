/*
 * Inode lookup.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */
#include <fs.h>
#include <vfs.h>
#include <stat.h>
#include <l4/api/errno.h>
#include <lib/pathstr.h>
#include <path.h>

/*
 * Given a dentry that has been populated by readdir with children dentries
 * and their vnodes, this itself checks all those children on that level for
 * a match, but it also calls lookup, which recursively checks lower levels.
 */
struct vnode *lookup_dentry_children(struct dentry *parentdir,
				     struct pathdata *pdata)
{
	struct dentry *childdir;
	struct vnode *v;
	const char *component = pathdata_next_component(pdata);

	list_foreach_struct(childdir, &parentdir->children, child)
		if (IS_ERR(v = childdir->vnode->ops.lookup(childdir->vnode,
							   pdata, component)))
			/* Means not found, continue search */
			if ((int)v == -ENOENT)
				continue;
			else	/* A real error */
				return v;
		else	/* No error, so found it */
			return v;

	/* Out of all children dentries, neither was a match */
	return PTR_ERR(-ENOENT);
}

/* Lookup, recursive, assuming single-mountpoint */
struct vnode *generic_vnode_lookup(struct vnode *thisnode,
				   struct pathdata *pdata,
				   const char *component)
{
	struct dentry *d;
	struct vnode *found;
	int err;

	/* Does this path component match with any of this vnode's dentries? */
	list_foreach_struct(d, &thisnode->dentries, vref) {
		if (d->ops.compare(d, component)) {
			/* Is this a directory? */
			if (vfs_isdir(thisnode)) {
				/* Are there more path components? */
				if (!list_empty(&pdata->list)) {
					/* Read directory contents */
					if ((err = d->vnode->ops.readdir(d->vnode)) < 0)
						return PTR_ERR(err);

					/* Search all children one level below. */
					if ((found = lookup_dentry_children(d, pdata)))
					 	/* Either found, or non-zero error */
						return found;
				} else
					return thisnode;
			} else { /* Its a file */
				if (!list_empty(&pdata->list)) /* There's still path, but not directory */
					return PTR_ERR(-ENOTDIR);
				else /* No path left, found it, so return file */
					return thisnode;
			}
		}
	}

	/* Not found, return nothing */
	return PTR_ERR(-ENOENT);
}

int generic_dentry_compare(struct dentry *d, const char *name)
{
	if (!strcmp(d->name, name) || !strcmp(name, VFS_STR_CURDIR))
		return 1;
	else
		return 0;
}

struct dentry_ops generic_dentry_operations = {
	.compare = generic_dentry_compare,
};

