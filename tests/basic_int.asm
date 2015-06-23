	.module basic_int

test_ctl_port     = 0x80
print_port        = 0x81
int_timeout_port  = 0x90

	.area BOOT_VEC
	
	jp	main
	
	.area INT_VEC

int_entry:
	exx

	ld	b, a
	ld	hl, #int_seen_str

print_str:
	ld	a, (hl)
	cp	#0
	jp	z, print_str_exit
	out	(print_port), a
	inc	hl
	jp	print_str

print_str_exit:
	ld	a, b
	exx

	ld	h, #1
	reti

	.area _CODE

main:
	ld	h,  #0
	ld	bc, #100
	ld	a, #50
	out	(int_timeout_port), a

test_timeout_loop:
	ld	a, #1
	cp	h
	jp	z, test_pass
	
	dec	bc
	jp	nz, test_timeout_loop

test_fail:
	ld	a, #2
	out	(test_ctl_port), a
	.db	0x76		; hlt

test_pass:
	ld	a, #1
	out (test_ctl_port), a
	.db	0x76		; hlt
	
	.area _DATA

int_seen_str:
	.ascii "Interrupt asserted"
	.db    0x0a
	.db    0x00
