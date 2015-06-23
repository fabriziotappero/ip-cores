/*
 * Definitions for exception support on ARMv5
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __ARCH_V5_EXCEPTION_H__
#define __ARCH_V5_EXCEPTION_H__

#include INC_ARCH(asm.h)

/*
 * v5 Architecture-defined data abort values for FSR ordered
 * in highest to lowest priority.
 */
#define DABT_TERMINAL				0x2
#define DABT_VECTOR				0x0	/* Obsolete */
#define DABT_ALIGN				0x1
#define DABT_EXT_XLATE_LEVEL1			0xC
#define DABT_EXT_XLATE_LEVEL2			0xE
#define DABT_XLATE_SECT				0x5
#define DABT_XLATE_PAGE				0x7
#define DABT_DOMAIN_SECT			0x9
#define DABT_DOMAIN_PAGE			0xB
#define DABT_PERM_SECT				0xD
#define DABT_PERM_PAGE				0xF
#define DABT_EXT_LFETCH_SECT			0x4
#define DABT_EXT_LFETCH_PAGE			0x6
#define DABT_EXT_NON_LFETCH_SECT		0x8
#define DABT_EXT_NON_LFETCH_PAGE		0xA

#define FSR_FS_MASK				0xF

#endif /* __ARCH_V5_EXCEPTION_H__ */
