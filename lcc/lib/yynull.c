#include <stdio.h>
#include <stdlib.h>
#ifndef EXPORT
#define EXPORT
#endif

static char rcsid[] = "$Id: yynull.c,v 1.3 2001/06/07 22:30:09 drh Exp $";

EXPORT void _YYnull(char *file, int line) {
	fprintf(stderr, "null pointer dereferenced:");
	if (file)
		fprintf(stderr, " file %s,", file);
	fprintf(stderr, " line %d\n", line);
	fflush(stderr);
	abort();
}
