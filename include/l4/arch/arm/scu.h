/*
 * SCU registers
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Prem Mallappa
 */
#ifndef __SCU_H__
#define __SCU_H__


/* Following defines may well go into realview/scu.h */
#define SCU_CTRL_REG		0x00 /* Control Register */
#define SCU_CFG_REG		0x04 /* Configuration Register */
#define SCU_CPU_PWR_REG		0x08 /* SCU CPU Power state register */
#define SCU_INV_ALL_S		0x0C /* SCU Invalidate all Secure Registers */
#define SCU_ACCESS_REG_S	0x50 /* SCU Access Control Secure */
#define SCU_ACCESS_REG_NS	0x54 /* SCU Access Control Non-Secure */

/* The contents of CONTROL AND CONFIG are Implementation Defined. so they may go into platform specific scu.h */
#define SCU_CTRL_EN		(1 << 0)
#define SCU_CTRL_ADDR_FLTR_EN	(1 << 1)
#define SCU_CTRL_PARITY_ON	(1 << 2)
#define SCU_CTRL_STBY_EN	(1 << 5) /* SCU StandBy Enable */
#define SCU_CTRL_GIC_STBY_EN	(1 << 6) /* GIC Standby enable */

/* Config register */
#define SCU_CFG_SMP_MASK	0x000000f0
#define SCU_CFG_TAG_RAM_MASK	0x0000ff00
#define SCU_CFG_NCPU_MASK	0x7
#define SCU_CFG_SMP_NCPU_SHIFT	4


#endif /* __SCU_H__ */
