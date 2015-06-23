/*
 * Copyright (C) 2009 Bahadir Bilgehan Balban
 */
#ifndef __ARM_UTCB_H__
#define __ARM_UTCB_H__

#define USER_UTCB_REF           0xFF000050
#define L4_KIP_ADDRESS		0xFF000000
#define UTCB_KIP_OFFSET		0x50

#ifndef __ASSEMBLY__
#include <l4lib/types.h>
#include <l4/macros.h>
#include <l4/lib/math.h>
#include INC_GLUE(message.h)
#include INC_GLUE(memory.h)
#include <string.h>
#include <stdio.h>
#include L4LIB_INC_SUBARCH(utcb.h)

/*
 * See kernel glue/arch/message.h for utcb details
 */
extern struct kip *kip;




/* Functions to read/write utcb registers */
static inline unsigned int read_mr(int offset)
{
	if (offset < MR_TOTAL)
		return l4_get_utcb()->mr[offset];
	else
		return l4_get_utcb()->mr_rest[offset - MR_TOTAL];
}

static inline void write_mr(unsigned int offset, unsigned int val)
{
	if (offset < MR_TOTAL)
		l4_get_utcb()->mr[offset] = val;
	else
		l4_get_utcb()->mr_rest[offset - MR_TOTAL] = val;
}


static inline void *utcb_full_buffer()
{
	return &l4_get_utcb()->mr_rest[0];
}

static inline char *utcb_full_strcpy_from(const char *src)
{
	return strncpy((char *)&l4_get_utcb()->mr_rest[0], src,
		       L4_UTCB_FULL_BUFFER_SIZE);
}

static inline void *utcb_full_memcpy_from(const char *src, int size)
{
	return memcpy(&l4_get_utcb()->mr_rest[0], src,
		      min(size, L4_UTCB_FULL_BUFFER_SIZE));
}

static inline char *utcb_full_strcpy_to(char *dst)
{
	return strncpy(dst, (char *)&l4_get_utcb()->mr_rest[0],
		       L4_UTCB_FULL_BUFFER_SIZE);
}

static inline void *utcb_full_memcpy_to(char *dst, int size)
{
	return memcpy(dst, &l4_get_utcb()->mr_rest[0],
		      min(size, L4_UTCB_FULL_BUFFER_SIZE));
}

#endif /* !__ASSEMBLY__ */

#endif /* __ARM_UTCB_H__ */
