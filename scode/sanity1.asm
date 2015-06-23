;/////////////////////////////////////////////////////////////////////
;////                                                             ////
;////  Mini-RISC-1                                                ////
;////  Compliance Test 1                                          ////
;////  Tests Ports                                                ////
;////                                                             ////
;////  Author: Rudolf Usselmann                                   ////
;////          russelmann@hotmail.com                             ////
;////                                                             ////
;/////////////////////////////////////////////////////////////////////
;////                                                             ////
;//// Copyright (C) 2000 Rudolf Usselmann                         ////
;////                    russelmann@hotmail.com                   ////
;////                                                             ////
;//// This source file may be used and distributed without        ////
;//// restriction provided that this copyright statement is not   ////
;//// removed from the file and that any derivative work contains ////
;//// the original copyright notice and the associated disclaimer.////
;////                                                             ////
;//// THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY        ////
;//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT           ////
;//// LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTIBILITY AND   ////
;//// FITNESS FOR A PARTICULAR PURPOSE.                           ////
;////                                                             ////
;/////////////////////////////////////////////////////////////////////

	list	p=16c57
	#include p16c5x.inc


main	; Main code entry
	; Port IO Test
	; All ports have a Pull up resistor
	
	; Tristate all ports
	clrw
	movwf	PORTA
	movwf	PORTB
	movwf	PORTC
	xorlw	0xff
	tris	PORTA
	tris	PORTB
	tris	PORTC

	; Now check that porta is 0xff
	btfss	PORTA,0
	goto	lerr
	btfss	PORTA,1
	goto	lerr
	btfss	PORTA,2
	goto	lerr
	btfss	PORTA,3
	goto	lerr
	btfss	PORTA,4
	goto	lerr
	btfss	PORTA,5
	goto	lerr	
	btfss	PORTA,6
	goto	lerr
	btfss	PORTA,7
	goto	lerr
	

	; Now check that portb is 0xff
	btfss	PORTB,0
	goto	lerr
	btfss	PORTB,1
	goto	lerr
	btfss	PORTB,2
	goto	lerr
	btfss	PORTB,3
	goto	lerr
	btfss	PORTB,4
	goto	lerr
	btfss	PORTB,5
	goto	lerr	
	btfss	PORTB,6
	goto	lerr
	btfss	PORTB,7
	goto	lerr

	; Now check that portc is 0xff
	btfss	PORTC,0
	goto	lerr
	btfss	PORTC,1
	goto	lerr
	btfss	PORTC,2
	goto	lerr
	btfss	PORTC,3
	goto	lerr
	btfss	PORTC,4
	goto	lerr
	btfss	PORTC,5
	goto	lerr	
	btfss	PORTA,6
	goto	lerr
	btfss	PORTC,7
	goto	lerr


	
	; Enable all ports
	clrw
	tris	PORTA
	tris	PORTB
	tris	PORTC

	; Drive them all 0xaa
	clrw
	xorlw	0xaa
	movwf	PORTA
	movwf	PORTB
	movwf	PORTC

	; Now check that porta is 0xaa
	btfsc	PORTA,0
	goto	lerr
	btfss	PORTA,1
	goto	lerr
	btfsc	PORTA,2
	goto	lerr
	btfss	PORTA,3
	goto	lerr
	btfsc	PORTA,4
	goto	lerr
	btfss	PORTA,5
	goto	lerr	
	btfsc	PORTA,6
	goto	lerr
	btfss	PORTA,7
	goto	lerr

	; Now check that portb is 0xaa
	btfsc	PORTB,0
	goto	lerr
	btfss	PORTB,1
	goto	lerr
	btfsc	PORTB,2
	goto	lerr
	btfss	PORTB,3
	goto	lerr
	btfsc	PORTB,4
	goto	lerr
	btfss	PORTB,5
	goto	lerr	
	btfsc	PORTB,6
	goto	lerr
	btfss	PORTB,7
	goto	lerr

	; Now check that portc is 0xaa
	btfsc	PORTC,0
	goto	lerr
	btfss	PORTC,1
	goto	lerr
	btfsc	PORTC,2
	goto	lerr
	btfss	PORTC,3
	goto	lerr
	btfsc	PORTC,4
	goto	lerr
	btfss	PORTC,5
	goto	lerr	
	btfsc	PORTC,6
	goto	lerr
	btfss	PORTC,7
	goto	lerr

	; Drive them all 0x55
	clrw
	xorlw	0x55
	movwf	PORTA
	movwf	PORTB
	movwf	PORTC

	; Now check that porta is 0x55
	btfss	PORTA,0
	goto	lerr
	btfsc	PORTA,1
	goto	lerr
	btfss	PORTA,2
	goto	lerr
	btfsc	PORTA,3
	goto	lerr
	btfss	PORTA,4
	goto	lerr
	btfsc	PORTA,5
	goto	lerr	
	btfss	PORTA,6
	goto	lerr
	btfsc	PORTA,7
	goto	lerr

	; Now check that portb is 0x55
	btfss	PORTB,0
	goto	lerr
	btfsc	PORTB,1
	goto	lerr
	btfss	PORTB,2
	goto	lerr
	btfsc	PORTB,3
	goto	lerr
	btfss	PORTB,4
	goto	lerr
	btfsc	PORTB,5
	goto	lerr	
	btfss	PORTB,6
	goto	lerr
	btfsc	PORTB,7
	goto	lerr

	; Now check that portc is 0x55
	btfss	PORTC,0
	goto	lerr
	btfsc	PORTC,1
	goto	lerr
	btfss	PORTC,2
	goto	lerr
	btfsc	PORTC,3
	goto	lerr
	btfss	PORTC,4
	goto	lerr
	btfsc	PORTC,5
	goto	lerr	
	btfss	PORTC,6
	goto	lerr
	btfsc	PORTC,7
	goto	lerr
	
	nop
	nop
	nop
	nop

good			; Loop in good on success
	goto	good
	nop
	nop
	nop
	nop
	
lerr			; Loop in lerr on failure
	goto	lerr
	nop
	nop
	nop
	nop

   END

