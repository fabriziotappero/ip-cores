/* The code in this file is taken from the arch/mips/dec/wbflush.c.
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 *
 * Copyright (C) 1998 Harald Koerfgen
 * Copyright (C) 2002 Maciej W. Rozycki
 * Copyright (C) 2014 Aleksander Osman
 */

#include <linux/init.h>

#include <asm/wbflush.h>

static void wbflush_r3000(void);

void (*__wbflush) (void);

void __init wbflush_setup(void)
{
	__wbflush = wbflush_r3000;
}

/*
 * For the aoR3000 the writeback buffer functions as part of Coprocessor 0.
 */
static void wbflush_r3000(void)
{
    asm(".set\tpush\n\t"
	".set\tnoreorder\n\t"
	"1:\tbc0f\t1b\n\t"
	"nop\n\t"
	".set\tpop");
}

#include <linux/module.h>

EXPORT_SYMBOL(__wbflush);
