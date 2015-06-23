/*
 * Used for thread and space ids.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include "idpool.h"
#include <stdio.h>
#include <stdlib.h>

struct id_pool *id_pool_new_init(int totalbits)
{
	int nwords = BITWISE_GETWORD(totalbits);
	struct id_pool *new = calloc(1, (nwords * SZ_WORD)
				      + sizeof(struct id_pool));
	new->nwords = nwords;
	return new;
}

int id_new(struct id_pool *pool)
{
	int id = find_and_set_first_free_bit(pool->bitmap,
					     pool->nwords * WORD_BITS);
	if (id < 0)
		printf("%s: Warning! New id alloc failed\n", __FUNCTION__);
	return id;
}

/* This finds n contiguous free ids, allocates and returns the first one */
int ids_new_contiguous(struct id_pool *pool, int numids)
{
	printf("%s: Enter\n", __FUNCTION__);
	int id = find_and_set_first_free_contig_bits(pool->bitmap,
						     pool->nwords *WORD_BITS,
						     numids);
	if (id < 0)
		printf("%s: Warning! New id alloc failed\n", __FUNCTION__);
	return id;
}

/* This deletes a list of contiguous ids given the first one and number of ids */
int ids_del_contiguous(struct id_pool *pool, int first, int numids)
{
	int ret;
	printf("bits: %d, first +nids: %d\n", pool->nwords *WORD_BITS, first+numids);
	if (pool->nwords * WORD_BITS < first + numids)
		return -1;
	if ((ret = check_and_clear_contig_bits(pool->bitmap, first, numids)))
		printf("Warning!!!\n");
	return ret;
}

int id_del(struct id_pool *pool, int id)
{
	int ret;

	if (pool->nwords * WORD_BITS < id)
		return -1;

	if ((ret = check_and_clear_bit(pool->bitmap, id) < 0))
		printf("Warning!!!\n");
	return ret;
}

