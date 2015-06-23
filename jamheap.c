/****************************************************************************/
/*																			*/
/*	Module:			jamheap.c												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Heap management functions.  The heap is implemented as	*/
/*					a linked list of blocks of variable size.				*/
/*																			*/
/*	Revisions:		1.1 added support for dynamic memory allocation			*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#include "jamport.h"
#include "jamexprt.h"
#include "jamdefs.h"
#include "jamsym.h"
#include "jamstack.h"
#include "jamheap.h"
#include "jamjtag.h"
#include "jamutil.h"

/****************************************************************************/
/*																			*/
/*	Global variables														*/
/*																			*/
/****************************************************************************/

JAMS_HEAP_RECORD *jam_heap = NULL;

void *jam_heap_top = NULL;

long jam_heap_records = 0L;

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_init_heap(void)

/*																			*/
/*	Description:	Initializes the heap area.  This is where all array		*/
/*					data is stored.											*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, or JAMC_OUT_OF_MEMORY if no	*/
/*					memory was available for the heap.						*/
/*																			*/
/****************************************************************************/
{
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	void **symbol_table = NULL;
	JAMS_STACK_RECORD *stack = NULL;
	long *jtag_buffer = NULL;

	jam_heap_records = 0L;

	if (jam_workspace != NULL)
	{
		symbol_table = (void **) jam_workspace;
		stack = (JAMS_STACK_RECORD *) &symbol_table[JAMC_MAX_SYMBOL_COUNT];
		jtag_buffer = (long *) &stack[JAMC_MAX_NESTING_DEPTH];
		jam_heap = (JAMS_HEAP_RECORD *)
			(((char *) jtag_buffer) + JAMC_JTAG_BUFFER_SIZE);
		jam_heap_top = (void *) jam_heap;

		/*
		*	Check that there is some memory available for the heap
		*/
		if (((long)jam_heap) > (((long)jam_workspace_size) +
			((long)jam_workspace)))
		{
			status = JAMC_OUT_OF_MEMORY;
		}
	}
	else
	{
		/* initialize heap to empty list */
		jam_heap = NULL;
	}

	return (status);
}

void jam_free_heap(void)
{
	int record = 0;
	JAMS_HEAP_RECORD *heap_ptr = NULL;
	JAMS_HEAP_RECORD *tmp_heap_ptr = NULL;

	if ((jam_heap != NULL) && (jam_workspace == NULL))
	{
		heap_ptr = jam_heap;
		for (record = 0; record < jam_heap_records; ++record)
		{
			if (heap_ptr != NULL)
			{
				tmp_heap_ptr = heap_ptr;
				heap_ptr = heap_ptr->next;
				jam_free(tmp_heap_ptr);
			}
		}
	}
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_add_heap_record
(
	JAMS_SYMBOL_RECORD *symbol_record,
	JAMS_HEAP_RECORD **heap_record,
	long dimension
)

/*																			*/
/*	Description:	Adds a heap record of the specified size to the heap.	*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, or JAMC_OUT_OF_MEMORY if not	*/
/*					enough memory was available.							*/
/*																			*/
/****************************************************************************/
{
	int count = 0;
	int element = 0;
	long space_needed = 0L;
	BOOL cached = FALSE;
	JAMS_HEAP_RECORD *heap_ptr = NULL;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;

	/*
	*	Compute space needed for array or cache buffer.  Initialized arrays
	*	will not be cached if their size is less than the cache buffer size.
	*/
	switch (symbol_record->type)
	{
	case JAM_INTEGER_ARRAY_WRITABLE:
		space_needed = dimension * sizeof(long);
		break;

	case JAM_BOOLEAN_ARRAY_WRITABLE:
		space_needed = ((dimension >> 5) + ((dimension & 0x1f) ? 1 : 0)) *
			sizeof(long);
		break;

	case JAM_INTEGER_ARRAY_INITIALIZED:
		space_needed = dimension * sizeof(long);
/*		if (space_needed > JAMC_ARRAY_CACHE_SIZE)	*/
/*		{											*/
/*			space_needed = JAMC_ARRAY_CACHE_SIZE;	*/
/*			cached = TRUE;							*/
/*		}											*/
		break;

	case JAM_BOOLEAN_ARRAY_INITIALIZED:
		space_needed = ((dimension >> 5) + ((dimension & 0x1f) ? 1 : 0)) *
			sizeof(long);
/*		if (space_needed > JAMC_ARRAY_CACHE_SIZE)	*/
/*		{											*/
/*			space_needed = JAMC_ARRAY_CACHE_SIZE;	*/
/*			cached = TRUE;							*/
/*		}											*/
		break;

	case JAM_PROCEDURE_BLOCK:
		space_needed = ((dimension >> 2) + 1) * sizeof(long);
		break;

	default:
		status = JAMC_INTERNAL_ERROR;
		break;
	}

	/*
	*	Check if there is enough space
	*/
	if (status == JAMC_SUCCESS)
	{
		if (jam_workspace != NULL)
		{
			heap_ptr = (JAMS_HEAP_RECORD *) jam_heap_top;

			jam_heap_top = (void *) ((long)heap_ptr +
				(long)sizeof(JAMS_HEAP_RECORD) + space_needed);

			if ((long)jam_heap_top > (long)jam_symbol_bottom)
			{
				status = JAMC_OUT_OF_MEMORY;
			}
		}
		else
		{
#if PORT==DOS
			if ((sizeof(JAMS_HEAP_RECORD) + space_needed) < 0x10000L)
			{
				heap_ptr = (JAMS_HEAP_RECORD *) jam_malloc((unsigned int)
					(sizeof(JAMS_HEAP_RECORD) + space_needed));
			}
			/* else error: cannot allocate a buffer greater than 64K */
#else
			heap_ptr = (JAMS_HEAP_RECORD *) jam_malloc((unsigned int)
				(sizeof(JAMS_HEAP_RECORD) + space_needed));
#endif

			if (heap_ptr == NULL)
			{
				status = JAMC_OUT_OF_MEMORY;
			}
			else if (jam_heap == NULL)
			{
				jam_heap = heap_ptr;
			}
		}
	}

	/*
	*	Add the new record to the heap
	*/
	if (status == JAMC_SUCCESS)
	{
		heap_ptr->symbol_record = symbol_record;
		heap_ptr->dimension = dimension;
		heap_ptr->cached = cached;
		heap_ptr->position = 0L;

		if (jam_workspace != NULL)
		{
			/* point next pointer to position of next block */
			heap_ptr->next = (JAMS_HEAP_RECORD *) jam_heap_top;
		}
		else
		{
			/* add new heap block to beginning of list */
			heap_ptr->next = jam_heap;
			jam_heap = heap_ptr;
		}

		/* initialize data area to zero */
		count = (int) (space_needed / sizeof(long));
		for (element = 0; element < count; ++element)
		{
			heap_ptr->data[element] = 0L;
		}

		++jam_heap_records;

		*heap_record = heap_ptr;
	}

	return (status);
}

/****************************************************************************/
/*																			*/

void *jam_get_temp_workspace
(
	long size
)

/*																			*/
/*	Description:	Gets a pointer to the unused area of the heap for		*/
/*					temporary use.  This area will be used for heap records	*/
/*					if jam_add_heap_record() is called.						*/
/*																			*/
/*	Returns:		pointer to memory, or NULL if memory not available		*/
/*																			*/
/****************************************************************************/
{
	void *temp_workspace = NULL;

	if (jam_workspace != NULL)
	{
		if (((long)jam_heap_top) + size <= (long)jam_symbol_bottom)
		{
			temp_workspace = jam_heap_top;
		}
	}
	else
	{
		temp_workspace = jam_malloc((unsigned int) size);
	}

	return (temp_workspace);
}

/****************************************************************************/
/*																			*/

void jam_free_temp_workspace
(
	void *ptr
)

/*																			*/
/*	Description:	Frees memory buffer allocated by jam_get_temp_workspace	*/
/*																			*/
/*	Returns:		Nothing													*/
/*																			*/
/****************************************************************************/
{
	if ((ptr != NULL) && (jam_workspace == NULL))
	{
		jam_free(ptr);
	}
}
