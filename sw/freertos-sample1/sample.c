#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Scheduler include files. */
#include "FreeRTOS.h"
#include "task.h"

#define PERIODO1	( ( portTickType ) 1000 / portTICK_RATE_MS  )
#define PERIODO2	( ( portTickType ) 3000 / portTICK_RATE_MS  )
#define PERIODO3	( ( portTickType )  100 / portTICK_RATE_MS  )

unsigned int lectura_pot;		/* para comunicarselo entre tareas */

/*-----------------------------------------------------------*/
static void vTask1( void *pvParameters )
{
	unsigned marca;
	/* The parameters are not used. */
	( void ) pvParameters;

	uart1_printline("\r\n\r\n");
	
	marca = 0;
	
	/* Cycle for ever, delaying then checking all the other tasks are still
	operating without error. */
	for( ;; )
	{
		switch(marca)
		{
		  case 0 : uart1_printchar('-'); break;
		  case 1 : uart1_printchar('\\'); break;
		  case 2 : uart1_printchar('|'); break;
		  case 3 : uart1_printchar('/'); break;
		}
		uart1_printchar('\r');
		marca++;
		if(marca == 4) marca = 0;
		
		vTaskDelay( PERIODO1 );
	}
}

/*-----------------------------------------------------------*/

portSHORT main( void )
{
	portBASE_TYPE xReturn;
	
	uart1_printline("entering main()\r\n");
	
	/* Create the tasks defined within this file. */
	xReturn = xTaskCreate( vTask1, (const signed portCHAR *) "TSK1", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY, NULL );
	if(xReturn != pdPASS)
	{
	  uart1_printline("xTaskCreate failed\r\n");
	  return 0;
	}
	
	/* In this port, to use preemptive scheduler define configUSE_PREEMPTION 
	as 1 in portmacro.h.  To use the cooperative scheduler define 
	configUSE_PREEMPTION as 0. */
	
	uart1_printline("starting scheduler....\r\n");
	vTaskStartScheduler();
	
	uart1_printline("end\r\n");
	return 0;
}
