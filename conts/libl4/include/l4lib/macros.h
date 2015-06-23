/*
 * Userspace-specific macros.
 *
 * Copyright (C) 2010 B Labs Ltd.
 */
#ifndef __LIBL4_MACROS_H__
#define __LIBL4_MACROS_H__

#include <l4/config.h>

/*
 * These are for the userspace code to include
 * different directories based on configuration
 * values for platform, architecture and so on.
 *
 * This file is meant to be included from all
 * userspace projects by default.
 */

#define L4LIB_INC_ARCH(x)		<l4lib/arch/__ARCH__/x>
#define L4LIB_INC_SUBARCH(x)		<l4lib/arch/__ARCH__/__SUBARCH__/x>
#define L4LIB_INC_PLAT(x)		<l4lib/platform/__PLATFORM__/x>
#define L4LIB_INC_GLUE(x)		<l4lib/glue/__ARCH__/x>

#endif /* __LIBL4_MACROS_H__ */
