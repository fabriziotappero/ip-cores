;
; pbr.s -- the partition boot record
;

; Runtime environment:
;
; This code must be loaded and started at 0xC0010000.
; It allocates a stack from 0xC0011000 downwards. So
; it must run within 4K (code + data + stack).
;
; This code expects the disk number of the boot disk
; in $16, the start sector of the disk or partition
; to be booted in $17 and its size in $18.
;
; NOTE: THIS IS A FAKE PARTITION BOOT RECORD!
;       It doesn't load anything, but displays a message
;       where the real thing can be downloaded from.

	.set	stacktop,0xC0011000	; top of stack

	.set	cout,0xC0000020		; the monitor's console output

	; display a message and halt
start:
	add	$29,$0,stacktop		; setup stack
	add	$4,$0,strtmsg		; say what is going on
	jal	msgout
	j	halt

	; output message
	;   $4 pointer to string
msgout:
	sub	$29,$29,8
	stw	$31,$29,4
	stw	$16,$29,0
	add	$16,$4,0		; $16: pointer to string
msgout1:
	ldbu	$4,$16,0		; get character
	beq	$4,$0,msgout2		; done?
	jal	chrout			; output character
	add	$16,$16,1		; bump pointer
	j	msgout1			; continue
msgout2:
	ldw	$16,$29,0
	ldw	$31,$29,4
	add	$29,$29,8
	jr	$31

	; output character
	;   $4 character
chrout:
	sub	$29,$29,4
	stw	$31,$29,0
	add	$8,$0,cout
	jalr	$8
	ldw	$31,$29,0
	add	$29,$29,4
	jr	$31

	; halt execution by looping
halt:
	add	$4,$0,hltmsg
	jal	msgout
halt1:
	j	halt1

	; messages
strtmsg:
	.byte	0x0D, 0x0A
	.byte	"You didn't expect this tiny program to be"
	.byte	0x0D, 0x0A
	.byte	"a full-fledged operating system, did you?"
	.byte	0x0D, 0x0A
	.byte	"You can find the real EOS32 for ECO32 on"
	.byte	0x0D, 0x0A
	.byte	"GitHub, under the name 'eos32-on-eco32'."
	.byte	0x0D, 0x0A, 0x0D, 0x0A, 0
hltmsg:
	.byte	"bootstrap halted", 0x0D, 0x0A, 0

	; boot record signature
	.locate	512-2
	.byte	0x55, 0xAA
