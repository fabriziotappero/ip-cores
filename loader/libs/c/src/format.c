/*
 * Australian Public Licence B (OZPLB)
 * 
 * Version 1-0
 * 
 * Copyright (c) 2004 University of New South Wales
 * 
 * All rights reserved. 
 * 
 * Developed by: Operating Systems and Distributed Systems Group (DiSy)
 *               University of New South Wales
 *               http://www.disy.cse.unsw.edu.au
 * 
 * Permission is granted by University of New South Wales, free of charge, to
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
 *     * Neither the name of University of New South Wales, nor the names of its
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
 * conditions, or imposes obligations or liability on University of New South
 * Wales or one of its contributors in respect of the Software that
 * cannot be wholly or partly excluded, restricted or modified, the
 * liability of University of New South Wales or the contributor is limited, to
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
/*
  Authors: Cristan Szmadja, Ben Leslie
*/
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include "format.h"
/*
 * lookup tables for umaxtostr 
 */
static const char xdigits[16] = "0123456789abcdef";
static const char Xdigits[16] = "0123456789ABCDEF";

/*
 * Convert an unsigned integer to a string of digits in the specified base. 
 * Buf should point to the END of the buffer: 22 characters is probably big
 * enough.  NO '\0' is appended to buf. 
 * 
 * If u == 0, NO digits are generated.  The '0' is supplied by vfprintf using
 * its default zero padding, except in certain rare situations (e.g., "%.0d"). 
 */
static inline char *
umaxtostr(char *buf, uintmax_t u, int base, const char *digits)
{
	unsigned long u2;

	/*
	 * generate the digits in reverse order 
	 */
#if UINTMAX_MAX > ULONG_MAX
	/*
	 * Uintmax_t arithmetic may be very slow.  Use it only until the
	 * residual fits in an unsigned long. 
	 */
	while (u > ULONG_MAX) {
		*--buf = digits[u % base];
		u /= base;
	}
#endif
	for (u2 = u; u2 != 0UL;) {
		*--buf = digits[u2 % base];
		u2 /= base;
	}
	return buf;
}


/*
This macro is *really* nasty.

It isn't an inline function because it relies on variables declared in the
surrounding scope. Specifically:
  stream_or_memory   -> Indicates if we are going to a file, or memory
  r                  -> The output counter
  n                  -> max size
  output             -> output buffer (if going to memory)
  stream             -> output stream (if going to file)
*/

#define WRITE_CHAR(x) {	          \
 if (n != -1 && r == n) {         \
	*output++ = '\0';	  \
	overflowed = 1;		  \
 }                                \
 if (stream_or_memory) {          \
	fputc(x, stream);         \
 } else if (! overflowed) {       \
	*output++ = x;	          \
 }                                \
 r++;                             \
}		                  \




/*
 * Print one formatted field.  The length of s is len; any '\0's in s are
 * IGNORED.  The field may have an optional prefix ('+', ' ', '-', '0x', or
 * '0X', packed into an unsigned int), and is padded appropriately to the
 * specified width.  If width < 0, the field is left-justified. 
 */
static inline int
fprintf1(char *output, FILE *stream, bool stream_or_memory, size_t r, size_t n,
	 const char *s, int len, unsigned int prefix,
	 int prefixlen, int width, int prec, bool *over)
{
	size_t i;
	size_t y = r;            /* Keep a copy the starting value */
	bool overflowed = *over; /* Current start of overflow flag */

	if (stream != NULL)
		lock_stream(stream);
	if (width - prec - prefixlen > 0) {
		for (i = 0; i < width - prec - prefixlen; i++) {
			WRITE_CHAR(' ');  /* left-padding (if any) */
		}
	}

	for (; prefix != 0; prefix >>= 8) {
		WRITE_CHAR(prefix & 0377); /* prefix string */
	}

	for (i = 0; i < prec - len; i++) {
		WRITE_CHAR('0');  /* zero-padding (if any) */
	}

	for (i = 0; i < len; i++) {
		WRITE_CHAR(s[i]); /* actual string */
	}

	if (width < 0) {
		while(y < -width) {
			WRITE_CHAR(' '); /* right-padding (if any) */
		}
	}

	*over = overflowed; /* Set overflow flag in the caller */

	if (stream != NULL)
		unlock_stream(stream);
	return r - y;      /* We return the number of chars added */
}

#include <assert.h>
/*
 * parse printf format string 
 * if stream_or_memory == 1 -> use fputc, otherwise write to memory
 * if n == -1, then don't check overflow
 */
int
format_string(char *output, FILE *stream, bool stream_or_memory, size_t n, 
	      const char *fmt, va_list ap)
{
	bool alt, ljust, point, zeropad, overflowed = 0; 
	int  lflags;	/* 'h', 'j', 'l', 't', 'z' */
	unsigned int prefix;	/* a very small string */
	int width, prec, base = 0, prefixlen;
	size_t r, len;
	const char *p, *s, *digits;
	char buf[24], *const buf_end = buf + sizeof buf;
	intmax_t d;
	uintmax_t u = 0;

	r = 0;
	if (stream != NULL)
		lock_stream(stream);
	for (p = fmt; *p != '\0'; p++) {
		if (*p != '%') {
		putc:
			WRITE_CHAR(*p);
			continue;
		}
		alt = false;
		ljust = false;
		point = false;
		zeropad = false;
		lflags = 0;
		prefix = '\0';
		prefixlen = 0;
		width = 0;
		prec = 1;	/* make sure 0 prints as "0" */
		digits = xdigits;
		for (p++;; p++) {
		      again:
			switch (*p) {
			case '%':
				goto putc;
			case '#':
				alt = true;
				continue;
			case '-':	/* takes precedence over '0' */
				ljust = true;
				continue;
			case '0':
				zeropad = true;
				continue;
			case '+':	/* XXX should take precedence over 
					 * ' ' */
			case ' ':
				prefix = *p;
				prefixlen = 1;
				continue;
			case '*':
				width = va_arg(ap, int);
				if (ljust)
					width = -width;
				continue;
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				/*
				 * width = strtol(p, &p, 10), sort of 
				 */
				width = *p - '0';
				for (p++; (unsigned int) (*p - '0') < 10;
				     p++)
					width = width * 10 + (*p - '0');
				if (ljust)
					width = -width;
				goto again;	/* don't increment p */
			case '.':
				point = true;
				if (*++p == '*') {
					prec = va_arg(ap, int);
					continue;
				} else {
					/*
					 * prec = strtol(p, &p, 10), sort
					 * of 
					 */
					for (prec = 0;
					     (unsigned int) (*p - '0') <
					     10; p++)
						prec =
						    prec * 10 + (*p - '0');
					goto again;	/* don't increment 
							 * p */
				}
			case 'h':
				lflags--;
				continue;
			case 'L':
			case 'l':
				lflags++;
				continue;
			case 't':
			case 'z':
				lflags = 1;	/* assume ptrdiff_t and
						 * size_t are long */
				continue;
			case 'j':
				lflags = 2;	/* assume intmax_t is long 
						 * long */
				continue;
#ifndef	NO_FLOAT
			case 'a':
			case 'A':
			case 'e':
			case 'E':
			case 'f':
			case 'g':
			case 'G':
				/*
				 * NOT IMPLEMENTED 
				 */
				switch (lflags) {
				case 0:
					va_arg(ap, double);
					break;
				case 1:
					va_arg(ap, long double);
					break;
				default:
					goto default_case;
				}
				break;
#endif				/* !NO_FLOAT */
			case 'c':
#ifndef	NO_WCHAR
				/*
				 * NOT IMPLEMENTED 
				 */
				if (lflags > 0)
					va_arg(ap, wchar_t);
				else
#endif
					*(buf_end - 1) = va_arg(ap, int);
				s = buf_end - 1;
				len = 1;
				goto common3;
			case 'd':
			case 'i':
				switch (lflags) {
				case -2:
					// d = va_arg(ap, signed char);
					d = va_arg(ap, int);
					break;
				case -1:
					// d = va_arg(ap, short);
					d = va_arg(ap, int);
					break;
				case 0:
					d = va_arg(ap, int);
					break;
				case 1:
					d = va_arg(ap, long);
					break;
#ifndef	NO_LONG_LONG
				case 2:
					d = va_arg(ap, long long);
					break;
#endif
				default:
					goto default_case;
				}
				if (d < 0LL) {
					/*
					 * safely negate d, even
					 * INTMAX_MIN 
					 */
					u = -(uintmax_t) d;
					prefix = '-';	/* override ' ' or 
							 * '+' */
					prefixlen = 1;
				} else {
					u = d;
				}
				base = 10;
				goto common2;
			case 'n':
				switch (lflags) {
				case -2:
					*va_arg(ap, signed char *) = r;
					break;
				case -1:
					*va_arg(ap, short *) = r;
					break;
				case 0:
					*va_arg(ap, int *) = r;
					break;
				case 1:
					*va_arg(ap, long *) = r;
					break;
				case 2:
					*va_arg(ap, long long *) = r;
					break;
				default:
					goto default_case;
				}
				break;
			case 'o':
				base = 8;
				goto common1;
			case 'p':
				u = (uintptr_t) va_arg(ap, const void *);
				if (u != (uintptr_t) NULL) {
					base = 16;
					prec = 2 * sizeof(const void *);
					prefix = '0' | 'x' << 8;
					prefixlen = 2;
					goto common2;
				} else {
					s = "(nil)";
					len = 5;
					goto common3;
				}
			case 's':
				s = va_arg(ap, const char *);
				/*
				 * XXX left-justified strings are scanned
				 * twice 
				 */
				if (point) {
					/*
					 * len = min(prec, strlen(s)) 
					 */
					for (len = 0; len < prec; len++)
						if (s[len] == '\0')
							break;
				} else {
					len = strlen(s);
				}
				goto common3;
			case 'u':
				base = 10;
				goto common1;
			case 'X':
				digits = Xdigits;
				/*
				 * FALLTHROUGH 
				 */
			case 'x':
				base = 16;
				if (alt) {
					prefix = '0' | *p << 8;
					prefixlen = 2;
				}
				/*
				 * FALLTHROUGH 
				 */
			      common1:
				/*
				 * common code for %o, %u, %X, and %x 
				 */
				switch (lflags) {
				case -2:
					// u = va_arg(ap, unsigned char);
					u = va_arg(ap, int);
					break;
				case -1:
					// u = va_arg(ap, unsigned short);
					u = va_arg(ap, int);
					break;
				case 0:
					u = va_arg(ap, unsigned int);
					break;
				case 1:
					u = va_arg(ap, unsigned long);
					break;
#ifndef	NO_LONG_LONG
				case 2:
					u = va_arg(ap, unsigned long long);
					break;
#endif
				default:
					goto default_case;
				}
				/*
				 * FALLTHROUGH 
				 */
			      common2:
				s = umaxtostr(buf_end, u, base, digits);
				len = buf_end - s;
				/*
				 * the field may overflow prec 
				 */
				if (prec < len)
					/*
					 * FALLTHOUGH 
					 */
				      common3:
					prec = len;
				if (zeropad && prec < width - prefixlen)
					prec = width - prefixlen;
				else if (alt && base == 8 && u != 0LL)
					prec++;

				{
					int tmp = fprintf1(output, stream, stream_or_memory, r, n, 
							   s, len, prefix, 
							   prefixlen, width, prec, &overflowed);
					r += tmp;
					output += tmp;
				}

				break;
			default:	/* unrecognized conversion
					 * specifier */
			      default_case:
				/*
				 * print uninterpreted 
				 */
				for (s = p - 1; *s != '%'; s--);
				for (; s <= p; s++) {
					WRITE_CHAR(*p);
				}
				break;
			}
			break;	/* finished the conversion specifier */
		}
	}
	if (! stream_or_memory && ! overflowed) 
		*output++ = '\0';
	if (stream != NULL)
		unlock_stream(stream);
	return r;
}
