PSG			EQU		0xFFFF_FFFF_FFD5_0000
PSGFREQ0	EQU		0xFFFF_FFFF_FFD5_0000
PSGPW0		EQU		0xFFFF_FFFF_FFD5_0002
PSGCTRL0	EQU		0xFFFF_FFFF_FFD5_0004
PSGADSR0	EQU		0xFFFF_FFFF_FFD5_0006

;--------------------------------------------------------------------------
; Sound a 800 Hz beep
;--------------------------------------------------------------------------
;
Beep:
	subui	sp,sp,#16
	sm		[sp],r1/lr
	ori		r1,r0,#15		; master volume to max
	sc		r1,PSG+128
	ori		r1,r0,#13422	; 800Hz
	sc		r1,PSGFREQ0
	; decay  (16.384 ms)2
	; attack (8.192 ms)1
	; release (1.024 s)A
	; sustain level C
	setlo	r1,#0xCA12
	sc		r1,PSGADSR0
	ori		r1,r0,#0x1104	; gate, output enable, triangle waveform
	sc		r1,PSGCTRL0
	ori		r1,r0,#25000000	; delay about 1s
beep1:
	loop	r1,beep1
	ori		r1,r0,#0x0104	; gate off, output enable, triangle waveform
	sc		r1,PSGCTRL0
	ori		r1,r0,#25000000	; delay about 1s
beep2:
	loop	r1,beep2
	ori		r1,r0,#0x0000	; gate off, output enable off, no waveform
	sc		r1,PSGCTRL0
	lm		[sp],r1/lr
	ret		#16

