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

typedef struct MCAPI_QNode_Struct
{
    struct MCAPI_QNode_Struct      *flink;
    struct MCAPI_QNode_Struct      *blink;
} MCAPI_QNODE;

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_enqueue
*
*   DESCRIPTION
*
*       Enqueues an entry onto a given queue.
*
*   INPUTS
*
*       *queue_ptr              Pointer to the queue to which the entry
*                               is being enqueued.
*       *entry                  Pointer to the new queue entry.
*
*   OUTPUTS
*
*       None.
*
*************************************************************************/
void mcapi_enqueue(void *queue_ptr, void *entry)
{
    MCAPI_QNODE     *hdr = queue_ptr;
    MCAPI_QNODE     *item = entry;

    /* Set item's flink to point at NULL */
    item->flink = MCAPI_NULL;

    /* If there is currently a node in the linked list, we want add
     * item after that node
     */
    if (hdr->flink)
    {
        /* Make the last node's flink point to item */
        hdr->blink->flink = item;

        /* Make item's blink point to the old last node */
        item->blink = hdr->blink;

        /* Make hdr's blink point to the new last node, item */
        hdr->blink = item;
    }

    /* If the linked list was empty, we want both the hdr's flink and
     * the hdr's blink to point to item.  Both of item's links will
     * point to NULL, as there are no other nodes in the list
     */
    else
    {
        hdr->flink = hdr->blink = item;
        item->blink = MCAPI_NULL;
    }

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_remove
*
*   DESCRIPTION
*
*       Removes an entry from a given queue.
*
*   INPUTS
*
*       *queue_ptr              Pointer to the queue from which the entry
*                               is being removed.
*       *entry                  Pointer to the queue entry to remove.
*
*   OUTPUTS
*
*       A pointer to the item that was removed.
*
*************************************************************************/
void *mcapi_remove(void *queue_ptr, void *entry)
{
    MCAPI_QNODE     *hdr = queue_ptr;
    MCAPI_QNODE     *item = entry;
    MCAPI_QNODE     *ent;

    /*  Search the linked list until item is found or the end of the list
     *  is reached.
     */
    for (ent = hdr->flink;( (ent) && (ent != item) ); ent = ent->flink)
        ;

    /*  If the item was found. */
    if (ent)
    {
        /* If we are deleting the list head, this is just a dequeue operation */
        if (hdr->flink == item)
            mcapi_dequeue(hdr);

        /*  If we are deleting the list tail, we need to reset the tail pointer
         *  and make the new tail point forward to 0.
         */
        else if (hdr->blink == item)
        {
            hdr->blink = item->blink;
            hdr->blink->flink = MCAPI_NULL;
        }

        /* We are removing this entry from the middle of the list */
        else
        {
            item->blink->flink = item->flink;
            item->flink->blink = item->blink;
        }
    }

    return (ent);

}

/*************************************************************************
*
*   FUNCTION
*
*       mcapi_dequeue
*
*   DESCRIPTION
*
*       Removes and returns the first entry in a queue.
*
*   INPUTS
*
*       *queue_ptr              Pointer to the queue from which the entry
*                               is being removed.
*
*   OUTPUTS
*
*       Pointer to the entry removed from the queue.
*
*************************************************************************/
void *mcapi_dequeue(void *queue_ptr)
{
   MCAPI_QNODE *hdr = queue_ptr;
   MCAPI_QNODE *ent;

   /* Create a pointer to the first node in the linked list */
   ent = hdr->flink;

   /* If there is a node in the list we want to remove it. */
   if (ent)
   {
       /* Make the hdr point the second node in the list */
       hdr->flink = ent->flink;

       /*  If there was a second node, we want that node's blink to at 0. */
       if (hdr->flink)
           hdr->flink->blink = MCAPI_NULL;

       /* Clear the next and previous pointers.*/
       ent->flink = ent->blink = MCAPI_NULL;
   }

   /* Return a pointer to the removed node */
   return (ent);

}  /* mcapi_dequeue */
