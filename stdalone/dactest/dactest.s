;
; dactest.s -- play samples
;

	.set	dba,0xF0500000		; DAC base address
	.set	tos,0xC0020000		; top of stack

	; get some addresses listed in the load map
	.export	start
	.export	main
	.export	out

	; these labels are defined in the data file
	.import	samples
	.import	endsmpl

	; minimal execution environment
start:
	add	$29,$0,tos		; setup stack
	jal	main			; do useful work
start1:
	j	start1			; halt by looping

	; main program
main:
	sub	$29,$29,12		; create stack frame
	stw	$31,$29,0		; save return register
	stw	$16,$29,4		; save register variable
	stw	$17,$29,8		; save register variable
	add	$16,$0,samples		; pointer to samples
	add	$17,$0,endsmpl		; pointer to end of samples
loop:
	ldw	$4,$16,0		; get sample
	jal	out			; output to DAC
	add	$16,$16,4		; bump pointer
	bne	$16,$17,loop		; next sample
stop:
	ldw	$31,$29,0		; restore return register
	ldw	$16,$29,4		; restore register variable
	add	$29,$29,12		; release stack frame
	jr	$31			; return

	; output a sample (2 * 16 bit) to the DAC
out:
	add	$8,$0,dba		; set I/O base address
out1:
	ldw	$9,$8,0			; get DAC status
	and	$9,$9,1			; value needed?
	beq	$9,$0,out1		; no - wait
	stw	$4,$8,0			; send sample
	jr	$31			; return
