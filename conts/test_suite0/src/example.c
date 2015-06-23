
#if 0

int mutex_user_thread(void *arg)
{
	/* TODO: Create and access a mutex */
}

int independent_thread(void *arg)
{
	/* TODO: Do whatever syscall available */
}


/*
 * This example demonstrates how the capability-based
 * security model can be bypassed and taken out of the
 * way for the sake of implementing an application that
 * doesn't worry too much about security.
 *
 * The benefit is that the user does neither worry about
 * capabilities nor using its api to design correctly
 * secure systems. The downside is that the system is
 * less security-enforced, i.e. all parties must be
 * trusted.
 */
int multi_threaded_nocaps_example(void)
{
	/*
	 * We are the first pager with capabilities to
	 * create new tasks, spaces, in its own container.
	 */
	pager_read_caps();

	/*
	 * We have all our capabilities private to us.
	 *
	 * If we create a new task, it won't be able to
	 * any kernel operations that we can do, because
	 * we hold our capabilities privately.
	 *
	 * In order to settle all capability access issues
	 * once and for all threads we will create and manage,
	 * we share our capabilities with the most global
	 * collection possible.
	 */

	/*
	 * Share all of our capabilities with all threads
	 * in the same container.
	 *
	 * From this point onwards, any thread we create and
	 * manage (i.e. whose container id is equal to our
	 * container id) will have the ability to leverage
	 * all of our capabilities as defined for us at
	 * configuration time.
	 */
	l4_cap_share(0, CAP_SHARE_CONTAINER | CAP_SHARE_ALL, self_tid());


	/*
	 * Lets try it.
	 *
	 * Create new thread that we don't have any hieararchical
	 * relationship, i.e. one that is a pager of itself, one
	 * that runs in a new address space, and in a new thread
	 * group. All we share is the container.
	 */
	if ((err = thread_create(independent_thread, 0,
				 TC_NO_SHARING, &ids)) < 0) {
		printf("mutex_user_thread creation failed.\n");
		goto out_err;
	}

	/*
	 * We can inspect the new thread by doing an ipc to it.
	 * NOTE:
	 *
	 * We are able to send to this thread from the start,
	 * as we had a container-wide ipc capability defined at
	 * config-time.
	 *
	 * But we would not be able to receive from it, if we
	 * did not share this capability with the container. It
	 * would have no rights to do a send to us. But because
	 * we're in the same container, and we shared our
	 * capability, it now can.
	 */
	if ((err = l4_recv(ids->tid, ids->tid, 0)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, fd);
		goto out_err;
	}

	/*
	 * From this point onwards we can create more threads
	 * without worrying about whether they have the caps
	 * to do certain ops, and the caps api. because we shared
	 * them all at the beginning.
	 */

out_err:
	BUG();
}

/*
 * This example demonstrates how a pager would
 * share part of its capabilities on the system
 * with its children.
 *
 * The example includes sharing of a mutex
 * capability with a paged-child.
 */
int multi_threaded_capability_sharing_example(void)
{
	struct capability *mutex_cap;
	int thread_retval;

	/*
	 * We are the first pager with capabilities to
	 * create new tasks, spaces, in its own container.
	 */
	pager_read_caps();

	/*
	 * We have all our capabilities private to us.
	 *
	 * If we create a new task, it won't be able to
	 * create and use userspace mutexes, because we
	 * hold mutex capabilities privately.
	 *
	 * Lets try it.
	 */

	/*
	 * Create new thread that will attempt
	 * a mutex operation, and die on us with a
	 * negative return code if it fails.
	 */
	if ((err = thread_create(mutex_user_thread, 0,
				 TC_SHARE_SPACE |
				 TC_AS_PAGER, &ids)) < 0) {
		printf("mutex_user_thread creation failed.\n");
		goto out_err;
	}

	/* Check on how the thread has done */
	if ((err = l4_thread_wait_on(ids, &thread_retval)) < 0) {
		print("Waiting on thread %d failed. err = %d\n",
		      ids->tid, err);
		goto out_err;
	}

	if (thread_retval == 0) {
		printf("Thread %d returned with success, where "
		       "we expected failure.\n", ids->tid);
		goto out_err;
	}

	/*
	 * Therefore, we share our capabilities with a
	 * collection so that our capabilities may be also
	 * used by them.
	 */

	/* Get our private mutex cap */
	mutex_cap = cap_get(CAP_TYPE_MUTEX);

	/* We have ability to create and use this many mutexes */
	printf("%s: We have ability to create/use %d mutexes\n",
	       self_tid(), mutex_cap->size);

	/* Split it */
	cap_new = cap_split(mutex_cap, 10, CAP_SPLIT_SIZE);

	/*
	 * Share the split part with paged-children.
	 *
	 * From this point onwards, any thread we create and
	 * manage (i.e. whose pagerid == self_tid()) will have
	 * the ability to use mutexes, as defined by cap_new
	 * we created.
	 */
	l4_cap_share(cap_new, CAP_SHARE_PGGROUP, self_tid());

	/*
	 * Create new thread that will attempt
	 * a mutex operation, and die on us with a
	 * negative return code if it fails.
	 */
	if ((err = thread_create(mutex_user_thread, 0,
				 TC_SHARE_SPACE |
				 TC_AS_PAGER, &ids)) < 0) {
		printf("mutex_user_thread creation failed.\n");
		goto out_err;
	}

	/* Check on how the thread has done */
	if ((err = l4_thread_wait_on(ids, &thread_retval)) < 0) {
		printf("Waiting on thread %d failed. err = %d\n",
		      ids->tid, err);
		goto out_err;
	}

	if (thread_retval < 0) {
		printf("Thread %d returned with failure, where "
		       "we expected success.\n", ids->tid);
		goto out_err;
	}

out_err:
	BUG();
}






#endif

