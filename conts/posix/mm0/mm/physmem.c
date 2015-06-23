/*
 * Global physical memory descriptions.
 *
 * Copyright (C) 2007 - 2009 Bahadir Balban
 */
#include <l4/macros.h>
#include <l4/config.h>
#include <l4/types.h>
#include <l4/lib/list.h>
#include <l4/lib/math.h>
#include <l4/api/thread.h>
#include <l4/api/kip.h>
#include <l4/api/errno.h>
#include INC_GLUE(memory.h)

#include L4LIB_INC_ARCH(syslib.h)
#include <stdio.h>
#include <init.h>
#include <physmem.h>
#include <bootm.h>


