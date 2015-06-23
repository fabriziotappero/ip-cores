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


//#define   MCAPI_SM_DBG_SUPPORT

#include <mcapi.h>
#include <openmcapi.h>
#include <atomic.h>
#include "shm.h"
#include "shm_os.h"

#ifdef MCAPI_SM_DBG_SUPPORT
#include <stdio.h>
#endif

#define LOCK   1
#define UNLOCK 0


SHM_MGMT_BLOCK*  SHM_Mgmt_Blk = MCAPI_NULL;
SHM_BUFFER*      SHM_Buff_Array_Ptr;
MCAPI_INTERFACE* SHM_Current_Interface_Ptr;


extern MCAPI_BUF_QUEUE MCAPI_RX_Queue[MCAPI_PRIO_COUNT];
extern mcapi_node_t MCAPI_Node_ID;


static void shm_acquire_lock(shm_lock* plock)
{
	const int lockVal = LOCK;
	unsigned int retVal;

	do {
		retVal = xchg(plock, lockVal);
	} while (retVal==lockVal);
}

static void shm_release_lock(shm_lock* plock)
{
	mb();

	*plock = UNLOCK;
}

static mcapi_uint32_t get_first_zero_bit(mcapi_int_t value)
{
	mcapi_uint32_t idx;
	mcapi_uint32_t tmp32;

	/* Invert value */
	value = ~value;

	/* (~value) & (2's complement of value) */
	value = (value & (-value)) - 1;

	/* log2(value) */

	tmp32 = value - ((value >> 1) & 033333333333)- ((value >> 2) & 011111111111);

	idx = ((tmp32 + (tmp32 >> 3))& 030707070707) % 63;

	/* Obtain index (compiler optimized ) */
	//GET_IDX(idx,value);

	return idx;
}

static mcapi_status_t get_sm_buff_index(mcapi_uint32_t* p_idx)
{
	mcapi_uint32_t i, tmp32;
	mcapi_status_t status = MCAPI_ERR_TRANSMISSION;

	/* Find first available buffer */
	for (i = 0; i < BITMASK_WORD_COUNT; i++)
	{
		tmp32 = get_first_zero_bit(SHM_Mgmt_Blk->shm_buff_mgmt_blk.buff_bit_mask[i]);

		if (tmp32 < BITMASK_WORD_SIZE)
		{
			/* Calculate absolute index of the available buffer */
			*p_idx = tmp32 + (i * BITMASK_WORD_SIZE);

			/* Mark the buffer taken */
			SHM_Mgmt_Blk->shm_buff_mgmt_blk.buff_bit_mask[i] |= 1 << tmp32;

			status = MCAPI_SUCCESS;

			break;
		}
	}

	return status;
}

static void clear_sm_buff_index(mcapi_uint32_t idx)
{
	mcapi_uint32_t *word;
	mcapi_uint32_t bit_msk_idx = idx/BITMASK_WORD_SIZE;
	mcapi_uint8_t  bit_idx = idx%BITMASK_WORD_SIZE;

	/* Mark the buffer available */
	word = &SHM_Mgmt_Blk->shm_buff_mgmt_blk.buff_bit_mask[bit_msk_idx];
	*word ^= 1 << bit_idx;
}

/*************************************************************************
*
*   FUNCTION
*
*       shm_get_buffer
*
*   DESCRIPTION
*
*       Obtain a Shared memory driver buffer.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       MCAPI_BUFFER*       Pointer to allocated MCAPI buffer
*
*************************************************************************/
static MCAPI_BUFFER* shm_get_buffer(mcapi_node_t node_id, size_t size,
                                    mcapi_uint32_t priority)
{
	mcapi_uint32_t  idx;
	SHM_BUFFER*     p_sm_buff = MCAPI_NULL;
	MCAPI_BUFFER*   p_mcapi_buff = MCAPI_NULL;
	mcapi_status_t  status = MCAPI_SUCCESS;

	/* Acquire lock of SM buffer management block */
	shm_acquire_lock(&SHM_Mgmt_Blk->shm_buff_mgmt_blk.lock);

	/* Check if obtained buff index is less than the buff count */
	if ((priority == SHM_PRIO_0) ||
		(SHM_Mgmt_Blk->shm_buff_mgmt_blk.shm_buff_count <= SHM_LOW_PRI_BUF_CONT))
	{
		for (idx = 0; idx < CONFIG_SHM_NR_NODES; idx++)
		{
			if (SHM_Mgmt_Blk->shm_routes[idx].node_id == node_id)
			{
				/* Obtain the index of the first available SM buffer */
				status = get_sm_buff_index(&idx);

#ifdef MCAPI_SM_DBG_SUPPORT
				printf("Get buffer - priority  = %d \r\n",priority);
				printf("Get buffer - obtained buffer index  = %d \r\n",idx);
#endif

				if (status == MCAPI_SUCCESS)
				{
					/* Obtain the address of the SM buffer for the index */
					p_sm_buff = (SHM_BUFFER*)OFFSET_TO_ADDRESS(SHM_Mgmt_Blk->shm_buff_mgmt_blk.shm_buff_base_offset + (sizeof(SHM_BUFFER)* idx));

					/* Obtain pointer to MCAPI buffer */
					p_mcapi_buff = &p_sm_buff->mcapi_buff;

					/* increment used buffer count */
					SHM_Mgmt_Blk->shm_buff_mgmt_blk.shm_buff_count++;

					break;
				}
			}
		}
	}

	/* Release lock of SM buffer management block */
	shm_release_lock(&SHM_Mgmt_Blk->shm_buff_mgmt_blk.lock);

	/* Return a MCAPI buffer to the caller */
	return p_mcapi_buff;
}

/*************************************************************************
*
*   FUNCTION
*
*       shm_free_buffer
*
*   DESCRIPTION
*
*       Free shared memory buffer.
*
*   INPUTS
*
*       SHM_BUFFER*          Pointer to SM buffer
*
*   OUTPUTS
*
*       None
*
*************************************************************************/
static void shm_free_buffer(MCAPI_BUFFER* buff)
{
	mcapi_uint32_t idx;

	/* Obtain the index of the buffer */
	idx = *((mcapi_uint32_t*)((mcapi_uint32_t)buff - (sizeof(mcapi_uint32_t))));

	shm_acquire_lock(&SHM_Mgmt_Blk->shm_buff_mgmt_blk.lock);

	/* Mark the buffer available */
	clear_sm_buff_index(idx);

	/* Decrement used buffer count */
	SHM_Mgmt_Blk->shm_buff_mgmt_blk.shm_buff_count--;

	shm_release_lock(&SHM_Mgmt_Blk->shm_buff_mgmt_blk.lock);

#ifdef MCAPI_SM_DBG_SUPPORT
	printf("Free buffer - freed index  = %d \r\n",idx);
#endif
}

/*************************************************************************
*
*   FUNCTION
*
*       get_sm_ring_q
*
*   DESCRIPTION
*
*       Obtain the SM packet descriptor ring queue for the node ID
*       requested.
*
*   INPUTS
*
*       mcapi_uint32_t      Destination node ID
*       mcapi_uint32_t*     Pointer to unit ID for the destination node
*
*   OUTPUTS
*
*       SHM_BUFF_DESC_Q*     Pointer to SM ring queue for requested node ID.
*
*************************************************************************/
static SHM_BUFF_DESC_Q* get_sm_ring_q(mcapi_uint32_t node_id,
                                      mcapi_uint32_t *p_unit_id)
{
	int idx;
	mcapi_uint32_t unit_id;
	SHM_BUFF_DESC_Q* p_sm_ring_queue = MCAPI_NULL;

	/* Look up routes for the requested node ID
	 * and obtain the corresponding unit ID and SM ring queue */

	for (idx = 0; idx < CONFIG_SHM_NR_NODES; idx++)
	{
		if (SHM_Mgmt_Blk->shm_routes[idx].node_id == node_id)
		{
			unit_id = SHM_Mgmt_Blk->shm_routes[idx].unit_id;

			/* Load unit ID for the caller */
			*p_unit_id = unit_id;

			/* Obtain pointer to ring queue */
			p_sm_ring_queue = &SHM_Mgmt_Blk->shm_queues[node_id];

			break;
		}
	}

	/* Return pointer to SM ring queue for the unit ID identified */
	return p_sm_ring_queue;
}

/*************************************************************************
*
*   FUNCTION
*
*       enqueue_sm_ring_q
*
*   DESCRIPTION
*
*       Enqueue a transmission request to the SM descriptor ring queue.
*
*   INPUTS
*
*       SHM_BUFF_DESC_Q*     Pointer to the SM packet descriptor queue
*       mcapi_uint16_t      Destination node ID
*       SHM_BUFFER*          Pointer to the SM buffer (payload)
*       size_t              Size of the SM buffer (payload)
*       mcapi_uint8_t       Message type
*
*   OUTPUTS
*
*       mcapi_status_t      status of attempt to enqueue.
*
*************************************************************************/
static mcapi_status_t enqueue_sm_ring_q(SHM_BUFF_DESC_Q *shm_des_q,
                                        mcapi_node_t node_id,
                                        MCAPI_BUFFER *buff,
                                        mcapi_priority_t priority,
                                        size_t buff_size, mcapi_uint8_t type)
{
	mcapi_uint32_t idx;
	mcapi_status_t status = MCAPI_SUCCESS;
	SHM_BUFF_DESC* shm_desc;

	/* Acquire lock of the SM packet descriptor queue */
	shm_acquire_lock(&shm_des_q->lock);

	/* Obtain put index into the queue */
	idx = shm_des_q->put_idx;

	if (shm_des_q->count == SHM_BUFF_DESC_Q_SIZE)
	{
		/* Queue is full fail denqueue operation */
		status = MCAPI_ERR_TRANSMISSION;
	}
	else
	{
		/* Load packet descriptor */
		shm_desc = &shm_des_q->pkt_desc_q[idx];
		shm_desc->priority = priority;
		shm_desc->type = type;
		shm_desc->value = ADDRESS_TO_OFFSET(buff);

		shm_des_q->put_idx = (shm_des_q->put_idx + 1) % SHM_BUFF_DESC_Q_SIZE;
		shm_des_q->count++;

		/* Enqueue operation successfully completed */
		status = MCAPI_SUCCESS;
	}

	/* Release lock of the SM packet descriptor queue */
	shm_release_lock(&shm_des_q->lock);

	return status;
}

/*************************************************************************
*
*   FUNCTION
*
*       shm_tx
*
*   DESCRIPTION
*
*       Transmit data using SM driver.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       mcapi_status_t      Return status of initialization
*
*************************************************************************/
static mcapi_status_t shm_tx(MCAPI_BUFFER *buffer, size_t buffer_size,
                             mcapi_priority_t priority,
                             struct _mcapi_endpoint *tx_endpoint)
{
	SHM_BUFF_DESC_Q* shm_q;
	mcapi_uint32_t  unit_id;
	mcapi_uint32_t	node_id;
	mcapi_status_t  status = MCAPI_SUCCESS;

#ifdef MCAPI_SM_DBG_SUPPORT
	mcapi_uint32_t  add = (mcapi_uint32_t)buffer;
	printf("TX buffer - transmitting buffer address  = %x \r\n",add);
	printf("TX buffer - transmitting buffer size     = %d \r\n",buffer_size);
	printf("TX buffer - transmitting buffer priority = %d \r\n",priority);
#endif

	/* Obtain SM ring queue for the destination node ID */
	node_id = tx_endpoint->mcapi_foreign_node_id;
	shm_q = get_sm_ring_q(node_id, &unit_id);

	if (shm_q)
	{
		/* Enqueue request to transmit data */
		status = enqueue_sm_ring_q(shm_q, node_id, buffer, priority,
			buffer_size, tx_endpoint->mcapi_chan_type);

		/* Resume Tasks suspensed on TX */
		mcapi_check_resume(MCAPI_REQ_TX_FIN, tx_endpoint->mcapi_endp_handle,
						   MCAPI_NULL, (buffer->buf_size - MCAPI_HEADER_LEN), status);

		/* Start data transmission */
		if (status == MCAPI_SUCCESS)
		{
			status = openmcapi_shm_notify(unit_id, node_id);

#ifdef MCAPI_SM_DBG_SUPPORT
			printf("TX buffer - TX success \r\n");
#endif
		}
	}
	else
	{
		/* TX request to unrecognized node ID */
		status = MCAPI_ERR_NODE_NOTINIT;

#ifdef MCAPI_SM_DBG_SUPPORT
		printf("TX buffer - TX Failed \r\n");
#endif
	}

	return status;

}

/*************************************************************************
*
*   FUNCTION
*
*       shm_finalize
*
*   DESCRIPTION
*
*       Finalization sequence for SM driver.
*
*   INPUTS
*
*       mcapi_node_t    Local node ID.
*
*       SHM_MGMT_BLOCK*  Pointer to SM driver management.
*       structure
*
*   OUTPUTS
*
*       mcapi_status_t          Initialization status.
*
*************************************************************************/
static mcapi_status_t shm_finalize(mcapi_node_t node_id,
                                   SHM_MGMT_BLOCK *SHM_Mgmt_Blk)
{
	int i;
	mcapi_status_t status = MCAPI_ERR_NODE_INITFAILED;

	for (i = 0; i < CONFIG_SHM_NR_NODES; i++)
	{
		if (SHM_Mgmt_Blk->shm_routes[i].node_id == node_id)
		{
			status = MCAPI_SUCCESS;

			SHM_Mgmt_Blk->shm_routes[i].node_id = SHM_INVALID_NODE;

			SHM_Mgmt_Blk->shm_routes[i].unit_id = SHM_INVALID_SCH_UNIT;

			break;
		}
	}

	/* Return finalization status */
	return status;
}

/*************************************************************************
*
*   FUNCTION
*
*       shm_ioctl
*
*   DESCRIPTION
*
*       IOCTL routine for the shared memory driver interface.
*
*   INPUTS
*
*       optname                 The name of the IOCTL option.
*       *option                 A pointer to memory that will be
*                               filled in if this is a GET option
*                               or the new value if this is a SET
*                               option.
*       optlen                  The length of the memory at option.
*
*   OUTPUTS
*
*       MCAPI_SUCCESS           The call was successful.
*       MCAPI_ERR_ATTR_NUM         Unrecognized option.
*       MCAPI_ERR_ATTR_SIZE        The size of option is invalid.
*
*************************************************************************/
static mcapi_status_t shm_ioctl(mcapi_uint_t optname, void *option,
                                size_t optlen)
{
	mcapi_status_t status = MCAPI_SUCCESS;

	switch (optname)
	{
		/* The total number of buffers in the system. */
		case MCAPI_ATTR_NO_BUFFERS:

			/* Ensure the buffer can hold the value. */
			if (optlen >= sizeof(mcapi_uint32_t))
				*(mcapi_uint32_t *)option = SHM_BUFF_COUNT;
			else
				status = MCAPI_ERR_ATTR_SIZE;

			break;

		/* The maximum size of an interface buffer. */
		case MCAPI_ATTR_BUFFER_SIZE:

			/* Ensure the buffer can hold the value. */
			if (optlen >= sizeof(mcapi_uint32_t))
				*(mcapi_uint32_t *)option = MCAPI_MAX_DATA_LEN;
			else
				status = MCAPI_ERR_ATTR_SIZE;

			break;

		/* The number of buffers available for receiving data. */
		case MCAPI_ATTR_RECV_BUFFERS_AVAILABLE:

			/* Ensure the buffer can hold the value. */
			if (optlen >= sizeof(mcapi_uint32_t))
				*(mcapi_uint32_t *)option = SHM_Mgmt_Blk->shm_buff_mgmt_blk.shm_buff_count;
			else
				status = MCAPI_ERR_ATTR_SIZE;

			break;

		/* The number of buffers available for receiving data. */
		case MCAPI_ATTR_NO_PRIORITIES:

			/* Ensure the buffer can hold the value. */
			if (optlen >= sizeof(mcapi_uint32_t))
				*(mcapi_uint32_t *)option = SHM_NUM_PRIORITIES;
			else
				status = MCAPI_ERR_ATTR_SIZE;

			break;

		/* The number of buffers available for receiving data. */
		case MCAPI_FINALIZE_DRIVER:

			/* Finalize OS layer */
			status = openmcapi_shm_os_finalize();

			if (status == MCAPI_SUCCESS)
			{
				/* Finalize SM driver */
				status = shm_finalize(MCAPI_Node_ID, SHM_Mgmt_Blk);
			}

			if (status == MCAPI_SUCCESS)
			{
				/* Unmap SM device */
				openmcapi_shm_unmap((void*)SHM_Mgmt_Blk);
			}

			break;

		default:

			status = MCAPI_ERR_ATTR_NUM;
			break;
	}

	return status;
}

/*************************************************************************
*
*   FUNCTION
*
*       shm_master_node_init
*
*   DESCRIPTION
*
*       Initialize Shared memory driver as the Master node.
*
*   INPUTS
*
*       mcapi_node_t    Local node ID.
*
*       SHM_MGMT_BLOCK*  Pointer to SM driver management.
*       structure
*
*   OUTPUTS
*
*       mcapi_status_t              Initialization status.
*
*************************************************************************/
static mcapi_status_t shm_master_node_init(mcapi_node_t node_id,
                                           SHM_MGMT_BLOCK* SHM_Mgmt_Blk)
{
	int i;
	mcapi_status_t status = MCAPI_SUCCESS;

	/* The current node is the first node executing in the system.
	 * Initialize SM driver as master node. */

	/* Initialize routes and SM buffer queue data structures */
	for (i = 0; i < CONFIG_SHM_NR_NODES; i++)
	{
		/* Initialize routes */
		SHM_Mgmt_Blk->shm_routes[i].node_id = SHM_INVALID_NODE;
		SHM_Mgmt_Blk->shm_routes[i].unit_id = SHM_INVALID_SCH_UNIT;
	}

	/* Initialize the base of shared memory buffers  */
	SHM_Buff_Array_Ptr = (SHM_BUFFER*)((((mcapi_uint32_t)SHM_Mgmt_Blk & (~(SHM_4K_ALIGN_SIZE - 1))) + SHM_4K_ALIGN_SIZE));

	/* Obtain the offset of the SM buffer space */
	SHM_Mgmt_Blk->shm_buff_mgmt_blk.shm_buff_base_offset = ADDRESS_TO_OFFSET(SHM_Buff_Array_Ptr);

	/* Initialize all SM buffers */
	for (i = 0; i < SHM_BUFF_COUNT; i++)
	{
		/* Initialize index and offset */
		SHM_Buff_Array_Ptr[i].idx = i;
	}

	/* Make all SM buffers available */
	for (i = 0; i < BITMASK_WORD_COUNT; i++)
	{
		SHM_Mgmt_Blk->shm_buff_mgmt_blk.buff_bit_mask[i] = 0;
	}

	/* Initialize used buff count */

	SHM_Mgmt_Blk->shm_buff_mgmt_blk.shm_buff_count = 0;

	/* Load the route for the current node */
	SHM_Mgmt_Blk->shm_routes[0].node_id = node_id;
	SHM_Mgmt_Blk->shm_routes[0].unit_id = openmcapi_shm_schedunitid();

	/* Load shared memory initialization complete key */
	SHM_Mgmt_Blk->shm_init_field = SHM_INIT_COMPLETE_KEY;

	/* Return master node initialization status */
	return status;
}

/*************************************************************************
*
*   FUNCTION
*
*       shm_slave_node_init
*
*   DESCRIPTION
*
*       Initialization sequence for SM driver for a slave node.
*
*   INPUTS
*
*       mcapi_node_id   Local node ID.
*
*       SHM_MGMT_BLOCK*  Pointer to SM driver management structure.
*
*   OUTPUTS
*
*       mcapi_status_t          Initialization status.
*
*************************************************************************/
static mcapi_status_t shm_slave_node_init(mcapi_node_t node_id,
                                          SHM_MGMT_BLOCK* SHM_Mgmt_Blk)
{
	int i;
	mcapi_status_t status = MCAPI_SUCCESS;

	/* SM driver has already been initialized by the master node */
	/* Perform slave initialization of SM driver */

	/* Make sure the current node has not been initialized */
	for (i = 0; i < CONFIG_SHM_NR_NODES; i++)
	{
		if (SHM_Mgmt_Blk->shm_routes[i].node_id == node_id)
		{
			status = MCAPI_ERR_NODE_INITFAILED;

			break;
		}
	}

	if (status == MCAPI_SUCCESS)
	{
		/* Load the route for the current node */
		for (i = 0; i < CONFIG_SHM_NR_NODES; i++)
		{
			if (SHM_Mgmt_Blk->shm_routes[i].node_id == SHM_INVALID_NODE)
			{
				SHM_Mgmt_Blk->shm_routes[i].node_id = node_id;

				SHM_Mgmt_Blk->shm_routes[i].unit_id = openmcapi_shm_schedunitid();

				break;
			}
		}

	}

	/* Return slave node initialization status */
	return status;
}

/*************************************************************************
*
*   FUNCTION
*
*       openmcapi_shm_init
*
*   DESCRIPTION
*
*       Initialize the Shared Memory driver interface.
*
*   INPUTS
*
*       None.
*
*   OUTPUTS
*
*       mcapi_status_t  Return status of initialization
*
*************************************************************************/
mcapi_status_t openmcapi_shm_init(mcapi_node_t node_id,
                                  MCAPI_INTERFACE* int_ptr)
{
	mcapi_status_t status = MCAPI_SUCCESS;

	if (node_id >= CONFIG_SHM_NR_NODES)
		return MCAPI_ERR_NODE_INVALID;

	/* Store the name of this interface. */
	memcpy(int_ptr->mcapi_int_name, OPENMCAPI_SHM_NAME, MCAPI_INT_NAME_LEN);

	/* Set the maximum buffer size for incoming / outgoing data. */
	int_ptr->mcapi_max_buf_size = MCAPI_MAX_DATA_LEN;

	/* Set up function pointers for sending data, reserving an outgoing
	 * driver buffer, returning the buffer to the free list, and
	 * issuing ioctl commands.
	 */
	int_ptr->mcapi_tx_output = shm_tx;
	int_ptr->mcapi_get_buffer = shm_get_buffer;
	int_ptr->mcapi_recover_buffer = shm_free_buffer;
	int_ptr->mcapi_ioctl = shm_ioctl;

	/* Obtain Shared memory base address */
	SHM_Mgmt_Blk = openmcapi_shm_map();

	if (SHM_Mgmt_Blk != MCAPI_NULL)
	{
		/* Initialize OS specific component */
		openmcapi_shm_os_init();

		/* Obtain SM driver initialization lock */
		shm_acquire_lock(&SHM_Mgmt_Blk->shm_init_lock);

		/* Has another node completed SM driver initialization */
		if (SHM_Mgmt_Blk->shm_init_field != SHM_INIT_COMPLETE_KEY)
		{
			/* Initialize SM driver as the Master node */
			status = shm_master_node_init(node_id, SHM_Mgmt_Blk);
		}
		else
		{
			/* Initialize SM driver as the Slave node */
			status = shm_slave_node_init(node_id, SHM_Mgmt_Blk);
		}

		/* Release SM driver initialization lock */
		shm_release_lock(&SHM_Mgmt_Blk->shm_init_lock);
	}
	else
	{
		status = MCAPI_ERR_GENERAL;
	}

	/* Obtain pointer to the local interface */
	SHM_Current_Interface_Ptr = int_ptr;

	/* Return status to caller */
	return status;
}

/* Return the first pending descriptor, or NULL. */
static SHM_BUFF_DESC* shm_desc_get_next(SHM_BUFF_DESC_Q* shm_des_q)
{
	if (shm_des_q->count)
		return &shm_des_q->pkt_desc_q[shm_des_q->get_idx];

	return MCAPI_NULL;
}

/* Make the first pending descriptor available to producers again. */
static void shm_desc_consume(SHM_BUFF_DESC_Q* shm_des_q)
{
	shm_acquire_lock(&shm_des_q->lock);

	/* Update index and count */
	shm_des_q->get_idx =  (shm_des_q->get_idx +1) % SHM_BUFF_DESC_Q_SIZE;
	shm_des_q->count--;

	shm_release_lock(&shm_des_q->lock);
}

/*************************************************************************
*
*   FUNCTION
*
*       shm_poll
*
*   DESCRIPTION
*
*       RX HISR for the shared memory driver.
*
*   INPUTS
*
*       None
*
*   OUTPUTS
*
*       None
*
*************************************************************************/
void shm_poll(void)
{
	SHM_BUFF_DESC_Q* shm_des_q;
	SHM_BUFF_DESC*   shm_des;
	MCAPI_BUFFER*    rcvd_pkt;
	int              got_data = 0;

#ifdef MCAPI_SM_DBG_SUPPORT
	mcapi_uint32_t  add;
	printf("Received data\r\n");
#endif

	/* Obtain the SM ring queue for the current Node ID */
	shm_des_q = &SHM_Mgmt_Blk->shm_queues[MCAPI_Node_ID];

	/* Enqueue all available data packets for this node */
	for (;;)
	{
		/* Get next available SM buffer descriptor */
		shm_des = shm_desc_get_next(shm_des_q);

		if (shm_des != MCAPI_NULL)
		{
			if (shm_des->priority < SHM_NUM_PRIORITIES)
			{
				/* Check packet type */
				if ((shm_des->type == MCAPI_MSG_TYPE) || \
					(shm_des->type == MCAPI_CHAN_PKT_TYPE) || \
					(shm_des->type == MCAPI_CHAN_SCAL_TYPE))
				{
					/* Packet buffer handling */
					rcvd_pkt = (MCAPI_BUFFER*)OFFSET_TO_ADDRESS(shm_des->value);

					/* Load current SM interface pointer */
					rcvd_pkt->mcapi_dev_ptr = (MCAPI_POINTER)SHM_Current_Interface_Ptr;

					/* Enqueue the packet received to the global queue */
					mcapi_enqueue(&MCAPI_RX_Queue[shm_des->priority],rcvd_pkt);
				}
				else
				{
					/* Scalar packet handling */

				}

				got_data = 1;

#ifdef MCAPI_SM_DBG_SUPPORT
				add = (mcapi_uint32_t)rcvd_pkt;
				printf(" RX HISR - received buffer address = %x \r\n", add);
				add = rcvd_pkt->buf_size;
				printf(" RX HISR - received buffer size = %d \r\n", add);
				printf(" RX HISR - received buffer priority = %d \r\n", shm_des->priority);
#endif
			}

			/* Consume current SM buffer descriptor */
			shm_desc_consume(shm_des_q);
		}
		else
		{
			break;
		}
	}

	/* Set notification event */
	if (got_data)
		MCAPI_Set_RX_Event();
}
