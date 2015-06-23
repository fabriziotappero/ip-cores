/*
 * Australian Public Licence B (OZPLB)
 * 
 * Version 1-0
 * 
 * Copyright (c) 2004 National ICT Australia
 * 
 * All rights reserved. 
 * 
 * Developed by: Embedded, Real-time and Operating Systems Program (ERTOS)
 *               National ICT Australia
 *               http://www.ertos.nicta.com.au
 * 
 * Permission is granted by National ICT Australia, free of charge, to
 * any person obtaining a copy of this software and any associated
 * documentation files (the "Software") to deal with the Software without
 * restriction, including (without limitation) the rights to use, copy,
 * modify, adapt, merge, publish, distribute, communicate to the public,
 * sublicense, and/or sell, lend or rent out copies of the Software, and
 * to permit persons to whom the Software is furnished to do so, subject
 * to the following conditions:
 * 
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimers.
 * 
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimers in the documentation and/or other materials provided
 *       with the distribution.
 * 
 *     * Neither the name of National ICT Australia, nor the names of its
 *       contributors, may be used to endorse or promote products derived
 *       from this Software without specific prior written permission.
 * 
 * EXCEPT AS EXPRESSLY STATED IN THIS LICENCE AND TO THE FULL EXTENT
 * PERMITTED BY APPLICABLE LAW, THE SOFTWARE IS PROVIDED "AS-IS", AND
 * NATIONAL ICT AUSTRALIA AND ITS CONTRIBUTORS MAKE NO REPRESENTATIONS,
 * WARRANTIES OR CONDITIONS OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
 * BUT NOT LIMITED TO ANY REPRESENTATIONS, WARRANTIES OR CONDITIONS
 * REGARDING THE CONTENTS OR ACCURACY OF THE SOFTWARE, OR OF TITLE,
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NONINFRINGEMENT,
 * THE ABSENCE OF LATENT OR OTHER DEFECTS, OR THE PRESENCE OR ABSENCE OF
 * ERRORS, WHETHER OR NOT DISCOVERABLE.
 * 
 * TO THE FULL EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT SHALL
 * NATIONAL ICT AUSTRALIA OR ITS CONTRIBUTORS BE LIABLE ON ANY LEGAL
 * THEORY (INCLUDING, WITHOUT LIMITATION, IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHERWISE) FOR ANY CLAIM, LOSS, DAMAGES OR OTHER
 * LIABILITY, INCLUDING (WITHOUT LIMITATION) LOSS OF PRODUCTION OR
 * OPERATION TIME, LOSS, DAMAGE OR CORRUPTION OF DATA OR RECORDS; OR LOSS
 * OF ANTICIPATED SAVINGS, OPPORTUNITY, REVENUE, PROFIT OR GOODWILL, OR
 * OTHER ECONOMIC LOSS; OR ANY SPECIAL, INCIDENTAL, INDIRECT,
 * CONSEQUENTIAL, PUNITIVE OR EXEMPLARY DAMAGES, ARISING OUT OF OR IN
 * CONNECTION WITH THIS LICENCE, THE SOFTWARE OR THE USE OF OR OTHER
 * DEALINGS WITH THE SOFTWARE, EVEN IF NATIONAL ICT AUSTRALIA OR ITS
 * CONTRIBUTORS HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH CLAIM, LOSS,
 * DAMAGES OR OTHER LIABILITY.
 * 
 * If applicable legislation implies representations, warranties, or
 * conditions, or imposes obligations or liability on National ICT
 * Australia or one of its contributors in respect of the Software that
 * cannot be wholly or partly excluded, restricted or modified, the
 * liability of National ICT Australia or the contributor is limited, to
 * the full extent permitted by the applicable legislation, at its
 * option, to:
 * a.  in the case of goods, any one or more of the following:
 * i.  the replacement of the goods or the supply of equivalent goods;
 * ii.  the repair of the goods;
 * iii. the payment of the cost of replacing the goods or of acquiring
 *  equivalent goods;
 * iv.  the payment of the cost of having the goods repaired; or
 * b.  in the case of services:
 * i.  the supplying of the services again; or
 * ii.  the payment of the cost of having the services supplied again.
 * 
 * The construction, validity and performance of this licence is governed
 * by the laws in force in New South Wales, Australia.
 */

#ifndef	_STDLIB_H_
#define	_STDLIB_H_

#include <stdint.h>
#include <stddef.h>

/* ISOC99 7.20 General Utilities */

/* 7.20.2 div types */
typedef struct {
	int quot, rem;
} div_t;

typedef struct {
	long quot, rem;
} ldiv_t;

typedef struct {
	long long quot, rem;
} lldiv_t;


/* 7.20.3 EXIT_ macros */  
#define	EXIT_FAILURE	1
#define	EXIT_SUCCESS	0

#define	RAND_MAX	INT_MAX
#define MB_CUR_MAX      1

/* 7.20.1 Numeric conversion functions */

/* 7.20.1-3 The strtod, strtof and strtold functions */
double strtod(const char *s, char **endp);
float strtof(const char *s, char **endp);
long double strtold(const char *s, char **endp);

/* 7.20.1-4 The strtol, stroll, stroul, strtoull functions */
long strtol(const char *s, char **endp, int base);
long long strtoll(const char *s, char **endp, int base);
unsigned long strtoul(const char *s, char **endp, int base);
unsigned long long strtoull(const char *s, char **endp, int base);

/* 7.20.1-1 atof function */
static inline double atof(const char *nptr)
{
	return strtod(nptr, (char **)NULL);
}

/* 7.20.1-2 The atoi, atol and atoll functions */
static inline int atoi(const char *nptr)
{
	return (int) strtol(nptr, (char **)NULL, 10);
}

static inline long atol(const char *nptr)
{
	return strtol(nptr, (char **)NULL, 10);
}

static inline long long atoll(const char *nptr)
{
	return strtoll(nptr, (char **)NULL, 10);
}

/* 7.20.2 Pseudo-random sequence generation functions */

int rand(void);
void srand(unsigned int seed);

/* 7.20.3 Memory management functions */

void *malloc(size_t);
void free(void *);
void *calloc(size_t, size_t);
void *realloc(void *, size_t);

/* 7.20.4 Communcation with the environment */

void abort(void);
int atexit(void (*func)(void));
void exit(int status);
void _Exit(int status);
char *getenv(const char *name);
int system(const char *string);

/* 7.20.5 Searching and sortin utilities */
void *bsearch(const void *key, const void *base, size_t nmemb, size_t, int (*compar)(const void *, const void*));
void qsort(void *base, size_t nmemb, size_t, int (*compar)(const void *, const void*));

/* 7.20.6 Integer arithmetic function */

/* FIXME: (benjl) Gcc defines these, but if we aren't using gcc it probably
   won't, but how do we know? Or maybe we should compile with -fnobuiltin? */

int abs(int);
long labs(long);
long long llabs(long long);

#if 0
static inline int
abs(int x)
{
	return x < 0 ? -x : x;
}

static inline long
labs(long x)
{
	return x < 0 ? -x : x;
}

static inline long long
llabs(long long x)
{
	return x < 0 ? -x : x;
}
#endif
/* 7.20.7 Multibyte/wide character conversion functions */
#if 0 /* We don't have wide characters */
int mblen(const char *s, size_t n);
int mbtowc(wchar_t pwc, const char *s, size_t n);
int wctomb(char *s, wchat_t wc);
#endif

/* 7.20.8 Multibyte/wide string conversion functions */
#if 0 /* We don't have wide characters */
size_t mbstowcs(wchar_t *pwcs, const char *s, size_t n);
size_t wcstombs(char *s, constwchat_t *pwcs, size_t n);
#endif

#endif				/* _STDLIB_H_ */
