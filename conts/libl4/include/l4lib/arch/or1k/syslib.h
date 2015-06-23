/*
 * Helper functions that wrap raw l4 syscalls.
 *
 * Copyright (C) 2007-2009 Bahadir Bilgehan Balban
 */

#ifndef __L4LIB_SYSLIB_H__
#define __L4LIB_SYSLIB_H__

#include <stdio.h>
#include <l4/macros.h>
#include L4LIB_INC_ARCH(syscalls.h)

/*
 * NOTE:
 * Its best to use these wrappers because they generalise the way
 * common ipc data like sender id, error, ipc tag are passed
 * between ipc parties.
 *
 * The arguments to l4_ipc() are used by the microkernel to initiate
 * the ipc. Any data passed in message registers may or may not be
 * a duplicate of this data, but the distinction is that anything
 * that is passed via the mrs are meant to be used by the other party
 * participating in the ipc.
 */

/* For system call arguments */
#define L4SYS_ARG0	(MR_UNUSED_START)
#define	L4SYS_ARG1	(MR_UNUSED_START + 1)
#define L4SYS_ARG2	(MR_UNUSED_START + 2)
#define L4SYS_ARG3	(MR_UNUSED_START + 3)


#define L4_IPC_TAG_MASK			0x00000FFF


/*
 * Servers get sender.
 */
static inline l4id_t l4_get_sender(void)
{
	return (l4id_t)read_mr(MR_SENDER);
}

/*
 * When doing an ipc the sender never has to be explicitly set in
 * the utcb via this function since this information is found out
 * by the microkernel by checking the system caller's id. This is
 * only used for restoring the sender on the utcb in order to
 * complete an earlier ipc.
 */
static inline void l4_set_sender(l4id_t sender)
{
	write_mr(MR_SENDER, sender);
}

static inline unsigned int l4_set_ipc_size(unsigned int word, unsigned int size)
{
	word &= ~L4_IPC_FLAGS_SIZE_MASK;
	word |= ((size << L4_IPC_FLAGS_SIZE_SHIFT) & L4_IPC_FLAGS_SIZE_MASK);
	return word;
}

static inline unsigned int l4_get_ipc_size(unsigned int word)
{
	return (word & L4_IPC_FLAGS_SIZE_MASK) >> L4_IPC_FLAGS_SIZE_SHIFT;
}

static inline unsigned int l4_set_ipc_msg_index(unsigned int word, unsigned int index)
{
	/* FIXME: Define MR_PRIMARY_TOTAL, MR_TOTAL etc. and use MR_TOTAL HERE! */
	BUG_ON(index > UTCB_SIZE);

	word &= ~L4_IPC_FLAGS_MSG_INDEX_MASK;
	word |= (index << L4_IPC_FLAGS_MSG_INDEX_SHIFT) &
		 L4_IPC_FLAGS_MSG_INDEX_MASK;
	return word;
}

static inline unsigned int l4_get_ipc_msg_index(unsigned int word)
{
	return (word & L4_IPC_FLAGS_MSG_INDEX_MASK)
	       >> L4_IPC_FLAGS_MSG_INDEX_SHIFT;
}

static inline unsigned int l4_set_ipc_flags(unsigned int word, unsigned int flags)
{
	word &= ~L4_IPC_FLAGS_TYPE_MASK;
	word |= flags & L4_IPC_FLAGS_TYPE_MASK;
	return word;
}

static inline unsigned int l4_get_ipc_flags(unsigned int word)
{
	return word & L4_IPC_FLAGS_TYPE_MASK;
}

static inline unsigned int l4_get_tag(void)
{
	return read_mr(MR_TAG) & L4_IPC_TAG_MASK;
}

static inline void l4_set_tag(unsigned int tag)
{
	unsigned int tag_flags = read_mr(MR_TAG);

	tag_flags &= ~L4_IPC_TAG_MASK;
	tag_flags |= tag & L4_IPC_TAG_MASK;

	write_mr(MR_TAG, tag_flags);
}

/* Servers:
 * Sets the message register for returning errors back to client task.
 * These are usually posix error codes.
 */
static inline void l4_set_retval(int retval)
{
	write_mr(MR_RETURN, retval);
}

/* Clients:
 * Learn result of request.
 */
static inline int l4_get_retval(void)
{
	return read_mr(MR_RETURN);
}

/*
 * This is useful for stacked IPC. A stacked IPC happens
 * when a new IPC is initiated before concluding the current
 * one.
 *
 * This saves the last ipc's parameters such as the sender
 * and tag information. Any previously saved data in save
 * slots are destroyed. This is fine as IPC stacking is only
 * useful if done once.
 */
static inline void l4_save_ipcregs(void)
{
	l4_get_utcb()->saved_sender = l4_get_sender();
	l4_get_utcb()->saved_tag = l4_get_tag();
}

static inline void l4_restore_ipcregs(void)
{
	l4_set_tag(l4_get_utcb()->saved_tag);
	l4_set_sender(l4_get_utcb()->saved_sender);
}

#define TASK_CID_MASK			0xFF000000
#define TASK_ID_MASK			0x00FFFFFF
#define TASK_CID_SHIFT			24

static inline l4id_t __raw_tid(l4id_t tid)
{
	return tid & TASK_ID_MASK;
}

static inline l4id_t __cid(l4id_t tid)
{
	return (tid & TASK_CID_MASK) >> TASK_CID_SHIFT;
}

static inline l4id_t self_tid(void)
{
	struct task_ids ids;

	l4_getid(&ids);
	return ids.tid;
}

static inline l4id_t __raw_self_tid(void)
{
	return __raw_tid(self_tid());
}

static inline int l4_send_full(l4id_t to, unsigned int tag)
{
	l4_set_tag(tag);
	return l4_ipc(to, L4_NILTHREAD, L4_IPC_FLAGS_FULL);
}

static inline int l4_receive_full(l4id_t from)
{
	return l4_ipc(L4_NILTHREAD, from, L4_IPC_FLAGS_FULL);
}

static inline int l4_sendrecv_full(l4id_t to, l4id_t from, unsigned int tag)
{
	int err;

	BUG_ON(to == L4_NILTHREAD || from == L4_NILTHREAD);
	l4_set_tag(tag);

	err = l4_ipc(to, from, L4_IPC_FLAGS_FULL);

	return err;
}

static inline int l4_send_extended(l4id_t to, unsigned int tag,
				   unsigned int size, void *buf)
{
	unsigned int flags = 0;

	l4_set_tag(tag);

	/* Set up flags word for extended ipc */
	flags = l4_set_ipc_flags(flags, L4_IPC_FLAGS_EXTENDED);
	flags = l4_set_ipc_size(flags, size);
	flags = l4_set_ipc_msg_index(flags, L4SYS_ARG0);

	/* Write buffer pointer to MR index that we specified */
	write_mr(L4SYS_ARG0, (unsigned long)buf);

	return l4_ipc(to, L4_NILTHREAD, flags);
}

static inline int l4_receive_extended(l4id_t from, unsigned int size, void *buf)
{
	unsigned int flags = 0;

	/* Indicate extended receive */
	flags = l4_set_ipc_flags(flags, L4_IPC_FLAGS_EXTENDED);

	/* How much data is accepted */
	flags = l4_set_ipc_size(flags, size);

	/* Indicate which MR index buffer pointer is stored */
	flags = l4_set_ipc_msg_index(flags, L4SYS_ARG0);

	/* Set MR with buffer to receive data */
	write_mr(L4SYS_ARG0, (unsigned long)buf);

	return l4_ipc(L4_NILTHREAD, from, flags);
}

/*
 * Return result value as extended IPC.
 *
 * Extended IPC copies up to 2KB user address space buffers.
 * Along with such an ipc, a return value is sent using a primary
 * mr that is used as the return register.
 *
 * It may not be desirable to return a payload on certain conditions,
 * (such as an error return value) So a nopayload field is provided.
 */
static inline int l4_return_extended(int retval, unsigned int size,
				     void *buf, int nopayload)
{
	unsigned int flags = 0;
	l4id_t sender = l4_get_sender();

	l4_set_retval(retval);

	/* Set up flags word for extended ipc */
	flags = l4_set_ipc_flags(flags, L4_IPC_FLAGS_EXTENDED);
	flags = l4_set_ipc_msg_index(flags, L4SYS_ARG0);

	/* Write buffer pointer to MR index that we specified */
	write_mr(L4SYS_ARG0, (unsigned long)buf);

	if (nopayload)
		flags = l4_set_ipc_size(flags, 0);
	else
		flags = l4_set_ipc_size(flags, size);

	return l4_ipc(sender, L4_NILTHREAD, flags);
}

static inline int l4_sendrecv_extended(l4id_t to, l4id_t from,
				       unsigned int tag, void *buf)
{
	/* Need to imitate sendrecv but with extended send/recv flags */
	return 0;
}

static inline int l4_send(l4id_t to, unsigned int tag)
{
	l4_set_tag(tag);

	return l4_ipc(to, L4_NILTHREAD, 0);
}

static inline int l4_sendrecv(l4id_t to, l4id_t from, unsigned int tag)
{
	int err;

	BUG_ON(to == L4_NILTHREAD || from == L4_NILTHREAD);
	l4_set_tag(tag);

	err = l4_ipc(to, from, 0);

	return err;
}

static inline int l4_receive(l4id_t from)
{
	return l4_ipc(L4_NILTHREAD, from, 0);
}

static inline void l4_print_mrs()
{
	printf("Message registers: 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x\n",
	       read_mr(0), read_mr(1), read_mr(2), read_mr(3),
	       read_mr(4), read_mr(5));
}

/* Servers:
 * Return the ipc result back to requesting task.
 */
static inline int l4_ipc_return(int retval)
{
	l4id_t sender = l4_get_sender();

	l4_set_retval(retval);

	/* Setting the tag would overwrite retval so we l4_send without tagging */
	return l4_ipc(sender, L4_NILTHREAD, 0);
}

void *l4_new_virtual(int npages);
void *l4_del_virtual(void *virt, int npages);

/* A helper that translates and maps a physical address to virtual */
static inline void *l4_map_helper(void *phys, int npages)
{
	struct task_ids ids;
	int err;

	void *virt = l4_new_virtual(npages);

	l4_getid(&ids);

	if ((err = l4_map(phys, virt, npages,
			  MAP_USR_DEFAULT, ids.tid)) < 0)
		return PTR_ERR(err);

	return virt;
}


/* A helper that translates and maps a physical address to virtual */
static inline void *l4_unmap_helper(void *virt, int npages)
{
	struct task_ids ids;

	l4_getid(&ids);
	l4_unmap(virt, npages, ids.tid);
	l4_del_virtual(virt, npages);
	return 0;
}

#define L4_EXIT_MASK		0xFFFF

static inline void l4_exit(unsigned int exit_code)
{
	struct task_ids ids;
	l4_getid(&ids);
	l4_thread_control(THREAD_DESTROY |
			  (exit_code & L4_EXIT_MASK),
			  &ids);
}

#endif /* __L4LIB_SYSLIB_H__ */
