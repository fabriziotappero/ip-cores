; bjp   modified to assemble on as80 assembler (needs different syntax).
; minor mods to account for changes in interrupt structure  and I/O
; all such are flagged with my initials..... 
;
; The origional code used operators <   and  >  on symbols to extract the 
; lower and higher bytes respectively.   It appears that as80 has no equivalent.
; I have hand coded such ---- hopefully correctly.   
; This is only a significant issue with such constructs as <stack_end.   
; My solution forces the stack to remain in its present location.   
;
; WARNING   If you must move the stack  --   check comments and fix code for my kludges
;
; Origional Code also had a pretty strange "passed" macro.  Removed it and 
; output a more useful message.	along with the bist controls
;
;z80 simulator test routine
;total error count is left in a at end of test routine
;

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

in_port:	equ	#20
out_port:	equ	#20
bist_adr:       equ     #ffff   ;last memory address for bist controll register
bist_ack:       equ	#01
bist_err:	equ	#02
bist_ei:        equ     #04     ;interrupt enable register for bist 
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
cr:             equ     #0d
lf:             equ     #0a
bell:           equ     #07
;
;inc_error_cnt	macro	     ;bjp   change for initial test to halt on error
;		ld	hl,error_cnt
;		inc	(hl)
;		endm
inc_error_cnt	macro
		halt
		endm

;
;passed		macro
;		push	bc
;		ld 	bc,(pass)
;		ld	(message_addr),bc
;		ld 	bc,(pass+2)
;		ld	(message_addr+2),bc
;		ld 	bc,(pass+4)
;		ld	(message_addr+4),bc
;		pop	bc
;		endm
;
;failed		macro
;		push	bc
;		ld 	bc,(fail)
;		ld	(message_addr),bc
;		ld 	bc,(fail+2)
;		ld	(message_addr+2),bc
;		ld 	bc,(fail+4)
;		ld	(message_addr+4),bc
;		pop	bc
;		endm
;
;

start:		xor	a
		ld	(pass_count),a
		ld	hl,error_cnt
		ld	(hl),a			;clear error count
nop_1:		nop
		nop

ld_167:		ld	a,data_55
		cp	data_55
		jr	z,ld_1
		inc_error_cnt
ld_1:		ld	b,data_7f
		ld	a,data_7f
		cp	b
		jr	z,ld_2
		inc_error_cnt
ld_2:		ld	c,data_80
		ld	a,data_80
		cp	c
		jr	z,ld_3
		inc_error_cnt
ld_3:		ld	d,data_aa
		ld	a,data_aa
		cp	d
		jr	z,ld_4
		inc_error_cnt
ld_4:		ld	e,data_55
		ld	a,data_55
		cp	e
		jr	z,ld_5
		inc_error_cnt
ld_5:		ld	h,data_7f
		ld	a,data_7f
		cp	h
		jr	z,ld_6
		inc_error_cnt
ld_6:		ld	l,data_80
		ld	a,data_80
		cp	l
		jr	z,ld_7
		inc_error_cnt
ld_7:		ld	a,data_55
		ld	b,a
		cp	b
		jr	z,ld_8
		inc_error_cnt
ld_8:		ld	c,b
		cp	c
		jr	z,ld_9
		inc_error_cnt
ld_9:		ld	d,c
		cp	d
		jr	z,ld_10
		inc_error_cnt
ld_10:		ld	e,d
		cp	e
		jr	z,ld_11
		inc_error_cnt
ld_11:		ld	h,e
		cp	h
		jr	z,ld_12
		inc_error_cnt
ld_12:		ld	l,h
		cp	l
		jr	z,ld_13
		inc_error_cnt
ld_13:		ld	l,data_80
		ld	a,l
		cp	l
		jr	z,ld_14
		inc_error_cnt
ld_14:		ld	h,l
		cp	h
		jr	z,ld_15
		inc_error_cnt
ld_15:		ld	e,h
		cp	e
		jr	z,ld_16
		inc_error_cnt
ld_16:		ld	d,e
		cp	d
		jr	z,ld_17
		inc_error_cnt
ld_17:		ld	c,d
		cp	c
		jr	z,ld_18
		inc_error_cnt
ld_18:		ld	b,c
		cp	b
		jr	z,ld_19
		inc_error_cnt
ld_19:		ld	hl,var1
		ld	a,(hl)
		cp	data_ff
		jr	z,ld_20
		inc_error_cnt
ld_20:		ld	hl,var2
		ld	a,data_55
		ld	b,(hl)
		cp	b
		jr	z,ld_21
		inc_error_cnt
ld_21:		ld	hl,var1
		ld	c,(hl)
		ld	a,(hl)
		cp	c
		jr	z,ld_22
		inc_error_cnt
ld_22:		ld	hl,var2
		ld	d,(hl)
		ld	a,(hl)
		cp	d
		jr	z,ld_23
		inc_error_cnt
ld_23:		ld	hl,var1
		ld	e,(hl)
		ld	a,(hl)
		cp	e
		jr	z,ld_24
		inc_error_cnt
ld_24:		ld	hl,var2
		ld	a,(hl)
		ld	h,(hl)
		cp	h
		jr	z,ld_25
		inc_error_cnt
ld_25:		ld	hl,var1
		ld	a,(hl)
		ld	l,(hl)
		cp	l
		jr	z,ld_26
		inc_error_cnt
ld_26:		ld	ix,var3
		ld	a,(ix-2)
		cp	data_ff
		jr	z,ld_27
		inc_error_cnt
ld_27:		ld	a,(ix+2)
		cp	data_7f
		jr	z,ld_28
		inc_error_cnt
ld_28:		ld	a,(ix-1)
		ld	b,(ix-1)
		cp	b
		jr	z,ld_29
		inc_error_cnt
ld_29:		cp	data_55
		jr	z,ld_30
		inc_error_cnt
ld_30:		ld	a,(ix+1)
		ld	c,(ix+1)
		cp	c
		jr	z,ld_31
		inc_error_cnt
ld_31:		cp	data_aa
		jr	z,ld_32
		inc_error_cnt
ld_32:		ld	d,(ix-2)
		ld	a,(ix-2)
		cp	d
		jr	z,ld_33
		inc_error_cnt
ld_33:		cp	data_ff
		jr	z,ld_34
		inc_error_cnt
ld_34:		ld	e,(ix+2)
		ld	a,(ix+2)
		cp	e
		jr	z,ld_35
		inc_error_cnt
ld_35:		cp	data_7f
		jr	z,ld_36
		inc_error_cnt
ld_36:		ld	h,(ix+0)
		ld	a,(ix+0)
		cp	h
		jr	z,ld_37
		inc_error_cnt
ld_37:		cp	data_80
		jr	z,ld_38
		inc_error_cnt
ld_38:		ld	l,(ix-1)
		ld	a,(ix-1)
		cp	l
		jr	z,ld_39
		inc_error_cnt
ld_39:		cp	data_55
		jr	z,ld_40
		inc_error_cnt
ld_40:		ld	iy,var3
		ld	a,(iy-2)
		cp	data_ff
		jr	z,ld_41
		inc_error_cnt
ld_41:		ld	a,(iy+2)
		cp	data_7f
		jr	z,ld_42
		inc_error_cnt
ld_42:		ld	b,(iy-1)
		ld	a,(iy-1)
		cp	b
		jr	z,ld_43
		inc_error_cnt
ld_43:		cp	data_55
		jr	z,ld_44
		inc_error_cnt
ld_44:		ld	c,(iy+1)
		ld	a,(iy+1)
		cp	c
		jr	z,ld_45
		inc_error_cnt
ld_45:		cp	data_aa
		jr	z,ld_46
		inc_error_cnt
ld_46:		ld	d,(iy-2)
		ld	a,(iy-2)
		cp	d
		jr	z,ld_47
		inc_error_cnt
ld_47:		cp	data_ff
		jr	z,ld_48
		inc_error_cnt
ld_48:		ld	e,(iy+2)
		ld	a,(iy+2)
		cp	e
		jr	z,ld_49
		inc_error_cnt
ld_49:		cp	data_7f
		jr	z,ld_50
		inc_error_cnt
ld_50:		ld	h,(iy+0)
		ld	a,(iy+0)
		cp	h
		jr	z,ld_51
		inc_error_cnt
ld_51:		cp	data_80
		jr	z,ld_52
		inc_error_cnt
ld_52:		ld	l,(iy-2)
		ld	a,(iy-2)
		cp	l
		jr	z,ld_53
		inc_error_cnt
ld_53:		cp	data_ff
		jr	z,ld_54
		inc_error_cnt
ld_54:		ld	hl,t_var1
		ld	a,data_aa+1
		ld	(hl),a
		ld	b,(hl)
		cp	b
		jr	z,ld_55
		inc_error_cnt
ld_55:		cp	data_aa+1
		jr	z,ld_56
		inc_error_cnt
ld_56:		ld	b,data_80+1
		ld	(hl),b
		ld	a,(hl)
		cp	b
		jr	z,ld_57
		inc_error_cnt
ld_57:		cp	data_80+1
		jr	z,ld_58
		inc_error_cnt
ld_58:		ld	c,data_55-1
		ld	(hl),c
		ld	a,(hl)
		cp	c
		jr	z,ld_59
		inc_error_cnt
ld_59:		cp	data_55-1
		jr	z,ld_60
		inc_error_cnt
ld_60:		ld	d,data_ff-1
		ld	(hl),d
		ld	a,(hl)
		cp	d
		jr	z,ld_61
		inc_error_cnt
ld_61:		cp	data_ff-1
		jr	z,ld_62
		inc_error_cnt
ld_62:		ld	e,data_55+1
		ld	(hl),e
		ld	a,(hl)
		cp	e
		jr	z,ld_63
		inc_error_cnt
ld_63:		cp	data_55+1
		jr	z,ld_64
		inc_error_cnt
ld_64:		ld	(hl),h
		ld	a,(hl)
		cp	h
		jr	z,ld_65
		inc_error_cnt
ld_65:		cp	#70		;bjp  guess  >t_var1
		jr	z,ld_66
		inc_error_cnt
ld_66:		ld	(hl),l
		ld	a,(hl)
		cp	l
		jr	z,ld_67
		inc_error_cnt
ld_67:		cp	a, #00		;bjp  guess <t_var1
		jr	z,ld_68
		inc_error_cnt
ld_68:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		ld	a,0
		ld	a,(ix-2)
		cp	data_55
		jr	z,ld_69
		inc_error_cnt
ld_69:		ld	a,data_80
		ld	(ix+2),a
		ld	a,0
		ld	a,(ix+2)
		cp	data_80
		jr	z,ld_70
		inc_error_cnt
ld_70:		ld	b,data_7f
		ld	(ix-1),b
		ld	a,(ix-1)
		cp	b
		jr	z,ld_71
		inc_error_cnt
ld_71:		cp	data_7f
		jr	z,ld_72
		inc_error_cnt
ld_72:		ld	c,data_aa
		ld	(ix+1),c
		ld	a,(ix+1)
		cp	c
		jr	z,ld_73
		inc_error_cnt
ld_73:		cp	data_aa
		jr	z,ld_74
		inc_error_cnt
ld_74:		ld	d,data_80
		ld	(ix+0),d
		ld	a,(ix+0)
		cp	d
		jr	z,ld_75
		inc_error_cnt
ld_75:		cp	data_80
		jr	z,ld_76
		inc_error_cnt
ld_76:		ld	e,data_55+2
		ld	(ix-2),e
		ld	a,(ix-2)
		cp	e
		jr	z,ld_77
		inc_error_cnt
ld_77:		cp	data_55+2
		jr	z,ld_78
		inc_error_cnt
ld_78:		ld	h,data_aa-2
		ld	(ix+2),h
		ld	a,(ix+2)
		cp	h
		jr	z,ld_79
		inc_error_cnt
ld_79:		cp	data_aa-2
		jr	z,ld_80
		inc_error_cnt
ld_80:		ld	l,data_aa+2
		ld	(ix-1),l
		ld	a,(ix-1)
		cp	l
		jr	z,ld_81
		inc_error_cnt
ld_81:		cp	data_aa+2
		jr	z,ld_82
		inc_error_cnt
ld_82:		ld	iy,t_var3
		ld	a,data_ff
		ld	(iy-2),a
		ld	a,0
		ld	a,(iy-2)
		cp	data_ff
		jr	z,ld_83
		inc_error_cnt
ld_83:		ld	a,data_7f
		ld	(iy+2),a
		ld	a,0
		ld	a,(iy+2)
		cp	data_7f
		jr	z,ld_84
		inc_error_cnt
ld_84:		ld	b,data_55
		ld	(iy-1),b
		ld	a,(iy-1)
		cp	b
		jr	z,ld_85
		inc_error_cnt
ld_85:		cp	data_55
		jr	z,ld_86
		inc_error_cnt
ld_86:		ld	c,data_aa
		ld	(iy+1),c
		ld	a,(iy+1)
		cp	c
		jr	z,ld_87
		inc_error_cnt
ld_87:		cp	data_aa
		jr	z,ld_88
		inc_error_cnt
ld_88:		ld	d,data_80
		ld	(iy+0),d
		ld	a,(iy+0)
		cp	d
		jr	z,ld_89
		inc_error_cnt
ld_89:		cp	data_80
		jr	z,ld_90
		inc_error_cnt
ld_90:		ld	e,data_ff-2
		ld	(iy-2),e
		ld	a,(iy-2)
		cp	e
		jr	z,ld_91
		inc_error_cnt
ld_91:		cp	data_ff-2
		jr	z,ld_92
		inc_error_cnt
ld_92:		ld	h,data_7f-3
		ld	(iy+2),h
		ld	a,(iy+2)
		cp	h
		jr	z,ld_93
		inc_error_cnt
ld_93:		cp	data_7f-3
		jr	z,ld_94
		inc_error_cnt
ld_94:		ld	l,data_55-5
		ld	(iy-1),l
		ld	a,(iy-1)
		cp	l
		jr	z,ld_95
		inc_error_cnt
ld_95:		cp	data_55-5
		jr	z,ld_96
		inc_error_cnt
ld_96:		ld	hl,t_var1
		ld	(hl),data_80+10
		ld	a,(hl)
		cp	data_80+10
		jr	z,ld_97
		inc_error_cnt
ld_97:		ld	ix,t_var3
		ld	(ix-2),data_55-10
		ld	a,(ix-2)
		cp	data_55-10
		jr	z,ld_98
		inc_error_cnt
ld_98:		ld	(ix+2),data_55+10
		ld	a,(ix+2)
		cp	data_55+10
		jr	z,ld_99
		inc_error_cnt
ld_99:		ld	iy,t_var2
		ld	(iy-1),data_80+17
		ld	a,(iy-1)
		cp	data_80+17
		jr	z,ld_100
		inc_error_cnt
ld_100:		ld	(iy+1),data_80-17
		ld	a,(iy+1)
		cp	data_80-17
		jr	z,ld_101
		inc_error_cnt
ld_101:		ld	hl,t_var5
		ld	bc,t_var5
		ld	(hl),data_aa-10
		ld	a,(bc)
		cp	data_aa-10
		jr	z,ld_102
		inc_error_cnt
ld_102:		ld	hl,t_var3
		ld	de,t_var3
		ld	(hl),data_aa+10
		ld	a,(de)
		cp	data_aa+10
		jr	z,ld_103
		inc_error_cnt
ld_103:		ld	hl,t_var2
		ld	(hl),data_7f-25
		ld	a,(t_var2)
		cp	data_7f-25
		jr	z,ld_104
		inc_error_cnt
ld_104:		ld	hl,t_var4
		ld	bc,t_var4
		ld	a,data_55-20
		ld	(bc),a
		ld	b,(hl)
		cp	b
		jr	z,ld_105
		inc_error_cnt
ld_105:		ld	a,b
		cp	data_55-20
		jr	z,ld_106
		inc_error_cnt
ld_106:		ld	hl,t_var5
		ld	de,t_var5
		ld	a,data_55+20
		ld	(de),a
		ld	c,(hl)
		cp	c
		jr	z,ld_107
		inc_error_cnt
ld_107:		ld	a,c
		cp	data_55+20
		jr	z,ld_108
		inc_error_cnt
ld_108:		ld	hl,t_var4
		ld	a,data_ff-24
		ld	(t_var4),a
		ld	e,(hl)
		cp	e
		jr	z,ld_109
		inc_error_cnt
ld_109:		ld	a,e
		cp	data_ff-24
		jr	z,ld_110
		inc_error_cnt
ld_110:		ld	a,data_55
		ld	i,a
		ld	a,0
		ld	a,i
		jr	nz,ld_111
		inc_error_cnt
ld_111:		jp	p,ld_112
		inc_error_cnt
ld_112:		cp	data_55
		jr	z,ld_113
		inc_error_cnt
ld_113:		ld	a,data_80
		ld	i,a
		ld	a,0
		ld	a,i
		jr	nz,ld_114
		inc_error_cnt
ld_114:		jp	m,ld_115
		inc_error_cnt
ld_115:		cp	data_80
		jr	z,ld_116
		inc_error_cnt
ld_116:		ld	a,0
		ld	i,a
		ld	a,data_55
		ld	a,i
		jr	z,ld_125
		inc_error_cnt
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
		inc_error_cnt
ld_126:		ld	a, #34			;bjp  guess  <data_1234
		cp	c
		jr	z,ld_127
		inc_error_cnt
ld_127:		ld	de,data_55aa
		ld	a,data_55
		cp	d
		jr	z,ld_128
		inc_error_cnt
ld_128:		ld	a,data_aa
		cp	e
		jr	z,ld_129
		inc_error_cnt
ld_129:		ld	hl,data_7fff
		ld	a,data_7f
		cp	h
		jr	z,ld_130
		inc_error_cnt
ld_130:		ld	a,data_ff
		cp	l
		jr	z,ld_131
		inc_error_cnt
ld_131:		ld	sp,data_aa55
		ld	hl,0
		add	hl,sp
		ld	a,data_aa
		cp	h
		jr	z,ld_132
		inc_error_cnt
ld_132:		ld	a,data_55
		cp	l
		jr	z,ld_133
		inc_error_cnt
ld_133:		ld	ix,data_ffff
		ld	hl,0
		ld	sp,ix
		add	hl,sp
		ld	a,data_ff
		cp	h
		jr	z,ld_134
		inc_error_cnt
ld_134:		cp	l
		jr	z,ld_135
		inc_error_cnt
ld_135:		ld	iy,data_1234
		ld	hl,0
		ld	sp,iy
		add	hl,sp
		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ld_136
		inc_error_cnt
ld_136:		ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,ld_137
		inc_error_cnt
ld_137:		ld	hl,(w_var2)
		ld	a,data_55
		cp	h
		jr	z,ld_138
		inc_error_cnt
ld_138:		ld	a,data_aa
		cp	l
		jr	z,ld_139
		inc_error_cnt
ld_139:		ld	bc,(w_var1)
		ld	a,#12      ;bjp was >data_1234
		cp	b
		jr	z,ld_140
		inc_error_cnt
ld_140:		ld	a,#34      ;bjp was >data_1234
		cp	c
		jr	z,ld_141
		inc_error_cnt
ld_141:		ld	de,(w_var3)
		ld	a,data_7f
		cp	d
		jr	z,ld_142
		inc_error_cnt
ld_142:		ld	a,data_ff
		cp	e
		jr	z,ld_143
		inc_error_cnt
ld_143:		ld	hl,(w_var4)
		ld	a,data_80
		cp	h
		jr	z,ld_144
		inc_error_cnt
ld_144:		ld	a,0
		cp	l
		jr	z,ld_145
		inc_error_cnt
ld_145:		ld	sp,(w_var5)
		ld	hl,0
		add	hl,sp
		ld	a,data_aa
		cp	h
		jr	z,ld_146
		inc_error_cnt
ld_146:		ld	a,data_55
		cp	l
		jr	z,ld_147
		inc_error_cnt
ld_147:		ld	ix,(w_var6)
		ld	hl,0
		ld	sp,ix
		add	hl,sp
		ld	a,data_ff
		cp	h
		jr	z,ld_148
		inc_error_cnt
ld_148:		cp	l
		jr	z,ld_149
		inc_error_cnt
ld_149:		ld	iy,(w_var1)
		ld	hl,0
		ld	sp,iy
		add	hl,sp
		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ld_150
		inc_error_cnt
ld_150:		ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,ld_151
		inc_error_cnt
ld_151:		ld	hl,data_1234
		ld	(tw_var1),hl
		ld	bc,(tw_var1)
		ld	a,#12      ;bjp was >data_1234
		cp	b
		jr	z,ld_152
		inc_error_cnt
ld_152:		ld	a,#34      ;bjp was >data_1234
		cp	c
		jr	z,ld_153
		inc_error_cnt
ld_153:		ld	bc,data_55aa
		ld	(tw_var2),bc
		ld	hl,(tw_var2)
		ld	a,data_55
		cp	h
		jr	z,ld_154
		inc_error_cnt
ld_154:		ld	a,data_aa
		cp	l
		jr	z,ld_155
		inc_error_cnt
ld_155:		ld	de,data_7fff
		ld	(tw_var3),de
		ld	hl,(tw_var3)
		ld	a,data_7f
		cp	h
		jr	z,ld_156
		inc_error_cnt
ld_156:		ld	a,data_ff
		cp	l
		jr	z,ld_157
		inc_error_cnt
ld_157:		ld	hl,data_8000
		ld	(tw_var4),hl
		ld	bc,(tw_var4)
		ld	a,data_80
		cp	b
		jr	z,ld_158
		inc_error_cnt
ld_158:		ld	a,0
		cp	c
		jr	z,ld_159
		inc_error_cnt
ld_159:		ld	sp,data_aa55
		ld	(tw_var5),sp
		ld	hl,(tw_var5)
		ld	a,data_aa
		cp	h
		jr	z,ld_160
		inc_error_cnt
ld_160:		ld	a,data_55
		cp	l
		jr	z,ld_161
		inc_error_cnt
ld_161:		ld	ix,data_ffff
		ld	(tw_var6),ix
		ld	hl,(tw_var6)
		ld	a,data_ff
		cp	h
		jr	z,ld_162
		inc_error_cnt
ld_162:		cp	l
		jr	z,ld_163
		inc_error_cnt
ld_163:		ld	iy,data_1234
		ld	(tw_var7),iy
		ld	hl,(tw_var7)
		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ld_164
		inc_error_cnt
ld_164:		ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,ld_165
		inc_error_cnt
ld_165:		ld	hl,data_55aa
		ld	sp,hl
		ld	hl,0
		add	hl,sp
		ld	a,data_55
		cp	h
		jr	z,ld_166
		inc_error_cnt
ld_166:		ld	a,data_aa
		cp	l
		jr	z,push_0
		inc_error_cnt
push_0:		ld	sp,stack_end
		ld	bc,data_1234
		push	bc
		ld	bc,0
		pop	bc
		ld	a,#12      ;bjp was >data_1234
		cp	b
		jr	z,push_1
		inc_error_cnt
push_1:		ld	a,#34      ;bjp was >data_1234
		cp	c
		jr	z,push_2
		inc_error_cnt
push_2:		ld	de,data_55aa
		push	de
		ld	de,0
		pop	de
		ld	a,data_55
		cp	d
		jr	z,push_3
		inc_error_cnt
push_3:		ld	a,data_aa
		cp	e
		jr	z,push_4
		inc_error_cnt
push_4:		ld	hl,data_7fff
		push	hl
		ld	hl,0
		pop	hl
		ld	a,data_7f
		cp	h
		jr	z,push_5
		inc_error_cnt
push_5:		ld	a,data_ff
		cp	l
		jr	z,push_6
		inc_error_cnt
push_6:		ld	a,data_80
		push	af			;f depends on previous compare
		ld	hl,0
		pop	hl
		cp	h
		jr	z,push_7
		inc_error_cnt
push_7:		ld	a,l
		cp	#42
		jr	z,push_8
push_8:		ld	h,data_55
		ld	l,data_80+#41
		ld	a,0
		push	hl
		pop	af
		jp	m,push_9
		inc_error_cnt
push_9:		jr	z,push_10
		inc_error_cnt
push_10:	jr	c,push_11
		inc_error_cnt
push_11:	cp	data_55
		jr	z,push_12
		inc_error_cnt
push_12:	ld	ix,data_aa55
		ld	bc,0
		push	ix
		pop	bc
		ld	a,data_aa
		cp	b
		jr	z,push_13
		inc_error_cnt
push_13:	ld	a,data_55
		cp	c
		jr	z,push_14
		inc_error_cnt
push_14:	ld	iy,data_7fff
		ld	de,0
		push	iy
		pop	de
		ld	a,data_7f
		cp	d
		jr	z,push_15
		inc_error_cnt
push_15:	ld	a,data_ff
		cp	e
		jr	z,push_16
		inc_error_cnt
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
		inc_error_cnt
push_17:	ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,push_18
		inc_error_cnt
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
		inc_error_cnt
push_19:	ld	a,data_aa
		cp	l
		jr	z,push_20
		inc_error_cnt
push_20:	ld	sp,stack_end
ex_0:		ld	de,data_1234
		ld	hl,data_55aa   ; 10/2/2007 was ffff  need to check all bytes (missed a bug)
		ex	de,hl
		ld	a,data_55
		cp	d
		jr	z,ex_1
		inc_error_cnt
ex_1:		ld	a,data_aa
		cp	e
		jr	z,ex_2
		inc_error_cnt
ex_2:		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ex_3
		inc_error_cnt
ex_3:		ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,ex_4
		inc_error_cnt
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
		inc_error_cnt
ex_5:		ex	af,af'
		jp	m,ex_6
		inc_error_cnt
ex_6:		jr	z,ex_7
		inc_error_cnt
ex_7:		cp	data_7f
		jr	z,ex_8
		inc_error_cnt
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
		inc_error_cnt
ex_9:		cp	l
		jr	z,ex_10
		inc_error_cnt
ex_10:		cp	d
		jr	z,ex_11
		inc_error_cnt
ex_11:		cp	e
		jr	z,ex_12
		inc_error_cnt
ex_12:		cp	b
		jr	z,ex_13
		inc_error_cnt
ex_13:		cp	c
		jr	z,ex_14
		inc_error_cnt
ex_14:		exx
		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ex_15
		inc_error_cnt
ex_15:		ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,ex_16
		inc_error_cnt
ex_16:		ld	a,data_aa
		cp	d
		jr	z,ex_17
		inc_error_cnt
ex_17:		ld	a,data_55
		cp	e
		jr	z,ex_18
		inc_error_cnt
ex_18:		ld	a,data_7f
		cp	b
		jr	z,ex_19
		inc_error_cnt
ex_19:		ld	a,data_ff
		cp	c
		jr	z,ex_20
		inc_error_cnt
ex_20:		ld	bc,data_55aa
		ld	hl,data_7fff
		push	bc
		ex	(sp),hl
		pop	bc
		ld	a,data_7f
		cp	b
		jr	z,ex_21
		inc_error_cnt
ex_21:		ld	a,data_ff
		cp	c
		jr	z,ex_22
		inc_error_cnt
ex_22:		ld	a,data_55
		cp	h
		jr	z,ex_23
		inc_error_cnt
ex_23:		ld	a,data_aa
		cp	l
		jr	z,ex_24
		inc_error_cnt
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
		inc_error_cnt
ex_25:		ld	a,0
		cp	c
		jr	z,ex_26
		inc_error_cnt
ex_26:		ld	a,data_ff
		cp	h
		jr	z,ex_27
		inc_error_cnt
ex_27:		cp	l
		jr	z,ex_28
		inc_error_cnt
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
		inc_error_cnt
ex_29:		ld	a,data_ff
		cp	c
		jr	z,ex_30
		inc_error_cnt
ex_30:		ld	a,#12      ;bjp was >data_1234
		cp	h
		jr	z,ex_31
		inc_error_cnt
ex_31:		ld	a,#34      ;bjp was >data_1234
		cp	l
		jr	z,add_0
		inc_error_cnt
add_0:		ld	a,0
		ld	b,data_7f
		add	a,b
		cp	data_7f
		jr	z,add_1
		inc_error_cnt
add_1:		ld	a,0
		ld	b,0
		add	a,b
		jr	z,add_2
		inc_error_cnt
add_2:		ld	b,data_55
		add	a,b
		jr	nz,add_3
		inc_error_cnt
add_3:		cp	data_55
		jr	z,add_4
		inc_error_cnt
add_4:		ld	a,data_ff
		ld	b,1
		add	a,b
		jr	c,add_5
		inc_error_cnt
add_5:		add	a,b
		jr	nc,add_6
		inc_error_cnt
add_6:		ld	a,data_ff
		ld	b,0
		add	a,b
		jp	m,add_7
		inc_error_cnt
add_7:		ld	b,1
		add	a,b
		jp	p,add_8
		inc_error_cnt
add_8:		ld	a,data_7f
		ld	b,1
		add	a,b
		jp	pe,add_9
		inc_error_cnt
add_9:		add	a,b
		jp	po,add_10
		inc_error_cnt
add_10:		ld	a,data_55
		ld	c,2
		add	a,c
		cp	data_55+2
		jr	z,add_11
		inc_error_cnt
add_11:		ld	a,data_80
		add	a,c
		cp	data_80+2
		jr	z,add_12
		inc_error_cnt
add_12:		ld	a,data_aa
		ld	d,data_55
		add	a,d
		cp	data_aa+data_55
		jr	z,add_13
		inc_error_cnt
add_13:		ld	a,data_aa
		ld	e,2
		add	a,e
		cp	data_aa+2
		jr	z,add_14
		inc_error_cnt
add_14:		ld	a,data_55
		ld	h,24
		add	a,h
		cp	data_55+24
		jr	z,add_15
		inc_error_cnt
add_15:		ld	a,data_7f-10
		ld	l,10
		add	a,l
		cp	data_7f
		jr	z,add_16
		inc_error_cnt
add_16:		ld	a,1
		add	a,data_7f
		jp	pe,add_17
		inc_error_cnt
add_17:		jp	m,add_18
		inc_error_cnt
add_18:		jr	nz,add_19
		inc_error_cnt
add_19:		cp	data_80
		jr	z,add_20
		inc_error_cnt
add_20:		ld	a,data_55
		add	a,1
		jp	po,add_21
		inc_error_cnt
add_21:		jp	p,add_22
		inc_error_cnt
add_22:		jr	nc,add_23
		inc_error_cnt
add_23:		cp	data_55+1
		jr	z,add_24
		inc_error_cnt
add_24:		ld	a,data_ff
		add	a,1
		jr	c,add_25
		inc_error_cnt
add_25:		jr	z,add_26
		inc_error_cnt
add_26:		add	a,1
		jr	nc,add_27
		inc_error_cnt
add_27:		jr	nz,add_28
		inc_error_cnt
add_28:		cp	1
		jr	z,add_29
		inc_error_cnt
add_29:		ld	hl,var2
		ld	a,2
		add	a,(hl)
		jp	po,add_30
		inc_error_cnt
add_30:		jp	p,add_31
		inc_error_cnt
add_31:		jr	nz,add_32
		inc_error_cnt
add_32:		jr	nc,add_33
		inc_error_cnt
add_33:		cp	data_55+2
		jr	z,add_34
		inc_error_cnt
add_34:		ld	hl,var1
		ld	a,1
		add	a,(hl)
		jr	c,add_35
		inc_error_cnt
add_35:		jr	z,add_36
		inc_error_cnt
add_36:		ld	hl,var5
		ld	a,1
		add	a,(hl)
		jp	m,add_37
		inc_error_cnt
add_37:		jp	pe,add_38
		inc_error_cnt
add_38:		cp	data_80
		jr	z,add_39
		inc_error_cnt
add_39:		ld	ix,var3
		ld	a,1
		add	a,(ix-1)
		jp	po,add_40
		inc_error_cnt
add_40:		jp	p,add_41
		inc_error_cnt
add_41:		jr	nz,add_42
		inc_error_cnt
add_42:		jr	nc,add_43
		inc_error_cnt
add_43:		cp	data_55+1
		jr	z,add_44
		inc_error_cnt
add_44:		ld	a,1
		add	a,(ix+2)
		jp	pe,add_45
		inc_error_cnt
add_45:		jp	m,add_46
		inc_error_cnt
add_46:		cp	data_80
		jr	z,add_47
		inc_error_cnt
add_47:		ld	a,1
		add	a,(ix-2)
		jr	c,add_48
		inc_error_cnt
add_48:		jr	z,add_49
		inc_error_cnt
add_49:		add	a,1
		jr	nc,add_50
		inc_error_cnt
add_50:		jr	nz,add_51
		inc_error_cnt
add_51:		cp	1
		jr	z,add_52
		inc_error_cnt
add_52:		ld	iy,var3
		ld	a,10
		add	a,(iy-1)
		jp	po,add_53
		inc_error_cnt
add_53:		jp	p,add_54
		inc_error_cnt
add_54:		jr	nz,add_55
		inc_error_cnt
add_55:		jr	nc,add_56
		inc_error_cnt
add_56:		cp	data_55+10
		jr	z,add_57
		inc_error_cnt
add_57:		ld	a,1
		add	a,(iy+2)
		jp	pe,add_58
		inc_error_cnt
add_58:		jp	m,add_59
		inc_error_cnt
add_59:		add	a,1
		jp	po,add_60
		inc_error_cnt
add_60: 	cp	data_80+1
		jr	z,add_61
		inc_error_cnt
add_61:		ld	a,1
		add	a,(iy-2)
		jr	z,add_62
		inc_error_cnt
add_62:		jr	c,add_63
		inc_error_cnt
add_63:		add	a,1
		jr	nc,add_64
		inc_error_cnt
add_64:		jr	nz,add_65
		inc_error_cnt
add_65:		cp	1
		jr	z,add_66
		inc_error_cnt
add_66:		ld	a,data_ff
		add	a,data_80
		jp	p,add_67
		inc_error_cnt
add_67:		jp	pe,add_68
		inc_error_cnt
add_68:		jr	c,add_69
		inc_error_cnt
add_69:		add	a,1
		jp	pe,add_70
		inc_error_cnt
add_70:		jp	m,add_71
		inc_error_cnt
add_71:		jr	nc,add_72
		inc_error_cnt
add_72:		add	a,1
		jp	po,add_73
		inc_error_cnt
add_73:		cp	data_80+1
		jr	z,adc_0
		inc_error_cnt
adc_0:		ld	a,0                 ;clear cry 
		add	a,0
		ld	b,data_7f
		adc	a,b                  ;a=7f cry=0
		jp	p,adc_1
		inc_error_cnt
adc_1:		jp	po,adc_2
		inc_error_cnt
adc_2:		jr	nc,adc_3
		inc_error_cnt
adc_3:		jr	nz,adc_4
		inc_error_cnt
adc_4:		ld	b,1
		adc	a,b                     ;a=80 cry=0  
		jp	pe,adc_5                ;jp  ofl
		inc_error_cnt
adc_5:		jp	m,adc_6
		inc_error_cnt
adc_6:		cp	data_80
		jr	z,adc_7                 ;z=0  ofl=0 cry=0 (borrow)
		inc_error_cnt
adc_7:		ld	a,data_ff
		ld	b,1
		adc	a,b                      ;ff+1+0
		jr	c,adc_8
		inc_error_cnt
adc_8:		jr	z,adc_9
		inc_error_cnt
adc_9:		adc	a,b
		jr	nc,adc_10
		inc_error_cnt
adc_10:		jr	nz,adc_11
		inc_error_cnt
adc_11:		cp	2
		jr	z,adc_12
		inc_error_cnt
adc_12:		ld	a,data_ff
		ld	c,0
		adc	a,c
		jp	m,adc_13
		inc_error_cnt
adc_13:		jr	nc,adc_14
		inc_error_cnt
adc_14:		ld	c,2
		adc	a,c
		jp	p,adc_15
		inc_error_cnt
adc_15:		jr	c,adc_16
		inc_error_cnt
adc_16:		ld	c,0
		adc	a,c
		cp	2
		jr	z,adc_17
		inc_error_cnt
adc_17:		ld	a,data_ff
		ld	d,1
		adc	a,d
		jr	c,adc_18
		inc_error_cnt
adc_18:		ld	d,0
		adc	a,d
		jr	nc,adc_19
		inc_error_cnt
adc_19:		cp	1
		jr	z,adc_20
		inc_error_cnt
adc_20:		ld	a,data_aa
		ld	e,data_7f
		adc	a,e
		jr	c,adc_21
		inc_error_cnt
adc_21:		ld	e,#2b
		adc	a,e
		cp	data_55
		jr	z,adc_22
		inc_error_cnt
adc_22:		ld	a,data_ff
		ld	h,1
		adc	a,h
		jr	c,adc_23
		inc_error_cnt
adc_23:		adc	a,h
		cp	2
		jr	z,adc_24
		inc_error_cnt
adc_24:		ld	a,data_ff
		ld	l,1
		adc	a,l
		jr	c,adc_25
		inc_error_cnt
adc_25:		adc	a,l
		cp	2
		jr	z,adc_26
		inc_error_cnt
adc_26:		ld	a,0
		adc	a,data_7f
		jp	po,adc_27
		inc_error_cnt
adc_27:		jp	p,adc_28
		inc_error_cnt
adc_28:		jr	nc,adc_29
		inc_error_cnt
adc_29:		jr	nz,adc_30
		inc_error_cnt
adc_30:		adc	a,1
		jp	pe,adc_31
		inc_error_cnt
adc_31:		jp	m,adc_32
		inc_error_cnt
adc_32:		cp	data_80
		jr	z,adc_33
		inc_error_cnt
adc_33:		ld	a,data_ff
		adc	a,1
		jr	c,adc_34
		inc_error_cnt
adc_34:		jr	z,adc_35
		inc_error_cnt
adc_35:		adc	a,1
		jr	nc,adc_36
		inc_error_cnt
adc_36:		jr	nz,adc_37
		inc_error_cnt
adc_37:		cp	2
		jr	z,adc_38
		inc_error_cnt
adc_38:		ld	hl,var5
		ld	a,0
		adc	a,(hl)
		jp	p,adc_39
		inc_error_cnt
adc_39:		jp	po,adc_40
		inc_error_cnt
adc_40:		jr	nz,adc_41
		inc_error_cnt
adc_41:		jr	nc,adc_42
		inc_error_cnt
adc_42:		ld	a,1
		adc	a,(hl)
		jp	m,adc_43
		inc_error_cnt
adc_43:		jp	pe,adc_44
		inc_error_cnt
adc_44:		cp	data_80
		jr	z,adc_45
		inc_error_cnt
adc_45:		ld	hl,var1
		ld	a,1
		adc	a,(hl)
		jr	z,adc_46
		inc_error_cnt
adc_46:		jr	c,adc_47
		inc_error_cnt
adc_47:		ld	hl,var2
		adc	a,(hl)
		jr	nc,adc_48
		inc_error_cnt
adc_48:		jr	nz,adc_49
		inc_error_cnt
adc_49:		cp	data_55+1
		jr	z,adc_50
		inc_error_cnt
adc_50:		ld	ix,var3
		ld	a,0
		adc	a,(ix+2)
		jp	p,adc_51
		inc_error_cnt
adc_51:		jp	po,adc_52
		inc_error_cnt
adc_52:		jr	nc,adc_53
		inc_error_cnt
adc_53:		jr	nz,adc_54
		inc_error_cnt
adc_54:		ld	a,1
		adc	a,(ix+2)
		jp	m,adc_55
		inc_error_cnt
adc_55:		jp	pe,adc_56
		inc_error_cnt
adc_56:		cp	data_80
		jr	z,adc_57
		inc_error_cnt
adc_57:		ld	a,1
		adc	a,(ix-2)
		jr	c,adc_58
		inc_error_cnt
adc_58:		jr	z,adc_59
		inc_error_cnt
adc_59:		adc	a,(ix-1)
		jr	nc,adc_60
		inc_error_cnt
adc_60:		jr	nz,adc_61
		inc_error_cnt
adc_61:		cp	data_55+1
		jr	z,adc_62
		inc_error_cnt
adc_62:		ld	iy,var3
		ld	a,0
		adc	a,(ix+2)
		jp	p,adc_63
		inc_error_cnt
adc_63:		jp	po,adc_64
		inc_error_cnt
adc_64:		jr	nc,adc_65
		inc_error_cnt
adc_65:		jr	nz,adc_66
		inc_error_cnt
adc_66:		ld	a,1
		adc	a,(iy+2)
		jp	m,adc_67
		inc_error_cnt
adc_67:		jp	pe,adc_68
		inc_error_cnt
adc_68:		cp	data_80
		jr	z,adc_69
		inc_error_cnt
adc_69:		ld	a,1
		adc	a,(iy-2)
		jr	c,adc_70
		inc_error_cnt
adc_70:		jr	z,adc_71
		inc_error_cnt
adc_71:		adc	a,(iy-1)
		jr	nc,adc_72
		inc_error_cnt
adc_72:		jr	nz,adc_73
		inc_error_cnt
adc_73:		cp	data_55+1
		jr	z,adc_74
		inc_error_cnt
adc_74:		ld	a,data_ff
		add	a,0
		adc	a,data_80
		jp	p,adc_75
		inc_error_cnt
adc_75:		jp	pe,adc_76
		inc_error_cnt
adc_76:		jr	nz,adc_77
		inc_error_cnt
adc_77:		adc	a,0
		jp	m,adc_78
		inc_error_cnt
adc_78:		jp	pe,adc_79
		inc_error_cnt
adc_79:		adc	a,1
		jp	po,adc_80
		inc_error_cnt
adc_80:		cp	data_80+1
		jr	z,sub_0
		inc_error_cnt
sub_0:		ld	a,0
		ld	b,1
		sub	a,b
		jp	m,sub_1
		inc_error_cnt
sub_1:		jp	po,sub_2
		inc_error_cnt
sub_2:		jr	c,sub_3
		inc_error_cnt
sub_3:		jr	nz,sub_4
		inc_error_cnt
sub_4:		sub	a,b
		jr	nc,sub_5
		inc_error_cnt
sub_5:		cp	data_ff-1
		jr	z,sub_6
		inc_error_cnt
sub_6:		ld	a,1
		ld	b,0
		sub	a,b
		jr	nz,sub_7
		inc_error_cnt
sub_7:		jp	p,sub_8
		inc_error_cnt
sub_8:		ld	b,1
		sub	a,b
		jr	z,sub_9
		inc_error_cnt
sub_9:		sub	a,b
		jp	m,sub_10
		inc_error_cnt
sub_10:		cp	data_ff
		jr	z,sub_11
		inc_error_cnt
sub_11:		ld	a,data_80
		ld	b,data_7f
		sub	a,b
		jp	pe,sub_12
		inc_error_cnt
sub_12:		sub	a,b
		jp	po,sub_13
		inc_error_cnt
sub_13:		cp	data_80+2
		jr	z,sub_14
		inc_error_cnt
sub_14:		ld	a,data_55
		ld	c,data_55
		sub	a,c
		jr	z,sub_15
		inc_error_cnt
sub_15:		ld	c,1
		sub	a,c
		jp	m,sub_16
		inc_error_cnt
sub_16:		jr	c,sub_17
		inc_error_cnt
sub_17:		cp	data_ff
		jr	z,sub_18
		inc_error_cnt
sub_18:		ld	a,data_55
		ld	d,data_7f
		sub	a,d
		jr	c,sub_19
		inc_error_cnt
sub_19:		cp	data_55-data_7f
		jr	z,sub_20
		inc_error_cnt
sub_20:		ld	a,0
		ld	e,data_ff
		sub	a,e
		jr	c,sub_21
		inc_error_cnt
sub_21:		cp	1
		jr	z,sub_22
		inc_error_cnt
sub_22:		ld	a,data_ff
		ld	h,data_80
		sub	a,h
		jp	p,sub_23
		inc_error_cnt
sub_23:		cp	data_7f
		jr	z,sub_24
		inc_error_cnt
sub_24:		ld	a,data_aa
		ld	l,data_ff
		sub	a,l
		jr	c,sub_25
		inc_error_cnt
sub_25:		cp	data_aa+1
		jr	z,sub_26
		inc_error_cnt
sub_26:		ld	a,data_7f
		sub	a,data_ff
		jp	pe,sub_27
		inc_error_cnt
sub_27:		jp	m,sub_28
		inc_error_cnt
sub_28:		sub	a,1
		jp	p,sub_29
		inc_error_cnt
sub_29:		sub	a,1
		jp	po,sub_30
		inc_error_cnt
sub_30:		jr	nz,sub_31
		inc_error_cnt
sub_31:		sub	a,data_7f-1
		jr	z,sub_32
		inc_error_cnt
sub_32:		ld	a,0
		sub	a,data_ff
		jr	c,sub_33
		inc_error_cnt
sub_33:		sub	a,1
		jr	z,sub_34
		inc_error_cnt
sub_34:		jr	nc,sub_35
		inc_error_cnt
sub_35:		ld	hl,var1
		ld	a,data_7f
		sub	a,(hl)
		jp	m,sub_36
		inc_error_cnt
sub_36:		jp	pe,sub_37
		inc_error_cnt
sub_37:		jr	c,sub_38
		inc_error_cnt
sub_38:		ld	hl,var3
		sub	a,(hl)
		jp	p,sub_39
		inc_error_cnt
sub_39:		jp	po,sub_40
		inc_error_cnt
sub_40:		jr	nc,sub_41
		inc_error_cnt
sub_41		jr	z,sub_42
		inc_error_cnt
sub_42:		ld	hl,var2
		sub	a,(hl)
		jr	nz,sub_43
		inc_error_cnt
sub_43:		cp	data_aa+1
		jr	z,sub_44
		inc_error_cnt
sub_44:		ld	ix,var3
		ld	a,data_7f
		sub	a,(ix-2)
		jp	m,sub_45
		inc_error_cnt
sub_45:		jp	pe,sub_46
		inc_error_cnt
sub_46:		jr	c,sub_47
		inc_error_cnt
sub_47:		sub	a,(ix+0)
		jp	p,sub_48
		inc_error_cnt
sub_48:		jp	po,sub_49
		inc_error_cnt
sub_49:		jr	nc,sub_50
		inc_error_cnt
sub_50:		jr	z,sub_51
		inc_error_cnt
sub_51:		sub	a,(ix+2)
		jr	nz,sub_52
		inc_error_cnt
sub_52:		cp	data_80+1
		jr	z,sub_53
		inc_error_cnt
sub_53:		ld	iy,var3
		ld	a,data_7f
		sub	a,(iy-2)
		jp	m,sub_54
		inc_error_cnt
sub_54:		jp	pe,sub_55
		inc_error_cnt
sub_55:		jr	c,sub_56
		inc_error_cnt
sub_56:		jr	nz,sub_57
		inc_error_cnt
sub_57:		sub	a,(iy+0)
		jp	p,sub_58
		inc_error_cnt
sub_58:		jp	po,sub_59
		inc_error_cnt
sub_59:		jr	nc,sub_60
		inc_error_cnt
sub_60:		jr	z,sub_61
		inc_error_cnt
sub_61:		sub	a,(iy+2)
		jr	nz,sub_62
		inc_error_cnt
sub_62:		cp	data_80+1
		jr	z,sbc_0
		inc_error_cnt
sbc_0:		ld	a,data_7f
		ld	b,0
		sub	a,b			;clear carry flag
		ld	b,data_ff
		sbc	a,b
		jp	m,sbc_1
		inc_error_cnt
sbc_1:		jp	pe,sbc_2
		inc_error_cnt
sbc_2:		jr	c,sbc_3
		inc_error_cnt
sbc_3:		jr	nz,sbc_4
		inc_error_cnt
sbc_4:		ld	b,data_7f
		sbc	a,b
		jp	p,sbc_5
		inc_error_cnt
sbc_5:		jp	pe,sbc_6
		inc_error_cnt
sbc_6:		jr	nc,sbc_7
		inc_error_cnt
sbc_7:		jr	z,sbc_8
		inc_error_cnt
sbc_8:		ld	b,data_ff
		sbc	a,b
		jp	po,sbc_9
		inc_error_cnt
sbc_9:		jr	nz,sbc_10
		inc_error_cnt
sbc_10:		ld	b,0
		sbc	a,b
		jr	z,sbc_11
		inc_error_cnt
sbc_11:		ld	a,data_aa
		ld	c,data_ff
		sbc	a,c
		jr	c,sbc_12
		inc_error_cnt
sbc_12:		ld	c,0
		sbc	a,c
		jr	nc,sbc_13
		inc_error_cnt
sbc_13:		cp	data_aa
		jr	z,sbc_14
		inc_error_cnt
sbc_14:		ld	a,data_55
		ld	d,data_ff
		sbc	a,d
		jr	c,sbc_15
		inc_error_cnt
sbc_15:		ld	d,0
		sbc	a,d
		jr	nc,sbc_16
		inc_error_cnt
sbc_16:		cp	data_55
		jr	z,sbc_17
		inc_error_cnt
sbc_17:		ld	a,data_aa
		ld	e,data_ff
		sbc	a,e
		jr	c,sbc_18
		inc_error_cnt
sbc_18:		ld	e,0
		sbc	a,e
		jr	nc,sbc_19
		inc_error_cnt
sbc_19:		cp	data_aa
		jr	z,sbc_20
		inc_error_cnt
sbc_20:		ld	a,data_55
		ld	h,data_ff
		sbc	a,h
		jr	c,sbc_21
		inc_error_cnt
sbc_21:		ld	h,0
		sbc	a,h
		jr	nc,sbc_22
		inc_error_cnt
sbc_22:		cp	data_55
		jr	z,sbc_23
		inc_error_cnt
sbc_23:		ld	a,data_aa
		ld	l,data_ff
		sbc	a,l
		jr	c,sbc_24
		inc_error_cnt
sbc_24:		ld	l,0
		sbc	a,l
		jr	nc,sbc_25
		inc_error_cnt
sbc_25:		cp	data_aa
		jr	z,sbc_26
		inc_error_cnt
sbc_26:		ld	a,data_7f
		sbc	a,data_ff
		jp	m,sbc_27
		inc_error_cnt
sbc_27:		jp	pe,sbc_28
		inc_error_cnt
sbc_28:		jr	c,sbc_29
		inc_error_cnt
sbc_29:		jr	nz,sbc_30
		inc_error_cnt
sbc_30:		sbc	a,data_7f
		jp	p,sbc_31
		inc_error_cnt
sbc_31:		jp	pe,sbc_32
		inc_error_cnt
sbc_32:		jr	nc,sbc_33
		inc_error_cnt
sbc_33:		jr	z,sbc_34
		inc_error_cnt
sbc_34:		sbc	a,data_ff
		jr	nz,sbc_35
		inc_error_cnt
sbc_35:		cp	1
		jr	z,sbc_36
		inc_error_cnt
sbc_36:		ld	hl,var1
		ld	a,data_7f
		sbc	a,(hl)
		jp	m,sbc_37
		inc_error_cnt
sbc_37:		jp	pe,sbc_38
		inc_error_cnt
sbc_38:		jr	c,sbc_39
		inc_error_cnt
sbc_39:		jr	nz,sbc_40
		inc_error_cnt
sbc_40:		ld	hl,var5
		sbc	a,(hl)
		jp	p,sbc_41
		inc_error_cnt
sbc_41:		jp	pe,sbc_42
		inc_error_cnt
sbc_42:		jr	nc,sbc_43
		inc_error_cnt
sbc_43:		jr	z,sbc_44
		inc_error_cnt
sbc_44:		ld	hl,var2
		sbc	a,(hl)
		jr	nz,sbc_45
		inc_error_cnt
sbc_45:		cp	data_aa+1
		jr	z,sbc_46
		inc_error_cnt
sbc_46:		ld	ix,var3
		ld	a,data_7f
		sbc	a,(ix-2)
		jp	m,sbc_47
		inc_error_cnt
sbc_47:		jp	pe,sbc_48
		inc_error_cnt
sbc_48:		jr	c,sbc_49
		inc_error_cnt
sbc_49:		jr	nz,sbc_50
		inc_error_cnt
sbc_50:		sbc	a,(ix+2)
		jp	p,sbc_51
		inc_error_cnt
sbc_51:		jp	pe,sbc_52
		inc_error_cnt
sbc_52:		jr	nc,sbc_53
		inc_error_cnt
sbc_53:		jr	z,sbc_54
		inc_error_cnt
sbc_54:		sbc	a,(ix-1)
		jr	nz,sbc_55
		inc_error_cnt
sbc_55:		cp	data_aa+1
		jr	z,sbc_56
		inc_error_cnt
sbc_56:		ld	iy,var3
		ld	a,data_7f
		sbc	a,(ix-2)
		jp	m,sbc_57
		inc_error_cnt
sbc_57:		jp	pe,sbc_58
		inc_error_cnt
sbc_58:		jr	c,sbc_59
		inc_error_cnt
sbc_59:		jr	nz,sbc_60
		inc_error_cnt
sbc_60:		sbc	a,(ix+2)
		jp	p,sbc_61
		inc_error_cnt
sbc_61:		jp	pe,sbc_62
		inc_error_cnt
sbc_62:		jr	nc,sbc_63
		inc_error_cnt
sbc_63:		jr	z,sbc_64
		inc_error_cnt
sbc_64:		sbc	a,(ix+1)
		jr	nz,sbc_65
		inc_error_cnt
sbc_65:		cp	data_55+1
		jr	z,and_0
		inc_error_cnt
and_0:		ld	a,data_ff
		add	a,1			;set carry
		ld	a,data_ff
		ld	b,data_aa
		and	a,b
		jr	nc,and_1
		inc_error_cnt
and_1:		jp	m,and_2
		inc_error_cnt
and_2:		jp	pe,and_3
		inc_error_cnt
and_3:		jr	nz,and_4
		inc_error_cnt
and_4:		ld	b,data_55
		and	a,b
		jp	p,and_5
		inc_error_cnt
and_5:		jr	z,and_6
		inc_error_cnt
and_6:		ld	a,data_ff
		ld	b,data_7f
		and	a,b
		jp	po,and_7
		inc_error_cnt
and_7:		ld	b,data_55
		and	a,b
		jp	pe,and_8
		inc_error_cnt
and_8:		ld	a,data_ff
		ld	c,data_80
		and	a,c
		jp	m,and_9
		inc_error_cnt
and_9:		cp	data_80
		jr	z,and_10
		inc_error_cnt
and_10:		ld	a,data_ff
		ld	d,data_7f
		and	a,d
		jp	p,and_11
		inc_error_cnt
and_11:		cp	data_7f
		jr	z,and_12
		inc_error_cnt
and_12:		ld	a,data_ff
		ld	e,data_aa
		and	a,e
		jp	m,and_13
		inc_error_cnt
and_13:		cp	data_aa
		jr	z,and_14
		inc_error_cnt
and_14:		ld	a,data_ff
		ld	h,data_55
		and	a,h
		jp	p,and_15
		inc_error_cnt
and_15:		cp	data_55
		jr	z,and_16
		inc_error_cnt
and_16:		ld	a,data_ff
		ld	l,data_aa
		and	a,l
		jp	m,and_17
		inc_error_cnt
and_17:		cp	data_aa
		jr	z,and_18
		inc_error_cnt
and_18:		ld	a,data_ff
		and	a,data_aa
		jp	m,and_19
		inc_error_cnt
and_19:		jr	nz,and_20
		inc_error_cnt
and_20:		and	a,data_55
		jp	p,and_21
		inc_error_cnt
and_21:		jr	z,and_22
		inc_error_cnt
and_22:		ld	a,data_ff
		and	a,data_7f
		jp	po,and_23
		inc_error_cnt
and_23:		and	a,data_55
		jp	pe,and_24
		inc_error_cnt
and_24:		jr	nz,and_25
		inc_error_cnt
and_25:		and	a,data_aa
		jr	z,and_26
		inc_error_cnt
and_26:		ld	a,data_ff
		and	a,data_aa
		cp	data_aa
		jr	z,and_27
		inc_error_cnt
and_27:		ld	hl,var4
		ld	a,data_ff
		and	a,(hl)
		jp	m,and_28
		inc_error_cnt
and_28:		jr	nz,and_29
		inc_error_cnt
and_29:		ld	hl,var2
		and	a,(hl)
		jp	p,and_30
		inc_error_cnt
and_30:		jr	z,and_31
		inc_error_cnt
and_31:		ld	a,data_ff
		ld	hl,var5
		and	a,(hl)
		jp	po,and_32
		inc_error_cnt
and_32:		ld	hl,var2
		and	a,(hl)
		jp	pe,and_33
		inc_error_cnt
and_33:		cp	data_55
		jr	z,and_34
		inc_error_cnt
and_34:		ld	ix,var3
		ld	a,data_ff
		and	a,(ix+1)
		jp	m,and_35
		inc_error_cnt
and_35:		jr	nz,and_36
		inc_error_cnt
and_36:		and	a,(ix-1)
		jp	p,and_37
		inc_error_cnt
and_37:		jr	z,and_38
		inc_error_cnt
and_38:		ld	a,data_ff
		and	a,(ix+2)
		jp	po,and_39
		inc_error_cnt
and_39:		and	a,(ix-1)
		jp	pe,and_40
		inc_error_cnt
and_40:		cp	data_55
		jr	z,and_41
		inc_error_cnt
and_41:		ld	iy,var3
		ld	a,data_ff
		and	a,(iy+1)
		jp	m,and_42
		inc_error_cnt
and_42:		jr	nz,and_43
		inc_error_cnt
and_43:		and	a,(iy-1)
		jp	p,and_44
		inc_error_cnt
and_44:		jr	z,and_45
		inc_error_cnt
and_45:		ld	a,data_ff
		and	a,(iy+2)
		jp	po,and_46
		inc_error_cnt
and_46:		and	a,(iy-1)
		jp	pe,and_47
		inc_error_cnt
and_47:		cp	data_55
		jr	z,or_0
		inc_error_cnt
or_0:		ld	a,0
		ld	b,data_7f
		or	a,b
		jp	p,or_1
		inc_error_cnt
or_1:		jp	po,or_2
		inc_error_cnt
or_2:		ld	b,data_80
		or	a,b
		jp	m,or_3
		inc_error_cnt
or_3:		jp	pe,or_4
		inc_error_cnt
or_4:		cp	data_ff
		jr	z,or_5
		inc_error_cnt
or_5:		ld	a,0
		ld	b,0
		or	a,b
		jr	z,or_6
		inc_error_cnt
or_6:		ld	b,data_55
		or	a,b
		jr	nz,or_7
		inc_error_cnt
or_7:		cp	data_55
		jr	z,or_8
		inc_error_cnt
or_8:		ld	a,data_ff
		add	a,1
		jr	c,or_9
		inc_error_cnt
or_9:		ld	b,data_7f
		or	a,b
		jr	nc,or_10
		inc_error_cnt
or_10:		cp	data_7f
		jr	z,or_11
		inc_error_cnt
or_11:		ld	a,0
		ld	c,data_55
		or	a,c
		cp	data_55
		jr	z,or_12
		inc_error_cnt
or_12:		ld	c,data_aa
		or	a,c
		cp	data_ff
		jr	z,or_13
		inc_error_cnt
or_13:		ld	a,0
		ld	d,data_aa
		or	a,d
		cp	data_aa
		jr	z,or_14
		inc_error_cnt
or_14:		ld	e,data_55
		or	a,e
		cp	data_ff
		jr	z,or_15
		inc_error_cnt
or_15:		ld	a,0
		ld	h,data_80
		or	a,h
		cp	data_80
		jr	z,or_16
		inc_error_cnt
or_16:		ld	l,data_7f
		or	a,l
		cp	data_ff
		jr	z,or_17
		inc_error_cnt
or_17:		ld	a,0
		or	a,data_7f
		jp	p,or_18
		inc_error_cnt
or_18:		jp	po,or_19
		inc_error_cnt
or_19:		or	a,data_80
		jp	m,or_20
		inc_error_cnt
or_20:		jp	pe,or_21
		inc_error_cnt
or_21:		cp	data_ff
		jr	z,or_22
		inc_error_cnt
or_22:		ld	a,0
		or	a,0
		jr	z,or_23
		inc_error_cnt
or_23:		or	a,data_7f
		jr	nz,or_24
		inc_error_cnt
or_24:		ld	a,data_ff
		add	a,1
		jr	c,or_25
		inc_error_cnt
or_25:		or	a,data_55
		jr	nc,or_26
		inc_error_cnt
or_26:		cp	data_55
		jr	z,or_27
		inc_error_cnt
or_27:		ld	hl,var5
		ld	a,0
		or	a,(hl)
		jp	p,or_28
		inc_error_cnt
or_28:		jp	po,or_29
		inc_error_cnt
or_29:		ld	hl,var3
		or	a,(hl)
		jp	m,or_30
		inc_error_cnt
or_30:		jp	pe,or_31
		inc_error_cnt
or_31:		cp	data_ff
		jr	z,or_32
		inc_error_cnt
or_32:		ld	hl,t_var1
		ld	a,0
		ld	(hl),a
		or	a,(hl)
		jr	z,or_33
		inc_error_cnt
or_33:		ld	hl,var2
		or	a,(hl)
		jr	nz,or_34
		inc_error_cnt
or_34:		cp	data_55
		jr	z,or_35
		inc_error_cnt
or_35:		ld	ix,var3
		ld	a,0
		or	a,(ix+2)
		jp	p,or_36
		inc_error_cnt
or_36:		jp	po,or_37
		inc_error_cnt
or_37:		or	a,(ix+0)
		jp	m,or_38
		inc_error_cnt
or_38:		jp	pe,or_39
		inc_error_cnt
or_39:		cp	data_ff
		jr	z,or_40
		inc_error_cnt
or_40:		ld	ix,t_var3
		ld	a,0
		ld	(ix-2),a
		or	a,(ix-2)
		jr	z,or_41
		inc_error_cnt
or_41:		ld	(ix+2),data_aa
		or	a,(ix+2)
		jr	nz,or_42
		inc_error_cnt
or_42:		cp	data_aa
		jr	z,or_43
		inc_error_cnt
or_43:		ld	iy,var3
		ld	a,0
		or	a,(iy+2)
		jp	p,or_44
		inc_error_cnt
or_44:		jp	po,or_45
		inc_error_cnt
or_45:		or	a,(iy+0)
		jp	m,or_46
		inc_error_cnt
or_46:		jp	pe,or_47
		inc_error_cnt
or_47:		cp	data_ff
		jr	z,or_48
		inc_error_cnt
or_48:		ld	iy,t_var3
		ld	a,0
		ld	(iy-2),a
		or	a,(iy-2)
		jr	z,or_49
		inc_error_cnt
or_49:		ld	(iy+2),data_55
		or	a,(iy+2)
		jr	nz,or_50
		inc_error_cnt
or_50:		cp	data_55
		jr	z,xor_0
		inc_error_cnt
xor_0:		ld	a,data_ff
		ld	b,data_55
		xor	a,b
		jp	m,xor_1
		inc_error_cnt
xor_1:		jp	pe,xor_2
		inc_error_cnt
xor_2:		ld	b,data_80
		xor	a,b
		jp	p,xor_3
		inc_error_cnt
xor_3:		jp	po,xor_4
		inc_error_cnt
xor_4:		cp	#2a
		jr	z,xor_5
		inc_error_cnt
xor_5:		ld	a,data_ff
		ld	b,data_ff
		xor	a,b
		jr	z,xor_6
		inc_error_cnt
xor_6:		ld	b,data_55
		xor	a,b
		jr	nz,xor_7
		inc_error_cnt
xor_7:		cp	data_55
		jr	z,xor_8
		inc_error_cnt
xor_8:		ld	a,data_ff
		add	a,1
		jr	c,xor_9
		inc_error_cnt
xor_9:		ld	b,data_aa
		xor	a,b
		jr	nc,xor_10
		inc_error_cnt
xor_10:		cp	data_aa
		jr	z,xor_11
		inc_error_cnt
xor_11:		ld	a,data_ff
		ld	c,data_7f
		xor	a,c
		jp	m,xor_12
		inc_error_cnt
xor_12:		cp	data_80
		jr	z,xor_13
		inc_error_cnt
xor_13:		ld	a,data_ff
		ld	d,data_55
		xor	a,d
		jp	m,xor_14
		inc_error_cnt
xor_14:		cp	data_aa
		jr	z,xor_15
		inc_error_cnt
xor_15:		ld	e,data_55
		xor	a,e
		jp	m,xor_16
		inc_error_cnt
xor_16:		cp	data_ff
		jr	z,xor_17
		inc_error_cnt
xor_17:		ld	a,data_ff
		ld	h,data_7f
		xor	a,h
		jp	po,xor_18
		inc_error_cnt
xor_18:		ld	l,data_7f
		xor	a,l
		jp	pe,xor_19
		inc_error_cnt
xor_19:		cp	data_ff
		jr	z,xor_20
		inc_error_cnt
xor_20:		ld	a,data_ff
		add	a,1
		jr	c,xor_21
		inc_error_cnt
xor_21:		ld	b,data_7f
		xor	a,b
		jr	nc,xor_22
		inc_error_cnt
xor_22:		cp	data_7f
		jr	z,xor_23
		inc_error_cnt
xor_23:		ld	a,data_ff
		xor	a,data_7f
		jp	po,xor_24
		inc_error_cnt
xor_24:		jp	m,xor_25
		inc_error_cnt
xor_25:		xor	a,data_7f
		jp	pe,xor_26
		inc_error_cnt
xor_26:		jp	m,xor_27
		inc_error_cnt
xor_27:		xor	a,data_aa
		jp	p,xor_28
		inc_error_cnt
xor_28:		cp	data_55
		jr	z,xor_29
		inc_error_cnt
xor_29:		ld	a,data_ff
		xor	a,data_ff
		jr	z,xor_30
		inc_error_cnt
xor_30:		xor	a,data_80
		jr	nz,xor_31
		inc_error_cnt
xor_31:		cp	data_80
		jr	z,xor_32
		inc_error_cnt
xor_32:		ld	hl,var5
		ld	a,data_ff
		xor	a,(hl)
		jp	m,xor_33
		inc_error_cnt
xor_33:		jp	po,xor_34
		inc_error_cnt
xor_34:		xor	a,(hl)
		jp	m,xor_35
		inc_error_cnt
xor_35:		jp	pe,xor_36
		inc_error_cnt
xor_36:		ld	hl,var3
		xor	a,(hl)
		jp	p,xor_37
		inc_error_cnt
xor_37:		cp	data_7f
		jr	z,xor_38
		inc_error_cnt
xor_38:		ld	hl,var1
		ld	a,data_ff
		xor	a,(hl)
		jr	z,xor_39
		inc_error_cnt
xor_39:		ld	hl,var2
		xor	a,(hl)
		jr	nz,xor_40
		inc_error_cnt
xor_40:		cp	data_55
		jr	z,xor_41
		inc_error_cnt
xor_41:		ld	ix,var3
		ld	a,data_ff
		xor	a,(ix+2)
		jp	m,xor_42
		inc_error_cnt
xor_42:		jp	po,xor_43
		inc_error_cnt
xor_43:		xor	a,(ix+2)
		jp	m,xor_44
		inc_error_cnt
xor_44:		jp	pe,xor_45
		inc_error_cnt
xor_45:		xor	a,(ix+1)
		jp	p,xor_46
		inc_error_cnt
xor_46:		cp	data_55
		jr	z,xor_47
		inc_error_cnt
xor_47:		ld	a,data_ff
		xor	a,(ix-2)
		jr	z,xor_48
		inc_error_cnt
xor_48:		xor	a,(ix+1)
		jr	nz,xor_49
		inc_error_cnt
xor_49:		cp	data_aa
		jr	z,xor_50
		inc_error_cnt
xor_50:		ld	iy,var3
		ld	a,data_ff
		xor	a,(iy+2)
		jp	m,xor_51
		inc_error_cnt
xor_51:		jp	po,xor_52
		inc_error_cnt
xor_52:		xor	a,(iy+2)
		jp	m,xor_53
		inc_error_cnt
xor_53:		jp	pe,xor_54
		inc_error_cnt
xor_54:		xor	a,(iy+1)
		jp	p,xor_55
		inc_error_cnt
xor_55:		cp	data_55
		jr	z,xor_56
		inc_error_cnt
xor_56:		ld	a,data_ff
		xor	a,(iy-2)
		jr	z,xor_57
		inc_error_cnt
xor_57:		xor	a,(iy-1)
		jr	nz,xor_58
		inc_error_cnt
xor_58:		cp	data_55
		jr	z,cp_0
		inc_error_cnt
cp_0:		ld	a,0
		ld	b,0
		cp	a,b
		jr	z,cp_1
		inc_error_cnt
cp_1:		jp	p,cp_2
		inc_error_cnt
cp_2:		jr	nc,cp_3
		inc_error_cnt
cp_3:		ld	b,data_55
		cp	a,b
		jr	nz,cp_4
		inc_error_cnt
cp_4:		jp	m,cp_5
		inc_error_cnt
cp_5:		jr	c,cp_6
		inc_error_cnt
cp_6:		ld	a,data_80
		ld	b,data_7f
		cp	a,b
		jp	pe,cp_7
		inc_error_cnt
cp_7:		jr	nc,cp_8
		inc_error_cnt
cp_8:		ld	a,data_7f
		ld	b,data_80
		cp	a,b
		jp	pe,cp_9
		inc_error_cnt
cp_9:		jr	c,cp_10
		inc_error_cnt
cp_10:		ld	b,0
		cp	a,b
		jp	po,cp_11
		inc_error_cnt
cp_11:		jr	nc,cp_12
		inc_error_cnt
cp_12:		ld	a,data_80
		ld	c,0
		cp	a,c
		jp	m,cp_13
		inc_error_cnt
cp_13:		ld	c,data_80
		cp	a,c
		jr	z,cp_14
		inc_error_cnt
cp_14:		ld	a,data_7f
		ld	d,data_55
		cp	a,d
		jp	p,cp_15
		inc_error_cnt
cp_15:		jr	nz,cp_16
		inc_error_cnt
cp_16:		ld	e,data_7f
		cp	a,e
		jr	z,cp_17
		inc_error_cnt
cp_17:		ld	a,data_80
		ld	h,data_ff
		cp	a,h
		jp	m,cp_18
		inc_error_cnt
cp_18:		jr	c,cp_19
		inc_error_cnt
cp_19:		ld	l,data_80
		cp	a,l
		jr	z,cp_20
		inc_error_cnt
cp_20:		ld	a,data_80
		cp	a,data_7f
		jp	p,cp_21
		inc_error_cnt
cp_21:		jp	pe,cp_22
		inc_error_cnt
cp_22:		jr	nz,cp_23
		inc_error_cnt
cp_23:		cp	a,data_80
		jp	p,cp_24
		inc_error_cnt
cp_24:		jp	po,cp_25
		inc_error_cnt
cp_25:		jr	z,cp_26
		inc_error_cnt
cp_26:		ld	a,data_55
		cp	a,data_7f
		jr	c,cp_27
		inc_error_cnt
cp_27:		jp	m,cp_28
		inc_error_cnt
cp_28:		cp	a,data_55
		jr	nc,cp_29
		inc_error_cnt
cp_29:		jr	z,cp_30
		inc_error_cnt
cp_30:		ld	a,data_80
		ld	hl,var5
		cp	a,(hl)
		jp	p,cp_31
		inc_error_cnt
cp_31:		jp	pe,cp_32
		inc_error_cnt
cp_32:		jr	nz,cp_33
		inc_error_cnt
cp_33:		ld	hl,var3
		cp	a,(hl)
		jp	p,cp_34
		inc_error_cnt
cp_34:		jp	po,cp_35
		inc_error_cnt
cp_35:		jr	z,cp_36
		inc_error_cnt
cp_36:		ld	a,data_55
		ld	hl,var5
		cp	a,(hl)
		jr	c,cp_37
		inc_error_cnt
cp_37:		jp	m,cp_38
		inc_error_cnt
cp_38:		ld	hl,var2
		cp	a,(hl)
		jr	nc,cp_39
		inc_error_cnt
cp_39:		jp	p,cp_40
		inc_error_cnt
cp_40:		jr	z,cp_41
		inc_error_cnt
cp_41:		ld	a,data_80
		ld	ix,var3
		cp	a,(ix+2)
		jp	p,cp_42
		inc_error_cnt
cp_42:		jp	pe,cp_43
		inc_error_cnt
cp_43:		jr	nz,cp_44
		inc_error_cnt
cp_44:		cp	a,(ix+0)
		jp	p,cp_45
		inc_error_cnt
cp_45:		jp	po,cp_46
		inc_error_cnt
cp_46:		jr	z,cp_47
		inc_error_cnt
cp_47:		ld	a,data_55
		cp	a,(ix-2)
		jr	nz,cp_48
		inc_error_cnt
cp_48:		jr	c,cp_49
		inc_error_cnt
cp_49:		cp	a,(ix-1)
		jr	z,cp_50
		inc_error_cnt
cp_50:		jr	nc,cp_51
		inc_error_cnt
cp_51:		ld	iy,var3
		ld	a,data_80
		cp	a,(iy+2)
		jp	p,cp_52
		inc_error_cnt
cp_52:		jp	pe,cp_53
		inc_error_cnt
cp_53:		jr	nz,cp_54
		inc_error_cnt
cp_54:		cp	a,(iy+0)
		jp	p,cp_55
		inc_error_cnt
cp_55:		jp	po,cp_56
		inc_error_cnt
cp_56:		jr	z,cp_57
		inc_error_cnt
cp_57:		ld	a,data_55
		cp	a,(iy-2)
		jr	nz,cp_58
		inc_error_cnt
cp_58:		jr	c,cp_59
		inc_error_cnt
cp_59:		cp	a,(iy-1)
		jr	z,cp_60
		inc_error_cnt
cp_60:		jr	nc,inc_0
		inc_error_cnt
inc_0:		ld	a,data_7f
		cp	a,data_7f
		jr	z,inc_1
		inc_error_cnt
inc_1:		inc	a
		jp	pe,inc_2
		inc_error_cnt
inc_2:		jp	m,inc_3
		inc_error_cnt
inc_3:		jr	nz,inc_4
		inc_error_cnt
inc_4:		ld	a,data_55
		inc	a
		jp	po,inc_5
		inc_error_cnt
inc_5:		jp	p,inc_6
		inc_error_cnt
inc_6:		cp	a,data_55+1
		jr	z,inc_7
		inc_error_cnt
inc_7:		ld	a,data_ff-1
		inc	a
		jr	nz,inc_8
		inc_error_cnt
inc_8:		jp	m,inc_9
		inc_error_cnt
inc_9:		inc	a
		jr	z,inc_10
		inc_error_cnt
inc_10:		ld	b,data_aa
		inc	b
		jp	m,inc_11
		inc_error_cnt
inc_11:		ld	a,b
		cp	a,data_aa+1
		jr	z,inc_12
		inc_error_cnt
inc_12:		ld	c,data_80
		inc	c
		jp	m,inc_13
		inc_error_cnt
inc_13:		ld	a,c
		cp	a,data_80+1
		jr	z,inc_14
		inc_error_cnt
inc_14:		ld	d,data_ff
		inc	d
		jr	z,inc_15
		inc_error_cnt
inc_15:		ld	e,data_55
		inc	e
		jp	p,inc_16
		inc_error_cnt
inc_16:		ld	a,e
		cp	a,data_55+1
		jr	z,inc_17
		inc_error_cnt
inc_17:		ld	h,data_7f
		inc	h
		jp	pe,inc_18
		inc_error_cnt
inc_18:		ld	a,h
		cp	a,data_80
		jr	z,inc_19
		inc_error_cnt
inc_19:		ld	l,data_aa
		inc	l
		jp	m,inc_20
		inc_error_cnt
inc_20:		ld	a,l
		cp	a,data_aa+1
		jr	z,inc_21
		inc_error_cnt
inc_21:		ld	hl,t_var1
		ld	a,data_7f
		ld	(hl),a
		cp	a,(hl)
		jr	z,inc_22
		inc_error_cnt
inc_22:		inc	(hl)
		jp	m,inc_23
		inc_error_cnt
inc_23:		jp	pe,inc_24
		inc_error_cnt
inc_24:		ld	a,data_55
		ld	(hl),a
		inc	(hl)
		jp	p,inc_25
		inc_error_cnt
inc_25:		jp	po,inc_26
		inc_error_cnt
inc_26:		ld	a,(hl)
		cp	a,data_55+1
		jr	z,inc_27
		inc_error_cnt
inc_27:		ld	a,data_ff
		ld	(hl),a
		inc	(hl)
		jr	z,inc_28
		inc_error_cnt
inc_28:		inc	(hl)
		jr	nz,inc_29
		inc_error_cnt
inc_29:		ld	a,(hl)
		cp	a,1
		jr	z,inc_30
		inc_error_cnt
inc_30:		ld	a,data_aa
		ld	(hl),a
		inc	(hl)
		jp	m,inc_31
		inc_error_cnt
inc_31:		ld	a,(hl)
		cp	a,data_aa+1
		jr	z,inc_32
		inc_error_cnt
inc_32:		ld	ix,t_var3
		ld	a,data_7f
		ld	(ix-2),a
		cp	a,data_7f
		jr	z,inc_33
		inc_error_cnt
inc_33:		inc	(ix-2)
		jp	m,inc_34
		inc_error_cnt
inc_34:		jp	pe,inc_35
		inc_error_cnt
inc_35:		ld	a,data_55
		ld	(ix+2),a
		inc	(ix+2)
		jp	p,inc_36
		inc_error_cnt
inc_36:		jp	po,inc_37
		inc_error_cnt
inc_37:		ld	a,(ix+2)
		cp	a,data_55+1
		jr	z,inc_38
		inc_error_cnt
inc_38:		ld	a,data_ff
		ld	(ix-1),a
		inc	(ix-1)
		jr	z,inc_39
		inc_error_cnt
inc_39:		inc	(ix-1)
		jr	nz,inc_40
		inc_error_cnt
inc_40:		ld	a,(ix-1)
		cp	a,1
		jr	z,inc_41
		inc_error_cnt
inc_41:		ld	a,data_aa
		ld	(ix+1),a
		inc	(ix+1)
		jp	m,inc_42
		inc_error_cnt
inc_42:		ld	a,(ix+1)
		cp	a,data_aa+1
		jr	z,inc_43
		inc_error_cnt
inc_43:		ld	iy,t_var3
		ld	a,data_7f
		ld	(iy+2),a
		cp	a,data_7f
		jr	z,inc_44
		inc_error_cnt
inc_44:		inc	(iy+2)
		jp	m,inc_45
		inc_error_cnt
inc_45:		jp	pe,inc_46
		inc_error_cnt
inc_46:		ld	a,data_55
		ld	(iy-2),a
		inc	(iy-2)
		jp	p,inc_47
		inc_error_cnt
inc_47:		jp	po,inc_48
		inc_error_cnt
inc_48:		ld	a,(iy-2)
		cp	a,data_55+1
		jr	z,inc_49
		inc_error_cnt
inc_49:		ld	a,data_ff
		ld	(iy+1),a
		inc	(iy+1)
		jr	z,inc_50
		inc_error_cnt
inc_50:		inc	(iy+1)
		jr	nz,inc_51
		inc_error_cnt
inc_51:		ld	a,(iy+1)
		cp	a,1
		jr	z,inc_52
		inc_error_cnt
inc_52:		ld	a,data_80
		ld	(iy-1),a
		inc	(iy-1)
		jp	m,inc_53
		inc_error_cnt
inc_53:		ld	a,(iy-1)
		cp	a,data_80+1
		jr	z,dec_0
		inc_error_cnt
dec_0:		ld	a,data_80
		cp	a,data_80
		jr	z,dec_1
		inc_error_cnt
dec_1:		dec	a
		jp	p,dec_2
		inc_error_cnt
dec_2:		jp	pe,dec_3
		inc_error_cnt
dec_3:		ld	a,0
		dec	a
		jp	m,dec_4
		inc_error_cnt
dec_4:		jp	po,dec_5
		inc_error_cnt
dec_5:		cp	a,data_ff
		jr	z,dec_6
		inc_error_cnt
dec_6:		ld	a,1
		dec	a
		jr	z,dec_7
		inc_error_cnt
dec_7:		dec	a
		jr	nz,dec_8
		inc_error_cnt
dec_8:		cp	a,data_ff
		jr	z,dec_9
		inc_error_cnt
dec_9:		ld	a,data_aa
		dec	a
		cp	a,data_aa-1
		jr	z,dec_10
		inc_error_cnt
dec_10:		ld	b,data_7f
		dec	b
		ld	a,b
		cp	a,data_7f-1
		jr	z,dec_11
		inc_error_cnt
dec_11:		ld	c,data_55
		dec	c
		ld	a,c
		cp	a,data_55-1
		jr	z,dec_12
		inc_error_cnt
dec_12:		ld	d,data_aa
		dec	d
		ld	a,d
		cp	a,data_aa-1
		jr	z,dec_13
		inc_error_cnt
dec_13:		ld	e,data_80
		dec	e
		ld	a,e
		cp	a,data_80-1
		jr	z,dec_14
		inc_error_cnt
dec_14:		ld	h,data_ff
		dec	h
		ld	a,h
		cp	a,data_ff-1
		jr	z,dec_15
		inc_error_cnt
dec_15:		ld	l,data_55
		dec	l
		ld	a,l
		cp	a,data_55-1
		jr	z,dec_16
		inc_error_cnt
dec_16:		ld	hl,t_var5
		ld	a,data_80
		ld	(hl),a
		cp	a,(hl)
		jr	z,dec_17
		inc_error_cnt
dec_17:		dec	(hl)
		jp	p,dec_18
		inc_error_cnt
dec_18:		jp	pe,dec_19
		inc_error_cnt
dec_19:		ld	a,0
		ld	(hl),a
		dec	(hl)
		jp	m,dec_20
		inc_error_cnt
dec_20:		jp	po,dec_21
		inc_error_cnt
dec_21:		ld	a,(hl)
		cp	a,data_ff
		jr	z,dec_22
		inc_error_cnt
dec_22:		ld	a,1
		ld	(hl),a
		dec	(hl)
		jr	z,dec_23
		inc_error_cnt
dec_23:		dec	(hl)
		jr	nz,dec_24
		inc_error_cnt
dec_24:		ld	a,(hl)
		cp	a,data_ff
		jr	z,dec_25
		inc_error_cnt
dec_25:		ld	a,data_aa
		ld	(hl),a
		dec	(hl)
		ld	a,(hl)
		cp	a,data_aa-1
		jr	z,dec_26
		inc_error_cnt
dec_26:		ld	ix,t_var3
		ld	a,data_80
		ld	(ix-2),a
		cp	a,(ix-2)
		jr	z,dec_27
		inc_error_cnt
dec_27:		dec	(ix-2)
		jp	p,dec_28
		inc_error_cnt
dec_28:		jp	pe,dec_29
		inc_error_cnt
dec_29:		ld	a,0
		ld	(ix+2),a
		dec	(ix+2)
		jp	m,dec_30
		inc_error_cnt
dec_30:		jp	po,dec_31
		inc_error_cnt
dec_31:		ld	a,(ix+2)
		cp	a,data_ff
		jr	z,dec_32
		inc_error_cnt
dec_32:		ld	a,1
		ld	(ix-1),a
		dec	(ix-1)
		jr	z,dec_33
		inc_error_cnt
dec_33:		dec	(ix-1)
		jr	nz,dec_34
		inc_error_cnt
dec_34:		ld	a,(ix-1)
		cp	a,data_ff
		jr	z,dec_35
		inc_error_cnt
dec_35:		ld	a,data_7f
		ld	(ix+1),a
		dec	(ix+1)
		ld	a,(ix+1)
		cp	a,data_7f-1
		jr	z,dec_36
		inc_error_cnt
dec_36:		ld	iy,t_var3
		ld	a,data_80
		ld	(iy-2),a
		cp	a,(iy-2)
		jr	z,dec_37
		inc_error_cnt
dec_37:		dec	(iy-2)
		jp	p,dec_38
		inc_error_cnt
dec_38:		jp	pe,dec_39
		inc_error_cnt
dec_39:		ld	a,0
		ld	(iy+2),a
		dec	(iy+2)
		jp	m,dec_40
		inc_error_cnt
dec_40:		jp	po,dec_41
		inc_error_cnt
dec_41:		ld	a,(iy+2)
		cp	a,data_ff
		jr	z,dec_42
		inc_error_cnt
dec_42:		ld	a,1
		ld	(iy+1),a
		dec	(iy+1)
		jr	z,dec_43
		inc_error_cnt
dec_43:		dec	(iy+1)
		jr	nz,dec_44
		inc_error_cnt
dec_44:		ld	a,(iy+1)
		cp	a,data_ff
		jr	z,dec_45
		inc_error_cnt
dec_45:		ld	a,data_aa
		ld	(iy-1),a
		dec	(iy-1)
		ld	a,(iy-1)
		cp	a,data_aa-1
		jr	z,cpl_0
		inc_error_cnt
cpl_0:		ld	a,data_ff
		cpl
		cp	a,0
		jr	z,cpl_1
		inc_error_cnt
cpl_1:		ld	a,data_aa
		cpl
		cp	a,data_55
		jr	z,cpl_2
		inc_error_cnt
cpl_2:		cpl
		cp	a,data_aa
		jr	z,neg_0
		inc_error_cnt
neg_0:		ld	a,data_80
		cp	a,data_80
		jp	po,neg_1
		inc_error_cnt
neg_1:		neg
		jp	pe,neg_2
		inc_error_cnt
neg_2:		jr	nz,neg_3
		inc_error_cnt
neg_3:		jr	c,neg_4
		inc_error_cnt
neg_4:		ld	a,0
		neg
		jp	po,neg_5
		inc_error_cnt
neg_5:		jr	z,neg_6
		inc_error_cnt
neg_6:		jr	nc,neg_7
		inc_error_cnt
neg_7:		ld	a,data_55
		cp	a,data_55
		jp	p,neg_8
		inc_error_cnt
neg_8:		neg
		jp	m,neg_9
		inc_error_cnt
neg_9:		neg
		jp	p,neg_10
		inc_error_cnt
neg_10:		cp	a,data_55
		jr	z,ccf_0
		inc_error_cnt
ccf_0:		scf
		jr	c,ccf_1
		inc_error_cnt
ccf_1:		ccf
		jr	nc,ccf_2
		inc_error_cnt
ccf_2:		ccf
		jr	c,im_0
		inc_error_cnt
im_0:		im	0
		im	1
		im	2
daa_0:		ld	a,#99
		ld	b,#1
		add	a,b
		daa
		jr	c,daa_1
		inc_error_cnt
daa_1:		jr	z,daa_2
		inc_error_cnt
daa_2:		add	a,b
		jr	nc,daa_3
		inc_error_cnt
daa_3:		jr	nz,daa_4
		inc_error_cnt
daa_4:		cp	a,1
		jr	z,daa_5
		inc_error_cnt
daa_5:		ld	a,#98
		ld	b,1
		add	a,b
		daa
		jp	m,daa_6
		inc_error_cnt
daa_6:		add	a,b
		daa
		jp	p,daa_7
		inc_error_cnt
daa_7:		ld	a,1
		ld	b,1
		add	a,b
		daa
		jp	po,daa_8
		inc_error_cnt
daa_8:		add	a,b
		daa
		jp	pe,daa_9
		inc_error_cnt
daa_9:		cp	a,3
		jr	z,add_74
		inc_error_cnt
add_74:		ld	hl,data_1234
		add	hl,hl
		jr	nc,add_75
		inc_error_cnt
add_75:		ld	a,h
		cp	a,#24
		jr	z,add_76
		inc_error_cnt
add_76:		ld	a,l
		cp	a,#68
		jr	z,add_77
		inc_error_cnt
add_77:		ld	hl,data_7fff
		ld	bc,data_8000
		add	hl,bc
		jr	nc,add_78
		inc_error_cnt
add_78:		ld	bc,1
		add	hl,bc
		jr	c,add_79
		inc_error_cnt
add_79:		ld	a,h
		cp	a,0
		jr	z,add_80
		inc_error_cnt
add_80:		ld	a,l
		cp	a,0
		jr	z,add_81
		inc_error_cnt
add_81:		ld	hl,data_aa55
		ld	de,data_ffff
		add	hl,de
		jr	c,add_82
		inc_error_cnt
add_82:		ld	a,h
		cp	a,data_aa
		jr	z,add_83
		inc_error_cnt
add_83:		ld	a,l
		cp	a,data_55-1
		jr	z,add_84
		inc_error_cnt
add_84:		ld	hl,data_aa55
		ld	sp,data_8000
		add	hl,sp
		jr	c,add_85
		inc_error_cnt
add_85:		ld	a,h
		cp	a,#2a
		jr	z,add_86
		inc_error_cnt
add_86:		ld	a,l
		cp	a,data_55
		jr	z,add_87
		inc_error_cnt
add_87:		ld	sp,stack_end
		ld	hl,data_1234
		scf
		ccf
		adc	hl,hl
		jr	nz,add_88
		inc_error_cnt
add_88:		jr	nc,add_89
		inc_error_cnt
add_89:		jp	p,add_90
		inc_error_cnt
add_90:		jp	po,add_91
		inc_error_cnt
add_91:		ld	bc,data_8000
		adc	hl,bc
		jp	m,add_92
		inc_error_cnt
add_92:		jr	nc,add_93
		inc_error_cnt
add_93:		jp	po,add_94
		inc_error_cnt
add_94:		jp	nz,add_95
		inc_error_cnt
add_95:		adc	hl,bc
		jp	p,add_96
		inc_error_cnt
add_96:		jp	pe,add_97
		inc_error_cnt
add_97:		jr	c,add_98
		inc_error_cnt
add_98:		jr	nz,add_99
		inc_error_cnt
add_99:		ld	de,#db97
		adc	hl,de
		jr	z,add_100
		inc_error_cnt
add_100:	jr	c,add_101
		inc_error_cnt
add_101:	jp	po,add_102
		inc_error_cnt
add_102:	ld	de,0
		adc	hl,de
		jr	nc,add_103
		inc_error_cnt
add_103:	jr	nz,add_104
		inc_error_cnt
add_104:	ld	a,h
		cp	a,0
		jr	z,add_105
		inc_error_cnt
add_105:	ld	a,l
		cp	a,1
		jr	z,add_106
		inc_error_cnt
add_106:	ld	hl,data_1234
		ld	sp,data_ffff
		adc	hl,sp
		jr	c,add_107
		inc_error_cnt
add_107:	ld	a,h
		cp	a,#12
		jr	z,add_108
		inc_error_cnt
add_108:	ld	a,l
		cp	a,#33
		jr	z,sbc_66
		inc_error_cnt
sbc_66:		ld	sp,stack_end
		scf
		ccf
		ld	hl,data_1234
		sbc	hl,hl
		jr	z,sbc_67
		inc_error_cnt
sbc_67:		jp	p,sbc_68
		inc_error_cnt
sbc_68:		jp	po,sbc_69
		inc_error_cnt
sbc_69:		jr	nc,sbc_70
		inc_error_cnt
sbc_70:		ld	bc,data_1234
		sbc	hl,bc
		jr	nz,sbc_71
		inc_error_cnt
sbc_71:		jr	c,sbc_72
		inc_error_cnt
sbc_72:		jp	m,sbc_73
		inc_error_cnt
sbc_73:		jp	po,sbc_74
		inc_error_cnt
sbc_74:		ld	de,data_7fff
		sbc	hl,de
		jr	nz,sbc_75
		inc_error_cnt
sbc_75:		jr	nc,sbc_76
		inc_error_cnt
sbc_76:		jp	p,sbc_77
		inc_error_cnt
sbc_77:		jp	pe,sbc_78
		inc_error_cnt
sbc_78:		ld	sp,data_1234
		sbc	hl,sp
		jr	nz,sbc_79
		inc_error_cnt
sbc_79:		ld	a,h
		cp	a,#5b
		jr	z,sbc_80
		inc_error_cnt
sbc_80:		ld	a,l
		cp	a,#98
		jr	z,add_109
		inc_error_cnt
add_109:	ld	sp,stack_end
		ld	ix,0
		add	ix,sp
		jr	nc,add_110
		inc_error_cnt
add_110:	push	ix
		pop	hl
		ld	a,h
		cp	a,#71		; >stack_end
		jr	z,add_111
		inc_error_cnt
add_111:	ld	a,l
		cp	a,#80		; <stack_end
		jr	z,add_112
		inc_error_cnt
add_112:	ld	ix,data_7fff
		ld	bc,data_aa55
		add	ix,bc
		jr	c,add_113
		inc_error_cnt
add_113:	add	ix,bc
		jr	nc,add_114
		inc_error_cnt
add_114:	push	ix
		pop	hl
		ld	a,h
		cp	a,#d4
		jr	z,add_115
		inc_error_cnt
add_115:	ld	a,l
		cp	a,#a9
		jr	z,add_116
		inc_error_cnt
add_116:	ld	ix,data_1234
		ld	de,data_1234
		add	ix,de
		push	ix
		pop	hl
		ld	a,h
		cp	a,#24		;>(data_1234+data_1234)
		jr	z,add_117
		inc_error_cnt
add_117:	ld	a,l
		cp	a,#68		;<(data_1234+data_1234)
		jr	z,add_118
		inc_error_cnt
add_118:	ld	ix,data_1234
		add	ix,ix
		push	ix
		pop	bc
		ld	a,b
		cp	a,#24		;>(data_1234+data_1234)
		jr	z,add_119
		inc_error_cnt
add_119:	ld	a,c
		cp	a,#68		;<(data_1234+data_1234)
		jr	z,add_120
		inc_error_cnt
add_120:	ld	sp,stack_end
		ld	iy,0
		add	iy,sp
		jr	nc,add_121
		inc_error_cnt
add_121:	push	iy
		pop	hl
		ld	a,h
		cp	a,#71		;>stack_end
		jr	z,add_122
		inc_error_cnt
add_122:	ld	a,l
		cp	a,#80		;<stack_end
		jr	z,add_123
		inc_error_cnt
add_123:	ld	iy,data_7fff
		ld	bc,data_aa55
		add	iy,bc
		jr	c,add_124
		inc_error_cnt
add_124:	add	iy,bc
		jr	nc,add_125
		inc_error_cnt
add_125:	push	iy
		pop	hl
		ld	a,h
		cp	a,#d4
		jr	z,add_126
		inc_error_cnt
add_126:	ld	a,l
		cp	a,#a9
		jr	z,add_127
		inc_error_cnt
add_127:	ld	iy,data_1234
		ld	de,data_1234
		add	iy,de
		push	iy
		pop	hl
		ld	a,h
		cp	a,#24		;>(data_1234+data_1234)
		jr	z,add_128
		inc_error_cnt
add_128:	ld	a,l
		cp	a,#68		;<(data_1234+data_1234)
		jr	z,add_129
		inc_error_cnt
add_129:	ld	iy,data_1234
		add	iy,iy
		push	iy
		pop	bc
		ld	a,b
		cp	a,#24		;>(data_1234+data_1234)
		jr	z,add_130
		inc_error_cnt
add_130:	ld	a,c
		cp	a,#68		;<(data_1234+data_1234)
		jr	z,inc_54
		inc_error_cnt
inc_54:		ld	bc,data_1234
		inc	bc
		ld	a,b
		cp	a,#12      ;bjp was >data_1234
		jr	z,inc_55
		inc_error_cnt
inc_55:		ld	a,c
		cp	a,#34+1      ;bjp was >data_1234+1
		jr	z,inc_56
		inc_error_cnt
inc_56:		ld	de,data_55aa
		inc	de
		ld	a,d
		cp	a,#55		;>data_55aa
		jr	z,inc_57
		inc_error_cnt
inc_57:		ld	a,e
		cp	a,#ab		;<data_55aa+1
		jr	z,inc_58
		inc_error_cnt
inc_58:		ld	hl,data_7fff
		inc	hl
		ld	a,h
		cp	a,#80		;>data_7fff+1
		jr	z,inc_59
		inc_error_cnt
inc_59:		ld	a,l
		cp	a,#00		;<data_7fff+1
		jr	z,inc_60
		inc_error_cnt
inc_60:		ld	hl,0
		inc	sp
		add	hl,sp
		ld	sp,stack_end
		ld	a,h
		cp	a,#71		;>stack_end+1
		jr	z,inc_61
		inc_error_cnt
inc_61:		ld	a,l
		cp	a,#81		;<stack_end+1
		jr	z,inc_62
		inc_error_cnt
inc_62:		ld	ix,data_8000
		inc	ix
		push	ix
		pop	de
		ld	a,d
		cp	a,#80		;>data_8000
		jr	z,inc_63
		inc_error_cnt
inc_63:		ld	a,e
		cp	a,#01		;<data_8000+1
		jr	z,inc_64
		inc_error_cnt
inc_64:		ld	iy,data_7fff
		inc 	iy
		push	iy
		pop	bc
		ld	a,b
		cp	a,#80		;>data_7fff+1
		jr	z,inc_65
		inc_error_cnt
inc_65:		ld	a,c
		cp	a,#00		;<data_7fff+1
		jr	z,dec_46
		inc_error_cnt
dec_46:		ld	bc,data_1234
		dec	bc
		ld	a,b
		cp	a,#12      ;bjp was >data_1234
		jr	z,dec_47
		inc_error_cnt
dec_47:		ld	a,c
		cp	a,#34-1      ;bjp was >data_1234-1
		jr	z,dec_48
		inc_error_cnt
dec_48:		ld	de,data_8000
		dec	de
		ld	a,d
		cp	a,#7f		;>data_7fff
		jr	z,dec_49
		inc_error_cnt
dec_49:		ld	a,e
		cp	a,#ff		;<data_7fff
		jr	z,dec_50
		inc_error_cnt
dec_50:		ld	hl,data_aa55
		dec	hl
		ld	a,h
		cp	a,#aa		;>data_aa55
		jr	z,dec_51
		inc_error_cnt
dec_51:		ld	a,l
		cp	a,#54		;<data_aa55-1
		jr	z,dec_52
		inc_error_cnt
dec_52:		ld	hl,0
		dec	sp
		add	hl,sp
		ld	a,h
		cp	a,#71		;>stack_end-1
		jr	z,dec_53
		inc_error_cnt
dec_53:		ld	a,l
		cp	a,#7f		;<stack_end-1
		jr	z,dec_54
		inc_error_cnt
dec_54:		ld	sp,stack_end
		ld	ix,data_ffff
		dec	ix
		push	ix
		pop	bc
		ld	a,b
		cp	a,#ff		;>data_ffff
		jr	z,dec_55
		inc_error_cnt
dec_55:		ld	a,c
		cp	a,#fe		;<data_ffff-1
		jr	z,dec_56
		inc_error_cnt
dec_56:		ld	iy,data_aa55
		dec	iy
		push	iy
		pop	de
		ld	a,d
		cp	a,#aa		;>data_aa55
		jr	z,dec_57
		inc_error_cnt
dec_57:		ld	a,e
		cp	a,#54		;<data_aa55-1
		jr	z,rlca_0
		inc_error_cnt
		; bjp  don't see any further mucking with sp after the load above.
		; perhaps it is now safe to enable interrupts. and test them a little
rlca_0:		ld	hl, bist_adr      ; enable interrupts
		ld      (hl), bist_ei
		ld	a, #72         ;bjp  this is >int_tbl  - if you move int_tbl change
		ld      i, a
		ei
		
                ld	a,data_80
		rlca
		jr	c,rlca_1
		inc_error_cnt
rlca_1:		rlca
		jr	nc,rlca_2
		inc_error_cnt
rlca_2:		cp	a,2
		jr	z,rlca_3
		inc_error_cnt
rlca_3:		ld	a,data_55
		rlca
		cp	a,data_aa
		jr	z,rla_0
		inc_error_cnt
rla_0:		scf
		ccf
		ld	a,data_80
		rla
		jr	c,rla_1
		inc_error_cnt
rla_1:		rla
		jr	nc,rla_2
		inc_error_cnt
rla_2:		cp	a,1
		jr	z,rla_3
		inc_error_cnt
rla_3:		ld	a,data_7f
		rla
		cp	a,data_ff-1
		jr	z,rrca_0
		inc_error_cnt
rrca_0:		di                 ; disable interrupts  we want to enable at specific pts
		scf
		ccf
		ld	a,1
		rrca
		jr	c,rrca_1
		inc_error_cnt
rrca_1:		rrca
		jr	nc,rrca_2
		inc_error_cnt
rrca_2:		cp	a,data_7f-#3f
		jr	z,rrca_3
		inc_error_cnt
rrca_3:		ld	a,data_aa
		rrca
		cp	a,data_55
		jr	z,rra_0
		inc_error_cnt
rra_0:		scf
		ccf
		ld	a,1
		rra
		jr	c,rra_1
		inc_error_cnt
rra_1:		rra
		jr	nc,rra_2
		inc_error_cnt
rra_2:		cp	a,data_80
		jr	z,rra_3
		inc_error_cnt
rra_3:		ld	a,data_aa
		rra
		cp	a,data_55
		jr	z,rlc_0
		inc_error_cnt
rlc_0:		ld	a,data_80
		rlc	a
		jr	c,rlc_1
		inc_error_cnt
rlc_1:		jp	p,rlc_2
		inc_error_cnt
rlc_2:		jr	nz,rlc_3
		inc_error_cnt
rlc_3:		jp	po,rlc_4
		inc_error_cnt
rlc_4:		rlc	a
		jr	nc,rlc_5
		inc_error_cnt
rlc_5:		rlc	a
		rlc	a
		rlc	a
		rlc	a
		rlc	a
		rlc	a
		jp	m,rlc_6
		inc_error_cnt
rlc_6:		ld	a,data_55
		rlc	a
		jp	m,rlc_7
		inc_error_cnt
rlc_7:		jp	pe,rlc_8
		inc_error_cnt
rlc_8:		cp	a,data_aa
		jr	z,rlc_9
		inc_error_cnt
rlc_9:		ld	a,0
		rlc	a
		jr	z,rlc_10
		inc_error_cnt
rlc_10:		ld	b,data_7f
		rlc	b
		ld	a,b
		cp	a,data_ff-1
		jr	z,rlc_11
		inc_error_cnt
rlc_11:		ld	c,data_aa
		rlc	c
		jr	c,rlc_12
		inc_error_cnt
rlc_12:		ld	a,c
		cp	a,data_55
		jr	z,rlc_13
		inc_error_cnt
rlc_13:		ld	d,data_80
		rlc	d
		jr	c,rlc_14
		inc_error_cnt
rlc_14:		ld	a,d
		cp	a,1
		jr	z,rlc_15
		inc_error_cnt
rlc_15:		ld	e,data_ff
		rlc	e
		jr	c,rlc_16
		inc_error_cnt
rlc_16:		ld	a,e
		cp	a,data_ff
		jr	z,rlc_17
		inc_error_cnt
rlc_17:		ld	h,data_55
		rlc	h
		jp	m,rlc_18
		inc_error_cnt
rlc_18:		ld	a,h
		cp	a,data_aa
		jr	z,rlc_19
		inc_error_cnt
rlc_19:		ld	l,data_80
		rlc	l
		jp	p,rlc_20
		inc_error_cnt
rlc_20:		ld	a,l
		cp	a,1
		jr	z,rlc_21
		inc_error_cnt
rlc_21:		ld	hl,t_var1
		ld	a,data_55
		ld	(hl),a
		rlc	(hl)
		jp	m,rlc_22
		inc_error_cnt
rlc_22:		jp	pe,rlc_23
		inc_error_cnt
rlc_23:		jr	nc,rlc_24
		inc_error_cnt
rlc_24:		jr	nz,rlc_25
		inc_error_cnt
rlc_25:		rlc	(hl)
		jp	p,rlc_26
		inc_error_cnt
rlc_26:		jr	c,rlc_27
		inc_error_cnt
rlc_27:		ld	a,(hl)
		cp	a,data_55
		jr	z,rlc_28
		inc_error_cnt
rlc_28:		ld	a,data_7f
		ld	(hl),a
		rlc	(hl)
		jp	po,rlc_29
		inc_error_cnt
rlc_29:		ld	a,(hl)
		cp	a,data_ff-1
		jr	z,rlc_30
		inc_error_cnt
rlc_30:		ld	a,0
		ld	(hl),a
		rlc	(hl)
		jr	z,rlc_31
		inc_error_cnt
rlc_31:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		rlc	(ix-2)
		jp	m,rlc_32
		inc_error_cnt
rlc_32:		jp	pe,rlc_33
		inc_error_cnt
rlc_33:		jr	nz,rlc_34
		inc_error_cnt
rlc_34:		jr	nc,rlc_35
		inc_error_cnt
rlc_35:		rlc	(ix-2)
		jp	p,rlc_36
		inc_error_cnt
rlc_36:		jr	c,rlc_37
		inc_error_cnt
rlc_37:		ld	a,(ix-2)
		cp	a,data_55
		jr	z,rlc_38
		inc_error_cnt
rlc_38:		ld	a,data_7f
		ld	(ix+2),a
		rlc	(ix+2)
		jp	po,rlc_39
		inc_error_cnt
rlc_39:		ld	a,(ix+2)
		cp	a,data_ff-1
		jr	z,rlc_40
		inc_error_cnt
rlc_40:		ld	a,0
		ld	(ix-1),a
		rlc	(ix-1)
		jr	z,rlc_41
		inc_error_cnt
rlc_41:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy+2),a
		rlc	(iy+2)
		jp	m,rlc_42
		inc_error_cnt
rlc_42:		jp	pe,rlc_43
		inc_error_cnt
rlc_43:		jr	nc,rlc_44
		inc_error_cnt
rlc_44:		jr	nz,rlc_45
		inc_error_cnt
rlc_45:		rlc	(iy+2)
		jp	p,rlc_46
		inc_error_cnt
rlc_46:		jr	c,rlc_47
		inc_error_cnt
rlc_47:		ld	a,(iy+2)
		cp	a,data_55
		jr	z,rlc_48
		inc_error_cnt
rlc_48:		ld	a,data_7f
		ld	(iy-2),a
		rlc	(iy-2)
		jp	po,rlc_49
		inc_error_cnt
rlc_49:		ld	a,(iy-2)
		cp	a,data_ff-1
		jr	z,rlc_50
		inc_error_cnt
rlc_50:		ld	a,0
		ld	(iy+1),a
		rlc	(iy+1)
		jr	z,rl_0
		inc_error_cnt
rl_0:		scf
		ccf
		ld	a,data_55
		rl	a
		jp	m,rl_1
		inc_error_cnt
rl_1:		jp	pe,rl_2
		inc_error_cnt
rl_2:		jr	nc,rl_3
		inc_error_cnt
rl_3:		jr	nz,rl_4
		inc_error_cnt
rl_4:		rl	a
		jp	p,rl_5
		inc_error_cnt
rl_5:		jp	po,rl_6
		inc_error_cnt
rl_6:		jr	c,rl_7
		inc_error_cnt
rl_7:		rl	a
		cp	a,data_aa-1
		jr	z,rl_8
		inc_error_cnt
rl_8:		ld	a,0
		rl	a
		jr	z,rl_9
		inc_error_cnt
rl_9:		ld	b,data_aa
		ld	c,data_7f
		rl	b
		jr	c,rl_10
		inc_error_cnt
rl_10:		rl	c
		jr	nc,rl_11
		inc_error_cnt
rl_11:		ld	a,b
		cp	a,data_55-1
		jr	z,rl_12
		inc_error_cnt
rl_12:		ld	a,c
		cp	a,data_ff
		jr	z,rl_13
		inc_error_cnt
rl_13:		ld	d,data_ff
		ld	e,data_80
		rl	e
		jr	c,rl_14
		inc_error_cnt
rl_14:		rl	d
		jr	c,rl_15
		inc_error_cnt
rl_15:		ld	a,d
		cp	a,data_ff
		jr	z,rl_16
		inc_error_cnt
rl_16:		ld	a,e
		cp	a,0
		jr	z,rl_17
		inc_error_cnt
rl_17:		ld	h,data_7f
		ld	l,data_55
		rl	h
		jp	m,rl_18
		inc_error_cnt
rl_18:		rl	l
		jp	m,rl_19
		inc_error_cnt
rl_19:		ld	a,h
		cp	a,data_ff-1
		jr	z,rl_20
		inc_error_cnt
rl_20:		ld	a,l
		cp	a,data_aa
		jr	z,rl_21
		inc_error_cnt
rl_21:		ld	hl,t_var5
		ld	a,data_55
		ld	(hl),a
		rl	(hl)
		jp	m,rl_22
		inc_error_cnt
rl_22:		jp	pe,rl_23
		inc_error_cnt
rl_23:		jr	nc,rl_24
		inc_error_cnt
rl_24:		jr	nz,rl_25
		inc_error_cnt
rl_25:		rl	(hl)
		jp	p,rl_26
		inc_error_cnt
rl_26:		jp	po,rl_27
		inc_error_cnt
rl_27:		jr	c,rl_28
		inc_error_cnt
rl_28:		ld	a,(hl)
		cp	a,data_55-1
		jr	z,rl_29
		inc_error_cnt
rl_29:		ld	a,0
		ld	(hl),a
		rl	(hl)
		jr	z,rl_30
		inc_error_cnt
rl_30:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		rl	(ix-2)
		jp	m,rl_31
		inc_error_cnt
rl_31:		jp	pe,rl_32
		inc_error_cnt
rl_32:		jr	nc,rl_33
		inc_error_cnt
rl_33:		jr	nz,rl_34
		inc_error_cnt
rl_34:		rl	(ix-2)
		jp	p,rl_35
		inc_error_cnt
rl_35:		jp	po,rl_36
		inc_error_cnt
rl_36:		jr	c,rl_37
		inc_error_cnt
rl_37:		ld	a,(ix-2)
		cp	a,data_55-1
		jr	z,rl_38
		inc_error_cnt
rl_38:		ld	a,0
		ld	(ix+2),a
		rl	(ix+2)
		jr	z,rl_39
rl_39:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy-1),a
		rl	(iy-1)
		jp	m,rl_40
		inc_error_cnt
rl_40:		jp	pe,rl_41
		inc_error_cnt
rl_41:		jr	nc,rl_42
		inc_error_cnt
rl_42:		jr	nz,rl_43
		inc_error_cnt
rl_43:		rl	(iy-1)
		jp	p,rl_44
		inc_error_cnt
rl_44:		jp	po,rl_45
		inc_error_cnt
rl_45:		jr	c,rl_46
		inc_error_cnt
rl_46:		ld	a,(iy-1)
		cp	a,data_55-1
		jr	z,rl_47
		inc_error_cnt
rl_47:		ld	a,0
		ld	(iy+1),a
		rl	(iy+1)
		jr	z,rrc_0
		inc_error_cnt
rrc_0:		ld	a,data_aa
		rrc	a
		jp	p,rrc_1
		inc_error_cnt
rrc_1:		jp	pe,rrc_2
		inc_error_cnt
rrc_2:		jr	nz,rrc_3
		inc_error_cnt
rrc_3:		jr	nc,rrc_4
		inc_error_cnt
rrc_4:		rrc	a
		jp	m,rrc_5
		inc_error_cnt
rrc_5:		jr	c,rrc_6
		inc_error_cnt
rrc_6:		cp	a,data_aa
		jr	z,rrc_7
		inc_error_cnt
rrc_7:		ld	a,1
		rrc	a
		jr	c,rrc_8
		inc_error_cnt
rrc_8:		cp	a,data_80
		jr	z,rrc_9
		inc_error_cnt
rrc_9:		ld	a,data_7f
		rrc	a
		jp	po,rrc_10
		inc_error_cnt
rrc_10:		cp	a,#bf
		jr	z,rrc_11
		inc_error_cnt
rrc_11:		ld	b,data_80
		ld	c,data_55
		rrc	b
		jr	nc,rrc_12
		inc_error_cnt
rrc_12:		rrc	c
		jr	c,rrc_13
		inc_error_cnt
rrc_13:		ld	a,b
		cp	a,#40
		jr	z,rrc_14
		inc_error_cnt
rrc_14:		ld	a,c
		cp	a,data_aa
		jr	z,rrc_15
		inc_error_cnt
rrc_15:		ld	d,data_aa
		ld	e,1
		rrc	d
		jp	p,rrc_16
		inc_error_cnt
rrc_16:		rrc	e
		jp	m,rrc_17
		inc_error_cnt
rrc_17:		ld	a,d
		cp	a,data_55
		jr	z,rrc_18
		inc_error_cnt
rrc_18:		ld	a,e
		cp	a,data_80
		jr	z,rrc_19
		inc_error_cnt
rrc_19:		ld	h,data_55
		ld	l,data_ff
		rrc	h
		jr	c,rrc_20
		inc_error_cnt
rrc_20:		rrc	l
		jr	c,rrc_21
		inc_error_cnt
rrc_21:		ld	a,h
		cp	a,data_aa
		jr	z,rrc_22
		inc_error_cnt
rrc_22:		ld	a,l
		cp	a,data_ff
		jr	z,rrc_23
		inc_error_cnt
rrc_23:		ld	hl,t_var4
		ld	(hl),data_aa
		rrc	 (hl)
		jp	p,rrc_24
		inc_error_cnt
rrc_24:		jp	pe,rrc_25
		inc_error_cnt
rrc_25:		jr	nz,rrc_26
		inc_error_cnt
rrc_26:		jr	nc,rrc_27
		inc_error_cnt
rrc_27:		rrc	(hl)
		jp	m,rrc_28
		inc_error_cnt
rrc_28:		jr	c,rrc_29
		inc_error_cnt
rrc_29:		ld	a,(hl)
		cp	a,data_aa
		jr	z,rrc_30
		inc_error_cnt
rrc_30:		ld	(hl),data_7f
		rrc	(hl)
		jp	po,rrc_31
		inc_error_cnt
rrc_31:		ld	a,(hl)
		cp	a,#bf
		jr	z,rrc_32
		inc_error_cnt
rrc_32:		ld	(hl),0
		rrc	(hl)
		jr	z,rrc_33
		inc_error_cnt
rrc_33:		ld	ix,t_var3
		ld	a,data_aa
		ld	(ix+2),a
		rrc	(ix+2)
		jp	p,rrc_34
		inc_error_cnt
rrc_34:		jp	pe,rrc_35
		inc_error_cnt
rrc_35:		jr	nc,rrc_36
		inc_error_cnt
rrc_36:		jr	nz,rrc_37
		inc_error_cnt
rrc_37:		rrc	(ix+2)
		jp	m,rrc_38
		inc_error_cnt
rrc_38:		jr	c,rrc_39
		inc_error_cnt
rrc_39:		ld	a,(ix+2)
		cp	a,data_aa
		jr	z,rrc_40
		inc_error_cnt
rrc_40:		ld	a,1
		ld	(ix-2),a
		rrc	(ix-2)
		jp	po,rrc_41
		inc_error_cnt
rrc_41:		ld	a,(ix-2)
		cp	a,data_80
		jr	z,rrc_42
		inc_error_cnt
rrc_42:		ld	a,0
		ld	(ix+1),a
		rrc	(ix+1)
		jr	z,rrc_43
		inc_error_cnt
rrc_43:		ld	iy,t_var3
		ld	a,data_aa
		ld	(iy+2),a
		rrc	(iy+2)
		jp	p,rrc_44
		inc_error_cnt
rrc_44:		jp	pe,rrc_45
		inc_error_cnt
rrc_45:		jr	nc,rrc_46
		inc_error_cnt
rrc_46:		jr	nz,rrc_47
		inc_error_cnt
rrc_47:		rrc	(iy+2)
		jp	m,rrc_48
		inc_error_cnt
rrc_48:		jr	c,rrc_49
		inc_error_cnt
rrc_49:		ld	a,(iy+2)
		cp	a,data_aa
		jr	z,rrc_50
		inc_error_cnt
rrc_50:		ld	a,1
		ld	(iy-2),a
		rrc	(iy-2)
		jp	po,rrc_51
		inc_error_cnt
rrc_51:		ld	a,(iy-2)
		cp	a,data_80
		jr	z,rrc_52
		inc_error_cnt
rrc_52:		ld	a,0
		ld	(iy+1),a
		rrc	(iy+1)
		jr	z,rr_0
		inc_error_cnt
rr_0:		scf
		ccf
		ld	a,data_aa
		rr	a
		jp	p,rr_1
		inc_error_cnt
rr_1:		jp	pe,rr_2
		inc_error_cnt
rr_2:		jr	nc,rr_3
		inc_error_cnt
rr_3:		jr	nz,rr_4
		inc_error_cnt
rr_4:		rr	a
		jr	c,rr_5
		inc_error_cnt
rr_5:		jp	po,rr_6
		inc_error_cnt
rr_6:		cp	a,#2a
		jr	z,rr_7
		inc_error_cnt
rr_7:		scf
		ld	a,0
		rr	a
		jp	m,rr_8
		inc_error_cnt
rr_8:		cp	a,data_80
		jr	z,rr_9
		inc_error_cnt
rr_9:		ld	a,0
		rr	a
		jr	z,rr_10
		inc_error_cnt
rr_10:		ld	b,data_55
		ld	c,data_aa
		rr	b
		jr	c,rr_11
		inc_error_cnt
rr_11:		rr	c
		jr	nc,rr_12
		inc_error_cnt
rr_12:		ld	a,b
		cp	a,#2a
		jr	z,rr_13
		inc_error_cnt
rr_13:		ld	a,c
		cp	a,#d5
		jr	z,rr_14
		inc_error_cnt
rr_14:		ld	d,data_7f
		ld	e,data_80
		rr	d
		jr	c,rr_15
		inc_error_cnt
rr_15:		rr	e
		jr	nc,rr_16
		inc_error_cnt
rr_16:		ld	a,d
		cp	a,#3f
		jr	z,rr_17
		inc_error_cnt
rr_17:		ld	a,e
		cp	a,#c0
		jr	z,rr_18
		inc_error_cnt
rr_18:		ld	hl,t_var2
		ld	(hl),data_55
		rr	(hl)
		jp	p,rr_19
		inc_error_cnt
rr_19:		jp	po,rr_20
		inc_error_cnt
rr_20:		jr	c,rr_21
		inc_error_cnt
rr_21:		jr	nz,rr_22
		inc_error_cnt
rr_22:		rr	(hl)
		jp	m,rr_23
		inc_error_cnt
rr_23:		jp	pe,rr_24
		inc_error_cnt
rr_24:		jr	nc,rr_25
		inc_error_cnt
rr_25:		ld	a,(hl)
		cp	a,#95
		jr	z,rr_26
		inc_error_cnt
rr_26:		ld	(hl),0
		rr	(hl)
		jr	z,rr_27
		inc_error_cnt
rr_27:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		rr	(ix-2)
		jp	p,rr_28
		inc_error_cnt
rr_28:		jp	po,rr_29
		inc_error_cnt
rr_29:		jr	c,rr_30
		inc_error_cnt
rr_30:		jr	nz,rr_31
		inc_error_cnt
rr_31:		rr	(ix-2)
		jp	m,rr_32
		inc_error_cnt
rr_32:		jp	pe,rr_33
		inc_error_cnt
rr_33:		jr	nc,rr_34
		inc_error_cnt
rr_34:		ld	a,(ix-2)
		cp	a,#95
		jr	z,rr_35
		inc_error_cnt
rr_35:		ld	a,0
		ld	(ix+2),a
		rr	(ix+2)
		jr	z,rr_36
		inc_error_cnt
rr_36:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy+2),a
		rr	(iy+2)
		jp	p,rr_37
		inc_error_cnt
rr_37:		jp	po,rr_38
		inc_error_cnt
rr_38:		jr	c,rr_39
		inc_error_cnt
rr_39:		jr	nz,rr_40
		inc_error_cnt
rr_40:		rr	(iy+2)
		jp	m,rr_41
		inc_error_cnt
rr_41:		jp	pe,rr_42
		inc_error_cnt
rr_42:		jr	nc,rr_43
		inc_error_cnt
rr_43:		ld	a,(iy+2)
		cp	a,#95
		jr	z,rr_44
		inc_error_cnt
rr_44:		ld	a,0
		ld	(iy-1),a
		rr	(iy-1)
		jr	z,sla_0
		inc_error_cnt
sla_0:		ld	a,data_55
		sla	a
		jp	m,sla_1
		inc_error_cnt
sla_1:		jp	pe,sla_2
		inc_error_cnt
sla_2:		jr	nc,sla_3
		inc_error_cnt
sla_3:		jr	nz,sla_4
		inc_error_cnt
sla_4:		sla	a
		jp	p,sla_5
		inc_error_cnt
sla_5:		jp	po,sla_6
		inc_error_cnt
sla_6:		jr	c,sla_7
		inc_error_cnt
sla_7:		cp	a,data_55-1
		jr	z,sla_8
		inc_error_cnt
sla_8:		ld	a,0
		sla	a
		jr	z,sla_9
		inc_error_cnt
sla_9:		ld	b,data_80
		ld	c,data_7f
		sla	b
		jr	c,sla_10
		inc_error_cnt
sla_10:		ld	a,b
		cp	a,0
		jr	z,sla_11
		inc_error_cnt
sla_11:		sla	c
		jp	m,sla_12
		inc_error_cnt
sla_12:		ld	a,c
		cp	a,data_ff-1
		jr	z,sla_13
		inc_error_cnt
sla_13:		ld	d,data_aa
		ld	e,data_55
		sla	d
		jr	c,sla_14
		inc_error_cnt
sla_14:		ld	a,d
		cp	a,data_55-1
		jr	z,sla_15
		inc_error_cnt
sla_15:		sla	e
		jp	m,sla_16
		inc_error_cnt
sla_16:		ld	a,e
		cp	a,data_aa
		jr	z,sla_17
		inc_error_cnt
sla_17:		ld	h,#12      ;bjp was >data_1234
		ld	l,#34      ;bjp was >data_1234
		sla	h
		jp	p,sla_18
		inc_error_cnt
sla_18:		ld	a,h
		cp	a,#24
		jr	z,sla_19
		inc_error_cnt
sla_19:		sla	l
		jp	p,sla_20
		inc_error_cnt
sla_20:		ld	a,l
		cp	a,#68
		jr	z,sla_21
		inc_error_cnt
sla_21:		ld	hl,t_var3
		ld	(hl),data_55
		sla	(hl)
		jp	m,sla_22
		inc_error_cnt
sla_22:		jp	pe,sla_23
		inc_error_cnt
sla_23:		jr	nc,sla_24
		inc_error_cnt
sla_24:		jr	nz,sla_25
		inc_error_cnt
sla_25:		sla	(hl)
		jp	p,sla_26
		inc_error_cnt
sla_26:		jp	po,sla_27
		inc_error_cnt
sla_27:		jr	c,sla_28
		inc_error_cnt
sla_28:		ld	a,(hl)
		cp	a,data_55-1
		jr	z,sla_29
		inc_error_cnt
sla_29:		ld	(hl),0
		sla	(hl)
		jr	z,sla_30
		inc_error_cnt
sla_30:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		sla	(ix-2)
		jp	m,sla_31
		inc_error_cnt
sla_31:		jp	pe,sla_32
		inc_error_cnt
sla_32:		jr	nc,sla_33
		inc_error_cnt
sla_33:		jr	nz,sla_34
		inc_error_cnt
sla_34:		sla	(ix-2)
		jp	p,sla_35
		inc_error_cnt
sla_35:		jp	po,sla_36
		inc_error_cnt
sla_36:		jr	c,sla_37
		inc_error_cnt
sla_37:		ld	a,(ix-2)
		cp	a,data_55-1
		jr	z,sla_38
		inc_error_cnt
sla_38:		ld	a,data_80
		ld	(ix+2),a
		sla	(ix+2)
		jr	z,sla_39
		inc_error_cnt
sla_39:		jr	c,sla_40
		inc_error_cnt
sla_40:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy+2),a
		sla	(iy+2)
		jp	m,sla_41
		inc_error_cnt
sla_41:		jp	pe,sla_42
		inc_error_cnt
sla_42:		jr	nc,sla_43
		inc_error_cnt
sla_43:		jr	nz,sla_44
		inc_error_cnt
sla_44:		sla	(iy+2)
		jp	p,sla_45
		inc_error_cnt
sla_45:		jp	po,sla_46
		inc_error_cnt
sla_46:		jr	c,sla_47
		inc_error_cnt
sla_47:		ld	a,(iy+2)
		cp	a,data_55-1
		jr	z,sla_48
		inc_error_cnt
sla_48:		ld	a,data_80
		ld	(iy-2),a
		sla	(iy-2)
		jr	z,sla_49
		inc_error_cnt
sla_49:		jr	c,sra_0
		inc_error_cnt
sra_0:		ld	a,data_55
		sra	a
		jp	p,sra_1
		inc_error_cnt
sra_1:		jp	po,sra_2
		inc_error_cnt
sra_2:		jr	c,sra_3
		inc_error_cnt
sra_3:		jr	nz,sra_4
		inc_error_cnt
sra_4:		sra	a
		jp	po,sra_5
		inc_error_cnt
sra_5:		jr	nc,sra_6
		inc_error_cnt
sra_6:		sra	a
		jp	pe,sra_7
		inc_error_cnt
sra_7:		cp	a,#0a			;data_aa.and.#0f
		jr	z,sra_8
		inc_error_cnt
sra_8:		ld	a,1
		sra	a
		jr	c,sra_9
		inc_error_cnt
sra_9:		jr	z,sra_10
		inc_error_cnt
sra_10:		ld	a,data_80
		sra	a
		jp	m,sra_11
		inc_error_cnt
sra_11:		cp	a,#c0
		jr	z,sra_12
		inc_error_cnt
sra_12:		ld	b,data_7f
		ld	c,data_aa
		sra	b
		jr	c,sra_13
		inc_error_cnt
sra_13:		ld	a,b
		cp	a,#3f
		jr	z,sra_14
		inc_error_cnt
sra_14:		sra	c
		jr	nc,sra_15
		inc_error_cnt
sra_15:		ld	a,c
		cp	a,#d5
		jr	z,sra_16
		inc_error_cnt
sra_16:		ld	d,data_55
		ld	e,data_ff
		sra	d
		jr	c,sra_17
		inc_error_cnt
sra_17:		ld	a,d
		cp	a,#2a
		jr	z,sra_18
		inc_error_cnt
sra_18:		sra	e
		jp	m,sra_19
		inc_error_cnt
sra_19:		ld	a,e
		cp	a,data_ff
		jr	z,sra_20
		inc_error_cnt
sra_20:		ld	h,data_aa
		ld	l,data_7f
		sra	h
		jp	m,sra_21
		inc_error_cnt
sra_21:		ld	a,h
		cp	a,#d5
		jr	z,sra_22
		inc_error_cnt
sra_22:		sra	l
		jr	c,sra_23
		inc_error_cnt
sra_23:		ld	a,l
		cp	a,#3f
		jr	z,sra_24
		inc_error_cnt
sra_24:		ld	hl,t_var1
		ld	(hl),data_55
		sra	(hl)
		jp	p,sra_25
		inc_error_cnt
sra_25:		jp	po,sra_26
		inc_error_cnt
sra_26:		jr	c,sra_27
		inc_error_cnt
sra_27:		jr	nz,sra_28
		inc_error_cnt
sra_28:		sra	(hl)
		jr	nc,sra_29
		inc_error_cnt
sra_29:		sra	(hl)
		jp	pe,sra_30
		inc_error_cnt
sra_30:		ld	a,(hl)
		cp	a,#0a			;data_aa.and.#0f
		jr	z,sra_31
		inc_error_cnt
sra_31:		ld	(hl),data_80
		sra	(hl)
		jp	m,sra_32
		inc_error_cnt
sra_32:		ld	a,(hl)
		cp	a,#c0
		jr	z,sra_33
		inc_error_cnt
sra_33:		ld	(hl),1
		sra	(hl)
		jr	c,sra_34
		inc_error_cnt
sra_34:		jr	z,sra_35
		inc_error_cnt
sra_35:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix-2),a
		sra	(ix-2)
		jp	p,sra_36
		inc_error_cnt
sra_36:		jp	po,sra_37
		inc_error_cnt
sra_37:		jr	c,sra_38
		inc_error_cnt
sra_38:		jr	nz,sra_39
		inc_error_cnt
sra_39:		sra	(ix-2)
		jr	nc,sra_40
		inc_error_cnt
sra_40:		sra	(ix-2)
		jp	pe,sra_41
		inc_error_cnt
sra_41:		ld	a,(ix-2)
		cp	a,#0a		;data_aa.and.#0f
		jr	z,sra_42
		inc_error_cnt
sra_42:		ld	a,data_80
		ld	(ix+2),a
		sra	(ix+2)
		jp	m,sra_43
		inc_error_cnt
sra_43:		ld	a,(ix+2)
		cp	a,#c0
		jr	z,sra_44
		inc_error_cnt
sra_44:		ld	a,1
		ld	(ix-1),a
		sra	(ix-1)
		jr	c,sra_45
		inc_error_cnt
sra_45:		jr	z,sra_46
		inc_error_cnt
sra_46:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy-2),a
		sra	(iy-2)
		jp	p,sra_47
		inc_error_cnt
sra_47:		jp	po,sra_48
		inc_error_cnt
sra_48:		jr	c,sra_49
		inc_error_cnt
sra_49:		jr	nz,sra_50
		inc_error_cnt
sra_50:		sra	(iy-2)
		jr	nc,sra_51
		inc_error_cnt
sra_51:		sra	(iy-2)
		jp	pe,sra_52
		inc_error_cnt
sra_52:		ld	a,(iy-2)
		cp	a,#0a		;data_aa.and.#0f
		jr	z,sra_53
		inc_error_cnt
sra_53:		ld	a,data_80
		ld	(iy+2),a
		sra	(iy+2)
		jp	m,sra_54
		inc_error_cnt
sra_54:		ld	a,(iy+2)
		cp	a,#c0
		jr	z,sra_55
		inc_error_cnt
sra_55:		ld	a,1
		ld	(iy-1),a
		sra	(iy-1)
		jr	c,sra_56
		inc_error_cnt
sra_56:		jr	z,srl_0
		inc_error_cnt
srl_0:		ld	a,data_55
		srl	a
		jr	c,srl_1
		inc_error_cnt
srl_1:		jp	po,srl_2
		inc_error_cnt
srl_2:		srl	a
		jr	nc,srl_3
		inc_error_cnt
srl_3:		srl	a
		jp	pe,srl_4
		inc_error_cnt
srl_4:		cp	a,#0a			;data_aa.and.#0f
		jr	z,srl_5
		inc_error_cnt
srl_5:		ld	a,data_80
		and	a
		jp	m,srl_6
		inc_error_cnt
srl_6:		srl	a
		jp	p,srl_7
		inc_error_cnt
srl_7:		ld	a,2
		srl	a
		jr	nz,srl_8
		inc_error_cnt
srl_8:		srl	a
		jr	z,srl_9
		inc_error_cnt
srl_9:		jr	c,srl_10
		inc_error_cnt
srl_10:		ld	b,data_aa
		srl	b
		jp	p,srl_11
		inc_error_cnt
srl_11:		ld	a,b
		cp	a,data_55
		jr	z,srl_12
		inc_error_cnt
srl_12:		ld	c,data_7f
		srl	c
		jr	c,srl_13
		inc_error_cnt
srl_13:		ld	a,c
		cp	a,#3f
		jr	z,srl_14
		inc_error_cnt
srl_14:		ld	d,data_55
		srl	d
		jr	c,srl_15
		inc_error_cnt
srl_15:		ld	a,d
		cp	a,#2a
		jr	z,srl_16
		inc_error_cnt
srl_16:		ld	e,data_ff
		srl	e
		jr	c,srl_17
		inc_error_cnt
srl_17:		ld	a,e
		cp	a,data_7f
		jr	z,srl_18
		inc_error_cnt
srl_18:		ld	h,#12      ;bjp was >data_1234
		srl	h
		jr	nc,srl_19
		inc_error_cnt
srl_19:		ld	a,h
		cp	a,9
		jr	z,srl_20
		inc_error_cnt
srl_20:		ld	l,#34      ;bjp was >data_1234
		srl	l
		jr	nc,srl_21
		inc_error_cnt
srl_21:		ld	a,l
		cp	a,#1a
		jr	z,srl_22
		inc_error_cnt
srl_22:		ld	hl,t_var1
		ld	(hl),data_55
		srl	(hl)
		jr	c,srl_23
		inc_error_cnt
srl_23:		jp	po,srl_24
		inc_error_cnt
srl_24:		srl	(hl)
		jr	nc,srl_25
		inc_error_cnt
srl_25:		srl	(hl)
		jp	pe,srl_26
		inc_error_cnt
srl_26:		ld	a,(hl)
		cp	a,#0a			;data_aa.and.#0f
		jr	z,srl_27
		inc_error_cnt
srl_27:		ld	(hl),data_80
		and	(hl)
		jp	z,srl_28
		inc_error_cnt
srl_28:		srl	(hl)
		jp	p,srl_29
		inc_error_cnt
srl_29:		ld	a,(hl)
		cp	a,#40
		jr	z,srl_30
		inc_error_cnt
srl_30:		ld	(hl),2
		srl	(hl)
		jr	nz,srl_31
		inc_error_cnt
srl_31:		srl	(hl)
		jr	z,srl_32
		inc_error_cnt
srl_32:		jr	c,srl_33
		inc_error_cnt
srl_33:		ld	ix,t_var3
		ld	a,data_55
		ld	(ix+2),a
		srl	(ix+2)
		jr	c,srl_34
		inc_error_cnt
srl_34:		jp	po,srl_35
		inc_error_cnt
srl_35:		srl	(ix+2)
		jr	nc,srl_36
		inc_error_cnt
srl_36:		srl	(ix+2)
		jp	pe,srl_37
		inc_error_cnt
srl_37:		ld	a,(ix+2)
		cp	a,#0a			;data_aa.and.#0f
		jr	z,srl_38
		inc_error_cnt
srl_38:		ld	a,data_80
		ld	(ix-2),a
		and	(ix-2)
		jp	m,srl_39
		inc_error_cnt
srl_39:		srl	(ix-2)
		jp	p,srl_40
		inc_error_cnt
srl_40:		ld	a,(ix-2)
		cp	a,#40
		jr	z,srl_41
		inc_error_cnt
srl_41:		ld	a,2
		ld	(ix+1),a
		srl	(ix+1)
		jr	nz,srl_42
		inc_error_cnt
srl_42:		srl	(ix+1)
		jr	z,srl_43
		inc_error_cnt
srl_43:		jr	c,srl_44
		inc_error_cnt
srl_44:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy+2),a
		srl	(iy+2)
		jr	c,srl_45
		inc_error_cnt
srl_45:		jp	po,srl_46
		inc_error_cnt
srl_46:		srl	(iy+2)
		jr	nc,srl_47
		inc_error_cnt
srl_47:		srl	(iy+2)
		jp	pe,srl_48
		inc_error_cnt
srl_48:		ld	a,(iy+2)
		cp	a,#0a			;data_aa.and.#0f
		jr	z,srl_49
		inc_error_cnt
srl_49:		ld	a,data_80
		ld	(iy-2),a
		and	(iy-2)
		jp	m,srl_50
		inc_error_cnt
srl_50:		srl	(iy-2)
		jp	p,srl_51
		inc_error_cnt
srl_51:		ld	a,(iy-2)
		cp	a,#40
		jr	z,srl_52
		inc_error_cnt
srl_52:		ld	a,2
		ld	(iy+1),a
		srl	(iy+1)
		jr	nz,srl_53
		inc_error_cnt
srl_53:		srl	(iy+1)
		jr	z,srl_54
		inc_error_cnt
srl_54:		jr	c,rld_0
		inc_error_cnt
rld_0:		ld	hl,t_var5
		ld	a,data_55
		ld	(hl),data_aa
		rld
		jp	p,rld_1
		inc_error_cnt
rld_1:		cp	a,data_55+5
		jr	z,rld_2
		inc_error_cnt
rld_2:		ld	a,(hl)
		cp	a,data_aa-5
		jr	z,rld_3
		inc_error_cnt
rld_3:		ld	(hl),data_7f
		ld	a,data_80
		rld
		jp	m,rld_4
		inc_error_cnt
rld_4:		jp	pe,rld_5
		inc_error_cnt
rld_5:		rld
		jp	po,rld_6
		inc_error_cnt
rld_6:		cp	a,data_80+15
		jr	z,rld_7
		inc_error_cnt
rld_7:		ld	a,(hl)
		cp	a,7
		jr	z,rld_8
		inc_error_cnt
rld_8:		ld	a,#05			;data_55.and.#0f
		ld	(hl),#0a			;data_aa.and.#0f
		rld
		jr	z,rld_9
		inc_error_cnt
rld_9:		ld	a,(hl)
		cp	a,#a5
		jr	z,rrd_0
		inc_error_cnt
rrd_0:		ld	hl,t_var3
		ld	a,data_55
		ld	(hl),data_aa
		rrd
		jp	p,rrd_1
		inc_error_cnt
rrd_1:		jp	pe,rrd_2
		inc_error_cnt
rrd_2:		jr	nz,rrd_3
		inc_error_cnt
rrd_3:		cp	a,data_55+5
		jr	z,rrd_4
		inc_error_cnt
rrd_4:		ld	a,(hl)
		cp	a,data_55+5
		jr	z,rrd_5
		inc_error_cnt
rrd_5:		ld	(hl),data_7f
		ld	a,data_80
		rrd
		jp	m,rrd_6
		inc_error_cnt
rrd_6:		jp	po,rrd_7
		inc_error_cnt
rrd_7:		cp	a,data_80+15
		jr	z,rrd_8
		inc_error_cnt
rrd_8:		ld	a,(hl)
		cp	a,7
		jr	z,rrd_9
		inc_error_cnt
rrd_9:		ld	a,8
		ld	(hl),0
		rrd
		jr	z,rrd_10
		inc_error_cnt
rrd_10:		ld	a,(hl)
		cp	a,data_80
		jr	z,bit_0
		inc_error_cnt
bit_0:		ld	a,data_ff
		bit	0,a
		jr	nz,bit_1
		inc_error_cnt
bit_1:		bit	1,a
		jr	nz,bit_2
		inc_error_cnt
bit_2:		bit	2,a
		jr	nz,bit_3
		inc_error_cnt
bit_3:		bit	3,a
		jr	nz,bit_4
		inc_error_cnt
bit_4:		bit	4,a
		jr	nz,bit_5
		inc_error_cnt
bit_5:		bit	5,a
		jr	nz,bit_6
		inc_error_cnt
bit_6:		bit	6,a
		jr	nz,bit_7
		inc_error_cnt
bit_7:		bit	7,a
		jr	nz,bit_8
		inc_error_cnt
bit_8:		ld	a,0
		bit	0,a
		jr	z,bit_9
		inc_error_cnt
bit_9:		bit	1,a
		jr	z,bit_10
		inc_error_cnt
bit_10:		bit	2,a
		jr	z,bit_11
		inc_error_cnt
bit_11:		bit	3,a
		jr	z,bit_12
		inc_error_cnt
bit_12:		bit	4,a
		jr	z,bit_13
		inc_error_cnt
bit_13:		bit	5,a
		jr	z,bit_14
		inc_error_cnt
bit_14:		bit	6,a
		jr	z,bit_15
		inc_error_cnt
bit_15:		bit	7,a
		jr	z,bit_16
		inc_error_cnt
bit_16:		ld	b,data_80
		bit	2,b
		jr	z,bit_17
		inc_error_cnt
bit_17:		bit	7,b
		jr	nz,bit_18
		inc_error_cnt
bit_18:		ld	c,data_55
		bit	7,c
		jr	z,bit_19
		inc_error_cnt
bit_19:		bit	0,c
		jr	nz,bit_20
		inc_error_cnt
bit_20:		ld	d,data_aa
		bit	7,d
		jr	nz,bit_21
		inc_error_cnt
bit_21:		bit	4,d
		jr	z,bit_22
		inc_error_cnt
bit_22:		ld	e,data_7f
		bit	7,e
		jr	z,bit_23
		inc_error_cnt
bit_23:		bit	3,e
		jr	nz,bit_24
		inc_error_cnt
bit_24:		ld	h,#12      ;bjp was >data_1234
		bit	4,h
		jr	nz,bit_25
		inc_error_cnt
bit_25:		bit	2,h
		jr	z,bit_26
		inc_error_cnt
bit_26:		ld	l,#34      ;bjp was >data_1234
		bit	3,l
		jr	z,bit_27
		inc_error_cnt
bit_27:		bit	2,l
		jr	nz,bit_28
		inc_error_cnt
bit_28:		ld	hl,t_var4
		ld	(hl),data_55
		bit	0,(hl)
		jr	nz,bit_29
		inc_error_cnt
bit_29:		bit	1,(hl)
		jr	z,bit_30
		inc_error_cnt
bit_30:		bit	2,(hl)
		jr	nz,bit_31
		inc_error_cnt
bit_31:		bit	3,(hl)
		jr	z,bit_32
		inc_error_cnt
bit_32:		bit	4,(hl)
		jr	nz,bit_33
		inc_error_cnt
bit_33:		bit	5,(hl)
		jr	z,bit_34
		inc_error_cnt
bit_34:		bit	6,(hl)
		jr	nz,bit_35
		inc_error_cnt
bit_35:		bit	7,(hl)
		jr	z,bit_36
		inc_error_cnt
bit_36:		ld	ix,t_var3
		ld	a,data_aa
		ld	(ix-2),a
		bit	0,(ix-2)
		jr	z,bit_37
		inc_error_cnt
bit_37:		bit	1,(ix-2)
		jr	nz,bit_38
		inc_error_cnt
bit_38:		bit	2,(ix-2)
		jr	z,bit_39
		inc_error_cnt
bit_39:		bit	3,(ix-2)
		jr	nz,bit_40
		inc_error_cnt
bit_40:		bit	4,(ix-2)
		jr	z,bit_41
		inc_error_cnt
bit_41:		bit	5,(ix-2)
		jr	nz,bit_42
		inc_error_cnt
bit_42:		bit	6,(ix-2)
		jr	z,bit_43
		inc_error_cnt
bit_43:		bit	7,(ix-2)
		jr	nz,bit_44
		inc_error_cnt
bit_44:		ld	iy,t_var3
		ld	a,data_55
		ld	(iy+2),a
		bit	0,(iy+2)
		jr	nz,bit_45
		inc_error_cnt
bit_45:		bit	1,(iy+2)
		jr	z,bit_46
		inc_error_cnt
bit_46:		bit	2,(iy+2)
		jr	nz,bit_47
		inc_error_cnt
bit_47:		bit	3,(iy+2)
		jr	z,bit_48
		inc_error_cnt
bit_48:		bit	4,(iy+2)
		jr	nz,bit_49
		inc_error_cnt
bit_49:		bit	5,(iy+2)
		jr	z,bit_50
		inc_error_cnt
bit_50:		bit	6,(iy+2)
		jr	nz,bit_51
		inc_error_cnt
bit_51:		bit	7,(iy+2)
		jr	z,set_0
		inc_error_cnt
set_0:		ld	a,0
		set	0,a
		set	2,a
		set	4,a
		set	6,a
		cp	a,data_55
		jr	z,set_1
		inc_error_cnt
set_1:		set	1,a
		set	3,a
		set	5,a
		set	7,a
		cp	a,data_ff
		jr	z,set_2
		inc_error_cnt
set_2:		ld	b,0
		set	1,b
		set	3,b
		ld	a,b
		cp	a,#0a			;data_aa.and.#0f
		jr	z,set_3
		inc_error_cnt
set_3:		ld	c,0
		set	1,c
		set	4,c
		ld	a,c
		cp	a,#12      ;bjp was >data_1234
		jr	z,set_4
		inc_error_cnt
set_4:		ld	d,0
		set	2,d
		set	4,d
		set	5,d
		ld	a,d
		cp	a,#34      ;bjp was >data_1234
		jr	z,set_5
		inc_error_cnt
set_5:		ld	e,0
		set	7,e
		ld	a,e
		cp	a,data_80
		jr	z,set_6
		inc_error_cnt
set_6:		ld	h,0
		set	0,h
		set	2,h
		set	4,h
		set	6,h
		ld	a,h
		cp	a,data_55
		jr	z,set_7
		inc_error_cnt
set_7:		ld	l,0
		set	1,l
		set	3,l
		set	5,l
		set	7,l
		ld	a,l
		cp	a,data_aa
		jr	z,set_8
		inc_error_cnt
set_8:		ld	hl,t_var5
		ld	(hl),0
		set	0,(hl)
		set	2,(hl)
		set	4,(hl)
		set	6,(hl)
		ld	a,(hl)
		cp	a,data_55
		jr	z,set_9
		inc_error_cnt
set_9:		ld	(hl),0
		set	1,(hl)
		set	3,(hl)
		set	5,(hl)
		set	7,(hl)
		ld	a,(hl)
		cp	a,data_aa
		jr	z,set_10
		inc_error_cnt
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
		inc_error_cnt
set_11:		set	1,(ix+2)
		set	3,(ix+2)
		set	5,(ix+2)
		set	7,(ix+2)
		ld	a,(ix+2)
		cp	a,data_aa
		jr	z,set_12
		inc_error_cnt
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
		inc_error_cnt
set_13:		set	1,(iy+1)
		set	3,(iy+1)
		set	5,(iy+1)
		set	7,(iy+1)
		ld	a,(iy+1)
		cp	a,data_aa
		jr	z,res_0
		inc_error_cnt
res_0:		ld	a,data_ff
		res	7,a
		cp	a,data_7f
		jr	z,res_1
		inc_error_cnt
res_1:		res	5,a
		res	3,a
		res	1,a
		cp	a,data_55
		jr	z,res_2
		inc_error_cnt
res_2:		ld	a,data_ff
		res	0,a
		res	2,a
		res	4,a
		res	6,a
		cp	a,data_aa
		jr	z,res_3
		inc_error_cnt
res_3:		ld	b,data_ff
		res	7,b
		ld	a,b
		cp	a,data_7f
		jr	z,res_4
		inc_error_cnt
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
		inc_error_cnt
res_5:		ld	d,data_ff
		res	0,d
		res	2,d
		res	4,d
		res	6,d
		ld	a,d
		cp	a,data_aa
		jr	z,res_6
		inc_error_cnt
res_6:		ld	e,data_ff
		res	1,e
		res	3,e
		res	5,e
		res	7,e
		ld	a,e
		cp	a,data_55
		jr	z,res_7
		inc_error_cnt
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
		inc_error_cnt
res_8:		ld	l,data_ff
		res	0,l
		res	1,l
		res	3,l
		res	6,l
		res	7,l
		ld	a,l
		cp	a,#34      ;bjp was >data_1234
		jr	z,res_9
		inc_error_cnt
res_9:		ld	hl,t_var3
		ld	(hl),data_ff
		res	0,(hl)
		res	2,(hl)
		res	4,(hl)
		res	6,(hl)
		ld	a,(hl)
		cp	a,data_aa
		jr	z,res_10
		inc_error_cnt
res_10:		res	1,(hl)
		res	3,(hl)
		res	5,(hl)
		res	7,(hl)
		ld	a,(hl)
		cp	a,0
		jr	z,res_11
		inc_error_cnt
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
		inc_error_cnt
res_12:		res	0,(ix+2)
		res	2,(ix+2)
		res	4,(ix+2)
		res	6,(ix+2)
		ld	a,(ix+2)
		cp	a,data_aa
		jr	z,res_13
		inc_error_cnt
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
		inc_error_cnt
res_14:		res	0,(iy+1)
		res	2,(iy+1)
		res	4,(iy+1)
		res	6,(iy+1)
		ld	a,(iy+1)
		cp	a,data_aa
		jr	z,jp_0
		inc_error_cnt
jp_0:		jp	jp_1
		nop
		nop
		inc_error_cnt
jp_1:		ld	a,0
		and	a
		jp	z,jp_2
		inc_error_cnt
jp_2:		jp	nc,jp_3
		inc_error_cnt
jp_3:		ld	b,1
		sub	a,b
		jp	nz,jp_4
		inc_error_cnt
jp_4:		jp	c,jp_5
		inc_error_cnt
jp_5:		jp	jp_7
		inc_error_cnt
jp_6:		jp	jr_0
		inc_error_cnt
jp_7:		jp	jp_6
		inc_error_cnt
jr_0:		jr	jr_2
		inc_error_cnt
jr_1:		jr	jr_3
		inc_error_cnt
jr_2:		jr	jr_1
		inc_error_cnt
jr_3:		ld	hl,jp_9
		jp	(hl)
		inc_error_cnt
jp_8:		ld	ix,jp_10
		jp	(ix)
		inc_error_cnt
jp_9:		jp	jp_8
		inc_error_cnt
jp_10:		ld	iy,djnz_0
		jp	(iy)
		inc_error_cnt
djnz_0:		ld	b,5
		ld	a,0
djnz_1:		inc	a
		djnz	djnz_1
		cp	a,5
		jr	z,call_0
		inc_error_cnt
call_0:		ld	a,0
		call	sub1
		cp	a,data_7f
		jr	z,call_1
		inc_error_cnt
call_1:		ld	a,0
		and	a
		call	z,sub2
		cp	a,data_55
		jr	z,call_2
		inc_error_cnt
call_2:		ld	a,data_aa
		and	a
		call	nz,sub3
		cp	a,data_aa+1
		jr	z,call_3
		inc_error_cnt
call_3:		ld	a,0
		cp	a,0
		call	nc,sub4
		cp	a,data_ff
		jr	z,call_4
		inc_error_cnt
call_4:		ld	a,0
		sub	a,1
		call	c,sub5
		cp	a,data_ff-1
		jr	z,call_5
		inc_error_cnt
call_5:		ld	a,data_7f
		sla	a
		call	po,sub6
		cp	a,data_7f
		jr	z,call_6
		inc_error_cnt
call_6:		ld	a,data_aa
		srl	a
		call	pe,sub7
		cp	a,data_aa
		jr	z,call_7
		inc_error_cnt
call_7:		ld	a,data_80
		sra	a
		call	m,sub8
		cp	a,data_80
		jr	z,call_8
		inc_error_cnt
call_8:		ld	a,data_7f
		sra	a
		call	p,sub9
		cp	a,data_7f
		jr	z,rst_0
		inc_error_cnt
rst_0:		rst	#00
		cp	a,1
		jr	z,rst_1
		inc_error_cnt
rst_1:		rst	#08
		cp	a,2
		jr	z,rst_2
		inc_error_cnt
rst_2:		rst	#10
		cp	a,3
		jr	z,rst_3
		inc_error_cnt
rst_3:		rst	#18
		cp	a,4
		jr	z,rst_4
		inc_error_cnt
rst_4:		rst	#20
		cp	a,5
		jr	z,rst_5
		inc_error_cnt
rst_5:		rst	#28
		cp	a,6
		jr	z,rst_6
		inc_error_cnt
rst_6:		rst	#30
		cp	a,7
		jr	z,rst_7
		inc_error_cnt
rst_7:		rst	#38
		cp	a,8
		jr	z,in_0
		inc_error_cnt
in_0:		in	a,(in_port)
		cp	a,data_7f
		jr	z,in_1
		inc_error_cnt
in_1:		ld	c,in_port
		in	a,(c)
		jr	nz,in_2
		inc_error_cnt
in_2:		jp	p,in_3
		inc_error_cnt
in_3:		jp	pe,in_4
		inc_error_cnt
in_4:		cp	a,data_55
		jr	z,in_5
		inc_error_cnt
in_5:		in	a,(c)
		jp	m,in_6
		inc_error_cnt
in_6:		jp	po,in_7
		inc_error_cnt
in_7:		jr	nz,in_8
		inc_error_cnt
in_8:		cp	a,data_80
		jr	z,in_9
		inc_error_cnt
in_9:		in	a,(c)
		jr	z,in_10
		inc_error_cnt
in_10:		in	b,(c)
		jp	m,in_11
		inc_error_cnt
in_11:		ld	a,b
		cp	a,data_ff
		jr	z,in_12
		inc_error_cnt
in_12:		in	d,(c)
		jp	pe,in_13
		inc_error_cnt
in_13:		ld	a,d
		cp	a,data_aa
		jr	z,in_14
		inc_error_cnt
in_14:		in	e,(c)
		jp	p,in_15
		inc_error_cnt
in_15:		ld	a,e
		cp	a,data_7f
		jr	z,in_16
		inc_error_cnt
in_16:		in	h,(c)
		jp	pe,in_17
		inc_error_cnt
in_17:		ld	a,h
		cp	a,data_55
		jr	z,in_18
		inc_error_cnt
in_18:		in	l,(c)
		jp	m,in_19
		inc_error_cnt
in_19:		ld	a,l
		cp	a,data_80
		jr	z,in_20
		inc_error_cnt
in_20:		in	c,(c)
		jr	z,in_21
		inc_error_cnt
in_21:		ld	c,in_port
		ld	b,2
		ld	hl,t_var1
		ini
		jr	nz,in_22
		inc_error_cnt
in_22:		ini
		jr	z,in_23
		inc_error_cnt
in_23:		ld	hl,t_var1
		ld	a,(hl)
		cp	a,data_ff
		jr	z,in_24
		inc_error_cnt
in_24:		inc	hl
		ld	a,(hl)
		cp	a,data_aa
		jr	z,in_25
		inc_error_cnt
in_25:		ld	b,5
		ld	c,in_port
		ld	hl,t_var1
		inir
		jr	z,in_26
		inc_error_cnt
in_26:		ld	hl,t_var1
		ld	a,(hl)
		cp	a,data_7f
		jr	z,in_27
		inc_error_cnt
in_27:		inc	hl
		ld	a,(hl)
		cp	a,data_55
		jr	z,in_28
		inc_error_cnt
in_28:		inc	hl
		ld	a,(hl)
		cp	a,data_80
		jr	z,in_29
		inc_error_cnt
in_29:		inc	hl
		ld	a,(hl)
		cp	a,0
		jr	z,in_30
		inc_error_cnt
in_30:		inc	hl
		ld	a,(hl)
		cp	a,data_ff
		jr	z,in_31
		inc_error_cnt
in_31:		ld	b,2
		ld	c,in_port
		ld	hl,t_var5
		ind
		jr	nz,in_32
		inc_error_cnt
in_32:		ind
		jr	z,in_33
		inc_error_cnt
in_33:		ld	hl,t_var5
		ld	a,(hl)
		cp	a,data_aa
		jr	z,in_34
		inc_error_cnt
in_34:		dec	hl
		ld	a,(hl)
		cp	a,data_7f
		jr	z,in_35
		inc_error_cnt
in_35:		ld	b,5
		ld	c,in_port
		ld	hl,t_var5
		indr
		jr	z,in_36
		inc_error_cnt
in_36:		ld	hl,t_var5
		ld	a,(hl)
		cp	a,data_55
		jr	z,in_37
		inc_error_cnt
in_37:		dec	hl
		ld	a,(hl)
		cp	a,data_80
		jr	z,in_38
		inc_error_cnt
in_38:		dec	hl
		ld	a,(hl)
		cp	a,0
		jr	z,in_39
		inc_error_cnt
in_39:		dec	hl
		ld	a,(hl)
		cp	a,data_ff
		jr	z,in_40
		inc_error_cnt
in_40:		dec	hl
		ld	a,(hl)
		cp	a,data_aa
		jr	z,in_41
		inc_error_cnt
		; 10,09,2007  Test for Howard Hart's IN bug
in_41:		ld	hl, t_var1
		ld	a, #34       ; something not in the input sequencer
		in 	a,(in_port)
		ld	(hl), a      ; 10/12/2007 previously this instruction got skipped
		ld	a, #34
		ld 	a,(hl)
		cp      a,data_7f
		jr	z,ldi_0
		inc_error_cnt
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
		inc_error_cnt
ldi_1:		ldi
		jp	po,ldi_2
		inc_error_cnt
ldi_2:		ld	hl,t_var3
		ld	a,(hl)
		cp	a,#12      ;bjp was >data_1234
		jr	z,ldi_3
		inc_error_cnt
ldi_3:		inc	hl
		ld	a,(hl)
		cp	a,#34      ;bjp was >data_1234
		jr	z,ldir_0
		inc_error_cnt
ldir_0:		ld	hl,var1
		ld	de,t_var1
		ld	bc,5
		ei                 ;bjp  be sure we can interrupt this instruction
		ldir
		jp	po,ldir_1
		inc_error_cnt
ldir_1:		ld	hl,t_var1
		ld	a,(hl)
		cp	a,data_ff
		jr	z,ldir_2
		inc_error_cnt
ldir_2:		inc	hl
		ld	a,(hl)
		cp	a,data_55
		jr	z,ldir_3
		inc_error_cnt
ldir_3:		inc	hl
		ld	a,(hl)
		cp	a,data_80
		jr	z,ldir_4
		inc_error_cnt
ldir_4:		inc	hl
		ld	a,(hl)
		cp	a,data_aa
		jr	z,ldir_5
		inc_error_cnt
ldir_5:		inc	hl
		ld	a,(hl)
		cp	a,data_7f
		jr	z,ldd_0
		inc_error_cnt
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
		inc_error_cnt
ldd_1:		ldd
		jp	po,ldd_2
		inc_error_cnt
ldd_2:		ld	hl,t_var3
		ld	a,(hl)
		cp	a,#12      ;bjp was >data_1234
		jr	z,ldd_3
		inc_error_cnt
ldd_3:		dec	hl
		ld	a,(hl)
		cp	a,#34      ;bjp was >data_1234
		jr	z,lddr_0
		inc_error_cnt
lddr_0:		ld	bc,5
		ld	hl,var5
		ld	de,t_var5
		lddr
		jp	po,lddr_1
		inc_error_cnt
lddr_1:		ld	hl,t_var1
		ld	a,(hl)
		cp	a,data_ff
		jr	z,lddr_2
		inc_error_cnt
lddr_2:		inc	hl
		ld	a,(hl)
		cp	a,data_55
		jr	z,lddr_3
		inc_error_cnt
lddr_3:		inc	hl
		ld	a,(hl)
		cp	a,data_80
		jr	z,lddr_4
		inc_error_cnt
lddr_4:		inc	hl
		ld	a,(hl)
		cp	a,data_aa
		jr	z,lddr_5
		inc_error_cnt
lddr_5:		inc	hl
		ld	a,(hl)
		cp	a,data_7f
		jr	z,cpi_0
		inc_error_cnt
cpi_0:		ld	hl,t_var1
		ld	bc,5
		ld	a,data_7f
		cpi
		jp	pe,cpi_1
		inc_error_cnt
cpi_1:		jp	m,cpi_2
		inc_error_cnt
cpi_2:		jr	nz,cpi_3
		inc_error_cnt
cpi_3:		cpi
		jp	pe,cpi_4
		inc_error_cnt
cpi_4:		jp	p,cpi_5
		inc_error_cnt
cpi_5:		jr	nz,cpi_6
		inc_error_cnt
cpi_6:		cpi
		jp	pe,cpi_7
		inc_error_cnt
cpi_7:		jp	m,cpi_8
		inc_error_cnt
cpi_8:		jr	nz,cpi_9
		inc_error_cnt
cpi_9:		cpi
		jp	pe,cpi_10
		inc_error_cnt
cpi_10:		jp	m,cpi_11
		inc_error_cnt
cpi_11:		jr	nz,cpi_12
		inc_error_cnt
cpi_12:		cpi
		jp	po,cpi_13
		inc_error_cnt
cpi_13:		jp	p,cpi_14
		inc_error_cnt
cpi_14:		jr	z,cpir_0
		inc_error_cnt
cpir_0:		ld	a,data_aa
		ld	hl,var1
		ld	bc,5
		cpir
		jr	z,cpir_1
		inc_error_cnt
cpir_1:		jp	pe,cpir_2
		inc_error_cnt
cpir_2:		ld	a,b
		cp	a,0
		jr	z,cpir_3
		inc_error_cnt
cpir_3:		ld	a,c
		cp	a,1
		jr	z,cpir_4
		inc_error_cnt
cpir_4:		ld	a,data_7f
		ld	hl,var1
		ld	bc,5
		cpir
		jp	po,cpir_5
		inc_error_cnt
cpir_5:		jr	z,cpir_6
		inc_error_cnt
cpir_6:		ld	a,#34      ;bjp was >data_1234
		ld	hl,var1
		ld	bc,5
		cpir
		jp	po,cpir_7
		inc_error_cnt
cpir_7:		jr	nz,cpir_8
		inc_error_cnt
cpir_8:		jp	m,cpir_9
		inc_error_cnt
cpir_9:		ld	a,data_aa
		ld	hl,var1
		ld	bc,3
		cpir
		jp	po,cpir_10
		inc_error_cnt
cpir_10:	jp	p,cpir_11
		inc_error_cnt
cpir_11:	jr	nz,cpd_0
		inc_error_cnt
cpd_0:		ld	a,data_ff
		ld	hl,var5
		ld	bc,5
		cpd
		jp	m,cpd_1
		inc_error_cnt
cpd_1:		jp	pe,cpd_2
		inc_error_cnt
cpd_2:		jr	nz,cpd_3
		inc_error_cnt
cpd_3:		cpd
		jp	p,cpd_4
		inc_error_cnt
cpd_4:		jp	pe,cpd_5
		inc_error_cnt
cpd_5:		jr	nz,cpd_6
		inc_error_cnt
cpd_6:		cpd
		jp	p,cpd_7
		inc_error_cnt
cpd_7:		jp	pe,cpd_8
		inc_error_cnt
cpd_8:		jr	nz,cpd_9
		inc_error_cnt
cpd_9:		cpd
		jp	m,cpd_10
		inc_error_cnt
cpd_10:		jp	pe,cpd_11
		inc_error_cnt
cpd_11:		jr	nz,cpd_12
		inc_error_cnt
cpd_12:		cpd
		jp	p,cpd_13
		inc_error_cnt
cpd_13:		jp	po,cpd_14
		inc_error_cnt
cpd_14:		jr	z,cpdr_0
		inc_error_cnt
cpdr_0:		ld	a,data_80
		ld	hl,var5
		ld	bc,5
		cpdr
		jp	pe,cpdr_1
		inc_error_cnt
cpdr_1:		jp	p,cpdr_2
		inc_error_cnt
cpdr_2:		jr	z,cpdr_3
		inc_error_cnt
cpdr_3:		ld	a,b
		cp	a,0
		jr	z,cpdr_4
		inc_error_cnt
cpdr_4:		ld	a,c
		cp	a,2
		jr	z,cpdr_5
		inc_error_cnt
cpdr_5:		ld	a,#34      ;bjp was >data_1234
		ld	hl,var5
		ld	bc,5
		cpdr
		jp	po,cpdr_6
		inc_error_cnt
cpdr_6:		jr	nz,cpdr_7
		inc_error_cnt
cpdr_7:		jp	p,cpdr_8
		inc_error_cnt
cpdr_8:		ld	a,#34      ;bjp was >data_1234
		ld	hl,var5
		ld	bc,3
		cpdr
		jp	po,cpdr_9
		inc_error_cnt
cpdr_9:		jr	nz,cpdr_10
		inc_error_cnt
cpdr_10:	jp	m,c_ret_f
		inc_error_cnt

;add a test for the Stephen Warren bug
;  first cut didn't do it. Lots of insts actually work. Gotta be something
;  basically executed from ir1  - like push
c_ret_f:	di
		ld	de, #1122
		push	de
		pop	af
		ld	hl, 0xaa55
		ld	a,7
		cp	0
		ret	z
		push	hl
		pop	af 
		cp	a, data_aa
		jp	z, out_0
		inc_error_cnt



;
;the file portfe.xxx must be examined to see if the proper output is generated
;
out_0:          di		; interrupts are tested, don't muck up output
		ld	a,#30
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
		inc_error_cnt
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
		inc_error_cnt
otdr_1:		out	(c),c
		ld	a,#0d
		out	(c),a
		ld	a,#0a
		out	(c),a
inc_pass:	ld	a,(pass_count)
		inc	a
		ld	(pass_count),a
		ld	hl,error_cnt
		ld	a,(hl)
		cp	a,0
		jr	z,worked
failed:		ld	hl,fail_msg
		ld	b,27
		otir
		ld	hl, bist_adr
		ld      (hl), bist_ack+bist_err
		halt
		nop
		nop
;worked:		passed           ;???? bjp
worked:		ld	hl,match_msg
		ld	b,33
		otir
		ld	hl,pass_msg
		ld	b,45
		otir
		ld	hl, bist_adr
		ld	(hl), bist_ack
		


stop:		halt
		nop
		nop
		nop

int_start:	push	hl
		push	bc
		push    af	; bj  -- this stuff gronks f as well 
		ld 	hl, int_msg
		ld	b, 1
		ld	c, out_port
		otir
		pop     af
		pop	bc
		pop	hl
		reti
		
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
rst_0000_1:	ld	a,(pass_count)
		or	a
		jp	nz,start
		ld	a,1
		ret
;
;		data
;

fail_msg:		db	cr,lf,'instruction test failed',cr,lf
match_msg:		db      lf,'0123456 12345 12345 54321 54321',lf
pass_msg:		db	'If above lines match instruction test passed',lf
int_msg:                db      bell
;message_addr:	equ	#be58

var1:		db	data_ff
var2:		db	data_55
var3:		db	data_80
var4:		db	data_aa
var5:		db	data_7f
;

		org	#7000
t_var1:		db	0
t_var2:		db	0
t_var3:		db	0
t_var4:		db	0
t_var5:		db	0
;
w_var1:		dw	data_1234
w_var2:		dw	data_55aa
w_var3:		dw	data_7fff
w_var4:		dw	data_8000
w_var5:		dw	data_aa55
w_var6:		dw	data_ffff
;
tw_var1:	dw	0
tw_var2:	dw	0
tw_var3:	dw	0
tw_var4:	dw	0
tw_var5:	dw	0
tw_var6:	dw	0
tw_var7:	dw	0
;
error_cnt:	db	0
pass_count:	db	1
;
		org	#7100
stack:		ds	128
stack_end:	equ	$
;
		end start
; only a single pointer in the interrupt table               
		org	#7200
int_tbl:	dw	0
                org     #72fe
int_ptr:	dw	int_start











































































































































































































































































































