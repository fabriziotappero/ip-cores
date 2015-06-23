/*
 * mm0. Pager for all tasks.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <stdio.h>
#include <init.h>
#include L4LIB_INC_ARCH(utcb.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include L4LIB_INC_ARCH(syslib.h)
#include <l4lib/kip.h>
#include <l4lib/utcb.h>
#include <l4lib/ipcdefs.h>
#include <l4lib/types.h>
#include <l4/api/thread.h>
#include <l4/api/space.h>
#include <l4/api/ipc.h>
#include <l4/api/errno.h>
#include <vm_area.h>
#include <syscalls.h>
#include <file.h>
#include <shm.h>
#include <mmap.h>
#include <test.h>
#include <capability.h>
#include <globals.h>

/* Receives all registers and origies back */
int ipc_test_full_sync(l4id_t senderid)
{
	for (int i = MR_UNUSED_START; i < MR_TOTAL + MR_REST; i++) {
	//	printf("%s/%s: MR%d: %d\n", __TASKNAME__, __FUNCTION__,
	//	       i, read_mr(i));
		/* Reset it to 0 */
		write_mr(i, 0);
	}

	/* Send a full origy */
	l4_send_full(senderid, 0);
	return 0;
}

void handle_requests(void)
{
	/* Generic ipc data */
	u32 mr[MR_UNUSED_TOTAL];
	l4id_t senderid;
	struct tcb *sender;
	u32 tag;
	int ret;

	// printf("%s: Initiating ipc.\n", __TASKNAME__);
	if ((ret = l4_receive(L4_ANYTHREAD)) < 0) {
		printf("%s: %s: IPC Error: %d. Quitting...\n", __TASKNAME__,
		       __FUNCTION__, ret);
		BUG();
	}

	/* Syslib conventional ipc data which uses first few mrs. */
	tag = l4_get_tag();
	senderid = l4_get_sender();

	if (!(sender = find_task(senderid))) {
		l4_ipc_return(-ESRCH);
		return;
	}

	/* Read mrs not used by syslib */
	for (int i = 0; i < MR_UNUSED_TOTAL; i++)
		mr[i] = read_mr(MR_UNUSED_START + i);

	switch(tag) {
	case L4_IPC_TAG_SYNC_FULL:
		ret = ipc_test_full_sync(senderid);
		return;
	case L4_IPC_TAG_SYNC:
		mm0_test_global_vm_integrity();
		// printf("%s: Synced with waiting thread.\n", __TASKNAME__);
		/* This has no receive phase */
		return;

	case L4_IPC_TAG_UNDEF_FAULT:
		/* Undefined instruction fault. Ignore. */
		// printf("Undefined instruction fault caught.\n");
		ret = 0;
		break;
	case L4_IPC_TAG_PFAULT: {
		struct page *p;

		/* Handle page fault. */
		if (IS_ERR(p = page_fault_handler(sender, (fault_kdata_t *)&mr[0])))
			ret = (int)p;
		else
			ret = 0;
		break;
	}
	case L4_REQUEST_CAPABILITY: {
		ret = sys_request_cap(sender, (struct capability *)mr[0]);
		break;
	}
	case L4_IPC_TAG_SHMGET: {
		ret = sys_shmget((key_t)mr[0], (int)mr[1], (int)mr[2]);
		break;
	}

	case L4_IPC_TAG_SHMAT: {
		ret = (int)sys_shmat(sender, (l4id_t)mr[0], (void *)mr[1], (int)mr[2]);
		break;
	}

	case L4_IPC_TAG_SHMDT:
		ret = sys_shmdt(sender, (void *)mr[0]);
		break;

	case L4_IPC_TAG_READ:
		ret = sys_read(sender, (int)mr[0], (void *)mr[1], (int)mr[2]);
		break;

	case L4_IPC_TAG_WRITE:
		ret = sys_write(sender, (int)mr[0], (void *)mr[1], (int)mr[2]);
		break;

	case L4_IPC_TAG_CLOSE:
		ret = sys_close(sender, (int)mr[0]);
		break;

	case L4_IPC_TAG_FSYNC:
		ret = sys_fsync(sender, (int)mr[0]);
		break;

	case L4_IPC_TAG_LSEEK:
		ret = sys_lseek(sender, (int)mr[0], (off_t)mr[1], (int)mr[2]);
		break;

	case L4_IPC_TAG_MMAP: {
		struct sys_mmap_args *args = (struct sys_mmap_args *)mr[0];
		ret = (int)sys_mmap(sender, args);
		break;
	}
	case L4_IPC_TAG_MUNMAP: {
		ret = sys_munmap(sender, (void *)mr[0], (unsigned long)mr[1]);
		break;
	}
	case L4_IPC_TAG_MSYNC: {
		ret = sys_msync(sender, (void *)mr[0],
				(unsigned long)mr[1], (int)mr[2]);
		break;
	}
	case L4_IPC_TAG_FORK: {
		ret = sys_fork(sender);
		break;
	}
	case L4_IPC_TAG_CLONE: {
		ret = sys_clone(sender, (void *)mr[0], (unsigned int)mr[1]);
		break;
	}
	case L4_IPC_TAG_EXIT: {
		/* Pager exit test
		struct task_ids ids;
		l4_getid(&ids);
		printf("\n%s: Destroying self (%d), along with any tasks.\n", __TASKNAME__, self_tid());
		l4_thread_control(THREAD_DESTROY, &ids);
		*/

		/* An exiting task has no receive phase */
		sys_exit(sender, (int)mr[0]);
		return;
	}
	case L4_IPC_TAG_EXECVE: {
		ret = sys_execve(sender, (char *)mr[0],
				 (char **)mr[1], (char **)mr[2]);
		if (ret < 0)
			break;	/* We reply for errors */
		else
			return; /* else we're done */
	}

	/* FS0 System calls */
	case L4_IPC_TAG_OPEN:
		ret = sys_open(sender, utcb_full_buffer(), (int)mr[0], (unsigned int)mr[1]);
		break;
	case L4_IPC_TAG_MKDIR:
		ret = sys_mkdir(sender, utcb_full_buffer(), (unsigned int)mr[0]);
		break;
	case L4_IPC_TAG_CHDIR:
		ret = sys_chdir(sender, utcb_full_buffer());
		break;
	case L4_IPC_TAG_READDIR: {
		char dirbuf[L4_IPC_EXTENDED_MAX_SIZE];
		ret = sys_readdir(sender, (int)mr[0], (int)mr[1], dirbuf);
		l4_return_extended(ret, L4_IPC_EXTENDED_MAX_SIZE, dirbuf, ret < 0);
		return;
	}
	default:
		printf("%s: Unrecognised ipc tag (%d) "
		       "received from (%d). Full mr reading: "
		       "%u, %u, %u, %u, %u, %u. Ignoring.\n",
		       __TASKNAME__, tag, senderid, read_mr(0),
		       read_mr(1), read_mr(2), read_mr(3), read_mr(4),
		       read_mr(5));
	}

	/* Reply */
	if ((ret = l4_ipc_return(ret)) < 0) {
		printf("%s: L4 IPC Error: %d.\n", __FUNCTION__, ret);
		BUG();
	}
}

void main(void)
{

	printf("\n%s: Started with thread id %x\n", __TASKNAME__, __raw_self_tid());

	init();

	printf("%s: Memory/Process manager initialized. Listening requests.\n", __TASKNAME__);
	while (1) {
		handle_requests();
	}
}

