; **************************************************************************************************************
; DEMO - Simple blink test
; **************************************************************************************************************

.equ lr           r7 ; link register

.equ sys0_core    c0
.equ sys1_core    c1
.equ com0_core    c2


; **************************************************************************************************************
; Exception Vector Table
; **************************************************************************************************************

reset_vec:		b reset
x_int0_vec:		b x_int0_vec					; freeze
x_int1_vec:		b x_int1_vec					; freeze
cmd_err_vec:	b cmd_err_vec					; freeze
swi_vec:		b swi_vec						; freeze


; **************************************************************************************************************
; Main Program
; **************************************************************************************************************
reset:	clr  r0
		mcr  #1, com0_core, r0, #7				; clear system output
forever:
		ldil  r5, #50
		bl    delay								; wait some time

		mcr  #1, com0_core, r0, #7				; read system output
		sft  r0, r0, #swp						; swap bytes
		inc  r0, r0, #1							; increment
		ldil r1, #0x0F
		and  r0, r0, r1							; apply 4-bit mask
		sft  r0, r0, #swp						; swap bytes again
		mcr  #1, com0_core, r0, #7				; set system output

		b     forever							; repeat forever

; wait subroutine
delay:	ldil  r6, #0xff
		decs  r6, r6, #1
		bne   #-1
		decs  r5, r5, #1
		bne   delay
		ret   lr
