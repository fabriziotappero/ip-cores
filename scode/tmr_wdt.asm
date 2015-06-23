;/////////////////////////////////////////////////////////////////////
;////                                                             ////
;////  Mini-RISC-1                                                ////
;////  Timer / Wachdog                                            ////
;////  Tests Timer / Wachdog                                      ////
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

; global Registers
r0	equ	0x8
r1	equ	0x9
r2	equ	0xa
r3	equ	0xb
r4	equ	0xc
r5	equ	0xd
r6	equ	0xe
r7	equ	0xf

; banked Registers
br0	equ	0x10
br1	equ	0x11
br2	equ	0x12
br3	equ	0x13
br4	equ	0x14
br5	equ	0x15
br6	equ	0x16
br7	equ	0x17
br8	equ	0x18
br9	equ	0x19
br10	equ	0x1a
br11	equ	0x1b
br12	equ	0x1c
br13	equ	0x1d
br14	equ	0x1e
br15	equ	0x1f


;	PORTB Indicates Test Number
;	PORTA Indicates Status: 0 - Running; 1 - done OK; ff - stoped on error

main	; Main code entry
	; Port IO Test
	; All ports have a Pull up resistor
	
	; SETUP all ports
	clrw
	movwf	FSR
	movwf	PORTA
	movwf	PORTB
	movwf	PORTC
	tris	PORTA
	tris	PORTB
	tris	PORTC

	; ---------------------------------------
	; ---- Test RMW on Register fil      ----
	; ---------------------------------------

	movlw	0x01	; 	TEST 1
	movwf	PORTB	; Set Test Number

	movlw	0x00
	option
	movwf	TMR0
	clrwdt
	nop
	nop
	nop
	nop

	clrw
	movwf	r1

loop2	; repeat 256 times
	clrw
	movwf	r0


	; repeat 256 times
loop1
	movfw	TMR0
	decfsz	r0,F
	goto	loop1

	decfsz	r1,F
	goto	loop2



	nop
	nop
	nop
	nop
	nop
	nop

	clrw
	movwf	TMR0
	clrwdt

	nop
	nop
	nop
	nop
	movlw	0x01
	movwf	PORTA
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

lerr
	movlw	0xff
	movwf	PORTA

	nop
	nop
	nop
	nop
lerr_loop		; Loop in lerr on failure
	goto	lerr_loop
	nop
	nop
	nop
	nop

   END

