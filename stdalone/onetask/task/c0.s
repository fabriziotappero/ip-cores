;
; c0.s -- startup code and begin-of-segment labels
;

	.import	main

	.export	_bcode
	.export	_bdata
	.export	_bbss

	.import	_ecode
	.import	_edata
	.import	_ebss

	.code
_bcode:

	.data
_bdata:

	.bss
_bbss:

	.code
	.align	4

start:
	jal	main		; call 'main' function
stop:
	j	stop		; just to be sure...
