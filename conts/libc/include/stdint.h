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
#ifndef _STDINT_H_
#define	_STDINT_H_

#include <limits.h>

/*
 * 7.18.1.1 Exact-width integers
 */
#include <arch/stdint.h>

/*
 * 7.18.2.1 Limits of exact-wdith integer types
 */
#define	INT8_MIN  SCHAR_MIN
#define	INT16_MIN SHRT_MIN
#define	INT32_MIN INT_MIN
#define	INT64_MIN LLONG_MIN

#define	INT8_MAX SCHAR_MAX
#define	INT16_MAX SHRT_MAX
#define	INT32_MAX INT_MAX
#define	INT64_MAX LLONG_MAX

#define	UINT8_MAX UCHAR_MAX
#define	UINT16_MAX USHRT_MAX
#define	UINT32_MAX UINT_MAX
#define	UINT64_MAX ULLONG_MAX


#ifndef __ARCH_HAS_LEAST
/*
 * 7.18.1.2 Minimum-width integers
 */
typedef int8_t  int_least8_t;
typedef int16_t int_least16_t;
typedef int32_t int_least32_t;
typedef int64_t int_least64_t;

typedef uint8_t uint_least8_t;
typedef uint16_t uint_least16_t;
typedef uint32_t uint_least32_t;
typedef uint64_t uint_least64_t;

/*
 * 7.18.2.2 Limits of minimum-width integers
 */
#define	INT_LEAST8_MIN		INT8_MIN
#define	INT_LEAST16_MIN		INT16_MIN
#define	INT_LEAST32_MIN		INT32_MIN
#define	INT_LEAST64_MIN		INT64_MIN

#define	INT_LEAST8_MAX		INT8_MAX
#define	INT_LEAST16_MAX		INT16_MAX
#define	INT_LEAST32_MAX		INT32_MAX
#define	INT_LEAST64_MAX		INT64_MAX

#define	UINT_LEAST8_MAX		UINT8_MAX
#define	UINT_LEAST16_MAX	UINT16_MAX
#define	UINT_LEAST32_MAX	UINT32_MAX
#define	UINT_LEAST64_MAX	UINT64_MAX
#else
#undef __ARCH_HAS_LEAST
#endif


#ifndef __ARCH_HAS_FAST
/*
 * 7.8.1.3 Fastest minimum-width integer types
 * Note -- We fulfil the spec, however we don't really know
 * which are fastest here. I assume `int' is probably fastest
 * more most, and should be used for [u]int_fast[8,16,32]_t.
 */

typedef int8_t int_fast8_t;
typedef int16_t int_fast16_t;
typedef int32_t int_fast32_t;
typedef int64_t int_fast64_t;

typedef uint8_t uint_fast8_t;
typedef uint16_t uint_fast16_t;
typedef uint32_t uint_fast32_t;
typedef uint64_t uint_fast64_t;

/*
 * 7.18.2.2 Limits of fastest minimum-width integers
 */
#define	INT_FAST8_MIN	INT8_MIN
#define	INT_FAST16_MIN	INT16_MIN
#define	INT_FAST32_MIN	INT32_MIN
#define	INT_FAST64_MIN	INT64_MIN

#define	INT_FAST8_MAX	INT8_MAX
#define	INT_FAST16_MAX	INT16_MAX
#define	INT_FAST32_MAX	INT32_MAX
#define	INT_FAST64_MAX	INT64_MAX

#define	UINT_FAST8_MAX	UINT8_MAX
#define	UINT_FAST16_MAX	UINT16_MAX
#define	UINT_FAST32_MAX	UINT32_MAX
#define	UINT_FAST64_MAX	UINT64_MAX
#else
#undef __ARCH_HAS_FAST
#endif

/*
 * 7.18.1.4 Integer types capable of holding object pointers
 * We should fix this to be 32/64 clean.
 */
#if __PTR_SIZE==32
typedef int32_t intptr_t;
typedef uint32_t uintptr_t;

#define INTPTR_MIN INT32_MIN
#define INTPTR_MAX INT32_MAX
#define UINTPTR_MAX UINT32_MAX

#elif __PTR_SIZE==64
typedef int64_t intptr_t;
typedef uint64_t uintptr_t;

#define INTPTR_MIN INT64_MIN
#define INTPTR_MAX INT64_MAX
#define UINTPTR_MAX UINT64_MAX
#else
#error Unknown pointer size
#endif

#undef __PTR_SIZE

/*
 * 7.18.1.5 Greatest-wdith integer types
 */
typedef long long int intmax_t;
typedef unsigned long long int uintmax_t;

/*
 * 7.18.2.5 Limits of greateast-width integer types
 */
#define	INTMAX_MIN		LLONG_MIN
#define	INTMAX_MAX		LLONG_MAX
#define	UINTMAX_MAX		ULLONG_MAX

/*
 * 7.18.3 Limits of other integer types
 */
/* FIXME: Check these limits are correct */
#define	PTRDIFF_MIN		INTPTR_MIN
#define	PTRDIFF_MAX		INTPTR_MAX

#define	SIG_ATOMIC_MIN		INT_MIN
#define	SIG_ATOMIC_MAX		INT_MAX

#define	SIZE_MAX		UINTPTR_MAX

#define	WCHAR_MIN		0
#define	WCHAR_MAX		UINT16_MAX

#define	WINT_MIN		0
#define	WINT_MAX		UINT16_MAX

/*
 * 7.18.4 Macros for integer constants
 */

#define	INT8_C(x)		(int8_t)(x)
#define	INT16_C(x)		(int16_t)(x)
#define	INT32_C(x)		(int32_t)(x)
#define	INT64_C(x)		(int64_t)(x)
#define	UINT8_C(x)		(uint8_t)(x)
#define	UINT16_C(x)		(uint16_t)(x)
#define	UINT32_C(x)		(uint32_t)(x)
#define	UINT64_C(x)		(uint64_t)(x)

#define	INT_FAST8_C(x)		(int_fast8_t)(x)
#define	INT_FAST16_C(x)		(int_fast16_t)(x)
#define	INT_FAST32_C(x)		(int_fast32_t)(x)
#define	INT_FAST64_C(x)		(int_fast64_t)(x)
#define	UINT_FAST8_C(x)		(uint_fast8_t)(x)
#define	UINT_FAST16_C(x)	(uint_fast16_t)(x)
#define	UINT_FAST32_C(x)	(uint_fast32_t)(x)
#define	UINT_FAST64_C(x)	(uint_fast64_t)(x)

#define	INT_LEAST8_C(x)		(int_least8_t)(x)
#define	INT_LEAST16_C(x)	(int_least16_t)(x)
#define	INT_LEAST32_C(x)	(int_least32_t)(x)
#define	INT_LEAST64_C(x)	(int_least64_t)(x)
#define	UINT_LEAST8_C(x)	(uint_least8_t)(x)
#define	UINT_LEAST16_C(x)	(uint_least16_t)(x)
#define	UINT_LEAST32_C(x)	(uint_least32_t)(x)
#define	UINT_LEAST64_C(x)	(uint_least64_t)(x)

#define	INTPTR_C(x)		(intptr_t)(x)
#define	UINTPTR_C(x)		(uintptr_t)(x)

#define	INTMAX_C(x)		(intmax_t)(x)
#define	UINTMAX_C(x)		(uintmax_t)(x)

#endif				/* _STDINT_H_ */
