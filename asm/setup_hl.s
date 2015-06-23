;**********************************************************************************
;*                                                                                *
;* set up hl register for trap patterns                                           *
;*                                                                                *
;**********************************************************************************
	org	00h
	jp	100h

	org	0c0h		;pattern finish location
	nop
	jr	0c0h

	org	0100h
	ld	hl, 0100h	;init hl for next pattern
	jp	0c0h
