// Ripped out of latest ecos build from http://sources-redhat.mirrors.airband.net/ecos/releases/ecos-3.0b1/ecos-3.0beta1.i386linux.tar.bz2
// File: ecos-3.0b1/packages/language/c/libc/stdio/v3_0b1/src/output/vfnprintf.cxx

//  Hacked to pieces so it would work with OpenRISC compiler, not using libc
//===========================================================================
//
//      vfnprintf.c
//
//      I/O routines for vfnprintf() for use with ANSI C library
//
//===========================================================================
// ####ECOSGPLCOPYRIGHTBEGIN####                                            
// -------------------------------------------                              
// This file is part of eCos, the Embedded Configurable Operating System.   
// Copyright (C) 1998, 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
//
// eCos is free software; you can redistribute it and/or modify it under    
// the terms of the GNU General Public License as published by the Free     
// Software Foundation; either version 2 or (at your option) any later      
// version.                                                                 
//
// eCos is distributed in the hope that it will be useful, but WITHOUT      
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or    
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License    
// for more details.                                                        
//
// You should have received a copy of the GNU General Public License        
// along with eCos; if not, write to the Free Software Foundation, Inc.,    
// 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.            
//
// As a special exception, if other files instantiate templates or use      
// macros or inline functions from this file, or you compile this file      
// and link it with other works to produce a work based on this file,       
// this file does not by itself cause the resulting work to be covered by   
// the GNU General Public License. However the source code for this file    
// must still be made available in accordance with section (3) of the GNU   
// General Public License v2.                                               
//
// This exception does not invalidate any other reasons why a work based    
// on this file might be covered by the GNU General Public License.         
// -------------------------------------------                              
// ####ECOSGPLCOPYRIGHTEND####                                              
//===========================================================================
//#####DESCRIPTIONBEGIN####
//
// Author(s):    jlarmour
// Contributors: 
// Date:         2000-04-20
// Purpose:     
// Description: 
// Usage:       
//
//####DESCRIPTIONEND####
//
//===========================================================================
//
// This code is based on original code with the following copyright:
//
/*-
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Chris Torek.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */


// CONFIGURATION

//#include <pkgconf/libc_stdio.h>   // Configuration header
//#include <pkgconf/libc_i18n.h>    // Configuration header for mb support

// INCLUDES

#include <stdlib.h> // For mbtowc()
#include <stddef.h>


//#include <cyg/infra/cyg_type.h>   // Common type definitions and support
#define CYG_MACRO_START do {
#define CYG_MACRO_END   } while (0)

#define CYG_EMPTY_STATEMENT CYG_MACRO_START CYG_MACRO_END

#define CYG_UNUSED_PARAM( _type_, _name_ ) CYG_MACRO_START      \
  _type_ __tmp1 = (_name_);                                     \
  _type_ __tmp2 = __tmp1;                                       \
  __tmp1 = __tmp2;                                              \
CYG_MACRO_END

#include <stdarg.h>               // Variable argument definitions
//#include <stdio.h>                // Standard header for all stdio files
#include <string.h>               // memchr() and strlen() functions
//#include <cyg/libc/stdio/stream.hxx> // C library streams

#include "vfnprintf.h"


# define BUF            40

/*
 * Actual printf innards.
 *
 * This code is large and complicated...
 */


/*
 * Macros for converting digits to letters and vice versa
 */
#define to_digit(c)     ((c) - '0')
#define is_digit(c)     ((unsigned)to_digit(c) <= 9)
#define to_char(n)      ((n) + '0')

/*
 * Flags used during conversion.
 */
#define ALT             0x001           /* alternate form */
#define HEXPREFIX       0x002           /* add 0x or 0X prefix */
#define LADJUST         0x004           /* left adjustment */
#define LONGDBL         0x008           /* long double; unimplemented */
#define LONGINT         0x010           /* long integer */
#define QUADINT         0x020           /* quad integer */
#define SHORTINT        0x040           /* short integer */
#define ZEROPAD         0x080           /* zero (as opposed to blank) pad */
#define FPT             0x100           /* Floating point number */
#define SIZET           0x200           /* size_t */


// Function which prints back to the buffer, ptr, len bytes
// returns 1 if it should finish up, otherwise 0 to continue
int print_back_to_string(char * ptr, int len, size_t * n, int * ret, char ** stream)
{
#define MIN(a, b) ((a) < (b) ? (a) : (b))
  do {
    int length = MIN( (int) len, *n - *ret - 1);
    memcpy(*stream + *ret, ptr, length);
    if (length < (int)len) {
      *ret += length;
      return 1; // finish up
    }

  } while(0);
    
    return 0;
}

//externC int 
int
//vfnprintf ( FILE *stream, size_t n, const char *format, va_list arg) __THROW
vfnprintf ( char *stream, size_t n, const char *format, va_list arg)
{
  char *fmt;     /* format string */
  int ch;        /* character from fmt */
  int x, y;      /* handy integers (short term usage) */
  char *cp;      /* handy char pointer (short term usage) */
  int flags;     /* flags as above */
  
  int ret;                /* return value accumulator */
  int width;              /* width from format (%8d), or 0 */
  int prec;               /* precision from format (%.3d), or -1 */
  char sign;              /* sign prefix (' ', '+', '-', or \0) */
  wchar_t wc;
  
#define quad_t    long long
#define u_quad_t  unsigned long long
  
  u_quad_t _uquad;        /* integer arguments %[diouxX] */
  enum { OCT, DEC, HEX } base;/* base for [diouxX] conversion */
  int dprec;              /* a copy of prec if [diouxX], 0 otherwise */
  int fieldsz;            /* field size expanded by sign, etc */
  int realsz;             /* field size expanded by dprec */
  int size;               /* size of converted field or string */
  char *xdigs;            /* digits for [xX] conversion */
#define NIOV 8
  char buf[BUF];          /* space for %c, %[diouxX], %[eEfgG] */
  char ox[2];             /* space for 0x hex-prefix */
  
  /*
   * Choose PADSIZE to trade efficiency vs. size.  If larger printf
   * fields occur frequently, increase PADSIZE and make the initialisers
   * below longer.
   */
#define PADSIZE 16              /* pad chunk size */
  static char blanks[PADSIZE] =
    {' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '};
  static char zeroes[PADSIZE] =
    {'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'};
  
  /*
   * BEWARE, these `goto error' on error, and PAD uses `n'.
   */
  
  // We'll copy len bytes from (char*) ptr, into the output stream
  // making sure we don't go over the end, so calculate length to be
  // either the whole length we've been passed, or the whole length
  // that is possible to write
  // We finish if it was not possible to write the entire variable
  // into the buffer, ie we had to write all we could, not all we
  // wanted to.
  /*
    #define PRINT(ptr, len)						\
    CYG_MACRO_START							\
    int length = MIN( (int) len, n - ret - 1);				\
    char* begin_stream_write = stream;					\
    stream = memcpy(stream, ptr, length);				\
    length = (unsigned long) stream - (unsigned long) begin_stream_write; \
    if (length < (int)len) {						\
    ret += length;							\
    goto done;								\
    }									\
    CYG_MACRO_END
  */
  
	//PRINT(with, PADSIZE);						\
      //PRINT(with, x);							\
  
#define PAD(howmany, with)						\
  CYG_MACRO_START							\
    if ((x = (howmany)) > 0) {						\
      while (x > PADSIZE) {						\
	if (print_back_to_string(with, PADSIZE, &n, &ret, &stream)) goto done; \
	x -= PADSIZE;							\
      }									\
      if (print_back_to_string(with, x, &n, &ret, &stream))goto done;	\
    }									\
  CYG_MACRO_END
  
  /*
   * To extend shorts properly, we need both signed and unsigned
   * argument extraction methods.
   */
  
#define SARG()					  \
  (flags&QUADINT ? va_arg(arg, long long) :	  \
   flags&LONGINT ? va_arg(arg, long) :			     \
   flags&SHORTINT ? (long)(short)va_arg(arg, int) :	     \
   flags&SIZET ? (long)va_arg(arg, size_t) :		     \
   (long)va_arg(arg, int))
#define UARG()						   \
  (flags&QUADINT ? va_arg(arg, unsigned long long) :	   \
   flags&LONGINT ? va_arg(arg, unsigned long) :				\
   flags&SHORTINT ? (unsigned long)(unsigned short)va_arg(arg, int) :	\
   flags&SIZET ? va_arg(arg, size_t) :					\
   (unsigned long)va_arg(arg, unsigned int))

  
  xdigs = NULL;  // stop compiler whinging
  fmt = (char *)format;
  ret = 0;
  
  /*
   * Scan the format for conversions (`%' character).
   */
  for (;;) {
    cp = (char *)fmt; // char pointer - set to where we begin looking from
    while ((x = ((wc = *fmt) != 0))) { // While, wc=next char and x is one while there's still chars left
      fmt += x; // increment the pointer to the char
      if (wc == '%') { // check if it's the beginning of
	fmt--; // Decrement the char pointer, actually
	break;
      }
    }
    if ((y = fmt - cp) != 0) { // y is length of string to copy out just now
      //PRINT(cp, y); // Copy macro 
      if(print_back_to_string(cp, y, &n, &ret, &stream)) goto done; // Copy macro 
      ret += y; // increment return chars
    }
    if ((x <= 0) || (ret >= (int)n))  // @@@ this check with n isn't good enough
      goto done;
    fmt++;          /* skip over '%' */
    
    flags = 0;
    dprec = 0;
    width = 0;
    prec = -1;
    sign = '\0';
    
  rflag:          ch = *fmt++;
  reswitch:       switch (ch) {
    case ' ':
      /*
       * ``If the space and + flags both appear, the space
       * flag will be ignored.''
       *      -- ANSI X3J11
       */
      if (!sign)
	sign = ' ';
      goto rflag;
    case '#':
      flags |= ALT;
      goto rflag;
    case '*':
      /*
       * ``A negative field width argument is taken as a
       * - flag followed by a positive field width.''
       *      -- ANSI X3J11
       * They don't exclude field widths read from args.
       */
      if ((width = va_arg(arg, int)) >= 0)
	goto rflag;
      width = -width;
      /* FALLTHROUGH */
    case '-':
      flags |= LADJUST;
      goto rflag;
    case '+':
      sign = '+';
      goto rflag;
    case '.':
      if ((ch = *fmt++) == '*') {
	x = va_arg(arg, int);
	prec = x < 0 ? -1 : x;
	goto rflag;
      }
      x = 0;
      while (is_digit(ch)) {
	x = 10 * x + to_digit(ch);
	ch = *fmt++;
      }
      prec = x < 0 ? -1 : x;
      goto reswitch;
    case '0':
      /*
       * ``Note that 0 is taken as a flag, not as the
       * beginning of a field width.''
       *      -- ANSI X3J11
       */
      flags |= ZEROPAD;
      goto rflag;
    case '1': case '2': case '3': case '4':
    case '5': case '6': case '7': case '8': case '9':
      x = 0;
      do {
	x = 10 * x + to_digit(ch);
	ch = *fmt++;
      } while (is_digit(ch));
      width = x;
      goto reswitch;
    case 'h':
      flags |= SHORTINT;
      goto rflag;
    case 'l':
      if (*fmt == 'l') {
	fmt++;
	flags |= QUADINT;
      } else {
	flags |= LONGINT;
      }
      goto rflag;
    case 'q':
      flags |= QUADINT;
      goto rflag;
    case 'c':
      *(cp = buf) = va_arg(arg, int);
      size = 1;
      sign = '\0';
      break;
    case 'D':
      flags |= LONGINT;
      /*FALLTHROUGH*/
    case 'd':
    case 'i':
      _uquad = SARG();
#ifndef _NO_LONGLONG
      if ((quad_t)_uquad < 0)
#else
	if ((long) _uquad < 0)
#endif
	  {
	    
	    _uquad = -_uquad;
	    sign = '-';
	  }
      base = DEC;
      goto number;
      
    case 'e':
    case 'E':
    case 'f':
    case 'g':
    case 'G':
      // Output nothing at all
      (void) va_arg(arg, double); // take off arg anyway
      cp = "";
      size = 0;
      sign = '\0';
      break;
      
    case 'n':
#ifndef _NO_LONGLONG
      if (flags & QUADINT)
	*va_arg(arg, quad_t *) = ret;
      else 
#endif
	if (flags & LONGINT)
	  *va_arg(arg, long *) = ret;
	else if (flags & SHORTINT)
	  *va_arg(arg, short *) = ret;
	else if (flags & SIZET)
	  *va_arg(arg, size_t *) = ret;
	else
	  *va_arg(arg, int *) = ret;
      continue;       /* no output */
    case 'O':
      flags |= LONGINT;
      /*FALLTHROUGH*/
    case 'o':
      _uquad = UARG();
      base = OCT;
      goto nosign;
    case 'p':
      /*
       * ``The argument shall be a pointer to void.  The
       * value of the pointer is converted to a sequence
       * of printable characters, in an implementation-
       * defined manner.''
       *      -- ANSI X3J11
       */
      /* NOSTRICT */
      _uquad = (unsigned long)va_arg(arg, void *);
      base = HEX;
      xdigs = (char *)"0123456789abcdef";
      flags |= HEXPREFIX;
      ch = 'x';
      goto nosign;
    case 's':
      if ((cp = va_arg(arg, char *)) == NULL)
	cp = (char *)"(null)";
      if (prec >= 0) {
	/*
	 * can't use strlen; can only look for the
	 * NUL in the first `prec' characters, and
	 * strlen() will go further.
	 */
	char *p = (char *)memchr(cp, 0, prec);
	
	if (p != NULL) {
	  size = p - cp;
	  if (size > prec)
	    size = prec;
	} else
	  size = prec;
      } else
	size = strlen(cp);
      sign = '\0';
      break;
    case 'U':
      flags |= LONGINT;
      /*FALLTHROUGH*/
    case 'u':
      _uquad = UARG();
      base = DEC;
      goto nosign;
    case 'X':
      xdigs = (char *)"0123456789ABCDEF";
      goto hex;
    case 'x':
      xdigs = (char *)"0123456789abcdef";
    hex:                    _uquad = UARG();
      base = HEX;
      /* leading 0x/X only if non-zero */
      if (flags & ALT && _uquad != 0)
	flags |= HEXPREFIX;
      
      /* unsigned conversions */
    nosign:                 sign = '\0';
      /*
       * ``... diouXx conversions ... if a precision is
       * specified, the 0 flag will be ignored.''
       *      -- ANSI X3J11
       */
    number:                 if ((dprec = prec) >= 0)
	flags &= ~ZEROPAD;
      
      /*
       * ``The result of converting a zero value with an
       * explicit precision of zero is no characters.''
       *      -- ANSI X3J11
       */
      cp = buf + BUF;
      if (_uquad != 0 || prec != 0) {
	/*
	 * Unsigned mod is hard, and unsigned mod
	 * by a constant is easier than that by
	 * a variable; hence this switch.
	 */
	switch (base) {
	case OCT:
	  do {
	    *--cp = to_char(_uquad & 7);
	    _uquad >>= 3;
	  } while (_uquad);
	  /* handle octal leading 0 */
	  if (flags & ALT && *cp != '0')
	    *--cp = '0';
	  break;
	  
	case DEC:
	  if (!(flags & QUADINT)) {
	    /* many numbers are 1 digit */
	    unsigned long v = (unsigned long)_uquad;
	    while (v >= 10) {
	      /* The following is usually faster than using a modulo */
	      unsigned long next = v / 10;
	      *--cp = to_char(v - (next * 10));
	      v = next;
	    }
	    *--cp = to_char(v);
	  }
	  else {
	    while (_uquad >= 10) {
	      /* The following is usually faster than using a modulo */
	      u_quad_t next = _uquad / 10;
	      *--cp = to_char(_uquad - (next * 10));
	      _uquad = next;
	    }
	    *--cp = to_char(_uquad);
	  }
	  break;
	  
	case HEX:
	  do {
	    *--cp = xdigs[_uquad & 15];
	    _uquad >>= 4;
	  } while (_uquad);
	  break;
	  
	default:
	  cp = (char *)"bug in vfprintf: bad base";
	  size = strlen(cp);
	  goto skipsize;
	}
      }
      size = buf + BUF - cp;
    skipsize:
      break;
    case 'z':
      flags |= SIZET;
      goto rflag;
    default:        /* "%?" prints ?, unless ? is NUL */
      if (ch == '\0')
	goto done;
      /* pretend it was %c with argument ch */
      cp = buf;
      *cp = ch;
      size = 1;
      sign = '\0';
      break;
    }
    
    /*
     * All reasonable formats wind up here.  At this point, `cp'
     * points to a string which (if not flags&LADJUST) should be
     * padded out to `width' places.  If flags&ZEROPAD, it should
     * first be prefixed by any sign or other prefix; otherwise,
     * it should be blank padded before the prefix is emitted.
     * After any left-hand padding and prefixing, emit zeroes
     * required by a decimal [diouxX] precision, then print the
     * string proper, then emit zeroes required by any leftover
     * floating precision; finally, if LADJUST, pad with blanks.
     *
     * Compute actual size, so we know how much to pad.
     * fieldsz excludes decimal prec; realsz includes it.
     */
#ifdef CYGSEM_LIBC_STDIO_PRINTF_FLOATING_POINT
    fieldsz = size + fpprec;
#else
    fieldsz = size;
#endif
    if (sign)
      fieldsz++;
    else if (flags & HEXPREFIX)
      fieldsz+= 2;
    realsz = dprec > fieldsz ? dprec : fieldsz;
    
    /* right-adjusting blank padding */
    if ((flags & (LADJUST|ZEROPAD)) == 0) {
      if (width - realsz > 0) {
	PAD(width - realsz, blanks);
	ret += width - realsz;
      }
    }
    
    /* prefix */
    if (sign) {
      //PRINT(&sign, 1);
      if(print_back_to_string(&sign, 1, &n, &ret, &stream))goto done;
      ret++;
    } else if (flags & HEXPREFIX) {
      ox[0] = '0';
      ox[1] = ch;
      //PRINT(ox, 2);
      if(print_back_to_string(ox, 2, &n, &ret, &stream))goto done;
      ret += 2;
    }
    
    /* right-adjusting zero padding */
    if ((flags & (LADJUST|ZEROPAD)) == ZEROPAD) {
      if (width - realsz > 0) {
	PAD(width - realsz, zeroes);
	ret += width - realsz;
      }
    }
    
    if (dprec - fieldsz > 0) {
      /* leading zeroes from decimal precision */
      PAD(dprec - fieldsz, zeroes);
      ret += dprec - fieldsz;
    }
    
    /* the string or number proper */
    //PRINT(cp, size);
    if(print_back_to_string(cp,size, &n, &ret, &stream))goto done;
    ret += size;
    
#ifdef CYGSEM_LIBC_STDIO_PRINTF_FLOATING_POINT
    /* trailing f.p. zeroes */
    PAD(fpprec, zeroes);
    ret += fpprec;
#endif
    
    /* left-adjusting padding (always blank) */
    if (flags & LADJUST) {
      if (width - realsz > 0) {
	PAD(width - realsz, blanks);
	ret += width - realsz;
      }
    }
    
  }
  
 done:
 error:
  return ret;// remove this error stuff (((Cyg_OutputStream *) stream)->get_error() ? EOF : ret);
  /* NOTREACHED */
}



// EOF vfnprintf.c
