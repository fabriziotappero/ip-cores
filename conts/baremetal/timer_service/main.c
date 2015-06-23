/*
 * Timer service for userspace
 */
#include <l4lib/lib/addr.h>
#include <l4lib/irq.h>
#include <l4lib/lib/thread.h>
#include <l4lib/ipcdefs.h>
#include <l4/api/errno.h>
#include <l4/api/irq.h>
#include <l4/api/capability.h>
#include <l4/generic/cap-types.h>
#include <l4/api/space.h>
#include <malloc/malloc.h>
#include <container.h>
#include <linker.h>
#include <timer.h>
#include <libdev/timer.h>

/* Capabilities of this service */
static struct capability caparray[32];
static int total_caps = 0;

/* Total number of timer chips being handled by us */
#define TIMERS_TOTAL		1
static struct timer global_timer[TIMERS_TOTAL];

/* Deafult timer to be used for sleep/wake etc purposes */
#define SLEEP_WAKE_TIMER	0

/* tasks whose sleep time has finished */
struct wake_task_list wake_tasks;

/* tid of handle_request thread */
l4id_t tid_ipc_handler;

int cap_read_all()
{
	int ncaps;
	int err;

	/* Read number of capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_NCAPS,
					 0, &ncaps)) < 0) {
		printf("l4_capability_control() reading # of"
		       " capabilities failed.\n Could not "
		       "complete CAP_CONTROL_NCAPS request.\n");
		BUG();
	}
	total_caps = ncaps;

	/* Read all capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_READ,
					 0, caparray)) < 0) {
		printf("l4_capability_control() reading of "
		       "capabilities failed.\n Could not "
		       "complete CAP_CONTROL_READ_CAPS request.\n");
		BUG();
	}

	return 0;
}

int cap_share_all_with_space()
{
	int err;

	/* Share all capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_SHARE,
					 CAP_SHARE_ALL_SPACE, 0)) < 0) {
		printf("l4_capability_control() sharing of "
		       "capabilities failed.\n Could not "
		       "complete CAP_CONTROL_SHARE request. err=%d\n",
		       err);
		BUG();
	}

	return 0;
}

/*
 * Initialize timer devices
 */
void timer_struct_init(struct timer* timer, unsigned long base)
{
	timer->base = base;
	timer->count = 0;
	timer->slot = 0;
	l4_mutex_init(&timer->task_list_lock);

	for (int i = 0; i < BUCKET_BASE_LEVEL_SIZE ; ++i) {
		link_init(&timer->task_list.bucket_level0[i]);
	}

	for (int i = 0; i < BUCKET_HIGHER_LEVEL_SIZE ; ++i) {
		link_init(&timer->task_list.bucket_level1[i]);
		link_init(&timer->task_list.bucket_level2[i]);
		link_init(&timer->task_list.bucket_level3[i]);
		link_init(&timer->task_list.bucket_level4[i]);
	}
}

/*
 * Initialize wake list head structure
 */
void wake_task_list_init(void)
{
	link_init(&wake_tasks.head);
	wake_tasks.end = &wake_tasks.head;
	l4_mutex_init(&wake_tasks.wake_list_lock);
}

/*
 * Allocate new sleeper task struct
 */
struct sleeper_task *new_sleeper_task(l4id_t tid, int ret)
{
	struct sleeper_task *task;

	/* May be we can prepare a cache for timer_task structs */
	task = (struct sleeper_task *)kzalloc(sizeof(struct sleeper_task));

	link_init(&task->list);
	task->tid = tid;
	task->retval = ret;

	return task;
}

void free_sleeper_task(struct sleeper_task *task)
{
	kfree(task);
	task = NULL;
}

/*
 * Find the bucket list correspongding to seconds value
 */
struct link* find_bucket_list(unsigned long seconds)
{
	struct link *vector;
	struct sleeper_task_bucket *bucket;

	bucket = &global_timer[SLEEP_WAKE_TIMER].task_list;

	/*
	 * TODO: Check if we have already surpassed seconds
	 */
	if (IS_IN_LEVEL0_BUCKET(seconds)) {
		vector = &bucket->bucket_level0[GET_BUCKET_LEVEL0(seconds)];
	} else if (IS_IN_LEVEL1_BUCKET(seconds)) {
		vector = &bucket->bucket_level1[GET_BUCKET_LEVEL1(seconds)];
	} else if (IS_IN_LEVEL2_BUCKET(seconds)) {
		vector = &bucket->bucket_level2[GET_BUCKET_LEVEL2(seconds)];
	} else if (IS_IN_LEVEL3_BUCKET(seconds)) {
		vector = &bucket->bucket_level3[GET_BUCKET_LEVEL3(seconds)];
	} else {
		vector = &bucket->bucket_level4[GET_BUCKET_LEVEL4(seconds)];
	}

	return vector;
}

/*
 * Scans for up to TIMERS_TOTAL timer devices in capabilities.
 */
int timer_probe_devices(void)
{
	int timers = 0;

	/* Scan for timer devices */
	for (int i = 0; i < total_caps; i++) {
		/* Match device type */
		if (cap_devtype(&caparray[i]) == CAP_DEVTYPE_TIMER) {
			/* Copy to correct device index */
			memcpy(&global_timer[cap_devnum(&caparray[i]) - 1].cap,
			       &caparray[i], sizeof(global_timer[0].cap));
			timers++;
		}
	}

	if (timers != TIMERS_TOTAL) {
		printf("%s: Error, not all timers could be found. "
		       "timers=%d\n", __CONTAINER_NAME__, timers);
		return -ENODEV;
	}
	return 0;
}

/*
 * Irq handler for timer interrupts
 */
int timer_irq_handler(void *arg)
{
	int err;
	struct timer *timer = (struct timer *)arg;
	struct link *vector;
	const int slot = 0;

	/*
	  * Initialise timer
	  * 1 interrupt per second
	  */
	timer_init(timer->base, 1000000);

	/* Register self for timer irq, using notify slot 0 */
	if ((err = l4_irq_control(IRQ_CONTROL_REGISTER, slot,
				  timer->cap.irq)) < 0) {
		printf("%s: FATAL: Timer irq could not be registered. "
		       "err=%d\n", __FUNCTION__, err);
		BUG();
	}

	/* Enable Timer */
	timer_start(timer->base);

	/* Handle irqs forever */
	while (1) {
		int count;
		struct link *task_list;

		/* Block on irq */
		if((count = l4_irq_wait(slot, timer->cap.irq)) < 0) {
			printf("l4_irq_wait() returned with negative value\n");
			BUG();
		}

		/*
		  * Update timer count
		  * TODO: Overflow check, we have 1 interrupt/sec from timer
		  * with 32bit count it will take 9years to overflow
		  */
		timer->count += count;
		printf("Got timer irq, current count = 0x%x\n", timer->count);

		/* find bucket list of taks to be woken for current count */
		vector = find_bucket_list(timer->count);

		if (!list_empty(vector)) {
			/* Removing tasks from sleeper list */
			l4_mutex_lock(&global_timer[SLEEP_WAKE_TIMER].task_list_lock);
			task_list = list_detach(vector);
			l4_mutex_unlock(&global_timer[SLEEP_WAKE_TIMER].task_list_lock);

			/* Add tasks to wake_task_list */
			l4_mutex_lock(&wake_tasks.wake_list_lock);
			list_attach(task_list, &wake_tasks.head, wake_tasks.end);
			l4_mutex_unlock(&wake_tasks.wake_list_lock);

			/*
			 * Send ipc to handle_request
			 * thread to send wake signals
			 */
			l4_send(tid_ipc_handler,L4_IPC_TAG_TIMER_WAKE_THREADS);
		}
	}
}

/*
 * Helper routine to wake tasks from wake list
 */
void task_wake(void)
{
	struct sleeper_task *struct_ptr, *temp_ptr;
	int ret;

	if (!list_empty(&wake_tasks.head)) {
		list_foreach_removable_struct(struct_ptr, temp_ptr,
					      &wake_tasks.head, list) {
			/* Remove task from wake list */
			l4_mutex_lock(&wake_tasks.wake_list_lock);
			list_remove(&struct_ptr->list);
			l4_mutex_unlock(&wake_tasks.wake_list_lock);

			/* Set sender correctly */
			l4_set_sender(struct_ptr->tid);

			printf("%s : Waking thread 0x%x at time 0x%x\n", __CONTAINER_NAME__,
				    struct_ptr->tid, global_timer[SLEEP_WAKE_TIMER].count);

			/* send wake ipc */
			if ((ret = l4_ipc_return(struct_ptr->retval)) < 0) {
				printf("%s: IPC return error: %d.\n",
				       __FUNCTION__, ret);
				BUG();
			}

			/* free allocated sleeper task struct */
			free_sleeper_task(struct_ptr);
		}
	}
	/* If wake list is empty set end = start */
	if (list_empty(&wake_tasks.head))
		wake_tasks.end = &wake_tasks.head;

}

int timer_setup_devices(void)
{
	struct l4_thread thread;
	struct l4_thread *tptr = &thread;
	int err;

	for (int i = 0; i < TIMERS_TOTAL; i++) {
		/* initialize timer */
		timer_struct_init(&global_timer[i],(unsigned long)l4_new_virtual(1) );

		/* Map timer to a virtual address region */
		if (IS_ERR(l4_map((void *)__pfn_to_addr(global_timer[i].cap.start),
				  (void *)global_timer[i].base, global_timer[i].cap.size,
				  MAP_USR_IO,
				  self_tid()))) {
			printf("%s: FATAL: Failed to map TIMER device "
			       "%d to a virtual address\n",
			       __CONTAINER_NAME__,
			       cap_devnum(&global_timer[i].cap));
			BUG();
		}

		/*
		 * Create new timer irq handler thread.
		 *
		 * This will initialize its timer argument, register
		 * itself as its irq handler, initiate the timer and
		 * wait on irqs.
		 */
		if ((err = thread_create(timer_irq_handler, &global_timer[i],
					 TC_SHARE_SPACE,
					 &tptr)) < 0) {
			printf("FATAL: Creation of irq handler "
			       "thread failed.\n");
			BUG();
		}
	}

	return 0;
}

/*
 * Declare a statically allocated char buffer
 * with enough bitmap size to cover given size
 */
#define DECLARE_IDPOOL(name, size)      \
         char name[(sizeof(struct id_pool) + ((size >> 12) >> 3))]

#define PAGE_POOL_SIZE                  SZ_1MB
static struct address_pool device_vaddr_pool;
DECLARE_IDPOOL(device_id_pool, PAGE_POOL_SIZE);

/*
 * Initialize a virtual address pool
 * for mapping physical devices.
 */
void init_vaddr_pool(void)
{
	for (int i = 0; i < total_caps; i++) {
		/* Find the virtual memory region for this process */
		if (cap_type(&caparray[i]) == CAP_TYPE_MAP_VIRTMEM
		    && __pfn_to_addr(caparray[i].start) ==
		    (unsigned long)vma_start) {

			/*
			 * Do we have any unused virtual space
			 * where we run, and do we have enough
			 * pages of it to map all timers?
			 */
			if (__pfn(page_align_up(__end))
			    + TIMERS_TOTAL <= caparray[i].end) {
				/*
				 * Yes. We initialize the device
				 * virtual memory pool here.
				 *
				 * We may allocate virtual memory
				 * addresses from this pool.
				 */
				address_pool_init(&device_vaddr_pool,
						  (struct id_pool *)&device_id_pool,
						  page_align_up(__end),
						  __pfn_to_addr(caparray[i].end));
				return;
			} else
				goto out_err;
		}
	}

out_err:
	printf("%s: FATAL: No virtual memory "
	       "region available to map "
	       "devices.\n", __CONTAINER_NAME__);
	BUG();
}

void *l4_new_virtual(int npages)
{
	return address_new(&device_vaddr_pool, npages, PAGE_SIZE);
}

/*
 * Got request for sleep for seconds,
 * right now max sleep allowed is 2^32 sec
 */
void task_sleep(l4id_t tid, unsigned long seconds, int ret)
{
	struct sleeper_task *task = new_sleeper_task(tid, ret);
	struct link *vector;

	/* can overflow happen here?, timer is in 32bit mode */
	seconds += global_timer[SLEEP_WAKE_TIMER].count;

	printf("sleep wake timer lock is present at address %lx\n",
		    ( (unsigned long)&global_timer[SLEEP_WAKE_TIMER].task_list_lock.lock));

	vector = find_bucket_list(seconds);

	printf("Acquiring lock for sleep wake timer\n");
	l4_mutex_lock(&global_timer[SLEEP_WAKE_TIMER].task_list_lock);
	printf("got lock for sleep wake timer\n");

	list_insert(&task->list, vector);

	printf("Releasing lock for sleep wake timer\n");
	l4_mutex_unlock(&global_timer[SLEEP_WAKE_TIMER].task_list_lock);
	printf("released lock for sleep wake timer\n");

}

void handle_requests(void)
{
	u32 mr[MR_UNUSED_TOTAL];
	l4id_t senderid;
	u32 tag;
	int ret;

	if ((ret = l4_receive(L4_ANYTHREAD)) < 0) {
		printf("%s: %s: IPC Error: %d. Quitting...\n",
		       __CONTAINER__, __FUNCTION__, ret);
		BUG();
	}

	/* Syslib conventional ipc data which uses first few mrs. */
	tag = l4_get_tag();
	senderid = l4_get_sender();

	/* Read mrs not used by syslib */
	for (int i = 0; i < MR_UNUSED_TOTAL; i++)
		mr[i] = read_mr(MR_UNUSED_START + i);

	/*
	 * TODO:
	 *
	 * Maybe add tags here that handle requests for sharing
	 * of the requested timer device with the client?
	 *
	 * In order to be able to do that, we should have a
	 * shareable/grantable capability to the device. Also
	 * the request should (currently) come from a task
	 * inside the current container
	 */
	switch (tag) {
	/* Return time in seconds, since the timer was started */
	case L4_IPC_TAG_TIMER_GETTIME:
		printf("%s: Got get time request from thread 0x%x "
			    " at time = 0x%x\n", __CONTAINER_NAME__,
			    senderid, global_timer[SLEEP_WAKE_TIMER].count);

		write_mr(2, global_timer[SLEEP_WAKE_TIMER].count);

		/* Reply */
		if ((ret = l4_ipc_return(ret)) < 0) {
			printf("%s: IPC return error: %d.\n", __FUNCTION__, ret);
			BUG();
		}
		break;

	case L4_IPC_TAG_TIMER_SLEEP:
		printf("%s: Got sleep request from thread 0x%x "
			    "for 0x%x seconds at 0x%x seconds\n",
			    __CONTAINER_NAME__, senderid, mr[0],
			    global_timer[SLEEP_WAKE_TIMER].count);

		if (mr[0] > 0) {
			task_sleep(senderid, mr[0], ret);
		}
		else {
			if ((ret = l4_ipc_return(ret)) < 0) {
				printf("%s: IPC return error: %d.\n",
				       __FUNCTION__, ret);
				BUG();
			}
		}
		break;

	/* Intra container ipc by irq_thread */
	case L4_IPC_TAG_TIMER_WAKE_THREADS:
		task_wake();
		break;

	default:
		printf("%s: Error received ipc from 0x%x residing "
		       "in container %x with an unrecognized tag: "
		       "0x%x\n", __CONTAINER__, senderid,
		       __cid(senderid), tag);
	}
}

/*
 * UTCB-size aligned utcb.
 *
 * BIG WARNING NOTE: This declaration is legal if we are
 * running in a disjoint virtual address space, where the
 * utcb declaration lies in a unique virtual address in
 * the system.
 */
#define DECLARE_UTCB(name) \
	struct utcb name ALIGN(sizeof(struct utcb))

DECLARE_UTCB(utcb);

/* Set up own utcb for ipc */
int l4_utcb_setup(void *utcb_address)
{
	struct task_ids ids;
	struct exregs_data exregs;
	int err;

	l4_getid(&ids);

	/* Clear utcb */
	memset(utcb_address, 0, sizeof(struct utcb));

	/* Setup exregs for utcb request */
	memset(&exregs, 0, sizeof(exregs));
	exregs_set_utcb(&exregs, (unsigned long)utcb_address);

	if ((err = l4_exchange_registers(&exregs, ids.tid)) < 0)
		return err;

	return 0;
}

void main(void)
{
	int err;

	/* Read all capabilities */
	cap_read_all();

	/* Share all with space */
	cap_share_all_with_space();

	/* Scan for timer devices in capabilities */
	timer_probe_devices();

	/* Initialize virtual address pool for timers */
	init_vaddr_pool();

	/* Setup own static utcb */
	if ((err = l4_utcb_setup(&utcb)) < 0) {
		printf("FATAL: Could not set up own utcb. "
		       "err=%d\n", err);
		BUG();
	}

	/* initialise timed_out_task list */
	wake_task_list_init();

	/* Map and initialize timer devices */
	timer_setup_devices();

	/* Set the tid of ipc handler */
	tid_ipc_handler = self_tid();

	/* Listen for timer requests */
	while (1)
		handle_requests();
}

