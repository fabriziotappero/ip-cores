#ifndef __GLUE_ARM_IPC_H__
#define __GLUE_ARM_IPC_H__

#include <l4/generic/tcb.h>
#include INC_GLUE(message.h)

static inline int extended_ipc_msg_index(unsigned int flags)
{
	return (flags & IPC_FLAGS_MSG_INDEX_MASK)
	       >> IPC_FLAGS_MSG_INDEX_SHIFT;
}

static inline int extended_ipc_msg_size(unsigned int flags)
{
	return (flags & IPC_FLAGS_SIZE_MASK)
	       >> IPC_FLAGS_SIZE_SHIFT;
}

static inline void tcb_set_ipc_flags(struct ktcb *task,
				     unsigned int flags)
{
	task->ipc_flags = flags;
}

static inline unsigned int tcb_get_ipc_flags(struct ktcb *task)
{
	return task->ipc_flags;
}

static inline unsigned int
ipc_flags_set_type(unsigned int flags, unsigned int type)
{
	flags &= ~IPC_FLAGS_TYPE_MASK;
	flags |= type & IPC_FLAGS_TYPE_MASK;
	return flags;
}

static inline unsigned int ipc_flags_get_type(unsigned int flags)
{
	return flags & IPC_FLAGS_TYPE_MASK;
}

static inline void tcb_set_ipc_type(struct ktcb *task,
				    unsigned int type)
{
	task->ipc_flags = ipc_flags_set_type(task->ipc_flags,
					     type);
}

static inline unsigned int tcb_get_ipc_type(struct ktcb *task)
{
	return ipc_flags_get_type(task->ipc_flags);
}

#endif /* __GLUE_ARM_IPC_H__ */
