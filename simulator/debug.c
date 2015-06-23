#define _GNU_SOURCE
#include <sys/types.h>

#include <assert.h>
#include <stdio.h>
#include <err.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#include "debug.h"
#include "hash.h"
#include "linkedlist.h"
#include "alloc.h"

hash
uint_hash(unsigned int *_key)
{
	hash key = *_key;

	key = ~key + (key << 15); // key = (key << 15) - key - 1;
	key = key ^ (key >> 12);
	key = key + (key << 2);
	key = key ^ (key >> 4);
	key = key * 2057; // key = (key + (key << 3)) + (key << 11);
	key = key ^ (key >> 16);

	return key;
}

hash
uint_cmp(unsigned int *k1, unsigned int *k2)
{
	return (*k1 == *k2);
}


HASH_DEFINE(hash_debuginfo, uint_cmp, uint_hash, unsigned int, void);
HASH_DECLARE(hash_debuginfo, uint_cmp, uint_hash, unsigned int, void);


static void
add_constant(char *group, char *name, unsigned int number)
{
	llist_t list;
	struct di_const *c;

	list = hash_debuginfo_lookup(debuginfo->constants, &number);
	if (list == NULL) {
		unsigned int *key = smalloc(sizeof(*key));

		*key = number;
		list = llist_make();

		hash_debuginfo_insert(debuginfo->constants, key, list);
	}
	c = smalloc(sizeof(*c));
	c->group = sstrdup(group);
	c->name = sstrdup(name);
	llist_add_tail(list, c);
}

int
debug_init(const char *path)
{
	char constfile[2048];
	char *line, group[1024], name[1024];
	unsigned int number;
	char *p, *p2;
	size_t n;
	FILE *fp;

	debuginfo = malloc(sizeof(*debuginfo));
	if (debuginfo == NULL)
		return 0;
	debuginfo->constants = hash_debuginfo_create(128, 0.50);

	snprintf(constfile, sizeof(constfile), "%s.const", path);

	fp = fopen(constfile, "r");
	if (fp == NULL) {
		debuginfo = NULL;
		return 0;
	}

	// Load constant information from file
	line = NULL;
	while (getline(&line, &n, fp) > 0) {
		line[strlen(line)-1] = '\0';
		p = strchr(line, ' ');
		*p = '\0';
		strncpy(group, line, sizeof(group));
		p++;
		p2 = strchr(p, ' ');
		*p2 = '\0';
		strncpy(name, p, sizeof(name));
		p2++;
		number = strtol(p2, NULL, 16); 
		free(line);

		add_constant(group, name, number);
		line = NULL;
	}

	fclose(fp);

	return 1;
}

void
debug_show(unsigned int x)
{
	debug_show_filter(x, NULL);
}

void
debug_show_filter(unsigned int x, const char *filter)
{
	llist_t l;
	llist_node_t node;

	if (debuginfo == NULL) {
		// No debuginfo loaded
		return;
	}

	l = hash_debuginfo_lookup(debuginfo->constants, &x);
	if (l == NULL) {
		printf("no debuginfo for: %x\n", x);
	} else {
		struct di_const *c;

		LLIST_FOREACH(l, node) {
			c = llist_getobj(node);
			if (filter == NULL || strcmp(filter, c->group) == 0)
				printf("> %s %s %x\n", c->group, c->name, x);
		}
	}
}

struct di_const *
debug_get1(unsigned int x)
{
	return debug_get1_filter(x, NULL);
}

struct di_const *
debug_get1_filter(unsigned int x, const char *filter)
{
	llist_t l;
	llist_node_t node;

	if (debuginfo == NULL) {
		// No debuginfo loaded
		return NULL;
	}

	l = hash_debuginfo_lookup(debuginfo->constants, &x);
	if (l == NULL) {
		return NULL;
	} else {
		struct di_const *c;

		LLIST_FOREACH(l, node) {
			c = llist_getobj(node);
			if (filter == NULL || strcmp(filter, c->group) == 0)
				return c;
		}
	}

	return NULL;
}

unsigned int
debug_get_key(const char *name, const char *group)
{
	hash i;
	struct hash_bucket *b;
	struct di_const *c;
	llist_node_t node;
	llist_t l;

	for (i = 0; i < debuginfo->constants->h_size; i++) {
		b = &debuginfo->constants->h_bucket[i];
		if (b->key == NULL)
			continue;
		l = b->value;

		LLIST_FOREACH(l, node) {
			c = llist_getobj(node);
			if (strcasecmp(c->name, name) == 0 &&
			    strcasecmp(c->group, group) == 0)
				return *((unsigned int*)b->key);
		}
	}

	return 0xdeadbeef;
}
