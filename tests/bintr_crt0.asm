	;; Generic crt0.s for a Z80
        .module bintr_crt0
       	.globl	_main
        .globl  _isr
        .globl  _nmi_isr

	.area _HEADER (ABS)
	;; Reset vector
	.org 	0
	jp	init

	.org	0x08
	reti
	.org	0x10
	reti
	.org	0x18
	reti
	.org	0x20
	reti
	.org	0x28
	reti
	.org	0x30
	reti
	.org	0x38
        di
        push    af
        call _isr
        pop     af
        ei
	reti
	
        .org    0x66
        push    af
        call    _nmi_isr
        pop     af
        retn
        
	.org	0x100
init:
	;; Stack at the top of memory.
	ld	sp,#0xffff        

    ;; enable interrupts
        im      1
        ei
    
        ;; Initialise global variables
	call	_main
	jp	_exit

	;; Ordering of segments for the linker.
	.area	_HOME
	.area	_CODE
        .area   _GSINIT
        .area   _GSFINAL
        
	.area	_DATA
        .area   _BSS
        .area   _HEAP

        .area   _CODE
__clock::
	ld	a,#2
        rst     0x08
	ret
	
_exit::
	;; Exit - special code to the emulator
	ld	a,#0
        rst     0x08
1$:
	halt
	jr	1$

        .area   _GSINIT
gsinit::	

        .area   _GSFINAL
        ret
