;;; 
;;; $Id: ae18_core.asm,v 1.4 2007-10-11 18:52:24 sybreon Exp $
;;; 
;;; Copyright (C) 2006 Shawn Tan Ser Ngiap <shawn.tan@aeste.net>
;;;
;;; This library is free software; you can redistribute it and/or modify it 
;;; under the terms of the GNU Lesser General Public License as published by
;;; the Free Software Foundation; either version 2.1 of the License,
;;; or (at your option) any later version.
;;; 
;;; This library is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
;;; License for more details.
;;; 
;;; You should have received a copy of the GNU Lesser General Public License
;;; along with this library; if not, write to the Free Software Foundation, Inc.,
;;; 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;;;
;;; DESCRIPTION
;;; This file contains a simple test programme to test the functionality of
;;; the AE18 core. It is by no means an exhaustive test. However, it does
;;; perform at least each PIC18 command at least once. This file has been
;;; compiled using GPASM and GPLINK.
;;;
;;; $Log: not supported by cvs2svn $
;;; 
	
	include	"p18f452.inc"

	processor p18f452
	radix	hex
		
_RAM	udata	0x020
reg0	res	1
reg1	res	1
reg2	res	2
_FSR	udata	0x100
fsr0	res	10
fsr1	res	10
fsr2	res	10
	
_RESET	code	0x0000
	goto	_START_TEST
_ERROR:
	goto	$
			
_ISRH	code	0x08
	goto	_ISRH_TEST
	
_ISRL	code	0x018
	goto	_ISRL_TEST

_MAIN	code	0x0020

	;; 
	;; MAIN test code loop
	;; Calls a series of test subroutines. Ends with a SLEEP.
	;; 
_START_TEST:
	;; Clear WDT
	clrwdt		
			
	rcall	_NPC_TEST
	rcall	_LW2W_TEST
	rcall	_BSR_TEST
	rcall	_F2F_TEST
	rcall	_FW2W_TEST	
	rcall	_FW2F_TEST
	rcall	_SKIP_TEST
	rcall	_BCC_TEST
	rcall	_C_TEST
 	rcall	_MUL_TEST
	rcall	_BIT_TEST
	rcall	_N2F_TEST	
	rcall	_FSR_TEST	
	rcall	_SHA_TEST	
	rcall	_TBL_TEST	
	;; rcall	_PCL_TEST
	

	;; All tests OK!!
	sleep

	;; BUGFIX! : Two NOPs required after SLEEP command.
	nop
	nop
	
	;; RESET on wake up
	reset
		
	;; Infinite Loop. It should NEVER loop.
	bra	$	

	;; 
	;; PCL tests - OK
	;; Tests to check that PCLATU/PCLATH/PCL works.
	;;
_PCL_TEST:
	movlw	UPPER(_PCL1)
	movwf	PCLATU
	movlw	HIGH(_PCL1)
	movwf	PCLATH
	movlw	LOW(_PCL1)
	movwf	PCL		; Jump
	bra	$
_PCL1:
	movlw	0xFF
	movwf	PCLATU
	movwf	PCLATH
	movf	PCL,W		; WREG = _PCL0
_PCL0:
	xorlw	LOW(_PCL0)
	bnz	$
	movf	PCLATH,W
	xorlw	HIGH(_PCL0)
	bnz	$
	movf	PCLATU,W
	xorlw	UPPER(_PCL0)
	bnz	$

	retlw	0x00
	
		
	;;
	;; TABLE tests - OK
	;; Tests to check that TBLRD is working
	;;
_TBL_TEST:
	clrf	TBLPTRH
	clrf	TBLPTRL
	tblrd*+			; TABLAT = 10
	movf	TABLAT,W
	xorlw	0x10
	bnz	$
	tblrd*+			; TABLAT = EF
	movf	TABLAT,W
	xorlw	0xEF
	bnz	$
	retlw	0x00
	
	;;
	;; SHADOW test - OK
	;; Tests to make sure that CALL,S and RETURN,S are working
	;;
_SHA_TEST:
	movlw	0xA5		; WREG = 0xA5
	call	_SHA0,1
	xorlw	0xA5		; Z = 1
	bnz	$
	retlw	0x00
_SHA0:	
	movlw	0x00		; WREG = 0x00
	xorlw	0x00		; Z = 1
	bnz	$
	return	1		; WREG = 0xA5
	
	;; 
	;; FSR test - OK
	;; Uses INDF0/INDF1/INDF2 for moving values around
	;; 
_FSR_TEST:
	lfsr	2,fsr2
	lfsr	1,fsr1
	lfsr	0,fsr0
	
	movlw	0xA5
	movwf	INDF0		; FSR2 = A5
	movff	fsr0,reg0	; REG2 = FSR2
	xorwf	reg0,W		; Z = 1
	bnz	$

	movlw	0xB6
	movwf	INDF1
	movff	fsr1,reg1
	xorwf	reg1,W
	bnz	$

	movlw	0xC7
	movwf	INDF2
	movff	fsr2,reg2
	xorwf	reg2,W
	bnz	$
	
	retlw	0x00

	;; 
	;; SETF/NEGF/CLRF tests - OK
	;; Miscellaneous mono op operations
	;; 
_N2F_TEST:
	clrf	reg0		; Z = 1, N = 0
	movf	reg0,F
	bnz	$
	bn	$
	setf	reg0		; Z = 0, N = 1
	movf	reg0,F
	bz	$
	bnn	$	
	negf	reg0		; REG0 = 0x01
	movf	reg0,F
	bz	$
	bn	$
	retlw	0x00

	;; 
	;; BCC test - OK
	;; Tests all the Z/N/C/OV conditional branches for
	;; positive and negative results
	;; 
_BCC_TEST:
	;; Positive tests
	movlw	0x01
	movwf	reg0		; REG0 = 0x01
	
	rrcf	reg0,W		; C = 1, WREG = 0x00
	bc	$+4
	bra	$
	rlcf	reg0,W		; C = 0, WREG = 0x02
	bnc	$+4
	bra	$

	andlw	0x00		; Z = 1
	bz	$+4
	bra	$
	iorlw	0x01		; Z = 0
	bnz	$+4
	bra	$

	xorlw	0x81		; N = 1
	bn	$+4
	bra	$
	xorlw	0x80		; N = 0
	bnn	$+4
	bra	$

	;; Negative test
	movlw	0x00		; WREG = 0
	addlw	0x00		; WREG = 0, C = 0
	iorlw	0xFF		; Z = 0, N = 1
	bz	$
	bnn	$
	bc	$
	
	addlw	0x01		; C = 1, Z = 1, N = 0
	bnc	$
	bnz	$	
	bn	$

	;; Test OV
	movlw	0x80
	addlw	0x80		; C = 1, OV = 1, N = 0, Z = 1
	bnov	$
	bov	$+4
	bra	$
	retlw	0x00

	;; 
	;; BSR test - OK
	;; Simple test to check that BSR is working
	;; 
_BSR_TEST:
	movlw	0xA5		; WREG = 0xA5
	movlb	0x02		; BSR = 0x02
	movwf	0x00,B		; (0x0200) = 0xA5
	movff	0x0200, 0x0000	; (0x0000) = 0xA5
	swapf	0x0000,W	; WREG = 0x5A;
	xorlw	0x5A		; WREG = 0, Z = 1
 	bnz	$
	retlw	0x00

	;; 
	;; C used instruction tests
	;; Tests a series of instructions that use C
	;; TODO - verify
_C_TEST:
	movlw	0xFF		; Indicate Start
	movlw	0x00
	addlw	0x00		; C = 0
	movwf	reg2		; REG2 = 0
	
	movlw	0x80		; WREG = 0x80, C = 0
	addlw	0x80		; WREG = 0x00, C = 1
	rrcf	reg2,W		; WREG = 0x80, C = 0;
	addlw	0x80		; WREG = 0x00, C = 1;
	rlcf	reg2,W		; WREG = 0x01, C = 0;

	addlw	0xFF		; WREG = 0x00, C = 1;
	addwfc	reg2,W		; WREG = 0x01, C = 0;
	
	subwfb	reg2,W		; WREG = 0xFE, C = 1;
	addwfc	reg2,W		; WREG = 0xFF, C = 0;
	subfwb	reg2,W		; WREG = 0xFE, C = 0;
		
	retlw	0x00

	;; 
	;; SKIP tests - OK
	;; Tests the various SNZ/SZ/SEQ/SGT/SLT instructions
	;; 
_SKIP_TEST:
	movlw	0x01		; WREG = 0x01
	movwf	reg0		; REG0 = 0x01

	btfss	reg0,0		
	bra	$
	btfsc	reg0,1
	bra	$

	decfsz	reg0,f		; REG0 = 0x00
	bra	$
	dcfsnz	reg0,f		; REG0 = 0xFF
	bra	$
	incfsz	reg0,f		; REG0 = 0x00
	bra	$
	infsnz	reg0,f		; REG0 = 0x01
	bra	$

	cpfseq	reg0
	bra	$
	movlw	0x02		
	cpfslt	reg0
	bra	$
	movlw	0x00		; WREG = 0x00
	cpfsgt	reg0
	bra	$

	movlw	0x00
	movwf	reg2
	tstfsz	reg2
	bra	$
	
	retlw	0x00

	;; 
	;; FILE * WREG => FILE tests - OK
	;; Tests the series of byte file operations
	;; 
_FW2F_TEST:
	movlw	0xA5		; WREG = 0xA5
	movwf	reg2		; REG2 = 0xA5

	swapf	reg2,F		; REG2 = 0x5A
	andwf	reg2,F		; REG2 = 0x00
	iorwf	reg2,F		; REG2 = 0xA5
	xorwf	reg2,F		; REG2 = 0x00

	addwf	reg2,F		; REG2 = 0xA5
	subwf	reg2,F		; REG2 = 0x00

	movwf	reg2		; REG2 = 0xA5
	rrncf	reg2,F		; REG2 = 0xD2
	rlncf	reg2,F		; REG2 = 0xA5

	comf	reg2,F		; REG2 = 0x5A
	incf	reg2,F		; REG2 = 0x5B
	decf	reg2,F		; REG2 = 0x5A	

	xorwf	reg2,W		; WREG = 0xFF
	xorlw	0xFF
	bnz	$
	retlw	0x00

	;; 
	;; FILE * WREG => WREG test - OK
	;; Tests the series of byte file operations
	;; 
_FW2W_TEST:
	movlw	0xA5		; WREG = 0xA5
	movwf	reg2		; REG2 = 0xA5

	swapf	reg2,W		; WREG = 0x5A
	andwf	reg2,W		; WREG = 0x00
	iorwf	reg2,W		; WREG = 0xA5
	xorwf	reg2,W		; WREG = 0x00

	addwf	reg2,W		; WREG = 0xA5
	subwf	reg2,W		; WREG = 0x00
	
	rrncf	reg2,W		; WREG = 0xD2
	rlncf	reg2,W		; WREG = 0x4B

	comf	reg2,W		; WREG = 0x5A
	incf	reg2,W		; WREG = 0xA6
	decf	reg2,W		; WREG = 0xA4

	xorlw	0xA4
	bnz	$	
	retlw	0x00		; WREG = 0x0

	;; 
	;; MOVE FILE=>WREG/FILE=>FILE/WREG=>FILE tests - OK
	;; Tests moves between FILE and WREG
	;; 
_F2F_TEST:
	movlw	0xA5		; WREG = 0xA5
	movwf	reg0		; REG0 = 0xA5
	movlw	0x00		; WREG = 0x00
	movff	reg0,reg1	; REG1 = 0xA5
	movf	reg0,f		; REG0 = 0xA5
	movf	reg1,w		; WREG = 0xA5
	xorlw	0xA5
	bnz	$
	retlw	0x00

	;;
	;; BIT test - OK
	;; Tests the sequence of BIT ops
	;; 
_BIT_TEST:
	movlw	0xA5		; WREG = 0xA5
	movwf	reg2		; REG2 = 0xA5
	bcf	reg2,0		; 
	movf	reg2,W		; WREG = 0xA4
	bsf	reg2,0		;
	movf	reg2,W		; WREG = 0xA5
	btg	reg2,0		;
	movf	reg2,W		; WREG = 0xA4
	xorlw	0xA4		; Z = 1
	bnz	$
	retlw	0x00

	;; 
	;; LIT * WREG => WREG tests - OK
	;; Tests that the sequence of literal operations
	;; 
_LW2W_TEST:	
	movlw	0xA5		; WREG = 0xA5
	addlw	0x05		; WREG = 0xAA
	sublw	0xFF		; WREG = 0x55
	andlw	0xF0		; WREG = 0x50
	iorlw	0x0A		; WREG = 0x5A
	xorlw	0xFF 		; WREG = 0xA5
	xorlw	0xA5
	bnz	$
	retlw	0x00		; WREG = 0x00

	;; 
	;; NEAR test - OK
	;; Tests the ability to perform BRA and RCALL by doing some
	;; jump acrobatics.
	;; 
_NPC_TEST:
	bra	_NTFWD
	goto	$		; Forward Jump
_NTFWD:	bra	_NTBWD	
_NTRET:	return
	goto	$
_NTBWD:	bra	_NTRET		; Backward Jump
	goto	$

	;; 
	;; MULLW/MULWF tests - OK
	;; Tests that the multiplier produces the correct results
	;; 
_MUL_TEST:
	movlw	0x0A		; WREG = 0x0A
	movwf	reg0		; REG0 = 0x0A
	mullw	0xA0		; PRODH,PRODL = 0x0640
	
	movf	PRODH,W		; Z = 0
	xorlw	0x06		; Z = 1
	bnz	$
	movf	PRODL,W		; Z = 0
	xorlw	0x40		; Z = 1
	bnz	$

	movlw	0x40		; WREG = 0x40
	mulwf	reg0		; PRODH,PRODL = 0x0280

	movf	PRODH,W		; Z = 0
	xorlw	0x02		; Z = 1
	bnz	$
	movf	PRODL,W		; Z = 0
	xorlw	0x80		; Z = 1
	bnz	$
	
	retlw	0x00
	
	;;
	;; Interrupt Response Test - OK
	;; Just check to see if it jumps here and returns correctly.
	;; 
_ISRH_TEST:	
_ISRL_TEST:			
	nop			; Do something
	retfie	1
	
	;; Add some NOP at the end to avoid simulation error
	;; due to XXXX content at memory locations outside
	;; of the end of the programme.
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	end