//---------------------------------------------------------------------------------------
//	Project:			light8080 SOC		WiCores Solutions 
//
//	File name:			intr_vec.h 			(March 03, 2012)
//
//	Writer:				Moti Litochevski 
//
//	Description:
//		This file contains a simple example of calling interrupt service routine. this 
//		file defines the interrupt vector for external interrupt 0 located at address 
//		0x0008. the interrupts vectors addresses are set in the verilog interrupt 
//		controller "intr_ctrl.v" file. 
//		Code is generated for all 4 supported external interrupts but non used interrupt 
//		are not called. 
//		On execution of an interrupt the CPU will automatically clear the interrupt 
//		enable flag set by the EI instruction. the interrupt vectors in this example 
//		enable the interrupts again after interrupt service routine execution. to enable 
//		nested interrupts just move the EI instruction to the code executed before the 
//		call instruction to the service routine (see comments below). 
//		Note that this code is not optimized in any way. this is just an example to 
//		verify the interrupt mechanism of the light8080 CPU and show a simple example. 
//
//	Revision History:
//
//	Rev <revnumber>			<Date>			<owner> 
//		<comment>
//---------------------------------------------------------------------------------------

// to support interrupt enable the respective interrupt vector is defined here at the 
// beginning of the output assembly file. only the interrupt vector for used interrupts
// should call a valid interrupt service routine name defined in the C source file. the 
// C function name should be prefixed by "__". 
#asm
;Preserve space for interrupt routines 
;interrupt 0 vector 
	org #0008
	push af
	push bc
	push de
	push hl 
;	ei					; to enable nested interrupts uncomment this instruction 
	call __int0_isr 
	pop hl 
	pop de 
	pop bc
	pop af
	ei 					; interrupt are not enabled during the execution os the isr 
	ret 
;interrupt 1 vector 
	org #0018
	push af
	push bc
	push de
	push hl 
;	call __int1_isr		; interrupt not used 
	pop hl 
	pop de 
	pop bc
	pop af
	ei 
	ret 
;interrupt 2 vector 
	org #0028
	push af
	push bc
	push de
	push hl 
;	call __int2_isr		; interrupt not used 
	pop hl 
	pop de 
	pop bc
	pop af
	ei 
	ret 
;interrupt 3 vector 
	org #0038
	push af
	push bc
	push de
	push hl 
;	call __int3_isr		; interrupt not used 
	pop hl 
	pop de 
	pop bc
	pop af
	ei 
	ret 
#endasm 
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------
