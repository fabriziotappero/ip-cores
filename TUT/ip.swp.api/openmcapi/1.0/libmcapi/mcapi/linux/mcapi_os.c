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

#include <openmcapi.h>

MCAPI_MUTEX MCAPI_Mutex;
pthread_t   MCAPI_Control_Task_TCB;

static inline long ms_to_s(long ms)
{
    return ms / 1000;
}

static inline long ns_to_s(long ns)
{
    return ns / 1000000000;
}

static inline long ms_to_ns(long ms)
{
    return ms * 1000000;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Init_OS
*
*   DESCRIPTION
*
*       Initializes OS specific data structures.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       MCAPI_SUCCESS
*       MCAPI_ERR_GENERAL
*
*************************************************************************/
mcapi_status_t MCAPI_Init_OS(void)
{
    int status;

    /* Create the task that will be used for receiving status
     * messages.
     */
    status = pthread_create(&MCAPI_Control_Task_TCB, NULL,
                            mcapi_process_ctrl_msg, NULL);

    if (status)
        return MCAPI_ERR_GENERAL;

    return MCAPI_SUCCESS;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Exit_OS
*
*   DESCRIPTION
*
*       Release OS specific data structures.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void MCAPI_Exit_OS(void)
{
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Resume_Task
*
*   DESCRIPTION
*
*       Resumes a suspended system task.
*
*   INPUTS
*
*       *request                The request structure on which the
*                               suspended task is suspended.
*
*   OUTPUTS
*
*       MCAPI_SUCCESS
*       MCAPI_ERR_GENERAL
*
*************************************************************************/
mcapi_status_t MCAPI_Resume_Task(mcapi_request_t *request)
{
    int status;

    /* If multiple requests are suspending on the same condition, we use
     * mcapi_cond_ptr. */
    if (request->mcapi_cond.mcapi_cond_ptr)
        status = pthread_cond_signal(request->mcapi_cond.mcapi_cond_ptr);
    else
        status = pthread_cond_signal(&request->mcapi_cond.mcapi_cond);

    if (status)
        return MCAPI_ERR_GENERAL;

    return MCAPI_SUCCESS;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Suspend_Task
*
*   DESCRIPTION
*
*       Suspends a system task.
*
*   INPUTS
*
*       *node_data              A pointer to the global node data
*                               structure.
*       *request                A pointer to the request associated
*                               with the thread being suspended.
*       *mcapi_os               A pointer to the OS specific structure
*                               containing suspend/resume data.
*       timeout                 The number of milliseconds to suspend
*                               pending completion of the request.
*
*   OUTPUTS
*
*       MCAPI_SUCCESS
*       MCAPI_ERR_GENERAL
*
*************************************************************************/
mcapi_status_t MCAPI_Suspend_Task(MCAPI_GLOBAL_DATA *node_data,
                                  mcapi_request_t *request,
                                  MCAPI_COND_STRUCT *condition,
                                  mcapi_timeout_t timeout)
{
    struct timespec ts;
    int status = 0;

    /* If a request structure was passed into the routine. */
    if (request)
    {
        /* Initialize the condition variable with default parameters. */
        status = pthread_cond_init(&request->mcapi_cond.mcapi_cond, NULL);

        if (status == 0)
        {
            /* Add the request to the queue of pending requests. */
            mcapi_enqueue(&node_data->mcapi_local_req_queue, request);
        }
    }

    if (status == 0)
    {
        /* If no timeout value was specified. */
        if (timeout == MCAPI_TIMEOUT_INFINITE)
        {
            status = pthread_cond_wait(&condition->mcapi_cond, &MCAPI_Mutex);
        }
        else
        {
            long subsecond_ms;
            long total_ns;

            clock_gettime(CLOCK_REALTIME, &ts);

            /* Add timeout to ts, accounting for nsec overflow. */
            subsecond_ms = timeout % 1000;
            total_ns = ts.tv_nsec + ms_to_ns(subsecond_ms);
            ts.tv_sec += ms_to_s(timeout) + ns_to_s(total_ns);
            ts.tv_nsec = total_ns % 1000000000;

            status = pthread_cond_timedwait(&condition->mcapi_cond,
                                            &MCAPI_Mutex, &ts);
        }

        /* Uninitialize the condition variable. */
        status = pthread_cond_destroy(&condition->mcapi_cond);
    }

    if (status)
        return MCAPI_ERR_GENERAL;

    return MCAPI_SUCCESS;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Cleanup_Task
*
*   DESCRIPTION
*
*       Terminates the current thread.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void MCAPI_Cleanup_Task(void)
{
    pthread_exit(NULL);
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Init_Condition
*
*   DESCRIPTION
*
*       Sets an OS specific condition for resuming a task in the future.
*
*   INPUTS
*
*       *os_cond                A pointer to the OS specific structure
*                               containing suspend/resume data.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void MCAPI_Init_Condition(MCAPI_COND_STRUCT *condition)
{
    /* Initialize the condition variable with default parameters. */
    pthread_cond_init(&condition->mcapi_cond, NULL);
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Set_Condition
*
*   DESCRIPTION
*
*       Sets an OS specific condition for resuming a task in the future.
*
*   INPUTS
*
*       *request                A request structure that will trigger
*                               a future task resume.
*       *os_cond                The condition to use for resuming the
*                               task.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void MCAPI_Set_Condition(mcapi_request_t *request, MCAPI_COND_STRUCT *condition)
{
    request->mcapi_cond.mcapi_cond_ptr = &condition->mcapi_cond;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Clear_Condition
*
*   DESCRIPTION
*
*       Clears a previously set OS condition.
*
*   INPUTS
*
*       *request                A request structure that will trigger
*                               a future task resume.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void MCAPI_Clear_Condition(mcapi_request_t *request)
{
    request->mcapi_cond.mcapi_cond_ptr = MCAPI_NULL;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Create_Mutex
*
*   DESCRIPTION
*
*       Creates a system mutex.
*
*   INPUTS
*
*       *mutex                  Pointer to the mutex control block.
*       *name                   Name of the mutex.
*
*   OUTPUTS
*
*       MCAPI_SUCCESS
*
*************************************************************************/
mcapi_status_t MCAPI_Create_Mutex(MCAPI_MUTEX *mutex, char *name)
{
    int status;

    status = pthread_mutex_init(mutex, NULL);

    if (status)
        return MCAPI_ERR_GENERAL;

    return MCAPI_SUCCESS;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Delete_Mutex
*
*   DESCRIPTION
*
*       Destroyes a system mutex.
*
*   INPUTS
*
*       *mutex                  Pointer to the mutex control block.
*
*   OUTPUTS
*
*       MCAPI_SUCCESS
*       MCAPI_ERR_GENERAL
*
*************************************************************************/
mcapi_status_t MCAPI_Delete_Mutex(MCAPI_MUTEX *mutex)
{
    int status;

    status = pthread_mutex_destroy(mutex);

    if (status)
        return MCAPI_ERR_GENERAL;

    return MCAPI_SUCCESS;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Obtain_Mutex
*
*   DESCRIPTION
*
*       Obtains a system mutex.
*
*   INPUTS
*
*       *mutex              Pointer to the mutex control block.
*
*   OUTPUTS
*
*       MCAPI_SUCCESS
*       MCAPI_ERR_GENERAL
*
*************************************************************************/
mcapi_status_t MCAPI_Obtain_Mutex(MCAPI_MUTEX *mutex)
{
    int status;

    status = pthread_mutex_lock(mutex);

    if (status)
        return MCAPI_ERR_GENERAL;

    return MCAPI_SUCCESS;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Release_Mutex
*
*   DESCRIPTION
*
*       Releases a system mutex.
*
*   INPUTS
*
*       *mutex              Pointer to the mutex control block.
*
*   OUTPUTS
*
*       MCAPI_SUCCESS
*       MCAPI_ERR_GENERAL
*
*************************************************************************/
mcapi_status_t MCAPI_Release_Mutex(MCAPI_MUTEX *mutex)
{
    int status;

    status = pthread_mutex_unlock(mutex);

    if (status)
        return MCAPI_ERR_GENERAL;

    return MCAPI_SUCCESS;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Set_RX_Event
*
*   DESCRIPTION
*
*       Sets an event indicating that data is ready to be received.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       MCAPI_SUCCESS
*
*************************************************************************/
mcapi_status_t MCAPI_Set_RX_Event(void)
{
    mcapi_rx_data();

    return MCAPI_SUCCESS;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Lock_RX_Queue
*
*   DESCRIPTION
*
*       Protect RX queue from concurrent accesses.  No work is required
*       in this routine since Linux receives data from the context of
*       the driver RX thread.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       Unused.
*
*************************************************************************/
mcapi_int_t MCAPI_Lock_RX_Queue(void)
{
    return 0;
}

/*************************************************************************
*
*   FUNCTION
*
*       MCAPI_Unlock_RX_Queue
*
*   DESCRIPTION
*
*       Protect RX queue from concurrent accesses.  No work is required
*       in this routine since Linux receives data from the context of
*       the driver RX thread.
*
*   INPUTS
*
*       cookie                  Unused.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void MCAPI_Unlock_RX_Queue(mcapi_int_t cookie)
{
}

void MCAPI_Sleep(unsigned int secs)
{
	/* XXX We can use select() to implement sub-second sleeps in the future. */
    sleep(secs);
}

