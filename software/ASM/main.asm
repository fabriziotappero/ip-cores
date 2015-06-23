/* ### DEMO PROGRAM: FIBONACCI NUMBERS ###
---------------------------------------------
   Calculates and stores the first 30 Fibonacci
   numbers and stores them in the internal memory,
   starting at word location 25 (byte loaction 100). */

.include "macro.inc"

/*-----------------------------------------------------
 Exception Vectors
-----------------------------------------------------*/

Vectors:	BAL Reset		/* Hardware Reset    */
			NOP				/* Undef Instruction */
			NOP				/* Software INT      */
			NOP				/* Prefetch Abort    */
			NOP				/* Data Abort        */
			NOP				/* Reserved          */
			NOP				/* HW INT req        */
			NOP				/* Fast HW INT req   */

/*-----------------------------------------------------
 Reset Handler
-----------------------------------------------------*/

Reset:		MOV R0, #0		/* A */
			MOV R1, #1		/* B */
			MOV R2, #0		/* C */
			MOV R3, #100	/* mem area to place results */

LOOP:		CMP R3, #220
			BEQ NIRVANA

			STR R0, [R3], #4
			ADD R2, R0, R1
			MOV R0, R1
			MOV R1, R2

			BAL LOOP

NIRVANA:	BAL NIRVANA
