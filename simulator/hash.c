/*
 * Copyright (c) 2007 Eirik A. Nygaard <eirikald@pvv.ntnu.no>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "hash.h"
#include "alloc.h"

static void hash_grow(hash_t *h);

hash_t *
_hash_create(hash_cmp cmp, hash_hash hash, unsigned long size, float threshold)
{
	hash_t *h;

	h = scalloc(sizeof(*h), 1);
	h->h_cmp = cmp;
	h->h_hash = hash;
	h->h_size = size;
	h->h_used = 0;
	h->h_bucket = scalloc(sizeof(*h->h_bucket), size);
	memset(h->h_bucket, '\0', sizeof(*h->h_bucket) * h->h_size);
	h->h_threshold = threshold;

	return h;
}


int
_hash_insert_do(hash_t *h, void *key, void *value, hash realhash)
{
	hash hash, i;

	hash = realhash % h->h_size;

	for (i = hash; h->h_bucket[i].key != NULL && !(h->h_cmp)(key,  h->h_bucket[i].key); i = (i + 1) % h->h_size)
		;

	if (h->h_bucket[i].key != NULL)
		free(h->h_bucket[i].key);
	h->h_bucket[i].key = key;
	h->h_bucket[i].value = value;
	h->h_bucket[i].hash = realhash;
	h->h_used++;

	return 1;
}

static void
hash_grow(hash_t *h)
{
	struct hash_bucket *old;
	hash oldsize, i;

	//printf("Growing, %lu -> %lu\n", h->h_size, h->h_size*2);

	oldsize = h->h_size;
	h->h_size *= 2;
	old = h->h_bucket;
	h->h_bucket = scalloc(sizeof(*h->h_bucket), h->h_size);
	memset(h->h_bucket, '\0', sizeof(*h->h_bucket) * h->h_size);

	h->h_used = 0;
	for (i = 0; i < oldsize; i++) {
		if (old[i].key != NULL)
			_hash_insert_do(h, old[i].key, old[i].value, old[i].hash);
	}
}

int
_hash_insert(hash_t *h, void *key, void *value)
{
	hash realhash;

	if (((float)h->h_used / (float)h->h_size) > h->h_threshold)
		hash_grow(h);

	realhash = (h->h_hash)(key);

	return _hash_insert_do(h, key, value, realhash);
}

int
_hash_remove(hash_t *h, void *key, int freevalue)
{
	hash hash, i, itr;

	hash = (h->h_hash)(key) % h->h_size;

	for (i = hash, itr = 0; itr < h->h_size && !(h->h_cmp)(h->h_bucket[i].key, key); i = (i + 1) % h->h_size, itr++)
		;

	if (itr == h->h_size)
		return 0;
	
	if (freevalue)
		free(h->h_bucket[i].value);
	free(h->h_bucket[i].key);
	h->h_bucket[i].key = NULL;

	return 1;
}

void *
_hash_lookup(hash_t *h, const void *key)
{
	hash hash, i, itr;

	hash = (h->h_hash)(key) % h->h_size;
	for (i = hash, itr = 0; itr < h->h_size && h->h_bucket[i].key != NULL
	    && !(h->h_cmp)(h->h_bucket[i].key, key);
	    i = (i + 1) % h->h_size, itr++)
		;
	
	if (itr == h->h_size ||
	    h->h_bucket[i].key == NULL)
		return NULL;
	return h->h_bucket[i].value;
}

void
hash_destroy(hash_t *h, int freevalue)
{
	hash i;

	for(i = 0; i < h->h_size; i++) {
		if (h->h_bucket[i].key == NULL)
			continue;
		if (freevalue)
			free(h->h_bucket[i].value);
		free(h->h_bucket[i].key);
	}
	free(h->h_bucket);
	free(h);
}
