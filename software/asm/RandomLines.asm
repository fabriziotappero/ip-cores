;--------------------------------------------------------------------------
; Draw random lines on the bitmap screen.
;--------------------------------------------------------------------------
;
message "RandomLines"
	align	8
public RandomLines:
	pha
	phx
	phy
	push	r4
	push	r5
	jsr		RequestIOFocus
	jsr		ClearScreen
	jsr		HomeCursor
	lda		#msgRandomLines
	jsr		DisplayStringB
	lda		#1
	sta		gr_cmd
rl5:
	tsr		LFSR,r1
	tsr		LFSR,r2
	tsr		LFSR,r3
	mod		r1,r1,#680
	mod		r2,r2,#384
	jsr		DrawPixel
	tsr		LFSR,r1
	sta		LineColor		; select a random color
rl1:						; random X0
	tsr		LFSR,r1
	mod		r1,r1,#680
rl2:						; random X1
	tsr		LFSR,r3
	mod		r3,r3,#680
rl3:						; random Y0
	tsr		LFSR,r2
	mod		r2,r2,#384
rl4:						; random Y1
	tsr		LFSR,r4
	mod		r4,r4,#384
rl8:
	ld		r5,GA_STATE		; make sure state is IDLE
	bne		rl8
	ld 		r5,gr_cmd
	cmp		r5,#2
	bne		rl11
	jsr		DrawLine
	bra		rl12
rl11:
	cmp		r5,#1
	bne		rl13
	jsr		DrawPixel
	bra		rl12
rl13:
	cmp		r5,#4
	bne		rl12
	jsr		DrawRectangle
rl12:
	jsr		KeybdGetChar
	cmp		#CTRLC
	beq		rl7
	cmp		#'p'
	bne		rl9
	jsr		ClearBmpScreen
	lda		#1
	sta		gr_cmd
	bra		rl5
rl9:
	cmp		#'r'
	bne		rl10
	jsr		ClearBmpScreen
	lda		#4
	sta		gr_cmd
	bra		rl5
rl10
	cmp		#'l'
	bne		rl5
	jsr		ClearBmpScreen
	lda		#2
	sta		gr_cmd
	bra		rl5
rl7:
;	jsr		ReleaseIOFocus
	pop		r5
	pop		r4
	ply
	plx
	pla
	rts


msgRandomLines:
	db		CR,LF,"Random lines running - press CTRL-C to exit.",CR,LF,0

;--------------------------------------------------------------------------
; Draw a pixel on the bitmap screen.
; r1 = x coordinate
; r2 = y coordinate
; r3 = color
;--------------------------------------------------------------------------
message "DrawPixel"
DrawPixel:
	pha
	sta		GA_X0
	stx		GA_Y0
	sty		GA_PEN
	lda		#1
	sta		GA_CMD
	pla
	rts
comment ~
	pha
	phx
	mul		r2,r2,#680	; y * 680
	add		r1,r1,r2	; + x
	sb		r3,BITMAPSCR<<2,r1
	plx
	pla
	rts
~
;--------------------------------------------------------------------------
; Draw a line on the bitmap screen.
;--------------------------------------------------------------------------
;50 REM DRAWLINE
;100 dx = ABS(xb-xa)
;110 dy = ABS(yb-ya)
;120 sx = SGN(xb-xa)
;130 sy = SGN(yb-ya)
;140 er = dx-dy
;150 PLOT xa,ya
;160 if xa<>xb goto 200
;170 if ya=yb goto 300
;200 ee = er * 2
;210 if ee <= -dy goto 240
;220 er = er - dy
;230 xa = xa + sx
;240 if ee >= dx goto 270
;250 er = er + dx
;260 ya = ya + sy
;270 GOTO 150
;300 RETURN

message "DrawLine"
DrawLine:
	pha
	sta		GA_X0
	stx		GA_Y0
	sty		GA_X1
	st		r4,GA_Y1
	lda		LineColor
	sta		GA_PEN
	lda		#2
	sta		GA_CMD
	pla
	rts

DrawRectangle:
	pha
	sta		GA_X0
	stx		GA_Y0
	sty		GA_X1
	st		r4,GA_Y1
	lda		LineColor
	sta		GA_PEN
	lda		#4
	sta		GA_CMD
	pla
	rts

comment ~
	pha
	phx
	phy
	push	r4
	push	r5
	push	r6
	push	r7
	push	r8
	push	r9
	push	r10
	push	r11

	sub		r5,r3,r1	; dx = abs(x2-x1)
	bpl		dln1
	sub		r5,r0,r5
dln1:
	sub		r6,r4,r2	; dy = abs(y2-y1)
	bpl		dln2
	sub		r6,r0,r6
dln2:

	sub		r7,r3,r1	; sx = sgn(x2-x1)
	beq		dln5
	bpl		dln4
	ld		r7,#-1
	bra		dln5
dln4:
	ld		r7,#1
dln5:

	sub		r8,r4,r2	; sy = sgn(y2-y1)
	beq		dln8
	bpl		dln7
	ld		r8,#-1
	bra		dln8
dln7:
	ld		r8,#1

dln8:
	sub		r9,r5,r6	; er = dx-dy
dln150:
	phy
	ldy		LineColor
	jsr		DrawPixel
	ply
	cmp		r1,r3		; if (xa <> xb)
	bne		dln200		;    goto 200
	cmp		r2,r4		; if (ya==yb)
	beq		dln300		;    goto 300
dln200:
	asl		r10,r9		; ee = er * 2
	sub		r11,r0,r6	; r11 = -dy
	cmp		r10,r11		; if (ee <= -dy)
	bmi		dln240		;     goto 240
	beq		dln240
	sub		r9,r9,r6	; er = er - dy
	add		r1,r1,r7	; xa = xa + sx
dln240:
	cmp		r10,r5		; if (ee >= dx)
	bpl		dln150		;    goto 150
	add		r9,r9,r5	; er = er + dx
	add		r2,r2,r8	; ya = ya + sy
	bra		dln150		; goto 150

dln300:
	pop		r11
	pop		r10
	pop		r9
	pop		r8
	pop		r7
	pop		r6
	pop		r5
	pop		r4
	ply
	plx
	pla
	rts
~

