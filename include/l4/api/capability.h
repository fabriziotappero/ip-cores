/*
 * Syscall API for capability manipulation
 *
 * Copyright (C) 2009 Bahadir Balban
 */
#ifndef __API_CAPABILITY_H__
#define __API_CAPABILITY_H__

#include <l4/lib/list.h>
#include INC_ARCH(types.h)

/* Capability syscall request types */
#define CAP_CONTROL_NCAPS		0x00000000
#define CAP_CONTROL_READ		0x00000001
#define CAP_CONTROL_SHARE		0x00000002
#define CAP_CONTROL_GRANT		0x00000003
#define CAP_CONTROL_REPLICATE		0x00000004
#define CAP_CONTROL_SPLIT		0x00000005
#define CAP_CONTROL_DEDUCE		0x00000006
#define CAP_CONTROL_DESTROY		0x00000007

#define CAP_SHARE_MASK			0x0000000F
#define CAP_SHARE_SINGLE		0x00000001
#define CAP_SHARE_ALL_CONTAINER		0x00000002
#define CAP_SHARE_ALL_SPACE		0x00000003

#define CAP_GRANT_MASK			0x0000000F
#define CAP_GRANT_SINGLE		0x00000001
#define CAP_GRANT_IMMUTABLE		0x00000004

#define CAP_SPLIT_MASK			0x0000000F
#define CAP_SPLIT_SIZE			0x00000001
#define CAP_SPLIT_ACCESS		0x00000002
#define CAP_SPLIT_RANGE			0x00000003 /* Returns -EPERM */

/*
 * A capability is a unique representation of security
 * qualifiers on a particular resource.
 *
 * In this structure:
 *
 * The capid denotes the unique capability ID.
 * The resid denotes the unique ID of targeted resource.
 * The owner denotes the unique ID of the one and only capability owner. This is
 * almost always a thread ID.
 *
 * The type field contains two types:
 * 	- The capability type,
 * 	- The targeted resource type.
 *
 * The targeted resouce type denotes what type of resource the capability is
 * allowed to operate on. For example a thread, a thread group, an address space
 * or a memory can be of this type.
 *
 * The capability type defines the general set of operations allowed on a
 * particular resource. For example a capability type may be thread_control,
 * exchange_registers, ipc, or map operations. A resource type may be such as a
 * thread, a thread group, a virtual or physical memory region.
 *
 * There are also quantitative capability types. While their names denote
 * quantitative objects such as memory, threads, and address spaces, these
 * types actually define the quantitative operations available on those
 * resources such as creation and deletion of a thread, allocation and
 * deallocation of a memory region etc.
 *
 * The access field denotes the fine-grain operations available on a particular
 * resource. The meaning of each bitfield differs according to the type of the
 * capability. For example, for a capability type thread_control, the bitfields
 * may mean suspend, resume, create, delete etc.
 */
struct capability {
	struct link list;

	/* Capability identifiers */
	l4id_t capid;		/* Unique capability ID */
	l4id_t owner;		/* Capability owner ID */
	l4id_t resid;		/* Targeted resource ID */
	unsigned int type;	/* Capability and target resource type */

	/* Capability limits/permissions */
	u32 access;		/* Permitted operations */

	/* Limits on the resource (NOTE: must never have signed type) */
	unsigned long start;	/* Resource start value */
	unsigned long end;	/* Resource end value */
	unsigned long size;	/* Resource size */

	/* Use count of resource */
	unsigned long used;

	/* Device attributes, if this is a device. */
	unsigned int attr;
	l4id_t irq;
};

#endif /* __API_CAPABILITY_H__ */
