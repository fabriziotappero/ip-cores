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

#ifndef _HASH_H_
#define _HASH_H_

typedef unsigned long hash;

typedef hash (*hash_hash)(const void *key);
typedef hash (*hash_cmp)(const void *k1, const void *k2);

struct hash_bucket {
	void *key;
	void *value;
	hash hash;
} *h_bucket;


typedef struct {
	struct hash_bucket *h_bucket;
	hash_hash h_hash;
	hash_cmp h_cmp;
	unsigned long h_size, h_used;
	float h_threshold;
} hash_t;

hash_t *_hash_create(hash_cmp cmp, hash_hash hash, unsigned long size, float threshold);
void hash_destroy(hash_t *h, int freevalue);
int _hash_insert(hash_t *h, void *key, void *value);
int _hash_remove(hash_t *h, void *key, int freevalue);
void *_hash_lookup(hash_t *h, const void *key);

#define HASH_DECLARE(name, hcmp, hhash, keytype, valuetype) \
hash_t * name ## _create (hash size, float threshold) { return _hash_create((hash_cmp)hcmp, (hash_hash)hhash, size, threshold); } \
int name ## _insert (hash_t *h, keytype * key, valuetype * value) { return _hash_insert(h, key, value); } \
int name ## _remove (hash_t *h, keytype * key, int freevalue) { return _hash_remove(h, key, freevalue); } \
valuetype * name ## _lookup (hash_t *h, const keytype * key) { return _hash_lookup(h, key); }

#define HASH_DEFINE(name, hcmp, hhash, keytype, valuetype) \
hash_t * name ## _create (hash size, float threshold); \
int name ## _insert (hash_t *h, keytype * key, valuetype * value); \
int name ## _remove (hash_t *h, keytype * key, int freevalue); \
valuetype * name ## _lookup (hash_t *h, const keytype * key);

#endif /* _HASH_H_ */
