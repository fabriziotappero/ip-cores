#ifndef __OS_KSTAT_H__
#define __OS_KSTAT_H__

#include <l4lib/types.h>

/*
 * Internal codezero-specific stat structure.
 * This is converted to posix stat in userspace
 */
struct kstat {
	u64 vnum;
	u32 mode;
	int links;
	u16 uid;
	u16 gid;
	u64 size;
	int blksize;
	u64 atime;
	u64 mtime;
	u64 ctime;
};

#endif
