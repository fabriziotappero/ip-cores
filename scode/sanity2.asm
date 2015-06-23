;/////////////////////////////////////////////////////////////////////
;////                                                             ////
;////  Mini-RISC-1                                                ////
;////  Compliance Test 2                                          ////
;////  Tests PLC register Rd/Wr                                   ////
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

	; -------------------------------
	; ---- Test the PLC register ----
	; -------------------------------

	; PLC read test 1	TEST 0

	movlw	pclrd1
	movwf	r0
	movf	PCL,W
pclrd1	subwf	r0,W
	btfss	STATUS,Z
	goto	lerr	

	; PLC read test 2	TEST 1
	movlw	0x01
	movwf	PORTB	; Set Test Number

	movlw	pclrd2
	movwf	r3
	movf	PCL,W
pclrd2	subwf	r3,W
	btfss	STATUS,Z
	goto	lerr

	; PLC write test 2	TEST 2
	movlw	0x02
	movwf	PORTB	; Set Test Number

	movlw	pclwr1
	movwf	PCL

	goto	lerr
	goto	lerr
	goto	lerr
pclwr1	goto	pcl1
	goto	lerr
	goto	lerr
	goto	lerr

pcl1
	; PLC write test 2	TEST 3
	movlw	0x03
	movwf	PORTB	; Set Test Number

	movlw	pclwr2
	movwf	PCL

	goto	lerr
	goto	lerr
	goto	lerr
pclwr2	goto	pcl2
	goto	lerr
	goto	lerr
	goto	lerr

pcl2	; Test other instructions that modify PC
	; This are ADDWF PC, BSF PC,X and BCF PC,X
	; (movwf pc already tested above)

	; PLC write test 3	TEST 4
	; test addwf PC
	movlw	0x04
	movwf	PORTB	; Set Test Number

	movlw	pcl3b
	movwf	r0
	movlw	pcl3a
	subwf	r0,W
pcl3a	addwf	PCL,1

	goto	lerr
	goto	lerr
pcl3b	goto	lerr
	goto	pcl3c
	goto	lerr
	goto	lerr
	goto	lerr
pcl3c

	; PLC write test 4	TEST 5
	; test addwf PC
	movlw	0x05
	movwf	PORTB	; Set Test Number

	movlw	pcl4b
	movwf	br8
	movlw	pcl4a
	subwf	br8,W
pcl4a	addwf	PCL,1

	goto	lerr
	goto	lerr
pcl4b	goto	lerr
	goto	pcl4c
	goto	lerr
	goto	lerr
	goto	lerr
pcl4c

	; PLC write test 5	TEST 6
	; test bsf PC,N
	movlw	0x06
	movwf	PORTB	; Set Test N

; allign memory
	goto	pcl50

pcl50	org	0x60

	bsf	PCL,1	; 60
	goto	lerr	; 61
	goto	lerr	; 62
	goto	pcl5a	; 63
	goto	lerr	; 64
	goto	lerr	; 65
	goto	lerr	; 66
	goto	lerr	; 67

pcl5a

	; PLC write test 6	TEST 7
	; test bsf PC,N
	movlw	0x07
	movwf	PORTB	; Set Test N

	bsf	PCL,2	; 6A
	goto	lerr	; 6B
	goto	lerr	; 6C
	goto	lerr	; 6D
	goto	lerr	; 6E
	goto	pcl6a	; 6F
	goto	lerr	; 70
	goto	lerr	; 71

pcl6a

	; PLC write test 7	TEST 8
	; test bcf PC,N
	movlw	0x08
	movwf	PORTB	; Set Test N

	goto	pcl7a	; 74
	goto	lerr	; 75
	goto	lerr	; 76
	goto	lerr	; 77
	goto	lerr	; 78
	goto	pcl7b	; 79
	goto	lerr	; 7a
	goto	lerr	; 7b

pcl7a
	bcf	PCL,2	; 7c

pcl7b


	; Make sure goto works
	movlw	0x09	;	TEST 9
	movwf	PORTB	; Set Test Number


	goto	gt1
	nop
	nop
	nop
	nop
	movlw	0xff
	movwf	PORTA
	nop
	nop
	nop
	nop
gt1

	; Make sure call works
	movlw	0x0a	;	TEST 10
	movwf	PORTB	; Set Test Number

	call	cal1
	movwf	r0
	movlw	0x55
	subwf	r0,w
	btfss	STATUS,Z
	goto	lerr

	call	cal2
	movwf	r0
	movlw	0xaa
	subwf	r0,w
	btfss	STATUS,Z
	goto	lerr

	call	cal3
	movwf	r0
	movlw	0xc3
	subwf	r0,w
	btfss	STATUS,Z
	goto	lerr

	call	cal4
	movwf	r0
	movlw	0x3c
	subwf	r0,w
	btfss	STATUS,Z
	goto	lerr

	goto	next1

cal1
	retlw	0x55
	goto	lerr

cal2
	nop
	retlw	0xaa
	goto	lerr

cal3
	nop
	nop
	retlw	0xc3
	goto	lerr

cal4
	nop
	nop
	nop
	retlw	0x3c
	goto	lerr

table1	
	addwf	PCL,F
	retlw	0xff
	retlw	0xfe
	retlw	0xfd
	retlw	0xfc
	retlw	0xfb
	retlw	0xfa
	retlw	0xf9
	retlw	0xf8
	retlw	0xf7
	retlw	0xf6
	retlw	0xf5
	goto	lerr
	goto	lerr
	goto	lerr
	goto	lerr
	goto	lerr
	goto	lerr

next1
	

	; Make sure call works (2)
	movlw	0x0b	;	TEST 11
	movwf	PORTB	; Set Test Number

	movlw	0x0
	movwf	r0
	call	table1
	comf	r0,F
	subwf	r0,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x1
	movwf	r0
	call	table1
	comf	r0,F
	subwf	r0,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x2
	movwf	r0
	call	table1
	comf	r0,F
	subwf	r0,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x3
	movwf	r0
	call	table1
	comf	r0,F
	subwf	r0,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x4
	movwf	r0
	call	table1
	comf	r0,F
	subwf	r0,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x5
	movwf	r0
	call	table1
	comf	r0,F
	subwf	r0,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x6
	movwf	r0
	call	table1
	comf	r0,F
	subwf	r0,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x7
	movwf	r0
	call	table1
	comf	r0,F
	subwf	r0,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x8
	movwf	r0
	call	table1
	comf	r0,F
	subwf	r0,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0x9
	movwf	r0
	call	table1
	comf	r0,F
	subwf	r0,F
	btfss	STATUS,Z
	goto	lerr

	movlw	0xa
	movwf	r0
	call	table1
	comf	r0,F
	subwf	r0,F
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

