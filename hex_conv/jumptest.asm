;
	LIST    p=16C58 ; PIC16C58 is the target processor


;
; Core Sanity Test
;
; JUMPTEST.ASM
;
; test some jumps
; NEW in rev 1.1, test indirect addressing
; test some inc & decs
; sit in loop multiplying port A with a constant
; output 16 bit result on ports C & B
;

CARRY   equ     H'00'   ; Carry bit in STATUS register
DC      equ     H'01'   ; DC    bit in STATUS register
ZERO    equ     H'02'   ; Zero  bit in STATUS register
W       equ     H'00'   ; W indicator for many instruction (not the address!)

INDF    equ     H'00'   ; Magic register that uses INDIRECT register
TIMER0  equ     H'01'   ; Timer register
PC      equ     H'02'   ; PC
STATUS  equ     H'03'   ; STATUS register F3
FSR     equ     H'04'   ; INDIRECT Pointer Register
porta   equ     H'05'   ; I/O register F5
portb   equ     H'06'   ; I/O register F6
portc   equ     H'07'   ; I/O register F7
x       equ     H'09'   ; scratch
y       equ     H'0A'   ; scratch
rh      equ     H'0B'   ; result h
rl      equ     H'0C'   ; result l

mult    MACRO   bit
	btfsc   y,bit
	addwf   rh,1
	rrf     rh,1
	rrf     rl,1
	ENDM

start:  movlw   H'ff'
	tris    porta   ; PORTA is Input
	clrw
	tris    portb   ; PORTB is Output
	tris    portc   ; PORTC is Output
	movwf   portb   ; PORTB <= 00

	movlw   h'0B'
	movwf   PC      ; move to pc (jump1)

	movlw   h'F0'   ; fail 0
	movwf   portb
	goto fail

jump1:  movlw   h'05'
	addwf   PC,f   ; jump forward to jump2
	movlw   h'F1'   ; fail 1
	movwf   portb
	goto fail

jump3:  goto    jump4   ; continue
	nop

jump2:  movlw   h'04'
	subwf   PC, f   ; jump back to jump 3

	movlw   h'F2'   ; fail 2
	movwf   portb
	goto fail

jump4:  
	movlw	h'10'	; set locations 10-1F to xFF
	movwf	FSR
	movlw	h'ff'
clrlp:	movwf	INDF
	incf	FSR,F
	btfsc	FSR,4
	goto clrlp

	movlw	h'10'
	movwf	x
	movlw	h'20'
	movwf	y
	
	movlw	x
	movwf	FSR	; point FSR at x

	movf	FSR,w
	xorlw	h'89'   ; check its x (note bit 7 set always)
	btfss   STATUS,ZERO
        goto 	fail
	movf	INDF,w
	xorlw	h'10'	; check its 10
	btfss   STATUS,ZERO
        goto 	fail
	
	movlw	h'15'	; write 15 to x using INDF
	movwf	INDF
	movf	x,w	; read x
	xorlw	h'15'	; check its 15
	btfss   STATUS,ZERO
        goto 	fail

	incf	FSR,F
	movf	INDF,w
	xorlw	h'20'	; check its 20
	btfss   STATUS,ZERO
        goto 	fail

	movlw	h'00'
	movwf	FSR
	movlw	h'A5'	; paranoid !
	movf	INDF,w	; reading INDR itself should = 0
	xorlw	h'00'	; check
	btfss	STATUS,ZERO
	goto 	fail
	
	; check banking 	
	; locations 20-2F, 40-4F, 60-6F all map to 0-0F
	; locations 10-1F, 30-3F, 50-5F, 70-7F are real


	movlw	h'00'
	movwf	FSR	; set bank 0
	movlw 	h'1F'
	movwf	h'1F'

	movlw	h'20'
	movwf	FSR	; set bank 1
	movlw	h'3F'
	movwf	h'1F'

	movlw	h'40'
	movwf	FSR	; set bank 2
	movlw	h'5F'
	movwf	h'1F'

	movlw	h'60'
	movwf	FSR	; set bank 3
	movlw	h'7F'
	movwf	h'1F'
	; check

	movlw	h'00'
	movwf	FSR	; set bank 0
	movf	h'1F',w
	xorlw	h'1F'
	btfss   STATUS,ZERO
        goto 	fail

	movlw	h'20'
	movwf	FSR	; set bank 1
	movf	h'1F',w
	xorlw	h'3F'
	btfss   STATUS,ZERO
        goto 	fail

	movlw	h'40'
	movwf	FSR	; set bank 2
	movf	h'1F',w	
	xorlw	h'5F'
	btfss   STATUS,ZERO
        goto 	fail

	movlw	h'60'
	movwf	FSR	; set bank 3
	movf	h'1F',w
	xorlw	h'7F'
	btfss   STATUS,ZERO
        goto 	fail
	
	movlw	h'00'
	movwf	FSR	; set bank 0
	
	movlw	h'45'
	movwf	h'0F'
	
	movlw	h'60'
	movwf	FSR	; set bank 3
	movlw	h'54'
	movwf	h'0F'

	movlw	h'40'
	movwf	FSR	; set bank 2	
	movf	h'0f',w	; w should contain 54
	
	xorlw	h'54'
	btfsc   STATUS,ZERO
        goto test1

	movlw   h'F3'   ; fail 3
	movwf   portb
	
	goto fail

test1:	movlw	h'00'
	movwf	FSR	; set bank 0
	movlw   h'04'   ; w <= 04
	movwf   x
	decf    x,f     ; x <= 03
	decf    x,f     ; x <= 02
	decf    x,f     ; x <= 01
	decf    x,f     ; x <= 00
	decf    x,f     ; x <= FF
	movf    x,w
	xorlw   h'FF'   ; does w = ff ?
	btfss   STATUS,ZERO ; skip if clear
	goto    fail
	incf    x,f     ; x <= 00
	incf    x,f     ; x <= 01
	movf    x,w
	xorlw   h'01'   ; does w = 01
	btfss   STATUS,ZERO
	goto    fail

	; test logic

	clrf	x 	; x <= 00
	movlw   h'a5'
	iorwf	x,f 	; x <= a5
	swapf	x,f	; x <= 5a
        movlw	h'f0'
	andwf	x,f	; x <= 50
	comf	x,f 	; x <= af
	movlw	h'5a'
	xorwf	x,f	; x <= f5
	
	;check
	movfw	x
	xorlw	h'f5'
	btfsc   STATUS,ZERO
        goto test2
	movlw   h'F4'   ; fail 4
	movwf   portb
	goto fail
        
test2:	movlw	h'23'
	movwf	x	; x <= 23
	movlw	h'e1'	; w <= e1
	addwf	x,f	; x <= 04
	btfss	STATUS,CARRY 
	goto	fail	; carry should be set
	movlw	h'02'	; w <= 02
	subwf	x,f	; x <= 02
	btfss	STATUS,CARRY 
	goto	fail	; borrow should be clear

	movlw	h'34'	; w <= 34
	subwf	x,f	; x <= ce
	btfsc	STATUS,CARRY 
	goto	fail	; borrow should be set

	movf	x,w
	xorlw	h'CE'
	btfss	STATUS,ZERO
 	goto	fail	; x /= ce

test3:	movlw	h'34'	; test dc flag
	movwf	x
	movlw	h'0F'
	addwf	x,f	; x <= 43
	btfsc	STATUS,CARRY
	goto	fail	; carry should be clear
	btfss	STATUS,DC
	goto	fail	; dc should be set
	movlw	h'01'
	subwf	x,f	; x <= 42
	btfss	STATUS,CARRY
	goto	fail	; borrow should be clear
	btfss	STATUS,DC
	goto	fail	; dc borrow should be clear
	movlw	h'FF'
	subwf	x,f
	btfsc	STATUS,CARRY
	goto	fail	; borrow should be set
	btfsc  STATUS,DC
	goto	fail	; dc borrow should be set

	movf	x,w
	xorlw	h'43'	; final check
	btfss	STATUS,ZERO
 	goto	fail	; x /= 43
	movlw   h'E0'   ; ok
	movwf   portb

loop1:                  ; mult x by y
	movf    porta,W
	movwf   x
	movlw   h'23'
	movwf   y

	clrf    rh
	clrf    rl
	movf    x,w
	bcf     STATUS,CARRY
	mult    0
	mult    1
	mult    2
	mult    3
	mult    4
	mult    5
	mult    6
	mult    7

	movf    rl,w
	movwf   portb   ; on port b low result
	movf    rh,w
	movwf   portc   ; on port c high result
	goto    loop1

fail:   goto    fail 
	end
