#ifndef DEBUG_H_
#define DEBUG_H_

#include "hash.h"

struct di_const {
	char *group, *name;
};

struct debuginfo {
	hash_t *constants;
} *debuginfo;

int debug_init(const char *);
void debug_show(unsigned int);
void debug_show_filter(unsigned int, const char *);
struct di_const *debug_get1(unsigned int);
struct di_const *debug_get1_filter(unsigned int, const char *);
unsigned int debug_get_key(const char *, const char *);

#endif /* DEBUG_H_ */
