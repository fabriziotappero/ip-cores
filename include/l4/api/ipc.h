#ifndef __IPC_H__
#define __IPC_H__

#define L4_NILTHREAD		0xFFFFFFFF
#define L4_ANYTHREAD		0xFFFFFFFE

#define L4_IPC_TAG_MR_OFFSET		0

/* Pagefault */
#define L4_IPC_TAG_PFAULT		0
#define L4_IPC_TAG_UNDEF_FAULT		1

#define L4_IPC_FLAGS_TYPE_MASK		0x0000000F
#define L4_IPC_FLAGS_SHORT		0x00000000	/* Short IPC involves just primary message registers */
#define L4_IPC_FLAGS_FULL		0x00000001	/* Full IPC involves full UTCB copy */
#define L4_IPC_FLAGS_EXTENDED		0x00000002	/* Extended IPC can page-fault and copy up to 2KB */

/* Extended IPC extra fields */
#define L4_IPC_FLAGS_MSG_INDEX_MASK	0x00000FF0	/* Index of message register with buffer pointer */
#define L4_IPC_FLAGS_SIZE_MASK		0x0FFF0000
#define L4_IPC_FLAGS_SIZE_SHIFT		16
#define L4_IPC_FLAGS_MSG_INDEX_SHIFT	4


#define L4_IPC_EXTENDED_MAX_SIZE	(SZ_1K*2)

#if defined (__KERNEL__)

/* Kernel-only flags */
#define IPC_FLAGS_SHORT			L4_IPC_FLAGS_SHORT
#define IPC_FLAGS_FULL			L4_IPC_FLAGS_FULL
#define IPC_FLAGS_EXTENDED		L4_IPC_FLAGS_EXTENDED
#define IPC_FLAGS_MSG_INDEX_MASK	L4_IPC_FLAGS_MSG_INDEX_MASK
#define IPC_FLAGS_TYPE_MASK		L4_IPC_FLAGS_TYPE_MASK
#define IPC_FLAGS_SIZE_MASK		L4_IPC_FLAGS_SIZE_MASK
#define IPC_FLAGS_SIZE_SHIFT		L4_IPC_FLAGS_SIZE_SHIFT
#define IPC_FLAGS_MSG_INDEX_SHIFT	L4_IPC_FLAGS_MSG_INDEX_SHIFT
#define IPC_FLAGS_ERROR_MASK		0xF0000000
#define IPC_FLAGS_ERROR_SHIFT		28
#define IPC_EFAULT			(1 << 28)
#define IPC_ENOIPC			(1 << 29)

#define IPC_EXTENDED_MAX_SIZE		L4_IPC_EXTENDED_MAX_SIZE

/*
 * ipc syscall uses an ipc_dir variable and send/recv
 * details are embedded in this variable.
 */
enum IPC_DIR {
	IPC_INVALID = 0,
	IPC_SEND = 1,
	IPC_RECV = 2,
	IPC_SENDRECV = 3,
};

/* These are for internally created ipc paths. */
int ipc_send(l4id_t to, unsigned int flags);
int ipc_sendrecv(l4id_t to, l4id_t from, unsigned int flags);

#endif

#endif /* __IPC_H__ */
