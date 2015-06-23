;/////////////////////////////////////////////////////////////////////
;////                                                             ////
;////  Mini-RISC-1                                                ////
;////  Register File Test 3                                       ////
;////  Tests Register File                                        ////
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

	movlw	0xfc
	movwf	r0
	incf	r0,F
	incf	r0,F
	incf	r0,F
	incf	r0,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0xfc
	movwf	br8
	incf	br8,F
	incf	br8,F
	incf	br8,F
	incf	br8,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x02	; 	TEST 2
	movwf	PORTB	; Set Test Number

	movlw	r1
	movwf	FSR
	movlw	0xfc
	movwf	INDF
	incf	INDF,F
	incf	INDF,F
	incf	INDF,F
	incf	INDF,F
	btfss	STATUS,Z
	goto	lerr

	movlw	br9
	movwf	FSR
	movlw	0xfc
	movwf	INDF
	incf	INDF,F
	incf	INDF,F
	incf	INDF,F
	incf	INDF,F
	btfss	STATUS,Z
	goto	lerr



	movlw	0x03	; 	TEST 3
	movwf	PORTB	; Set Test Number

	movlw	0x04
	movwf	r0
	decf	r0,F
	decf	r0,F
	decf	r0,F
	decf	r0,F
	btfss	STATUS,Z
	goto	lerr


	movlw	0x04
	movwf	br0
	decf	br0,F
	decf	br0,F
	decf	br0,F
	decf	br0,F
	btfss	STATUS,Z
	goto	lerr


	movlw	0x04	; 	TEST 4
	movwf	PORTB	; Set Test Number

	movlw	r1
	movwf	FSR
	movlw	0x04
	movwf	INDF
	decf	INDF,F
	decf	INDF,F
	decf	INDF,F
	decf	INDF,F
	btfss	STATUS,Z
	goto	lerr

	movlw	br9
	movwf	FSR
	movlw	0x04
	movwf	INDF
	decf	INDF,F
	decf	INDF,F
	decf	INDF,F
	decf	INDF,F
	btfss	STATUS,Z
	goto	lerr


	movlw	0x05	; 	TEST 5
	movwf	PORTB	; Set Test Number

	movlw	0xfc
	movwf	r4
	incfsz	r4,F
	incfsz	r4,F
	incfsz	r4,F
	incfsz	r4,F
	goto	lerr

	movlw	0xfc
	movwf	br8
	incfsz	br8,F
	incfsz	br8,F
	incfsz	br8,F
	incfsz	br8,F
	goto	lerr


	movlw	0x06	; 	TEST 6
	movwf	PORTB	; Set Test Number

	movlw	r1
	movwf	FSR
	movlw	0xfc
	movwf	INDF
	incfsz	INDF,F
	incfsz	INDF,F
	incfsz	INDF,F
	incfsz	INDF,F
	goto	lerr

	movlw	br9
	movwf	FSR
	movlw	0xfc
	movwf	INDF
	incfsz	INDF,F
	incfsz	INDF,F
	incfsz	INDF,F
	incfsz	INDF,F
	goto	lerr

	movlw	0x07	; 	TEST 7
	movwf	PORTB	; Set Test Number

	movlw	0x04
	movwf	r0
	decfsz	r0,F
	decfsz	r0,F
	decfsz	r0,F
	decfsz	r0,F
	goto	lerr


	movlw	0x04
	movwf	br0
	decfsz	br0,F
	decfsz	br0,F
	decfsz	br0,F
	decfsz	br0,F
	goto	lerr


	movlw	0x08	; 	TEST 8
	movwf	PORTB	; Set Test Number

	movlw	r1
	movwf	FSR
	movlw	0x04
	movwf	INDF
	decfsz	INDF,F
	decfsz	INDF,F
	decfsz	INDF,F
	decfsz	INDF,F
	goto	lerr

	movlw	br9
	movwf	FSR
	movlw	0x04
	movwf	INDF
	decfsz	INDF,F
	decfsz	INDF,F
	decfsz	INDF,F
	decfsz	INDF,F
	goto	lerr


	movlw	0x09	; 	TEST 9
	movwf	PORTB	; Set Test Number

	movlw	0xfc
	movwf	FSR
	incf	FSR,F
	incf	FSR,F
	incf	FSR,F
	incf	FSR,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x04
	movwf	FSR
	movlw	0x7f
	decf	FSR,F
	decf	FSR,F
	decf	FSR,F
	decf	FSR,F
	andwf	FSR,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x0a	; 	TEST 10
	movwf	PORTB	; Set Test Number

	movlw	0xfc
	movwf	STATUS
	movlw	0x18
	incf	STATUS,F
	incf	STATUS,F
	incf	STATUS,F
	incf	STATUS,F
	subwf	STATUS,W
	btfss	STATUS,Z
	goto	lerr




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

