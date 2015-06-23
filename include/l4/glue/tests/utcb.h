#ifndef __GLUE__V4_ARM__UTCB_H__
#define __GLUE__V4_ARM__UTCB_H__

/*
 * Userspace thread control block
 *
 * Copyright (C) 2005 Bahadir Balban
 *
 */
#include <macros.h>
#include <config.h>
#include <types.h>

struct utcb {
	u32 global_id;
	u32 error_code;
};

#endif /* !__GLUE__V4_ARM__UTCB_H__ */
