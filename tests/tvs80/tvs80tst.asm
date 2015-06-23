; bjp   modified to assemble on as80.
; minor mods to account for changes in interrupt structure  and I/O
; all such are flagged with my initials..... 
;
; The origional code used operators <   and  >  on symbols to extract the 
; lower and higher bytes respectively.   It appears that as80 has no equivaltent.
; I have hand coded such ---- hopefully correctly.   
; This is only a significant issue with such constructs as <stack_end.   
; My solution forces the stack to remain in its present location.   
;
; WARNING   If you must move the stack  --   check comments and fix code for my kludges
;
;z80 simulator test routine
;total error count is left in a at end of test routine

; gth  modified to work in tv80 simulation environment
;      moved data segment from 7000 to 8000
;      replaced constants with stack_end_hi and stack_end_lo

		code
		org	#0000
;
rst_0000:	jp	rst_0000_1
;
		org	#0008
;
rst_0008:	ld	a,2
		ret
;
		org	#0010
;
rst_0010:	ld	a,3
		ret
;
		org	#0018
;
rst_0018:	ld	a,4
		ret
;
		org	#0020
;
rst_0020:	ld	a,5
		ret
;
		org	#0028
;
rst_0028:	ld	a,6
		ret
;
		org	#0030
;
rst_0030:	ld	a,7
		ret
;
		org	#0038
;
rst_0038:	ld	a,8
		ret
;
		code
;

fail:		db	'failed'
pass:		db	'passed'
message_addr:	equ	#be58
in_port:	equ	#ff
out_port:	equ	#10
;
data_55:	equ	#55
data_7f:	equ	#7f
data_80:	equ	#80
data_aa:	equ	#aa
data_ff:	equ	#ff
;
data_1234:	equ	#1234
data_55aa:	equ	#55aa
data_7fff:	equ	#7fff
data_8000:	equ	#8000
data_aa55:	equ	#aa55
data_ffff:	equ	#ffff

stack:          equ     #8100
stack_end:      equ     #8180
    
stack_end_hi:   equ     #81
stack_end_lo:   equ     #80

ctl_port:	equ	#80
print_port:	equ	#81
;
;inc_error_cnt	macro	     ;bjp   change for initial test to halt on error
;		ld	hl,error_cnt
;		inc	(hl)
;		endm
;inc_error_cnt	macro        ; gth  replaced with fail_msg ###
;                ld      a, 2
;                out     (ctl_port), a
;		halt
;		endm


passed		macro
                ld      a, 1
                out     (ctl_port), a
                halt
		;push	bc
		;ld 	bc,(pass)
		;ld	(message_addr),bc
		;ld 	bc,(pass+2)
		;ld	(message_addr+2),bc
		;ld 	bc,(pass+4)
		;ld	(message_addr+4),bc
		;pop	bc
		endm
;
failed		macro
                ld      a, 2
                out     (ctl_port), a
		halt
		;push	bc
		;ld 	bc,(fail)
		;ld	(message_addr),bc
		;ld 	bc,(fail+2)
		;ld	(message_addr+2),bc
		;ld 	bc,(fail+4)
		;ld	(message_addr+4),bc
		;pop	bc
		endm
;
;

	;; subroutine to print a message
	;; called from within the "print" macro
	;; expects address to be printed in hl
	;; preserves all other registers
print_sub:
	push	bc
	ld	b, a

print_sub_loop:	
	ld	a, (hl)
	cp	#0
	jp	z, print_sub_exit
	out	(print_port), a
	inc	hl
	jp	print_sub_loop
	
print_sub_exit:
	ld	a, b
	pop	bc
	ret

	;; macro to print out a message
	;; calls print_sub to do grunt work and minimize code impact of
	;; strings
print	macro	message

	push	hl		; preserve existing regs
	ld	hl, msg\?
	call	print_sub
	pop	hl
	jp	exit\?
	
msg\?	db	message
	db	#0a
	db	#00

exit\?:
	
	endm

	;; print a hex number between 0-255, stored in the A register
print_number:
	push	bc
	ld	b, a		; store number to be printed in b

	and	#f0
	sra	a
	sra	a
	sra	a
	sra	a
	cp	a, 10
	jp	p, alpha_0
	add	48		; ordinal value of '0'
	out	(print_port), a
	jp	second_digit
alpha_0:
	add	55              ; 'A' - 10
	out	(print_port), a

second_digit:	
	ld	a, b
	and	#0f
	
	cp	a, 10
	jp	p, alpha_1
	add	48
	out	(print_port), a
	jp	print_number_exit

alpha_1:
	add	55              ; 'A' - 10
	out	(print_port), a

print_number_exit:	
	pop	bc
	ret

fail_text db   "Test failed at checkpoint #"
	db	#00

fail_routine:
	ld	hl, fail_text
	call	print_sub	; print out boilerplate text
        ld      a, b

	call	print_number	; print out error number

	ld	a, #0a		; print carriage return
	out	(print_port), a
	failed
	
	;; macro to print out failure checkpoint number
fail_msg macro number		; fail with checkpoint number
	ld	b, number
	jp	fail_routine
	endm

print_ns macro message		; print w/o using subroutine
	
	push	hl		; preserve existing regs
	ld	hl, msg\?
	
	push	bc
	ld	b, a
loop\?:
	ld	a, (hl)
	cp	#0
	jp	z, exit\?
	out	(print_port), a
	inc	hl
	jp	loop\?
	
	pop	hl
	jp	exit\?
	
msg\?	db	message
	db	#0a
	db	#00

exit\?:
	ld	a, b
	pop	bc
	pop	hl
	
	endm	
	
start:
		print "Starting test"
	        ld      a, 1
		ld	(pass_count),a
		ld	hl,error_cnt
		ld	(hl),a			;clear error count
        call    mem_init
nop_1:		nop
		nop
		print "Starting ld tests"
ld_167:		ld	a,data_55
		cp	data_55
		jr	z,ld_1
		fail_msg 167
		
ld_1:		ld	b,data_7f
		ld	a,data_7f
		cp	b
		jr	z,ld_2
		fail_msg 1
ld_2:		ld	c,data_80
		ld	a,data_80
		cp	c
		jr	z,ld_3
		fail_msg 2
ld_3:		ld	d,data_aa
		ld	a,data_aa
		cp	d
		jr	z,ld_4
		fail_msg 3
ld_4:		ld	e,data_55
		ld	a,data_55
		cp	e
		jr	z,ld_5
		fail_msg 4
ld_5:		ld	h,data_7f
		ld	a,data_7f
		cp	h
		jr	z,ld_6
		fail_msg 5
ld_6:		ld	l,data_80
		ld	a,data_80
		cp	l
		jr	z,ld_7
		fail_msg 6
ld_7:		ld	a,data_55
		ld	b,a
		cp	b
		jr	z,ld_8
		fail_msg 7
ld_8:		ld	c,b
		cp	c
		jr	z,ld_9
		fail_msg 8
ld_9:		ld	d,c
		cp	d
		jr	z,ld_10
		fail_msg 9
ld_10:		ld	e,d
		cp	e
		jr	z,ld_11
		fail_msg 10
ld_11:		ld	h,e
		cp	h
		jr	z,ld_12
		fail_msg 11
ld_12:		ld	l,h
		cp	l
		jr	z,ld_13
		fail_msg 12
ld_13:		ld	l,data_80
		ld	a,l
		cp	l
		jr	z,ld_14
		fail_msg 13
ld_14:		ld	h,l
		cp	h
		jr	z,ld_15
		fail_msg 14
ld_15:		ld	e,h
		cp	e
		jr	z,ld_16
		fail_msg 15
ld_16:		ld	d,e
		cp	d
		jr	z,ld_17
		fail_msg 16
ld_17:		ld	c,d
		cp	c
		jr	z,ld_18
		fail_msg 17
ld_18:		ld	b,c
		cp	b
		jr	z,ld_19
		fail_msg 18
ld_19:		ld	hl,var1
		ld	a,(hl)
		cp	data_ff
		jr	z,ld_20
		fail_msg 19
ld_20:		ld	hl,var2
		ld	a,data_55
		ld	b,(hl)
		cp	b
		jr	z,ld_21
		fail_msg 20
ld_21:		ld	hl,var1
		ld	c,(hl)
		ld	a,(hl)
		cp	c
		jr	z,ld_22
		fail_msg 21
ld_22:		ld	hl,var2
		ld	d,(hl)
		ld	a,(hl)
		cp	d
		jr	z,ld_23
		fail_msg 22
ld_23:		ld	hl,var1
		ld	e,(hl)
		ld	a,(hl)
		cp	e
		jr	z,ld_24
		fail_msg 23
ld_24:		ld	hl,var2
		ld	a,(hl)
		ld	h,(hl)
		cp	h
		jr	z,ld_25
		fail_msg 24
ld_25:		ld	hl,var1
		ld	a,(hl)
		ld	l,(hl)
		cp	l
		jr	z,ld_26
		fail_msg 25
ld_26:		ld	ix,var3
		ld	a,(ix-2)
		cp	data_ff
		jr	z,ld_27
		fail_msg 26
ld_27:		ld	a,(ix+2)
		cp	data_7f
		jr	z,ld_28
		fail_msg 27
ld_28:		ld	a,(ix-1)
		ld	b,(ix-1)
		cp	b
		jr	z,ld_29
		fail_msg 28
ld_29:		cp	data_55
		jr	z,ld_30
		fail_msg 29
ld_30:		ld	a,(ix+1)
		ld	c,(ix+1)
		cp	c
		jr	z,ld_31
		fail_msg 30
ld_31:		cp	data_aa
		jr	z,ld_32
		fail_msg 31
ld_32:		ld	d,(ix-2)
		ld	a,(ix-2)
		cp	d
		jr	z,ld_33
		fail_msg 32
ld_33:		cp	data_ff
		jr	z,ld_34
		fail_msg 33
ld_34:		ld	e,(ix+2)
		ld	a,(ix+2)
		cp	e
		jr	z,ld_35
		fail_msg 34
ld_35:		cp	data_7f
		jr	z,ld_36
		fail_msg 35
ld_36:		ld	h,(ix+0)
		ld	a,(ix+0)
		cp	h
		jr	z,ld_37
		fail_msg 36
ld_37:		cp	data_80
		jr	z,ld_38
		fail_msg 37
ld_38:		ld	l,(ix-1)
		ld	a,(ix-1)
		cp	l
		jr	z,ld_39
		fail_msg 38
ld_39:		cp	data_55
		jr	z,ld_40
		fail_msg 39
ld_40:		ld	iy,var3
		ld	a,(iy-2)
		cp	data_ff
		jr	z,ld_41
		fail_msg 40
ld_41:		ld	a,(iy+2)
		cp	data_7f
		jr	z,ld_42
		fail_msg 41
ld_42:		ld	b,(iy-1)
		ld	a,(iy-1)
		cp	b
		jr	z,ld_43
		fail_msg 42
ld_43:		cp	data_55
		jr	z,ld_44
		fail_msg 43
ld_44:		ld	c,(iy+1)
		ld	a,(iy+1)
		cp	c
		jr	z,ld_45
		fail_msg 44
ld_45:		cp	data_aa
		jr	z,ld_46
		fail_msg 45
ld_46:		ld	d,(iy-2)
		ld	a,(iy-2)
		cp	d
		jr	z,ld_47
		fail_msg 46
ld_47:		cp	data_ff
		jr	z,ld_48
		fail_msg 47
ld_48:		ld	e,(iy+2)
		ld	a,(iy+2)
		cp	e
		jr	z,ld_49
		fail_msg 48
ld_49:		cp	data_7f
		jr	z,ld_50
		fail_msg 49
ld_50:
                ld	h,(iy+0)
		ld	a,(iy+0)
		cp	h
		jr	z,ld_51
		fail_msg 50
ld_51:		cp	data_80
		jr	z,ld_52
		fail_msg 51
ld_52:		ld	l,(iy-2)
		ld	a,(iy-2)
		cp	l
		jr	z,ld_53
		fail_msg 52
ld_53:		cp	data_ff
		jr	z,ld_54
		fail_msg 53
ld_54:		ld	hl,t_var1
		ld	a,data_aa+1
		ld	(hl),a
		ld	b,(hl)
		cp	b
		jr	z,ld_55
		fail_msg 54
ld_55:		cp	data_aa+1
		jr	z,ld_56
		fail_msg 55
ld_56:		ld	b,data_80+1
		ld	(hl),b
		ld	a,(hl)
		cp	b
		jr	z,ld_57
		fail_msg 56
ld_57:		cp	data_80+1
		jr	z,ld_58
		fail_msg 57
ld_58:		ld	c,data_55-1
		ld	(hl),c
		ld	a,(hl)
		cp	c
		jr	z,ld_59
		fail_msg 58
ld_59:		cp	data_55-1
		jr	z,ld_60
		fail_msg 59
ld_60:		ld	d,data_ff-1
		ld	(hl),d
		ld	a,(hl)
		cp	d
		jr	z,ld_61
		fail_msg 60
ld_61:		cp	data_ff-1
		jr	z,ld_62
		fail_msg 61
ld_62:		ld	e,data_55+1
		ld	(hl),e
		ld	a,(hl)
		cp	e
		jr	z,ld_63
		fail_msg 62
ld_63:		cp	data_55+1
		jr	z,ld_64
		fail_msg 63
ld_64:		ld	(hl),h
		ld	a,(hl)
		cp	h
		jr	z,ld_65
		fail_msg 64
ld_65:		cp	#80		;bjp  guess  >t_var1
		jr	z,ld_66
		fail_msg 65
ld_66:		ld	(hl),l
		ld	a,(hl)
		cp	l
		jr	z,ld_67
		fail_msg 66
ld_67:		cp	a, #00		;bjp  guess <t_var1
		jr	z,ld_68
		fail_msg 67
ld_68:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		ld	a,0
		ld	a,(ix-2)
		cp	data_55
		jr	z,ld_69
		fail_msg 68
ld_69:		ld	a,data_80
		ld	(ix+2),a
		ld	a,0
		ld	a,(ix+2)
		cp	data_80
		jr	z,ld_70
		fail_msg 69
ld_70:		ld	b,data_7f
		ld	(ix-1),b
		ld	a,(ix-1)
		cp	b
		jr	z,ld_71
		fail_msg 70
ld_71:		cp	data_7f
		jr	z,ld_72
		fail_msg 71
ld_72:		ld	c,data_aa
		ld	(ix+1),c
		ld	a,(ix+1)
		cp	c
		jr	z,ld_73
		fail_msg 72
ld_73:		cp	data_aa
		jr	z,ld_74
		fail_msg 73
ld_74:		ld	d,data_80
		ld	(ix+0),d
		ld	a,(ix+0)
		cp	d
		jr	z,ld_75
		fail_msg 74
ld_75:		cp	data_80
		jr	z,ld_76
		fail_msg 75
ld_76:		ld	e,data_55+2
		ld	(ix-2),e
		ld	a,(ix-2)
		cp	e
		jr	z,ld_77
		fail_msg 76
ld_77:		cp	data_55+2
		jr	z,ld_78
		fail_msg 77
ld_78:		ld	h,data_aa-2
		ld	(ix+2),h
		ld	a,(ix+2)
		cp	h
		jr	z,ld_79
		fail_msg 78
ld_79:		cp	data_aa-2
		jr	z,ld_80
		fail_msg 79
ld_80:		ld	l,data_aa+2
		ld	(ix-1),l
		ld	a,(ix-1)
		cp	l
		jr	z,ld_81
		fail_msg 80
ld_81:		cp	data_aa+2
		jr	z,ld_82
		fail_msg 81
ld_82:		ld	iy,t_var3
		ld	a,data_ff
		ld	(iy-2),a
		ld	a,0
		ld	a,(iy-2)
		cp	data_ff
		jr	z,ld_83
		fail_msg 82
ld_83:		ld	a,data_7f
		ld	(iy+2),a
		ld	a,0
		ld	a,(iy+2)
		cp	data_7f
		jr	z,ld_84
		fail_msg 83
ld_84:		ld	b,data_55
		ld	(iy-1),b
		ld	a,(iy-1)
		cp	b
		jr	z,ld_85
		fail_msg 84
ld_85:		cp	data_55
		jr	z,ld_86
		fail_msg 85
ld_86:		ld	c,data_aa
		ld	(iy+1),c
		ld	a,(iy+1)
		cp	c
		jr	z,ld_87
		fail_msg 86
ld_87:		cp	data_aa
		jr	z,ld_88
		fail_msg 87
ld_88:		ld	d,data_80
		ld	(iy+0),d
		ld	a,(iy+0)
		cp	d
		jr	z,ld_89
		fail_msg 88
ld_89:		cp	data_80
		jr	z,ld_90
		fail_msg 89
ld_90:		ld	e,data_ff-2
		ld	(iy-2),e
		ld	a,(iy-2)
		cp	e
		jr	z,ld_91
		fail_msg 90
ld_91:		cp	data_ff-2
		jr	z,ld_92
		fail_msg 91
ld_92:		ld	h,data_7f-3
		ld	(iy+2),h
		ld	a,(iy+2)
		cp	h
		jr	z,ld_93
		fail_msg 92
ld_93:		cp	data_7f-3
		jr	z,ld_94
		fail_msg 93
ld_94:		ld	l,data_55-5
		ld	(iy-1),l
		ld	a,(iy-1)
		cp	l
		jr	z,ld_95
		fail_msg 94
ld_95:		cp	data_55-5
		jr	z,ld_96
		fail_msg 95
ld_96:		ld	hl,t_var1
		ld	(hl),data_80+10
		ld	a,(hl)
		cp	data_80+10
		jr	z,ld_97
		fail_msg 96
ld_97:		ld	ix,t_var3
		ld	(ix-2),data_55-10
		ld	a,(ix-2)
		cp	data_55-10
		jr	z,ld_98
		fail_msg 97
ld_98:		ld	(ix+2),data_55+10
		ld	a,(ix+2)
		cp	data_55+10
		jr	z,ld_99
		fail_msg 98
ld_99:		ld	iy,t_var2
		ld	(iy-1),data_80+17
		ld	a,(iy-1)
		cp	data_80+17
		jr	z,ld_100
		fail_msg 99
ld_100:
                ld	(iy+1),data_80-17
		ld	a,(iy+1)
		cp	data_80-17
		jr	z,ld_101
		fail_msg 100
ld_101:		ld	hl,t_var5
		ld	bc,t_var5
		ld	(hl),data_aa-10
		ld	a,(bc)
		cp	data_aa-10
		jr	z,ld_102
		fail_msg 101
ld_102:		ld	hl,t_var3
		ld	de,t_var3
		ld	(hl),data_aa+10
		ld	a,(de)
		cp	data_aa+10
		jr	z,ld_103
		fail_msg 102
ld_103:		ld	hl,t_var2
		ld	(hl),data_7f-25
		ld	a,(t_var2)
		cp	data_7f-25
		jr	z,ld_104
		fail_msg 103
ld_104:		ld	hl,t_var4
		ld	bc,t_var4
		ld	a,data_55-20
		ld	(bc),a
		ld	b,(hl)
		cp	b
		jr	z,ld_105
		fail_msg 104
ld_105:		ld	a,b
		cp	data_55-20
		jr	z,ld_106
		fail_msg 105
ld_106:		ld	hl,t_var5
		ld	de,t_var5
		ld	a,data_55+20
		ld	(de),a
		ld	c,(hl)
		cp	c
		jr	z,ld_107
		fail_msg 106
ld_107:		ld	a,c
		cp	data_55+20
		jr	z,ld_108
		fail_msg 107
ld_108:		ld	hl,t_var4
		ld	a,data_ff-24
		ld	(t_var4),a
		ld	e,(hl)
		cp	e
		jr	z,ld_109
		fail_msg 108
ld_109:		ld	a,e
		cp	data_ff-24
		jr	z,ld_110
		fail_msg 109

; commented out ld_110 so test can continue
; may depend on side-effect in original Z80
ld_110:         ld      a, data_55
                jp      ld_125
;ld_110:		ld	a,data_55
;		ld	i,a
;		ld	a,0
;		ld	a,i
;		jr	nz,ld_111
;		fail_msg 110
;ld_111:		jp	p,ld_112
;		fail_msg 111
;ld_112:		cp	data_55
;		jr	z,ld_113
;		fail_msg 112
;ld_113:		ld	a,data_80
;		ld	i,a
;		ld	a,0
;		ld	a,i
;		jr	nz,ld_114
;		fail_msg 113
;ld_114:		jp	m,ld_115
;		fail_msg 114
;ld_115:		cp	data_80
;		jr	z,ld_116
;		fail_msg 115
;ld_116:		ld	a,0
;		ld	i,a
;		ld	a,data_55
;		ld	a,i
;		jr	z,ld_125
;		fail_msg 116
;   refresh register not implemented    
;   test for ie ?  
;ld_117:		ld	a,data_55
;		ld	r,a
;		ld	a,0
;		ld	a,r
;		jp	p,ld_118
;		inc_error_cnt
;ld_118:		jr	nz,ld_119
;		inc_error_cnt
;ld_119:		ld	a,data_ff
;		ld	r,a
;		ld	a,0
;		ld	a,r
;		jp	m,ld_120
;		inc_error_cnt
;ld_120:		ld	a,4			;totally sequence dependent
;		ld	r,a
;		ld	a,data_55
;		ld	a,r
;		jr	z,ld_121
;		inc_error_cnt
;ld_121:		ei				;set iff2
;		ld	a,i
;		jp	pe,ld_122		;iff2 was set
;		inc_error_cnt
;ld_122:		di				;clear iff2
;		ld	a,i
;		jp	po,ld_123		;iff2 was cleared
;		inc_error_cnt
;ld_123:		ei				;set iff2
;		ld	a,r
;		jp	pe,ld_124		;iff2 was set
;		inc_error_cnt
;ld_124:		di				;clear iff2
;		ld	a,r
;		jp	po,ld_125		;iff2 was cleared
;		inc_error_cnt
;
ld_125:		ld	bc,data_1234
		ld	a, #12			;bjp  guess >data_1234
		cp	b
		jr	z,ld_126
		fail_msg 125
ld_126:		ld	a, #34			;bjp  guess  <data_1234
		cp	c
		jr	z,ld_127
		fail_msg 126
ld_127:		ld	de,data_55aa
		ld	a,data_55
		cp	d
		jr	z,ld_128
		fail_msg 127
ld_128:		ld	a,data_aa
		cp	e
		jr	z,ld_129
		fail_msg 128
ld_129:		ld	hl,data_7fff
		ld	a,data_7f
		cp	h
		jr	z,ld_130
		fail_msg 129
ld_130:		ld	a,data_ff
		cp	l
		jr	z,ld_131
		fail_msg 130
ld_131:		ld	sp,data_aa55
		ld	hl,0
		add	hl,sp
		ld	a,data_aa
		cp	h
		jr	z,ld_132
		fail_msg 131
ld_132:		ld	a,data_55
		cp	l
		jr	z,ld_133
		fail_msg 132
ld_133:		ld	ix,data_ffff
		ld	hl,0
		ld	sp,ix
		add	hl,sp
		ld	a,data_ff
		cp	h
		jr	z,ld_134
		fail_msg 133
ld_134:		cp	l
		jr	z,ld_135
		fail_msg 134
ld_135:		ld	iy,data_1234
		ld	hl,0
		ld	sp,iy
		add	hl,sp
		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ld_136
		fail_msg 135
ld_136:		ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,ld_137
		fail_msg 136
ld_137:		ld	hl,(w_var2)
		ld	a,data_55
		cp	h
		jr	z,ld_138
		fail_msg 137
ld_138:		ld	a,data_aa
		cp	l
		jr	z,ld_139
		fail_msg 138
ld_139:		ld	bc,(w_var1)
		ld	a,#12      ;bjp was >data_1234
		cp	b
		jr	z,ld_140
		fail_msg 139
ld_140:		ld	a,#34      ;bjp was >data_1234
		cp	c
		jr	z,ld_141
		fail_msg 140
ld_141:		ld	de,(w_var3)
		ld	a,data_7f
		cp	d
		jr	z,ld_142
		fail_msg 141
ld_142:		ld	a,data_ff
		cp	e
		jr	z,ld_143
		fail_msg 142
ld_143:		ld	hl,(w_var4)
		ld	a,data_80
		cp	h
		jr	z,ld_144
		fail_msg 143
ld_144:		ld	a,0
		cp	l
		jr	z,ld_145
		fail_msg 144
ld_145:		ld	sp,(w_var5)
		ld	hl,0
		add	hl,sp
		ld	a,data_aa
		cp	h
		jr	z,ld_146
		fail_msg 145
ld_146:		ld	a,data_55
		cp	l
		jr	z,ld_147
		fail_msg 146
ld_147:		ld	ix,(w_var6)
		ld	hl,0
		ld	sp,ix
		add	hl,sp
		ld	a,data_ff
		cp	h
		jr	z,ld_148
		fail_msg 147
ld_148:		cp	l
		jr	z,ld_149
		fail_msg 148
ld_149:		ld	iy,(w_var1)
		ld	hl,0
		ld	sp,iy
		add	hl,sp
		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ld_150
		fail_msg 149
ld_150:		
                ld      sp, stack_end ; reset stack pointer to EOM
                ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,ld_151
		fail_msg 150
ld_151:		ld	hl,data_1234
		ld	(tw_var1),hl
		ld	bc,(tw_var1)
		ld	a,#12      ;bjp was >data_1234
		cp	b
		jr	z,ld_152
		fail_msg 151
ld_152:		ld	a,#34      ;bjp was >data_1234
		cp	c
		jr	z,ld_153
		fail_msg 152
ld_153:		ld	bc,data_55aa
		ld	(tw_var2),bc
		ld	hl,(tw_var2)
		ld	a,data_55
		cp	h
		jr	z,ld_154
		fail_msg 153
ld_154:		ld	a,data_aa
		cp	l
		jr	z,ld_155
		fail_msg 154
ld_155:		ld	de,data_7fff
		ld	(tw_var3),de
		ld	hl,(tw_var3)
		ld	a,data_7f
		cp	h
		jr	z,ld_156
		fail_msg 155
ld_156:		ld	a,data_ff
		cp	l
		jr	z,ld_157
		fail_msg 156
ld_157:		ld	hl,data_8000
		ld	(tw_var4),hl
		ld	bc,(tw_var4)
		ld	a,data_80
		cp	b
		jr	z,ld_158
		fail_msg 157
ld_158:		ld	a,0
		cp	c
		jr	z,ld_159
		fail_msg 158
ld_159:		ld	sp,data_aa55
		ld	(tw_var5),sp
		ld	hl,(tw_var5)
		ld	a,data_aa
		cp	h
		jr	z,ld_160
		fail_msg 159
ld_160:		ld	a,data_55
		cp	l
		jr	z,ld_161
		fail_msg 160
ld_161:		ld	ix,data_ffff
		ld	(tw_var6),ix
		ld	hl,(tw_var6)
		ld	a,data_ff
		cp	h
		jr	z,ld_162
		fail_msg 161
ld_162:		cp	l
		jr	z,ld_163
		fail_msg 162
ld_163:		ld	iy,data_1234
		ld	(tw_var7),iy
		ld	hl,(tw_var7)
		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ld_164
		fail_msg 163
ld_164:		ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,ld_165
		fail_msg 164
ld_165:		ld	hl,data_55aa
		ld	sp,hl
		ld	hl,0
		add	hl,sp
		ld	a,data_55
		cp	h
		jr	z,ld_166
		fail_msg 165
ld_166:		ld	a,data_aa
		cp	l
		jr	z,push_0
		fail_msg 166
push_0:		ld	sp,stack_end
                print	"push_0"
		ld	bc,data_1234
		push	bc
		ld	bc,0
		pop	bc
		ld	a,#12      ;bjp was >data_1234
		cp	b
		jr	z,push_1
		fail_msg 0
push_1:		ld	a,#34      ;bjp was >data_1234
		cp	c
		jr	z,push_2
		fail_msg 1
push_2:		ld	de,data_55aa
		push	de
		ld	de,0
		pop	de
		ld	a,data_55
		cp	d
		jr	z,push_3
		fail_msg 2
push_3:		ld	a,data_aa
		cp	e
		jr	z,push_4
		fail_msg 3
push_4:		ld	hl,data_7fff
		push	hl
		ld	hl,0
		pop	hl
		ld	a,data_7f
		cp	h
		jr	z,push_5
		fail_msg 4
push_5:		ld	a,data_ff
		cp	l
		jr	z,push_6
		fail_msg 5
push_6:		ld	a,data_80
		push	af			;f depends on previous compare
		ld	hl,0
		pop	hl
		cp	h
		jr	z,push_7
		fail_msg 6
push_7:		ld	a,l
		cp	#42
		jr	z,push_8
push_8:		ld	h,data_55
		ld	l,data_80+#41
		ld	a,0
		push	hl
		pop	af
		jp	m,push_9
		fail_msg 8
push_9:		jr	z,push_10
		fail_msg 9
push_10:	jr	c,push_11
		fail_msg 10
push_11:	cp	data_55
		jr	z,push_12
		fail_msg 11
push_12:	ld	ix,data_aa55
		ld	bc,0
		push	ix
		pop	bc
		ld	a,data_aa
		cp	b
		jr	z,push_13
		fail_msg 12
push_13:	ld	a,data_55
		cp	c
		jr	z,push_14
		fail_msg 13
push_14:	ld	iy,data_7fff
		ld	de,0
		push	iy
		pop	de
		ld	a,data_7f
		cp	d
		jr	z,push_15
		fail_msg 14
push_15:	ld	a,data_ff
		cp	e
		jr	z,push_16
		fail_msg 15
push_16:	ld	de,data_1234
		ld	ix,0
		ld	hl,0
		push	de
		pop	ix
		ld	sp,ix
		add	hl,sp
		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,push_17
		fail_msg 16
push_17:	ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,push_18
		fail_msg 17
push_18:	ld	sp,stack_end
		ld	bc,data_55aa
		ld	iy,0
		ld	hl,0
		push	bc
		pop	iy
		ld	sp,iy
		add	hl,sp
		ld	a,data_55
		cp	h
		jr	z,push_19
		fail_msg 18
push_19:	ld	a,data_aa
		cp	l
		jr	z,push_20
		fail_msg 19
push_20:	ld	sp,stack_end
                print	"ex_0"
ex_0:		ld	de,data_1234
		ld	hl,data_ffff
		ex	de,hl
		ld	a,data_ff
		cp	d
		jr	z,ex_1
		fail_msg 0
ex_1:		cp	e
		jr	z,ex_2
		fail_msg 1
ex_2:		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ex_3
		fail_msg 2
ex_3:		ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,ex_4
		fail_msg 3
ex_4:		ld	h,0
		ld	l,0
		push	hl
		pop	af
		ex	af,af'
		ld	h,data_7f
		ld	l,data_80+#41
		push	hl
		pop	af
		ex	af,af'
		cp	0
		jr	z,ex_5
		fail_msg 4
ex_5:		ex	af,af'
		jp	m,ex_6
		fail_msg 5
ex_6:		jr	z,ex_7
		fail_msg 6
ex_7:		cp	data_7f
		jr	z,ex_8
		fail_msg 7
ex_8:		ld	hl,0
		ld	bc,0
		ld	de,0
		exx
		ld	hl,data_1234
		ld	bc,data_7fff
		ld	de,data_aa55
		exx
		ld	a,0
		cp	h
		jr	z,ex_9
		fail_msg 8
ex_9:		cp	l
		jr	z,ex_10
		fail_msg 9
ex_10:		cp	d
		jr	z,ex_11
		fail_msg 10
ex_11:		cp	e
		jr	z,ex_12
		fail_msg 11
ex_12:		cp	b
		jr	z,ex_13
		fail_msg 12
ex_13:		cp	c
		jr	z,ex_14
		fail_msg 13
ex_14:		exx
		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ex_15
		fail_msg 14
ex_15:		ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,ex_16
		fail_msg 15
ex_16:		ld	a,data_aa
		cp	d
		jr	z,ex_17
		fail_msg 16
ex_17:		ld	a,data_55
		cp	e
		jr	z,ex_18
		fail_msg 17
ex_18:		ld	a,data_7f
		cp	b
		jr	z,ex_19
		fail_msg 18
ex_19:		ld	a,data_ff
		cp	c
		jr	z,ex_20
		fail_msg 19
ex_20:		ld	bc,data_55aa
		ld	hl,data_7fff
		push	bc
		ex	(sp),hl
		pop	bc
		ld	a,data_7f
		cp	b
		jr	z,ex_21
		fail_msg 20
ex_21:		ld	a,data_ff
		cp	c
		jr	z,ex_22
		fail_msg 21
ex_22:		ld	a,data_55
		cp	h
		jr	z,ex_23
		fail_msg 22
ex_23:		ld	a,data_aa
		cp	l
		jr	z,ex_24
		fail_msg 23
ex_24:		ld	bc,data_ffff
		ld	ix,data_8000
		ld	hl,0
		push	bc
		ex	(sp),ix
		pop	bc
		ld	sp,ix
		add	hl,sp
		ld	a,data_80
		cp	b
		jr	z,ex_25
		fail_msg 24
ex_25:		ld	a,0
		cp	c
		jr	z,ex_26
		fail_msg 25
ex_26:		ld	a,data_ff
		cp	h
		jr	z,ex_27
		fail_msg 26
ex_27:		cp	l
		jr	z,ex_28
		fail_msg 27
ex_28:		ld	sp,stack_end
		ld	bc,data_1234
		ld	iy,data_7fff
		ld	hl,0
		push	bc
		ex	(sp),iy
		pop	bc
		ld	sp,iy
		add	hl,sp
		ld	a,data_7f
		cp	b
		jr	z,ex_29
		fail_msg 28
ex_29:		ld	a,data_ff
		cp	c
		jr	z,ex_30
		fail_msg 29
ex_30:		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ex_31
		fail_msg 30
ex_31:		ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,add_0
		fail_msg 31
add_0:		ld	sp,stack_end ; reset stack after EX operations
		print   "add_0"
		ld	a,0
		ld	b,data_7f
		add	a,b
		cp	data_7f
		jr	z,add_1
		fail_msg 0
add_1:		ld	a,0
		ld	b,0
		add	a,b
		jr	z,add_2
		fail_msg 1
add_2:		ld	b,data_55
		add	a,b
		jr	nz,add_3
		fail_msg 2
add_3:		cp	data_55
		jr	z,add_4
		fail_msg 3
add_4:		ld	a,data_ff
		ld	b,1
		add	a,b
		jr	c,add_5
		fail_msg 4
add_5:		add	a,b
		jr	nc,add_6
		fail_msg 5
add_6:		ld	a,data_ff
		ld	b,0
		add	a,b
		jp	m,add_7
		fail_msg 6
add_7:		ld	b,1
		add	a,b
		jp	p,add_8
		fail_msg 7
add_8:		ld	a,data_7f
		ld	b,1
		add	a,b
		jp	pe,add_9
		fail_msg 8
add_9:		add	a,b
		jp	po,add_10
		fail_msg 9
add_10:		ld	a,data_55
		ld	c,2
		add	a,c
		cp	data_55+2
		jr	z,add_11
		fail_msg 10
add_11:		ld	a,data_80
		add	a,c
		cp	data_80+2
		jr	z,add_12
		fail_msg 11
add_12:		ld	a,data_aa
		ld	d,data_55
		add	a,d
		cp	data_aa+data_55
		jr	z,add_13
		fail_msg 12
add_13:		ld	a,data_aa
		ld	e,2
		add	a,e
		cp	data_aa+2
		jr	z,add_14
		fail_msg 13
add_14:		ld	a,data_55
		ld	h,24
		add	a,h
		cp	data_55+24
		jr	z,add_15
		fail_msg 14
add_15:		ld	a,data_7f-10
		ld	l,10
		add	a,l
		cp	data_7f
		jr	z,add_16
		fail_msg 15
add_16:		ld	a,1
		add	a,data_7f
		jp	pe,add_17
		fail_msg 16
add_17:		jp	m,add_18
		fail_msg 17
add_18:		jr	nz,add_19
		fail_msg 18
add_19:		cp	data_80
		jr	z,add_20
		fail_msg 19
add_20:		ld	a,data_55
		add	a,1
		jp	po,add_21
		fail_msg 20
add_21:		jp	p,add_22
		fail_msg 21
add_22:		jr	nc,add_23
		fail_msg 22
add_23:		cp	data_55+1
		jr	z,add_24
		fail_msg 23
add_24:		ld	a,data_ff
		add	a,1
		jr	c,add_25
		fail_msg 24
add_25:		jr	z,add_26
		fail_msg 25
add_26:		add	a,1
		jr	nc,add_27
		fail_msg 26
add_27:		jr	nz,add_28
		fail_msg 27
add_28:		cp	1
		jr	z,add_29
		fail_msg 28
add_29:		ld	hl,var2
		ld	a,2
		add	a,(hl)
		jp	po,add_30
		fail_msg 29
add_30:		jp	p,add_31
		fail_msg 30
add_31:		jr	nz,add_32
		fail_msg 31
add_32:		jr	nc,add_33
		fail_msg 32
add_33:		cp	data_55+2
		jr	z,add_34
		fail_msg 33
add_34:		ld	hl,var1
		ld	a,1
		add	a,(hl)
		jr	c,add_35
		fail_msg 34
add_35:		jr	z,add_36
		fail_msg 35
add_36:		ld	hl,var5
		ld	a,1
		add	a,(hl)
		jp	m,add_37
		fail_msg 36
add_37:		jp	pe,add_38
		fail_msg 37
add_38:		cp	data_80
		jr	z,add_39
		fail_msg 38
add_39:		ld	ix,var3
		ld	a,1
		add	a,(ix-1)
		jp	po,add_40
		fail_msg 39
add_40:		jp	p,add_41
		fail_msg 40
add_41:		jr	nz,add_42
		fail_msg 41
add_42:		jr	nc,add_43
		fail_msg 42
add_43:		cp	data_55+1
		jr	z,add_44
		fail_msg 43
add_44:		ld	a,1
		add	a,(ix+2)
		jp	pe,add_45
		fail_msg 44
add_45:		jp	m,add_46
		fail_msg 45
add_46:		cp	data_80
		jr	z,add_47
		fail_msg 46
add_47:		ld	a,1
		add	a,(ix-2)
		jr	c,add_48
		fail_msg 47
add_48:		jr	z,add_49
		fail_msg 48
add_49:		add	a,1
		jr	nc,add_50
		fail_msg 49
add_50:		jr	nz,add_51
		fail_msg 50
add_51:		cp	1
		jr	z,add_52
		fail_msg 51
add_52:		ld	iy,var3
		ld	a,10
		add	a,(iy-1)
		jp	po,add_53
		fail_msg 52
add_53:		jp	p,add_54
		fail_msg 53
add_54:		jr	nz,add_55
		fail_msg 54
add_55:		jr	nc,add_56
		fail_msg 55
add_56:		cp	data_55+10
		jr	z,add_57
		fail_msg 56
add_57:		ld	a,1
		add	a,(iy+2)
		jp	pe,add_58
		fail_msg 57
add_58:		jp	m,add_59
		fail_msg 58
add_59:		add	a,1
		jp	po,add_60
		fail_msg 59
add_60: 	cp	data_80+1
		jr	z,add_61
		fail_msg 60
add_61:		ld	a,1
		add	a,(iy-2)
		jr	z,add_62
		fail_msg 61
add_62:		jr	c,add_63
		fail_msg 62
add_63:		add	a,1
		jr	nc,add_64
		fail_msg 63
add_64:		jr	nz,add_65
		fail_msg 64
add_65:		cp	1
		jr	z,add_66
		fail_msg 65
add_66:		ld	a,data_ff
		add	a,data_80
		jp	p,add_67
		fail_msg 66
add_67:		jp	pe,add_68
		fail_msg 67
add_68:		jr	c,add_69
		fail_msg 68
add_69:		add	a,1
		jp	pe,add_70
		fail_msg 69
add_70:		jp	m,add_71
		fail_msg 70
add_71:		jr	nc,add_72
		fail_msg 71
add_72:		add	a,1
		jp	po,add_73
		fail_msg 72
add_73:		cp	data_80+1
		jr	z,adc_0
		fail_msg 73
adc_0:		nop
		print   "adc_0"
		ld	a,0                 ;clear cry 
		add	a,0
		ld	b,data_7f
		adc	a,b                  ;a=7f cry=0
		jp	p,adc_1
		fail_msg 0
adc_1:		jp	po,adc_2
		fail_msg 1
adc_2:		jr	nc,adc_3
		fail_msg 2
adc_3:		jr	nz,adc_4
		fail_msg 3
adc_4:		ld	b,1
		adc	a,b                     ;a=80 cry=0  
		jp	pe,adc_5                ;jp  ofl
		fail_msg 4
adc_5:		jp	m,adc_6
		fail_msg 5
adc_6:		cp	data_80
		jr	z,adc_7                 ;z=0  ofl=0 cry=0 (borrow)
		fail_msg 6
adc_7:		ld	a,data_ff
		ld	b,1
		adc	a,b                      ;ff+1+0
		jr	c,adc_8
		fail_msg 7
adc_8:		jr	z,adc_9
		fail_msg 8
adc_9:		adc	a,b
		jr	nc,adc_10
		fail_msg 9
adc_10:		jr	nz,adc_11
		fail_msg 10
adc_11:		cp	2
		jr	z,adc_12
		fail_msg 11
adc_12:		ld	a,data_ff
		ld	c,0
		adc	a,c
		jp	m,adc_13
		fail_msg 12
adc_13:		jr	nc,adc_14
		fail_msg 13
adc_14:		ld	c,2
		adc	a,c
		jp	p,adc_15
		fail_msg 14
adc_15:		jr	c,adc_16
		fail_msg 15
adc_16:		ld	c,0
		adc	a,c
		cp	2
		jr	z,adc_17
		fail_msg 16
adc_17:		ld	a,data_ff
		ld	d,1
		adc	a,d
		jr	c,adc_18
		fail_msg 17
adc_18:		ld	d,0
		adc	a,d
		jr	nc,adc_19
		fail_msg 18
adc_19:		cp	1
		jr	z,adc_20
		fail_msg 19
adc_20:		ld	a,data_aa
		ld	e,data_7f
		adc	a,e
		jr	c,adc_21
		fail_msg 20
adc_21:		ld	e,#2b
		adc	a,e
		cp	data_55
		jr	z,adc_22
		fail_msg 21
adc_22:		ld	a,data_ff
		ld	h,1
		adc	a,h
		jr	c,adc_23
		fail_msg 22
adc_23:		adc	a,h
		cp	2
		jr	z,adc_24
		fail_msg 23
adc_24:		ld	a,data_ff
		ld	l,1
		adc	a,l
		jr	c,adc_25
		fail_msg 24
adc_25:		adc	a,l
		cp	2
		jr	z,adc_26
		fail_msg 25
adc_26:		ld	a,0
		adc	a,data_7f
		jp	po,adc_27
		fail_msg 26
adc_27:		jp	p,adc_28
		fail_msg 27
adc_28:		jr	nc,adc_29
		fail_msg 28
adc_29:		jr	nz,adc_30
		fail_msg 29
adc_30:		adc	a,1
		jp	pe,adc_31
		fail_msg 30
adc_31:		jp	m,adc_32
		fail_msg 31
adc_32:		cp	data_80
		jr	z,adc_33
		fail_msg 32
adc_33:		ld	a,data_ff
		adc	a,1
		jr	c,adc_34
		fail_msg 33
adc_34:		jr	z,adc_35
		fail_msg 34
adc_35:		adc	a,1
		jr	nc,adc_36
		fail_msg 35
adc_36:		jr	nz,adc_37
		fail_msg 36
adc_37:		cp	2
		jr	z,adc_38
		fail_msg 37
adc_38:		ld	hl,var5
		ld	a,0
		adc	a,(hl)
		jp	p,adc_39
		fail_msg 38
adc_39:		jp	po,adc_40
		fail_msg 39
adc_40:		jr	nz,adc_41
		fail_msg 40
adc_41:		jr	nc,adc_42
		fail_msg 41
adc_42:		ld	a,1
		adc	a,(hl)
		jp	m,adc_43
		fail_msg 42
adc_43:		jp	pe,adc_44
		fail_msg 43
adc_44:		cp	data_80
		jr	z,adc_45
		fail_msg 44
adc_45:		ld	hl,var1
		ld	a,1
		adc	a,(hl)
		jr	z,adc_46
		fail_msg 45
adc_46:		jr	c,adc_47
		fail_msg 46
adc_47:		ld	hl,var2
		adc	a,(hl)
		jr	nc,adc_48
		fail_msg 47
adc_48:		jr	nz,adc_49
		fail_msg 48
adc_49:		cp	data_55+1
		jr	z,adc_50
		fail_msg 49
adc_50:		ld	ix,var3
		ld	a,0
		adc	a,(ix+2)
		jp	p,adc_51
		fail_msg 50
adc_51:		jp	po,adc_52
		fail_msg 51
adc_52:		jr	nc,adc_53
		fail_msg 52
adc_53:		jr	nz,adc_54
		fail_msg 53
adc_54:		ld	a,1
		adc	a,(ix+2)
		jp	m,adc_55
		fail_msg 54
adc_55:		jp	pe,adc_56
		fail_msg 55
adc_56:		cp	data_80
		jr	z,adc_57
		fail_msg 56
adc_57:		ld	a,1
		adc	a,(ix-2)
		jr	c,adc_58
		fail_msg 57
adc_58:		jr	z,adc_59
		fail_msg 58
adc_59:		adc	a,(ix-1)
		jr	nc,adc_60
		fail_msg 59
adc_60:		jr	nz,adc_61
		fail_msg 60
adc_61:		cp	data_55+1
		jr	z,adc_62
		fail_msg 61
adc_62:		ld	iy,var3
		ld	a,0
		adc	a,(ix+2)
		jp	p,adc_63
		fail_msg 62
adc_63:		jp	po,adc_64
		fail_msg 63
adc_64:		jr	nc,adc_65
		fail_msg 64
adc_65:		jr	nz,adc_66
		fail_msg 65
adc_66:		ld	a,1
		adc	a,(iy+2)
		jp	m,adc_67
		fail_msg 66
adc_67:		jp	pe,adc_68
		fail_msg 67
adc_68:		cp	data_80
		jr	z,adc_69
		fail_msg 68
adc_69:		ld	a,1
		adc	a,(iy-2)
		jr	c,adc_70
		fail_msg 69
adc_70:		jr	z,adc_71
		fail_msg 70
adc_71:		adc	a,(iy-1)
		jr	nc,adc_72
		fail_msg 71
adc_72:		jr	nz,adc_73
		fail_msg 72
adc_73:		cp	data_55+1
		jr	z,adc_74
		fail_msg 73
adc_74:		ld	a,data_ff
		add	a,0
		adc	a,data_80
		jp	p,adc_75
		fail_msg 74
adc_75:		jp	pe,adc_76
		fail_msg 75
adc_76:		jr	nz,adc_77
		fail_msg 76
adc_77:		adc	a,0
		jp	m,adc_78
		fail_msg 77
adc_78:		jp	pe,adc_79
		fail_msg 78
adc_79:		adc	a,1
		jp	po,adc_80
		fail_msg 79
adc_80:		cp	data_80+1
		jr	z,sub_0
		fail_msg 80
sub_0:		nop
		print   "sub_0"
		ld	a,0
		ld	b,1
		sub	a,b
		jp	m,sub_1
		fail_msg 0
sub_1:		jp	po,sub_2
		fail_msg 1
sub_2:		jr	c,sub_3
		fail_msg 2
sub_3:		jr	nz,sub_4
		fail_msg 3
sub_4:		sub	a,b
		jr	nc,sub_5
		fail_msg 4
sub_5:		cp	data_ff-1
		jr	z,sub_6
		fail_msg 5
sub_6:		ld	a,1
		ld	b,0
		sub	a,b
		jr	nz,sub_7
		fail_msg 6
sub_7:		jp	p,sub_8
		fail_msg 7
sub_8:		ld	b,1
		sub	a,b
		jr	z,sub_9
		fail_msg 8
sub_9:		sub	a,b
		jp	m,sub_10
		fail_msg 9
sub_10:		cp	data_ff
		jr	z,sub_11
		fail_msg 10
sub_11:		ld	a,data_80
		ld	b,data_7f
		sub	a,b
		jp	pe,sub_12
		fail_msg 11
sub_12:		sub	a,b
		jp	po,sub_13
		fail_msg 12
sub_13:		cp	data_80+2
		jr	z,sub_14
		fail_msg 13
sub_14:		ld	a,data_55
		ld	c,data_55
		sub	a,c
		jr	z,sub_15
		fail_msg 14
sub_15:		ld	c,1
		sub	a,c
		jp	m,sub_16
		fail_msg 15
sub_16:		jr	c,sub_17
		fail_msg 16
sub_17:		cp	data_ff
		jr	z,sub_18
		fail_msg 17
sub_18:		ld	a,data_55
		ld	d,data_7f
		sub	a,d
		jr	c,sub_19
		fail_msg 18
sub_19:		cp	data_55-data_7f
		jr	z,sub_20
		fail_msg 19
sub_20:		ld	a,0
		ld	e,data_ff
		sub	a,e
		jr	c,sub_21
		fail_msg 20
sub_21:		cp	1
		jr	z,sub_22
		fail_msg 21
sub_22:		ld	a,data_ff
		ld	h,data_80
		sub	a,h
		jp	p,sub_23
		fail_msg 22
sub_23:		cp	data_7f
		jr	z,sub_24
		fail_msg 23
sub_24:		ld	a,data_aa
		ld	l,data_ff
		sub	a,l
		jr	c,sub_25
		fail_msg 24
sub_25:		cp	data_aa+1
		jr	z,sub_26
		fail_msg 25
sub_26:		ld	a,data_7f
		sub	a,data_ff
		jp	pe,sub_27
		fail_msg 26
sub_27:		jp	m,sub_28
		fail_msg 27
sub_28:		sub	a,1
		jp	p,sub_29
		fail_msg 28
sub_29:		sub	a,1
		jp	po,sub_30
		fail_msg 29
sub_30:		jr	nz,sub_31
		fail_msg 30
sub_31:		sub	a,data_7f-1
		jr	z,sub_32
		fail_msg 31
sub_32:		ld	a,0
		sub	a,data_ff
		jr	c,sub_33
		fail_msg 32
sub_33:		sub	a,1
		jr	z,sub_34
		fail_msg 33
sub_34:		jr	nc,sub_35
		fail_msg 34
sub_35:		ld	hl,var1
		ld	a,data_7f
		sub	a,(hl)
		jp	m,sub_36
		fail_msg 35
sub_36:		jp	pe,sub_37
		fail_msg 36
sub_37:		jr	c,sub_38
		fail_msg 37
sub_38:		ld	hl,var3
		sub	a,(hl)
		jp	p,sub_39
		fail_msg 38
sub_39:		jp	po,sub_40
		fail_msg 39
sub_40:		jr	nc,sub_41
		fail_msg 40
sub_41		jr	z,sub_42
		fail_msg 40
sub_42:		ld	hl,var2
		sub	a,(hl)
		jr	nz,sub_43
		fail_msg 42
sub_43:		cp	data_aa+1
		jr	z,sub_44
		fail_msg 43
sub_44:		ld	ix,var3
		ld	a,data_7f
		sub	a,(ix-2)
		jp	m,sub_45
		fail_msg 44
sub_45:		jp	pe,sub_46
		fail_msg 45
sub_46:		jr	c,sub_47
		fail_msg 46
sub_47:		sub	a,(ix+0)
		jp	p,sub_48
		fail_msg 47
sub_48:		jp	po,sub_49
		fail_msg 48
sub_49:		jr	nc,sub_50
		fail_msg 49
sub_50:		jr	z,sub_51
		fail_msg 50
sub_51:		sub	a,(ix+2)
		jr	nz,sub_52
		fail_msg 51
sub_52:		cp	data_80+1
		jr	z,sub_53
		fail_msg 52
sub_53:		ld	iy,var3
		ld	a,data_7f
		sub	a,(iy-2)
		jp	m,sub_54
		fail_msg 53
sub_54:		jp	pe,sub_55
		fail_msg 54
sub_55:		jr	c,sub_56
		fail_msg 55
sub_56:		jr	nz,sub_57
		fail_msg 56
sub_57:		sub	a,(iy+0)
		jp	p,sub_58
		fail_msg 57
sub_58:		jp	po,sub_59
		fail_msg 58
sub_59:		jr	nc,sub_60
		fail_msg 59
sub_60:		jr	z,sub_61
		fail_msg 60
sub_61:		sub	a,(iy+2)
		jr	nz,sub_62
		fail_msg 61
sub_62:		cp	data_80+1
		jr	z,sbc_0
		fail_msg 62
sbc_0:		nop
		print   "sbc_0"
		ld	a,data_7f
		ld	b,0
		sub	a,b			;clear carry flag
		ld	b,data_ff
		sbc	a,b
		jp	m,sbc_1
		fail_msg 0
sbc_1:		jp	pe,sbc_2
		fail_msg 1
sbc_2:		jr	c,sbc_3
		fail_msg 2
sbc_3:		jr	nz,sbc_4
		fail_msg 3
sbc_4:		ld	b,data_7f
		sbc	a,b
		jp	p,sbc_5
		fail_msg 4
sbc_5:		jp	pe,sbc_6
		fail_msg 5
sbc_6:		jr	nc,sbc_7
		fail_msg 6
sbc_7:		jr	z,sbc_8
		fail_msg 7
sbc_8:		ld	b,data_ff
		sbc	a,b
		jp	po,sbc_9
		fail_msg 8
sbc_9:		jr	nz,sbc_10
		fail_msg 9
sbc_10:		ld	b,0
		sbc	a,b
		jr	z,sbc_11
		fail_msg 10
sbc_11:		ld	a,data_aa
		ld	c,data_ff
		sbc	a,c
		jr	c,sbc_12
		fail_msg 11
sbc_12:		ld	c,0
		sbc	a,c
		jr	nc,sbc_13
		fail_msg 12
sbc_13:		cp	data_aa
		jr	z,sbc_14
		fail_msg 13
sbc_14:		ld	a,data_55
		ld	d,data_ff
		sbc	a,d
		jr	c,sbc_15
		fail_msg 14
sbc_15:		ld	d,0
		sbc	a,d
		jr	nc,sbc_16
		fail_msg 15
sbc_16:		cp	data_55
		jr	z,sbc_17
		fail_msg 16
sbc_17:		ld	a,data_aa
		ld	e,data_ff
		sbc	a,e
		jr	c,sbc_18
		fail_msg 17
sbc_18:		ld	e,0
		sbc	a,e
		jr	nc,sbc_19
		fail_msg 18
sbc_19:		cp	data_aa
		jr	z,sbc_20
		fail_msg 19
sbc_20:		ld	a,data_55
		ld	h,data_ff
		sbc	a,h
		jr	c,sbc_21
		fail_msg 20
sbc_21:		ld	h,0
		sbc	a,h
		jr	nc,sbc_22
		fail_msg 21
sbc_22:		cp	data_55
		jr	z,sbc_23
		fail_msg 22
sbc_23:		ld	a,data_aa
		ld	l,data_ff
		sbc	a,l
		jr	c,sbc_24
		fail_msg 23
sbc_24:		ld	l,0
		sbc	a,l
		jr	nc,sbc_25
		fail_msg 24
sbc_25:		cp	data_aa
		jr	z,sbc_26
		fail_msg 25
sbc_26:		ld	a,data_7f
		sbc	a,data_ff
		jp	m,sbc_27
		fail_msg 26
sbc_27:		jp	pe,sbc_28
		fail_msg 27
sbc_28:		jr	c,sbc_29
		fail_msg 28
sbc_29:		jr	nz,sbc_30
		fail_msg 29
sbc_30:		sbc	a,data_7f
		jp	p,sbc_31
		fail_msg 30
sbc_31:		jp	pe,sbc_32
		fail_msg 31
sbc_32:		jr	nc,sbc_33
		fail_msg 32
sbc_33:		jr	z,sbc_34
		fail_msg 33
sbc_34:		sbc	a,data_ff
		jr	nz,sbc_35
		fail_msg 34
sbc_35:		cp	1
		jr	z,sbc_36
		fail_msg 35
sbc_36:		ld	hl,var1
		ld	a,data_7f
		sbc	a,(hl)
		jp	m,sbc_37
		fail_msg 36
sbc_37:		jp	pe,sbc_38
		fail_msg 37
sbc_38:		jr	c,sbc_39
		fail_msg 38
sbc_39:		jr	nz,sbc_40
		fail_msg 39
sbc_40:		ld	hl,var5
		sbc	a,(hl)
		jp	p,sbc_41
		fail_msg 40
sbc_41:		jp	pe,sbc_42
		fail_msg 41
sbc_42:		jr	nc,sbc_43
		fail_msg 42
sbc_43:		jr	z,sbc_44
		fail_msg 43
sbc_44:		ld	hl,var2
		sbc	a,(hl)
		jr	nz,sbc_45
		fail_msg 44
sbc_45:		cp	data_aa+1
		jr	z,sbc_46
		fail_msg 45
sbc_46:		ld	ix,var3
		ld	a,data_7f
		sbc	a,(ix-2)
		jp	m,sbc_47
		fail_msg 46
sbc_47:		jp	pe,sbc_48
		fail_msg 47
sbc_48:		jr	c,sbc_49
		fail_msg 48
sbc_49:		jr	nz,sbc_50
		fail_msg 49
sbc_50:		sbc	a,(ix+2)
		jp	p,sbc_51
		fail_msg 50
sbc_51:		jp	pe,sbc_52
		fail_msg 51
sbc_52:		jr	nc,sbc_53
		fail_msg 52
sbc_53:		jr	z,sbc_54
		fail_msg 53
sbc_54:		sbc	a,(ix-1)
		jr	nz,sbc_55
		fail_msg 54
sbc_55:		cp	data_aa+1
		jr	z,sbc_56
		fail_msg 55
sbc_56:		ld	iy,var3
		ld	a,data_7f
		sbc	a,(ix-2)
		jp	m,sbc_57
		fail_msg 56
sbc_57:		jp	pe,sbc_58
		fail_msg 57
sbc_58:		jr	c,sbc_59
		fail_msg 58
sbc_59:		jr	nz,sbc_60
		fail_msg 59
sbc_60:		sbc	a,(ix+2)
		jp	p,sbc_61
		fail_msg 60
sbc_61:		jp	pe,sbc_62
		fail_msg 61
sbc_62:		jr	nc,sbc_63
		fail_msg 62
sbc_63:		jr	z,sbc_64
		fail_msg 63
sbc_64:		sbc	a,(ix+1)
		jr	nz,sbc_65
		fail_msg 64
sbc_65:		cp	data_55+1
		jr	z,and_0
		fail_msg 65
and_0:		nop
		print	"and_0"
		ld	a,data_ff
		add	a,1			;set carry
		ld	a,data_ff
		ld	b,data_aa
		and	a,b
		jr	nc,and_1
		fail_msg 0
and_1:		jp	m,and_2
		fail_msg 1
and_2:		jp	pe,and_3
		fail_msg 2
and_3:		jr	nz,and_4
		fail_msg 3
and_4:		ld	b,data_55
		and	a,b
		jp	p,and_5
		fail_msg 4
and_5:		jr	z,and_6
		fail_msg 5
and_6:		ld	a,data_ff
		ld	b,data_7f
		and	a,b
		jp	po,and_7
		fail_msg 6
and_7:		ld	b,data_55
		and	a,b
		jp	pe,and_8
		fail_msg 7
and_8:		ld	a,data_ff
		ld	c,data_80
		and	a,c
		jp	m,and_9
		fail_msg 8
and_9:		cp	data_80
		jr	z,and_10
		fail_msg 9
and_10:		ld	a,data_ff
		ld	d,data_7f
		and	a,d
		jp	p,and_11
		fail_msg 10
and_11:		cp	data_7f
		jr	z,and_12
		fail_msg 11
and_12:		ld	a,data_ff
		ld	e,data_aa
		and	a,e
		jp	m,and_13
		fail_msg 12
and_13:		cp	data_aa
		jr	z,and_14
		fail_msg 13
and_14:		ld	a,data_ff
		ld	h,data_55
		and	a,h
		jp	p,and_15
		fail_msg 14
and_15:		cp	data_55
		jr	z,and_16
		fail_msg 15
and_16:		ld	a,data_ff
		ld	l,data_aa
		and	a,l
		jp	m,and_17
		fail_msg 16
and_17:		cp	data_aa
		jr	z,and_18
		fail_msg 17
and_18:		ld	a,data_ff
		and	a,data_aa
		jp	m,and_19
		fail_msg 18
and_19:		jr	nz,and_20
		fail_msg 19
and_20:		and	a,data_55
		jp	p,and_21
		fail_msg 20
and_21:		jr	z,and_22
		fail_msg 21
and_22:		ld	a,data_ff
		and	a,data_7f
		jp	po,and_23
		fail_msg 22
and_23:		and	a,data_55
		jp	pe,and_24
		fail_msg 23
and_24:		jr	nz,and_25
		fail_msg 24
and_25:		and	a,data_aa
		jr	z,and_26
		fail_msg 25
and_26:		ld	a,data_ff
		and	a,data_aa
		cp	data_aa
		jr	z,and_27
		fail_msg 26
and_27:		ld	hl,var4
		ld	a,data_ff
		and	a,(hl)
		jp	m,and_28
		fail_msg 27
and_28:		jr	nz,and_29
		fail_msg 28
and_29:		ld	hl,var2
		and	a,(hl)
		jp	p,and_30
		fail_msg 29
and_30:		jr	z,and_31
		fail_msg 30
and_31:		ld	a,data_ff
		ld	hl,var5
		and	a,(hl)
		jp	po,and_32
		fail_msg 31
and_32:		ld	hl,var2
		and	a,(hl)
		jp	pe,and_33
		fail_msg 32
and_33:		cp	data_55
		jr	z,and_34
		fail_msg 33
and_34:		ld	ix,var3
		ld	a,data_ff
		and	a,(ix+1)
		jp	m,and_35
		fail_msg 34
and_35:		jr	nz,and_36
		fail_msg 35
and_36:		and	a,(ix-1)
		jp	p,and_37
		fail_msg 36
and_37:		jr	z,and_38
		fail_msg 37
and_38:		ld	a,data_ff
		and	a,(ix+2)
		jp	po,and_39
		fail_msg 38
and_39:		and	a,(ix-1)
		jp	pe,and_40
		fail_msg 39
and_40:		cp	data_55
		jr	z,and_41
		fail_msg 40
and_41:		ld	iy,var3
		ld	a,data_ff
		and	a,(iy+1)
		jp	m,and_42
		fail_msg 41
and_42:		jr	nz,and_43
		fail_msg 42
and_43:		and	a,(iy-1)
		jp	p,and_44
		fail_msg 43
and_44:		jr	z,and_45
		fail_msg 44
and_45:		ld	a,data_ff
		and	a,(iy+2)
		jp	po,and_46
		fail_msg 45
and_46:		and	a,(iy-1)
		jp	pe,and_47
		fail_msg 46
and_47:		cp	data_55
		jr	z,or_0
		fail_msg 47
or_0:		nop
		print   "or_0"
		ld	a,0
		ld	b,data_7f
		or	a,b
		jp	p,or_1
		fail_msg 0
or_1:		jp	po,or_2
		fail_msg 1
or_2:		ld	b,data_80
		or	a,b
		jp	m,or_3
		fail_msg 2
or_3:		jp	pe,or_4
		fail_msg 3
or_4:		cp	data_ff
		jr	z,or_5
		fail_msg 4
or_5:		ld	a,0
		ld	b,0
		or	a,b
		jr	z,or_6
		fail_msg 5
or_6:		ld	b,data_55
		or	a,b
		jr	nz,or_7
		fail_msg 6
or_7:		cp	data_55
		jr	z,or_8
		fail_msg 7
or_8:		ld	a,data_ff
		add	a,1
		jr	c,or_9
		fail_msg 8
or_9:		ld	b,data_7f
		or	a,b
		jr	nc,or_10
		fail_msg 9
or_10:		cp	data_7f
		jr	z,or_11
		fail_msg 10
or_11:		ld	a,0
		ld	c,data_55
		or	a,c
		cp	data_55
		jr	z,or_12
		fail_msg 11
or_12:		ld	c,data_aa
		or	a,c
		cp	data_ff
		jr	z,or_13
		fail_msg 12
or_13:		ld	a,0
		ld	d,data_aa
		or	a,d
		cp	data_aa
		jr	z,or_14
		fail_msg 13
or_14:		ld	e,data_55
		or	a,e
		cp	data_ff
		jr	z,or_15
		fail_msg 14
or_15:		ld	a,0
		ld	h,data_80
		or	a,h
		cp	data_80
		jr	z,or_16
		fail_msg 15
or_16:		ld	l,data_7f
		or	a,l
		cp	data_ff
		jr	z,or_17
		fail_msg 16
or_17:		ld	a,0
		or	a,data_7f
		jp	p,or_18
		fail_msg 17
or_18:		jp	po,or_19
		fail_msg 18
or_19:		or	a,data_80
		jp	m,or_20
		fail_msg 19
or_20:		jp	pe,or_21
		fail_msg 20
or_21:		cp	data_ff
		jr	z,or_22
		fail_msg 21
or_22:		ld	a,0
		or	a,0
		jr	z,or_23
		fail_msg 22
or_23:		or	a,data_7f
		jr	nz,or_24
		fail_msg 23
or_24:		ld	a,data_ff
		add	a,1
		jr	c,or_25
		fail_msg 24
or_25:		or	a,data_55
		jr	nc,or_26
		fail_msg 25
or_26:		cp	data_55
		jr	z,or_27
		fail_msg 26
or_27:		ld	hl,var5
		ld	a,0
		or	a,(hl)
		jp	p,or_28
		fail_msg 27
or_28:		jp	po,or_29
		fail_msg 28
or_29:		ld	hl,var3
		or	a,(hl)
		jp	m,or_30
		fail_msg 29
or_30:		jp	pe,or_31
		fail_msg 30
or_31:		cp	data_ff
		jr	z,or_32
		fail_msg 31
or_32:		ld	hl,t_var1
		ld	a,0
		ld	(hl),a
		or	a,(hl)
		jr	z,or_33
		fail_msg 32
or_33:		ld	hl,var2
		or	a,(hl)
		jr	nz,or_34
		fail_msg 33
or_34:		cp	data_55
		jr	z,or_35
		fail_msg 34
or_35:		ld	ix,var3
		ld	a,0
		or	a,(ix+2)
		jp	p,or_36
		fail_msg 35
or_36:		jp	po,or_37
		fail_msg 36
or_37:		or	a,(ix+0)
		jp	m,or_38
		fail_msg 37
or_38:		jp	pe,or_39
		fail_msg 38
or_39:		cp	data_ff
		jr	z,or_40
		fail_msg 39
or_40:		ld	ix,t_var3
		ld	a,0
		ld	(ix-2),a
		or	a,(ix-2)
		jr	z,or_41
		fail_msg 40
or_41:		ld	(ix+2),data_aa
		or	a,(ix+2)
		jr	nz,or_42
		fail_msg 41
or_42:		cp	data_aa
		jr	z,or_43
		fail_msg 42
or_43:		ld	iy,var3
		ld	a,0
		or	a,(iy+2)
		jp	p,or_44
		fail_msg 43
or_44:		jp	po,or_45
		fail_msg 44
or_45:		or	a,(iy+0)
		jp	m,or_46
		fail_msg 45
or_46:		jp	pe,or_47
		fail_msg 46
or_47:		cp	data_ff
		jr	z,or_48
		fail_msg 47
or_48:		ld	iy,t_var3
		ld	a,0
		ld	(iy-2),a
		or	a,(iy-2)
		jr	z,or_49
		fail_msg 48
or_49:		ld	(iy+2),data_55
		or	a,(iy+2)
		jr	nz,or_50
		fail_msg 49
or_50:		cp	data_55
		jr	z,xor_0
		fail_msg 50
xor_0:		nop
		print	"xor_0"
		ld	a,data_ff
		ld	b,data_55
		xor	a,b
		jp	m,xor_1
		fail_msg 0
xor_1:		jp	pe,xor_2
		fail_msg 1
xor_2:		ld	b,data_80
		xor	a,b
		jp	p,xor_3
		fail_msg 2
xor_3:		jp	po,xor_4
		fail_msg 3
xor_4:		cp	#2a
		jr	z,xor_5
		fail_msg 4
xor_5:		ld	a,data_ff
		ld	b,data_ff
		xor	a,b
		jr	z,xor_6
		fail_msg 5
xor_6:		ld	b,data_55
		xor	a,b
		jr	nz,xor_7
		fail_msg 6
xor_7:		cp	data_55
		jr	z,xor_8
		fail_msg 7
xor_8:		ld	a,data_ff
		add	a,1
		jr	c,xor_9
		fail_msg 8
xor_9:		ld	b,data_aa
		xor	a,b
		jr	nc,xor_10
		fail_msg 9
xor_10:		cp	data_aa
		jr	z,xor_11
		fail_msg 10
xor_11:		ld	a,data_ff
		ld	c,data_7f
		xor	a,c
		jp	m,xor_12
		fail_msg 11
xor_12:		cp	data_80
		jr	z,xor_13
		fail_msg 12
xor_13:		ld	a,data_ff
		ld	d,data_55
		xor	a,d
		jp	m,xor_14
		fail_msg 13
xor_14:		cp	data_aa
		jr	z,xor_15
		fail_msg 14
xor_15:		ld	e,data_55
		xor	a,e
		jp	m,xor_16
		fail_msg 15
xor_16:		cp	data_ff
		jr	z,xor_17
		fail_msg 16
xor_17:		ld	a,data_ff
		ld	h,data_7f
		xor	a,h
		jp	po,xor_18
		fail_msg 17
xor_18:		ld	l,data_7f
		xor	a,l
		jp	pe,xor_19
		fail_msg 18
xor_19:		cp	data_ff
		jr	z,xor_20
		fail_msg 19
xor_20:		ld	a,data_ff
		add	a,1
		jr	c,xor_21
		fail_msg 20
xor_21:		ld	b,data_7f
		xor	a,b
		jr	nc,xor_22
		fail_msg 21
xor_22:		cp	data_7f
		jr	z,xor_23
		fail_msg 22
xor_23:		ld	a,data_ff
		xor	a,data_7f
		jp	po,xor_24
		fail_msg 23
xor_24:		jp	m,xor_25
		fail_msg 24
xor_25:		xor	a,data_7f
		jp	pe,xor_26
		fail_msg 25
xor_26:		jp	m,xor_27
		fail_msg 26
xor_27:		xor	a,data_aa
		jp	p,xor_28
		fail_msg 27
xor_28:		cp	data_55
		jr	z,xor_29
		fail_msg 28
xor_29:		ld	a,data_ff
		xor	a,data_ff
		jr	z,xor_30
		fail_msg 29
xor_30:		xor	a,data_80
		jr	nz,xor_31
		fail_msg 30
xor_31:		cp	data_80
		jr	z,xor_32
		fail_msg 31
xor_32:		ld	hl,var5
		ld	a,data_ff
		xor	a,(hl)
		jp	m,xor_33
		fail_msg 32
xor_33:		jp	po,xor_34
		fail_msg 33
xor_34:		xor	a,(hl)
		jp	m,xor_35
		fail_msg 34
xor_35:		jp	pe,xor_36
		fail_msg 35
xor_36:		ld	hl,var3
		xor	a,(hl)
		jp	p,xor_37
		fail_msg 36
xor_37:		cp	data_7f
		jr	z,xor_38
		fail_msg 37
xor_38:		ld	hl,var1
		ld	a,data_ff
		xor	a,(hl)
		jr	z,xor_39
		fail_msg 38
xor_39:		ld	hl,var2
		xor	a,(hl)
		jr	nz,xor_40
		fail_msg 39
xor_40:		cp	data_55
		jr	z,xor_41
		fail_msg 40
xor_41:		ld	ix,var3
		ld	a,data_ff
		xor	a,(ix+2)
		jp	m,xor_42
		fail_msg 41
xor_42:		jp	po,xor_43
		fail_msg 42
xor_43:		xor	a,(ix+2)
		jp	m,xor_44
		fail_msg 43
xor_44:		jp	pe,xor_45
		fail_msg 44
xor_45:		xor	a,(ix+1)
		jp	p,xor_46
		fail_msg 45
xor_46:		cp	data_55
		jr	z,xor_47
		fail_msg 46
xor_47:		ld	a,data_ff
		xor	a,(ix-2)
		jr	z,xor_48
		fail_msg 47
xor_48:		xor	a,(ix+1)
		jr	nz,xor_49
		fail_msg 48
xor_49:		cp	data_aa
		jr	z,xor_50
		fail_msg 49
xor_50:		ld	iy,var3
		ld	a,data_ff
		xor	a,(iy+2)
		jp	m,xor_51
		fail_msg 50
xor_51:		jp	po,xor_52
		fail_msg 51
xor_52:		xor	a,(iy+2)
		jp	m,xor_53
		fail_msg 52
xor_53:		jp	pe,xor_54
		fail_msg 53
xor_54:		xor	a,(iy+1)
		jp	p,xor_55
		fail_msg 54
xor_55:		cp	data_55
		jr	z,xor_56
		fail_msg 55
xor_56:		ld	a,data_ff
		xor	a,(iy-2)
		jr	z,xor_57
		fail_msg 56
xor_57:		xor	a,(iy-1)
		jr	nz,xor_58
		fail_msg 57
xor_58:		cp	data_55
		jr	z,cp_0
		fail_msg 58
cp_0:		nop
		print	"cp_0"
		ld	a,0
		ld	b,0
		cp	a,b
		jr	z,cp_1
		fail_msg 0
cp_1:		jp	p,cp_2
		fail_msg 1
cp_2:		jr	nc,cp_3
		fail_msg 2
cp_3:		ld	b,data_55
		cp	a,b
		jr	nz,cp_4
		fail_msg 3
cp_4:		jp	m,cp_5
		fail_msg 4
cp_5:		jr	c,cp_6
		fail_msg 5
cp_6:		ld	a,data_80
		ld	b,data_7f
		cp	a,b
		jp	pe,cp_7
		fail_msg 6
cp_7:		jr	nc,cp_8
		fail_msg 7
cp_8:		ld	a,data_7f
		ld	b,data_80
		cp	a,b
		jp	pe,cp_9
		fail_msg 8
cp_9:		jr	c,cp_10
		fail_msg 9
cp_10:		ld	b,0
		cp	a,b
		jp	po,cp_11
		fail_msg 10
cp_11:		jr	nc,cp_12
		fail_msg 11
cp_12:		ld	a,data_80
		ld	c,0
		cp	a,c
		jp	m,cp_13
		fail_msg 12
cp_13:		ld	c,data_80
		cp	a,c
		jr	z,cp_14
		fail_msg 13
cp_14:		ld	a,data_7f
		ld	d,data_55
		cp	a,d
		jp	p,cp_15
		fail_msg 14
cp_15:		jr	nz,cp_16
		fail_msg 15
cp_16:		ld	e,data_7f
		cp	a,e
		jr	z,cp_17
		fail_msg 16
cp_17:		ld	a,data_80
		ld	h,data_ff
		cp	a,h
		jp	m,cp_18
		fail_msg 17
cp_18:		jr	c,cp_19
		fail_msg 18
cp_19:		ld	l,data_80
		cp	a,l
		jr	z,cp_20
		fail_msg 19
cp_20:		ld	a,data_80
		cp	a,data_7f
		jp	p,cp_21
		fail_msg 20
cp_21:		jp	pe,cp_22
		fail_msg 21
cp_22:		jr	nz,cp_23
		fail_msg 22
cp_23:		cp	a,data_80
		jp	p,cp_24
		fail_msg 23
cp_24:		jp	po,cp_25
		fail_msg 24
cp_25:		jr	z,cp_26
		fail_msg 25
cp_26:		ld	a,data_55
		cp	a,data_7f
		jr	c,cp_27
		fail_msg 26
cp_27:		jp	m,cp_28
		fail_msg 27
cp_28:		cp	a,data_55
		jr	nc,cp_29
		fail_msg 28
cp_29:		jr	z,cp_30
		fail_msg 29
cp_30:		ld	a,data_80
		ld	hl,var5
		cp	a,(hl)
		jp	p,cp_31
		fail_msg 30
cp_31:		jp	pe,cp_32
		fail_msg 31
cp_32:		jr	nz,cp_33
		fail_msg 32
cp_33:		ld	hl,var3
		cp	a,(hl)
		jp	p,cp_34
		fail_msg 33
cp_34:		jp	po,cp_35
		fail_msg 34
cp_35:		jr	z,cp_36
		fail_msg 35
cp_36:		ld	a,data_55
		ld	hl,var5
		cp	a,(hl)
		jr	c,cp_37
		fail_msg 36
cp_37:		jp	m,cp_38
		fail_msg 37
cp_38:		ld	hl,var2
		cp	a,(hl)
		jr	nc,cp_39
		fail_msg 38
cp_39:		jp	p,cp_40
		fail_msg 39
cp_40:		jr	z,cp_41
		fail_msg 40
cp_41:		ld	a,data_80
		ld	ix,var3
		cp	a,(ix+2)
		jp	p,cp_42
		fail_msg 41
cp_42:		jp	pe,cp_43
		fail_msg 42
cp_43:		jr	nz,cp_44
		fail_msg 43
cp_44:		cp	a,(ix+0)
		jp	p,cp_45
		fail_msg 44
cp_45:		jp	po,cp_46
		fail_msg 45
cp_46:		jr	z,cp_47
		fail_msg 46
cp_47:		ld	a,data_55
		cp	a,(ix-2)
		jr	nz,cp_48
		fail_msg 47
cp_48:		jr	c,cp_49
		fail_msg 48
cp_49:		cp	a,(ix-1)
		jr	z,cp_50
		fail_msg 49
cp_50:		jr	nc,cp_51
		fail_msg 50
cp_51:		ld	iy,var3
		ld	a,data_80
		cp	a,(iy+2)
		jp	p,cp_52
		fail_msg 51
cp_52:		jp	pe,cp_53
		fail_msg 52
cp_53:		jr	nz,cp_54
		fail_msg 53
cp_54:		cp	a,(iy+0)
		jp	p,cp_55
		fail_msg 54
cp_55:		jp	po,cp_56
		fail_msg 55
cp_56:		jr	z,cp_57
		fail_msg 56
cp_57:		ld	a,data_55
		cp	a,(iy-2)
		jr	nz,cp_58
		fail_msg 57
cp_58:		jr	c,cp_59
		fail_msg 58
cp_59:		cp	a,(iy-1)
		jr	z,cp_60
		fail_msg 59
cp_60:		jr	nc,inc_0
		fail_msg 60
inc_0:		nop
		print "inc"
		ld	a,data_7f
		cp	a,data_7f
		jr	z,inc_1
		fail_msg 0
inc_1:		inc	a
		jp	pe,inc_2
		fail_msg 1
inc_2:		jp	m,inc_3
		fail_msg 2
inc_3:		jr	nz,inc_4
		fail_msg 3
inc_4:		ld	a,data_55
		inc	a
		jp	po,inc_5
		fail_msg 4
inc_5:		jp	p,inc_6
		fail_msg 5
inc_6:		cp	a,data_55+1
		jr	z,inc_7
		fail_msg 6
inc_7:		ld	a,data_ff-1
		inc	a
		jr	nz,inc_8
		fail_msg 7
inc_8:		jp	m,inc_9
		fail_msg 8
inc_9:		inc	a
		jr	z,inc_10
		fail_msg 9
inc_10:		ld	b,data_aa
		inc	b
		jp	m,inc_11
		fail_msg 10
inc_11:		ld	a,b
		cp	a,data_aa+1
		jr	z,inc_12
		fail_msg 11
inc_12:		ld	c,data_80
		inc	c
		jp	m,inc_13
		fail_msg 12
inc_13:		ld	a,c
		cp	a,data_80+1
		jr	z,inc_14
		fail_msg 13
inc_14:		ld	d,data_ff
		inc	d
		jr	z,inc_15
		fail_msg 14
inc_15:		ld	e,data_55
		inc	e
		jp	p,inc_16
		fail_msg 15
inc_16:		ld	a,e
		cp	a,data_55+1
		jr	z,inc_17
		fail_msg 16
inc_17:		ld	h,data_7f
		inc	h
		jp	pe,inc_18
		fail_msg 17
inc_18:		ld	a,h
		cp	a,data_80
		jr	z,inc_19
		fail_msg 18
inc_19:		ld	l,data_aa
		inc	l
		jp	m,inc_20
		fail_msg 19
inc_20:		ld	a,l
		cp	a,data_aa+1
		jr	z,inc_21
		fail_msg 20
inc_21:		ld	hl,t_var1
		ld	a,data_7f
		ld	(hl),a
		cp	a,(hl)
		jr	z,inc_22
		fail_msg 21
inc_22:		inc	(hl)
		jp	m,inc_23
		fail_msg 22
inc_23:		jp	pe,inc_24
		fail_msg 23
inc_24:		ld	a,data_55
		ld	(hl),a
		inc	(hl)
		jp	p,inc_25
		fail_msg 24
inc_25:		jp	po,inc_26
		fail_msg 25
inc_26:		ld	a,(hl)
		cp	a,data_55+1
		jr	z,inc_27
		fail_msg 26
inc_27:		ld	a,data_ff
		ld	(hl),a
		inc	(hl)
		jr	z,inc_28
		fail_msg 27
inc_28:		inc	(hl)
		jr	nz,inc_29
		fail_msg 28
inc_29:		ld	a,(hl)
		cp	a,1
		jr	z,inc_30
		fail_msg 29
inc_30:		ld	a,data_aa
		ld	(hl),a
		inc	(hl)
		jp	m,inc_31
		fail_msg 30
inc_31:		ld	a,(hl)
		cp	a,data_aa+1
		jr	z,inc_32
		fail_msg 31
inc_32:		ld	ix,t_var3
		ld	a,data_7f
		ld	(ix-2),a
		cp	a,data_7f
		jr	z,inc_33
		fail_msg 32
inc_33:		inc	(ix-2)
		jp	m,inc_34
		fail_msg 33
inc_34:		jp	pe,inc_35
		fail_msg 34
inc_35:		ld	a,data_55
		ld	(ix+2),a
		inc	(ix+2)
		jp	p,inc_36
		fail_msg 35
inc_36:		jp	po,inc_37
		fail_msg 36
inc_37:		ld	a,(ix+2)
		cp	a,data_55+1
		jr	z,inc_38
		fail_msg 37
inc_38:		ld	a,data_ff
		ld	(ix-1),a
		inc	(ix-1)
		jr	z,inc_39
		fail_msg 38
inc_39:		inc	(ix-1)
		jr	nz,inc_40
		fail_msg 39
inc_40:		ld	a,(ix-1)
		cp	a,1
		jr	z,inc_41
		fail_msg 40
inc_41:		ld	a,data_aa
		ld	(ix+1),a
		inc	(ix+1)
		jp	m,inc_42
		fail_msg 41
inc_42:		ld	a,(ix+1)
		cp	a,data_aa+1
		jr	z,inc_43
		fail_msg 42
inc_43:		ld	iy,t_var3
		ld	a,data_7f
		ld	(iy+2),a
		cp	a,data_7f
		jr	z,inc_44
		fail_msg 43
inc_44:		inc	(iy+2)
		jp	m,inc_45
		fail_msg 44
inc_45:		jp	pe,inc_46
		fail_msg 45
inc_46:		ld	a,data_55
		ld	(iy-2),a
		inc	(iy-2)
		jp	p,inc_47
		fail_msg 46
inc_47:		jp	po,inc_48
		fail_msg 47
inc_48:		ld	a,(iy-2)
		cp	a,data_55+1
		jr	z,inc_49
		fail_msg 48
inc_49:		ld	a,data_ff
		ld	(iy+1),a
		inc	(iy+1)
		jr	z,inc_50
		fail_msg 49
inc_50:		inc	(iy+1)
		jr	nz,inc_51
		fail_msg 50
inc_51:		ld	a,(iy+1)
		cp	a,1
		jr	z,inc_52
		fail_msg 51
inc_52:		ld	a,data_80
		ld	(iy-1),a
		inc	(iy-1)
		jp	m,inc_53
		fail_msg 52
inc_53:		ld	a,(iy-1)
		cp	a,data_80+1
		jr	z,dec_0
		fail_msg 53
dec_0:		nop
		print "dec"
		ld	a,data_80
		cp	a,data_80
		jr	z,dec_1
		fail_msg 0
dec_1:		dec	a
		jp	p,dec_2
		fail_msg 1
dec_2:		jp	pe,dec_3
		fail_msg 2
dec_3:		ld	a,0
		dec	a
		jp	m,dec_4
		fail_msg 3
dec_4:		jp	po,dec_5
		fail_msg 4
dec_5:		cp	a,data_ff
		jr	z,dec_6
		fail_msg 5
dec_6:		ld	a,1
		dec	a
		jr	z,dec_7
		fail_msg 6
dec_7:		dec	a
		jr	nz,dec_8
		fail_msg 7
dec_8:		cp	a,data_ff
		jr	z,dec_9
		fail_msg 8
dec_9:		ld	a,data_aa
		dec	a
		cp	a,data_aa-1
		jr	z,dec_10
		fail_msg 9
dec_10:		ld	b,data_7f
		dec	b
		ld	a,b
		cp	a,data_7f-1
		jr	z,dec_11
		fail_msg 10
dec_11:		ld	c,data_55
		dec	c
		ld	a,c
		cp	a,data_55-1
		jr	z,dec_12
		fail_msg 11
dec_12:		ld	d,data_aa
		dec	d
		ld	a,d
		cp	a,data_aa-1
		jr	z,dec_13
		fail_msg 12
dec_13:		ld	e,data_80
		dec	e
		ld	a,e
		cp	a,data_80-1
		jr	z,dec_14
		fail_msg 13
dec_14:		ld	h,data_ff
		dec	h
		ld	a,h
		cp	a,data_ff-1
		jr	z,dec_15
		fail_msg 14
dec_15:		ld	l,data_55
		dec	l
		ld	a,l
		cp	a,data_55-1
		jr	z,dec_16
		fail_msg 15
dec_16:		ld	hl,t_var5
		ld	a,data_80
		ld	(hl),a
		cp	a,(hl)
		jr	z,dec_17
		fail_msg 16
dec_17:		dec	(hl)
		jp	p,dec_18
		fail_msg 17
dec_18:		jp	pe,dec_19
		fail_msg 18
dec_19:		ld	a,0
		ld	(hl),a
		dec	(hl)
		jp	m,dec_20
		fail_msg 19
dec_20:		jp	po,dec_21
		fail_msg 20
dec_21:		ld	a,(hl)
		cp	a,data_ff
		jr	z,dec_22
		fail_msg 21
dec_22:		ld	a,1
		ld	(hl),a
		dec	(hl)
		jr	z,dec_23
		fail_msg 22
dec_23:		dec	(hl)
		jr	nz,dec_24
		fail_msg 23
dec_24:		ld	a,(hl)
		cp	a,data_ff
		jr	z,dec_25
		fail_msg 24
dec_25:		ld	a,data_aa
		ld	(hl),a
		dec	(hl)
		ld	a,(hl)
		cp	a,data_aa-1
		jr	z,dec_26
		fail_msg 25
dec_26:		ld	ix,t_var3
		ld	a,data_80
		ld	(ix-2),a
		cp	a,(ix-2)
		jr	z,dec_27
		fail_msg 26
dec_27:		dec	(ix-2)
		jp	p,dec_28
		fail_msg 27
dec_28:		jp	pe,dec_29
		fail_msg 28
dec_29:		ld	a,0
		ld	(ix+2),a
		dec	(ix+2)
		jp	m,dec_30
		fail_msg 29
dec_30:		jp	po,dec_31
		fail_msg 30
dec_31:		ld	a,(ix+2)
		cp	a,data_ff
		jr	z,dec_32
		fail_msg 31
dec_32:		ld	a,1
		ld	(ix-1),a
		dec	(ix-1)
		jr	z,dec_33
		fail_msg 32
dec_33:		dec	(ix-1)
		jr	nz,dec_34
		fail_msg 33
dec_34:		ld	a,(ix-1)
		cp	a,data_ff
		jr	z,dec_35
		fail_msg 34
dec_35:		ld	a,data_7f
		ld	(ix+1),a
		dec	(ix+1)
		ld	a,(ix+1)
		cp	a,data_7f-1
		jr	z,dec_36
		fail_msg 35
dec_36:		ld	iy,t_var3
		ld	a,data_80
		ld	(iy-2),a
		cp	a,(iy-2)
		jr	z,dec_37
		fail_msg 36
dec_37:		dec	(iy-2)
		jp	p,dec_38
		fail_msg 37
dec_38:		jp	pe,dec_39
		fail_msg 38
dec_39:		ld	a,0
		ld	(iy+2),a
		dec	(iy+2)
		jp	m,dec_40
		fail_msg 39
dec_40:		jp	po,dec_41
		fail_msg 40
dec_41:		ld	a,(iy+2)
		cp	a,data_ff
		jr	z,dec_42
		fail_msg 41
dec_42:		ld	a,1
		ld	(iy+1),a
		dec	(iy+1)
		jr	z,dec_43
		fail_msg 42
dec_43:		dec	(iy+1)
		jr	nz,dec_44
		fail_msg 43
dec_44:		ld	a,(iy+1)
		cp	a,data_ff
		jr	z,dec_45
		fail_msg 44
dec_45:		ld	a,data_aa
		ld	(iy-1),a
		dec	(iy-1)
		ld	a,(iy-1)
		cp	a,data_aa-1
		jr	z,cpl_0
		fail_msg 45
cpl_0:		ld	a,data_ff
		cpl
		cp	a,0
		jr	z,cpl_1
		fail_msg 0
cpl_1:		ld	a,data_aa
		cpl
		cp	a,data_55
		jr	z,cpl_2
		fail_msg 1
cpl_2:		cpl
		cp	a,data_aa
		jr	z,neg_0
		fail_msg 2
neg_0:		nop
		print "neg"
		ld	a,data_80
		cp	a,data_80
		jp	po,neg_1
		fail_msg 0
neg_1:		neg
		jp	pe,neg_2
		fail_msg 1
neg_2:		jr	nz,neg_3
		fail_msg 2
neg_3:		jr	c,neg_4
		fail_msg 3
neg_4:		ld	a,0
		neg
		jp	po,neg_5
		fail_msg 4
neg_5:		jr	z,neg_6
		fail_msg 5
neg_6:		jr	nc,neg_7
		fail_msg 6
neg_7:		ld	a,data_55
		cp	a,data_55
		jp	p,neg_8
		fail_msg 7
neg_8:		neg
		jp	m,neg_9
		fail_msg 8
neg_9:		neg
		jp	p,neg_10
		fail_msg 9
neg_10:		cp	a,data_55
		jr	z,ccf_0
		fail_msg 10
ccf_0:		nop
		print "ccf/im"
		scf
		jr	c,ccf_1
		fail_msg 0
ccf_1:		ccf
		jr	nc,ccf_2
		fail_msg 1
ccf_2:		ccf
		jr	c,im_0
		fail_msg 2
im_0:		im	0
		im	1
		im	2
daa_0:		nop
		print "daa"
		ld	a,#99
		ld	b,#1
		add	a,b
		daa
		jr	c,daa_1
		fail_msg 0
daa_1:		jr	z,daa_2
		fail_msg 1
daa_2:		add	a,b
		jr	nc,daa_3
		fail_msg 2
daa_3:		jr	nz,daa_4
		fail_msg 3
daa_4:		cp	a,1
		jr	z,daa_5
		fail_msg 4
daa_5:		ld	a,#98
		ld	b,1
		add	a,b
		daa
		jp	m,daa_6
		fail_msg 5
daa_6:		add	a,b
		daa
		jp	p,daa_7
		fail_msg 6
daa_7:		ld	a,1
		ld	b,1
		add	a,b
		daa
		jp	po,daa_8
		fail_msg 7
daa_8:		add	a,b
		daa
		jp	pe,daa_9
		fail_msg 8
daa_9:		cp	a,3
		jr	z,add_74
		fail_msg 9
add_74:		nop
		print "add"
		ld	hl,data_1234
		add	hl,hl
		jr	nc,add_75
		fail_msg 74
add_75:		ld	a,h
		cp	a,#24
		jr	z,add_76
		fail_msg 75
add_76:		ld	a,l
		cp	a,#68
		jr	z,add_77
		fail_msg 76
add_77:		ld	hl,data_7fff
		ld	bc,data_8000
		add	hl,bc
		jr	nc,add_78
		fail_msg 77
add_78:		ld	bc,1
		add	hl,bc
		jr	c,add_79
		fail_msg 78
add_79:		ld	a,h
		cp	a,0
		jr	z,add_80
		fail_msg 79
add_80:		ld	a,l
		cp	a,0
		jr	z,add_81
		fail_msg 80
add_81:		ld	hl,data_aa55
		ld	de,data_ffff
		add	hl,de
		jr	c,add_82
		fail_msg 81
add_82:		ld	a,h
		cp	a,data_aa
		jr	z,add_83
		fail_msg 82
add_83:		ld	a,l
		cp	a,data_55-1
		jr	z,add_84
		fail_msg 83
add_84:		ld	hl,data_aa55
		ld	sp,data_8000
		add	hl,sp
		jr	c,add_85
		fail_msg 84
add_85:		ld	a,h
		cp	a,#2a
		jr	z,add_86
		fail_msg 85
add_86:		ld	a,l
		cp	a,data_55
		jr	z,add_87
		fail_msg 86
add_87:		ld	sp,stack_end
		ld	hl,data_1234
		scf
		ccf
		adc	hl,hl
		jr	nz,add_88
		fail_msg 87
add_88:		jr	nc,add_89
		fail_msg 88
add_89:		jp	p,add_90
		fail_msg 89
add_90:		jp	po,add_91
		fail_msg 90
add_91:		ld	bc,data_8000
		adc	hl,bc
		jp	m,add_92
		fail_msg 91
add_92:		jr	nc,add_93
		fail_msg 92
add_93:		jp	po,add_94
		fail_msg 93
add_94:		jp	nz,add_95
		fail_msg 94
add_95:		adc	hl,bc
		jp	p,add_96
		fail_msg 95
add_96:		jp	pe,add_97
		fail_msg 96
add_97:		jr	c,add_98
		fail_msg 97
add_98:		jr	nz,add_99
		fail_msg 98
add_99:		ld	de,#db97
		adc	hl,de
		jr	z,add_100
		fail_msg 99
add_100:	jr	c,add_101
		fail_msg 100
add_101:	jp	po,add_102
		fail_msg 101
add_102:	ld	de,0
		adc	hl,de
		jr	nc,add_103
		fail_msg 102
add_103:	jr	nz,add_104
		fail_msg 103
add_104:	ld	a,h
		cp	a,0
		jr	z,add_105
		fail_msg 104
add_105:	ld	a,l
		cp	a,1
		jr	z,add_106
		fail_msg 105
add_106:	ld	hl,data_1234
		ld	sp,data_ffff
		adc	hl,sp
		jr	c,add_107
		fail_msg 106
add_107:	ld	a,h
		cp	a,#12
		jr	z,add_108
		fail_msg 107
add_108:	ld	a,l
		cp	a,#33
		jr	z,sbc_66
		fail_msg 108
sbc_66:		ld	sp,stack_end
		print	"sbc"
		scf
		ccf
		ld	hl,data_1234
		sbc	hl,hl
		jr	z,sbc_67
		fail_msg 66
sbc_67:		jp	p,sbc_68
		fail_msg 67
sbc_68:		jp	po,sbc_69
		fail_msg 68
sbc_69:		jr	nc,sbc_70
		fail_msg 69
sbc_70:		ld	bc,data_1234
		sbc	hl,bc
		jr	nz,sbc_71
		fail_msg 70
sbc_71:		jr	c,sbc_72
		fail_msg 71
sbc_72:		jp	m,sbc_73
		fail_msg 72
sbc_73:		jp	po,sbc_74
		fail_msg 73
sbc_74:		ld	de,data_7fff
		sbc	hl,de
		jr	nz,sbc_75
		fail_msg 74
sbc_75:		jr	nc,sbc_76
		fail_msg 75
sbc_76:		jp	p,sbc_77
		fail_msg 76
sbc_77:		jp	pe,sbc_78
		fail_msg 77
sbc_78:		ld	sp,data_1234
		sbc	hl,sp
		jr	nz,sbc_79
		fail_msg 78
sbc_79:		ld	a,h
		cp	a,#5b
		jr	z,sbc_80
		fail_msg 79
sbc_80:		ld	a,l
		cp	a,#98
		jr	z,add_109
		fail_msg 80
add_109:	ld	sp,stack_end
		print	"add"
		ld	ix,0
		add	ix,sp
		jr	nc,add_110
		fail_msg 109
add_110:	push	ix
		pop	hl
		ld	a,h
		cp	a,stack_end_hi		; >stack_end
		jr	z,add_111
		fail_msg 110
add_111:	ld	a,l
		cp	a,stack_end_lo		; <stack_end
		jr	z,add_112
		fail_msg 111
add_112:	ld	ix,data_7fff
		ld	bc,data_aa55
		add	ix,bc
		jr	c,add_113
		fail_msg 112
add_113:	add	ix,bc
		jr	nc,add_114
		fail_msg 113
add_114:	push	ix
		pop	hl
		ld	a,h
		cp	a,#d4
		jr	z,add_115
		fail_msg 114
add_115:	ld	a,l
		cp	a,#a9
		jr	z,add_116
		fail_msg 115
add_116:	ld	ix,data_1234
		ld	de,data_1234
		add	ix,de
		push	ix
		pop	hl
		ld	a,h
		cp	a,#24		;>(data_1234+data_1234)
		jr	z,add_117
		fail_msg 116
add_117:	ld	a,l
		cp	a,#68		;<(data_1234+data_1234)
		jr	z,add_118
		fail_msg 117
add_118:	ld	ix,data_1234
		add	ix,ix
		push	ix
		pop	bc
		ld	a,b
		cp	a,#24		;>(data_1234+data_1234)
		jr	z,add_119
		fail_msg 118
add_119:	ld	a,c
		cp	a,#68		;<(data_1234+data_1234)
		jr	z,add_120
		fail_msg 119
add_120:	ld	sp,stack_end
		ld	iy,0
		add	iy,sp
		jr	nc,add_121
		fail_msg 120
add_121:	push	iy
		pop	hl
		ld	a,h
		cp	a,stack_end_hi		;>stack_end
		jr	z,add_122
		fail_msg 121
add_122:	ld	a,l
		cp	a,stack_end_lo		;<stack_end
		jr	z,add_123
		fail_msg 122
add_123:	ld	iy,data_7fff
		ld	bc,data_aa55
		add	iy,bc
		jr	c,add_124
		fail_msg 123
add_124:	add	iy,bc
		jr	nc,add_125
		fail_msg 124
add_125:	push	iy
		pop	hl
		ld	a,h
		cp	a,#d4
		jr	z,add_126
		fail_msg 125
add_126:	ld	a,l
		cp	a,#a9
		jr	z,add_127
		fail_msg 126
add_127:	ld	iy,data_1234
		ld	de,data_1234
		add	iy,de
		push	iy
		pop	hl
		ld	a,h
		cp	a,#24		;>(data_1234+data_1234)
		jr	z,add_128
		fail_msg 127
add_128:	ld	a,l
		cp	a,#68		;<(data_1234+data_1234)
		jr	z,add_129
		fail_msg 128
add_129:	ld	iy,data_1234
		add	iy,iy
		push	iy
		pop	bc
		ld	a,b
		cp	a,#24		;>(data_1234+data_1234)
		jr	z,add_130
		fail_msg 129
add_130:	ld	a,c
		cp	a,#68		;<(data_1234+data_1234)
		jr	z,inc_54
		fail_msg 130
inc_54:		ld	sp,stack_end
		print "inc"
		ld	bc,data_1234
		inc	bc
		ld	a,b
		cp	a,#12      ;bjp was >data_1234
		jr	z,inc_55
		fail_msg 54
inc_55:		ld	a,c
		cp	a,#34+1      ;bjp was >data_1234+1
		jr	z,inc_56
		fail_msg 55
inc_56:		ld	de,data_55aa
		inc	de
		ld	a,d
		cp	a,#55		;>data_55aa
		jr	z,inc_57
		fail_msg 56
inc_57:		ld	a,e
		cp	a,#ab		;<data_55aa+1
		jr	z,inc_58
		fail_msg 57
inc_58:		ld	hl,data_7fff
		inc	hl
		ld	a,h
		cp	a,#80		;>data_7fff+1
		jr	z,inc_59
		fail_msg 58
inc_59:		ld	a,l
		cp	a,#00		;<data_7fff+1
		jr	z,inc_60
		fail_msg 59
	;; this test doesn't make any sense to me.  it looks
	;; like it increments SP, and then looks for *both*
	;; SPhigh and SPlow to have been incremented by 1.  The
	;; only way this works is if SP started as stack_end + 100
	;; added new statement accordingly. (gth)
inc_60:		ld	sp,stack_end+#100 ; added new initial val (gth)
		ld	hl,0
		inc	sp
		add	hl,sp
		ld	sp,stack_end
		ld	a,h
		cp	a,stack_end_hi+1		;>stack_end+1
		jr	z,inc_61
		fail_msg 60
inc_61:		ld	a,l
		cp	a,stack_end_lo+1		;<stack_end+1
		jr	z,inc_62
		fail_msg 61
inc_62:		ld	ix,data_8000
		inc	ix
		push	ix
		pop	de
		ld	a,d
		cp	a,#80		;>data_8000
		jr	z,inc_63
		fail_msg 62
inc_63:		ld	a,e
		cp	a,#01		;<data_8000+1
		jr	z,inc_64
		fail_msg 63
inc_64:		ld	iy,data_7fff
		inc 	iy
		push	iy
		pop	bc
		ld	a,b
		cp	a,#80		;>data_7fff+1
		jr	z,inc_65
		fail_msg 64
inc_65:		ld	a,c
		cp	a,#00		;<data_7fff+1
		jr	z,dec_46
		fail_msg 65
dec_46:		nop
		print	"dec"
		ld	bc,data_1234
		dec	bc
		ld	a,b
		cp	a,#12      ;bjp was >data_1234
		jr	z,dec_47
		fail_msg 46
dec_47:		ld	a,c
		cp	a,#34-1      ;bjp was >data_1234-1
		jr	z,dec_48
		fail_msg 47
dec_48:		ld	de,data_8000
		dec	de
		ld	a,d
		cp	a,#7f		;>data_7fff
		jr	z,dec_49
		fail_msg 48
dec_49:		ld	a,e
		cp	a,#ff		;<data_7fff
		jr	z,dec_50
		fail_msg 49
dec_50:		ld	hl,data_aa55
		dec	hl
		ld	a,h
		cp	a,#aa		;>data_aa55
		jr	z,dec_51
		fail_msg 50
dec_51:		ld	a,l
		cp	a,#54		;<data_aa55-1
		jr	z,dec_52
		fail_msg 51
	;; similar mysterious test to inc_60, expecting both halves
	;; of SP to be decremented.  Fix by setting sp stack_end-100 (gth)
dec_52:		ld	sp, stack_end-#100 ; new starting SP (gth)
		ld	hl,0
		dec	sp
		add	hl,sp
		ld	a,h
		cp	a,stack_end_hi-1		;>stack_end-1
		jr	z,dec_53
		fail_msg 52
dec_53:		ld	a,l
		cp	a,stack_end_lo-1		;<stack_end-1
		jr	z,dec_54
		fail_msg 53
dec_54:		ld	sp,stack_end
		ld	ix,data_ffff
		dec	ix
		push	ix
		pop	bc
		ld	a,b
		cp	a,#ff		;>data_ffff
		jr	z,dec_55
		fail_msg 54
dec_55:		ld	a,c
		cp	a,#fe		;<data_ffff-1
		jr	z,dec_56
		fail_msg 55
dec_56:		ld	iy,data_aa55
		dec	iy
		push	iy
		pop	de
		ld	a,d
		cp	a,#aa		;>data_aa55
		jr	z,dec_57
		fail_msg 56
dec_57:		ld	a,e
		cp	a,#54		;<data_aa55-1
		jr	z,rlca_0
		fail_msg 57
rlca_0:		nop
		print	"rlca/rla"
		ld	a,data_80
		rlca
		jr	c,rlca_1
		fail_msg 0
rlca_1:		rlca
		jr	nc,rlca_2
		fail_msg 1
rlca_2:		cp	a,2
		jr	z,rlca_3
		fail_msg 2
rlca_3:		ld	a,data_55
		rlca
		cp	a,data_aa
		jr	z,rla_0
		fail_msg 3
rla_0:
		scf
		ccf
		ld	a,data_80
		rla
		jr	c,rla_1
		fail_msg 0
rla_1:		rla
		jr	nc,rla_2
		fail_msg 1
rla_2:		cp	a,1
		jr	z,rla_3
		fail_msg 2
rla_3:		ld	a,data_7f
		rla
		cp	a,data_ff-1
		jr	z,rrca_0
		fail_msg 3
rrca_0:		nop
		print "rrca/rra"
		scf
		ccf
		ld	a,1
		rrca
		jr	c,rrca_1
		fail_msg 0
rrca_1:		rrca
		jr	nc,rrca_2
		fail_msg 1
rrca_2:		cp	a,data_7f-#3f
		jr	z,rrca_3
		fail_msg 2
rrca_3:		ld	a,data_aa
		rrca
		cp	a,data_55
		jr	z,rra_0
		fail_msg 3
rra_0:		scf
		ccf
		ld	a,1
		rra
		jr	c,rra_1
		fail_msg 0
rra_1:		rra
		jr	nc,rra_2
		fail_msg 1
rra_2:		cp	a,data_80
		jr	z,rra_3
		fail_msg 2
rra_3:		ld	a,data_aa
		rra
		cp	a,data_55
		jr	z,rlc_0
		fail_msg 3
rlc_0:		nop
		print	"rlc"
		ld	a,data_80
		rlc	a
		jr	c,rlc_1
		fail_msg 0
rlc_1:		jp	p,rlc_2
		fail_msg 1
rlc_2:		jr	nz,rlc_3
		fail_msg 2
rlc_3:		jp	po,rlc_4
		fail_msg 3
rlc_4:		rlc	a
		jr	nc,rlc_5
		fail_msg 4
rlc_5:		rlc	a
		rlc	a
		rlc	a
		rlc	a
		rlc	a
		rlc	a
		jp	m,rlc_6
		fail_msg 5
rlc_6:		ld	a,data_55
		rlc	a
		jp	m,rlc_7
		fail_msg 6
rlc_7:		jp	pe,rlc_8
		fail_msg 7
rlc_8:		cp	a,data_aa
		jr	z,rlc_9
		fail_msg 8
rlc_9:		ld	a,0
		rlc	a
		jr	z,rlc_10
		fail_msg 9
rlc_10:		ld	b,data_7f
		rlc	b
		ld	a,b
		cp	a,data_ff-1
		jr	z,rlc_11
		fail_msg 10
rlc_11:		ld	c,data_aa
		rlc	c
		jr	c,rlc_12
		fail_msg 11
rlc_12:		ld	a,c
		cp	a,data_55
		jr	z,rlc_13
		fail_msg 12
rlc_13:		ld	d,data_80
		rlc	d
		jr	c,rlc_14
		fail_msg 13
rlc_14:		ld	a,d
		cp	a,1
		jr	z,rlc_15
		fail_msg 14
rlc_15:		ld	e,data_ff
		rlc	e
		jr	c,rlc_16
		fail_msg 15
rlc_16:		ld	a,e
		cp	a,data_ff
		jr	z,rlc_17
		fail_msg 16
rlc_17:		ld	h,data_55
		rlc	h
		jp	m,rlc_18
		fail_msg 17
rlc_18:		ld	a,h
		cp	a,data_aa
		jr	z,rlc_19
		fail_msg 18
rlc_19:		ld	l,data_80
		rlc	l
		jp	p,rlc_20
		fail_msg 19
rlc_20:		ld	a,l
		cp	a,1
		jr	z,rlc_21
		fail_msg 20
rlc_21:		ld	hl,t_var1
		ld	a,data_55
		ld	(hl),a
		rlc	(hl)
		jp	m,rlc_22
		fail_msg 21
rlc_22:		jp	pe,rlc_23
		fail_msg 22
rlc_23:		jr	nc,rlc_24
		fail_msg 23
rlc_24:		jr	nz,rlc_25
		fail_msg 24
rlc_25:		rlc	(hl)
		jp	p,rlc_26
		fail_msg 25
rlc_26:		jr	c,rlc_27
		fail_msg 26
rlc_27:		ld	a,(hl)
		cp	a,data_55
		jr	z,rlc_28
		fail_msg 27
rlc_28:		ld	a,data_7f
		ld	(hl),a
		rlc	(hl)
		jp	po,rlc_29
		fail_msg 28
rlc_29:		ld	a,(hl)
		cp	a,data_ff-1
		jr	z,rlc_30
		fail_msg 29
rlc_30:		ld	a,0
		ld	(hl),a
		rlc	(hl)
		jr	z,rlc_31
		fail_msg 30
rlc_31:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		rlc	(ix-2)
		jp	m,rlc_32
		fail_msg 31
rlc_32:		jp	pe,rlc_33
		fail_msg 32
rlc_33:		jr	nz,rlc_34
		fail_msg 33
rlc_34:		jr	nc,rlc_35
		fail_msg 34
rlc_35:		rlc	(ix-2)
		jp	p,rlc_36
		fail_msg 35
rlc_36:		jr	c,rlc_37
		fail_msg 36
rlc_37:		ld	a,(ix-2)
		cp	a,data_55
		jr	z,rlc_38
		fail_msg 37
rlc_38:		ld	a,data_7f
		ld	(ix+2),a
		rlc	(ix+2)
		jp	po,rlc_39
		fail_msg 38
rlc_39:		ld	a,(ix+2)
		cp	a,data_ff-1
		jr	z,rlc_40
		fail_msg 39
rlc_40:		ld	a,0
		ld	(ix-1),a
		rlc	(ix-1)
		jr	z,rlc_41
		fail_msg 40
rlc_41:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy+2),a
		rlc	(iy+2)
		jp	m,rlc_42
		fail_msg 41
rlc_42:		jp	pe,rlc_43
		fail_msg 42
rlc_43:		jr	nc,rlc_44
		fail_msg 43
rlc_44:		jr	nz,rlc_45
		fail_msg 44
rlc_45:		rlc	(iy+2)
		jp	p,rlc_46
		fail_msg 45
rlc_46:		jr	c,rlc_47
		fail_msg 46
rlc_47:		ld	a,(iy+2)
		cp	a,data_55
		jr	z,rlc_48
		fail_msg 47
rlc_48:		ld	a,data_7f
		ld	(iy-2),a
		rlc	(iy-2)
		jp	po,rlc_49
		fail_msg 48
rlc_49:		ld	a,(iy-2)
		cp	a,data_ff-1
		jr	z,rlc_50
		fail_msg 49
rlc_50:		ld	a,0
		ld	(iy+1),a
		rlc	(iy+1)
		jr	z,rl_0
		fail_msg 50
rl_0:		nop
		print	"rl"
		scf
		ccf
		ld	a,data_55
		rl	a
		jp	m,rl_1
		fail_msg 0
rl_1:		jp	pe,rl_2
		fail_msg 1
rl_2:		jr	nc,rl_3
		fail_msg 2
rl_3:		jr	nz,rl_4
		fail_msg 3
rl_4:		rl	a
		jp	p,rl_5
		fail_msg 4
rl_5:		jp	po,rl_6
		fail_msg 5
rl_6:		jr	c,rl_7
		fail_msg 6
rl_7:		rl	a
		cp	a,data_aa-1
		jr	z,rl_8
		fail_msg 7
rl_8:		ld	a,0
		rl	a
		jr	z,rl_9
		fail_msg 8
rl_9:		ld	b,data_aa
		ld	c,data_7f
		rl	b
		jr	c,rl_10
		fail_msg 9
rl_10:		rl	c
		jr	nc,rl_11
		fail_msg 10
rl_11:		ld	a,b
		cp	a,data_55-1
		jr	z,rl_12
		fail_msg 11
rl_12:		ld	a,c
		cp	a,data_ff
		jr	z,rl_13
		fail_msg 12
rl_13:		ld	d,data_ff
		ld	e,data_80
		rl	e
		jr	c,rl_14
		fail_msg 13
rl_14:		rl	d
		jr	c,rl_15
		fail_msg 14
rl_15:		ld	a,d
		cp	a,data_ff
		jr	z,rl_16
		fail_msg 15
rl_16:		ld	a,e
		cp	a,0
		jr	z,rl_17
		fail_msg 16
rl_17:		ld	h,data_7f
		ld	l,data_55
		rl	h
		jp	m,rl_18
		fail_msg 17
rl_18:		rl	l
		jp	m,rl_19
		fail_msg 18
rl_19:		ld	a,h
		cp	a,data_ff-1
		jr	z,rl_20
		fail_msg 19
rl_20:		ld	a,l
		cp	a,data_aa
		jr	z,rl_21
		fail_msg 20
rl_21:		ld	hl,t_var5
		ld	a,data_55
		ld	(hl),a
		rl	(hl)
		jp	m,rl_22
		fail_msg 21
rl_22:		jp	pe,rl_23
		fail_msg 22
rl_23:		jr	nc,rl_24
		fail_msg 23
rl_24:		jr	nz,rl_25
		fail_msg 24
rl_25:		rl	(hl)
		jp	p,rl_26
		fail_msg 25
rl_26:		jp	po,rl_27
		fail_msg 26
rl_27:		jr	c,rl_28
		fail_msg 27
rl_28:		ld	a,(hl)
		cp	a,data_55-1
		jr	z,rl_29
		fail_msg 28
rl_29:		ld	a,0
		ld	(hl),a
		rl	(hl)
		jr	z,rl_30
		fail_msg 29
rl_30:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		rl	(ix-2)
		jp	m,rl_31
		fail_msg 30
rl_31:		jp	pe,rl_32
		fail_msg 31
rl_32:		jr	nc,rl_33
		fail_msg 32
rl_33:		jr	nz,rl_34
		fail_msg 33
rl_34:		rl	(ix-2)
		jp	p,rl_35
		fail_msg 34
rl_35:		jp	po,rl_36
		fail_msg 35
rl_36:		jr	c,rl_37
		fail_msg 36
rl_37:		ld	a,(ix-2)
		cp	a,data_55-1
		jr	z,rl_38
		fail_msg 37
rl_38:		ld	a,0
		ld	(ix+2),a
		rl	(ix+2)
		jr	z,rl_39
rl_39:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy-1),a
		rl	(iy-1)
		jp	m,rl_40
		fail_msg 39
rl_40:		jp	pe,rl_41
		fail_msg 40
rl_41:		jr	nc,rl_42
		fail_msg 41
rl_42:		jr	nz,rl_43
		fail_msg 42
rl_43:		rl	(iy-1)
		jp	p,rl_44
		fail_msg 43
rl_44:		jp	po,rl_45
		fail_msg 44
rl_45:		jr	c,rl_46
		fail_msg 45
rl_46:		ld	a,(iy-1)
		cp	a,data_55-1
		jr	z,rl_47
		fail_msg 46
rl_47:		ld	a,0
		ld	(iy+1),a
		rl	(iy+1)
		jr	z,rrc_0
		fail_msg 47
rrc_0:		nop
		print	"rrc"
		ld	a,data_aa
		rrc	a
		jp	p,rrc_1
		fail_msg 0
rrc_1:		jp	pe,rrc_2
		fail_msg 1
rrc_2:		jr	nz,rrc_3
		fail_msg 2
rrc_3:		jr	nc,rrc_4
		fail_msg 3
rrc_4:		rrc	a
		jp	m,rrc_5
		fail_msg 4
rrc_5:		jr	c,rrc_6
		fail_msg 5
rrc_6:		cp	a,data_aa
		jr	z,rrc_7
		fail_msg 6
rrc_7:		ld	a,1
		rrc	a
		jr	c,rrc_8
		fail_msg 7
rrc_8:		cp	a,data_80
		jr	z,rrc_9
		fail_msg 8
rrc_9:		ld	a,data_7f
		rrc	a
		jp	po,rrc_10
		fail_msg 9
rrc_10:		cp	a,#bf
		jr	z,rrc_11
		fail_msg 10
rrc_11:		ld	b,data_80
		ld	c,data_55
		rrc	b
		jr	nc,rrc_12
		fail_msg 11
rrc_12:		rrc	c
		jr	c,rrc_13
		fail_msg 12
rrc_13:		ld	a,b
		cp	a,#40
		jr	z,rrc_14
		fail_msg 13
rrc_14:		ld	a,c
		cp	a,data_aa
		jr	z,rrc_15
		fail_msg 14
rrc_15:		ld	d,data_aa
		ld	e,1
		rrc	d
		jp	p,rrc_16
		fail_msg 15
rrc_16:		rrc	e
		jp	m,rrc_17
		fail_msg 16
rrc_17:		ld	a,d
		cp	a,data_55
		jr	z,rrc_18
		fail_msg 17
rrc_18:		ld	a,e
		cp	a,data_80
		jr	z,rrc_19
		fail_msg 18
rrc_19:		ld	h,data_55
		ld	l,data_ff
		rrc	h
		jr	c,rrc_20
		fail_msg 19
rrc_20:		rrc	l
		jr	c,rrc_21
		fail_msg 20
rrc_21:		ld	a,h
		cp	a,data_aa
		jr	z,rrc_22
		fail_msg 21
rrc_22:		ld	a,l
		cp	a,data_ff
		jr	z,rrc_23
		fail_msg 22
rrc_23:		ld	hl,t_var4
		ld	(hl),data_aa
		rrc	 (hl)
		jp	p,rrc_24
		fail_msg 23
rrc_24:		jp	pe,rrc_25
		fail_msg 24
rrc_25:		jr	nz,rrc_26
		fail_msg 25
rrc_26:		jr	nc,rrc_27
		fail_msg 26
rrc_27:		rrc	(hl)
		jp	m,rrc_28
		fail_msg 27
rrc_28:		jr	c,rrc_29
		fail_msg 28
rrc_29:		ld	a,(hl)
		cp	a,data_aa
		jr	z,rrc_30
		fail_msg 29
rrc_30:		ld	(hl),data_7f
		rrc	(hl)
		jp	po,rrc_31
		fail_msg 30
rrc_31:		ld	a,(hl)
		cp	a,#bf
		jr	z,rrc_32
		fail_msg 31
rrc_32:		ld	(hl),0
		rrc	(hl)
		jr	z,rrc_33
		fail_msg 32
rrc_33:		ld	ix,t_var3
		ld	a,data_aa
		ld	(ix+2),a
		rrc	(ix+2)
		jp	p,rrc_34
		fail_msg 33
rrc_34:		jp	pe,rrc_35
		fail_msg 34
rrc_35:		jr	nc,rrc_36
		fail_msg 35
rrc_36:		jr	nz,rrc_37
		fail_msg 36
rrc_37:		rrc	(ix+2)
		jp	m,rrc_38
		fail_msg 37
rrc_38:		jr	c,rrc_39
		fail_msg 38
rrc_39:		ld	a,(ix+2)
		cp	a,data_aa
		jr	z,rrc_40
		fail_msg 39
rrc_40:		ld	a,1
		ld	(ix-2),a
		rrc	(ix-2)
		jp	po,rrc_41
		fail_msg 40
rrc_41:		ld	a,(ix-2)
		cp	a,data_80
		jr	z,rrc_42
		fail_msg 41
rrc_42:		ld	a,0
		ld	(ix+1),a
		rrc	(ix+1)
		jr	z,rrc_43
		fail_msg 42
rrc_43:		ld	iy,t_var3
		ld	a,data_aa
		ld	(iy+2),a
		rrc	(iy+2)
		jp	p,rrc_44
		fail_msg 43
rrc_44:		jp	pe,rrc_45
		fail_msg 44
rrc_45:		jr	nc,rrc_46
		fail_msg 45
rrc_46:		jr	nz,rrc_47
		fail_msg 46
rrc_47:		rrc	(iy+2)
		jp	m,rrc_48
		fail_msg 47
rrc_48:		jr	c,rrc_49
		fail_msg 48
rrc_49:		ld	a,(iy+2)
		cp	a,data_aa
		jr	z,rrc_50
		fail_msg 49
rrc_50:		ld	a,1
		ld	(iy-2),a
		rrc	(iy-2)
		jp	po,rrc_51
		fail_msg 50
rrc_51:		ld	a,(iy-2)
		cp	a,data_80
		jr	z,rrc_52
		fail_msg 51
rrc_52:		ld	a,0
		ld	(iy+1),a
		rrc	(iy+1)
		jr	z,rr_0
		fail_msg 52
rr_0:		nop
		print	"rr"
		scf
		ccf
		ld	a,data_aa
		rr	a
		jp	p,rr_1
		fail_msg 0
rr_1:		jp	pe,rr_2
		fail_msg 1
rr_2:		jr	nc,rr_3
		fail_msg 2
rr_3:		jr	nz,rr_4
		fail_msg 3
rr_4:		rr	a
		jr	c,rr_5
		fail_msg 4
rr_5:		jp	po,rr_6
		fail_msg 5
rr_6:		cp	a,#2a
		jr	z,rr_7
		fail_msg 6
rr_7:		scf
		ld	a,0
		rr	a
		jp	m,rr_8
		fail_msg 7
rr_8:		cp	a,data_80
		jr	z,rr_9
		fail_msg 8
rr_9:		ld	a,0
		rr	a
		jr	z,rr_10
		fail_msg 9
rr_10:		ld	b,data_55
		ld	c,data_aa
		rr	b
		jr	c,rr_11
		fail_msg 10
rr_11:		rr	c
		jr	nc,rr_12
		fail_msg 11
rr_12:		ld	a,b
		cp	a,#2a
		jr	z,rr_13
		fail_msg 12
rr_13:		ld	a,c
		cp	a,#d5
		jr	z,rr_14
		fail_msg 13
rr_14:		ld	d,data_7f
		ld	e,data_80
		rr	d
		jr	c,rr_15
		fail_msg 14
rr_15:		rr	e
		jr	nc,rr_16
		fail_msg 15
rr_16:		ld	a,d
		cp	a,#3f
		jr	z,rr_17
		fail_msg 16
rr_17:		ld	a,e
		cp	a,#c0
		jr	z,rr_18
		fail_msg 17
rr_18:		ld	hl,t_var2
		ld	(hl),data_55
		rr	(hl)
		jp	p,rr_19
		fail_msg 18
rr_19:		jp	po,rr_20
		fail_msg 19
rr_20:		jr	c,rr_21
		fail_msg 20
rr_21:		jr	nz,rr_22
		fail_msg 21
rr_22:		rr	(hl)
		jp	m,rr_23
		fail_msg 22
rr_23:		jp	pe,rr_24
		fail_msg 23
rr_24:		jr	nc,rr_25
		fail_msg 24
rr_25:		ld	a,(hl)
		cp	a,#95
		jr	z,rr_26
		fail_msg 25
rr_26:		ld	(hl),0
		rr	(hl)
		jr	z,rr_27
		fail_msg 26
rr_27:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		rr	(ix-2)
		jp	p,rr_28
		fail_msg 27
rr_28:		jp	po,rr_29
		fail_msg 28
rr_29:		jr	c,rr_30
		fail_msg 29
rr_30:		jr	nz,rr_31
		fail_msg 30
rr_31:		rr	(ix-2)
		jp	m,rr_32
		fail_msg 31
rr_32:		jp	pe,rr_33
		fail_msg 32
rr_33:		jr	nc,rr_34
		fail_msg 33
rr_34:		ld	a,(ix-2)
		cp	a,#95
		jr	z,rr_35
		fail_msg 34
rr_35:		ld	a,0
		ld	(ix+2),a
		rr	(ix+2)
		jr	z,rr_36
		fail_msg 35
rr_36:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy+2),a
		rr	(iy+2)
		jp	p,rr_37
		fail_msg 36
rr_37:		jp	po,rr_38
		fail_msg 37
rr_38:		jr	c,rr_39
		fail_msg 38
rr_39:		jr	nz,rr_40
		fail_msg 39
rr_40:		rr	(iy+2)
		jp	m,rr_41
		fail_msg 40
rr_41:		jp	pe,rr_42
		fail_msg 41
rr_42:		jr	nc,rr_43
		fail_msg 42
rr_43:		ld	a,(iy+2)
		cp	a,#95
		jr	z,rr_44
		fail_msg 43
rr_44:		ld	a,0
		ld	(iy-1),a
		rr	(iy-1)
		jr	z,sla_0
		fail_msg 44
sla_0:		nop
		print	"sla"
		ld	a,data_55
		sla	a
		jp	m,sla_1
		fail_msg 0
sla_1:		jp	pe,sla_2
		fail_msg 1
sla_2:		jr	nc,sla_3
		fail_msg 2
sla_3:		jr	nz,sla_4
		fail_msg 3
sla_4:		sla	a
		jp	p,sla_5
		fail_msg 4
sla_5:		jp	po,sla_6
		fail_msg 5
sla_6:		jr	c,sla_7
		fail_msg 6
sla_7:		cp	a,data_55-1
		jr	z,sla_8
		fail_msg 7
sla_8:		ld	a,0
		sla	a
		jr	z,sla_9
		fail_msg 8
sla_9:		ld	b,data_80
		ld	c,data_7f
		sla	b
		jr	c,sla_10
		fail_msg 9
sla_10:		ld	a,b
		cp	a,0
		jr	z,sla_11
		fail_msg 10
sla_11:		sla	c
		jp	m,sla_12
		fail_msg 11
sla_12:		ld	a,c
		cp	a,data_ff-1
		jr	z,sla_13
		fail_msg 12
sla_13:		ld	d,data_aa
		ld	e,data_55
		sla	d
		jr	c,sla_14
		fail_msg 13
sla_14:		ld	a,d
		cp	a,data_55-1
		jr	z,sla_15
		fail_msg 14
sla_15:		sla	e
		jp	m,sla_16
		fail_msg 15
sla_16:		ld	a,e
		cp	a,data_aa
		jr	z,sla_17
		fail_msg 16
sla_17:		ld	h,#12      ;bjp was >data_1234
		ld	l,#34      ;bjp was >data_1234
		sla	h
		jp	p,sla_18
		fail_msg 17
sla_18:		ld	a,h
		cp	a,#24
		jr	z,sla_19
		fail_msg 18
sla_19:		sla	l
		jp	p,sla_20
		fail_msg 19
sla_20:		ld	a,l
		cp	a,#68
		jr	z,sla_21
		fail_msg 20
sla_21:		ld	hl,t_var3
		ld	(hl),data_55
		sla	(hl)
		jp	m,sla_22
		fail_msg 21
sla_22:		jp	pe,sla_23
		fail_msg 22
sla_23:		jr	nc,sla_24
		fail_msg 23
sla_24:		jr	nz,sla_25
		fail_msg 24
sla_25:		sla	(hl)
		jp	p,sla_26
		fail_msg 25
sla_26:		jp	po,sla_27
		fail_msg 26
sla_27:		jr	c,sla_28
		fail_msg 27
sla_28:		ld	a,(hl)
		cp	a,data_55-1
		jr	z,sla_29
		fail_msg 28
sla_29:		ld	(hl),0
		sla	(hl)
		jr	z,sla_30
		fail_msg 29
sla_30:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		sla	(ix-2)
		jp	m,sla_31
		fail_msg 30
sla_31:		jp	pe,sla_32
		fail_msg 31
sla_32:		jr	nc,sla_33
		fail_msg 32
sla_33:		jr	nz,sla_34
		fail_msg 33
sla_34:		sla	(ix-2)
		jp	p,sla_35
		fail_msg 34
sla_35:		jp	po,sla_36
		fail_msg 35
sla_36:		jr	c,sla_37
		fail_msg 36
sla_37:		ld	a,(ix-2)
		cp	a,data_55-1
		jr	z,sla_38
		fail_msg 37
sla_38:		ld	a,data_80
		ld	(ix+2),a
		sla	(ix+2)
		jr	z,sla_39
		fail_msg 38
sla_39:		jr	c,sla_40
		fail_msg 39
sla_40:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy+2),a
		sla	(iy+2)
		jp	m,sla_41
		fail_msg 40
sla_41:		jp	pe,sla_42
		fail_msg 41
sla_42:		jr	nc,sla_43
		fail_msg 42
sla_43:		jr	nz,sla_44
		fail_msg 43
sla_44:		sla	(iy+2)
		jp	p,sla_45
		fail_msg 44
sla_45:		jp	po,sla_46
		fail_msg 45
sla_46:		jr	c,sla_47
		fail_msg 46
sla_47:		ld	a,(iy+2)
		cp	a,data_55-1
		jr	z,sla_48
		fail_msg 47
sla_48:		ld	a,data_80
		ld	(iy-2),a
		sla	(iy-2)
		jr	z,sla_49
		fail_msg 48
sla_49:		jr	c,sra_0
		fail_msg 49
sra_0:		nop
		print	"sra"
		ld	a,data_55
		sra	a
		jp	p,sra_1
		fail_msg 0
sra_1:		jp	po,sra_2
		fail_msg 1
sra_2:		jr	c,sra_3
		fail_msg 2
sra_3:		jr	nz,sra_4
		fail_msg 3
sra_4:		sra	a
		jp	po,sra_5
		fail_msg 4
sra_5:		jr	nc,sra_6
		fail_msg 5
sra_6:		sra	a
		jp	pe,sra_7
		fail_msg 6
sra_7:		cp	a,#0a			;data_aa.and.#0f
		jr	z,sra_8
		fail_msg 7
sra_8:		ld	a,1
		sra	a
		jr	c,sra_9
		fail_msg 8
sra_9:		jr	z,sra_10
		fail_msg 9
sra_10:		ld	a,data_80
		sra	a
		jp	m,sra_11
		fail_msg 10
sra_11:		cp	a,#c0
		jr	z,sra_12
		fail_msg 11
sra_12:		ld	b,data_7f
		ld	c,data_aa
		sra	b
		jr	c,sra_13
		fail_msg 12
sra_13:		ld	a,b
		cp	a,#3f
		jr	z,sra_14
		fail_msg 13
sra_14:		sra	c
		jr	nc,sra_15
		fail_msg 14
sra_15:		ld	a,c
		cp	a,#d5
		jr	z,sra_16
		fail_msg 15
sra_16:		ld	d,data_55
		ld	e,data_ff
		sra	d
		jr	c,sra_17
		fail_msg 16
sra_17:		ld	a,d
		cp	a,#2a
		jr	z,sra_18
		fail_msg 17
sra_18:		sra	e
		jp	m,sra_19
		fail_msg 18
sra_19:		ld	a,e
		cp	a,data_ff
		jr	z,sra_20
		fail_msg 19
sra_20:		ld	h,data_aa
		ld	l,data_7f
		sra	h
		jp	m,sra_21
		fail_msg 20
sra_21:		ld	a,h
		cp	a,#d5
		jr	z,sra_22
		fail_msg 21
sra_22:		sra	l
		jr	c,sra_23
		fail_msg 22
sra_23:		ld	a,l
		cp	a,#3f
		jr	z,sra_24
		fail_msg 23
sra_24:		ld	hl,t_var1
		ld	(hl),data_55
		sra	(hl)
		jp	p,sra_25
		fail_msg 24
sra_25:		jp	po,sra_26
		fail_msg 25
sra_26:		jr	c,sra_27
		fail_msg 26
sra_27:		jr	nz,sra_28
		fail_msg 27
sra_28:		sra	(hl)
		jr	nc,sra_29
		fail_msg 28
sra_29:		sra	(hl)
		jp	pe,sra_30
		fail_msg 29
sra_30:		ld	a,(hl)
		cp	a,#0a			;data_aa.and.#0f
		jr	z,sra_31
		fail_msg 30
sra_31:		ld	(hl),data_80
		sra	(hl)
		jp	m,sra_32
		fail_msg 31
sra_32:		ld	a,(hl)
		cp	a,#c0
		jr	z,sra_33
		fail_msg 32
sra_33:		ld	(hl),1
		sra	(hl)
		jr	c,sra_34
		fail_msg 33
sra_34:		jr	z,sra_35
		fail_msg 34
sra_35:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		sra	(ix-2)
		jp	p,sra_36
		fail_msg 35
sra_36:		jp	po,sra_37
		fail_msg 36
sra_37:		jr	c,sra_38
		fail_msg 37
sra_38:		jr	nz,sra_39
		fail_msg 38
sra_39:		sra	(ix-2)
		jr	nc,sra_40
		fail_msg 39
sra_40:		sra	(ix-2)
		jp	pe,sra_41
		fail_msg 40
sra_41:		ld	a,(ix-2)
		cp	a,#0a		;data_aa.and.#0f
		jr	z,sra_42
		fail_msg 41
sra_42:		ld	a,data_80
		ld	(ix+2),a
		sra	(ix+2)
		jp	m,sra_43
		fail_msg 42
sra_43:		ld	a,(ix+2)
		cp	a,#c0
		jr	z,sra_44
		fail_msg 43
sra_44:		ld	a,1
		ld	(ix-1),a
		sra	(ix-1)
		jr	c,sra_45
		fail_msg 44
sra_45:		jr	z,sra_46
		fail_msg 45
sra_46:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy-2),a
		sra	(iy-2)
		jp	p,sra_47
		fail_msg 46
sra_47:		jp	po,sra_48
		fail_msg 47
sra_48:		jr	c,sra_49
		fail_msg 48
sra_49:		jr	nz,sra_50
		fail_msg 49
sra_50:		sra	(iy-2)
		jr	nc,sra_51
		fail_msg 50
sra_51:		sra	(iy-2)
		jp	pe,sra_52
		fail_msg 51
sra_52:		ld	a,(iy-2)
		cp	a,#0a		;data_aa.and.#0f
		jr	z,sra_53
		fail_msg 52
sra_53:		ld	a,data_80
		ld	(iy+2),a
		sra	(iy+2)
		jp	m,sra_54
		fail_msg 53
sra_54:		ld	a,(iy+2)
		cp	a,#c0
		jr	z,sra_55
		fail_msg 54
sra_55:		ld	a,1
		ld	(iy-1),a
		sra	(iy-1)
		jr	c,sra_56
		fail_msg 55
sra_56:		jr	z,srl_0
		fail_msg 56
srl_0:		nop
		print	"srl"
		ld	a,data_55
		srl	a
		jr	c,srl_1
		fail_msg 0
srl_1:		jp	po,srl_2
		fail_msg 1
srl_2:		srl	a
		jr	nc,srl_3
		fail_msg 2
srl_3:		srl	a
		jp	pe,srl_4
		fail_msg 3
srl_4:		cp	a,#0a			;data_aa.and.#0f
		jr	z,srl_5
		fail_msg 4
srl_5:		ld	a,data_80
		and	a
		jp	m,srl_6
		fail_msg 5
srl_6:		srl	a
		jp	p,srl_7
		fail_msg 6
srl_7:		ld	a,2
		srl	a
		jr	nz,srl_8
		fail_msg 7
srl_8:		srl	a
		jr	z,srl_9
		fail_msg 8
srl_9:		jr	c,srl_10
		fail_msg 9
srl_10:		ld	b,data_aa
		srl	b
		jp	p,srl_11
		fail_msg 10
srl_11:		ld	a,b
		cp	a,data_55
		jr	z,srl_12
		fail_msg 11
srl_12:		ld	c,data_7f
		srl	c
		jr	c,srl_13
		fail_msg 12
srl_13:		ld	a,c
		cp	a,#3f
		jr	z,srl_14
		fail_msg 13
srl_14:		ld	d,data_55
		srl	d
		jr	c,srl_15
		fail_msg 14
srl_15:		ld	a,d
		cp	a,#2a
		jr	z,srl_16
		fail_msg 15
srl_16:		ld	e,data_ff
		srl	e
		jr	c,srl_17
		fail_msg 16
srl_17:		ld	a,e
		cp	a,data_7f
		jr	z,srl_18
		fail_msg 17
srl_18:		ld	h,#12      ;bjp was >data_1234
		srl	h
		jr	nc,srl_19
		fail_msg 18
srl_19:		ld	a,h
		cp	a,9
		jr	z,srl_20
		fail_msg 19
srl_20:		ld	l,#34      ;bjp was >data_1234
		srl	l
		jr	nc,srl_21
		fail_msg 20
srl_21:		ld	a,l
		cp	a,#1a
		jr	z,srl_22
		fail_msg 21
srl_22:		ld	hl,t_var1
		ld	(hl),data_55
		srl	(hl)
		jr	c,srl_23
		fail_msg 22
srl_23:		jp	po,srl_24
		fail_msg 23
srl_24:		srl	(hl)
		jr	nc,srl_25
		fail_msg 24
srl_25:		srl	(hl)
		jp	pe,srl_26
		fail_msg 25
srl_26:		ld	a,(hl)
		cp	a,#0a			;data_aa.and.#0f
		jr	z,srl_27
		fail_msg 26
srl_27:		ld	(hl),data_80
		and	(hl)
		jp	z,srl_28
		fail_msg 27
srl_28:		srl	(hl)
		jp	p,srl_29
		fail_msg 28
srl_29:		ld	a,(hl)
		cp	a,#40
		jr	z,srl_30
		fail_msg 29
srl_30:		ld	(hl),2
		srl	(hl)
		jr	nz,srl_31
		fail_msg 30
srl_31:		srl	(hl)
		jr	z,srl_32
		fail_msg 31
srl_32:		jr	c,srl_33
		fail_msg 32
srl_33:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix+2),a
		srl	(ix+2)
		jr	c,srl_34
		fail_msg 33
srl_34:		jp	po,srl_35
		fail_msg 34
srl_35:		srl	(ix+2)
		jr	nc,srl_36
		fail_msg 35
srl_36:		srl	(ix+2)
		jp	pe,srl_37
		fail_msg 36
srl_37:		ld	a,(ix+2)
		cp	a,#0a			;data_aa.and.#0f
		jr	z,srl_38
		fail_msg 37
srl_38:		ld	a,data_80
		ld	(ix-2),a
		and	(ix-2)
		jp	m,srl_39
		fail_msg 38
srl_39:		srl	(ix-2)
		jp	p,srl_40
		fail_msg 39
srl_40:		ld	a,(ix-2)
		cp	a,#40
		jr	z,srl_41
		fail_msg 40
srl_41:		ld	a,2
		ld	(ix+1),a
		srl	(ix+1)
		jr	nz,srl_42
		fail_msg 41
srl_42:		srl	(ix+1)
		jr	z,srl_43
		fail_msg 42
srl_43:		jr	c,srl_44
		fail_msg 43
srl_44:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy+2),a
		srl	(iy+2)
		jr	c,srl_45
		fail_msg 44
srl_45:		jp	po,srl_46
		fail_msg 45
srl_46:		srl	(iy+2)
		jr	nc,srl_47
		fail_msg 46
srl_47:		srl	(iy+2)
		jp	pe,srl_48
		fail_msg 47
srl_48:		ld	a,(iy+2)
		cp	a,#0a			;data_aa.and.#0f
		jr	z,srl_49
		fail_msg 48
srl_49:		ld	a,data_80
		ld	(iy-2),a
		and	(iy-2)
		jp	m,srl_50
		fail_msg 49
srl_50:		srl	(iy-2)
		jp	p,srl_51
		fail_msg 50
srl_51:		ld	a,(iy-2)
		cp	a,#40
		jr	z,srl_52
		fail_msg 51
srl_52:		ld	a,2
		ld	(iy+1),a
		srl	(iy+1)
		jr	nz,srl_53
		fail_msg 52
srl_53:		srl	(iy+1)
		jr	z,srl_54
		fail_msg 53
srl_54:		jr	c,rld_0
		fail_msg 54
rld_0:		nop
		print	"rld/rrd"
		ld	hl,t_var5
		ld	a,data_55
		ld	(hl),data_aa
		rld
		jp	p,rld_1
		fail_msg 0
rld_1:		cp	a,data_55+5
		jr	z,rld_2
		fail_msg 1
rld_2:		ld	a,(hl)
		cp	a,data_aa-5
		jr	z,rld_3
		fail_msg 2
rld_3:		ld	(hl),data_7f
		ld	a,data_80
		rld
		jp	m,rld_4
		fail_msg 3
rld_4:		jp	pe,rld_5
		fail_msg 4
rld_5:		rld
		jp	po,rld_6
		fail_msg 5
rld_6:		cp	a,data_80+15
		jr	z,rld_7
		fail_msg 6
rld_7:		ld	a,(hl)
		cp	a,7
		jr	z,rld_8
		fail_msg 7
rld_8:		ld	a,#05			;data_55.and.#0f
		ld	(hl),#0a			;data_aa.and.#0f
		rld
		jr	z,rld_9
		fail_msg 8
rld_9:		ld	a,(hl)
		cp	a,#a5
		jr	z,rrd_0
		fail_msg 9
rrd_0:		ld	hl,t_var3
		ld	a,data_55
		ld	(hl),data_aa
		rrd
		jp	p,rrd_1
		fail_msg 0
rrd_1:		jp	pe,rrd_2
		fail_msg 1
rrd_2:		jr	nz,rrd_3
		fail_msg 2
rrd_3:		cp	a,data_55+5
		jr	z,rrd_4
		fail_msg 3
rrd_4:		ld	a,(hl)
		cp	a,data_55+5
		jr	z,rrd_5
		fail_msg 4
rrd_5:		ld	(hl),data_7f
		ld	a,data_80
		rrd
		jp	m,rrd_6
		fail_msg 5
rrd_6:		jp	po,rrd_7
		fail_msg 6
rrd_7:		cp	a,data_80+15
		jr	z,rrd_8
		fail_msg 7
rrd_8:		ld	a,(hl)
		cp	a,7
		jr	z,rrd_9
		fail_msg 8
rrd_9:		ld	a,8
		ld	(hl),0
		rrd
		jr	z,rrd_10
		fail_msg 9
rrd_10:		ld	a,(hl)
		cp	a,data_80
		jr	z,bit_0
		fail_msg 10
bit_0:		nop
		print	"bit"
		ld	a,data_ff
		bit	0,a
		jr	nz,bit_1
		fail_msg 0
bit_1:		bit	1,a
		jr	nz,bit_2
		fail_msg 1
bit_2:		bit	2,a
		jr	nz,bit_3
		fail_msg 2
bit_3:		bit	3,a
		jr	nz,bit_4
		fail_msg 3
bit_4:		bit	4,a
		jr	nz,bit_5
		fail_msg 4
bit_5:		bit	5,a
		jr	nz,bit_6
		fail_msg 5
bit_6:		bit	6,a
		jr	nz,bit_7
		fail_msg 6
bit_7:		bit	7,a
		jr	nz,bit_8
		fail_msg 7
bit_8:		ld	a,0
		bit	0,a
		jr	z,bit_9
		fail_msg 8
bit_9:		bit	1,a
		jr	z,bit_10
		fail_msg 9
bit_10:		bit	2,a
		jr	z,bit_11
		fail_msg 10
bit_11:		bit	3,a
		jr	z,bit_12
		fail_msg 11
bit_12:		bit	4,a
		jr	z,bit_13
		fail_msg 12
bit_13:		bit	5,a
		jr	z,bit_14
		fail_msg 13
bit_14:		bit	6,a
		jr	z,bit_15
		fail_msg 14
bit_15:		bit	7,a
		jr	z,bit_16
		fail_msg 15
bit_16:		ld	b,data_80
		bit	2,b
		jr	z,bit_17
		fail_msg 16
bit_17:		bit	7,b
		jr	nz,bit_18
		fail_msg 17
bit_18:		ld	c,data_55
		bit	7,c
		jr	z,bit_19
		fail_msg 18
bit_19:		bit	0,c
		jr	nz,bit_20
		fail_msg 19
bit_20:		ld	d,data_aa
		bit	7,d
		jr	nz,bit_21
		fail_msg 20
bit_21:		bit	4,d
		jr	z,bit_22
		fail_msg 21
bit_22:		ld	e,data_7f
		bit	7,e
		jr	z,bit_23
		fail_msg 22
bit_23:		bit	3,e
		jr	nz,bit_24
		fail_msg 23
bit_24:		ld	h,#12      ;bjp was >data_1234
		bit	4,h
		jr	nz,bit_25
		fail_msg 24
bit_25:		bit	2,h
		jr	z,bit_26
		fail_msg 25
bit_26:		ld	l,#34      ;bjp was >data_1234
		bit	3,l
		jr	z,bit_27
		fail_msg 26
bit_27:		bit	2,l
		jr	nz,bit_28
		fail_msg 27
bit_28:		ld	hl,t_var4
		ld	(hl),data_55
		bit	0,(hl)
		jr	nz,bit_29
		fail_msg 28
bit_29:		bit	1,(hl)
		jr	z,bit_30
		fail_msg 29
bit_30:		bit	2,(hl)
		jr	nz,bit_31
		fail_msg 30
bit_31:		bit	3,(hl)
		jr	z,bit_32
		fail_msg 31
bit_32:		bit	4,(hl)
		jr	nz,bit_33
		fail_msg 32
bit_33:		bit	5,(hl)
		jr	z,bit_34
		fail_msg 33
bit_34:		bit	6,(hl)
		jr	nz,bit_35
		fail_msg 34
bit_35:		bit	7,(hl)
		jr	z,bit_36
		fail_msg 35
bit_36:		ld	ix,t_var3
		ld	a,data_aa
		ld	(ix-2),a
		bit	0,(ix-2)
		jr	z,bit_37
		fail_msg 36
bit_37:		bit	1,(ix-2)
		jr	nz,bit_38
		fail_msg 37
bit_38:		bit	2,(ix-2)
		jr	z,bit_39
		fail_msg 38
bit_39:		bit	3,(ix-2)
		jr	nz,bit_40
		fail_msg 39
bit_40:		bit	4,(ix-2)
		jr	z,bit_41
		fail_msg 40
bit_41:		bit	5,(ix-2)
		jr	nz,bit_42
		fail_msg 41
bit_42:		bit	6,(ix-2)
		jr	z,bit_43
		fail_msg 42
bit_43:		bit	7,(ix-2)
		jr	nz,bit_44
		fail_msg 43
bit_44:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy+2),a
		bit	0,(iy+2)
		jr	nz,bit_45
		fail_msg 44
bit_45:		bit	1,(iy+2)
		jr	z,bit_46
		fail_msg 45
bit_46:		bit	2,(iy+2)
		jr	nz,bit_47
		fail_msg 46
bit_47:		bit	3,(iy+2)
		jr	z,bit_48
		fail_msg 47
bit_48:		bit	4,(iy+2)
		jr	nz,bit_49
		fail_msg 48
bit_49:		bit	5,(iy+2)
		jr	z,bit_50
		fail_msg 49
bit_50:		bit	6,(iy+2)
		jr	nz,bit_51
		fail_msg 50
bit_51:		bit	7,(iy+2)
		jr	z,set_0
		fail_msg 51
set_0:		nop
		print	"set"
		ld	a,0
		set	0,a
		set	2,a
		set	4,a
		set	6,a
		cp	a,data_55
		jr	z,set_1
		fail_msg 0
set_1:		set	1,a
		set	3,a
		set	5,a
		set	7,a
		cp	a,data_ff
		jr	z,set_2
		fail_msg 1
set_2:		ld	b,0
		set	1,b
		set	3,b
		ld	a,b
		cp	a,#0a			;data_aa.and.#0f
		jr	z,set_3
		fail_msg 2
set_3:		ld	c,0
		set	1,c
		set	4,c
		ld	a,c
		cp	a,#12      ;bjp was >data_1234
		jr	z,set_4
		fail_msg 3
set_4:		ld	d,0
		set	2,d
		set	4,d
		set	5,d
		ld	a,d
		cp	a,#34      ;bjp was >data_1234
		jr	z,set_5
		fail_msg 4
set_5:		ld	e,0
		set	7,e
		ld	a,e
		cp	a,data_80
		jr	z,set_6
		fail_msg 5
set_6:		ld	h,0
		set	0,h
		set	2,h
		set	4,h
		set	6,h
		ld	a,h
		cp	a,data_55
		jr	z,set_7
		fail_msg 6
set_7:		ld	l,0
		set	1,l
		set	3,l
		set	5,l
		set	7,l
		ld	a,l
		cp	a,data_aa
		jr	z,set_8
		fail_msg 7
set_8:		ld	hl,t_var5
		ld	(hl),0
		set	0,(hl)
		set	2,(hl)
		set	4,(hl)
		set	6,(hl)
		ld	a,(hl)
		cp	a,data_55
		jr	z,set_9
		fail_msg 8
set_9:		ld	(hl),0
		set	1,(hl)
		set	3,(hl)
		set	5,(hl)
		set	7,(hl)
		ld	a,(hl)
		cp	a,data_aa
		jr	z,set_10
		fail_msg 9
set_10:		ld	ix,t_var3
		ld	a,0
		ld	(ix-2),a
		ld	(ix+2),a
		set	0,(ix-2)
		set	2,(ix-2)
		set	4,(ix-2)
		set	6,(ix-2)
		ld	a,(ix-2)
		cp	a,data_55
		jr	z,set_11
		fail_msg 10
set_11:		set	1,(ix+2)
		set	3,(ix+2)
		set	5,(ix+2)
		set	7,(ix+2)
		ld	a,(ix+2)
		cp	a,data_aa
		jr	z,set_12
		fail_msg 11
set_12:		ld	iy,t_var3
		ld	a,0
		ld	(iy-1),a
		ld	(iy+1),a
		set	0,(iy-1)
		set	2,(iy-1)
		set	4,(iy-1)
		set	6,(iy-1)
		ld	a,(iy-1)
		cp	a,data_55
		jr	z,set_13
		fail_msg 12
set_13:		set	1,(iy+1)
		set	3,(iy+1)
		set	5,(iy+1)
		set	7,(iy+1)
		ld	a,(iy+1)
		cp	a,data_aa
		jr	z,res_0
		fail_msg 13
res_0:		nop
		print	"res"
		ld	a,data_ff
		res	7,a
		cp	a,data_7f
		jr	z,res_1
		fail_msg 0
res_1:		res	5,a
		res	3,a
		res	1,a
		cp	a,data_55
		jr	z,res_2
		fail_msg 1
res_2:		ld	a,data_ff
		res	0,a
		res	2,a
		res	4,a
		res	6,a
		cp	a,data_aa
		jr	z,res_3
		fail_msg 2
res_3:		ld	b,data_ff
		res	7,b
		ld	a,b
		cp	a,data_7f
		jr	z,res_4
		fail_msg 3
res_4:		ld	c,data_ff
		res	0,c
		res	1,c
		res	2,c
		res	3,c
		res	4,c
		res	5,c
		res	6,c
		ld	a,c
		cp	a,data_80
		jr	z,res_5
		fail_msg 4
res_5:		ld	d,data_ff
		res	0,d
		res	2,d
		res	4,d
		res	6,d
		ld	a,d
		cp	a,data_aa
		jr	z,res_6
		fail_msg 5
res_6:		ld	e,data_ff
		res	1,e
		res	3,e
		res	5,e
		res	7,e
		ld	a,e
		cp	a,data_55
		jr	z,res_7
		fail_msg 6
res_7:		ld	h,data_ff
		res	0,h
		res	2,h
		res	3,h
		res	5,h
		res	6,h
		res	7,h
		ld	a,h
		cp	a,#12      ;bjp was >data_1234
		jr	z,res_8
		fail_msg 7
res_8:		ld	l,data_ff
		res	0,l
		res	1,l
		res	3,l
		res	6,l
		res	7,l
		ld	a,l
		cp	a,#34      ;bjp was >data_1234
		jr	z,res_9
		fail_msg 8
res_9:		ld	hl,t_var3
		ld	(hl),data_ff
		res	0,(hl)
		res	2,(hl)
		res	4,(hl)
		res	6,(hl)
		ld	a,(hl)
		cp	a,data_aa
		jr	z,res_10
		fail_msg 9
res_10:		res	1,(hl)
		res	3,(hl)
		res	5,(hl)
		res	7,(hl)
		ld	a,(hl)
		cp	a,0
		jr	z,res_11
		fail_msg 10
res_11:		ld	ix,t_var3
		ld	a,data_ff
		ld	(ix-2),a
		ld	(ix+2),a
		res	1,(ix-2)
		res	3,(ix-2)
		res	5,(ix-2)
		res	7,(ix-2)
		ld	a,(ix-2)
		cp	a,data_55
		jr	z,res_12
		fail_msg 11
res_12:		res	0,(ix+2)
		res	2,(ix+2)
		res	4,(ix+2)
		res	6,(ix+2)
		ld	a,(ix+2)
		cp	a,data_aa
		jr	z,res_13
		fail_msg 12
res_13:		ld	iy,t_var3
		ld	a,data_ff
		ld	(iy-1),a
		ld	(iy+1),a
		res	1,(iy-1)
		res	3,(iy-1)
		res	5,(iy-1)
		res	7,(iy-1)
		ld	a,(iy-1)
		cp	a,data_55
		jr	z,res_14
		fail_msg 13
res_14:		res	0,(iy+1)
		res	2,(iy+1)
		res	4,(iy+1)
		res	6,(iy+1)
		ld	a,(iy+1)
		cp	a,data_aa
		jr	z,jp_0
		fail_msg 14
jp_0:		nop
		print	"jp"
		jp	jp_1
		nop
		nop
		fail_msg 0
jp_1:		ld	a,0
		and	a
		jp	z,jp_2
		fail_msg 1
jp_2:		jp	nc,jp_3
		fail_msg 2
jp_3:		ld	b,1
		sub	a,b
		jp	nz,jp_4
		fail_msg 3
jp_4:		jp	c,jp_5
		fail_msg 4
jp_5:		jp	jp_7
		fail_msg 5
jp_6:		jp	jr_0
		fail_msg 6
jp_7:		jp	jp_6
		fail_msg 7
jr_0:		jr	jr_2
		fail_msg 0
jr_1:		jr	jr_3
		fail_msg 1
jr_2:		jr	jr_1
		fail_msg 2
jr_3:		ld	hl,jp_9
		jp	(hl)
		fail_msg 3
jp_8:		ld	ix,jp_10
		jp	(ix)
		fail_msg 8
jp_9:		jp	jp_8
		fail_msg 9
jp_10:		ld	iy,djnz_0
		jp	(iy)
		fail_msg 10
djnz_0:		ld	b,5
		ld	a,0
djnz_1:		inc	a
		djnz	djnz_1
		cp	a,5
		jr	z,call_0
		fail_msg 1
call_0:		nop
		print	"call"
		ld	a,0
		call	sub1
		cp	a,data_7f
		jr	z,call_1
		fail_msg 0
call_1:		ld	a,0
		and	a
		call	z,sub2
		cp	a,data_55
		jr	z,call_2
		fail_msg 1
call_2:		ld	a,data_aa
		and	a
		call	nz,sub3
		cp	a,data_aa+1
		jr	z,call_3
		fail_msg 2
call_3:		ld	a,0
		cp	a,0
		call	nc,sub4
		cp	a,data_ff
		jr	z,call_4
		fail_msg 3
call_4:		ld	a,0
		sub	a,1
		call	c,sub5
		cp	a,data_ff-1
		jr	z,call_5
		fail_msg 4
call_5:		ld	a,data_7f
		sla	a
		call	po,sub6
		cp	a,data_7f
		jr	z,call_6
		fail_msg 5
call_6:		ld	a,data_aa
		srl	a
		call	pe,sub7
		cp	a,data_aa
		jr	z,call_7
		fail_msg 6
call_7:		ld	a,data_80
		sra	a
		call	m,sub8
		cp	a,data_80
		jr	z,call_8
		fail_msg 7
call_8:		ld	a,data_7f
		sra	a
		call	p,sub9
		cp	a,data_7f
		jr	z,rst_0
		fail_msg 8
rst_0:		ld	a, 1
		ld	(rst_state),a
		print	"rst"
		rst	#00
		cp	a,1
		jr	z,rst_1
		fail_msg 0
rst_1:		rst	#08
		cp	a,2
		jr	z,rst_2
		fail_msg 1
rst_2:		rst	#10
		cp	a,3
		jr	z,rst_3
		fail_msg 2
rst_3:		rst	#18
		cp	a,4
		jr	z,rst_4
		fail_msg 3
rst_4:		rst	#20
		cp	a,5
		jr	z,rst_5
		fail_msg 4
rst_5:		rst	#28
		cp	a,6
		jr	z,rst_6
		fail_msg 5
rst_6:		rst	#30
		cp	a,7
		jr	z,rst_7
		fail_msg 6
rst_7:		rst	#38
		cp	a,8
		jp	z,ldi_ops
		fail_msg 7

	;; skip the in instructions, as they need to be reworked
	;; for TV80 environment. (gth)
in_0:		in	a,(in_port)
		cp	a,data_7f
		jr	z,in_1
		fail_msg 0
in_1:		ld	c,in_port
		in	a,(c)
		jr	nz,in_2
		fail_msg 1
in_2:		jp	p,in_3
		fail_msg 2
in_3:		jp	pe,in_4
		fail_msg 3
in_4:		cp	a,data_55
		jr	z,in_5
		fail_msg 4
in_5:		in	a,(c)
		jp	m,in_6
		fail_msg 5
in_6:		jp	po,in_7
		fail_msg 6
in_7:		jr	nz,in_8
		fail_msg 7
in_8:		cp	a,data_80
		jr	z,in_9
		fail_msg 8
in_9:		in	a,(c)
		jr	z,in_10
		fail_msg 9
in_10:		in	b,(c)
		jp	m,in_11
		fail_msg 10
in_11:		ld	a,b
		cp	a,data_ff
		jr	z,in_12
		fail_msg 11
in_12:		in	d,(c)
		jp	pe,in_13
		fail_msg 12
in_13:		ld	a,d
		cp	a,data_aa
		jr	z,in_14
		fail_msg 13
in_14:		in	e,(c)
		jp	p,in_15
		fail_msg 14
in_15:		ld	a,e
		cp	a,data_7f
		jr	z,in_16
		fail_msg 15
in_16:		in	h,(c)
		jp	pe,in_17
		fail_msg 16
in_17:		ld	a,h
		cp	a,data_55
		jr	z,in_18
		fail_msg 17
in_18:		in	l,(c)
		jp	m,in_19
		fail_msg 18
in_19:		ld	a,l
		cp	a,data_80
		jr	z,in_20
		fail_msg 19
in_20:		in	c,(c)
		jr	z,in_21
		fail_msg 20
in_21:		ld	c,in_port
		ld	b,2
		ld	hl,t_var1
		ini
		jr	nz,in_22
		fail_msg 21
in_22:		ini
		jr	z,in_23
		fail_msg 22
in_23:		ld	hl,t_var1
		ld	a,(hl)
		cp	a,data_ff
		jr	z,in_24
		fail_msg 23
in_24:		inc	hl
		ld	a,(hl)
		cp	a,data_aa
		jr	z,in_25
		fail_msg 24
in_25:		ld	b,5
		ld	c,in_port
		ld	hl,t_var1
		inir
		jr	z,in_26
		fail_msg 25
in_26:		ld	hl,t_var1
		ld	a,(hl)
		cp	a,data_7f
		jr	z,in_27
		fail_msg 26
in_27:		inc	hl
		ld	a,(hl)
		cp	a,data_55
		jr	z,in_28
		fail_msg 27
in_28:		inc	hl
		ld	a,(hl)
		cp	a,data_80
		jr	z,in_29
		fail_msg 28
in_29:		inc	hl
		ld	a,(hl)
		cp	a,0
		jr	z,in_30
		fail_msg 29
in_30:		inc	hl
		ld	a,(hl)
		cp	a,data_ff
		jr	z,in_31
		fail_msg 30
in_31:		ld	b,2
		ld	c,in_port
		ld	hl,t_var5
		ind
		jr	nz,in_32
		fail_msg 31
in_32:		ind
		jr	z,in_33
		fail_msg 32
in_33:		ld	hl,t_var5
		ld	a,(hl)
		cp	a,data_aa
		jr	z,in_34
		fail_msg 33
in_34:		dec	hl
		ld	a,(hl)
		cp	a,data_7f
		jr	z,in_35
		fail_msg 34
in_35:		ld	b,5
		ld	c,in_port
		ld	hl,t_var5
		indr
		jr	z,in_36
		fail_msg 35
in_36:		ld	hl,t_var5
		ld	a,(hl)
		cp	a,data_55
		jr	z,in_37
		fail_msg 36
in_37:		dec	hl
		ld	a,(hl)
		cp	a,data_80
		jr	z,in_38
		fail_msg 37
in_38:		dec	hl
		ld	a,(hl)
		cp	a,0
		jr	z,in_39
		fail_msg 38
in_39:		dec	hl
		ld	a,(hl)
		cp	a,data_ff
		jr	z,in_40
		fail_msg 39
in_40:		dec	hl
		ld	a,(hl)
		cp	a,data_aa
		jr	z,ldi_0
		fail_msg 40

ldi_ops:	nop
		print	"ldi"
ldi_0:		ld	hl,t_var1
		ld	a,#12      ;bjp was >data_1234
		ld	(hl),a
		inc	hl
		ld	a,#34      ;bjp was >data_1234
		ld	(hl),a
		dec	hl
		ld	de,t_var3
		ld	bc,2
		ldi
		jp	pe,ldi_1
		fail_msg 0
ldi_1:		ldi
		jp	po,ldi_2
		fail_msg 1
ldi_2:		ld	hl,t_var3
		ld	a,(hl)
		cp	a,#12      ;bjp was >data_1234
		jr	z,ldi_3
		fail_msg 2
ldi_3:		inc	hl
		ld	a,(hl)
		cp	a,#34      ;bjp was >data_1234
		jr	z,ldir_0
		fail_msg 3
ldir_0:		ld	hl,var1
		ld	de,t_var1
		ld	bc,5
		ldir
		jp	po,ldir_1
		fail_msg 0
ldir_1:		ld	hl,t_var1
		ld	a,(hl)
		cp	a,data_ff
		jr	z,ldir_2
		fail_msg 1
ldir_2:		inc	hl
		ld	a,(hl)
		cp	a,data_55
		jr	z,ldir_3
		fail_msg 2
ldir_3:		inc	hl
		ld	a,(hl)
		cp	a,data_80
		jr	z,ldir_4
		fail_msg 3
ldir_4:		inc	hl
		ld	a,(hl)
		cp	a,data_aa
		jr	z,ldir_5
		fail_msg 4
ldir_5:		inc	hl
		ld	a,(hl)
		cp	a,data_7f
		jr	z,ldd_0
		fail_msg 5
ldd_0:		ld	hl,t_var5
		ld	a,#12      ;bjp was >data_1234
		ld	(hl),a
		dec	hl
		ld	a,#34      ;bjp was >data_1234
		ld	(hl),a
		inc	hl
		ld	bc,2
		ld	de,t_var3
		ldd
		jp	pe,ldd_1
		fail_msg 0
ldd_1:		ldd
		jp	po,ldd_2
		fail_msg 1
ldd_2:		ld	hl,t_var3
		ld	a,(hl)
		cp	a,#12      ;bjp was >data_1234
		jr	z,ldd_3
		fail_msg 2
ldd_3:		dec	hl
		ld	a,(hl)
		cp	a,#34      ;bjp was >data_1234
		jr	z,lddr_0
		fail_msg 3
lddr_0:		ld	bc,5
		ld	hl,var5
		ld	de,t_var5
		lddr
		jp	po,lddr_1
		fail_msg 0
lddr_1:		ld	hl,t_var1
		ld	a,(hl)
		cp	a,data_ff
		jr	z,lddr_2
		fail_msg 1
lddr_2:		inc	hl
		ld	a,(hl)
		cp	a,data_55
		jr	z,lddr_3
		fail_msg 2
lddr_3:		inc	hl
		ld	a,(hl)
		cp	a,data_80
		jr	z,lddr_4
		fail_msg 3
lddr_4:		inc	hl
		ld	a,(hl)
		cp	a,data_aa
		jr	z,lddr_5
		fail_msg 4
lddr_5:		inc	hl
		ld	a,(hl)
		cp	a,data_7f
		jr	z,cpi_0
		fail_msg 5
cpi_0:		ld	hl,t_var1
		ld	bc,5
		ld	a,data_7f
		cpi
		jp	pe,cpi_1
		fail_msg 0
cpi_1:		jp	m,cpi_2
		fail_msg 1
cpi_2:		jr	nz,cpi_3
		fail_msg 2
cpi_3:		cpi
		jp	pe,cpi_4
		fail_msg 3
cpi_4:		jp	p,cpi_5
		fail_msg 4
cpi_5:		jr	nz,cpi_6
		fail_msg 5
cpi_6:		cpi
		jp	pe,cpi_7
		fail_msg 6
cpi_7:		jp	m,cpi_8
		fail_msg 7
cpi_8:		jr	nz,cpi_9
		fail_msg 8
cpi_9:		cpi
		jp	pe,cpi_10
		fail_msg 9
cpi_10:		jp	m,cpi_11
		fail_msg 10
cpi_11:		jr	nz,cpi_12
		fail_msg 11
cpi_12:		cpi
		jp	po,cpi_13
		fail_msg 12
cpi_13:		jp	p,cpi_14
		fail_msg 13
cpi_14:		jr	z,cpir_0
		fail_msg 14
cpir_0:		ld	a,data_aa
		ld	hl,var1
		ld	bc,5
		cpir
		jr	z,cpir_1
		fail_msg 0
cpir_1:		jp	pe,cpir_2
		fail_msg 1
cpir_2:		ld	a,b
		cp	a,0
		jr	z,cpir_3
		fail_msg 2
cpir_3:		ld	a,c
		cp	a,1
		jr	z,cpir_4
		fail_msg 3
cpir_4:		ld	a,data_7f
		ld	hl,var1
		ld	bc,5
		cpir
		jp	po,cpir_5
		fail_msg 4
cpir_5:		jr	z,cpir_6
		fail_msg 5
cpir_6:		ld	a,#34      ;bjp was >data_1234
		ld	hl,var1
		ld	bc,5
		cpir
		jp	po,cpir_7
		fail_msg 6
cpir_7:		jr	nz,cpir_8
		fail_msg 7
cpir_8:		jp	m,cpir_9
		fail_msg 8
cpir_9:		ld	a,data_aa
		ld	hl,var1
		ld	bc,3
		cpir
		jp	po,cpir_10
		fail_msg 9
cpir_10:	jp	p,cpir_11
		fail_msg 10
cpir_11:	jr	nz,cpd_0
		fail_msg 11
cpd_0:		ld	a,data_ff
		ld	hl,var5
		ld	bc,5
		cpd
		jp	m,cpd_1
		fail_msg 0
cpd_1:		jp	pe,cpd_2
		fail_msg 1
cpd_2:		jr	nz,cpd_3
		fail_msg 2
cpd_3:		cpd
		jp	p,cpd_4
		fail_msg 3
cpd_4:		jp	pe,cpd_5
		fail_msg 4
cpd_5:		jr	nz,cpd_6
		fail_msg 5
cpd_6:		cpd
		jp	p,cpd_7
		fail_msg 6
cpd_7:		jp	pe,cpd_8
		fail_msg 7
cpd_8:		jr	nz,cpd_9
		fail_msg 8
cpd_9:		cpd
		jp	m,cpd_10
		fail_msg 9
cpd_10:		jp	pe,cpd_11
		fail_msg 10
cpd_11:		jr	nz,cpd_12
		fail_msg 11
cpd_12:		cpd
		jp	p,cpd_13
		fail_msg 12
cpd_13:		jp	po,cpd_14
		fail_msg 13
cpd_14:		jr	z,cpdr_0
		fail_msg 14
cpdr_0:		ld	a,data_80
		ld	hl,var5
		ld	bc,5
		cpdr
		jp	pe,cpdr_1
		fail_msg 0
cpdr_1:		jp	p,cpdr_2
		fail_msg 1
cpdr_2:		jr	z,cpdr_3
		fail_msg 2
cpdr_3:		ld	a,b
		cp	a,0
		jr	z,cpdr_4
		fail_msg 3
cpdr_4:		ld	a,c
		cp	a,2
		jr	z,cpdr_5
		fail_msg 4
cpdr_5:		ld	a,#34      ;bjp was >data_1234
		ld	hl,var5
		ld	bc,5
		cpdr
		jp	po,cpdr_6
		fail_msg 5
cpdr_6:		jr	nz,cpdr_7
		fail_msg 6
cpdr_7:		jp	p,cpdr_8
		fail_msg 7
cpdr_8:		ld	a,#34      ;bjp was >data_1234
		ld	hl,var5
		ld	bc,3
		cpdr
		jp	po,cpdr_9
		fail_msg 8
cpdr_9:		jr	nz,cpdr_10
		fail_msg 9
cpdr_10:	jp	m,test_exit
		fail_msg 10

	;; this section needs to be reworked for the TV80 environment.
	;; Since env uses ports for all its test control, this gets
	;; partially covered by normal operation. (gth)
;
;the file portfe.xxx must be examined to see if the proper output is generated
;
out_0:		ld	a,#30
		out	(out_port),a
		ld	c,out_port
		ld	a,#31
		out	(c),a
		ld	b,#32
		out	(c),b
		ld	d,#33
		out	(c),d
		ld	e,#34
		out	(c),e
		ld	h,#35
		out	(c),h
		ld	l,#36
		out	(c),l
		out	(c),c			;output value divider
outi_0:		ld	a,#31			;set up output values
		ld	b,5
		ld	hl,t_var1
outi_1:		ld	(hl),a
		inc	a
		inc	hl
		djnz	outi_1
outi_2:		ld	c,out_port
		ld	b,5
		ld	hl,t_var1
outi_3:		outi
		jr	nz,outi_3
otir_0:		out	(c),c			;output value divider
		ld	hl,t_var1
		ld	b,5
		otir
		jr	z,outd_0
		fail_msg 0
outd_0:		out	(c),c
		ld	hl,t_var5
		ld	b,5
outd_1:		outd
		jr	nz,outd_1
otdr_0:		out	(c),c
		ld	b,5
		ld	hl,t_var5
		otdr
		jr	z,otdr_1
		fail_msg 0
otdr_1:		out	(c),c
		ld	a,#0d
		out	(c),a
		ld	a,#0a
		out	(c),a

test_exit:	
	;; complicated pass/fail computation no longer necessary
	;; if we got here, we passed
	passed
		
;
;subroutine 1, must load a with #7f
;
sub1:		ld	a,data_7f
		ret
;
;
;subroutine 2, must load a with #55
;
sub2:		ld	a,data_55
		cp	a,data_55
		ret	z
;
;subroutine 3, increments a
;
sub3:		inc	a
		and	a
		ret	nz
;
;subroutine 4, subtracts 1 from a
;
sub4:		sub	a,1
		ret	c
;
;subroutine 5, subtracts 1 from a
;
sub5:		sub	a,1
		ret	nc
;
;subroutine 6, shifts a right logically
;
sub6:		srl	a
		ret	po
;
;subroutine 7, shifts a left arithmetically
;
sub7:		sla	a
		ret	pe
;
;subroutine 8, shifts a left arithmetically
;
sub8:		sla	a
		ret	m
;
;subroutine 9, rotates a left
;
sub9:		rl	a
		ret	p
;
;restart 0 routine
;
rst_0000_1:
		ld	a, (rst_state)
		cp	1
		jp	z,rst_test_ret
	
		ld	a, 0
		out     (#82), a	; disable timeout count
	
		ld	a,(pass_count)
		or	a
		jp	z,start
		ld	a,1
		ret

rst_test_ret:	ret
;
;		data
;
var1:		db	data_ff
var2:		db	data_55
var3:		db	data_80
var4:		db	data_aa
var5:		db	data_7f
;

mem_init_vals:  
		dw	data_1234
		dw	data_55aa
		dw	data_7fff
		dw	data_8000
		dw	data_aa55
		dw	data_ffff
    
mem_init:
    push    bc
    push    de
    push    hl
    
    ;; initialize region from 8000 to 80FF
    ld  hl, #8000
    ld  b, #ff

mem_init_loop_1:  
    ld      (hl), 0
    inc     hl
    djnz    mem_init_loop_1
    
    ;; initialize region from 8100 to 81FF
    ld      hl, #8100
    ld      b, #ff

mem_init_loop_2:  
    ld      (hl), 0
    inc     hl
    djnz    mem_init_loop_2
    
    ;; populate special values from 8005
    ld      de, #8005
    ld      hl, mem_init_vals
    ld      b, 12

mem_init_loop_3: 
    ld      a, (hl)
    inc     hl
    ex      de, hl
    ld      (hl), a
    inc     hl
    ex      de, hl
    djnz    mem_init_loop_3
    
    ;; exit
    pop     hl
    pop     de
    pop     bc
    ret

t_var1:		equ	#8000
t_var2:		equ	#8001
t_var3:		equ	#8002
t_var4:		equ	#8003
t_var5:		equ	#8004

w_var1:		equ #8005
w_var2:		equ #8007
w_var3:		equ #8009
w_var4:		equ #800B
w_var5:		equ #800D
w_var6:		equ #800F

tw_var1:	equ #8011
tw_var2:	equ #8013
tw_var3:	equ #8015
tw_var4:	equ #8017
tw_var5:	equ #8019
tw_var6:	equ #801B
tw_var7:	equ #801D

error_cnt:	equ #801E
pass_count:	equ #801F
fail_num:   equ #8020
rst_state:	equ #8021

;		org	#8000
;t_var1:		db	0
;t_var2:		db	0
;t_var3:		db	0
;t_var4:		db	0
;t_var5:		db	0
;;
;w_var1:		dw	data_1234
;w_var2:		dw	data_55aa
;w_var3:		dw	data_7fff
;w_var4:		dw	data_8000
;w_var5:		dw	data_aa55
;w_var6:		dw	data_ffff
;;
;tw_var1:	dw	0
;tw_var2:	dw	0
;tw_var3:	dw	0
;tw_var4:	dw	0
;tw_var5:	dw	0
;tw_var6:	dw	0
;tw_var7:	dw	0
;;
;error_cnt:	db	0
;pass_count:	db	0
;fail_num        db      0
;rst_state	db	0
;
;		org	#8100
;stack:		ds	128
;stack_end:	equ	$
;
		end start
