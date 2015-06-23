/* Copyright (C) 1991,92,93,95,96,97,98,99,2000,2001 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */

#ifndef _LIBC_INTERNAL_H
#define _LIBC_INTERNAL_H 1

#include <features.h>

#ifdef __UCLIBC_BUILD_RELRO__
# define attribute_relro __attribute__ ((section (".data.rel.ro")))
#else
# define attribute_relro
#endif

#ifdef __UCLIBC_HAS_THREADS_NATIVE__
# define attribute_tls_model_ie __attribute__ ((tls_model ("initial-exec")))
#endif

/* Pull in things like __attribute_used__ */
#include <sys/cdefs.h>

/* --- this is added to integrate linuxthreads */
/*#define __USE_UNIX98            1*/

#ifndef __ASSEMBLER__
# ifdef IS_IN_libc

#  define __need_size_t
#  include <stddef.h>

/* sources are built w/ _GNU_SOURCE, this gets undefined */
#ifdef __USE_GNU
extern int __xpg_strerror_r (int __errnum, char *__buf, size_t __buflen);
#else
extern char *__glibc_strerror_r (int __errnum, char *__buf, size_t __buflen);
#endif

/* #include <pthread.h> */
#  ifndef __UCLIBC_HAS_THREADS__
#   define __pthread_mutex_init(mutex, mutexattr)         ((void)0)
#   define __pthread_mutex_lock(mutex)                    ((void)0)
#   define __pthread_mutex_trylock(mutex)                 ((void)0)
#   define __pthread_mutex_unlock(mutex)                  ((void)0)
#   define _pthread_cleanup_push_defer(mutex)             ((void)0)
#   define _pthread_cleanup_pop_restore(mutex)            ((void)0)
#  endif

/* internal access to program name */
extern const char *__uclibc_progname attribute_hidden;

# endif /* IS_IN_libc */

/* #include <alloca.h> */
#include <bits/stackinfo.h>
#if defined(_STACK_GROWS_DOWN)
# define extend_alloca(buf, len, newlen) \
  (__typeof (buf)) ({ size_t __newlen = (newlen);			      \
		      char *__newbuf = alloca (__newlen);		      \
		      if (__newbuf + __newlen == (char *) buf)		      \
			len += __newlen;				      \
		      else						      \
			len = __newlen;					      \
		      __newbuf; })
#elif defined(_STACK_GROWS_UP)
# define extend_alloca(buf, len, newlen) \
  (__typeof (buf)) ({ size_t __newlen = (newlen);			      \
		      char *__newbuf = alloca (__newlen);		      \
		      char *__buf = (buf);				      \
		      if (__buf + __newlen == __newbuf)			      \
			{						      \
			  len += __newlen;				      \
			  __newbuf = __buf;				      \
			}						      \
		      else						      \
			len = __newlen;					      \
		      __newbuf; })
#else
# warning unknown stack
# define extend_alloca(buf, len, newlen) \
  alloca (((len) = (newlen)))
#endif

#endif /* __ASSEMBLER__ */

#endif /* _LIBC_INTERNAL_H */
