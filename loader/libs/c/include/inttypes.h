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

/*
 Authors: Ben Leslie
*/

#ifndef _INT_TYPES_
#define _INT_TYPES_

#include <stdint.h>

#include <arch/inttypes.h>

/* 7.8.1 Macros for format specifies */

/* 7.8.1.2 signed integers */
#define PRId8 __LENGTH_8_MOD "d"
#define PRId16 __LENGTH_16_MOD "d"
#define PRId32 __LENGTH_32_MOD "d"
#define PRId64 __LENGTH_64_MOD "d"

#define PRIi8 __LENGTH_8_MOD "i"
#define PRIi16 __LENGTH_16_MOD "i"
#define PRIi32 __LENGTH_32_MOD "i"
#define PRIi64 __LENGTH_64_MOD "i"

#define PRIdLEAST8 __LENGTH_LEAST8_MOD "d"
#define PRIdLEAST16 __LENGTH_LEAST16_MOD "d"
#define PRIdLEAST32 __LENGTH_LEAST32_MOD "d"
#define PRIdLEAST64 __LENGTH_LEAST64_MOD "d"

#define PRIiLEAST8 __LENGTH_LEAST8_MOD "i"
#define PRIiLEAST16 __LENGTH_LEAST16_MOD "i"
#define PRIiLEAST32 __LENGTH_LEAST32_MOD "i"
#define PRIiLEAST64 __LENGTH_LEAST64_MOD "i"

#define PRIdFAST8 __LENGTH_FAST8_MOD "d"
#define PRIdFAST16 __LENGTH_FAST16_MOD "d"
#define PRIdFAST32 __LENGTH_FAST32_MOD "d"
#define PRIdFAST64 __LENGTH_FAST64_MOD "d"

#define PRIiFAST8 __LENGTH_FAST8_MOD "i"
#define PRIiFAST16 __LENGTH_FAST16_MOD "i"
#define PRIiFAST32 __LENGTH_FAST32_MOD "i"
#define PRIiFAST64 __LENGTH_FAST64_MOD "i"

#define PRIdMAX __LENGTH_MAX_MOD "d" 
#define PRIiMAX __LENGTH_MAX_MOD "i"

#define PRIdPTR __LENGTH_PTR_MOD "d"
#define PRIiPTR __LENGTH_PTR_MOD "i"

/* 7.8 __LENGTH_8_MOD.1.3 unsigned integers */

#define PRIo8 __LENGTH_8_MOD "o"
#define PRIo16 __LENGTH_16_MOD "o"
#define PRIo32 __LENGTH_32_MOD "o"
#define PRIo64 __LENGTH_64_MOD "o"

#define PRIu8 __LENGTH_8_MOD "u"
#define PRIu16 __LENGTH_16_MOD "u"
#define PRIu32 __LENGTH_32_MOD "u"
#define PRIu64 __LENGTH_64_MOD "u"

#define PRIx8 __LENGTH_8_MOD "x"
#define PRIx16 __LENGTH_16_MOD "x"
#define PRIx32 __LENGTH_32_MOD "x"
#define PRIx64 __LENGTH_64_MOD "x"

#define PRIX8 __LENGTH_8_MOD "X"
#define PRIX16 __LENGTH_16_MOD "X"
#define PRIX32 __LENGTH_32_MOD "X"
#define PRIX64 __LENGTH_64_MOD "X"

#define PRIoLEAST8 __LENGTH_LEAST8_MOD "o"
#define PRIoLEAST16 __LENGTH_LEAST16_MOD "o"
#define PRIoLEAST32 __LENGTH_LEAST32_MOD "o"
#define PRIoLEAST64 __LENGTH_LEAST64_MOD "o"

#define PRIuLEAST8 __LENGTH_LEAST8_MOD "u"
#define PRIuLEAST16 __LENGTH_LEAST16_MOD "u"
#define PRIuLEAST32 __LENGTH_LEAST32_MOD "u"
#define PRIuLEAST64 __LENGTH_LEAST64_MOD "u"

#define PRIxLEAST8 __LENGTH_LEAST8_MOD "x"
#define PRIxLEAST16 __LENGTH_LEAST16_MOD "x"
#define PRIxLEAST32 __LENGTH_LEAST32_MOD "x"
#define PRIxLEAST64 __LENGTH_LEAST64_MOD "x"

#define PRIXLEAST8 __LENGTH_LEAST8_MOD "X"
#define PRIXLEAST16 __LENGTH_LEAST16_MOD "X"
#define PRIXLEAST32 __LENGTH_LEAST32_MOD "X"
#define PRIXLEAST64 __LENGTH_LEAST64_MOD "X"

#define PRIoFAST8 __LENGTH_FAST8_MOD "o"
#define PRIoFAST16 __LENGTH_FAST16_MOD "o"
#define PRIoFAST32 __LENGTH_FAST32_MOD "o"
#define PRIoFAST64 __LENGTH_FAST64_MOD "o"

#define PRIuFAST8 __LENGTH_FAST8_MOD "u"
#define PRIuFAST16 __LENGTH_FAST16_MOD "u"
#define PRIuFAST32 __LENGTH_FAST32_MOD "u"
#define PRIuFAST64 __LENGTH_FAST64_MOD "u"

#define PRIxFAST8 __LENGTH_FAST8_MOD "x"
#define PRIxFAST16 __LENGTH_FAST16_MOD "x"
#define PRIxFAST32 __LENGTH_FAST32_MOD "x"
#define PRIxFAST64 __LENGTH_FAST64_MOD "x"

#define PRIXFAST8 __LENGTH_FAST8_MOD "X"
#define PRIXFAST16 __LENGTH_FAST16_MOD "X"
#define PRIXFAST32 __LENGTH_FAST32_MOD "X"
#define PRIXFAST64 __LENGTH_FAST64_MOD "X"

#define PRIoMAX __LENGTH_MAX_MOD "o"
#define PRIuMAX __LENGTH_MAX_MOD "u"
#define PRIxMAX __LENGTH_MAX_MOD "x"
#define PRIXMAX __LENGTH_MAX_MOD "X"

#define PRIoPTR __LENGTH_PTR_MOD "o"
#define PRIuPTR __LENGTH_PTR_MOD "u" 
#define PRIxPTR __LENGTH_PTR_MOD "x"
#define PRIXPTR __LENGTH_PTR_MOD "X"

#endif
