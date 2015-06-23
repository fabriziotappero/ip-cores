;/////////////////////////////////////////////////////////////////////
;////                                                             ////
;////  Mini-RISC-1                                                ////
;////  Register File Test 1                                       ////
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

	bsf	STATUS,5

	; ---------------------------------------
	; ---- Test the entire register file ----
	; ---------------------------------------

	movlw	0x81
	movwf	r0
	movlw	0x82
	movwf	r1
	movlw	0x83
	movwf	r2
	movlw	0x84
	movwf	r3
	movlw	0x85
	movwf	r4
	movlw	0x86
	movwf	r5
	movlw	0x87
	movwf	r6
	movlw	0x88
	movwf	r7


	movlw	0x90
	movwf	br0
	movlw	0x91
	movwf	br1
	movlw	0x92
	movwf	br2
	movlw	0x93
	movwf	br3
	movlw	0x94
	movwf	br4
	movlw	0x95
	movwf	br5
	movlw	0x96
	movwf	br6
	movlw	0x97
	movwf	br7
	movlw	0x98
	movwf	br8
	movlw	0x99
	movwf	br9
	movlw	0x9a
	movwf	br10
	movlw	0x9b
	movwf	br11
	movlw	0x9c
	movwf	br12
	movlw	0x9d
	movwf	br13
	movlw	0x9e
	movwf	br14
	movlw	0x9f
	movwf	br15

	bsf	FSR,5	; Select Register Bank 01

	movlw	0xa0
	movwf	br0
	movlw	0xa1
	movwf	br1
	movlw	0xa2
	movwf	br2
	movlw	0xa3
	movwf	br3
	movlw	0xa4
	movwf	br4
	movlw	0xa5
	movwf	br5
	movlw	0xa6
	movwf	br6
	movlw	0xa7
	movwf	br7
	movlw	0xa8
	movwf	br8
	movlw	0xa9
	movwf	br9
	movlw	0xaa
	movwf	br10
	movlw	0xab
	movwf	br11
	movlw	0xac
	movwf	br12
	movlw	0xad
	movwf	br13
	movlw	0xae
	movwf	br14
	movlw	0xaf
	movwf	br15

	bcf	FSR,5	; Select Register Bank 10
	bsf	FSR,6
 
	movlw	0xb0
	movwf	br0
	movlw	0xb1
	movwf	br1
	movlw	0xb2
	movwf	br2
	movlw	0xb3
	movwf	br3
	movlw	0xb4
	movwf	br4
	movlw	0xb5
	movwf	br5
	movlw	0xb6
	movwf	br6
	movlw	0xb7
	movwf	br7
	movlw	0xb8
	movwf	br8
	movlw	0xb9
	movwf	br9
	movlw	0xba
	movwf	br10
	movlw	0xbb
	movwf	br11
	movlw	0xbc
	movwf	br12
	movlw	0xbd
	movwf	br13
	movlw	0xbe
	movwf	br14
	movlw	0xbf
	movwf	br15

	bsf	FSR,5	; Select Register Bank 11
	bsf	FSR,6

	movlw	0xc0
	movwf	br0
	movlw	0xc1
	movwf	br1
	movlw	0xc2
	movwf	br2
	movlw	0xc3
	movwf	br3
	movlw	0xc4
	movwf	br4
	movlw	0xc5
	movwf	br5
	movlw	0xc6
	movwf	br6
	movlw	0xc7
	movwf	br7
	movlw	0xc8
	movwf	br8
	movlw	0xc9
	movwf	br9
	movlw	0xca
	movwf	br10
	movlw	0xcb
	movwf	br11
	movlw	0xcc
	movwf	br12
	movlw	0xcd
	movwf	br13
	movlw	0xce
	movwf	br14
	movlw	0xcf
	movwf	br15

	; Register File		TEST 1
	movlw	0x01
	movwf	PORTB	; Set Test Number

	clrw
	movwf	FSR

	movlw	0x81
	subwf	r0,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x82
	subwf	r1,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x83
	subwf	r2,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x84
	subwf	r3,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x85
	subwf	r4,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x86
	subwf	r5,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x87
	subwf	r6,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x88
	subwf	r7,W
	btfss	STATUS,Z
	goto	lerr

	movlw	0x90
	subwf	br0,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x91
	subwf	br1,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x92
	subwf	br2,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x93
	subwf	br3,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x94
	subwf	br4,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x95
	subwf	br5,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x96
	subwf	br6,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x97
	subwf	br7,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x98
	subwf	br8,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x99
	subwf	br9,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x9a
	subwf	br10,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x9b
	subwf	br11,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x9c
	subwf	br12,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x9d
	subwf	br13,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x9e
	subwf	br14,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x9f
	subwf	br15,W
	btfss	STATUS,Z
	goto	lerr

	; Register File		TEST 2
	movlw	0x02
	movwf	PORTB	; Set Test Number

	bsf	FSR,5	; Select Register Bank 01

	movlw	0x81
	subwf	r0,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x82
	subwf	r1,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x83
	subwf	r2,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x84
	subwf	r3,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x85
	subwf	r4,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x86
	subwf	r5,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x87
	subwf	r6,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x88
	subwf	r7,W
	btfss	STATUS,Z
	goto	lerr

	movlw	0xa0
	subwf	br0,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xa1
	subwf	br1,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xa2
	subwf	br2,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xa3
	subwf	br3,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xa4
	subwf	br4,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xa5
	subwf	br5,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xa6
	subwf	br6,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xa7
	subwf	br7,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xa8
	subwf	br8,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xa9
	subwf	br9,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xaa
	subwf	br10,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xab
	subwf	br11,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xac
	subwf	br12,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xad
	subwf	br13,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xae
	subwf	br14,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xaf
	subwf	br15,W
	btfss	STATUS,Z
	goto	lerr

	; Register File		TEST 3
	movlw	0x03
	movwf	PORTB	; Set Test Number

	bcf	FSR,5	; Select Register Bank 10
	bsf	FSR,6

	movlw	0x81
	subwf	r0,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x82
	subwf	r1,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x83
	subwf	r2,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x84
	subwf	r3,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x85
	subwf	r4,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x86
	subwf	r5,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x87
	subwf	r6,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x88
	subwf	r7,W
	btfss	STATUS,Z
	goto	lerr

	movlw	0xb0
	subwf	br0,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xb1
	subwf	br1,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xb2
	subwf	br2,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xb3
	subwf	br3,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xb4
	subwf	br4,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xb5
	subwf	br5,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xb6
	subwf	br6,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xb7
	subwf	br7,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xb8
	subwf	br8,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xb9
	subwf	br9,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xba
	subwf	br10,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xbb
	subwf	br11,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xbc
	subwf	br12,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xbd
	subwf	br13,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xbe
	subwf	br14,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xbf
	subwf	br15,W
	btfss	STATUS,Z
	goto	lerr


	; Register File		TEST 4
	movlw	0x04
	movwf	PORTB	; Set Test Number

	bsf	FSR,5	; Select Register Bank 11
	bsf	FSR,6

	movlw	0x81
	subwf	r0,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x82
	subwf	r1,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x83
	subwf	r2,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x84
	subwf	r3,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x85
	subwf	r4,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x86
	subwf	r5,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x87
	subwf	r6,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0x88
	subwf	r7,W
	btfss	STATUS,Z
	goto	lerr

	movlw	0xc0
	subwf	br0,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xc1
	subwf	br1,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xc2
	subwf	br2,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xc3
	subwf	br3,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xc4
	subwf	br4,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xc5
	subwf	br5,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xc6
	subwf	br6,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xc7
	subwf	br7,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xc8
	subwf	br8,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xc9
	subwf	br9,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xca
	subwf	br10,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xcb
	subwf	br11,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xcc
	subwf	br12,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xcd
	subwf	br13,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xce
	subwf	br14,W
	btfss	STATUS,Z
	goto	lerr
	movlw	0xcf
	subwf	br15,W
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

