
; simple instruction excerciser

        lds #$00ff
        andcc #$af  ; enable interrupts
		ldd	#$AABB
		mul
		ldx	#$1234
		ldy	#$5678
		exg	a,b
		;exg	a,x
		exg	y,x
		tfr	x,u	; 16 bit transfer
		tfr	a,u	; high to high
		tfr	b,u	
		tfr	x,a	; gets high byte
		tfr	x,b	; gets low byte
		bra	eatests
addr:		fcb	0, 4	; an address

eatests:	lda	#$02
		ldb	#$00
		sta	$0
		stb	$1
		ldx	$0	; load saved value
		ldy	#$0
		cmpx	,y	; compare
		beq	test_push_pull

error:		bra	error

test_push_pull:	lds	#$00ff
		pshs	a,b
		puls	x
		cmpx	,y	; compare again
		bne	error

		bsr	test_bsr
		bne	error	; push/pull with sub don't work
		lbsr	test_lea
		bne	error
ok:		bra	ok

test_bsr:	pshs	y
		puls	y
		cmpx	0,y
		rts

test_lea:	leau	1,y
		leay	0,y
		rts

_boot:		ldx	#100
_loop0:		ldd	#$4100
_loop1:		sta	b,x
		incb
		cmpb	#16
		bne	_loop1
		inca
_loop2:		incb
		bne	_loop2	; delay
		cmpa	#128
		beq	_loop1	; another row of characters
		bra	_loop0
		
_interrupt: nop
            nop
            rti
		
