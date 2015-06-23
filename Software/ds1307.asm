
; clear out 64 byte memory block
;
move.l	d1,#64
move.l	a0,#0xFFd80300
j1:
clr.l	(a0)+
dbeq	d1,j1

; perform write to ds1307

move.l	a0,#0xFFD8_0300
move.b	d0,#0x08
move.b	d0,7(a0)			; set register #7, bits 3:2=10

; wait 10ms
;
; perform read of ds1307
;
move.l	a0,#0xFFD8_0300
move.b	d0,#0x08
move.b	d0,7(a0)			; set register #7, bits 3:2=10

