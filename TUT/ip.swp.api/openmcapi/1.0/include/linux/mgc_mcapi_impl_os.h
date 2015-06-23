/*
 * Copyright (c) 2011, Mentor Graphics Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of the <ORGANIZATION> nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */


#ifndef MCAPI_OS_LINUX_H
#define MCAPI_OS_LINUX_H

#include <stdint.h>
#include <pthread.h>

/* XXX include these directly from files that actually need them */
#include <string.h>
#include <unistd.h>

/********************* Porting Section **************************/

/* This type must match across all reachable nodes in the system.
 * This type is used within the MCAPI_BUFFER data structure to represent
 * data pointers in that structure.  Since the MCAPI_BUFFER structure
 * is shared across reachable nodes, this type must be consistent.
 */
typedef uint32_t      MCAPI_POINTER;

typedef pthread_cond_t      mcapi_cond_t;
typedef pthread_mutex_t     MCAPI_MUTEX;
typedef pthread_t           MCAPI_THREAD;

#define MCAPI_THREAD_ENTRY(f)       void *f(void *argv)
#define MCAPI_THREAD_PTR_ENTRY(f)   void *(*f)(void *argv)

/********************* End Porting Section **********************/

extern MCAPI_MUTEX          MCAPI_RX_Lock;

#endif  /* MCAPI_OS_LINUX_H */
