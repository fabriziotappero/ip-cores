/*
 * Test ipc system call.
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/lib/thread.h>
#include <l4lib/ipcdefs.h>
#include <tests.h>
#include <macros.h>
#include <fault.h>
#include <memory.h>

struct ipc_ext_data {
	void *virtual;	/* Virtual address to start ipc from */
	l4id_t partner; /* Partner to do extended ipc */
};

int ipc_extended_sender(void *arg)
{
	struct ipc_ext_data *data = arg;
	int err;

	if ((err = l4_send_extended(data->partner, 0,
				    SZ_2K, data->virtual)) < 0) {
		printf("%s: Extended send failed. err=%d\n",
		       __FUNCTION__, err);
	}
	return 0;
}

int ipc_extended_receiver(void *arg)
{
	struct ipc_ext_data *data = arg;
	int err;

	if ((err = l4_receive_extended(data->partner, SZ_2K,
				       data->virtual)) < 0) {
		printf("%s: Extended receive failed. err=%d\n",
		       __FUNCTION__, err);
	}

	/*
	 * Test the data received
	 */
	for (int i = 0; i < SZ_2K; i++) {
		if (((char *)data->virtual)[i] != 'A' + i)
			printf("%s: Extended receive buffer has unexpected "
			       "data: Start %p, Offset: %d, "
			       "Data=%d, expected=%d\n", __FUNCTION__,
			       data->virtual, i, ((char *)data->virtual)[i],
			       'A' + i);
		return err;
	}

	return 0;
}

int ipc_ext_handle_pfault(struct ipc_ext_data *ipc_data,
			  void **virt, void **phys)
{
	u32 mr[MR_UNUSED_TOTAL];
	struct fault_data fault;
	int err;

	/* Read mrs not used by syslib */
	for (int i = 0; i < MR_UNUSED_TOTAL; i++)
		mr[i] = read_mr(MR_UNUSED_START + i);

	fault.kdata = (fault_kdata_t *)&mr[0];
	fault.sender = l4_get_sender();

	/* Convert from arch-specific to generic fault data */
	set_generic_fault_params(&fault);

	/*
	 * Handle the fault using a basic logic - if a virtual index
	 * is faulted, map the corresponding page at same physical index.
	 */
	if (page_align(fault.address) == (unsigned long)virt[0]) {
		if ((err = l4_map(phys[0], virt[0], 1,
				  MAP_USR_RW, fault.sender)) < 0) {
			printf("%s: Error: l4_map failed. "
			       "phys=%p, virt=%p\n", __FUNCTION__,
			       phys[0], virt[0]);
			return err;
		}
	} else if (page_align(fault.address) == (unsigned long)virt[1]) {
		if ((err = l4_map(phys[1], virt[1], 1,
				  MAP_USR_RW, fault.sender)) < 0) {
			printf("%s: Error: l4_map failed. "
			       "phys=%p, virt=%p\n", __FUNCTION__,
			       phys[1], virt[1]);
			return err;
		}
	} else if (page_align(fault.address) == (unsigned long)virt[2]) {
		if ((err = l4_map(phys[2], virt[2], 1,
				  MAP_USR_RW, fault.sender)) < 0) {
			printf("%s: Error: l4_map failed. "
			       "phys=%p, virt=%p\n", __FUNCTION__,
			       phys[2], virt[2]);
			return err;
		}
	} else if (page_align(fault.address) == (unsigned long)virt[3]) {
		if ((err = l4_map(phys[3], virt[3], 1,
				  MAP_USR_RW, fault.sender)) < 0) {
			printf("%s: Error: l4_map failed. "
			       "phys=%p, virt=%p\n", __FUNCTION__,
			       phys[3], virt[3]);
			return err;
		}
	} else {
		printf("%s: Error, page fault occured on an unexpected "
		       "address. adress=0x%x\n", __FUNCTION__,
		       fault.address);
		return -1;
	}

	/* Reply back to fault thread and return */
	return l4_ipc_return(0);
}

/*
 * Create two threads who will do page-faulting ipc to each other.
 * Their parent waits and handles the page faults.
 *
 * This test allocates 4 virtual page and 4 physical page addresses.
 * It fills a total of 2KB of payload starting from the 3rd quarter
 * of the first page and until the 2nd quarter of the 2nd page to
 * be sent by the sender thread.
 *
 * The payload is copied and the pages deliberately unmapped so that
 * the sender thread will page fault during the send operation.
 *
 * The receive pages are also set up same as above, so the receiving
 * thread also faults during the receive.
 *
 * The main thread starts both ipc threads, and starts waiting on
 * page faults. It handles the faults and the test succeeds if the
 * data is transfered safely to receiving end, despite all faults.
 */
int test_ipc_extended(void)
{
	struct task_ids self_ids;
	struct ipc_ext_data ipc_data[2];
	struct l4_thread *thread[2];
	void *virt[4], *phys[4];
	int err, tag;

	l4_getid(&self_ids);

	/* Get 4 physical pages */
	for (int i = 0; i < 4; i++)
		phys[i] = physical_page_new(1);

	/* Get 2 pairs of virtual pages */
	virt[0] = virtual_page_new(2);
	virt[1] = virt[0] + PAGE_SIZE;
	virt[2] = virtual_page_new(2);
	virt[3] = virt[2] + PAGE_SIZE;

	/* Map sender pages to self */
	if ((err = l4_map(phys[0], virt[0], 1,
			  MAP_USR_RW, self_ids.tid)) < 0) {
		printf("Error: Mapping Sender pages failed. phys: 0x%p,"
		       " virt: 0x%p, tid=%d, err=%d\n", phys[0], virt[0],
		       self_ids.tid, err);
		return err;
	}
	if ((err = l4_map(phys[1], virt[1], 1,
			  MAP_USR_RW, self_ids.tid)) < 0) {
		printf("Error: Mapping Sender pages failed. phys: 0x%p,"
		       " virt: 0x%p, tid=%d, err=%d\n", phys[0], virt[0],
		       self_ids.tid, err);
		return err;
	}

	/*
	 * Fill them with values to be sent
	 * Filling in 3rd KB of first page to 2nd KB of second page
	 */
	for (int i = 0; i < SZ_2K; i++)
		((char *)virt[0] + SZ_1K * 3)[i] = 'A' + i;

	/* Unmap the pages */
	l4_unmap(virt[0], 2, self_ids.tid);

	/* Create ipc threads but don't start. */
	if ((err = thread_create(ipc_extended_sender,
				 &ipc_data[0],
				 TC_SHARE_SPACE | TC_NOSTART,
				 &thread[0])) < 0) {
		dbg_printf("Thread create failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Thread created successfully. "
		   "tid=%d\n", thread[0]->ids.tid);

	if ((err = thread_create(ipc_extended_receiver,
				 &ipc_data[1],
				 TC_SHARE_SPACE | TC_NOSTART,
				 &thread[1])) < 0) {
		dbg_printf("Thread create failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Thread created successfully. "
		   "tid=%d\n", thread[1]->ids.tid);

	/*
	 * Set up arguments to sender,
	 * Send offset at 3rd quarter of first page.
	 */
	ipc_data[0].virtual = virt[0] + SZ_1K * 3;
	ipc_data[0].partner = thread[1]->ids.tid;

	/*
	 * Set up arguments to receiver
	 * Receive offset at 3rd quarter of first page.
	 */
	ipc_data[1].virtual = virt[1] + SZ_1K * 3;
	ipc_data[1].partner = thread[0]->ids.tid;

	/* Start the threads */
	l4_thread_control(THREAD_RUN, &thread[0]->ids);
	l4_thread_control(THREAD_RUN, &thread[1]->ids);

	/* Expecting 4 faults on 4 pages */
	for (int i = 0; i < 4; i++) {
		/* Wait on page fault */
		if ((err = l4_receive(L4_ANYTHREAD)) < 0) {
			printf("Error: l4_receive() for page"
			       " fault has failed. err=%d\n",
			       err);
		}
		if ((tag = l4_get_tag()) != L4_IPC_TAG_PFAULT) {
			printf("Error: Parent thread received "
			       "non-page fault ipc tag. tag=%d\n",
			       tag);
			return -1;
		}

		/* Handle fault */
		if ((err = ipc_ext_handle_pfault(ipc_data, virt, phys)) < 0) {
			printf("Error: An error occured during ipc "
			       "page fault handling. err=%d\n", err);
			return err;
		}
	}

	/* Wait for the ipc threads */
	for (int i = 0; i < 2; i ++)
		if ((err = thread_wait(thread[i])) < 0) {
			dbg_printf("THREAD_WAIT failed. "
				   "err=%d\n", err);
			return err;
		}

	/* Unmap and release pages */
	for (int i = 0; i < 4; i++) {
		l4_unmap(virt[i], 1, self_ids.tid);
		virtual_page_free(virt[i], 1);
		physical_page_free(phys[i], 1);
	}

	return 0;
}

int ipc_full_thread(void *arg)
{
	l4id_t parent = *((l4id_t *)arg);
	int err;

	/* Do two full send/receives */
	for (int i = 0; i < 2; i++) {
		/* Full receive, return positive if error */
		if ((err = l4_receive_full(parent)) < 0) {
			dbg_printf("Full receive failed on new "
				   "thread. err=%d", err);
			return 1;
		}

		/* Test full utcb received values */
		for (int i = MR_UNUSED_START; i < MR_TOTAL + MR_REST; i++) {
			if (read_mr(i) != i) {
				dbg_printf("IPC full receive on new thread: "
					   "Unexpected message register "
					   "values. MR%d = %d, should be %d\n",
					   i, read_mr(i), i);
				return 1; /* Exit positive without reply */
			}
		}

		/*
		 * Reset all message registers
		 */
		for (int i = MR_UNUSED_START; i < MR_TOTAL + MR_REST; i++)
			write_mr(i, 0);

		/* Send full return reply */
		l4_send_full(parent, 0);
	}
	return 0;
}

int ipc_short_thread(void *arg)
{
	l4id_t parent = *((l4id_t *)arg);
	int err;

	/* Short receive, return positive if error */
	if ((err = l4_receive(parent)) < 0) {
		dbg_printf("Short receive failed on new "
			   "thread. err=%d", err);
		return 1;
	}

	/* Test received registers */
	for (int i = MR_UNUSED_START; i < MR_TOTAL; i++) {
		if (read_mr(i) != i) {
			dbg_printf("IPC Receive on new thread: "
				   "Unexpected message register "
				   "values.\n"
				   "read = %d, expected = %d\n",
				   read_mr(i), i);
			l4_print_mrs();
			return 1; /* Exit positive without reply */
		}
	}

	/*
	 * Reset all message registers
	 */
	for (int i = MR_UNUSED_START; i < MR_TOTAL; i++)
		write_mr(i, 0);

	/*
	 * Send return reply and exit
	 */
	return l4_send(parent, 0);
}


/*
 * Create a thread and do a full ipc to it
 */
int test_ipc_full(void)
{
	struct task_ids self_ids;
	struct l4_thread *thread;
	int err;

	l4_getid(&self_ids);

	/*
	 * Create a thread in the same space
	 */
	if ((err = thread_create(ipc_full_thread,
				 &self_ids.tid,
				 TC_SHARE_SPACE,
				 &thread)) < 0) {
		dbg_printf("Thread create failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Thread created successfully. "
		   "tid=%d\n", thread->ids.tid);

	/*
	 * Try one short and one full send/recv
	 * to test full send/recv occurs on both cases
	 */

	/*
	 * Write data to full utcb registers
	 */
	for (int i = MR_UNUSED_START; i < MR_TOTAL + MR_REST; i++)
		write_mr(i, i);

	/*
	 * First, do a full ipc send/recv
	 */
	if ((err = l4_sendrecv_full(thread->ids.tid,
				    thread->ids.tid,
				    0)) < 0) {
		dbg_printf("Full IPC send/recv failed. "
			   "err=%d\n", err);
		return err;
	}

	/*
	 * Check that payload registers are modified to 0
	 */
	dbg_printf("%s: After send/recv:\n", __FUNCTION__);
	for (int i = MR_UNUSED_START; i < MR_TOTAL + MR_REST; i++) {
		if (read_mr(i) != 0) {
			dbg_printf("Full IPC send/recv: "
				   "Received payload is not "
				   "as expected.\n "
				   "MR%d = %d, should be %d\n",
				   i, read_mr(i), 0);
			return -1;
		}
	}

	/*
	 * Write data to full utcb registers
	 */
	for (int i = MR_UNUSED_START; i < MR_TOTAL + MR_REST; i++)
		write_mr(i, i);

	/*
	 * Try a short ipc send/recv. This should still result
	 * in full ipc since the other side is doing full send/recv.
	 */
	if ((err = l4_sendrecv(thread->ids.tid,
			       thread->ids.tid,
			       0)) < 0) {
		dbg_printf("Full IPC send/recv failed. "
			   "err=%d\n", err);
		return err;
	}

	/*
	 * Check that payload registers are modified to 0
	 */
	// dbg_printf("%s: After send/recv:\n", __FUNCTION__);
	for (int i = MR_UNUSED_START; i < MR_TOTAL + MR_REST; i++) {
		// dbg_printf("MR%d: %d\n", i, read_mr(i));
		if (read_mr(i) != 0) {
			dbg_printf("Full IPC send/recv: "
				   "Received payload is not "
				   "as expected.\n "
				   "MR%d = %d, should be %d\n",
				   i, read_mr(i), 0);
			return -1;
		}
	}

	/* Wait for the ipc thread to die */
	if ((err = thread_wait(thread)) < 0) {
		dbg_printf("THREAD_WAIT failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Full IPC send/recv successful.\n");
	return 0;
}

/*
 * Create a thread and do a short ipc to it
 */
int test_ipc_short(void)
{
	struct task_ids self_ids;
	struct l4_thread *thread;
	int err;

	l4_getid(&self_ids);

	/*
	 * Create a thread in the same space
	 */
	if ((err = thread_create(ipc_short_thread,
				 &self_ids.tid,
				 TC_SHARE_SPACE,
				 &thread)) < 0) {
		dbg_printf("Thread create failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Thread created successfully. "
		   "tid=%d\n", thread->ids.tid);

	/*
	 * Write data to short ipc registers
	 */
	for (int i = MR_UNUSED_START; i < MR_TOTAL; i++)
		write_mr(i, i);

	/*
	 * Do short ipc send/recv and check data is reset
	 */
	if ((err = l4_sendrecv(thread->ids.tid,
			       thread->ids.tid,
			       0)) < 0) {
		dbg_printf("Short IPC send/recv failed. "
			   "err=%d\n", err);
		return err;
	}

	/*
	 * Check that payload registers are reset
	 */
	for (int i = MR_UNUSED_START; i < MR_TOTAL; i++) {
		if (read_mr(i) != 0) {
			dbg_printf("Short IPC send/recv: "
				   "Received payload is incorrect."
				   "read = %d, expected=%d\n",
				   read_mr(i), 0);
			return -1;
		}
	}

	/* Wait for the ipc thread */
	if ((err = thread_wait(thread)) < 0) {
		dbg_printf("THREAD_WAIT failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Short IPC send/recv successful.\n");
	return 0;
}

int test_api_ipc(void)
{
	int err;

	if ((err = test_ipc_extended()) < 0)
		goto out_err;

	if ((err = test_ipc_short()) < 0)
		goto out_err;

	if ((err = test_ipc_full()) < 0)
		goto out_err;

	printf("IPC:                           -- PASSED --\n");
	return 0;

out_err:
	printf("IPC:                           -- FAILED --\n");
	return err;

}

