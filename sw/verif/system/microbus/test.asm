	;; *******************************************************************
	;; $Id: test.asm 179 2009-04-01 19:48:38Z arniml $
	;;
	;; Test the MICROBUS functionality.
	;;

	;; the cpu type is defined on asl's command line

	org	0x00
	clra

	;; init counter with 0
	xad	3, 15


	;;
	;; microbus data is written to RAM register 0&1, digits 0-11
	;;

read_next_char:
	;; request data
	ogi	0x1
poll_write:
	skgbz	0
	jp	poll_write

	;; read posted data
	cqma
	x	1		; put A to R0, Q[3:0]
	x	1		; put M to R1, Q[7:4]

	;; check increment
	ldd	3, 15
	aisc	0x1
	cab			; set new Bd
	xad	3, 15
	aisc	0x5		; check for old Bd == 0xb
	jmp	read_next_char


	;;
	;; output received string
	;;

	;; init counter with 0
	clra
	cab
	xad	3, 15

write_next_char:
	ld	1
	ld	1		; load A from    R1, Q[7:4]
				; present M from R0, Q[3:0]
	camq

	;; request read
	ogi	0x1
poll_read:
	skgbz	0
	jp	poll_read

	;; check increment
	ldd	3, 15
	aisc	0x1
	cab			; set new Bd
	xad	3, 15
	aisc	0x5		; check for old Bd == 0xb
	jmp	write_next_char


	jmp	.
