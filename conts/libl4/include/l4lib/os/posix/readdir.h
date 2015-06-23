#ifndef __OS_READDIR_H__
#define __OS_READDIR_H__

/* Any os syscall related data that is not in posix */
ssize_t os_readdir(int fd, void *buf, size_t count);

#endif
