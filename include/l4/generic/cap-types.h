/*
 * Types of capabilities and their operations
 *
 * Copyright (C) 2009 Bahadir Balban
 */
#ifndef __CAP_TYPES_H__
#define __CAP_TYPES_H__

/*
 * Capability types
 */
#define CAP_TYPE_MASK		0x0000FFFF
#define CAP_TYPE_TCTRL		(1 << 0)
#define CAP_TYPE_EXREGS		(1 << 1)
#define CAP_TYPE_MAP_PHYSMEM	(1 << 2)
#define CAP_TYPE_MAP_VIRTMEM	(1 << 3)
#define CAP_TYPE_IPC		(1 << 4)
#define CAP_TYPE_IRQCTRL	(1 << 5)
#define CAP_TYPE_UMUTEX		(1 << 6)
#define CAP_TYPE_QUANTITY	(1 << 7)
#define CAP_TYPE_CAP		(1 << 8)
#define cap_type(c)	((c)->type & CAP_TYPE_MASK)

/*
 * Resource types
 */
#define CAP_RTYPE_MASK		0xFFFF0000
#define CAP_RTYPE_THREAD	(1 << 16)
#define CAP_RTYPE_SPACE		(1 << 17)
#define CAP_RTYPE_CONTAINER	(1 << 18)
#define CAP_RTYPE_CPUPOOL	(1 << 19)
#define CAP_RTYPE_THREADPOOL	(1 << 20)
#define CAP_RTYPE_SPACEPOOL	(1 << 21)
#define CAP_RTYPE_MUTEXPOOL	(1 << 22)
#define CAP_RTYPE_MAPPOOL	(1 << 23) /* For pmd spending */
#define CAP_RTYPE_CAPPOOL	(1 << 24) /* For new cap generation */

#define cap_rtype(c)	((c)->type & CAP_RTYPE_MASK)
#define cap_set_rtype(c, rtype)			\
	{(c)->type &= ~CAP_RTYPE_MASK;		\
	 (c)->type |= CAP_RTYPE_MASK & rtype;}

/*
 * User-defined device-types
 * (Kept in the user field)
 */
#define CAP_DEVTYPE_TIMER		1
#define CAP_DEVTYPE_UART		2
#define CAP_DEVTYPE_KEYBOARD           	3
#define CAP_DEVTYPE_MOUSE              	4
#define CAP_DEVTYPE_CLCD              	5
#define CAP_DEVTYPE_OTHER		0xF
#define CAP_DEVTYPE_MASK		0xFFFF
#define CAP_DEVNUM_MASK			0xFFFF0000
#define CAP_DEVNUM_SHIFT		16

#define cap_is_devmem(c)		((c)->attr)
#define cap_set_devtype(c, devtype)			\
	{(c)->attr &= ~CAP_DEVTYPE_MASK;		\
	 (c)->attr |= CAP_DEVTYPE_MASK & devtype;}
#define cap_set_devnum(c, devnum)			\
	{(c)->attr &= ~CAP_DEVNUM_MASK;		\
	 (c)->attr |= CAP_DEVNUM_MASK & (devnum << CAP_DEVNUM_SHIFT);}
#define cap_devnum(c)					\
	(((c)->attr & CAP_DEVNUM_MASK) >> CAP_DEVNUM_SHIFT)
#define cap_devtype(c)		((c)->attr & CAP_DEVTYPE_MASK)

/*
 * Access permissions
 */

/* Generic permissions */
#define CAP_CHANGEABLE		(1 << 28)	/* Can modify contents */
#define CAP_TRANSFERABLE	(1 << 29)	/* Can grant or share it */
#define CAP_REPLICABLE		(1 << 30)	/* Can create copies */
#define CAP_GENERIC_MASK	0xF0000000
#define CAP_IMMUTABLE			0
#define cap_generic_perms(c)	\
	((c)->access & CAP_GENERIC_MASK)

/* Thread control capability */
#define CAP_TCTRL_CREATE	(1 << 0)
#define CAP_TCTRL_DESTROY	(1 << 1)
#define CAP_TCTRL_RUN		(1 << 2)
#define CAP_TCTRL_SUSPEND	(1 << 3)
#define CAP_TCTRL_RECYCLE	(1 << 4)
#define CAP_TCTRL_WAIT		(1 << 5)

/* Exchange registers capability */
#define CAP_EXREGS_RW_PAGER	(1 << 0)
#define CAP_EXREGS_RW_UTCB	(1 << 1)
#define CAP_EXREGS_RW_SP	(1 << 2)
#define CAP_EXREGS_RW_PC	(1 << 3)
#define CAP_EXREGS_RW_REGS	(1 << 4) /* Other regular regs */
#define CAP_EXREGS_RW_CPU	(1 << 5)
#define CAP_EXREGS_RW_CPUTIME	(1 << 6)

/* Map capability */
#define CAP_MAP_READ		(1 << 0)
#define CAP_MAP_WRITE		(1 << 1)
#define CAP_MAP_EXEC		(1 << 2)
#define CAP_MAP_CACHED		(1 << 3)
#define CAP_MAP_UNCACHED	(1 << 4)
#define CAP_MAP_UNMAP		(1 << 5)
#define CAP_MAP_UTCB		(1 << 6)

/* Cache operations, applicable to (virtual) memory regions */
#define CAP_CACHE_INVALIDATE		(1 << 7)
#define CAP_CACHE_CLEAN			(1 << 8)

/*
 * IRQ Control capability
 */
#define CAP_IRQCTRL_WAIT	(1 << 8)

/*
 * This is a common one and it applies to both
 * CAP_TYPE_IRQCTRL and CAP_TYPE_MAP_PHYSMEM
 */
#define CAP_IRQCTRL_REGISTER	(1 << 7)



/* Ipc capability */
#define CAP_IPC_SEND		(1 << 0)
#define CAP_IPC_RECV		(1 << 1)
#define CAP_IPC_SHORT		(1 << 2)
#define CAP_IPC_FULL		(1 << 3)
#define CAP_IPC_EXTENDED	(1 << 4)
#define CAP_IPC_ASYNC		(1 << 5)

/* Userspace mutex capability */
#define CAP_UMUTEX_LOCK		(1 << 0)
#define CAP_UMUTEX_UNLOCK	(1 << 1)

/* Capability control capability */
#define CAP_CAP_GRANT		(1 << 0)
#define CAP_CAP_READ		(1 << 1)
#define CAP_CAP_SHARE		(1 << 2)
#define CAP_CAP_REPLICATE	(1 << 3)
#define CAP_CAP_SPLIT		(1 << 4)
#define CAP_CAP_DEDUCE		(1 << 5)
#define CAP_CAP_DESTROY		(1 << 6)
#define CAP_CAP_MODIFY		(CAP_CAP_DEDUCE | CAP_CAP_SPLIT \
				 | CAP_CAP_DESTROY)


#endif /* __CAP_TYPES_H__ */
