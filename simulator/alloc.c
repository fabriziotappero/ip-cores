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
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <err.h>

void *
sstrdup(char *buf)
{
	void *p;

	p = strdup(buf);
	if (p == NULL)
		err(1, "sstrdup()");

	return p;
}

void *
smalloc(size_t s)
{
	void *p;

	p = malloc(s);
	if (p == NULL)
		err(1, "smalloc()");
	return p;
}

void *
scalloc(size_t num, size_t size)
{
	void *p;

	p = calloc(num, size);
	if (p == NULL)
		err(1, "scalloc()");
	return p;
}

void *
srealloc(void *ptr, size_t size)
{
	void *p;

	p = realloc(ptr, size);
	if (p == NULL)
		err(1, "srealloc()");
	return p;
}

int
sasprintf(char **strp, const char *fmt, ...)
{
	va_list ap;
	int i;

	va_start(ap, fmt);
	i = vasprintf(strp, fmt, ap);
	va_end(ap);

	if (i == -1)
		err(1, "sasprintf()");

	return i;
}
