
#include <l4lib/mutex.h>
#include <l4lib/lib/thread.h>
#include <memcache/memcache.h>

/*
 * Static stack and utcb for same-space threads.
 * +1 is a good approximation for allocating for bitmap
 * structures in the memcache.
 */
static char stack[THREADS_TOTAL * (STACK_SIZE + 1)] ALIGN(STACK_SIZE);
static char utcb[THREADS_TOTAL * (UTCB_SIZE + 1)] ALIGN(UTCB_SIZE);

struct mem_cache *utcb_cache;
struct mem_cache *stack_cache;

struct l4_thread_list l4_thread_list;

/* Number of thread structs + allowance for memcache internal data */
#define L4_THREAD_LIST_BUFFER_SIZE (THREADS_TOTAL * \
				    (sizeof(struct l4_thread_list)) + 256)

static char l4_thread_list_buf[L4_THREAD_LIST_BUFFER_SIZE];

void l4_thread_list_init(void)
{
	struct l4_thread_list *tlist = &l4_thread_list;

	/* Initialize the head struct */
	memset(tlist, 0, sizeof (*tlist));
	link_init(&tlist->thread_list);
	l4_mutex_init(&tlist->lock);

	/* Initialize a cache of l4_thread_list structs */
	if (!(tlist->thread_cache =
	      mem_cache_init(&l4_thread_list_buf,
			     L4_THREAD_LIST_BUFFER_SIZE,
			     sizeof(struct l4_thread), 0))) {
		printf("FATAL: Could not initialize internal "
		       "thread struct cache.\n");
		BUG();
	}
}

void l4_stack_alloc_init(void)
{
	BUG_ON(!(stack_cache =
		 mem_cache_init((void *)stack, STACK_SIZE *
			 	(THREADS_TOTAL + 1),
				STACK_SIZE, STACK_SIZE)));
}

/*
 * Initialize a memcache that is aligned to utcb size
 */
void l4_utcb_alloc_init(void)
{
	BUG_ON(!(utcb_cache =
		 mem_cache_init((void *)utcb, UTCB_SIZE *
			 	(THREADS_TOTAL + 1),
				UTCB_SIZE, UTCB_SIZE)));
}

void __l4_threadlib_init(void)
{
	l4_utcb_alloc_init();
	l4_stack_alloc_init();
	l4_thread_list_init();
	l4_parent_thread_init();
}

