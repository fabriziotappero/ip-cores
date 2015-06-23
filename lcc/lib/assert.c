#include <stdio.h>
#include <stdlib.h>
#ifndef EXPORT
#define EXPORT
#endif

static char rcsid[] = "$Id: assert.c,v 1.2 2001/06/07 22:30:08 drh Exp $";

EXPORT int _assert(char *e, char *file, int line) {
	fprintf(stderr, "assertion failed:");
	if (e)
		fprintf(stderr, " %s", e);
	if (file)
		fprintf(stderr, " file %s", file);
	fprintf(stderr, " line %d\n", line);
	fflush(stderr);
	abort();
	return 0;
}
