/*
	FreeRTOS.org V4.2.0 - Copyright (C) 2003-2007 Richard Barry.

	This file is part of the FreeRTOS.org distribution.

	FreeRTOS.org is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	FreeRTOS.org is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with FreeRTOS.org; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

	A special exception to the GPL can be applied should you wish to distribute
	a combined work that includes FreeRTOS.org, without being obliged to provide
	the source code for any proprietary components.  See the licensing section 
	of http://www.FreeRTOS.org for full details of how and when the exception
	can be applied.

	***************************************************************************
	See http://www.FreeRTOS.org for documentation, latest information, license 
	and contact details.  Please ensure to read the configuration and relevant 
	port sections of the online documentation.
	***************************************************************************
*/

/*-----------------------------------------------------------
 * Implementation of functions defined in portable.h for the MicroBlaze port.
 *----------------------------------------------------------*/

#include <stdio.h>

/* Scheduler includes. */
#include "FreeRTOS.h"
#include "task.h"

/* Standard includes. */
#include <string.h>

/* Hardware includes. */
#include "openfire.h"

/* Tasks are started with interrupts enabled. */
#define portINITIAL_MSR_STATE		( ( portSTACK_TYPE ) 0x02 )

/* Tasks are started with a critical section nesting of 0 - however prior
to the scheduler being commenced we don't want the critical nesting level
to reach zero, so it is initialised to a high value. */
#define portINITIAL_NESTING_VALUE	( 0xff )

/* The stack used by the ISR is filled with a known value to assist in
debugging. */
#define portISR_STACK_FILL_VALUE	0x55555555

/* Counts the nesting depth of calls to portENTER_CRITICAL().  Each task 
maintains it's own count, so this variable is saved as part of the task
context. */
volatile unsigned portBASE_TYPE uxCriticalNesting = portINITIAL_NESTING_VALUE;

/* To limit the amount of stack required by each task, this port uses a
separate stack for interrupts. */
unsigned portLONG *pulISRStack;

/*-----------------------------------------------------------*/

/*
 * Sets up the periodic ISR used for the RTOS tick.  This uses timer 0, but
 * could have alternatively used the watchdog timer or timer 1.
 */
static void prvSetupTimerInterrupt( void );
/*-----------------------------------------------------------*/

/* 
 * Initialise the stack of a task to look exactly as if a call to 
 * portSAVE_CONTEXT had been made.
 * 
 * See the header file portable.h.
 */
portSTACK_TYPE *pxPortInitialiseStack( portSTACK_TYPE *pxTopOfStack, pdTASK_CODE pxCode, void *pvParameters )
{
extern void *_SDA2_BASE_, *_SDA_BASE_;
const unsigned portLONG ulR2 = ( unsigned portLONG ) &_SDA2_BASE_;
const unsigned portLONG ulR13 = ( unsigned portLONG ) &_SDA_BASE_;

	/* Place a few bytes of known values on the bottom of the stack. 
	This is essential for the Microblaze port and these lines must
	not be omitted.  The parameter value will overwrite the 
	0x22222222 value during the function prologue. */
	*pxTopOfStack = ( portSTACK_TYPE ) 0x11111111;
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x22222222;
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x33333333;
	pxTopOfStack--; 

	/* First stack an initial value for the critical section nesting.  This
	is initialised to zero as tasks are started with interrupts enabled. */
	*pxTopOfStack = ( portSTACK_TYPE ) 0x00;	/* R0. */

	/* Place an initial value for all the general purpose registers. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) ulR2;	/* R2 - small data area. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x03;	/* R3. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x04;	/* R4. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) pvParameters;/* R5 contains the function call parameters. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x06;	/* R6. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x07;	/* R7. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x08;	/* R8. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x09;	/* R9. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x0a;	/* R10. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x0b;	/* R11. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x0c;	/* R12. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) ulR13;	/* R13 - small data read write area. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) pxCode;	/* R14. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x0f;	/* R15. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x10;	/* R16. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x11;	/* R17. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x12;	/* R18. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x13;	/* R19. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x14;	/* R20. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x15;	/* R21. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x16;	/* R22. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x17;	/* R23. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x18;	/* R24. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x19;	/* R25. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x1a;	/* R26. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x1b;	/* R27. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x1c;	/* R28. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x1d;	/* R29. */
	pxTopOfStack--;
	*pxTopOfStack = ( portSTACK_TYPE ) 0x1e;	/* R30. */
	pxTopOfStack--;

	/* The MSR is stacked between R30 and R31. */
	*pxTopOfStack = portINITIAL_MSR_STATE;
	pxTopOfStack--;

	*pxTopOfStack = ( portSTACK_TYPE ) 0x1f;	/* R31. */
	pxTopOfStack--;

	/* Return a pointer to the top of the stack we have generated so this can
	be stored in the task control block for the task. */
	return pxTopOfStack;
}
/*-----------------------------------------------------------*/

portBASE_TYPE xPortStartScheduler( void )
{
extern void ( __FreeRTOS_interrupt_Handler )( void );
extern void ( vStartFirstTask )( void );

	/* Setup the FreeRTOS interrupt handler.  Code copied from crt0.s. */
	asm volatile ( 	"la  r6, r0, __FreeRTOS_interrupt_handler	\n\t" \
			"sw  r6, r1, r0					\n\t" \
			"lhu r7, r1, r0					\n\t" \
			"shi r7, r0, 0x12				\n\t" \
			"shi r6, r0, 0x16 				\n\t" );

	/* Setup the hardware to generate the tick.  Interrupts are disabled when
	this function is called. */
	prvSetupTimerInterrupt();

	/* Allocate the stack to be used by the interrupt handler. */
	pulISRStack = ( unsigned portLONG * ) pvPortMalloc( configMINIMAL_STACK_SIZE * sizeof( portSTACK_TYPE ) );

	/* Restore the context of the first task that is going to run. */
	if( pulISRStack != NULL )
	{
		/* Fill the ISR stack with a known value to facilitate debugging. */
		memset( pulISRStack, portISR_STACK_FILL_VALUE, configMINIMAL_STACK_SIZE * sizeof( portSTACK_TYPE ) );
		pulISRStack += ( configMINIMAL_STACK_SIZE - 1 );

		/* Kick off the first task. */
		vStartFirstTask();
	}

	/* Should not get here as the tasks are now running! */
	return pdFALSE;
}
/*-----------------------------------------------------------*/

void vPortEndScheduler( void )
{
	/* Not implemented. */
}
/*-----------------------------------------------------------*/

/*
 * Manual context switch called by portYIELD or taskYIELD.  
 */
void vPortYield( void )
{
extern void VPortYieldASM( void );

	/* Perform the context switch in a critical section to assure it is
	not interrupted by the tick ISR.  It is not a problem to do this as
	each task maintains it's own interrupt status. */
	portENTER_CRITICAL();
		/* Jump directly to the yield function to ensure there is no
		compiler generated prologue code. */
		asm volatile (	"bralid r14, VPortYieldASM		\n\t" \
				"or r0, r0, r0				\n\t" );
	portEXIT_CRITICAL();
}
/*-----------------------------------------------------------*/

/*
 * Hardware initialisation to generate the RTOS tick.   
 */
static void prvSetupTimerInterrupt( void )
{
const unsigned portLONG ulCounterValue = configCPU_CLOCK_HZ / configTICK_RATE_HZ;

	/* configure Timer1 with ulCounterValue and enable timer */
	*(unsigned portLONG *) TIMER1_PORT = TIMER1_CONTROL | ulCounterValue;

 	/* enable interrupts for timer1 */
 	*(unsigned portLONG *) INTERRUPT_ENABLE = INTERRUPT_TIMER1;
}
/*-----------------------------------------------------------*/

/*
 * The interrupt handler placed in the interrupt vector when the scheduler is
 * started.  The task context has already been saved when this is called.
 * This handler determines the interrupt source and calls the relevant 
 * peripheral handler.
 */
void vTaskISRHandler( void )
{
  	/* todo : check which peripheral triggered the interrupt */
  
	/* Increment the RTOS tick - this might cause a task to unblock. */
	vTaskIncrementTick();

	/* Clear the timer interrupt */
	/* automatically cleread --> better design? */

	/* If we are using the preemptive scheduler then we also need to determine
	if this tick should cause a context switch. */
	#if configUSE_PREEMPTION == 1
		vTaskSwitchContext();
	#endif
}
/*-----------------------------------------------------------*/

void openfire_disable_interrupts(void)
{
  asm volatile ( "mfs r5, rmsr			\n\t" 	\
  		 "andi r5, r0, ~0x2		\n\t" 	\
  		 "mts rmsr, r5			\n\t");
}

void openfire_enable_interrupts(void)
{
  asm volatile ( "mfs r5, rmsr			\n\t" 	\
  		 "ori r5, r0, 0x2		\n\t" 	\
  		 "mts rmsr, r5			\n\t");
}

