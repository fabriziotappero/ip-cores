#ifndef __CLONE_H__
#define __CLONE_H__

/* Linux clone() system call flags */
#define CLONE_VM	0x100
#define CLONE_FS	0x200
#define CLONE_FILES	0x400
#define CLONE_SIGHAND	0x800
#define CLONE_VFORK	0x4000
#define CLONE_PARENT	0x8000
#define CLONE_THREAD	0x10000
#define CLONE_NEWNS	0x20000
#define CLONE_STOPPED	0x2000000

#endif /* __CLONE_H__ */


