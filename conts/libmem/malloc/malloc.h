#ifndef __PRIVATE_MALLOC_H__
#define __PRIVATE_MALLOC_H__

#include <stddef.h>
#include <string.h>

void *kmalloc(size_t size);
void kfree(void *blk);

static inline void *kzalloc(size_t size)
{
	void *buf = kmalloc(size);

	memset(buf, 0, size);
	return buf;
}


#endif /*__PRIVATE_MALLOC_H__ */
