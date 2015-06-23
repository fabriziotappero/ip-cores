AC97		EQU		0xFFFF_FFFF_FFDC_1000
;--------------------------------------------------------------------------
; Setup the AC97/LM4550 audio controller. Check keyboard for a CTRL-C
; interrupt which may be necessary if the audio controller isn't 
; responding.
;--------------------------------------------------------------------------
;
SetupAC97:
	subui	sp,sp,#16
	sm		[sp],r1/lr
sac974:
	sc		r0,AC97+0x26	; trigger a read of register 26 (status reg)
sac971:						; wait for status to register 0xF (all ready)
	call	KeybdGetChar	; see if we needed to CTRL-C
	beqi	r1,#CTRLC,sac973
	lc		r1,AC97+0x68	; wait for dirty bit to clear
	bne		r1,r0,sac971
	lc		r1,AC97+0x26	; check status at reg h26, wait for
	andi	r1,r1,#0x0F		; analogue to be ready
	bnei	r1,#0x0F,sac974
sac973:
	sc		r0,AC97+2		; master volume, 0db attenuation, mute off
	sc		r0,AC97+4		; headphone volume, 0db attenuation, mute off
	sc		r0,AC97+0x18	; PCM gain (mixer) mute off, no attenuation
	sc		r0,AC97+0x0A	; mute PC beep
	setlo	r1,#0x8000		; bypass 3D sound
	sc		r1,AC97+0x20
sac972:
	call	KeybdGetChar
	beqi	r1,#CTRLC,sac975
	lc		r1,AC97+0x68	; wait for dirty bits to clear
	bne		r1,r0,sac972	; wait a while for the settings to take effect
sac975:
	lm		[sp],r1/lr
	addui	sp,sp,#16
	ret
