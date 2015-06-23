/*
 * Copyright (c) 2010, Mentor Graphics Corporation
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

/************************************************************************
*
*   FILENAME
*
*       os_linux_demo.c
*
*
*************************************************************************/
#include <pthread.h>
#include <signal.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include "mcapid.h"
#include "support_suite/mcapid_support.h"

extern int mcapi_test_start(int argc, char *argv[]);

static struct sigaction oldactions[32];

static void cleanup(void)
{
	mcapi_status_t status;

	mcapi_finalize(&status);
}

static void signalled(int signal, siginfo_t *info, void *context)
{
	struct sigaction *action;

	action = &oldactions[signal];

	if ((action->sa_flags & SA_SIGINFO) && action->sa_sigaction)
		action->sa_sigaction(signal, info, context);
	else if (action->sa_handler)
		action->sa_handler(signal);

	exit(signal);
}

struct sigaction action = {
	.sa_sigaction = signalled,
	.sa_flags = SA_SIGINFO,
};

int main(int argc, char *argv[])
{
	atexit(cleanup);
	sigaction(SIGQUIT, &action, &oldactions[SIGQUIT]);
	sigaction(SIGABRT, &action, &oldactions[SIGABRT]);
	sigaction(SIGTERM, &action, &oldactions[SIGTERM]);
	sigaction(SIGINT,  &action, &oldactions[SIGINT]);

    return mcapi_test_start(argc, argv);
}

mcapi_status_t MCAPID_Create_Thread(MCAPI_THREAD_PTR_ENTRY(thread_entry),
                                    MCAPID_STRUCT *mcapi_struct)
{
    mcapi_status_t status = MCAPI_SUCCESS;
    int rc;

    /* Initialize the state. */
    mcapi_struct->state = -1;

    rc = pthread_create(&mcapi_struct->task_ptr, NULL,
                        thread_entry, (void*)mcapi_struct);

    if (rc)
        status = MCAPI_ERR_GENERAL;

    mcapi_struct->status = status;

    return status;
}

/************************************************************************
*
*   FUNCTION
*
*       MCAPID_Cleanup
*
*   DESCRIPTION
*
*       This routine destroys a Linux thread.  Since Linux threads
*       are destroyed upon completion, there is no work required
*       of this routine.
*
*************************************************************************/
void MCAPID_Cleanup(MCAPID_STRUCT *mcapi_struct)
{
    /* Delete the local endpoint. */
    mcapi_delete_endpoint(mcapi_struct->local_endp, &mcapi_struct->status);

} /* MCAPID_Cleanup */

void MCAPID_Sleep(unsigned ms)
{
    usleep(ms * 1000);
}

/* Number of seconds since a fixed time. */
unsigned long MCAPID_Time(void)
{
    return (unsigned long)time(NULL);
}
