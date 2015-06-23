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

extern MCAPI_BUF_QUEUE      MCAPI_Buf_Wait_List;

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_pktchan_free
*
*   DESCRIPTION
*
*       Non-blocking API routine to return a system buffer.
*
*   INPUTS
*
*       *buffer                 A pointer to the buffer to return.
*       *mcapi_status           A pointer to memory that will be filled in
*                               with the status of the call.
*
*   OUTPUTS
*
*       The number of receive operations that are guaranteed to not block
*       waiting for incoming data.
*
*************************************************************************/
void mcapi_pktchan_free(void *buffer, mcapi_status_t *mcapi_status)
{
    MCAPI_BUFFER    *cur_buf;

    /* Validate mcapi_status input parameter. */
    if (mcapi_status)
    {
        /* Validate buffer input parameter. */
        if (buffer)
        {
            /* Get the lock. */
            mcapi_lock_node_data();

            /* Get a pointer to the first buffer on the wait list. */
            cur_buf = MCAPI_Buf_Wait_List.head;

            /* Find the buffer structure associated with this buffer. */
            while (cur_buf)
            {
                /* If the buffer matches the buffer being free. */
                if (cur_buf->buf_ptr == ((unsigned char*)buffer - MCAPI_HEADER_LEN))
                {
                    /* Remove this buffer from the Wait List. */
                    mcapi_remove(&MCAPI_Buf_Wait_List, cur_buf);

                    /* Return the buffer to the list of free buffers. */
                    ((MCAPI_INTERFACE*)(cur_buf->mcapi_dev_ptr))->
                        mcapi_recover_buffer(cur_buf);

                    break;
                }

                /* Get a pointer to the next buffer. */
                cur_buf = (MCAPI_BUFFER*)(cur_buf->next_buf);
            }

            /* The buffer was found on the list. */
            if (cur_buf)
            {
                *mcapi_status = MCAPI_SUCCESS;
            }

            /* The buffer was not found. */
            else
            {
                *mcapi_status = MCAPI_ERR_BUF_INVALID;
            }

            /* Release the lock. */
            mcapi_unlock_node_data();
        }

        /* The buffer is not valid. */
        else
        {
            *mcapi_status = MCAPI_ERR_BUF_INVALID;
        }
    }

}
