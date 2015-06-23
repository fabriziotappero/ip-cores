/*****************************************************************************
Simple malloc
Chris Giese <geezer@execpc.com>	http://www.execpc.com/~geezer
Release date: Oct 30, 2002
This code is public domain (no copyright).
You can do whatever you want with it.

Features:
- First-fit
- free() coalesces adjacent free blocks
- Uses variable-sized heap, enlarged with kbrk()/sbrk() function
- Does not use mmap()
- Can be easily modified to use fixed-size heap
- Works with 16- or 32-bit compilers

Build this program with either of the two main() functions, then run it.
Messages that indicate a software error will contain three asterisks (***).
*****************************************************************************/
#include <string.h> /* memcpy(), memset() */
#include <stdio.h> /* printf() */
#include <l4/macros.h>
#define	_32BIT	1

/* use small (32K) heap for 16-bit compilers,
large (500K) heap for 32-bit compilers */
#if defined(_32BIT)
#define	HEAP_SIZE	500000uL
#else
#define	HEAP_SIZE	32768u
#endif

#define	MALLOC_MAGIC	0x6D92	/* must be < 0x8000 */

typedef struct _malloc		/* Turbo C	DJGPP */
{
	size_t size;		/* 2 bytes	 4 bytes */
	struct _malloc *next;	/* 2 bytes	 4 bytes */
	unsigned magic : 15;	/* 2 bytes total 4 bytes total */
	unsigned used : 1;
} malloc_t;		/* total   6 bytes	12 bytes */

static char *g_heap_bot, *g_kbrk, *g_heap_top;
/*****************************************************************************
*****************************************************************************/
void dump_heap(void)
{
	unsigned blks_used = 0, blks_free = 0;
	size_t bytes_used = 0, bytes_free = 0;
	malloc_t *m;
	int total;

	printf("===============================================\n");
	for(m = (malloc_t *)g_heap_bot; m != NULL; m = m->next)
	{
		printf("blk %5p: %6u bytes %s\n", m,
			m->size, m->used ? "used" : "free");
		if(m->used)
		{
			blks_used++;
			bytes_used += m->size;
		}
		else
		{
			blks_free++;
			bytes_free += m->size;
		}
	}
	printf("blks:  %6u used, %6u free, %6u total\n", blks_used,
		blks_free, blks_used + blks_free);
	printf("bytes: %6u used, %6u free, %6u total\n", bytes_used,
		bytes_free, bytes_used + bytes_free);
	printf("g_heap_bot=0x%p, g_kbrk=0x%p, g_heap_top=0x%p\n",
		g_heap_bot, g_kbrk, g_heap_top);
	total = (bytes_used + bytes_free) +
			(blks_used + blks_free) * sizeof(malloc_t);
	if(total != g_kbrk - g_heap_bot)
		printf("*** some heap memory is not accounted for\n");
	printf("===============================================\n");
}
/*****************************************************************************
POSIX sbrk() looks like this
	void *sbrk(int incr);
Mine is a bit different so I can signal the calling function
if more memory than desired was allocated (e.g. in a system with paging)
If your kbrk()/sbrk() always allocates the amount of memory you ask for,
this code can be easily changed.

			int brk(	void *sbrk(		void *kbrk(
function		 void *adr);	 int delta);		 int *delta);
----------------------	------------	------------		-------------
POSIX?			yes		yes			NO
return value if error	-1		-1			NULL
get break value		.		sbrk(0)			int x=0; kbrk(&x);
set break value to X	brk(X)		sbrk(X - sbrk(0))	int x=X, y=0; kbrk(&x) - kbrk(&y);
enlarge heap by N bytes	.		sbrk(+N)		int x=N; kbrk(&x);
shrink heap by N bytes	.		sbrk(-N)		int x=-N; kbrk(&x);
can you tell if you're
  given more memory
  than you wanted?	no		no			yes
*****************************************************************************/
static void *kbrk(int *delta)
{
	static char heap[HEAP_SIZE];
/**/
	char *new_brk, *old_brk;

/* heap doesn't exist yet */
	if(g_heap_bot == NULL)
	{
		g_heap_bot = g_kbrk = heap;
		g_heap_top = g_heap_bot + HEAP_SIZE;
	}
	new_brk = g_kbrk + (*delta);
/* too low: return NULL */
	if(new_brk < g_heap_bot)
		return NULL;
/* too high: return NULL */
	if(new_brk >= g_heap_top)
		return NULL;
/* success: adjust brk value... */
	old_brk = g_kbrk;
	g_kbrk = new_brk;
/* ...return actual delta... (for this sbrk(), they are the same)
	(*delta) = (*delta); */
/* ...return old brk value */
	return old_brk;
}
/*****************************************************************************
kmalloc() and kfree() use g_heap_bot, but not g_kbrk nor g_heap_top
*****************************************************************************/
void *kmalloc(size_t size)
{
	unsigned total_size;
	malloc_t *m, *n;
	int delta;

	if(size == 0)
		return NULL;
	total_size = size + sizeof(malloc_t);
/* search heap for free block (FIRST FIT) */
	m = (malloc_t *)g_heap_bot;
/* g_heap_bot == 0 == NULL if heap does not yet exist */
	if(m != NULL)
	{
		if(m->magic != MALLOC_MAGIC)
//			panic("kernel heap is corrupt in kmalloc()");
		{
			printf("*** kernel heap is corrupt in kmalloc()\n");
			return NULL;
		}
		for(; m->next != NULL; m = m->next)
		{
			if(m->used)
				continue;
/* size == m->size is a perfect fit */
			if(size == m->size)
				m->used = 1;
			else
			{
/* otherwise, we need an extra sizeof(malloc_t) bytes for the header
of a second, free block */
				if(total_size > m->size)
					continue;
/* create a new, smaller free block after this one */
				n = (malloc_t *)((char *)m + total_size);
				n->size = m->size - total_size;
				n->next = m->next;
				n->magic = MALLOC_MAGIC;
				n->used = 0;
/* reduce the size of this block and mark it used */
				m->size = size;
				m->next = n;
				m->used = 1;
			}
			return (char *)m + sizeof(malloc_t);
		}
	}
/* use kbrk() to enlarge (or create!) heap */
	delta = total_size;
	n = kbrk(&delta);
/* uh-oh */
	if(n == NULL)
		return NULL;
	if(m != NULL)
		m->next = n;
	n->size = size;
	n->magic = MALLOC_MAGIC;
	n->used = 1;
/* did kbrk() return the exact amount of memory we wanted?
cast to make "gcc -Wall -W ..." shut the hell up */
	if((int)total_size == delta)
		n->next = NULL;
	else
	{
/* it returned more than we wanted (it will never return less):
create a new, free block */
		m = (malloc_t *)((char *)n + total_size);
		m->size = delta - total_size - sizeof(malloc_t);
		m->next = NULL;
		m->magic = MALLOC_MAGIC;
		m->used = 0;

		n->next = m;
	}
	return (char *)n + sizeof(malloc_t);
}

/*****************************************************************************
*****************************************************************************/
void kfree(void *blk)
{
	malloc_t *m, *n;

/* get address of header */
	m = (malloc_t *)((char *)blk - sizeof(malloc_t));
	if(m->magic != MALLOC_MAGIC)
//		panic("attempt to kfree() block at 0x%p "
//			"with bad magic value", blk);
	{
		printf("*** attempt to kfree() block at 0x%p "
			"with bad magic value\n", blk);
		BUG();
		return;
	}
/* find this block in the heap */
	n = (malloc_t *)g_heap_bot;
	if(n->magic != MALLOC_MAGIC)
//		panic("kernel heap is corrupt in kfree()");
	{
		printf("*** kernel heap is corrupt in kfree()\n");
		return;
	}
	for(; n != NULL; n = n->next)
	{
		if(n == m)
			break;
	}
/* not found? bad pointer or no heap or something else? */
	if(n == NULL)
//		panic("attempt to kfree() block at 0x%p "
//			"that is not in the heap", blk);
	{
		printf("*** attempt to kfree() block at 0x%p "
			"that is not in the heap\n", blk);
		return;
	}
/* free the block */
	m->used = 0;
/* BB: Addition: put 0xFF to block memory so we know if we use freed memory */
	memset(blk, 0xFF, m->size);

/* coalesce adjacent free blocks
Hard to spell, hard to do */
	for(m = (malloc_t *)g_heap_bot; m != NULL; m = m->next)
	{
		while(!m->used && m->next != NULL && !m->next->used)
		{
/* resize this block */
			m->size += sizeof(malloc_t) + m->next->size;
/* merge with next block */
			m->next = m->next->next;
		}
	}
}
/*****************************************************************************
*****************************************************************************/
void *krealloc(void *blk, size_t size)
{
	void *new_blk;
	malloc_t *m;

/* size == 0: free block */
	if(size == 0)
	{
		if(blk != NULL)
			kfree(blk);
		new_blk = NULL;
	}
	else
	{
/* allocate new block */
		new_blk = kmalloc(size);
/* if allocation OK, and if old block exists, copy old block to new */
		if(new_blk != NULL && blk != NULL)
		{
			m = (malloc_t *)((char *)blk - sizeof(malloc_t));
			if(m->magic != MALLOC_MAGIC)
//				panic("attempt to krealloc() block at "
//					"0x%p with bad magic value", blk);
			{
				printf("*** attempt to krealloc() block at "
					"0x%p with bad magic value\n", blk);
				return NULL;
			}
/* copy minimum of old and new block sizes */
			if(size > m->size)
				size = m->size;
			memcpy(new_blk, blk, size);
/* free the old block */
			kfree(blk);
		}
	}
	return new_blk;
}
/*****************************************************************************
*****************************************************************************/

#if 0

#include <stdlib.h> /* rand() */


#define	SLOTS	17

int main(void)
{
	unsigned lifetime[SLOTS];
	void *blk[SLOTS];
	int i, j, k;

	dump_heap();
	memset(lifetime, 0, sizeof(lifetime));
	memset(blk, 0, sizeof(blk));
	for(i = 0; i < 1000; i++)
	{
		printf("Pass %6u\n", i);
		for(j = 0; j < SLOTS; j++)
		{
/* age the block */
			if(lifetime[j] != 0)
			{
				(lifetime[j])--;
				continue;
			}
/* too old; free it */
			if(blk[j] != NULL)
			{
				kfree(blk[j]);
				blk[j] = NULL;
			}
/* alloc new block of random size
Note that size_t==unsigned, but kmalloc() uses integer math,
so block size must be positive integer */
#if defined(_32BIT)
			k = rand() % 40960 + 1;
#else
			k = rand() % 4096 + 1;
#endif
			blk[j] = kmalloc(k);
			if(blk[j] == NULL)
				printf("failed to alloc %u bytes\n", k);
			else
/* give it a random lifetime 0-20 */
				lifetime[j] = rand() % 21;
		}
	}
/* let's see what we've wrought */
	printf("\n\n");
	dump_heap();
/* free everything */
	for(j = 0; j < SLOTS; j++)
	{
		if(blk[j] != NULL)
		{
			kfree(blk[j]);
			blk[j] = NULL;
		}
		(lifetime[j]) = 0;
	}
/* after all that, we should have a single, unused block */
	dump_heap();
	return 0;
}
/*****************************************************************************
*****************************************************************************/

int main(void)
{
	void *b1, *b2, *b3;

	dump_heap();

	b1 = kmalloc(42);
	dump_heap();

	b2 = kmalloc(23);
	dump_heap();

	b3 = kmalloc(7);
	dump_heap();

	b2 = krealloc(b2, 24);
	dump_heap();

	kfree(b1);
	dump_heap();

	b1 = kmalloc(5);
	dump_heap();

	kfree(b2);
	dump_heap();

	kfree(b3);
	dump_heap();

	kfree(b1);
	dump_heap();

	return 0;
}
#endif

